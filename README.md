docker-proftpd
==============

Simple way to install a proftp server on an host.

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

Author
------

inspired by the good idea and the image hauptmedia/proftpd
from Julian Haupt.
