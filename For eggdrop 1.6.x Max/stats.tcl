# ---------------------------------------
# IRC Server UpTime by dirty Inc.
# 
# Contact:
# WwW.BotZone.TK
# irc.undernet.org @ #BotZone
#
# HOW TO USE!!!!
# !ircuptime
# ---------------------------------------

# Set here the global and local flags that can use this command.
# Write "-" for everyone to use.
set dty_isu(flags) "o|o"

# Set here the command that triggers the script
set dty_isu(cmd) "!stats"

# DO NOT EDIT PASS THIS LINE (AT YOUR OWN RISK)

bind pub $dty_isu(flags) $dty_isu(cmd) isu:cmd:uptime
proc isu:cmd:uptime {nick uhost handle channel text} {
	global dty_isu
	
	if {[info exists dty_isu($channel)]} { return 0 }
	putserv "STATS u"
	
	if {[info exists dty_isu(channels)]} {
		lappend dty_isu(channels) $channel
	} else {
		set dty_isu(channels) $channel
	}
	set dty_isu($channel) "flood"
	utimer 30 "unset -nocomplain dty_isu($channel)"
}

bind raw - 242 isu:raw:242
proc isu:raw:242 {from keyword text} {
	global dty_isu
	
	set dty_isu(text) "[lindex [split [lrange $text 3 end] ","] 0]"
}

bind raw - 250 isu:raw:250
proc isu:raw:250 {from keyword text} {
	global dty_isu
	
	foreach chan $dty_isu(channels) {
		putserv "PRIVMSG $chan :Server \0033$from\003 has uptime of\0033 $dty_isu(text)\003 with a connection count of [lrange $text 4 end]."
	}
	unset -nocomplain dty_isu(channels)
	unset -nocomplain dty_isu(text)
}

putlog "\002IRC Server UpTime\002 by dirty Inc. Loaded."