#!/usr/bin/env bash
# ============================================================================
# Hermes Agent - Termux PRoot-Distro Ubuntu Installer Wrapper
# ============================================================================
# Automates the setup of an Ubuntu glibc container inside Termux via PRoot-Distro,
# bootstraps compiler tools/dependencies, installs the official Hermes Agent
# inside the container, and sets up transparent shell launchers in Termux.
#
# GitHub One-Liner Usage (once pushed to your repository):
#   curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/hermes_install_proot.sh | bash
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
    echo "│        ⚕ Hermes Agent Termux Ubuntu-PRoot Installer    │"
    echo "├────────────────────────────────────────────────────────┤"
    echo "│  Solves dependencies by running Hermes inside a        │"
    echo "│  standard Ubuntu environment via Termux proot-distro.  │"
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

    # Install PRoot-distro and basic utilities in Termux
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
        log_info "Installing Ubuntu proot container (this may take a few minutes depending on connection speed)..."
        proot-distro install ubuntu
        log_success "Ubuntu container installed successfully."
    fi
}

# 5. Bootstrap dependencies inside the Ubuntu container
bootstrap_ubuntu_container() {
    log_info "Bootstrapping base utilities inside the Ubuntu container..."
    
    # We update apt, and install curl, git, sudo, ca-certificates, and python3-venv (needed by standard python installations)
    proot-distro login ubuntu --shared-tmp -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get upgrade -y
        apt-get install -y curl git sudo ca-certificates python3-pip python3-venv build-essential libffi-dev libssl-dev dbus-x11
    "
    log_success "Ubuntu container base packages initialized."
}

# 6. Execute official Hermes Agent installer inside Ubuntu
execute_hermes_inside_ubuntu() {
    log_info "Downloading and running official Hermes Agent installer inside the Ubuntu container..."
    
    # We login as root inside the Ubuntu container and run the official installer.
    # The official installer handles FHS installation layout inside Ubuntu.
    proot-distro login ubuntu --shared-tmp -- bash -c "
        curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
    "
    log_success "Hermes installation inside the Ubuntu container is complete."
}

# 7. Configure Transparent Launchers in Termux
configure_termux_launchers() {
    log_info "Setting up transparent launchers in Termux..."
    
    local bin_dir="$PREFIX/bin"
    mkdir -p "$bin_dir"

    # Main hermes launcher
    cat > "$bin_dir/hermes" <<EOF
#!/usr/bin/env bash
# Hermes Termux wrapper
if command -v termux-wake-lock >/dev/null 2>&1; then
    termux-wake-lock
fi
exec proot-distro login ubuntu --shared-tmp -- hermes "\$@"
EOF
    chmod +x "$bin_dir/hermes"

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
    local alias_start="alias hermes-start='hermes tui'"
    local alias_gateway="alias hermes-gateway='hermes gateway'"
    local alias_setup="alias hermes-setup='hermes setup'"
    
    local added=0
    for al in "$alias_start" "$alias_gateway" "$alias_setup"; do
        if ! grep -qF "$al" "$shell_rc"; then
            echo "$al" >> "$shell_rc"
            added=1
        fi
    done

    if [ "$added" -eq 1 ]; then
        log_success "Termux environment aliases added to $shell_rc."
    fi
    log_success "Command line launchers configured: Type 'hermes' anywhere in Termux."
}

# 8. Print Post-Install Guidelines
show_final_summary() {
    # Resolve the path to the container rootfs so the user knows where their files live
    local rootfs_path="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/root"
    
    print_header
    echo -e "${GREEN}${BOLD}✓ Hermes Agent is configured inside Ubuntu via Termux PRoot!${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}📱 Termux Quick Commands:${NC}"
    echo "  You can run these commands directly in Termux (no need to login manually):"
    echo -e "  - ${YELLOW}hermes-setup${NC}   : Run the setup wizard to select models and configure API keys."
    echo -e "  - ${YELLOW}hermes-start${NC}   : Open the interactive Terminal Console (TUI)."
    echo -e "  - ${YELLOW}hermes-gateway${NC} : Run the background bot gateway (Telegram/WhatsApp/Discord)."
    echo -e "  - ${YELLOW}hermes <cmd>${NC}   : Run any standard hermes CLI command."
    echo ""
    echo -e "${CYAN}${BOLD}📁 File Locations (Accessible from Termux):${NC}"
    echo -e "  Your configuration files live inside the Ubuntu root home directory:"
    echo -e "  - ${YELLOW}Config File:${NC}  $rootfs_path/.hermes/config.yaml"
    echo -e "  - ${YELLOW}API Keys:${NC}     $rootfs_path/.hermes/.env"
    echo -e "  - ${YELLOW}Logs/Data:${NC}    $rootfs_path/.hermes/"
    echo ""
    echo -e "  You can edit these files directly from Termux (e.g. 'nano $rootfs_path/.hermes/.env')."
    echo ""
    echo -e "${CYAN}${BOLD}🔋 Android Background Settings:${NC}"
    echo "  Android will aggressively suspend Termux if it is in the background."
    echo "  - Make sure Termux Wake Lock is acquired (check your notification bar)."
    echo "  - Disable Battery Optimization for Termux in your Android Settings."
    echo ""
    echo -e "${MAGENTA}Setup complete! Run 'source ~/.bashrc' (or source ~/.zshrc) and type 'hermes-setup' to begin! ⚕${NC}"
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
    execute_hermes_inside_ubuntu
    configure_termux_launchers
    show_final_summary
}

main "$@"
