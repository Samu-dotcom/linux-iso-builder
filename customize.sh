#!/bin/bash
echo "🎨 Personalizzazione sistema..."

# Aggiorna
export DEBIAN_FRONTEND=noninteractive
apt update
apt upgrade -y

# Software base
apt install -y \
    firefox-esr \
    vlc \
    git curl wget \
    vim nano \
    htop \
    gparted

echo "🍎 Installazione temi macOS..."

# Dipendenze temi
apt install -y git gtk2-engines-murrine sassc

# Tema WhiteSur
cd /tmp
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd WhiteSur-gtk-theme
./install.sh -l -c Dark -t all 2>/dev/null || true

# Icone
cd /tmp
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git
cd WhiteSur-icon-theme
./install.sh -a 2>/dev/null || true

# Plank Dock
apt install -y plank

# Autostart Plank
mkdir -p /etc/skel/.config/autostart
cat > /etc/skel/.config/autostart/plank.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Plank
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# Wallpaper macOS
mkdir -p /usr/share/backgrounds
wget -q -O /usr/share/backgrounds/catalina.jpg \
    https://512pixels.net/downloads/macos-wallpapers/10-15-Catalina-Night.jpg 2>/dev/null || true

# Hostname personalizzato
echo "CustomMacLinux" > /etc/hostname

# MOTD
cat > /etc/motd << 'MOTD'
╔════════════════════════════════════╗
║   Custom Linux - macOS Edition     ║
║   Built with GitHub Codespaces     ║
╚════════════════════════════════════╝
MOTD

# Cleanup
apt autoremove -y
rm -rf /tmp/*

echo "✅ Personalizzazione completata!"
