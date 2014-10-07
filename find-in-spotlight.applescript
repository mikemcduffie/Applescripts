on run query
	--set query to "/Volumes/Data SSD/Downloads/Usenet Completed/alt.binaries.comics.dcp/Copernicus Jones - Robot Detective 005 (2014) (digital) (Son of Ultron-Empire).cbr"
	tell application "Finder"
		activate
		set the search_string to "name:" & (do shell script "basename " & quoted form of query) -- strip path
		set the search_string to "name:" & (do shell script "echo " & quoted form of search_string & " | sed -e 's/ [0-9]\\{2,3\\} .*$//'") -- strip all after issue numer (assumes 2-3 digits space elimited)
		make new Finder window
		
		tell application "System Events"
			keystroke "f" using {option down, command down}
			delay 0.1
			keystroke the search_string
			delay 0.1
			key code 36 -- Enter
			--set searchType to "kind:comic"
			--keystroke the searchType
			tell process "Finder" to click radio button 1 of radio group 1 of group 1 of splitter group 1 of window 1 -- Click "This Mac"
			set i to 0
			repeat while i ² 4
				set i to i + 1
				--delay 0.1
				keystroke tab -- Tab to Finder window list
			end repeat
		end tell
	end tell
end run