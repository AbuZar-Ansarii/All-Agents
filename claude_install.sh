#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "========== Starting Claude Code Setup for Termux =========="

# 1. Update and upgrade system packages automatically (-y)
echo "Updating package repositories..."
pkg update -y && pkg upgrade -y

# 2. Install dependencies (git, nodejs, npm)
echo "Installing required packages (git, nodejs)..."
pkg install git nodejs -y

# 3. Install Claude Code globally, passing 'yes' to any prompts automatically
echo "Installing Claude Code v2.1.112..."
yes | npm install -g @anthropic-ai/claude-code@2.1.112

# 4. Prompt the user for their API Key safely
echo "--------------------------------------------------"
echo -n "Please enter your ANTHROPIC_API_KEY: "
read -r USER_API_KEY
echo "--------------------------------------------------"

# Validate that the user didn't just press enter
if [ -z "$USER_API_KEY" ]; then
    echo "Error: API Key cannot be empty. Exiting."
    exit 1
fi

# 5. Create the directory and write the configurations automatically
echo "Creating configuration directory and settings.json..."
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

echo "========== Installation & Configuration Complete! =========="
echo "You can now run 'claude' to start using it."