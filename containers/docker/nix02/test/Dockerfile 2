FROM ubuntu:24.04

RUN apt-get update
RUN apt-get install -y curl wget locales
ENV LANG en_US.utf8
COPY ./entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint
ENTRYPOINT [ "/bin/entrypoint" ]