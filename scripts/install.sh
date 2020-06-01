yum -y install epel-release;
yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm;
yum -y update;
yum -y install pgadmin4
echo '<VirtualHost *:80>' > /etc/httpd/conf.d/pgadmin4.conf
cat /etc/httpd/conf.d/pgadmin4.conf.sample >> /etc/httpd/conf.d/pgadmin4.conf
echo '</VirtualHost>' >> /etc/httpd/conf.d/pgadmin4.conf
sed -i '/^<VirtualHost \*:80>/,/^<\/VirtualHost>/d' /etc/httpd/conf/httpd.conf
httpd -t
systemctl restart httpd
mkdir -p /var/lib/pgadmin4/ /var/log/pgadmin4/
cat << EOF >> /usr/lib/python3.6/site-packages/pgadmin4-web/config_distro.py
LOG_FILE = '/var/log/pgadmin4/pgadmin4.log'
SQLITE_PATH = '/var/lib/pgadmin4/pgadmin4.db'
SESSION_DB_PATH = '/var/lib/pgadmin4/sessions'
STORAGE_DIR = '/var/lib/pgadmin4/storage'
EOF
expect -c '
spawn python3 /usr/lib/python3.6/site-packages/pgadmin4-web/setup.py
expect "Email address:"
send "${globals.email}\r"
expect "Password:"
send "${globals.password}\r"
expect "Retype password:" 
send "${globals.password}\r"
expect eof
'
chown -R apache:apache /var/lib/pgadmin4 /var/log/pgadmin4
cat << EOF > $WEBROOT/ROOT/.htaccess
RewriteEngine On
RewriteRule   /*  /pgadmin4
EOF
chmod 644 $WEBROOT/ROOT/.htaccess
