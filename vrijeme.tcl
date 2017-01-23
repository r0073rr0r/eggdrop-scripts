bind pub - !vrijeme pub_vrijeme

package require http

proc pub_vrijeme {nick host hand channel grad} {

if {$grad == "Banja Luka"} { set grad "banja-luka" } 

set gradovi "banja-luka, bihac, bijeljina, brcko, jahorina, mostar, neum, sarajevo, trebinje, tuzla, visegrad"

set grad [string tolower $grad]

if {$grad != "" && [string match *$grad* $gradovi ] == 1} {
set url "http://www.prognozavremena.info/vremenska-prognoza-$grad/"
  set token [ ::http::geturl $url ]
  set page [ ::http::data $token ]
  set vreme [ regexp -all -inline {<div class="wp-forecast-curr">.*?<a href="http://www.accuweather.com">} $page ]
  regsub -all {</div>} $vreme " " vreme
  regsub -all {&deg;} $vreme "°" vreme
  regsub -all -- {\}} $vreme {} vreme
regsub -all -- {\{} $vreme {} vreme
regsub -all "\[\t\n\]" $vreme { } vreme
  set vreme [ split [ string trim [ regsub {Trenutno merenje} [ regsub -all {<.*?>} $vreme "" ] {} ] "\n" ] "\n" ]
  set vreme [ regsub -all {Trenutni pritisak} $vreme "- \002Trenutni pritisak\002" ]
  set vreme [ regsub -all {Brzina vetra} $vreme "- \002Brzina vetra\002" ]
  set vreme [ regsub -all {Vla.nost} $vreme "- \002Vlaznost vazduha\002" ]
  set vreme [ regsub -all {Vidljivost} $vreme "- \002Vidljivost\002" ]
  set vreme [ regsub -all {Subjektivno} $vreme "\002Subjektivno\002" ]
  set vreme [ regsub -all {Naleti vetra} $vreme "\002Naleti vetra\002" ]
set vreme [ regsub -all {Izlazak sunca} $vreme "\002Izlazak sunca\002" ]
set vreme [ regsub -all {Zalazak sunca} $vreme "\002Zalazak sunca\002" ]

  foreach msg $vreme {
        putnotc $nick "[encoding convertto utf-8 $msg]"
        after 1000 set end 1
        vwait end
}

} elseif {$grad == "" || [string match *$grad* $gradovi ] != 1} {
putnotc $nick "\002Niste odabrali grad!\002 Koristite komandu \002!vrijeme <grad>\002"
putnotc $nick "\002Dostupni gradovi:\002 Banja Luka, Bihac, Bijeljina, Brcko, Jahorina, Mostar, Neum, Sarajevo, Trebinje, Tuzla, Visegrad"
}

}
