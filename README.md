# Hermes Termux Installer

This repository contains a professional wrapper script (`hermes_install.sh`) to install **[Nous Research's Hermes Agent](https://github.com/NousResearch/hermes-agent)** on Android using the **Termux** app.

It automatically handles the installation of required compiler toolchains (clang, rust, make, etc.), retrieves Android storage permissions, handles background execution settings (Wake Lock), and runs the official installer cleanly.

## 🚀 One-Line Installation

Once you push this repository to GitHub, open the **Termux** app on your Android device and run the following command:

```bash
curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/hermes_install.sh | bash
```

### Passing Installer Options

You can also pass arguments down to the official installer (for example, to skip the setup wizard or download specific branches):

```bash
curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/hermes_install.sh | bash -s -- --skip-setup --branch main
```

---

## 🛠️ What the Installer Does

1. **System & Environment Checks:** Verifies that the environment is Termux and handles fallback prompts.
2. **Repository Mirror Optimization:** Runs `pkg update` and automatically manages Termux mirror fallbacks.
3. **Android Storage & Wake Lock Access:** Prompts for Android Storage permission and runs `termux-wake-lock` to keep the Hermes background process alive.
4. **Pre-installs Native Toolchains:** Headlessly installs compilation dependencies (`clang`, `rust`, `make`, `pkg-config`, `libffi`, `openssl`, `git`, `python`, `nodejs`, `ffmpeg`, `ripgrep`) to ensure the compilation of Python modules (such as `psutil` or cryptography packages) runs smoothly.
5. **Invokes Official Installer:** Fetches and runs the official `install.sh` from Nous Research.
6. **Convenience Shell Aliases:** Appends shortcuts to your `~/.bashrc` (or `~/.zshrc`):
   - `hermes-start`: Launches the TUI (`hermes tui`).
   - `hermes-gateway`: Runs the background messenger gateway (useful if using WhatsApp/Telegram/Discord).
   - `hermes-setup`: Re-runs the configuration setup wizard.

---

## 🔋 Keeping the Agent Running in the Background

Android is very aggressive with battery management and will kill background applications like Termux. To prevent this:

1. **Enable Wake Lock:** The installer automatically attempts to do this, but make sure to accept any notification permissions Termux asks for.
2. **Disable Battery Optimization:** 
   - Go to your Android device **Settings** -> **Apps** -> **Termux**.
   - Tap on **Battery** or **Battery Saver**.
   - Change the setting to **Unrestricted** (or turn off battery optimization).

---

## ⚙️ How to Push this Repository to GitHub

If you haven't pushed this folder to GitHub yet, run these commands in your workstation's terminal:

```bash
# 1. Initialize git and commit changes
git add hermes_install.sh README.md
git commit -m "Add Hermes Termux Installer and README"

# 2. Rename default branch to main (if not already done)
git branch -M main

# 3. Add your remote repository and push (replace with your repo URL)
git remote add origin https://github.com/AbuZar-Ansarii/All-Agents.git
git push -u origin main
```
