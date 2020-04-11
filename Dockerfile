FROM ubuntu:18.04
MAINTAINER Norbert Kamiński "norbert.kaminski@3mbed.com"

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select \
    true | /usr/bin/debconf-set-selections && \
    apt-get install -y wget default-jre libxext-dev libswt-gtk-4-jni && \
    apt-get install -y libxrender-dev libxtst-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# Install libgtk as a separate step so that we can share the layer above with
# the netbeans image
RUN apt-get update && apt-get install -y libgtk2.0-0 libcanberra-gtk-module

RUN wget http://eclipse.c3sl.ufpr.br/technology/epp/downloads/release/2020-03/R/eclipse-cpp-2020-03-R-incubation-linux-gtk-x86_64.tar.gz \
    -O /tmp/eclipse.tar.gz -q && \
    echo 'Installing eclipse' && \
    tar -xf /tmp/eclipse.tar.gz -C /opt && \
    rm /tmp/eclipse.tar.gz

ADD run /usr/local/bin/eclipse

RUN chmod +x /usr/local/bin/eclipse && \
    mkdir -p /home/developer && \
    echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" \
    >> /etc/passwd && \
    echo "developer:x:1000:" >> /etc/group && \
    chown developer:developer -R /home/developer

USER developer
ENV HOME /home/developer
WORKDIR /home/developer
CMD /bin/bash
