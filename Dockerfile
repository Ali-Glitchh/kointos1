FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install essential packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-8-jdk \
    wget \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up Flutter
ENV FLUTTER_HOME=/flutter
ENV PATH=$PATH:$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME -b stable

# Run basic Flutter commands to setup the environment
RUN flutter precache && \
    flutter doctor && \
    flutter config --no-analytics

# Set up Android SDK
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# Download Android SDK
RUN mkdir -p $ANDROID_HOME && \
    cd $ANDROID_HOME && \
    curl -o cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip && \
    unzip cmdline-tools.zip && \
    rm cmdline-tools.zip && \
    mkdir -p cmdline-tools/latest && \
    mv cmdline-tools/bin cmdline-tools/latest/ && \
    mv cmdline-tools/lib cmdline-tools/latest/ && \
    rm -rf cmdline-tools/NOTICE.txt cmdline-tools/source.properties

# Accept licenses and install required Android components
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3"

# Set the working directory
WORKDIR /app

# Install Flutter project dependencies and build generated code
ONBUILD COPY pubspec.yaml pubspec.lock /app/
ONBUILD RUN flutter pub get
ONBUILD COPY . /app/
ONBUILD RUN if grep -q "build_runner" pubspec.yaml; then \
    flutter pub run build_runner build --delete-conflicting-outputs; \
    fi

# Set environment variables for Flutter to run correctly in Docker
ENV CHROME_EXECUTABLE=google-chrome

# The entry point
CMD ["bash"]
