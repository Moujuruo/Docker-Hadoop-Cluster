# 单机真分布式纯 Hadoop Docker 最速配置方式指北

本方案提供哈工大分布式系统 lab2 Hadoop Linux 环境配置方案，在已有 Docker 的前提下，可以实现五分钟以内完成配置进行实验，以下给出详细操作步骤。

## 前置准备

本方案建立在已有 WSL 2 的前提下，新版本的 Docker 已经可以内嵌入 WSL 2 下已有的 Linux 系统，使用起来十分方便。

若只安装 Docker，不使用 WSL 2，本方案理论可行，但未经测试。

Docker 的下载与安装参见，https://docs.docker.com/desktop/install/windows-install/, 个人推荐使用 WSL 2 的方式。

## 具体步骤

1. 