# dotfiles

**One repository to rule them all.**

This repository contains my personal system configurations, installation scripts, and dotfiles. It is designed to automate the bootstrapping process of a fresh machine across the three operating systems I use daily.

## 🖥️ Supported Environments

| OS | Shell | Script Entry Point |
| :--- | :--- | :--- |
| **Windows 11** | PowerShell | `./install.ps1` |
| **Fedora Workstation 43** | Bash | `./install.sh` |
| **macOS 26.1** | Zsh | `./install.zsh` |

## 📦 What's Included

* **Shell Configurations:** Custom setups for `.zshrc`, `.bashrc`, and PowerShell profiles.
* **Package Management:**
    * **Windows:** `winget` and `choco` packages.
    * **Fedora:** `dnf` repositories and packages.
    * **macOS:** `Homebrew` formulas and casks.
* **App Preferences:** Automated settings for VS Code, Terminal, and Git.
* **Fonts:** Nerd Fonts installation scripts.

## 🚀 Installation

### Windows 11
Open PowerShell as Administrator and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
git clone [https://github.com/YOUR_USERNAME/dotfiles.git](https://github.com/YOUR_USERNAME/dotfiles.git)
cd dotfiles/windows
.\setup.ps1
