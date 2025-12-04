#!/bin/bash
set -e

echo "===> BPI-R4 ImmortalWrt Build Setup - Optimized v0.1"

# Essential tools organized by category
CORE_TOOLS="
btop
htop
nano
screen
rsync
curl
wget-ssl
diffutils
"

# Network monitoring and diagnostics
NETWORK_MONITOR="
iftop
iperf3
ethtool-full
tcpdump-mini
nmap
nlbwmon
luci-app-nlbwmon
"

# Statistics and performance
STATS_PKGS="
luci-app-statistics
collectd-mod-thermal
collectd-mod-cpufreq
collectd-mod-irq
irqbalance
"

# Modern QoS - qosify is the modern alternative to classic SQM
QOS_MODERN="
qosify
luci-app-qosify
kmod-sched-cake
kmod-sched-core
kmod-ifb
"

# Modern VPN (WireGuard only, no OpenVPN)
VPN_PKGS="
wireguard-tools
luci-app-wireguard
luci-proto-wireguard
"

# Policy Based Routing
PBR_PKGS="
pbr
luci-app-pbr
"

# BPI-R4 specific hardware
HARDWARE_PKGS="
mmc-utils
kmod-fs-f2fs
kmod-phy-marvell
kmod-phy-aquantia
kmod-hwmon-pwmfan
kmod-i2c-mux-pca954x
kmod-eeprom-at24
kmod-rtc-pcf8563
kmod-sfp
"

# USB and storage
USB_STORAGE="
kmod-usb3
kmod-usb-storage
kmod-usb-net
kmod-usb-net-rndis
kmod-usb-net-cdc-ether
usb-modeswitch
block-mount
"

# Automatic updates
UPDATES="
luci-app-attendedsysupgrade
"

# Useful LuCI extras
LUCI_EXTRAS="
luci-app-commands
luci-ssl-openssl
"

# Combine all packages
EXTRA_PKGS="
$CORE_TOOLS
$NETWORK_MONITOR
$STATS_PKGS
$QOS_MODERN
$VPN_PKGS
$PBR_PKGS
$HARDWARE_PKGS
$USB_STORAGE
$UPDATES
$LUCI_EXTRAS
"

# Validate .config
[ ! -f .config ] && echo "❌ ERROR: .config not found. Run 'make menuconfig' first." && exit 1

echo "🧹 Cleaning previous configuration..."

# ===== BASE CONFIGURATION =====

# Use standard default-settings (not -chn)
sed -i '/CONFIG_DEFAULT_default-settings/d' .config
echo "CONFIG_DEFAULT_default-settings=y" >> .config

sed -i '/CONFIG_DEFAULT_default-settings-chn/d' .config
echo "# CONFIG_DEFAULT_default-settings-chn is not set" >> .config

# Full LuCI (not light)
sed -i '/CONFIG_PACKAGE_luci-light/d' .config
sed -i '/CONFIG_PACKAGE_luci=/d' .config
echo "CONFIG_PACKAGE_luci=y" >> .config

# English only (no extra languages)
sed -i '/CONFIG_LUCI_LANG_/d' .config
echo "CONFIG_LUCI_LANG_en=y" >> .config

# ===== REMOVE BLOAT =====

echo "🗑️  Removing unnecessary packages..."

REMOVE_PKGS="
luci-app-openvpn
openvpn-openssl
openvpn-mbedtls
kmod-tun
sqm-scripts
luci-app-sqm
wpad-basic
wpad-basic-mbedtls
"

for PKG in $REMOVE_PKGS; do
  sed -i "/CONFIG_PACKAGE_${PKG}=/d" .config
  echo "# CONFIG_PACKAGE_${PKG} is not set" >> .config
done

# ===== MT7988 OPTIMIZATIONS =====

echo "⚡ Configuring MT7988 optimizations..."

# Flow offloading (incompatible with classic SQM, compatible with qosify)
sed -i '/CONFIG_PACKAGE_kmod-nf-flow/d' .config
sed -i '/CONFIG_PACKAGE_kmod-nft-offload/d' .config
echo "CONFIG_PACKAGE_kmod-nf-flow=y" >> .config
echo "CONFIG_PACKAGE_kmod-nft-offload=y" >> .config

# WiFi 7 - wpad-openssl (better than basic)
sed -i '/CONFIG_PACKAGE_wpad-/d' .config
echo "CONFIG_PACKAGE_wpad-openssl=y" >> .config
echo "# CONFIG_PACKAGE_wpad-basic is not set" >> .config
echo "# CONFIG_PACKAGE_wpad-basic-mbedtls is not set" >> .config

# ===== ADD PACKAGES =====

echo "📦 Adding optimized packages..."

for PKG in $EXTRA_PKGS; do
  # Skip empty lines
  [ -z "$PKG" ] && continue
  
  sed -i "/CONFIG_PACKAGE_${PKG}=/d" .config
  echo "CONFIG_PACKAGE_${PKG}=y" >> .config
done

# ===== KERNEL OPTIONS =====

echo "🔧 Configuring kernel..."

# BBR TCP congestion control
sed -i '/CONFIG_TCP_CONG_BBR/d' .config
echo "CONFIG_TCP_CONG_BBR=y" >> .config

# BBR as default
sed -i '/CONFIG_DEFAULT_TCP_CONG/d' .config
echo 'CONFIG_DEFAULT_TCP_CONG="bbr"' >> .config

# ===== BUILD =====

echo "✅ Normalizing configuration..."
make defconfig

echo ""
echo "============================================="
echo "✅ Configuration completed successfully"
echo "============================================="
echo ""
echo "📋 Main features:"
echo "   • qosify (modern, flow offload compatible)"
echo "   • WireGuard VPN (no OpenVPN)"
echo "   • BBR TCP congestion control"
echo "   • Flow offloading enabled"
echo "   • WiFi 7 wpad-openssl"
echo "   • No Chinese packages (default-settings-chn)"
echo "   • Complete monitoring tools"
echo ""
echo "🚀 Build with:"
echo "   make download -j\$(nproc)"
echo "   make -j\$(nproc) V=s"
echo ""
echo "⚠️  NOTE: qosify + flow offload > classic SQM"
echo "   qosify allows QoS with hardware offload active"
echo ""
