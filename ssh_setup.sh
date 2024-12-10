#!/bin/bash

# 设置颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查root权限
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}请以root权限运行此脚本${NC}"
    exit 1
fi

echo -e "${GREEN}开始配置SSH服务...${NC}"

# 设置root密码
echo -e "${YELLOW}请设置root密码${NC}"
until passwd root; do
    echo -e "${RED}密码设置失败，请重试${NC}"
done

# 配置自动登录
echo -e "${GREEN}正在配置登录设置...${NC}"
files=("/etc/pam.d/gdm-autologin" "/etc/pam.d/gdm-password")
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        sed -i "s/.*root quiet_success$/#&/" "$file"
        echo -e "${GREEN}已更新 $file${NC}"
    fi
done

# 修改root配置文件
if [ -f "/root/.profile" ]; then
    sed -i 's/^mesg.*/tty -s \&\& mesg n \|\| true/' /root/.profile
    echo -e "${GREEN}已更新 root profile${NC}"
fi

# 安装OpenSSH服务器
echo -e "${GREEN}正在安装OpenSSH服务器...${NC}"
if ! apt install -y openssh-server; then
    echo -e "${RED}OpenSSH安装失败${NC}"
    exit 1
fi

# 配置SSH
echo -e "${GREEN}正在配置SSH...${NC}"
sshd_config="/etc/ssh/sshd_config"
if [ -f "$sshd_config" ]; then
    # 备份原配置文件
    cp "$sshd_config" "${sshd_config}.bak"
    
    # 修改SSH配置
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' "$sshd_config"
    
    # 确保密码认证开启
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' "$sshd_config"
    
    echo -e "${GREEN}SSH配置已更新${NC}"
else
    echo -e "${RED}未找到SSH配置文件${NC}"
    exit 1
fi

# 重启SSH服务
echo -e "${GREEN}正在重启SSH服务...${NC}"
if systemctl restart ssh; then
    echo -e "${GREEN}SSH服务已重启${NC}"
else
    echo -e "${RED}SSH服务重启失败${NC}"
    exit 1
fi

# 检查SSH服务状态
if systemctl is-active ssh >/dev/null 2>&1; then
    echo -e "${GREEN}SSH服务配置成功！${NC}"
    # 显示SSH端口信息
    ssh_port=$(grep "^Port" "$sshd_config" | awk '{print $2}')
    echo -e "${YELLOW}SSH服务正在运行在端口: ${ssh_port:-22}${NC}"
else
    echo -e "${RED}SSH服务未能正常运行，请检查配置${NC}"
    exit 1
fi 