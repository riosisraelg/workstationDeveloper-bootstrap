#!/bin/zsh

# --- Global Configuration ---
LOG_FILE="$HOME/workstationDeveloper-bootstrap/install.log"
DOTFILES_DIR="$HOME/workstationDeveloper-bootstrap"
BREWFILE="$DOTFILES_DIR/macos/Brewfile"
CONFIG_JSON="$DOTFILES_DIR/macos/aws-config.json"

# Clear previous log
echo "--- macOS Setup Log - $(date) ---" > "$LOG_FILE"

# --- Helper Functions ---
log_info() {
    echo "ℹ️  $1"
    echo "[INFO] $1" >> "$LOG_FILE"
}

log_error() {
    echo "❌ $1"
    echo "[ERROR] $1" >> "$LOG_FILE"
}

run_section() {
    local section_name="$1"
    local func_name="$2"

    echo ""
    log_info "Starting Section: $section_name"
    
    # Run the function; capturing output could be done, but we want live output too.
    # We use a subshell or simple call. Standard call is fine.
    # We capture exit status.
    if $func_name; then
        log_info "Section '$section_name' completed successfully."
    else
        log_error "Section '$section_name' failed or had errors. Continuing to next section..."
    fi
}

# --- Section Definitions ---

install_homebrew() {
    if ! command -v brew &> /dev/null; then
        log_info "Homebrew not found. Installing..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || return 1
        
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        log_info "Homebrew is already installed."
    fi

    log_info "Installing Boring Notch..."
    brew install --cask TheBoredTeam/boring-notch/boring-notch --no-quarantine || true
}

install_packages() {
    if [[ -f "$BREWFILE" ]]; then
        log_info "Installing dependencies from Brewfile..."
        brew bundle --file="$BREWFILE" || return 1
    else
        log_error "Brewfile not found at $BREWFILE!"
        return 1
    fi
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

# --- Execution ---
echo "� Starting macOS Setup..."
log_info "Setup started."

run_section "Homebrew Setup" install_homebrew
run_section "Package Installation" install_packages
run_section "Python Setup" setup_python
run_section "System Defaults" setup_defaults
run_section "Touch ID Setup" setup_touchid
run_section "AWS Config" configure_aws
run_section "Warp Theme" setup_warp
run_section "Dotfiles Link" link_dotfiles
run_section "Tealdeer Update" update_tealdeer
# run_section "Font Installation" install_fonts

echo ""
echo "🎉 macOS Setup Process Finished! (Check $LOG_FILE for any errors)"
log_info "Setup finished."