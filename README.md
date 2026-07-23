# ImmortalWrt 定制固件 — Cudy TR3000 v1 (490MB)

## 功能清单

| # | 功能 | 说明 |
|---|------|------|
| 1 | 基础版本 | ImmortalWrt 24.10.6 稳定版 |
| 2 | Argon 主题 | 已设为默认主题 |
| 3 | UPnP / NAT-PMP | miniupnpd-nftables + LuCI 面板 |
| 4 | passwall 软件源 | 首次启动自动写入，opkg 可直接在线安装 |
| 5 | UBI 分区扩展 | DTS 中64MB→490MB |
| 6 | 首次启动预设 | 无密码、192.168.1.1、WiFi开启（Cudy / Cudy-5G）|
| 7 | 官方预装包 | 全部保留 |
| 8 | 中兴F50驱动 | kmod-mii / usb-net / cdc-ether / rndis |

---

## 使用 GitHub Actions 编译（推荐）

### 步骤

1. **Fork 本仓库**到你的 GitHub 账号

2. 进入你 fork 的仓库 → **Actions** → 启用 Workflows

3. 点击左侧 **Build ImmortalWrt for Cudy TR3000 v1** → **Run workflow**

4. 等待约 **2~3 小时**编译完成

5. 编译成功后在 **Artifacts** 下载固件压缩包
   - 文件名：`immortalwrt-cudy-tr3000-v1-112MB`
   - 保留 7 天

### 重要提醒：检查 DTS 补丁

编译日志里搜索 `Patched UBI size` 确认补丁生效。  
如果没有找到 DTS 文件，请手动检查路径：

```
immortalwrt/target/linux/mediatek/dts/mt7981b-cudy-tr3000-v1.dts
```

确认其中 UBI 分区的 `reg` 字段已改为 `0x7000000`：

```dts
partition@4000000 {
    label = "ubi";
    reg = <0x4000000 0x7000000>;  /* ← 应为 0x7000000 */
};
```

---

## 本地编译（Ubuntu 22.04）

```bash
# 1. 安装依赖
sudo apt-get update && sudo apt-get install -y \
  build-essential clang flex bison g++ gawk gcc-multilib \
  g++-multilib gettext git libncurses5-dev libssl-dev \
  python3-setuptools rsync swig unzip zlib1g-dev file wget

# 2. 克隆源码
git clone --depth=1 --branch v24.10.6 \
  https://github.com/immortalwrt/immortalwrt.git
cd immortalwrt

# 3. 打 DTS 补丁（112MB UBI）
DTS="target/linux/mediatek/dts/mt7981b-cudy-tr3000-v1.dts"
sed -i 's/0x4000000/0x7000000/g' "$DTS"

# 4. 更新 feeds
./scripts/feeds update -a && ./scripts/feeds install -a

# 5. 添加 nikki feed
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" \
  >> feeds.conf.default
./scripts/feeds update nikki && ./scripts/feeds install -a -p nikki

# 6. 添加 argon 主题
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git \
  package/luci-theme-argon

# 7. 复制自定义文件
cp -r files/ .

# 8. 应用配置
cp .config.seed .config
make defconfig

# 9. 编译
make download -j$(nproc)
make -j$(nproc) V=s

# 输出在：bin/targets/mediatek/filogic/
```

---

## 刷机说明

> ⚠️ 你已安装三分区 uboot，请使用对应的刷机方式。

### 使用 uboot web 界面刷入

1. 将电脑 IP 设为 `192.168.1.x`，连接路由器 LAN 口
2. 按住 reset 键上电进入 uboot web（通常为 `192.168.1.1`）
3. 上传 `*-sysupgrade.bin` 文件
4. 等待重启

### 关于固件文件选择

| 文件 | 用途 |
|------|------|
| `*-factory.bin` | 首次从原厂固件刷入 |
| `*-sysupgrade.bin` | 从 ImmortalWrt/OpenWrt 升级 |

---

## 首次启动后

### 安装 nikki（mihomo）

SSH 登录后（无需密码）：

```bash
opkg update
opkg install luci-app-nikki
```

或在 LuCI 软件包管理器中直接搜索 `nikki` 安装。

### 中兴 F50 USB 共享网络

将 F50 插入 USB 口，开启 USB 网络共享（RNDIS 模式）后：

```bash
# 查看新网卡
ip link show

# 若需要手动 DHCP（通常自动）
udhcpc -i usb0
```

驱动已预装，不会影响 WAN 口配置。

---

## 软件包版本参考

| 软件包 | 来源 |
|--------|------|
| ImmortalWrt | v24.10.6 官方稳定版 |
| luci-theme-argon | jerrykuku/luci-theme-argon main |
| nikki (mihomo) | nikkinikki-org/OpenWrt-nikki main |
| miniupnpd-nftables | ImmortalWrt 官方源 |
