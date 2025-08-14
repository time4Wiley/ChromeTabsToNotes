#!/bin/bash

# Chrome Tabs to Notes - Fallback version using Python categorizer
# Use this if Claude Code CLI is not available

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
TAB_COUNT=$(python3 -c "import json; print(len(json.load(open('$TABS_FILE'))))")
echo "✅ Collected $TAB_COUNT tabs"

echo "📂 Categorizing tabs with Python..."
python3 "$SCRIPT_DIR/categorize_tabs.py" "$TABS_FILE" > "$CATEGORIZED_FILE"

if [ $? -ne 0 ] || [ ! -s "$CATEGORIZED_FILE" ]; then
    echo "❌ Error: Failed to categorize tabs"
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
