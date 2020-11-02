FROM node:12

LABEL org.opencontainers.image.source https://github.com/rez0n/docker-nodebb

ENV NODE_ENV=production \
    daemon=false \
    silent=false
ARG RELEASE

RUN mkdir -p /usr/src/app
RUN mkdir -p /data
WORKDIR /usr/src/app


RUN wget https://github.com/NodeBB/NodeBB/archive/${RELEASE}.tar.gz -O nodebb.tar.gz \
    && tar xzf nodebb.tar.gz --strip-components 1 \
    && rm nodebb.tar.gz \
    && cp install/package.json package.json \
    && npm install --only=prod \
    && npm cache clean --force

VOLUME /data
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "node", "loader.js" ]

EXPOSE 4567