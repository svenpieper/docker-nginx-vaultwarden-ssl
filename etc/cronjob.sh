#!/bin/bash

DIR="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

# cleanup exited docker containers
EXITED_CONTAINERS=$(/usr/bin/docker ps -a | grep Exited | awk '{ print $1 }')
if [ -z "$EXITED_CONTAINERS" ]
then
        echo "No exited containers to clean"
else
        /usr/bin/docker rm $EXITED_CONTAINERS
fi
 
# renew certbot certificate
/usr/local/bin/docker-compose -f $DIR/../docker-compose.yml run --rm certbot
/usr/local/bin/docker-compose -f $DIR/../docker-compose.yml exec nginx nginx -s reload