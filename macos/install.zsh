#!/bin/zsh

# --- Global Configuration ---
DOTFILES_DIR="$HOME/Downloads/workstationDeveloper-bootstrap"
CONFIG_JSON="$DOTFILES_DIR/macos/aws-config.json"

install_homebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo >> /Users/riosisraelg/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/riosisraelg/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    brew update
    brew upgrade
    brew install git
    brew install wget
    brew install python
    brew install openjdk
    brew install node
    brew install yarn
    brew install mas
    brew install awscli
    brew install jq
    brew install gemini-cli
    brew install tealdeer
    brew install mole
    brew install ykman

    brew install --cask antigravity
    brew install --cask warp
    brew install --cask TheBoredTeam/boring-notch/boring-notch --no-quarantine
    brew install --cask arc
    brew install --cask antinote
    brew install --cask domzilla-caffeine
    brew install --cask notion
    brew install --cask obsidian
    brew install --cask raycast
    brew install --cask rustdesk
    brew install --cask modrinth
    brew install --cask minecraft
    brew install --cask whatsapp
    brew install --cask discord
    brew install --cask onedrive
    brew install --cask google-drive
    brew install --cask mactex-no-gui

    mas install 302584613
    mas install 310633997
    mas install 1358823008
}

setup_python() {
    local python_path='export PATH="/usr/local/opt/python/libexec/bin:$PATH"'
    if ! grep -Fq "$python_path" "$HOME/.zshrc"; then
        echo "$python_path" >> "$HOME/.zshrc"
    fi

    python3 --version || return 1
    pip3 install --upgrade pip
    pip3 install pandas --break-system-packages 2>/dev/null || pip3 install pandas
    
    if python3 -c "import pandas; print('Pandas verified')" &> /dev/null; then
    fi
}

setup_third_party() {
    local download_url="https://dl.wisprflow.ai/mac-apple/latest"
    local dmg_name="wisprflow.dmg"

    cd "$HOME/Downloads"
    curl -L -o "$dmg_name" "$download_url"
    cd "$HOME"
}

setup_defaults() {    
    # General UI
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    defaults write com.apple.dock autohide -bool true
    
    # App Specific
    defaults write com.google.antigravity ApplePressAndHoldEnabled -bool false
}

setup_touchid() {
    sudo mo touchid
}

configure_aws() {
    mkdir -p "$HOME/.aws"
    if [[ -f "$CONFIG_JSON" ]]; then        
        # Read keys
        local aws_key=$(jq -r '.aws_access_key_id // empty' "$CONFIG_JSON")
        local aws_secret=$(jq -r '.aws_secret_access_key // empty' "$CONFIG_JSON")
        local aws_region=$(jq -r '.default_region // empty' "$CONFIG_JSON")
        local aws_output=$(jq -r '.default_output // empty' "$CONFIG_JSON")

        if [[ -n "$aws_key" && -n "$aws_secret" ]]; then
            aws configure set aws_access_key_id "$aws_key"
            aws configure set aws_secret_access_key "$aws_secret"
        fi

        [[ -n "$aws_region" ]] && aws configure set default.region "$aws_region"
        [[ -n "$aws_output" ]] && aws configure set default.output "$aws_output"
    fi
}

setup_warp() {
    local warp_dir="$HOME/.warp"
    local themes_dir="$warp_dir/themes"

    mkdir -p "$warp_dir"
    
    # Clone to temp dir first to ensure git success before deleting old themes
    local tmp_theme_dir=$(mktemp -d)
    if git clone --quiet https://github.com/warpdotdev/themes.git "$tmp_theme_dir"; then
        mkdir -p "$themes_dir"
        
        # Copy standard themes
        cp "$tmp_theme_dir/standard/"* "$themes_dir/" 2>/dev/null || true
        # Or copy all if structure differs
        cp "$tmp_theme_dir/"*.yaml "$themes_dir/" 2>/dev/null || true
        
        rm -rf "$tmp_theme_dir"
    fi
}

link_dotfiles() {
    if [[ -f "$DOTFILES_DIR/shared/.vimrc" ]]; then
        cp "$DOTFILES_DIR/shared/.vimrc" "$HOME/.vimrc"
    fi
}

update_tealdeer() {
    if command -v tldr &> /dev/null; then
        tldr --update &> /dev/null || true
    fi
}

# --- Execution Flow ---

echo "🚀 Starting macOS Workstation Setup..."

# 1. Core Tools
install_homebrew

# 2. Languages & Runtime
run_section "Python Setup" setup_python

# 3. System Config
run_section "System Defaults" setup_defaults
run_section "Touch ID Setup" setup_touchid
run_section "AWS Config" configure_aws

# 4. UI & Apps
run_section "Warp Theme" setup_warp
run_section "Third Party Apps" setup_third_party
run_section "Dotfiles Link" link_dotfiles
run_section "Tealdeer Update" update_tealdeer

echo ""
echo "🎉 macOS Setup Process Finished!"
echo "📄 Log file available at: $LOG_FILE"
