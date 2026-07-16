#!/data/data/com.termux/files/usr/bin/bash

# Prevent any interactive blocking screens
export DEBIAN_FRONTEND=noninteractive

echo "🚀 Starting 100% automated n8n installation..."

# 1. Update Termux base using direct dpkg force options to bypass Y/N prompts
echo "🔄 Updating Termux repository..."
pkg update -y -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-confdef"
pkg upgrade -y -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-confdef"
pkg install proot-distro curl -y -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-confdef"

# 2. Install Ubuntu container if it isn't already installed
if [ ! -d "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu" ]; then
    echo "📦 Downloading and installing Ubuntu container..."
    proot-distro install ubuntu
fi

# 3. Write the internal installation script inside the Ubuntu environment
echo "📝 Writing automated configuration..."
cat << 'EOF' > $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/root/setup_n8n.sh
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Update Ubuntu packages inside the container with prompt forcing
apt-get update
apt-get upgrade -y -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-confdef"
apt-get install -y curl build-essential -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-confdef"

# Install Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-confdef"

# Install n8n globally
npm install -g n8n --omit=dev --yes
echo "🎉 Internal setup completed successfully!"
EOF

# Make the internal script executable and run it inside the Ubuntu environment
chmod +x $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/root/setup_n8n.sh
echo "⚙️ Running n8n setup inside Ubuntu (this will take a few minutes)..."
proot-distro login ubuntu --shared-tmp -- bash /root/setup_n8n.sh

# Cleanup internal setup script
rm $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/root/setup_n8n.sh

echo "------------------------------------------------------------"
echo "✅ Fully hands-free installation complete!"
echo "------------------------------------------------------------"
echo "To start n8n from now on, use this single command:"
echo "proot-distro login ubuntu --shared-tmp -- n8n"
echo ""
echo "Then open your mobile browser to: http://localhost:5678"
echo "------------------------------------------------------------"
