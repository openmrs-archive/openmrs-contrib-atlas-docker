#!/bin/bash
. /tmp/atlas.cfg

if [ ! -f /etc/apache2/ssl/server.key ]; then
        mkdir -p /etc/apache2/ssl
        KEY=/etc/apache2/ssl/server.key
        export PASSPHRASE=$(head -c 128 /dev/urandom  | uuencode - | grep -v "^end" | tr "\n" "d")
        SUBJ="
C=US
ST=United States
O=Dischord
localityName=Indianapolis
commonName=$HOST
organizationalUnitName=openmrs
emailAddress=helpdesk@openmrs.org
"
        openssl genrsa -des3 -out /etc/apache2/ssl/server.key -passout env:PASSPHRASE 2048
        openssl req -new -batch -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key $KEY -out /tmp/$HOST.csr -passin env:PASSPHRASE
        cp $KEY $KEY.orig
        openssl rsa -in $KEY.orig -out $KEY -passin env:PASSPHRASE
        openssl x509 -req -days 365 -in /tmp/$HOST.csr -signkey $KEY -out /etc/apache2/ssl/server.crt
fi

HOSTLINE=$(echo $(ip -f inet addr show eth0 | grep 'inet' | awk '{ print $2 }' | cut -d/ -f1) $(hostname) $(hostname -s))
#sudo echo $HOSTLINE >> /etc/hosts

echo "SSL deployed"