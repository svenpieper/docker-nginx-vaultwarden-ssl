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

# Asking if vaultwarden will run on a Arm machine.
while true; do
    read -p "Is vaultwarden started on an Arm CPU? (yes/no) " answer
    case $answer in
        [Nn] | [Nn][Oo] )
            echo "Setting certbot version to non Arm version."
            # Changing certbot version within docker-compose files
            sed -i 's/certbot\/certbot:arm32v6-latest/certbot\/certbot:latest/g' docker-compose.yml
            sed -i 's/certbot\/certbot:arm32v6-latest/certbot\/certbot:latest/g' docker-compose.init.yml
            break;;
        [Yy] | [Yy][Ee][Ss] )
            # Using setup as is
            echo "Using certbot for Arm CPU."
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

# Generating crontab file
ETC_PATH=$(pwd)/etc
echo "30 3 * * * sh $ETC_PATH/cronjob.sh" > $ETC_PATH/crontab

# Creating new custom nginx.domain.conf for production server
nginx_config=$ETC_PATH/nginx/templates/nginx.template.conf
new_config=nginx.domain.conf
sed "s/\$domain/$DOMAIN/g" $nginx_config > $ETC_PATH/nginx/$new_config

# Phase 1 - Only for generating certs
/usr/local/bin/docker-compose -f ./docker-compose.init.yml up -d nginx
/usr/local/bin/docker-compose -f ./docker-compose.init.yml up certbot
/usr/local/bin/docker-compose -f ./docker-compose.init.yml down

# Some configurations for let's encrypt
/usr/bin/curl -L --create-dirs -o etc/letsencrypt/options-ssl-nginx.conf https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf
/usr/bin/openssl dhparam -out etc/letsencrypt/ssl-dhparams.pem 2048

# Phase 2 - Setting cronjob for auto renew and starting final vaultwarden and nginx instance
/usr/bin/crontab ./etc/crontab
/usr/bin/docker network create -d bridge vault_nginx
/usr/local/bin/docker-compose -f ./docker-compose.yml up -d

# Printing crontab reminder
echo "Finished."
echo "Please run >crontab ./etc/crontab< to start cronjob for auto renew certs."