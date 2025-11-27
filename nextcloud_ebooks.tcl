# nextcloud_ebooks.tcl
# Skripta za pretragu Nextcloud eBooks foldera
# Komande: !ebook ili !knjiga <naziv knjige>
#
# Konfiguracija:
# - nextcloud_url: URL vašeg Nextcloud servera (npr. https://cloud.dbase.in.rs)
# - nextcloud_username: Vaš Nextcloud username
# - nextcloud_app_password: App password (kreirati u Nextcloud Settings > Security > Devices & sessions)

putlog "nextcloud_ebooks.tcl: POČETAK UČITAVANJA SKRIPTE"

# Postavljanje UTF-8 encoding-a za pravilno prikazivanje srpskih slova
if {[catch {encoding system utf-8}]} {
    # Ako ne može da postavi sistem encoding, pokušavamo sa convertfrom
    putlog "nextcloud_ebooks.tcl: UTF-8 encoding podešen"
}

package require http
putlog "nextcloud_ebooks.tcl: HTTP paket učitan"

# Provera base64 paketa
set base64_available 1
if {[catch {package require base64}]} {
    putlog "nextcloud_ebooks.tcl: base64 package not found. Script may not work."
    set base64_available 0
} else {
    putlog "nextcloud_ebooks.tcl: base64 paket učitan"
}

# Provera da li je TLS dostupan za HTTPS
if {[catch {package require tls}]} {
    putlog "nextcloud_ebooks.tcl: TLS package not found. HTTPS may not work."
} else {
    ::http::register https 443 [list ::tls::socket -autoservername true]
    putlog "nextcloud_ebooks.tcl: TLS paket učitan i HTTPS registrovan"
}

# Konfiguracija - izmenite ove vrednosti
putlog "nextcloud_ebooks.tcl: Postavljanje konfiguracije"
set nextcloud_url "https://cloud.dbase.in.rs"
set nextcloud_username "<vas-username-password>"
set nextcloud_app_password "<vas-admin-password>"
putlog "nextcloud_ebooks.tcl: Konfiguracija postavljena"

# Bind komandi - na početku fajla kao u prcko.tcl
bind pub - !ebook nextcloud_search_ebook
bind pub - !knjiga nextcloud_search_ebook

# Helper funkcija za kreiranje auth headera
proc nextcloud_get_auth_header {} {
    global nextcloud_username nextcloud_app_password base64_available
    
    # Provera da li promenljive postoje
    if {![info exists nextcloud_username] || ![info exists nextcloud_app_password]} {
        putlog "nextcloud_ebooks.tcl: GREŠKA: Konfiguracija nije postavljena u nextcloud_get_auth_header!"
        error "Konfiguracija nije postavljena"
    }
    
    if {![info exists base64_available]} {
        set base64_available 1
    }
    
    set auth_string "${nextcloud_username}:${nextcloud_app_password}"
    
    if {$base64_available == 0} {
        putlog "nextcloud_ebooks.tcl: GREŠKA: base64 paket nije dostupan!"
        error "base64 paket nije dostupan"
    }
    
    if {[catch {set auth_encoded [::base64::encode $auth_string]} err]} {
        putlog "nextcloud_ebooks.tcl: GREŠKA pri base64 enkodovanju: $err"
        error "base64 encode failed: $err"
    }
    
    return $auth_encoded
}

# Helper funkcija za URL encoding
proc nextcloud_url_encode {str} {
    set encoded ""
    foreach char [split $str ""] {
        scan $char %c ascii
        if {($ascii >= 48 && $ascii <= 57) || ($ascii >= 65 && $ascii <= 90) || ($ascii >= 97 && $ascii <= 122) || $char == "-" || $char == "_" || $char == "." || $char == "~" || $char == "/"} {
            append encoded $char
        } else {
            append encoded [format "%%%02X" $ascii]
        }
    }
    return $encoded
}

# Helper funkcija za URL decoding (bez encoding konverzije - koristi se za putanje)
proc nextcloud_url_decode {str} {
    set decoded ""
    set i 0
    set len [string length $str]
    while {$i < $len} {
        set char [string index $str $i]
        if {$char == "%" && $i + 2 < $len} {
            set hex [string range $str [expr {$i + 1}] [expr {$i + 2}]]
            if {[string match {[0-9A-Fa-f][0-9A-Fa-f]} $hex]} {
                scan $hex %x ascii
                append decoded [format %c $ascii]
                incr i 3
            } else {
                append decoded $char
                incr i
            }
        } else {
            append decoded $char
            incr i
        }
    }
    return $decoded
}

# Helper funkcija za pravilno dekodovanje UTF-8 stringa
proc nextcloud_fix_encoding {str} {
    # Pokušavamo da konvertujemo string iz UTF-8 u sistem encoding
    # Ovo će popraviti encoding ako je string UTF-8 ali je pogrešno interpretiran
    # Prvo proveravamo da li string već sadrži UTF-8 karaktere koji su pogrešno interpretirani
    if {[string match "*Å*" $str] || [string match "*Ã*" $str]} {
        # String verovatno sadrži pogrešno interpretirane UTF-8 karaktere
        # Pokušavamo da ga konvertujemo iz UTF-8
        if {[catch {set fixed [encoding convertfrom utf-8 $str]}]} {
            # Ako konverzija ne uspe, vraćamo originalni string
            return $str
        }
        return $fixed
    }
    # Ako string ne sadrži očigledne UTF-8 probleme, vraćamo ga kako jeste
    return $str
}

proc nextcloud_search_ebook {nick uhost hand channel arg} {
    putlog "nextcloud_ebooks.tcl: ====== KOMANDA POZVANA ======"
    putlog "nextcloud_ebooks.tcl: Nick: $nick, Channel: $channel, Arg: '$arg'"
    
    global nextcloud_username nextcloud_app_password base64_available
    
    if {![info exists base64_available]} {
        set base64_available 1
    }
    
    if {$base64_available == 0} {
        putserv "NOTICE $nick :Greška: base64 paket nije dostupan. Kontaktirajte administratora."
        return 0
    }
    
    if {![info exists nextcloud_username] || ![info exists nextcloud_app_password]} {
        putserv "NOTICE $nick :Greška: Konfiguracija nije postavljena. Kontaktirajte administratora."
        return 0
    }
    
    if {$nextcloud_username == "your_username" || $nextcloud_app_password == "your_app_password"} {
        putserv "NOTICE $nick :Skripta nije konfigurisana. Kontaktirajte administratora."
        return 0
    }
    
    set search_term [string trim $arg]
    
    if {$search_term == ""} {
        putserv "NOTICE $nick :Koristite: !ebook <naziv knjige> ili !knjiga <naziv knjige>"
        putserv "NOTICE $nick :Primer: !knjiga Perun ili !ebook Perunove vede"
        putserv "NOTICE $nick :Razmaci u nazivu knjige su dozvoljeni - bot će pretražiti sve knjige koje sadrže uneti termin"
        return 0
    }
    
    putserv "NOTICE $nick :Tražim knjigu: $search_term"
    
    set results ""
    if {[catch {set results [nextcloud_find_book $search_term]} error]} {
        putlog "nextcloud_ebooks.tcl: GREŠKA pri pretrazi: $error"
        if {$error == "" || $error == "0"} {
            set error "Nepoznata greška pri pretrazi"
        }
        putserv "NOTICE $nick :Greška pri pretrazi knjiga: $error"
        return 0
    }
    
    if {[llength $results] == 0} {
        putserv "NOTICE $nick :Nisam našao knjigu sa terminom '$search_term'. Pokušajte sa drugim terminom."
    } else {
        set total [llength $results]
        putserv "NOTICE $nick :Našao sam $total knjigu/knjige za '$search_term'."
        
        if {$total == 1} {
            set result [lindex $results 0]
            set display_name [nextcloud_fix_encoding [lindex $result 0]]
            putserv "NOTICE $nick :Pronađena knjiga: $display_name - [lindex $result 1]"
        } else {
            putserv "NOTICE $nick :Pronađeno $total knjiga:"
            foreach result $results {
                set display_name [nextcloud_fix_encoding [lindex $result 0]]
                putserv "NOTICE $nick :  • $display_name - [lindex $result 1]"
            }
        }
    }
    
    putlog "nextcloud_ebooks.tcl: ====== KOMANDA ZAVRŠENA ======"
    return 0
}

proc nextcloud_find_book {search_term} {
    global nextcloud_url nextcloud_username
    
    # WebDAV endpoint za eBooks folder
    set webdav_url "${nextcloud_url}/remote.php/dav/files/${nextcloud_username}/eBooks"
    
    # Kreiranje Basic Auth header-a iz helper funkcije sa error handling
    if {[catch {set auth_encoded [nextcloud_get_auth_header]} err]} {
        putlog "nextcloud_ebooks.tcl: GREŠKA u nextcloud_get_auth_header: $err"
        if {$err == "" || $err == "0"} {
            set err "Greška pri kreiranju auth headera"
        }
        error $err
    }
    
    # PROPFIND zahtev za rekurzivno listanje fajlova (infinity = svi fajlovi u svim podfolderima)
    set headers [list "Authorization" "Basic $auth_encoded" "Depth" "infinity"]
    
    if {[catch {
        set token [::http::geturl $webdav_url -method PROPFIND -headers $headers -timeout 10000]
        set status [::http::ncode $token]
        set data [::http::data $token]
        ::http::cleanup $token
    } error]} {
        putlog "nextcloud_ebooks.tcl: HTTP error: $error"
        error "Nextcloud server ne odgovara. Pokušajte ponovo za nekoliko sekundi."
    }
    
    if {$status != 207} {
        putlog "nextcloud_ebooks.tcl: WebDAV error: HTTP $status"
        error "Nextcloud server je vratio grešku (HTTP $status). Pokušajte ponovo."
    }
    
    # Parsiranje XML odgovora sa error handling
    if {[catch {set files [nextcloud_parse_propfind $data]} error]} {
        putlog "nextcloud_ebooks.tcl: GREŠKA pri parsiranju XML: $error"
        error "Greška pri obradi odgovora sa Nextcloud servera. Pokušajte ponovo."
    }
    
    # Pretraga fajlova koji odgovaraju search term-u
    set search_lower [string tolower $search_term]
    set matches {}
    
    foreach file $files {
        set filename [lindex $file 0]
        set filepath [lindex $file 1]
        set filename_lower [string tolower $filename]
        
        if {[string match "*${search_lower}*" $filename_lower]} {
            lappend matches [list $filename $filepath]
        }
    }
    
    if {[llength $matches] == 0} {
        return {}
    }
    
    # Ograničavamo broj rezultata na 10 za prikaz
    set max_results 10
    set total_matches [llength $matches]
    set display_matches $matches
    
    if {$total_matches > $max_results} {
        set display_matches [lrange $matches 0 [expr {$max_results - 1}]]
    }
    
    # Kreiranje liste rezultata sa share linkovima
    set result_list {}
    
    foreach match $display_matches {
        set filename [lindex $match 0]
        set filepath [lindex $match 1]
        
        # Dobijanje ili kreiranje public share linka sa error handling
        if {[catch {set public_link [nextcloud_get_or_create_share $filepath]} error]} {
            putlog "nextcloud_ebooks.tcl: GREŠKA pri kreiranju share linka za $filename: $error"
            lappend result_list [list $filename "greška pri kreiranju linka"]
        } elseif {$public_link != ""} {
            lappend result_list [list $filename $public_link]
        } else {
            lappend result_list [list $filename "nije moguće kreirati link"]
        }
    }
    
    return $result_list
}

proc nextcloud_parse_propfind {xml_data} {
    set files {}
    
    # Parsiranje XML - tražimo sve href i displayname elemente
    # WebDAV PROPFIND vraća strukturu sa <d:response> blokovima
    
    # Prvo ekstraktujemo sve href elemente
    set hrefs {}
    set start 0
    while {[set pos [string first "<d:href>" $xml_data $start]] >= 0} {
        set start [expr {$pos + 9}]
        set end [string first "</d:href>" $xml_data $start]
        if {$end >= 0} {
            set href [string trim [string range $xml_data $start $end-1]]
            lappend hrefs $href
            set start $end
        } else {
            break
        }
    }
    
    # Zatim ekstraktujemo sve displayname elemente
    set displaynames {}
    set start 0
    while {[set pos [string first "<d:displayname>" $xml_data $start]] >= 0} {
        set start [expr {$pos + 16}]
        set end [string first "</d:displayname>" $xml_data $start]
        if {$end >= 0} {
            set displayname [string trim [string range $xml_data $start $end-1]]
            lappend displaynames $displayname
            set start $end
        } else {
            break
        }
    }
    
    # Povezujemo href i displayname (trebaju biti u istom redosledu)
    set len [llength $hrefs]
    
    if {[llength $displaynames] != $len} {
        # Ako brojevi ne odgovaraju, koristimo samo href-ove
        foreach href $hrefs {
            # Preskačemo foldere (href-ovi koji završavaju sa /)
            if {[string match "*/" $href]} {
                continue
            }
            
            # Ekstraktujemo ime fajla iz href-a
            set path_parts [split $href "/"]
            set filename_raw [lindex $path_parts end]
            
            # URL dekodovanje imena fajla
            set filename [nextcloud_url_decode $filename_raw]
            
            # Dodajemo samo fajlove (ne foldere) - fajlovi obično imaju ekstenziju
            if {$filename != "" && $filename != "eBooks" && [string match "*.*" $filename]} {
                # Čuvamo i originalno ime (za pretragu) i dekodovano ime (za prikaz)
                lappend files [list $filename $href]
            }
        }
    } else {
        for {set i 0} {$i < $len} {incr i} {
            set href [lindex $hrefs $i]
            set displayname [lindex $displaynames $i]
            
            # Preskačemo foldere (href-ovi koji završavaju sa /)
            if {[string match "*/" $href]} {
                continue
            }
            
            # Koristimo displayname ako postoji, inače ekstraktujemo iz href-a
            if {$displayname != "" && $displayname != "eBooks"} {
                set filename $displayname
            } else {
                set path_parts [split $href "/"]
                set filename [lindex $path_parts end]
                # URL dekodovanje
                set filename [nextcloud_url_decode $filename]
            }
            
            # Dodajemo samo fajlove (ne foldere) - fajlovi obično imaju ekstenziju
            if {$filename != "" && $filename != "eBooks" && [string match "*.*" $filename]} {
                lappend files [list $filename $href]
            }
        }
    }
    
    return $files
}

proc nextcloud_get_relative_path {filepath} {
    global nextcloud_username
    
    # Ekstraktujemo putanju fajla relativno na user folder
    # href može biti u formatu: /remote.php/dav/files/admin/eBooks/... ili remote.php/dav/files/admin/eBooks/...
    # Treba da ekstraktujemo deo posle /files/username/
    # VAŽNO: Dekodujemo URL encoding da dobijemo čistu putanju, pa ćemo je ponovo encodovati pre slanja API-ju
    
    # Uklanjamo početni / ako postoji
    set filepath [string trimleft $filepath "/"]
    
    # Tražimo /files/username/ u putanji
    set files_pattern "/files/${nextcloud_username}/"
    set files_pos [string first $files_pattern $filepath]
    
    if {$files_pos >= 0} {
        # Ekstraktujemo deo posle /files/username/ (sa URL encoding-om)
        set relative_path_encoded [string range $filepath [expr {$files_pos + [string length $files_pattern]}] end]
        
        # Dekodujemo URL encoding da dobijemo čistu putanju
        set relative_path [nextcloud_url_decode $relative_path_encoded]
        
        # Dodajemo početni / koji Nextcloud API očekuje
        set relative_path "/${relative_path}"
        
        return $relative_path
    }
    
    # Alternativno, tražimo samo username/ u putanji (za slučaj da nema /files/)
    set username_pattern "${nextcloud_username}/"
    set username_pos [string first $username_pattern $filepath]
    
    if {$username_pos >= 0} {
        # Ekstraktujemo deo posle username/ (sa URL encoding-om)
        set relative_path_encoded [string range $filepath [expr {$username_pos + [string length $username_pattern]}] end]
        
        # Dekodujemo URL encoding da dobijemo čistu putanju
        set relative_path [nextcloud_url_decode $relative_path_encoded]
        
        # Dodajemo početni / koji Nextcloud API očekuje
        set relative_path "/${relative_path}"
        
        return $relative_path
    }
    
    return ""
}

proc nextcloud_get_existing_share {relative_path} {
    global nextcloud_url
    
    # OCS API endpoint za listanje postojećih share-ova
    set shares_url "${nextcloud_url}/ocs/v2.php/apps/files_sharing/api/v1/shares"
    
    # Kreiranje Basic Auth header-a iz helper funkcije sa error handling
    if {[catch {set auth_encoded [nextcloud_get_auth_header]} err]} {
        putlog "nextcloud_ebooks.tcl: GREŠKA u nextcloud_get_auth_header: $err"
        if {$err == "" || $err == "0"} {
            set err "Greška pri kreiranju auth headera"
        }
        error $err
    }
    
    # URL encoding putanje
    set encoded_path [nextcloud_url_encode $relative_path]
    
    # GET zahtev za listanje share-ova za određeni fajl
    set headers [list \
        "Authorization" "Basic $auth_encoded" \
        "OCS-APIRequest" "true" \
    ]
    
    set query_url "${shares_url}?path=${encoded_path}&reshares=true"
    
    if {[catch {
        set token [::http::geturl $query_url -method GET -headers $headers -timeout 10000]
        set status [::http::ncode $token]
        set data [::http::data $token]
        ::http::cleanup $token
    } error]} {
        putlog "nextcloud_ebooks.tcl: Share check error: $error"
        return ""
    }
    
    if {$status != 200} {
        return ""
    }
    
    # Parsiranje XML odgovora - tražimo public share (shareType=3)
    # Nextcloud OCS API vraća XML sa <element> blokovima za svaki share
    set start 0
    while {[set pos [string first "<element>" $data $start]] >= 0} {
        set start [expr {$pos + 9}]
        set end [string first "</element>" $data $start]
        if {$end >= 0} {
            set element [string range $data $start $end-1]
            
            # Proveravamo da li je shareType=3 (public link) - koristimo string first umesto regexp
            set share_type_start [string first "<share_type>" $element]
            if {$share_type_start >= 0} {
                set share_type_start [expr {$share_type_start + 12}]
                set share_type_end [string first "</share_type>" $element $share_type_start]
                if {$share_type_end >= 0} {
                    set share_type [string trim [string range $element $share_type_start [expr {$share_type_end - 1}]]]
                    if {$share_type == 3} {
                        # Pronašli smo public share, ekstraktujemo URL
                        set url_start [string first "<url>" $element]
                        if {$url_start >= 0} {
                            set url_start [expr {$url_start + 5}]
                            set url_end [string first "</url>" $element $url_start]
                            if {$url_end >= 0} {
                                set share_url [string trim [string range $element $url_start [expr {$url_end - 1}]]]
                                return $share_url
                            }
                        }
                    }
                }
            }
            set start $end
        } else {
            break
        }
    }
    
    return ""
}

proc nextcloud_get_or_create_share {filepath} {
    global nextcloud_url
    
    # Prvo dobijamo relativnu putanju sa error handling
    if {[catch {set relative_path [nextcloud_get_relative_path $filepath]} error]} {
        putlog "nextcloud_ebooks.tcl: GREŠKA pri dobijanju relativne putanje: $error"
        return ""
    }
    
    if {$relative_path == ""} {
        return ""
    }
    
    # Proveravamo da li već postoji public share sa error handling
    if {[catch {set existing_share [nextcloud_get_existing_share $relative_path]} error]} {
        putlog "nextcloud_ebooks.tcl: GREŠKA pri proveri postojećeg share-a: $error"
        # Nastavljamo sa kreiranjem novog share-a
    } elseif {$existing_share != ""} {
        return $existing_share
    }
    
    # Ako ne postoji, kreiramo novi sa error handling
    if {[catch {set new_share [nextcloud_create_share $filepath]} error]} {
        putlog "nextcloud_ebooks.tcl: GREŠKA pri kreiranju novog share-a: $error"
        return ""
    }
    
    return $new_share
}

proc nextcloud_create_share {filepath} {
    global nextcloud_url
    
    # OCS API endpoint za kreiranje share-a
    set share_url "${nextcloud_url}/ocs/v2.php/apps/files_sharing/api/v1/shares"
    
    # Dobijamo relativnu putanju
    set relative_path [nextcloud_get_relative_path $filepath]
    
    if {$relative_path == ""} {
        return ""
    }
    
    # Kreiranje Basic Auth header-a iz helper funkcije sa error handling
    if {[catch {set auth_encoded [nextcloud_get_auth_header]} err]} {
        putlog "nextcloud_ebooks.tcl: GREŠKA u nextcloud_get_auth_header: $err"
        if {$err == "" || $err == "0"} {
            set err "Greška pri kreiranju auth headera"
        }
        error $err
    }
    
    # POST zahtev za kreiranje public share-a
    set headers [list \
        "Authorization" "Basic $auth_encoded" \
        "OCS-APIRequest" "true" \
        "Content-Type" "application/x-www-form-urlencoded" \
    ]
    
    # URL encoding putanje
    set encoded_path [nextcloud_url_encode $relative_path]
    
    set post_data "path=${encoded_path}&shareType=3&permissions=1"
    
    if {[catch {
        set token [::http::geturl $share_url -method POST -headers $headers -query $post_data -timeout 10000]
        set status [::http::ncode $token]
        set data [::http::data $token]
        ::http::cleanup $token
    } error]} {
        putlog "nextcloud_ebooks.tcl: Share creation error: $error"
        return ""
    }
    
    if {$status != 200} {
        putlog "nextcloud_ebooks.tcl: Share creation failed: HTTP $status"
        putlog "nextcloud_ebooks.tcl: Response data: [string range $data 0 500]"
        return ""
    }
    
    # Parsiranje XML odgovora za URL
    # Nextcloud OCS API vraća XML sa <url> elementom
    set url_start [string first "<url>" $data]
    if {$url_start >= 0} {
        set url_start [expr {$url_start + 5}]
        set url_end [string first "</url>" $data $url_start]
        if {$url_end >= 0} {
            set share_url [string trim [string range $data $url_start [expr {$url_end - 1}]]]
            return $share_url
        }
    }
    
    return ""
}

putlog "nextcloud_ebooks.tcl: ====== SKRIPTA UČITANA ======"
putlog "nextcloud_ebooks.tcl: Komande: !ebook i !knjiga"
putlog "nextcloud_ebooks.tcl: Ne zaboravite da konfigurišete nextcloud_url, nextcloud_username i nextcloud_app_password u skripti!"
putlog "nextcloud_ebooks.tcl: Proverite bind komande sa: .binds pub"
putlog "nextcloud_ebooks.tcl: Bind komande su registrovane: !ebook i !knjiga"
putlog "nextcloud_ebooks.tcl: ====== KRAJ UČITAVANJA SKRIPTE ======"
