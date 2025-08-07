# Raspberry Pi 3B Emulation on macOS
This guide helps you to "How to emulate Raspberry 3B on macOS"

# Requirements
 - homebrew
 - qemu
 - some boot files (kernel and dtb) for qemu
 - raspberry image

Install **homebrew** with following command-line

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
and then install  **qemu**

    brew install qemu
    
we're gonna need some linux utils. 

    brew install util-linux

## Prepare required Kernel and DTB files
qemu needs Raspberry Pi 3B kernel and device tree files. You can download that files from this repo

 - [kernel8.img](https://github.com/mesutschwarz/raspberry-emulation/raw/main/kernel8.img)
 - [bcm2710-rpi-3-b-plus.dtb](https://github.com/mesutschwarz/raspberry-emulation/raw/main/bcm2710-rpi-3-b-plus.dtb)
 
or extract from RPi image. In this case we're gonna use  
 - **Raspberry Pi OS Lite**
 -  Release date:  May 13th 2025
 -  System:  64-bit
 -  Kernel version:  6.12
 -  Debian version:  12 (bookworm)
 -  Size:  433MB

download this image https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2025-05-13/2025-05-13-raspios-bookworm-armhf-lite.img.xz
and extract it (or just double click `2025-05-13-raspios-bookworm-armhf-lite.img.xz` file icon)

    xz -d ./2025-05-13-raspios-bookworm-armhf-lite.img.xz 
    
mount extracted image file (or just double click `2023-12-11-raspios-bookworm-arm64-lite.img` file icon)

    hdiutil mount ./2025-05-13-raspios-bookworm-armhf-lite.img.xz
    
Please note image /dev/diskX, it will be used in next steps.

`bootfs` is mounted to your Desktop (or `/Volumes/bootfs` folder) copy required files from bootfs

    cp /Volumes/bootfs/kernel8.img ./
    cp /Volumes/bootfs/bcm2710-rpi-3-b-plus.dtb ./

Unmount RaspiOS image

    hdiutil detach /dev/diskX 

### Resize image file

Before resize, you should eject/unmount bootfs image.

    qemu-img resize -f raw ./2025-05-13-raspios-bookworm-armhf-lite.img.xz 8G


## Start qemu

Now we're ready to launch qemu with following command or using [launch.sh](https://github.com/mesutschwarz/raspberry-emulation/raw/main/launch.sh) file (Don't forget `chmod +x ./launch.sh` before run)

qemu-system-aarch64 \
  -M raspi3b \
  -cpu cortex-a72 \
  -m 1G \
  -smp 4 \
  -kernel ./kernel8.img \
  -dtb ./bcm2710-rpi-3-b-plus.dtb \
  -append "rw earlyprintk dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootdelay=1" \
  -drive file=./2025-05-13-raspios-bookworm-armhf-lite.img,format=raw,if=sd \
  -serial stdio \
  -usb \
  -device usb-mouse \
  -device usb-kbd \
  -device usb-net,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp::5555-:22


If you enable SSH in `raspi-config` you can connect your RPi image via ssh

    ssh pi_username@localhost -p5555
