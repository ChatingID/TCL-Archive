##########################################
#
#                                 dns.tcl 
#                              
#                         Created @ 2014
#
# Show the ipv4 and ipv6 result in one command.
#
setudef flag dns
#########################################
bind pub - .dns pub:dns
bind pub - !dns pub:dns
proc pub:dns {nick uhost hand chan arguments} {
 if {![channel get $chan dns]} { return 0 }
 if {$arguments == ""} { return 0 }
 set cmd "nslookup"
 set orig [lindex $arguments 0]
 dnslookup $orig dns:rep $chan $orig
 if {[string match "*:*.*" $orig]} {
  puthelp "PRIVMSG $chan :Invalid ipv6 "
  return
 } elseif {[string match "*.*:*" $orig]} {
  puthelp "PRIVMSG $chan :Invalid ipv6 "
  return
 }
 catch {exec $cmd -type=any $orig} input
 set result ""
 set fnd 0
 foreach line [split $input "\n"] {
  if {[string match "*ip6.\[int|arpa\]*name*=*" $line] || [string match "*IPv6 address*=*" $line]} {
   set result [string trim [lindex [split $line "="] 1]]
   break
  } elseif {[string match "*has AAAA*" $line]} {
   set result [lindex [split $line] [expr [llength [split $line]] - 1]]
   break
  }
 }
 if {$result == ""} {
  puthelp "privmsg $chan :(04Ipv6): Available"
  return
 }
 puthelp "privmsg $chan :(04Ipv6): 12Resolved with $result "
 return
}

proc dns:rep {ip host status chan orig} {
 if {[string match "*:*:*" $ip]} {
   putquick "privmsg $chan :(04Ipv4): Available"
 } elseif {!$status} {
   putquick "privmsg $chan :(04Ipv4): Available"
 } elseif {[regexp -nocase -- $ip $orig]} {
   putquick "privmsg $chan :(04Ipv4): 12Resolved with $host "
 } else {
   putquick "privmsg $chan :(04Ipv4): 12Resolved with $ip "
 }
}
###[ VIEW HOST ]###
bind pub - .host pub:host
bind pub - host pub:host
bind pub - !host pub:host
proc pub:host {nick uhost hand chan arg} {
global hostchan notc
set hostchan "$chan"
if {$arg == ""} {
puthelp "NOTICE $nick :$notc !host <nick>"
return 0
} elseif {[string length $arg] >= "31"} {
puthelp "NOTICE $nick :$notc nama terlalu panjang guys.";
return 0
} else {
putserv "WHOIS [lindex $arg 0]"
bind raw * 311 raw:host
unbind raw * 317 view:user:idle
}
}
proc raw:host {from keyword arguments} {
global hostchan notc
set infonick "[lindex $arguments 1]"
set infoident "[lindex $arguments 2]"
set infohost "[lindex $arguments 3]"
putquick "PRIVMSG $hostchan :!\[4Host\]! $infonick » 6$infoident@$infohost"
unbind raw * 311 raw:host
}

###[ IP LOOKUP ]###
set whoisinfo(trigger) ".ip"
set whoisinfo(port) 43
set whoisinfo(ripe) "whois.ripe.net"
set whoisinfo(arin) "whois.arin.net"
set whoisinfo(apnic) "whois.apnic.net"
set whoisinfo(lacnic) "whois.lacnic.net"
set whoisinfo(afrinic) "whois.afrinic.net"
bind pub - $whoisinfo(trigger) pub_whoisinfo
proc whoisinfo_setarray {} {
global query
set query(netname) "(none)"
set query(country) "(none)"
set query(orgname) "(none)"
set query(orgid) "(none)"
set query(range) "(none)"
}
proc whoisinfo_display { chan } {
global query notc
puthelp "PRIVMSG $chan ::\[4R\]: $query(range)"
puthelp "PRIVMSG $chan ::\[4N\]: $query(netname)"
puthelp "PRIVMSG $chan ::\[4O\]: $query(orgname)"
puthelp "PRIVMSG $chan ::\[4C\]: $query(country)"
}

proc pub_whoisinfo {nick uhost handle chan search} {
global whoisinfo
global notc
global query
whoisinfo_setarray 
if {[whoisinfo_whois $whoisinfo(arin) $search]==1} {
if {[string compare [string toupper $query(orgid)] "RIPE"]==0} {
if {[whoisinfo_whois $whoisinfo(ripe) $search]==1} {
whoisinfo_display $chan
}
 } elseif {[string compare [string toupper $query(orgid)] "APNIC"]==0} {
if {[whoisinfo_whois $whoisinfo(apnic) $search]==1} {
whoisinfo_display $chan
}
 } elseif {[string compare [string toupper $query(orgid)] "LACNIC"]==0} {
if {[whoisinfo_whois $whoisinfo(lacnic) $search]==1} {
whoisinfo_display $chan
}
 } elseif {[string compare [string toupper $query(orgid)] "AFRINIC"]==0} {
if {[whoisinfo_whois $whoisinfo(afrinic) $search]==1} {
whoisinfo_display $chan
}
 } else {
whoisinfo_display $chan
}
} else {
if { [info exist query(firstline)] } {
puthelp "PRIVMSG $chan :$query(firstline)"
} else {
puthelp "NOTICE $nick :$notc terjadi kesalahan."
}
}
}

proc whoisinfo_whois {server search} {
global whoisinfo
global query
set desccount 0
set firstline 0
set reply 0
putlog "Whois: $server:$whoisinfo(port) -> $search"
if {[catch {set sock [socket -async $server $whoisinfo(port)]} sockerr]} {
puthelp "NOTICE $nick :$notc error '$sockerr'. silahkan coba lagi."
close $sock
return 0
}
puts $sock $search
flush $sock
while {[gets $sock whoisline]>=0} {
putlog "Whois: $whoisline"
if {[string index $whoisline 0]!="#" && [string index $whoisline 0]!="%" && $firstline==0} {
if {[string trim $whoisline]!=""} {
set query(firstline) [string trim $whoisline]
set firstline 1
}
}
if {[regexp -nocase {netname:(.*)} $whoisline all item]} {
set query(netname) [string trim $item]
set reply 1
} elseif {[regexp -nocase {owner-c:(.*)} $whoisline all item]} {
set query(netname) [string trim $item]
set reply 1 
} elseif {[regexp -nocase {country:(.*)} $whoisline all item]} {
set query(country) [string trim $item]
set reply 1
} elseif {[regexp -nocase {descr:(.*)} $whoisline all item] && $desccount==0} {
set query(orgname) [string trim $item]
set desccount 1
set reply 1
} elseif {[regexp -nocase {orgname:(.*)} $whoisline all item]} {
set query(orgname) [string trim $item]
set reply 1
} elseif {[regexp -nocase {owner:(.*)} $whoisline all item]} {
set query(orgname) [string trim $item]
set reply 1
} elseif {[regexp -nocase {orgid:(.*)} $whoisline all item]} {
set query(orgid) [string trim $item]
set reply 1
} elseif {[regexp -nocase {inetnum:(.*)} $whoisline all item]} {
set query(range) [string trim $item]
set reply 1
} elseif {[regexp -nocase {netrange:(.*)} $whoisline all item]} {
set query(range) [string trim $item]
set reply 1
}
}
close $sock
return $reply
}
putlog "+++ Maqiecious - IP LookUp Loaded..."

###[ CHECK OS ]###
bind pub - !os oscheck
bind pub - .os oscheck
proc oscheck {nick host handle chan text} {
set server [lindex $text 0]
set port 80
set x 1
set sock [socket $server $port]
puts $sock "GET / HTTP/1.0"
puts $sock "User.Agent:Mozilla"
puts $sock "Host: $server"
puts $sock ""
flush $sock
while {$x < 10} {
gets $sock line
if {[string match "*erver: *" $line]} {
putserv "PRIVMSG $chan :!\[4Os\]! $line"
}
if {[string match "*ate: *" $line]} {
putserv "PRIVMSG $chan :!\[4Os\]! $line"
}
incr x
}
close $sock
}
putlog "+++ Maqiecious - OS Check Loaded..."

###[ PORT CHECK ]###
set portc(flag) "-"
set portc(read) 1
bind pub $portc(flag) !port portscanpub
bind pub $portc(flag) port portscanpub
bind pub $portc(flag) .port portscanpub
bind msg $portc(flag) !port portscanmsg
bind msg $portc(flag) port portscanmsg
bind msg $portc(flag) .port portscanmsg
setudef flag portc
proc portscanpub {nick uhost hand chan text} {
global portc notc
set host [lindex [split $text] 0]
set port [lindex [split $text] 1]
if {$port == ""} {
putquick "NOTICE $nick :$notc !port <host> <port>"
} else {
if {[catch {set sock [socket -async $host $port]} error]} {
putquick "PRIVMSG $chan :!\[4Port\]! host: 6$host port: 6$port 12> 7Refushed!"
} else {
set timerid [utimer 15 [list porttimeoutpub $chan $sock $host $port]]
fileevent $sock writable [list portconnectedpub $chan $sock $host $port $timerid]
}
}
}
proc portconnectedpub {chan sock host port timerid} {
killutimer $timerid
set error [fconfigure $sock -error]
if {$error != ""} {
close $sock
putquick "PRIVMSG $chan :!\[4Port\]! host: 6$host port: 6$port 12> 4[string totitle $error]!"
} else {
fileevent $sock writable {}
fileevent $sock readable [list portreadpub $chan $sock $host $port]
putquick "PRIVMSG $chan :!\[4Port\]! host: 6$host port: 6$port 12> 3Accepted!"
}
}
proc porttimeoutpub {chan sock host port} {
close $sock
putquick "PRIVMSG $chan :!\[4Port\]! host: 6$host port: 6$port 12> 4Timed Out!"
}
proc portreadpub {sock} {
global portc
if {!$portc(read)} {
close $sock
} elseif {[gets $sock read] == -1} {
putquick "PRIVMSG $chan :!\[4Port\]! host: 14$host port: 14$port 12? 7Socket Closed!"
close $sock
}
}
proc portscanmsg {nick uhost hand text} {
global portc notc
set host [lindex [split $text] 0]
set port [lindex [split $text] 1]
if {$port == ""} {
putquick "NOTICE $nick :$notc !port <host> <port>"
} else {
if {[catch {set sock [socket -async $host $port]} error]} {
putquick "PRIVMSG $nick :!\[4Port\]! host: 14$host port: 14$port 12? 12Refushed!"
} else {
set timerid [utimer 15 [list porttimeoutmsg $nick $sock $host $port]]
fileevent $sock writable [list portconnectedmsg $nick $sock $host $port $timerid]
}
}
}
proc portconnectedmsg {nick sock host port timerid} {
killutimer $timerid
set error [fconfigure $sock -error]
if {$error != ""} {
close $sock
putquick "PRIVMSG $nick :!\[4Port\]! host: 14$host port: 14$port 12? 4[string totitle $error]!"
} else {
fileevent $sock writable {}
fileevent $sock readable [list portreadmsg $nick $sock $host $port]
putquick "PRIVMSG $nick :!\[4Port\]! host: 14$host port: 14$port 12? 3Accepted!"
}
}
proc porttimeoutmsg {nick sock host port} {
close $sock
putquick "PRIVMSG $nick :!\[4Port\]! host: 14$host port: 14$port 12? 4Timed Out!"
}
proc portreadmsg {sock} {
global portc
if {!$portc(read)} {
close $sock
} elseif {[gets $sock read] == -1} {
putquick "PRIVMSG $nick :!\[4Port\]! host: 14$host port: 14$port 12? 7Socket Closed!"
close $sock
}
}
###[  WHOIS NICK  ]###
bind pub - .whois whois:nick
#bind pub - !whois whois:nick
proc whois:nick { nickname hostname handle channel arguments } {
global whois notc
set target [lindex [split $arguments] 0]
if {$target == ""} {
putquick "NOTICE $nickname :$notc !whois <nick>"
return 0
}
if {[string length $target] >= "31"} {
putquick "NOTICE $nickname :$notc nama terlalu panjang guys."; return
}
putquick "WHOIS $target $target"
set ::whoischannel $channel
set ::whoistarget $target
bind RAW - 401 whois:nosuch
bind RAW - 311 whois:info
bind RAW - 319 whois:channels
#bind RAW - 301 whois:away
bind RAW - 313 whois:ircop
bind RAW - 330 whois:auth
bind RAW - 317 whois:idle
}
proc whois:putmsg { channel arguments } {
putquick "PRIVMSG $channel :$arguments"
}
proc whois:info { from keyword arguments } {
set channel $::whoischannel
set nickname [lindex [split $arguments] 1]
set ident [lindex [split $arguments] 2]
set host [lindex [split $arguments] 3]
set realname [string range [join [lrange $arguments 5 end]] 1 end]
whois:putmsg $channel "$nickname is $ident@$host * $realname"
unbind RAW - 311 whois:info
}
proc whois:ircop { from keyword arguments } {
set channel $::whoischannel
set target $::whoistarget
whois:putmsg $channel "$target is an IRC Operator"
unbind RAW - 313 whois:ircop
}
proc whois:away { from keyword arguments } {
set channel $::whoischannel
set target $::whoistarget
set awaymessage [string range [join [lrange $arguments 2 end]] 1 end]
whois:putmsg $channel "$target is away: $awaymessage"
unbind RAW - 301 whois:away
}
proc whois:channels { from keyword arguments } {
set channel $::whoischannel
set channels [string range [join [lrange $arguments 2 end]] 1 end]
set target $::whoistarget
whois:putmsg $channel "$target on $channels"
unbind RAW - 319 whois:channels
}
proc whois:auth { from keyword arguments } {
set channel $::whoischannel
set target $::whoistarget
set authname [lindex [split $arguments] 2]
whois:putmsg $channel "$target was logged as $authname"
unbind RAW - 330 whois:auth
}
proc whois:nosuch { from keyword arguments } {
set channel $::whoischannel
set target $::whoistarget
# whois:putmsg $channel "$target no such nickname"
unbind RAW - 401 whois:nosuch
}
proc whois:idle { from keyword arguments } {
set channel $::whoischannel
set target $::whoistarget
set idletime [lindex [split $arguments] 2]
set signon [lindex [split $arguments] 3]
whois:putmsg $channel "$target has been idle for [duration $idletime]. signon time [ctime $signon]"
unbind RAW - 317 whois:idle
}

###[  WIB TIME  ]###
set shelltime_setting(flag) "-|-"
set shelltime_setting(cmd) "time"
set shelltime_setting(pubcmd) "*jam*"
set shelltime_setting(pubcmds) "*tanggal*"
set shelltime_setting(format) "%I:%M:%S %p"
set shelltime_setting(formats) "%A, %d %B %Y"
set shelltime_setting(bold) 1
set shelltime_setting(SHELLTIME:) 1

####################
# Code begins here #
####################

if {$numversion < 1060800} { putlog "\002SHELLTIME:\002 \002WARNING:\002 This script is intended to run on eggdrop 1.6.8 or later." }
if {[info tclversion] < 8.2} { putlog "\002SHELLTIME:\002 \002WARNING:\002 This script is intended to run on Tcl Version 8.2 or later." }

bind dcc $shelltime_setting(flag) $shelltime_setting(cmd) shelltime_dcc
bind pubm $shelltime_setting(flag) $shelltime_setting(pubcmd) shelltime_pub
bind pubm $shelltime_setting(flag) $shelltime_setting(pubcmds) shelltime_pubs

proc shelltime_dopre {} {
	global shelltime_setting
	if {!$shelltime_setting(SHELLTIME:)} { return "" }
	if {!$shelltime_setting(bold)} { return "SHELLTIME: " }
	return "\002SHELLTIME:\002 "
}
proc shelltime_dcc {hand idx text} {
	global shelltime_setting
	putdcc $idx "[shelltime_dopre][clock format [clock seconds] -format $shelltime_setting(format)]"
}
proc shelltime_pub {nick uhost hand chan text} {
	if {[string match *cbot* [string tolower $text]]} {
	global shelltime_setting
	puthelp "PRIVMSG $chan :[clock format [clock seconds] -timezone :Asia/Jakarta -format $shelltime_setting(format)] WIB"
	}
}
proc shelltime_pubs {nick uhost hand chan text} {
	if {[string match *cbot* [string tolower $text]]} {
	global shelltime_setting
	puthelp "PRIVMSG $chan :[clock format [clock seconds] -timezone :Asia/Jakarta -format $shelltime_setting(formats)]"
	}
}
putlog "\002SHELLTIME:\002 ShellTime.tcl 1.6 by wonk_santai is loaded."

###[ VERSION ]###
bind pub - !version versinick
bind pub - !versi versinick
bind pub - .version versinick
bind pub - .versi versinick
proc versinick {nick uhost hand chan rest} {
global versinick versichan
bind ctcr - VERSION versireply
bind notc - VERSION* versireplynotc
set rest [lindex $rest 0]
set versinick 0
set versichan $chan
putquick "PRIVMSG $rest :\001VERSION\001"
return 0
}
proc versireply {nick uhost hand dest key args} {
global versichan versinick
unbind ctcr - VERSION versireply
unbind notc - VERSION* versireplynotc
set versiresult [lindex $args 0]
putquick "PRIVMSG $versichan :!\[4Versi\]! $nick 12» 6$versiresult"
}

######### whoisd.tcl -- 1.2 ######
### Settings
set whoisd(cmd_dcc_domain) "whoisd"; #the dcc command - eg: .whoisd <domain>
set whoisd(cmd_dcc_tld) "tld"; #the dcc tld command - eg: .tld <tld>
set whoisd(cmd_pub_domain) ".domain"; #the pub command - eg: .whois <domain>
set whoisd(cmd_pub_tld) ".tld"; #the pub tld command - eg: .tld <tld>
set whoisd(data_country) "";#place holder for country data
set whoisd(data_type) "domain"; #default data type
set whoisd(debug) 1; #turn debug on or off
set whoisd(error_connect) "Error: Connection to %s:%s failed."; #Connection failed
set whoisd(error_connect_lost) "Error: Connection to server has been lost.";
set whoisd(error_invalid) "Error: Invalid %s."; #Invalid domain/tld error
set whoisd(flag) "-|-"; #flag required to use the script
set whoisd(nomatch_domain) "No match|not found|Invalid query|does not exist|no data found|status:         avail|domain is available|(null)|no entries found|not registered|no objects found|domain name is not|Status:.*AVAILABLE"; #Replies from Whois Servers that match as "Available"... #TODO: split into new lines, join again later
set whoisd(nomatch_tld) "This query returned 0 objects."; #Error returned for invalid tld
set whoisd(notice_connect) "Connecting to... %s:%s (%s)"; #Connecting notice
set whoisd(output_country) "Country for %s is %s";
set whoisd(output_found) "%s is available!";
set whoisd(output_nomatch) "%s is taken!";
set whoisd(output_timeout) "Connection to %s:%s timed out within %s seconds.";
set whoisd(port) 43; #The default whois server port - should not change
set whoisd(prefix) "Domain:"; #prefix on output
set whoisd(regex_country) {address.*?:\s*(.+)$};
set whoisd(regex_contact) {contact.*?:\s*(.+)$};
set whoisd(regex_server) {whois.*?:\s*(.+)$};
set whoisd(regex_valid_domain) {^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$}; #Regular expression used for validating domains
set whoisd(regex_valid_tld) {^\.?[a-z]+$};
set whoisd(rplmode) 1; #reply mode (1:chan privmsg, 2:chan notice, 3:nick privmsg, 4:nick notice)
set whoisd(server) "whois.iana.org"; #The main whois server - should not change
set whoisd(timeout) 15; #server timeout in seconds - servers are quick, keep low 
set whoisd(usage) "Usage: %s <%s>"; #Usage
set whoisd(ver) "1.1"; # version

### Package Definition
package require eggdrop 1.6;  #see http://geteggdrop.com/
package require Tcl 8.2.3;    #see http://tinyurl.com/6kvu2n

### Binds
bind dcc $whoisd(flag) $whoisd(cmd_dcc_domain) whoisd:dcc_domain;
bind pub $whoisd(flag) $whoisd(cmd_pub_domain) whoisd:pub_domain;
bind dcc $whoisd(flag) $whoisd(cmd_dcc_tld) whoisd:dcc_tld;
bind pub $whoisd(flag) $whoisd(cmd_pub_tld) whoisd:pub_tld;

### Procedures
proc whoisd:validate {cmd word} {
	if {[string compare $word ""] == 0} {
    return [format $::whoisd(usage) $cmd $::whoisd(data_type)];    
  }
	if {![regexp $::whoisd(regex_valid) $word]} {
    return [format $::whoisd(error_invalid) $::whoisd(data_type)];
  }
  return;
}
proc whoisd:dcc_domain {hand idx text} {
  set ::whoisd(data_type) "domain";
  set ::whoisd(cmd_dcc) $::whoisd(cmd_dcc_domain);
  set ::whoisd(regex_valid) $::whoisd(regex_valid_domain);
	return [whoisd:dcc $hand $idx $text];
}
proc whoisd:pub_domain {nick uhost hand chan text} {
  set ::whoisd(data_type) "domain";
  set ::whoisd(cmd_pub) $::whoisd(cmd_pub_domain);
  set ::whoisd(regex_valid) $::whoisd(regex_valid_domain);
	return [whoisd:pub $nick $uhost $hand $chan $text];
}
proc whoisd:dcc_tld {hand idx text} {
  set ::whoisd(data_type) "tld";
  set ::whoisd(cmd_dcc) $::whoisd(cmd_dcc_tld);
  set ::whoisd(regex_valid) $::whoisd(regex_valid_tld);
	return [whoisd:dcc $hand $idx $text];
}
proc whoisd:pub_tld {nick uhost hand chan text} {
  set ::whoisd(data_type) "tld";
  set ::whoisd(cmd_pub) $::whoisd(cmd_pub_tld);
  set ::whoisd(regex_valid) $::whoisd(regex_valid_tld);
  return [whoisd:pub $nick $uhost $hand $chan $text];
}
proc whoisd:dcc {hand idx text} {
  set word [lrange [split $text] 0 0];
  if {[set invalid [whoisd:validate ".$::whoisd(cmd_dcc)" $word]] != ""} {
    whoisd:out 0 $idx {} $invalid;
    return;
  }
	whoisd:connect 0 $idx {} $::whoisd(server) $::whoisd(port) $word;
}
proc whoisd:pub {nick uhost hand chan text} {
  set word [lrange [split $text] 0 0];
  if {[set invalid [whoisd:validate $::whoisd(cmd_pub) $word]] != ""} {
    whoisd:out 4 {} $nick $invalid;
    return;
  }
	whoisd:connect $::whoisd(rplmode) $chan $nick $::whoisd(server) $::whoisd(port) $word;
}

proc whoisd:out {type dest nick text} {
	if {[string length [string trim $text]] < 1} { return; }
	if {[string match "*avail*" [string tolower $text]]} {
		set clr "3"
	   } else {
		set clr "14"
        }
	switch -- $type {
	  "0" { putdcc $dest "$::whoisd(prefix) $text"; }
		"1" { putserv "PRIVMSG $dest :$::whoisd(prefix)$clr $text"; }
		"2" { putserv "NOTICE $dest :$::whoisd(prefix)$clr $text"; }
		"3" { putserv "PRIVMSG $nick :$::whoisd(prefix)$clr $text"; }
		"4" { putserv "NOTICE $nick :$::whoisd(prefix)$clr $text"; }
		"5" { putlog "$::whoisd(prefix) $text"; }
	}
}
proc whoisd:connect {type dest nick server port word} {
  set whoisd(data_country) "";
  putlog [format $::whoisd(notice_connect) $server $port $word];
	if {[catch {socket -async $server $port} sock]} {
    whoisd:out $type $dest $nick [format $::whoisd(error_connect) $server $port];
    return;
  }
	#TODO: too long; must be split
  fileevent $sock writable [list whoisd:write $type $dest $nick $word $sock $server $port [utimer $::whoisd(timeout) [list whoisd:timeout $type $dest $nick $server $port $sock $word]]];
}
proc whoisd:write {type dest nick word sock server port timerid} {
	if {[set error [fconfigure $sock -error]] != ""} {
		whoisd:out $type $dest $nick [format $::whoisd(error_connect) $server $port];
		whoisd:die $sock $timerid;
		return;
	}
  set word [string trim $word .];
	if {$server == $::whoisd(server)} {
    set lookup [lrange [split $word "."] end end];
  } else {
    set lookup $word;
  }
	puts $sock "$lookup\n";
	flush $sock;
	fconfigure $sock -blocking 0;
	fileevent $sock readable [list whoisd:read $type $dest $nick $word $sock $server $port $timerid];
	fileevent $sock writable {};
}
proc whoisd:read {type dest nick word sock server port timerid} {
	while {![set error [catch {gets $sock output} read]] && $read > 0} {
    if {!$type} { whoisd:out $type $dest $nick $output; }
		if {$server == $::whoisd(server)} {
			if {[regexp $::whoisd(nomatch_tld) $output]} {
				set output [format $::whoisd(error_invalid) "tld"];
				whoisd:out $type $dest $nick $output;
				whoisd:die $sock $timerid;
			}
			if {$::whoisd(data_type) == "tld"} {
				if {[regexp $::whoisd(regex_country) $output -> country]} {
          set ::whoisd(data_country) $country;
				}
				if {[regexp $::whoisd(regex_contact) $output -> contact]} {
          #set ::whoisd(data_contact) $contact;
          whoisd:timeout $type $dest $nick $server $port $sock $word;
  				whoisd:die $sock $timerid;
				}
			} elseif {[regexp -nocase -- $::whoisd(regex_server) $output -> server]} {
        whoisd:connect $type $dest $nick $server $port $word;
        whoisd:die $sock $timerid;
  		}
		} else {
			if {[regexp -nocase -- $::whoisd(nomatch_domain) $output]} { 
				set output [format $::whoisd(output_found) $word];
        whoisd:out $type $dest $nick $output;
				whoisd:die $sock $timerid;
			}
		}
	if {$error} {
		whoisd:out $type $dest $nick $::whoisd(error_connect_lost);
		whoisd:die $sock $timerid;
	}
 }
}
proc whoisd:die {sock timerid} {
  catch { killutimer $timerid }
	catch { close $sock }
}
proc whoisd:timeout {type dest nick server port sock word} {
	catch { close $sock }
	if {$server != $::whoisd(server)} {
    set output [format $::whoisd(output_nomatch) $word];
    whoisd:out $type $dest $nick $output;
    return;
  } elseif {$::whoisd(data_country) != ""} {
    set output [format $::whoisd(output_country) $word $::whoisd(data_country)];
  } else {
    set output [format $::whoisd(output_timeout) $server $port $::whoisd(timeout)];
  }
  whoisd:out $type $dest $nick $output;
}

###### Whois Domain Tools ###############

### Loaded
putlog "whoisd.tcl $whoisd(ver) loaded";

#EOF










