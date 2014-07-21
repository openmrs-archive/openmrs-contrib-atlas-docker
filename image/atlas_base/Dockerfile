FROM ubuntu:14.04
MAINTAINER Alexis DUQUE "alexis.duque@openmrs.org"

#Add universe repository and update
RUN echo "debconf debconf/frontend select Teletype" | debconf-set-selections &&apt-get -y update &&\
	apt-get -y install software-properties-common &&\
    add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe" &&\
    add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc)-updates main universe" 

RUN apt-get -y update &&\
    apt-mark hold initscripts &&\
    apt-get -y upgrade

RUN mkdir -p /var/run/sshd &&\
	echo 'root:test' |chpasswd &&\
	mkdir -p /var/log/supervisor &&\
	mkdir -p /var/lib/dock &&\
	mkdir -p /var/lib/mysql

#Install OpenSSH and Supervisor
RUN apt-get install -y openssh-server supervisor
RUN mkdir -p /root/.ssh
ADD auth_key.pub /root/.ssh/authorized_keys
RUN chmod 640 /root/.ssh/authorized_keys

#Install Lamp server
RUN apt-get update && install -y wget nano apache2 mysql-client mysql-server libapache2-mod-php5 php5-mysql php5-mcrypt &&\
	apt-get install -y php5-json  php5-cli git openssl ssl-cert sharutils libaio1 libaio-dev

#Configure Apache
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

RUN echo "extension=mcrypt.so" >> /etc/php5/cli/php.ini
RUN echo "extension=mcrypt.so" >> /etc/php5/apache2/php.ini

RUN a2enmod rewrite

#Install composer
RUN apt-get install -y curl
RUN curl -sS http://getcomposer.org/installer|php
RUN mv composer.phar /usr/local/bin/composer

#Install phantomJS and font requirement
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.7-linux-x86_64.tar.bz2 &&\
	tar -xjf phantomjs-1.9.7-linux-x86_64.tar.bz2 &&\
	    rm phantomjs-1.9.7-linux-x86_64.tar.bz2 &&\
	    cp phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/local/bin &&\
	    rm -fr phantomjs-1.9.7-linux-x86_64 &&\
		chmod a+x /usr/local/bin/phantomjs

RUN apt-get install -y fontconfig xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic