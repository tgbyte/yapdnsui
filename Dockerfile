FROM node:0.12-slim

ENV DUMBINIT_VERSION 1.0.1
ENV GOSU_VERSION 1.7

ENV DEBIAN_FRONTEND noninteractive
#ENV NODE_ENV production
ENV DEBUG yapdnsui
ENV PORT 8080
EXPOSE $PORT

RUN apt-get update && apt-get -y upgrade && \
    npm install -g bower grunt-cli npm-check-updates express express-generator jade request sqlite3 && \
    apt-get -y install libsqlite3-0 git wget ca-certificates && \
    wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DUMBINIT_VERSION}/dumb-init_${DUMBINIT_VERSION}_amd64 && \
    chmod +x /usr/local/bin/dumb-init && \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" && \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true && \
    apt-get purge -y --auto-remove ca-certificates wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    adduser --uid 500 --disabled-login --gecos "yapdnsui" --no-create-home --home /app/yapdnsui yapdnsui

VOLUME ["/data"]
ADD . /app/yapdnsui

RUN \
  cd /app/yapdnsui && \
  npm prune --production && \
  npm install --production --unsafe-perm && \
  npm rebuild && \
  bower --allow-root install

WORKDIR /app/yapdnsui

ENTRYPOINT ["/usr/local/bin/dumb-init"]
CMD ["/app/yapdnsui/docker-entrypoint.sh"]
