#!/bin/sh
set -e

COMMAND=bash

# Add $COMMAND if needed
if [ "${1:0:1}" = '-' ]; then
	set -- $COMMAND "$@"
fi

# Configure the AD DC
if [[ "${SAMBA_DOMAIN}" != "tld" && "${SAMBA_DNS_REALM}" != "tld.your.domain" ]]; then
  if[ ! -f /etc/samba/smb.conf && ]; then
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
    
    sed -ri \
        -e "s/(search) .*/\1 ${SAMBA_DNS_REALM}/" \
        -e "s/(nameserver) .*/\1 127.0.0.1/" \
        /etc/resolv.conf
  fi
fi

if [ "$1" = 'samba' ]; then
    exec /usr/sbin/samba -i
fi

exec "$@"
