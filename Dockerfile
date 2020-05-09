FROM extremeshok/baseimage-ubuntu:latest

LABEL maintainer "Adrian Kriel <admin@extremeshok.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    rsync \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup rsync
EXPOSE 873/tcp

COPY ./rootfs /

RUN chmod 744 /xshok-init.sh

ENTRYPOINT ["/init"]
