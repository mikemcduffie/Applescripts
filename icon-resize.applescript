on run q
	set q to q as real
	tell application "Finder"
		activate
		--set the current view of front Finder window to list view
		set the current view of front Finder window to icon view
		tell front window to set sidebar width to 0
		set arrangement of icon view options of front Finder window to arranged by name
	end tell
	
	
	tell application "System Events"
		tell process "Finder"
			-- Attempting to use slider name "resize icon" from Accessibility Inspector fails ?!?
			set value of slider 1 of front window to q -- Values 0 to 112 for Icon Size 
		end tell
	end tell
end run