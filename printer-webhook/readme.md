0. Perform one time setup on an Ubuntu Server VM.
```
apt install vsftpd curl
useradd -m -d /srv/ibmi -s /usr/sbin/nologin ibmi
passwd ibmi
mkdir -p /srv/ibmi/sent && chown -R ibmi:ibmi /srv/ibmi
```