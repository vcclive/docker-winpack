FROM ubuntu:18.04
MAINTAINER Tamas Jalsovszky <tamas.jalsovszky@vcc.live>
# Inspired by suchja/*

ARG myuid
ARG mygid

COPY waitonprocess.sh /scripts/
RUN chmod 755 /scripts/waitonprocess.sh

# get at least error information from wine
ENV WINEDEBUG -all,err+all

# first create user and group for all the X Window stuff
# required to do this first so we have consistent uid/gid between server and client container
RUN addgroup --system jenkins --gid $mygid \
	&& adduser \
	    --home /home/jenkins \
	    --disabled-password \
	    --shell /bin/bash \
	    --gecos "user for running an xclient application" \
	    --ingroup jenkins \
	    --quiet \
	    --uid $myuid \
	    jenkins

# Use xclient's home dir as working dir
WORKDIR /home/jenkins

# Install some tools required for creating the image
RUN dpkg --add-architecture i386
RUN sed -i "s/main/main contrib non-free/" /etc/apt/sources.list
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	    curl \
	    unzip \
	    ca-certificates \
	    unrar \
	&& apt-get clean

# Install wine and related packages
RUN apt-get install -y --no-install-recommends \
	    wine64 \
	    wine32 \
	    winetricks \
	    xvfb \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Overwrite system bounded script because it doesn't work well in docker
ADD bin/xvfb-run /usr/bin/xvfb-run
RUN chmod 755 /usr/bin/xvfb-run

ENV WINE_MONO_VERSION 4.7.1
# Get latest version of mono for wine, installed by wine upon demand
RUN mkdir -p /usr/share/wine/mono \
	&& curl -SL 'http://dl.winehq.org/wine/wine-mono/$WINE_MONO_VERSION/wine-mono-$WINE_MONO_VERSION.msi' -o /usr/share/wine/mono/wine-mono-$WINE_MONO_VERSION.msi \
	&& chmod +x /usr/share/wine/mono/wine-mono-$WINE_MONO_VERSION.msi

# Wine really doesn't like to be run as root, so let's use a non-root user
USER jenkins
ENV HOME /home/jenkins
ENV WINEPREFIX /home/jenkins/.wine32
# set default wine arch
ENV WINEARCH win32
RUN wineboot --update

# Install Resource Hacker 4.7.x
RUN mkdir reshack \
	&& cd reshack \
	&& curl -SL "http://www.angusj.com/resourcehacker/resource_hacker.zip" -o resource_hacker.zip \
	&& unzip resource_hacker.zip \
	&& rm resource_hacker.zip

# Install .NET Framework 4.0
RUN wine wineboot --update \
	&& /scripts/waitonprocess.sh wineserver \
	&& winetricks --unattended dotnet40 dotnet_verifier \
	&& /scripts/waitonprocess.sh wineserver

# Install Wix Toolset
RUN mkdir wix \
	&& cd wix \
	&& curl -fsSLk -o wix.zip "https://github.com/wixtoolset/wix3/releases/download/wix3111rtm/wix311-binaries.zip" \
	&& unzip wix.zip \
	&& rm wix.zip
