# 使用基础镜像
FROM ubuntu:18.04

# 设置环境变量
ENV HADOOP_HOME=/opt/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin

# 安装 Java
RUN apt-get update && apt-get install -y openjdk-8-jdk

# 复制 Hadoop 相关文件到容器
COPY hadoop /opt/hadoop

# 运行脚本以配置 Hadoop
RUN chmod +x /opt/hadoop/hadoop_setup.sh
RUN /opt/hadoop/hadoop_setup.sh

# 安装和配置 Hadoop
RUN cd $HADOOP_HOME && \
    # 配置 Hadoop 环境变量
    echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> etc/hadoop/hadoop-env.sh && \
    # 其他配置步骤...

# 暴露 Hadoop 端口
EXPOSE 8088 50070

# 设置容器启动时的默认命令
CMD ["hadoop", "version"]
