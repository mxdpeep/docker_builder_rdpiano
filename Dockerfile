FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential cmake git pkg-config \
    libasound2-dev libjack-jackd2-dev libfreetype6-dev \
    libcurl4-openssl-dev libx11-dev libxcomposite-dev \
    libxcursor-dev libxext-dev libxinerama-dev \
    libxrandr-dev libxrender-dev libwebkit2gtk-4.0-dev \
    libglu1-mesa-dev freeglut3-dev mesa-common-dev curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ARG CACHE_BUST=1
RUN git clone --recursive https://github.com/giulioz/rdpiano.git .

WORKDIR /app/rdpiano_juce
RUN git clone -b 8.0.1 --depth 1 https://github.com/juce-framework/JUCE JUCE

WORKDIR /app/rdpiano_juce/JUCE/extras/Projucer/Builds/LinuxMakefile
RUN make -j$(nproc)

WORKDIR /app/rdpiano_juce
RUN ./JUCE/extras/Projucer/Builds/LinuxMakefile/build/Projucer --resave rdpiano_juce.jucer

WORKDIR /app/rdpiano_juce/Builds/LinuxMakefile
RUN make -j$(nproc) CONFIG=Release