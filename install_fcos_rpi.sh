#!/usr/bin/env bash

# Download the RPM from repo

RELEASE=42 # The target Fedora Release. Use the same one that current FCOS is based on.
mkdir -p /tmp/RPi4boot/boot/efi/
dnf download --resolve --releasever=$RELEASE --forcearch=aarch64 --destdir=/tmp/RPi4boot/ uboot-images-armv8 bcm283x-firmware bcm283x-overlays

# Extract RPM

for rpm in /tmp/RPi4boot/*rpm; do rpm2cpio $rpm | sudo cpio -idv -D /tmp/RPi4boot/; done
sudo mv /tmp/RPi4boot/usr/share/uboot/rpi_arm64/u-boot.bin /tmp/RPi4boot/boot/efi/rpi-u-boot.bin

# Copy files over to RPi ESP (to be done only AFTER coreos-installer command)

FCOSEFIPARTITION=$(lsblk $FCOSDISK -J -oLABEL,PATH  | jq -r '.blockdevices[] | select(.label == "EFI-SYSTEM").path')
mkdir /tmp/FCOSEFIpart
sudo mount $FCOSEFIPARTITION /tmp/FCOSEFIpart
sudo rsync -avh --ignore-existing /tmp/RPi4boot/boot/efi/ /tmp/FCOSEFIpart/
sudo umount $FCOSEFIPARTITION