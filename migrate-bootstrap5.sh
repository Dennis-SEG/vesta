#!/bin/bash
# Bootstrap 5 Migration Script

echo "Starting Bootstrap 5 class migration..."

cd src/react/src

# Margin classes
echo "Migrating margin classes..."
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" -o -name "*.css" \) -exec sed -i 's/\bml-/ms-/g' {} +
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" -o -name "*.css" \) -exec sed -i 's/\bmr-/me-/g' {} +
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" -o -name "*.css" \) -exec sed -i 's/\bpl-/ps-/g' {} +
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" -o -name "*.css" \) -exec sed -i 's/\bpr-/pe-/g' {} +

# Float classes
echo "Migrating float classes..."
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" -o -name "*.css" \) -exec sed -i 's/float-left/float-start/g' {} +
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" -o -name "*.css" \) -exec sed -i 's/float-right/float-end/g' {} +

# Text alignment
echo "Migrating text alignment classes..."
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" -o -name "*.css" \) -exec sed -i 's/text-left/text-start/g' {} +
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" -o -name "*.css" \) -exec sed -i 's/text-right/text-end/g' {} +

# Data attributes
echo "Migrating data attributes..."
find . -type f \( -name "*.js" -o -name "*.jsx" \) -exec sed -i 's/data-toggle/data-bs-toggle/g' {} +
find . -type f \( -name "*.js" -o -name "*.jsx" \) -exec sed -i 's/data-target/data-bs-target/g' {} +
find . -type f \( -name "*.js" -o -name "*.jsx" \) -exec sed -i 's/data-dismiss/data-bs-dismiss/g' {} +

# Form classes
echo "Migrating form classes..."
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" -o -name "*.css" \) -exec sed -i 's/custom-select/form-select/g' {} +

echo "Bootstrap 5 migration complete!"
echo "Please review changes, especially:"
echo "- form-group classes (removed in BS5, use mb-3 instead)"
echo "- custom-file classes (removed, use form-control)"
echo "- Test UI thoroughly for any visual regressions"
