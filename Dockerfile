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

EXPOSE 1935
EXPOSE 8086
EXPOSE 8087
EXPOSE 8088

VOLUME ["/data"]
VOLUME ["/var/log/wowza"]

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["start"]
