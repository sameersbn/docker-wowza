FROM sameersbn/ubuntu:14.04.20150220
MAINTAINER sameer@damagehead.com

RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential libfuse-dev libcurl4-openssl-dev libxml2-dev mime-support automake libtool wget tar

RUN wget https://github.com/s3fs-fuse/s3fs-fuse/archive/v1.78.tar.gz -O /usr/src/v1.78.tar.gz

RUN tar xvz -C /usr/src -f /usr/src/v1.78.tar.gz
RUN cd /usr/src/s3fs-fuse-1.78 && ./autogen.sh && ./configure --prefix=/usr && make && make install

RUN apt-get update \
 && apt-get install -y supervisor logrotate openjdk-7-jre \
 && rm -rf /var/lib/apt/lists/* # 20150220

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
