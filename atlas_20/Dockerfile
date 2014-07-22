FROM openmrs/atlas:base
MAINTAINER Alexis DUQUE "alexis.duque@openmrs.org"

ENV HTTP_PORT 80
ENV HTTPS_PORT 443
ENV SSH_PORT 22
ENV SERVER_URL https://localhost/
ENV CAPTURE_URL https://atlas.openmrs.org
ENV SERVER_DATA https://localhost/data.php?callback=loadSites
ENV ID_HOST http://localhost:8888
ENV HOST atlas
ENV MYSQL_PASSWORD mysql
ENV SAMPLE_DATA 1

RUN useradd atlas -s /bin/bash -m -U &&\
    mkdir /opt/atlas && cd /opt &&\
    git clone https://github.com/openmrs/openmrs-contrib-atlas.git atlas &&\
    cd atlas &&\
    chown -R atlas:atlas /opt/atlas &&\
    chown -R www-data:www-data /opt/atlas/app/storage &&\
    chmod -R a+rwx /opt/atlas/app/storage
RUN cd /opt/atlas && sudo -u atlas composer install

RUN mkdir /opt/auth && cd /opt &&\
    git clone https://github.com/alexisduque/atlas-mock-id.git auth
ADD auth.conf /etc/apache2/sites-available/auth.conf
RUN a2ensite auth.conf

RUN mkdir /etc/apache2/ssl
RUN a2enmod rewrite ssl

ADD crontab /etc/crontab
ADD mysql-setup.sh /tmp/mysql-setup.sh
ADD laravel-setup.sh /tmp/laravel-setup.sh
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD atlas.sql /tmp/atlas.sql
ADD ssl.sh /tmp/ssl.sh
ADD 000-default.conf /tmp/000-default.conf
RUN chmod a+x /tmp/*.sh

EXPOSE 22 80 443 8888

CMD ["/tmp/laravel-setup.sh"]