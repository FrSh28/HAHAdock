#!/bin/bash

PASSWORD=123456

mkdir -p ./hadoop/kms/keys
keytool -genkey -noprompt -keystore ./hadoop/kms/keys/kms.keystore \
    -alias "master-key" -storepass $PASSWORD \
    -dname "CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, S=Unknown, C=Unknown" \
    -keypass $PASSWORD
echo $1 > ./config/hadoop/kms.keystore.password

mkdir -p ./tmp
ssh-keygen -t rsa -f ./tmp/id_rsa -C "" -P ""
cat ./tmp/id_rsa.pub >> ./config/.ssh/authorized_keys

docker build -t hadoop-base .
docker network create hadoop-network
docker run -itd -v ./hadoop/master/hdfs:/root/hdfs --name hadoop-master -p 127.0.0.1:9870:9870 --network hadoop-network hadoop-base
docker run -itd -v ./hadoop/worker1/hdfs:/root/hdfs --name hadoop-worker1 --network hadoop-network hadoop-base
docker run -itd -v ./hadoop/worker2/hdfs:/root/hdfs --name hadoop-worker2 --network hadoop-network hadoop-base
docker run -itd -v ./hadoop/worker3/hdfs:/root/hdfs --name hadoop-worker3 --network hadoop-network hadoop-base
docker run -itd -v ./hadoop/worker4/hdfs:/root/hdfs --name hadoop-worker4 --network hadoop-network hadoop-base
docker run -itd -v ./hadoop/kms/keys:/root/keys --name hadoop-kms --network hadoop-network hadoop-base

docker cp ./tmp/id_rsa hadoop-master:/root/.ssh
docker exec -it hadoop-master /bin/bash -c "chmod 600 ~/.ssh/id_rsa"
rm -rf ./tmp

docker exec -it hadoop-master hdfs namenode -format
docker exec -it hadoop-master /bin/bash -c "start-dfs.sh; start-yarn.sh"
