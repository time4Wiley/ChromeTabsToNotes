# Chrome Tabs to Apple Notes (with Claude Code CLI)

A streamlined workflow to collect all Chrome tabs, categorize them using Claude, and save to Apple Notes with proper formatting.

## 🚀 Quick Start

Simply run:
```bash
cd ~/Desktop/ChromeTabsToNotes
./chrome_tabs_to_notes.sh
```

That's it! Claude will intelligently categorize your tabs and save them to Apple Notes.

## 🤖 Claude Code CLI Integration

This workflow now uses **Claude Code CLI** for intelligent tab categorization. Claude understands context and creates more meaningful categories than rule-based systems.

### Prerequisites
- Install Claude Code CLI: https://docs.anthropic.com/en/docs/claude-code/setup
- Authenticate: `claude auth login`

### How it Works
1. Collects all Chrome tabs
2. Sends them to Claude Sonnet for categorization
3. Creates properly formatted Apple Notes

## 📁 Files Overview

- `chrome_tabs_to_notes.sh` - Main script using Claude CLI
- `chrome_tabs_to_notes_python.sh` - Fallback script using Python rules
- `chrome_tabs_to_notes_advanced.sh` - Advanced script with model selection
- `collect_chrome_tabs.applescript` - Collects all tabs from Chrome
- `categorize_prompt.txt` - Prompt for Claude categorization
- `categorize_tabs.py` - Python fallback categorizer
- `create_notes.applescript` - Creates properly formatted Notes

## 🎯 Usage Options

### Option 1: Default (Claude Sonnet)
```bash
./chrome_tabs_to_notes.sh
```

### Option 2: Different Claude Model
```bash
./chrome_tabs_to_notes_advanced.sh claude-3-5-haiku-latest
# or
./chrome_tabs_to_notes_advanced.sh claude-3-opus-latest
```

### Option 3: Python Fallback (no Claude CLI)
```bash
./chrome_tabs_to_notes_python.sh
```

## 📊 Categories

Claude automatically creates categories like:
- YouTube Videos
- AI & Claude Tools
- Task Management Tools
- GitHub Repositories
- Development Tools
- Translation & Localization
- Local Development
- Search Results
- Documentation & References
- Communication Tools
- Cloud Services
- Design Tools
- Miscellaneous

## 💡 Integration with Claude/Claude Code

### Minimal Token Usage
Just tell Claude:
```
Run chrome tabs script
```

### With Model Selection
```
Run chrome tabs script with haiku
```

### Custom Categorization
Edit `categorize_prompt.txt` to customize how Claude categorizes your tabs.

## 📊 Output Files

All data is saved with timestamps in `output/`:
- `tabs_TIMESTAMP.json` - Raw tab data
- `categorized_TIMESTAMP.json` - Claude's categorization

## 🛠️ Troubleshooting

### Claude CLI Not Found
If you see "claude command not found":
1. Install Claude Code CLI: https://docs.anthropic.com/en/docs/claude-code/setup
2. Run `claude auth login`
3. Or use the Python fallback: `./chrome_tabs_to_notes_python.sh`

### Invalid JSON from Claude
Sometimes Claude might return explanatory text. The script validates JSON and will show an error if this happens.

## 🔄 Regular Use

Create aliases for quick access:
```bash
alias chrome2notes="~/Desktop/ChromeTabsToNotes/chrome_tabs_to_notes.sh"
alias ctn="~/Desktop/ChromeTabsToNotes/chrome_tabs_to_notes.sh"
```

## 📝 Advanced Usage

### Export Only
```bash
osascript collect_chrome_tabs.applescript > my_tabs.json
```

### Categorize with Claude
```bash
cat categorize_prompt.txt my_tabs.json | claude -p --model claude-3-5-sonnet-latest > categorized.json
```

### Create Notes from JSON
```bash
osascript create_notes.applescript categorized.json
```

## 🎯 Token Optimization

Using Claude CLI for categorization:
- **First setup**: ~5,000 tokens (one time)
- **Each run**: ~500-1000 tokens for Claude categorization
- **Future runs with just "run script"**: ~50 tokens

Still 95%+ token savings compared to doing everything in chat!

## 🔐 Privacy Note

Your tab data is sent to Claude for categorization. Use the Python fallback script if you prefer local-only processing.

---

Created for efficient Chrome tab management with Claude Code CLI integration.
