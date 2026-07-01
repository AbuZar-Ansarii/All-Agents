#!/usr/bin/env bash
# ============================================================================
# Hermes Agent - Termux Installation Selector
# ============================================================================
# A visual interactive console menu to allow users to select between
# lightweight Native Termux installation or highly compatible Ubuntu PRoot
# containerized installation.
#
# GitHub One-Liner Usage (once pushed to your repository):
#   curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/hermes_install.sh | bash
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

print_header() {
    clear
    echo -e "${MAGENTA}${BOLD}"
    echo "┌────────────────────────────────────────────────────────┐"
    echo "│        ⚕ Hermes Agent Termux Installation Menu         │"
    echo "├────────────────────────────────────────────────────────┤"
    echo "│  Choose between a lightweight Native installation or   │"
    echo "│  a highly compatible PRoot Ubuntu container.           │"
    echo "└────────────────────────────────────────────────────────┘"
    echo -e "${NC}"
}

print_header
echo -e "${CYAN}${BOLD}Select your installation strategy:${NC}\n"
echo -e "  ${YELLOW}1)${NC} ${BOLD}Native Termux Installation (Lightweight & Native)${NC}"
echo -e "     - Runs directly on Termux without virtualization."
echo -e "     - Highly efficient and uses less memory/CPU."
echo -e "     - Requires compiler setups for Python wheel compilation."
echo ""
echo -e "  ${YELLOW}2)${NC} ${BOLD}Ubuntu PRoot Container Installation (Highly Compatible)${NC}"
echo -e "     - Virtualizes an Ubuntu glibc container inside Termux."
echo -e "     - Resolves all SQLite, Python build, and Playwright browser errors."
echo -e "     - Requires about 1.5 GB of free disk space."
echo ""
if [ -t 0 ] || [ -r /dev/tty ]; then
    read -r -p "Enter your choice [1 for without proot, 2 for with proot] (Default: 1): " choice < /dev/tty || choice="1"
else
    choice="1"
fi
choice="${choice:-1}"

case "$choice" in
    1)
        echo -e "\n${GREEN}→ Fetching and launching Native Termux Installer...${NC}\n"
        exec bash -c "$(curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/hermes_install_native.sh)" -- "$@"
        ;;
    2)
        echo -e "\n${GREEN}→ Fetching and launching Ubuntu PRoot Installer...${NC}\n"
        exec bash -c "$(curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/hermes_install_proot.sh)" -- "$@"
        ;;
    *)
        echo -e "\n${RED}[ERROR] Invalid option choice. Exiting.${NC}\n"
        exit 1
        ;;
esac
