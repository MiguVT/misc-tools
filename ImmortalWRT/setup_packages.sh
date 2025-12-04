#!/bin/bash
set -e

echo "===> BPI-R4 ImmortalWrt Build Setup"

EXTRA_PKGS="
btop
htop
nano
screen
rsync
iftop
luci-app-statistics
collectd-mod-thermal
nlbwmon
luci-app-nlbwmon
iperf3
ethtool-full
tcpdump-mini
nmap
curl
wget-ssl
diffutils
irqbalance
mmc-utils
kmod-fs-f2fs
sqm-scripts
luci-app-sqm
kmod-phy-marvell
wireguard-tools
luci-app-wireguard
luci-proto-wireguard
luci-app-openvpn
openvpn-openssl
luci-ssl-openssl
pbr
luci-app-pbr
luci-app-commands
kmod-usb-storage
kmod-usb-net
usb-modeswitch
"

[ ! -f .config ] && echo "ERROR: .config not found" && exit 1

# Full LuCI
sed -i '/CONFIG_PACKAGE_luci-light/d' .config
sed -i '/CONFIG_PACKAGE_luci=/d' .config
echo "CONFIG_PACKAGE_luci=y" >> .config

# English only
sed -i '/CONFIG_LUCI_LANG_/d' .config
echo "CONFIG_LUCI_LANG_en=y" >> .config

# Add packages
for PKG in $EXTRA_PKGS; do
  sed -i "/CONFIG_PACKAGE_${PKG}=/d" .config
  echo "CONFIG_PACKAGE_${PKG}=y" >> .config
done

# Normalize
make defconfig

echo "✅ Done. Build with:"
echo "   make download -j\$(nproc)"
echo "   make -j\$(nproc) V=s"
