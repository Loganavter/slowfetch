<p align="center">
  <h1 align="center">slowfetch</h1>
</p>

<p align="center">
  <strong>A highly customizable configuration layer and TUI manager for Fastfetch with 20 custom scripts.</strong>
</p>

---

## 📸 Preview

<div align="center">
  <img src="https://habrastorage.org/webt/wa/lt/fg/waltfg9oc73hxy8d7pcy2mgu05e.jpeg" width="85%">
</div>

---

## 🧭 Quick Links

- **Installation**: [docs/INSTALL.md](docs/INSTALL.md)
- **Development History**: [HISTORY.md](HISTORY.md)
- **Supported Modules**: See the `scripts/` directory for full list.

---

## 🧩 Overview

**slowfetch** is a powerful wrapper and distribution for [Fastfetch](https://github.com/fastfetch-cli/fastfetch). Instead of manually editing JSON files, it provides an interactive **Terminal User Interface (TUI)** to manage your system fetch.

It includes a curated collection of bash scripts that extend Fastfetch capabilities, showing information like system age, detailed disk stats, currency rates, news, and even GitHub repository stars.

---

## 🚀 Key Features

- **Interactive TUI Editor ⚙️**: Add, remove, and reorder modules visually using an arrow-key interface.
- **Custom Script Library 📜**: Over 20 specialized scripts including:
    - **Hardware**: RAM specs (with slots/frequency), VRAM info, Disk info (NVMe/SSD/HDD detection), Mouse info.
    - **System**: OS Age, Last Update time, Display orientation, Network speed.
    - **Web & API**: Live Currency Rates (CBR/ECB), GitHub Stars, Daily News (OpenNet, Phoronix, LWN).
    - **Media**: Player status, media underline, and album art (via `chafa`).
- **Dependency Checker 🔍**: Automatically checks if required tools (like `inxi`, `jq`, `curl`) are installed for each module.
- **Easy Configuration 🛠️**: Built-in menu to configure API keys, news sources, and currency pairs.
- **Smart Alias Management**: Creates `slowfetch` for the app and `slowfetch-config` for the manager.
- **Localization 🌐**: Full interface support for both **English** and **Russian**.

---

## 📦 Dependencies

The core manager requires `jq` and `curl`. Individual modules may require:
- **System Info**: `inxi`, `lsblk`, `df`, `findmnt`, `udevadm`
- **Media/Graphics**: `playerctl`, `chafa`, `nvidia-smi`, `xrandr`/`wlr-randr`
- **Web**: `xmlstarlet`, `iconv`, `gh` (GitHub CLI)

---

## 🤝 Contributing

Feel free to submit issues or pull requests. If you want to add a new script, place it in the `scripts/` folder and update the dependency map in `core/config_manager.sh`.

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
