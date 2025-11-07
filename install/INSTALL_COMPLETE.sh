#!/bin/bash

# Vesta Control Panel - Complete Modern Installer
# Version: 2.0 (Modernized)
# Supports: Ubuntu 20.04+, Debian 10+, RHEL 8+
# PHP 8.2/8.3/8.4 | MariaDB 10.11+ | Modern Security

#----------------------------------------------------------#
#                    Initial Setup                         #
#----------------------------------------------------------#

# Strict error handling
set -e
trap 'echo "Error on line $LINENO"' ERR

# Source the appropriate OS-specific installer
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        ubuntu)
            if [ -f "$(dirname $0)/vst-install-ubuntu-modern.sh" ]; then
                source "$(dirname $0)/vst-install-ubuntu-modern.sh"
            fi
            ;;
        debian)
            if [ -f "$(dirname $0)/vst-install-debian-modern.sh" ]; then
                source "$(dirname $0)/vst-install-debian-modern.sh"
            fi
            ;;
        rhel|rocky|almalinux|centos)
            if [ -f "$(dirname $0)/vst-install-rhel-modern.sh" ]; then
                source "$(dirname $0)/vst-install-rhel-modern.sh"
            fi
            ;;
        *)
            echo "Unsupported OS: $ID"
            echo "Supported: Ubuntu 20.04+, Debian 10+, RHEL/Rocky/AlmaLinux 8+"
            exit 1
            ;;
    esac
else
    echo "Cannot detect OS. /etc/os-release not found."
    exit 1
fi

echo "Vesta Control Panel installation complete!"
echo ""
echo "Access the control panel at: https://$(hostname -I | awk '{print $1}'):8083"
echo ""
echo "For documentation, visit: https://vestacp.com/docs/"
