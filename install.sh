#!/bin/bash

# takes two paramters, the domain name and the email to be associated with the certificate
DOMAIN=$1
EMAIL=$2

# Check for numbers of arguments
if [ $# -ne 2 ]
then
    echo "Error: Incorrect number of arguments. Expected $EXPECTED_ARGS, but got $#."
    echo "Please pass your domain and email as arguments."
    echo "Usage: ./install.sh <DOMAIN> <EMAIL>"
    exit 1
fi

# Check for first parameter. Must be a valid domain name.
if ! [[ $1 =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z.]*[a-zA-Z]$ ]];
then
    echo "The first parameter is not a valid domain"
    exit 1
fi

# Check for second parameter. Must be a valid email address.
if ! [[ $2 =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]];
then
    echo "The second parameter is not a valid email address"
    exit 1
fi

# Asking if vaultwarden will run on a ARM machine.
while true; do
    read -p "Is vaultwarden started on an Arm CPU? (yes/no) " answer
    case $answer in
        [Nn] | [Nn][Oo] )
            echo "Setting nginx version to non Arm version."
            # Changing nginx version within docker-compose files
            sed -i 's/arm64v8\/nginx:latest/nginx:latest/g' docker-compose.yml
            sed -i 's/arm64v8\/nginx:latest/nginx:latest/g' docker-compose.init.yml
            break;;
        [Yy] | [Yy][Ee][Ss] )
            # Using setup as is
            echo "Using nginx for Arm CPU."
            break;;
        * )
            echo "Invalid input. Please enter 'yes', 'y', 'no', or 'n'."
    esac
done

# Writing environment file, later on used by docker.
if [ -e ".env" ]; then
    rm -f ".env"
fi
echo DOMAIN=${DOMAIN} >> .env
echo EMAIL=${EMAIL} >> .env

exit 0

# Phase 1 - Only for generating certs
docker-compose -f ./docker-compose.init.yml up -d nginx
docker-compose -f ./docker-compose.init.yml up certbot
docker-compose -f ./docker-compose.init.yml down

# Some configurations for let's encrypt
curl -L --create-dirs -o etc/letsencrypt/options-ssl-nginx.conf https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf
openssl dhparam -out etc/letsencrypt/ssl-dhparams.pem 2048
 
# Phase 2 - Setting cronjob for auto renew and starting final vaultwarden and nginx instance
crontab ./etc/crontab
docker-compose -f ./docker-compose.yml -d up