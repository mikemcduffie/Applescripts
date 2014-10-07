set p to (do shell script "mdfind 'kMDItemDisplayName==CodeBox&&kMDItemKind==Application'")
set p to p & "/Contents/Resources/CodeBox.icns"
--set i to POSIX file of p
set i to POSIX file of "/Applications/CodeBox.app/Contents/Resources/CodeBox.icns"
display dialog i
-- "/Applications/CodeBox.app/Contents/Resources/CodeBox.icns"
display dialog "What type of snippet do you want to create?" with title "Create CodeBox Snippet from Safari" with icon i buttons {"Applescript", "Bash", "Plain Text"} default button 2