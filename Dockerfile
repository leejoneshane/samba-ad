FROM alpine:latest

ENV SAMBA_DC_ACT join
ENV SAMBA_DNS_REALM tld.your.domain
ENV SAMBA_DOMAIN tld
ENV SAMBA_ROLE dc
ENV SAMBA_ADMIN_PASSWORD secret.password
ENV SAMBA_DNS_FORWARDER 8.8.8.8
ADD docker-entrypoint.sh /

RUN apk update \
    && apk add --no-cache samba-dc supervisor \
    && rm -rf /etc/samba/smb.conf \
    && rm -rf /var/lib/samba \
    && rm -rf /var/log/samba \
    && ln -s /samba/etc /etc/samba \
    && ln -s /samba/lib /var/lib/samba \
    && ln -s /samba/log /var/log/samba

EXPOSE 37/udp \
       53 \
       88 \
       135/tcp \
       137/udp \
       138/udp \
       139 \
       389 \
       445 \
       464 \
       636/tcp \
       1024-5000/tcp \
       3268/tcp \
       3269/tcp

VOLUME ["/samba"]

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["samba"]
