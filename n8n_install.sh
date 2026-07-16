#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 Setting up Ubuntu environment in Termux..."

# 1. Update Termux base using strict 'yes y' pipelining
echo "🔄 Updating Termux repository..."
yes y | pkg update -y
yes y | pkg upgrade -y
yes y | pkg install proot-distro curl -y

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

# Update Ubuntu packages inside the container
yes y | apt-get update
yes y | apt-get upgrade -y
yes y | apt-get install -y curl build-essential

# Install Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
yes y | apt-get install -y nodejs

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
