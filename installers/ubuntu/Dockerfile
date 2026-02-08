FROM --platform=$TARGETPLATFORM ubuntu:24.04

LABEL author="zzahkaboom24" maintainer="contact@zzahkaboom24.de"
LABEL org.opencontainers.image.source="https://github.com/zzahkaboom24/yolks"
LABEL org.opencontainers.image.licenses=MIT

ENV DEBIAN_FRONTEND=noninteractive

# Add i386 architecture (useful for 32-bit x86 compat via FEX)
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        git \
        software-properties-common \
        python3 \
        lib32gcc-s1 \
        libsdl2-2.0-0:i386 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
