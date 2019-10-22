FROM alpine:edge
LABEL maintainer="jorin.laatsch@gmail.com"

RUN echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk add grep hping3@testing bash nmap mosquitto-clients

ENTRYPOINT ["/presence/presence_main.sh"]
