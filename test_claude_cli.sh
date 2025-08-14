#!/bin/bash

# Test Claude CLI integration

echo "🧪 Testing Claude CLI integration..."
echo ""

# Test if claude command exists
if command -v claude &> /dev/null; then
    echo "✅ Claude CLI is installed"
    
    # Test if authenticated
    if claude auth status &> /dev/null; then
        echo "✅ Claude CLI is authenticated"
    else
        echo "⚠️  Claude CLI needs authentication"
        echo "   Run: claude auth login"
    fi
    
    # Test categorization with a small sample
    echo ""
    echo "Testing categorization with sample tabs..."
    
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    TEST_TABS='[{"title":"YouTube","url":"https://youtube.com"},{"title":"GitHub - claude/code","url":"https://github.com/claude/code"}]'
    
    echo "$TEST_TABS" > /tmp/test_tabs.json
    cat "$SCRIPT_DIR/categorize_prompt.txt" /tmp/test_tabs.json | claude -p --model claude-3-5-sonnet-latest > /tmp/test_categorized.json 2>/dev/null
    
    if [ $? -eq 0 ] && [ -s /tmp/test_categorized.json ]; then
        # Check if valid JSON
        if python3 -c "import json; json.load(open('/tmp/test_categorized.json'))" 2>/dev/null; then
            echo "✅ Claude categorization works!"
            echo ""
            echo "Sample output:"
            cat /tmp/test_categorized.json | python3 -m json.tool | head -20
        else
            echo "⚠️  Claude returned invalid JSON"
        fi
    else
        echo "❌ Claude categorization failed"
    fi
    
    rm -f /tmp/test_tabs.json /tmp/test_categorized.json
else
    echo "❌ Claude CLI not found"
    echo ""
    echo "To install:"
    echo "1. Visit: https://docs.anthropic.com/en/docs/claude-code/setup"
    echo "2. Follow installation instructions for your platform"
    echo "3. Run: claude auth login"
    echo ""
    echo "Alternative: Use ./chrome_tabs_to_notes_python.sh for local categorization"
fi
