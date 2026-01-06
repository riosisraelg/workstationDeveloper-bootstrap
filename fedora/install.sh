#!/bin/bash
set -e

# --- 1. Define Variables ---
DOTFILES_DIR="$(dirname "$(realpath "$0")")/.."
SHARED_VIMRC="$DOTFILES_DIR/shared/.vimrc"
AWS_CONFIG_JSON="$DOTFILES_DIR/macos/aws-config.json"

echo "🐧 Starting Fedora Workstation 43 Setup..."

# --- 2. System Update & Dependencies ---
echo "🔄 Updating system..."
sudo dnf update -y

echo "📦 Installing base dependencies..."
sudo dnf install -y git wget curl python3 python3-pip jq util-linux-user

# --- 3. Install Packages (DNF) ---
# Fedora usually has recent versions of these
echo "📦 Installing development tools..."
sudo dnf install -y gh awscli

# --- 4. Install GUI Apps (Flatpak) ---
# Check if flatpak is installed (it is by default on Fedora Workstation)
if command -v flatpak &> /dev/null; then
    echo "📦 Installing Flatpak applications..."
    # Ensure Flathub is added
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    
    # Discord
    flatpak install -y flathub com.discordapp.Discord
    
    # Obsidian
    flatpak install -y flathub md.obsidian.Obsidian
    
    # Note: Warp for Linux might not be on Flathub yet or requires specific RPM. 
    # Skipping Warp automated install to avoid breaking if URL changes.
    echo "⚠️  Skipping Warp Terminal install (Please install RPM manually from https://www.warp.dev/linux-terminal)"
else
    echo "⚠️  Flatpak not found. Skipping GUI app installation."
fi

# --- 5. Dotfiles (Symlink .vimrc) ---
echo "🔗 Linking .vimrc..."
if [[ -f "$SHARED_VIMRC" ]]; then
    ln -sf "$SHARED_VIMRC" "$HOME/.vimrc"
    echo "✅ Linked .vimrc"
else
    echo "⚠️  Shared .vimrc not found at $SHARED_VIMRC"
fi

# --- 6. Bashrc Configuration ---
# prevent double appending
if ! grep -q "Workstation Bootstrap" "$HOME/.bashrc"; then
    echo "📄 Updating .bashrc..."
    cat << 'EOF' >> "$HOME/.bashrc"

# --- Workstation Bootstrap ---
# Custom Prompt
PS1='\[\033[01;36m\][\u@\h] \[\033[01;33m\]\w\[\033[00m\]\$ '

# Aliases
alias ll='ls -alF'
alias g='git'
alias vim='source /usr/share/vim/vim*/defaults.vim && vim' # Fix for Fedora minimal vim if needed
alias update='sudo dnf update -y && flatpak update -y'

# --- End Workstation Bootstrap ---
EOF
    echo "✅ Updated .bashrc"
else
    echo "✅ .bashrc already configured."
fi

# --- 7. AWS CLI Configuration ---
if [[ -f "$AWS_CONFIG_JSON" ]]; then
    echo "☁️  Configuring AWS CLI..."
    
    AWS_KEY=$(jq -r '.aws_access_key_id' "$AWS_CONFIG_JSON")
    AWS_SECRET=$(jq -r '.aws_secret_access_key' "$AWS_CONFIG_JSON")
    AWS_REGION=$(jq -r '.default_region' "$AWS_CONFIG_JSON")
    AWS_OUTPUT=$(jq -r '.default_output' "$AWS_CONFIG_JSON")

    if [[ -n "$AWS_KEY" && -n "$AWS_SECRET" ]]; then
        aws configure set aws_access_key_id "$AWS_KEY"
        aws configure set aws_secret_access_key "$AWS_SECRET"
    fi
    [[ -n "$AWS_REGION" ]] && aws configure set default.region "$AWS_REGION"
    [[ -n "$AWS_OUTPUT" ]] && aws configure set default.output "$AWS_OUTPUT"
    
    echo "✅ AWS CLI configured."
else
    echo "⚠️  AWS Config JSON not found at $AWS_CONFIG_JSON"
fi

# --- 8. Fonts ---
echo "🅰️  Installing Fonts..."
FONTS_DIR="$DOTFILES_DIR/shared/fonts"
if [[ -d "$FONTS_DIR" ]]; then
    mkdir -p ~/.local/share/fonts
    cp "$FONTS_DIR/"*.ttf ~/.local/share/fonts/
    fc-cache -f -v > /dev/null
    echo "✅ Fonts installed and cache updated."
else
    echo "⚠️  Fonts directory not found at $FONTS_DIR"
fi

echo "🎉 Fedora Setup Complete! Please restart your terminal."
