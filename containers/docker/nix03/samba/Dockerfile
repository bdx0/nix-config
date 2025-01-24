# https://github.com/b32147/docker-samba
# https://github.com/alubbock/samba-docker/blob/master/Dockerfile
# https://github.com/udkyo/smb/blob/master/samba.conf
# https://forums.docker.com/t/current-best-practice-for-exposing-a-smb-share-to-a-docker-container/75440
# https://fariszr.com/docker-smb-network-discovery/
# https://github.com/ahmetozer/docker-samba/blob/master/functions.sh
# https://github.com/crazy-max/docker-samba?tab=readme-ov-file
# https://github.com/bmustiata/samba-share
# https://github.com/babim/docker-samba
# https://github.com/dockur/samba/blob/master/samba.sh

FROM golang:alpine AS weed_builder

RUN apk add git g++ fuse
RUN mkdir -p /go/src/github.com/seaweedfs/
RUN git clone https://github.com/seaweedfs/seaweedfs /go/src/github.com/seaweedfs/seaweedfs
ARG BRANCH=${BRANCH:-master}
ARG TAGS="elastic gocdk rclone sqlite tikv ydb"
RUN cd /go/src/github.com/seaweedfs/seaweedfs && git checkout $BRANCH
RUN cd /go/src/github.com/seaweedfs/seaweedfs/weed \
    && export LDFLAGS="-X github.com/seaweedfs/seaweedfs/weed/util.COMMIT=$(git rev-parse --short HEAD)" \
    && CGO_ENABLED=0 go install -tags "$TAGS" -ldflags "-extldflags -static ${LDFLAGS}"

FROM alpine:latest as samba

RUN apk add --no-cache --update \
    runit \
    samba-common-tools \
    samba-client \
    samba-server \
    && rm -rf /var/cache/apk/*

COPY smb.conf /etc/samba/smb.conf

EXPOSE 139/tcp 445/tcp

ADD docker-entrypoint.sh /root/docker-entrypoint.sh
RUN chmod +x /root/docker-entrypoint.sh


ENTRYPOINT ["/root/docker-entrypoint.sh"]
CMD []

COPY --from=weed_builder /go/bin/weed /usr/bin/
RUN mkdir -p /etc/seaweedfs
COPY --from=weed_builder /go/src/github.com/seaweedfs/seaweedfs/docker/filer.toml /etc/seaweedfs/filer.toml
COPY --from=weed_builder /go/src/github.com/seaweedfs/seaweedfs/docker/entrypoint.sh /entrypoint.sh
RUN apk add fuse # for weed mount

# volume server gprc port
EXPOSE 18080
# volume server http port
EXPOSE 8080
# filer server gprc port
EXPOSE 18888
# filer server http port
EXPOSE 8888
# master server shared gprc port
EXPOSE 19333
# master server shared http port
EXPOSE 9333
# s3 server http port
EXPOSE 8333
# webdav server http port
EXPOSE 7333

EXPOSE 5572

RUN mkdir -p /data/filerldb2

VOLUME /data
WORKDIR /data