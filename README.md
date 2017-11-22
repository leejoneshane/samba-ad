# samba-ad

This is a docker image to runing samba base AD build from alpine linux. It's about 38MB.

# How to use

AD is binding a lot of services such as Kerbros, LDAP, NBT, File Sharing, Time Server, DNS, Computer Discovery and so on.
These services packages is already building in this image. But you need follow the step to prepare it for working properly.

# Provision a New Domain

If you want the samba-ad container to provision a *New* domain, you *MUST* setting the container's resolv nameserver to  127.0.0.1, and you *MUST* setting DNS Forwarder to your existed windows dns server. The hostname write into the AD directory should specifie with --hostname option. Then, SAMBA_DOMAIN and SAMBA_DNS_REALM *MUST* use upper case. The docker run command example:

```
docker run --dns=127.0.0.1 --hostname=SambaAD --net=host -e SAMBA_DC_ACT=provision -e SAMBA_DOMAIN=EXAMPLE -e SAMBA_DNS_REALM=EXAMPLE.COM -e SAMBA_ADMIN_PASSWORD=#$W35fn807L -e SAMBA_DNS_FORWARDER=windows.dns.ip -d leejoneshane/samba-ad
```

# Join to Existed Domain

If you want the samba-ad container to join *Existed* domain, you *MUST* setting the container's resolv nameserver to your existed windows dns server. The hostname write into the AD directory should specifie with --hostname option. Then, SAMBA_DOMAIN and SAMBA_DNS_REALM *MUST* use upper case. The docker run command example:

```
docker run --dns=windows.dns.ip --hostname=SambaAD --net=host -e SAMBA_DC_ACT=join -e SAMBA_DOMAIN=EXAMPLE -e SAMBA_DNS_REALM=EXAMPLE.COM -e SAMBA_ADMIN_PASSWORD=#$W35fn807L -d leejoneshane/samba-ad
```
