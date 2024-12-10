#!/bin/bash

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then 
    echo "请以 root 权限运行此脚本"
    exit 1
fi

# 获取第一个活动的网卡名称
INTERFACE=$(ip route | grep default | awk '{print $5}')

if [ -z "$INTERFACE" ]; then
    echo "未能找到主网卡接口"
    exit 1
fi

echo "检测到主网卡名称: $INTERFACE"

# 创建网络配置文件
CONFIG_DIR="/etc/systemd/network"
CONFIG_FILE="$CONFIG_DIR/10-$INTERFACE.network"

# 确保目录存在
mkdir -p "$CONFIG_DIR"

# 创建配置文件
cat > "$CONFIG_FILE" << EOF
[Match]
Name = $INTERFACE

[Network]
DHCP = ipv4
LinkLocalAddressing = ipv6
NTP = 169.254.169.254
EOF

echo "已创建网络配置文件: $CONFIG_FILE"

# 一次性执行网络切换命令
echo "正在切换网络配置..."
systemctl stop networking && systemctl stop "ifup@$INTERFACE" && systemctl start systemd-networkd

# 等待几秒确保网络连接
sleep 5

# 测试网络连接
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo "网络连接正常，继续完成配置..."
    
    # 启用 systemd-networkd 开机启动
    systemctl enable systemd-networkd
    
    # 卸载 ifupdown
    apt purge -y --auto-remove ifupdown isc-dhcp-client
    
    echo "配置完成！系统已切换到 systemd-networkd 管理网络"
else
    echo "警告：网络连接似乎有问题，请检查配置"
    exit 1
fi 