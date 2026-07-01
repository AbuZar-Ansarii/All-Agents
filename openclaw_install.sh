#!/usr/bin/env bash
# ============================================================================
# OpenClaw - Native Termux Android Installer
# ============================================================================
# A highly optimized, professional installer to set up the OpenClaw AI Agent
# gateway natively in Termux (no PRoot or virtualized container required).
#
# GitHub One-Liner Usage (once pushed to your repository):
#   curl -fsSL https://raw.githubusercontent.com/<username>/<repo>/main/openclaw_install.sh | bash
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
    echo "│  Installs OpenClaw AI gateway natively in Termux       │"
    echo "│  with Node.js LTS and compiler build toolchains.       │"
    echo "└────────────────────────────────────────────────────────┘"
    echo -e "${NC}"
}

# 1. Environment Verification
verify_termux() {
    log_info "Verifying execution environment..."
    if [ -n "${TERMUX_VERSION:-}" ] || [[ "${PREFIX:-}" == *"com.termux/files/usr"* ]]; then
        log_success "Termux detected (Version: ${TERMUX_VERSION:-Unknown})"
    else
        log_error "This script is optimized for Android (Termux) only."
        log_warn "If you are on Linux or macOS, please run the official installer directly:"
        echo "  curl -fsSL https://openclaw.ai/install.sh | bash"
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

    # Request Storage Access to allow reading/writing files
    if [ ! -d "$HOME/storage" ]; then
        log_info "Requesting Android Shared Storage access..."
        log_info "Please approve the storage permission prompt on your screen."
        termux-setup-storage
        log_success "Storage folder check complete."
    else
        log_info "Shared Storage is already configured (~/storage found)."
    fi

    # Request Wake Lock to prevent Android OS from killing the gateway
    if command -v termux-wake-lock >/dev/null 2>&1; then
        log_info "Acquiring Termux Wake Lock (prevents CPU sleep)..."
        termux-wake-lock
        log_success "Wake Lock acquired. Termux will run in the background."
    else
        log_warn "termux-wake-lock command not found. (Install termux-api for wake-lock controls)"
    fi
}

# 4. Install Toolchains (Node.js & C++ compiler chain for native modules)
install_toolchains() {
    log_info "Installing Node.js LTS, compilers, and dependencies..."
    
    # Native compilation chain is required in case OpenClaw compiles C++ native addons (node-gyp, sqlite, etc.)
    local deps=(
        nodejs-lts
        git
        clang
        make
        python
        pkg-config
        openssl
        libffi
        ripgrep
        ffmpeg
    )

    log_info "Installing packages: ${deps[*]}"
    
    if pkg install -y "${deps[@]}"; then
        log_success "All compiler toolchains and node runtimes installed successfully."
    else
        log_error "Failed to install some system dependencies."
        log_warn "Retrying dependency installation individually..."
        for pkg in "${deps[@]}"; do
            pkg install -y "$pkg" || log_warn "Failed to install optional dependency: $pkg"
        done
    fi
    
    # Check Node.js and NPM versions
    if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
        local node_version
        node_version=$(node -v)
        local npm_version
        npm_version=$(npm -v)
        log_success "Node.js $node_version and NPM $npm_version verified."
    else
        log_error "Node.js or NPM was not installed correctly. Aborting install."
        exit 1
    fi
}

# 5. Install OpenClaw globally
install_openclaw() {
    log_info "Installing OpenClaw globally via NPM..."
    
    # Run npm install globally. We use --unsafe-perm in case root-level processes are needed.
    # Note: On Termux, packages are installed under $PREFIX/lib/node_modules
    if npm install -g openclaw@latest; then
        log_success "OpenClaw global NPM package installed successfully!"
    else
        log_error "NPM installation failed. Trying force install..."
        npm install -g --force openclaw@latest || {
            log_error "Failed to install OpenClaw. Please inspect NPM logs above."
            exit 1
        }
    fi
    
    # Verify openclaw command availability
    if command -v openclaw >/dev/null 2>&1; then
        local openclaw_version
        openclaw_version=$(openclaw --version || echo "installed")
        log_success "OpenClaw command is available: $openclaw_version"
    else
        log_error "OpenClaw binary is not found on PATH. Checking installation directory..."
        # If it was installed but not linked on PATH, we link it manually
        if [ -f "$PREFIX/lib/node_modules/openclaw/bin/openclaw" ]; then
            ln -sf "$PREFIX/lib/node_modules/openclaw/bin/openclaw" "$PREFIX/bin/openclaw"
            log_success "Manually symlinked openclaw to $PREFIX/bin/openclaw."
        else
            log_error "Could not find openclaw executable. Try running: npm install -g --force openclaw@latest"
            exit 1
        fi
    fi
}

# 6. Configure Shell Shortcuts & Aliases
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

    # Ensure shell RC file exists
    touch "$shell_rc"

    # Define custom convenience aliases
    local alias_start="alias openclaw-start='openclaw gateway'"
    local alias_onboard="alias openclaw-setup='openclaw onboard'"
    local alias_doctor="alias openclaw-doctor='openclaw doctor'"
    
    # Check and append aliases safely
    local added=0
    for al in "$alias_start" "$alias_onboard" "$alias_doctor"; do
        if ! grep -qF "$al" "$shell_rc"; then
            echo "$al" >> "$shell_rc"
            added=1
        fi
    done

    if [ "$added" -eq 1 ]; then
        log_success "OpenClaw aliases added to $shell_rc."
    fi
}

# 7. Print Installation Success & Onboarding Guide
show_final_summary() {
    print_header
    echo -e "${GREEN}${BOLD}✓ OpenClaw AI Agent installed natively on Termux!${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}🚀 Onboarding Instructions:${NC}"
    echo -e "  To initialize your AI agent, you must run the onboarding wizard:"
    echo -e "  - Run: ${YELLOW}openclaw onboard${NC} (or ${YELLOW}openclaw-setup${NC})"
    echo "    This will guide you to set up your LLM providers, workspaces, and chat channels."
    echo ""
    echo -e "${CYAN}${BOLD}🤖 Control and Management:${NC}"
    echo -e "  - ${YELLOW}openclaw-start${NC}  : Launches the background OpenClaw Gateway bot."
    echo -e "  - ${YELLOW}openclaw-doctor${NC} : Diagnostics check to verify API keys, paths, and configs."
    echo ""
    echo -e "${CYAN}${BOLD}🌐 Web Control Dashboard:${NC}"
    echo "  Once the gateway is running, access the visual web dashboard on your phone:"
    echo -e "  - URL:  ${BLUE}http://127.0.0.1:18789${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}📁 File Locations:${NC}"
    echo -e "  - Config File:  ${YELLOW}~/.openclaw/openclaw.json${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}🔋 Android Background Settings:${NC}"
    echo "  Android will kill background Termux processes if battery saver is enabled."
    echo "  - Make sure 'Acquire Wake Lock' is clicked in the Termux notification."
    echo "  - Set Termux app battery usage to 'Unrestricted' in your system settings."
    echo ""
    echo -e "${MAGENTA}Happy Agenting! 🦞${NC}"
    echo ""
}

# Main Execution Flow
main() {
    print_header
    verify_termux
    optimize_repositories
    setup_android_permissions
    install_toolchains
    install_openclaw
    configure_shell_shortcuts
    show_final_summary
}

main "$@"
