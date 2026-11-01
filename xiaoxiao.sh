#!/bin/bash

export LANG=en_US.UTF-8

# 确保以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    printf "❌ 请使用 root 权限运行此脚本！(例如: sudo bash menu.sh)\n"
    exit 1
fi

# 定义颜色变量
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
SKYBLUE='\033[1;36m'
BOLD='\033[1m'      # 粗体
NC='\033[0m' # 恢复默认颜色

# ----------------- 自动检测并安装 jq 依赖 -----------------
check_and_install_jq() {
    if ! command -v jq &> /dev/null; then
        echo "=== 检测到系统未安装 jq，正在尝试自动安装... ==="
        
        # 尝试通过系统包管理器安装
        if command -v apt &> /dev/null; then
            apt update -y && apt install -y jq
        elif command -v yum &> /dev/null; then
            yum install -y jq
        elif command -v dnf &> /dev/null; then
            dnf install -y jq
        fi
        
        # 如果包管理器安装失败或系统没有jq命令，使用二进制直接下载安装
        if ! command -v jq &> /dev/null; then
            echo "=== 系统源安装 jq 失败，正在通过官方二进制文件直接下载安装... ==="
            wget -O /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
            chmod +x /usr/bin/jq
        fi
        
        # 最终验证
        if command -v jq &> /dev/null; then
            printf "${GREEN}✅ jq 安装成功！${NC}\n"
        else
            printf "${RED}❌ jq 安装失败，可能会影响部分脚本的显示和解析。${NC}\n"
        fi
    fi
}

# 检查 OpenVPN 是否已安装
check_openvpn_installed() {
    if [ -d "/etc/openvpn/server" ] || [ -f "/etc/systemd/system/openvpn-server@server.service" ]; then
        return 0
    else
        return 1
    fi
}

# ----------------- OpenVPN 管理函数（安装与客户端管理一体化） -----------------
do_openvpn_manager() {
    echo "=== 正在启动 OpenVPN 一键脚本 ==="
    bash <(wget -qO- https://raw.githubusercontent.com/Dzw1988/open/main/open.sh)
}

# ----------------- 其他工具安装函数 -----------------
do_install_hy2() {
    echo "=== 正在启动 Hysteria 2 一键脚本 ==="
    bash <(wget -qO- https://raw.githubusercontent.com/Dzw1988/hysteria2/main/hysteria2.sh)
}

do_install_frp() {
    echo "=== 正在启动 FRP 一键安装脚本 ==="
    bash <(wget -qO- https://raw.githubusercontent.com/Dzw1988/FRP/main/frp.sh)
}

do_install_rinetd() {
    echo "=== 正在启动 Rinetd 一键脚本 ==="
    bash <(wget -qO- https://raw.githubusercontent.com/Dzw1988/rinetd/main/rinetd.sh)
}

do_install_softether() {
    echo "=== 正在启动 SoftEther 一键脚本 ==="
    bash <(wget -qO- https://raw.githubusercontent.com/pinode1314/SoftEther/main/SoftEther.sh)
}

do_install_singbox() {
    # 在运行五合一脚本前自动检测并安装 jq
    check_and_install_jq

    # 检查 sing-box 是否已经安装（根据命令或常见配置文件目录判断）
    local is_installed=0
    if command -v sb &> /dev/null || [ -d "/etc/sing-box" ]; then
        is_installed=1
    fi

    echo "=== 正在启动五合一脚本 ==="
    
    if [ $is_installed -eq 0 ]; then
        # 第一次安装：运行脚本安装，并自动执行生成订阅链接
        bash <(wget -qO- https://raw.githubusercontent.com/Dzw1988/sing-box/main/sb.sh)
        printf '3\n8\n1\n888988' | sb
    else
        # 已经安装过：仅运行脚本进入菜单，不再强制自动输入生成订阅
        bash <(wget -qO- https://raw.githubusercontent.com/Dzw1988/sing-box/main/sb.sh)
    fi
}

do_install_system_tools() {
    echo "=== 正在启动 linux系统工具 ==="
    bash <(wget -qO- https://raw.githubusercontent.com/Dzw1988/linux/main/linux.sh)
}

do_install_firewall() {
    echo "=== 正在启动防火墙管理脚本 ==="
    bash <(wget -qO- https://raw.githubusercontent.com/Dzw1988/firewalld/main/firewalld.sh)
}

# ----------------- AmneziaWG 安装管理函数（全流程终极全汉化版） -----------------
do_install_amneziawg() {
    echo "=== 正在下载并准备 AmneziaWG 一键搭建与管理脚本 ==="
    
    # 强制重新下载最新脚本
    rm -f amneziawg-install.sh
    curl -sO https://raw.githubusercontent.com/wiresock/amneziawg-install/main/amneziawg-install.sh
    
    if [ -f "amneziawg-install.sh" ]; then
        # 1. 安装前引导及基础配置项汉化
        sed -i 's#I need to ask you a few questions before starting the setup.#在开始安装之前，需要向您确认几个配置问题。#g' amneziawg-install.sh
        sed -i 's#You can keep the default options and just press enter if you are ok with them.#如果您接受默认选项，直接按回车键即可使用默认值。#g' amneziawg-install.sh
        sed -i 's#Public IPv4 or IPv6 address or domain:#公网 IPv4、IPv6 地址或域名：#g' amneziawg-install.sh
        sed -i 's#Public interface:#公网网卡接口：#g' amneziawg-install.sh
        sed -i 's#AmneziaWG interface name:#AmneziaWG 网卡接口名称：#g' amneziawg-install.sh
        sed -i 's#Server AmneziaWG IPv4:#服务端 AmneziaWG IPv4 地址：#g' amneziawg-install.sh
        sed -i 's#Enable IPv6 support (tunnel + NAT)?#是否启用 IPv6 支持 (隧道 + NAT)？#g' amneziawg-install.sh
        sed -i 's#First DNS resolver to use for the clients:#客户端首选 DNS 解析服务器：#g' amneziawg-install.sh
        sed -i 's#Second DNS resolver to use for the clients (optional):#客户端备用 DNS 解析服务器 (可选)：#g' amneziawg-install.sh

        # 2. 路由及高级混淆参数提示汉化
        sed -i 's#AmneziaWG uses a parameter called AllowedIPs to-determine what is routed over the VPN.#AmneziaWG 使用 AllowedIPs 参数来决定哪些流量通过 VPN 路由。#g' amneziawg-install.sh
        sed -i 's#AmneziaWG uses a parameter called AllowedIPs to determine what is routed over the VPN.#AmneziaWG 使用 AllowedIPs 参数来决定哪些流量通过 VPN 路由。#g' amneziawg-install.sh
        sed -i 's#Allowed IPs list for generated clients (leave default to route everything):#生成客户端的 AllowedIPs 列表 (留空默认路由所有流量)：#g' amneziawg-install.sh
        sed -i 's#Server AmneziaWG Jc#服务端 AmneziaWG Jc 混淆包数量#g' amneziawg-install.sh
        sed -i 's#Server AmneziaWG Jmin#服务端 AmneziaWG Jmin 最小垃圾包大小#g' amneziawg-install.sh
        sed -i 's#Server AmneziaWG Jmax#服务端 AmneziaWG Jmax 最大垃圾包大小#g' amneziawg-install.sh
        sed -i 's#Server AmneziaWG S1#服务端 AmneziaWG 混淆参数 S1#g' amneziawg-install.sh
        sed -i 's#Server AmneziaWG S2#服务端 AmneziaWG 混淆参数 S2#g' amneziawg-install.sh
        sed -i 's#Server AmneziaWG S3#服务端 AmneziaWG 混淆参数 S3#g' amneziawg-install.sh
        sed -i 's#Server AmneziaWG S4#服务端 AmneziaWG 混淆参数 S4#g' amneziawg-install.sh
        sed -i 's#AmneziaWG 2.0 Features:#AmneziaWG 2.0 特性参数：#g' amneziawg-install.sh
        sed -i 's#H1-H4 Ranged Headers (ranges must not overlap):#H1-H4 范围包头 (各范围不能重叠)：#g' amneziawg-install.sh
        sed -i 's#Server AmneziaWG H1#服务端 AmneziaWG 范围包头 H1#g' amneziawg-install.sh
        sed -i 's#Server AmneziaWG H2#服务端 AmneziaWG 范围包头 H2#g' amneziawg-install.sh
        sed -i 's#Server AmneziaWG H3#服务端 AmneziaWG 范围包头 H3#g' amneziawg-install.sh
        sed -i 's#Server AmneziaWG H4#服务端 AmneziaWG 范围包头 H4#g' amneziawg-install.sh
        sed -i 's#format: min-max or single value#格式: 最小值-最大值 或 单个数值#g' amneziawg-install.sh

        # 3. 准备就绪及初始客户端创建提示汉化
        sed -i 's#Okay, that was all I needed. We are ready to setup your AmneziaWG server now.#好的，所需配置
