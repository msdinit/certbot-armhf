FROM alpine:3

RUN apk add --no-cache python3

RUN apk add --no-cache --virtual .build-deps \
    gcc \
    linux-headers \
    openssl-dev \
    musl-dev \
    python3-dev \
    libffi-dev \
    && pip3 install --no-cache-dir certbot certbot-dns-cloudflare \
    && apk del .build-deps

COPY entrypoint.sh /entrypoint.sh
COPY run-certbot.sh /run-certbot.sh

VOLUME /etc/letsencrypt

ENTRYPOINT ["/entrypoint.sh"]

CMD [""]
