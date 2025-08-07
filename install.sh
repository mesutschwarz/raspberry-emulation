#!/bin/bash

# Acceptable image sizes
VALID_SIZES=(8G 16G 32G 64G 128G 256G)
IMG_SIZE="${1:-8G}"

# Validate image size
if [[ ! " ${VALID_SIZES[@]} " =~ " ${IMG_SIZE} " ]]; then
  echo "Error: Invalid image size '$IMG_SIZE'. Allowed values: ${VALID_SIZES[*]}"
  exit 1
fi

echo "Image size will be set to: $IMG_SIZE"

# Homebrew check...
echo "Checking for Homebrew..."
command -v brew >/dev/null 2>&1 || { echo >&2 "Homebrew not found. Installing Homebrew..."; /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; }

echo "Updating Homebrew..."
brew update

echo "Checking for qemu..."
if ! brew list qemu &>/dev/null; then
  echo "qemu not found. Installing qemu..."
  brew install qemu
else
  echo "qemu is already installed."
fi

echo "Checking for util-linux..."
if ! brew list util-linux &>/dev/null; then
  echo "util-linux not found. Installing util-linux..."
  brew install util-linux
else
  echo "util-linux is already installed."
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

echo "Mounting image: $IMG_RAW ..."
MOUNT_OUTPUT=$(hdiutil mount "$IMG_RAW")
DEVICE_NAME=$(echo "$MOUNT_OUTPUT" | grep -Eo '/dev/disk[0-9]+' | head -1)

echo "Image mounted on device: $DEVICE_NAME"
BOOTFS_PATH=$(echo "$MOUNT_OUTPUT" | grep 'bootfs' | awk '{print $3}')
if [ -z "$BOOTFS_PATH" ]; then
  BOOTFS_PATH="/Volumes/bootfs"
fi

echo "Copying kernel and dtb files from $BOOTFS_PATH ..."
cp "$BOOTFS_PATH/kernel8.img" ./
cp "$BOOTFS_PATH/bcm2710-rpi-3-b-plus.dtb" ./

echo "Detaching image device: $DEVICE_NAME ..."
hdiutil detach "$DEVICE_NAME"

echo "Resizing image to $IMG_SIZE ..."
qemu-img resize -f raw "$IMG_RAW" "$IMG_SIZE"

echo "Setup complete. Use launch.sh to start emulation."
#qemu run command will be in launch.sh