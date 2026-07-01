#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 🤖 OpenClaw Standalone Installer (No Shizuku) - Native Termux
# =========================================================================
# Designed to run via: curl -sL <url> | bash
# This version removes all Shizuku-specific phone control dependencies.
# =========================================================================

# ── Global Settings ──────────────────────────────────────────────────────
export DEBIAN_FRONTEND=noninteractive
export DPKG_FORCE=confold
export APT_LISTCHANGES_FRONTEND=none
export LANG=C
export LC_ALL=C

echo ""
echo "🤖 OpenClaw Termux Installer (Native)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# =========================================================================
# Step 1/3: Update Packages & Install Dependencies
# =========================================================================
echo "📦 Step 1/3: Updating packages and installing dependencies..."

# Update packages
pkg update -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" </dev/null 2>&1 || {
    echo "⚠️  pkg update had warnings (continuing...)"
}

# Install core dependencies for OpenClaw
pkg install -y curl nodejs git cmake make clang binutils openssl which </dev/null 2>&1 || {
    echo "⚠️  Some packages may have failed to install, checking essentials..."
}

# Verify essentials
MISSING=""
for cmd in curl node git; do
    if ! command -v "$cmd" </dev/null >/dev/null 2>&1; then
        MISSING="$MISSING $cmd"
    fi
done

if [ -n "$MISSING" ]; then
    echo "❌ ERROR: Missing critical commands:$MISSING"
    exit 1
fi

echo "✅ Dependencies installed"

# =========================================================================
# Step 2/3: Fix Node.js IPv4 DNS (Crucial for Termux)
# =========================================================================
echo ""
echo "🔧 Step 2/3: Applying Network Fixes..."
if ! grep -q "NODE_OPTIONS=--dns-result-order=ipv4first" ~/.bashrc 2>/dev/null; then
    echo "export NODE_OPTIONS=--dns-result-order=ipv4first" >> ~/.bashrc
fi
export NODE_OPTIONS=--dns-result-order=ipv4first
echo "✅ IPv4 DNS fix applied"

# =========================================================================
# Step 3/3: Install Official OpenClaw
# =========================================================================
echo ""

if command -v openclaw &>/dev/null || [ -d "$HOME/.openclaw/repo" ]; then
    echo "✅ Step 3/3: OpenClaw is already installed!"
else
    echo "📦 Step 3/3: Installing OpenClaw. This may take a moment..."
    # Running the official install script directly
    bash -c "$(curl -sSL https://myopenclawhub.com/install)" < /dev/tty && source ~/.bashrc 2>/dev/null
fi

# =========================================================================
# 🎉 Done!
# =========================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 INSTALLATION COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "To get started with OpenClaw:"
echo " 1. source ~/.bashrc"
echo " 2. openclaw onboard"
echo " 3. openclaw gateway"
echo ""
