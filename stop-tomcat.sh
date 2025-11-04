#!/bin/bash

# Tomcat停止脚本
# 用于停止proxy目录下的Tomcat服务器

echo "正在停止Tomcat服务器..."

# 进入proxy目录
cd proxy

# 检查shutdown.sh是否存在
if [ ! -f "bin/shutdown.sh" ]; then
    echo "错误: 找不到shutdown.sh文件"
    exit 1
fi

# 尝试优雅关闭
echo "正在优雅关闭Tomcat..."
./bin/shutdown.sh

# 等待关闭
sleep 3

# 检查端口8888是否还在使用
PORT=8888
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "优雅关闭失败，强制关闭进程..."
    lsof -ti:$PORT | xargs kill -9
    sleep 1
fi

# 最终检查
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "Tomcat停止失败，端口 $PORT 仍被占用"
else
    echo "Tomcat已成功停止"
fi