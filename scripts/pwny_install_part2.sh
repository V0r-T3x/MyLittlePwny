#!/usr/bin/env bash
#########################################
# 3. pwnagotchi

## download and uncompress code
git clone https://github.com/Fikolmij/Pwnagotchi-For-Banana-Orange-Pi

## Update some Python3.7 modules
mkdir /root/tmp
TMPDIR=/root/tmp python3.7 -m pip install --upgrade pip wheel
## install setuptools 65.5.0
TMPDIR=/root/tmp python3.7 -m pip install setuptools==65.5.0


#### download the wheel zip https://drive.google.com/file/d/1pIzS08gm0zUG6-xC5kMb-br_i8Ig6OeV/view?usp=share_link
#### upload to pwny and unzip

sudo wget 'https://drive.google.com/u/0/uc?id=1pIzS08gm0zUG6-xC5kMb-br_i8Ig6OeV&export=download&confirm=t&uuid=cc698975-e61f-48a5-ac71-b55dffeb0780&at=AKKF8vxH3fwRKw9INFNc_X6FXFzA:1683847982317' -O Pwny-WHLs_armv7l_V3.zip

unzip Pwny-WHLs_armv7l_V3.zip
cd Pwny-WHLs\ armv7l/

###### install in this order numpy, opencv, pandas, grpcio, tensorflow, *.whl

TMPDIR=/root/tmp python3.7 -m pip install numpy-1.20.2-cp37-cp37m-linux_armv7l.whl 
TMPDIR=/root/tmp python3.7 -m pip install opencv_python-4.3.0.38-cp37-cp37m-linux_armv7l.whl
TMPDIR=/root/tmp python3.7 -m pip install pandas-1.3.5-cp37-cp37m-linux_armv7l.whl
#TMPDIR=/root/tmp python3.7 -m pip install grpcio-1.53.0-cp37-cp37m-linux_armv7l.whl
TMPDIR=/root/tmp python3.7 -m pip install grpcio-1.51.3-cp37-cp37m-linux_armv7l.whl

#### Tensorflow takes a while to compile h5py and using wheel file results in error (grab a coffee)
TMPDIR=/root/tmp python3.7 -m pip install tensorflow-1.13.1-cp37-none-linux_armv7l.whl

#### remove installed wheels to install the rest in one hit
rm numpy*
rm opencv*
rm pandas*
rm grpcio*
rm tensor*

#### Install the rest of the wheels kiwisolver, atari-py and future can take a while...
TMPDIR=/root/tmp python3.7 -m pip install *.whl

#### Install some other dependencies/correct the version
TMPDIR=/root/tmp python3.7 -m pip install jinja2==3.0.1
TMPDIR=/root/tmp python3.7 -m pip install itsdangerous==2.0.1
TMPDIR=/root/tmp python3.7 -m pip install Werkzeug==2.0.0
# and complete the installation by rebooting
reboot now
