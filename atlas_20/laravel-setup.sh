#!/bin/bash

if [ ! -e /etc/.initsuccess ]
then
/tmp/mysql-setup.sh
/tmp/ssl.sh
/tmp/ssl.sh

ID_HOST=${ID_HOST:-http://${HOST_IP}:8888}
SERVER_DATA=${SERVER_DATA:-https://${HOST_IP}:$HTTPS_PORT/data.php?callback=loadSites}
SERVER_URL=${SERVER_URL:-https://${HOST_IP}:${HTTPS_PORT}/}

cd /opt/atlas
cp env.local.php .env.prod.php

sed -i 's/\/var\/www/\/opt\/atlas\/public/g' /etc/apache2/apache2.conf

sed -i 's/user/atlas/g' .env.prod.php
sed -i 's/password/atlas/g' .env.prod.php
sed -i "s/secret'/secret',/g" .env.prod.php
sed -i 's#http://localhost:3000#'$ID_HOST'#g' .env.prod.php
sed -i 's#http://localhost/openmrs-contrib-atlas/public/data.php?callback=loadSites#'$SERVER_DATA'#g' .env.prod.php
sed -i 's#http://localhost/openmrs-contrib-atlas/public/#'$CAPTURE_URL'#g' .env.prod.php
sed -i 's/bin\/phantomjs/local\/bin\/phantomjs/g' .env.prod.php

#Set correct database collation and charset 
sed -i '0,/utf8/s/utf8/latin1/g' app/config/database.php
sed -i 's/utf8_unicode_ci/latin1_swedish_ci/g' app/config/database.php

TMP_HOST=$(hostname)
#Set production hostname in bootstrap/start.php
sed -i 's/atlas-server/'$TMP_HOST'/' bootstrap/start.php

service mysql start
sleep 5
if [ $SAMPLE_DATA = "1" ]
then
	mysql -uatlas -patlas --database atlas < /tmp/atlas.sql || { echo 'Command failed' ; exit 1; }
fi

php artisan migrate || { echo 'Command failed' ; exit 1; }

rm /etc/apache2/sites-available/000-default.conf
mv /tmp/000-default.conf /etc/apache2/sites-available/000-default.conf

sed -i 's/HTTPS-PORT/'$HTTPS_PORT'/g' /etc/apache2/sites-available/000-default.conf

cd /opt/auth

echo "Listen 8888" >> /etc/apache2/apache2.conf

sed -i 's#https://atlas.local/#'$SERVER_URL#'g' config.php
service mysql stop
sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

crontab /etc/crontab

touch /etc/.initsuccess
fi

/usr/bin/supervisord