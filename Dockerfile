FROM ubuntu:18.04
MAINTAINER Norbert Kamiński "norbert.kaminski@3mbed.com"
USER root

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select \
    true | /usr/bin/debconf-set-selections && \
    apt-get install -y wget default-jre libxext-dev libswt-gtk-4-jni && \
    apt-get install -y libxrender-dev libxtst-dev && \
    apt-get install -y gcc gcc-avr g++ make udev && \
    apt-get install -y git usbutils lib32ncurses5 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# Install libgtk as a separate step so that we can share the layer above with
# the netbeans image
RUN apt-get update && apt-get install -y libgtk2.0-0 libcanberra-gtk-module

RUN wget http://mirror.dkm.cz/eclipse/technology/epp/downloads/release/2020-03/R/eclipse-cpp-2020-03-R-incubation-linux-gtk-x86_64.tar.gz \
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

RUN git clone -b mapy https://github.com/EcoTech-Team/Software.git ~/Software
RUN git clone -b develop https://github.com/EcoTech-Team/Hardware.git ~/Hardware
CMD sh -c 'echo \'ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="664", GROUP="plugdev"\' > /etc/udev/rules.d/99-openocd.rules'
CMD sh -c 'echo \'SUBSYSTEM=="usb",GROUP="users",MODE="0666"\' > /etc/udev/rules.d/90-usbpermission.rules'
CMD sh -c 'ln -s /lib/x86_64-linux-gnu/libncurses.so.5 /usr/lib/libncurses.so.5'
CMD sh -c 'ln -s /lib/x86_64-linux-gnu/libtinfo.so.5 /usr/lib/libtinfo.so.5'
# Install STM-32 plugins
RUN /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://ac6-tools.com/Eclipse-updates/org.openstm32.system-workbench.update-site-v2 \
    -installIU fr.ac6.feature.mcu.externaltools.armnone.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://ac6-tools.com/Eclipse-updates/org.openstm32.system-workbench.update-site-v2 \
    -installIU fr.ac6.feature.mcu.externaltools.armnone.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://ac6-tools.com/Eclipse-updates/org.openstm32.system-workbench.update-site-v2 \
    -installIU fr.ac6.feature.mcu.utils.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://ac6-tools.com/Eclipse-updates/org.openstm32.system-workbench.update-site-v2 \
    -installIU fr.ac6.feature.mcu.externaltools.openocd.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://ac6-tools.com/Eclipse-updates/org.openstm32.system-workbench.update-site-v2 \
    -installIU fr.ac6.feature.mcu.documentation.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://ac6-tools.com/Eclipse-updates/org.openstm32.system-workbench.update-site-v2 \
    -installIU fr.ac6.feature.mcu.ide.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://ac6-tools.com/Eclipse-updates/org.openstm32.system-workbench.update-site-v2 \
    -installIU fr.ac6.feature.mcu.ldscript.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://ac6-tools.com/Eclipse-updates/org.openstm32.system-workbench.update-site-v2 \
    -installIU fr.ac6.feature.mcu.debug.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://ac6-tools.com/Eclipse-updates/org.openstm32.system-workbench.update-site-v2 \
    -installIU fr.ac6.feature.mcu.externaltools.stlinkserver.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://ac6-tools.com/Eclipse-updates/org.openstm32.system-workbench.update-site-v2 \
    -installIU com.st.stm32ide.mpu.feature.common.documentation.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://ac6-tools.com/Eclipse-updates/org.openstm32.system-workbench.update-site-v2 \
    -installIU com.st.stm32ide.mpu.feature.common.utils.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository https://download.eclipse.org/releases/2020-03/ \
    -installIU org.eclipse.rse.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository https://download.eclipse.org/releases/2020-03/ \
    -installIU org.eclipse.libra.facet.feature.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://ac6-tools.com/Eclipse-updates/org.openstm32.system-workbench.update-site-v2 \
    -installIU com.st.stm32ide.mpu.feature.debug.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://ac6-tools.com/Eclipse-updates/org.openstm32.system-workbench.update-site-v2 \
    -installIU com.st.stm32ide.mpu.feature.ide.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://ac6-tools.com/Eclipse-updates/org.openstm32.system-workbench.update-site-v2 \
    -installIU com.st.stm32ide.mpu.feature.documentation.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://ac6-tools.com/Eclipse-updates/org.openstm32.system-workbench.update-site-v2 \
    -installIU com.st.stm32ide.mpu.feature.externaltools.openocd.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://ac6-tools.com/Eclipse-updates/org.openstm32.system-workbench.update-site-v2 \
    -installIU com.st.stm32ide.mpu.feature.productdb.feature.group && \
    /opt/eclipse/./eclipse -nosplash -application org.eclipse.equinox.p2.director \
    -repository http://avr-eclipse.sourceforge.net/updatesite \
    -installIU de.innot.avreclipse.feature.group

CMD /bin/bash
