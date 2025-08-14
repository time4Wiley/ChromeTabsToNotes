#!/usr/bin/osascript

-- Create Notes from Categorized Tabs
-- Input: JSON file with categorized tabs

on run argv
    if (count of argv) < 1 then
        return "Error: Please provide JSON file path as argument"
    end if
    
    set jsonFile to item 1 of argv
    
    -- Read JSON file
    try
        set jsonContent to read POSIX file jsonFile
    on error
        return "Error: Cannot read file " & jsonFile
    end try
    
    -- Parse JSON using shell script
    set categoriesData to do shell script "python3 -c \"
import json
import sys

with open('" & jsonFile & "', 'r') as f:
    data = json.load(f)

for category, tabs in data.items():
    print('CATEGORY:' + category)
    for tab in tabs:
        print('TAB:' + tab['title'])
        print('URL:' + tab['url'])
    print('ENDCATEGORY')
\""
    
    -- Process categories
    set categories to paragraphs of categoriesData
    set currentCategory to ""
    set currentContent to ""
    set noteCount to 0
    
    repeat with lineItem in categories
        set lineText to lineItem as string
        if lineText starts with "CATEGORY:" then
            -- Save previous category if exists
            if currentCategory is not "" then
                my createNote(currentCategory, currentContent)
                set noteCount to noteCount + 1
            end if
            
            -- Start new category
            if (count of lineText) > 9 then
                set currentCategory to text 10 thru -1 of lineText
            else
                set currentCategory to "Uncategorized"
            end if
            set currentContent to ""
            
        else if lineText starts with "TAB:" then
            if (count of lineText) > 4 then
                set tabTitle to text 5 thru -1 of lineText
            else
                set tabTitle to "(Untitled)"
            end if
            if currentContent is not "" then
                set currentContent to currentContent & return & return
            end if
            set currentContent to currentContent & "• " & tabTitle
            
        else if lineText starts with "URL:" then
            if (count of lineText) > 4 then
                set tabURL to text 5 thru -1 of lineText
            else
                set tabURL to ""
            end if
            if tabURL is not "" then
                set currentContent to currentContent & return & "  " & tabURL
            end if
            
        else if lineText is "ENDCATEGORY" then
            -- Category complete
        end if
    end repeat
    
    -- Save last category
    if currentCategory is not "" then
        my createNote(currentCategory, currentContent)
        set noteCount to noteCount + 1
    end if
    
    -- Create summary note
    my createSummaryNote(jsonFile, noteCount)
    
    return "Successfully created " & (noteCount + 1) & " notes"
end run

on createNote(noteTitle, rawContent)
    -- Add category suffix to title
    set fullTitle to noteTitle & " - Chrome Tabs"
    
    -- Convert to HTML
    set htmlBody to "<div>" & my replaceText(return, "</div><div>", my escapeHTML(rawContent)) & "</div>"
    
    tell application "Notes"
        set theAccount to account "iCloud"
        try
            set theFolder to folder "Notes" of theAccount
        on error
            set theFolder to folder 1 of theAccount
        end try
        
        make new note at theFolder with properties {name:fullTitle, body:htmlBody}
    end tell
end createNote

on createSummaryNote(jsonFile, categoryCount)
    set summaryTitle to "Chrome Tabs Collection Summary"
    set summaryContent to "Chrome Tabs Collection - " & (current date as string) & return & return
    set summaryContent to summaryContent & "Source: " & jsonFile & return & return
    set summaryContent to summaryContent & "Total categories created: " & categoryCount & return & return
    set summaryContent to summaryContent & "All tabs have been successfully categorized and saved to Apple Notes."
    
    set htmlBody to "<div>" & my replaceText(return, "</div><div>", my escapeHTML(summaryContent)) & "</div>"
    
    tell application "Notes"
        set theAccount to account "iCloud"
        try
            set theFolder to folder "Notes" of theAccount
        on error
            set theFolder to folder 1 of theAccount
        end try
        
        make new note at theFolder with properties {name:summaryTitle, body:htmlBody}
    end tell
end createSummaryNote

on replaceText(findText, replaceWith, theText)
    set AppleScript's text item delimiters to findText
    set parts to text items of theText
    set AppleScript's text item delimiters to replaceWith
    set newText to parts as text
    set AppleScript's text item delimiters to ""
    return newText
end replaceText

on escapeHTML(t)
    set t to my replaceText("&", "&amp;", t)
    set t to my replaceText("<", "&lt;", t)
    set t to my replaceText(">", "&gt;", t)
    set t to my replaceText("\"", "&quot;", t)
    return t
end escapeHTML
