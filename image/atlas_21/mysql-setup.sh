
#!/bin/bash
chown mysql:mysql /var/run/mysqld/
mysql_install_db
service mysql start
sleep 10s
mysqladmin -h 127.0.0.1 -u root password $MYSQL_PASSWORD || { echo 'Command failed' ; exit 1; }
mysql -uroot -p$MYSQL_PASSWORD -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" || { echo 'Command failed' ; exit 1; }
mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE $MYSQL_USER; GRANT ALL PRIVILEGES ON atlas.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; FLUSH PRIVILEGES;" || { echo 'Command failed' ; exit 1; }
service mysql start
sleep 5
mysql -uatlas -p$MYSQL_PASSWORD --database atlas < /tmp/atlas.sql