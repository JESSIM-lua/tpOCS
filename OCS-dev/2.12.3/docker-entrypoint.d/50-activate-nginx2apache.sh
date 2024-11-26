#!/bin/bash

# Get timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "[$TIMESTAMP] Error: Please run as root"
    # exit 1
fi

# Check if Apache is installed
if ! command -v apache2ctl &>/dev/null; then
    echo "[$TIMESTAMP] Error: Apache is not installed"
    # exit 1
fi

echo "[$TIMESTAMP] Starting Apache headers and rewrite module check..."

a2enmod proxy proxy_http headers rewrite

echo "[$TIMESTAMP] - DEBUG - apache2ctl -M -> $(apache2ctl -M)"
echo "[$TIMESTAMP] Script completed successfully"

ocs_container_ip=$(hostname -i)

cat >/etc/apache2/conf-available/zzz-ocsnginxrewrite.conf <<EOF
# OCS server configuration

<VirtualHost *:80>
    ServerName localhost

    ProxyTimeout 60

    <Location />
        RedirectMatch permanent ^/$ /ocsreports
        ProxyPass http://localhost/
        ProxyPassReverse http://localhost/
        RequestHeader set X-Forwarded-Proto \$scheme
        RequestHeader set Host \$http_host
        RequestHeader set X-Real-IP \$remote_addr
        RequestHeader set X-Forwarded-For \$proxy_add_x_forwarded_for
        Header set X-Frame-Options SAMEORIGIN
    </Location>

    <Location /ocsapi>
        AuthType Basic
        AuthName "OCS Api area"
        AuthUserFile /etc/apache2/ocsapi.htaccess
        ProxyPass http://localhost/ocsapi/
        ProxyPassReverse http://localhost/ocsapi/
    </Location>

    <Location /download>
        ProxyPass http://localhost/download/
        ProxyPassReverse http://localhost/download/
        ProxyPreserveHost On
        LimitRequestBody 10485760
    </Location>
</VirtualHost>
EOF

mkdir /etc/apache2/auth
echo $OCS_API_PASS >/etc/apache2/auth/ocsapi.htaccess

a2enconf zzz-ocsnginxrewrite
