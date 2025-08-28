#!/bin/bash

# Chrome Tabs to Notes - Enhanced Script
# Comprehensive script with better error handling and features

set -e  # Exit on error

# Configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="$SCRIPT_DIR/output"
TABS_FILE="$OUTPUT_DIR/tabs_${TIMESTAMP}.json"
CATEGORIZED_FILE="$OUTPUT_DIR/categorized_${TIMESTAMP}.json"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    
    # Check for Python 3
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    fi
    
    # Check for osascript (should always exist on macOS)
    if ! command -v osascript &> /dev/null; then
        missing_deps+=("osascript")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        echo "Please install the missing dependencies and try again."
        exit 1
    fi
}

# Function to check if Chrome is running
check_chrome() {
    if ! osascript -e 'tell application "System Events" to return name of processes contains "Google Chrome"' | grep -q "true"; then
        print_warning "Chrome is not running"
        echo "Would you like to open Chrome? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            open -a "Google Chrome"
            sleep 2
        else
            print_error "Chrome must be running to collect tabs"
            exit 1
        fi
    fi
}

# Function to detect categorization method
detect_categorizer() {
    if command -v claude &> /dev/null; then
        echo "claude"
    else
        echo "python"
    fi
}

# Function to collect Chrome tabs
collect_tabs() {
    print_status "🔍 Collecting Chrome tabs..."
    
    "$SCRIPT_DIR/collect_chrome_tabs.applescript" > "$TABS_FILE"
    
    if [ $? -ne 0 ] || [ ! -s "$TABS_FILE" ]; then
        print_error "Failed to collect Chrome tabs"
        exit 1
    fi
    
    # Count tabs
    local tab_count=$(python3 -c "import json; print(len(json.load(open('$TABS_FILE'))))" 2>/dev/null || echo "0")
    
    if [ "$tab_count" -eq 0 ]; then
        print_warning "No tabs found in Chrome"
        exit 1
    fi
    
    print_success "Collected $tab_count tabs"
    # Don't return the tab count as exit code, as non-zero values will cause script to exit with set -e
    TAB_COUNT=$tab_count
    return 0
}

# Function to categorize with Claude
categorize_with_claude() {
    local model="${1:-claude-3-5-sonnet-latest}"
    
    print_status "🤖 Categorizing tabs with Claude ($model)..."
    
    # Combine prompt with tabs data and send to Claude
    cat "$SCRIPT_DIR/categorize_prompt.txt" "$TABS_FILE" | claude -p --model "$model" > "$CATEGORIZED_FILE"
    
    if [ $? -ne 0 ] || [ ! -s "$CATEGORIZED_FILE" ]; then
        print_error "Failed to categorize tabs with Claude"
        return 1
    fi
    
    # Validate JSON
    if ! python3 -c "import json; json.load(open('$CATEGORIZED_FILE'))" 2>/dev/null; then
        print_error "Claude returned invalid JSON"
        return 1
    fi
    
    return 0
}

# Function to categorize with Python
categorize_with_python() {
    print_status "🐍 Categorizing tabs with Python rules..."
    
    python3 "$SCRIPT_DIR/categorize_tabs.py" "$TABS_FILE" > "$CATEGORIZED_FILE"
    
    if [ $? -ne 0 ] || [ ! -s "$CATEGORIZED_FILE" ]; then
        print_error "Failed to categorize tabs with Python"
        return 1
    fi
    
    return 0
}

# Function to create Apple Notes
create_notes() {
    print_status "📝 Creating Apple Notes..."
    
    osascript "$SCRIPT_DIR/create_notes.applescript" "$CATEGORIZED_FILE"
    
    if [ $? -ne 0 ]; then
        print_error "Failed to create notes"
        return 1
    fi
    
    # Count categories
    local category_count=$(python3 -c "import json; print(len(json.load(open('$CATEGORIZED_FILE'))))" 2>/dev/null || echo "0")
    
    print_success "Created notes for $category_count categories"
    return 0
}

# Function to show summary
show_summary() {
    echo ""
    echo "═══════════════════════════════════════════════════════"
    print_success "✨ Success! All Chrome tabs have been saved to Apple Notes"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "📊 Summary:"
    echo "  • Tab data: $TABS_FILE"
    echo "  • Categorized data: $CATEGORIZED_FILE"
    echo "  • Categorization method: $1"
    echo "  • Timestamp: $TIMESTAMP"
    echo ""
    
    # Show categories
    if [ -f "$CATEGORIZED_FILE" ]; then
        echo "📂 Categories created:"
        python3 -c "
import json
with open('$CATEGORIZED_FILE', 'r') as f:
    data = json.load(f)
    for cat in data.keys():
        print(f'  • {cat} ({len(data[cat])} tabs)')
" 2>/dev/null || echo "  (Unable to display categories)"
    fi
}

# Main execution
main() {
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║     Chrome Tabs to Apple Notes - Enhanced Edition     ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo ""
    
    # Parse command line arguments
    FORCE_METHOD=""
    MODEL="claude-3-5-sonnet-latest"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --claude)
                FORCE_METHOD="claude"
                shift
                ;;
            --python)
                FORCE_METHOD="python"
                shift
                ;;
            --model)
                MODEL="$2"
                shift 2
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --claude        Force Claude categorization"
                echo "  --python        Force Python categorization"
                echo "  --model MODEL   Specify Claude model (default: claude-3-5-sonnet-latest)"
                echo "  --help, -h      Show this help message"
                echo ""
                echo "Available Claude models:"
                echo "  • claude-3-5-sonnet-latest (default)"
                echo "  • claude-3-5-haiku-latest"
                echo "  • claude-3-opus-latest"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Check dependencies
    check_dependencies
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Check if Chrome is running
    check_chrome
    
    # Collect tabs
    collect_tabs
    # TAB_COUNT is now set as a global variable in collect_tabs function
    
    # Determine categorization method
    if [ -n "$FORCE_METHOD" ]; then
        METHOD="$FORCE_METHOD"
    else
        METHOD=$(detect_categorizer)
    fi
    
    # Categorize tabs
    if [ "$METHOD" = "claude" ]; then
        if ! command -v claude &> /dev/null; then
            print_warning "Claude CLI not found, falling back to Python"
            METHOD="python"
            categorize_with_python
        else
            if categorize_with_claude "$MODEL"; then
                METHOD="Claude ($MODEL)"
            else
                print_warning "Claude categorization failed, falling back to Python"
                METHOD="python"
                categorize_with_python
            fi
        fi
    else
        categorize_with_python
        METHOD="Python rules"
    fi
    
    # Create notes
    create_notes
    
    # Show summary
    show_summary "$METHOD"
}

# Run main function
main "$@"