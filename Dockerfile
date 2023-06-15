FROM ubuntu:18.04

WORKDIR /root

RUN apt-get update && apt-get install -y openssh-server openjdk-8-jdk wget
RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5.tar.gz && \
    tar -xzvf hadoop-3.3.5.tar.gz -C /opt && \
    rm hadoop-3.3.5.tar.gz

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/opt/hadoop-3.3.5
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

ENV HDFS_NAMENODE_USER=root \
    HDFS_DATANODE_USER=root \
    HDFS_SECONDARYNAMENODE_USER=root \
    YARN_RESOURCEMANAGER_USER=root \
    YARN_NODEMANAGER_USER=root

COPY config/ tmp/

# RUN mkdir -p ~/hdfs/namenode && \
#     mkdir -p ~/hdfs/datanode && \
RUN mkdir -p ~/.ssh && \
    mv ~/tmp/.ssh/* ~/.ssh/ && \
    mv ~/tmp/hadoop/* $HADOOP_HOME/etc/hadoop && \
    rm -rf ~/tmp

RUN chmod 0600 ~/.ssh/* && \
    chmod 0600 $HADOOP_HOME/etc/hadoop/kms.keystore.password && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 


CMD [ "sh", "-c", "service ssh start; bash"]
