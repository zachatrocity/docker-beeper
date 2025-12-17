FROM ghcr.io/linuxserver/baseimage-selkies:ubuntunoble

# set version label
# ARG BUILD_DATE
# ARG VERSION
# ARG BEEPER_VERSION
# LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="zachatrocity"

# https://download.beeper.com/linux/
# legacy appimage: beeper-3.110.1x86_64.AppImage

# title
ENV TITLE=Beeper

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://avatars.githubusercontent.com/u/74791520?s=200&v=4 && \
  echo "**** install packages ****" && \
  add-apt-repository ppa:xtradeb/apps && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  echo "**** install beeper ****" && \
  # Todo don't hard code beeper version
  # if [ -z ${BEEPER_VERSION+x} ]; then \
  #   BEEPER_VERSION=$(curl -sX GET "https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest"| awk '/tag_name/{print $4;exit}' FS='[""]'); \
  # fi && \
  apt-get install -y --no-install-recommends \
    chromium \
    chromium-l10n \
    git \
    libgtk-3-bin \
    libatk1.0 \
    libatk-bridge2.0 \
    libnss3 \
    python3-xdg && \
  cd /tmp && \
  echo "**** download beta ****" && \
  curl -o \
    /tmp/beeper.app -L \
    "https://beeper-desktop.download.beeper.com/builds/Beeper-4.2.330-x86_64.AppImage" && \
  chmod +x /tmp/beeper.app && \
  ./beeper.app --appimage-extract && \
  mv squashfs-root /opt/beeper && \
  cp \
    /opt/beeper/beepertexts.png \
    /usr/share/icons/hicolor/512x512/apps/beeper.png && \
  localedef -i en_GB -f UTF-8 en_GB.UTF-8 && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /config/.launchpadlib \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config
