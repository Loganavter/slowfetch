# Installation Guide

This document describes how to install, update, and uninstall **slowfetch**.

## 🛠 Quick Install

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Loganavter/slowfetch.git
   cd slowfetch
   ```

2. **Make the launcher executable**:
   ```bash
   chmod +x launcher.sh
   ```

3. **Run the installer**:
   ```bash
   ./launcher.sh
   ```

The script will:
- Check for the `jq` dependency.
- Offer to install the project to `~/.config/fastfetch`.
- Set up aliases (`slowfetch` and `slowfetch-config`) in your `.bashrc` or `.zshrc`.
- Move your existing Fastfetch configuration to a backup folder if it exists.

---

## 🧪 Usage

Once installed, you can use these commands:

- `slowfetch` — Runs Fastfetch with your custom configuration.
- `slowfetch-config` — Opens the interactive TUI to manage modules and settings.

---

## 🗑 Uninstallation

To completely remove **slowfetch** and restore your original configuration:
1. Run `slowfetch-config`.
2. Choose the **Uninstall** option (`u`).
3. Confirm the action.

The manager will remove aliases and try to restore files from the `.backup` folder created during installation.

---

## ⚠️ OS Compatibility

Developed and tested on **Arch Linux**.
- **Supported Shells**: Bash, Zsh.
- **Compatibility**: Logic for `apt`, `dnf`, `zypper`, and `nix` is included in the "Last Update" script, but primary testing is done on Arch-based systems.
