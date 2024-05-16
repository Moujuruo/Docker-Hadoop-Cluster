FROM ubuntu:22.04

WORKDIR /root/

# apt换清华源
# 使用 http, 因为 https 需要 certificates
RUN sed -i "s@http://.*.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list

# 安装JDK等
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk wget vim openssh-server net-tools

# 配置SSH免密码登录
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# 下载并解压 Hadoop
RUN wget https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
RUN tar -xzvf hadoop-3.3.6.tar.gz && \
    rm hadoop-3.3.6.tar.gz && \
    mv hadoop-3.3.6 hadoop && \
    chmod -R 777 hadoop

RUN echo "slave1" > /root/hadoop/etc/hadoop/workers
RUN echo "slave2" >> /root/hadoop/etc/hadoop/workers 
RUN echo "slave3" >> /root/hadoop/etc/hadoop/workers

# 配置环境变量
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/root/hadoop

RUN mkdir $HADOOP_HOME/tmp
ENV HADOOP_TMP_DIR=$HADOOP_HOME/tmp

RUN mkdir $HADOOP_HOME/tmp/dfs

RUN mkdir $HADOOP_HOME/tmp/dfs/namenode
RUN mkdir $HADOOP_HOME/tmp/dfs/datanode

ENV HADOOP_CONFIG_HOME=$HADOOP_HOME/etc/hadoop

ENV PATH=$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

ENV HADOOP_CLASSPATH=$HADOOP_HOME/share/hadoop/tools/lib/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_CLASSPATH

ENV HDFS_NAMENODE_USER="root"
ENV HDFS_DATANODE_USER="root"
ENV HDFS_SECONDARYNAMENODE_USER="root"
ENV YARN_RESOURCEMANAGER_USER="root"
ENV YARN_NODEMANAGER_USER="root"

# 配置Hadoop
COPY hadoop_config/* /root/hadoop/etc/hadoop/
RUN sed -i '1i export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' /root/hadoop/etc/hadoop/hadoop-env.sh

# 配置SSH
RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

# 启动SSH服务
CMD ["bash", "-c", "service ssh restart; bash"]
