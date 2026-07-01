# Hermes Termux Ubuntu-PRoot Installer

This repository contains a professional wrapper installer (`hermes_install.sh`) to run **[Nous Research's Hermes Agent](https://github.com/NousResearch/hermes-agent)** on Android inside a native **Ubuntu glibc container** using Termux and `proot-distro`.

Running Hermes inside a standard Ubuntu environment solves common compilation issues, library incompatibilities, and browser control socket limitations on Android (such as Playwright Chromium and SQLite issues). It provides a standard, robust execution environment while keeping it completely transparent to use.

---

## 🚀 One-Line Installation

Open the **Termux** app on your Android device and execute the following command:

```bash
curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/hermes_install.sh | bash
```

### Passing Options to the Installer

Any command-line options you pass to this wrapper will automatically be forwarded to the official installer running inside the Ubuntu container:

```bash
curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/hermes_install.sh | bash -s -- --skip-setup --branch main
```

---

## ⚙️ How It Works (Behind the Scenes)

1. **Termux Environment Prep:** Updates Termux package repositories, and installs `proot-distro` and native utilities (`curl`, `git`).
2. **Ubuntu Environment Setup:** Downloads, installs, and starts a standard Ubuntu image using `proot-distro`.
3. **Ubuntu Bootstrapping:** Installs compilation headers and packages (`python3-venv`, `python3-pip`, `build-essential`, `curl`, `git`, `dbus`, etc.) inside the container.
4. **Official Hermes Installation:** Runs the official Hermes installer inside the virtualized Ubuntu environment. It installs `uv`, configures virtual environments, and installs package dependencies natively.
5. **Termux Wrapper Commands:** Generates wrapper scripts under Termux's `$PREFIX/bin` to allow executing Hermes commands directly from Termux.

---

## 🎮 How to Control the Agent from Termux

The installer configures commands that execute transparently inside the Ubuntu container. You can run them directly in your Termux shell:

*   `hermes` - Access the Hermes CLI.
*   `hermes-setup` - Run the configuration wizard (API keys, model configuration).
*   `hermes-start` - Start the interactive terminal dashboard (TUI).
*   `hermes-gateway` - Run the background bot integration (Telegram, Slack, Discord, WhatsApp).

---

## 📁 Accessing Config & Data Files

Although Hermes runs inside the Ubuntu container, all its files are stored on your device and can be accessed or edited directly from Termux.

The root home directory of the Ubuntu container is located at:
```
/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/root
```

This means your Hermes configuration folders live at:
*   **API Keys / Environment:** `/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/root/.hermes/.env`
*   **YAML Config:** `/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/root/.hermes/config.yaml`
*   **Custom Skills / Memory:** `/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/root/.hermes/`

For example, to configure your API keys from Termux, simply run:
```bash
nano /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/root/.hermes/.env
```

---

## 🔋 Preventing Android from Killing the Agent

Android's background execution limits can terminate background processes like Termux. To prevent this:

1. **Acquire Wake Lock:** The installer automatically calls `termux-wake-lock`. You will see a persistent notification saying Termux is running in the background. Do not close this notification.
2. **Disable Battery Optimization:**
   - Go to your Android device **Settings** -> **Apps** -> **Termux**.
   - Tap on **Battery** or **Battery Saver**.
   - Set it to **Unrestricted** / **No restrictions**.
