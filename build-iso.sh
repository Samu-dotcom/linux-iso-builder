#!/bin/bash
set -e

ISO_NAME="MyCustomLinux"
BASE_ISO_URL="https://distro.ibiblio.org/puppylinux/puppy-bookworm/BookwormPup64/10.0.8/BookwormPup64-10.0.8-uefi.iso"
WORK_DIR="/tmp/iso-build"
OUTPUT_DIR="/workspaces/linux-iso-builder/output"

echo "======================================"
echo "  Custom Linux ISO Builder"
echo "======================================"

# Crea directory
mkdir -p "$WORK_DIR"/{iso,squashfs,extract} "$OUTPUT_DIR"

# Download ISO base
if [ ! -f "/tmp/base.iso" ]; then
    echo "[1/7] Download ISO base (400MB)..."
    wget -q --show-progress -O /tmp/base.iso "$BASE_ISO_URL"
fi

# Estrai ISO
echo "[2/7] Estrazione ISO..."
mount -o loop /tmp/base.iso "$WORK_DIR/iso" 2>/dev/null || true
rsync -a "$WORK_DIR/iso/" "$WORK_DIR/extract/"
umount "$WORK_DIR/iso" 2>/dev/null || true

# Trova e estrai filesystem
echo "[3/7] Estrazione filesystem..."
SQUASHFS=$(find "$WORK_DIR/extract" -name "*.sfs" -o -name "filesystem.squashfs" | head -1)
unsquashfs -d "$WORK_DIR/squashfs" "$SQUASHFS"

# Chroot setup
echo "[4/7] Personalizzazione sistema..."
mount --bind /dev "$WORK_DIR/squashfs/dev"
mount --bind /proc "$WORK_DIR/squashfs/proc"
mount --bind /sys "$WORK_DIR/squashfs/sys"

# Copia script customizzazione
cp /workspaces/linux-iso-builder/customize.sh "$WORK_DIR/squashfs/tmp/"
chmod +x "$WORK_DIR/squashfs/tmp/customize.sh"

# Esegui personalizzazioni
chroot "$WORK_DIR/squashfs" /tmp/customize.sh

# Cleanup chroot
chroot "$WORK_DIR/squashfs" bash -c "apt clean && rm -rf /tmp/* /var/tmp/*"

# Umount
umount "$WORK_DIR/squashfs/dev" 2>/dev/null || true
umount "$WORK_DIR/squashfs/proc" 2>/dev/null || true
umount "$WORK_DIR/squashfs/sys" 2>/dev/null || true

# Ricrea squashfs
echo "[5/7] Compressione filesystem..."
rm "$SQUASHFS"
mksquashfs "$WORK_DIR/squashfs" "$WORK_DIR/extract/live/filesystem.squashfs" \
    -comp xz -b 1M

# Aggiorna dimensioni
printf $(du -sx --block-size=1 "$WORK_DIR/squashfs" | cut -f1) > \
    "$WORK_DIR/extract/live/filesystem.size"

# Crea ISO
echo "[6/7] Generazione ISO..."
cd "$WORK_DIR/extract"

genisoimage -rational-rock -volid "$ISO_NAME" \
    -cache-inodes -joliet -full-iso9660-filenames \
    -b isolinux/isolinux.bin -c isolinux/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -output "$OUTPUT_DIR/${ISO_NAME}.iso" .

# Rendi ibrida (bootable su USB)
isohybrid "$OUTPUT_DIR/${ISO_NAME}.iso" 2>/dev/null || true

# Checksum
cd "$OUTPUT_DIR"
sha256sum "${ISO_NAME}.iso" > "${ISO_NAME}.iso.sha256"

echo ""
echo "======================================"
echo "✅ ISO CREATA!"
echo "======================================"
echo "File: output/${ISO_NAME}.iso"
echo "Dimensione: $(du -h "$OUTPUT_DIR/${ISO_NAME}.iso" | cut -f1)"
echo ""
echo "📥 Per scaricare:"
echo "  1. Apri cartella 'output' nella sidebar"
echo "  2. Click destro su ${ISO_NAME}.iso"
echo "  3. Download"
echo "======================================"
