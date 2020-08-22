#!/bin/bash
set -e

if ! [ -e config.json ]; then

    if [ -n "$DATABASE" ]; then

        if [ "$DATABASE" == "redis" ]; then
            url=$URL database=$DATABASE redis__database=$DB_NAME redis__password=$DB_PASSWORD redis__host=$DB_HOST redis__port=$DB_PORT node app --setup
        elif [ "$DATABASE" == "mongo" ]; then
            url=$URL database=$DATABASE mongo__username=$DB_USER mongo__password=$DB_PASSWORD mongo__host=$DB_HOST mongo__port=$DB_PORT node app --setup
        fi

    else
        echo "Database setting is invalid"
    fi

    mv config.json /data/config.json
    ln -s /data/config.json /usr/src/app/config.json
    mv /usr/src/app/public/uploads /data/uploads \
    && ln -s /data/uploads /usr/src/app/public/uploads \
    && mv /usr/src/app/package.json /data/package.json \
    && ln -s /data/package.json /usr/src/app/package.json
fi

if [ -f config.json ]; then
    /usr/src/app/nodebb upgrade -sb
fi

exec "$@"