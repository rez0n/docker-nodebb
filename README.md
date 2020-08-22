# NodeBB in the Docker
[NodeBB](https://github.com/NodeBB/NodeBB) forum software Docker container.
## Available tags
`latest` - used for latest *beta* releases (autobuilds)

`stable` - *stable* releases builds (currntly manual maintained)

---

## Features
* Auto installation
* Auto upgrade when you update image
* Persistant storage support (official NodeBB image haven't that)

---

## How to run

### Run using Mongo database

```
docker run --name nodebb -d -p 4567:4567 \
    -v /path/to/data:/data \
    -e DATABASE="mongo" \
    -e DB_HOST="host.docker.internal" \
    -e DB_USER="user" \
    -e DB_PASSWORD="pass" \
    -e DB_PORT="27017" \
    nibrev/nodebb:stable
```

### Run using Redis

```
docker run --name nodebb -d -p 4567:4567 \
    -v /path/to/data:/data \
    -e DATABASE="redis" \
    -e DB_NAME="0" \
    -e DB_HOST="host.docker.internal" \
    -e DB_PASSWORD="pass" \
    -e DB_PORT="6379" \
    nibrev/nodebb:stable
```
---
## Known issues
* Nodebb update script get crash in the Docker in case if host have less than 4GB RAM.s