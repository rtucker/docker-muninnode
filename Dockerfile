FROM ubuntu:zesty
MAINTAINER Rey Tucker <docker@ryantucker.us>

# Resynchronize the package index files 
RUN apt-get update
RUN apt-get -y dist-upgrade

# Install the prerequisites
RUN apt-get install -y git-core munin-node munin-plugins-extra snmp

RUN git clone https://github.com/rtucker/munin-plugins.git

ADD munin-node.conf /etc/munin/
ADD snmp /etc/munin/plugin-conf.d/

ADD config.sh /
ADD munin-startup.sh /

RUN /bin/bash /munin-startup.sh

CMD ["/usr/sbin/munin-node"]
