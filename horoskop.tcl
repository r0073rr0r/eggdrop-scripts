# Horoskop v3.1337
# Veci deo koda pisao: tik-tak,
# a kod preradio i modifikovao za eggdrop: munZe
# Skriptu mozete naci na Hawkee sa svezim updateovima
# na adresi https://github.com/r0073rr0r/eggdrop-scripts/blob/master/horoskop.tcl
#
# Komande su: !horoskop - !dnevni - !nedeljni - !mesecni - !ljubavni - !godisnji - !srecni / !srecni-dani
#
# !horoskop je isto sto i !dnevni ;-)
# !horoskop bez argumenta prikazuje listu svih komandi
#
# Posetite nas na kanalu #DBase @ irc.dbase.in.rs
#
# Veliki pozdrav za sve koji su prijavljivali bugove
# i pomagali razvijanju ovog snippeta ;)
# I naravno, sajtu sa koga se sve svlaci https://www.astrolook.com/
#
# MyH3e KoH3a MaToPu !!!
#
# MIT License
#
# Copyright (c) 2024
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# -= Podesavanja =-

# Ako je saljina 1 skripta salje horoskop NA KANAL
# saljina 2 - ide korisniku na PVT
# saljina 3 - ide korisniku na NOTICE

set saljina 2

# Flood protection - ogranicenja po korisniku
# dnevni_max - maksimalan broj poziva dnevnog horoskopa po korisniku dnevno (default: 10)
# ostali_max - maksimalan broj poziva ostalih horoskopa po korisniku dnevno (default: 3)
# godisnji_cooldown - koliko sekundi mora da prodje pre ponovnog poziva godisnjeg horoskopa (default: 3600 = 1 sat)

set dnevni_max 10
set ostali_max 3
set godisnji_cooldown 3600

# Kesiranje - kesira se sve na dnevnom nivou (brze je nego svaki put pozivati HTTPS i parsirati)
set cache_enabled 1

# Skripta pocinje ...
# Pozeljno je da NE DIRATE nista ispod osim ako
# NE ZNATE STA RADITE! ;-)

# Kanalske komande
bind pub - !horoskop pub_horoskop
bind pub - !dnevni pub_horoskop
bind pub - !nedeljni pub_nedeljni
bind pub - !mesecni pub_mesecni
bind pub - !ljubavni pub_ljubavni
bind pub - !godisnji pub_godisnji
bind pub - !srecni pub_srecni
bind pub - !srecni-dani pub_srecni

# Privatne komande (MSG)
bind msg - !horoskop msg_horoskop
bind msg - !dnevni msg_horoskop
bind msg - !nedeljni msg_nedeljni
bind msg - !mesecni msg_mesecni
bind msg - !ljubavni msg_ljubavni
bind msg - !godisnji msg_godisnji
bind msg - !srecni msg_srecni
bind msg - !srecni-dani msg_srecni

package require http

# Register HTTPS support
if {[catch {package require tls}]} {
    putlog "Horoskop: TLS package not available, HTTPS may not work"
} else {
    ::http::register https 443 [list ::tls::socket -autoservername true]
}

# Globalne varijable za flood protection i kesiranje
array set horoskop_cache {}
array set horoskop_usage {}
array set godisnji_lastcall {}

# Helper proc za flood protection
proc check_flood_limit {nick type} {
    global dnevni_max ostali_max godisnji_cooldown horoskop_usage godisnji_lastcall
    
    set now [clock seconds]
    set today [clock format $now -format "%Y-%m-%d"]
    set user_key "${nick}:${today}"
    
    # Proveri da li je dnevni horoskop
    if {$type == "dnevni"} {
        if {![info exists horoskop_usage($user_key:dnevni)]} {
            set horoskop_usage($user_key:dnevni) 0
        }
        if {$horoskop_usage($user_key:dnevni) >= $dnevni_max} {
            return [list 0 "Dostigli ste dnevni limit od $dnevni_max poziva za dnevni horoskop. Probajte ponovo sutra."]
        }
        incr horoskop_usage($user_key:dnevni)
        return [list 1 ""]
    }
    
    # Proveri za godišnji horoskop - poseban cooldown
    if {$type == "godisnji"} {
        set lastcall_key "${nick}:godisnji"
        if {[info exists godisnji_lastcall($lastcall_key)]} {
            set time_diff [expr {$now - $godisnji_lastcall($lastcall_key)}]
            if {$time_diff < $godisnji_cooldown} {
                set remaining [expr {$godisnji_cooldown - $time_diff}]
                set minutes [expr {$remaining / 60}]
                return [list 0 "Godišnji horoskop je veliki i zahteva pripremu. Molimo sačekajte još $minutes minuta pre ponovnog poziva."]
            }
        }
        set godisnji_lastcall($lastcall_key) $now
        
        # Proveri dnevni limit za ostale horoskope
        if {![info exists horoskop_usage($user_key:ostali)]} {
            set horoskop_usage($user_key:ostali) 0
        }
        if {$horoskop_usage($user_key:ostali) >= $ostali_max} {
            return [list 0 "Dostigli ste dnevni limit od $ostali_max poziva za horoskop. Probajte ponovo sutra."]
        }
        incr horoskop_usage($user_key:ostali)
        return [list 1 ""]
    }
    
    # Proveri dnevni limit za ostale horoskope (nedeljni, mesecni, ljubavni, srecni)
    if {![info exists horoskop_usage($user_key:ostali)]} {
        set horoskop_usage($user_key:ostali) 0
    }
    if {$horoskop_usage($user_key:ostali) >= $ostali_max} {
        return [list 0 "Dostigli ste dnevni limit od $ostali_max poziva za horoskop. Probajte ponovo sutra."]
    }
    incr horoskop_usage($user_key:ostali)
    return [list 1 ""]
}

# Helper proc za kesiranje svih tipova horoskopa na dnevnom nivou
proc get_cached_horoscope {type sign} {
    global horoskop_cache cache_enabled
    
    if {!$cache_enabled} {
        return ""
    }
    
    set today [clock format [clock seconds] -format "%Y-%m-%d"]
    set cache_key "${type}:${today}:${sign}"
    
    if {[info exists horoskop_cache($cache_key)]} {
        return $horoskop_cache($cache_key)
    }
    return ""
}

proc set_cached_horoscope {type sign text} {
    global horoskop_cache cache_enabled
    
    if {!$cache_enabled} {
        return
    }
    
    set today [clock format [clock seconds] -format "%Y-%m-%d"]
    set cache_key "${type}:${today}:${sign}"
    set horoskop_cache($cache_key) $text
}

# Helper proc za ciscenje starih cache i usage podataka (poziva se jednom dnevno)
proc cleanup_old_data {} {
    global horoskop_cache horoskop_usage
    
    set now [clock seconds]
    set today [clock format $now -format "%Y-%m-%d"]
    
    # Obrisi stare cache podatke (sve osim današnjih - kes od juče se briše)
    foreach key [array names horoskop_cache] {
        if {![string match "*:${today}:*" $key]} {
            unset horoskop_cache($key)
        }
    }
    
    # Obrisi stare usage podatke (sve osim današnjih)
    foreach key [array names horoskop_usage] {
        if {![string match "*:${today}:*" $key]} {
            unset horoskop_usage($key)
        }
    }
    
    # Godisnji_lastcall se cuva dok se ne pozove ponovo, ne brisemo ga ovde
    # Pokreni cleanup ponovo za 24 sata
    utimer 86400 cleanup_old_data
}

# Pokreni cleanup jednom dnevno (prvi put za 1 sat, zatim svakih 24 sata)
if {![info exists horoskop_cleanup_started]} {
    utimer 3600 cleanup_old_data
    set horoskop_cleanup_started 1
}

# Helper proc to extract horoscope text for a sign
proc extract_horoscope {page sign} {
    # Map user input to website sign names
    set sign_map [dict create \
        "skorpija" "Škorpion" \
        "skorpion" "Škorpion" \
        "ovan" "Ovan" \
        "bik" "Bik" \
        "blizanci" "Blizanci" \
        "rak" "Rak" \
        "lav" "Lav" \
        "devica" "Devica" \
        "vaga" "Vaga" \
        "strelac" "Strelac" \
        "jarac" "Jarac" \
        "vodolija" "Vodolija" \
        "ribe" "Ribe" \
    ]
    
    set sign_lower [string tolower $sign]
    if {[dict exists $sign_map $sign_lower]} {
        set website_sign [dict get $sign_map $sign_lower]
    } else {
        # Try to capitalize first letter
        set website_sign [string totitle $sign]
    }
    
    # Escape special regex characters in sign name
    set escaped_sign [regsub -all {[\[\](){}.*+?^$|\\]} $website_sign {\\&}]
    
    # Extract content between <h3 class="block-title">Sign</h3> and <div class="paketi"
    # TCL regexp matches newlines by default with .
    # Note: paketi div can have additional attributes like style="..."
    set pattern "<h3 class=\"block-title\">$escaped_sign</h3>(.*?)<div class=\"paketi"
    if {[regexp -nocase $pattern $page match content]} {
        # Remove any paketi div content that might have been captured
        regsub -all {<div class="paketi"[^>]*>.*?</div>} $content "" content
        # Remove HTML comments (including Word document comments)
        regsub -all {<!--.*?-->} $content "" content
        regsub -all {<!\[if[^\]]*\]>.*?<!\[endif\]>} $content "" content
        # Replace HTML entities with their actual characters
        regsub -all {&nbsp;} $content " " content
        regsub -all {&amp;} $content "&" content
        regsub -all {&lt;} $content "<" content
        regsub -all {&gt;} $content ">" content
        regsub -all {&quot;} $content "\"" content
        regsub -all {&#39;} $content "'" content
        # Clean up HTML tags and whitespace
        regsub -all {<[^>]+>} $content " " content
        regsub -all {\s+} $content " " content
        regsub -all {^\s+|\s+$} $content "" content
        return $content
    }
    return ""
}

#Dnevni horoskop

proc pub_horoskop {nick host hand channel sign} {
    global saljina
    
    if {$saljina==1} { 
        set salji "PRIVMSG $channel" 
    } elseif {$saljina==2} { 
        set salji "PRIVMSG $nick" 
    } else { 
        set salji "NOTICE $nick" 
    }
    
    if {$sign == ""} {
        # Prikazujemo help - uvek ide na notice da ne floodamo kanal
        putserv "NOTICE $nick \002\037Horoskop komande:\037\002"
        putserv "NOTICE $nick \002!horoskop \{znak\}\002 - Dnevni horoskop za odredjeni znak"
        putserv "NOTICE $nick \002!dnevni \{znak\}\002 - Isto kao !horoskop"
        putserv "NOTICE $nick \002!nedeljni \{znak\}\002 - Nedeljni horoskop za odredjeni znak"
        putserv "NOTICE $nick \002!mesecni \{znak\}\002 - Mesecni horoskop za odredjeni znak"
        putserv "NOTICE $nick \002!ljubavni \{znak\}\002 - Ljubavni horoskop za odredjeni znak"
        putserv "NOTICE $nick \002!godisnji \{znak\}\002 - Godisnji horoskop za odredjeni znak"
        putserv "NOTICE $nick \002!srecni \{znak\}\002 ili \002!srecni-dani \{znak\}\002 - Srecni dani za odredjeni znak"
        putserv "NOTICE $nick \002Dostupni znakovi:\002 ovan, bik, blizanci, rak, lav, devica, vaga, skorpija/skorpion, strelac, jarac, vodolija, ribe"
        putserv "NOTICE $nick \002Primer:\002 !horoskop rak  ili  !nedeljni skorpija  ili  !godisnji lav"
        putserv "NOTICE $nick \002Komande rade i privatno:\002 posaljite botu MSG sa !horoskop \{znak\}"
        return
    }
    
    # Flood protection
    set flood_check [check_flood_limit $nick "dnevni"]
    if {[lindex $flood_check 0] == 0} {
        putserv "$salji [lindex $flood_check 1]"
        return
    }
    
    # Proveri cache za dnevni horoskop
    set text [get_cached_horoscope "dnevni" $sign]
    
    if {$text == ""} {
        set url "https://www.astrolook.com/dnevni-horoskop"
        set token [::http::geturl $url -timeout 10000]
        set page [::http::data $token]
        ::http::cleanup $token
        
        set text [extract_horoscope $page $sign]
        
        if {$text != ""} {
            # Clean up and format the text
            regsub -all {\s+} $text " " text
            # Sacuvaj u cache
            set_cached_horoscope "dnevni" $sign $text
        }
    }
    
    if {$text != ""} {
        putserv "$salji \002Dnevni horoskop za \037$sign\037:\002 $text"
    } else {
        putserv "$salji \002Niste odredili adekvatan horoskopski znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002"
    }
}

#Nedeljni horoskop

proc pub_nedeljni {nick host hand channel sign} {
    global saljina
    
    if {$saljina==1} { 
        set salji "PRIVMSG $channel" 
    } elseif {$saljina==2} { 
        set salji "PRIVMSG $nick" 
    } else { 
        set salji "NOTICE $nick" 
    }
    
    if {$sign == ""} {
        putserv "$salji \002Niste odredili znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002"
        return
    }
    
    # Flood protection
    set flood_check [check_flood_limit $nick "ostali"]
    if {[lindex $flood_check 0] == 0} {
        putserv "$salji [lindex $flood_check 1]"
        return
    }
    
    # Proveri cache za nedeljni horoskop
    set text [get_cached_horoscope "nedeljni" $sign]
    
    if {$text == ""} {
        set url "https://www.astrolook.com/nedeljni-horoskop"
        set token [::http::geturl $url -timeout 10000]
        set page [::http::data $token]
        ::http::cleanup $token
        
        set text [extract_horoscope $page $sign]
        
        if {$text != ""} {
            # Sacuvaj u cache
            set_cached_horoscope "nedeljni" $sign $text
        }
    }
    
    if {$text != ""} {
        regsub -all {\s+} $text " " text
        putserv "$salji \002Nedeljni horoskop za \037$sign\037:\002"
        set msgs [regexp -all -inline {.{1,250}[^ ]* *} $text]
        foreach msg $msgs {
            putserv "$salji $msg"
            after 1000 set end 1
            vwait end
        }
    } else {
        putserv "$salji \002Niste odredili adekvatan horoskopski znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002"
    }
}

#Mesecni horoskop

proc pub_mesecni {nick host hand channel sign} {
    global saljina
    
    if {$saljina==1} { 
        set salji "PRIVMSG $channel" 
    } elseif {$saljina==2} { 
        set salji "PRIVMSG $nick" 
    } else { 
        set salji "NOTICE $nick" 
    }
    
    if {$sign == ""} {
        putserv "$salji \002Niste odredili znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002"
        return
    }
    
    # Flood protection
    set flood_check [check_flood_limit $nick "ostali"]
    if {[lindex $flood_check 0] == 0} {
        putserv "$salji [lindex $flood_check 1]"
        return
    }
    
    # Proveri cache za mesečni horoskop
    set text [get_cached_horoscope "mesecni" $sign]
    
    if {$text == ""} {
        set url "https://www.astrolook.com/mesecni-horoskop"
        set token [::http::geturl $url -timeout 10000]
        set page [::http::data $token]
        ::http::cleanup $token
        
        set text [extract_horoscope $page $sign]
        
        if {$text != ""} {
            # Sacuvaj u cache
            set_cached_horoscope "mesecni" $sign $text
        }
    }
    
    if {$text != ""} {
        regsub -all {\s+} $text " " text
        putserv "$salji \002Mesecni horoskop za \037$sign\037:\002"
        set msgs [regexp -all -inline {.{1,250}[^ ]* *} $text]
        foreach msg $msgs {
            putserv "$salji $msg"
            after 1000 set end 1
            vwait end
        }
    } else {
        putserv "$salji \002Niste odredili adekvatan horoskopski znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002"
    }
}

#Ljubavni horoskop

proc pub_ljubavni {nick host hand channel sign} {
    global saljina
    
    if {$saljina==1} { 
        set salji "PRIVMSG $channel" 
    } elseif {$saljina==2} { 
        set salji "PRIVMSG $nick" 
    } else { 
        set salji "NOTICE $nick" 
    }
    
    if {$sign == ""} {
        putserv "$salji \002Niste odredili znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002"
        return
    }
    
    # Flood protection
    set flood_check [check_flood_limit $nick "ostali"]
    if {[lindex $flood_check 0] == 0} {
        putserv "$salji [lindex $flood_check 1]"
        return
    }
    
    # Proveri cache za ljubavni horoskop
    set text [get_cached_horoscope "ljubavni" $sign]
    
    if {$text == ""} {
        set url "https://www.astrolook.com/ljubavni-horoskop"
        set token [::http::geturl $url -timeout 10000]
        set page [::http::data $token]
        ::http::cleanup $token
        
        set text [extract_horoscope $page $sign]
        
        if {$text != ""} {
            # Sacuvaj u cache
            set_cached_horoscope "ljubavni" $sign $text
        }
    }
    
    if {$text != ""} {
        regsub -all {\s+} $text " " text
        putserv "$salji \002Ljubavni horoskop za \037$sign\037:\002"
        set msgs [regexp -all -inline {.{1,250}[^ ]* *} $text]
        foreach msg $msgs {
            putserv "$salji $msg"
            after 1000 set end 1
            vwait end
        }
    } else {
        putserv "$salji \002Niste odredili adekvatan horoskopski znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002"
    }
}

#Godisnji horoskop

proc pub_godisnji {nick host hand channel sign} {
    global saljina
    
    if {$saljina==1} { 
        set salji "PRIVMSG $channel" 
    } elseif {$saljina==2} { 
        set salji "PRIVMSG $nick" 
    } else { 
        set salji "NOTICE $nick" 
    }
    
    if {$sign == ""} {
        putserv "$salji \002Niste odredili znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002 \037-\037 \002!godisnji rak\002"
        return
    }
    
    # Flood protection
    set flood_check [check_flood_limit $nick "godisnji"]
    if {[lindex $flood_check 0] == 0} {
        putserv "$salji [lindex $flood_check 1]"
        return
    }
    
    # Proveri cache za godišnji horoskop
    set text [get_cached_horoscope "godisnji" $sign]
    
    if {$text == ""} {
        # Poruka o pripremi
        putserv "$salji \002Godisnji horoskop je veliki i zahteva pripremu. Pripremam Vam horoskop za \037$sign\037...\002"
        
        set url "https://www.astrolook.com/godisnji-horoskop"
        set token [::http::geturl $url -timeout 10000]
        set page [::http::data $token]
        ::http::cleanup $token
        
        set text [extract_horoscope $page $sign]
        
        if {$text != ""} {
            # Sacuvaj u cache
            set_cached_horoscope "godisnji" $sign $text
        }
    }
    
    if {$text != ""} {
        regsub -all {\s+} $text " " text
        putserv "$salji \002Godisnji horoskop za \037$sign\037:\002"
        set msgs [regexp -all -inline {.{1,250}[^ ]* *} $text]
        foreach msg $msgs {
            putserv "$salji $msg"
            after 1000 set end 1
            vwait end
        }
    } else {
        putserv "$salji \002Niste odredili adekvatan horoskopski znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002 \037-\037 \002!godisnji rak\002"
    }
}

#Srecni dani

proc pub_srecni {nick host hand channel sign} {
    global saljina
    
    if {$saljina==1} { 
        set salji "PRIVMSG $channel" 
    } elseif {$saljina==2} { 
        set salji "PRIVMSG $nick" 
    } else { 
        set salji "NOTICE $nick" 
    }
    
    if {$sign == ""} {
        putserv "$salji \002Niste odredili znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002 \037-\037 \002!srecni rak\002"
        return
    }
    
    # Flood protection
    set flood_check [check_flood_limit $nick "ostali"]
    if {[lindex $flood_check 0] == 0} {
        putserv "$salji [lindex $flood_check 1]"
        return
    }
    
    # Proveri cache za srećne dane
    set text [get_cached_horoscope "srecni" $sign]
    
    if {$text == ""} {
        set url "https://www.astrolook.com/srecni-dani"
        set token [::http::geturl $url -timeout 10000]
        set page [::http::data $token]
        ::http::cleanup $token
        
        set text [extract_horoscope $page $sign]
        
        if {$text != ""} {
            # Sacuvaj u cache
            set_cached_horoscope "srecni" $sign $text
        }
    }
    
    if {$text != ""} {
        regsub -all {\s+} $text " " text
        putserv "$salji \002Srecni dani za \037$sign\037:\002 $text"
    } else {
        putserv "$salji \002Niste odredili adekvatan horoskopski znak!\002 Koristite komande npr. \002!horoskop rak\002 \037-\037 \002!nedeljni rak\002 \037-\037 \002!mesecni rak\002 \037-\037 \002!ljubavni rak\002 \037-\037 \002!srecni rak\002"
    }
}

# MSG verzije komandi (privatne poruke)

proc msg_horoskop {nick host hand text} {
    set sign [string trim $text]
    set salji "PRIVMSG $nick"
    
    if {$sign == ""} {
        putserv "NOTICE $nick \002\037Horoskop komande:\037\002"
        putserv "NOTICE $nick \002!horoskop \{znak\}\002 - Dnevni horoskop za odredjeni znak"
        putserv "NOTICE $nick \002!dnevni \{znak\}\002 - Isto kao !horoskop"
        putserv "NOTICE $nick \002!nedeljni \{znak\}\002 - Nedeljni horoskop za odredjeni znak"
        putserv "NOTICE $nick \002!mesecni \{znak\}\002 - Mesecni horoskop za odredjeni znak"
        putserv "NOTICE $nick \002!ljubavni \{znak\}\002 - Ljubavni horoskop za odredjeni znak"
        putserv "NOTICE $nick \002!godisnji \{znak\}\002 - Godisnji horoskop za odredjeni znak"
        putserv "NOTICE $nick \002!srecni \{znak\}\002 ili \002!srecni-dani \{znak\}\002 - Srecni dani za odredjeni znak"
        putserv "NOTICE $nick \002Dostupni znakovi:\002 ovan, bik, blizanci, rak, lav, devica, vaga, skorpija/skorpion, strelac, jarac, vodolija, ribe"
        putserv "NOTICE $nick \002Primer:\002 !horoskop rak  ili  !nedeljni skorpija  ili  !godisnji lav"
        return
    }
    
    # Flood protection
    set flood_check [check_flood_limit $nick "dnevni"]
    if {[lindex $flood_check 0] == 0} {
        putserv "$salji [lindex $flood_check 1]"
        return
    }
    
    # Proveri cache za dnevni horoskop
    set cached_text [get_cached_horoscope "dnevni" $sign]
    
    if {$cached_text == ""} {
        set url "https://www.astrolook.com/dnevni-horoskop"
        set token [::http::geturl $url -timeout 10000]
        set page [::http::data $token]
        ::http::cleanup $token
        
        set cached_text [extract_horoscope $page $sign]
        
        if {$cached_text != ""} {
            regsub -all {\s+} $cached_text " " cached_text
            set_cached_horoscope "dnevni" $sign $cached_text
        }
    }
    
    if {$cached_text != ""} {
        putserv "$salji \002Dnevni horoskop za \037$sign\037:\002 $cached_text"
    } else {
        putserv "$salji \002Niste odredili adekvatan horoskopski znak!\002 Koristite komande npr. \002!horoskop rak\002"
    }
}

proc msg_nedeljni {nick host hand text} {
    set sign [string trim $text]
    set salji "PRIVMSG $nick"
    
    if {$sign == ""} {
        putserv "$salji \002Niste odredili znak!\002 Koristite: !nedeljni \{znak\}"
        return
    }
    
    # Flood protection
    set flood_check [check_flood_limit $nick "ostali"]
    if {[lindex $flood_check 0] == 0} {
        putserv "$salji [lindex $flood_check 1]"
        return
    }
    
    # Proveri cache za nedeljni horoskop
    set text_result [get_cached_horoscope "nedeljni" $sign]
    
    if {$text_result == ""} {
        set url "https://www.astrolook.com/nedeljni-horoskop"
        set token [::http::geturl $url -timeout 10000]
        set page [::http::data $token]
        ::http::cleanup $token
        
        set text_result [extract_horoscope $page $sign]
        
        if {$text_result != ""} {
            set_cached_horoscope "nedeljni" $sign $text_result
        }
    }
    
    if {$text_result != ""} {
        regsub -all {\s+} $text_result " " text_result
        putserv "$salji \002Nedeljni horoskop za \037$sign\037:\002"
        set msgs [regexp -all -inline {.{1,250}[^ ]* *} $text_result]
        foreach msg $msgs {
            putserv "$salji $msg"
            after 1000 set end 1
            vwait end
        }
    } else {
        putserv "$salji \002Niste odredili adekvatan horoskopski znak!\002"
    }
}

proc msg_mesecni {nick host hand text} {
    set sign [string trim $text]
    set salji "PRIVMSG $nick"
    
    if {$sign == ""} {
        putserv "$salji \002Niste odredili znak!\002 Koristite: !mesecni \{znak\}"
        return
    }
    
    # Flood protection
    set flood_check [check_flood_limit $nick "ostali"]
    if {[lindex $flood_check 0] == 0} {
        putserv "$salji [lindex $flood_check 1]"
        return
    }
    
    # Proveri cache za mesečni horoskop
    set text_result [get_cached_horoscope "mesecni" $sign]
    
    if {$text_result == ""} {
        set url "https://www.astrolook.com/mesecni-horoskop"
        set token [::http::geturl $url -timeout 10000]
        set page [::http::data $token]
        ::http::cleanup $token
        
        set text_result [extract_horoscope $page $sign]
        
        if {$text_result != ""} {
            set_cached_horoscope "mesecni" $sign $text_result
        }
    }
    
    if {$text_result != ""} {
        regsub -all {\s+} $text_result " " text_result
        putserv "$salji \002Mesecni horoskop za \037$sign\037:\002"
        set msgs [regexp -all -inline {.{1,250}[^ ]* *} $text_result]
        foreach msg $msgs {
            putserv "$salji $msg"
            after 1000 set end 1
            vwait end
        }
    } else {
        putserv "$salji \002Niste odredili adekvatan horoskopski znak!\002"
    }
}

proc msg_ljubavni {nick host hand text} {
    set sign [string trim $text]
    set salji "PRIVMSG $nick"
    
    if {$sign == ""} {
        putserv "$salji \002Niste odredili znak!\002 Koristite: !ljubavni \{znak\}"
        return
    }
    
    # Flood protection
    set flood_check [check_flood_limit $nick "ostali"]
    if {[lindex $flood_check 0] == 0} {
        putserv "$salji [lindex $flood_check 1]"
        return
    }
    
    # Proveri cache za ljubavni horoskop
    set text_result [get_cached_horoscope "ljubavni" $sign]
    
    if {$text_result == ""} {
        set url "https://www.astrolook.com/ljubavni-horoskop"
        set token [::http::geturl $url -timeout 10000]
        set page [::http::data $token]
        ::http::cleanup $token
        
        set text_result [extract_horoscope $page $sign]
        
        if {$text_result != ""} {
            set_cached_horoscope "ljubavni" $sign $text_result
        }
    }
    
    if {$text_result != ""} {
        regsub -all {\s+} $text_result " " text_result
        putserv "$salji \002Ljubavni horoskop za \037$sign\037:\002"
        set msgs [regexp -all -inline {.{1,250}[^ ]* *} $text_result]
        foreach msg $msgs {
            putserv "$salji $msg"
            after 1000 set end 1
            vwait end
        }
    } else {
        putserv "$salji \002Niste odredili adekvatan horoskopski znak!\002"
    }
}

proc msg_godisnji {nick host hand text} {
    set sign [string trim $text]
    set salji "PRIVMSG $nick"
    
    if {$sign == ""} {
        putserv "$salji \002Niste odredili znak!\002 Koristite: !godisnji \{znak\}"
        return
    }
    
    # Flood protection
    set flood_check [check_flood_limit $nick "godisnji"]
    if {[lindex $flood_check 0] == 0} {
        putserv "$salji [lindex $flood_check 1]"
        return
    }
    
    # Proveri cache za godišnji horoskop
    set text_result [get_cached_horoscope "godisnji" $sign]
    
    if {$text_result == ""} {
        # Poruka o pripremi
        putserv "$salji \002Godisnji horoskop je veliki i zahteva pripremu. Pripremam Vam horoskop za \037$sign\037...\002"
        
        set url "https://www.astrolook.com/godisnji-horoskop"
        set token [::http::geturl $url -timeout 10000]
        set page [::http::data $token]
        ::http::cleanup $token
        
        set text_result [extract_horoscope $page $sign]
        
        if {$text_result != ""} {
            set_cached_horoscope "godisnji" $sign $text_result
        }
    }
    
    if {$text_result != ""} {
        regsub -all {\s+} $text_result " " text_result
        putserv "$salji \002Godisnji horoskop za \037$sign\037:\002"
        set msgs [regexp -all -inline {.{1,250}[^ ]* *} $text_result]
        foreach msg $msgs {
            putserv "$salji $msg"
            after 1000 set end 1
            vwait end
        }
    } else {
        putserv "$salji \002Niste odredili adekvatan horoskopski znak!\002"
    }
}

proc msg_srecni {nick host hand text} {
    set sign [string trim $text]
    set salji "PRIVMSG $nick"
    
    if {$sign == ""} {
        putserv "$salji \002Niste odredili znak!\002 Koristite: !srecni \{znak\}"
        return
    }
    
    # Flood protection
    set flood_check [check_flood_limit $nick "ostali"]
    if {[lindex $flood_check 0] == 0} {
        putserv "$salji [lindex $flood_check 1]"
        return
    }
    
    # Proveri cache za srećne dane
    set text_result [get_cached_horoscope "srecni" $sign]
    
    if {$text_result == ""} {
        set url "https://www.astrolook.com/srecni-dani"
        set token [::http::geturl $url -timeout 10000]
        set page [::http::data $token]
        ::http::cleanup $token
        
        set text_result [extract_horoscope $page $sign]
        
        if {$text_result != ""} {
            set_cached_horoscope "srecni" $sign $text_result
        }
    }
    
    if {$text_result != ""} {
        regsub -all {\s+} $text_result " " text_result
        putserv "$salji \002Srecni dani za \037$sign\037:\002 $text_result"
    } else {
        putserv "$salji \002Niste odredili adekvatan horoskopski znak!\002"
    }
}

putlog "Horoskop v3.1337 ucitan..."
