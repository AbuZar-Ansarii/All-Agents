#!/usr/bin/env bash
# ============================================================================
# Hermes Agent - Termux Android Installer Wrapper
# ============================================================================
# A highly optimized, professional wrapper script to prepare the Termux
# environment, install compiler toolchains, configure system settings,
# and run the official Nous Research Hermes Agent installer on Android.
#
# GitHub One-Liner Usage (once pushed to your repository):
#   curl -fsSL https://raw.githubusercontent.com/<username>/<repo>/main/hermes_install.sh | bash
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
    echo -e "${MAGENTA}${BOLD}"
    echo "┌────────────────────────────────────────────────────────┐"
    echo "│        ⚕ Hermes Agent Termux Installer Wrapper         │"
    echo "├────────────────────────────────────────────────────────┤"
    echo "│  Optimized environment setup & toolchain compiler      │"
    echo "│  pre-configuration for Termux on Android.              │"
    echo "└────────────────────────────────────────────────────────┘"
    echo -e "${NC}"
}

# 1. Environment Verification
verify_termux() {
    log_info "Verifying execution environment..."
    if [ -n "${TERMUX_VERSION:-}" ] || [[ "${PREFIX:-}" == *"com.termux/files/usr"* ]]; then
        log_success "Termux detected (Version: ${TERMUX_VERSION:-Unknown})"
    else
        log_error "This script is optimized for Android (Termux)."
        log_warn "If you are on Linux or macOS, please run the official installer directly:"
        echo "  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash"
        echo ""
        read -r -p "Do you want to force continue anyway? [y/N] " response
        case "$response" in
            [yY]|[yY][eE][sS])
                log_info "Proceeding under forced environment mode..."
                ;;
            *)
                log_info "Installation aborted."
                exit 1
                ;;
        esac
    fi
}

# 2. Termux Package Repositories Optimization
optimize_repositories() {
    log_info "Checking network and updating Termux package indexes..."
    
    # Enable non-interactive package updates if available
    export DEBIAN_FRONTEND=noninteractive

    # Standard package list update
    if ! pkg update -y; then
        log_warn "Package index update failed. Stale or unreachable mirror detected."
        log_warn "You can change your mirror by running: termux-change-repo"
        log_info "Attempting mirror recovery using default main mirror..."
        termux-change-repo || true
        pkg update -y || {
            log_error "Could not update packages. Please check your internet connection."
            exit 1
        }
    fi
    log_success "Package repositories updated successfully."
}

# 3. Android-Specific System Requests
setup_android_permissions() {
    print_header
    log_info "Setting up Android system integration..."

    # Request Storage Access to allow reading/writing project folders
    if [ ! -d "$HOME/storage" ]; then
        log_info "Requesting Android Shared Storage access..."
        log_info "Please approve the storage permission prompt on your screen."
        termux-setup-storage
        log_success "Storage folder check complete."
    else
        log_info "Shared Storage is already configured (~/storage found)."
    fi

    # Request Wake Lock to prevent Android OS from killing the background gateway (Telegram/WhatsApp etc.)
    if command -v termux-wake-lock >/dev/null 2>&1; then
        log_info "Acquiring Termux Wake Lock (prevents sleep during background operations)..."
        termux-wake-lock
        log_success "Wake Lock acquired. Termux will run in the background."
    else
        log_warn "termux-wake-lock command not found. You may need to run 'pkg install termux-api'."
    fi
}

# 4. Pre-install Core Toolchains
install_toolchains() {
    log_info "Installing compiler toolchains & package dependencies..."
    
    # Core packages required for python compilation (e.g., psutil wheel build) and node runtime
    local deps=(
        clang
        rust
        make
        pkg-config
        libffi
        openssl
        ca-certificates
        curl
        git
        python
        nodejs
        ffmpeg
        ripgrep
    )

    log_info "Required packages: ${deps[*]}"
    
    # Install dependencies Headlessly
    if pkg install -y "${deps[@]}"; then
        log_success "All compiler toolchains and system dependencies installed successfully."
    else
        log_error "Failed to install some system dependencies."
        log_warn "Retrying compilation dependencies individually..."
        for pkg in "${deps[@]}"; do
            pkg install -y "$pkg" || log_warn "Failed to install optional dependency: $pkg"
        done
    fi
}

# 5. Run official Hermes Agent installer
execute_hermes_installer() {
    log_info "Launching the official Hermes Agent installer..."
    
    # We pass the arguments received by this script down to the official installer.
    # E.g. --skip-setup, --branch, etc.
    if curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- "$@"; then
        log_success "Official Hermes Agent installer completed successfully!"
    else
        log_error "Official Hermes Agent installer encountered an error."
        exit 1
    fi
}

# 6. Add Custom Shortcuts and Shell Configurations
configure_shell_shortcuts() {
    log_info "Configuring shell shortcuts..."
    
    local shell_rc=""
    local login_shell
    login_shell=$(basename "${SHELL:-/bin/bash}")
    
    case "$login_shell" in
        zsh)  shell_rc="$HOME/.zshrc" ;;
        bash) shell_rc="$HOME/.bashrc" ;;
        *)    shell_rc="$HOME/.bashrc" ;;
    esac

    # Ensure RC file exists
    touch "$shell_rc"

    # Define custom convenience aliases
    local alias_start="alias hermes-start='hermes tui'"
    local alias_gateway="alias hermes-gateway='hermes gateway'"
    local alias_setup="alias hermes-setup='hermes setup'"
    
    # Check and append aliases safely
    local added=0
    for al in "$alias_start" "$alias_gateway" "$alias_setup"; do
        if ! grep -qF "$al" "$shell_rc"; then
            echo "$al" >> "$shell_rc"
            added=1
        fi
    done

    if [ "$added" -eq 1 ]; then
        log_success "Convenience aliases added to $shell_rc"
        log_info "  - hermes-start   : Launches the Hermes Agent TUI console"
        log_info "  - hermes-gateway : Runs the background messaging gateway"
        log_info "  - hermes-setup   : Re-runs the configuration wizard"
    else
        log_info "Shell shortcuts are already configured in $shell_rc."
    fi
}

# 7. Print Installation Success & Guide
show_final_summary() {
    print_header
    echo -e "${GREEN}${BOLD}✓ Hermes Agent is successfully configured on Termux!${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}📱 Termux Android Quick Guide:${NC}"
    echo ""
    echo -e "  ${YELLOW}1. Refresh Session:${NC} Run 'source ~/.bashrc' (or source ~/.zshrc) to load commands."
    echo -e "  ${YELLOW}2. Run Agent:${NC}       Type 'hermes-start' or 'hermes tui' to launch the TUI."
    echo -e "  ${YELLOW}3. Configuration:${NC}  Config lives at '~/.hermes/config.yaml'."
    echo -e "                     API keys live at '~/.hermes/.env'."
    echo -e "  ${YELLOW}4. Messaging Bot:${NC}  If you configured Telegram/Discord/WhatsApp, run 'hermes-gateway'."
    echo ""
    echo -e "${CYAN}${BOLD}🔋 Battery Optimization Advice:${NC}"
    echo "  Android aggressively kills background processes. To keep Hermes active:"
    echo "  - Swipe down your notification drawer, tap 'Acquire Wake Lock' if prompt is shown."
    echo "  - Disable Battery Optimization for the Termux App in your Android Settings."
    echo ""
    echo -e "${MAGENTA}Happy Agenting! ⚕${NC}"
    echo ""
}

# Main Execution Flow
main() {
    print_header
    verify_termux
    optimize_repositories
    setup_android_permissions
    install_toolchains
    execute_hermes_installer "$@"
    configure_shell_shortcuts
    show_final_summary
}

main "$@"
