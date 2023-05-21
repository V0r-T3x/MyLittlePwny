#!/usr/bin/env bash
#######################################################################
#########  Download and install Buster Current 5.1y####################
#https://xogium.performanceservers.nl/archive/nanopiduo2/archive/Armbian_21.02.3_Nanopiduo2_buster_current_5.10.21.img.xz
#######################################################################
###########NanoPi Duo2 512mb install notes #####################
#######################################################################
#########These instructions should work on most armbian boards#########
#########Look in https://armbian.hosthatch.com/archive/ for list#######
#######################################################################

#########Increase swap size (on boards with less than 1gb ram)to speed shit up and not crash later during mpi4py install

dd if=/dev/zero of=/swapfile1 bs=1024 count=1048000
chown root:root /swapfile1
chmod 0600 /swapfile1
mkswap /swapfile1
swapon /swapfile1

#nano /etc/fstab
##### add following line to end of fstab
#/swapfile1 none swap sw 0 0

echo '/swapfile1 none swap sw 0 0' >> /etc/fstab

#apt update && apt upgrade
sudo apt-get update && sudo apt-get upgrade -y

###### script to install all the other deps
##!/usr/bin/env bash

# Orange Pi Zero Bionic dependencies
cat > /tmp/dependencies << EOF
rsync
vim
wget
screen
git
cmake
clang
build-essential
dkms
unzip
gawk
libopenmpi-dev
libelf-dev
libopenjp2-7
libtiff5
tcpdump
lsof
libgstreamer1.0-0
libavcodec58
libavformat58
libswscale5
libopenmpi3
libdbus-1-dev 
libdbus-glib-1-dev
bc
libncursesw5-dev 
libssl-dev 
libsqlite3-dev 
libgdbm-dev 
libc6-dev 
libbz2-dev 
libffi-dev 
zlib1g-dev
liblzma-dev
lzma
g++
libjpeg62
libgtk-3-0
libilmbase-dev 
libopenexr-dev 
libgstreamer1.0-dev 
libavcodec-dev 
libavformat-dev 
libswscale-dev
tk-dev 
cython
iw
gfortran
libatlas-base-dev 
liblapack-dev
libopenblas-dev 
libblas-dev
libpcap0.8-dev
libusb-1.0-0-dev
libnetfilter-queue-dev
libhdf5-dev 
armbian-firmware-full
#python3.7
#python3-distutils 
#python3-dev
#python3-pip
EOF

sudo apt -q update
for pkg in $(cat /tmp/dependencies)
do
  sudo apt install -y $pkg
done

#################################
###################Install Python3.7
wget https://www.python.org/ftp/python/3.7.15/Python-3.7.15.tgz
mv Python-3.7.15.tgz /opt/
cd /opt/
tar xvf Python-3.7.15.tgz
cd Python-3.7.15
./configure --enable-optimizations --enable-shared
##### set make going and go to bed, 7.5 hours is normal
make -j 4
make altinstall
ldconfig /opt/Python3.7.15/

#################################
# 1. bettercap

####### install late version of go to try and fix go crash as best as possible using latest go and bettercap
wget https://go.dev/dl/go1.20.2.linux-armv6l.tar.gz
sudo rm -r /usr/local/go
sudo rm -r /usr/local/bin/go
sudo rm -r /usr/bin/go
sudo tar -C /usr/local -xzf go1.20.2.linux-armv6l.tar.gz
export PATH=$PATH:/usr/local/go/bin/
source .bashrc
# Add export PATH=$PATH:/usr/local/go/bin to /etc/profile
# nano /etc/profile
#####2.29?
wget https://github.com/bettercap/bettercap/archive/refs/tags/v2.32.0.zip
unzip v2.32.0.zip
cd better*
make build
mv bettercap /usr/bin/

## install the caplets and the web ui in /usr/local/share/bettercap and quit
sudo bettercap -eval "caplets.update; ui.update; quit"

## Modifying the http-ui.cap file
sed -i 's/set api.rest.username user/set api.rest.username pwnagotchi/' /usr/local/share/bettercap/caplets/http-ui.cap
sed -i 's/set api.rest.password pass/set api.rest.password pwnagotchi/' /usr/local/share/bettercap/caplets/http-ui.cap

## create system services
sudo bash -c 'cat > /usr/bin/bettercap-launcher' << EOF
#!/usr/bin/env bash
/usr/bin/monstart
  # if override file exists, go into auto mode
  if [ -f /root/.pwnagotchi-auto ]; then
    /usr/bin/bettercap -no-colors -caplet pwnagotchi-auto -iface mon0
  else
    /usr/bin/bettercap -no-colors -caplet pwnagotchi-manual -iface mon0
  fi
else
  /usr/bin/bettercap -no-colors -caplet pwnagotchi-auto -iface mon0
fi
EOF

chmod u+x /usr/bin/bettercap-launcher

sudo bash -c 'cat > /etc/systemd/system/bettercap.service' << EOF
[Unit]
Description=bettercap api.rest service.
Documentation=https://bettercap.org
Wants=network.target
#After=pwngrid.service

[Service]
Type=simple
PermissionsStartOnly=true
ExecStart=/usr/bin/bettercap-launcher
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

################################
# 2. pwngrid

# method to create pwngrid-peer.service

sudo bash -c 'cat > /etc/systemd/system/pwngrid-peer.service' << EOF
[Unit]
Description=pwngrid peer service.
Documentation=https://pwnagotchi.ai
Wants=network.target

[Service]
Type=simple
PermissionsStartOnly=true
ExecStart=/usr/bin/pwngrid -keys /etc/pwnagotchi -address 127.0.0.1:8666 -client-token /root/.api-enrollment.json -wait -log /var/log/pwngrid-peer.log -iface mon0
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

##########################################
## download and uncompress code
wget "https://github.com/evilsocket/pwngrid/releases/download/v1.10.3/pwngrid_linux_armhf_v1.10.3.zip"
unzip pwngrid_linux_armhf_v1.10.3.zip

## move binary to bin folder
mv pwngrid /usr/bin/

## generate the keypair
pwngrid -generate -keys /etc/pwnagotchi

#########################################
