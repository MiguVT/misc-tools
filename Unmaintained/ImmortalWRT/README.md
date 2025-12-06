> ⚠️ DEPRECATED: I moved to Snapshot OpenWRT (More stability, full open-source)

# ImmortalWrt BPI‑R4 Build

This is how I build a custom ImmortalWrt image for the Banana Pi BPI‑R4 on Arch/CachyOS.

## 1. Clone ImmortalWrt and checkout tag

```bash
cd /mnt/data/TempRepos
git clone https://github.com/immortalwrt/immortalwrt.git ImmortalWRT
cd ImmortalWRT

git fetch --tags
git checkout v24.10.4
```

## 2. Update feeds

```bash
./scripts/feeds update -a
./scripts/feeds install -a
```

## 3. Initial target config

Run menuconfig once to select the board:

```bash
make menuconfig
```

Inside menuconfig:

- Target System: `MediaTek ARM`  
- Subtarget: `Filogic 8x0 (MT798x)`  
- Target Profile: `Banana Pi BPI-R4`  

Save and exit. This creates a base `.config`.

## 4. Apply my package setup (script via curl \| bash)

From the ImmortalWRT repo root:

```bash
curl -fsSL https://raw.githubusercontent.com/MiguVT/misc-tools/refs/heads/main/ImmortalWRT/setup_packages.sh | bash
```

This script:

- Keeps the BPI‑R4 profile  
- Switches `luci-light` → full `luci`  
- Adds tools: `btop`, `iperf3`, `luci-app-statistics`, `collectd-mod-thermal`, `pbr`, `luci-app-pbr`, etc.  
- Disables `default-settings-chn`  
- Sets LuCI to English  
- Runs `make defconfig` to normalize the config  

Optional: run menuconfig again just to look around:

```bash
make menuconfig
```

Exit without changing anything if it looks good.

## 5. Build

```bash
make download
make -j$(nproc) V=s
```

When it finishes, images are in:

```bash
bin/targets/mediatek/filogic/
```

Important files:

- `*-sdcard.img.gz` → SD card image  
- `*-nand-factory.ubi` → NAND factory image (if generated)

***

# Install to SD, NAND and eMMC (BPI‑R4)

Basic flow: boot from SD → install to NAND → from NAND flash eMMC + 8GB BL2.

## 1. Flash SD card

On your PC:

```bash
gunzip openwrt-*-sdcard.img.gz
sudo dd if=openwrt-*-sdcard.img of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with your SD card device.

Set the BPI‑R4 boot switches to **SD**, insert the card, power on, and SSH into the router:

```bash
ssh root@192.168.1.1
```

(default: user `root`, no password)

## 2. Install to NAND

Copy the NAND image to the router:

```bash
scp openwrt-*-nand-factory.ubi root@192.168.1.1:/tmp/
```

SSH into the router (from SD-booted system) and write to NAND (ubi name may differ, adjust if needed):

```bash
ssh root@192.168.1.1
mtd write /tmp/openwrt-*-nand-factory.ubi ubi
poweroff
```

Power off when it finishes.

## 3. Boot from NAND

Set boot switches to **NAND**, remove the SD card (recommended), power on, and SSH again:

```bash
ssh root@192.168.1.1
```

Now you’re running from NAND.

## 4. Install image to eMMC and apply 8GB BL2

While running from NAND, copy the SD image and BL2 file:

```bash
scp openwrt-*-sdcard.img root@192.168.1.1:/tmp/
scp bl2_emmc_8g.img root@192.168.1.1:/tmp/
```

SSH into the router and write the system to eMMC:

```bash
ssh root@192.168.1.1
dd if=/tmp/openwrt-*-sdcard.img of=/dev/mmcblk0 bs=4M status=progress conv=fsync
```

Then unlock and write BL2 to the eMMC boot partition (to enable full 8GB RAM):

```bash
echo 0 > /sys/block/mmcblk0boot0/force_ro
dd if=/tmp/bl2_emmc_8g.img of=/dev/mmcblk0boot0
mmc bootpart enable 1 1 /dev/mmcblk0
poweroff
```

## 5. Boot from eMMC

Set boot switches to **eMMC**, power on, and SSH again:

```bash
ssh root@192.168.1.1
free -h
```

You should see around 7.x GB of RAM available and your custom ImmortalWrt build running from eMMC.
