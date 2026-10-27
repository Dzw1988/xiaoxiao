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
# ----------------- 工具函数 -----------------
do_openvpn_manager() {
    echo "=== 正在启动 OpenVPN 一键脚本 ==="
    bash <(wget -qO- https://raw.githubusercontent.com/Dzw1988/open/main/open.sh)
}
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
do_install_singbox() {
    echo "=== 正在启动 sing‑box 五合一脚本 ==="
    bash <(wget -qO- https://raw.githubusercontent.com/yonggekkk/sing-box-yg/main/sb.sh)

    # 刷新命令缓存
    hash -r
    # 卸载时sb不存在，直接返回，不输出红色提示
    if ! command -v sb &> /dev/null; then
        return 0
    fi

    # ============BBR任务提示（停顿前打印）============
    echo -e "\n${YELLOW}########################################################${NC}"
    echo -e "${YELLOW}        ⏳ 正在自动执行BBR加速任务，请耐心等待…         ${NC}"
    echo -e "${YELLOW}########################################################${NC}"

expect -c '
set timeout 20
spawn sb
expect "请选择"
send "11\r"
expect "Press any key to start"
send "\r"
expect eof
'

    echo -e "\n${GREEN}============================================${NC}"
    echo -e "${GREEN}          📄 正在自动生成订阅链接…           ${NC}"
    echo -e "${GREEN}============================================${NC}"
    printf '3\n8\n1\n888888' | sb

    echo -e "\n${YELLOW}################################################${NC}"
    echo -e "${YELLOW}        ✅ 全部自动任务执行完毕！可手动选择功能        ${NC}"
    echo -e "${YELLOW}################################################${NC}"
}
do_install_system_tools() {
    echo "=== 正在启动 linux系统工具 ==="
    bash <(wget -qO- https://raw.githubusercontent.com/Dzw1988/linux/main/linux.sh)
}
do_install_firewall() {
    echo "=== 正在启动防火墙管理脚本 ==="
    bash <(wget -qO- https://raw.githubusercontent.com/Dzw1988/firewalld/main/firewalld.sh)
}
# ----------------- 主菜单循环 -----------------
while true; do
    echo ""
    printf "${SKYBLUE}=========================================\n${NC}"
    printf "${SKYBLUE}     ⚡ 脚本工具箱 ⚡         \n${NC}"
    printf "${SKYBLUE}=========================================\n${NC}"
    echo " 1. 安装 OpenVPN"
    echo " 2. 安装 Hysteria 2"
    echo " 3. 安装 frp 端口映射"
    echo " 4. 安装 rinetd TCP端口映射"
    echo " 5. sing‑box 五合一脚本"
    echo " 6. linux系统工具"
    echo " 7. 系统防火墙管理"
    echo " 0. 退出脚本"
    printf "${SKYBLUE}=========================================\n${NC}"
    read -p "请选择操作 [0‑7]: " CHOICE
    case "$CHOICE" in
        1)
            do_openvpn_manager
            ;;
        2)
            do_install_hy2
            ;;
        3)
            do_install_frp
            ;;
        4)
            do_install_rinetd
            ;;
        5)
            do_install_singbox
            ;;
        6)
            do_install_system_tools
            ;;
        7)
            do_install_firewall
            ;;
        0)
            echo "已安全退出脚本。"
            break
            ;;
        *)
            printf "${RED}❌ 无效的选项，请输入 0 到 7 之间的数字。\n${NC}"
            ;;
    esac
done
