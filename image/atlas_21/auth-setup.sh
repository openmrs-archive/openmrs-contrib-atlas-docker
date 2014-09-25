#!/bin/bash

. /tmp/atlas.cfg

cd /opt/auth

echo "Listen 8888" >> /etc/apache2/apache2.conf

sed -i 's#https://atlas.local/#'$SERVER_URL#'g' config.php
sed -i 's#localhost#'$SITE_KEY#'g' config.php
sed -i 's#1234567890abcdef#'$API_KEY#'g' config.php
