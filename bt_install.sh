#!/bin/bash

# 设置文字颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 清屏
clear

# 显示菜单
echo -e "${GREEN}宝塔面板安装脚本${NC}"
echo "----------------------------------------"
echo -e "${BLUE}重要提示：${NC}"
echo -e "${YELLOW}1. PHP切换页面报错属于正常情况"
echo "   - 需安装企业插件「PHP网站安全告警」解决${NC}"
echo ""
echo -e "${YELLOW}2. 以下页面报错属于正常情况："
echo "   - 安全-SSH管理-SSH登录日志"
echo "   - 安全-入侵防御"
echo "   - 需安装企业插件「堡塔防入侵」解决${NC}"
echo ""
echo -e "${YELLOW}3. nginx安装失败解决方案："
echo "   - 关闭「堡塔防入侵」后即可正常安装${NC}"
echo "----------------------------------------"
echo -e "${YELLOW}请选择安装类型：${NC}"
echo ""
echo "1) Centos安装"
echo "2) 试验性Centos/Ubuntu/Debian安装（py3.7环境）"
echo "3) Ubuntu/Deepin安装"
echo "4) Debian安装"
echo "5) Fedora安装"
echo "6) 升级到企业版 9.2.0"
echo "7) 还原到官方最新版本"
echo ""
echo -e "${RED}注意：安装前请确保系统干净，不要存在其他面板${NC}"
echo "----------------------------------------"

# 读取用户输入
read -p "请输入选择的数字 [1-7]: " choice

# 根据用户选择执行相应命令
case $choice in
    1)
        echo -e "${GREEN}开始安装Centos版本...${NC}"
        yum install -y wget && wget -O install.sh http://io.bt.sy/install/install_6.0.sh && sh install.sh
        ;;
    2)
        echo -e "${GREEN}开始安装试验性版本...${NC}"
        curl -sSO http://io.bt.sy/install/install_panel.sh && bash install_panel.sh
        ;;
    3)
        echo -e "${GREEN}开始安装Ubuntu/Deepin版本...${NC}"
        wget -O install.sh http://io.bt.sy/install/install-ubuntu_6.0.sh && sudo bash install.sh
        ;;
    4)
        echo -e "${GREEN}开始安装Debian版本...${NC}"
        wget -O install.sh http://io.bt.sy/install/install-ubuntu_6.0.sh && bash install.sh
        ;;
    5)
        echo -e "${GREEN}开始安装Fedora版本...${NC}"
        wget -O install.sh http://io.bt.sy/install/install_6.0.sh && bash install.sh
        ;;
    6)
        echo -e "${GREEN}开始升级到企业版 9.2.0...${NC}"
        curl https://io.bt.sy/install/update_panel.sh|bash
        ;;
    7)
        echo -e "${GREEN}开始还原到官方最新版本...${NC}"
        curl http://download.bt.cn/install/update6.sh|bash
        ;;
    *)
        echo -e "${RED}无效的选择，请输入1-7之间的数字${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}命令执行完成！${NC}" 