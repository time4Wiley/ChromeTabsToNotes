#!/bin/bash

# Test the Chrome Tabs to Notes workflow

echo "🧪 Testing Chrome Tabs to Notes workflow..."
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Test 1: Check all files exist
echo "1️⃣ Checking files..."
FILES=(
    "chrome_tabs_to_notes.sh"
    "collect_chrome_tabs.applescript" 
    "categorize_tabs.py"
    "create_notes.applescript"
)

ALL_GOOD=true
for file in "${FILES[@]}"; do
    if [ -f "$SCRIPT_DIR/$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (missing)"
        ALL_GOOD=false
    fi
done

if [ "$ALL_GOOD" = false ]; then
    echo ""
    echo "❌ Some files are missing. Please check the installation."
    exit 1
fi

echo ""
echo "2️⃣ Checking Python..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "  ✅ $PYTHON_VERSION"
else
    echo "  ❌ Python 3 not found"
    exit 1
fi

echo ""
echo "3️⃣ Testing Chrome connection..."
TEST_RESULT=$(osascript -e 'tell application "System Events" to return name of processes contains "Google Chrome"' 2>&1)
if [[ "$TEST_RESULT" == *"true"* ]]; then
    echo "  ✅ Chrome is running"
else
    echo "  ⚠️  Chrome is not running - please open Chrome and try again"
fi

echo ""
echo "✨ All tests passed! The workflow is ready to use."
echo ""
echo "Run ./chrome_tabs_to_notes.sh to collect and save your tabs!"
