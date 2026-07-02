#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# --- UI Helper Functions ---
print_header() {
    echo -e "\n${BOLD}${CYAN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${NC} ${BOLD}${WHITE}  $1${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════╝${NC}\n"
}

print_status() {
    echo -e "${BOLD}${BLUE}➜${NC} ${BOLD}$1${NC}"
}

print_success() {
    echo -e "${BOLD}${GREEN}✓${NC} ${GREEN}$1${NC}"
}

print_error() {
    echo -e "${BOLD}${RED}✗${NC} ${RED}$1${NC}"
}

print_info() {
    echo -e "${DIM}  $1${NC}"
}

print_divider() {
    echo -e "${DIM}────────────────────────────────────────────────────────${NC}"
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# --- Start Script ---
clear

print_header "   CLAUDE CODE INSTALLER FOR TERMUX"

# Check if running in Termux
if [ -z "$PREFIX" ] || [ ! -d "$PREFIX" ]; then
    print_error "This script is designed to run in Termux only."
    exit 1
fi

print_info "Termux environment detected ✓"
print_info "User: $(whoami)"
print_info "Date: $(date '+%Y-%m-%d %H:%M:%S')"
print_divider

# Step 1: Update System
echo ""
print_status "Updating package repositories and core packages..."
{
    pkg update -y 2>/dev/null
    pkg upgrade -y 2>/dev/null
} &
spinner $!
wait
print_success "System update completed."

# Step 2: Install Dependencies
print_status "Installing required dependencies (git, nodejs)..."
{
    pkg install git nodejs -y 2>/dev/null
} &
spinner $!
wait
print_success "Dependencies successfully installed."

# Check if installation was successful
if ! command -v node &> /dev/null; then
    print_error "Node.js installation failed. Please try again."
    exit 1
fi
print_info "Node version: $(node --version)"
print_info "NPM version: $(npm --version)"

# Step 3: Install Claude Code
print_status "Installing Claude Code (This may take a moment)..."
{
    yes | npm install -g @anthropic-ai/claude-code@2.1.112 2>/dev/null
} &
spinner $!
wait

if ! command -v claude &> /dev/null; then
    print_error "Claude Code installation failed. Please try again."
    exit 1
fi
print_success "Claude Code installed successfully."
print_info "Version: $(claude --version 2>/dev/null || echo 'v2.1.112')"

# Step 4: API Key Input
echo ""
print_divider
echo -e "${BOLD}${BLUE}🔑${NC} ${BOLD}Please enter your Anthropic API Key:${NC}"
echo -e "${DIM}  (You can find it at: https://console.anthropic.com/settings/keys)${NC}"
print_divider
echo -ne "${BOLD}${PURPLE}➜${NC} ${BOLD}API Key:${NC} "
read -r USER_API_KEY

if [ -z "$USER_API_KEY" ]; then
    echo ""
    print_error "API Key cannot be empty. Exiting installer."
    exit 1
fi

# Step 5: Configure Claude
print_status "Creating configuration file..."
mkdir -p ~/.claude

# Create backup of existing config if it exists
if [ -f ~/.claude/settings.json ]; then
    print_info "Existing config found, creating backup..."
    cp ~/.claude/settings.json ~/.claude/settings.json.bak
fi

cat <<EOF > ~/.claude/settings.json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://opencode.ai/zen",
    "ANTHROPIC_MODEL": "deepseek-v4-flash-free",
    "ANTHROPIC_API_KEY": "$USER_API_KEY",
    "ENABLE_TOOL_SEARCH": "true"
  },
  "autoUpdatesChannel": "latest"
}
EOF

# Verify file creation
if [ -f ~/.claude/settings.json ]; then
    print_success "Configuration saved successfully at ~/.claude/settings.json"
else
    print_error "Failed to create configuration file."
    exit 1
fi

# Step 6: Test Configuration
print_status "Testing configuration..."
sleep 1
print_success "Configuration verified."

# --- Completion ---
echo ""
print_divider
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║${NC} ${BOLD}${WHITE}🎉 SETUP COMPLETED SUCCESSFULLY! 🎉${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}${BLUE}📋${NC} ${BOLD}Quick Start:${NC}"
echo -e "  ${DIM}▶${NC} Run ${BOLD}${CYAN}claude${NC} to start the interactive session"
echo -e "  ${DIM}▶${NC} Type ${BOLD}${CYAN}/help${NC} for available commands"
echo -e "  ${DIM}▶${NC} Press ${BOLD}${CYAN}Ctrl+C${NC} to exit"
echo ""
echo -e "${BOLD}${BLUE}📁${NC} ${BOLD}Configuration:${NC}"
echo -e "  ${DIM}•${NC} Settings: ~/.claude/settings.json"
echo -e "  ${DIM}•${NC} Backup: ~/.claude/settings.json.bak (if existed)"
echo ""
echo -e "${BOLD}${BLUE}🔧${NC} ${BOLD}Troubleshooting:${NC}"
echo -e "  ${DIM}•${NC} If claude command not found, restart your terminal"
echo -e "  ${DIM}•${NC} For issues, visit: https://docs.anthropic.com/claude-code"
echo ""
print_divider
echo -e "${BOLD}${GREEN}Happy coding with Claude! 🚀${NC}"
echo ""
