#!/bin/bash

# Output colors
red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
blue='\e[1;34m%s\e[0m\n'

# Make sure we run under sudo
if [ $(id -u) != 0 ]; then
   printf "$red" "Please run as root!"
   exit 1
fi

# Reading arguments
SSL="Yes"
while [ "$1" != "" ]
do
    case $1 in
        -n|--no-ssl)
        SSL="No"
        shift
        ;;
        -d|--domain)
        shift
        DOMAIN=$1
        shift
        ;;
        -dr|--document-root)
        shift
        DOCUMENT_ROOT=$1
        shift
        ;;
        -e|--entrypoint)
        shift
        ENTRYPOINT=$1
        shift
        ;;
    esac
done

# Checking if all necessary arguments were passed
if [[ -z $DOMAIN ]] || [[ -z $DOCUMENT_ROOT ]]; then
    printf "$red" "Please provide domain, document root and project name!"
    exit 1
fi

if [[ -z $ENTRYPOINT ]]; then
    $ENTRYPOINT="index.html"
fi

# Virtual Host informations
printf "Creating virtual host...\n"
printf "Document root: $DOCUMENT_ROOT\n"
printf "Domain: $DOMAIN\n"
printf "Entrypoint: $ENTRYPOINT\n"
printf "SSL: $SSL\n"

no_ssl_template="<VirtualHost *:80>
    ServerAdmin sukovic.aleksa@gmail.com
    DocumentRoot $DOCUMENT_ROOT
    ServerName $DOMAIN
    DirectoryIndex $ENTRYPOINT

    <Directory $DOCUMENT_ROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Order allow,deny
        Allow from all
    </Directory>
</VirtualHost>"

ssl_template="<VirtualHost *:443>
    ServerAdmin sukovic.aleksa@gmail.com
    DocumentRoot $DOCUMENT_ROOT
    ServerName $DOMAIN
    DirectoryIndex $ENTRYPOINT

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/$DOMAIN.crt
    SSLCertificateKeyFile /etc/ssl/certs/$DOMAIN.key

    <Directory $DOCUMENT_ROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Order allow,deny
        Allow from all
    </Directory>
</VirtualHost>
<VirtualHost *:80>
    ServerName $DOMAIN
    DocumentRoot $DOCUMENT_ROOT
    Redirect permanent / https://$DOMAIN/
</VirtualHost>"

vhost_path="/etc/apache2/sites-available/$DOMAIN.conf"

if [ $SSL = "Yes" ]; then
    echo "$ssl_template" > "$vhost_path"
else
    echo "$no_ssl_template" > "$vhost_path"
fi

a2ensite $DOMAIN
