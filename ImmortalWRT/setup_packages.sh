#!/bin/bash
set -e

echo "===> OpenWrt/ImmortalWrt BPI-R4 package setup"

# -------------------------------
# 1. Package groups (readable)
# -------------------------------
CORE_PKGS="
autocore
base-files
block-mount
bridger
ca-bundle
dnsmasq-full
dropbear
firewall4
fitblk
fstools
libc
libgcc
logd
mtd
netifd
nftables
opkg
procd-ujail
uci
uclient-fetch
urandom-seed
urngd
"

KERNEL_MODS="
kmod-crypto-hw-safexcel
kmod-gpio-button-hotplug
kmod-leds-gpio
kmod-nf-nathelper
kmod-nf-nathelper-extra
kmod-nft-offload
kmod-phy-aquantia
kmod-hwmon-pwmfan
kmod-i2c-mux-pca954x
kmod-eeprom-at24
kmod-mt7996-firmware
kmod-mt7996-233-firmware
kmod-rtc-pcf8563
kmod-sfp
kmod-usb3
mt7988-wo-firmware
"

NETWORK_PKGS="
odhcp6c
odhcpd-ipv6only
ppp
ppp-mod-pppoe
wpad-openssl
iperf3
ethtool-full
libustream-openssl
"

LUCI_PKGS="
luci-app-package-manager
luci-lib-base
luci-lib-ipkg
luci
luci-ssl
luci-app-ttyd
luci-app-statistics
collectd-mod-thermal
luci-proto-wireguard
wireguard-tools
"

TOOLS_PKGS="
btop
uboot-envtools
e2fsprogs
f2fsck
mkf2fs
"

ROUTING_PKGS="
pbr
luci-app-pbr
"

# Merge all groups into a single list
PACKAGES="
$CORE_PKGS
$KERNEL_MODS
$NETWORK_PKGS
$LUCI_PKGS
$TOOLS_PKGS
$ROUTING_PKGS
"

# -------------------------------
# 2. Sanity checks
# -------------------------------
if [ ! -f .config ]; then
  echo "ERROR: .config not found."
  echo "Run 'make menuconfig' first and select the Banana Pi BPI-R4 target."
  exit 1
fi

# -------------------------------
# 3. Apply package selection
# -------------------------------
echo "===> [1/3] Removing previous CONFIG_PACKAGE_ entries"
sed -i '/^CONFIG_PACKAGE_/d' .config

echo "===> [2/3] Injecting requested packages"
for PKG in $PACKAGES; do
  [ -n "$PKG" ] || continue
  echo "CONFIG_PACKAGE_${PKG}=y" >> .config
done

echo "===> [3/3] Cleaning up unwanted defaults"
# Explicitly disable ImmortalWrt CN defaults if present
echo "CONFIG_PACKAGE_default-settings-chn=n" >> .config
echo "CONFIG_LUCI_LANG_zh_Hans=n" >> .config
# Keep LuCI in English only
echo "CONFIG_LUCI_LANG_en=y" >> .config

echo "===> Running 'make defconfig' to resolve dependencies"
make defconfig

echo "✅ setup_build.sh finished."
echo "Next steps:"
echo "  make download"
echo "  make -j\$(nproc) V=s"
