# React UI Migration Tasks

**Version:** 2.0.0
**Status:** ⏳ IN PROGRESS - Dependencies Updated, Code Migration Needed
**Last Updated:** January 2025

## Overview

React dependencies have been updated to latest versions, but the code still uses old APIs. This document tracks all necessary code changes.

---

## Current Status

### ✅ Completed
- React 16.10 → 18.3 (dependencies updated)
- React Router 5.x → 6.28 (dependencies updated)
- Bootstrap 4.3 → 5.3.3 (dependencies updated)
- axios 0.21.4 → 1.7.9 (dependencies updated)
- node-sass → sass (dependencies updated)
- `index.js` updated to use `createRoot` (React 18 API)

### ❌ Pending Code Migration

#### 1. React Router v6 Migration
**Files affected:** ~15+ component files
**Priority:** HIGH - App will break until fixed

#### 2. Bootstrap 5 Class Updates
**Files affected:** ~30+ component files
**Priority:** MEDIUM - UI will look broken

---

## Part 1: React Router v6 Migration

### Breaking Changes Summary

| Old (v5) | New (v6) | Impact |
|----------|----------|--------|
| `<Switch>` | `<Routes>` | Replace all occurrences |
| `<Route component={}>` | `<Route element={<>}>` | Change all routes |
| `useHistory()` | `useNavigate()` | Replace hook usage |
| `<Redirect>` | `<Navigate>` | Replace component |
| `history.push()` | `navigate()` | Change method calls |

### Files to Update

#### **Priority 1: Main Router (CRITICAL)**

**File:** `src/react/src/containers/App/App.js`

**Current Code (v5):**
```javascript
import { Route, Switch, useHistory, Redirect } from "react-router";

const App = () => {
  const history = useHistory();

  // ...

  return (
    <Switch>
      <Route path="/login" exact component={LoginForm} />
      <Route path="/reset" exact component={ForgotPassword} />
      <AuthenticatedRoute path="/" exact authenticated={session.token} component={ControlPanelContent} />
    </Switch>
  );
}
```

**New Code (v6):**
```javascript
import { Route, Routes, useNavigate, Navigate } from "react-router-dom";

const App = () => {
  const navigate = useNavigate();

  // ...

  // Replace history.push('/login') with:
  navigate('/login');

  return (
    <Routes>
      <Route path="/login" element={<LoginForm />} />
      <Route path="/reset" element={<ForgotPassword />} />
      <Route path="/" element={
        session.token ? <ControlPanelContent /> : <Navigate to="/login" replace />
      } />
    </Routes>
  );
}
```

**Changes needed:**
1. Line 3: Change imports
2. Line 65: `useHistory()` → `useNavigate()`
3. Line 77: `history.push('/login')` → `navigate('/login')`
4. Line 82-89: Rewrite `AuthenticatedRoute` component
5. Line 97: `<Switch>` → `<Routes>`
6. Lines 98-100+: Update all `<Route>` components

#### **Priority 2: Other Components Using Router**

Search for files using router:
```bash
grep -r "useHistory\|Switch\|Redirect" src/react/src --include="*.js" --include="*.jsx"
```

**Likely files:**
- `src/react/src/components/Login/LoginForm.js`
- `src/react/src/components/ForgotPassword/*.js`
- `src/react/src/containers/ControlPanelContent/*.js`
- Any component with navigation logic

**Pattern to fix:**
```javascript
// OLD
import { useHistory } from 'react-router';
const history = useHistory();
history.push('/path');

// NEW
import { useNavigate } from 'react-router-dom';
const navigate = useNavigate();
navigate('/path');
```

### Migration Steps

1. **Update App.js** (main router)
2. **Search all files** for router usage:
   ```bash
   grep -r "from 'react-router'" src/react/src --include="*.js"
   ```
3. **Update each file** systematically
4. **Test compilation**: `npm run build`
5. **Fix any errors** that arise

---

## Part 2: Bootstrap 5 Migration

### Breaking Changes Summary

| Old (Bootstrap 4) | New (Bootstrap 5) | Files Affected |
|-------------------|-------------------|----------------|
| `.ml-*` | `.ms-*` | ~20 files |
| `.mr-*` | `.me-*` | ~20 files |
| `.pl-*` | `.ps-*` | ~15 files |
| `.pr-*` | `.pe-*` | ~15 files |
| `.float-left` | `.float-start` | ~10 files |
| `.float-right` | `.float-end` | ~10 files |
| `.text-left` | `.text-start` | ~5 files |
| `.text-right` | `.text-end` | ~5 files |
| `data-toggle` | `data-bs-toggle` | ~10 files |
| `data-target` | `data-bs-target` | ~10 files |

### Class Mapping Reference

```javascript
// Margin/Padding
ml-* → ms-*  (margin-left → margin-start)
mr-* → me-*  (margin-right → margin-end)
pl-* → ps-*  (padding-left → padding-start)
pr-* → pe-*  (padding-right → padding-end)

// Float
float-left → float-start
float-right → float-end

// Text alignment
text-left → text-start
text-right → text-end

// Forms
form-group → mb-3 (no longer exists, use margin bottom)
form-control-file → form-control (merged)
custom-select → form-select
custom-file → (removed, use form-control)

// Data attributes
data-toggle → data-bs-toggle
data-target → data-bs-target
data-dismiss → data-bs-dismiss
```

### Files to Update

#### Search Command:
```bash
# Find all files with old Bootstrap 4 classes
grep -r "\.ml-\|\.mr-\|\.pl-\|\.pr-\|float-left\|float-right\|text-left\|text-right\|form-group\|data-toggle\|data-target" \
  src/react/src --include="*.js" --include="*.jsx" --include="*.scss" --include="*.css"
```

#### Common Files:
- `src/react/src/containers/*/` - All container components
- `src/react/src/components/*/` - All UI components
- `src/react/src/**/*.scss` - All stylesheets

### Migration Example

**Before (Bootstrap 4):**
```jsx
<div className="ml-3 mr-2 float-right">
  <button className="btn btn-primary" data-toggle="modal" data-target="#myModal">
    Open
  </button>
</div>
```

**After (Bootstrap 5):**
```jsx
<div className="ms-3 me-2 float-end">
  <button className="btn btn-primary" data-bs-toggle="modal" data-bs-target="#myModal">
    Open
  </button>
</div>
```

### Automated Migration Script

```bash
#!/bin/bash
# bootstrap5-migrate.sh - Automated class replacement

cd src/react/src

# Margin classes
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" \) -exec sed -i 's/\bml-/ms-/g' {} +
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" \) -exec sed -i 's/\bmr-/me-/g' {} +
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" \) -exec sed -i 's/\bpl-/ps-/g' {} +
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" \) -exec sed -i 's/\bpr-/pe-/g' {} +

# Float classes
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" \) -exec sed -i 's/float-left/float-start/g' {} +
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" \) -exec sed -i 's/float-right/float-end/g' {} +

# Text alignment
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" \) -exec sed -i 's/text-left/text-start/g' {} +
find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.scss" \) -exec sed -i 's/text-right/text-end/g' {} +

# Data attributes
find . -type f \( -name "*.js" -o -name "*.jsx" \) -exec sed -i 's/data-toggle/data-bs-toggle/g' {} +
find . -type f \( -name "*.js" -o -name "*.jsx" \) -exec sed -i 's/data-target/data-bs-target/g' {} +
find . -type f \( -name "*.js" -o -name "*.jsx" \) -exec sed -i 's/data-dismiss/data-bs-dismiss/g' {} +

echo "Bootstrap 5 migration complete!"
echo "Review changes and test thoroughly."
```

---

## Part 3: Testing After Migration

### Build Test
```bash
cd src/react
npm install
npm run build
```

**Expected:** No errors, successful build

### Development Test
```bash
npm start
```

**Expected:** App starts without errors

### Browser Test
1. Open http://localhost:3000
2. Check console for errors
3. Test navigation (routing)
4. Test UI elements (Bootstrap)
5. Test forms and modals

---

## Part 4: Estimated Effort

| Task | Complexity | Time | Priority |
|------|------------|------|----------|
| Router v6 - App.js | Medium | 2 hours | CRITICAL |
| Router v6 - Other files | Medium | 4 hours | CRITICAL |
| Bootstrap 5 - Automated script | Low | 1 hour | HIGH |
| Bootstrap 5 - Manual review | Medium | 3 hours | HIGH |
| Testing & fixes | Medium | 4 hours | HIGH |
| **Total** | | **14 hours** | |

---

## Part 5: Migration Checklist

### React Router v6
- [ ] Update `src/react/src/containers/App/App.js`
- [ ] Find all files using `useHistory` and update
- [ ] Find all files using `<Switch>` and update
- [ ] Find all files using `<Redirect>` and update
- [ ] Find all `<Route component={}>` and update to `element={<>}`
- [ ] Test routing in development
- [ ] Fix any navigation errors

### Bootstrap 5
- [ ] Run automated migration script
- [ ] Review changes in git diff
- [ ] Manually check complex components
- [ ] Update any custom SCSS depending on Bootstrap
- [ ] Test UI in development
- [ ] Fix any styling issues

### Final Validation
- [ ] Build succeeds: `npm run build`
- [ ] No console errors in browser
- [ ] All routes work
- [ ] All UI elements display correctly
- [ ] Forms and modals work
- [ ] Responsive design intact

---

## Part 6: Rollback Plan

If migration causes issues:

```bash
# Revert to previous commit
git checkout HEAD~1 src/react/

# Or create branch before migration
git checkout -b react-migration-backup
# Make changes on new branch
git checkout -b react-migration-work
```

---

## Part 7: Resources

### React Router v6
- Official Migration Guide: https://reactrouter.com/en/main/upgrading/v5
- Breaking Changes: https://github.com/remix-run/react-router/blob/main/CHANGELOG.md

### Bootstrap 5
- Migration Guide: https://getbootstrap.com/docs/5.3/migration/
- What's New: https://getbootstrap.com/docs/5.3/getting-started/introduction/

---

## Notes

1. **Don't rush** - Test each change
2. **Use git** - Commit after each working state
3. **Test thoroughly** - UI bugs are subtle
4. **Ask for help** - If stuck, consult docs or community

---

**Status:** 📝 **Documentation Complete** - Ready for implementation
**Next Step:** Start with React Router v6 migration in App.js
