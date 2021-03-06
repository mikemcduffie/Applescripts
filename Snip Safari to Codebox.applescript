(*
tell application "System Events" to set frontApp to name of first process whose frontmost is true
if (frontApp = "Safari") or (frontApp = "Webkit") then
	using terms from application "Safari"
		tell application frontApp to set currentTabUrl to URL of front document
		tell application frontApp to set currentTabTitle to name of front document
	end using terms from
else if (frontApp = "Google Chrome") or (frontApp = "Google Chrome Canary") or (frontApp = "Chromium") then
	using terms from application "Google Chrome"
		tell application frontApp to set currentTabUrl to URL of active tab of front window
		tell application frontApp to set currentTabTitle to title of active tab of front window
	end using terms from
else
	return "You need a supported browser as your frontmost app"
end if
*)

-- Key codes from Many Tricks' "Key Codes" app
-- http://manytricks.com/keycodes/

tell application "Safari"
	--activate
	set theURL to URL of front document
	set theTitle to name of front document
	set selectedText to (do JavaScript "(''+getSelection())" in document 1)
end tell

tell application "CodeBox"
	set frontApp to ""
	repeat while frontApp is not equal to "Codebox" -- wait for Codebox to launch
		activate
		delay 0.25 -- wait .25 seconds
		tell application "System Events" to set frontApp to name of first process whose frontmost is true
	end repeat
	delay 0.25 -- extra delay needed from Alfred, wait .25 seconds
	if selectedText = "" then -- No text selected in browser
		tell application "System Events" to key code 45 using command down -- ⌘N (New Snippet)
	else
		set the clipboard to selectedText as string
		tell application "System Events" to key code 45 using {command down, option down} -- ⌥⌘N (New Snippet from clipboard)
	end if
	set the clipboard to theTitle as string
	tell application "System Events" to key code 9 using command down -- ⌘V (Paste the Title)
	tell application "System Events" to key code 48 -- ⇥ (Tab to Tags)
	--delay 0.25 -- wait .25 seconds
	tell application "System Events" to key code 48 -- ⇥ (Tab to Asset Notes)
	set the clipboard to theURL as string
	tell application "System Events" to key code 9 using command down -- ⌘V (Paste the URL to Asset Notes)
	tell application "System Events" to key code 48 -- ⇥ (Tab to Snippet Body)
end tell


(* 
	ALTERNATE METHOD for using whole webpage as snippet when no text is selected

	if selectedText = "" then -- No text selected in browser
		set the clipboard to theURL as string
	else
		set the clipboard to selectedText as string -- use the whole webpage as body of snippet
	end if
	tell application "System Events" to key code 45 using {command down, option down} -- ⌥⌘N (New Snippet from clipboard)
*)
