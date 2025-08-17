<p align="center">
  <h1 align="center">slowfetch</h1>
</p>

<p align="center">
  <strong>A highly customizable and feature-rich fetch tool powered by fastfetch and shell scripts.</strong>
</p>

---

## 📸 Preview

<div align="center">
  <img src="https://private-user-images.githubusercontent.com/66126148/456020217-b654e44b-d0a8-4b0c-8203-0bce603bbb3b.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTUzOTk2NDgsIm5iZiI6MTc1NTM5OTM0OCwicGF0aCI6Ii82NjEyNjE0OC80NTYwMjAyMTctYjY1NGU0NGItZDBhOC00YjBjLTgyMDMtMGJjZTYwM2JiYjNiLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA4MTclMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwODE3VDAyNTU0OFomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWY1YmU5YjU4MmMyMTEyYzQxNWQwM2E5ZmJjODUxNzBiN2YxMTA5MzhkN2M1MjZkNWVlNDJiODNlNjliMzAyMTQmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.PGp6YW1u5-sszLMWsMouYnSaUYbZmxrpIazqOu7gCJo" width="85%">
</div>

---

## 📖 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Installation](#installation)
- [Dependencies](#dependencies)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

---

## 🧩 Overview <a name="overview"></a>

**slowfetch** is not a standalone fetch program, but a comprehensive configuration layer built on top of the incredibly fast and versatile [fastfetch](https://github.com/fastfetch-cli/fastfetch). It provides a curated collection of powerful shell scripts and a beautiful default theme, all managed by an interactive command-line utility.

The goal is to provide a visually appealing and highly informative fetch experience out-of-the-box, while giving you an easy way to customize every aspect of it. Please note that some dynamic metrics, such as internet speed or current CPU frequency, are estimates and may not always be perfectly accurate.

---

## 🚀 Key Features <a name="key-features"></a>

- **Interactive Configurator ⚙️**: An easy-to-use command-line interface (`launcher.sh`) handles installation, uninstallation, and all configuration changes. No need to manually edit JSON files.
- **Extensive Custom Modules ` scripting:`**: Comes packed with over 20 custom scripts to display information that fastfetch doesn't show by default, including:
    - **Currency Rates**: Show exchange rates from configurable sources (e.g., `USD/RUB`, `EUR/GBP`).
    - **GitHub Stars**: Fetches the total star count for your repositories.
    - **News Headlines**: Pulls the latest headline from sources like OpenNet, Phoronix, or LWN.
    - **Disk Health**: Displays detailed info for each drive, including vendor, type (NVMe/SSD/HDD), usage, and filesystem.
    - **RAM Specs**: Shows RAM type, module size, and frequency.
    - **Last System Update**: Tells you how long ago your last package manager update was.
- **Easy Customization 🎨**: The configurator allows you to visually add, remove, and reorder any module to create the perfect layout for your needs.
- **Smart Sudo Handling ✨**: The installer can automatically configure passwordless `sudo` for the single `smartctl` command, allowing the `disk_info.sh` script to run without password prompts in the most secure way possible.
- **Localization 🌐**: The configurator interface is available in both English and Russian.

---

## 🛠️ Installation <a name="installation"></a>

### 🐧 Linux

The installation is managed by a self-contained launcher script.

```bash
# 1. Clone the repository
git clone https://github.com/YourUsername/slowfetch.git

# 2. Navigate into the directory
cd slowfetch

# 3. Make the launcher executable
chmod +x launcher.sh

# 4. Run the launcher to install
./launcher.sh
```
The script will guide you through the first-time setup, check for dependencies, configure aliases (`slowfetch` and `slowfetch-config`), and copy all necessary files to `~/.config/fastfetch`.

> **OS Compatibility Note**
>
> Guaranteed to work on **Arch Linux** and its derivatives. Most scripts have been field-tested on different computers with various hardware specifications.
>
> While the modules are designed with portability in mind, functionality on other distributions (Debian, Fedora, etc.) is not guaranteed. It is highly likely to work correctly if all [dependencies](#dependencies) are met, but some modules may behave unexpectedly. As this is an ambitious configuration layer, perfect out-of-the-box operation on every unique system cannot be guaranteed. You can expect a high degree of compatibility (likely 80-90%), but it's possible some modules may not function as expected.

---

## 📦 Dependencies <a name="dependencies"></a>

For all modules to function correctly, you will need `fastfetch` and several other command-line tools. The installer will warn you if any are missing.

- **Core**: `fastfetch`, `jq`
- **For `disk_info.sh`**: `smartmontools` (provides `smartctl`), `util-linux` (provides `lsblk`, `findmnt`), `coreutils` (provides `df`)
- **For `currency_rate.sh`**: `curl`, `xmlstarlet`, `bc`
- **For `github_stars.sh`**: `gh` (GitHub CLI)
- **For `ram_specs.sh`**: `inxi`
- **For `news.sh`**: `curl`, `xmlstarlet`, `iconv` (for OpenNet)
- **Other Utilities**: `playerctl` (for media), `xrandr` (for orientation), `nvidia-smi` (for VRAM), etc.

---

## 🧪 Usage <a name="usage"></a>

Once installed, two new aliases will be available in your shell (you may need to restart it or `source` your `.bashrc`/`.zshrc`).

- **`slowfetch`**: Runs the configured fastfetch instance to display your system information.
- **`slowfetch-config`**: Launches the interactive configurator again to manage your setup.

The configurator menu allows you to:
1.  **Show/refresh** the current module list.
2.  **Move** modules up or down.
3.  **Remove** a module from the list.
4.  **Add** a new module from the available scripts.
5.  **Configure** specific modules (like GitHub Stars, News source, or Currency Rate).
6.  **Reset** the configuration to the default.
7.  **Uninstall** slowfetch completely.

---

## 🤝 Contributing <a name="contributing"></a>

Feel free to fork, submit [issues](https://github.com/Loganavter/Improve-ImgSLI/issues), or open [PRs](https://github.com/Loganavter/Improve-ImgSLI/pulls). Contributions are welcome!
  
---

## 📄 License <a name="license"></a>

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## 🧠 Development Story <a name="development-story"></a>

<details>
<summary>How slowfetch came to be</summary>

My journey with what would become slowfetch began around January 2025, as I started delving into the possibilities of `fastfetch`. The initial concept was ambitious and thematic: an over-the-top "mega Arch btw" fetch. I envisioned a theme of worship, complete with Bible verses, a church background in the terminal, and a glowing Arch logo.

As I added more modules, the project's focus shifted from aesthetics to pure functionality. I wanted to flex what was possible, creating modules that were significantly more informative than their standard counterparts. A prime example is the disk module, which evolved into a mini-"gparted," capable of even identifying USB flash drives. The development process relied heavily on AI assistance, and throughout this path, I used a wide array of models: DeepSeek, Qwen, Claude, ChatGPT, Grok, and Gemini.

The main development hurdle was my workflow. Not realizing I could simply call an external `.sh` script from the config, I forced the AIs to generate complex logic as a single, heavily-escaped line to be embedded directly into the JSON. This was a nightmare, as the complex escaping and convoluted logic were incredibly difficult for the models to handle correctly.

For several months, I wanted to share my creation, but it was too tailored to my personal setup—more of a private config than a public project. The breakthrough came in a single, intense 7-hour session. Using Gemini and Cursor AI, I finally refactored the entire project. The monolithic configuration was broken down into a clean, modular collection of individual scripts. During this sprint, I tested everything, wrote a few new modules, and iteratively built the installer which also serves as the interactive configurator you see today. What started as a personal experiment has now been transformed into a polished, distributable tool.

</details>
