#!/bin/bash


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
