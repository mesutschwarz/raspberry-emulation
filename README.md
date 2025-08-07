# Raspberry Pi 3B Emulation on macOS & Linux

This repository provides an automated way to emulate a Raspberry Pi 3B environment on your macOS or Linux computer using QEMU. It downloads the latest Raspberry Pi OS Lite image, extracts necessary boot files, and sets up a virtual SD card image for emulation.

## Features
- Fully automated setup and launch scripts for macOS and Linux
- Always fetches the latest official Raspberry Pi OS Lite image
- Allows custom SD card image sizes (8G, 16G, 32G, 64G, 128G, 256G)
- Extracts and prepares kernel and device tree files automatically
- SSH access to the emulated Pi (if enabled in the guest OS)
- Emulates USB keyboard, mouse, and network

## How It Works
The setup script (`install-mac.sh` or `install-linux.sh`) downloads and prepares everything you need for emulation. The launch script (`launch-mac.sh` or `launch-linux.sh`) starts the virtual Raspberry Pi 3B using QEMU.

## Quick Start

### 1. Clone the repository
```sh
git clone https://github.com/mesutschwarz/raspberry-emulation.git
cd raspberry-emulation
```

### 2. Make scripts executable
```sh
chmod +x install-mac.sh launch-mac.sh install-linux.sh launch-linux.sh
```

### 3. macOS Setup
- Run the install script:
    ```sh
    ./install-mac.sh [IMAGE_SIZE]
    ```
    - `IMAGE_SIZE` is optional. Allowed values: `8G`, `16G`, `32G`, `64G`, `128G`, `256G`. Default is `8G`.
    - The script will check for Homebrew, QEMU, and util-linux (and install if missing).
    - It will download, extract, mount, copy boot files, and resize the SD card image.

- Launch the emulation:
    ```sh
    ./launch-mac.sh
    ```

### 4. Linux Setup
- **Requirements:**
    - QEMU (`qemu-system-aarch64`, `qemu-img`)
    - util-linux (`losetup`, `mount`)
    - wget, xz
    - Install via your package manager, e.g.:
        ```sh
        sudo apt update
        sudo apt install qemu qemu-utils util-linux wget xz-utils
        ```

- Run the install script:
    ```sh
    ./install-linux.sh [IMAGE_SIZE]
    ```
    - `IMAGE_SIZE` is optional. Allowed values: `8G`, `16G`, `32G`, `64G`, `128G`, `256G`. Default is `8G`.
    - The script will check for required tools and warn if missing (does not install automatically).
    - It will download, extract, mount, copy boot files, and resize the SD card image.

- Launch the emulation:
    ```sh
    ./launch-linux.sh
    ```

## Virtual Machine Details
- **Emulated Hardware:** Raspberry Pi 3B (ARM Cortex-A72, 1GB RAM, 4 cores)
- **Boot Files:** Uses official kernel and device tree from the downloaded image
- **Peripherals:** USB keyboard, mouse, and network are emulated
- **Networking:** SSH port forwarding enabled (host port 5555 → guest port 22)

## Raspberry Pi 3B vs. QEMU VM
- The emulation closely matches the real Pi 3B hardware, but performance may differ.
- Some hardware features (e.g., GPIO, camera, WiFi) are not emulated.
- Most standard Linux software for ARM will run as expected.

## Advanced Usage
- **Custom Image Size:**  
  Run `./install-mac.sh 32G` or `./install-linux.sh 32G` to create a 32GB SD card image.
- **Re-running Setup:**  
  If you want to update or overwrite the image, simply rerun the install script. The script will prompt before overwriting any existing files.
- **SSH Access:**  
  Enable SSH in the guest OS (`raspi-config`), then connect from your host:
    ```sh
    ssh pi@localhost -p 5555
    ```
- **Troubleshooting:**  
  - If QEMU fails to launch, ensure all required files are present and dependencies are installed.
  - If you want to use a different Raspberry Pi OS image, update the script or manually place the image in the directory.

## Credits
- Kernel and device tree files are extracted from official Raspberry Pi OS images.
- QEMU is used for ARM emulation.

## License
MIT License
