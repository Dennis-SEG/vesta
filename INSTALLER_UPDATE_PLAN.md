# Installation Script Modernization Plan

This document outlines the comprehensive plan to modernize Vesta Control Panel installation scripts for current operating systems and software versions.

## Status: IN PROGRESS

**Created:** 2025-01-07
**Priority:** CRITICAL - Current scripts have major security issues

## Overview

The installation scripts need complete modernization to:
1. Remove End of Life operating system support
2. Remove PHP 5.x and 7.x support (security critical)
3. Add PHP 8.x support
4. Add modern OS version support
5. Specify current database versions
6. Update all package dependencies

## Files Requiring Updates

### Critical Priority
- ✅ **`install/vst-install-ubuntu-modern.sh`** - NEW modernized template created
- ⏳ **`install/vst-install-ubuntu.sh`** - Original, needs replacement (1469 lines)
- ⏳ **`install/vst-install-debian.sh`** - Needs modernization (1400+ lines)
- ⏳ **`install/vst-install-rhel.sh`** - Needs modernization (1200+ lines)
- ⏳ **`install/vst-install-amazon.sh`** - Needs modernization
- ⏳ **`install/vst-install.sh`** - Main wrapper, needs update

### Configuration Directories
- ⏳ **`install/ubuntu/20.04/`** - NEW directory needed
- ⏳ **`install/ubuntu/22.04/`** - NEW directory needed
- ⏳ **`install/ubuntu/24.04/`** - NEW directory needed
- ⏳ **`install/debian/10/`** - NEW directory needed
- ⏳ **`install/debian/11/`** - NEW directory needed
- ⏳ **`install/debian/12/`** - NEW directory needed
- ⏳ **`install/rhel/8/`** - NEW directory needed
- ⏳ **`install/rhel/9/`** - NEW directory needed

## Ubuntu Installer Modernization

### File: `vst-install-ubuntu.sh` (1469 lines)

#### Version Check Updates (Lines 17-40)

**REMOVE Support For:**
```bash
# Remove all these checks
if [[ ${release:0:2} -lt 16 ]]; then
if [[ ${release:0:2} -lt 20 ]]; then  # Update this
```

**ADD Version Validation:**
```bash
# Only allow Ubuntu 20.04, 22.04, 24.04
supported_versions="20.04 22.04 24.04"
if ! echo "$supported_versions" | grep -w "$release" > /dev/null; then
    echo "ERROR: Unsupported Ubuntu version: $release"
    echo "Supported versions: 20.04 LTS, 22.04 LTS, 24.04 LTS"
    exit 1
fi
```

#### PHP Support Updates

**REMOVE All References To:**
- Lines 36-38: PHP 5 fallback logic
- Lines 522-523: `service php5-fpm stop`, `service php7.0-fpm stop`
- Lines 525-526: PHP 5/7.0 backup paths
- Lines 598-604: PHP 5/7.0 package removals
- Lines 639-649: PHP 5/7.0 MySQL/PostgreSQL extensions
- Line 1227: `php5enmod mcrypt`

**ADD PHP 8.x Support:**
```bash
# Add ondrej PPA for PHP 8.x
add-apt-repository -y ppa:ondrej/php
apt-get update

# Default to PHP 8.3 (configurable)
php_version="${php_version:-8.3}"

# PHP packages
php${php_version}-cli php${php_version}-fpm php${php_version}-mysql
php${php_version}-pgsql php${php_version}-gd php${php_version}-mbstring
php${php_version}-xml php${php_version}-zip php${php_version}-bcmath
php${php_version}-soap php${php_version}-intl php${php_version}-imap
php${php_version}-curl
```

#### Package List Updates (Lines 22-32)

**REMOVE:**
- `apache2.2-common` (EOL)
- `e2fslibs` (merged into e2fsprogs)
- `mysql-server mysql-client mysql-common` (if using MariaDB)

**ADD/UPDATE:**
- `mariadb-server mariadb-client mariadb-common` (10.11+ from repos)
- `software-properties-common` (for PPA management)
- PHP 8.x packages (listed above)

#### Repository Setup Updates (Lines 474-500)

**ADD PHP Repository:**
```bash
# Add ondrej PHP repository
add-apt-repository -y ppa:ondrej/php
check_result $? "Failed to add PHP repository"
```

**UPDATE Nginx Repository:**
```bash
# Use stable nginx instead of mainline for production
echo "deb http://nginx.org/packages/ubuntu/ $codename nginx" \
    > /etc/apt/sources.list.d/nginx.list
```

**ADD PostgreSQL Repository (if needed):**
```bash
# For PostgreSQL 16+
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $codename-pgdg main" \
    > /etc/apt/sources.list.d/pgdg.list
```

#### Database Version Specification

**MariaDB (Recommended):**
```bash
# Ubuntu 22.04+ includes MariaDB 10.6+
# Ubuntu 24.04 includes MariaDB 10.11
# Use distribution version (already 10.6+)
apt-get -y install mariadb-server mariadb-client
```

**MySQL 8.0 (Alternative):**
```bash
# If MySQL preferred over MariaDB
wget https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb
dpkg -i mysql-apt-config_0.8.29-1_all.deb
apt-get update
apt-get -y install mysql-server
```

#### phpMyAdmin Update

**REMOVE:**
```bash
# Don't use distribution phpMyAdmin (old version)
# software=$(echo "$software" | sed -e "s/phpmyadmin//")
```

**ADD Download Latest:**
```bash
# Download phpMyAdmin 5.2.x
PMA_VERSION="5.2.1"
wget https://files.phpmyadmin.net/phpMyAdmin/${PMA_VERSION}/phpMyAdmin-${PMA_VERSION}-all-languages.tar.gz
tar -xzf phpMyAdmin-${PMA_VERSION}-all-languages.tar.gz
mv phpMyAdmin-${PMA_VERSION}-all-languages /usr/share/phpmyadmin
```

## Debian Installer Modernization

### File: `vst-install-debian.sh`

**Similar updates as Ubuntu:**
- Remove Debian < 10 support
- Add Debian 10 (Buster), 11 (Bullseye), 12 (Bookworm) support
- Remove PHP 5.x/7.0 references
- Add PHP 8.x from sury.org repository:
  ```bash
  wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
  echo "deb https://packages.sury.org/php/ $codename main" \
      > /etc/apt/sources.list.d/php.list
  ```

## RHEL/CentOS/Rocky/AlmaLinux Installer

### File: `vst-install-rhel.sh`

**REMOVE Support For:**
- RHEL/CentOS 5, 6 (completely EOL)
- CentOS 7 (EOL June 2024)

**ADD Support For:**
- RHEL 8, 9
- Rocky Linux 8, 9
- AlmaLinux 8, 9

**UPDATE PHP Support:**
```bash
# Use Remi repository for PHP 8.x
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${release}.noarch.rpm
dnf -y install https://rpms.remirepo.net/enterprise/remi-release-${release}.rpm

# Enable PHP 8.3 module
dnf -y module reset php
dnf -y module enable php:remi-8.3
dnf -y install php php-cli php-fpm php-mysqlnd php-gd php-mbstring \
    php-xml php-pgsql php-intl php-soap php-bcmath
```

**UPDATE Package Names:**
- `mariadb-server` (MariaDB 10.5+ in RHEL 8+)
- `postgresql16-server` (from PostgreSQL repo)
- `httpd` instead of `apache2`

## Configuration Templates

### New Directory Structure

Each modern OS version needs configuration templates:

```
install/
├── ubuntu/
│   ├── 20.04/        # Focal
│   │   ├── nginx/
│   │   ├── apache2/
│   │   ├── php/
│   │   ├── mysql/
│   │   └── exim4/
│   ├── 22.04/        # Jammy
│   │   └── [same structure]
│   └── 24.04/        # Noble
│       └── [same structure]
├── debian/
│   ├── 10/           # Buster
│   ├── 11/           # Bullseye
│   └── 12/           # Bookworm
└── rhel/
    ├── 8/            # Rocky/Alma 8
    └── 9/            # Rocky/Alma 9
```

### PHP Configuration Updates

**PHP-FPM Pool Configuration:**
```ini
; /etc/php/8.3/fpm/pool.d/www.conf
[www]
user = www-data
group = www-data
listen = /run/php/php8.3-fpm.sock
listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

**PHP.ini Updates:**
```ini
; Modern PHP 8.3 settings
memory_limit = 256M
upload_max_filesize = 128M
post_max_size = 128M
max_execution_time = 300
date.timezone = UTC
```

### Nginx Configuration Updates

**For PHP 8.3:**
```nginx
location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php8.3-fpm.sock;
}
```

### Apache Configuration Updates

**PHP-FPM Integration:**
```apache
<FilesMatch \.php$>
    SetHandler "proxy:unix:/run/php/php8.3-fpm.sock|fcgi://localhost"
</FilesMatch>
```

## Testing Plan

### Test Matrix

| OS Version | PHP | Database | Web Server | Status |
|------------|-----|----------|------------|--------|
| Ubuntu 20.04 | 8.2 | MariaDB 10.6 | Nginx | ⏳ |
| Ubuntu 20.04 | 8.3 | MariaDB 10.6 | Apache | ⏳ |
| Ubuntu 22.04 | 8.3 | MariaDB 10.6 | Nginx | ⏳ |
| Ubuntu 22.04 | 8.3 | MySQL 8.0 | Apache | ⏳ |
| Ubuntu 24.04 | 8.3 | MariaDB 10.11 | Nginx | ⏳ |
| Ubuntu 24.04 | 8.4 | MariaDB 10.11 | Apache | ⏳ |
| Debian 11 | 8.2 | MariaDB 10.5 | Nginx | ⏳ |
| Debian 12 | 8.3 | MariaDB 10.11 | Nginx | ⏳ |
| Rocky 9 | 8.3 | MariaDB 10.5 | Apache | ⏳ |

### Test Steps

For each configuration:
1. ✅ Fresh OS installation
2. ✅ Run modernized installer
3. ✅ Verify all services start
4. ✅ Test Vesta panel access
5. ✅ Create test user
6. ✅ Create test domain
7. ✅ Test PHP functionality
8. ✅ Test database creation
9. ✅ Test email functionality
10. ✅ Test SSL certificate generation
11. ✅ Test backup/restore
12. ✅ Security audit

## Implementation Phases

### Phase 1: Ubuntu (CURRENT)
- ✅ Create modernized template (`vst-install-ubuntu-modern.sh`)
- ⏳ Complete full Ubuntu installer (1469 lines)
- ⏳ Create Ubuntu 20.04/22.04/24.04 config directories
- ⏳ Test on all Ubuntu LTS versions

### Phase 2: Debian
- ⏳ Modernize Debian installer
- ⏳ Create Debian 10/11/12 config directories
- ⏳ Test on all Debian versions

### Phase 3: RHEL Family
- ⏳ Modernize RHEL installer for Rocky/Alma
- ⏳ Add RHEL 8/9 detection
- ⏳ Create RHEL 8/9 config directories
- ⏳ Test on Rocky Linux and AlmaLinux

### Phase 4: Integration & Documentation
- ⏳ Update main `vst-install.sh` wrapper
- ⏳ Update all documentation
- ⏳ Create migration guides
- ⏳ Update README with supported versions

### Phase 5: Deprecation
- ⏳ Mark old installers as deprecated
- ⏳ Add warnings to old installers
- ⏳ Eventually remove EOL OS support

## Breaking Changes

Users upgrading from old versions will need to:

1. **PHP Upgrade Required**
   - No automatic upgrade path from PHP 5.x/7.x to 8.x
   - Sites must be tested for PHP 8 compatibility
   - Deprecated functions must be updated

2. **MySQL/MariaDB Upgrade**
   - Authentication plugin changes
   - SQL mode differences
   - Performance tuning may be needed

3. **Configuration Changes**
   - PHP-FPM socket paths changed
   - Apache module names changed
   - Nginx configuration syntax updates

## Rollback Plan

If issues occur:
1. Keep old installers in `install/legacy/` directory
2. Provide clear documentation on using old installers
3. Maintain security patches for old installers (limited time)
4. Strongly encourage migration to modern versions

## Security Considerations

### Critical
- PHP 5.x/7.x have known vulnerabilities - no support
- EOL operating systems have unpatched vulnerabilities
- All new installations MUST use supported software

### Recommendations
- Enable automatic security updates
- Configure fail2ban properly
- Use strong SSL/TLS configurations
- Regular backup verification
- Monitor security advisories

## Timeline

- **Week 1:** Complete Ubuntu installer modernization
- **Week 2:** Complete Debian installer modernization
- **Week 3:** Complete RHEL installer modernization
- **Week 4:** Testing and bug fixes
- **Week 5:** Documentation and release preparation
- **Week 6:** Public beta release
- **Week 8:** Production release

## Resources Needed

### Development
- Development VMs for each OS version (9 VMs)
- Testing infrastructure
- CI/CD pipeline updates

### Documentation
- Updated installation guides
- Migration documentation
- Troubleshooting guides
- Video tutorials

### Community
- Beta testers for each OS
- Feedback collection system
- Support forum preparation

## Success Criteria

✅ All tests pass on supported OS versions
✅ No PHP 5.x/7.x references remain
✅ No EOL OS support remains
✅ Documentation is complete
✅ Community feedback is positive
✅ Security audit passes
✅ Performance benchmarks meet targets

## Current Status Summary

**Completed:**
- ✅ System requirements audit
- ✅ Documentation of needed changes
- ✅ Ubuntu modernized template created
- ✅ Implementation plan documented

**In Progress:**
- ⏳ Ubuntu full installer completion
- ⏳ Configuration directory creation

**Pending:**
- Debian installer modernization
- RHEL installer modernization
- Testing infrastructure
- Documentation updates

## Next Steps

1. Complete Ubuntu installer (1469 lines) based on template
2. Create OS-specific configuration directories
3. Set up testing VMs
4. Begin Debian installer modernization
5. Create comprehensive testing suite

---

**Document Version:** 1.0
**Last Updated:** 2025-01-07
**Status:** Active Development
**Priority:** CRITICAL
