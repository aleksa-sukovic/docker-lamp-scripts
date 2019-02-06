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

# Reading domain
while [ "$1" != "" ]
do
    case $1 in
        -d|--domain)
        shift
        DOMAIN=$1
        ;;
        -wd|--working-dir)
        shift
        WORKING_DIR=$1
        ;;
    esac
    shift
done
if [ -z $DOMAIN ] || [ -z $WORKING_DIR ]; then
    printf "$red" "Please provide domain and working directory as arguments"
    exit 1
fi

# Checking if certificate exists
cd $WORKING_DIR
if [ -f /etc/ssl/certs/$DOMAIN.crt ] && [ -f /etc/ssl/certs/$DOMAIN.key ]; then
    printf "Certificate and domain exists, skipping creation...\n"
    exit 1
else
   if [ ! -d ./temp ]; then
        mkdir "./temp"
    fi

    SERVER_CONFIG="[req]
    default_bits = 2048
    prompt = no
    default_md = sha256
    distinguished_name = dn

    [dn]
    C=ME
    L=Podgorica
    O=gka1ek
    emailAddress=sukovic.aleksa@gmail.com
    CN = $DOMAIN"
    echo "$SERVER_CONFIG" > "temp/server_config.cnf"

    EXT_CONFIG="authorityKeyIdentifier=keyid,issuer
    basicConstraints=CA:FALSE
    keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
    subjectAltName = @alt_names

    [alt_names]
    DNS.1 = $DOMAIN"
    echo "$EXT_CONFIG" > "temp/ext_config.ext"

    # Generating CA key and certificate
    openssl genrsa -out temp/temp_key.key 2048
    openssl req -x509 -new -nodes -key temp/temp_key.key -sha256 -days 3650 -out temp/temp_pem.pem -config ./temp/server_config.cnf

    # Genrating certificate signing request and signing certificate with our own CA
    openssl req -new -sha256 -nodes -out ./temp/$DOMAIN.csr -newkey rsa:2048 -keyout $DOMAIN.key -config ./temp/server_config.cnf
    openssl x509 -req -in ./temp/$DOMAIN.csr -CA temp/temp_pem.pem -CAkey temp/temp_key.key -CAcreateserial -out $DOMAIN.crt -days 3650 -sha256 -extfile ./temp/ext_config.ext

    rm -rf ./temp
    printf "Successfully generated certificate for $DOMAIN\n"
fi

cp $DOMAIN.crt /etc/ssl/certs/$DOMAIN.crt
mv $DOMAIN.key /etc/ssl/certs/$DOMAIN.key

exit 0
