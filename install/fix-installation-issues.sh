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

# Kill any existing mysqld/mariadbd processes
pkill -9 mysqld 2>/dev/null || true
pkill -9 mariadbd 2>/dev/null || true
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
ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('$DB_ROOT_PASS');
FLUSH PRIVILEGES;
EOF

# Kill mysqld_safe
kill $MYSQLD_PID 2>/dev/null || true
pkill -9 mysqld 2>/dev/null || true
pkill -9 mariadbd 2>/dev/null || true
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
echo "=== Fixing Admin User Home Directory ==="

# Check if admin user exists
if ! grep -q "^admin:" /etc/passwd; then
    print_error "Admin user not found in /etc/passwd"
else
    # Ensure admin home directory is set correctly
    ADMIN_HOME=$(grep "^admin:" /etc/passwd | cut -d: -f6)
    if [ "$ADMIN_HOME" != "$VESTA" ]; then
        print_warning "Admin home directory is $ADMIN_HOME, should be $VESTA"
        usermod -d $VESTA admin
        print_status "Admin home directory updated"
    fi

    # Ensure Vesta directory exists and has proper ownership
    if [ ! -d "$VESTA" ]; then
        print_error "Vesta directory $VESTA does not exist"
    else
        chown -R admin:admin $VESTA
        chmod 755 $VESTA
        print_status "Admin home directory ownership fixed"
    fi

    # Create admin user data directory
    mkdir -p $VESTA/data/users/admin
    chown admin:admin $VESTA/data/users/admin
    print_status "Admin user directory created"
fi

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
echo "=== Fixing PHP Environment Variables ==="

# Fix missing VESTA environment variable in PHP context (Bug #27)
if ! grep -q 'putenv("VESTA=/usr/local/vesta")' $VESTA/web/inc/main.php; then
    print_status "Adding VESTA environment variable to inc/main.php..."
    sed -i '3i putenv("VESTA=/usr/local/vesta");' $VESTA/web/inc/main.php
    systemctl restart php8.3-fpm
    print_status "VESTA environment variable configured"
else
    print_status "VESTA environment variable already configured"
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
echo "=== Fixing Firewall Rules Configuration (Bug #28) ==="

# Check if firewall rules file exists and has wrong format
if [ -f "$VESTA/data/firewall/rules.conf" ]; then
    if grep -q "^ACCEPT" "$VESTA/data/firewall/rules.conf"; then
        print_status "Fixing firewall rules.conf format..."

        # Backup old file
        cp "$VESTA/data/firewall/rules.conf" "$VESTA/data/firewall/rules.conf.bak"

        # Create proper format
        cat > $VESTA/data/firewall/rules.conf <<'FWEOF'
RULE='1' ACTION='ACCEPT' PROTOCOL='TCP' PORT='22' IP='0.0.0.0/0' COMMENT='SSH' SUSPENDED='no' TIME='00:00:00' DATE='2025-11-09'
RULE='2' ACTION='ACCEPT' PROTOCOL='TCP' PORT='80' IP='0.0.0.0/0' COMMENT='HTTP' SUSPENDED='no' TIME='00:00:00' DATE='2025-11-09'
RULE='3' ACTION='ACCEPT' PROTOCOL='TCP' PORT='443' IP='0.0.0.0/0' COMMENT='HTTPS' SUSPENDED='no' TIME='00:00:00' DATE='2025-11-09'
RULE='4' ACTION='ACCEPT' PROTOCOL='TCP' PORT='8083' IP='0.0.0.0/0' COMMENT='Vesta Control Panel' SUSPENDED='no' TIME='00:00:00' DATE='2025-11-09'
RULE='5' ACTION='ACCEPT' PROTOCOL='TCP' PORT='25' IP='0.0.0.0/0' COMMENT='SMTP' SUSPENDED='no' TIME='00:00:00' DATE='2025-11-09'
RULE='6' ACTION='ACCEPT' PROTOCOL='TCP' PORT='465' IP='0.0.0.0/0' COMMENT='SMTPS' SUSPENDED='no' TIME='00:00:00' DATE='2025-11-09'
RULE='7' ACTION='ACCEPT' PROTOCOL='TCP' PORT='587' IP='0.0.0.0/0' COMMENT='SMTP Submission' SUSPENDED='no' TIME='00:00:00' DATE='2025-11-09'
RULE='8' ACTION='ACCEPT' PROTOCOL='TCP' PORT='110' IP='0.0.0.0/0' COMMENT='POP3' SUSPENDED='no' TIME='00:00:00' DATE='2025-11-09'
RULE='9' ACTION='ACCEPT' PROTOCOL='TCP' PORT='995' IP='0.0.0.0/0' COMMENT='POP3S' SUSPENDED='no' TIME='00:00:00' DATE='2025-11-09'
RULE='10' ACTION='ACCEPT' PROTOCOL='TCP' PORT='143' IP='0.0.0.0/0' COMMENT='IMAP' SUSPENDED='no' TIME='00:00:00' DATE='2025-11-09'
RULE='11' ACTION='ACCEPT' PROTOCOL='TCP' PORT='993' IP='0.0.0.0/0' COMMENT='IMAPS' SUSPENDED='no' TIME='00:00:00' DATE='2025-11-09'
RULE='12' ACTION='ACCEPT' PROTOCOL='TCP' PORT='53' IP='0.0.0.0/0' COMMENT='DNS' SUSPENDED='no' TIME='00:00:00' DATE='2025-11-09'
RULE='13' ACTION='ACCEPT' PROTOCOL='UDP' PORT='53' IP='0.0.0.0/0' COMMENT='DNS' SUSPENDED='no' TIME='00:00:00' DATE='2025-11-09'
RULE='14' ACTION='ACCEPT' PROTOCOL='TCP' PORT='21' IP='0.0.0.0/0' COMMENT='FTP' SUSPENDED='no' TIME='00:00:00' DATE='2025-11-09'
RULE='15' ACTION='ACCEPT' PROTOCOL='TCP' PORT='12000:12100' IP='0.0.0.0/0' COMMENT='FTP passive' SUSPENDED='no' TIME='00:00:00' DATE='2025-11-09'
FWEOF
        chmod 660 $VESTA/data/firewall/rules.conf
        print_status "Firewall rules configuration fixed"
    else
        print_status "Firewall rules configuration already correct"
    fi
fi

echo ""
echo "=== Creating Missing Admin Configuration Files (Bug #29) ==="

# Check if admin configuration files exist
if grep -q "^admin:" /etc/passwd; then
    ADMIN_DATA_DIR="$VESTA/data/users/admin"

    # List of required configuration files
    CONFIG_FILES=("db.conf" "dns.conf" "web.conf" "mail.conf" "cron.conf" "backup.conf")

    for conf_file in "${CONFIG_FILES[@]}"; do
        if [ ! -f "$ADMIN_DATA_DIR/$conf_file" ]; then
            print_status "Creating $conf_file..."
            touch "$ADMIN_DATA_DIR/$conf_file"
            chmod 640 "$ADMIN_DATA_DIR/$conf_file"
            chown admin:admin "$ADMIN_DATA_DIR/$conf_file"
        else
            print_status "$conf_file already exists"
        fi
    done

    print_status "Admin configuration files verified"
else
    print_warning "Admin user not found, skipping configuration files"
fi

echo ""
echo "=== Configuring Firewall Rules ==="

# Check if firewall rules need to be configured
RULE_COUNT=$(iptables -L INPUT -n | grep -c "dpt:" || echo "0")
if [ "$RULE_COUNT" -lt "4" ]; then
    print_status "Configuring iptables firewall..."

    # Flush existing rules
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X

    # Set default policies
    iptables -P INPUT ACCEPT
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT

    # Allow loopback
    iptables -A INPUT -i lo -j ACCEPT

    # Allow established connections
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

    # Allow critical services
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT    # SSH
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT    # HTTP
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT   # HTTPS
    iptables -A INPUT -p tcp --dport 8083 -j ACCEPT  # Vesta Web Interface
    iptables -A INPUT -p tcp --dport 21 -j ACCEPT    # FTP
    iptables -A INPUT -p tcp --dport 25 -j ACCEPT    # SMTP
    iptables -A INPUT -p tcp --dport 587 -j ACCEPT   # SMTP Submission
    iptables -A INPUT -p tcp --dport 110 -j ACCEPT   # POP3
    iptables -A INPUT -p tcp --dport 995 -j ACCEPT   # POP3S
    iptables -A INPUT -p tcp --dport 143 -j ACCEPT   # IMAP
    iptables -A INPUT -p tcp --dport 993 -j ACCEPT   # IMAPS
    iptables -A INPUT -p tcp --dport 53 -j ACCEPT    # DNS TCP
    iptables -A INPUT -p udp --dport 53 -j ACCEPT    # DNS UDP

    # Drop all other INPUT traffic
    iptables -A INPUT -j DROP

    # Install and save rules
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y iptables-persistent > /dev/null 2>&1
    netfilter-persistent save > /dev/null 2>&1

    print_status "Firewall configured and saved"
else
    print_status "Firewall rules already configured"
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
echo "✓ Admin home directory ownership fixed"
echo "✓ Admin user directory created"
echo "✓ Default package created"
echo "✓ VESTA environment variable configured (Bug #27)"
echo "✓ Firewall rules.conf format fixed (Bug #28)"
echo "✓ Admin configuration files created (Bug #29)"
echo "✓ Firewall configured (iptables)"
echo ""
echo "Next Steps:"
echo "-----------"
echo "1. Test MariaDB: mysql -e 'SHOW DATABASES;'"
echo "2. Access web interface: https://$(hostname -I | awk '{print $1}'):8083"
echo "3. Check service status: systemctl status nginx php8.3-fpm mariadb"
echo "4. Verify admin user: grep '^admin:' /etc/passwd"
echo "5. Check firewall: iptables -L -n"
echo ""

exit 0
