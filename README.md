build dockerfile by running this command :   

docker build -t lambda .

run lambda full node + electrumx server using this command 

sudo docker run -it -p 50012:50012 --name lambda-container lambda /bin/bash
