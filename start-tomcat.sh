#!/bin/bash

# Tomcat启动脚本
# 用于启动proxy目录下的Tomcat服务器

echo "正在启动Tomcat服务器..."

# 进入proxy目录
cd proxy

# 检查startup.sh是否存在且可执行
if [ ! -f "bin/startup.sh" ]; then
    echo "错误: 找不到startup.sh文件"
    exit 1
fi

# 检查端口8888是否已被占用
PORT=8888
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "端口 $PORT 已被占用，正在尝试关闭现有进程..."
    # 尝试优雅关闭
    ./bin/shutdown.sh
    sleep 2

    # 检查是否还在运行
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
        echo "强制关闭端口 $Port 上的进程..."
        lsof -ti:$PORT | xargs kill -9
    fi
fi

# 启动Tomcat
echo "启动Tomcat..."
./bin/startup.sh

# 等待一下让Tomcat启动
sleep 3

# 检查是否启动成功
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "Tomcat启动成功！"
    echo "访问地址: http://localhost:$PORT/proxy/"
    echo "查看日志: tail -f logs/catalina.out"
else
    echo "Tomcat启动失败，请检查日志: logs/catalina.out"
fi