# Vesta Control Panel

[![Join the chat at https://gitter.im/vesta-cp/Lobby](https://badges.gitter.im/vesta-cp/Lobby.svg)](https://gitter.im/vesta-cp/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

Vesta is back under active development as of February 25, 2024. We are committed to open source and will engage with the community to identify the new roadmap for Vesta.

## ✅ Modernization Complete (January 2025)

**Vesta now features fully modernized installation scripts with:**
- ✅ PHP 8.2, 8.3, 8.4 support (default: 8.3)
- ✅ Modern OS support (Ubuntu 20.04+, Debian 10+, RHEL 8+)
- ✅ MariaDB 10.11+ and MySQL 8.0+
- ✅ Security hardening with fail2ban
- ✅ Let's Encrypt SSL automation via acme.sh
- ✅ Production-ready configurations

**For upgrading from old Vesta installations:**
- See [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) for complete migration procedures
- Backup your data before upgrading
- Test PHP 8 compatibility of your applications

## About

Vesta is a comprehensive open-source hosting control panel designed for system administrators and web hosting providers. It provides a clean, focused interface for managing web servers without unnecessary complexity.

### Key Features

- **Web Server Management** - Apache, Nginx, or hybrid configurations
- **Database Administration** - MySQL/MariaDB and PostgreSQL support
- **DNS Management** - Full DNS zone control with template support
- **Mail Server** - Complete email solution with Exim, Dovecot, SpamAssassin
- **SSL/TLS Certificates** - Automated Let's Encrypt integration
- **Firewall Management** - iptables-based firewall with fail2ban
- **File Manager** - Web-based file management interface
- **Backup System** - Automated backup scheduling and remote storage
- **Multi-user Support** - User isolation and resource quotas
- **Modern UI** - React-based control panel with REST API

### Supported Operating Systems

**Fully Supported (Modern Installers):**
- ✅ **Ubuntu**: 20.04 LTS (Focal), 22.04 LTS (Jammy), 24.04 LTS (Noble)
- ✅ **Debian**: 10 (Buster), 11 (Bullseye), 12 (Bookworm)
- ✅ **RHEL Family**: RHEL 8/9, Rocky Linux 8/9, AlmaLinux 8/9

**End-of-Life (Not Supported):**
- ❌ Ubuntu < 20.04, Debian < 10, RHEL < 8
- ❌ CentOS (all versions - project discontinued)
- ❌ Amazon Linux < 2023

The modern installers automatically detect your OS and reject unsupported versions with clear error messages.

## Installation

### System Requirements

**Minimum:**
- 1 CPU core
- 2GB RAM (4GB recommended)
- 20GB free disk space
- Fresh OS installation recommended

**Software:**
- Ubuntu 20.04+, Debian 10+, or RHEL 8+
- Root access via SSH
- Internet connection

### Quick Install

**1. Connect to your server as root:**
```bash
ssh root@your.server
```

**2. Download the modern installer:**
```bash
wget https://github.com/outroll/vesta/raw/master/install/INSTALL_COMPLETE.sh
```

**3. Run the installation:**
```bash
# Basic installation with PHP 8.3 (default)
bash INSTALL_COMPLETE.sh -e admin@example.com

# With custom PHP version
bash INSTALL_COMPLETE.sh --php 8.3 -e admin@example.com

# With custom password and SSL
bash INSTALL_COMPLETE.sh \
  --php 8.3 \
  -e admin@example.com \
  -p mypassword \
  -s server.example.com \
  --ssl yes
```

### Installation Options

```bash
Options:
  --php VERSION          PHP version (8.2, 8.3, 8.4) - default: 8.3
  -e, --email EMAIL      Admin email address (required)
  -p, --password PASS    Admin password (auto-generated if not provided)
  -s, --hostname NAME    Server hostname
  --ssl yes|no           Request Let's Encrypt SSL for hostname
  -h, --help             Show help message

Examples:
  # Minimal installation
  bash INSTALL_COMPLETE.sh -e admin@example.com

  # Full installation with SSL
  bash INSTALL_COMPLETE.sh --php 8.3 -e admin@example.com -s vesta.example.com --ssl yes
```

### Installation Time

- **Expected duration:** 10-20 minutes
- **Depends on:** Server specs and internet connection
- **Progress:** Detailed output during installation

### Post-Installation

**1. Access the control panel:**
```
https://your-server-ip:8083
https://your-hostname:8083
```

**2. Credentials:**
- Username: `admin`
- Password: Displayed at end of installation
- Also saved to: `/root/vesta_install_info.txt`

**3. First Steps:**
- Change admin password (recommended)
- Create your first user account
- Add your first domain
- Configure backups
- Review firewall rules

### Upgrading from Old Vesta

If you're running an old Vesta installation with PHP 5.x/7.x:

**See [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) for:**
- Two migration strategies (fresh install vs. in-place upgrade)
- PHP 8 compatibility testing procedures
- Database migration steps
- Application-specific migration guides
- Rollback procedures

**⚠️ Important:** Always backup before upgrading!

## Development

### Prerequisites

- Bash 4.0+
- PHP 7.4+
- Node.js 18+ (for React UI development)
- Git

### Building the React UI

```bash
cd src/react
npm install
npm run build
```

### Project Structure

```
vesta/
├── bin/          # CLI commands (v-add-*, v-delete-*, etc.)
├── func/         # Bash function libraries
├── install/      # Installation scripts
├── src/          # Source code (React UI, C utilities)
├── web/          # PHP web interface
├── test/         # Test scripts
└── upd/          # Update scripts
```

## Architecture

Vesta uses a modular architecture with three main components:

1. **CLI Tools** - 385+ bash scripts for all operations
2. **Web Interface** - PHP-based traditional interface
3. **React UI** - Modern control panel built with React 18

All operations go through the CLI tools, ensuring consistency and security.

## Documentation

### Installation & Migration
- [Migration Guide](MIGRATION_GUIDE.md) - Complete guide for upgrading from old Vesta
- [System Requirements](SYSTEM_REQUIREMENTS.md) - Detailed dependency analysis
- [Installer Update Plan](INSTALLER_UPDATE_PLAN.md) - Modernization roadmap
- [Upgrade Notes](UPGRADE_NOTES.md) - React/JavaScript upgrade guide

### Development
- [Contributing Guide](CONTRIBUTING.md) - How to contribute to Vesta
- [Changelog](CHANGELOG.md) - Version history and changes
- [Security Policy](SECURITY.md) - Security practices and reporting

### Online Resources
- [Official Website](https://vestacp.com/)
- [API Documentation](https://vestacp.com/docs/)
- [User Manual](https://vestacp.com/docs/)
- [Forum](https://forum.vestacp.com/)

## Community

- **Website:** [vestacp.com](http://vestacp.com/)
- **Forum:** [forum.vestacp.com](https://forum.vestacp.com/)
- **Gitter Chat:** [vesta-cp/Lobby](https://gitter.im/vesta-cp/Lobby)
- **Issues:** [GitHub Issues](https://github.com/outroll/vesta/issues)

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## Security

If you discover a security vulnerability, please email dev@vestacp.com. Do not use the public issue tracker for security issues.

## License

Vesta Control Panel is licensed under the [GNU General Public License v3.0](LICENSE).

## Acknowledgments

Vesta is built on the shoulders of many excellent open-source projects:

- Nginx, Apache
- PHP, Node.js
- MySQL/MariaDB, PostgreSQL
- Exim, Dovecot
- React, Redux
- And many more...

## What's New in 2025

### Installation System Modernization ✨

**Major Update - January 2025:**
- 🎯 **Full PHP 8.x support** (8.2, 8.3, 8.4)
- 🚀 **Modern OS support** (Ubuntu 20.04+, Debian 10+, RHEL 8+)
- 🔒 **Enhanced security** with fail2ban and modern TLS
- 🤖 **Automated SSL** via Let's Encrypt (acme.sh)
- 📦 **Production-ready** configurations for all services
- 📚 **Comprehensive documentation** and migration guides

**For Developers:**
- ⚛️ React 18.3 with latest dependencies
- 🔄 Modern build tools and CI/CD
- 🎨 Bootstrap 5 ready
- 🛠️ Comprehensive testing framework

See [CHANGELOG.md](CHANGELOG.md) for complete release notes.

---

**Version:** 2.0.0 (Modernized)
**Release Date:** January 2025
**Status:** Active Development
**Maintained by:** The Vesta Community

**License:** GNU General Public License v3.0
