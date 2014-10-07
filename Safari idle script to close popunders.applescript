on idle
	tell application "Safari"
		repeat with t in tabs of windows
			tell t
				if URL contains "adrotator.se" then close
			end tell
		end repeat
		return 3
	end tell
	--return 1
end idle