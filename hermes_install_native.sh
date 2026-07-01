#!/usr/bin/env bash
# ============================================================================
# Hermes Agent - Termux Native Installer Wrapper (No PRoot)
# ============================================================================
# A highly optimized wrapper script to prepare the Termux environment,
# install compilers, and execute the official Hermes Agent installer
# natively inside Termux.
#
# GitHub One-Liner Usage (once pushed to your repository):
#   curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/hermes_install_native.sh | bash
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
    echo "│        ⚕ Hermes Agent Termux Native Installer          │"
    echo "├────────────────────────────────────────────────────────┤"
    echo "│  Native environment configuration, compiler setup,     │"
    echo "│  and direct execution pipeline on Android/Termux.      │"
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

# 2. Termux Package Repositories Optimization
optimize_repositories() {
    log_info "Checking network and updating Termux package indexes..."
    export DEBIAN_FRONTEND=noninteractive

    if ! pkg update -y; then
        log_warn "Standard package index update failed."
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
    log_info "Setting up Android system integration..."

    # Request Storage Access
    if [ ! -d "$HOME/storage" ]; then
        log_info "Requesting Android Shared Storage access..."
        log_info "Please approve the storage permission prompt on your screen."
        termux-setup-storage
        log_success "Storage folder check complete."
    else
        log_info "Shared Storage is already configured (~/storage found)."
    fi

    # Request Wake Lock to prevent Android OS from killing background tasks
    if command -v termux-wake-lock >/dev/null 2>&1; then
        log_info "Acquiring Termux Wake Lock..."
        termux-wake-lock
        log_success "Wake Lock acquired. Termux will run in the background."
    else
        log_warn "termux-wake-lock command not found."
    fi
}

# 4. Pre-install Core Toolchains
install_toolchains() {
    log_info "Installing compiler toolchains & package dependencies..."
    
    # Compiler tools needed for native Python wheel compilation (like psutil) on Android
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

    log_info "Installing packages: ${deps[*]}"
    
    if pkg install -y "${deps[@]}"; then
        log_success "All compiler toolchains and system dependencies installed successfully."
    else
        log_error "Failed to install some system dependencies."
        log_warn "Retrying dependency installation individually..."
        for pkg in "${deps[@]}"; do
            pkg install -y "$pkg" || log_warn "Failed to install optional dependency: $pkg"
        done
    fi
}

# 5. Run official Hermes Agent installer
execute_hermes_installer() {
    log_info "Launching the official Hermes Agent installer..."
    
    # Execute installer. Since we are in Termux, the official script will detect it
    # and execute its native python/pip installation pipeline.
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
    fi
}

# 7. Print Installation Success & Guide
show_final_summary() {
    print_header
    echo -e "${GREEN}${BOLD}✓ Hermes Agent is successfully configured natively on Termux!${NC}"
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
