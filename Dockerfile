FROM debian:jessie

RUN echo " \
deb http://mirrors.163.com/debian jessie main non-free contrib\n \
deb http://mirrors.163.com/debian jessie-updates main non-free contrib\n \
deb http://mirrors.163.com/debian jessie-backports main non-free contrib\n \
deb http://mirrors.163.com/debian-security/ jessie/updates main non-free contrib\n \
" > /etc/apt/sources.list && \
	apt-get update && \
    apt-get install -y vim wget unzip telnet sudo net-tools locales-all python-pip ffmpeg

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN wget -q https://github.com/ossrs/srs/archive/v2.0-r2.zip -P /tmp/ && \
	cd /tmp && \
	unzip v2.0-r2.zip && \
	rm -f v2.0-r2.zip

EXPOSE 1935
EXPOSE 8080

# for nginx gzip module
RUN apt-get install zlib1g-dev

RUN cd /tmp/srs-2.0-r2/trunk && \
	./configure --with-hls --with-dvr --with-nginx --with-transcode --with-ingest --with-stat --with-http-callback --with-http-server --with-http-api --log-trace \
				--without-hds --without-ssl --without-ffmpeg --without-stream-caster --without-librtmp --without-research --without-utest --without-gperf --without-gmc --without-gmp --without-gcp --without-gprof --without-arm-ubuntu12 --without-mips-ubuntu12	\
				--jobs=4 --x86-x64 --log-trace && \
	make
