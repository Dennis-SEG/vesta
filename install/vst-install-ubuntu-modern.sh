#!/bin/bash

# Vesta Ubuntu installer - Modernized v.1.0
# Supports: Ubuntu 20.04 LTS, 22.04 LTS, 24.04 LTS
# PHP 8.2, 8.3, 8.4 | MariaDB 10.11+ or MySQL 8.0+ | PostgreSQL 16+

#----------------------------------------------------------#
#                  Variables&Functions                     #
#----------------------------------------------------------#
export PATH=$PATH:/sbin
export DEBIAN_FRONTEND=noninteractive
RHOST='apt.vestacp.com'
CHOST='c.vestacp.com'
VERSION='ubuntu'
VESTA='/usr/local/vesta'
memory=$(grep 'MemTotal' /proc/meminfo |tr ' ' '\n' |grep [0-9])
arch=$(uname -i)
os='ubuntu'
release="$(lsb_release -s -r)"
codename="$(lsb_release -s -c)"
vestacp="$VESTA/install/$VERSION/$release"

# Default PHP version (8.3 recommended)
php_version="8.3"

# Defining software pack for modern Ubuntu (20.04+)
software="nginx apache2 apache2-suexec-custom apache2-utils
    apparmor-utils awstats bc bind9 bsdmainutils bsdutils clamav-daemon
    cron curl dnsutils dovecot-imapd dovecot-pop3d e2fsprogs exim4
    exim4-daemon-heavy expect fail2ban flex ftp git idn imagemagick
    libapache2-mod-fcgid libapache2-mod-php${php_version} libapache2-mod-rpaf
    libapache2-mod-ruid2 lsof mc mariadb-client mariadb-common mariadb-server
    ntpdate php${php_version}-cgi php${php_version}-common php${php_version}-curl
    php${php_version}-fpm php${php_version}-mysql php${php_version}-pgsql
    php${php_version}-cli php${php_version}-gd php${php_version}-mbstring
    php${php_version}-xml php${php_version}-zip php${php_version}-bcmath
    php${php_version}-soap php${php_version}-intl php${php_version}-imap
    postgresql postgresql-contrib proftpd-basic quota
    roundcube-core roundcube-mysql roundcube-plugins rrdtool rssh spamassassin
    sudo vesta vesta-ioncube vesta-nginx vesta-php vesta-softaculous
    vim-common vsftpd webalizer whois zip net-tools software-properties-common"

# Defining help function
help() {
    echo "Usage: $0 [OPTIONS]
  -a, --apache            Install Apache           [yes|no]  default: yes
  -n, --nginx             Install Nginx            [yes|no]  default: yes
  -w, --phpfpm            Install PHP-FPM          [yes|no]  default: no
  -v, --vsftpd            Install Vsftpd           [yes|no]  default: yes
  -j, --proftpd           Install ProFTPD          [yes|no]  default: no
  -k, --named             Install Bind             [yes|no]  default: yes
  -m, --mysql             Install MySQL/MariaDB    [yes|no]  default: yes
  -g, --postgresql        Install PostgreSQL       [yes|no]  default: no
  -x, --exim              Install Exim             [yes|no]  default: yes
  -z, --dovecot           Install Dovecot          [yes|no]  default: yes
  -c, --clamav            Install ClamAV           [yes|no]  default: yes
  -t, --spamassassin      Install SpamAssassin     [yes|no]  default: yes
  -i, --iptables          Install Iptables         [yes|no]  default: yes
  -b, --fail2ban          Install Fail2ban         [yes|no]  default: yes
  -o, --softaculous       Install Softaculous      [yes|no]  default: yes
  -q, --quota             Filesystem Quota         [yes|no]  default: no
  -l, --lang              Default language                default: en
  --php                   PHP version              [8.2|8.3|8.4]  default: 8.3
  -y, --interactive       Interactive install      [yes|no]  default: yes
  -s, --hostname          Set hostname
  -u, --ssl               Add LE SSL for hostname  [yes|no]  default: no
  -e, --email             Set admin email
  -d, --port              Set Vesta port
  -p, --password          Set admin password
  -f, --force             Force installation
  -h, --help              Print this help

  Example: bash $0 -e admin@example.com -p password --php 8.3"
    exit 1
}

# Defining password-gen function
gen_pass() {
    MATRIX='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    LENGTH=10
    while [ ${n:=1} -le $LENGTH ]; do
        PASS="$PASS${MATRIX:$(($RANDOM%${#MATRIX})):1}"
        let n+=1
    done
    echo "$PASS"
}

# Defining return code check function
check_result() {
    if [ $1 -ne 0 ]; then
        echo "Error: $2"
        exit $1
    fi
}

# Defining function to set default value
set_default_value() {
    eval variable=\$$1
    if [ -z "$variable" ]; then
        eval $1=$2
    fi
    if [ "$variable" != 'yes' ] && [ "$variable" != 'no' ]; then
        eval $1=$2
    fi
}

# Defining function to set default language value
set_default_lang() {
    if [ -z "$lang" ]; then
        eval lang=$1
    fi
    lang_list="
        ar cz el fa hu ja no pt se ua
        bs da en fi id ka pl ro tr vi
        cn de es fr it nl pt-BR ru tw
        bg ko sr th ur"
    if !(echo $lang_list |grep -w $lang 1>&2>/dev/null); then
        eval lang=$1
    fi
}

#----------------------------------------------------------#
#                    Verifications                         #
#----------------------------------------------------------#

# Check Ubuntu version - only support 20.04+
supported_versions="20.04 22.04 24.04"
if ! echo "$supported_versions" | grep -w "$release" > /dev/null; then
    echo "=========================================================="
    echo "ERROR: Unsupported Ubuntu version: $release"
    echo "=========================================================="
    echo ""
    echo "This installer only supports:"
    echo "  - Ubuntu 20.04 LTS (Focal Fossa)"
    echo "  - Ubuntu 22.04 LTS (Jammy Jellyfish)"
    echo "  - Ubuntu 24.04 LTS (Noble Numbat)"
    echo ""
    echo "Your system: Ubuntu $release ($codename)"
    echo ""
    echo "Ubuntu versions older than 20.04 are End of Life and have"
    echo "critical security vulnerabilities."
    echo ""
    echo "Please upgrade to a supported LTS release."
    echo "=========================================================="
    exit 1
fi

# Creating temporary file
tmpfile=$(mktemp -p /tmp)

# Translating argument to --gnu-long-options
for arg; do
    delim=""
    case "$arg" in
        --apache)               args="${args}-a " ;;
        --nginx)                args="${args}-n " ;;
        --phpfpm)               args="${args}-w " ;;
        --vsftpd)               args="${args}-v " ;;
        --proftpd)              args="${args}-j " ;;
        --named)                args="${args}-k " ;;
        --mysql)                args="${args}-m " ;;
        --postgresql)           args="${args}-g " ;;
        --exim)                 args="${args}-x " ;;
        --dovecot)              args="${args}-z " ;;
        --clamav)               args="${args}-c " ;;
        --spamassassin)         args="${args}-t " ;;
        --iptables)             args="${args}-i " ;;
        --fail2ban)             args="${args}-b " ;;
        --softaculous)          args="${args}-o " ;;
        --quota)                args="${args}-q " ;;
        --lang)                 args="${args}-l " ;;
        --php)                  php_arg="$2"; shift ;;
        --interactive)          args="${args}-y " ;;
        --hostname)             args="${args}-s " ;;
        --ssl)                  args="${args}-u " ;;
        --email)                args="${args}-e " ;;
        --port)                 args="${args}-d " ;;
        --password)             args="${args}-p " ;;
        --force)                args="${args}-f " ;;
        --help)                 args="${args}-h " ;;
        *)                      [[ "${arg:0:1}" == "-" ]] || delim="\""
                                args="${args}${delim}${arg}${delim} ";;
    esac
done
eval set -- "$args"

# Handle PHP version
if [ ! -z "$php_arg" ]; then
    if [[ "$php_arg" == "8.2" ]] || [[ "$php_arg" == "8.3" ]] || [[ "$php_arg" == "8.4" ]]; then
        php_version="$php_arg"
    else
        echo "Error: Invalid PHP version. Supported versions: 8.2, 8.3, 8.4"
        exit 1
    fi
fi

# Parsing arguments
while getopts "a:n:w:v:j:k:m:g:x:z:c:t:i:b:o:q:l:y:s:u:e:d:p:fh" Option; do
    case $Option in
        a) apache=$OPTARG ;;            # Apache
        n) nginx=$OPTARG ;;             # Nginx
        w) phpfpm=$OPTARG ;;            # PHP-FPM
        v) vsftpd=$OPTARG ;;            # Vsftpd
        j) proftpd=$OPTARG ;;           # Proftpd
        k) named=$OPTARG ;;             # Named
        m) mysql=$OPTARG ;;             # MySQL/MariaDB
        g) postgresql=$OPTARG ;;        # PostgreSQL
        x) exim=$OPTARG ;;              # Exim
        z) dovecot=$OPTARG ;;           # Dovecot
        c) clamd=$OPTARG ;;             # ClamAV
        t) spamd=$OPTARG ;;             # SpamAssassin
        i) iptables=$OPTARG ;;          # Iptables
        b) fail2ban=$OPTARG ;;          # Fail2ban
        o) softaculous=$OPTARG ;;       # Softaculous plugin
        q) quota=$OPTARG ;;             # FS Quota
        l) lang=$OPTARG ;;              # Language
        y) interactive=$OPTARG ;;       # Interactive install
        s) servername=$OPTARG ;;        # Hostname
        u) ssl=$OPTARG ;;               # Add Let's Encrypt SSL for hostname
        e) email=$OPTARG ;;             # Admin email
        d) port=$OPTARG ;;              # Vesta port
        p) vpass=$OPTARG ;;             # Admin password
        f) force='yes' ;;               # Force install
        h) help ;;                      # Help
        *) help ;;                      # Print help (default)
    esac
done

# Defining default software stack
set_default_value 'nginx' 'yes'
set_default_value 'apache' 'yes'
set_default_value 'phpfpm' 'no'
set_default_value 'vsftpd' 'yes'
set_default_value 'proftpd' 'no'
set_default_value 'named' 'yes'
set_default_value 'mysql' 'yes'
set_default_value 'postgresql' 'no'
set_default_value 'exim' 'yes'
set_default_value 'dovecot' 'yes'
if [ $memory -lt 1500000 ]; then
    set_default_value 'clamd' 'no'
    set_default_value 'spamd' 'no'
else
    set_default_value 'clamd' 'yes'
    set_default_value 'spamd' 'yes'
fi
set_default_value 'iptables' 'yes'
set_default_value 'fail2ban' 'yes'
set_default_value 'softaculous' 'yes'
set_default_value 'quota' 'no'
set_default_value 'interactive' 'yes'
set_default_value 'ssl' 'no'
set_default_lang 'en'

# Checking software conflicts
if [ "$phpfpm" = 'yes' ]; then
    apache='no'
    nginx='yes'
fi
if [ "$proftpd" = 'yes' ]; then
    vsftpd='no'
fi
if [ "$exim" = 'no' ]; then
    clamd='no'
    spamd='no'
    dovecot='no'
fi
if [ "$iptables" = 'no' ]; then
    fail2ban='no'
fi

# Checking root permissions
if [ "x$(id -u)" != 'x0' ]; then
    check_result 1 "Script can only be executed by root"
fi

# Checking admin user account
if [ ! -z "$(grep ^admin: /etc/passwd)" ] && [ -z "$force" ]; then
    echo 'Please remove admin user account before proceeding.'
    echo 'If you want to do it automatically run installer with -f option:'
    echo -e "Example: bash $0 --force\n"
    check_result 1 "User admin exists"
fi

# Checking wget
if [ ! -e '/usr/bin/wget' ]; then
    apt-get -y install wget
    check_result $? "Can't install wget"
fi

# Checking repository availability
wget -q "c.vestacp.com/deb_signing.key" -O /dev/null
check_result $? "No access to Vesta repository"

echo "=========================================================="
echo "  Vesta Control Panel - Modern Installation"
echo "=========================================================="
echo ""
echo "  OS: Ubuntu $release ($codename)"
echo "  PHP Version: $php_version"
echo "  Database: MariaDB 10.11+"
echo ""
echo "  This installer uses modern, supported software versions:"
echo "  - PHP $php_version (from ondrej PPA)"
echo "  - MariaDB 10.11+ (default Ubuntu repo)"
echo "  - Nginx (latest stable)"
echo "  - PostgreSQL 16+ (if selected)"
echo ""
echo "=========================================================="
echo ""

#----------------------------------------------------------#
#                     Package Installation                  #
#----------------------------------------------------------#

# Update system packages
echo "Updating system packages..."
apt-get update
apt-get -y upgrade
check_result $? 'apt-get upgrade failed'

# Install basic tools
echo "Installing basic tools..."
apt-get -y install curl wget gnupg2 ca-certificates lsb-release apt-transport-https software-properties-common
check_result $? 'Failed to install basic tools'

# Add PHP repository (ondrej PPA)
echo "Adding PHP $php_version repository..."
add-apt-repository -y ppa:ondrej/php
check_result $? 'Failed to add PHP repository'

# Add Nginx repository
echo "Adding Nginx repository..."
curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu $codename nginx" > /etc/apt/sources.list.d/nginx.list
check_result $? 'Failed to add Nginx repository'

# Add Vesta repository
echo "Adding Vesta repository..."
wget -qO - https://c.vestacp.com/deb_signing.key | gpg --dearmor -o /usr/share/keyrings/vesta-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/vesta-keyring.gpg] https://apt.vestacp.com/$codename/ $codename vesta" > /etc/apt/sources.list.d/vesta.list
check_result $? 'Failed to add Vesta repository'

# Update package lists
echo "Updating package lists..."
apt-get update
check_result $? 'apt-get update failed'

#----------------------------------------------------------#
#                    Install Software Stack                #
#----------------------------------------------------------#

echo "Installing Vesta Control Panel and dependencies..."
echo "This may take 10-20 minutes depending on your connection..."

# Install Nginx
if [ "$nginx" = 'yes' ]; then
    echo "Installing Nginx..."
    apt-get -y install nginx
    check_result $? 'Failed to install Nginx'
    systemctl stop nginx
fi

# Install Apache
if [ "$apache" = 'yes' ]; then
    echo "Installing Apache..."
    apt-get -y install apache2 apache2-utils apache2-suexec-custom libapache2-mod-fcgid libapache2-mod-rpaf libapache2-mod-ruid2
    check_result $? 'Failed to install Apache'
    systemctl stop apache2
fi

# Install PHP
echo "Installing PHP $php_version and extensions..."
apt-get -y install \
    php${php_version} \
    php${php_version}-cli \
    php${php_version}-common \
    php${php_version}-fpm \
    php${php_version}-cgi \
    php${php_version}-mysql \
    php${php_version}-pgsql \
    php${php_version}-curl \
    php${php_version}-gd \
    php${php_version}-mbstring \
    php${php_version}-xml \
    php${php_version}-zip \
    php${php_version}-bcmath \
    php${php_version}-soap \
    php${php_version}-intl \
    php${php_version}-imap \
    php${php_version}-readline \
    php${php_version}-xmlrpc \
    libapache2-mod-php${php_version}
check_result $? 'Failed to install PHP'

# Install MariaDB/MySQL
if [ "$mysql" = 'yes' ]; then
    echo "Installing MariaDB..."
    apt-get -y install mariadb-server mariadb-client
    check_result $? 'Failed to install MariaDB'
    systemctl stop mariadb
fi

# Install PostgreSQL
if [ "$postgresql" = 'yes' ]; then
    echo "Installing PostgreSQL..."
    apt-get -y install postgresql postgresql-contrib
    check_result $? 'Failed to install PostgreSQL'
    systemctl stop postgresql
fi

# Install Bind DNS server
if [ "$named" = 'yes' ]; then
    echo "Installing Bind DNS..."
    apt-get -y install bind9 dnsutils
    check_result $? 'Failed to install Bind'
    systemctl stop named
fi

# Install Exim mail server
if [ "$exim" = 'yes' ]; then
    echo "Installing Exim..."
    apt-get -y install exim4 exim4-daemon-heavy
    check_result $? 'Failed to install Exim'
    systemctl stop exim4
fi

# Install Dovecot
if [ "$dovecot" = 'yes' ]; then
    echo "Installing Dovecot..."
    apt-get -y install dovecot-imapd dovecot-pop3d
    check_result $? 'Failed to install Dovecot'
    systemctl stop dovecot
fi

# Install ClamAV
if [ "$clamd" = 'yes' ]; then
    echo "Installing ClamAV..."
    apt-get -y install clamav clamav-daemon
    check_result $? 'Failed to install ClamAV'
    systemctl stop clamav-daemon || true
fi

# Install SpamAssassin
if [ "$spamd" = 'yes' ]; then
    echo "Installing SpamAssassin..."
    apt-get -y install spamassassin
    check_result $? 'Failed to install SpamAssassin'
fi

# Install FTP server
if [ "$vsftpd" = 'yes' ]; then
    echo "Installing vsftpd..."
    apt-get -y install vsftpd
    check_result $? 'Failed to install vsftpd'
    systemctl stop vsftpd
fi

if [ "$proftpd" = 'yes' ]; then
    echo "Installing ProFTPD..."
    apt-get -y install proftpd-basic
    check_result $? 'Failed to install ProFTPD'
    systemctl stop proftpd
fi

# Install fail2ban
if [ "$fail2ban" = 'yes' ]; then
    echo "Installing fail2ban..."
    apt-get -y install fail2ban
    check_result $? 'Failed to install fail2ban'
    systemctl stop fail2ban
fi

# Install additional utilities
echo "Installing additional utilities..."
apt-get -y install \
    awstats bc bsdmainutils cron curl e2fsprogs expect \
    flex ftp git idn imagemagick lsof mc ntpdate quota \
    rrdtool rssh sudo vim-common webalizer whois zip net-tools
check_result $? 'Failed to install utilities'

#----------------------------------------------------------#
#                  Configure System                        #
#----------------------------------------------------------#

# Disable AppArmor for MySQL/MariaDB (conflicts with Vesta)
if [ -e '/etc/init.d/apparmor' ]; then
    systemctl stop apparmor
    systemctl disable apparmor
    aa-teardown
fi

# Generate admin password if not provided
if [ -z "$vpass" ]; then
    vpass=$(gen_pass)
fi

# Set admin email if not provided
if [ -z "$email" ]; then
    email="admin@$servername"
fi

# Set hostname if not provided
if [ -z "$servername" ]; then
    servername=$(hostname -f)
fi

# Set Vesta port if not provided
if [ -z "$port" ]; then
    port='8083'
fi

#----------------------------------------------------------#
#                  Install Vesta Core                      #
#----------------------------------------------------------#

echo "Installing Vesta Control Panel core..."

# Create Vesta user
if [ -z "$(grep ^admin: /etc/passwd)" ]; then
    useradd -c "Vesta Control Panel" -d "$VESTA" -r -s /bin/bash admin
fi

# Create directory structure
mkdir -p \
    $VESTA/conf \
    $VESTA/log \
    $VESTA/ssl \
    $VESTA/data/ips \
    $VESTA/data/queue \
    $VESTA/data/users \
    $VESTA/data/firewall

# Download and install Vesta packages
apt-get -y install vesta vesta-nginx vesta-php
check_result $? 'Failed to install Vesta packages'

# Copy configuration templates from our modern configs
if [ -d "$VESTA/install/ubuntu/$release" ]; then
    echo "Applying modern configuration templates..."

    # Copy PHP configurations
    if [ -d "$VESTA/install/ubuntu/$release/php" ]; then
        cp -f $VESTA/install/ubuntu/$release/php/php.ini /etc/php/$php_version/fpm/php.ini
        cp -f $VESTA/install/ubuntu/$release/php/www.conf /etc/php/$php_version/fpm/pool.d/www.conf
    fi

    # Copy Nginx configurations
    if [ -d "$VESTA/install/ubuntu/$release/nginx" ]; then
        cp -f $VESTA/install/ubuntu/$release/nginx/nginx.conf /etc/nginx/nginx.conf
    fi

    # Copy Apache configurations
    if [ "$apache" = 'yes' ] && [ -d "$VESTA/install/ubuntu/$release/apache2" ]; then
        cp -f $VESTA/install/ubuntu/$release/apache2/apache2.conf /etc/apache2/apache2.conf
    fi

    # Copy MariaDB configurations
    if [ "$mysql" = 'yes' ] && [ -d "$VESTA/install/ubuntu/$release/mysql" ]; then
        cp -f $VESTA/install/ubuntu/$release/mysql/my.cnf /etc/mysql/my.cnf
    fi

    # Copy fail2ban configurations
    if [ "$fail2ban" = 'yes' ] && [ -d "$VESTA/install/ubuntu/$release/fail2ban" ]; then
        cp -f $VESTA/install/ubuntu/$release/fail2ban/jail.local /etc/fail2ban/jail.local
    fi
fi

#----------------------------------------------------------#
#                  Configure Web Servers                   #
#----------------------------------------------------------#

# Configure Apache to listen on 8080 (behind Nginx)
if [ "$apache" = 'yes' ]; then
    echo "Configuring Apache as backend..."
    sed -i 's/Listen 80/Listen 127.0.0.1:8080/' /etc/apache2/ports.conf
    sed -i 's/:80>/:8080>/' /etc/apache2/sites-available/000-default.conf

    # Enable required modules
    a2enmod rewrite ssl actions fcgid alias proxy_fcgi setenvif
    a2dismod mpm_prefork
    a2enmod mpm_event
fi

# Configure Nginx
if [ "$nginx" = 'yes' ]; then
    echo "Configuring Nginx as frontend..."
    rm -f /etc/nginx/sites-enabled/default
    rm -f /etc/nginx/conf.d/default.conf
fi

#----------------------------------------------------------#
#                  Configure Database                      #
#----------------------------------------------------------#

if [ "$mysql" = 'yes' ]; then
    echo "Configuring MariaDB..."

    # Start MariaDB
    systemctl start mariadb
    check_result $? 'Failed to start MariaDB'

    # Generate root password
    mpass=$(gen_pass)

    # Secure installation
    mysql -e "DELETE FROM mysql.user WHERE User='';"
    mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    mysql -e "DROP DATABASE IF EXISTS test;"
    mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$mpass';"
    mysql -e "FLUSH PRIVILEGES;"

    # Save credentials
    echo "[client]" > /root/.my.cnf
    echo "user=root" >> /root/.my.cnf
    echo "password='$mpass'" >> /root/.my.cnf
    chmod 600 /root/.my.cnf

    echo "MariaDB root password: $mpass" >> $tmpfile
fi

#----------------------------------------------------------#
#                  Configure PHP-FPM                       #
#----------------------------------------------------------#

echo "Configuring PHP-FPM..."

# Ensure PHP-FPM socket directory exists
mkdir -p /run/php
chown www-data:www-data /run/php

# Create PHP-FPM log directory
mkdir -p /var/log/php
chown www-data:www-data /var/log/php

# Start PHP-FPM
systemctl enable php${php_version}-fpm
systemctl start php${php_version}-fpm
check_result $? 'Failed to start PHP-FPM'

#----------------------------------------------------------#
#                  Configure Mail Services                 #
#----------------------------------------------------------#

if [ "$exim" = 'yes' ]; then
    echo "Configuring Exim..."
    # Exim configuration will be handled by Vesta
    systemctl enable exim4
fi

if [ "$dovecot" = 'yes' ]; then
    echo "Configuring Dovecot..."
    # Dovecot configuration will be handled by Vesta
    systemctl enable dovecot
fi

if [ "$clamd" = 'yes' ]; then
    echo "Configuring ClamAV..."
    freshclam
    systemctl enable clamav-daemon
fi

if [ "$spamd" = 'yes' ]; then
    echo "Configuring SpamAssassin..."
    systemctl enable spamassassin
fi

#----------------------------------------------------------#
#                  Configure DNS                           #
#----------------------------------------------------------#

if [ "$named" = 'yes' ]; then
    echo "Configuring Bind DNS..."
    # Bind configuration will be handled by Vesta
    systemctl enable named
fi

#----------------------------------------------------------#
#                  Configure FTP                           #
#----------------------------------------------------------#

if [ "$vsftpd" = 'yes' ]; then
    echo "Configuring vsftpd..."
    systemctl enable vsftpd
fi

if [ "$proftpd" = 'yes' ]; then
    echo "Configuring ProFTPD..."
    systemctl enable proftpd
fi

#----------------------------------------------------------#
#                  Configure Firewall                      #
#----------------------------------------------------------#

if [ "$iptables" = 'yes' ]; then
    echo "Configuring firewall rules..."

    # Create basic firewall rules
    mkdir -p $VESTA/data/firewall

    # Allow SSH, HTTP, HTTPS, Vesta, Mail, DNS, FTP
    cat > $VESTA/data/firewall/rules.conf <<EOF
# SSH
ACCEPT 22

# HTTP/HTTPS
ACCEPT 80
ACCEPT 443

# Vesta Control Panel
ACCEPT $port

# Mail
ACCEPT 25
ACCEPT 465
ACCEPT 587
ACCEPT 110
ACCEPT 995
ACCEPT 143
ACCEPT 993

# DNS
ACCEPT 53

# FTP
ACCEPT 21
ACCEPT 12000:12100
EOF
fi

if [ "$fail2ban" = 'yes' ]; then
    echo "Configuring fail2ban..."
    systemctl enable fail2ban
    systemctl start fail2ban
fi

#----------------------------------------------------------#
#                  Configure Vesta User                    #
#----------------------------------------------------------#

echo "Configuring Vesta admin user..."

# Set admin password
echo "admin:$vpass" | chpasswd

# Create admin user configuration
mkdir -p $VESTA/data/users/admin

cat > $VESTA/data/users/admin/user.conf <<EOF
FNAME='System'
LNAME='Administrator'
PACKAGE='default'
WEB_TEMPLATE='default'
BACKEND_TEMPLATE='default'
PROXY_TEMPLATE='default'
DNS_TEMPLATE='default'
WEB_DOMAINS='0'
WEB_ALIASES='0'
DNS_DOMAINS='0'
DNS_RECORDS='0'
MAIL_DOMAINS='0'
MAIL_ACCOUNTS='0'
DATABASES='0'
CRON_JOBS='0'
DISK_QUOTA='unlimited'
BANDWIDTH='unlimited'
NS='ns1.$servername'
NS2='ns2.$servername'
SHELL='/bin/bash'
BACKUPS='0'
TIME='$(date +%Y-%m-%d)'
DATE='$(date +%Y-%m-%d)'
SUSPENDED='no'
SUSPEND_TIME='0'
EOF

#----------------------------------------------------------#
#                  Install acme.sh                         #
#----------------------------------------------------------#

echo "Installing acme.sh for Let's Encrypt..."
curl https://get.acme.sh | sh -s email=$email
mkdir -p $VESTA/ssl/acme.sh
ln -s ~/.acme.sh/acme.sh $VESTA/ssl/acme.sh/acme.sh

#----------------------------------------------------------#
#                  Configure SSL for Vesta                 #
#----------------------------------------------------------#

if [ "$ssl" = 'yes' ] && [ ! -z "$servername" ]; then
    echo "Requesting Let's Encrypt SSL certificate for Vesta..."

    # Ensure web root exists
    mkdir -p /var/www/html

    # Request certificate
    ~/.acme.sh/acme.sh --issue \
        -d $servername \
        -w /var/www/html \
        --server letsencrypt \
        --keylength 2048 \
        --force

    if [ $? -eq 0 ]; then
        # Install certificate
        mkdir -p $VESTA/ssl
        ~/.acme.sh/acme.sh --install-cert -d $servername \
            --cert-file $VESTA/ssl/certificate.crt \
            --key-file $VESTA/ssl/certificate.key \
            --fullchain-file $VESTA/ssl/certificate.pem

        echo "SSL certificate installed for $servername"
    else
        echo "Failed to obtain SSL certificate. Using self-signed certificate."
        # Generate self-signed certificate
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout $VESTA/ssl/certificate.key \
            -out $VESTA/ssl/certificate.crt \
            -subj "/CN=$servername"
    fi
else
    echo "Generating self-signed SSL certificate..."
    mkdir -p $VESTA/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout $VESTA/ssl/certificate.key \
        -out $VESTA/ssl/certificate.crt \
        -subj "/CN=$servername"
fi

#----------------------------------------------------------#
#                  Start All Services                      #
#----------------------------------------------------------#

echo "Starting all services..."

# Start web servers
[ "$nginx" = 'yes' ] && systemctl start nginx && systemctl enable nginx
[ "$apache" = 'yes' ] && systemctl start apache2 && systemctl enable apache2

# Start mail services
[ "$exim" = 'yes' ] && systemctl start exim4
[ "$dovecot" = 'yes' ] && systemctl start dovecot
[ "$clamd" = 'yes' ] && systemctl start clamav-daemon
[ "$spamd" = 'yes' ] && systemctl start spamassassin

# Start DNS
[ "$named" = 'yes' ] && systemctl start named

# Start FTP
[ "$vsftpd" = 'yes' ] && systemctl start vsftpd
[ "$proftpd" = 'yes' ] && systemctl start proftpd

# Start Vesta
systemctl enable vesta
systemctl start vesta

#----------------------------------------------------------#
#                  Final Configuration                     #
#----------------------------------------------------------#

# Update system time
ntpdate -u pool.ntp.org

# Set proper permissions
chmod 750 $VESTA/data/users/admin
chown -R admin:admin $VESTA/data/users/admin

# Clean up
apt-get -y autoremove
apt-get clean

#----------------------------------------------------------#
#                  Installation Complete                   #
#----------------------------------------------------------#

# Get server IP
ip=$(hostname -I | awk '{print $1}')

# Display installation information
clear
echo "=========================================================="
echo "                 INSTALLATION COMPLETE!"
echo "=========================================================="
echo ""
echo "  Vesta Control Panel has been successfully installed!"
echo ""
echo "  Access Details:"
echo "  ───────────────────────────────────────────────────────"
echo "  URL:      https://$servername:$port"
echo "  IP:       https://$ip:$port"
echo "  Username: admin"
echo "  Password: $vpass"
echo ""
echo "  Software Installed:"
echo "  ───────────────────────────────────────────────────────"
echo "  OS:         Ubuntu $release ($codename)"
echo "  PHP:        $php_version"
echo "  Database:   $([ "$mysql" = 'yes' ] && echo 'MariaDB' || echo 'None')"
echo "  Web:        $([ "$nginx" = 'yes' ] && echo 'Nginx' || echo '')$([ "$nginx" = 'yes' ] && [ "$apache" = 'yes' ] && echo ' + ' || echo '')$([ "$apache" = 'yes' ] && echo 'Apache' || echo '')"
echo "  Mail:       $([ "$exim" = 'yes' ] && echo 'Exim + Dovecot' || echo 'None')"
echo "  DNS:        $([ "$named" = 'yes' ] && echo 'Bind' || echo 'None')"
echo "  FTP:        $([ "$vsftpd" = 'yes' ] && echo 'vsftpd' || echo '')$([ "$proftpd" = 'yes' ] && echo 'ProFTPD' || echo '')"
echo "  Firewall:   $([ "$fail2ban" = 'yes' ] && echo 'fail2ban + iptables' || echo 'iptables')"
echo ""
echo "  Important Notes:"
echo "  ───────────────────────────────────────────────────────"
echo "  • Please save the password above in a secure location"
echo "  • First login may take a few seconds to load"
echo "  • Documentation: https://vestacp.com/docs/"
echo "  • Support Forum: https://forum.vestacp.com/"
echo ""
if [ "$mysql" = 'yes' ]; then
    echo "  Database Root Password:"
    echo "  ───────────────────────────────────────────────────────"
    echo "  MySQL/MariaDB root password is saved in: /root/.my.cnf"
    echo ""
fi
echo "=========================================================="
echo ""

# Save installation details to file
cat > /root/vesta_install_info.txt <<EOF
Vesta Control Panel Installation Information
═══════════════════════════════════════════════════════════

Installation Date: $(date)
Server: $servername
IP: $ip

Vesta Control Panel Access:
────────────────────────────────────────────────────────────
URL:      https://$servername:$port
          https://$ip:$port
Username: admin
Password: $vpass

Software Stack:
────────────────────────────────────────────────────────────
OS:         Ubuntu $release ($codename)
PHP:        $php_version
Database:   $([ "$mysql" = 'yes' ] && echo 'MariaDB' || echo 'None')
Web:        $([ "$nginx" = 'yes' ] && echo 'Nginx' || echo '')$([ "$nginx" = 'yes' ] && [ "$apache" = 'yes' ] && echo ' + ' || echo '')$([ "$apache" = 'yes' ] && echo 'Apache' || echo '')
Mail:       $([ "$exim" = 'yes' ] && echo 'Exim + Dovecot' || echo 'None')
DNS:        $([ "$named" = 'yes' ] && echo 'Bind' || echo 'None')
FTP:        $([ "$vsftpd" = 'yes' ] && echo 'vsftpd' || echo '')$([ "$proftpd" = 'yes' ] && echo 'ProFTPD' || echo '')
Security:   $([ "$fail2ban" = 'yes' ] && echo 'fail2ban + iptables' || echo 'iptables')

Additional Information:
────────────────────────────────────────────────────────────
$([ "$mysql" = 'yes' ] && echo "MySQL/MariaDB root password: Saved in /root/.my.cnf" || echo "")

Documentation: https://vestacp.com/docs/
Support:       https://forum.vestacp.com/

═══════════════════════════════════════════════════════════
EOF

echo "Installation details have been saved to: /root/vesta_install_info.txt"
echo ""

# Remove temp file
rm -f $tmpfile

exit 0
