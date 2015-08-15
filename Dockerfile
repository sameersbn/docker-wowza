FROM sameersbn/ubuntu:14.04.20150805
MAINTAINER sameer@damagehead.com

RUN apt-get update \
 && apt-get install -y supervisor logrotate openjdk-7-jre \
 && rm -rf /var/lib/apt/lists/*

COPY assets/install /app/install
RUN chmod 755 /app/install
RUN /app/install

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 1935/tcp 8086/tcp 8087/tcp 8088/tcp

VOLUME ["/data"]
VOLUME ["/var/log/wowza"]

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["start"]
