#
# Dockerfile for Tuxedo 12.1.3
# Author: Jai  / 12-SEP-21
#
# Download the following files to current directory in case it is not present:
#   tuxedo121300_64_Linux_01_x86.zip	from http://www.oracle.com/technetwork/middleware/tuxedo/downloads/index.html
#   p22090512_121300_Linux-x86-64.zip 	or whatever the latest Tuxedo rolling patch is from My Oracle Support

FROM centos:7

RUN yum -y install vim curl unzip gcc file; yum -y clean all
RUN yum -y group install "Development Tools"

# Create the installation directory tree and user tuxdev with a password of tuxdev
RUN groupadd -g 1000 tuxdev; useradd -b /home -m -g tuxdev -u 1000 -s /bin/bash tuxdev; echo tuxdev:tuxdev | chpasswd; echo root:samplesvm | chpasswd

ADD tuxedo12.1.3_silent_install.sh tuxedo12.1.3.rsp p*_121300_Linux-x86-64.zip tuxedo121300_64_Linux_01_x86.zip /home/tuxdev/Downloads/
ADD simpclappd.cpp simpcl.c simpserv.c startup.sh start_tlisten.sh /home/tuxdev/

RUN chown tuxdev:tuxdev -R /home/tuxdev
WORKDIR /home/tuxdev/Downloads

USER tuxdev
# Install Tuxedo, SALT, and TSAM Agent
RUN sh tuxedo12.1.3_silent_install.sh p*_121300_Linux-x86-64.zip tuxedo121300_64_Linux_01_x86.zip

# --------Installations Appdynamics Specifics <Starts>
ENV LD_LIBRARY_PATH="/opt/appdynamics-cpp-sdk/lib:${LD_LIBRARY_PATH}"
ADD ext_lib/appdynamics-sdk-native-64bit-linux-21.7.4.283.0.tar /opt/
# --------Installations Appdynamics Specifics <Ends>

ENV TUXDIR /home/tuxdev/app/tuxedo12.1.3.0.0

# Clean up installer files
RUN rm -f *.zip

USER tuxdev
WORKDIR /home/tuxdev