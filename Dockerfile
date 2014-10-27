FROM sameersbn/ubuntu:14.04.20141026
MAINTAINER sameer@damagehead.com

RUN apt-get update \
 && apt-get install -y supervisor logrotate openjdk-7-jre \
 && rm -rf /var/lib/apt/lists/* # 20140918

COPY assets/install /app/install
RUN chmod 755 /app/install
RUN /app/install

COPY assets/init /app/init
RUN chmod 755 /app/init

EXPOSE 1935
EXPOSE 8086
EXPOSE 8087
EXPOSE 8088

VOLUME ["/data"]
VOLUME ["/var/log/wowza"]

ENTRYPOINT ["/app/init"]
CMD ["start"]
