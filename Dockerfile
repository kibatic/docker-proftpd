FROM debian:bullseye-slim

MAINTAINER Philippe Le Van (@plv on twitter)

RUN apt-get update -qq && \
	apt-get install -y proftpd proftpd-mod-crypto && \
	apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed -i "s/# DefaultRoot/DefaultRoot /" /etc/proftpd/proftpd.conf

# Enable TLS module
RUN sed -i "s/#LoadModule mod_tls.c/LoadModule mod_tls.c/" /etc/proftpd/modules.conf

EXPOSE 20 21

ADD docker-entrypoint.sh /usr/local/sbin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/sbin/docker-entrypoint.sh"]

CMD ["proftpd", "--nodaemon"]
