FROM alexisduque/atlas_base
MAINTAINER Alexis DUQUE "alexis.duque@openmrs.org"

RUN useradd atlas -s /bin/bash -m -U &&\
    mkdir /opt/atlas && cd /opt &&\
     git clone https://github.com/openmrs/openmrs-contrib-atlas.git atlas &&\
     cd atlas &&\
     chown -R atlas:atlas /opt/atlas &&\
     chown -R www-data:www-data /opt/atlas/app/storage &&\
     chmod -R ug+rwx /opt/atlas/app/storage &&\
     
     sudo -u atlas php composer install
