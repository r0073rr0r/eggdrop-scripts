##############################################################################################
##  ##        dnsbl.tcl v1.337 for eggdrop by munZe irc.krstarica.com                    ##  ##
##############################################################################################
##############################################################################################
##      ____                __                 ###########################################  ##
##     / __/___ _ ___ _ ___/ /____ ___   ___   ###########################################  ##
##    / _/ / _ `// _ `// _  // __// _ \ / _ \  ###########################################  ##
##   /___/ \_, / \_, / \_,_//_/   \___// .__/  ###########################################  ##
##        /___/ /___/                 /_/      ###########################################  ##
##                                             ###########################################  ##
##############################################################################################
##  ##                             Start Setup.                                         ##  ##
##############################################################################################
package require http
package require tls
http::register https 443 [list ::tls::socket -tls1 1]
namespace eval PIK {
## Podesava nulu sa dve decimale (NE DIRATI)                                                ##
  set NULLA [format "%.2f" 0]
## ako je sadrzaj izlaza > od neke konstante koju definisemo (npr. 60.6) da banuje          ##
  set BanAkoJeVeceOd [format "%.2f" 60.6]
## Kanal na koji ce da siba poruke                                                          ##
  set KanalZaObavestenja "#services"
## ako je sadrzaj izlaza < 0 da ispise da je problem                                        ##
  set ManjeOdNuleNaKanaluIspisuje ""
## Change bantype to the type of ban you want: gzline, zline                                ## 
  set bantype "GLINE"
## Change bantime to the length of ban you want                                             ##
  set bantime "12h"
## Change opernick and operpass to reflect the info from the bots oper block                ## 
## If you already have a oper script, comment out the bind at the bottom of this script     ##
  set opernick opernickhere
  set operpass operpasshere
##############################################################################################
##  ##                           End Setup.                                              ## ##
##############################################################################################

  proc IPlookup {ip} {
    set url "https://pricaonica.krstarica.com/ipcheck.php?ip=$ip"
    set token [ ::http::geturl $url ]
    if {[::http::status $token] == "ok"} {
      set page [ ::http::data $token ]
      set ajdedagamerimo [regexp -all -inline {\d+.\d+} $page]
      if {$ajdedagamerimo <= $PIK::NULLA} { putmsg $PIK::KanalZaObavestenja $PIK::ManjeOdNuleNaKanaluIspisuje }
      if {$ajdedagamerimo >= $PIK::BanAkoJeVeceOd} { putnow "$PIK::bantype *@$a.$b.$c.$d $PIK::bantime :Vasa IP adresa $ip je problematicna" }
    } else { putmsg $PIK::KanalZaObavestenja Error: IPCheck Status: [::http::status $token] }
  }

  proc connection {host type text} {
    if {[string match -nocase {*client connecting*} $text]} {
      #Gets IP
      regexp -- {.*@([^\)]+)} $text null ip
      #Check IP
      PIK::IPlookup $ip
    }
  }
  
  proc operup {type} { 
    putserv "OPER $PIK::opernick $PIK::operpass" 
  }
}
bind raw - NOTICE PIK::connection
## You can comment out the event below if you already have a oper script for this bot.
bind evnt - init-server PIK::operup 