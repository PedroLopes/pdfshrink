#!/usr/bin/env bash
set -e

TOOL_NAME="pdfshrink"
TOOL_FILE="pdfshrink.sh"
INSTALL_DIR="$HOME/.local/$TOOL_NAME"
BIN_DIR="$HOME/.local/bin"
DEPENDENCY=gs

echo "Installing $TOOL_NAME..."

echo "First, checking if $DEPENDENCY is installed..."

# Check if Ghostscript (gs) is installed, then select installed based on OS
if ! command -v gs >/dev/null 2>&1; then
    echo "$DEPENDENCY not found."
    
    # Detect OS
    OS="$(uname)"
    
    if [[ "$OS" == "Darwin" ]]; then
        # macOS
        if command -v brew >/dev/null 2>&1; then
            echo "Homebrew detected. Installing Ghostscript via brew..."
            brew install ghostscript || { echo "Failed to install Ghostscript via brew. Please install manually."; exit 1; }
        else
            echo "Homebrew not found. Please install Ghostscript manually:"
            echo "  https://www.ghostscript.com/"
            exit 1
        fi
    elif [[ "$OS" == "Linux" ]]; then
        if command -v apt >/dev/null 2>&1; then
            echo "APT detected. Installing Ghostscript via sudo apt..."
            sudo apt update && sudo apt install -y ghostscript || { echo "Failed to install Ghostscript via apt. Please install manually."; exit 1; }
        else
            echo "No supported package manager detected. Please install Ghostscript manually:"
            echo "  https://www.ghostscript.com/"
            exit 1
        fi
    else
        echo "Unsupported OS. Please install Ghostscript manually:"
        echo "  https://www.ghostscript.com/"
        exit 1
    fi
    echo "$DEPENDENCY installation complete. Continuing..."
fi

# Ensure directories exist
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

# Copy script
cp "$TOOL_FILE" "$INSTALL_DIR/$TOOL_NAME"

# Create launcher
cat > "$BIN_DIR/$TOOL_NAME" <<EOF
#!/usr/bin/env bash
exec "$INSTALL_DIR/$TOOL_NAME" "\$@"
EOF

chmod +x "$BIN_DIR/$TOOL_NAME"

read -p "Add ~/.local/bin to your PATH? [y/N] " answer
[[ "$answer" != "y" ]] && exit 0

SHELL_NAME=$(basename "$SHELL")

case "$SHELL_NAME" in
  bash)
    PROFILE="$HOME/.bashrc"
    ;;
  zsh)
    PROFILE="$HOME/.zshrc"
    ;;
  *)
    echo "Unknown shell. Please add ~/.local/bin to PATH manually."
    exit 0
    ;;
esac

LINE='export PATH="$HOME/.local/bin:$PATH"'

grep -qxF "$LINE" "$PROFILE" || echo "$LINE" >> "$PROFILE"

echo "Added to $PROFILE. Restart your shell."

echo "Installed successfully!"
