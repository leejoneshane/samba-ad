FROM alpine

ENV SAMBA_DC_ACT join
ENV SAMBA_DNS_REALM tld.your.domain
ENV SAMBA_DOMAIN tld
ENV SAMBA_HOST hostname
ENV SAMBA_ADMIN_PASSWORD secret.password
ENV SAMBA_DNS_FORWARDER 8.8.8.8
ADD samba.init /etc/init.d/samba
ADD configure.sh /configure.sh
ADD ntpd.conf /etc/ntpd.conf
ADD resolv.conf /etc/resolv.conf

RUN apk update \
    && apk add --no-cache bash acl samba-dc krb5 openntpd supervisor \
    && chmod +x /configure.sh \
    && rm -rf /etc/samba /var/log/samba /var/lib/samba \
    && mkdir -p /samba/etc /samba/log /samba/lib \
    && ln -s /samba/etc /etc/samba \
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
ENTRYPOINT ["/configure.sh"]
CMD ["bash"]
