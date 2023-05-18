#!/bin/bash

sudo -s

apt-get update
apt-get install -y openssh-server openjdk-8-jdk wget
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/profile

## only on namenode
ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ""
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
cp ~/.ssh/authorized_keys $OUTSIDE
## else
cp $OUTSIDE/authorized_keys ~/.ssh/authorized_keys
## end
chmod 0600 ~/.ssh/authorized_keys
service ssh start

## only on namenode
mkdir -p ~/hdfs/name
## end
## only on datanode
mkdir -p ~/hdfs/data
## end

wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5.tar.gz
tar -zxvf hadoop-3.3.5.tar.gz -C /opt
rm hadoop-3.3.5.tar.gz
echo "HADDOP_HOME=/opt/hadoop-3.3.5" >> /etc/profile
echo "PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin" >> /etc/profile

cp $OUTSIDE/config/* $HADDOP_HOME/etc/hadoop

## only on namenode
hdfs namenode -format
## end

## only on kms
hadoop --daemon start kms
## end


## after container up
start-dfs.sh
start-yarn.sh
