#!/bin/sh
set -e

# Configure the AD DC
if [[ "$SAMBA_DOMAIN" != "tld" && "$SAMBA_DNS_REALM" != "tld.your.domain" ]]; then
  if [ ! -f /etc/samba/smb.conf ]; then
    echo "$SAMBA_DOMAIN - Begin Domain $SAMBA_DC_ACT..."
    samba-tool domain $SAMBA_DC_ACT \
        --domain="$SAMBA_DOMAIN" \
        --adminpass="$SAMBA_ADMIN_PASSWORD" \
        --server-role=dc \
        --realm="$SAMBA_DNS_REALM" \
        --dns-backend="SAMBA_INTERNAL"
    echo "$SAMBA_DOMAIN - Domain $SAMBA_DC_ACT Successfully."
  fi
  if [ ! -f /etc/krb5.conf ]; then
    ln -sf /var/lib/samba/private/krb5.conf /etc/krb5.conf
  fi      
  if [ -f /etc/samba/smb.conf ]; then
    exec /usr/sbin/samba -i
  fi
  if [ -f /etc/ntpd.conf ]; then
    exec ntpd -d
  fi
fi

exec "$@"
