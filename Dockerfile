FROM alpine

ENV SAMBA_DC_ACT join
ENV SAMBA_DNS_REALM tld.your.domain
ENV SAMBA_DOMAIN tld
ENV SAMBA_HOST hostname
ENV SAMBA_ADMIN_PASSWORD secret.password
ENV SAMBA_DNS_FORWARDER 8.8.8.8
COPY samba.init /etc/init.d/samba
COPY smb.conf /smb.conf
COPY configure.sh /configure.sh

RUN apk update \
    && apk add --no-cache bash samba-dc krb5 supervisor \
    && chmod +x /configure.sh \
    && ln -sf /var/lib/samba/private/krb5.conf /etc/krb5.conf \
    && rm -rf /etc/samba /var/log/samba /var/lib/samba \
    && mkdir -p /samba/etc /samba/log /samba/lib \
    && ln -s /sambe/etc /etc/samba \
    && ln -s /samba/log /var/log/samba \
    && ln -s /samba/lib /var/lib/samba

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
ENTRYPOINT ["configure.sh"]
