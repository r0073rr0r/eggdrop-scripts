# Horoskop v1.337
# Veci deo koda pisao: tik-tak,
# a kod preradio i modifikovao za eggdrop: munZe
# Skriptu mozete naci na Hawkee sa svezim updateovima
# na adresi http://www.hawkee.com/snippet/9379/
#
# Komande su: !horoskop - !dnevni - !nedeljni - !mesecni - !ljubavni
#
# !horoskop je isto sto i !dnevni ;-)
#
# Posetite nas na kanalu #entrance @ irc.krstarica.com
#
# Veliki pozdrav za sve koji su prijavljivali bugove
# i pomagali razvijanju ovog snippeta ;)
# I naravno, sajtu sa koga se sve svlaci http://www.astrolook.com/
#
# MyH3e KoH3a MaToPu !!!

# -= Podesavanja =-

# Ako je saljina 1 skripta salje horoskop NA KANAL
# saljina 2 - ide korisniku na PVT
# saljina 3 - ide korisniku na NOTICE

set saljina 1

# Skripta pocinje ...
# Pozeljno je da NE DIRATE nista ispod osim ako
# NE ZNATE STA RADITE! ;-)

bind pub - !horoskop pub_horoskop
bind pub - !dnevni pub_horoskop
bind pub - !nedeljni pub_nedeljni
bind pub - !mesecni pub_mesecni
bind pub - !ljubavni pub_ljubavni
package require http

#Dnevni horoskop

proc pub_horoskop {nick host hand channel sign} {

set salji [

    global saljina

    if {$saljina==1} { set salji "PRIVMSG $channel" 
    } elseif {$saljina==2} { set salji "PRIVMSG $nick" 
    } else { set salji "NOTICE $nick" }

]
  set url "http://www.astrolook.com/dnevni.shtml"
  set token [ ::http::geturl $url ]
  set page [ ::http::data $token ]

  set znaci [ 
regexp -all -inline {<font class="hheader">([^\n\r]*?)</font><BR>
<font class="htext">
<!-pocetak-->
(.*?)
<!-kraj-->
} $page 
]

if { [lsearch $znaci [string toupper $sign]] >= 0 && $sign != "" && $sign != "skorpija"} {
putserv "$salji \002Dnevni horoskop za \037$sign\037:\002 [ lindex $znaci [expr [lsearch $znaci [string toupper $sign]] + 1] ]" 
} elseif {$sign == "skorpija"} { putserv "$salji \002Dnevni horoskop za \037skorpija\037:\002 [ lindex $znaci [expr [lsearch $znaci [string toupper *korpija]] + 1] ]" 
} elseif {$sign == ""} { putserv "$salji \002Niste odredili znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002" 
} else { putserv "$salji \002Niste odredili adekvatan horoskopski znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002" }

}

#Nedeljni horoskop

proc pub_nedeljni {nick host hand channel sign} {
set salji [

    global saljina

    if {$saljina==1} { set salji "PRIVMSG $channel" 
    } elseif {$saljina==2} { set salji "PRIVMSG $nick" 
    } else { set salji "NOTICE $nick" }

]
  set url "http://www.astrolook.com/sedmicni.shtml"
  set token [ ::http::geturl $url ]
  set page [ ::http::data $token ]

  set znaci [ 
regexp -all -inline {<font class="hheader">([^\n\r]*?)</font><BR>
<font class="htext">
<!-pocetak-->
(.*?)
<!-kraj-->
} $page 
]
if { [lsearch $znaci [string toupper $sign]] >= 0 && $sign != "" && $sign != "skorpija"} {

putserv "$salji \002Nedeljni horoskop za \037$sign\037:\002" 
set text [ lindex $znaci [expr [lsearch $znaci [string toupper $sign]] + 1] ]
set msgs [ regexp -all -inline {.{1,250}[^ ]* *} $text ]
foreach msg $msgs { 
 putserv "$salji $msg" 
after 1000 set end 1
vwait end
}
 } elseif {$sign == "skorpija"} { 
putserv "$salji \002Nedeljni horoskop za \037$sign\037:\002" 
set text [ lindex $znaci [expr [lsearch $znaci [string toupper *korpija]] + 1] ]
set msgs [ regexp -all -inline {.{1,250}[^ ]* *} $text ]
foreach msg $msgs { 
 putserv "$salji $msg" 
after 1000 set end 1
vwait end
}
} elseif {$sign == ""} { putserv "$salji \002Niste odredili znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002"
} else { putserv "$salji \002Niste odredili adekvatan horoskopski znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002" }
}

#Mesecni horoskop

proc pub_mesecni {nick host hand channel sign} {
set salji [

    global saljina

    if {$saljina==1} { set salji "PRIVMSG $channel" 
    } elseif {$saljina==2} { set salji "PRIVMSG $nick" 
    } else { set salji "NOTICE $nick" }

]
  set url "http://www.astrolook.com/mesecni.shtml"
  set token [ ::http::geturl $url ]
  set page [ ::http::data $token ]

  set znaci [ 
regexp -all -inline {<font class="hheader">([^\n\r]*?)</font><BR>
<font class="htext">
<!-pocetak-->
(.*?)
<!-kraj-->
} $page 
]
if { [lsearch $znaci [string toupper $sign]] >= 0 && $sign != "" && $sign != "skorpija"} {

putserv "$salji \002Mesecni horoskop za \037$sign\037:\002" 
set text [ lindex $znaci [expr [lsearch $znaci [string toupper $sign]] + 1] ]
regsub -all "\n" $text { } text
set msgs [ regexp -all -inline {.{1,250}[^ ]* *} $text ]
foreach msg $msgs { 
 putserv "$salji $msg" 
after 1000 set end 1
vwait end
}
 } elseif {$sign == "skorpija"} { 
putserv "$salji \002Mesecni horoskop za \037$sign\037:\002" 
set text [ lindex $znaci [expr [lsearch $znaci [string toupper *korpija]] + 1] ]
set msgs [ regexp -all -inline {.{1,250}[^ ]* *} $text ]
foreach msg $msgs { 
 putserv "$salji $msg" 
after 1000 set end 1
vwait end
}
} elseif {$sign == ""} { putserv "$salji \002Niste odredili znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002"
} else { putserv "$salji \002Niste odredili adekvatan horoskopski znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002" }
}

#Ljubavni horoskop

proc pub_ljubavni {nick host hand channel sign} {
set salji [
    global saljina
    if {$saljina==1} { set salji "PRIVMSG $channel" 
    } elseif {$saljina==2} { set salji "PRIVMSG $nick" 
    } else { set salji "NOTICE $nick" }
]
  set url "http://www.astrolook.com/ljubavni.shtml"
  set token [ ::http::geturl $url ]
  set page [ ::http::data $token ]

  set znaci [ 
regexp -all -inline {<font class="hheader">([^\n\r]*?)</font><BR>
<font class="htext">
<!-pocetak-->
(.*?)
<!-kraj-->
} $page 
]
if { [lsearch $znaci [string toupper $sign]] >= 0 && $sign != "" && $sign != "skorpija"} {

putserv "$salji \002Ljubavni horoskop za \037$sign\037:\002" 
set text [ lindex $znaci [expr [lsearch $znaci [string toupper $sign]] + 1] ]
regsub -all "\n" $text { } text
set msgs [ regexp -all -inline {.{1,250}[^ ]* *} $text ]
foreach msg $msgs { 
 putserv "$salji $msg" 
after 1000 set end 1
vwait end
}
 } elseif {$sign == "skorpija"} { 
putserv "$salji \002Ljubavni horoskop za \037$sign\037:\002" 
set text [ lindex $znaci [expr [lsearch $znaci [string toupper *korpija]] + 1] ]
set msgs [ regexp -all -inline {.{1,250}[^ ]* *} $text ]
foreach msg $msgs { 
 putserv "$salji $msg" 
after 1000 set end 1
vwait end
}
} elseif {$sign == ""} { putserv "$salji \002Niste odredili znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002"
} else { putserv "$salji \002Niste odredili adekvatan horoskopski znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002" }
}
putlog "Horoskop ucitan..."
