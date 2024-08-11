# MySkynetServer

## submodules设置

---
cd skynet
sudo git submodule update

cd 3rd/jemalloc/
sudo git submodule update
---

## 使用了skynet自带的redis


## 环境安装(git clone或svn checkout后的操作)
0. 安装基础依赖
yum install gcc gcc-c++ openssl-devel autoconf automake
yum install libtool readline-devel zlib-devel unzip
yum install nc (debug console需要)

1. 编译skynet
进入skynet目录，make linux
ps:可能会遇到libjemalloc.so报错，只要从3rd/jemalloc/lib中把
libjemalloc.so.2复制一份libjemalloc.so即可
安装成功后会产生一个skynet可执行文件

2. 安装redis
