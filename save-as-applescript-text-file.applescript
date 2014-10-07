on remove_extension(this_name)
	if this_name contains "." then
		set this_name to Â
			(the reverse of every character of this_name) as string
		set x to the offset of "." in this_name
		set this_name to (text (x + 1) thru -1 of this_name)
		set this_name to (the reverse of every character of this_name) as string
	end if
	return this_name
end remove_extension

tell application "Script Editor" to set scriptName to the name of document 1
set baseName to remove_extension(scriptName)
tell application "Script Editor" to save document 1 as "text" in file ((path to home folder as Unicode text) & "Programming:Applescripts:" & baseName & ".applescript")
