#!/bin/bash
set -e

echo "===> BPI-R4 package KISS setup (based on default profile)"

# Extra packages to ensure are enabled
EXTRA_PKGS="
btop
luci-app-statistics
collectd-mod-thermal
iperf3
ethtool-full
pbr
luci-app-pbr
"

if [ ! -f .config ]; then
  echo "ERROR: .config not found."
  echo "Run 'make menuconfig' first and select the Banana Pi BPI-R4 target/profile."
  exit 1
fi

echo "===> [1/4] Disable CN default settings if present"
# Optional: comment this out if you want to keep them
sed -i '/CONFIG_PACKAGE_default-settings-chn/d' .config
echo "CONFIG_PACKAGE_default-settings-chn=n" >> .config

echo "===> [2/4] Replace luci-light with full luci"
# Remove any existing luci/light flags
sed -i '/CONFIG_PACKAGE_luci-light/d' .config
sed -i '/CONFIG_PACKAGE_luci=/d' .config
# Force full LuCI instead of luci-light
echo "CONFIG_PACKAGE_luci=y" >> .config

echo "===> [3/4] Ensure extra tools and apps are enabled"
for PKG in $EXTRA_PKGS; do
  sed -i "/CONFIG_PACKAGE_${PKG}=/d" .config
  echo "CONFIG_PACKAGE_${PKG}=y" >> .config
done

echo "===> [4/4] Keep LuCI English only"
sed -i '/CONFIG_LUCI_LANG_/d' .config
echo "CONFIG_LUCI_LANG_en=y" >> .config

echo "===> Running 'make defconfig' to normalize config"
make defconfig

echo "✅ Done. Now run:"
echo "   make download"
echo "   make -j\$(nproc) V=s"
