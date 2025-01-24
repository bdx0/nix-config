FROM golang:alpine AS rclone_builder

WORKDIR /go/src/github.com/rclone/rclone

# RUN go get -v github.com/rclone/rclone/...
RUN apk add --no-cache make bash gawk git g++ fuse
RUN git clone https://github.com/rclone/rclone /go/src/github.com/rclone/rclone
RUN \
    CGO_ENABLED=0 \
    make
RUN ./rclone version

FROM golang:alpine AS weed_builder

RUN apk add git g++ fuse
RUN mkdir -p /go/src/github.com/seaweedfs/
RUN git clone https://github.com/seaweedfs/seaweedfs /go/src/github.com/seaweedfs/seaweedfs
ARG BRANCH=${BRANCH:-master}
ARG TAGS="elastic gocdk sqlite tikv ydb rclone "
RUN cd /go/src/github.com/seaweedfs/seaweedfs && git checkout $BRANCH
RUN cd /go/src/github.com/seaweedfs/seaweedfs/weed \
    && export LDFLAGS="-X github.com/seaweedfs/seaweedfs/weed/util.COMMIT=$(git rev-parse --short HEAD)" \
    && CGO_ENABLED=0 go install -tags "$TAGS" -ldflags "-extldflags -static ${LDFLAGS}"

FROM alpine AS bdfs

### Rclone
RUN apk --no-cache add ca-certificates fuse3 tzdata && \
    echo "user_allow_other" >> /etc/fuse.conf

COPY --from=rclone_builder /go/src/github.com/rclone/rclone/rclone /usr/local/bin/

RUN addgroup -g 1009 rclone && adduser -u 1009 -Ds /bin/sh -G rclone rclone
COPY ./rclone.conf /config/rclone/rclone.conf

# ENTRYPOINT [ "rclone" ]

WORKDIR /data
ENV XDG_CONFIG_HOME=/config
### SeaweedFS
COPY --from=weed_builder /go/bin/weed /usr/bin/
RUN mkdir -p /etc/seaweedfs
COPY --from=weed_builder /go/src/github.com/seaweedfs/seaweedfs/docker/filer.toml /etc/seaweedfs/filer.toml
COPY --from=weed_builder /go/src/github.com/seaweedfs/seaweedfs/docker/entrypoint.sh /entrypoint.sh
COPY master.toml /etc/seaweedfs/master.toml
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

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# FROM busybox AS samba