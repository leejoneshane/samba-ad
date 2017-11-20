#!/bin/sh
set -e

COMMAND=bash

# Add $COMMAND if needed
if [ "${1:0:1}" = '-' ]; then
	set -- $COMMAND "$@"
fi

# Configure the AD DC
if [[ "${SAMBA_DOMAIN}" != "tld" && "${SAMBA_DNS_REALM}" != "tld.your.domain" ]]; then
  if[ -f /etc/samba/smb.conf && ]; then
    sed -ri \
        -e "s/SAMBA_DOMAIN/${SAMBA_DOMAIN}/" \
        -e "s/SAMBA_DNS_REALM/${SAMBA_DNS_REALM}/" \
        -e "s/SAMBA_HOST/${SAMBA_HOST}/" \
        -e "s/SAMBA_DNS_FORWARD/${SAMBA_DNS_FORWARD}/" \
        /etc/samba/smb.conf  
  else
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
  fi
  sed -ri \
      -e "s/(search) .*/\1 ${SAMBA_DNS_REALM}/" \
      -e "s/(nameserver) .*/\1 127.0.0.1/" \
      /etc/resolv.conf
fi

if [ "$1" = 'samba' ]; then
    exec /usr/sbin/samba -i
fi

exec "$@"
