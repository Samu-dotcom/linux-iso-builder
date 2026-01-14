#!/bin/bash
echo "🚀 Setup ambiente ISO Builder..."

apt update && apt upgrade -y

apt install -y \
    squashfs-tools \
    genisoimage \
    xorriso \
    isolinux \
    syslinux-utils \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    git curl wget rsync

chmod +x /workspaces/linux-iso-builder/*.sh

echo ""
echo "✅ Ambiente pronto!"
echo "📋 Esegui: ./build-iso.sh"
