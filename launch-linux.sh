#!/bin/bash

# Check for extracted Raspberry Pi OS Lite image
IMG_RAW=$(ls -1 *.img 2>/dev/null | grep 'raspios-bookworm-armhf-lite.img' | head -1)
if [ -z "$IMG_RAW" ]; then
  echo "No Raspberry Pi OS Lite image found in the current directory. Please run install-linux.sh first."
  exit 1
fi

# Check for kernel and dtb files
if [ ! -f "kernel8.img" ] || [ ! -f "bcm2710-rpi-3-b-plus.dtb" ]; then
  echo "Missing kernel8.img or bcm2710-rpi-3-b-plus.dtb. Please run install-linux.sh first."
  exit 1
fi

echo "Launching QEMU Raspberry Pi 3B emulation..."

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