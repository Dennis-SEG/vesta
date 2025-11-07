# Vesta Control Panel 2.0 - GitHub Issues Tracking

**Version:** 2.0.0 (Modernized)
**Last Updated:** January 2025

## Overview

This document tracks all issues that need to be created on GitHub for the 2.0.0 release. Use this as a template for creating individual issues.

---

## Critical Issues (Must Fix Before Production)

### Issue #1: React Router v6 Code Migration Needed
**Title:** Migrate React UI code to Router v6 API
**Labels:** `enhancement`, `react`, `critical`, `good first issue`
**Priority:** CRITICAL

**Description:**
Dependencies updated to React Router v6, but code still uses v5 patterns. App will not work correctly until migration complete.

**Current State:**
- Using `<Switch>` instead of `<Routes>`
- Using `component={}` prop instead of `element={<>}`
- Using `useHistory()` instead of `useNavigate()`
- Using `<Redirect>` instead of `<Navigate>`

**Files Affected:**
- `src/react/src/containers/App/App.js` (main router)
- ~15 other component files

**Steps to Fix:**
See `REACT_UI_MIGRATION_TASKS.md` for complete migration guide

**Acceptance Criteria:**
- [ ] All Router v5 patterns replaced with v6
- [ ] `npm run build` succeeds
- [ ] All routes work correctly
- [ ] No console errors

**Estimated Effort:** 6 hours

---

### Issue #2: Bootstrap 5 Class Updates Needed
**Title:** Update Bootstrap 4 classes to Bootstrap 5
**Labels:** `enhancement`, `ui`, `bootstrap`, `good first issue`
**Priority:** HIGH

**Description:**
Bootstrap upgraded to v5 but code uses v4 class names. UI will render incorrectly.

**Breaking Changes:**
- `ml-*` → `ms-*`
- `mr-*` → `me-*`
- `float-left` → `float-start`
- `data-toggle` → `data-bs-toggle`

**Files Affected:**
- ~30 component files
- All `.scss` stylesheets

**Steps to Fix:**
1. Run automated migration script (provided in REACT_UI_MIGRATION_TASKS.md)
2. Manual review of complex components
3. Test UI thoroughly

**Acceptance Criteria:**
- [ ] All Bootstrap 4 classes updated
- [ ] UI displays correctly
- [ ] No styling regressions
- [ ] Responsive design intact

**Estimated Effort:** 4 hours

---

### Issue #3: VM Installation Testing Required
**Title:** Test installers on actual VMs before production release
**Labels:** `testing`, `critical`, `help wanted`
**Priority:** CRITICAL

**Description:**
Modern installers have NOT been tested on real VMs. Must test before declaring production-ready.

**Testing Required:**
- [ ] Ubuntu 20.04 + PHP 8.3
- [ ] Ubuntu 22.04 + PHP 8.3
- [ ] Ubuntu 24.04 + PHP 8.3
- [ ] Debian 11 + PHP 8.3
- [ ] Debian 12 + PHP 8.3
- [ ] Rocky Linux 9 + PHP 8.3

**Test Procedure:**
See `VM_TEST_PLAN.md` for complete testing steps

**Acceptance Criteria:**
- [ ] All critical tests pass
- [ ] All services start correctly
- [ ] Control panel accessible
- [ ] No PHP errors in logs
- [ ] All features functional

**Help Needed:**
Looking for volunteers to test on their VMs and report results

**Estimated Effort:** 8-16 hours (across multiple testers)

---

### Issue #4: PHP 8 Compatibility Validation
**Title:** Validate all existing PHP code for PHP 8 compatibility
**Labels:** `php8`, `testing`, `high priority`
**Priority:** HIGH

**Description:**
324 PHP files need validation for PHP 8 compatibility. Initial scan shows no obvious issues, but runtime testing required.

**Steps:**
1. Install composer and PHPCompatibility: See `test-php8-compatibility.sh`
2. Run compatibility checker on all PHP files
3. Fix any issues found
4. Test on PHP 8.3 VM

**Files to Check:**
- `web/**/*.php` (324 files - web interface)
- `func/**/*.php` (function libraries)

**Known Potential Issues:**
- Stricter null handling
- Type juggling changes
- Parameter order sensitivity

**Acceptance Criteria:**
- [ ] PHPCompatibility scan passes
- [ ] No PHP errors during functional testing
- [ ] All features work on PHP 8.3

**Estimated Effort:** 8 hours

---

## High Priority Issues

### Issue #5: Let's Encrypt SSL Testing
**Title:** Test Let's Encrypt SSL automation on live domains
**Labels:** `testing`, `ssl`, `enhancement`
**Priority:** HIGH

**Description:**
`bin/v-add-letsencrypt-domain-modern` uses acme.sh but hasn't been tested with real domains.

**Testing Needed:**
- [ ] Test SSL issuance for new domain
- [ ] Test SSL renewal
- [ ] Test multi-domain certificates
- [ ] Test wildcard certificates
- [ ] Test auto-renewal cron

**Requirements:**
- VM with public IP
- Real domain pointing to VM
- Port 80/443 accessible

**Acceptance Criteria:**
- [ ] SSL certificates issue successfully
- [ ] Auto-renewal works
- [ ] Certificates install correctly

**Estimated Effort:** 4 hours

---

### Issue #6: fail2ban Jail Testing
**Title:** Validate fail2ban jails are working correctly
**Labels:** `security`, `testing`, `fail2ban`
**Priority:** HIGH

**Description:**
15 fail2ban jails configured but need testing to ensure they work.

**Jails to Test:**
- [ ] sshd (SSH brute force)
- [ ] vesta (panel login)
- [ ] exim (SMTP brute force)
- [ ] dovecot (IMAP/POP3 brute force)
- [ ] nginx-http-auth
- [ ] apache-auth
- [ ] mysqld-auth
- [ ] phpmyadmin-auth
- [ ] vsftpd
- [ ] recidive (repeat offenders)

**Test Method:**
1. Trigger failed logins
2. Verify IP gets banned
3. Check `fail2ban-client status jail-name`
4. Verify unban works

**Acceptance Criteria:**
- [ ] All jails detect attacks
- [ ] IPs banned correctly
- [ ] Ban times appropriate
- [ ] No false positives

**Estimated Effort:** 6 hours

---

### Issue #7: Database Migration from Old Vesta
**Title:** Test migration from old Vesta installations
**Labels:** `migration`, `testing`, `documentation`
**Priority:** HIGH

**Description:**
MIGRATION_GUIDE.md provides procedures but needs real-world testing.

**Test Scenarios:**
- [ ] Fresh install + data migration (recommended path)
- [ ] In-place upgrade (risky path)
- [ ] PHP 5.x → PHP 8.3 migration
- [ ] PHP 7.4 → PHP 8.3 migration
- [ ] Old Ubuntu → New Ubuntu

**Test Applications:**
- [ ] WordPress sites
- [ ] Joomla sites
- [ ] Drupal sites
- [ ] Custom PHP applications

**Acceptance Criteria:**
- [ ] Migration guide accurate
- [ ] No data loss
- [ ] All applications work after migration
- [ ] Clear rollback procedures

**Estimated Effort:** 16 hours

---

## Medium Priority Issues

### Issue #8: Performance Benchmarking
**Title:** Establish performance benchmarks for PHP 8.3
**Labels:** `performance`, `testing`
**Priority:** MEDIUM

**Description:**
Need baseline performance metrics to compare against old Vesta.

**Benchmarks to Measure:**
- [ ] PHP requests per second
- [ ] Database queries per second
- [ ] Page load times
- [ ] Memory usage
- [ ] CPU usage

**Tools:**
- Apache Bench (ab)
- mysqlslap
- Custom scripts

**Acceptance Criteria:**
- [ ] Baseline metrics established
- [ ] Performance equal or better than old Vesta
- [ ] Documented in TESTING.md

**Estimated Effort:** 4 hours

---

### Issue #9: Documentation Review
**Title:** Community review of all documentation
**Labels:** `documentation`, `help wanted`
**Priority:** MEDIUM

**Description:**
11 documentation files created - need community review for accuracy and clarity.

**Documents to Review:**
- [ ] README.md
- [ ] TESTING.md
- [ ] RELEASE_NOTES.md
- [ ] MIGRATION_GUIDE.md
- [ ] SYSTEM_REQUIREMENTS.md
- [ ] INSTALLER_UPDATE_PLAN.md
- [ ] VM_TEST_PLAN.md
- [ ] REACT_UI_MIGRATION_TASKS.md
- [ ] CONTRIBUTING.md
- [ ] UPGRADE_NOTES.md
- [ ] SECURITY.md

**Acceptance Criteria:**
- [ ] No technical inaccuracies
- [ ] Clear and understandable
- [ ] Code examples work
- [ ] Links valid

**Estimated Effort:** 4 hours

---

### Issue #10: Automated Testing Suite
**Title:** Create automated test suite for CI/CD
**Labels:** `testing`, `ci/cd`, `enhancement`
**Priority:** MEDIUM

**Description:**
GitHub Actions workflows created but need comprehensive test suite.

**Tests Needed:**
- [ ] Installer smoke tests
- [ ] PHP syntax validation
- [ ] Bash script validation (shellcheck)
- [ ] Configuration validation
- [ ] Integration tests

**Acceptance Criteria:**
- [ ] Tests run automatically on PR
- [ ] Clear pass/fail indicators
- [ ] Fast execution (< 10 minutes)

**Estimated Effort:** 12 hours

---

## Low Priority Issues (Nice to Have)

### Issue #11: Docker Support
**Title:** Add Docker/Docker Compose support
**Labels:** `enhancement`, `docker`, `future`
**Priority:** LOW

**Description:**
Create Dockerfile and docker-compose.yml for development/testing.

**Benefits:**
- Easy development environment
- Consistent testing
- Modern deployment option

**Estimated Effort:** 8 hours

---

### Issue #12: API v2 with OpenAPI Spec
**Title:** Modernize REST API with OpenAPI 3.0 specification
**Labels:** `enhancement`, `api`, `future`
**Priority:** LOW

**Description:**
Current API lacks formal specification. Create OpenAPI 3.0 spec.

**Benefits:**
- Auto-generated documentation
- Client SDK generation
- API testing tools

**Estimated Effort:** 16 hours

---

### Issue #13: Multi-Server Management
**Title:** Add support for managing multiple Vesta servers
**Labels:** `enhancement`, `feature`, `future`
**Priority:** LOW

**Description:**
Allow one panel to manage multiple Vesta installations.

**Use Case:**
- Hosting providers with multiple servers
- Agencies managing client servers

**Estimated Effort:** 40+ hours

---

## Issue Templates

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. See error

**Expected behavior**
What you expected to happen.

**Actual behavior**
What actually happened.

**Environment:**
- OS: [e.g. Ubuntu 22.04]
- PHP Version: [e.g. 8.3]
- Vesta Version: [e.g. 2.0.0]

**Logs:**
Paste relevant error logs here.

**Screenshots:**
If applicable, add screenshots.
```

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of the problem.

**Describe the solution you'd like**
What you want to happen.

**Describe alternatives you've considered**
Other solutions you've thought about.

**Additional context**
Any other information.
```

---

## Summary Statistics

| Priority | Count | Total Effort |
|----------|-------|--------------|
| CRITICAL | 4 | 28-36 hours |
| HIGH | 3 | 26 hours |
| MEDIUM | 4 | 24 hours |
| LOW | 3 | 64+ hours |
| **TOTAL** | **14** | **142+ hours** |

**Critical Path to Production:** Issues #1, #2, #3, #4 must be resolved

---

## How to Create These Issues

1. Go to https://github.com/outroll/vesta/issues
2. Click "New Issue"
3. Copy template from this document
4. Add appropriate labels
5. Assign if you plan to work on it

**Or create all at once using GitHub CLI:**
```bash
# Example for Issue #1
gh issue create \
  --title "Migrate React UI code to Router v6 API" \
  --body-file issue-templates/issue-1.md \
  --label "enhancement,react,critical"
```

---

**Status:** 📋 **Ready for GitHub Issue Creation**
**Next Step:** Create issues #1-4 (critical) first, then others as needed
