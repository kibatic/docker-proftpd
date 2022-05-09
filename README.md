docker-proftpd
==============

Simple way to install a proftp server on an host.

This FTP server is in active mode.

Quick start
-----------

```bash
docker run -d --net host \
	-e FTP_LIST="user1:pass1;user2:pass2" \
	-v /path_to_ftp_dir_for_user1:/home/user1 \
	-v /path_to_ftp_dir_for_user2:/home/user2 \
	kibatic/proftpd
```

Warning
-------

The way to define the users and passwords makes that you should not
use ";" or ":" in your user name or password.

(ok, this is ugly, but using FTP in 2018 is ugly too)

USERADD_OPTIONS
---------------

```bash
docker run -d --net host \
	-e FTP_LIST="user1:pass1;user2:pass2" \
	-e USERADD_OPTIONS="-o --gid 33 --uid 33" \
	-v /path_to_ftp_dir_for_user1:/home/user1 \
	-v /path_to_ftp_dir_for_user2:/home/user2 \
	kibatic/proftpd
```

The USERADD_OPTIONS is not mandatory. It contains parameters we can
give to the useradd command (in order for example to indicates the
created user can have the uid of www-data (33) ).

It allows to give different accesses, but each user will create
the files and directory with the right user on the host.

docker-compose.yml example
--------------------------

You can for example use a docker-compose like this :

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
    volumes:
      - "/the_direcotry_on_the_host:/home/myusername"
```

Firewall
--------

You can use these firewall rules with the FTP in active mode

```bash
modprobe ip_conntrack_ftp
iptables -A INPUT -p tcp --sport 21 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 21 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 20 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 20 -m state --state ESTABLISHED -j ACCEPT
```

Testing this Dockerfile
-----------------------

If you want to test this Dockerfile, you can use the tester directory :

```bash
cd tester
docker-compose build --pull
docker-compose up
```

Versions
--------

* 2022-05-09 : update to debian:bullseye-slim and better doc
* 2019-10-09 : USERADD_OPTIONS added
* 2019-04-01 : update to debian stretch
* 2018-03-30 : creation

Author
------

inspired by the good idea and the image hauptmedia/proftpd
from Julian Haupt.
