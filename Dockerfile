FROM alpine:edge
LABEL maintainer="jorin.laatsch@gmail.com"

RUN echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk add hping3@testing arp-scan@testing mosquitto-clients

ENTRYPOINT ["/presence/presence_run.sh"]
