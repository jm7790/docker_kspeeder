# Docker KSpeeder

## 项目简介
Docker KSpeeder 是一个基于 Alpine Linux 的 KSpeeder 容器化部署方案。KSpeeder 是一个用于优化 Docker 镜像仓库访问的工具，它提供了智能镜像源选择、下载加速、状态监控等功能。本项目提供了多架构支持，可以在不同的硬件平台上运行。

## 功能特点
- 基于 Alpine Linux 的轻量级容器
- 支持多种硬件架构：
  - x86_64 (AMD64)
  - ARM v6
  - ARM v7
  - ARM64 (AArch64)
- 提供 Docker Compose 支持
- 支持数据持久化
- 支持自定义配置

## 软件特性

- Docker 镜像仓库代理服务
  - 支持 HTTPS 协议
  - 自动配置 Docker 镜像源
  - 支持证书自动获取和缓存
  - 支持多架构（AMD64/ARM64/ARM）
  - 智能镜像源选择和自动切换
  - 实时下载速度监控
  - 可视化状态监控界面

- 限速文件服务器
  - 支持可配置的带宽限制
  - 基于目录的文件服务
  - HTTP 协议支持

- 网络优化
  - 支持 HTTP/2 协议
  - 支持自定义超时设置
  - 内置连接池管理
  - 异步读取优化

## 快速开始

### 使用 Docker Compose
1. 创建 docker-compose.yml 文件：
```yaml
services:
  kspeeder:
    image: linkease/kspeeder:latest
    container_name: kspeeder
    ports:
      - "5443:5443"
      - "5003:5003"
    volumes:
      - ./kspeeder-data:/kspeeder-data
      - ./kspeeder-config:/kspeeder-config
    restart: unless-stopped
```

2. 启动服务：
```bash
docker-compose up -d
```

### 配置说明
- 端口配置：
  - 5443：KSpeeder 主服务端口
  - 5003：管理端口

- 数据卷：
  - /kspeeder-data：数据存储目录
  - /kspeeder-config：配置文件目录

- 节点配置：
  - `KS_USER_NODES_CONFIG` 用来指定 `nodes.yaml` 的路径，容器默认设置为 `/kspeeder-config/nodes.yaml`，建议把节点清单写在该位置或通过环境变量指向你的自定义文件。
  - 为了兼容旧的 docker 镜像源配置，entrypoint 仍会导出 `KS_USER_MIRROR_CONFIG`，但该 envvar 目前已废弃；优先把镜像源配置写到 `nodes.yaml` 的 `docker`/`proxies` block 下。若真的需要旧格式，也请把 `mirrors.yaml` 挂载进容器并显式设置 `KS_USER_MIRROR_CONFIG`。

## 使用说明
- 配置docker镜像服务地址
  - 镜像地址：https://registry.linkease.net:5443
- 重启docker服务
- 验证
```bash

docker info | grep "registry.linkease.net"

```
## 镜像地址
官方 Docker Hub 镜像：[linkease/kspeeder](https://hub.docker.com/r/linkease/kspeeder/)

## 开发构建

如果你需要自行构建镜像，可以使用以下命令：

```bash
# 准备多架构构建环境
docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
docker buildx create --name mybuilder --driver docker-container
docker buildx use mybuilder

# 构建并推送多架构镜像
docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64 \
  -t linkease/kspeeder:latest -f ./Dockerfile.architecture --push .
```

## 注意事项
- 首次启动时，请确保配置文件目录和数据目录具有正确的权限
- 如需修改端口映射，请同时更新容器的环境变量配置
- 建议使用 `docker-compose` 进行部署和管理
