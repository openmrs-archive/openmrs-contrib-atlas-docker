FROM ubuntu:14.04
MAINTAINER Alexis DUQUE "alexis.duque@openmrs.org"

VOLUME /var/lib/mysql

#Add universe repository and update
RUN echo "debconf debconf/frontend select Teletype" | debconf-set-selections &&apt-get -y update &&\
	apt-get -y install software-properties-common &&\
    add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe" &&\
    add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc)-updates main universe" 

RUN apt-get -y update &&\
    apt-mark hold initscripts &&\
    apt-get -y upgrade

RUN apt-get -y install mysql-client mysql-server

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/#bind-address = 0.0.0.0/" /etc/mysql/my.cnf

ADD ./run.sh /tmp/run.sh
RUN chmod a+rwx /tmp/run.sh

EXPOSE 3306

CMD ["/tmp/run.sh"]