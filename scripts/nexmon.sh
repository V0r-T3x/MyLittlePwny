#!/bin/bash
# Install script for nexmon on armbian for NanoPi Duo2
# Adjusted from the WPA2 nexmon install script for rpi0w

# Update and upgrade system
sudo apt-get update && sudo apt-get upgrade -y

# Install necessary packages
sudo apt-get install -y git libgmp3-dev gawk qpdf bison flex make autoconf libtool texinfo gcc-arm-none-eabi wl libfl-dev g++ xxd libisl-dev libmpfr-dev

# Clone nexmon repository
git clone https://github.com/DrSchottky/nexmon.git

# Comment -DDEBUG from your brcmfmac's Makefile
sed -i '/-DDEBUG/ s/^/#/' /root/nexmon/patches/driver/brcmfmac_5.10.y-nexmon/Makefile
sed -i '/debug.o/ s/^/#/' /root/nexmon/patches/driver/brcmfmac_5.10.y-nexmon/Makefile


# Set up environment
cd nexmon
source setup_env.sh

# Build nexmon
make

# Build nexmon firmware patches
cd patches/bcm43430a1/7_45_41_46/nexmon
make

# Backup firmware
make backup-firmware

# Install patched firmware
make install-firmware

# Build and install nexutil
cd /root/nexmon/utilities/nexutil
make
sudo make install

# Remove wpasupplicant
sudo apt-get remove -y wpasupplicant

# Disable power save mode for wlan0
sudo iw dev wlan0 set power_save off

# Archive the .ko into a .xz file
#sudo xz /root/nexmon/patches/driver/brcmfmac_5.10.y-nexmon/brcmfmac.ko

# Backup original brcmfmac.ko
sudo mv /lib/modules/5.10.21-sunxi/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko /lib/modules/5.10.21-sunxi/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko.bak

# Copy nexmon patched brcmfmac.ko
sudo cp /root/nexmon/patches/driver/brcmfmac_5.10.y-nexmon/brcmfmac.ko /lib/modules/5.10.21-sunxi/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko

# Update module dependencies
sudo depmod -a

# Setup a new monitor mode interface (thanks to Mame82)
#iw phy `iw dev wlan0 info | gawk '/wiphy/ {printf "phy" $2}'` interface add mon0 type monitor

# To activate monitor mode:
# testing patch: tcpdump -i mon0
# ifconfig wlan0 down && ifconfig mon0 up
# ifconfig mon0 down && ifconfig wlan0 up

# Exit from root
exit
