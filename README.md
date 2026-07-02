# 🤖 Termux AI Agent Suite

A collection of optimized, professional installer configurations to run state-of-the-art autonomous AI agents natively or virtualized on Android devices using **Termux**.

---

## 📊 Agent Comparison Matrix

| Agent | Environment | Installation Type | Key Focus & Characteristics |
| :--- | :--- | :--- | :--- |
| **🦞 OpenClaw** | PRoot (Ubuntu) | Node.js (Global) | Local-first personal AI assistant gateway connecting chats (WhatsApp, etc.) inside a stable glibc Ubuntu environment. |
| **⚕ Hermes (Native)** | Termux (Native) | Python/Venv + Node.js | Lightweight native Termux version of the persistent self-learning agent (runs directly on device CPU). |
| **⚕ Hermes (PRoot)** | PRoot (Ubuntu) | Python/Venv + Node.js | Virtualized Ubuntu version of Hermes solving native Bionic libc compilation and browser control socket errors. |
| **🧠 OpenClaude** | Termux (Native) | Vanilla Shell Script | Lightweight, autonomous terminal coder and assistant running natively without container overhead. |



---

## ✨ Suite Features

*   **Hybrid Execution Models:** Run lightweight scripts directly inside Termux or opt for a full glibc-compliant virtualized Ubuntu container when standard library compatibility is required.
*   **Persistent Services:** Built-in Wake-Lock management ensures background messaging gateways (WhatsApp, Telegram, Discord) remain online 24/7.
*   **Web Dashboard Access:** Direct support for routing visual control dashboards to local ports (e.g., port 18789) for interactive browser configurations.
*   **Native Build Configuration:** Automatic configuration of C++ compilation toolchains (`clang`, `make`, `binutils`) to support compiling native modules on Android.

---

## 📋 Prerequisites

Before installing any agent, ensure your environment meets the following conditions:
*   **Official Termux App:** Do not use the deprecated version from the Google Play Store. You must install the modern build from [F-Droid](https://f-droid.org/packages/com.termux/) or the [Termux GitHub Releases](https://github.com/termux/termux-app).
*   **Active Internet Connection:** Stable connection is required to fetch compiler tools, Node packages, or container images.
*   **LLM API Keys:** You will need API credentials (e.g., Gemini, OpenRouter, Anthropic, or OpenAI keys) to authorize model requests during onboarding.
*   **FREE API key** Visit the OpenCode [OpenCodeZen Free API]([https://github.com/termux/termux-app](https://opencode.ai/))
---

## 🦞 1. OpenClaw Agent (Ubuntu PRoot)

OpenClaw connects your messaging accounts to AI models to automate tasks using a stable Node.js environment inside a virtualized Ubuntu container (which bypasses Bionic libc and glibc dynamic linker/runner errors).

### 🚀 Installation
```bash
curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/openclaw_install.sh | bash
```

### ⚙️ Quick Reference Commands
*   **Onboarding:** `openclaw onboard` (or `openclaw-setup`)
*   **Start gateway:** `openclaw gateway` (or `openclaw-start`)
*   **Get gateway token:** `openclaw-token` *(Prints your gateway authorization token)*
*   **Openclaw dashboard:** `http://127.0.0.1:18789`

---

## ⚕ 2. Hermes Agent (Dual Methods)

Hermes is a persistent agent that creates its own skills. You can install it natively or inside a virtualized Ubuntu container depending on your compatibility requirements.

### 🚀 Installation (Interactive Selector)
Run this single interactive script to select between the Native (default) and PRoot Ubuntu installation methods:
```bash
curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/All-Agents/main/hermes_install.sh | bash
```

### ⚙️ Quick Reference Commands
*   `hermes-setup` — Initialize LLM models and API credentials.
*   `hermes-start` — Open the terminal console interface (TUI).
*   `hermes-gateway` — Run the background bot connector.
*   `hermes <command>` — Directly run CLI tools.

---

## 🧠 3. OpenClaude Agent 

OpenClaude is an autonomous developer workspace running natively on your phone via vanilla shell installations.

### 🚀 Installation
```bash
curl -sL "https://raw.githubusercontent.com/AbuZar-Ansarii/free-openclaude/master/vanila_install.sh" | bash
```
---


## 🔋 Android Background Optimization

To prevent Android's battery manager from terminating your active agent processes in the background:

1. **Acquire Wake Lock:** Keep the CPU awake. The wrapper scripts automatically trigger `termux-wake-lock`. Ensure you do not close the persistent Termux notification in your status bar.
2. **Disable Battery Optimization:**
   - Open Android **Settings** -> **Apps** -> **Termux**.
   - Tap **Battery** or **Battery Saver**.
   - Change the setting to **Unrestricted** (or turn off battery optimization/restrictions).

---

## 🛠️ Troubleshooting

### 1. Mirror Connection / Package Locating Errors
If packages fail to install or update:
*   Run `termux-change-repo` in Termux.
*   Select **Main Repository** and switch your mirror to a reputable host (e.g., **Mirror by Grimler** or **Cloudflare**).
*   Run `pkg update -y` and retry the installer.

### 2. DNS / Network Timeout Failures
If Node.js throws network timeout or hostname resolution errors:
*   Ensure the DNS fix is loaded by running `source ~/.bashrc`.
*   Verify that `NODE_OPTIONS` environment variable is active: `echo $NODE_OPTIONS` (should output `--dns-result-order=ipv4first`).
