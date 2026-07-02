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
NC='\033[0m'

# --- UI Helper Functions ---
print_header() {
    echo -e "\n${BOLD}${CYAN}==================================================${NC}"
    echo -e "${BOLD}${PURPLE}  $1 ${NC}"
    echo -e "${BOLD}${CYAN}==================================================${NC}\n"
}

print_status() {
    echo -e "${BOLD}${YELLOW}>> $1${NC}"
}

print_success() {
    echo -e "${BOLD}${GREEN}✔ $1${NC}"
}

# START SETUP
print_header "   CLAUDE CODE INSTALLER FOR TERMUX"

print_status "Updating package repositories and core packages..."
pkg update -y && pkg upgrade -y
print_success "System update completed."

print_status "Installing required dependencies (git, nodejs)..."
pkg install git nodejs -y
print_success "Dependencies successfully installed."

print_status "Installing Claude Code v2.1.112 (This may take a moment)..."
yes | npm install -g @anthropic-ai/claude-code@2.1.112
print_success "Claude Code installed successfully."

echo -e "\n${BOLD}${YELLOW}--------------------------------------------------${NC}"
echo -e "${BOLD}${BLUE}👉 Please enter or paste your ANTHROPIC_API_KEY:${NC}"
echo -e "${BOLD}${YELLOW}--------------------------------------------------${NC}"

echo -ne "${BOLD}${PURPLE}Key: ${NC}"
read -r USER_API_KEY

echo -e "${BOLD}${YELLOW}--------------------------------------------------${NC}\n"

if [ -z "$USER_API_KEY" ]; then
    echo -e "${BOLD}${RED}❌ Error: API Key cannot be empty. Exiting installer.${NC}\n"
    exit 1
fi

print_status "Generating settings file at ~/.claude/settings.json..."
mkdir -p ~/.claude

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
print_success "Configuration saved perfectly."

echo -e "\n${BOLD}${GREEN}==================================================${NC}"
echo -e "${BOLD}${GREEN}🎉 SETUP COMPLETED SUCCESSFULLY! 🎉${NC}"
echo -e "${BOLD}${GREEN}==================================================${NC}"
echo -e "${BOLD}${WHITE} You can now start using it by typing: ${CYAN}claude${NC}\n"
