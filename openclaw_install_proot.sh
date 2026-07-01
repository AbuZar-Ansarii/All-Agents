#!/usr/bin/env bash
# ============================================================================
# OpenClaw - Termux PRoot-Distro Ubuntu Installer Wrapper
# ============================================================================
# Automates the setup of an Ubuntu glibc container inside Termux via PRoot-Distro,
# bootstraps compiler tools, Node.js v22+, installs OpenClaw globally inside the
# container, and sets up transparent shell launchers in Termux.
#
# GitHub One-Liner Usage (once pushed to your repository):
#   curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/openclaw_install_proot.sh | bash
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
    echo "│         🦞 OpenClaw Termux Ubuntu-PRoot Installer      │"
    echo "├────────────────────────────────────────────────────────┤"
    echo "│  Bypasses glibc dynamic linker and runner failures by  │"
    echo "│  running OpenClaw natively inside Ubuntu via PRoot.    │"
    echo "└────────────────────────────────────────────────────────┘"
    echo -e "${NC}"
}

# 1. Environment Verification
verify_termux() {
    log_info "Verifying execution environment..."
    if [ -n "${TERMUX_VERSION:-}" ] || [[ "${PREFIX:-}" == *"com.termux/files/usr"* ]]; then
        log_success "Termux environment verified."
    else
        log_error "This script is optimized for Android Termux."
        exit 1
    fi
}

# 2. Setup Termux Repositories and PRoot-Distro
setup_termux_prereqs() {
    log_info "Updating Termux repositories..."
    export DEBIAN_FRONTEND=noninteractive
    
    if ! pkg update -y; then
        log_warn "Standard mirror failed. Running mirror diagnostic/recovery..."
        termux-change-repo || true
        pkg update -y || {
            log_error "Failed to sync package lists. Check internet connection."
            exit 1
        }
    fi

    log_info "Installing PRoot-Distro and Termux integrations..."
    pkg install -y proot-distro termux-api curl git
}

# 3. Setup Android storage and background wake-lock
setup_android_integration() {
    log_info "Configuring storage access and wake locks..."
    
    # Storage setup
    if [ ! -d "$HOME/storage" ]; then
        log_info "Please grant Storage Access on the upcoming screen..."
        termux-setup-storage || true
    fi

    # Wake lock setup
    if command -v termux-wake-lock >/dev/null 2>&1; then
        termux-wake-lock
        log_success "Termux Wake-Lock enabled (prevents Android from killing background services)."
    fi
}

# 4. Install Ubuntu via PRoot-Distro
install_ubuntu_container() {
    log_info "Checking if Ubuntu proot container is installed..."
    
    if proot-distro list | grep -q "ubuntu.*installed"; then
        log_success "Ubuntu container is already installed."
    else
        log_info "Installing Ubuntu proot container..."
        proot-distro install ubuntu
        log_success "Ubuntu container installed successfully."
    fi
}

# 5. Bootstrap Node.js v22 and OpenClaw inside the Ubuntu container
bootstrap_ubuntu_container() {
    log_info "Bootstrapping dependencies, Node.js v22+, and OpenClaw inside the container..."
    
    # 1. Install base build packages
    # 2. Install NodeSource Node.js v22 repository and package
    # 3. Install openclaw globally via npm
    proot-distro login ubuntu --shared-tmp -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get install -y curl git sudo ca-certificates build-essential libssl-dev dbus-x11
        
        log_info() { echo -e '\033[0;36m[INFO]\033[0m '\$1; }
        log_success() { echo -e '\033[0;32m[SUCCESS]\033[0m '\$1; }
        
        log_info 'Adding NodeSource Node.js v22 repository...'
        curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
        
        log_info 'Installing Node.js v22...'
        apt-get install -y nodejs
        
        log_info 'Installing OpenClaw globally via NPM...'
        npm install -g openclaw@latest
        
        log_success 'OpenClaw successfully installed inside the container.'
    "
    log_success "Ubuntu container packages and OpenClaw initialized."
}

# 6. Configure Transparent Launchers in Termux
configure_termux_launchers() {
    log_info "Setting up transparent launchers in Termux..."
    
    local bin_dir="$PREFIX/bin"
    mkdir -p "$bin_dir"

    # Main openclaw launcher
    cat > "$bin_dir/openclaw" <<EOF
#!/usr/bin/env bash
# OpenClaw Termux wrapper
if command -v termux-wake-lock >/dev/null 2>&1; then
    termux-wake-lock
fi
exec proot-distro login ubuntu --shared-tmp -- openclaw "\$@"
EOF
    chmod +x "$bin_dir/openclaw"

    # Add quick shortcuts/aliases in shell configs
    local shell_rc=""
    local login_shell
    login_shell=$(basename "${SHELL:-/bin/bash}")
    
    case "$login_shell" in
        zsh)  shell_rc="$HOME/.zshrc" ;;
        bash) shell_rc="$HOME/.bashrc" ;;
        *)    shell_rc="$HOME/.bashrc" ;;
    esac

    touch "$shell_rc"

    # Define custom convenience aliases that redirect to the proot launcher
    local alias_start="alias openclaw-start='openclaw gateway'"
    local alias_onboard="alias openclaw-setup='openclaw onboard'"
    local alias_doctor="alias openclaw-doctor='openclaw doctor'"
    
    local added=0
    for al in "$alias_start" "$alias_onboard" "$alias_doctor"; do
        if ! grep -qF "$al" "$shell_rc"; then
            echo "$al" >> "$shell_rc"
            added=1
        fi
    done

    if [ "$added" -eq 1 ]; then
        log_success "Termux environment aliases added to $shell_rc."
    fi
    log_success "Command line launchers configured: Type 'openclaw' anywhere in Termux."
}

# 7. Print Post-Install Guidelines
show_final_summary() {
    # Resolve the path to the container rootfs so the user knows where their files live
    local rootfs_path="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/root"
    
    print_header
    echo -e "${GREEN}${BOLD}✓ OpenClaw is configured inside Ubuntu via Termux PRoot!${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}📱 Termux Quick Commands:${NC}"
    echo -e "  - ${YELLOW}openclaw-setup${NC}  : Run the onboarding wizard to configure API keys."
    echo -e "  - ${YELLOW}openclaw-start${NC}  : Start the background messaging gateway."
    echo -e "  - ${YELLOW}openclaw-doctor${NC} : Run diagnostics check."
    echo ""
    echo -e "${CYAN}${BOLD}🌐 Web Control Dashboard:${NC}"
    echo "  Once the gateway is running, access the visual web dashboard on your phone:"
    echo -e "  - URL:  ${BLUE}http://127.0.0.1:18789${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}📁 File Locations (Accessible from Termux):${NC}"
    echo -e "  Your configuration files live inside the Ubuntu root home directory:"
    echo -e "  - ${YELLOW}Config File:${NC}  $rootfs_path/.openclaw/openclaw.json"
    echo ""
    echo -e "  You can read your config or token directly from Termux:"
    echo -e "  - ${YELLOW}Command:${NC}      cat $rootfs_path/.openclaw/openclaw.json"
    echo ""
    echo -e "${MAGENTA}Setup complete! Run 'source ~/.bashrc' (or source ~/.zshrc) and type 'openclaw-setup' to begin! 🦞${NC}"
    echo ""
}

# Main Execution Flow
main() {
    print_header
    verify_termux
    setup_termux_prereqs
    setup_android_integration
    install_ubuntu_container
    bootstrap_ubuntu_container
    configure_termux_launchers
    show_final_summary
}

main "$@"
