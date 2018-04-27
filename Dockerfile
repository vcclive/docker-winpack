FROM ubuntu:18.04
MAINTAINER Tamas Jalsovszky <tamas.jalsovszky@vcc.live>
# Inspired by suchja/*

COPY waitonprocess.sh /scripts/
RUN chmod +x /scripts/waitonprocess.sh

# get at least error information from wine
ENV WINEDEBUG -all,err+all

# first create user and group for all the X Window stuff
# required to do this first so we have consistent uid/gid between server and client container
RUN addgroup --system xusers \
	&& adduser \
	    --home /home/xclient \
	    --disabled-password \
	    --shell /bin/bash \
	    --gecos "user for running an xclient application" \
	    --ingroup xusers \
	    --quiet \
	    xclient

# Use xclient's home dir as working dir
WORKDIR /home/xclient

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

ENV WINE_MONO_VERSION 4.7.1
# Get latest version of mono for wine, installed by wine upon demand
RUN mkdir -p /usr/share/wine/mono \
	&& curl -SL 'http://dl.winehq.org/wine/wine-mono/$WINE_MONO_VERSION/wine-mono-$WINE_MONO_VERSION.msi' -o /usr/share/wine/mono/wine-mono-$WINE_MONO_VERSION.msi \
	&& chmod +x /usr/share/wine/mono/wine-mono-$WINE_MONO_VERSION.msi

# Wine really doesn't like to be run as root, so let's use a non-root user
USER xclient
ENV HOME /home/xclient
ENV WINEPREFIX /home/xclient/.wine32
# set default wine arch
ENV WINEARCH win32
RUN wineboot --update

# Install Resource Hacker 4.7.x
RUN mkdir reshack \
	&& cd reshack \
	&& curl -SL "http://www.angusj.com/resourcehacker/resource_hacker.zip" -o resource_hacker.zip \
	&& unzip resource_hacker.zip \
	&& rm resource_hacker.zip

# Install InnoSetup
RUN mkdir innosetup \
	&& cd innosetup \
	&& curl -fsSLk -o innounp046.rar "https://downloads.sourceforge.net/project/innounp/innounp/innounp%200.46/innounp046.rar?r=&ts=1439566551&use_mirror=skylineservers" \
	&& curl -fsSLk -o is-unicode.exe http://www.jrsoftware.org/download.php/is-unicode.exe \
	&& unrar e innounp046.rar \
	&& wine "./innounp.exe" -e "is-unicode.exe" \
	&& rm innounp* is-unicode.exe

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
