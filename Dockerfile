FROM debian:jessie

RUN echo " \
deb http://mirrors.163.com/debian jessie main non-free contrib\n \
deb http://mirrors.163.com/debian jessie-updates main non-free contrib\n \
deb http://mirrors.163.com/debian jessie-backports main non-free contrib\n \
deb http://mirrors.163.com/debian-security/ jessie/updates main non-free contrib\n \
" > /etc/apt/sources.list && \
	apt-get update && \
    apt-get install -y vim wget unzip lsb-release locales locales-all

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN wget http://www.ossrs.net/srs.release/releases/files/SRS-CentOS6-x86_64-2.0.243.zip -P /tmp/ && \
	cd /tmp/ && \
	unzip SRS-CentOS6-x86_64-2.0.243.zip && \
	rm -f SRS-CentOS6-x86_64-2.0.243.zip && \
	SRS-CentOS6-x86_64-2.0.243/INSTALL && \
	rm -rf SRS-CentOS6-x86_64-2.0.243
