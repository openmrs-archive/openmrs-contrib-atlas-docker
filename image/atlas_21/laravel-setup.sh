#!/bin/bash

. /tmp/atlas.cfg

if [ ! -e /etc/.initsuccess ]
then

MYSQL_HOST=${MYSQL_HOST:-atlas_db}
ID_HOST=${ID_HOST:-http://${HOST_IP}:8888}
SERVER_DATA=${SERVER_DATA:-https://${HOST_IP}:$HTTPS_PORT/data.php?callback=loadSites}
SERVER_URL=${SERVER_URL:-https://${HOST_IP}:${HTTPS_PORT}/}
echo $SSH_PUB_KEY > /root/.ssh/authorized_keys
chmod 640 /root/.ssh/authorized_keys

cd /opt/atlas
cp env.local.php .env.prod.php

sed -i 's/\/var\/www/\/opt\/atlas\/public/g' /etc/apache2/apache2.conf

sed -i "s/'DB_HOST' => 'localhost'/'DB_HOST' => '$MYSQL_HOST'/g" .env.prod.php
sed -i 's/user/'$MYSQL_USER'/g' .env.prod.php
sed -i 's/password/'$MYSQL_PASSWORD'/g' .env.prod.php
sed -i "s/secret'/secret',/g" .env.prod.php
sed -i 's#http://localhost:3000#'$ID_HOST'#g' .env.prod.php
sed -i 's#http://localhost/openmrs-contrib-atlas/public/data.php?callback=loadSites#'$SERVER_DATA'#g' .env.prod.php
sed -i 's#http://localhost/openmrs-contrib-atlas/public/#'$CAPTURE_URL'#g' .env.prod.php
sed -i 's/bin\/phantomjs/local\/bin\/phantomjs/g' .env.prod.php
sed -i 's/UTC/'$TIMEZONE'/g' .env.prod.php

#Set correct database collation and charset 
sed -i '0,/utf8/s/utf8/latin1/g' app/config/database.php
sed -i 's/utf8_unicode_ci/latin1_swedish_ci/g' app/config/database.php

TMP_HOST=$(hostname)
#Set production hostname in bootstrap/start.php
sed -i 's/atlas-server/'$TMP_HOST'/' bootstrap/start.php

php artisan migrate

rm /etc/apache2/sites-available/000-default.conf
mv /tmp/000-default.conf /etc/apache2/sites-available/000-default.conf

sed -i 's/HTTPS-PORT/'$HTTPS_PORT'/g' /etc/apache2/sites-available/000-default.conf

cd /opt/auth

if [ $SELF_ID == "TRUE" ]
then
  echo "Listen 8888" >> /etc/apache2/apache2.conf
  a2ensite auth.conf
fi

sed -i 's#https://atlas.local/#'$SERVER_URL#'g' config.php

crontab /etc/crontab

touch /etc/.initsuccess
else
cd /opt/atlas
git remote update
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
BASE=$(git merge-base @ @{u})

if [ $LOCAL = $REMOTE ]; then
    echo "Up-to-date"
elif [ $LOCAL = $BASE ]; then
  if [ $UPDATE_ON_START = "TRUE" ]; then
    echo "Need to pull"
    git pull origin master && composer update && php artisan migrate
  fi
fi

fi

/usr/bin/supervisord