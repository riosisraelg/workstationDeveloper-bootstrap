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
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || return 1
        
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        log_info "Homebrew is already installed."
    fi
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
    log_info "Checking Python and installing Pandas..."
    # User's custom python setup
    # Note: modifying .bash_profile from zsh script affects bash sessions, not necessarily this one immediately unless sourced effectively.
    # But we will execute as requested.
    
    # We use 'try' blocks for individual commands if we want granularity, 
    # but here we just run the block.
    {
        echo 'export PATH="/usr/local/opt/python/libexec/bin:$PATH"' >> ~/.bash_profile
        # Sourcing bash_profile in zsh might warn, but we try standard source
        # If it fails, we catch it.
        source ~/.bash_profile || true 
        
        python3 --version
        sleep 5
        python3 -c "import pandas as pd; print(pd.__version__)" || true # Log but continue
        sleep 5
        pip3 install pandas
    } || return 1
}

setup_defaults() {
    log_info "Applying macOS System Defaults..."
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    defaults write com.apple.dock autohide -bool true
    defaults write com.google.antigravity ApplePressAndHoldEnabled -bool false
    
    # Passwords app
    defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Passwords.app</string><key>_CFURLFileTypeID</key><string>com.apple.application-bundle</string></dict></dict></dict>" || true

    # Caffeine
    if [[ -d "/Applications/Caffeine.app" ]]; then
        osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Caffeine.app", hidden:false}' || true
    fi
}

setup_touchid() {
    if command -v mole &> /dev/null; then
        log_info "Enabling Touch ID for sudo via mole..."
        sudo mo touchid || return 1
    fi
}

configure_aws() {
    if [[ -f "$CONFIG_JSON" ]]; then
        log_info "Configuring AWS CLI..."
        AWS_KEY=$(jq -r '.aws_access_key_id' "$CONFIG_JSON")
        AWS_SECRET=$(jq -r '.aws_secret_access_key' "$CONFIG_JSON")
        AWS_REGION=$(jq -r '.default_region' "$CONFIG_JSON")
        AWS_OUTPUT=$(jq -r '.default_output' "$CONFIG_JSON")

        if [[ -n "$AWS_KEY" && -n "$AWS_SECRET" ]]; then
            aws configure set aws_access_key_id "$AWS_KEY"
            aws configure set aws_secret_access_key "$AWS_SECRET"
        fi
        [[ -n "$AWS_REGION" ]] && aws configure set default.region "$AWS_REGION"
        [[ -n "$AWS_OUTPUT" ]] && aws configure set default.output "$AWS_OUTPUT"
    fi
}

setup_warp() {
    log_info "Generating Warp Theme..."
    mkdir -p $HOME/.warp
    # Run in subshell to avoid directory change affecting main script
    (
        cd $HOME/.warp/ || exit
        if [[ -d "themes" ]]; then rm -rf themes; fi
        git clone https://github.com/warpdotdev/themes.git || exit
        mkdir -p "$HOME/.warp/themes/"
        mv themes/* "$HOME/.warp/themes/"
        rm -rf themes
    ) || return 1
}

link_dotfiles() {
    log_info "Linking .vimrc..."
    if [[ -f "$DOTFILES_DIR/shared/.vimrc" ]]; then
        ln -sf "$DOTFILES_DIR/shared/.vimrc" "$HOME/.vimrc"
    fi
}

update_tealdeer() {
    if command -v tldr &> /dev/null; then
        tldr --update || true
    fi
}

install_fonts() {
    # Currently commented out by user request/state, but logic is here for future enablement.
    # log_info "Installing Fonts..."
    # if [[ -d "$DOTFILES_DIR/shared/fonts" ]]; then
    #     cp "$DOTFILES_DIR/shared/fonts/"*.ttf ~/Library/Fonts/
    #     log_info "Fonts installed to ~/Library/Fonts/"
    # else
    #     log_error "Fonts directory not found at $DOTFILES_DIR/shared/fonts"
    # fi
    : # pass
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