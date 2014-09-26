FROM openmrs/atlas:base_web
MAINTAINER Alexis DUQUE "alexis.duque@openmrs.org"

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

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD laravel-setup.sh /tmp/laravel-setup.sh
ADD auth-setup.sh /tmp/auth-setup.sh
ADD atlas.cfg /tmp/atlas.cfg
ADD 000-default.conf /tmp/000-default.conf
ADD auth_key.pub /root/.ssh/authorized_keys
RUN chmod 640 /root/.ssh/authorized_keys
RUN chmod a+x /tmp/*.sh

ADD crontab /etc/crontab
RUN crontab /etc/crontab

EXPOSE 22 80 8888

CMD ["/tmp/laravel-setup.sh"]