#!/bin/bash

. /tmp/atlas.cfg

chown mysql:mysql /var/run/mysqld/
mysql_install_db
service mysql start
sleep 10s

echo mysql root password: $MYSQL_PASSWORD

mysqladmin -h 127.0.0.1 -u root password $MYSQL_PASSWORD || { echo 'Command failed' ; exit 1; }
mysql -uroot -p$MYSQL_PASSWORD -e "CREATE USER 'atlas'@'%' IDENTIFIED BY 'atlas';" || { echo 'Command failed' ; exit 1; }
mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE atlas; GRANT ALL PRIVILEGES ON atlas.* TO 'atlas'@'%' IDENTIFIED BY 'atlas'; FLUSH PRIVILEGES;" || { echo 'Command failed' ; exit 1; }

service mysql stop