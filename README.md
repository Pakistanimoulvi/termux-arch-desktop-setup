# Termux Arch Linux XFCE4 Desktop Setup

An automated bash script tailored for rootless Termux PRoot environments to install, configure, and manage a graphical Arch Linux ARM XFCE4 desktop environment with working audio.

---

## Features

* **Automated Environment Provisioning:** Installs `proot-distro` and fetches the targeted ARM64 Arch Linux container.
* **Audio Integration:** Sets up PulseAudio background routing natively between Termux and the container.
* **Streamlined Control:** Generates local wrapper scripts (`~/desktop.sh` and `~/stop-desktop.sh`) to easily start and stop the VNC display server and clean up lingering lock files.
* **Pre-configured User Profile:** Configures a standard non-root user (`majid`) with proper sudo privileges and decoupled TigerVNC startup profiles.

---

## Installation & Usage

1. **Download and Run the Script:**
```bash
curl -O https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/termux-arch-desktop-setup/main/setup.sh
chmod +x setup.sh
./setup.sh

```


2. **Start the Desktop Environment:**
```bash
~/desktop.sh

```


Connect using any VNC Viewer app at `127.0.0.1:5901` with the default password: `12345678`.
3. **Stop the Desktop Environment:**
```bash
~/stop-desktop.sh

```



---

## Default Credentials

* **User/Sudo Password:** `12345678`
* **Root Password:** `12345678`
* **VNC Security Password:** `12345678`

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.
