# All-Agents Termux Installers

This repository contains professional environment preparers and installers to run top-tier autonomous AI agents on Android using **Termux**.

It provides installation wrapper scripts for:
1. **[Hermes Agent](https://github.com/NousResearch/hermes-agent)** (Ubuntu PRoot method) — solves Bionic libc compilation errors by running inside a standard Ubuntu environment.
2. **[OpenClaw Agent](https://github.com/openclaw/openclaw)** (Native Termux method) — runs directly on the device using Node.js LTS and compiler toolchains.

---

## 🦞 1. OpenClaw Installer (Native Termux)

**OpenClaw** is a local-first personal AI assistant gateway that connects messaging apps (WhatsApp, Telegram, Discord, etc.) to AI models. It runs natively in Termux using Node.js.

### 🚀 One-Line Installation

Open the **Termux** app on your Android device and run:

```bash
curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/openclaw_install.sh | bash
```

### 🎮 How to Control OpenClaw
Once installed, the following commands are configured directly in your Termux shell:
*   `openclaw onboard` (or `openclaw-setup`) — Run the interactive wizard to set up LLM providers (Gemini, OpenAI, etc.) and messaging credentials.
*   `openclaw gateway` (or `openclaw-start`) — Run the background messaging connector.
*   `openclaw doctor` (or `openclaw-doctor`) — Runs verification and diagnostics check.
*   **Web Dashboard:** Accessible on your device at `http://127.0.0.1:18789` once the gateway is running.

---

## ⚕ 2. Hermes Agent Installer (Ubuntu PRoot)

**Hermes Agent** is a persistent, self-improving AI agent developed by Nous Research. Because of Bionic libc incompatibilities and Playwright Chromium requirements, it is installed inside a standard Ubuntu environment virtualized via `proot-distro`.

### 🚀 One-Line Installation

Open the **Termux** app on your Android device and run:

```bash
curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/hermes_install.sh | bash
```

### 🎮 How to Control Hermes
Commands run transparently inside the Ubuntu container:
*   `hermes-setup` — Run the model config setup wizard.
*   `hermes-start` — Open the terminal console interface (TUI).
*   `hermes-gateway` — Run the messaging bot connector.
*   `hermes <command>` — Direct CLI access.

---

## 🔋 Crucial Settings for Background Execution

Android's battery manager will kill background services like Termux. To ensure your AI agents stay online:

1. **Acquire Wake Lock:** Both installers automatically invoke `termux-wake-lock`. Make sure a persistent Termux notification remains in your status drawer.
2. **Battery Optimization:**
   - Go to Android **Settings** -> **Apps** -> **Termux**.
   - Tap **Battery** or **Battery Saver**.
   - Set to **Unrestricted** / **No restrictions**.

---

## ⚙️ Push Updates to GitHub

To sync these scripts and documentation with your remote repository, run:

```bash
git add openclaw_install.sh hermes_install.sh README.md
git commit -m "Add OpenClaw native Termux installer and update unified README"
git push origin main
```
