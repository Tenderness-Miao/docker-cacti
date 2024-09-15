FROM rockylinux/rockylinux:9.4

LABEL org.opencontainers.image.authors="Sean Cline <smcline06@gmail.com>"

EXPOSE 80 443

## --- ENV ---
ENV \
    DB_NAME=cacti \
    DB_USER=cactiuser \
    DB_PASS=cactipassword \
    DB_HOST=localhost \
    DB_PORT=3306 \
    RDB_NAME=cacti \
    RDB_USER=cactiuser \
    RDB_PASS=cactipassword \
    RDB_HOST=localhost \
    RDB_PORT=3306 \
    CACTI_URL_PATH=cacti \
    BACKUP_RETENTION=7 \
    BACKUP_TIME=0 \
    REMOTE_POLLER=0 \
    INITIALIZE_DB=0 \
    TZ=UTC \
    PHP_MEMORY_LIMIT=800M \
    PHP_MAX_EXECUTION_TIME=60 \
    PHP_SNMP=1

CMD ["sh", "/start.sh"]

## --- Start ---
COPY start.sh /start.sh

## --- SERVICE CONFIGS ---
COPY configs /template_configs
COPY configs/crontab /etc/crontab

## --- SETTINGS/EXTRAS ---
COPY plugins /cacti_install/plugins
COPY templates /templates
COPY settings /settings

## --- SCRIPTS ---
COPY upgrade.sh /upgrade.sh
COPY restore.sh /restore.sh
COPY backup.sh /backup.sh

## --- UPDATE OS, INSTALL EPEL, PHP EXTENTIONS, CACTI/SPINE Requirements, Other/Requests ---
RUN \
    chmod +x /upgrade.sh && \
    chmod +x /restore.sh && \
    chmod +x /backup.sh && \
    chmod u+s /bin/ping && \
    chmod g+s /bin/ping && \
    mkdir /backups && \
    mkdir /cacti && \
    mkdir /spine && \
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    yum config-manager --set-enabled crb && \
    yum install -y \
    php php-xml php-session php-sockets php-ldap php-gd \
    php-json php-mysqlnd php-gmp php-mbstring php-posix \
    php-intl php-common php-cli php-devel php-pear \
    php-pdo && \
    yum install -y \
    rrdtool net-snmp net-snmp-utils cronie mariadb autoconf \
    bison openssl openldap mod_ssl net-snmp-libs automake \
    gcc gzip libtool make net-snmp-devel dos2unix m4 which \
    openssl-devel sendmail wget perl-libwww-perl && \
    wget --no-check-certificate --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36" -q 'http://www.cacti.net/downloads/cacti-latest.tar.gz' -O /cacti_install/cacti-latest.tar.gz && \
    wget --no-check-certificate --user-agent="Mozilla/5.0 (Windows NT  10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36" -q 'http://www.cacti.net/downloads/spine/cacti-spine-latest.tar.gz' -O /cacti_install/cacti-spine-latest.tar.gz && \
    yum clean all && \
    rm -rf /var/cache/yum/* && \
    chmod 0644 /etc/crontab && \
    echo "ServerName localhost" > /etc/httpd/conf.d/fqdn.conf && \
    /usr/libexec/httpd-ssl-gencerts
