(* CBR droplet v1.1

Changes for v1.1
- filters for "Folder" Document Type (via Info.plist) [will not allow non-Folders to be dropped]
- add error check in script for fallback for non-folders with error dialog
- checks if resulting filename from folder name already exists and increments for unique filename in ".x.cbr" syntax
- timeout changed to 7200 seconds (2 hours) [too long for hard drive wear?]
- added terminal-notifier for results (requires 10.6+) (10.9 for custom send/image/icon; notes uses Private APIs!)
- Uses Finder as Sender for notifications ("sender = CBR Droplet" doesn't work but sender = "Simple Comic" does)


*)

(* INSTRUCTIONS
This droplet is designed to process one or more folders whose icons are dragged onto the droplet icon.
The droplet compresesses all dropped folders with rarlab's rar compression (using an embedded executable) 
to a CBR (ComicBook Rar archive) based on the Folder name and move the Folder to the Trash.
The droplet will check if the resulting filename already exists and increment the filename to ensure a unique filename.
Results are reported via Notification Center using embedded 

*)




on open (theItems) --receive items dropped onto droplet as a list
	with timeout of 7200 seconds -- timeout after 2 hours
		try
			tell application "Finder"
				set rartool to quoted form of POSIX path of ((path to me as string) & "Contents:MacOS:rar")
				set notifyTool to quoted form of POSIX path of ((path to me as string) & "Contents:MacOS:terminal-notifier.app:Contents:MacOS:terminal-notifier")
				set numCBRs to 0 -- count of archives processed for notification at end
				repeat with oneItem in theItems --repeat the command to compress each item as an individual archive
					if kind of oneItem is not "Folder" then
						display dialog quoted form of oneItem & " is not a Folder."
						exit repeat -- do not process if not Folder
					end if
					set numCBRs to numCBRs + 1
					set itemProp to properties of oneItem
					set itemPath to quoted form of POSIX path of oneItem
					set folderName to name of oneItem
					set parentFolder to POSIX path of (container of oneItem as alias)
					set rarFile to parentFolder & folderName & ".cbr"
					set fileSuffix to 1 -- suffix to append to filename for unique name
					#quoted form of (do shell script "echo \"" & "This:is:some:test:text:" & "\" | sed 's/:/ /g'")
					repeat while exists rarFile as POSIX file
						set rarFile to (parentFolder & folderName & "." & fileSuffix as string) & ".cbr"
						set fileSuffix to fileSuffix + 1
					end repeat
					set itemName to name of oneItem
					set folderName to the quoted form of folderName
					set rarFile to the quoted form of rarFile
					--do shell script ("cd " & itemPath & "; cd ..; " & rartool & " a -x'*.DS_Store' " & rarFile & " " & folderName)
					display dialog "cd " & itemPath & "; cd ..; " & rartool & " a -x'*.DS_Store' -x thumbs.db -x '*.nfo' -x '*NFO.jpg' " & rarFile & " " & folderName
					--delete oneItem
				end repeat
				#display notification ((count of theItems) as string) & " archives processed."
				set myMessage to quoted form of ((numCBRs as string) & " CBR archive(s) processed.")
				set osVer to system version of (system info)
				if osVer is not less than 10.8 then
					do shell script Â
						(notifyTool & " -title 'CBR Droplet' -message " & myMessage & " -sound default -sender 'com.apple.finder'")
				end if
			end tell
		on error errmsg
			display dialog errmsg
		end try
	end timeout
end open

