FROM alpine

ENV SAMBA_DC_ACT join
ENV SAMBA_DNS_REALM tld.your.domain
ENV SAMBA_DOMAIN tld
ENV SAMBA_HOST hostname
ENV SAMBA_ADMIN_PASSWORD secret.password
ENV SAMBA_DNS_FORWARDER 8.8.8.8
ADD docker-entrypoint.sh /usr/sbin/docker-entrypoint.sh

RUN apk update \
    && apk add --no-cache bash acl samba-dc krb5 openntpd supervisor \
    && chmod +x /usr/sbin/docker-entrypoint.sh \
    && rm -rf /etc/samba /var/log/samba /var/lib/samba \
    && mkdir -p /samba/etc /samba/log /samba/lib \
    && ln -s /samba/etc /etc/samba \
    && ln -s /samba/log /var/log/samba \
    && ln -s /samba/lib /var/lib/samba \
    && echo "servers pool.ntp.org" > /etc/ntpd.conf

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
       3268/tcp \
       3269/tcp

VOLUME ["/samba"]
ENTRYPOINT ["docker-entrypoint.sh"]
