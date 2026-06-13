#!/bin/bash
# ==============================================================================
# Script Name: termux-arch-desktop-setup.sh
# Description: Automated Arch Linux ARM XFCE Desktop Environment installation
#              tailored for rootless Termux PRoot environments with stop script.
# Author: Majid Javed (Fixed Target Architecture Version)
# ==============================================================================

set -e

echo "[*] Initializing Termux system updates..."
pkg update -y && pkg upgrade -y
pkg install proot-distro pulseaudio -y

echo "[*] Downloading and installing Arch Linux ARM container via targeted registry path..."
# Force installation of the explicit ARM64 build under the unified 'archlinux' name identifier
proot-distro install -n archlinux danhunsaker/archlinuxarm:latest

echo "[*] Generating native local startup environment execution wrapper..."
cat << 'EOF' > ~/desktop.sh
#!/bin/bash
pulseaudio --start --exit-idle-time=-1 2>/dev/null

proot-distro login archlinux --user majid --shared-tmp -- bash -c "
  pkill -9 Xvnc || true
  rm -f /tmp/.X*-lock /tmp/.X11-unix/X* || true
  vncserver :1
"
EOF
chmod +x ~/desktop.sh

echo "[*] Generating native local shutdown environment execution wrapper..."
cat << 'EOF' > ~/stop-desktop.sh
#!/bin/bash
echo "[*] Terminating XFCE4 VNC session..."
proot-distro login archlinux --user majid --shared-tmp -- bash -c "vncserver -kill :1" || true

echo "[*] Killing remaining PulseAudio background services..."
pulseaudio --kill 2>/dev/null || true

echo "[*] Clearing lingering lock files..."
rm -f /tmp/.X*-lock /tmp/.X11-unix/X* 2>/dev/null || true

echo "[*] Desktop services stopped successfully."
EOF
chmod +x ~/stop-desktop.sh

echo "[*] Injecting container settings, package modules, and user permissions..."
proot-distro login archlinux --user root --shared-tmp -- bash -c "
  sed -i '/\[options\]/a DisableSandbox' /etc/pacman.conf
"

proot-distro login archlinux --user root --shared-tmp -- bash -c '
  # Initialize package validation keys (Using standard archlinux keyring)
  pacman-key --init && pacman-key --populate archlinux || true
  
  # Install Desktop Environment, VNC Server, and administration utilities
  pacman -Syu xfce4 xfce4-goodies tigervnc discover packagekit-qt6 mc sudo --noconfirm
  
  # Provision default non-root user and assign security groups
  id -u majid &>/dev/null || useradd -m -g users -G wheel,storage,power -s /bin/bash majid
  mkdir -p /etc/sudoers.d
  echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
  
  # Set system passwords safely
  echo "majid:12345678" | chpasswd
  echo "root:12345678" | chpasswd
'

# Separate execution block running strictly under the provisioned user profile
proot-distro login archlinux --user majid --shared-tmp -- bash -c '
  mkdir -p ~/.vnc ~/.config/tigervnc
  
  # Generate encrypted TigerVNC password files natively using standard piped input
  echo "12345678" | vncpasswd -f > ~/.config/tigervnc/passwd
  cp ~/.config/tigervnc/passwd ~/.vnc/passwd
  
  # Configure modern decoupled TigerVNC display settings
  echo "geometry=1280x720" > ~/.vnc/config
  echo "depth=24" >> ~/.vnc/config
  
  # Map X11 startup vectors to activate XFCE4
  echo "startxfce4 &" > ~/.vnc/xstartup
  chmod +x ~/.vnc/xstartup
  chmod 600 ~/.vnc/passwd ~/.config/tigervnc/passwd
'

echo "================================================================================"
echo "[*] Setup complete! Run '~/desktop.sh' to execute the graphical session."
echo "[*] Run '~/stop-desktop.sh' to terminate the graphical session."
echo "[*] VNC Address: 127.0.0.1:5901 | Security Token Password: 12345678"
echo "================================================================================"