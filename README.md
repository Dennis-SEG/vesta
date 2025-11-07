# Vesta Control Panel

[![Join the chat at https://gitter.im/vesta-cp/Lobby](https://badges.gitter.im/vesta-cp/Lobby.svg)](https://gitter.im/vesta-cp/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

Vesta is back under active development as of February 25, 2024. We are committed to open source and will engage with the community to identify the new roadmap for Vesta.

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

- RHEL 5, 6, 7
- CentOS 5, 6, 7
- Debian 7, 8, 9, 10, 11
- Ubuntu 12.04 - 22.04
- Amazon Linux 2017

## Installation

### Quick Install (2 steps)

Connect to your server as root via SSH:
```bash
ssh root@your.server
```

Download and run the installation script:
```bash
curl -O https://vestacp.com/pub/vst-install.sh
bash vst-install.sh
```

### Alternative Install (Direct Pipe)

```bash
curl https://vestacp.com/pub/vst-install.sh | bash
```

**Note:** For production systems, we recommend reviewing the installation script before execution.

## Post-Installation

After installation, you can access the control panel at:
```
https://your-server-ip:8083
```

Default credentials will be displayed at the end of the installation.

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

- [Installation Guide](https://vestacp.com/install/)
- [API Documentation](https://vestacp.com/docs/)
- [User Manual](https://vestacp.com/docs/)
- [Contributing Guide](CONTRIBUTING.md)
- [Security Policy](SECURITY.md)

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

---

**Version:** 1.0.0-5
**Status:** Active Development
**Maintained by:** The Vesta Community
