![Alt](banner.png)
# FastTune – Clean & Optimize Your Linux System

`FastTune` is a lightweight, safe, and efficient Linux shell script designed to clean your system, free up space, and improve overall performance. It works great for systems using **APT-based distributions** like Ubuntu, Debian, and Linux Mint, and supports popular browsers like **LibreWolf**, **Brave**, **Firefox**, and **Chromium**.

---

## ✅ Features

- Clean APT package cache and orphaned dependencies
- Vacuum system logs (default: keep last 7 days)
- Empty Trash and thumbnail caches
- Remove browser and VS Code caches
- Clear Snap and Flatpak leftovers (if installed)
- Optimize Linux memory management (swappiness)
- Dry-run mode to preview changes
- Logs all actions to `~/.local/logs/`

---

## 📦 Requirements

- APT-based distro (Ubuntu, Debian, Linux Mint)
- Bash shell (v4+)
- `sudo` privileges
- Optional:
  - Snap (`snapd`) if you use Snap packages
  - Flatpak if you use Flatpak apps

---

## 📥 Installation

Clone this repository and make the script executable:

```bash
git clone https://github.com/thedevreda/clean.sh.git
cd clean.sh
chmod +x clean.sh
```

---
## (Optional) Move it to a directory in your system PATH for easy use:

```bash
mkdir -p ~/bin
mv clean.sh ~/bin/
```
---
## Ensure ~/bin is in your PATH: 

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## 🚀 Usage

- Run the script from your terminal:
```bash
clean.sh
```
- You can also preview actions (no changes made):
```bash
clean.sh --dry
```
- Or change how many days of logs you want to keep:
```bash
clean.sh --keep-journal=3
```
