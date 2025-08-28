#!/usr/bin/osascript

-- Collect Chrome Tabs Script
-- Outputs JSON format for easy parsing

on run
    tell application "Google Chrome"
        set output to "["
        set isFirst to true
        
        repeat with w from 1 to count windows
            repeat with t from 1 to count tabs of window w
                if not isFirst then
                    set output to output & ","
                end if
                set isFirst to false
                
                set tabTitle to title of tab t of window w
                set tabURL to URL of tab t of window w
                
                -- Escape quotes in title and URL
                set tabTitle to my escapeQuotes(tabTitle)
                set tabURL to my escapeQuotes(tabURL)
                
                set output to output & "{\"title\":\"" & tabTitle & "\",\"url\":\"" & tabURL & "\"}"
            end repeat
        end repeat
        
        set output to output & "]"
        return output
    end tell
end run

on escapeQuotes(str)
    -- First escape backslashes
    set AppleScript's text item delimiters to "\\"
    set parts to text items of str
    set AppleScript's text item delimiters to "\\\\"
    set escaped to parts as text
    
    -- Then escape quotes
    set AppleScript's text item delimiters to "\""
    set parts to text items of escaped
    set AppleScript's text item delimiters to "\\\""
    set escaped to parts as text
    
    -- Reset delimiter
    set AppleScript's text item delimiters to ""
    return escaped
end escapeQuotes
