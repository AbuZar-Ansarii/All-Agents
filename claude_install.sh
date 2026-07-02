#!/usr/bin/env bash
# ============================================================================
# Claude Code - Termux Native Installer
# ============================================================================
# Automates the setup of Anthropic's Claude Code CLI tool on Android/Termux,
# installs nodejs and git, configures custom settings with custom API Base
# URL and model, and sets up transparent shell environment settings.
#
# GitHub One-Liner Usage (once pushed to your repository):
#   curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/claude_install.sh | bash
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
    echo "│         🧠 Claude Code Termux Native Installer         │"
    echo "├────────────────────────────────────────────────────────┤"
    echo "│  Installs Anthropic's Claude Code CLI tool natively   │"
    echo "│  on Android/Termux with a custom API/Model provider.   │"
    echo "└────────────────────────────────────────────────────────┘"
    echo -e "${NC}"
}

# 1. Environment Verification
verify_termux() {
    log_info "Verifying execution environment..."
    if [ -n "${TERMUX_VERSION:-}" ] || [[ "${PREFIX:-}" == *"com.termux/files/usr"* ]]; then
        log_success "Termux environment verified (Version: ${TERMUX_VERSION:-Unknown})."
    else
        log_warn "Non-standard Termux environment detected. Proceeding anyway..."
    fi
}

# 2. Termux Package Repositories Optimization & Non-interactive update
optimize_and_update_repos() {
    log_info "Updating Termux package repositories..."
    
    # Configure non-interactive options to prevent dpkg prompt blocks (answering N/O/confold automatically)
    export DEBIAN_FRONTEND=noninteractive
    
    # Update repository index
    if ! pkg update -y; then
        log_warn "Standard package index update failed."
        log_info "Attempting mirror recovery using default main mirror..."
        termux-change-repo || true
        pkg update -y || {
            log_error "Could not update packages. Please check your internet connection."
            exit 1
        }
    fi

    # Perform package upgrade with auto-answer settings (noninteractive + confold to keep config files intact)
    log_info "Upgrading system packages (auto-responding to maintain defaults)..."
    if apt-get upgrade -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef"; then
        log_success "Package repository and system upgrades finished."
    else
        log_warn "Apt upgrade encountered minor issues, retrying with force options..."
        apt-get upgrade -y --force-yes -o Dpkg::Options::="--force-confold" || log_warn "Upgrade returned non-zero code but continuing..."
    fi
}

# 3. Setup Android storage and background wake-lock
setup_android_integration() {
    log_info "Configuring storage access and wake locks..."
    
    # Storage setup
    if [ ! -d "$HOME/storage" ]; then
        log_info "Requesting Android Shared Storage access..."
        log_info "Please approve the storage permission prompt on your screen."
        termux-setup-storage || true
    fi

    # Wake lock setup
    if command -v termux-wake-lock >/dev/null 2>&1; then
        termux-wake-lock
        log_success "Termux Wake-Lock enabled (prevents Android from killing background services)."
    fi
}

# 4. Install Toolchains
install_dependencies() {
    log_info "Installing package dependencies (git, nodejs, npm)..."
    
    local deps=(
        git
        nodejs
        npm
    )

    if pkg install -y "${deps[@]}"; then
        log_success "Dependencies installed successfully: ${deps[*]}"
    else
        log_error "Failed to install dependencies via pkg."
        log_info "Attempting installation via apt-get directly..."
        apt-get install -y "${deps[@]}" || {
            log_error "Could not install required packages. Please install git, nodejs, and npm manually."
            exit 1
        }
    fi
}

# 5. Get API Key from User
retrieve_api_key() {
    echo -e "\n${CYAN}${BOLD}🔑 API Key Configuration:${NC}"
    echo -e "You are using a custom endpoint provider (https://opencode.ai/zen)."
    echo -e "Please enter your API key to configure the agent automatically."
    echo -e "Press Enter to skip and configure the API key manually later."
    echo ""
    
    local user_key=""
    if [ -t 0 ] || [ -r /dev/tty ]; then
        echo -ne "${YELLOW}${BOLD}Enter API Key:${NC} "
        read -r user_key < /dev/tty || user_key=""
    else
        echo -ne "${YELLOW}${BOLD}Enter API Key:${NC} "
        read -r user_key || user_key=""
    fi
    
    # Clean input
    user_key=$(echo "$user_key" | xargs)

    if [ -z "$user_key" ]; then
        log_warn "No API Key provided. Will use standard placeholder 'YOUR_API_KEY_HERE'."
        api_key="YOUR_API_KEY_HERE"
    else
        log_success "API Key received."
        api_key="$user_key"
    fi
}

# 6. Install Claude Code CLI
install_claude_code() {
    log_info "Installing @anthropic-ai/claude-code@2.1.112 globally via npm..."
    
    # Clean cache and install globally
    if npm install -g @anthropic-ai/claude-code@2.1.112; then
        log_success "Claude Code version 2.1.112 has been installed successfully."
    else
        log_error "Global npm install failed."
        log_info "Retrying with sudo-like permissions check or prefix flag..."
        npm install -g --unsafe-perm @anthropic-ai/claude-code@2.1.112 || {
            log_error "Claude Code installation failed. Please check node/npm versions and retry."
            exit 1
        }
    fi
}

# 7. Configure Claude Settings
configure_settings() {
    log_info "Writing settings config to ~/.claude/settings.json..."
    
    mkdir -p "$HOME/.claude"
    
    cat <<EOF > "$HOME/.claude/settings.json"
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://opencode.ai/zen",
    "ANTHROPIC_MODEL": "deepseek-v4-flash-free",
    "ANTHROPIC_API_KEY": "${api_key}",
    "ENABLE_TOOL_SEARCH": "true"
  },
  "autoUpdatesChannel": "latest"
}
EOF

    log_success "Settings file written successfully to $HOME/.claude/settings.json"
}

# 8. Configure Shell Aliases
configure_shell() {
    log_info "Configuring shell shortcuts and conveniences..."
    
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
    local alias_claude="alias claude-code='claude'"
    
    # Check and append alias
    if ! grep -qF "$alias_claude" "$shell_rc"; then
        echo "" >> "$shell_rc"
        echo "# Claude Code Custom Alias" >> "$shell_rc"
        echo "$alias_claude" >> "$shell_rc"
        log_success "Convenience alias 'claude-code' added to $shell_rc."
    else
        log_info "Alias 'claude-code' already exists in $shell_rc."
    fi
}

# 9. Print Installation Success & Summary
show_final_summary() {
    print_header
    echo -e "${GREEN}${BOLD}✓ Claude Code is successfully installed and configured!${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}📱 Termux Quick Commands:${NC}"
    echo -e "  - ${YELLOW}claude${NC}      : Launch the Claude Code CLI tool."
    echo -e "  - ${YELLOW}claude-code${NC} : Alias to launch the Claude Code tool."
    echo ""
    echo -e "${CYAN}${BOLD}📁 File Locations:${NC}"
    echo -e "  - ${YELLOW}Config File:${NC}  $HOME/.claude/settings.json"
    echo ""
    echo -e "${CYAN}${BOLD}⚙️ Pre-configured Environment:${NC}"
    echo -e "  - ${YELLOW}Base URL:${NC}    https://opencode.ai/zen"
    echo -e "  - ${YELLOW}Model:${NC}       deepseek-v4-flash-free"
    echo -e "  - ${YELLOW}API Key:${NC}     $(if [ "$api_key" = "YOUR_API_KEY_HERE" ]; then echo -e "${RED}Placeholder (Needs Configuration)${NC}"; else echo -e "${GREEN}Configured successfully${NC}"; fi)"
    echo ""
    echo -e "${CYAN}${BOLD}🔋 Android Background Optimization:${NC}"
    echo "  Android will aggressively suspend Termux if it is in the background."
    echo "  - Make sure Termux Wake Lock is acquired (check your notification bar)."
    echo "  - Disable Battery Optimization for Termux in your Android Settings."
    echo ""
    echo -e "${MAGENTA}Setup complete! Run 'source ~/.bashrc' (or source ~/.zshrc) and type 'claude' to begin! 🧠${NC}"
    echo ""
}

# Main Execution Flow
main() {
    print_header
    verify_termux
    optimize_and_update_repos
    setup_android_integration
    install_dependencies
    retrieve_api_key
    install_claude_code
    configure_settings
    configure_shell
    show_final_summary
}

main "$@"
