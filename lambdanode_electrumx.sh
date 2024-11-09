#!/usr/bin/env bash

if [[ ! -f /data/lambdanode_electrumx/lambda.conf ]]; then
echo -e "Creating config file..."
mkdir /data/lambdanode_electrumx > /dev/null 2>&1
touch /data/lambdanode_electrumx/lambda.conf
cat <<- EOF > /data/lambdanode_electrumx/lambda.conf
rpcuser=LambdaDockerUser
rpcpassword=LambdaDockerPassword
listen=1
daemon=1
server=1
rest=1
dbcache=10
txindex=1
rpcworkqueue=1024
rpcthreads=128
rpcallowip=0.0.0.0/0
addnode=145.239.0.137:11029
addnode=51.75.144.177:21029
acceptnonstdtxn=0

EOF
fi


if [[ ! -f /data/lambdanode_electrumx/electrumdb/server.key ]]; then
  mkdir -p /data/lambdanode_electrumx/electrumdb 2>&1
  cd /data/lambdanode_electrumx/electrumdb
  openssl genrsa -out server.key 2048 > /dev/null 2>&1
  openssl req -new -key server.key -out server.csr -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=lambdablockchain.com" > /dev/null 2>&1
  openssl x509 -req -days 1825 -in server.csr -signkey server.key -out server.crt > /dev/null 2>&1
fi

bash -c "lambdad -datadir=/data/lambdanode_electrumx && python3 /root/electrumx/electrumx_server"
