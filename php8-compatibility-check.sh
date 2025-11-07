#!/bin/bash

echo "==================================================================="
echo "  PHP 8 Compatibility Deep Scan"
echo "==================================================================="
echo ""

ISSUES=0

# 1. Check for deprecated/removed functions
echo "1. Checking for deprecated/removed functions..."
echo "-------------------------------------------------------------------"

check_function() {
    local func=$1
    local reason=$2
    local count=$(grep -r "\b$func\s*(" web/ --include="*.php" 2>/dev/null | grep -v "//" | wc -l)
    if [ $count -gt 0 ]; then
        echo "⚠ Found $count uses of: $func"
        echo "  Reason: $reason"
        grep -rn "\b$func\s*(" web/ --include="*.php" 2>/dev/null | grep -v "//" | head -3
        echo ""
        ISSUES=$((ISSUES + count))
    fi
}

check_function "create_function" "Removed in PHP 8.0"
check_function "each" "Removed in PHP 8.0"
check_function "money_format" "Removed in PHP 8.0"  
check_function "ezmlm_hash" "Removed in PHP 8.0"
check_function "restore_include_path" "Removed in PHP 8.0"
check_function "get_magic_quotes_gpc" "Removed in PHP 8.0"
check_function "get_magic_quotes_runtime" "Removed in PHP 8.0"

# 2. Check for problematic patterns
echo ""
echo "2. Checking for problematic patterns..."
echo "-------------------------------------------------------------------"

# Implicit string to number conversion
count=$(grep -rE "\"[0-9]+\"\s*[\+\-\*\/]" web/ --include="*.php" 2>/dev/null | wc -l)
if [ $count -gt 0 ]; then
    echo "⚠ Found $count potential string/number conversion issues"
    ISSUES=$((ISSUES + count))
fi

# Array access on null
count=$(grep -rE "\$[a-zA-Z_][a-zA-Z0-9_]*\[['\"]" web/ --include="*.php" 2>/dev/null | wc -l)
if [ $count -gt 100 ]; then
    echo "ℹ Found $count array accesses (check for null safety)"
fi

# 3. Check for @ error suppression (bad practice)
echo ""
echo "3. Checking for error suppression..."
echo "-------------------------------------------------------------------"
count=$(grep -r "@\$" web/ --include="*.php" 2>/dev/null | wc -l)
count2=$(grep -rE "@[a-z_]+\(" web/ --include="*.php" 2>/dev/null | wc -l)
total=$((count + count2))
if [ $total -gt 0 ]; then
    echo "⚠ Found $total uses of @ error suppression"
    echo "  (Can hide PHP 8 errors)"
fi

# 4. Check for mysql_* functions (removed in PHP 7)
echo ""
echo "4. Checking for old mysql_* functions..."
echo "-------------------------------------------------------------------"
count=$(grep -rE "mysql_(connect|query|fetch|close)" web/ --include="*.php" 2>/dev/null | grep -v "//" | wc -l)
if [ $count -gt 0 ]; then
    echo "❌ CRITICAL: Found $count uses of old mysql_* functions"
    echo "  These were removed in PHP 7.0!"
    grep -rn "mysql_" web/ --include="*.php" 2>/dev/null | grep -v "//" | head -5
    ISSUES=$((ISSUES + count * 10))
fi

# 5. Check for implicit type coercion in comparisons
echo ""
echo "5. Checking for loose comparisons..."
echo "-------------------------------------------------------------------"
count=$(grep -rE "==\s*['\"]" web/ --include="*.php" 2>/dev/null | wc -l)
if [ $count -gt 50 ]; then
    echo "ℹ Found $count loose comparisons (== instead of ===)"
    echo "  PHP 8 is stricter with type juggling"
fi

# 6. Check for isset() on array access
echo ""
echo "6. Checking for safe array access patterns..."
echo "-------------------------------------------------------------------"
safe=$(grep -r "isset(" web/ --include="*.php" 2>/dev/null | wc -l)
unsafe=$(grep -rE "\\$_GET\[|\$_POST\[|\$_REQUEST\[" web/ --include="*.php" 2>/dev/null | wc -l)
echo "✓ Found $safe isset() checks"
echo "ℹ Found $unsafe superglobal array accesses"

# 7. Check for switch() fallthrough without comment
echo ""
echo "7. Checking for switch fallthrough..."
echo "-------------------------------------------------------------------"
count=$(grep -A5 "case.*:" web/ --include="*.php" -r 2>/dev/null | grep -v "break" | grep -v "return" | grep -v "//" | wc -l)
if [ $count -gt 20 ]; then
    echo "⚠ Potential switch fallthrough cases: $count"
fi

echo ""
echo "==================================================================="
echo "SUMMARY"
echo "==================================================================="
echo "Total potential issues found: $ISSUES"
echo ""
if [ $ISSUES -eq 0 ]; then
    echo "✓ No major PHP 8 compatibility issues detected"
    echo "  (But still needs runtime testing!)"
else
    echo "⚠ Found compatibility concerns that need review"
fi
echo ""
