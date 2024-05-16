# 单机真分布式纯 Hadoop Docker 最速配置方式指北

本方案提供哈工大分布式系统 lab2 Hadoop Linux 环境配置方案，在已有 Docker 的前提下，可以实现五分钟以内完成 Hadoop 3.3.6 配置进行实验，以下给出详细操作步骤。

## 前置准备

本方案建立在已有 WSL 2 的前提下，新版本的 Docker 已经可以内嵌入 WSL 2 下已有的 Linux 系统，使用起来十分方便。

若只安装 Docker，不使用 WSL 2，本方案理论可行，但未经测试。

Docker 的下载与安装参见，https://docs.docker.com/desktop/install/windows-install/, 个人推荐使用 WSL 2 的方式。

## 具体步骤

1. git clone 本仓库到本地 `git clone https://github.com/Moujuruo/Docker-Hadoop-Cluster.git`
2. 进入仓库目录 `cd Docker-Hadoop-Cluster`
3. 进入 amd64 目录 `cd amd64`
4. 构建镜像 `docker build . -t hadoop`，这一步需要等待一些时间，网络正常情况下不超过 10 分钟
5. 返回上级目录 `cd ..`
6. 运行容器 `docker-compose up -d`

到这里如果一切正常，你应该能看到

![alt text](Picture/image.png)

此时，容器已经正常启动，你的环境已经搭建完成。环境由一个主机节点 master 和三个从机节点 slave1, slave2, slave3 组成。正常情况下都只要进入主机完成操作即可，命令为`docker exec -it master bash`。

Hadoop 暴露的几个端口如下：
- "8020:8020" # fs.defaultFS
- "9870:9870" # NameNode Web UI
- "9868:9868" # Secondary NameNode Web UI
- "8088:8088" # Yarn Web UI

除了 8020 外，其它都可以在本地浏览器中通过 `localhost:端口号` 或 `127.0.0.1:端口号` 访问。

此外再介绍几个操作方便使用 Docker，由于未知原因，这里不推荐使用 Docker Desktop 的可视化界面进行操作
- 容器关闭，`docker-compose stop`
- 容器再次启动，`docker-compose up -d`
- 进入容器使用 bash，`docker exec -it master bash`

## IDEA 连接

在 IDEA 中可以连接 Hadoop 集群，可以直接操作 HDFS，但需要完成关于 Windows 下 Hadoop 的环境配置。

该环境配置有两种方式，一种只要配置 winutils，一种则是完整配置 Hadoop 环境，鉴于本实验要求在 Windows 上也能运行，因此介绍第二种配置方式。该配置需要前置 JAVA 8(jdk 1.8)环境，这里不赘述。

1. 完整下载 Hadoop，推荐清华源https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-3.3.6/, 下载 hadoop-3.3.6.tar.gz 
2. 解压到某个非中文路径下，解压时用部分解压缩软件会报错，可以使用`tar zxvf hadoop-3.3.6.tar.gz`，我测试 7-Zip 是可以的
3. clone 这个仓库`https://github.com/feishuoren/hadoop_compiler`，将`/hadoop-3.3.6/hadoop-dist/winutils` 目录下的两个文件放到第 2 步解压后的 `/hadoop-3.3.6/bin` 目录下，同时把两个文件中的`hadoop.dll`放到 `C:/windows/system32` 下。
4. 配置系统环境变量，新增变量名`HADOOP_HOME`
变量值：就是你上面选择的hadoop版本文件夹的位置地址，例如`D:\HIT\2024\distributed_system\hadoop-3.3.6`
![alt text](Picture/image2.png)
5. 在环境变量 Path 中新增变量值 `%HADOOP_HOME%\bin`
![alt text](Picture/image3.png)
6. 修改解压路径 `\hadoop-3.3.6\etc\hadoop\hadoop-env.cmd` 内容，搜索`set JAVA_HOME=` 将原来的`set JAVA_HOME=%JAVA_HOME%`改为`set JAVA_HOME=你的jdk路径`，例如`set JAVA_HOME=C:\PROGRA~1\Java\jdk1.8.0_202`, 特别注意，如果如今中是`Program Files`存在空格，需要用`PROGRA~1`代替`Program Files`，就如上面的例子。
7. 重启电脑，在 cmd 中输入`hadoop version`，如果出现版本号，说明配置成功。

IDEA 中可以安装插件 BigData Tools，直接连接 HDFS，配置如下：
![alt text](Picture/image4.png)


## 测试

新建一个 Maven 项目，添加 Hadoop 依赖，这里使用的是 3.3.6 版本，pom.xml 中新增依赖如下：

```xml
<dependencies>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-common</artifactId>
            <version>3.3.6</version>
            <exclusions>
                <exclusion>
                    <groupId>org.slf4j</groupId>
                    <artifactId>slf4j-api</artifactId>
                </exclusion>
                <exclusion>
                    <groupId>org.slf4j</groupId>
                    <artifactId>slf4j-reload4j</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-hdfs</artifactId>
            <version>3.3.6</version>
        </dependency>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-client</artifactId>
            <version>3.3.6</version>
        </dependency>
    </dependencies>
```
提供操作 HDFS 的示例代码如下
```
package org.example;
import java.io.IOException;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;

public class Demo {


public static void main(String[] args) throws IOException, InterruptedException, ClassNotFoundException {

        Configuration conf = new Configuration();
//这里指定使用的是hdfs文件系统
        conf.set("fs.defaultFS", "hdfs://127.0.0.1:8020");
//通过如下的方式进行客户端身份的设置
        System.setProperty("HADOOP_USER_NAME", "root");
//通过FileSystem的静态方法获取文件系统客户端对象
        FileSystem fs = FileSystem.get(conf);
//也可以通过如下的方式去指定文件系统的类型并且同时设置用户身份
//FileSystem fs = FileSystem.get(new URI("hdfs://master:8020"), conf, "root");
//创建一个目录
        fs.create(new Path("/hdfsbyjava-ha1"), false);
//创建一个文件
        fs.create(new Path("/helloByJava1"));
//关闭我们的文件系统
        fs.close();
    }
}
```
执行后可以在`http://localhost:9870/explorer.html#`中看到新建的文件夹和文件。