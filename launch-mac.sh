#!/bin/bash

# Check for extracted Raspberry Pi OS Lite image
IMG_RAW=$(ls -1 *.img 2>/dev/null | grep 'raspios-bookworm-armhf-lite.img' | head -1)
if [ -z "$IMG_RAW" ]; then
  echo "No Raspberry Pi OS Lite image found in the current directory. Please run install.sh first."
  exit 1
fi

qemu-system-aarch64 \
  -M raspi3b \
  -cpu cortex-a72 \
  -m 1G \
  -smp 4 \
  -kernel ./kernel8.img \
  -dtb ./bcm2710-rpi-3-b-plus.dtb \
  -append "rw earlyprintk dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootdelay=1" \
  -drive file="./$IMG_RAW",format=raw,if=sd \
  -serial stdio \
  -usb \
  -device usb-mouse \
  -device usb-kbd \
  -device usb-net,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp::5555-:22
