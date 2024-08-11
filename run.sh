#!/bin/bash

# 定义变量
PID_DIR="./pid"
SKYNET_EXEC="./skynet/skynet"
CONFIG_DIR="skynet_config"

# 定义可支持的进程名称数组
declare -a PROCESSES=("game" "process1" "process2")

# 检查pid目录是否存在，不存在则创建
if [ ! -d "$PID_DIR" ]; then
    mkdir -p "$PID_DIR"
fi

# 启动进程
start() {
    local process_name=$1
    local config_file="$CONFIG_DIR/$process_name.config"
    local pid_file="$PID_DIR/$process_name.pid"

    if [ -f "$pid_file" ]; then
        echo "$process_name is already running. PID: $(cat $pid_file)"
    else
        echo "Starting $process_name..."
        $SKYNET_EXEC $config_file &
        echo $! > "$pid_file"
        echo "$process_name started with PID: $(cat $pid_file)"
    fi
}

# 停止进程
stop() {
    local process_name=$1
    local pid_file="$PID_DIR/$process_name.pid"

    if [ -f "$pid_file" ]; then
        PID=$(cat "$pid_file")
        if kill -0 $PID > /dev/null 2>&1; then
            echo "Stopping $process_name with PID: $PID"
            kill $PID
            rm "$pid_file"
            echo "$process_name stopped."
        else
            echo "No $process_name process found with PID: $PID. Removing stale PID file."
            rm "$pid_file"
        fi
    else
        echo "No $process_name PID file found. $process_name may not be running."
    fi
}

# 检查进程名称是否在数组中
is_valid_process() {
    local process_name=$1
    for i in "${PROCESSES[@]}"; do
        if [ "$i" == "$process_name" ]; then
            return 0
        fi
    done
    return 1
}

# 主程序逻辑
if [ "$1" == "stop" ]; then
    if is_valid_process "$2"; then
        stop "$2"
    else
        echo "Invalid process name: $2"
        echo "Valid process names: ${PROCESSES[*]}"
    fi
else
    if is_valid_process "$1"; then
        if [ "$2" == "restart" ]; then
            stop "$1"
            start "$1"
        else
            start "$1"
        fi
    else
        echo "Usage: $0 {process_name | stop process_name}"
        echo "Valid process names: ${PROCESSES[*]}"
    fi
fi
