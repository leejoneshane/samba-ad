#!/bin/sh
set -e

# Configure the AD DC
if [[ ! -z "$SAMBA_DOMAIN" && ! -z "$SAMBA_DNS_REALM" ]]; then
  if [[ ! -f /etc/samba/smb.conf ]]; then
    if [[ "$SAMBA_DC_ACT" == "join" ]]; then
      echo "create kerbros client settings ..."
      export SAMBA_DNS_REALM=$(echo $SAMBA_DNS_REALM | tr 'a-z' 'A-Z')
      export SAMBA_DOMAIN=$(echo $SAMBA_DOMAIN | tr 'a-z' 'A-Z')
      rm -rf /etc/krb5.conf
      echo " 
[libdefaults]
    dns_lookup_realm = false
    dns_lookup_kdc = true
    default_realm = $SAMBA_DNS_REALM
" >> /etc/krb5.conf
      echo "$SAMBA_DOMAIN - Begin Domain Join as DC ..."
      samba-tool domain join \
        "$SAMBA_DNS_REALM" DC \
        -W "$SAMBA_DOMAIN" \
        -U Administrator \
        --password="$SAMBA_ADMIN_PASSWORD" \
        --option="dns forwarder = $SAMBA_DNS_FORWARDER"
      echo "$SAMBA_DOMAIN - Domain Join as DC Successfully."
    else
      echo "$SAMBA_DOMAIN - Begin Domain Provisioning..."
      samba-tool domain provision \
        --use-rfc2307 \
        --domain="$SAMBA_DOMAIN" \
        --adminpass="$SAMBA_ADMIN_PASSWORD" \
        --server-role=dc \
        --realm="$SAMBA_DNS_REALM" \
        --dns-backend="SAMBA_INTERNAL"
      echo "$SAMBA_DOMAIN - Domain Provisioning Successfully."
    fi
  fi
  if [[ ! -f /etc/krb5.conf ]]; then
    ln -sf /var/lib/samba/private/krb5.conf /etc/krb5.conf
  fi      
  if [[ -f /etc/samba/smb.conf ]]; then
    exec /usr/sbin/samba -i
  fi
  if [[ -f /etc/ntpd.conf ]]; then
    exec ntpd -d
  fi
fi

if [ "$#" -lt 1 ]; then
  exec bash
else
  exec "$@"
fi
