# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Chrome Tabs to Apple Notes - A workflow that collects all Chrome tabs, categorizes them using Claude AI or Python rules, and saves them to Apple Notes with proper formatting.

## Primary Commands

### Run the workflow
```bash
# Smart auto-detect (uses Claude if available, falls back to Python)
./chrome_tabs_smart.sh

# Force Claude CLI categorization
./chrome_tabs_to_notes.sh

# Force Python categorization  
./chrome_tabs_to_notes_python.sh

# With specific Claude model
./chrome_tabs_to_notes_advanced.sh claude-3-5-haiku-latest
```

### Setup aliases
```bash
./setup_aliases.sh
source ~/.zshrc  # or ~/.bashrc
# Then use: ctn
```

### Testing
```bash
./test_workflow.sh  # Test all components are working
./test_claude_cli.sh  # Test Claude CLI integration
```

## Architecture

### Core Components

1. **Tab Collection** (`collect_chrome_tabs.applescript`)
   - Extracts all tabs from Chrome using AppleScript
   - Outputs JSON: `[{"title": "...", "url": "..."}, ...]`

2. **Categorization** (Two approaches)
   - **Claude CLI**: Sends tabs + prompt to Claude for intelligent categorization
   - **Python Rules**: Rule-based categorization using URL patterns and keywords

3. **Note Creation** (`create_notes.applescript`)
   - Parses categorized JSON
   - Creates Apple Notes with HTML formatting
   - Adds summary note

### Data Flow
```
Chrome → AppleScript → JSON → Categorizer (Claude/Python) → JSON → AppleScript → Apple Notes
```

### Output Structure
- All outputs saved to `output/` with timestamps
- Format: `tabs_YYYYMMDD_HHMMSS.json` and `categorized_YYYYMMDD_HHMMSS.json`

## Key Files

- `categorize_prompt.txt` - Claude's instructions for categorization
- `categorize_tabs.py` - Python fallback with customizable rules in `CATEGORY_RULES` dict
- Shell scripts follow pattern: collect → categorize → create notes

## Claude CLI Integration

The workflow checks for Claude CLI availability:
- If present: Uses AI categorization via `claude -p --model`
- If absent: Falls back to Python rule-based categorization
- Advanced script allows model selection (sonnet, haiku, opus)

## Customization Points

1. **Categories**: Edit `categorize_prompt.txt` for Claude or `CATEGORY_RULES` in `categorize_tabs.py`
2. **Models**: Pass model name to `chrome_tabs_to_notes_advanced.sh`
3. **Output format**: Modify AppleScript files for different note structure

## Requirements

- macOS with Google Chrome and Apple Notes
- Python 3 (for JSON processing and fallback categorization)
- Claude CLI (optional, for AI categorization)
- AppleScript execution enabled