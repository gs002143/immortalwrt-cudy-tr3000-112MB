#!/bin/sh
# 99-custom-init.sh — 首次启动预配置
# Cudy TR3000 v1 定制固件

# ---- 1. 无登录密码 ----
passwd -d root

# ---- 2. 局域网 IP ----
uci set network.lan.ipaddr='192.168.1.1'
uci set network.lan.netmask='255.255.255.0'
uci commit network

# ---- 3. WiFi 预配置 ----
# 2.4G（device[0] / iface[0]）
uci set wireless.@wifi-device[0].disabled='0'
uci set wireless.@wifi-iface[0].disabled='0'
uci set wireless.@wifi-iface[0].ssid='Cudy'
uci set wireless.@wifi-iface[0].encryption='none'

# 5G（device[1] / iface[1]）
uci set wireless.@wifi-device[1].disabled='0'
uci set wireless.@wifi-iface[1].disabled='0'
uci set wireless.@wifi-iface[1].ssid='Cudy-5G'
uci set wireless.@wifi-iface[1].encryption='none'

uci commit wireless
wifi up

# ---- 4. 设置 Argon 为默认主题 ----
uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci

# ---- 5. 添加 nikki 软件源 ----
NIKKI_FEED="src/gz nikki https://nikkinikki-org.github.io/OpenWrt-nikki/releases/packages-24.10/aarch64_cortex-a53"
CUSTOM_FEEDS="/etc/opkg/customfeeds.conf"
grep -qF "nikki" "$CUSTOM_FEEDS" 2>/dev/null || echo "$NIKKI_FEED" >> "$CUSTOM_FEEDS"

# ---- 完成 ----
exit 0
