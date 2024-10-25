# The lambda Blockchain Developers
# The purpose of this image is to be able to host lambda Node (LMC)
# Build with: `docker build .`
# Public images at: https://hub.docker.com/u/lambdacommunity
# Thanks to Bacto for detecting bugs in the code
# CMD tail -f /dev/null

FROM ubuntu:22.04

LABEL maintainer="code@lambdablockchain.com"
LABEL version="1.3.0"
LABEL description="Docker image for lambdad node with wallet"

ARG DEBIAN_FRONTEND=nointeractive

WORKDIR /root

ENV PACKAGES="\
  build-essential \
  pkg-config \
  libtool \
  git \
  autoconf \
  automake \
  libevent-dev \
  libboost-chrono-dev \
  libboost-filesystem-dev \
  libboost-test-dev \
  ca-certificates \
  libcurl4-openssl-dev \
  libboost-thread-dev \
  libevent-dev \
  libssl-dev \
  libzmq3-dev \ 
  ninja-build \
  python3 \
  clang-tidy\
  python3-pip \
  libdb++-dev \
  cmake \
  apt-utils" 

ENV REMOVE="\
  build-essential \
  pkg-config \
  libtool \
  git \
  autoconf \
  automake \
  ninja-build \
  cmake"

RUN apt update \ 
   && apt install --no-install-recommends -y $PACKAGES  \
   && rm -rf /var/lib/apt/lists/* \
   && git clone --depth 1 --branch master https://github.com/lambdablockchain/lambda-node \
   && cmake -GNinja lambda-node -DBUILD_LAMBDA_QT=OFF -DENABLE_UPNP=OFF -DENABLE_MAN=OFF -DBUILD_LAMBDA_SEEDER=OFF -DBUILD_LAMBDA_ZMQ=ON \
   && find ../ -name "*.sh" -exec chmod +x {} \; \
  && find ../ -name "*.py" -exec chmod +x {} \; \
   && ninja \
   && ninja install \
   && rm -rf /root/* /tmp/* /var/tmp/* \
   && git clone --depth 1 --branch master https://github.com/lambdablockchain/electrumx \
   && python3 -m pip install -r /root/electrumx/requirements.txt \
   && apt remove -y $REMOVE \
   && apt autoremove -y \
   && apt purge -y --auto-remove \
   && apt clean 

ENV DAEMON_URL=http://LambdaDockerUser:LambdaDockerPassword@localhost:9332/
ENV COIN=Lambda
ENV REQUEST_TIMEOUT=60
ENV DB_DIRECTORY=/data/lambdanode_electrumx/electrumdb
ENV DB_ENGINE=leveldb
ENV SERVICES=tcp://0.0.0.0:50010,ssl://0.0.0.0:50012,wss://0.0.0.0:50022,rpc://0.0.0.0:8000
ENV SSL_CERTFILE=/data/lambdanode_electrumx/electrumdb/server.crt
ENV SSL_KEYFILE=/data/lambdanode_electrumx/electrumdb/server.key
ENV HOST=""
ENV ALLOW_ROOT=true
ENV CACHE_MB=2000
ENV MAX_SESSIONS=5000
ENV MAX_SEND=10000000
ENV MAX_RECV=10000000
ENV COST_SOFT_LIMIT=10
ENV COST_HARD_LIMIT=10

EXPOSE 9333 50010 50012 50022

COPY lambdanode_electrumx.sh /lambdanode_electrumx.sh

RUN chmod 755 /lambdanode_electrumx.sh

RUN mkdir -p /data

VOLUME /data

ENTRYPOINT ["/bin/sh", "-c" , "/lambdanode_electrumx.sh"]