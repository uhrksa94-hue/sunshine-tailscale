FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# System Basics + Desktop
RUN apt-get update && apt-get install -y \
    sudo wget curl git unzip nano \
    dbus dbus-x11 systemd \
    xfce4 xfce4-goodies \
    pulseaudio alsa-utils \
    mesa-utils libgl1-mesa-dri \
    openssh-server \
    xrdp \
    nvidia-utils-470 \
    && rm -rf /var/lib/apt/lists/*

# User anlegen
RUN useradd -m -s /bin/bash vast && \
    echo "vast:vast" | chpasswd && \
    echo "vast ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Sunshine installieren
RUN wget -q https://github.com/LizardByte/Sunshine/releases/latest/download/sunshine-ubuntu-22.04-amd64.deb && \
    apt-get update && apt-get install -y \
    libmfx1 \
    libboost-filesystem1.74.0 \
    libboost-locale1.74.0 \
    libboost-log1.74.0 \
    libboost-program-options1.74.0 \
    libnuma1 \
    libva2 \
    libva-drm2 \
    libvdpau1 \
    miniupnpc \
    libayatana-appindicator3-1 \
    ./sunshine-ubuntu-22.04-amd64.deb && \
    rm sunshine-ubuntu-22.04-amd64.deb

# Tailscale installieren
RUN curl -fsSL https://tailscale.com/install.sh | sh

# SSH vorbereiten
RUN mkdir /var/run/sshd && \
    echo "root:Docker!" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# XRDP Setup
RUN echo "startxfce4" > /home/vast/.xsession && \
    chown vast:vast /home/vast/.xsession

# Sunshine Config Ordner
RUN mkdir -p /home/vast/.config/sunshine && \
    chown -R vast:vast /home/vast/.config

# Xorg und Display vorbereiten
RUN mkdir -p /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix

# PulseAudio Config
RUN echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1" >> /etc/pulse/default.pa && \
    echo "load-module module-esound-protocol-tcp" >> /etc/pulse/default.pa

# Xorg Config für NVIDIA
COPY xorg.conf /etc/X11/xorg.conf
RUN chmod 644 /etc/X11/xorg.conf

# Startscript
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 22
EXPOSE 3389
EXPOSE 47984-48010/tcp
EXPOSE 47998-48010/udp

CMD ["/start.sh"]