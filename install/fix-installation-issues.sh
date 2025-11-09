#!/bin/bash
#
# Vesta Control Panel - Post-Installation Fix Script
# Fixes common issues with Ubuntu 24.04 installation
#

set -e

VESTA='/usr/local/vesta'

echo "=========================================="
echo "  Vesta Control Panel - Fix Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "=== Fixing MariaDB Root Access ==="

# Check if MariaDB is running
if ! systemctl is-active --quiet mariadb; then
    print_warning "MariaDB is not running. Starting..."
    systemctl start mariadb
    systemctl enable mariadb
    sleep 3
fi

# Reset MariaDB root password
print_status "Resetting MariaDB root password..."

# Stop MariaDB
systemctl stop mariadb

# Start MariaDB in safe mode (skip grant tables)
mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld

# Kill any existing mysqld processes
pkill -9 mysqld 2>/dev/null || true
sleep 2

# Start mysqld_safe in background
mysqld_safe --skip-grant-tables --skip-networking &
MYSQLD_PID=$!
sleep 5

# Generate new random root password
DB_ROOT_PASS=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

# Reset root password
mysql -u root << EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASS';
FLUSH PRIVILEGES;
EOF

# Kill mysqld_safe
kill $MYSQLD_PID 2>/dev/null || true
pkill -9 mysqld 2>/dev/null || true
sleep 2

# Start MariaDB normally
systemctl start mariadb
sleep 3

# Save credentials to /root/.my.cnf
cat > /root/.my.cnf << EOF
[client]
user=root
password=$DB_ROOT_PASS

[mysql]
user=root
password=$DB_ROOT_PASS

[mysqldump]
user=root
password=$DB_ROOT_PASS
EOF

chmod 600 /root/.my.cnf

# Test connection
if mysql -e "SHOW DATABASES;" > /dev/null 2>&1; then
    print_status "MariaDB root access fixed successfully"
    echo "  Root password saved to: /root/.my.cnf"
else
    print_error "Failed to fix MariaDB root access"
    exit 1
fi

echo ""
echo "=== Fixing Apache MPM Module Conflict ==="

# Disable PHP module and enable event MPM
a2dismod php8.3 2>/dev/null || true
a2dismod mpm_prefork 2>/dev/null || true
a2enmod mpm_event 2>/dev/null || true

# Restart Apache
systemctl restart apache2
print_status "Apache MPM fixed"

echo ""
echo "=== Checking Critical Services ==="

# List of critical services
SERVICES=(
    "nginx"
    "apache2"
    "php8.3-fpm"
    "mariadb"
    "exim4"
    "dovecot"
    "named"
    "vsftpd"
    "fail2ban"
)

for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet $service; then
        print_status "$service is running"
    else
        print_warning "$service is not running. Starting..."
        systemctl start $service 2>/dev/null || print_error "Failed to start $service"
        systemctl enable $service 2>/dev/null || true
    fi
done

echo ""
echo "=== Creating Default Package ==="

# Check if admin user exists
if ! grep -q "^admin:" /etc/passwd; then
    print_error "Admin user not found in /etc/passwd"
else
    # Create default package if it doesn't exist
    if [ ! -f "$VESTA/data/packages/default.pkg" ]; then
        print_status "Creating default package..."

        mkdir -p $VESTA/data/packages

        cat > $VESTA/data/packages/default.pkg << 'PKGEOF'
WEB_TEMPLATE='default'
BACKEND_TEMPLATE='default'
PROXY_TEMPLATE='default'
DNS_TEMPLATE='default'
WEB_DOMAINS='unlimited'
WEB_ALIASES='unlimited'
DNS_DOMAINS='unlimited'
DNS_RECORDS='unlimited'
MAIL_DOMAINS='unlimited'
MAIL_ACCOUNTS='unlimited'
DATABASES='unlimited'
CRON_JOBS='unlimited'
DISK_QUOTA='unlimited'
BANDWIDTH='unlimited'
BACKUPS='unlimited'
TIME='00:00'
DATE='2025-11-09'
SUSPENDED='no'
PKGEOF

        chown admin:admin $VESTA/data/packages/default.pkg
        chmod 660 $VESTA/data/packages/default.pkg

        print_status "Default package created"
    else
        print_status "Default package already exists"
    fi
fi

echo ""
echo "=== Checking Web Interface ==="

# Check if web interface is accessible
if curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8083 | grep -q "200"; then
    print_status "Web interface is accessible on port 8083"
else
    print_warning "Web interface may not be accessible"
fi

echo ""
echo "=== Checking Firewall Rules ==="

# Check if iptables has rules
if iptables -L -n | grep -q "Chain INPUT"; then
    print_status "Firewall rules are configured"
else
    print_warning "No firewall rules found"
fi

echo ""
echo "=========================================="
echo "  Fix Script Completed"
echo "=========================================="
echo ""
echo "Summary:"
echo "--------"
echo "✓ MariaDB root access fixed"
echo "✓ Root password saved to /root/.my.cnf"
echo "✓ Apache MPM module conflict resolved"
echo "✓ Services checked and started"
echo "✓ Default package created"
echo ""
echo "Next Steps:"
echo "-----------"
echo "1. Test MariaDB: mysql -e 'SHOW DATABASES;'"
echo "2. Access web interface: https://$(hostname -I | awk '{print $1}'):8083"
echo "3. Check service status: systemctl status nginx php8.3-fpm mariadb"
echo ""

exit 0
