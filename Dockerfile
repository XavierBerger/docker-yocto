# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.17

MAINTAINER Doug Goldstein <cardoe@cardoe.com>

# No Debian that's a bad Debian! We don't have an interactive prompt don't fail
ENV DEBIAN_FRONTEND noninteractive

# Use baseimage-docker's init
# https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/
ENTRYPOINT ["/sbin/my_init", "--"]

# Where we build
RUN mkdir -p /var/build
WORKDIR /var/build

# Yocto's depends (plus sudo)
RUN apt-get --quiet --yes update && \
	apt-get --quiet --yes install gawk wget git-core diffstat unzip \
		texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev \
		xterm python sudo curl

# Update the CA certificates with the web proxy cert
RUN curl http://www.star.lab/proxy.crt >> /usr/local/share/ca-certificates/StarLab.crt && update-ca-certificates --fresh

# If you need to add more packages, just do additional RUN commands here
# I've intentionally done this so that the layers before this don't have
# to be regenerated and fetched since the above layer is big.
# RUN apt-get --quiet --yes install something
RUN apt-get --quiet --yes install tmux

# clean up
RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# utilize my_init from the baseimage to create the user for us
# the reason this is dynamic is so that the caller of the container
# gets the UID:GID they need/want made for them
RUN mkdir -p /etc/my_init.d
ADD create-user.sh /etc/my_init.d/create-user.sh

# bitbake wrapper to drop root perms
ADD bitbake.sh /usr/local/bin/bitbake
ADD bitbake.sh /usr/local/bin/bitbake-diffsigs
ADD bitbake.sh /usr/local/bin/bitbake-dumpsig
ADD bitbake.sh /usr/local/bin/bitbake-layers
ADD bitbake.sh /usr/local/bin/bitbake-prserv
ADD bitbake.sh /usr/local/bin/bitbake-selftest
ADD bitbake.sh /usr/local/bin/bitbake-worker
ADD bitbake.sh /usr/local/bin/bitdoc
ADD bitbake.sh /usr/local/bin/image-writer
ADD bitbake.sh /usr/local/bin/toaster
ADD bitbake.sh /usr/local/bin/toaster-eventreplay

