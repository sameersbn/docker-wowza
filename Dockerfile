FROM sameersbn/ubuntu:14.04.20150805
MAINTAINER sameer@damagehead.com

ENV WOWZA_VERSION=4.1.2 \
    WOWZA_DATA_DIR=/data \
    WOWZA_LOG_DIR=/var/log/wowza

RUN apt-get update \
 && apt-get install -y supervisor logrotate openjdk-7-jre \
 && rm -rf /var/lib/apt/lists/*

COPY install.sh /app/install.sh
RUN bash /app/install.sh

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 1935/tcp 8086/tcp 8087/tcp 8088/tcp
VOLUME ["${WOWZA_DATA_DIR}", "${WOWZA_LOG_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["start"]
