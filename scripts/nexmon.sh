#!/bin/bash
# Install script for nexmon on armbian for NanoPi Duo2
# Adjusted from the WPA2 nexmon install script for rpi0w

# Update and upgrade system
sudo apt-get update && sudo apt-get upgrade -y

# Install necessary packages
#sudo apt-get install -y raspberrypi-kernel-headers git libgmp3-dev gawk qpdf bison flex make autoconf libtool texinfo
#sudo apt-get install -y git libgmp3-dev gawk qpdf bison flex make autoconf libtool texinfo
sudo apt-get install -y git libgmp3-dev gawk qpdf bison flex make autoconf libtool texinfo gcc-arm-none-eabi wl libfl-dev g++ xxd libisl-dev libmpfr-dev

# Clone nexmon repository
#git clone https://github.com/seemoo-lab/nexmon.git
git clone https://github.com/DrSchottky/nexmon.git

# Build and install isl
#cd nexmon/buildtools/isl-0.10
#./configure
#make
#sudo make install

# Create symlink for libisl (*https://codeby.net/threads/nexmon-nexmonsdr-na-raspberry-pi-3-model-b-pi-0-w.75585/*)
#sudo ln -s /usr/local/lib/libisl.so /usr/lib/arm-linux-gnueabihf/libisl.so.10
#sudo ln -s /usr/lib/arm-linux-gnueabihf/libisl.so /usr/lib/arm-linux-gnueabihf/libisl.so.10

# Build and install mpfr
#cd /home/pi/nexmon/buildtools/mpfr-3.1.4
#autoreconf -f -i
#./configure
#make
#sudo make install

# Create symlink for libmpfr
#sudo ln -s /usr/local/lib/libmpfr.so /usr/lib/arm-linux-gnueabihf/libmpfr.so.4
#sudo ln -s usr/lib/arm-linux-gnueabihf/libmpfr.so /usr/lib/arm-linux-gnueabihf/libmpfr.so.4

# Remove -DDEBUG from your brcmfmac's Makefile
sed -i '/-DDEBUG/ s/^/#/' /root/nexmon/patches/driver/brcmfmac_5.15.y-nexmon/Makefile

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

# Backup original brcmfmac.ko
#sudo mv /usr/lib/modules/5.10.103+/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko /usr/lib/modules/5.10.103+/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko.bak
sudo mv /usr/lib/modules/5.15.93-sunxi/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko.xz /usr/lib/modules/5.15.93-sunxi/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko.bak

# Copy nexmon patched brcmfmac.ko
#sudo cp /home/pi/nexmon/patches/driver/brcmfmac_5.10.y-nexmon/brcmfmac.ko /usr/lib/modules/5.10.103+/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko
sudo cp /root/nexmon/patches/driver/brcmfmac_5.15.y-nexmon/brcmfmac.ko /usr/lib/modules/5.15.93-sunxi/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko

# Update module dependencies
sudo depmod -a

# Setup a new monitor mode interface (thanks to Mame82)
iw phy `iw dev wlan0 info | gawk '/wiphy/ {printf "phy" $2}'` interface add mon0 type monitor

# To activate monitor mode:
# ifconfig wlan0 down && ifconfig mon0 up
# ifconfig mon0 down && ifconfig wlan0 up

# Exit from root
exit
