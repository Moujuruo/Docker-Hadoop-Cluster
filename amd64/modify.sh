#!/bin/bash

# 定义基于主机名要添加的属性
case "$HOSTNAME" in 
  slave2)
    sed -i '$d' /root/hadoop/etc/hadoop/hdfs-site.xml
    cat >> /root/hadoop/etc/hadoop/hdfs-site.xml <<EOF
  <property>
      <name>dfs.datanode.address</name>
      <value>0.0.0.0:9966</value>
  </property>
  <property>
      <name>dfs.datanode.http.address</name>
      <value>0.0.0.0:9964</value>
  </property>
</configuration>
EOF
    ;;
  slave3)  
    sed -i '$d' /root/hadoop/etc/hadoop/hdfs-site.xml
    cat >> /root/hadoop/etc/hadoop/hdfs-site.xml <<EOF
  <property>
      <name>dfs.datanode.address</name>
      <value>0.0.0.0:10066</value>
  </property>
  <property>
      <name>dfs.datanode.http.address</name>
      <value>0.0.0.0:10064</value>
  </property>
</configuration>
EOF
    ;;
esac

# 继续执行原始命令
exec "$@"
