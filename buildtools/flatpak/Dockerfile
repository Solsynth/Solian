FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl unzip xz-utils git \
    ninja-build pkg-config \
    libgtk-3-dev liblzma-dev \
    libmpv-dev mpv \
    libayatana-appindicator3-dev \
    keybinder-3.0 libnotify-dev \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    gstreamer-1.0 libsecret-1-dev \
    libcurl4-openssl-dev \
    flatpak flatpak-builder \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.2-stable.tar.xz \
    -o /tmp/flutter.tar.xz \
    && tar xf /tmp/flutter.tar.xz -C /opt \
    && rm /tmp/flutter.tar.xz
ENV PATH="/opt/flutter/bin:${PATH}"
RUN flutter precache --no-web --no-android --no-ios --no-macos --no-fuchsia

# Install Freedesktop Flatpak runtime
RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo \
    && flatpak install -y --noninteractive flathub org.freedesktop.Platform//24.08 \
    && flatpak install -y --noninteractive flathub org.freedesktop.Sdk//24.08

WORKDIR /workspace
ENTRYPOINT ["bash"]
