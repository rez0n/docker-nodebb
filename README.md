# NodeBB in the Docker
[NodeBB](https://github.com/NodeBB/NodeBB) forum software Docker container.
## Available tags
`latest` - used for latest *stable* releases

`beta` - *beta* releases builds

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
    -e URL="http://mynodebb.com" \
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
    -e URL="http://mynodebb.com" \
    -e DATABASE="redis" \
    -e DB_NAME="0" \
    -e DB_HOST="host.docker.internal" \
    -e DB_PASSWORD="pass" \
    -e DB_PORT="6379" \
    nibrev/nodebb:stable
```
---

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
