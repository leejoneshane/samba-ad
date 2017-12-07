FROM alpine

ADD docker-entrypoint.sh /usr/sbin/docker-entrypoint.sh

RUN apk update \
    && apk add --no-cache bash attr acl samba-dc krb5 openntpd \
    && chmod +x /usr/sbin/docker-entrypoint.sh \
    && rm -rf /etc/samba /var/log/samba /var/lib/samba \
    && mkdir -p /samba/etc /samba/log /samba/lib \
    && ln -s /samba/etc /etc/samba \
    && ln -s /samba/log /var/log/samba \
    && ln -s /samba/lib /var/lib/samba \
    && echo "servers pool.ntp.org" > /etc/ntpd.conf \
    && cd /root \
    && wget https://www.isc.org/downloads/file/bind-9-11-2/ \
    && tar -xzf bind-9.11.2.tar.gz \
    && cd bind* \
    && ./configure --with-gssapi=/usr/include/gssapi --with-dlopen=yes \
    && make \
    && make install \
    && wget -q -O /var/named/named.root http://www.internic.net/zones/named.root

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
