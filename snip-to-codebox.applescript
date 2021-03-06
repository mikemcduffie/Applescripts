-- Key codes from Many Tricks' "Key Codes" app (requires 10.7 or later)
-- http://manytricks.com/keycodes/

on run snippetType
	set snippetType to ""
	tell application "Safari"
		--activate
		set theURL to URL of front document
		set theTitle to name of front document
		set selectedText to (do JavaScript "(''+getSelection())" in document 1)
	end tell
	
	tell application "CodeBox"
		activate
		if snippetType = "" then -- no snippet type entered in Alfred
			set i to (do shell script "mdfind 'kMDItemDisplayName==CodeBox&&kMDItemKind==Application'") as Unicode text -- Find Codebox app
			set i to (do shell script "echo \\" & i & "\\ | sed 's/\\//:/g' | sed 's/ //g'") -- first sed sub added trailing space?!?	
			set i to i & ":Contents:Resources:CodeBox.icns"
			try
				set userChoice to (display dialog "What type of snippet do you want to create?" & return & return & "¬
					[ Press ESC for \"Plain Text\" ]" with title "Create CodeBox Snippet from Safari" with icon i as alias ¬
					buttons {"Applescript", "Bash", "Plain Text"} default button 2 cancel button 3)
				
				if button returned of userChoice = "Bash" then
					set snippetType to "Bash"
				else if button returned of result = "Applescript" then
					set snippetType to "Applescript"
				else if button returned of result = "Plain Text" then
					set snippetType to "Plain Text"
				end if
			on error number n
				if n is -128 then set snippetType to "Plain Text" -- User canceled to select "Plain Test"
			end try
		end if
		
		-- display dialog "You chose " & quoted form of snippetType
		set frontApp to ""
		repeat while frontApp is not equal to "Codebox" -- wait for Codebox to launch
			delay 0.25 -- wait .25 seconds
			tell application "System Events" to set frontApp to name of first process whose frontmost is true
		end repeat
		delay 0.5 -- extra delay needed from Alfred, wait .25 seconds
		if selectedText = "" then -- No text selected in browser
			set the clipboard to theURL as string -- use the webpage as body of snippet
		else
			set the clipboard to selectedText as string
		end if
		delay 0.25 -- wait .25 seconds
		tell application "System Events" to key code 45 using {command down, option down} -- ⌥⌘N (New Snippet from clipboard)
		set the clipboard to theTitle as string
		delay 0.25 -- wait .25 seconds
		tell application "System Events" to key code 9 using command down -- ⌘V (Paste the Title)
		delay 0.25 -- wait .25 seconds
		tell application "System Events" to key code 48 -- ⇥ (Tab to Tags)
		if snippetType = "Plain Text" then -- special case (No Tag)
			delay 0.25 -- wait .25 seconds
		else
			if snippetType = "Bash" then -- special case (Tag = shell not bash)
				set the clipboard to "shell"
			else -- snippitType = tag (error check to avoid cleaing tags or allow new tags to be defined?)
				set the clipboard to snippetType as string
			end if
			tell application "System Events" to key code 9 using command down -- ⌘V (Paste the Tag)
		end if
		set the clipboard to snippetType as string
		tell application "System Events" to key code 48 -- ⇥ (Tab to Asset Notes)
		set the clipboard to theURL as string
		delay 0.25 -- wait .25 seconds
		tell application "System Events" to key code 9 using command down -- ⌘V (Paste the URL to Asset Notes)
		--tell application "System Events" to key code 48 -- ⇥ (Tab to Snippet Body)
	end tell
end run