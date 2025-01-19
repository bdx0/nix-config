FROM haproxy:3.1

COPY ./scripts /scripts
COPY ./haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
USER root
RUN  apt-get -y update && apt-get -y install postgresql-client-common postgresql-client
USER haproxy
# RUN chmod -R +x /scripts/*