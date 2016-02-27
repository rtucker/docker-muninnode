FROM ubuntu:wily
MAINTAINER Ryan Tucker <docker@ryantucker.us>

# Resynchronize the package index files 
RUN apt-get update
RUN apt-get -y dist-upgrade

# Install the prerequisites
RUN apt-get install -y git-core munin-node munin-plugins-extra

RUN git clone https://github.com/rtucker/munin-plugins.git

ADD munin-startup.sh /
ADD munin-node.conf /etc/munin/
ADD snmp /etc/munin/plugin-conf.d/

RUN /bin/sh /munin-startup.sh

CMD ["/usr/sbin/munin-node"]
