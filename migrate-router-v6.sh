#!/bin/bash
# React Router v6 Migration Script

echo "Starting React Router v6 migration..."

cd src/react/src

# Step 1: Replace useHistory with useNavigate in imports
echo "Step 1: Updating imports..."
find . -type f \( -name "*.js" -o -name "*.jsx" \) -exec sed -i 's/useHistory/useNavigate/g' {} +

# Step 2: Replace const history = useNavigate() with const navigate = useNavigate()
echo "Step 2: Updating variable declarations..."
find . -type f \( -name "*.js" -o -name "*.jsx" \) -exec sed -i 's/const history = useNavigate()/const navigate = useNavigate()/g' {} +

# Step 3: Replace history.push with navigate
echo "Step 3: Updating history.push calls..."
find . -type f \( -name "*.js" -o -name "*.jsx" \) -exec sed -i 's/history\.push(/navigate(/g' {} +

# Step 4: Replace history.replace with navigate(..., { replace: true })
# This is more complex and might need manual review
echo "Step 4: Updating history.replace calls..."
find . -type f \( -name "*.js" -o -name "*.jsx" \) -exec sed -i 's/history\.replace(/navigate(/g' {} +

# Step 5: Replace history.goBack() with navigate(-1)
echo "Step 5: Updating history.goBack calls..."
find . -type f \( -name "*.js" -o -name "*.jsx" \) -exec sed -i 's/history\.goBack()/navigate(-1)/g' {} +

# Step 6: Replace history.location with window.location
echo "Step 6: Updating history.location references..."
find . -type f \( -name "*.js" -o -name "*.jsx" \) -exec sed -i 's/history\.location/window.location/g' {} +

# Step 7: Update dependency array references (history -> navigate)
echo "Step 7: Updating dependency arrays..."
find . -type f \( -name "*.js" -o -name "*.jsx" \) -exec sed -i 's/\[history\]/[navigate]/g' {} +
find . -type f \( -name "*.js" -o -name "*.jsx" \) -exec sed -i 's/, history\]/, navigate]/g' {} +
find . -type f \( -name "*.js" -o -name "*.jsx" \) -exec sed -i 's/\[history,/[navigate,/g' {} +

echo "Migration complete!"
echo "Please review changes and test thoroughly."
