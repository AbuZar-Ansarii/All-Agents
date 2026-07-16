#!/data/data/com.termux/files/usr/bin/bash

# Force non-interactive frontend for Debian/APT tools if they ask questions
export DEBIAN_FRONTEND=noninteractive

echo "🚀 Starting fully automated n8n installation..."

# 1. Update Termux packages (automatically answering 'yes' to all configuration prompts)
echo "🔄 Updating package lists (handling prompts automatically)..."
yes "" | pkg update -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
yes "" | pkg upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

# 2. Install required dependencies
echo "📦 Installing Node.js, Python, and build tools..."
pkg install -y nodejs python build-essential tur-repo

# 3. Install n8n globally
echo "⏳ Installing n8n globally (this will take a few minutes, please wait)..."
npm install -g n8n --omit=dev --yes

echo "----------------------------------------"
echo "✅ Installation complete!"
echo "To start n8n, simply type: n8n"
echo "Then open your phone's browser and go to: http://localhost:5678"
echo "----------------------------------------"