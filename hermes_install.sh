#!/usr/bin/env bash
# ============================================================================
# Hermes Agent - Termux Auto-Installer (Ubuntu PRoot + Shizuku Bridge)
# ============================================================================
# Automatically repairs packages, verifies Shizuku, and installs Hermes inside
# an Ubuntu PRoot container with full phone control capabilities.
# ============================================================================

set -euo pipefail

# Style Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

print_header() {
    clear
    echo -e "${MAGENTA}${BOLD}"
    echo "┌────────────────────────────────────────────────────────┐"
    echo "│        ⚕ Hermes Agent Termux Auto-Installer            │"
    echo "├────────────────────────────────────────────────────────┤"
    echo "│  Automatically configures Ubuntu PRoot & Shizuku       │"
    echo "│  Bridge for full mobile device control.                │"
    echo "└────────────────────────────────────────────────────────┘"
    echo -e "${NC}"
}

print_header

# 1. Package Database Repair & Update
log_info "Repairing package database and performing system updates..."
export DEBIAN_FRONTEND=noninteractive
dpkg --configure -a || true
apt install -f -y || true
pkg clean || true
pkg update -y || {
    log_warn "Standard repository update failed. Trying alternative repositories..."
    termux-change-repo || true
    pkg update -y || log_error "Failed to update package index. Proceeding with installation..."
}

# Ensure storage is set up
if [ ! -d "$HOME/storage" ]; then
    log_info "Setting up Android storage integration..."
    log_info "Please grant Storage Access on the upcoming screen..."
    termux-setup-storage || true
    sleep 2
fi

# 2. Check and Setup Shizuku Files
log_info "Detecting Shizuku 'rish' files..."
local_bin="$PREFIX/bin"
mkdir -p "$local_bin"

copy_shizuku_files() {
    local paths=(
        "/sdcard/Shizuku"
        "$HOME/storage/shared/Shizuku"
        "/sdcard/Android/media/moe.shizuku.privileged.api"
        "$HOME/storage/shared/Android/media/moe.shizuku.privileged.api"
        "/sdcard/Android/media/moe.shizuku.privileged.api/files"
        "$HOME/storage/shared/Android/media/moe.shizuku.privileged.api/files"
    )
    for path in "${paths[@]}"; do
        if [ -f "$path/rish" ] && [ -f "$path/rish_shizuku.dex" ]; then
            log_success "Found Shizuku files in $path. Copying to Termux..."
            cp "$path/rish" "$local_bin/rish"
            cp "$path/rish_shizuku.dex" "$local_bin/rish_shizuku.dex"
            chmod +x "$local_bin/rish"
            chmod 400 "$local_bin/rish_shizuku.dex"
            return 0
        fi
    done
    return 1
}

# Attempt to copy if not already in bin
if [ ! -f "$local_bin/rish" ] || [ ! -f "$local_bin/rish_shizuku.dex" ]; then
    if ! copy_shizuku_files; then
        log_warn "Could not locate Shizuku 'rish' files automatically."
        echo ""
        echo -e "Please:"
        echo -e "  1. Open the Shizuku app."
        echo -e "  2. Tap ${BOLD}'Use Shizuku in terminal apps'${NC} -> ${BOLD}'Export files'${NC}."
        echo -e "  3. Save the files to your device's Shizuku folder."
        echo ""
        while true; do
            read -r -p "Press [Enter] once you have exported the files, or Ctrl+C to abort..."
            if copy_shizuku_files; then
                break
            fi
            log_warn "Still unable to find rish files in storage. Please export them first."
        done
    fi
fi

# 3. Verify Shizuku Service is Running
log_info "Verifying Shizuku service status..."
while true; do
    # Run test command via rish
    if rish -c "true" >/dev/null 2>&1; then
        log_success "Shizuku service verified and connected!"
        break
    fi
    log_warn "Shizuku service is not running or Termux is not authorized."
    echo ""
    echo -e "Please:"
    echo -e "  1. Open the Shizuku app and start the service (via Wireless Debugging)."
    echo -e "  2. Ensure Termux is authorized under Shizuku's authorized apps."
    echo ""
    read -r -p "Press [Enter] to retry connection, or Ctrl+C to abort..."
done

# 4. Forward to the PRoot Installer directly
log_info "Launching the Ubuntu PRoot installer wrapper..."
exec bash -c "$(curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/hermes_install_proot.sh)" -- "$@"
