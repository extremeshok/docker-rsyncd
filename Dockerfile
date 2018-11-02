FROM alpine:latest

LABEL maintainer "Adrian Kriel <admin@extremeshok.com>"

RUN apk add --update --no-cache \
	rsync \
	bash

# Remove the default config
RUN rm -f /etc/rsyncd.conf

EXPOSE 873/tcp

COPY ./rootfs /

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
