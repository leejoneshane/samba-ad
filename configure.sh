#!/bin/sh
set -e

# Configure the AD DC
if [[ "$SAMBA_DOMAIN" != "tld" && "$SAMBA_DNS_REALM" != "tld.your.domain" ]]; then
  sed -ri \
      -e "s/(search) .*/\1 $SAMBA_DNS_REALM/" \
      -e "s/(nameserver) .*/\1 127.0.0.1/" \
      /etc/resolv.conf
  if [ ! -f /etc/samba/smb.conf ]; then
    echo "$SAMBA_DOMAIN - Begin Domain $SAMBA_DC_ACT..."
    samba-tool domain $SAMBA_DC_ACT \
        --use-rfc2307 \
        --domain="$SAMBA_DOMAIN" \
        --adminpass="$SAMBA_ADMIN_PASSWORD" \
        --server-role=dc \
        --realm="$SAMBA_DNS_REALM" \
        --dns-backend="SAMBA_INTERNAL"
    echo "$SAMBA_DOMAIN - Domain $SAMBA_DC_ACT Successfully."
  fi
      
  exec /usr/sbin/samba -i
  exec ntpd -d
else
  exec bash
fi
