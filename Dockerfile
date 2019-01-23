FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y unzip wget software-properties-common make

RUN mkdir -p /android

WORKDIR /android

ENV ANDROID_SDK_VERSION=r25.2.3

RUN wget -q https://dl.google.com/android/repository/tools_${ANDROID_SDK_VERSION}-linux.zip \
 && unzip -q tools_${ANDROID_SDK_VERSION}-linux.zip \
 && rm tools_${ANDROID_SDK_VERSION}-linux.zip

ENV ANDROID_NDK_VERSION r18b

RUN wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip \
 && unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip \
 && rm android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip \
 && ln -s android-ndk-${ANDROID_NDK_VERSION} ndk-bundle

ENV ANDROID_HOME=/android
ENV ANDROID_NDK_HOME=/android/ndk-bundle
ENV PATH=${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${ANDROID_NDK_HOME}:$PATH

RUN mkdir -p ${ANDROID_HOME}/licenses \
 && touch ${ANDROID_HOME}/licenses/android-sdk-license \
 && echo "\n8933bad161af4178b1185d1a37fbf41ea5269c55" >> $ANDROID_HOME/licenses/android-sdk-license \
 && echo "\nd56f5187479451eabf01fb78af6dfcb131a6481e" >> $ANDROID_HOME/licenses/android-sdk-license \
 && echo "\ne6b7c2ab7fa2298c15165e9583d0acf0b04a2232" >> $ANDROID_HOME/licenses/android-sdk-license \
 && echo "\n84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license \
 && echo "\nd975f751698a77b662f1254ddbeed3901e976f5a" > $ANDROID_HOME/licenses/intel-android-extra-license

# Install Java.
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN yes | sdkmanager "platforms;android-23"
RUN mkdir -p ${ANDROID_HOME}/.android \
 && touch ~/.android/repositories.cfg ${ANDROID_HOME}/.android/repositories.cfg
RUN yes | sdkmanager "build-tools;25.0.2"

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

RUN wget https://downloads.sourceforge.net/project/opencvlibrary/opencv-android/3.2.0/opencv-3.2.0-android-sdk.zip \
 && unzip opencv-3.2.0-android-sdk.zip \
 && rm -f opencv-3.2.0-android-sdk.zip
ENV OPENCV_ANDROID_SDK=/afr-library/OpenCV-android-sdk
ENV CLASSPATH=$OPENCV_ANDROID_SDK/sdk/java/src

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN mkdir -p /opt \
 && ln -s $ANDROID_HOME /opt/android-sdk-linux

WORKDIR /afr-test

COPY . .

ENV AFR_LIBS_VERSION=v1.5.3.4

RUN cd app \
 && wget https://github.com/sofwerx/Android-Face-Recognition-with-Deep-Learning-Library/releases/download/${AFR_LIBS_VERSION}/afr-libs-${AFR_LIBS_VERSION}.tar.bz2 \
 && tar xvjf afr-libs-${AFR_LIBS_VERSION}.tar.bz2 \
 && rm -f afr-libs-${AFR_LIBS_VERSION}.tar.bz2

RUN ./gradlew build

CMD sleep 3600
