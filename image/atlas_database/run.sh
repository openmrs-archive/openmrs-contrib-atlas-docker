#!/bin/bash

if [ ! -f /var/lib/mysql/ibdata1 ]; then

    mysql_install_db

    /usr/bin/mysqld_safe &
    sleep 10s

    echo "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;" | mysql
    echo "CREATE USER 'atlas'@'%' IDENTIFIED BY 'atlas';" | mysql
    echo "CREATE DATABASE atlas; GRANT ALL PRIVILEGES ON atlas.* TO 'atlas'@'%' IDENTIFIED BY 'atlas'; FLUSH PRIVILEGES;" | mysql

    killall mysqld
    sleep 10s
fi

/usr/bin/mysqld_safe
