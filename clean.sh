#!/usr/bin/env bash
# clean.sh – Clean and speed up your Linux system safely
# Author: Reda Amelloul (improved by ChatGPT Pro)
# Last update: 2025-07-14

set -euo pipefail
IFS=$'\n\t'

# ─── Configuration ──────────────────────────────────────────────
KEEP_JOURNAL_DAYS=7
LOG_DIR="$HOME/.local/logs"
LOG_FILE="$LOG_DIR/clean_$(date +%F_%H%M).log"
DRY_RUN=0

mkdir -p "$LOG_DIR"

# ─── CLI Argument Parsing ───────────────────────────────────────
for arg in "$@"; do
  case $arg in
    --dry) DRY_RUN=1 ;;
    --keep-journal=*) KEEP_JOURNAL_DAYS="${arg#*=}" ;;
    -h|--help)
      echo "Usage: ./clean.sh [--dry] [--keep-journal=N]"
      echo "  --dry               Preview actions without making changes"
      echo "  --keep-journal=N    Keep system logs for N days (default: 7)"
      exit 0
      ;;
    *) echo "Unknown argument: $arg" && exit 1 ;;
  esac
done

# ─── Utility Functions ───────────────────────────────────────────
log()   { echo "[*] $*" | tee -a "$LOG_FILE"; }
run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[DRY] $*"
  else
    eval "$@" >>"$LOG_FILE" 2>&1
  fi
}

# ─── APT Cleanup ────────────────────────────────────────────────
clean_apt() {
  log "Cleaning APT packages and cache..."
  run "sudo apt clean"
  run "sudo apt autoclean"
  run "sudo apt autoremove -y --purge"
}

# ─── System Log Cleanup ─────────────────────────────────────────
clean_logs() {
  log "Cleaning system logs (older than $KEEP_JOURNAL_DAYS days)..."
  run "sudo journalctl --vacuum-time=${KEEP_JOURNAL_DAYS}d"
  run "sudo find /var/log -type f -name '*.gz' -mtime +30 -delete"
  run "sudo find /var/log -type f -name '*.1' -mtime +30 -delete"
}

# ─── User Cache Cleanup ─────────────────────────────────────────
clean_user_cache() {
  log "Cleaning user-level caches..."

  # General
  run "rm -rf ~/.cache/thumbnails/*"
  run "rm -rf ~/.local/share/Trash/files/*"
  run "rm -rf ~/.local/share/Trash/info/*"
  run "rm -rf ~/.recently-used.xbel"

  # VS Code
  run "rm -rf ~/.config/Code/{Cache,CachedData,User/workspaceStorage}/*"

  # LibreWolf / Firefox
  run "rm -rf ~/.librewolf/*.default*/cache2/*"
  run "rm -rf ~/.mozilla/firefox/*.default*/cache2/*"

  # Brave / Chromium / Chrome
  run "rm -rf ~/.cache/BraveSoftware/Brave-Browser/*"
  run "rm -rf ~/.cache/google-chrome/*"
  run "rm -rf ~/.cache/chromium/*"
}

# ─── Snap & Flatpak Cleanup ─────────────────────────────────────
clean_snap_flatpak() {
  if command -v snap &>/dev/null; then
    log "Cleaning Snap cache and disabled versions..."
    run "sudo rm -rf /var/lib/snapd/cache/*"
    run "sudo snap list --all | awk '/disabled/{print \$1, \$3}' | while read name rev; do sudo snap remove \$name --revision=\$rev; done"
  fi
  if command -v flatpak &>/dev/null; then
    log "Cleaning Flatpak unused runtimes..."
    run "flatpak uninstall --unused -y"
  fi
}

# ─── Swappiness Optimization ────────────────────────────────────
optimize_swappiness() {
  local current_swappiness
  current_swappiness=$(cat /proc/sys/vm/swappiness)
  if (( current_swappiness > 20 )); then
    log "Optimizing swappiness (from $current_swappiness to 20)..."
    run "echo 'vm.swappiness=20' | sudo tee /etc/sysctl.d/99-swappiness.conf"
    run "sudo sysctl -p /etc/sysctl.d/99-swappiness.conf"
  else
    log "Swappiness already optimized (current: $current_swappiness)"
  fi
}

# ─── System Health Summary ──────────────────────────────────────
system_status() {
  log "System status after cleanup:"
  run "free -h"
  run "df -h /"
  run "ps -eo pid,comm,%mem --sort=-%mem | head -n 10"
}

# ─── Main Execution ─────────────────────────────────────────────
main() {
  log "Starting system cleanup and optimization..."

  clean_apt
  clean_logs
  clean_user_cache
  clean_snap_flatpak
  optimize_swappiness
  system_status

  log "Cleanup completed. Log saved to: $LOG_FILE"
}

main
