# Vesta Control Panel 2.0 - VM Test Plan

**Version:** 2.0.0 (Modernized)
**Last Updated:** January 2025
**Status:** Pre-Release Testing Required

## Overview

This document provides step-by-step testing procedures to validate Vesta Control Panel 2.0 installations on virtual machines before production release.

---

## Test Matrix

### Required Test Environments

| OS | Version | PHP | Status | Priority |
|---|---|---|---|---|
| Ubuntu | 20.04 LTS | 8.3 | ⏳ Pending | HIGH |
| Ubuntu | 22.04 LTS | 8.3 | ⏳ Pending | CRITICAL |
| Ubuntu | 24.04 LTS | 8.3 | ⏳ Pending | HIGH |
| Debian | 11 (Bullseye) | 8.3 | ⏳ Pending | MEDIUM |
| Debian | 12 (Bookworm) | 8.3 | ⏳ Pending | HIGH |
| Rocky Linux | 9 | 8.3 | ⏳ Pending | MEDIUM |

### Optional Test Combinations

| OS | PHP Version | Purpose |
|---|---|---|
| Ubuntu 22.04 | 8.2 | Test PHP version selection |
| Ubuntu 22.04 | 8.4 | Test latest PHP |
| Debian 12 | 8.4 | Test bleeding edge |

---

## Pre-Test Setup

### VM Requirements

**Minimum Specs:**
- 2 CPU cores
- 4GB RAM
- 40GB disk space
- Network: Bridge or NAT with port forwarding

**Recommended Specs:**
- 4 CPU cores
- 8GB RAM
- 80GB disk space
- Network: Bridge adapter (for real domain testing)

### VM Preparation

```bash
# 1. Create fresh VM with Ubuntu 22.04
# 2. Update system
sudo apt-get update
sudo apt-get upgrade -y

# 3. Take snapshot "fresh-install"
# (Use VM hypervisor snapshot feature)

# 4. Verify prerequisites
df -h  # Check disk space
free -h  # Check RAM
nproc  # Check CPU cores
```

---

## Test Procedure

### Phase 1: Basic Installation (Critical)

**Objective:** Verify installer completes without errors

**Test 1.1: Default Installation**

```bash
# Download installer
cd /root
wget https://github.com/Dennis-SEG/vesta/raw/master/install/INSTALL_COMPLETE.sh

# Run with minimal options
bash INSTALL_COMPLETE.sh -e test@example.com

# Expected duration: 10-20 minutes
```

**Pass Criteria:**
- [ ] No error messages during installation
- [ ] All packages install successfully
- [ ] Installation completes with "INSTALLATION COMPLETE!" message
- [ ] Admin password displayed and saved to /root/vesta_install_info.txt
- [ ] Time: < 25 minutes

**Fail Criteria:**
- Any installation error
- Package installation failure
- Service start failure
- Missing credentials file

**Test 1.2: Custom PHP Version**

```bash
# Restore to snapshot
# Test PHP 8.2
bash INSTALL_COMPLETE.sh --php 8.2 -e test@example.com
php -v  # Should show 8.2.x

# Test PHP 8.4
bash INSTALL_COMPLETE.sh --php 8.4 -e test@example.com
php -v  # Should show 8.4.x
```

**Pass Criteria:**
- [ ] Requested PHP version installed
- [ ] php -v shows correct version

**Test 1.3: Full Options**

```bash
bash INSTALL_COMPLETE.sh \
  --php 8.3 \
  -e admin@testdomain.com \
  -p TestPassword123! \
  -s vesta.testdomain.com \
  --ssl no
```

**Pass Criteria:**
- [ ] Custom email saved
- [ ] Custom password works
- [ ] Hostname set correctly

---

### Phase 2: Service Verification (Critical)

**Objective:** All services are running and accessible

**Test 2.1: Service Status**

```bash
# Check all services
systemctl status nginx
systemctl status apache2
systemctl status php8.3-fpm
systemctl status mariadb
systemctl status exim4
systemctl status dovecot
systemctl status bind9
systemctl status vsftpd
systemctl status fail2ban
systemctl status vesta
```

**Pass Criteria:**
- [ ] All services show "active (running)"
- [ ] No failed services
- [ ] No error messages in status

**Log Failures:**
```bash
# If any service fails:
journalctl -xe -u service-name
```

**Test 2.2: Port Accessibility**

```bash
# Check listening ports
ss -tulpn | grep -E ':(80|443|8083|25|587|993|995|53|21)\b'
```

**Expected Ports:**
- [ ] 80 (HTTP) - nginx
- [ ] 443 (HTTPS) - nginx
- [ ] 8083 (Vesta) - vesta
- [ ] 25 (SMTP) - exim4
- [ ] 587 (Submission) - exim4
- [ ] 993 (IMAPS) - dovecot
- [ ] 995 (POP3S) - dovecot
- [ ] 53 (DNS) - bind9
- [ ] 21 (FTP) - vsftpd

**Test 2.3: Process Verification**

```bash
# Check PHP-FPM processes
ps aux | grep php-fpm | grep -v grep

# Check Nginx workers
ps aux | grep nginx | grep -v grep

# Check Apache workers
ps aux | grep apache2 | grep -v grep
```

**Pass Criteria:**
- [ ] PHP-FPM master + worker processes running
- [ ] Nginx master + worker processes running
- [ ] Apache2 processes running

---

### Phase 3: Control Panel Access (Critical)

**Objective:** Web interface is accessible and functional

**Test 3.1: Panel Access**

```bash
# Get server IP
ip addr show | grep inet

# From browser:
https://SERVER_IP:8083
```

**Pass Criteria:**
- [ ] Page loads (may have SSL warning - expected for self-signed)
- [ ] Login page displays
- [ ] No blank page or errors
- [ ] Vesta branding visible

**Test 3.2: Login**

```bash
# Get credentials
cat /root/vesta_install_info.txt

# Login with:
# Username: admin
# Password: (from file)
```

**Pass Criteria:**
- [ ] Login succeeds
- [ ] Dashboard loads
- [ ] No JavaScript errors in browser console
- [ ] UI elements visible

**Test 3.3: Navigation**

Click through:
- [ ] Dashboard
- [ ] Users
- [ ] Web
- [ ] DNS
- [ ] Mail
- [ ] Database
- [ ] Cron
- [ ] Backup

**Pass Criteria:**
- [ ] All pages load
- [ ] No 404 errors
- [ ] No PHP errors

---

### Phase 4: Functional Testing (High Priority)

**Objective:** Core features work correctly

**Test 4.1: Create Domain**

```bash
# Via UI:
# 1. Click "WEB"
# 2. Click "Add Web Domain"
# 3. Enter: test.local
# 4. Click "Add"
```

**Pass Criteria:**
- [ ] Domain created without errors
- [ ] Apache config created: /etc/apache2/sites-available/test.local.conf
- [ ] Nginx config created: /etc/nginx/conf.d/test.local.conf
- [ ] DNS zone created: check Bind

**Test via CLI:**
```bash
# Check domain
curl -H "Host: test.local" http://localhost

# Should return default page or 200 status
```

**Test 4.2: Create User**

```bash
# Via UI:
# 1. Click "USER"
# 2. Click "Add User"
# 3. Username: testuser
# 4. Password: TestPassword123!
# 5. Email: test@example.com
# 6. Click "Add"
```

**Pass Criteria:**
- [ ] User created
- [ ] Home directory created: /home/testuser/
- [ ] PHP-FPM pool created: /etc/php/8.3/fpm/pool.d/testuser.conf
- [ ] User can login to panel

**Test 4.3: Create Database**

```bash
# Via UI:
# 1. Click "DB"
# 2. Click "Add Database"
# 3. Database: testdb
# 4. User: testdbuser
# 5. Password: DbPassword123!
# 6. Click "Add"
```

**Pass Criteria:**
- [ ] Database created
- [ ] User created with access
- [ ] Can connect:

```bash
mysql -u testdbuser -p testdb
# Enter password: DbPassword123!
# Should connect successfully
```

**Test 4.4: Create Mail Domain**

```bash
# Via UI:
# 1. Click "MAIL"
# 2. Click "Add Mail Domain"
# 3. Domain: mail.test.local
# 4. Click "Add"
```

**Pass Criteria:**
- [ ] Mail domain created
- [ ] Exim accepts mail for domain

**Test 4.5: Create Mailbox**

```bash
# Via UI:
# 1. Select mail.test.local
# 2. Click "Add Mail Account"
# 3. Account: info
# 4. Password: MailPassword123!
# 5. Click "Add"
```

**Pass Criteria:**
- [ ] Mailbox created
- [ ] Can test with telnet:

```bash
telnet localhost 110
USER info@mail.test.local
PASS MailPassword123!
# Should authenticate
```

---

### Phase 5: PHP 8 Compatibility Testing (Critical)

**Objective:** PHP code executes without errors

**Test 5.1: Error Log Monitoring**

```bash
# Start monitoring in separate terminal
tail -f /var/log/php8.3-fpm-error.log
```

**Test 5.2: Exercise All Panel Features**

While monitoring logs, perform:
1. Create/edit domain
2. Create/edit user
3. Create/edit database
4. Create/edit mail domain
5. Create/edit cron job
6. View statistics
7. Change settings
8. Run backup

**Pass Criteria:**
- [ ] No PHP errors in log
- [ ] No deprecated warnings
- [ ] No fatal errors
- [ ] No type errors

**Common PHP 8 Issues to Watch:**
```
Deprecated: strlen(): Passing null to parameter
TypeError: Argument must be of type string, null given
```

**Test 5.3: PHP Info Check**

```bash
# Create phpinfo file
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# Visit: http://SERVER_IP/info.php
```

**Verify:**
- [ ] PHP Version: 8.3.x
- [ ] Loaded extensions: mysqli, pdo_mysql, gd, mbstring, xml, etc.
- [ ] OPcache enabled
- [ ] display_errors: Off (production)
- [ ] error_log configured

**Delete after test:**
```bash
rm /var/www/html/info.php
```

---

### Phase 6: Security Testing (High Priority)

**Objective:** Security features are working

**Test 6.1: Firewall Rules**

```bash
# Check iptables rules
iptables -L -n

# Should see rules for:
# - Port 22 (SSH)
# - Port 80 (HTTP)
# - Port 443 (HTTPS)
# - Port 8083 (Vesta)
# - Mail ports
# - DNS port
# - FTP ports
```

**Pass Criteria:**
- [ ] Firewall rules applied
- [ ] Required ports open
- [ ] Default deny policy

**Test 6.2: fail2ban**

```bash
# Check fail2ban status
fail2ban-client status

# Check specific jails
fail2ban-client status sshd
fail2ban-client status vesta
```

**Pass Criteria:**
- [ ] fail2ban running
- [ ] Multiple jails active (10+)
- [ ] Jails monitoring logs

**Test 6.3: SSL/TLS**

```bash
# Test SSL certificate
openssl s_client -connect localhost:8083 < /dev/null

# Test TLS versions
openssl s_client -connect localhost:8083 -tls1_2 < /dev/null  # Should work
openssl s_client -connect localhost:8083 -tls1 < /dev/null    # Should fail
```

**Pass Criteria:**
- [ ] SSL certificate present
- [ ] TLS 1.2 accepted
- [ ] TLS 1.3 accepted
- [ ] TLS 1.0/1.1 rejected

**Test 6.4: Database Security**

```bash
# Check MySQL users
mysql -e "SELECT user, host, authentication_string FROM mysql.user;"
```

**Pass Criteria:**
- [ ] No anonymous users
- [ ] Root only from localhost
- [ ] No blank passwords
- [ ] test database removed

---

### Phase 7: Performance Testing (Medium Priority)

**Objective:** System performs adequately

**Test 7.1: Resource Usage**

```bash
# Check memory
free -h

# Check CPU
top -bn1 | head -20

# Check disk
df -h
```

**Pass Criteria:**
- [ ] Memory usage < 80%
- [ ] CPU idle > 50% at rest
- [ ] Disk space adequate

**Test 7.2: Web Performance**

```bash
# Install Apache Bench if needed
apt-get install apache2-utils

# Test static page
ab -n 1000 -c 10 http://localhost/

# Test PHP page (create test.php)
echo "<?php echo 'OK'; ?>" > /var/www/html/test.php
ab -n 1000 -c 10 http://localhost/test.php
```

**Benchmarks:**
- [ ] Static: > 1000 req/s
- [ ] PHP: > 100 req/s
- [ ] No failed requests

---

## Test Results Template

### Test Report

**Date:** YYYY-MM-DD
**Tester:** Name
**Environment:** Ubuntu 22.04 / PHP 8.3

#### Summary
- **Overall Result:** PASS / FAIL
- **Critical Issues:** 0
- **Major Issues:** 0
- **Minor Issues:** 0

#### Phase Results

| Phase | Result | Notes |
|-------|--------|-------|
| 1. Installation | ✅ PASS | |
| 2. Services | ✅ PASS | |
| 3. Control Panel | ✅ PASS | |
| 4. Functionality | ✅ PASS | |
| 5. PHP 8 Compat | ✅ PASS | |
| 6. Security | ✅ PASS | |
| 7. Performance | ✅ PASS | |

#### Issues Found

1. **[SEVERITY] Issue Title**
   - Description:
   - Steps to reproduce:
   - Expected behavior:
   - Actual behavior:
   - Workaround:

#### Recommendations

- Recommendation 1
- Recommendation 2

---

## Quick Test Script

Save this as `quick-test.sh` for rapid validation:

```bash
#!/bin/bash

echo "=== Vesta Quick Validation ==="

# 1. Services
echo "1. Checking services..."
for service in nginx apache2 php8.3-fpm mariadb exim4 dovecot bind9 fail2ban vesta; do
    if systemctl is-active --quiet $service 2>/dev/null; then
        echo "  ✓ $service"
    else
        echo "  ✗ $service FAILED"
    fi
done

# 2. Ports
echo "2. Checking ports..."
for port in 80 443 8083 25 993 53; do
    if ss -tuln | grep -q ":$port "; then
        echo "  ✓ Port $port"
    else
        echo "  ✗ Port $port NOT listening"
    fi
done

# 3. PHP
echo "3. Checking PHP..."
php -v | head -1

# 4. Panel access
echo "4. Checking panel..."
if curl -k -s https://localhost:8083 | grep -q "vesta\|Vesta"; then
    echo "  ✓ Panel accessible"
else
    echo "  ✗ Panel NOT accessible"
fi

# 5. Credentials
echo "5. Installation info:"
if [ -f /root/vesta_install_info.txt ]; then
    echo "  ✓ Credentials file exists"
    echo "  Location: /root/vesta_install_info.txt"
else
    echo "  ✗ Credentials file missing"
fi

echo ""
echo "=== Test Complete ==="
```

---

## Troubleshooting Common Issues

### Issue: Service Failed to Start

```bash
# Check logs
journalctl -xe -u service-name

# Check configuration
service-name -t  # Test config

# Restart
systemctl restart service-name
```

### Issue: Panel Not Accessible

```bash
# Check Vesta service
systemctl status vesta

# Check port
ss -tuln | grep 8083

# Check firewall
iptables -L -n | grep 8083

# Check SSL cert
ls -la /usr/local/vesta/ssl/
```

### Issue: PHP Errors

```bash
# Check PHP-FPM log
tail -f /var/log/php8.3-fpm-error.log

# Check Nginx error log
tail -f /var/log/nginx/error.log

# Test PHP
php -r "echo 'PHP OK';"
```

---

## Next Steps After Testing

1. **Document all issues** found
2. **Create GitHub issues** for each problem
3. **Fix critical issues** before release
4. **Re-test** after fixes
5. **Mark as production-ready** only after all critical tests pass

---

**Test Status:** ⏳ **PENDING** - No VM tests performed yet

**Required Before Production:** ✅ All critical tests must pass on at least Ubuntu 22.04 and Debian 12
