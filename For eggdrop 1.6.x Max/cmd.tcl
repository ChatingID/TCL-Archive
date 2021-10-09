#############################################################################################
################################### Command Bot Allin #######################################
############################## Combined & Modified by Aryo ##################################
########################## Original by Jaysee a.k.a Ninja_Bay ###############################
#loading script for fun only
putlog "*** Loading Commands & Control Allin Please wait..."
# Set this as your Public (channel) command character. For example: you set this to ".".. means you must-
# type !mycommand in channel to activate public commands...
set ATHPRM "."

# This is for your benefit hehe ;), you can either set your own LOGO here, your logo will appear-
# when the bot notice you, or when it makes msgs/notices/kicks or scripts loading. So keep smiling-
# and set this variable as you wish ;), you can either set this to "" to leave it blank.
set cmdathlg "\[S-B\]:"

######### Please do not edit anything below unless you know what you are doing ;) #########

proc msg_pass {nick uhost hand rest} {
	global botnick cmdathlg ; set rest [lindex $rest 0]
	if {$rest == ""} {putquick "NOTICE $nick :$cmdathlg Command: /msg $botnick pass <password>" ; return 0}
	if {![passwdok $hand "-"]} {putquick "NOTICE $nick :$cmdathlg Your password has been set before, you don't need to set it again. Simpy type: \[/msg $botnick auth <password>\] to authenticate yourself." ; return 0}
	setuser $hand PASS $rest ; putquick "NOTICE $nick :$cmdathlg Your password now sets to: $rest, remember your password for future use."
	putcmdlog "$cmdathlg <<$nick>> !$hand! Set Password." ; return 0
}

proc msg_auth {nick uhost hand rest} {
	global botnick cmdathlg ; set pw [lindex $rest 0]
	if {$pw == ""} {putquick "NOTICE $nick :$cmdathlg Command: /msg $botnick auth <password>" ; return 0}
	if {[passwdok $hand ""]} {putquick "NOTICE $nick :$cmdathlg You haven't set your password. Type: \[/msg $botnick pass <password>\] to set-up Your password." ; return 0}
	if {[matchattr $hand Q]} {putquick "NOTICE $nick :$cmdathlg You have authenticate before, no need another authentication." ; return 0}
	if {![passwdok $hand $pw]} {putquick "NOTICE $nick :$cmdathlg Authentication rejected!!, check out Your password." ; return 0}
	chattr $hand +Q ; putquick "NOTICE $nick :$cmdathlg Authentication accepted!!, thank you for Your authentication."
	putcmdlog "$cmdathlg <<$nick>> !$hand! Authentication." ; return 0
}

proc msg_deauth {nick uhost hand rest} {
	global botnick cmdathlg ; if {$rest == ""} {putquick "NOTICE $nick :$cmdathlg Command: /msg $botnick auth <password>" ; return 0}
	if {[passwdok $hand ""]} {putquick "NOTICE $nick :$cmdathlg You haven't set your password. Type: \[/msg $botnick pass <password>\] to set-up Your password." ; return 0}
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdathlg You haven't authenticate at all!!, Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	if {![passwdok $hand $rest]} {putquick "NOTICE $nick :$cmdathlg Deauthentication rejected!!, check out Your password." ; return 0}
	chattr $hand -Q ; putquick "NOTICE $nick :$cmdathlg Deauthentication finished!!, remember to authenticate again before You run another PUBLIC commands."
	putcmdlog "$cmdathlg <<$nick>> !$hand! Deauthenticate." ; return 0
}

proc pub_auth {nick uhost hand chan rest} {
	global ATHPRM botnick cmdathlg ; if {[matchattr $hand Q]} {putquick "NOTICE $nick :$cmdathlg You have authenticate before, no need another authentication." ; return 0}
	chattr $hand +Q ; putquick "NOTICE $nick :$cmdathlg Global Authentication completed!!, thank you for Your authentication."
	putcmdlog "$cmdathlg <<$nick>> !$hand! $chan: Global Authentication." ; return 0
}

proc pub_deauth {nick uhost hand chan rest} {
	global ATHPRM botnick cmdathlg ; if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdathlg You haven't authenticate at all!!, Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	chattr $hand -Q ; putquick "NOTICE $nick :$cmdathlg Global Deauthentication finished!!, remember to authenticate again before You run another PUBLIC commands."
	putcmdlog "$cmdathlg <<$nick>> !$hand! $chan: Global Deauthentication." ; return 0
}

proc part_deauth {nick uhost hand chan rest} {
	global botnick cmdathlg ; if {![matchattr $hand Q]} {return 0}
	chattr $hand -Q ; putlog "$cmdathlg $hand no longer exist on $chan, performing Auto-deatentication." ; return 0
}

proc sign_deauth {nick uhost hand chan rest} {part_deauth $nick $uhost $hand $chan $rest}

# Set this to "1" if you like the script to be loaded.. and set it to "0" to unload.
set cmdauthloaded 1

if {[info exist cmdauthloaded]} {
	if {${cmdauthloaded}} {
		unbind msg - pass *msg:pass
		bind msg p|p pass msg_pass
		bind msg p|p auth msg_auth
		bind msg p|p deauth msg_deauth
		bind pub n ${ATHPRM}auth pub_auth
		bind pub n ${ATHPRM}deauth pub_deauth
		bind part p|p * part_deauth
		bind sign p|p * sign_deauth
	} else {
		bind msg - pass msg:pass
		unbind msg p|p pass msg_pass
		unbind msg p|p auth msg_auth
		unbind msg p|p deauth msg_deauth
		unbind pub n ${ATHPRM}auth pub_auth
		unbind pub n ${ATHPRM}deauth pub_deauth
		unbind part p|p * part_deauth
		unbind sign p|p * sign_deauth
	}
	
}

# End of - Commands & Control, Authentication. (cmd_auth.tcl)

# Begin - Commands & Control, Channel Control. (cmd_chan.tcl)
#	Designed & Written by TCP-IP (Vicky@Vic.ky), © April 1999
#	Developed by Ninja_baby (Jaysee@Jaysee.Tv), © March 2000

# This script was made by TCP-IP in middle of 1999, I develop this script since he passes this script-
# to me in middle of 2000. I made few changes, add some features, and fixed some bugs that were remain-
# here in this script package.

# This TCL contains some public / msg commands related to channel's stuffs.. such as to ban, kick, op-
# deop, etc... simpy do /msg <yourbotnick> chanhelp or do `chanhelp in channel to see what commands-
# did this script has.. I set 2 types of commands.. /msg commands and public (channel) commands.
# NOTE: not much.. even almost has no DCC command stuffs here.. I will make the DCC commands very soon ;)
#       so please support ;)

# Set this as your Public (channel) command character. For example: you set this to ".".. means you must-
# type !mycommand in channel to activate public commands.
set CHPRM "."

# This is for network compatiblity (be sure your IRC network using SirvServces) with ChanServ arround.
# I set this with DALnet's ChanServ's nickname.. you can set it according to your ChanServ's nickname-
# in your IRC network ;)
set cmdsvrnick "ChanServ"

if {[info exist ban-time]} {
	# Checking whenever the "ban-time" variable is exist on your bot conf file. (Default)
	set gbantime ${ban-time}
} else {
	# Set this as global ban time.. this will be use when you trigger +ban / +gban command to ban ppl-
	# out of channel.. when you're not typing a ban time.. the bot will set the ban time according with-
	# what you set here.. set this variable in Minute(s) format.
	# Remember that if "ban-time" variable (which taken from your eggdrop.conf.dist file) already-
	# exist, you do not need to set the bantime from here, this script will automaticly add the-
	# variable from your bot conf file.
	set gbantime 15
}

# This is for your benefit hehe ;), you can either set your own LOGO here, your logo will appear-
# when the bot notice you, or when it makes msgs/notices/kicks or scripts loading. So keep smiling-
# and set this variable as you wish ;), you can either set this to "" to leave it blank.
set cmdchnlg "\[S-B\]:"

######### Please do not edit anything below unless you know what you are doing ;) #########

proc msg_masuk {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0] ; set chankey [lindex $rest 1]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick join <#channel> \[join-key\]" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {[validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am already on $chan." ; return 0}
	channel add $chan ; utimer 1 save
	if {$chankey == ""} {putquick "NOTICE $nick :$cmdchnlg Joining myself to channel: $chan. Updating channel list." ; putcmdlog "$cmdchnlg <<$nick>> !$hand! Join $chan." ; return 0}
	putquick "JOIN $chan $chankey"
	putquick "NOTICE $nick :$cmdchnlg Joining myself to channel: $chan with Join-key: $chankey. Updating channel list."
	putcmdlog "$cmdchnlg <<$nick>> !$hand! Join $chan (Join-key: $chankey)." ; return 0
}

proc pub_masuk {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set channel [lindex $rest 0] ; if {$channel == "#" || $channel == ""} {putquick "NOTICE $nick :$cmdchnlg Command: \[${CHPRM}join <#channel> \[join-key\]\]" ; return 0}
	msg_masuk $nick $uhost $hand $rest
}

proc msg_cabut {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick leave <#channel>" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {![isdynamic $chan]} {putquick "NOTICE $nick :$cmdchnlg I appologize, but I cannot part from $chan, coz' it is not a dynamic channel." ; return 0}
	channel remove $chan ; utimer 1 save
	putquick "NOTICE $nick :$cmdchnlg I am now leaving channel: $chan. Updating channel list."
	putcmdlog "$cmdchnlg <<$nick>> !$hand! Leave $chan." ; return 0
}

proc pub_cabut {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set rest [lindex $rest 0] ; if {$rest == "#" || $rest == ""} {set rest $chan}
	msg_cabut $nick $uhost $hand $rest
}

proc msg_cycle {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0]
	if {$chan == "#"} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick cycle \[#channel\]" ; return 0}
	if {$chan == ""} {set chan "ALL"
	} else {if {![string match "#*" $chan]} {set chan "#$chan" ; if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}}}
	if {$chan != "ALL"} {
		putquick "PART $chan :$chan" ; putquick "JOIN $chan" ; putquick "NOTICE $nick :$cmdchnlg Cycling: $chan."
	} else {
		foreach pchan [channels] {
			putquick "PART $pchan :Cycling" ; putquick "JOIN $pchan" ; putquick "NOTICE $nick :$cmdchnlg Cycling: $pchan."
		}
	} ; putcmdlog "$cmdchnlg <<$nick>> !$hand! Cycle." ; return 0
}

proc pub_cycle {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set chans "" ; if {$rest == ""} {msg_cycle $nick $uhost $hand $chan} else {msg_cycle $nick $uhost $hand $rest}
}

proc msg_konci {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand p]} {putquick "NOTICE $nick :$cmdchnlg You have +o privelage but you don't have +p, you need +p flag to set your password and authenticate before phrasing commands. Ask my owner/master to set that flag for you =)" ; return 0}
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick lock <#channel>" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {![botisop $chan]} {putquick "NOTICE $nick :$cmdchnlg I appologize, but I am not an Operator on channel: $chan. Your command cannot be perform." ; return 0}
	set currmode [getchanmode $chan] ; set lockmode ""
	if {![string match "*m*" $currmode]} {append lockmode "m"}
	if {![string match "*i*" $currmode]} {append lockmode "i"}
	if {$lockmode == ""} {putquick "NOTICE $nick :$cmdchnlg Channel $chan already locked. I will not lock that channel twice." ; return 0}
	putquick "MODE $chan $lockmode"
	putcmdlog "$cmdchnlg <<$nick>> !$hand! Lock $chan." ; return 0
}

proc pub_konci {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set rest [lindex $rest 0] ; if {$rest == "#" || $rest == ""} {set rest $chan}
	msg_konci $nick $uhost $hand $rest
}

proc msg_buka {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand p]} {putquick "NOTICE $nick :$cmdchnlg You have +o privelage but you don't have +p, you need +p flag to set your password and authenticate before phrasing commands. Ask my owner/master to set that flag for you =)" ; return 0}
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick unlock <#channel>" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {![botisop $chan]} {putquick "NOTICE $nick :$cmdchnlg I appologize, but I am not an Operator on channel: $chan. Your command cannot be perform." ; return 0}
	set currmode [getchanmode $chan] ; set lockmode ""
	if {[string match "*m*" $currmode]} {append lockmode "m"}
	if {[string match "*i*" $currmode]} {append lockmode "i"}
	if {$lockmode == ""} {putquick "NOTICE $nick :$cmdchnlg Channel $chan is not locked." ; return 0}
	putquick "MODE $chan -$lockmode"
	putcmdlog "$cmdchnlg <<$nick>> !$hand! Unlock $chan." ; return 0
}

proc pub_buka {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set rest [lindex $rest 0] ; if {$rest == "#" || $rest == ""} {set rest $chan}
	msg_buka $nick $uhost $hand $rest
}

proc msg_cmode {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand p]} {putquick "NOTICE $nick :$cmdchnlg You have +o privelage but you don't have +p, you need +p flag to set your password and authenticate before phrasing commands. Ask my owner/master to set that flag for you =)" ; return 0}
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0] ; set mlock [lrange $rest 1 end]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick cmode <#channel> <+/-modelocks>" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {$mlock == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick cmode $chan <+/-modelocks>" ; return 0}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {![botisop $chan]} {putquick "NOTICE $nick :$cmdchnlg I appologize, but I am not an Operator on channel: $chan. Your command cannot be perform." ; return 0}
	putquick "MODE $chan $mlock"
	putcmdlog "$cmdchnlg <<$nick>> !$hand! Mode change: $rest on channel: $chan." ; return 0
}

proc pub_cmode {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set chans "" ; set channel [lindex $rest 0]
	if {![string match "#*" $channel]} {set channel $chan ; append chans "$channel $rest "} else {append chans " $rest"}
	set cmodes [lindex $chans 1]
	if {$cmodes == ""} {putquick "NOTICE $nick :$cmdchnlg Command: ${CHPRM}cmode \[#channel\] <+/-modelocks>" ; return 0}
	msg_cmode $nick $uhost $hand $chans
}

proc msg_opbot {nick uhost hand rest} {
	global CHPRM botnick cmdsvrnick cmdchnlg
	if {![matchattr $hand p]} {putquick "NOTICE $nick :$cmdchnlg You have +o privelage but you don't have +p, you need +p flag to set your password and authenticate before phrasing commands. Ask my owner/master to set that flag for you =)" ; return 0}
	if {$cmdsvrnick == ""} {putquick "NOTICE $nick :$cmdchnlg This network doesn't have any channel services, or you set its nick blank, I cannot Op myself." ; return 0}
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick up <#channel>" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {[botisop $chan]} {putquick "NOTICE $nick :$cmdchnlg I am already Opped on channel: $chan." ; return 0}
	if {$cmdsvrnick == ""} {putquick "NOTICE $nick :$cmdchnlg This network doesn't have any channel services, or you set its nick blank, I cannot Op myself." ; return 0}
	putquick "PRIVMSG $cmdsvrnick :op $chan $botnick"
	putcmdlog "$cmdchnlg <<$nick>> !$hand! Self-Op on channel: $chan." ; return 0
}

proc pub_opbot {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set rest [lindex $rest 0] ; if {$rest == "#" || $rest == ""} {set rest $chan}
	msg_opbot $nick $uhost $hand $rest
}

proc msg_deopbot {nick uhost hand rest} {
	global CHPRM botnick cmdchnlg
	if {![matchattr $hand p]} {putquick "NOTICE $nick :$cmdchnlg You have +o privelage but you don't have +p, you need +p flag to set your password and authenticate before phrasing commands. Ask my owner/master to set that flag for you =)" ; return 0}
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick down <#channel>" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {![botisop $chan]} {putquick "NOTICE $nick :$cmdchnlg I appologize, but I am not an Operator on channel: $chan. Your command cannot be perform." ; return 0}
	putquick "MODE $chan +v-o $botnick $botnick"
	putcmdlog "$cmdchnlg <<$nick>> !$hand! Self-DeOp on channel: $chan." ; return 0
}

proc pub_deopbot {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set rest [lindex $rest 0] ; if {$rest == "#" || $rest == ""} {set rest $chan}
	msg_deopbot $nick $uhost $hand $rest
}

proc msg_naekin {nick uhost hand rest} {
	global botnick cmdsvrnick cmdchnlg
	if {![matchattr $hand p]} {putquick "NOTICE $nick :$cmdchnlg You have +o privelage but you don't have +p, you need +p flag to set your password and authenticate before phrasing commands. Ask my owner/master to set that flag for you =)" ; return 0}
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0] ; set opnick [lrange $rest 1 end]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick op <#channel> <nickname(s)>" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {$opnick == ""} {
		if {[isop $nick $chan]} {putquick "NOTICE $nick :$cmdchnlg You are already Opped on channel: $chan." ; return 0}
		if {![botisop $chan]} {
			if {$cmdsvrnick == ""} {putquick "NOTICE $nick :$cmdchnlg This network doesn't have any channel services, or you set its nick blank, I cannot Op you since I'm not opped." ; return 0}
			putquick "PRIVMSG $cmdsvrnick :op $chan $nick" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! $cmdsvrnick Op: $nick on channel: $chan." ; return 0
		}
		if {![onchan $nick $chan]} {putquick "NOTICE $nick :$cmdchnlg You are not on channel: $chan." ; return 0}
		putquick "MODE $chan +o $nick" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! Op: $nick on channel: $chan." ; return 0
	}
	set opnicks "" ; set gopnicks "" ; set nonenicks "" ; set gotop 0
	foreach x $opnick {
		if {(![onchansplit $x $chan]) && (![isbotnick $x])} {
			if {[string toupper $x] == "ME"} {set x $nick}
			if {$gotop < 6} {if {[isop $x $chan]} {append gopnicks " $x"} else {if {![onchan $x $chan]} {append nonenicks " $x"} else {append opnicks " $x" ; set gotop [expr $gotop + 1]}}}
			if {$gotop == 6} {
				set gotop 0
				if {$opnicks != ""} {
					if {![botisop $chan]} {
						if {$cmdsvrnick == ""} {putquick "NOTICE $nick :$cmdchnlg This network doesn't have any channel services, or you set its nick blank, I cannot Op anyone since I'm not opped." ; return 0}
						putquick "PRIVMSG $cmdsvrnick :op $chan $opnicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! $cmdsvrnick Op: $opnicks on channel: $chan."
					} else {
						putquick "MODE $chan +oooooo $opnicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! Op: $opnicks on channel: $chan."
					}
					set opnicks "" ; append opnicks " $x" ; set gotop 1
				}
			}
		}
	}
	if {$nonenicks != ""} {putquick "NOTICE $nick :$cmdchnlg $nonenicks is not on channel: $chan."}
	if {$gopnicks != ""} {putquick "NOTICE $nick :$cmdchnlg $gopnicks already Oped on channel: $chan."}
	if {$opnicks != ""} {
		if {![botisop $chan]} {
			if {$cmdsvrnick == ""} {putquick "NOTICE $nick :$cmdchnlg This network doesn't have any channel services, or you set its nick blank, I cannot Op anyone since I'm not opped." ; return 0}
			putquick "PRIVMSG $cmdsvrnick :op $chan $opnicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! $cmdsvrnick Op: $opnicks on channel: $chan."
		} else {
			putquick "MODE $chan +oooooo $opnicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! Op: $opnicks on channel: $chan."
		}
	} ; return 0
}

proc pub_naekin {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set chans "" ; set channel [lindex $rest 0]
	if {![string match "#*" $channel]} {set channel $chan ; append chans "$channel $rest "} else {append chans " $rest"}
	msg_naekin $nick $uhost $hand $chans
}

proc msg_turunin {nick uhost hand rest} {
	global botnick cmdsvrnick cmdchnlg
	if {![matchattr $hand p]} {putquick "NOTICE $nick :$cmdchnlg You have +o privelage but you don't have +p, you need +p flag to set your password and authenticate before phrasing commands. Ask my owner/master to set that flag for you =)" ; return 0}
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0] ; set deopnick [lrange $rest 1 end]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick deop <#channel> <nickname(s)>" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {$deopnick == ""} {
		if {![isop $nick $chan]} {putquick "NOTICE $nick :$cmdchnlg You are not Opped on channel: $chan." ; return 0}
		if {![botisop $chan]} {
		if {$cmdsvrnick == ""} {putquick "NOTICE $nick :$cmdchnlg This network doesn't have any channel services, or you set its nick blank, I cannot DeOp you since I'm not opped." ; return 0}
			putquick "PRIVMSG $cmdsvrnick :deop $chan $nick" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! $cmdsvrnick DeOp: $nick on channel: $chan." ; return 0
		}
		if {![onchan $nick $chan]} {putquick "NOTICE $nick :$cmdchnlg You are not on channel: $chan." ; return 0}
		putquick "MODE $chan -o $nick" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! DeOp: $nick on channel: $chan." ; return 0
	}
	set deopnicks "" ; set nopnicks "" ; set nonenicks "" ; set ownicks "" ; set gotdeop 0
	foreach x $deopnick {
		if {(![onchansplit $x $chan]) && (![isbotnick $x])} {
			if {[string toupper $x] == "ME"} {set x $nick}
			if {$gotdeop < 6} {if {![isop $x $chan]} {append nopnicks " $x"} else {if {![onchan $x $chan]} {append nonenicks " $x"} else {if {[matchattr [nick2hand $x $chan] m]} {append ownicks " $x"} else {append deopnicks " $x" ; set gotdeop [expr $gotdeop + 1]}}}}
			if {$gotdeop == 6} {
				set gotdeop 0
				if {$deopnicks != ""} {
					if {![botisop $chan]} {
						if {$cmdsvrnick == ""} {putquick "NOTICE $nick :$cmdchnlg This network doesn't have any channel services, or you set its nick blank, I cannot DeOp anyone since I'm not opped." ; return 0}
						putquick "PRIVMSG $cmdsvrnick :deop $chan $deopnicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! $cmdsvrnick DeOp: $deopnicks on channel: $chan."
					} else {
						putquick "MODE $chan -oooooo $deopnicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! DeOp: $deopnicks on channel: $chan."
					}
					set deopnicks "" ; append deopnicks " $x" ; set gotdeop 1
				}
			}
		}
	}
	if {$nonenicks != ""} {putquick "NOTICE $nick :$cmdchnlg $nonenicks is not on channel: $chan."}
	if {$nopnicks != ""} {putquick "NOTICE $nick :$cmdchnlg $nopnicks already DeOped on channel: $chan."}
	if {$ownicks != ""} {putquick "NOTICE $nick :$cmdchnlg $ownicks are my \[Master(s)\], and will I will not DeOp them on channel: $chan."}
	if {$deopnicks != ""} {
		if {![botisop $chan]} {
			if {$cmdsvrnick == ""} {putquick "NOTICE $nick :$cmdchnlg This network doesn't have any channel services, or you set its nick blank, I cannot DeOp anyone since I'm not opped." ; return 0}
			putquick "PRIVMSG $cmdsvrnick :deop $chan $deopnicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! $cmdsvrnick DeOp: $deopnicks on channel: $chan."
		} else {
			putquick "MODE $chan -oooooo $deopnicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! DeOp: $deopnicks on channel: $chan."
		}
	} ; return 0
}

proc pub_turunin {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set chans "" ; set channel [lindex $rest 0]
	if {![string match "#*" $channel]} {set channel $chan ; append chans "$channel $rest "} else {append chans " $rest"}
	msg_turunin $nick $uhost $hand $chans
}

proc msg_massop {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick mop <#channel>" ; return 0}
	set massopnick [chanlist $chan]
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {![botisop $chan]} {putquick "NOTICE $nick :$cmdchnlg I appologize, but I am not an Operator on channel: $chan. Your command cannot be perform." ; return 0}
	set massopnicks "" ; set gotop 0
	foreach x $massopnick {
		if {(![isop $x $chan]) && (![onchansplit $x $chan]) && (![isbotnick $x])} {
			if {$gotop < 6} {append massopnicks " $x" ; set gotop [expr $gotop + 1]}
			if {$gotop == 6} {
				set gotop 0
				if {$massopnicks != ""} {
					putquick "MODE $chan +oooooo $massopnicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! MassOp on channel: $chan by: $nick."
					set massopnicks "" ; append massopnicks " $x" ; set gotop 1
				}
			}
		}
	}
	if {$massopnicks != ""} {putquick "MODE $chan +oooooo $massopnicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! MassOp on channel: $chan by: $nick."} ; return 0
}

proc pub_massop {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set channel [lindex $rest 0]
	if {$channel == ""} {set channel $chan} else {if {![string match "#*" $channel]} {set channel "#$channel"}}
	msg_massop $nick $uhost $hand $channel
}

proc msg_massdeop {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick mdeop <#channel>" ; return 0}
	set massdeopnick [chanlist $chan]
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {![botisop $chan]} {putquick "NOTICE $nick :$cmdchnlg I appologize, but I am not an Operator on channel: $chan. Your command cannot be perform." ; return 0}
	set massdeopnicks "" ; set ownicks "" ; set gotdeop 0
	foreach x $massdeopnick {
		if {([isop $x $chan]) && (![onchansplit $x $chan]) && (![isbotnick $x])} {
			if {$gotdeop < 6} {if {[matchattr [nick2hand $x $chan] m]} {append ownicks " $x"} else {append massdeopnicks " $x" ; set gotdeop [expr $gotdeop + 1]}}
			if {$gotdeop == 6} {
				set gotdeop 0
				if {$massdeopnicks != ""} {
					putquick "MODE $chan -oooooo $massdeopnicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! Mass DeOp on channel: $chan by: $nick."
					set massdeopnicks "" ; append massdeopnicks " $x" ; set gotdeop 1
				}
			}
		}
	}
	if {$ownicks != ""} {putquick "NOTICE $nick :$cmdchnlg $ownicks are my \[Master(s)\], and will I will not DeOp them on channel: $chan."}
	if {$massdeopnicks != ""} {putquick "MODE $chan -oooooo $massdeopnicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! Mass DeOp on channel: $chan by: $nick."} ; return 0
}

proc pub_massdeop {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set channel [lindex $rest 0]
	if {$channel == ""} {set channel $chan} else {if {![string match "#*" $channel]} {set channel "#$channel"}}
	msg_massdeop $nick $uhost $hand $channel
}

proc msg_pois {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand p]} {putquick "NOTICE $nick :$cmdchnlg You have +o privelage but you don't have +p, you need +p flag to set your password and authenticate before phrasing commands. Ask my owner/master to set that flag for you =)" ; return 0}
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0] ; set vonick [lrange $rest 1 end]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick voice <#channel> <nickname(s)>" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {![botisop $chan]} {putquick "NOTICE $nick :$cmdchnlg I appologize, but I am not an Operator on channel: $chan. Your command cannot be perform." ; return 0}
	if {$vonick == ""} {
		if {[isvoice $nick $chan]} {putquick "NOTICE $nick :$cmdchnlg You are already Voiced on channel: $chan." ; return 0}
		if {![onchan $nick $chan]} {putquick "NOTICE $nick :$cmdchnlg You are not on channel: $chan." ; return 0}
		putquick "MODE $chan +v $nick" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! Voice: $nick on channel: $chan." ; return 0
	}
	set vonicks "" ; set gvonicks "" ; set nonenicks "" ; set gotvoiced 0
	foreach x $vonick {
		if {(![onchansplit $x $chan]) && (![isbotnick $x])} {
			if {[string toupper $x] == "ME"} {set x $nick}
			if {$gotvoiced < 6} {if {[isvoice $x $chan]} {append gvonicks " $x"} else {if {![onchan $x $chan]} {append nonenicks " $x"} else {append vonicks " $x" ; set gotvoiced [expr $gotvoiced + 1]}}}
			if {$gotvoiced == 6} {
				set gotvoiced 0
				if {$vonicks != ""} {
					putquick "MODE $chan +vvvvvv $vonicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! Voice: $vonicks on channel: $chan."
					set vonicks "" ; append vonicks " $x" ; set gotvoiced 1
				}
			}
		}
	}
	if {$nonenicks != ""} {putquick "NOTICE $nick :$cmdchnlg $nonenicks is not on channel: $chan."}
	if {$gvonicks != ""} {putquick "NOTICE $nick :$cmdchnlg $gvonicks already Voiced on channel: $chan."}
	if {$vonicks != ""} {putquick "MODE $chan +vvvvvv $vonicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! Voice: $vonicks on channel: $chan."} ; return 0
}

proc pub_pois {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set chans "" ; set channel [lindex $rest 0]
	if {![string match "#*" $channel]} {set channel $chan ; append chans "$channel $rest "} else {append chans " $rest"}
	msg_pois $nick $uhost $hand $chans
}

proc msg_depois {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand p]} {putquick "NOTICE $nick :$cmdchnlg You have +o privelage but you don't have +p, you need +p flag to set your password and authenticate before phrasing commands. Ask my owner/master to set that flag for you =)" ; return 0}
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0] ; set dvonick [lrange $rest 1 end]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick devoice <#channel> <nickname(s)>" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {![botisop $chan]} {putquick "NOTICE $nick :$cmdchnlg I appologize, but I am not an Operator on channel: $chan. Your command cannot be perform." ; return 0}
	if {$dvonick == ""} {
		if {![isvoice $nick $chan]} {putquick "NOTICE $nick :$cmdchnlg You are already DeVoiced on channel: $chan." ; return 0}
		if {![onchan $nick $chan]} {putquick "NOTICE $nick :$cmdchnlg You are not on channel: $chan." ; return 0}
		putquick "MODE $chan -v $nick" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! DeVoice: $nick on channel: $chan." ; return 0
	}
	set dvonicks "" ; set gdvonicks "" ; set nonenicks "" ; set devoiced 0
	foreach x $dvonick {
		if {(![onchansplit $x $chan]) && (![isbotnick $x])} {
			if {[string toupper $x] == "ME"} {set x $nick}
			if {$devoiced < 6} {if {![isvoice $x $chan]} {append gdvonicks " $x"} else {if {![onchan $x $chan]} {append nonenicks " $x"} else {append dvonicks " $x" ; set devoiced [expr $devoiced + 1]}}}
			if {$devoiced == 6} {
				set devoiced 0
				if {$dvonicks != ""} {
					putquick "MODE $chan -vvvvvv $dvonicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! DeVoice: $dvonicks on channel: $chan."
					set dvonicks "" ; append dvonicks " $x" ; set devoiced 1
				}
			}
		}
	}
	if {$nonenicks != ""} {putquick "NOTICE $nick :$cmdchnlg $nonenicks is not on channel: $chan."}
	if {$gdvonicks != ""} {putquick "NOTICE $nick :$cmdchnlg $gdvonicks are not Voiced on channel: $chan."}
	if {$dvonicks != ""} {putquick "MODE $chan -vvvvvv $dvonicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! DeVoice: $dvonicks on channel: $chan."} ; return 0
}

proc pub_depois {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set chans "" ; set channel [lindex $rest 0]
	if {![string match "#*" $channel]} {set channel $chan ; append chans "$channel $rest "} else {append chans " $rest"}
	msg_depois $nick $uhost $hand $chans
}

proc msg_massvo {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick mvoice <#channel>" ; return 0}
	set massvonick [chanlist $chan]
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {![botisop $chan]} {putquick "NOTICE $nick :$cmdchnlg I appologize, but I am not an Operator on channel: $chan. Your command cannot be perform." ; return 0}
	set massvonicks "" ; set gmvoiced 0
	foreach x $massvonick {
		if {(![isvoice $x $chan]) && (![onchansplit $x $chan]) && (![isbotnick $x])} {
			if {$gmvoiced < 6} {append massvonicks " $x" ; set gmvoiced [expr $gmvoiced + 1]}
			if {$gmvoiced == 6} {
				set gmvoiced 0
				if {$massvonicks != ""} {
					putquick "MODE $chan +vvvvvv $massvonicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! Mass Voice on channel: $chan by: $nick."
					set massvonicks "" ; append massvonicks " $x" ; set gmvoiced 1
				}
			}
		}
	}
	if {$massvonicks != ""} {putquick "MODE $chan +vvvvvv $massvonicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! Mass Voice on channel: $chan by: $nick."} ; return 0
}

proc pub_massvo {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set channel [lindex $rest 0]
	if {$channel == ""} {set channel $chan} else {if {![string match "#*" $channel]} {set channel "#$channel"}}
	msg_massvo $nick $uhost $hand $channel
}

proc msg_massdevo {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick mdevo <#channel>" ; return 0}
	set massdevonick [chanlist $chan]
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {![botisop $chan]} {putquick "NOTICE $nick :$cmdchnlg I appologize, but I am not an Operator on channel: $chan. Your command cannot be perform." ; return 0}
	set massdevonicks "" ; set gmdvoice 0
	foreach x $massdevonick {
		if {([isvoice $x $chan]) && (![onchansplit $x $chan]) && (![isbotnick $x])} {
			if {$gmdvoice < 6} {append massdevonicks " $x" ; set gmdvoice [expr $gmdvoice + 1]}
			if {$gmdvoice == 6} {
				set gmdvoice 0
				if {$massdevonicks != ""} {
					putquick "MODE $chan -vvvvvv $massdevonicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! Mass DeVoice on channel: $chan by: $nick."
					set massdevonicks "" ; append massdevonicks " $x" ; set gmdvoice 1
				}
			}
		}
	}
	if {$massdevonicks != ""} {putquick "MODE $chan -vvvvvv $massdevonicks" ; putcmdlog "$cmdchnlg <<$nick>> !$hand! Mass DeVoice on channel: $chan by: $nick."} ; return 0
}

proc pub_massdevo {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set channel [lindex $rest 0]
	if {$channel == ""} {set channel $chan} else {if {![string match "#*" $channel]} {set channel "#$channel"}}
	msg_massdevo $nick $uhost $hand $channel
}

proc msg_tendang {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand p]} {putquick "NOTICE $nick :$cmdchnlg You have +o privelage but you don't have +p, you need +p flag to set your password and authenticate before phrasing commands. Ask my owner/master to set that flag for you =)" ; return 0}
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0] ; set knick [lrange $rest 1 end]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick kick <#channel> <nickname(s)> \[!reason\]" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {$knick == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick kick $chan <nickname(s)> \[!reason\]" ; return 0}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {![botisop $chan]} {putquick "NOTICE $nick :$cmdchnlg I appologize, but I am not an Operator on channel: $chan. Your command cannot be perform." ; return 0}
	set knicks "" ; set ownicks "" ; set nonenicks "" ; set reason ""
	foreach x $knick {
		if {(![onchansplit $x $chan]) && (![isbotnick $x])} {
			if {[string match "!*" $x]} {set reason "4$cmdchnlg $x"} else {if {[matchattr [nick2hand $x $chan] m]} {append ownicks " $x"} else {if {![onchan $x $chan]} {append nonenicks " $x"} else {append knicks "$x,"}}}
		}
	}
	if {$nonenicks != ""} {putquick "NOTICE $nick :$cmdchnlg $nonenicks is not on channel: $chan."}
	if {$ownicks != ""} {putquick "NOTICE $nick :$cmdchnlg $ownicks are my \[Master(s)\], and will I will not Kick them from channel: $chan."}
	if {$knicks != ""} {
		if {$reason == ""} {set reason "4$cmdchnlg Requested by: $nick"} ; putkick $chan $knicks $reason
		putcmdlog "$cmdchnlg <<$nick>> !$hand! Kick: ${knicks} from channel: $chan. Reason: $reason."
	} ; return 0
}

proc pub_tendang {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set chans "" ; set channel [lindex $rest 0]
	if {![string match "#*" $channel]} {set channel $chan ; append chans "$channel $rest "} else {append chans " $rest"}
	set knicks [lindex $chans 1]
	if {$knicks == ""} {putquick "NOTICE $nick :$cmdchnlg Command: ${CHPRM}kick $chan <nickname(s)> \[!reason\]" ; return 0}
	msg_tendang $nick $uhost $hand $chans
}

proc msg_mtendang {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick mkick <#channel> \[!reason\]" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {![botisop $chan]} {putquick "NOTICE $nick :$cmdchnlg I appologize, but I am not an Operator on channel: $chan. Your command cannot be perform." ; return 0}
	set knick [chanlist $chan]
	set knicks "" ; set ownicks "" ; set reason ""
	foreach x $knick {
		if {(![onchansplit $x $chan]) && (![isbotnick $x])} {
			if {[string match "!*" $x]} {set reason "4$cmdchnlg $x"} else {if {[matchattr [nick2hand $x $chan] m]} {append ownicks " $x"} else {append knicks "$x,"}}
		}
	}
	if {$ownicks != ""} {putquick "NOTICE $nick :$cmdchnlg $ownicks are my \[Master(s)\], and will I will not Kick them from channel: $chan."}
	if {$knicks != ""} {
		if {$reason == ""} {set reason "4$cmdchnlg Mass Kick by: $nick"} ; putkick $chan $knicks $reason
		putcmdlog "$cmdchnlg <<$nick>> !$hand! Mass Kick on channel: $chan. Reason: $reason."
	} ; return 0
}

proc pub_mtendang {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set chans "" ; set channel [lindex $rest 0]
	if {![string match "#*" $channel]} {set channel $chan ; append chans "$channel $rest "} else {append chans " $rest"}
	msg_mtendang $nick $uhost $hand $chans
}

proc msg_+ban {nick uhost hand rest} {
	global botnick gbantime cmdchnlg
	if {![matchattr $hand p]} {putquick "NOTICE $nick :$cmdchnlg You have +o privelage but you don't have +p, you need +p flag to set your password and authenticate before phrasing commands. Ask my owner/master to set that flag for you =)" ; return 0}
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick +ban <#channel> <nickname/hostname> \[ban time (minute(s))\] \[reason\]" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	set rest [lrange $rest 1 end]
	if {$rest == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick +ban <#channel> <nickname/hostname> \[ban time (minute(s))\] \[reason\]" ; return 0}
	set bntime [lindex $rest 1] ; set reason [lrange $rest 2 end]
	set bntime [string trim $bntime "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_+|~,./;'<>?:{}"]
	if {$bntime == ""} {if {$gbantime <= 0} {set gbantime 15} ; set bntime $gbantime}
	if {$reason == ""} {set reason "4$cmdchnlg Requested by: $nick"}
	set bannick [lindex $rest 0]
	if {[string match "*@*" $bannick]} {
		set host $bannick ; set banhost $host ; set banhand $host
	} else {
		if {![onchan $bannick $chan]} {putquick "NOTICE $nick :$cmdchnlg $bannick is not on channel: $chan." ; return 0
		} else {set host [getchanhost $bannick $chan] ; set banhost *!*@[lindex [split $host @] 1]}
		set banhand [nick2hand $bannick $chan]
	}
	if {[string tolower $bannick] == [string tolower $botnick]} {putquick "NOTICE $nick :$cmdchnlg I will not ban on myself." ; return 0}
	if {[matchattr $banhand f]} {putquick "NOTICE $nick :$cmdchnlg I will not place ban on $bannick coz a hostmask of this user is included in my user list." ; return 0}
	foreach x [userlist] {
		if {[string match *$x* $banhost]} {putquick "NOTICE $nick :$cmdchnlg I will not place ban on $bannick coz this hostmask belongs to me or one of my users." ; return 0}
		if {[getchanhost $x $chan] != ""} {
			set rhostmem [lindex [split [getchanhost $x $chan] @] 1] ; set rhostban [string trim [lindex [split $banhost @] 1] "\*\."]
			set lhostmem [lindex [split [getchanhost $x $chan] @] 0] ; set lhostban [string trim [lindex [split $banhost @] 0] "\*\!\."]
			if {[string match *$rhostban* $rhostmem] && [string match *$lhostban* $lhostmem]} {putquick "NOTICE $nick :$cmdchnlg I will not place ban on $bannick coz this hostmask belongs to me or one of my users." ; return 0}
		}
	}
	if {[ischanban $banhost $chan]} {putquick "NOTICE $nick :$cmdchnlg A local ban already exist on channel: $chan for: $banhost" ; return 0}
	putquick "NOTICE $nick :$cmdchnlg Creating new ban on channel: $chan for: $banhost"
	newchanban $chan $banhost $hand $reason $bntime
	set bmembers [chanlist $chan]
	foreach banmember $bmembers {
		set bselectedhost [getchanhost $banmember $chan]
		set ubanhost *!*@[lindex [split $bselectedhost @] 1]
		if {$ubanhost == $banhost} {putkick $chan $banmember $reason}
	}
	putcmdlog "$cmdchnlg <<$nick>> !$hand! ($chan) +ban $host $bntime $reason" ; return 0
}

proc pub_+ban {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set chans "" ; set channel [lindex $rest 0]
	if {![string match "#*" $channel]} {set channel $chan ; append chans "$channel $rest "} else {append chans " $rest"}
	set bnicks [lindex $chans 1]
	if {$bnicks == ""} {putquick "NOTICE $nick :$cmdchnlg Command: ${CHPRM}+ban \[#channel\] <nickname/hostname> \[ban time (minute(s))\] \[reason\]" ; return 0}
	msg_+ban $nick $uhost $hand $chans
}

proc msg_-ban {nick uhost hand rest} {
	global botnick banlist cmdchnlg
	if {![matchattr $hand p]} {putquick "NOTICE $nick :$cmdchnlg You have +o privelage but you don't have +p, you need +p flag to set your password and authenticate before phrasing commands. Ask my owner/master to set that flag for you =)" ; return 0}
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick -ban <#channel> <nickname/hostname>" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	set rest [lrange $rest 1 end]
	if {$rest == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick -ban <#channel> <nickname/hostname>" ; return 0}
	if {![string match "*@*" $rest]} {
		if {![onchan $rest $chan]} {putquick "NOTICE $nick :$cmdchnlg $rest is not on channel: $chan." ; return 0
		} else {set rest [getchanhost $rest $chan] ; set rest *!*@[lindex [split $rest @] 1]}
	}
	if {[string match *$rest* [lrange [banlist $chan] 0 end]]} {
		putquick "NOTICE $nick :$cmdchnlg Releasing current ban: $rest on channel: $chan"
		killchanban $chan $rest
	} else {
		putquick "NOTICE $nick :$cmdchnlg There are no Bans for: $rest on channel: $chan. Perhaps it was a Global Ban." ; return 0
	}
	putcmdlog "$cmdchnlg <<$nick>> !$hand! ($chan) -ban $rest" ; return 0
}

proc pub_-ban {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set chans "" ; set channel [lindex $rest 0]
	if {![string match "#*" $channel]} {set channel $chan ; append chans "$channel $rest "} else {append chans " $rest"}
	set bnicks [lindex $chans 1]
	if {$bnicks == ""} {putquick "NOTICE $nick :$cmdchnlg Command: ${CHPRM}-ban \[#channel\] <nickname/hostname>" ; return 0}
	msg_-ban $nick $uhost $hand $chans
}

proc msg_+gban {nick uhost hand rest} {
	global botnick gbantime cmdchnlg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set rest [lindex $rest 0]
	if {[string match "#*" $rest]} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick +gban <nickname/hostname> \[ban time (minute(s))\] \[reason\]" ; return 0}
	if {$rest == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick +gban <nickname/hostname> \[ban time (minute(s))\] \[reason\]" ; return 0}
	set bntime [lindex $rest 1] ; set reason [lrange $rest 2 end]
	set bntime [string trim $bntime "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_+|~,./;'<>?:{}"]
	if {$bntime == ""} {if {$gbantime <= 0} {set gbantime 15} ; set bntime $gbantime}
	if {$reason == ""} {set reason "4$cmdchnlg \[GLOBAL Ban\] Requested by: $nick"}
	set bannick [lindex $rest 0]
	if {[string match "*@*" $bannick]} {set host $bannick ; set banhost $host ; set banhand $host} else {set host "" ; set banhost "" ; set banhand ""}
	foreach x [channels] {
		set chan $x
		if {[onchan $bannick $chan]} {if {$host == "" || $banhost == "" || $bannick == ""} {set host [getchanhost $bannick $chan] ; set banhost *!*@[lindex [split $host @] 1] ; set banhand [nick2hand $bannick $chan]}}
	}
	if {$host == "" || $banhost == "" || $banhand == ""} {putquick "NOTICE $nick :$cmdchnlg $bannick is not on any of my channel(s)." ; return 0}
	if {[string tolower $bannick] == [string tolower $botnick]} {putquick "NOTICE $nick :$cmdchnlg I will not ban on myself." ; return 0}
	if {[matchattr $banhand f]} {putquick "NOTICE $nick :$cmdchnlg I will not place ban on $bannick coz a hostmask of this user is included in my user list." ; return 0}
	foreach x [userlist] {
		if {[string match *$x* $banhost]} {putquick "NOTICE $nick :$cmdchnlg I will not place ban on $bannick coz this hostmask belongs to me or one of my users." ; return 0}
		if {[getchanhost $x $chan] != ""} {
			set rhostmem [lindex [split [getchanhost $x $chan] @] 1] ; set rhostban [string trim [lindex [split $banhost @] 1] "\*\."]
			set lhostmem [lindex [split [getchanhost $x $chan] @] 0] ; set lhostban [string trim [lindex [split $banhost @] 0] "\*\!\."]
			if {[string match *$rhostban* $rhostmem] && [string match *$lhostban* $lhostmem]} {putquick "NOTICE $nick :$cmdchnlg I will not place ban on $bannick coz this hostmask belongs to me or one of my users." ; return 0}
		}
	}
	if {[isban $banhost]} {putquick "NOTICE $nick :$cmdchnlg A Global ban already exist for: $banhost" ; return 0}
	putquick "NOTICE $nick :$cmdchnlg Creating new Global ban for: $banhost"
	newban $banhost $hand $reason $bntime
	putcmdlog "$cmdchnlg <<$nick>> !$hand! +gban $host $bntime $reason" ; return 0
}

proc pub_+gban {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set banhost [lindex $rest 0]
	if {[string match "#*" $banhost]} {putquick "NOTICE $nick :$cmdchnlg Command: ${CHPRM}+gban <nickname/hostname> \[ban time (minute(s))\] \[reason\]" ; return 0}
	if {$banhost == ""} {putquick "NOTICE $nick :$cmdchnlg Command: ${CHPRM}+gban <nickname/hostname> \[ban time (minute(s))\] \[reason\]" ; return 0}
	msg_+gban $nick $uhost $hand $banhost
}

proc msg_-gban {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set rest [lindex $rest 0]
	if {[string match "#*" $rest]} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick -gban <nickname/hostname>" ; return 0}
	if {$rest == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick -gban <nickname/hostname>" ; return 0}
	if {![isban $rest]} {putquick "NOTICE $nick :$cmdchnlg There are no Global Bans for: $rest." ; return 0}
	putquick "NOTICE $nick :$cmdchnlg Releasing Global ban for: $rest"
	killban $rest ; regsub -all " " [channels] ", " chans
	putcmdlog "$cmdchnlg <<$nick>> !$hand! -gban $rest" ; return 0
}

proc pub_-gban {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set banhost [lindex $rest 0]
	if {[string match "#*" $banhost]} {putquick "NOTICE $nick :$cmdchnlg Command: ${CHPRM}-gban <nickname/hostname>" ; return 0}
	if {$banhost == ""} {putquick "NOTICE $nick :$cmdchnlg Command: ${CHPRM}-gban <nickname/hostname>" ; return 0}
	msg_-gban $nick $uhost $hand $banhost
}

proc msg_infoban {nick uhost hand rest} {
	global botnick cmdchnlg
	set chan [lindex $rest 0]
	if {$chan == "#" || $chan == ""} {if {[string toupper $chan] != "GLOBAL"} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick baninfo <#channel|GLOBAL>" ; return 0}}
	if {[string toupper $chan] != "GLOBAL"} {if {![string match "#*" $chan]} {set chan "#$chan"}}
	set banlistchan ""
	if {[string toupper $chan] != "GLOBAL"} {
		if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
		foreach x [banlist $chan] {set banlister [lindex $x 0] ; set banlistchan "$banlistchan $banlister"}
		if {[banlist $chan] == ""} {set banlistchan "empty"}
		putquick "NOTICE $nick :$cmdchnlg Ban records for channel: $chan: $banlistchan."
		putcmdlog "$cmdchnlg <<$nick>> !$hand! List Bans on: $banlistchan." ; return 0
	}
	set banlist ""
	if {[string toupper $chan] == "GLOBAL"} {
		foreach x [banlist] {set banlisting [lindex $x 0] ; set banlist "$banlist $banlisting"}
		if {$banlist == ""} {set banlist "empty"}
		putquick "NOTICE $nick :$cmdchnlg Global Ban records: $banlist."
		putcmdlog "$cmdchnlg <<$nick>> !$hand! List Global Bans." ; return 0
	}
}

proc pub_infoban {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set channel [lindex $rest 0]
	if {$channel == "" && [string toupper $channel] != "GLOBAL"} {putquick "NOTICE $nick :$cmdchnlg Command: ${CHPRM}baninfo <#channel|GLOBAL>" ; return 0}
	msg_infoban $nick $uhost $hand $channel
}

proc msg_lepasban {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand p]} {putquick "NOTICE $nick :$cmdchnlg You have +o privelage but you don't have +p, you need +p flag to set your password and authenticate before phrasing commands. Ask my owner/master to set that flag for you =)" ; return 0}
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick rlbans <#channel>" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {![botisop $chan]} {putquick "NOTICE $nick :$cmdchnlg I appologize, but I am not an Operator on channel: $chan. Your command cannot be perform." ; return 0}
	set ban "" ; foreach ban [banlist $chan] {putquick "MODE $chan +b [lindex $ban 0]"} ; putquick "MODE $chan +b"
	putquick "NOTICE $nick :$cmdchnlg Releasing all Bans on channel: $chan. Updating Ban records."
	putcmdlog "$cmdchnlg <<$nick>> !$hand! Release Bans on: $chan." ; return 0
}

proc pub_lepasban {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set channel [lindex $rest 0]
	if {$channel == ""} {set channel $chan} else {if {![string match "#*" $channel]} {set channel "#$channel"}}
	msg_lepasban $nick $uhost $hand $channel
}

proc msg_inpait {nick uhost hand rest} {
	global botnick cmdchnlg
	if {![matchattr $hand p]} {putquick "NOTICE $nick :$cmdchnlg You have +o privelage but you don't have +p, you need +p flag to set your password and authenticate before phrasing commands. Ask my owner/master to set that flag for you =)" ; return 0}
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdchnlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set chan [lindex $rest 0] ; set inick [lindex $rest 1]
	if {$chan == "#" || $chan == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick invite <#channel> <nickname>" ; return 0}
	if {![string match "#*" $chan]} {set chan "#$chan"}
	if {![validchan $chan]} {putquick "NOTICE $nick :$cmdchnlg I am not on channel: $chan, check out my channel list." ; return 0}
	if {$inick == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick invite $chan <nickname>" ; return 0}
	if {[onchan $inick $chan]} {putquick "NOTICE $nick :$cmdchnlg $inick already on channel: $chan. Invites are not needed." ; return 0}
	putquick "INVITE $inick $chan"
	putquick "NOTICE $nick :$cmdchnlg $inick are now invited to join channel: $chan."
	putcmdlog "$cmdchnlg <<$nick>> !$hand! Inviting: $inick to channel: $chan." ; return 0
}

proc pub_inpait {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	set chans "" ; set channel [lindex $rest 0]
	if {![string match "#*" $channel]} {set channel $chan ; append chans "$channel $rest "} else {append chans " $rest"}
	set inicks [lindex $chans 1]
	if {$inicks == ""} {putquick "NOTICE $nick :$cmdchnlg Command: ${CHPRM}invite $channel <nickname>" ; return 0}
	msg_inpait $nick $uhost $hand $chans
}

proc msg_chanhelp {nick uhost hand rest} {
	global CHPRM botnick cmdchnlg
	if {![matchattr $hand p]} {putquick "NOTICE $nick :$cmdchnlg You have +o privelage but you don't have +p, you need +p flag to set your password and authenticate before phrasing commands. Ask my owner/master to set that flag for you =)" ; return 0}
	set chlptype [string toupper [lindex $rest 0]]
	if {$chlptype == ""} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick chanhelp PUB or /msg $botnick chanhelp MSG" ; return 0}
	if {[string toupper $chlptype] != "PUB" && [string toupper $chlptype] != "MSG"} {putquick "NOTICE $nick :$cmdchnlg Command: /msg $botnick chanhelp PUB or /msg $botnick chanhelp MSG" ; return 0}
	putquick "NOTICE $nick :$cmdchnlg Channel Control Commands $cmdchnlg"
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :NOTES:"
	putquick "NOTICE $nick :<> sign means you MUST fill the value."
	putquick "NOTICE $nick :\[\] sign means you can either fill the value or leave it blank."
	putquick "NOTICE $nick :| sign means you MUST choose one between value placed on the left side of | sign, or on the right side."
	putquick "NOTICE $nick : "
	if {$chlptype == "PUB"} {
		putquick "NOTICE $nick :Public Commands:"
		putquick "NOTICE $nick : "
		if {[matchattr $hand n]} {
			putquick "NOTICE $nick :${CHPRM}join <#channel> \[join-key\]"
			putquick "NOTICE $nick :${CHPRM}leave <#channel>"
			putquick "NOTICE $nick :${CHPRM}cycle \[#channel\]"
		}
		putquick "NOTICE $nick :${CHPRM}lock \[#channel\]"
		putquick "NOTICE $nick :${CHPRM}unlock \[#channel\]"
		putquick "NOTICE $nick :${CHPRM}cmode \[#channel\] <+/-modelocks>"
		putquick "NOTICE $nick :${CHPRM}up \[#channel\]"
		putquick "NOTICE $nick :${CHPRM}down \[#channel\]"
		putquick "NOTICE $nick :${CHPRM}op \[#channel\] <nickname(s)>"
		putquick "NOTICE $nick :${CHPRM}deop \[#channel\] <nickname(s)>"
		if {[matchattr $hand m]} {
			putquick "NOTICE $nick :${CHPRM}mop \[#channel\]"
			putquick "NOTICE $nick :${CHPRM}mdeop \[#channel\]"
		}
		putquick "NOTICE $nick :${CHPRM}voice \[#channel\] <nickname(s)>"
		putquick "NOTICE $nick :${CHPRM}devoice \[#channel\] <nickname(s)>"
		if {[matchattr $hand m]} {
			putquick "NOTICE $nick :${CHPRM}mvoice \[#channel\]"
			putquick "NOTICE $nick :${CHPRM}mdevo \[#channel\]"
		}
		putquick "NOTICE $nick :${CHPRM}kick \[#channel\] <nickname(s)> \[!reason\]"
		if {[matchattr $hand m]} {
			putquick "NOTICE $nick :${CHPRM}mkick \[#channel\] \[!reason\]"
		}
		putquick "NOTICE $nick :${CHPRM}+ban \[#channel\] <nickname/hostname> \[ban-time (minute(s))\] \[reason\]"
		putquick "NOTICE $nick :${CHPRM}-ban \[#channel\] <nickname/hostname>"
		if {[matchattr $hand m]} {
			putquick "NOTICE $nick :${CHPRM}+gban <nickname/hostname> \[ban-time (minute(s))\] \[reason\]"
			putquick "NOTICE $nick :${CHPRM}-gban <nickname/hostname>"
		}
		putquick "NOTICE $nick :${CHPRM}baninfo <#channel|GLOBAL>"
		putquick "NOTICE $nick :${CHPRM}rlbans \[#channel\]"
		putquick "NOTICE $nick :${CHPRM}invite \[#channel\] <nickname>"
		putquick "NOTICE $nick : "
	}
	if {$chlptype == "MSG"} {
		putquick "NOTICE $nick :MSG Commands:"
		putquick "NOTICE $nick : "
		if {[matchattr $hand n]} {
			putquick "NOTICE $nick :/msg $botnick join <#channel> \[join-key\]"
			putquick "NOTICE $nick :/msg $botnick leave <#channel>"
			putquick "NOTICE $nick :/msg $botnick cycle \[#channel\]"
		}
		putquick "NOTICE $nick :/msg $botnick lock <#channel>"
		putquick "NOTICE $nick :/msg $botnick unlock <#channel>"
		putquick "NOTICE $nick :/msg $botnick cmode <#channel> <+/-modelocks>"
		putquick "NOTICE $nick :/msg $botnick up <#channel>"
		putquick "NOTICE $nick :/msg $botnick down <#channel>"
		putquick "NOTICE $nick :/msg $botnick op <#channel> <nickname(s)>"
		putquick "NOTICE $nick :/msg $botnick deop <#channel> <nickname(s)>"
		if {[matchattr $hand m]} {
			putquick "NOTICE $nick :/msg $botnick mop <#channel>"
			putquick "NOTICE $nick :/msg $botnick mdeop <#channel>"
		}
		putquick "NOTICE $nick :/msg $botnick voice <#channel> <nickname(s)>"
		putquick "NOTICE $nick :/msg $botnick devoice <#channel> <nickname(s)>"
		if {[matchattr $hand m]} {
			putquick "NOTICE $nick :/msg $botnick mvoice <#channel>"
			putquick "NOTICE $nick :/msg $botnick mdevo <#channel>"
		}
		putquick "NOTICE $nick :/msg $botnick kick <#channel> <nickname(s)> \[!reason\]"
		if {[matchattr $hand m]} {
			putquick "NOTICE $nick :/msg $botnick mkick <#channel> \[!reason\]"
		}
		putquick "NOTICE $nick :/msg $botnick +ban <#channel> <nickname/hostname> \[ban-time (minute(s))\] \[reason\]"
		putquick "NOTICE $nick :/msg $botnick -ban <#channel> <nickname/hostname>"
		if {[matchattr $hand m]} {
			putquick "NOTICE $nick :/msg $botnick +gban <nickname/hostname> \[ban-time (minute(s))\] \[reason\]"
			putquick "NOTICE $nick :/msg $botnick -gban <nickname/hostname>"
		}
		putquick "NOTICE $nick :/msg $botnick baninfo <#channel|GLOBAL>"
		putquick "NOTICE $nick :/msg $botnick rlbans <#channel>"
		putquick "NOTICE $nick :/msg $botnick invite <#channel> <nickname>"
		putquick "NOTICE $nick : "
	}
	putquick "NOTICE $nick :Other Commands:"
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :${CHPRM}chanhelp PUB or ${CHPRM}chanhelp MSG"
	putquick "NOTICE $nick :/msg $botnick chanhelp PUB or /msg $botnick chanhelp MSG"
	putquick "NOTICE $nick : "
	putcmdlog "$cmdchnlg <<$nick>> !$hand! Channel Control Commands Help." ; return 0
}

proc pub_chanhelp {nick uhost hand chan rest} {
	global CHPRM botnick cmdchnlg
	if {![matchattr $hand p]} {putquick "NOTICE $nick :$cmdchnlg You have +o privelage but you don't have +p, you need +p flag to set your password and authenticate before phrasing commands. Ask my owner/master to set that flag for you =)" ; return 0}
	set chlptype [string toupper [lindex $rest 0]]
	if {$chlptype == ""} {putquick "NOTICE $nick :$cmdchnlg Command: ${CHPRM}chanhelp PUB or ${CHPRM}chanhelp MSG" ; return 0}
	if {[string toupper $chlptype] != "PUB" && [string toupper $chlptype] != "MSG"} {putquick "NOTICE $nick :$cmdchnlg Command: ${CHPRM}chanhelp PUB or ${CHPRM}chanhelp MSG" ; return 0}
	msg_chanhelp $nick $uhost $hand $chlptype
}

# Set this to "1" if you like the script to be loaded.. and set it to "0" to unload.
set cmdchanloaded 1

if {[info exist cmdchanloaded]} {
	if {${cmdchanloaded}} {
		bind pub n ${CHPRM}join pub_masuk
		bind msg n leave msg_cabut
		bind pub n ${CHPRM}leave pub_cabut
		bind msg n join msg_masuk
		bind pub n ${CHPRM}cycle pub_cycle
		bind msg n cycle msg_cycle
		bind pub o|o ${CHPRM}lock pub_konci
		bind msg o|o lock msg_konci
		bind pub o|o ${CHPRM}unlock pub_buka
		bind msg o|o unlock msg_buka
		bind pub o|o ${CHPRM}cmode pub_cmode
		bind msg o|o cmode msg_cmode
		bind pub o|o ${CHPRM}up pub_opbot
		bind msg o|o up msg_opbot
		bind pub o|o ${CHPRM}down pub_deopbot
		bind msg o|o down msg_deopbot
		bind pub o|o ${CHPRM}op pub_naekin
		bind msg o|o op msg_naekin
		bind pub o|o ${CHPRM}deop pub_turunin
		bind msg o|o deop msg_turunin
		bind pub m ${CHPRM}mop pub_massop
		bind msg m mop msg_massop
		bind pub m ${CHPRM}mdeop pub_massdeop
		bind msg m mdeop msg_massdeop
		bind pub o|o ${CHPRM}voice pub_pois
		bind msg o|o voice msg_pois
		bind pub o|o ${CHPRM}devoice pub_depois
		bind msg o|o devoice msg_depois
		bind pub m ${CHPRM}mvoice pub_massvo
		bind msg m mvoice msg_massvo
		bind pub m ${CHPRM}mdevo pub_massdevo
		bind msg m mdevo msg_massdevo
		bind pub o|o ${CHPRM}kick pub_tendang
		bind msg o|o kick msg_tendang
		bind pub m ${CHPRM}mkick pub_mtendang
		bind msg m mkick msg_mtendang
		bind pub o|o ${CHPRM}+ban pub_+ban
		bind msg o|o +ban msg_+ban
		bind pub o|o ${CHPRM}-ban pub_-ban
		bind msg o|o -ban msg_-ban
		bind pub m ${CHPRM}+gban pub_+gban
		bind msg m +gban msg_+gban
		bind pub m ${CHPRM}-gban pub_-gban
		bind msg m -gban msg_-gban
		bind pub o|o ${CHPRM}baninfo pub_infoban
		bind msg o|o baninfo msg_infoban
		bind pub o|o ${CHPRM}rlbans pub_lepasban
		bind msg o|o rlbans msg_lepasban
		bind pub o|o ${CHPRM}invite pub_inpait
		bind msg o|o invite msg_inpait
		bind pub o|o ${CHPRM}chanhelp pub_chanhelp
		bind msg o|o chanhelp msg_chanhelp
	} else {
		unbind pub n ${CHPRM}join pub_masuk
		unbind msg n leave msg_cabut
		unbind pub n ${CHPRM}leave pub_cabut
		unbind msg n join msg_masuk
		unbind pub n ${CHPRM}cycle pub_cycle
		unbind msg n cycle msg_cycle
		unbind pub o|o ${CHPRM}lock pub_konci
		unbind msg o|o lock msg_konci
		unbind pub o|o ${CHPRM}unlock pub_buka
		unbind msg o|o unlock msg_buka
		unbind pub o|o ${CHPRM}cmode pub_cmode
		unbind msg o|o cmode msg_cmode
		unbind pub o|o ${CHPRM}up pub_opbot
		unbind msg o|o up msg_opbot
		unbind pub o|o ${CHPRM}down pub_deopbot
		unbind msg o|o down msg_deopbot
		unbind pub o|o ${CHPRM}op pub_naekin
		unbind msg o|o op msg_naekin
		unbind pub o|o ${CHPRM}deop pub_turunin
		unbind msg o|o deop msg_turunin
		unbind pub m ${CHPRM}mop pub_massop
		unbind msg m mop msg_massop
		unbind pub m ${CHPRM}mdeop pub_massdeop
		unbind msg m mdeop msg_massdeop
		unbind pub o|o ${CHPRM}voice pub_pois
		unbind msg o|o voice msg_pois
		unbind pub o|o ${CHPRM}devoice pub_depois
		unbind msg o|o devoice msg_depois
		unbind pub m ${CHPRM}mvoice pub_massvo
		unbind msg m mvoice msg_massvo
		unbind pub m ${CHPRM}mdevo pub_massdevo
		unbind msg m mdevo msg_massdevo
		unbind pub o|o ${CHPRM}kick pub_tendang
		unbind msg o|o kick msg_tendang
		unbind pub m ${CHPRM}mkick pub_mtendang
		unbind msg m mkick msg_mtendang
		unbind pub o|o ${CHPRM}+ban pub_+ban
		unbind msg o|o +ban msg_+ban
		unbind pub o|o ${CHPRM}-ban pub_-ban
		unbind msg o|o -ban msg_-ban
		unbind pub m ${CHPRM}+gban pub_+gban
		unbind msg m +gban msg_+gban
		unbind pub m ${CHPRM}-gban pub_-gban
		unbind msg m -gban msg_-gban
		unbind pub o|o ${CHPRM}baninfo pub_infoban
		unbind msg o|o baninfo msg_infoban
		unbind pub o|o ${CHPRM}rlbans pub_lepasban
		unbind msg o|o rlbans msg_lepasban
		unbind pub o|o ${CHPRM}invite pub_inpait
		unbind msg o|o invite msg_inpait
		unbind pub o|o ${CHPRM}chanhelp pub_chanhelp
		unbind msg o|o chanhelp msg_chanhelp
	}
	
}

# End of - Commands & Control, Channel Control. (cmd_chan.tcl)

# Begin - Commands & Control, Channel Access List control (Sirv). (cmd_clistmod.tcl)
#	Designed & Written by Ninja_baby (Jaysee@Jaysee.Tv), © January 2001

# This TCL was made following request from my friend Ziad (ZiZO on DALnet) for his channel #Leb. This script will-
# help you to control channel access list from your bot (if you're not currently identify to the NickServ).
# Note that your bot must has SOp access minimaly to use this script, more kewl if it has founder access-
# hehe ;). I design this script for use only with IRC Network that have SirvService installed. Which-
# has ChanServ, NickServ, MemoServ services available. ;) so don't use this on UnderNET ;p
# NOTE: I've test this script in DALnet, works fine, I don't know about other Network with SirvService.
#       So please support ;) I'll make modifications as soon I receives any critics and opinions. ;)

# Set this as the IRC network ChanServ's nickname (I set this default to DALnet's ChanServ nickname).
# if you're in other network, simply you can set this as "ChanServ" or others, according to the network ;)
set chanservnick "ChanServ"

# Set this as the IRC network MemoServ's nickname (I set this default to DALnet's MemoServ nickname).
# if you're in other network, simply you can set this as "MemoServ" or others, according to the network ;)
set memoservnick "MemoServ"

# Set this to "1" if you like to bot to /memoserv send the channel founder after it does modification-
# to the channel access list. and leave this to "0" if you don't like the bot to memo the founder about-
# channel access list modification made by it ;)
set addelmemofnd 1

# Set this as ChanServ's IP address/hostname. The bot will check ChanServ's IP after it receives-
# notices from ChanServ. So set this according to the IRC network you and your bot are on.
set chanservips "ChanServ@services.allnetwork.org"

# Set this as your Public (channel) command character. For example: you set this to ".".. means you must-
# type !mycommand in channel to activate public commands.
set CADELPRM "."

# This is for your benefit hehe ;), you can either set your own LOGO here, your logo will appear-
# when the bot notice you, or when it makes msgs/notices/kicks or scripts loading. So keep smiling-
# and set this variable as you wish ;), you can either set this to "" to leave it blank.
set cmdclistlg "\[S-B\]:"

######### Please do not edit anything below unless you know what you are doing ;) #########

proc msg_+sop {nick uhost hand rest} {
	global botnick botname chanservnick memoservnick chanservips cmsgannounce cmdclistlg
	set cmsgannounce $nick ; if {![matchattr $hand Q]} {putquick "NOTICE $cmsgannounce :$cmdclistlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	if {[string match "@" $chanservnick]} {set lchanservnick [lindex [split $chanservnick @] 0]} else {set lchanservnick $chanservnick}
	set cmsgtarg [lindex $rest 0] ; set tnickhost [lindex $rest 1]
	if {$cmsgtarg == "#" || $cmsgtarg == ""} {putquick "NOTICE $cmsgannounce :$cmdclistlg Command: /msg $botnick +sop <#channel> <nickname/hostname>" ; return 0}
	if {$tnickhost == ""} {putquick "NOTICE $cmsgannounce :$cmdclistlg Command: /msg $botnick +sop <#channel> <nickname/hostname>" ; return 0}
	if {![string match "#*" $cmsgtarg]} {set cmsgtarg "#$cmsgtarg"}
	if {[string match *$botnick* $tnickhost]} {putquick "NOTICE $cmsgannounce :$cmdclistlg I cannot add $tnickhost to SOp list, since it similiar with my nickname." ; return 0}
	putquick "PRIVMSG $chanservnick :SOp $cmsgtarg ADD $tnickhost"
	putquick "NOTICE $cmsgannounce :$cmdclistlg doing /$lchanservnick SOp $cmsgtarg ADD $tnickhost"
	putcmdlog "$cmdclistlg <<$cmsgannounce>> !$hand! /$lchanservnick SOp $cmsgtarg ADD $tnickhost." ; return 0
}

proc pub_+sop {nick uhost hand chan rest} {
	global CADELPRM botnick cmdclistlg
	if {$rest == ""} {putquick "NOTICE $nick :$cmdclistlg Command: ${CADELPRM}+sop <nickname/hostname>" ; return 0}
	append crests "$chan $rest" ; msg_+sop $nick $uhost $hand $crests
}

proc msg_-sop {nick uhost hand rest} {
	global botnick botname chanservnick memoservnick chanservips cmsgannounce cmdclistlg
	set cmsgannounce $nick ; if {![matchattr $hand Q]} {putquick "NOTICE $cmsgannounce :$cmdclistlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	if {[string match "@" $chanservnick]} {set lchanservnick [lindex [split $chanservnick @] 0]} else {set lchanservnick $chanservnick}
	set cmsgtarg [lindex $rest 0] ; set tnickhost [lindex $rest 1]
	if {$cmsgtarg == "#" || $cmsgtarg == ""} {putquick "NOTICE $cmsgannounce :$cmdclistlg Command: /msg $botnick -sop <#channel> <nickname/hostname>" ; return 0}
	if {$tnickhost == ""} {putquick "NOTICE $cmsgannounce :$cmdclistlg Command: /msg $botnick -sop <#channel> <nickname/hostname>" ; return 0}
	if {![string match "#*" $cmsgtarg]} {set cmsgtarg "#$cmsgtarg"}
	set bothost [lindex [split ${botname} @] 1]
	if {[string match *$tnickhost* $bothost]} {putquick "NOTICE $cmsgannounce :$cmdclistlg I cannot delete $tnickhost from SOp list since it similiar with my hostname/IP." ; return 0}
	if {[string match *$botnick* $tnickhost]} {putquick "NOTICE $cmsgannounce :$cmdclistlg I cannot delete $tnickhost from SOp list, since it similiar with my nickname." ; return 0}
	putquick "PRIVMSG $chanservnick :SOp $cmsgtarg DEL $tnickhost"
	putquick "NOTICE $cmsgannounce :$cmdclistlg doing /$lchanservnick SOp $cmsgtarg DEL $tnickhost"
	putcmdlog "$cmdclistlg <<$cmsgannounce>> !$hand! /$lchanservnick SOp $cmsgtarg DEL $tnickhost." ; return 0
}

proc pub_-sop {nick uhost hand chan rest} {
	global CADELPRM botnick cmdclistlg
	if {$rest == ""} {putquick "NOTICE $nick :$cmdclistlg Command: ${CADELPRM}-sop <nickname/hostname>" ; return 0}
	append crests "$chan $rest" ; msg_-sop $nick $uhost $hand $crests
}

proc msg_+aop {nick uhost hand rest} {
	global botnick botname chanservnick memoservnick chanservips cmsgannounce cmdclistlg
	set cmsgannounce $nick ; if {![matchattr $hand Q]} {putquick "NOTICE $cmsgannounce :$cmdclistlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	if {[string match "@" $chanservnick]} {set lchanservnick [lindex [split $chanservnick @] 0]} else {set lchanservnick $chanservnick}
	set cmsgtarg [lindex $rest 0] ; set tnickhost [lindex $rest 1]
	if {$cmsgtarg == "#" || $cmsgtarg == ""} {putquick "NOTICE $cmsgannounce :$cmdclistlg Command: /msg $botnick +aop <#channel> <nickname/hostname>" ; return 0}
	if {$tnickhost == ""} {putquick "NOTICE $cmsgannounce :$cmdclistlg Command: /msg $botnick +aop <#channel> <nickname/hostname>" ; return 0}
	if {![string match "#*" $cmsgtarg]} {set cmsgtarg "#$cmsgtarg"}
	putquick "PRIVMSG $chanservnick :AOp $cmsgtarg ADD $tnickhost"
	putquick "NOTICE $cmsgannounce :$cmdclistlg doing /$lchanservnick AOp $cmsgtarg ADD $tnickhost"
	putcmdlog "$cmdclistlg <<$cmsgannounce>> !$hand! /$lchanservnick AOp $cmsgtarg ADD $tnickhost." ; return 0
}

proc pub_+aop {nick uhost hand chan rest} {
	global CADELPRM botnick cmdclistlg
	if {$rest == ""} {putquick "NOTICE $nick :$cmdclistlg Command: ${CADELPRM}+aop <nickname/hostname>" ; return 0}
	append crests "$chan $rest" ; msg_+aop $nick $uhost $hand $crests
}

proc msg_-aop {nick uhost hand rest} {
	global botnick botname chanservnick memoservnick chanservips cmsgannounce cmdclistlg
	set cmsgannounce $nick ; if {![matchattr $hand Q]} {putquick "NOTICE $cmsgannounce :$cmdclistlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	if {[string match "@" $chanservnick]} {set lchanservnick [lindex [split $chanservnick @] 0]} else {set lchanservnick $chanservnick}
	set cmsgtarg [lindex $rest 0] ; set tnickhost [lindex $rest 1]
	if {$cmsgtarg == "#" || $cmsgtarg == ""} {putquick "NOTICE $cmsgannounce :$cmdclistlg Command: /msg $botnick -aop <#channel> <nickname/hostname>" ; return 0}
	if {$tnickhost == ""} {putquick "NOTICE $cmsgannounce :$cmdclistlg Command: /msg $botnick -aop <#channel> <nickname/hostname>" ; return 0}
	if {![string match "#*" $cmsgtarg]} {set cmsgtarg "#$cmsgtarg"}
	set bothost [lindex [split ${botname} @] 1]
	if {[string match *$tnickhost* $bothost]} {putquick "NOTICE $cmsgannounce :$cmdclistlg I cannot delete $tnickhost from AOp list since it similiar with my hostname/IP." ; return 0}
	if {[string match *$botnick* $tnickhost]} {putquick "NOTICE $cmsgannounce :$cmdclistlg I cannot delete $tnickhost from AOp list, since it similiar with my nickname." ; return 0}
	putquick "PRIVMSG $chanservnick :AOp $cmsgtarg DEL $tnickhost"
	putquick "NOTICE $cmsgannounce :$cmdclistlg doing /$lchanservnick AOp $cmsgtarg DEL $tnickhost"
	putcmdlog "$cmdclistlg <<$cmsgannounce>> !$hand! /$lchanservnick AOp $cmsgtarg DEL $tnickhost." ; return 0
}

proc pub_-aop {nick uhost hand chan rest} {
	global CADELPRM botnick cmdclistlg
	if {$rest == ""} {putquick "NOTICE $nick :$cmdclistlg Command: ${CADELPRM}-aop <nickname/hostname>" ; return 0}
	append crests "$chan $rest" ; msg_-aop $nick $uhost $hand $crests
}

proc msg_+akick {nick uhost hand rest} {
	global botnick botname chanservnick memoservnick chanservips cmsgannounce cmdclistlg
	set cmsgannounce $nick ; if {![matchattr $hand Q]} {putquick "NOTICE $cmsgannounce :$cmdclistlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	if {[string match "@" $chanservnick]} {set lchanservnick [lindex [split $chanservnick @] 0]} else {set lchanservnick $chanservnick}
	set cmsgtarg [lindex $rest 0] ; set tnickhost [lindex $rest 1]
	if {$cmsgtarg == "#" || $cmsgtarg == ""} {putquick "NOTICE $cmsgannounce :$cmdclistlg Command: /msg $botnick +akick <#channel> <nickname/hostname>" ; return 0}
	if {$tnickhost == ""} {putquick "NOTICE $cmsgannounce :$cmdclistlg Command: /msg $botnick +akick <#channel> <nickname/hostname>" ; return 0}
	if {![string match "#*" $cmsgtarg]} {set cmsgtarg "#$cmsgtarg"}
	set bothost [lindex [split ${botname} @] 1]
	if {[string match *$tnickhost* $bothost]} {putquick "NOTICE $cmsgannounce :$cmdclistlg I cannot add $tnickhost to AKick list since it similiar with my hostname/IP." ; return 0}
	if {[string match *$botnick* $tnickhost]} {putquick "NOTICE $cmsgannounce :$cmdclistlg I cannot add $tnickhost to AKick list, since it similiar with my nickname." ; return 0}
	putquick "PRIVMSG $chanservnick :AKick $cmsgtarg ADD $tnickhost"
	putquick "NOTICE $cmsgannounce :$cmdclistlg doing /$lchanservnick AKick $cmsgtarg ADD $tnickhost"
	putcmdlog "$cmdclistlg <<$cmsgannounce>> !$hand! /$lchanservnick AKick $cmsgtarg ADD $tnickhost." ; return 0
}

proc pub_+akick {nick uhost hand chan rest} {
	global CADELPRM botnick cmdclistlg
	if {$rest == ""} {putquick "NOTICE $nick :$cmdclistlg Command: ${CADELPRM}+akick <nickname/hostname>" ; return 0}
	append crests "$chan $rest" ; msg_+akick $nick $uhost $hand $crests
}

proc msg_-akick {nick uhost hand rest} {
	global botnick botname chanservnick memoservnick chanservips cmsgannounce cmdclistlg
	set cmsgannounce $nick ; if {![matchattr $hand Q]} {putquick "NOTICE $cmsgannounce :$cmdclistlg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	if {[string match "@" $chanservnick]} {set lchanservnick [lindex [split $chanservnick @] 0]} else {set lchanservnick $chanservnick}
	set cmsgtarg [lindex $rest 0] ; set tnickhost [lindex $rest 1]
	if {$cmsgtarg == "#" || $cmsgtarg == ""} {putquick "NOTICE $cmsgannounce :$cmdclistlg Command: /msg $botnick -akick <#channel> <nickname/hostname>" ; return 0}
	if {$tnickhost == ""} {putquick "NOTICE $cmsgannounce :$cmdclistlg Command: /msg $botnick -akick <#channel> <nickname/hostname>" ; return 0}
	if {![string match "#*" $cmsgtarg]} {set cmsgtarg "#$cmsgtarg"}
	putquick "PRIVMSG $chanservnick :AKick $cmsgtarg DEL $tnickhost"
	putquick "NOTICE $cmsgannounce :$cmdclistlg doing /$lchanservnick AKick $cmsgtarg DEL $tnickhost"
	putcmdlog "$cmdclistlg <<$cmsgannounce>> !$hand! /$lchanservnick AKick $cmsgtarg DEL $tnickhost." ; return 0
}

proc pub_-akick {nick uhost hand chan rest} {
	global CADELPRM botnick cmdclistlg
	if {$rest == ""} {putquick "NOTICE $nick :$cmdclistlg Command: ${CADELPRM}-akick <nickname/hostname>" ; return 0}
	append crests "$chan $rest" ; msg_-akick $nick $uhost $hand $crests
}

proc msg_+click {nick uhost hand rest} {
	global botnick cmdclistlg
	set cmsgtarg [lindex $rest 0] ; set tnickhost [lindex $rest 1]
	if {$cmsgtarg == "#" || $cmsgtarg == ""} {putquick "NOTICE $cmsgannounce :$cmdclistlg Command: /msg $botnick +click <#channel> <nickname>" ; return 0}
	if {$tnickhost == ""} {putquick "NOTICE $cmsgannounce :$cmdclistlg Command: /msg $botnick +click <#channel> <nickname>" ; return 0}
	if {[string match "*.*" $tnickhost]} {putquick "NOTICE $cmsgannounce :$cmdclistlg Command: /msg $botnick +click <#channel> <nickname>" ; return 0}
	append crests "$cmsgtarg $tnickhost" ; msg_+aop $nick $uhost $hand $crests ; msg_naekin $nick $uhost $hand $crests ; msg_-aop $nick $uhost $hand $crests
}

proc pub_+click {nick uhost hand chan rest} {
	global CADELPRM botnick cmdclistlg
	if {$rest == ""} {putquick "NOTICE $nick :$cmdclistlg Command: ${CADELPRM}-click <nickname/hostname>" ; return 0}
	append crests "$chan $rest" ; msg_+aop $nick $uhost $hand $crests ; msg_naekin $nick $uhost $hand $crests ; msg_-aop $nick $uhost $hand $crests
}

proc msg_cadelhelp {nick uhost hand rest} {
	global CADELPRM botnick cmdclistlg
	putquick "NOTICE $nick :$cmdclistlg Channel Access List Control Commands $cmdclistlg"
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :NOTES:"
	putquick "NOTICE $nick :<> sign means you MUST fill the value."
	putquick "NOTICE $nick :\[\] sign means you can either fill the value or leave it blank."
	putquick "NOTICE $nick :| sign means you MUST choose one between value placed on the left side of | sign, or on the right side."
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :Public Commands:"
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :${CADELPRM}+sop <nickname/hostname>"
	putquick "NOTICE $nick :${CADELPRM}-sop <nickname/hostname>"
	putquick "NOTICE $nick :${CADELPRM}+aop <nickname/hostname>"
	putquick "NOTICE $nick :${CADELPRM}-aop <nickname/hostname>"
	putquick "NOTICE $nick :${CADELPRM}+akick <nickname/hostname>"
	putquick "NOTICE $nick :${CADELPRM}-akick <nickname/hostname>"
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :MSG Commands:"
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :/msg $botnick +sop <#channel> <nickname/hostname>"
	putquick "NOTICE $nick :/msg $botnick -sop <#channel> <nickname/hostname>"
	putquick "NOTICE $nick :/msg $botnick +aop <#channel> <nickname/hostname>"
	putquick "NOTICE $nick :/msg $botnick -aop <#channel> <nickname/hostname>"
	putquick "NOTICE $nick :/msg $botnick +akick <#channel> <nickname/hostname>"
	putquick "NOTICE $nick :/msg $botnick -akick <#channel> <nickname/hostname>"
	putquick "NOTICE $nick : "
	putcmdlog "$cmdclistlg <<$nick>> !$hand! Channel Control Commands Help." ; return 0
}

proc pub_cadelhelp {nick uhost hand chan rest} {global CADELPRM botnick cmdclistlg ; msg_cadelhelp $nick $uhost $hand $rest}

proc cservcmdnot {from keyword arg} {
	global botnick addelmemofnd chanservnick memoservnick chanservips cmsgannounce adcurrnickhost acurrproc acurraccess acurrchan cmdclistlg
	if {![info exist cmsgannounce]} {return 0}
	set nick [lindex [split $from !] 0] ; set uhost [lindex [split $from !] 1]
	if {[string match "*.*" $nick]} {return 0}
	if {[string match "@" $chanservnick]} {set lchanservnick [lindex [split $chanservnick @] 0]} else {set lchanservnick $chanservnick}
	if {![string match *[string tolower $chanservips]* [string tolower $uhost]]} {return 0}
	if {[string match "* are * not have access *" $arg]} {
		set acurraccess [lindex $arg 13] ; set acurrchan [lindex $arg 16]
		putquick "NOTICE $cmsgannounce :$cmdclistlg I don't have to modify $acurraccess of channel: $acurrchan. Reason: I'm only [lindex $arg 4] there."
	} else {
		if {[string match "* not have access *" $arg]} {
			set acurraccess [lindex $arg 9] ; set acurrchan [lindex $arg 12]
			putquick "NOTICE $cmsgannounce :$cmdclistlg I don't have to modify $acurraccess of channel: $acurrchan."
		} else {
			if {[string match "* must be * to perform *" $arg]} {
				set acurrchan [lindex $arg 7]
				putquick "NOTICE $cmsgannounce :$cmdclistlg I don't have any access in channel: $acurrchan."
			} else {
				if {[string match "* already exists on the *" $arg]} {
					set adcurrnickhost [string trim [lindex $arg 1] ":"] ; set acurraccess [string trim [lindex $arg 6] ""] ; set acurrchan [string trim [lindex $arg 9] ""]
					putquick "NOTICE $cmsgannounce :$cmdclistlg $adcurrnickhost already exist on the $acurraccess of channel: $acurrchan."
				} else {
					if {[string match "* does not wish *" $arg]} {
						set adcurrnickhost [string trim [lindex $arg 1] ":"]
						putquick "NOTICE $cmsgannounce :$cmdclistlg $adcurrnickhost does not wish to be added to channel operator list."
					} else {
						if {[string match "* registered nicks * added *" $arg]} {
							putquick "NOTICE $cmsgannounce :$cmdclistlg I cannot add un-registered nickname(s)."
						} else {
							if {[string match "* was not found on *" $arg]} {
								set adcurrnickhost [string trim [lindex $arg 1] ":"] ; set acurraccess [string trim [lindex $arg 7] ""] ; set acurrchan [string trim [lindex $arg 10] ""]
								putquick "NOTICE $cmsgannounce :$cmdclistlg $adcurrnickhost does not exist on the $acurraccess of channel: $acurrchan."
							} else {
								if {[string match "* channel * is not *" $arg]} {
									set acurrchan [string trim [lindex $arg 3] ""]
									putquick "NOTICE $cmsgannounce :$cmdclistlg The channel: $acurrchan is not registered."
								} else {
									if {[string match "* been successfully *" $arg]} {
										set adcurrnickhost [string trim [lindex $arg 1] ":"] ; set acurrproc [lindex $arg 5] ; set acurraccess [string trim [lindex $arg 8] ""]
										set acurrchan [string trim [lindex $arg 11] ""]
										putquick "NOTICE $cmsgannounce :$cmdclistlg $adcurrnickhost is now $acurrproc to/from $acurraccess of channel: $acurrchan."
										if {$addelmemofnd} {putquick "PRIVMSG $chanservnick :info $chan" ; putlog "$cmdclistlg doing /$nick info for $chan"}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	if {[info exist adcurrnickhost] || [info exist acurrproc] || [info exist acurraccess] || [info exist acurrchan]} {
		if {$addelmemofnd} {
			if {[string match "*FOUNDER*" [string toupper $arg]] && ![string match "*emo *eve*" [string toupper $arg]]} {
				set achanfnd [lindex $arg 3]
				if {[string match "@" $memoservnick]} {set lmemoservnick [lindex [split $memoservnick @] 0]} else {set lmemoservnick $memoservnick}
				putquick "PRIVMSG $memoservnick :send $achanfnd $cmdclistlg $adcurrnickhost is now $acurrproc to/from $acurraccess of channel: $acurrchan."
				putlog "$cmdclistlg doing /$lmemoservnick send $achanfnd $cmdclistlg $adcurrnickhost is now $acurrproc to/from $acurraccess of channel: $acurrchan."
			}
		}
		if {[info exist adcurrnickhost]} {unset adcurrnickhost} ; if {[info exist acurrproc]} {unset acurrproc}
		if {[info exist acurraccess]} {unset acurraccess} ; if {[info exist acurrchan]} {unset acurrchan}
	} ; return 0
}

# Set this to "1" if you like the script to be loaded.. and set it to "0" to unload.
set cadelloaded 1

if {[info exist cadelloaded]} {
	if {${cadelloaded}} {
		bind pub m ${CHPRM}+sop pub_+sop
		bind msg m +sop msg_+sop
		bind pub m ${CHPRM}-sop pub_-sop
		bind msg m -sop msg_-sop
		bind pub m ${CHPRM}+aop pub_+aop
		bind msg m +aop msg_+aop
		bind pub m ${CHPRM}-aop pub_-aop
		bind msg m -aop msg_-aop
		bind pub m ${CHPRM}+akick pub_+akick
		bind msg m +akick msg_+akick
		bind pub m ${CHPRM}-akick pub_-akick
		bind msg m -akick msg_-akick
		bind pub m ${CHPRM}+click pub_+click
		bind msg m +click msg_+click
		bind pub m ${CHPRM}servcmdhelp pub_cadelhelp
		bind msg m servcmdhelp msg_cadelhelp
		bind raw - NOTICE cservcmdnot
	} else {
		unbind pub m ${CHPRM}+sop pub_+sop
		unbind msg m +sop msg_+sop
		unbind pub m ${CHPRM}-sop pub_-sop
		unbind msg m -sop msg_-sop
		unbind pub m ${CHPRM}+aop pub_+aop
		unbind msg m +aop msg_+aop
		unbind pub m ${CHPRM}-aop pub_-aop
		unbind msg m -aop msg_-aop
		unbind pub m ${CHPRM}+akick pub_+akick
		unbind msg m +akick msg_+akick
		unbind pub m ${CHPRM}-akick pub_-akick
		unbind msg m -akick msg_-akick
		unbind pub m ${CHPRM}+click pub_+click
		unbind msg m +click msg_+click
		unbind pub m ${CHPRM}servcmdhelp pub_cadelhelp
		unbind msg m servcmdhelp msg_cadelhelp
		unbind raw - NOTICE cservcmdnot
	}
	
}

# End of - Commands & Control, Channel Access List control (Sirv). (cmd_clistmod.tcl)

# Begin - Commands & Control, Console System. (cmd_cons.tcl)
#	Designed & Written by TCP-IP (Vicky@Vic.ky), © April 1999
#	Developed by Ninja_baby (Jaysee@Jaysee.Tv), © March 2000

# This script was made by TCP-IP in middle of 1999, I develop this script since he passes this script-
# to me in middle of 2000. I made few changes, add some features, and fixed some bugs that were remain-
# here in this script package.

# This TCL will give a little help about console systems.. like to REHASH, RELOAD, RESTART, etc.
# You can ask for help simpy do /msg <yourbotnick> conshelp or do `conshelp in channel to see what commands-
# did this script has.. I set 2 types of commands.. /msg commands and public (channel) commands.
# NOTE: not much.. even almost has no DCC command stuffs over here.. I will make the DCC commands very soon ;)
#       so please support ;)

# Set this as your Public (channel) command character. For example: you set this to ".".. means you must-
# type !mycommand in channel to activate public commands...
set SVRPRM "."

# Fill this with your personal nickname. The bot will consider these nicknames as its SuperAdmins.
# These following SAdmins can SHUTDOWN or RESTART the bot by doing public commands or by /msg-
# commands.. so set this carefully ;)
# NOTE that you can set this as many as you want ;)
set sadmins {
  "Chimp"
  "C"
}

# This is for your benefit hehe ;), you can either set your own LOGO here, your logo will appear-
# when the bot notice you, or when it makes msgs/notices/kicks or scripts loading. So keep smiling-
# and set this variable as you wish ;), you can either set this to "" to leave it blank.
set cmdconslg "\[S-B\]:"

######### Please do not edit anything below unless you know what you are doing ;) #########

proc msg_databot {nick uhost hand rest} {
	global botnick botname server version uptime server-online cmdconslg
	puthelp "NOTICE $nick :$cmdconslg Nickname: ${botnick}. Hostname: [lindex [split ${botname} !] 1]."
	puthelp "NOTICE $nick :$cmdconslg Current IRC server: ${server}, Active for: [expr [unixtime] - ${server-online}] sec(s)."
	puthelp "NOTICE $nick :$cmdconslg Eggdrop version: ${version}. Uptime: [expr [unixtime] - ${uptime}] sec(s)."
	putcmdlog "$cmdconslg <<$nick>> !$hand! Bot Info."
}

proc pub_databot {nick uhost hand chan rest} {global SVRPRM botnick cmdconslg ; msg_databot $nick $uhost $hand $rest}

proc msg_settcl {nick uhost hand rest} {
	global botnick cmdconslg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdconslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	utimer 1 rehash ; putquick "NOTICE $nick :$cmdconslg Rehashing TCL script(s) and variable(s)."
	putcmdlog "$cmdconslg <<$nick>> !$hand! Rehash." ; return 0
}

proc pub_settcl {nick uhost hand chan rest} {global SVRPRM botnick cmdconslg ; msg_settcl $nick $uhost $hand $rest}

proc msg_ulang {nick uhost hand rest} {
	global botnick sadmins cmdconslg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdconslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	foreach superadmin [string toupper $sadmins] {
		if {[string match *$superadmin* [string toupper $hand]]} {
			putquick "NOTICE $nick :$cmdconslg BOT Restarting." ; putcmdlog "$cmdconslg <<$nick>> !$hand! Restart." ; utimer 2 restart ; return 0
		}
	}
	putquick "NOTICE $nick :$cmdconslg Only Super Admins can perform Restart. I cannot restart myself since you are not my Super Admin." ; return 0
}

proc pub_ulang {nick uhost hand chan rest} {global SVRPRM botnick cmdconslg ; msg_ulang $nick $uhost $hand $rest}

proc msg_serper {nick uhost hand rest} {
	global SVRPRM botnick default-port servers cmdconslg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdconslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set server [lindex $rest 0] ; set port [lindex $rest 1] ; set password [lindex $rest 2]
	if {$server == ""} {
		set server [lindex ${servers} [rand [llength ${servers}]]]
		putquick "NOTICE $nick :$cmdconslg No server specified, I'm going to use my default server setting. My next jump server will be: [lindex [split $server :] 0]"
		putquick "NOTICE $nick :$cmdconslg You can use command: ${SVRPRM}server \[IRC_server\] \[port\] \[password\]"
		putquick "NOTICE $nick :$cmdconslg          or command: /msg $botnick server \[IRC_server\] \[port\] \[password\]"
	} else {
		if {[string match ":" $server]} {set port [lindex [split $server :] 1]}
	}
	if {$port == ""} {
		if {[string match ":" $server]} {
			set port [lindex [split $server :] 1] ; putquick "NOTICE $nick :$cmdconslg No port specified, I'm going to use my default port setting. My port now is: $port"
		} else {
			set port ${default-port} ; putquick "NOTICE $nick :$cmdconslg No port specified, I'm going to use my default port setting. My port now is: $port"
		}
	}
	set server [lindex [split $server :] 0]
	utimer 2 "jump $server $port $password"
	putcmdlog "$cmdconslg <<$nick>> !$hand! Jump $server $port $password" ; return 0
}

proc pub_serper {nick uhost hand chan rest} {global SVRPRM botnick cmdconslg ; msg_serper $nick $uhost $hand $rest}

proc msg_selesai {nick uhost hand rest} {
	global botnick sadmins cmdconslg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdconslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	foreach superadmin [string toupper $sadmins] {
		if {[string match *$superadmin* [string toupper $hand]]} {
			if {$rest == ""} {set rest "Shuts down (MSG) by Super Admin: ($nick)"}
			foreach x [userlist] {chattr $x -Q}
			save ; putquick "NOTICE $nick :$cmdconslg Saving user and channel file."
			putquick "QUIT :$rest" ; putcmdlog "$cmdconslg <<$nick>> !$hand! Shutdown: $rest."
			utimer 2 die ; return 0
		}
	}
	putquick "NOTICE $nick :$cmdconslg Only Super Admins can perform shutdown command. I cannot shutdown myself since you are not my Super Admin." ; return 0
}

proc pub_selesai {nick uhost hand chan rest} {global SVRPRM botnick cmdconslg ; if {$rest == ""} {set rest "Shuts down (Public) by Super Admin: ($nick)"} ; msg_selesai $nick $uhost $hand $rest}

proc msg_conshelp {nick uhost hand rest} {
	global SVRPRM botnick cmdconslg
	putquick "NOTICE $nick :$cmdconslg Console Commands $cmdconslg"
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :NOTES:"
	putquick "NOTICE $nick :<> sign means you MUST fill the value."
	putquick "NOTICE $nick :\[\] sign means you can either fill the value or leave it blank."
	putquick "NOTICE $nick :| sign means you MUST choose one between value placed on the left side of | sign, or on the right side."
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :Public Commands:"
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :${SVRPRM}botinfo"
	if {[matchattr $hand m]} {
		putquick "NOTICE $nick :${SVRPRM}rehash"
	}
	if {[matchattr $hand n]} {
		putquick "NOTICE $nick :${SVRPRM}restart"
		putquick "NOTICE $nick :${SVRPRM}jump \[IRC_server\] \[port_#\] \[server_password\]"
		putquick "NOTICE $nick :${SVRPRM}shutdown \[reason\]"
	}
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :MSG Commands:"
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :/msg $botnick botinfo"
	if {[matchattr $hand m]} {
		putquick "NOTICE $nick :/msg $botnick rehash"
	}
	if {[matchattr $hand n]} {
		putquick "NOTICE $nick :/msg $botnick restart"
		putquick "NOTICE $nick :/msg $botnick jump \[IRC_server\] \[port_#\] \[server_password\]"
		putquick "NOTICE $nick :/msg $botnick shutdown \[reason\]"
	}
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :Other Commands:"
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :${SVRPRM}conshelp"
	putquick "NOTICE $nick :/msg $botnick conshelp"
	putquick "NOTICE $nick : "
	putcmdlog "$cmdconslg <<$nick>> !$hand! Console Commands Help." ; return 0
}

proc pub_conshelp {nick uhost hand chan rest} {global SVRPRM botnick ; msg_conshelp $nick $uhost $hand $rest}

# Set this to "1" if you like the script to be loaded.. and set it to "0" to unload.
set cmdconsloaded 1

if {[info exist cmdconsloaded]} {
	if {${cmdconsloaded}} {
		bind pub f|f ${SVRPRM}botinfo pub_databot
		bind msg f|f botinfo msg_databot
		bind pub m ${SVRPRM}rehash pub_settcl
		bind msg m rehash msg_settcl
		bind pub n ${SVRPRM}restart pub_ulang
		bind msg n restart msg_ulang
		bind pub n ${SVRPRM}jump pub_serper
		bind msg n jump msg_serper
		bind pub n ${SVRPRM}shutdown pub_selesai
		bind msg n shutdown msg_selesai
		bind pub f|f ${SVRPRM}conshelp pub_conshelp
		bind msg f|f conshelp msg_conshelp
	} else {
		unbind pub f|f ${SVRPRM}botinfo pub_databot
		unbind msg f|f botinfo msg_databot
		unbind pub m ${SVRPRM}rehash pub_settcl
		unbind msg m rehash msg_settcl
		unbind pub n ${SVRPRM}restart pub_ulang
		unbind msg n restart msg_ulang
		unbind pub n ${SVRPRM}jump pub_serper
		unbind msg n jump msg_serper
		unbind pub n ${SVRPRM}shutdown pub_selesai
		unbind msg n shutdown msg_selesai
		unbind pub f|f ${SVRPRM}conshelp pub_conshelp
		unbind msg f|f conshelp msg_conshelp
	}
	
}

# End of - Commands & Control, Console System. (cmd_cons.tcl)

# Begin - Commands & Control, Database. (cmd_dtbs.tcl)
#	Designed & Written by TCP-IP (Vicky@Vic.ky), © April 1999
#	Developed by Ninja_baby (Jaysee@Jaysee.Tv), © March 2000

# This script was made by TCP-IP in middle of 1999, I develop this script since he passes this script-
# to me in middle of 2000. I made few changes, add some features, and fixed some bugs that were remain-
# here in this script package.

# This TCL will give a little help for database system (user files / channel files). you can do-
# +user +bot chattr, etc. from public (channel) or by /msg..
# You can ask for help simpy do /msg <yourbotnick> dtbshelp or do `dtbshelp in channel to see what commands-
# did this script has.. I set 2 types of commands.. /msg commands and public (channel) commands.
# NOTE: not much.. even almost has no DCC command stuffs over here.. I will make the DCC commands very soon ;)
#       so please support ;)

# Set this as your Public (channel) command character. For example: you set this to ".".. means you must-
# type !mycommand in channel to activate public commands...
set DBPRM "."

if {[info exist ignore-time]} {
	# Checking whenever the "ignore-time" variable is exist on your bot conf file. (Default)
	set defingtime ${ignore-time}
} else {
	# Set this one as your bot default Ignore Time (in minute(s)). This variable will be read when you-
	# trigger IGNORE command in channel or by /msg. Set this to "0" to ignore FOREVER! hehe ;p
	# NOTE that this script will first seek the default variable on your eggdrop.conf file. If the-
	# default ignore time exist, you do not need to set this variable.
	set defingtime 2
}

# This is for your benefit hehe ;), you can either set your own LOGO here, your logo will appear-
# when the bot notice you, or when it makes msgs/notices/kicks or scripts loading. So keep smiling-
# and set this variable as you wish ;), you can either set this to "" to leave it blank.
set cmdtbslg "\[S-B\]:"

######### Please do not edit anything below unless you know what you are doing ;) #########

proc msg_setdata {nick uhost hand rest} {
	global botnick cmdtbslg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	utimer 1 reload ; putquick "NOTICE $nick :$cmdtbslg Reloading user's and channel's records."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! Reload." ; return 0
}

proc pub_setdata {nick uhost hand chan rest} {global DBPRM botnick cmdtbslg ; msg_setdata $nick $uhost $hand $rest}

proc msg_simpan {nick uhost hand rest} {
	global botnick cmdtbslg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	utimer 1 save ; putquick "NOTICE $nick :$cmdtbslg Saving user and channel file."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! Save." ; return 0
}

proc pub_simpan {nick uhost hand chan rest} {global DBPRM botnick cmdtbslg ; msg_simpan $nick $uhost $hand $rest}

proc msg_backup {nick uhost hand rest} {
	global botnick cmdtbslg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	utimer 1 backup ; putquick "NOTICE $nick :$cmdtbslg Backuping user and channel file."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! Backup." ; return 0
}

proc pub_backup {nick uhost hand chan rest} {global DBPRM botnick cmdtbslg ; msg_backup $nick $uhost $hand $rest}

proc msg_nickgue {nick uhost hand rest} {
	global botnick cmdtbslg
	if {![matchattr $hand Q]} {puthelp "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set old [lindex $rest 0] ; set new [lindex $rest 1]
	if {$old == "" || $new == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: /msg $botnick chandle <current_handle> <new_handle>" ; return 0}
	if {$hand != $old} {puthelp "NOTICE $nick :$cmdtbslg Your current handle: $old is not exist in my user list." ; return 0}
	if {[validuser $new]} {puthelp "NOTICE $nick :$cmdtbslg Handle: $new belongs to another user." ; return 0}
	if {![chnick $old $new]} {puthelp "NOTICE $nick :$cmdtbslg New handle: $new is not a valid handlename." ; return 0}
	chnick $old $new ; puthelp "NOTICE $nick :$cmdtbslg Your old handle: $old has changed to: $new."
	save ; puthelp "NOTICE $nick :$cmdtbslg Saving user file."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! Handle change: $old to: $new." ; return 0
}

proc pub_nickgue {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set old [lindex $rest 0] ; set new [lindex $rest 1]
	if {$old == "" || $new == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: ${DBPRM}chandle <current_handle> <new_handle>" ; return 0}
	msg_nickgue $nick $uhost $hand $rest
}

proc msg_+ignore {nick uhost hand rest} {
	global botnick defingtime cmdtbslg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set rest [lindex $rest 0]
	if {[string match "#*" $rest]} {putquick "NOTICE $nick :$cmdtbslg Command: /msg $botnick +ignore <nickname/hostname> \[ignore time (minute(s))\] \[reason\]" ; return 0}
	if {$rest == ""} {putquick "NOTICE $nick :$cmdtbslg Command: /msg $botnick +ignore <nickname/hostname> \[ignore time (minute(s))\] \[reason\]" ; return 0}
	set ingtime [lindex $rest 1] ; set reason [lrange $rest 2 end]
	set ingtime [string trim $ingtime "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_+|~,./;'<>?:{}"]
	if {$ingtime == ""} {set ingtime $defingtime} ; if {$reason == ""} {set reason "4$cmdtbslg \[Ignore\] Requested by: $nick"}
	set ingnick [lindex $rest 0]
	if {[string match "*@*" $ingnick]} {set host $ingnick ; set inghost $host ; set inghand $host} else {set host "" ; set inghost "" ; set inghand ""}
	foreach x [channels] {
		set chan $x
		if {[onchan $ingnick $chan]} {if {$host == "" || $inghost == "" || $ingnick == ""} {set host [getchanhost $ingnick $chan] ; set inghost *!*@[lindex [split $host @] 1] ; set inghand [nick2hand $ingnick $chan]}}
	}
	if {$host == "" || $inghost == "" || $inghand == ""} {putquick "NOTICE $nick :$cmdtbslg $ingnick is not on any of my channel(s)." ; return 0}
	if {[string tolower $ingnick] == [string tolower $botnick]} {putquick "NOTICE $nick :$cmdtbslg I will not ignore myself." ; return 0}
	if {[matchattr $inghand f]} {putquick "NOTICE $nick :$cmdtbslg I will not place an ignore on $ingnick coz a hostmask of this user is included in my user list." ; return 0}
	foreach x [userlist] {
		if {[string match *$x* $inghost]} {putquick "NOTICE $nick :$cmdtbslg I will not place an ignore on $ingnick coz this hostmask belongs to me or one of my users." ; return 0}
		if {[getchanhost $x $chan] != ""} {
			set rhostmem [lindex [split [getchanhost $x $chan] @] 1] ; set rhosting [string trim [lindex [split $inghost @] 1] "\*\."]
			set lhostmem [lindex [split [getchanhost $x $chan] @] 0] ; set lhosting [string trim [lindex [split $inghost @] 0] "\*\!\."]
			if {[string match *$rhosting* $rhostmem] && [string match *$lhosting* $lhostmem]} {putquick "NOTICE $nick :$cmdtbslg I will not place an ignore on $ingnick coz this hostmask belongs to me or one of my users." ; return 0}
		}
	}
	if {[isignore $rest]} {putquick "NOTICE $nick :$cmdtbslg An ignore already exist for: $inghost." ; return 0}
	putquick "NOTICE $nick :$cmdtbslg Creating Ignore for: $inghost"
	newignore $inghost $hand $reason $ingtime ; putcmdlog "$cmdtbslg <<$nick>> !$hand! +ignore $host $ingtime $reason" ; return 0
}

proc pub_+ignore {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set inghost [lindex $rest 0]
	if {[string match "#*" $inghost]} {putquick "NOTICE $nick :$cmdtbslg Command: ${DBPRM}+ignore <nickname/hostname> \[ignore time (minute(s))\] \[reason\]" ; return 0}
	if {$inghost == ""} {putquick "NOTICE $nick :$cmdtbslg Command: ${DBPRM}+ignore <nickname/hostname> \[ignore time (minute(s))\] \[reason\]" ; return 0}
	msg_+ignore $nick $uhost $hand $inghost
}

proc msg_-ignore {nick uhost hand rest} {
	global botnick cmdtbslg
	if {![matchattr $hand Q]} {putquick "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set rest [lindex $rest 0]
	if {[string match "#*" $rest]} {putquick "NOTICE $nick :$cmdtbslg Command: /msg $botnick -ignore <nickname/hostname>" ; return 0}
	if {$rest == ""} {putquick "NOTICE $nick :$cmdtbslg Command: /msg $botnick -ignore <nickname/hostname>" ; return 0}
	if {![isignore $rest]} {putquick "NOTICE $nick :$cmdtbslg There are no Ignores for: $rest." ; return 0}
	putquick "NOTICE $nick :$cmdtbslg Releasing Ignore on: $rest"
	killignore $rest ; putcmdlog "$cmdtbslg <<$nick>> !$hand! -ignore $rest" ; return 0
}

proc pub_-ignore {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set inghost [lindex $rest 0]
	if {[string match "#*" $inghost]} {putquick "NOTICE $nick :$cmdtbslg Command: ${DBPRM}-ignore <nickname/hostname>" ; return 0}
	if {$inghost == ""} {putquick "NOTICE $nick :$cmdtbslg Command: ${DBPRM}-ignore <nickname/hostname>" ; return 0}
	msg_-ignore $nick $uhost $hand $inghost
}

proc msg_ignorelist {nick uhost hand rest} {
	global botnick cmdtbslg
	set ignorelist ""
	foreach x [ignorelist] {set ignorelisting [lindex $x 0] ; set ignorelist "$ignorelist $ignorelisting"}
	if {$ignorelist == ""} {set ignorelist "empty"}
	putquick "NOTICE $nick :$cmdtbslg My ignore(s) are: $ignorelist."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! List Ignore." ; return 0
}

proc pub_ignorelist {nick uhost hand chan rest} {global DBPRM botnick cmdtbslg ; set rest [lindex $rest 0] ; msg_ignorelist $nick $uhost $hand $rest}

set thehosts { "*" "*!*" "*@*" "*@*.*" "*!*@*" "*!*@*.*" }

proc msg_+user {nick uhost hand rest} {
	global botnick thehosts default-flags cmdtbslg
	if {![matchattr $hand Q]} {puthelp "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set who [lindex $rest 0]
	if {$who == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: /msg $botnick +user <handle> \[ip_address\] \[flags\]" ; return 0}
	if {[validuser $who]} {puthelp "NOTICE $nick :$cmdtbslg $who already exist in my user list." ; return 0}
	set hostmask [lindex $rest 1]
	if {$hostmask == ""} {
		foreach x [channels] {
			set chan $x
			if {[onchan $who $chan]} {set hostmask [getchanhost $who $chan]} else {puthelp "NOTICE $nick :$cmdtbslg $who is not on my channel(s), a <hostmask> must be included in the command." ; return 0}
		}
		set hostmask [maskhost $nick!$hostmask]
	} else {
		foreach hostsuser $thehosts {
			set hostuser $hostsuser
			if {$hostmask == $hostuser} {puthelp "NOTICE $nick :$cmdtbslg Hostmask: \[$hostmask\] is not a valid hostmask." ; return 0}
		}
	}
	adduser $who $hostmask ; puthelp "NOTICE $nick :$cmdtbslg $who is now added to my user list with hostmask: \[$hostmask\]."
	set addflags [lindex $rest 2]
	if {$addflags == ""} {puthelp "NOTICE $nick :$cmdtbslg No user flags included, I'm going to use my default flag \[${default-flags}\] for this user."}
	chattr $who ${default-flags} ; puthelp "NOTICE $nick :$cmdtbslg Standard user's flags ${default-flags} now added for handle: $who."
	save ; puthelp "NOTICE $nick :$cmdtbslg Saving user file."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! +user $who \[$hostmask\]." ; return 0
}

proc pub_+user {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set who [lindex $rest 0] ; if {$who == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: ${DBPRM}+user <handle> \[ip_address\] \[flags\]" ; return 0}
	msg_+user $nick $uhost $hand $rest
}

proc msg_+master {nick uhost hand rest} {
	global botnick thehosts default-flags cmdtbslg
	if {![matchattr $hand Q]} {puthelp "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set who [lindex $rest 0]
	if {$who == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: /msg $botnick +master <handle> \[ip_address\] \[flags\]" ; return 0}
	if {[validuser $who]} {puthelp "NOTICE $nick :$cmdtbslg $who already exist in my user list." ; return 0}
	set hostmask [lindex $rest 1]
	if {$hostmask == ""} {
		foreach x [channels] {
			set chan $x
			if {[onchan $who $chan]} {set hostmask [getchanhost $who $chan]} else {puthelp "NOTICE $nick :$cmdtbslg $who is not on my channel(s), a <hostmask> must be included in the command." ; return 0}
		}
		set hostmask [maskhost $nick!$hostmask]
	} else {
		foreach hostsuser $thehosts {
			set hostuser $hostsuser
			if {$hostmask == $hostuser} {puthelp "NOTICE $nick :$cmdtbslg Hostmask: \[$hostmask\] is not a valid hostmask." ; return 0}
		}
	}
	adduser $who $hostmask ; puthelp "NOTICE $nick :$cmdtbslg $who sekarang menjadi master dengan hostmask: \[$hostmask\]."
	set addflags +fmolj
	if {$addflags == ""} {puthelp "NOTICE $nick :$cmdtbslg Flags $who adalah \[$addflags\] sekarang."}
	chattr $who $addflags ; puthelp "NOTICE $nick :$cmdtbslg Standard master flags $addflags sekarang ditambahkan ke: $who."
	puthelp "NOTICE $who :$cmdtbslg Sekarang kamu menjadi master, ketik /msg $botnick pass <password> untuk bisa auth ke bot"
	save ; puthelp "NOTICE $nick :$cmdtbslg Saving user file."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! +master $who \[$hostmask\]." ; return 0
}

proc pub_+master {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set who [lindex $rest 0] ; if {$who == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: ${DBPRM}+master <handle> \[ip_address\] \[flags\]" ; return 0}
	msg_+master $nick $uhost $hand $rest
}
proc msg_+friend {nick uhost hand rest} {
	global botnick thehosts default-flags cmdtbslg
	if {![matchattr $hand Q]} {puthelp "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set who [lindex $rest 0]
	if {$who == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: /msg $botnick friend <handle> \[ip_address\] \[flags\]" ; return 0}
	if {[validuser $who]} {puthelp "NOTICE $nick :$cmdtbslg $who already exist in my user list." ; return 0}
	set hostmask [lindex $rest 1]
	if {$hostmask == ""} {
		foreach x [channels] {
			set chan $x
			if {[onchan $who $chan]} {set hostmask [getchanhost $who $chan]} else {puthelp "NOTICE $nick :$cmdtbslg $who is not on my channel(s), a <hostmask> must be included in the command." ; return 0}
		}
		set hostmask [maskhost $nick!$hostmask]
	} else {
		foreach hostsuser $thehosts {
			set hostuser $hostsuser
			if {$hostmask == $hostuser} {puthelp "NOTICE $nick :$cmdtbslg Hostmask: \[$hostmask\] is not a valid hostmask." ; return 0}
		}
	}
	adduser $who $hostmask ; puthelp "NOTICE $nick :$cmdtbslg $who sekarang menjadi master dengan hostmask: \[$hostmask\]."
	set addflags +f
	if {$addflags == ""} {puthelp "NOTICE $nick :$cmdtbslg Flags $who adalah \[$addflags\] sekarang."}
	chattr $who $addflags ; puthelp "NOTICE $nick :$cmdtbslg Standard master flags $addflags sekarang ditambahkan ke: $who."
	puthelp "NOTICE $who :$cmdtbslg kamu di tambahkan ke bot sebagai Friend \[$addflags\]"
	save ; puthelp "NOTICE $nick :$cmdtbslg Saving user file."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! +master $who \[$hostmask\]." ; return 0
}

proc pub_+friend {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set who [lindex $rest 0] ; if {$who == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: ${DBPRM}+friend <handle> \[ip_address\] \[flags\]" ; return 0}
	msg_+friend $nick $uhost $hand $rest
}

proc msg_-user {nick uhost hand rest} {
	global botnick cmdtbslg
	if {![matchattr $hand Q]} {puthelp "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set who [lindex $rest 0]
	if {$who == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: /msg $botnick -user <handle>" ; return 0}
	if {![validuser $who]} {puthelp "NOTICE $nick :$cmdtbslg Handle: $who is not exist in my user list." ; return 0}
	if {![matchattr $hand n] && [matchattr $who n]} {puthelp "NOTICE $nick :$cmdtbslg You are a master and you are not allowed to remove my owner's profile." ; return 0}
	deluser $who ; puthelp "NOTICE $nick :$cmdtbslg Handle: $who is now removed from my user list."
	save ; puthelp "NOTICE $nick :$cmdtbslg Saving user file."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! -user $who." ; return 0
}

proc pub_-user {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set who [lindex $rest 0] ; if {$who == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: ${DBPRM}-user <handle>" ; return 0}
	msg_-user $nick $uhost $hand $rest
}

proc msg_+bot {nick uhost hand rest} {
	global botnick thehosts default-flags cmdtbslg
	if {![matchattr $hand Q]} {puthelp "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set bot [lindex $rest 0] ; set address [lindex $rest 1] ; set hostmask [lindex $rest 2]
	if {$bot == "" || $address == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: /msg $botnick +bot <bothandle> <ip_address:botport#\[userport#\]> \[hostmask\]" ; return 0}
	if {[validuser $bot]} {puthelp "NOTICE $nick :$cmdtbslg Bot handle: $bot already exist in my user list." ; return 0}
	set porttest [string trim $address "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_+|~,./;'<>?:{}"] ; set porttest [string trim $porttest ":"]
	if {$porttest == ""} {puthelp "NOTICE $nick :$cmdtbslg You must include the bot port number." ; return 0}
	addbot $bot $address ; chattr $bot +b
	if {$hostmask != ""} {
		foreach hostsuser $thehosts {
			set hostuser $hostsuser
			if {$hostmask == $hostuser} {puthelp "NOTICE $nick :$cmdtbslg Hostmask: \[$hostmask\] is not a valid hostmask." ; return 0}
		}
		setuser $bot HOSTS $hostmask
	}
	puthelp "NOTICE $nick :$cmdtbslg $bot \[${address}\] is now added to my user list as a BOT."
	save ; puthelp "NOTICE $nick :$cmdtbslg Saving user file."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! +bot $bot $address $hostmask." ; return 0
}

proc pub_+bot {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set bot [lindex $rest 0] ; set address [lindex $rest 1]
	if {$bot == "" || $address == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: ${DBPRM}+bot <bothandle> <ip_address:botport#\[userport#\]> \[hostmask\]" ; return 0}
	msg_+bot $nick $uhost $hand $rest
}

proc msg_-bot {nick uhost hand rest} {
	global botnick cmdtbslg
	if {![matchattr $hand Q]} {puthelp "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set bot [lindex $rest 0]
	if {$bot == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: /msg $botnick -bot <bothandle>" ; return 0}
	if {![validuser $bot]} {puthelp "NOTICE $nick :$cmdtbslg Bot handle: $bot is not exist in my user list." ; return 0}
	if {![matchattr $bot b]} {puthelp "NOTICE $nick :$cmdtbslg $bot is not a user who recorded as a bot." ; return 0}
	deluser $bot ; puthelp "NOTICE $nick :$cmdtbslg Bot handle: $bot is now removed from my user list."
	save ; puthelp "NOTICE $nick :$cmdtbslg Saving user file."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! -bot $bot." ; return 0
}

proc pub_-bot {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set bot [lindex $rest 0] ; if {$bot == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: ${DBPRM}-bot <bothandle>" ; return 0}
	msg_-bot $nick $uhost $hand $rest
}

proc msg_+host {nick uhost hand rest} {
	global botnick thehosts cmdtbslg
	if {![matchattr $hand Q]} {puthelp "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set who [lindex $rest 0] ; set hostname [lindex $rest 1]
	if {$who == "" || $hostname == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: /msg $botnick +host <handle> <new_hostmask>" ; return 0}
	if {![validuser $who]} {puthelp "NOTICE $nick :$cmdtbslg Handle: $who is not exist in my user list." ; return 0}
	foreach hostsuser [getuser $who HOSTS] {
		set hostuser $hostsuser
		if {$hostname == $hostuser} {puthelp "NOTICE $nick :$cmdtbslg Hostmask: $hostname already exist for handle: $who." ; return 0}
	}
	if {![matchattr $hand n] && [matchattr $who n]} {puthelp "NOTICE $nick :$cmdtbslg You are a master and you are not allowed to add or remove any hostmasks for my owner." ; return 0}
	foreach hostsuser $thehosts {
		set hostuser $hostsuser
		if {$hostname == $hostuser} {puthelp "NOTICE $nick :$cmdtbslg Hostmask: $hostname is not a valid hostmask." ; return 0}
	}
	setuser $who HOSTS $hostname ; if {[matchattr $who a]} {putquick "MODE $chan +o $who"}
	puthelp "NOTICE $nick :$cmdtbslg New nostmask: \[$hostname\] is now added for handle: $who."
	save ; puthelp "NOTICE $nick :$cmdtbslg Saving user file."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! +host $who $hostname." ; return 0
}

proc pub_+host {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set who [lindex $rest 0] ; set hostname [lindex $rest 1]
	if {$who == "" || $hostname == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: ${DBPRM}+host <handle> <new_hostmask>" ; return 0}
	msg_+host $nick $uhost $hand $rest
}

proc msg_-host {nick uhost hand rest} {
	global botnick thehosts cmdtbslg
	if {![matchattr $hand Q]} {puthelp "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set who [lindex $rest 0] ; set hostname [lrange $rest 1 end]
	if {$who == "" || $hostname == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: /msg $botnick -host <handle> <hostmask>" ; return 0}
	if {![validuser $who]} {puthelp "NOTICE $nick :$cmdtbslg Handle: $who is not exist in my user list." ; return 0}
	if {![matchattr $hand n] && [matchattr $who n]} {puthelp "NOTICE $nick :$cmdtbslg You are a master and you are not allowed to add or remove any hostmasks for my owner." ; return 0}
	set delhost ""
	foreach hostsuser [getuser $who HOSTS] {
		if {$hostname == $hostsuser} {set delhost $hostsuser}
	}
	if {$delhost == ""} {puthelp "NOTICE $nick :$cmdtbslg Hostmask: $hostname is not exist for handle: $who." ; return 0}
	delhost $who $hostname ; puthelp "NOTICE $nick :$cmdtbslg Hostmask: \[$hostname\] is now removed from handle: $who."
	save ; puthelp "NOTICE $nick :$cmdtbslg Saving user file."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! -host $who $hostname." ; return 0
}

proc pub_-host {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set who [lindex $rest 0] ; set hostname [lindex $rest 1]
	if {$who == "" || $hostname == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: ${DBPRM}-host <handle> <hostmask>" ; return 0}
	msg_-host $nick $uhost $hand $rest
}

proc msg_chattr {nick uhost hand rest} {
	global botnick default-flags cmdtbslg
	if {![matchattr $hand Q]} {puthelp "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set who [lindex $rest 0] ; set flags [lindex $rest 1] ; set chan [lindex $rest 2]
	if {$who == "" || $flags == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: /msg $botnick chattr <handle> <flags> \[#channel\]" ; return 0}
	if {![validuser $who]} {puthelp "NOTICE $nick :$cmdtbslg Handle: $who is not exist in my user list." ; return 0}
	if {![matchattr $hand n] && [matchattr $who n]} {puthelp "NOTICE $nick :$cmdtbslg You are a master and you are not allowed to modify my owner's flags." ; return 0}
	if {![matchattr $hand n]} {
		set nflagl [string trim $flags abcdefghijklopqrstuvwxyzABCDEFGHIJKLOPQRSTUVWXYZ+-|]
		if {$nflagl != ""} {puthelp "NOTICE $nick :$cmdtbslg You are a master and you don't have access to modify \[n\] or \[m\] flag for other users." ; return 0}
	}
	set nflag2 [string trim $flags abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-|]
	if {$nflag2 != ""} {puthelp "NOTICE $nick :$cmdtbslg You specified an invalid flag: \[$nflag2\], refer to \[.help chattr\] on DCC chat." ; return 0}
	if {$chan != ""} {
		if {[validchan $chan]} {
			if {[string trim $flags abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-] == "|"} {chattr $who $flags $chan} else {chattr $who |$flags $chan}
			set chanflags [chattr $who | $chan]
			set chanflags [string trimleft $chanflags "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]
			set chanflags [string trim $chanflags "|"]
			puthelp "NOTICE $nick :$cmdtbslg Chattr $who \[$chanflags\] $chan."
			puthelp "NOTICE $nick :$cmdtbslg New flags for handle: $who are now: \[[chattr $who]\]."
			if {$chanflags != "-"} {puthelp "NOTICE $nick :$cmdtbslg Channel's flag for: $who on channel: $chan are now: \[$chanflags\]." ; return 0
			} else {puthelp "NOTICE $nick :$cmdtbslg $who does not have any specific channel flags." ; return 0}
			save ; puthelp "NOTICE $nick :$cmdtbslg Saving user file."
			putcmdlog "$cmdtbslg <<$nick>> !$hand! Chattr $who \[$flags\] $chan." ; return 0
		} else {puthelp "NOTICE $nick :$cmdtbslg Channel: $chan is not exist in my channel list." ; return 0}
	} else {
		chattr $who $flags
		puthelp "NOTICE $nick :$cmdtbslg Chattr $who \[$flags\]"
		puthelp "NOTICE $nick :$cmdtbslg Global flags for handle: $who are now: \[[chattr $who]\]."
	}
	if {[matchattr $who a]} {putquick "MODE $chan +o $who"}
	if {![matchattr $who a] && ![matchattr $who o]} {if {[isop $who $chan]} {putquick "MODE $chan -o $who"}}
	save ; puthelp "NOTICE $nick :$cmdtbslg Saving user file."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! chattr $who \[$flags\]." ; return 0
}

proc pub_chattr {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set who [lindex $rest 0] ; set flags [lindex $rest 1]
	if {$who == "" || $flags == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: ${DBPRM}chattr <handle> <flags> \[#channel\]" ; return 0}
	msg_chattr $nick $uhost $hand $rest
}

proc msg_botattr {nick uhost hand rest} {
	global botnick default-flags cmdtbslg
	if {![matchattr $hand Q]} {puthelp "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set bot [lindex $rest 0] ; set bflags [lindex $rest 1] ; set chan [lindex $rest 2]
	if {$bot == "" || $bflags == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: /msg $botnick botattr <bothandle> <botflags> \[#channel\]" ; return 0}
	if {![validuser $bot]} {puthelp "NOTICE $nick :$cmdtbslg Bot handle: $bot is not exist in my user list." ; return 0}
	if {![matchattr $bot b]} {puthelp "NOTICE $nick :$cmdtbslg $bot is not a user who recorded as a bot." ; return 0}
	set nflagl [string trim $flags acdefghijklmnopqrstuvwxyzACDEFGHIJKLMNOPQRSTUVWXYZ+-|]
	if {$nflagl != ""} {puthelp "NOTICE $nick :$cmdtbslg Since this user is a bot, you cannot remove \[b\] flag for this user." ; return 0}
	set nflag2 [string trim $flags abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-|]
	if {$nflag2 != ""} {puthelp "NOTICE $nick :$cmdtbslg You specified an invalid flag: \[$nflag2\], refer to \[.help chattr\] on DCC chat." ; return 0}
	if {$chan != ""} {
		if {[validchan $chan]} {
			if {[string trim $bflags abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-] == "|"} {botattr $bot $bflags $chan} else {botattr $bot |$bflags $chan}
			set chanflags [chattr $bot | $chan]
			set chanflags [string trimleft "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-"]
			set chanflags [string trim $chanflags "|"] 
			puthelp "NOTICE $nick :$cmdtbslg Botattr $bot \[$chanflags\] $chan"
			puthelp "NOTICE $nick :$cmdtbslg New flags for bot: $bot are now: \[[chattr $bot]\]."
			if {$chanflags != "-"} {puthelp "NOTICE $nick :$cmdtbslg Channel's flag for bot: $bot on channel: $chan are now: \[$chanflags\]." ; return 0
			} else {puthelp "NOTICE $nick :$cmdtbslg Bot: $bot does not have any specific channel flags." ; return 0}
			save ; puthelp "NOTICE $nick :$cmdtbslg Saving user file."
			putcmdlog "$cmdtbslg <<$nick>> !$hand! botattr $bot \[$bflags\] $chan." ; return 0
		} else {puthelp "NOTICE $nick :$cmdtbslg Channel: $chan is not exist in my channel list." ; return 0}
	} else {
		botattr $bot $bflags
		puthelp "NOTICE $nick :$cmdtbslg Botattr $bot \[$bflags\]."
		puthelp "NOTICE $nick :$cmdtbslg Global flags for bot: $bot are now: \[[chattr $bot]\]."
		save ; puthelp "NOTICE $nick :$cmdtbslg Saving user file."
		putcmdlog "$cmdtbslg <<$nick>> !$hand! Botattr $bot \[$bflags\]." ; return 0
	}
}

proc pub_botattr {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set bot [lindex $rest 0] ; set bflags [lindex $rest 1] ; set chan [lindex $rest 2]
	if {$bot == "" || $bflags == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: ${DBPRM}botattr <bothandle> <botflags> \[#channel\]" ; return 0}
	msg_botattr $nick $uhost $hand $rest
}

proc msg_hubung {nick uhost hand rest} {
	global botnick cmdtbslg
	if {![matchattr $hand Q]} {puthelp "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set rest [lindex $rest 0]
	if {$rest == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: /msg $botnick link <bothandle>" ; return 0}
	if {![validuser $rest]) {puthelp "NOTICE $nick :$cmdtbslg Bot handle: $rest is not exist in my user list." ; return 0}
	if (![matchattr $rest b]} {puthelp "NOTICE $nick :$cmdtbslg $rest is not a user who recorded as a bot." ; return 0}
	if {[lsearch -exact [string tolower [bots]] [string tolower $rest]] > -1} {puthelp "NOTICE $nick :$cmdtbslg Bot: $rest already linked to the BotNet." ; return 0}
	if {[lsearch -exact [string tolower [bots]] [string tolower $rest]] == -1} {
		link $rest ; puthelp "NOTICE $nick :$cmdtbslg Linking Bot: $rest with Bot address: \[[getuser $rest BOTADDR]\]."
		putcmdlog "$cmdtbslg <<$nick>> !$hand! link $rest." ; return 0
	}
}

proc pub_hubung {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set rest [lindex $rest 0] ; if {$rest == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: ${DBPRM}link <bothandle>" ; return 0}
	msg_hubung $nick $uhost $hand $rest
}

proc msg_putus {nick uhost hand rest} {
	global botnick cmdtbslg
	if {![matchattr $hand Q]} {puthelp "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	set rest [lindex $rest 0]
	if {$rest == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: /msg $botnick unlink <bothandle>" ; return 0}
	if {![validuser $rest]) {puthelp "NOTICE $nick :$cmdtbslg Bot handle: $rest is not exist in my user list." ; return 0}
	if (![matchattr $rest b]} {puthelp "NOTICE $nick :$cmdtbslg $rest is not a user who recorded as a bot." ; return 0}
	if {[lsearch -exact [string tolower [bots]] [string tolower $rest]] == -1} {puthelp "NOTICE $nick :$cmdtbslg Bot: $rest is not currently connected to the BotNet." ; return 0}
	if {[lsearch -exact [string tolower [bots]] [string tolower $rest]] > -1} {
		unlink $rest ; puthelp "NOTICE $nick :$cmdtbslg Unlinking Bot: $rest from the BotNet."
		putcmdlog "$cmdtbslg <<$nick>> !$hand! unlink $rest." ; return 0
	}
}

proc pub_putus {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set rest [lindex $rest 0] ; if {$rest == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: ${DBPRM}unlink <bothandle>" ; return 0}
	msg_putus $nick $uhost $hand $rest
}

proc msg_info {nick uhost hand rest} {
	global botnick cmdtbslg
	if {![matchattr $hand Q]} {puthelp "NOTICE $nick :$cmdtbslg You haven't authenticate Yourself. Type: \[/msg $botnick auth <password>\] to do so." ; return 0}
	if {$rest == ""} {
		set currinfo [getuser $hand INFO]
		if {$currinfo == ""} {set currinfo "No greeting info sets for you yet."}
		puthelp "NOTICE $nick :$cmdtbslg Info: $currinfo" ; return 0
	}
	if {[string toupper $rest] == "NONE"} {
		setuser $hand info "" ; puthelp "NOTICE $nick :$cmdtbslg Removing greet info for handle: $hand."
		save ; puthelp "NOTICE $nick :$cmdtbslg Saving user file."
		putcmdlog "$cmdtbslg <<$nick>> !$hand! Remove Info for: $hand" ; return 0
	}
	setuser $hand info $rest
	puthelp "NOTICE $nick :$cmdtbslg Greet info for handle: $hand are now: $rest."
	save ; puthelp "NOTICE $nick :$cmdtbslg Saving user file."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! Set $nick info: $rest." ; return 0
}

proc pub_info {nick uhost hand chan rest} {global DBPRM botnick cmdtbslg ; msg_info $nick $uhost $hand $rest}

proc msg_infouser {nick uhost hand rest} {
	global botnick max-notes cmdtbslg
	set rest [lindex $rest 0]
	if {$rest == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: /msg $botnick userinfo <handle>" ; return 0}
	set fl "$cmdtbslg"
	if {![validuser $rest]} {puthelp "NOTICE $nick :$cmdtbslg Handle: $rest is not exist in my user list." ; return 0}
	set user [lindex $rest 0]
	set ch [passwdok "$rest" ""]
	if {!$ch} {set pass "Yes "} else {set pass " No "}
	set notes [notes $user]
	set flags [chattr $user]
	while {[string length $flags] < 15} {append flags " "}
	while {[string length $user] < 9} {append user " "}
	if {[string length $notes] == "1"} {set notes " ${notes}"}
	if {[string length $notes] == "2"} {set notes " ${notes}"}
	set lastseen [ctime [lindex [getuser [string trim $user] LASTON] 0]]
	set day "[lindex $lastseen 0]."
	set month "[lindex $lastseen 1], [lindex $lastseen 2]"
	set time [lindex $lastseen 3]
	set year "[string range [lindex $lastseen 4] 2 3]"
	set last "$time on $month"
	puthelp "NOTICE $nick :$fl HANDLE: [string trim $user " "], PASSWORD: [string trim $pass " "], NOTES: [string trim $notes " "] note(s), GLOBAL FLAGS: [string trim $flags " "], LAST SEEN: [string trim $last " "]"
	set user [string trim $user]
	if {![matchattr $user b]} {
		foreach i [channels] {
			set tchan [string length $i]
			set bl3 "                  "
			if {$tchan < 18} {set dt3 [expr 17-$tchan] ; set add2 [string range $bl3 0 $dt3] ; append channels $i$add2}
			set cflags [chattr $user | $i] 
			set nflags [string trimleft $cflags "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]
			set cfflags [string trim $nflags "|"]
			set cf [string length $cfflags]
			set flagslen2 [string length $cf]
			set bl26 "               "
			if {$flagslen2 < 14} {set dt26 [expr 13-$flagslen2] ; set add4 [string range $bl26 0 $dt26] ; append flags12 $add4}
			if {$flagslen2 > 14} {set flags12 [string range $flagslen2 0 13]}
			set lastseen2 [ctime [lindex [getuser $user LASTON $i] 0]]
			set day2 "[lindex $lastseen2 0]."
			set month2 "[lindex $lastseen2 1], [lindex $lastseen2 2]"
			set time2 [lindex $lastseen2 3]
			set year2 "[string range [lindex $lastseen2 4] 2 3]"
			set last2 "$time on $month2"
		}
		puthelp "NOTICE $nick :$fl CHANNEL(s): [string trim $channels " "], CHAN FLAGS: [string trim $cfflags " "] - [string trim $flags12 " "], LAST SEEN: [string trim $last2 " "]"
	}
	if {[getuser $user HOSTS] != ""} {set hosts [getuser $user hosts] ; puthelp "NOTICE $nick :$fl HOSTMASK: [string trim $hosts " "]"}
	if {[getuser $user BOTFL] != ""} {puthelp "NOTICE $nick :$fl BOT FLAGS: [string trim [getuser $user BOTFL] " "]"}
	if {[getuser $user BOTADDR] != ""} {set botinfo [getuser $user BOTADDR] ; puthelp "NOTICE $nick :$fl BOT ADDRESS: [string trim [lindex $botinfo 0] " "]" ; puthelp "NOTICE $nick :$fl, TELNET: [string trim [lindex $botinfo 1] " "], RELAY: [string trim [lindex $botinfo 2] " "]"}
	putcmdlog "$cmdtbslg <<$nick>> !$hand! userinfo $rest." ; return 0
}

proc pub_infouser {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set rest [lindex $rest 0] ; if {$rest == ""} {puthelp "NOTICE $nick :$cmdtbslg Command: ${DBPRM}userinfo <handle>" ; return 0}
	msg_infouser $nick $uhost $hand $rest
}

proc msg_chennel {nick hand uhost rest} {
	global botnick cmdtbslg
	regsub -all " " [channels] ", " chans
	puthelp "NOTICE $nick :$cmdtbslg My channel(s) are: $chans."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! Channel list." ; return 0
}

proc pub_chennel {nick uhost hand chan rest} {global DBPRM botnick cmdtbslg ; msg_chennel $nick $uhost $hand $rest}

proc msg_daftaruser {nick uhost hand rest} {
	global botnick cmdtbslg
	set nflag1 [string trim $rest abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-|]
	if {$nflag1 != ""} {puthelp "NOTICE $nick :$cmdtbslg You specified an invalid flag: \[$nflag1\], refer to \[.help chattr\] on DCC chat." ; return 0}
	if {[userlist $rest] == ""} {puthelp "NOTICE $nick :$cmdtbslg User with flags: \[$rest\] is not exist in my user list." ; return 0}
	regsub -all " " [userlist $rest]  ", " userlist ; if {$rest == ""} {set rest "*"}
	puthelp "NOTICE $nick :$cmdtbslg My users \[$rest\] are: $userlist."
	putcmdlog "$cmdtbslg <<$nick>> !$hand! User list (flag): $rest." ; return 0
}

proc pub_daftaruser {nick uhost hand chan rest} {global DBPRM botnick cmdtbslg ; msg_daftaruser $nick $uhost $hand $rest}

proc dcc_chennel {hand idx rest} {
	global botnick cmdtbslg
	regsub -all " " [channels] ", " chans ; putdcc $idx "$cmdtbslg My channel(s) are: $chans"
	putcmdlog "$cmdtbslg <<$hand>> !$hand! Channel list." ; return 0
}

proc dcc_daftaruser {hand idx rest} {
	global botnick cmdtbslg
	set nflag1 [string trim $rest abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-|]
	if {$nflag1 != ""} {putdcc $idx "$cmdtbslg You specified an invalid flag: \[$nflag1\], refer to \[.help chattr\] on DCC chat." ; return 0}
	if {[userlist $rest] == ""} {putdcc $idx "$cmdtbslg User with flags: \[$rest\] is not exist in my user list." ; return 0}
	regsub -all " " [userlist $rest]  ", " userlist ; putdcc $idx "$cmdtbslg My users \[$rest\] are: $userlist."
	putcmdlog "$cmdtbslg <<$hand>> !$hand! User list (flag): $rest." ; return 0
}

proc msg_dtbshelp {nick uhost hand rest} {
	global DBPRM botnick cmdtbslg
	set dhlptype [string toupper [lindex $rest 0]]
	if {$dhlptype == ""} {putquick "NOTICE $nick :$cmdtbslg Command: /msg $botnick dtbshelp PUB or /msg $botnick dtbshelp MSG" ; return 0}
	if {$dhlptype != "PUB" && $dhlptype != "MSG"} {putquick "NOTICE $nick :$cmdtbslg Command: /msg $botnick dtbshelp PUB or /msg $botnick dtbshelp MSG" ; return 0}
	putquick "NOTICE $nick :$cmdtbslg Database Commands $cmdtbslg"
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :NOTES:"
	putquick "NOTICE $nick :<> sign means you MUST fill the value."
	putquick "NOTICE $nick :\[\] sign means you can either fill the value or leave it blank."
	putquick "NOTICE $nick :| sign means you MUST choose one between value placed on the left side of | sign, or on the right side."
	putquick "NOTICE $nick : "
	if {$dhlptype == "PUB"} {
		putquick "NOTICE $nick :Public Commands:"
		putquick "NOTICE $nick : "
		if {[matchattr $hand m]} {putquick "NOTICE $nick :${DBPRM}reload"}
		putquick "NOTICE $nick :${DBPRM}save"
		putquick "NOTICE $nick :${DBPRM}backup"
		putquick "NOTICE $nick :${DBPRM}chandle <oldhandle> <newhandle>"
		if {[matchattr $hand m]} {
			putquick "NOTICE $nick :${DBPRM}+ignore <nickname/hostname> \[ignore-time (minute(s))\] \[reason\]"
			putquick "NOTICE $nick :${DBPRM}-ignore <nickname/hostname>"
			putquick "NOTICE $nick :${DBPRM}ignorelist"
			putquick "NOTICE $nick :${DBPRM}+user <handle> \[ip_address\] \[flags\]"
			putquick "NOTICE $nick :${DBPRM}-user <handle>"
			putquick "NOTICE $nick :${DBPRM}+bot <bothandle> <ip_address:botport#\[userport#\]> \[hostmask\]"
			putquick "NOTICE $nick :${DBPRM}-bot <bothandle>"
			putquick "NOTICE $nick :${DBPRM}+host <handle> <new_hostmask>"
			putquick "NOTICE $nick :${DBPRM}-host <handle> <hostmask>"
			putquick "NOTICE $nick :${DBPRM}chattr <handle> <flags> \[#channel\]"
			putquick "NOTICE $nick :${DBPRM}botattr <bothandle> <botflags> \[#channel\]"
			putquick "NOTICE $nick :${DBPRM}link <bothandle>"
			putquick "NOTICE $nick :${DBPRM}unlink <bothandle>"
		}
		putquick "NOTICE $nick :${DBPRM}info \[newgreetinfo|NONE\]"
		putquick "NOTICE $nick :${DBPRM}userinfo <handle>"
		putquick "NOTICE $nick :${DBPRM}chanlist"
		putquick "NOTICE $nick :${DBPRM}userlist \[flags\]"
		putquick "NOTICE $nick : "
	}
	if {$dhlptype == "MSG"} {
		putquick "NOTICE $nick :MSG & DCC Commands:"
		putquick "NOTICE $nick : "
		if {[matchattr $hand m]} {putquick "NOTICE $nick :/msg $botnick reload"}
		putquick "NOTICE $nick :/msg $botnick save"
		putquick "NOTICE $nick :/msg $botnick backup"
		putquick "NOTICE $nick :/msg $botnick chandle <oldhandle> <newhandle>"
		if {[matchattr $hand m]} {
			putquick "NOTICE $nick :/msg $botnick +ignore <nickname/hostname> \[ignore-time (minute(s))\] \[reason\]"
			putquick "NOTICE $nick :/msg $botnick -ignore <nickname/hostname>"
			putquick "NOTICE $nick :/msg $botnick ignorelist"
			putquick "NOTICE $nick :/msg $botnick +user <handle> \[ip_address\] \[flags\]"
			putquick "NOTICE $nick :/msg $botnick -user <handle>"
			putquick "NOTICE $nick :/msg $botnick +bot <bothandle> <ip_address:botport#\[userport#\]> \[hostmask\]"
			putquick "NOTICE $nick :/msg $botnick -bot <bothandle>"
			putquick "NOTICE $nick :/msg $botnick +host <handle> <new_hostmask>"
			putquick "NOTICE $nick :/msg $botnick -host <handle> <hostmask>"
			putquick "NOTICE $nick :/msg $botnick chattr <handle> <flags> \[#channel\]"
			putquick "NOTICE $nick :/msg $botnick botattr <bothandle> <botflags> \[#channel\]"
			putquick "NOTICE $nick :/msg $botnick link <bothandle>"
			putquick "NOTICE $nick :/msg $botnick unlink <bothandle>"
		}
		putquick "NOTICE $nick :/msg $botnick info \[newgreetinfo|NONE\]"
		putquick "NOTICE $nick :/msg $botnick userinfo <handle>"
		putquick "NOTICE $nick :/msg $botnick chanlist"
		putquick "NOTICE $nick :/msg $botnick userlist \[flags\]"
		putquick "NOTICE $nick : "
		putquick "NOTICE $nick :DCC Commands:"
		putquick "NOTICE $nick :"
		putquick "NOTICE $nick :.chanlist"
		putquick "NOTICE $nick :.userlist \[flags\]"
		putquick "NOTICE $nick : "
	}
	putquick "NOTICE $nick :Other Commands:"
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :${DBPRM}dtbshelp PUB ${DBPRM}dtbshelp MSG"
	putquick "NOTICE $nick :/msg $botnick dtbshelp PUB or /msg $botnick dtbshelp MSG"
	putquick "NOTICE $nick : "
	putcmdlog "$cmdtbslg <<$nick>> !$hand! Database Commands Help." ; return 0
}

proc pub_dtbshelp {nick uhost hand chan rest} {
	global DBPRM botnick cmdtbslg
	set dhlptype [string toupper [lindex $rest 0]]
	if {$dhlptype == ""} {putquick "NOTICE $nick :$cmdtbslg Command: ${DBPRM}dtbshelp PUB or ${DBPRM}dtbshelp MSG" ; return 0}
	if {$dhlptype != "PUB" && $dhlptype != "MSG"} {putquick "NOTICE $nick :$cmdtbslg Command: ${DBPRM}dtbshelp PUB or ${DBPRM}dtbshelp MSG" ; return 0}
	msg_dtbshelp $nick $uhost $hand $dhlptype
}

# Set this to "1" if you like the script to be loaded.. and set it to "0" to unload.
set cmddtbsloaded 1

if {[info exist cmddtbsloaded]} {
	if {${cmddtbsloaded}} {
		bind pub m ${DBPRM}reload pub_setdata
		bind msg m reload msg_setdata
		bind pub p|p ${DBPRM}save pub_simpan
		bind msg p|p save msg_simpan
		bind pub p|p ${DBPRM}backup pub_backup
		bind msg p|p backup msg_backup
		bind pub p|p ${DBPRM}chandle pub_nickgue
		bind msg p|p chandle msg_nickgue
		bind pub m ${CHPRM}+ignore pub_+ignore
		bind msg m +ignore msg_+ignore
		bind pub m ${CHPRM}-ignore pub_-ignore
		bind msg m -ignore msg_-ignore
		bind pub m ${CHPRM}ignorelist pub_ignorelist
		bind msg m ignorelist msg_ignorelist
		bind pub m ${DBPRM}+user pub_+user
		bind msg m +user msg_+user
		bind pub m ${DBPRM}+master pub_+master
		bind msg m +master msg_+master
		bind pub m ${DBPRM}-user pub_-user
		bind msg m -user msg_-user
		bind pub m ${DBPRM}+bot pub_+bot
		bind msg m +bot msg_+bot
		bind pub m ${DBPRM}-bot pub_-bot
		bind msg m -bot msg_-bot
		bind pub m ${DBPRM}+host pub_+host
		bind msg m +host msg_+host
		bind pub m ${DBPRM}-host pub_-host
		bind msg m -host msg_-host
		bind pub m ${DBPRM}chattr pub_chattr
		bind msg m chattr msg_chattr
		bind pub m ${DBPRM}botattr pub_botattr
		bind msg m botattr msg_botattr
		bind pub m ${DBPRM}link pub_hubung
		bind msg m link msg_hubung
		bind pub m ${DBPRM}unlink pub_putus
		bind msg m unlink msg_putus
		bind pub p|p ${DBPRM}info pub_info
		bind msg p|p info msg_info
		bind pub p|p ${DBPRM}userinfo pub_infouser
		bind msg p|p userinfo msg_infouser
		bind pub p|p ${DBPRM}chanlist pub_chennel
		bind msg p|p chanlist msg_chennel
		bind dcc p|p chanlist dcc_chennel
		bind pub p|p ${DBPRM}userlist pub_daftaruser
		bind msg p|p userlist msg_daftaruser
		bind dcc p|p userlist dcc_daftaruser
		bind pub p|p ${DBPRM}dtbshelp pub_dtbshelp
		bind msg p|p dtbshelp msg_dtbshelp
	} else {
		unbind pub m ${DBPRM}reload pub_setdata
		unbind msg m reload msg_setdata
		unbind pub p|p ${DBPRM}save pub_simpan
		unbind msg p|p save msg_simpan
		unbind pub p|p ${DBPRM}backup pub_backup
		unbind msg p|p backup msg_backup
		unbind pub p|p ${DBPRM}chandle pub_nickgue
		unbind msg p|p chandle msg_nickgue
		unbind pub m ${CHPRM}+ignore pub_+ignore
		unbind msg m +ignore msg_+ignore
		unbind pub m ${CHPRM}-ignore pub_-ignore
		unbind msg m -ignore msg_-ignore
		unbind pub m ${CHPRM}ignorelist pub_ignorelist
		unbind msg m ignorelist msg_ignorelist
		unbind pub m ${DBPRM}+user pub_+user
		unbind msg m +user msg_+user
		unbind pub m ${DBPRM}+master pub_+master
		unbind msg m +master msg_+master
		unbind pub m ${DBPRM}-user pub_-user
		unbind msg m -user msg_-user
		unbind pub m ${DBPRM}+bot pub_+bot
		unbind msg m +bot msg_+bot
		unbind pub m ${DBPRM}-bot pub_-bot
		unbind msg m -bot msg_-bot
		unbind pub m ${DBPRM}+host pub_+host
		unbind msg m +host msg_+host
		unbind pub m ${DBPRM}-host pub_-host
		unbind msg m -host msg_-host
		unbind pub m ${DBPRM}chattr pub_chattr
		unbind msg m chattr msg_chattr
		unbind pub m ${DBPRM}botattr pub_botattr
		unbind msg m botattr msg_botattr
		unbind pub m ${DBPRM}link pub_hubung
		unbind msg m link msg_hubung
		unbind pub m ${DBPRM}unlink pub_putus
		unbind msg m unlink msg_putus
		unbind pub p|p ${DBPRM}info pub_info
		unbind msg p|p info msg_info
		unbind pub p|p ${DBPRM}userinfo pub_infouser
		unbind msg p|p userinfo msg_infouser
		unbind pub p|p ${DBPRM}chanlist pub_chennel
		unbind msg p|p chanlist msg_chennel
		unbind dcc p|p chanlist dcc_chennel
		unbind pub p|p ${DBPRM}userlist pub_daftaruser
		unbind msg p|p userlist msg_daftaruser
		unbind dcc p|p userlist dcc_daftaruser
		unbind pub p|p ${DBPRM}dtbshelp pub_dtbshelp
		unbind msg p|p dtbshelp msg_dtbshelp
	}
	
}

# End of - Commands & Control, Database. (cmd_dtbs.tcl)

# Begin - Commands & Control, Misc. Commands. (cmd_misc.tcl)
#	Designed & Written by TCP-IP (Vicky@Vic.ky), © April 1999
#	Developed by Ninja_baby (Jaysee@Jaysee.Tv), © March 2000

# This script was made by TCP-IP in middle of 1999, I develop this script since he passes this script-
# to me in middle of 2000. I made few changes, add some features, and fixed some bugs that were remain-
# here in this script package.

# This TCL contains some cool stuffs which can be triggered from channel (public) or by /msg..
# You can also use this feature to check your access.. see? hehe ;)
# You can ask for help simpy do /msg <yourbotnick> mischelp or do `mischelp in channel to see what commands-
# did this script has.. I set 2 types of commands.. /msg commands and public (channel) commands.
# NOTE: not much.. even almost has no DCC command stuffs over here.. I will make the DCC commands very soon ;)
#       so please support ;)

# Set this as your Public (channel) command character. For example: you set this to ".".. means you must-
# type !mycommand in channel to activate public commands...
set MISCPRM "."

# This is for your benefit hehe ;), you can either set your own LOGO here, your logo will appear-
# when the bot notice you, or when it makes msgs/notices/kicks or scripts loading. So keep smiling-
# and set this variable as you wish ;), you can either set this to "" to leave it blank.
set cmdmisclg "\[S-B\]:"

######### Please do not edit anything below unless you know what you are doing ;) #########

proc pub_ping {nick uhost hand chan rest} {
	global MISCPRM botnick cmdmisclg
	putquick "PRIVMSG $chan :$nick, PONG =P" ; putcmdlog "$cmdmisclg <<$nick>> !$hand! PING." ; return 0
}

proc pub_pong {nick uhost hand chan rest} {
	global MISCPRM botnick cmdmisclg
	putquick "PRIVMSG $chan :$nick, PING =P" ; putcmdlog "$cmdmisclg <<$nick>> !$hand! PONG." ; return 0
}

proc pub_bilang {nick uhost hand chan rest} {
	global MISCPRM botnick cmdmisclg
	if {$rest == ""} {putquick "NOTICE $nick :$cmdmisclg Command: ${MISCPRM}say <messages>" ; return 0}
	putquick "PRIVMSG $chan :$rest" ; putcmdlog "$cmdmisclg <<$nick>> !$hand! say $rest on: $chan." ; return 0
}

proc pub_aksi {nick uhost hand chan rest} {
	global MISCPRM botnick cmdmisclg
	if {$rest == ""} {putquick "NOTICE $nick :$cmdmisclg Command: ${MISCPRM}act <actions>" ; return 0}
	putquick "PRIVMSG $chan :\001ACTION $rest\001" ; putcmdlog "$cmdmisclg <<$nick>> !$hand! act $rest on: $chan." ; return 0
}

proc pub_peve {nick uhost hand chan rest} {
	global MISCPRM botnick cmdmisclg
	set person [lindex $rest 0] ; set rest [lrange $rest 1 end]
	if {$person == "" || $rest == ""} {putquick "NOTICE $nick :$cmdmisclg Command: ${MISCPRM}msg <nickname/#channel> <messages>" ; return 0}
	if {[isbotnick [string toupper $person]]} {putquick "NOTICE $nick :$cmdmisclg I will not send any messages to myself. Try to trigger this command to another person or a channel." ; return 0}
	putquick "NOTICE $nick :$cmdmisclg I'm now sending message to: $person." ; putquick "PRIVMSG $person :$rest"
	putcmdlog "$cmdmisclg <<$nick>> !$hand! msg $person $rest." ; return 0
}

proc pub_notis {nick uhost hand chan rest} {
	global MISCPRM botnick cmdmisclg
	set person [lindex $rest 0] ; set rest [lrange $rest 1 end]
	if {$person == "" || $rest == ""} {putquick "NOTICE $nick :$cmdmisclg Command: ${MISCPRM}notice <nickname/#channel> <messages>" ; return 0}
	if {[isbotnick [string toupper $person]]} {putquick "NOTICE $nick :$cmdmisclg I will not send any notices to myself. Try to trigger this command to another person or a channel." ; return 0}
	putquick "NOTICE $nick :$cmdmisclg I'm now sending a notice to: $person." ; putquick "NOTICE $person :$rest"
	putcmdlog "$cmdmisclg <<$nick>> !$hand! notice $person $rest." ; return 0
}

#proc pub_ctcp {nick uhost hand chan rest} {
#	global MISCPRM botnick cmdmisclg
#	set person [lindex $rest 0] ; set rest [string toupper [lrange $rest 1 end]]
#	if {$person == "" || $rest == ""} {putquick "NOTICE $nick :$cmdmisclg Command: ${MISCPRM}ctcp <nickname> <messages>" ; return 0}
#	if {[string match "#*" $person]} {putquick "NOTICE $nick :$cmdmisclg I will not send any CTCPs to $person. I can only CTCP to a nickname NOT a channel." ; return 0}
#	if {[string match "ACTION*" $rest] || [string match "PING" $rest]} {putquick "NOTICE $nick :$cmdmisclg Do not use ACTION or PING CTCPs in that command. Different commands are available for your request." ; return 0}
#	if {[isbotnick [string toupper $person]]} {putquick "NOTICE $nick :$cmdmisclg I will not send any CTCPs to myself. Try to trigger this command to another person." ; return 0}
#	putquick "NOTICE $nick :$cmdmisclg I'm now sending CTCP $rest to: $person." ; putquick "PRIVMSG $person :\001$rest\001"
#	putcmdlog "$cmdmisclg <<$nick>> !$hand! ctcp $person $rest." ; return 0
#}

proc misc_creply {nick uhost hand dest key arg} {
	global botnick cmdmisclg
	if {[isbotnick $nick]} {return 0}
	putquick "NOTICE $nick :$cmdmisclg Your $key reply is: [string toupper $arg]" ; return 0
}

proc msg_mischelp {nick uhost hand rest} {
	global MISCPRM botnick cmdmisclg
	putquick "NOTICE $nick :$cmdmisclg Misc. Commands $cmdmisclg"
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :NOTES:"
	putquick "NOTICE $nick :<> sign means you MUST fill the value."
	putquick "NOTICE $nick :\[\] sign means you can either fill the value or leave it blank."
	putquick "NOTICE $nick :| sign means you MUST choose one between value placed on the left side of | sign, or on the right side."
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :Public (channel) Misc. Commands:"
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :${MISCPRM}ping"
	putquick "NOTICE $nick :${MISCPRM}pong"
	if {[matchattr $hand o]} {
		putquick "NOTICE $nick :${MISCPRM}say <messages>"
		putquick "NOTICE $nick :${MISCPRM}act <actions>"
		putquick "NOTICE $nick :${MISCPRM}msg <nickname/#channel> <messages>"
		putquick "NOTICE $nick :${MISCPRM}notice <nickname/#channel> <messages>"
		putquick "NOTICE $nick :${MISCPRM}ctcp <nickname> <CTCP-KEY>"
	}
	putquick "NOTICE $nick : "
	putquick "NOTICE $nick :${MISCPRM}mischelp"
	putquick "NOTICE $nick :/msg $botnick mischelp"
	putquick "NOTICE $nick : "
	putcmdlog "$cmdmisclg <<$nick>> !$hand! Misc. Commands Help." ; return 0
}

proc pub_mischelp {nick uhost hand chan rest} {global MISCPRM botnick cmdmisclg ; set rest "" ; msg_mischelp $nick $uhost $hand $rest}

# Set this to "1" if you like the script to be loaded.. and set it to "0" to unload.
set cmdmiscloaded 1

if {[info exist cmdmiscloaded]} {
	if {${cmdmiscloaded}} {
		bind pub p|p ${MISCPRM}ping pub_ping
		bind pub p|p ${MISCPRM}pong pub_pong
		bind pub p|p ${MISCPRM}say pub_bilang
		bind pub p|p ${MISCPRM}act pub_aksi
		bind pub o|o ${MISCPRM}ping pub_ping
		bind pub o|o ${MISCPRM}pong pub_pong
		bind pub o|o ${MISCPRM}say pub_bilang
		bind pub o|o ${MISCPRM}act pub_aksi
		bind pub o|o ${MISCPRM}msg pub_peve
		bind pub o|o ${MISCPRM}notice pub_notis
		bind pub o|o ${MISCPRM}ctcp pub_ctcp
		bind ctcr - VERSION misc_creply
		bind ctcr - CLIENTINFO misc_creply
		bind ctcr - TIME misc_creply
		bind ctcr - FINGER misc_creply
		bind pub p|p ${MISCPRM}mischelp pub_mischelp
		bind msg p|p mischelp msg_mischelp
		bind pub o|o ${MISCPRM}mischelp pub_mischelp
		bind msg o|o mischelp msg_mischelp
	} else {
		unbind pub p|p ${MISCPRM}ping pub_ping
		unbind pub p|p ${MISCPRM}pong pub_pong
		unbind pub p|p ${MISCPRM}say pub_bilang
		unbind pub p|p ${MISCPRM}act pub_aksi
		unbind pub o|o ${MISCPRM}ping pub_ping
		unbind pub o|o ${MISCPRM}pong pub_pong
		unbind pub o|o ${MISCPRM}say pub_bilang
		unbind pub o|o ${MISCPRM}act pub_aksi
		unbind pub o|o ${MISCPRM}msg pub_peve
		unbind pub o|o ${MISCPRM}notice pub_notis
		unbind pub o|o ${MISCPRM}ctcp pub_ctcp
		unbind ctcr - VERSION misc_creply
		unbind ctcr - CLIENTINFO misc_creply
		unbind ctcr - TIME misc_creply
		unbind ctcr - FINGER misc_creply
		unbind pub p|p ${MISCPRM}mischelp pub_mischelp
		unbind msg p|p mischelp msg_mischelp
		unbind pub o|o ${MISCPRM}mischelp pub_mischelp
		unbind msg o|o mischelp msg_mischelp
	}
	
}

# End of - Commands & Control, Misc. Commands. (cmd_misc.tcl)
####################################################################################
putlog "*** ${cmdathlg} Commands & Control Allin Loaded."
putlog "*** ${cmdathlg} Joined by Aryo@sepicis.net"
####################################################################################
