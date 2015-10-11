FROM quay.io/sameersbn/ubuntu:14.04.20151011
MAINTAINER sameer@damagehead.com

ENV WOWZA_VERSION=4.1.2 \
    WOWZA_DATA_DIR=/var/lib/wowza \
    WOWZA_LOG_DIR=/var/log/wowza

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y wget supervisor openjdk-7-jre \
 && rm -rf /var/lib/apt/lists/*

COPY install.sh /app/install.sh
RUN bash /app/install.sh

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 1935/tcp 8086/tcp 8087/tcp 8088/tcp
VOLUME ["${WOWZA_DATA_DIR}", "${WOWZA_LOG_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
