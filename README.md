<!--
 * @Author: elenno elenno.chen@gmail.com
 * @Date: 2024-08-06 23:27:05
 * @LastEditors: elenno elenno.chen@gmail.com
 * @LastEditTime: 2024-08-18 13:25:43
 * @FilePath: \MySkynetServer\README.md
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
-->
# MySkynetServer

## submodules设置

---
cd skynet
sudo git submodule update

cd 3rd/jemalloc/
sudo git submodule update
---

## 使用了skynet自带的redis


## 环境安装(git clone或svn checkout后的操作)  PS:按实际需要加sudo
0. 安装基础依赖
yum install gcc gcc-c++ openssl-devel autoconf automake
yum install libtool readline-devel zlib-devel unzip
yum install nc (debug console需要)
yum install wget 

1. 编译skynet
进入skynet目录，make linux
ps:可能会遇到libjemalloc.so报错，只要从3rd/jemalloc/lib中把
libjemalloc.so.2复制一份libjemalloc.so即可
安装成功后会产生一个skynet可执行文件

2. 安装redis
yum install redis

3. 手动安装lua (用于执行一些工具代码)
wget http://www.lua.org/ftp/lua-5.4.7.tar.gz
tar zxvf lua-5.4.7.tar.gz
cd lua-5.4.7
make linux
make install

4. 安装luarocks （lua的包管理器）
wget https://luarocks.org/releases/luarocks-3.11.1.tar.gz（或直接手动下载）
tar zxpf luarocks-3.11.1.tar.gz
cd luarocks-3.11.1
./configure && make && make install

5. 用luarocks安装lpeg等其他模块
luarocks install lpeg    （lpeg用于sprotodump生成spb)




## TODO列表
1. server.server_id问题（优先级 高）
2. 一个agent管理若干个client_fd(优先级 低)
3. 变量名混乱，尝试用self来区分