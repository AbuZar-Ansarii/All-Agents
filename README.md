# 🤖 Termux AI Agent Suite

A collection of optimized, professional installer scripts to run state-of-the-art autonomous AI agents natively or virtualized on Android devices using **Termux**.

---

## 📊 Agent Comparison Matrix

| Agent | Environment | Installation Type | Quick Install Command |
| :--- | :--- | :--- | :--- |
| **🦞 OpenClaw** | Termux (Native) | Node.js (Standalone) | `curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/openclaw_install.sh \| bash` |
| **⚕ Hermes** | PRoot (Ubuntu) | Python/Venv + Node.js | `curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/hermes_install.sh \| bash` |
| **🧠 OpenClaude** | Termux (Native) | Vanilla Shell Script | `curl -sL "https://raw.githubusercontent.com/AbuZar-Ansarii/free-openclaude/master/vanila_install.sh" \| bash` |

---

## 🦞 1. OpenClaw Agent (Native Termux)

**OpenClaw** is a local-first personal AI assistant gateway that connects multiple messaging interfaces (WhatsApp, Telegram, Discord, etc.) directly to your AI models.

### 🚀 Installation
```bash
curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/openclaw_install.sh | bash
```

### ⚙️ Command Directory
Run these commands directly in your Termux command line:
*   `openclaw onboard` — Start the interactive model configuration setup.
*   `openclaw gateway` — Boot up the background chat connectors.
*   `openclaw doctor` — Run diagnostics to check configs and credentials.
*   **Web Console:** Accessible at `http://127.0.0.1:18789` once the gateway is active.

---

## ⚕ 2. Hermes Agent (PRoot Ubuntu)

**Hermes** is a persistent, self-improving AI agent developed by Nous Research. Because of Python wheel compilation requirements and Playwright Chromium control interfaces on Android, it runs inside an Ubuntu container via `proot-distro` for maximum compatibility.

### 🚀 Installation
```bash
curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/hermes_install.sh | bash
```

### ⚙️ Command Directory
The installer adds wrapper binaries to Termux so you can execute these transparently:
*   `hermes-setup` — Run the model config setup wizard.
*   `hermes-start` — Open the terminal console interface (TUI).
*   `hermes-gateway` — Run the messaging bot connector.
*   `hermes <command>` — Direct CLI access.

---

## 🧠 3. OpenClaude Agent (Native / Vanilla)

**OpenClaude** is an autonomous terminal agent workspace designed to interact natively with your environment using optimized vanilla shell installers.

### 🚀 Installation
```bash
curl -sL "https://raw.githubusercontent.com/AbuZar-Ansarii/free-openclaude/master/vanila_install.sh" | bash
```

---

## 🔋 Crucial Background Execution Guard

Android OS aggressively stops background apps like Termux to preserve battery. To prevent your AI gateways from going offline:

1. **Enable Wake Lock:** Keep the CPU awake. The installers run `termux-wake-lock` automatically. Ensure you keep the Termux background notification active in your notification drawer.
2. **Disable Battery Optimization:**
   - Go to your Android **Settings** -> **Apps** -> **Termux**.
   - Tap **Battery** or **Battery Saver**.
   - Change the setting to **Unrestricted** (or turn off battery optimization).

---

## ⚙️ Push Updates to GitHub

To sync changes made on your workstation back to your remote repository, run:

```bash
git add openclaw_install.sh hermes_install.sh README.md
git commit -m "Update and refine installer suite README"
git push origin main
```
