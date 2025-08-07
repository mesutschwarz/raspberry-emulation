#!/bin/bash


#is brew installed? if not, install it
command -v brew >/dev/null 2>&1 || { echo >&2 "Installing Homebrew Now"; /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; }

# install required  tools 
brew update
brew install qemu
brew install util-linux

wget https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2025-05-13/2025-05-13-raspios-bookworm-armhf-lite.img.xz

xz -d ./2025-05-13-raspios-bookworm-armhf-lite.img.xz

hdiutil mount 2025-05-13-raspios-bookworm-armhf-lite.img

echo "Please note the 'dev/diskX' device name of the mounted image, you will need it to unmount the image later. Enter to continue"
read -r

cp /Volumes/bootfs/kernel8.img ./    
cp /Volumes/bootfs/bcm2710-rpi-3-b-plus.dtb ./

hdiutil detach /dev/disk4

qemu-img resize -f raw 2025-05-13-raspios-bookworm-armhf-lite.img 8G  

#qemu run command will be in launch.sh