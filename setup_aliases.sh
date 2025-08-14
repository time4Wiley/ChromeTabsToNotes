#!/bin/bash

# Setup script for Chrome Tabs to Notes
# Adds convenient aliases to your shell profile

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Detect shell profile
if [ -f ~/.zshrc ]; then
    PROFILE=~/.zshrc
    SHELL_NAME="zsh"
elif [ -f ~/.bash_profile ]; then
    PROFILE=~/.bash_profile
    SHELL_NAME="bash"
else
    PROFILE=~/.bashrc
    SHELL_NAME="bash"
fi

echo "Setting up aliases for $SHELL_NAME..."

# Remove old aliases if present
sed -i.bak '/# Chrome Tabs to Notes aliases/,/^$/d' "$PROFILE" 2>/dev/null

# Add new aliases
echo "
# Chrome Tabs to Notes aliases
alias chrome2notes='$SCRIPT_DIR/chrome_tabs_smart.sh'
alias ctn='$SCRIPT_DIR/chrome_tabs_smart.sh'  # Even shorter!
alias ctn-claude='$SCRIPT_DIR/chrome_tabs_to_notes.sh'  # Force Claude CLI
alias ctn-python='$SCRIPT_DIR/chrome_tabs_to_notes_python.sh'  # Force Python
" >> "$PROFILE"

echo "✅ Setup complete!"
echo ""
echo "Available commands:"
echo "  chrome2notes   - Smart auto-detect (Claude or Python)"
echo "  ctn           - Short version of chrome2notes"
echo "  ctn-claude    - Force Claude CLI categorization"
echo "  ctn-python    - Force Python categorization"
echo ""
echo "Please run: source $PROFILE"
echo "Or restart your terminal to use the new commands."

# Test Claude CLI availability
echo ""
if command -v claude &> /dev/null; then
    echo "✅ Claude CLI detected - will use AI categorization by default"
else
    echo "📝 Note: Claude CLI not found - will use Python categorization"
    echo "   To enable AI categorization, install Claude Code CLI:"
    echo "   https://docs.anthropic.com/en/docs/claude-code/setup"
fi
