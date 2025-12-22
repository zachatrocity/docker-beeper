FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie

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
    /usr/share/selkies/www/icon.png \
    https://avatars.githubusercontent.com/u/74791520?s=200&v=4 && \
  echo "**** install packages ****" && \
  apt-get update && \
  echo "**** install beeper ****" && \
  # Get Beeper Version
  BEEPER_VERSION=$(curl -s 'https://www.beeper.com/changelog/desktop' | grep -o 'class="version-text[^>]*>[^<]*</a>' | head -n 1 | sed 's/.*v\([0-9.]*\).*/\1/') \
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
    "https://beeper-desktop.download.beeper.com/builds/Beeper-$BEEPER_VERSION-x86_64.AppImage" && \
  chmod +x /tmp/beeper.app && \
  ./beeper.app --appimage-extract && \
  mv squashfs-root /opt/beeper && \
  cp \
    /opt/beeper/beepertexts.png \
    /usr/share/icons/hicolor/512x512/apps/beeper.png && \
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
