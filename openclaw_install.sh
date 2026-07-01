#!/data/data/com.termux/files/usr/bin/bash
# ============================================================================
# 🦞 OpenClaw Termux Native Installer
# ============================================================================
# A professional wrapper script to install OpenClaw natively on Android
# using Termux. Configures system dependencies, compiler toolchains,
# applies critical Node.js DNS fixes, and invokes the official installer.
#
# Usage (run directly on your phone):
#   curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/openclaw_install.sh | bash
# ============================================================================

set -euo pipefail

# Style Definitions (Colors and Formatting)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Logger Helper Functions
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

print_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "┌────────────────────────────────────────────────────────┐"
    echo "│         🦞 OpenClaw Native Termux Installer            │"
    echo "├────────────────────────────────────────────────────────┤"
    echo "│  Native environment configuration, compiler setup,     │"
    echo "│  DNS optimization, and OpenClaw execution plane.       │"
    echo "└────────────────────────────────────────────────────────┘"
    echo -e "${NC}"
}

# 1. Environment Verification
verify_termux() {
    log_info "Verifying execution environment..."
    if [ -n "${TERMUX_VERSION:-}" ] || [[ "${PREFIX:-}" == *"com.termux/files/usr"* ]]; then
        log_success "Termux detected (Version: ${TERMUX_VERSION:-Unknown})"
    else
        log_warn "Non-standard Termux environment detected. Proceeding anyway..."
    fi
}

# 2. Update Packages & Install Dependencies
install_dependencies() {
    log_info "Step 1/3: Updating packages and installing dependencies..."
    
    # Global environment flags to prevent interactive apt blockers
    export DEBIAN_FRONTEND=noninteractive
    export DPKG_FORCE=confold
    export APT_LISTCHANGES_FRONTEND=none
    export LANG=C
    export LC_ALL=C

    # Run Termux repository update
    pkg update -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" </dev/null 2>&1 || {
        log_warn "pkg update had warnings (continuing...)"
    }

    # Install the specific set of packages needed for OpenClaw compilation/running
    local deps=(curl nodejs git cmake make clang binutils openssl which)
    log_info "Installing core packages: ${deps[*]}"

    pkg install -y "${deps[@]}" </dev/null 2>&1 || {
        log_warn "Some packages may have failed to install, checking essentials..."
    }

    # Clear shell hash cache to recognize newly installed commands
    if [ -n "${BASH_VERSION:-}" ]; then
        hash -r
    fi

    # Verify critical commands
    local missing=""
    for cmd in curl node git; do
        if ! command -v "$cmd" </dev/null >/dev/null 2>&1; then
            missing="$missing $cmd"
        fi
    done

    if [ -n "$missing" ]; then
        log_error "Missing critical dependencies:$missing"
        log_warn "--------------------------------------------------------"
        log_warn "If packages cannot be located, you may be using an obsolete"
        log_warn "Google Play Store version of Termux."
        log_warn "FIX: Uninstall Termux and download the official F-Droid build:"
        log_warn "👉 https://f-droid.org/packages/com.termux/"
        log_warn "--------------------------------------------------------"
        exit 1
    fi

    log_success "Dependencies installed."
}

# 3. Apply Node.js DNS Fix (Crucial for Android networks)
apply_network_fixes() {
    log_info "Step 2/3: Applying Network Fixes (IPv4 DNS Optimization)..."
    
    # We append the options to both .bashrc and .zshrc in case the user runs ZSH
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$rc" ] || [ "$(basename "$rc")" = ".bashrc" ]; then
            touch "$rc"
            if ! grep -q "NODE_OPTIONS=--dns-result-order=ipv4first" "$rc" 2>/dev/null; then
                echo "export NODE_OPTIONS=--dns-result-order=ipv4first" >> "$rc"
                log_info "Added IPv4 DNS preference to $rc"
            fi
        fi
    done
    
    export NODE_OPTIONS=--dns-result-order=ipv4first
    log_success "IPv4 DNS fix successfully applied."
}

# 4. Install Official OpenClaw via Direct Pipeline
install_openclaw() {
    log_info "Step 3/3: Checking OpenClaw installation status..."

    if command -v openclaw &>/dev/null || [ -d "$HOME/.openclaw/repo" ]; then
        log_success "OpenClaw is already installed!"
    else
        log_info "Installing OpenClaw (myopenclawhub.com)..."
        # We redirect stdin to /dev/tty to support interactive prompts in the child installer
        if bash -c "$(curl -sSL https://myopenclawhub.com/install)" < /dev/tty; then
            log_success "OpenClaw core installer finished successfully."
        else
            log_error "OpenClaw core installer reported an error."
            exit 1
        fi
    fi
}

# 5. Set up Android permissions and Wake Locks
setup_android_settings() {
    log_info "Configuring Android background and storage parameters..."
    
    # Storage check
    if [ ! -d "$HOME/storage" ]; then
        log_info "Setting up storage folder..."
        termux-setup-storage || true
    fi

    # Wake Lock (prevents gateway sleep)
    if command -v termux-wake-lock >/dev/null 2>&1; then
        termux-wake-lock
        log_success "Termux Wake-Lock activated."
    fi
}

# 6. Print Installation Summary
show_final_summary() {
    print_header
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "🎉 INSTALLATION COMPLETE!"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}To get started with OpenClaw:${NC}"
    echo -e "  ${YELLOW}1. Reload Shell:${NC} run 'source ~/.bashrc' (or source ~/.zshrc)"
    echo -e "  ${YELLOW}2. Onboard:${NC}      run 'openclaw onboard' to set up API keys."
    echo -e "  ${YELLOW}3. Start Bot:${NC}    run 'openclaw gateway' to launch the service."
    echo ""
    echo -e "${CYAN}${BOLD}🔋 Background Tip:${NC}"
    echo "  Disable Battery Optimization for the Termux App in your Android Settings"
    echo "  to ensure your gateway bot stays online 24/7."
    echo ""
}

# Main Execution Flow
main() {
    print_header
    verify_termux
    install_dependencies
    apply_network_fixes
    install_openclaw
    setup_android_settings
    show_final_summary
}

main "$@"
