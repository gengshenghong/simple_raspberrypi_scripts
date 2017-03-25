#!/bin/bash
# This script will convert official Raspberry Pi version arduino IDE (which is .tar.gz) file to .deb package, to make it convenient for installation
# What will the deb done on your raspberry pi?
# 1. install Arduino IDE to /opt/ArduinoIDE
# 2. create shortcut (Linux call it "desktop" file) at "Programming -> Arduino IDE"
# Note: this script itself is tested at Ubuntu 14.04

# how to download offcial .tar.gz file
# wget http://downloads.arduino.cc/arduino-1.8.2-linuxarm.tar.xz

version="1.8.2"
xzPkg="arduino-$version-linuxarm.tar.xz"
tarPkg="arduino-$version-linuxarm.tar"
arduinoFolder="arduino-$version"
debPkg="arduino-$version-linuxarm.deb"

# prepare work dir
rm -rf temp && mkdir temp
cp $xzPkg temp

# extract .tar.xz
cd temp
xz -d $xzPkg
tar xf $tarPkg
rm -rf $tarPkg
cd ..

# copy DEBIAN
cp DEBIAN temp -R
# replace version in DEBIAN/control
sed -i "s/<version>/$version/g" temp/DEBIAN/control
# replace installsize in DEBIAN/control
installsize=$(du -s temp/$arduinoFolder| cut -f 1)
sed -i "s/<installsize>/$installsize/g" temp/DEBIAN/control

# copy install files
mkdir -p temp/opt/ArduinoIDE
mv temp/$arduinoFolder temp/opt/ArduinoIDE/$arduinoFolder

# copy .desktop file
mkdir -p temp/usr/share/applications
cp ArduinoIDE.desktop temp/usr/share/applications/ArduinoIDE.desktop
chmod +x temp/usr/share/applications/ArduinoIDE.desktop
# replace version in .desktop
sed -i "s/<version>/$version/g" temp/usr/share/applications/ArduinoIDE.desktop

# build deb
chmod -R 755 temp/DEBIAN
# http://www.askingbox.com/question/debian-the-package-is-of-bad-quality-wrong-file-owner-uid-or-gid
# need to use fakeroot, or you'll get warning as below during installation: wrong-file-owner-uid-or-gid opt/ 1000/1000
rm -rf $debPkg
fakeroot dpkg-deb --build temp $debPkg

# clean
rm -rf temp
