(*

Sending Images via iMessage with AppleScript
https://discussions.apple.com/thread/5007228?tstart=0

Applescript: Mail this selcted item
https://brooksreview.net/2012/12/km-mail-file/

In Safari, this copies the Title and URL of the current tab to the clipboard.  
-- Save the script in ~/Library/Scripts/Applications/Safari
-- Using QuickSilver, I assign a trigger to this script using the hotkey ⌥-C (option c), with the scope of the trigger limited to Safari.
-- Inspired by CopyURL + (http://copyurlplus.mozdev.org/)
-- Christopher R. Murphy 
*)

tell application "Messages"
	set myService to 1st service whose service type = iMessage
	set myBuddy to buddy "mariemcduffie@me.com" of myService
end tell

tell application "System Events" to set frontApp to name of first process whose frontmost is true

if (frontApp = "AppleScript Editor") or (frontApp = "Script Editor") then set frontApp to "Safari" -- test mode w/ 10.10 editor ref

if (frontApp = "Safari") or (frontApp = "Webkit") then
	using terms from application "Safari"
		tell application frontApp
			set currentTabUrl to URL of front document
			set currentTabTitle to name of front document
			set selectedText to (do JavaScript "(''+getSelection())" in document 1)
		end tell
	end using terms from
	set mytext to currentTabTitle & return & currentTabUrl as string
	tell application "Messages"
		--activate
		send mytext to myBuddy
		if selectedText = "" then -- No text selected in browser
			return "Safari Title & URL sent as message."
		else
			send selectedText to myBuddy
			return "Safari Title,URL & selected text sent as message."
		end if
	end tell
else if (frontApp = "Google Chrome") or (frontApp = "Google Chrome Canary") or (frontApp = "Chromium") then
	using terms from application "Google Chrome"
		tell application frontApp to set currentTabUrl to URL of active tab of front window
		tell application frontApp to set currentTabTitle to title of active tab of front window
	end using terms from
	set mytext to currentTabTitle & return & currentTabUrl as string
	tell application "Messages"
		activate
		send mytext to myBuddy
	end tell
else if (frontApp = "Finder") then
	tell application "Finder"
		-- Make a list to gather the names of the selected files
		set fileAliases to {}
		-- Get the selection of the frontmost Finder window
		set fileSelection to the selection
		-- Iterate of the selection
		repeat with fileItem in fileSelection
			copy the fileItem as alias to the end of fileAliases
		end repeat
		-- Check if the selection is not empty
		if the number of items of fileAliases is 0 then
			-- Audible feedback, so the script always does something.
			beep
		else
			tell application "Messages"
				repeat with fileAlias in fileAliases
					send fileAlias to myBuddy
				end repeat
			end tell
			return "Finder items as message."
		end if
	end tell
end if
