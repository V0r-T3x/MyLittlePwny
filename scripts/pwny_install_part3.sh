### Install requirements.txt followed by the Pwnagotchi
cd Pwnagotchi-For-Banana-Orange-Pi/
TMPDIR=/root/tmp python3.7 -m pip install -r requirements.txt
TMPDIR=/root/tmp python3.7 -m pip install .

## Fix permissions errors

sudo chmod 755 /usr/bin/bettercap
sudo chown root:root /usr/bin/bettercap
sudo chmod 755 /usr/bin/bettercap-launcher
sudo chmod 755 /usr/bin/pwngrid
sudo chown root:root /usr/bin/pwngrid
sudo chmod 755 /usr/local/bin/pwnagotchi
sudo chown root:root /usr/local/bin/pwnagotchi
sudo chmod 711 /usr/bin/pwnagotchi-launcher
sudo chmod +x /usr/bin/monstart
sudo chmod +x /usr/bin/monstop
sudo chmod +x /etc/systemd/system/pwnagotchi.service
sudo chmod +x /etc/systemd/system/pwngrid-peer.service

# Download aluminum-ice pwnlib
cd /root/
wget https://raw.githubusercontent.com/aluminum-ice/pwnagotchi/master/builder/data/usr/bin/pwnlib

# Copy pwnlib
sudo mv /usr/bin/pwnlib /usr/bin/pwnlib.bak
sudo cp /root/pwnlib /usr/bin/pwnlib

############ edit pwnlib and change interface mon0 command to below
############ wlanxxxxxx should be the name of the external wifi device in iwconfig eg wlx00ee11ff00cc 
#wlxe84e065ce1f5
#iwconfig
#iw phy `iw dev wlxe84e065ce1f5 info | gawk '/wiphy/ {printf "phy" $2}'` interface add mon1 type monitor
##### copy iface name and change wlanxxxxxx to that device name and change command in /usr/bin/pwnlib
#iw phy `iw dev wlanxxxxxx info | gawk '/wiphy/ {printf "phy" $2}'` interface add mon0 type monitor

sudo systemctl enable bettercap pwngrid-peer pwnagotchi
