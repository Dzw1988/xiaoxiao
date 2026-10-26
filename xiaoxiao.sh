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
NC='\033[0m' # 恢复默认颜色
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
    if [ ! -f "openvpn-install.sh" ]; then
        wget -O openvpn-install.sh https://raw.githubusercontent.com/Dzw1988/open/main/open.sh >/dev/null 2>&1
        chmod +x openvpn-install.sh
    fi
    if check_openvpn_installed; then
        echo ""
        echo "=================================================="
        printf "${GREEN}✅ 检测到 OpenVPN 服务端已安装！${NC}\n"
        printf "${GREEN}即将为您打开原版客户端与服务端管理菜单...${NC}\n"
        echo "=================================================="
        echo ""
        read -p "请按回车键继续进入管理菜单..."
    else
        echo "=== 正在下载并运行原版 OpenVPN 安装程序 ==="
    fi
    # 直接调用原版管理/安装脚本（保留原生交互，去掉多设备修改）
    bash openvpn-install.sh
}
# ----------------- 其他工具安装函数 -----------------
do_install_frp() {
    echo "=== 正在启动 FRP 一键安装脚本 ==="
    bash <(wget -qO- https://raw.githubusercontent.com/Dzw1988/FRP/main/frp.sh)
}
do_install_rinetd() {
    echo "=== 正在启动 Rinetd 一键脚本 ==="
    bash <(wget -qO- https://raw.githubusercontent.com/Dzw1988/rinetd/main/rinetd.sh)
}
do_install_singbox() {
    echo "=== 正在启动五合一脚本 ==="
    bash <(wget -qO- https://raw.githubusercontent.com/Dzw1988/sing-box/main/sb.sh)
    # 安装完成后自动执行指定命令生成订阅链接
    printf '3\n8\n1\n888988' | sb
}
# ----------------- 主菜单循环 -----------------
while true; do
    echo ""
    printf "${SKYBLUE}=========================================\n${NC}"
    printf "${SKYBLUE}     ⚡ 脚本工具箱 ⚡         \n${NC}"
    printf "${SKYBLUE}=========================================\n${NC}"
    echo " 1. 安装 OpenVPN"
    echo " 2. 安装 frp 端口映射"
    echo " 3. 安装 rinetd TCP端口映射"
    echo " 4. sing‑box 五合一脚本"
    echo " 0. 退出脚本"
    printf "${SKYBLUE}=========================================\n${NC}"
    read -p "请选择操作 [0-4]: " CHOICE
    case "$CHOICE" in
        1)
            do_openvpn_manager
            ;;
        2)
            do_install_frp
            ;;
        3)
            do_install_rinetd
            ;;
        4)
            do_install_singbox
            ;;
        0)
            echo "已安全退出脚本。"
            break
            ;;
        *)
            printf "${RED}❌ 无效的选项，请输入 0 到 4 之间的数字。\n${NC}"
            ;;
    esac
done
