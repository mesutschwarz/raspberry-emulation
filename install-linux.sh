#!/bin/bash

# Optional image size argument (default: 8G)
VALID_SIZES=(8G 16G 32G 64G 128G 256G)
IMG_SIZE="${1:-8G}"

# Validate image size
if [[ ! " ${VALID_SIZES[@]} " =~ " ${IMG_SIZE} " ]]; then
  echo "Error: Invalid image size '$IMG_SIZE'. Allowed values: ${VALID_SIZES[*]}"
  exit 1
fi

echo "Image size will be set to: $IMG_SIZE"

echo "Checking for qemu..."
if ! command -v qemu-img &>/dev/null; then
  echo "Warning: qemu-img not found. Please install QEMU before running this script."
fi

echo "Checking for util-linux (losetup, mount)..."
if ! command -v losetup &>/dev/null || ! command -v mount &>/dev/null; then
  echo "Warning: util-linux tools (losetup, mount) not found. Please install util-linux before running this script."
fi

# Get latest Raspberry Pi OS Lite image URL using redirect
echo "Fetching latest Raspberry Pi OS Lite image URL..."
LATEST_URL=$(wget -O /dev/null -o - --max-redirect=0 https://downloads.raspberrypi.org/raspios_lite_armhf_latest 2>/dev/null | sed -n "s/^Location: \(.*\) \[following\]$/\1/p")

echo "Latest image URL: $LATEST_URL"
IMG_NAME=$(basename "$LATEST_URL")
IMG_RAW="${IMG_NAME%.xz}"

# Check for existing .xz file
echo "Checking for existing image archive: $IMG_NAME ..."
if [ -f "$IMG_NAME" ]; then
  read -p "$IMG_NAME already exists. Overwrite? (y/N): " OVERWRITE_XZ
  if [[ ! "$OVERWRITE_XZ" =~ ^[Yy]$ ]]; then
    echo "Skipping download."
  else
    echo "Downloading image: $IMG_NAME ..."
    wget -O "$IMG_NAME" "$LATEST_URL"
  fi
else
  echo "Downloading image: $IMG_NAME ..."
  wget -O "$IMG_NAME" "$LATEST_URL"
fi

# Check for existing .img file
echo "Checking for existing extracted image: $IMG_RAW ..."
if [ -f "$IMG_RAW" ]; then
  read -p "$IMG_RAW already exists. Overwrite? (y/N): " OVERWRITE_IMG
  if [[ ! "$OVERWRITE_IMG" =~ ^[Yy]$ ]]; then
    echo "Skipping extraction."
  else
    echo "Extracting image: $IMG_NAME ..."
    xz -f -d "$IMG_NAME"
  fi
else
  echo "Extracting image: $IMG_NAME ..."
  xz -d "$IMG_NAME"
fi

echo "Setting up loop device for image: $IMG_RAW ..."
LOOPDEV=$(sudo losetup --show -fP "$IMG_RAW")
if [ -z "$LOOPDEV" ]; then
  echo "Failed to set up loop device. Exiting."
  exit 1
fi

echo "Loop device: $LOOPDEV"

# Find boot partition (usually first partition)
BOOTPART="${LOOPDEV}p1"
if [ ! -e "$BOOTPART" ]; then
  BOOTPART="${LOOPDEV}p1"
  if [ ! -e "$BOOTPART" ]; then
    BOOTPART="${LOOPDEV}"
  fi
fi

MOUNTDIR="/mnt/raspi-bootfs"
sudo mkdir -p "$MOUNTDIR"
echo "Mounting boot partition: $BOOTPART to $MOUNTDIR ..."
sudo mount "$BOOTPART" "$MOUNTDIR"

if [ ! -f "$MOUNTDIR/kernel8.img" ] || [ ! -f "$MOUNTDIR/bcm2710-rpi-3-b-plus.dtb" ]; then
  echo "Warning: kernel8.img or bcm2710-rpi-3-b-plus.dtb not found in boot partition."
fi

echo "Copying kernel and dtb files from $MOUNTDIR ..."
sudo cp "$MOUNTDIR/kernel8.img" ./
sudo cp "$MOUNTDIR/bcm2710-rpi-3-b-plus.dtb" ./

echo "Unmounting boot partition..."
sudo umount "$MOUNTDIR"
sudo losetup -d "$LOOPDEV"
sudo rmdir "$MOUNTDIR"

echo "Resizing image to $IMG_SIZE ..."
qemu-img resize -f raw "$IMG_RAW" "$IMG_SIZE"

echo "Setup complete. Use launch.sh to start emulation."
#qemu run command will be in launch.sh
