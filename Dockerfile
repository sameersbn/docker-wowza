FROM sameersbn/ubuntu:14.04.20150220
MAINTAINER emili@streamgps.com

RUN apt-get update \
 && apt-get install -y supervisor logrotate openjdk-7-jre build-essential libfuse-dev libcurl4-openssl-dev libxml2-dev mime-support automake libtool wget tar unzip \
 && rm -rf /var/lib/apt/lists/* # 20150220

COPY assets/install /app/install
RUN chmod 755 /app/install
RUN /app/install

COPY assets/init /app/init
RUN chmod 755 /app/init

RUN wget https://github.com/s3fs-fuse/s3fs-fuse/archive/master.zip -O /usr/src/master.zip

RUN unzip /usr/src/master.zip -d /usr/src
RUN cd /usr/src/s3fs-fuse-master && ./autogen.sh && ./configure --prefix=/usr && make && make install

RUN mkdir /mnt/s3
RUN chmod 755 /mnt/s3

EXPOSE 1935
EXPOSE 8086
EXPOSE 8087
EXPOSE 8088

VOLUME ["/data"]
VOLUME ["/var/log/wowza"]

ENTRYPOINT ["/app/init"]
CMD ["start"]
