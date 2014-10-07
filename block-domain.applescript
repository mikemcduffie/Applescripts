property SuffixOptions : {".com", ".org", ".net", ".int", ".edu", ".gov", ".biz", ".mil", ".ac", ".ad", ".ae", ".af", ".ag", ".ai", ".al", ".am", ".an", ".ao", ".aq", ".ar", ".as", ".at", ".au", ".aw", ".ax", ".az", ".ba", ".bb", ".bd", ".be", ".bf", ".bg", ".bh", ".bi", ".bj", ".bm", ".bn", ".bo", ".br", ".bs", ".bt", ".bv", ".bw", ".by", ".bz", ".ca", ".cc", ".cd", ".cf", ".cg", ".ch", ".ci", ".ck", ".cl", ".cm", ".cn", ".co", ".cr", ".cs", " Ser", "The ", "Serb", ".cu", ".cv", ".cw", ".cx", ".cy", ".cz", ".dd", ".de", ".dj", ".dk", ".dm", ".do", ".dz", ".ec", ".ee", ".eg", ".eh", ".er", ".es", ".et", ".eu", ".fi", ".fj", ".fk", ".fm", ".fo", ".fr", ".ga", ".gb", ".gd", ".ge", ".gf", ".gg", ".gh", ".gi", ".gl", ".gm", ".gn", ".gp", ".gq", ".gr", ".gs", ".gt", ".gu", ".gw", ".gy", ".hk", ".hm", ".hn", ".hr", ".ht", ".hu", ".id", ".ie", ".il", ".im", ".in", ".io", ".iq", ".ir", ".is", ".it", ".je", ".jm", ".jo", ".jp", ".ke", ".kg", ".kh", ".ki", ".km", ".kn", ".kp", ".kr", ".kw", ".ky", ".kz", ".la", ".lb", ".lc", ".li", ".lk", ".lr", ".ls", ".lt", ".lu", ".lv", ".ly", ".ma", ".mc", ".md", ".me", ".mg", ".mh", ".mk", ".ml", ".mm", ".mn", ".mo", ".mp", ".mq", ".mr", ".ms", ".mt", ".mu", ".mv", ".mw", ".mx", ".my", ".mz", ".na", ".nc", ".ne", ".nf", ".ng", ".ni", ".nl", ".no", ".np", ".nr", ".nu", ".nz", ".om", ".pa", ".pe", ".pf", ".pg", ".ph", ".pk", ".pl", ".pm", ".pn", ".pr", ".ps", ".pt", ".pw", ".py", ".qa", ".re", ".ro", ".rs", ".ru", ".rw", ".sa", ".sb", ".sc", ".sd", ".se", ".sg", ".sh", ".si", ".sj", " Jan", ".sk", ".sl", ".sm", ".sn", ".so", ".sr", ".ss", ".st", ".su", ".sv", ".sx", ".sy", ".sz", ".tc", ".td", ".tf", ".tg", ".th", ".tj", ".tk", ".tl", ".tm", ".tn", ".to", ".tp", ".tr", ".tt", ".tv", ".tw", ".tz", ".ua", ".ug", ".uk", ".us", ".uy", ".uz", ".va", ".vc", ".ve", ".vg", ".vi", ".vn", ".vu", ".wf", ".ws", ".ye", ".yt", ".yu", ".za", ".zm", ".zr", ".zr ", ".zw"}

on run q
	set theURL to q as string
	--display dialog "theURL= '" & theURL & "'" & return & "length= " & length of theURL
	if length of theURL is equal to 0 then
		tell application "Safari"
			tell document 1
				set theURL to URL
			end tell
		end tell
		set JustDomain to FindDomainName(theURL)
		if JustDomain = theURL then
			--display dialog "Could not find the domain from the URL." with icon stop buttons {"Quit"}
			return "Could not find the domain from the URL." & theURL
		end if
	else
		set JustDomain to theURL
		set TheSuffix to ""
		repeat with CurrentSuffix in SuffixOptions
			if JustDomain ends with (CurrentSuffix) then
				set TheSuffix to CurrentSuffix
				exit repeat
			end if
		end repeat
		if TheSuffix = "" then
			--display dialog "You did not enter a valid domain." with icon stop buttons {"Quit"}
			return "You did not enter a valid domain."
		end if
	end if
	
	set hostsLine to return & "127.0.0.1 " & JustDomain
	tell current application
		activate
		set output to (do shell script "printf '" & hostsLine & "   # Added by block-domain workflow' >> /private/etc/hosts" with administrator privileges)
	end tell
	if output is equal to "1" then
		return "Error, /etc/hosts was NOT updated."
	end if
	
	set output to (do shell script "killall -HUP mDNSResponder;echo $?" with administrator privileges)
	
	if output is equal to "0" then
		return "Success, /etc/hosts updated & the DNS cache successfully flushed."
	else
		return "Error, /etc/hosts was updated, but the DNS cache was NOT flushed."
	end if
end run

on FindDomainName(theURL)
	set TheSuffix to ""
	repeat with CurrentSuffix in SuffixOptions
		if theURL contains (CurrentSuffix & "/") then
			set TheSuffix to CurrentSuffix
			exit repeat
		end if
	end repeat
	if TheSuffix = "" then
		return theURL -- couldn't find a Suffix and return original URL
	else
		set SuffixOffset to offset of (CurrentSuffix & "/") in theURL
		set JustDomain to (characters 1 thru (SuffixOffset - 1) of theURL) as string
		set PointOffSet to 0
		repeat with NegOffSet from (length of JustDomain) to 1 by -1
			if character NegOffSet of JustDomain is "." or character NegOffSet of JustDomain is "/" then
				set PointOffSet to NegOffSet
				exit repeat
			end if
		end repeat
		set JustDomain to (characters (PointOffSet + 1) thru (length of JustDomain) of JustDomain as string) & CurrentSuffix
		return JustDomain
	end if
end FindDomainName
