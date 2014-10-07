set trashcontents to ""
tell application "Finder" to set mypath to POSIX path of (parent of (path to me) as string)
set mypath to POSIX path of mypath

try
	set trashcontents to quoted form of (do shell script "ls /Volumes/*/.Trashes/* 2>&1 | grep -v 'No such file or directory'")
	set trashcontents to trashcontents & quoted form of (do shell script "ls ~/.Trash/ | grep -v 'No such file or directory'")
end try

set trashcontents to trashcontents as string
if length of trashcontents is not greater than 0 then -- checking for "" didn't always work
	--display dialog "Trash is empty." & return & "Contents: " & trashcontents & return & "Length: " & length of trashcontents
	
	-- Applescript notifications not working in scpt launched from alfred
	--set variableWithSoundName to "Basso"
	--display notification "Trash is already empty." with title "Force Empty Trash" sound name variableWithSoundName
	
	do shell script quoted form of mypath & "/terminal-notifier -title 'Force Empty Trash' -message 'Trash is already empty.' -sound 'Basso' -sender 'com.apple.finder'"
else
	--display dialog "Trash is NOT empty." & return & "Contents: " & trashcontents & return & "Length: " & length of trashcontents
	--set myPath to (path to me as string)
	tell current application
		activate
		do shell script "sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; afplay '" & mypath & "/empty trash.aif'" with administrator privileges
	end tell
end if