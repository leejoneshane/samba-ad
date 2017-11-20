#!/bin/sh
set -e

# Configure the AD DC
if [ ! -f /samba/etc/smb.conf ]; then
    mkdir -p /samba/etc /samba/lib /samba/log
    echo "${SAMBA_DOMAIN} - Begin Domain ${SAMBA_DC_ACT}..."
    samba-tool domain ${SAMBA_DC_ACT} \
        --use-rfc2307 \
        --domain="${SAMBA_DOMAIN}" \
        --adminpass="${SAMBA_ADMIN_PASSWORD}" \
        --server-role="${SAMBA_ROLE}" \
        --realm="${SAMBA_DNS_REALM}" \
        --dns-backend="SAMBA_INTERNAL"
    echo "${SAMBA_DOMAIN} - Domain ${SAMBA_DC_ACT} Successfully."
    
    echo "dns forwarder = ${SAMBA_DNS_FORWARDER}" >> /samba/etc/smb.conf
    echo "unix password sync = no" >> /samba/etc/smb.conf
fi

if [ "$1" = 'samba' ]; then
    exec /usr/sbin/samba -i
fi

# Assume that user wants to run their own process,
# for example a `bash` shell to explore this image
exec "$@"
