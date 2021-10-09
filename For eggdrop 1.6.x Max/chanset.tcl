############################

bind pub n !set pub:sets

proc pub:sets {nick uhost hand chan arg} {
global botnick
  if {$arg == ""} { 
    puthelp "PRIVMSG $chan :Syntax: !set <#channel> <mode>"
  }
  if {[string match "*#*" [lindex $arg 0]]} {
    set tgrchan [lindex $arg 0]
    set flag [lindex $arg 1]
    channel set $tgrchan $flag
    putquick "NOTICE $nick :Set $flag for $tgrchan"
  } else {
    set flag [lindex $arg 0] 
    channel set $chan $flag
    putquick "NOTICE $nick :Set $flag for $chan" 
  }
  if {[string match "-cerewet" [lindex $arg 0]]} {
      puthelp "PRIVMSG $chan :Iya deh $botnick diem"
  }
  if {[string match "+cerewet" [lindex $arg 0]]} {
      puthelp "PRIVMSG $chan :yes siap cewewet $nick!!!"
  }
}
