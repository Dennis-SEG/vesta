#!/bin/bash

# Vesta Control Panel - PHP 8 Compatibility Test Script
# Tests all PHP files for PHP 8.0+ compatibility issues

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "================================================================"
echo "  Vesta Control Panel - PHP 8 Compatibility Test"
echo "================================================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if composer exists
if ! command -v composer &> /dev/null; then
    echo -e "${YELLOW}WARNING: Composer not found. Installing PHPCompatibility requires composer.${NC}"
    echo ""
    echo "To install composer:"
    echo "  curl -sS https://getcomposer.org/installer | php"
    echo "  sudo mv composer.phar /usr/local/bin/composer"
    echo ""
    echo "Continuing with manual checks..."
    echo ""
    MANUAL_ONLY=1
fi

# Manual compatibility checks
echo "================================================================"
echo "1. Manual PHP 8 Compatibility Checks"
echo "================================================================"
echo ""

check_deprecated_functions() {
    local func=$1
    local desc=$2
    local count=$(grep -r "\b$func\b" web/ func/ --include="*.php" 2>/dev/null | grep -v "// " | wc -l)

    if [ $count -gt 0 ]; then
        echo -e "${RED}✗ Found $count uses of deprecated function: $func${NC}"
        echo "  Description: $desc"
        grep -rn "\b$func\b" web/ func/ --include="*.php" 2>/dev/null | grep -v "// " | head -5
        echo ""
        return 1
    else
        echo -e "${GREEN}✓ No uses of $func found${NC}"
        return 0
    fi
}

echo "Checking for removed PHP functions..."
echo "--------------------------------------"

issues=0

# Functions removed in PHP 8.0
check_deprecated_functions "create_function" "Removed in PHP 8.0 - Use anonymous functions" || ((issues++))
check_deprecated_functions "each" "Removed in PHP 8.0 - Use foreach instead" || ((issues++))

# Functions removed in PHP 7.0 (check just in case)
check_deprecated_functions "ereg" "Removed in PHP 7.0 - Use preg_match" || ((issues++))
check_deprecated_functions "eregi" "Removed in PHP 7.0 - Use preg_match with /i" || ((issues++))
check_deprecated_functions "split" "Removed in PHP 7.0 - Use explode or preg_split" || ((issues++))
check_deprecated_functions "mysql_connect" "Removed in PHP 7.0 - Use mysqli or PDO" || ((issues++))
check_deprecated_functions "mysql_query" "Removed in PHP 7.0 - Use mysqli or PDO" || ((issues++))

echo ""
echo "Checking for PHP 8 breaking changes..."
echo "---------------------------------------"

# Check for potential null issues
echo "Checking for potential null parameter issues..."
null_issues=$(grep -rn "strlen\s*(\s*\$[^)]*)\s*==" web/ func/ --include="*.php" 2>/dev/null | wc -l)
if [ $null_issues -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found $null_issues potential null parameter issues (strlen, etc.)${NC}"
    echo "  In PHP 8, passing null to strlen() triggers deprecation warning"
    echo "  Consider using null coalescing: strlen(\$var ?? '')"
    ((issues++))
else
    echo -e "${GREEN}✓ No obvious null parameter issues${NC}"
fi

# Check for string offsets
echo ""
echo "Checking for empty string offset access..."
offset_issues=$(grep -rn '\$[a-zA-Z_][a-zA-Z0-9_]*\[[^]]*\]\s*=\s*' web/ func/ --include="*.php" 2>/dev/null | grep -v "//" | wc -l)
if [ $offset_issues -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found $offset_issues array assignments (check for empty string offset)${NC}"
    echo "  In PHP 8, cannot assign to empty string offset"
else
    echo -e "${GREEN}✓ No obvious string offset issues${NC}"
fi

# Check for implicit numeric string conversions
echo ""
echo "Checking for numeric string operations..."
numeric_issues=$(grep -rn '"\d\+".*[+\-*/]' web/ func/ --include="*.php" 2>/dev/null | wc -l)
if [ $numeric_issues -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found $numeric_issues potential numeric string operations${NC}"
    echo "  PHP 8 has stricter rules for numeric string handling"
else
    echo -e "${GREEN}✓ No obvious numeric string issues${NC}"
fi

echo ""
echo "================================================================"
echo "2. File Statistics"
echo "================================================================"
echo ""

php_files=$(find web/ func/ -name "*.php" -type f 2>/dev/null | wc -l)
echo "Total PHP files to check: $php_files"

web_files=$(find web/ -name "*.php" -type f 2>/dev/null | wc -l)
echo "  - Web interface: $web_files files"

func_files=$(find func/ -name "*.php" -type f 2>/dev/null | wc -l)
echo "  - Functions: $func_files files"

echo ""

# Composer-based automated check
if [ -z "$MANUAL_ONLY" ]; then
    echo "================================================================"
    echo "3. Automated PHP Compatibility Check (PHPCompatibility)"
    echo "================================================================"
    echo ""

    if [ ! -f "composer.json" ]; then
        echo "Creating composer.json..."
        cat > composer.json << 'EOF'
{
    "require-dev": {
        "phpcompatibility/php-compatibility": "^9.3",
        "squizlabs/php_codesniffer": "^3.7"
    },
    "config": {
        "allow-plugins": {
            "dealerdirect/phpcodesniffer-composer-installer": true
        }
    }
}
EOF
    fi

    if [ ! -d "vendor" ]; then
        echo "Installing PHPCompatibility via composer..."
        composer install --dev --no-interaction
        echo ""
    fi

    if [ -f "vendor/bin/phpcs" ]; then
        echo "Running PHPCompatibility scanner..."
        echo "This may take a few minutes..."
        echo ""

        # Create report directory
        mkdir -p reports

        # Run PHP 8.3 compatibility check
        echo "Checking PHP 8.3 compatibility..."
        vendor/bin/phpcs -p web/ func/ \
            --standard=PHPCompatibility \
            --runtime-set testVersion 8.3 \
            --report=summary \
            --report-file=reports/php8-compatibility-summary.txt \
            2>&1 | tee reports/php8-compatibility-full.txt

        echo ""
        echo "Reports saved to:"
        echo "  - reports/php8-compatibility-summary.txt"
        echo "  - reports/php8-compatibility-full.txt"
        echo ""

        # Check if there are errors
        if grep -q "FOUND 0 ERRORS" reports/php8-compatibility-summary.txt; then
            echo -e "${GREEN}✓ No PHP 8 compatibility errors found!${NC}"
        else
            echo -e "${YELLOW}⚠ PHP 8 compatibility issues found. Check reports/ directory.${NC}"
            ((issues++))
        fi
    fi
fi

echo ""
echo "================================================================"
echo "4. Specific PHP 8 Pattern Checks"
echo "================================================================"
echo ""

# Check for old array access
echo "Checking for curly brace array access..."
curly_issues=$(grep -rn '\$[a-zA-Z_][a-zA-Z0-9_]*{' web/ func/ --include="*.php" 2>/dev/null | wc -l)
if [ $curly_issues -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found $curly_issues uses of curly brace array/string access${NC}"
    echo "  PHP 8 deprecated \$var{0}, use \$var[0] instead"
    ((issues++))
else
    echo -e "${GREEN}✓ No curly brace array access found${NC}"
fi

# Check for old constructor names
echo ""
echo "Checking for PHP 4 style constructors..."
php4_constructors=$(grep -rn "function \+[A-Z][a-zA-Z0-9_]*\s*(" web/ func/ --include="*.php" 2>/dev/null | \
    grep -v "function __construct" | grep -v "function __" | wc -l)
if [ $php4_constructors -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found $php4_constructors potential PHP 4 style constructors${NC}"
    echo "  PHP 8 removed PHP 4 constructors, use __construct()"
    ((issues++))
else
    echo -e "${GREEN}✓ No PHP 4 style constructors found${NC}"
fi

# Check for assertions
echo ""
echo "Checking for assert() usage..."
assert_usage=$(grep -rn "\bassert\s*(" web/ func/ --include="*.php" 2>/dev/null | wc -l)
if [ $assert_usage -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found $assert_usage uses of assert()${NC}"
    echo "  PHP 8 changed assert() behavior, review usage"
else
    echo -e "${GREEN}✓ No assert() usage found${NC}"
fi

echo ""
echo "================================================================"
echo "5. Recommendations"
echo "================================================================"
echo ""

if [ $issues -eq 0 ]; then
    echo -e "${GREEN}✓ No critical PHP 8 compatibility issues detected!${NC}"
    echo ""
    echo "The codebase appears to be PHP 8 compatible based on automated checks."
    echo "However, manual testing on PHP 8.3 is still required to catch:"
    echo "  - Runtime type errors"
    echo "  - Behavioral changes"
    echo "  - Edge cases"
else
    echo -e "${YELLOW}⚠ Found $issues potential compatibility issues${NC}"
    echo ""
    echo "Recommendations:"
    echo "  1. Review all flagged issues above"
    echo "  2. Test on PHP 8.3 development environment"
    echo "  3. Enable error_reporting = E_ALL in php.ini"
    echo "  4. Monitor error logs: /var/log/php8.3-fpm-error.log"
    echo "  5. Run functional tests after fixes"
fi

echo ""
echo "Next steps:"
echo "  1. Fix any issues found above"
echo "  2. Test on PHP 8.3 VM: bash install/INSTALL_COMPLETE.sh -e test@example.com"
echo "  3. Access control panel and test all features"
echo "  4. Check logs: tail -f /var/log/php8.3-fpm-error.log"
echo ""

echo "================================================================"
echo "Test Complete"
echo "================================================================"

exit 0
