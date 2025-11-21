bind pub - !tenistop3 pub_tenis
package require http
#Verzija
set verzija "0.1337"
#Def OS
set OS [lindex $tcl_platform(os) 0]
proc pub_tenis {nick host hand channel bla} {
set url "http://www.atpworldtour.com/en/rankings/singles"
set token [ ::http::geturl $url ]
set page [ ::http::data $token ]
::http::cleanup $token
set matches [regexp -inline -all {<tbody>(.*?)</tbody>} $page]
foreach {match value} $matches {
lappend values $value
}
regsub -all {<td class="rank-cell">\n\t+4\n\t+</td>\n\t+.*</tr>} $values {} values
regsub -all {<td class="rank-cell">} $values "\n\002RANKING:\002" values
regsub -all {<td class="player-cell">} $values "\002PLAYER:\002" values
regsub -all {<td class="age-cell">} $values "\002AGE:\002" values
regsub -all {<td class="points-cell">} $values "\002POINTS:\002" values
regsub -all {<td class="tourn-cell">} $values "\002TOURN PLAYED:\002" values
regsub -all {<td class="pts-cell">} $values "\002POINTS DROPPING:\002" values
regsub -all {<td class="next-cell">} $values "\002NEXT BEST:\002" values
regsub -all {<div class="move-text">(.*?)</div>} $values {} values
regsub -all {<([^<])*>} $values {} values
regsub -all "\[\t\]" $values { } values
regsub -all "\[\n\]" $values { } values
regsub -all "                                                                           " $values {} values
regsub -all "      " $values { } values
regsub -all {\}} $values {} values
regsub -all {\{} $values {} values
regsub -all {   } $values {} values
regsub -all "  " $values " " values
putnotc $nick $values
}
putlog "Loaded Top Tennis Rankings v$verzija by \002munZe\002"
