# ![NodeBB](https://github.com/NodeBB/NodeBB/raw/master/public/images/logo.svg) in the Docker

[**NodeBB Forum Software**](https://nodebb.org) is powered by Node.js and supports either Redis, MongoDB, or a PostgreSQL database. It utilizes web sockets for instant interactions and real-time notifications. NodeBB has many modern features out of the box such as social network integration and streaming discussions, while still making sure to be compatible with older browsers.

## Available tags
##### Stable releases
`latest`, `v1.15.1`, `v1.15.0`, `v1.14.3`, `v1.14.2` ...
##### Beta releases
`beta`, `v1.15.1-beta.0`, `v1.15.0-rc.4`, `v1.15.0-rc.3`, `v1.15.0-beta.30` ...

*Images delivers through two registries, [DockerHub](https://hub.docker.com/r/nibrev/nodebb) and [GitHub Container Registry](https://github.com/users/rez0n/packages/container/package/nodebb).*

## Features
* Auto installation
* Auto upgrade when you update image
* Persistant storage support (official NodeBB image haven't that)


## Quick start 

### Run using Mongo database

```docker
docker run --name nodebb -d -p 4567:4567 \
    -v ./data:/data \
    -e URL="http://mynodebb.com" \
    -e DATABASE="mongo" \
    -e DB_HOST="host.docker.internal" \
    -e DB_USER="mongo_user" \
    -e DB_PASSWORD="mongo_pass" \
    -e DB_PORT="27017" \
    nibrev/nodebb:latest
```

### Run using Redis

```docker
docker run --name nodebb -d -p 4567:4567 \
    -v ./data:/data \
    -e URL="http://localhost" \
    -e DATABASE="redis" \
    -e DB_NAME="0" \
    -e DB_HOST="host.docker.internal" \
    -e DB_PASSWORD="redis_pass" \
    -e DB_PORT="6379" \
    nibrev/nodebb:latest
```


### Run using docker-compose
There is basic docker-compose example to run NodeBB using Redis database.

```yaml

version: '3.1'
services:
  nodebb:
    image: ghcr.io/rez0n/nodebb:latest
    restart: unless-stopped
    environment:
      URL: "http://localhost"
      DATABASE: "redis"
      DB_NAME: "0"
      DB_HOST: "redis"
      DB_PORT: "6379"
    volumes:
      - ./data/nodebb:/data
    networks:
      - nodebb
    ports:
      - "4567:4567"

  redis:
    image: redis
    restart: unless-stopped
    volumes:
      - ./data/redis:/data
    networks:
      - nodebb

networks:
  nodebb:
    driver: bridge
```


### Run in k8s
This image was adjusted to run in k8s clusters. Example manifest below, you can find full manifests in the k8s-manifests directory.
```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: beta-nodebb-pv-claim
  namespace: nodebb
  labels:
    app: nodebb
spec:
  storageClassName: local-path
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodebb
  namespace: nodebb
  labels:
    app: nodebb
spec:
  selector:
    matchLabels:
      app: nodebb
      tier: frontend
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: nodebb
        tier: frontend
    spec:
      containers:
        - image: nibrev/nodebb:beta
          imagePullPolicy: Always
          name: nodebb
          env:
            - name: DATABASE
              value: "redis"
            - name: DB_NAME
              value: "1"
            - name: DB_HOST
              value: redis
            - name: DB_PORT
              value: "6379"
            - name: URL
              value: "http://node.157.230.78.171.nip.io"
          ports:
            - containerPort: 4567
              name: nodebb
          volumeMounts:
            - name: beta-nodebb-pv
              mountPath: /data
      volumes:
        - name: beta-nodebb-pv
          persistentVolumeClaim:
            claimName: beta-nodebb-pv-claim

---
apiVersion: v1
kind: Service
metadata:
  name: nodebb
  namespace: nodebb
  labels:
    app: nodebb
spec:
  selector:
    app: nodebb
    tier: frontend
  ports:
    - port: 80
      targetPort: 4567

---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: nodebb
  namespace: nodebb
spec:
  rules:
    - host: node.157.230.78.171.nip.io
      http:
        paths:
          - path: /
            backend:
              serviceName: nodebb
              servicePort: 80
```
