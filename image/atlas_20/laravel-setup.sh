#!/bin/bash

. /tmp/atlas.cfg

cd /opt/atlas

cp env.local.php .env.prod.php

sed -i 's/\/var\/www/\/opt\/atlas\/public/g' /etc/apache2/apache2.conf

sed -i 's/user/atlas/g' .env.prod.php
sed -i 's/password/atlas/g' .env.prod.php
sed -i "s/secret'/secret',/g" .env.prod.php
sed -i 's#http://localhost:3000#https://id-stg.openmrs.org#g' .env.prod.php
sed -i 's#http://localhost/openmrs-contrib-atlas/public/data.php?callback=loadSites#'$SERVER_DATA'#g' .env.prod.php
sed -i 's#http://localhost/openmrs-contrib-atlas/public/#'$SERVER_URL'#g' .env.prod.php
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
#service apache2 start
#php artisan screen-capture --force
sed -i 's/'$TMP_HOST'/'$HOST'/' bootstrap/start.php

service mysql stop
#service apache2 stop