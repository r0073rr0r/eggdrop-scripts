bind pub - !vreme pub_vreme

package require http

proc pub_vreme {nick host hand channel grad} {
set gradovi "Beograd, Pristina, Crni-Vrh, Kikinda, Negotin, Sjenica, Valjevo, Krusevac, Pancevo, Kragujevac, Novi-Sad, Kopaonik, Dimitrovgrad, Kraljevo, Palic, Smederevo, Zrenjanin, Vrsac, Cacak, Subotica, Nis, Vranje, Loznica, Leskova, Ruma, Sremska-Mitrovica, Zlatibor, Knjazevac, Uzice"
if {$grad != "" && [string match *$grad* $gradovi ] == 1} {
set url "http://www.blic.rs/vremenska-prognoza/$grad"
  set token [ ::http::geturl $url ]
  set page [ ::http::data $token ]
  set vreme [ regexp -all -inline {<table class="weather_now" border="0" cellpadding="0" cellspacing="0">.*?</table>} $page ]
  regsub -all {&#176;} $vreme "°" vreme
  regsub -all -- {\}} $vreme {} vreme
regsub -all -- {\{} $vreme {} vreme
regsub -all "\[\t\n\]" $vreme { } vreme
  set vreme [ split [ string trim [ regsub {Trenutno merenje} [ regsub -all {<.*?>} $vreme "" ] {} ] "\n" ] "\n" ]
  set vreme [ regsub -all {Pritisak} $vreme "- \002Pritisak\002" ]
  set vreme [ regsub -all {Vetar} $vreme "- \002Vetar\002" ]
  set vreme [ regsub -all {Vla.nost vazduha} $vreme "- \002Vlaznost vazduha\002" ]
  set vreme [ regsub -all {Vidljivost} $vreme "- \002Vidljivost\002" ]
  set vreme [ regsub -all {UV index} $vreme "\002UV index\002" ]

  foreach msg $vreme {
        putnotc $nick "[encoding convertto utf-8 $msg]"
        after 1000 set end 1
        vwait end
}
} elseif {$grad == "" || [string match *$grad* $gradovi ] != 1} {
putnotc $nick "\002Niste odabrali grad!\002 Koristite komandu \002!vreme <grad>\002"
putnotc $nick "\002Dostupni gradovi:\002 Beograd, Pristina, Crni-Vrh, Kikinda, Negotin, Sjenica, Valjevo, Krusevac, Pancevo, Kragujevac, Novi-Sad, Kopaonik, Dimitrovgrad, Kraljevo, Palic, Smederevo, Zrenjanin, Vrsac, Cacak, Subotica, Nis, Vranje, Loznica, Leskova, Ruma, Sremska-Mitrovica, Zlatibor, Knjazevac, Uzice"
}
}
