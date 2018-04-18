FROM suchja/wix:latest

ENV DEBIAN_FRONTEND noninteractive

USER root
RUN dpkg --add-architecture i386
RUN sed -i "s/main/main contrib non-free/" /etc/apt/sources.list
RUN apt-get update && apt-get install -yq curl unrar

USER xclient
# innosetup
RUN mkdir innosetup && \
    cd innosetup && \
    curl -fsSLk -o innounp046.rar "https://downloads.sourceforge.net/project/innounp/innounp/innounp%200.46/innounp046.rar?r=&ts=1439566551&use_mirror=skylineservers" && \
    curl -fsSLk -o is-unicode.exe http://www.jrsoftware.org/download.php/is-unicode.exe && \
    unrar e innounp046.rar && \
    wine "./innounp.exe" -e "is-unicode.exe" && \
    rm innounp* is-unicode.exe
