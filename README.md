# docker-proftpd

Simple way to install a proftp server on an host.

This FTP server work in passive mode (perhaps in active mode also but not sure...)


# Quick start

```bash
docker run -d --net host \
	-e FTP_LIST="user1:pass1;user2:pass2" \
	-e MASQUERADE_ADDRESS=1.2.3.4 \
	-v /path_to_ftp_dir_for_user1:/home/user1 \
	-v /path_to_ftp_dir_for_user2:/home/user2 \
	kibatic/proftpd
```

The default passive ports are 50000-50100.

The masquerade address should be the external address of your FTP server

### Warning

The way to define the users and passwords makes that you should not
use ";" or ":" in your user name or password.

(ok, this is ugly, but using FTP in 2018 is ugly too)

## USERADD_OPTIONS and PASSIVE_MIN_PORT, PASSIVE_MAX_PORT

```bash
docker run -d --net host \
	-e FTP_LIST="user1:pass1;user2:pass2" \
	-e USERADD_OPTIONS="-o --gid 33 --uid 33" \
	-e PASSIVE_MIN_PORT=50000
	-e PASSIVE_MAX_PORT=50100
	-e MASQUERADE_ADDRESS=1.2.3.4
	-v /path_to_ftp_dir_for_user1:/home/user1 \
	-v /path_to_ftp_dir_for_user2:/home/user2 \
	kibatic/proftpd
```

The `USERADD_OPTIONS` is not mandatory. It contains parameters we can
give to the useradd command (in order for example to indicate the
created user can have the uid of www-data (33) ).

It allows to give different accesses, but each user will create
the files and directory with the right user on the host.

## docker-compose.yml example

You can for example use a docker-compose like this (comment ports with `#` if you do not want to expose it to outside your machine:

```yaml
version: '3.7'

services:
  proftpd:
    image: kibatic/proftpd
    network_mode: "host"
    restart: unless-stopped
    environment:
      FTP_LIST: "myusername:mypassword"
      USERADD_OPTIONS: "-o --gid 33 --uid 33"
      # optional : default to 50000 and 50100
      PASSIVE_MIN_PORT: 50000
      PASSIVE_MAX_PORT: 50100
      # optional : default to undefined
      MASQUERADE_ADDRESS: 1.2.3.4
    volumes:
      - "/the_direcotry_on_the_host:/home/myusername"
    ports:
      - 21:21
      - 50000-50100:50000-50100 
```

## Firewall

You can use these firewall rules with the FTP in active mode

```bash
iptables -A INPUT -p tcp --dport 21 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 21 -j ACCEPT
iptables -A INPUT -p tcp --dport 20 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 20 -j ACCEPT
iptables -A INPUT -p tcp --dport 50000:50100 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 50000:50100 -j ACCEPT
```

## Testing this Dockerfile

If you want to test this Dockerfile, you can use the tester directory :

```bash
cd tester
docker-compose build --pull
docker-compose up
```

## FTPS support

If you want to enable [FTPS](https://en.wikipedia.org/wiki/FTPS) (FTP over TLS) then you will need a certificate, a private key and the configuration to enable it.

### Creating a certificate

To create a self-signed certificate and key on Linux you can use the following command:
```bash
openssl req -x509 -nodes -newkey rsa:4096 -keyout key.pem -out cert.pem
```

### Proftpd configuration to use certificate for FTPS
Assuming the certificate is called `cert.pem` and the private key is called `key.pem` you can use the following configuration file:
```
<IfModule mod_tls.c>
  TLSEngine on
  TLSLog /var/log/ftpd-tls.log

  TLSProtocol TLSv1.2 TLSv1.3

  # Are clients required to use FTP over TLS when talking to this server?
  TLSRequired on

  # Server's RSA certificate
  TLSRSACertificateFile /etc/proftpd/cert.pem
  TLSRSACertificateKeyFile /etc/proftpd/key.pem

  # Server's EC certificate
  #TLSECCertificateFile /etc/ftpd/server-ec.cert.pem
  #TLSECCertificateKeyFile /etc/ftpd/server-ec.key.pem

  # CA the server trusts
  #TLSCACertificateFile /etc/ftpd/root.cert.pem

  # Authenticate clients that want to use FTP over TLS?
  TLSVerifyClient off

  # Allow SSL/TLS renegotiations when the client requests them, but
  # do not force the renegotiations.  Some clients do not support
  # SSL/TLS renegotiations; when mod_tls forces a renegotiation, these
  # clients will close the data connection, or there will be a timeout
  # on an idle data connection.
  TLSRenegotiate none
</IfModule>
```

### Mounting the configuration and certificates

Assuming the configuration file will be called `proftpd-tls.conf` and the certificate will use `cert.pem` and `key.pem` you have to mount these 3 files to your container. You have to add the following to your docker command (before the image name). It is recommended to mount them as read-only (hence the `:ro` at the end):

```bash
docker run ...
	-v /path_to_config_dir/proftpd-tls.conf:/etc/proftpd/conf.d/proftpd-tls.conf:ro \
	-v /path_to_certificate_dir/key.pem:/etc/proftpd/key.pem:ro \
	-v /path_to_certificate_dir/cert.pem:/etc/proftpd/cert.pem:ro \
	kibatic/proftpd
```

If you're using docker compose then add them to the list of volumes:
```yaml
    volumes:
      - ...
      - /path_to_config_dir/proftpd-tls.conf:/etc/proftpd/conf.d/proftpd-tls.conf:ro
      - /path_to_certificate_dir/key.pem:/etc/proftpd/key.pem:ro
      - /path_to_certificate_dir/cert.pem:/etc/proftpd/cert.pem:ro
```

# Versions

* 2024-04-?  : Enable TLS module to allow FTPS
* 2024-04-01 : Throw error if user creation failed
* 2022-05-10 : passive port config and masquerade config
* 2022-05-09 : update to debian:bullseye-slim and better doc
* 2019-10-09 : USERADD_OPTIONS added
* 2019-04-01 : update to debian stretch
* 2018-03-30 : creation

# Author

inspired by the good idea and the image hauptmedia/proftpd
from Julian Haupt.
