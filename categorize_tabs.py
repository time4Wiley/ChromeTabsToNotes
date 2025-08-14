#!/usr/bin/env python3
"""
Chrome Tabs Categorizer
Automatically categorizes tabs based on URL patterns and keywords
"""

import json
import sys
import re
from collections import defaultdict
from urllib.parse import urlparse

# Category rules - easily customizable
CATEGORY_RULES = {
    "YouTube Videos": {
        "domains": ["youtube.com", "youtu.be"],
        "patterns": [r"watch\?v=", r"youtube\.com/results"],
        "keywords": []
    },
    "AI & Claude Tools": {
        "domains": ["anthropic.com", "openai.com", "chatgpt.com"],
        "patterns": [r"claude", r"chatgpt", r"ai-", r"llm", r"gpt"],
        "keywords": ["Claude", "ChatGPT", "AI", "LLM", "Anthropic", "OpenAI", "Aider", "Serena", "agent"]
    },
    "Task Management Tools": {
        "domains": [],
        "patterns": [r"task", r"todo", r"to-do"],
        "keywords": ["Task", "Todo", "Taskwarrior", "TaskJuggler", "Taskchamp", "TODO"]
    },
    "GitHub Repositories": {
        "domains": ["github.com"],
        "patterns": [r"github\.com/[^/]+/[^/]+"],
        "keywords": []
    },
    "Development Tools": {
        "domains": ["stackoverflow.com", "developer.mozilla.org"],
        "patterns": [r"localhost:", r"127\.0\.0\.1:", r"::1:", r"0\.0\.0\.0:"],
        "keywords": ["Excalidraw", "Superdesign", "DevTools", "CloudKit", "Swift", "developer", "framework", "SDK"]
    },
    "Translation & Localization": {
        "domains": [],
        "patterns": [r"translat", r"i18n", r"l10n", r"localiz"],
        "keywords": ["translate", "translation", "localization", "i18n", "l10n", "Lingo", "Okapi"]
    },
    "Local Development": {
        "domains": [],
        "patterns": [r"localhost:", r"127\.0\.0\.1:", r"http://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"],
        "keywords": ["Dashboard", "localhost"]
    },
    "Search Results": {
        "domains": ["google.com/search", "bing.com/search", "duckduckgo.com"],
        "patterns": [r"search\?", r"/search/", r"results\?search"],
        "keywords": ["search results", "Repository search"]
    }
}

def categorize_tab(tab):
    """Categorize a single tab based on rules"""
    title = tab.get("title", "").lower()
    url = tab.get("url", "").lower()
    
    # Parse domain
    try:
        domain = urlparse(url).netloc.lower()
    except:
        domain = ""
    
    # Check each category
    for category, rules in CATEGORY_RULES.items():
        # Check domains
        for rule_domain in rules["domains"]:
            if rule_domain in domain:
                return category
        
        # Check URL patterns
        for pattern in rules["patterns"]:
            if re.search(pattern, url, re.IGNORECASE):
                return category
        
        # Check keywords in title
        for keyword in rules["keywords"]:
            if keyword.lower() in title:
                return category
    
    # Default category
    return "Miscellaneous"

def categorize_tabs(tabs_json):
    """Categorize all tabs and return organized structure"""
    try:
        tabs = json.loads(tabs_json)
    except:
        return {"error": "Invalid JSON input"}
    
    categories = defaultdict(list)
    
    for tab in tabs:
        category = categorize_tab(tab)
        categories[category].append(tab)
    
    # Convert to regular dict and sort
    result = {}
    for category in sorted(categories.keys()):
        result[category] = categories[category]
    
    return result

if __name__ == "__main__":
    # Read from stdin or file
    if len(sys.argv) > 1:
        with open(sys.argv[1], 'r') as f:
            tabs_json = f.read()
    else:
        tabs_json = sys.stdin.read()
    
    categorized = categorize_tabs(tabs_json)
    print(json.dumps(categorized, indent=2))
