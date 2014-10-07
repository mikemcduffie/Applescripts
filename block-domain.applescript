(* Block Domain

Adds domain of current Safari URL to /etc/hosts file to block domain and flushes cache.

v1.1

- now captures complete domain address (hosts file doesnÕt support wildcards for subdomains)
- changed DNS flush with version check for OS X 10.10 (Yosemite)
- changed separator between IP address and domain to TAB
- added check if domain already exists


Notes:

OS X 10.10 is monitoring for hosts files changes and automatically flushes the cache:

	10/5/14 4:15:08.831 PM discoveryd[51]: Basic DNSResolver etc/hosts file changed: Event 0x7fd08e205b20 Flushed /etc/hosts cache

Occurs after BBedit Authenticated Save using their helper script (http://www.barebones.com/support/bbedit/auth-saves.html) in the MAS version (sandbox restrictions). Also occurs after modification in place with the block-domain script. However the flush is not reliable when modded in place despite the exact same resulting file.  Ping to the domain name does not resolve to 127.0.0.1 with in place mod.




*)

property SuffixOptions : {".com", ".org", ".net", ".int", ".edu", ".gov", ".biz", ".mil", ".ac", ".ad", ".ae", ".af", ".ag", ".ai", ".al", ".am", ".an", ".ao", ".aq", ".ar", ".as", ".at", ".au", ".aw", ".ax", ".az", ".ba", ".bb", ".bd", ".be", ".bf", ".bg", ".bh", ".bi", ".bj", ".bm", ".bn", ".bo", ".br", ".bs", ".bt", ".bv", ".bw", ".by", ".bz", ".ca", ".cc", ".cd", ".cf", ".cg", ".ch", ".ci", ".ck", ".cl", ".cm", ".cn", ".co", ".cr", ".cs", " Ser", "The ", "Serb", ".cu", ".cv", ".cw", ".cx", ".cy", ".cz", ".dd", ".de", ".dj", ".dk", ".dm", ".do", ".dz", ".ec", ".ee", ".eg", ".eh", ".er", ".es", ".et", ".eu", ".fi", ".fj", ".fk", ".fm", ".fo", ".fr", ".ga", ".gb", ".gd", ".ge", ".gf", ".gg", ".gh", ".gi", ".gl", ".gm", ".gn", ".gp", ".gq", ".gr", ".gs", ".gt", ".gu", ".gw", ".gy", ".hk", ".hm", ".hn", ".hr", ".ht", ".hu", ".id", ".ie", ".il", ".im", ".in", ".io", ".iq", ".ir", ".is", ".it", ".je", ".jm", ".jo", ".jp", ".ke", ".kg", ".kh", ".ki", ".km", ".kn", ".kp", ".kr", ".kw", ".ky", ".kz", ".la", ".lb", ".lc", ".li", ".lk", ".lr", ".ls", ".lt", ".lu", ".lv", ".ly", ".ma", ".mc", ".md", ".me", ".mg", ".mh", ".mk", ".ml", ".mm", ".mn", ".mo", ".mp", ".mq", ".mr", ".ms", ".mt", ".mu", ".mv", ".mw", ".mx", ".my", ".mz", ".na", ".nc", ".ne", ".nf", ".ng", ".ni", ".nl", ".no", ".np", ".nr", ".nu", ".nz", ".om", ".pa", ".pe", ".pf", ".pg", ".ph", ".pk", ".pl", ".pm", ".pn", ".pr", ".ps", ".pt", ".pw", ".py", ".qa", ".re", ".ro", ".rs", ".ru", ".rw", ".sa", ".sb", ".sc", ".sd", ".se", ".sg", ".sh", ".si", ".sj", " Jan", ".sk", ".sl", ".sm", ".sn", ".so", ".sr", ".ss", ".st", ".su", ".sv", ".sx", ".sy", ".sz", ".tc", ".td", ".tf", ".tg", ".th", ".tj", ".tk", ".tl", ".tm", ".tn", ".to", ".tp", ".tr", ".tt", ".tv", ".tw", ".tz", ".ua", ".ug", ".uk", ".us", ".uy", ".uz", ".va", ".vc", ".ve", ".vg", ".vi", ".vn", ".vu", ".wf", ".ws", ".ye", ".yt", ".yu", ".za", ".zm", ".zr", ".zr ", ".zw"}

on run q
	
	-- check if testing in Script editor
	tell application "System Events" to set frontApp to name of first process whose frontmost is true
	if (frontApp = "AppleScript Editor") or (frontApp = "Script Editor") then set q to "" -- test mode w/ 10.10 editor ref
	
	
	set theURL to q as string
	--display dialog "theURL= '" & theURL & "'" & return & "length= " & length of theURL
	if length of theURL is equal to 0 then -- User did not enter domain manually
		set manualEntry to false
		tell application "Safari"
			tell document 1
				set theURL to URL
			end tell
		end tell
		set theDomain to do shell script ("echo '" & theURL & "' | awk -F '/' '{print $3}'")
	else
		set manualEntry to true
		set theDomain to theURL
		set TheSuffix to ""
		repeat with CurrentSuffix in SuffixOptions
			if theDomain ends with (CurrentSuffix) then
				set TheSuffix to CurrentSuffix
				exit repeat
			end if
		end repeat
		if TheSuffix = "" then
			--display dialog "You did not enter a valid domain." with icon stop buttons {"Quit"}
			return "You did not enter a valid domain."
		end if
	end if
	
	-- check if domain is already blocked
	set hostsFile to POSIX file "/private/etc/hosts" as alias
	set theHosts to read hostsFile as string
	if theHosts contains theDomain then
		return "Domain is already blocked."
	end if
	
	set hostsLine to return & "127.0.0.1	" & theDomain -- hosts file needs TAB between IP Address and domain?
	
	if manualEntry then
		set commentString to "	# Added by block-domain workflow (manually entered)"
	else
		set commentString to "	# Added by block-domain workflow"
	end if
	
	tell current application -- alternate method: Tell me
		activate
		display dialog "Trying to get focusÉ" with title "Can't focus in Yosemite" buttons {"Cancel", "Idle"} cancel button "Cancel" giving up after (1)
		set output to (do shell script "printf '" & hostsLine & commentString & "' >> /etc/hosts" with administrator privileges)
	end tell
	
	if output is equal to "1" then -- do shell had error
		return "Error, the hosts file was NOT updated."
	end if
	
	if system version of (system info) = "10.10" then
		set output to (do shell script "sudo discoveryutil mdnsflushcache" with administrator privileges)
	else
		set output to (do shell script "killall -HUP mDNSResponder;echo $?" with administrator privileges)
	end if
	
	return "Success, the hosts file was updated & the DNS cache successfully flushed."
	
	(*	if output is equal to "0" then
		return "Success, the hosts file was updated & the DNS cache successfully flushed."
	else
		return "Error, the hosts file was updated, but the DNS cache was NOT flushed."
	end if
*)
	
end run

