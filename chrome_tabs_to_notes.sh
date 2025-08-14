#!/bin/bash

# Chrome Tabs to Notes - Master Script with Claude Code CLI
# One command to collect, categorize, and save all Chrome tabs to Apple Notes

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="$SCRIPT_DIR/output"
TABS_FILE="$OUTPUT_DIR/tabs_${TIMESTAMP}.json"
CATEGORIZED_FILE="$OUTPUT_DIR/categorized_${TIMESTAMP}.json"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "🔍 Collecting Chrome tabs..."
osascript "$SCRIPT_DIR/collect_chrome_tabs.applescript" > "$TABS_FILE"

if [ $? -ne 0 ] || [ ! -s "$TABS_FILE" ]; then
    echo "❌ Error: Failed to collect Chrome tabs"
    exit 1
fi

# Count tabs
TAB_COUNT=$(python3 -c "import json; print(len(json.load(open('$TABS_FILE'))))" 2>/dev/null || echo "?")
echo "✅ Collected $TAB_COUNT tabs"

echo "🤖 Categorizing tabs with Claude..."

# Check if claude command exists
if ! command -v claude &> /dev/null; then
    echo "❌ Error: claude command not found. Please install Claude Code CLI"
    echo "Visit: https://docs.anthropic.com/en/docs/claude-code/setup"
    exit 1
fi

# Combine prompt with tabs data and send to Claude
cat "$SCRIPT_DIR/categorize_prompt.txt" "$TABS_FILE" | claude -p --model claude-3-5-sonnet-latest > "$CATEGORIZED_FILE"

if [ $? -ne 0 ] || [ ! -s "$CATEGORIZED_FILE" ]; then
    echo "❌ Error: Failed to categorize tabs with Claude"
    echo "Check if Claude Code CLI is properly configured"
    exit 1
fi

# Validate JSON output
python3 -c "import json; json.load(open('$CATEGORIZED_FILE'))" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "❌ Error: Claude returned invalid JSON"
    echo "Output saved to: $CATEGORIZED_FILE"
    exit 1
fi

# Count categories
CATEGORY_COUNT=$(python3 -c "import json; print(len(json.load(open('$CATEGORIZED_FILE'))))")
echo "✅ Organized into $CATEGORY_COUNT categories"

echo "📝 Creating Notes..."
osascript "$SCRIPT_DIR/create_notes.applescript" "$CATEGORIZED_FILE"

if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to create notes"
    exit 1
fi

echo "✨ Success! All Chrome tabs have been saved to Apple Notes"
echo "📄 Tab data saved to: $TABS_FILE"
echo "📊 Categorized data saved to: $CATEGORIZED_FILE"
