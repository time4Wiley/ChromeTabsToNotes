#!/bin/bash

# Chrome Tabs to Notes - Smart Auto-detect Version
# Automatically uses Claude CLI if available, falls back to Python

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if claude CLI is available
if command -v claude &> /dev/null; then
    echo "🤖 Claude CLI detected - using AI categorization"
    exec "$SCRIPT_DIR/chrome_tabs_to_notes.sh" "$@"
else
    echo "🐍 Using Python categorization (Claude CLI not found)"
    exec "$SCRIPT_DIR/chrome_tabs_to_notes_python.sh" "$@"
fi
