#!/bin/bash
set -e

# --- Define Variables ---
DOTFILES_DIR="$(dirname "$(realpath "$0")")/.."
FONTS_DIR="$DOTFILES_DIR/shared/fonts"
JB_MONO_VER="2.304"
JB_MONO_ZIP="JetBrainsMono-$JB_MONO_VER.zip"
JB_MONO_URL="https://github.com/JetBrains/JetBrainsMono/releases/download/v$JB_MONO_VER/$JB_MONO_ZIP"

echo "🅰️  Setting up Fonts..."

# --- Ensure Fonts Directory Exists ---
mkdir -p "$FONTS_DIR"

# --- Download JetBrains Mono ---
if ls "$FONTS_DIR"/JetBrainsMono*.ttf 1> /dev/null 2>&1; then
    echo "✅ JetBrains Mono already present."
else
    echo "⬇️  Downloading JetBrains Mono v$JB_MONO_VER..."
    cd "$FONTS_DIR"
    curl -L -O "$JB_MONO_URL"
    unzip -o -q "$JB_MONO_ZIP"
    
    # Organize: Move TTFs to root of fonts dir and cleanup
    mv fonts/ttf/*.ttf . || true
    rm -rf fonts "$JB_MONO_ZIP" Authors.txt OFL.txt
    
    echo "✅ Downloaded JetBrains Mono."
fi
