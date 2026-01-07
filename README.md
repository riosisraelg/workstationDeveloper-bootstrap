# workstationDeveloper-bootstrap

**One repository to rule them all.**

This repository contains my personal system configurations, installation scripts, and dotfiles. It is designed to automate the bootstrapping process of a fresh machine across the three operating systems I use daily.

## Quick Start

Setup permissions for the scripts:

```bash
chmod +x ./windows/install.ps1
chmod +x ./fedora/install.sh
chmod +x ./macos/install.zsh
```

Then run the scripts:

```bash
./windows/install.ps1   
./fedora/install.sh
./macos/install.zsh
```

## 🖥️ Supported Environments

| OS | Shell | Script Entry Point |
| :--- | :--- | :--- |
| **Windows 11** | PowerShell | `./windows/install.ps1` |
| **Fedora Workstation 43** | Bash | `./fedora/install.sh` |
| **macOS 26.1** | Zsh | `./macos/install.zsh` |

## 📦 What's Included

* **Package Management:**
  * **Windows:** `winget` and `choco` packages.
  * **Fedora:** `dnf` repositories and packages.
  * **macOS:** `Homebrew` formulas and casks and `mas` apps (mac app store).
* **App Preferences:** Automated settings for VS Code, Terminal, and Git.
* **Fonts:** Not font decied
