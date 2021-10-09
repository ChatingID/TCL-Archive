###########################################
# auth.tcl   
# Published by lou:
#  lou (lou@quakenet.org)      
# Taken from:       
#  velvet (velvet@quakenet.org)
# Channels:
#  #dmm on tiscali.dk.quakenet.org
#  #bygames on blueyonder.uk.quakenet.org
# Version 1.0
###########################################
# Install:
#  Change the settings.
#  Put the script in your eggdrop/scripts
# directory and add to your eggdrop.conf
# the line:
#  source scripts/auth.tcl   
###########################################

set Qauth "???" ; # Q auth username
set Qpass "???" ; # Q auth password
set Qhost "TheQBot@CServe.quakenet.org" ; # Q ident@hostmark

bind raw - 311 raw:qauth

proc raw:qauth {from keyword args} {
 global Qauth Qpass Qhost
 set args [string tolower [join $args]]
 set nick [lindex $args 1]
 set host "[lindex $args 2]@[lindex $args 3]"
 if {$host == [string tolower $Qhost]} {
  puthelp "PRIVMSG Q@CServe.quakenet.org :AUTH $Qauth $Qpass"
 }
}

bind join - * hnd:join

proc hnd:join {nick uhost hand chan} {
 global botnick
 set host [string trimleft [string tolower [getchanhost $nick $chan]] ~]
 if {$host == [string trimleft [string tolower [getchanhost $botnick $chan]] ~] || $nick == "Q"} {
  putserv "WHOIS Q"
 }
}

putlog "auth v1.0 loaded"

###########################################