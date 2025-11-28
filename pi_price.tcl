###############################################################################
#                                                                             #
#   ██████╗ ██████╗  █████╗ ███████╗███████╗                                  #
#   ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝                                  #
#   ██║  ██║██████╔╝███████║███████╗█████╗                                    #
#   ██║  ██║██╔══██╗██╔══██║╚════██║██╔══╝                                    #
#   ██████╔╝██████╔╝██║  ██║███████║███████╗                                  #
#   ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝                                  #
#                                                                             #
#   Cryptocurrency Price Monitor for Eggdrop                                  #
#   Version: 3.5.0                                                            #
#                                                                             #
###############################################################################
#                                                                             #
#   DESCRIPTION:                                                              #
#   Fetches ALL cryptocurrency prices from CoinMarketCap API and caches       #
#   them to a JSON database file. Automatically updates every 2 hours.        #
#                                                                             #
#   COMMANDS:                                                                 #
#   • !pi              - Pi Network price with invite link                    #
#   • !cprice TOKEN    - Get price for any cryptocurrency token               #
#   • !ctokens [query] - List available tokens (optionally search by name)    #
#                                                                             #
#   AUTHOR:                                                                   #
#   Velimir Majstorov (AKA munZe)                                             #
#   DBase Network - irc.dbase.in.rs                                           #
#                                                                             #
#   LICENSE:                                                                  #
#   MIT License                                                               #
#                                                                             #
###############################################################################
#                                                                             #
# Copyright (c) 2025 Velimir Majstorov AKA munZe from DBase                   #
#                                                                             #
# Permission is hereby granted, free of charge, to any person obtaining a copy#
# of this software and associated documentation files (the "Software"), to    #
# deal in the Software without restriction, including without limitation the  #
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or #
# sell copies of the Software, and to permit persons to whom the Software is  #
# furnished to do so, subject to the following conditions:                    #
#                                                                             #
# The above copyright notice and this permission notice shall be included in  #
# all copies or substantial portions of the Software.                         #
#                                                                             #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     #
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         #
# DEALINGS IN THE SOFTWARE.                                                   #
###############################################################################
package require json

# --- Config ---
set pi_channels [list "#Pi"]
set pi_api_key "<your-API-key>" ;# from https://coinmarketcap.com/api/
set pi_api_url "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest"
set pi_invite_link "https://minepi.com/Majstorov" ;# change with your invite link or leave it like this :) 
set pi_check_interval 7200          ;# 2h
set pi_db_file "scripts/crypto_prices.json"
set pi_network_id "35697"

array set coin_data {}

# --- Bind commands ---
bind pub - !pi pi_price_command
bind pub - !cprice crypto_price_command
bind pub - !ctokens list_crypto_tokens
bind evnt - init-server start_pi_monitor

# --- Start monitor ---
proc start_pi_monitor {type} {
    global pi_check_interval coin_data
    load_crypto_database_json
    after 2000 update_all_prices
    timer $pi_check_interval update_all_prices
}

# --- JSON storage ---
proc save_crypto_database_json {json_data} {
    global pi_db_file
    if {[catch {set fd [open $pi_db_file w]} err]} {return}
    puts $fd $json_data
    close $fd
}

proc load_crypto_database_json {} {
    global coin_data pi_db_file pi_network_id
    foreach k [array names coin_data] {unset coin_data($k)}
    array set coin_data {}

    if {![file exists $pi_db_file]} {
        putlog "DEBUG: JSON file not found: $pi_db_file"
        return 0
    }
    if {[catch {set fd [open $pi_db_file r]} err]} {
        putlog "DEBUG: Cannot open JSON file: $err"
        return 0
    }

    set json_data [read $fd]
    close $fd

    if {[catch {set parsed [::json::json2dict $json_data]} err]} {
        putlog "DEBUG: JSON parse error: $err"
        return 0
    }
    
    if {![dict exists $parsed data]} {
        putlog "DEBUG: No 'data' key in JSON"
        return 0
    }
    set data_list [dict get $parsed data]

    set count 0
    set pi_found 0
    foreach coin $data_list {
        set coin_id [dict get $coin id]
        set coin_symbol [string toupper [dict get $coin symbol]]
        set coin_name [dict get $coin name]
        set coin_price 0
        set coin_change24 0
        if {[dict exists $coin quote]} {
            set usd [dict get $coin quote USD]
            if {[dict exists $usd price]} {set coin_price [dict get $usd price]}
            if {[dict exists $usd percent_change_24h]} {set coin_change24 [dict get $usd percent_change_24h]}
        }
        
        # Чувај све токене по симболу
        if {$coin_symbol ne ""} {
            set coin_data($coin_symbol) [dict create id $coin_id name $coin_name price $coin_price change24h $coin_change24]
            incr count
        }
        
        # Посебно чувај Pi Network по ID-у
        if {[string equal $coin_id $pi_network_id]} {
            set coin_data(PI_NETWORK) [dict create id $coin_id name $coin_name price $coin_price change24h $coin_change24]
            putlog "DEBUG: Found Pi Network! ID=$coin_id, Symbol=$coin_symbol, Name=$coin_name, Price=$coin_price"
            set pi_found 1
        }
    }

    putlog "DEBUG: Loaded $count coins from JSON"
    
    if {!$pi_found} {
        putlog "WARNING: Pi Network (ID: $pi_network_id) not found in database!"
    }

    return $count
}

# --- Update from API ---
proc update_all_prices {} {
    global pi_api_key pi_api_url pi_check_interval pi_channels coin_data pi_invite_link pi_db_file

    set curl_cmd "curl -s -H \"X-CMC_PRO_API_KEY: $pi_api_key\" -H \"Accept: application/json\" -G \"$pi_api_url\" -d \"start=1&limit=5000&convert=USD\""
    if {[catch {set json_data [exec sh -c $curl_cmd]} err]} {
        putlog "ERROR: API call failed: $err"
        return
    }
    if {[string length $json_data] == 0} {
        putlog "ERROR: Empty API response"
        return
    }

    # Snimi ceo JSON
    save_crypto_database_json $json_data

    # Parsiraj u memoriju
    load_crypto_database_json

    # Pi price to channels
    set pi_info [get_cached_price "PI"]
    if {$pi_info ne ""} {
        set price_msg [format_pi_message $pi_info "PI"]
        foreach channel $pi_channels {
            if {[validchan $channel] && [botonchan $channel]} {
                putserv "PRIVMSG $channel :$price_msg"
            }
        }
    } else {
        putlog "WARNING: Could not get Pi price for channel announcement"
    }

    timer $pi_check_interval update_all_prices
}

# --- Get coin from cache ---
proc get_cached_price {symbol} {
    global coin_data pi_network_id pi_db_file
    set symbol_uc [string toupper $symbol]

    # Ако је PI, користи специјални ключ PI_NETWORK
    if {$symbol_uc eq "PI"} {
        if {[info exists coin_data(PI_NETWORK)]} {
            return $coin_data(PI_NETWORK)
        }
    } else {
        if {[info exists coin_data($symbol_uc)]} {
            return $coin_data($symbol_uc)
        }
    }

    # Ako nije u memoriji, učitaj JSON bazu i probaj opet
    if {[array size coin_data]==0 && [file exists $pi_db_file]} {
        load_crypto_database_json
        if {$symbol_uc eq "PI"} {
            if {[info exists coin_data(PI_NETWORK)]} {
                return $coin_data(PI_NETWORK)
            }
        } else {
            if {[info exists coin_data($symbol_uc)]} {
                return $coin_data($symbol_uc)
            }
        }
    }

    putlog "DEBUG: Token $symbol not found in cache"
    return ""
}

# --- Formatiranje poruka ---
proc format_crypto_message {price_info symbol} {
    if {$price_info eq ""} {return "Price for $symbol not found"}
    set name [dict get $price_info name]
    set price [format "%.8f" [dict get $price_info price]]
    regsub {\.?0+$} $price "" price
    set change24h [dict get $price_info change24h]
    set change_sign ""; set change_color "\003"
    if {$change24h>0} {set change_sign "+"; set change_color "\0033"}
    if {$change24h<0} {set change_color "\0034"}
    set change_formatted [format "%.2f" $change24h]
    return "\002$name ($symbol) Price:\002 \$$price USD | 24h: ${change_color}${change_sign}${change_formatted}%\003"
}

proc format_pi_message {price_info symbol} {
    global pi_invite_link
    if {$price_info eq ""} {return "Pi Price: Error"}
    set price_val [dict get $price_info price]
    set price_formatted [format "%.6f" $price_val]
    set change24h [dict get $price_info change24h]
    set change_sign ""; set change_color "\003"
    if {$change24h>0} {set change_sign "+"; set change_color "\0033"}
    if {$change24h<0} {set change_color "\0034"}
    set change_formatted [format "%.2f" $change24h]
    set id [dict get $price_info id]
    return "\002Pi Network (PI) Price:\002 \$$price_formatted USD | 24h: ${change_color}${change_sign}${change_formatted}%\003 | Join Pi: \037$pi_invite_link\037"
}

# --- Commands ---
proc pi_price_command {nick host handle chan arg} {
    set pi_info [get_cached_price "PI"]
    if {$pi_info eq ""} {
        putserv "PRIVMSG $chan :Pi Network Price not found. Try !cprice PI or check logs."
        return 0
    }
    putserv "PRIVMSG $chan :[format_pi_message $pi_info PI]"
    return 0
}

proc crypto_price_command {nick host handle chan arg} {
    set token [string toupper [string trim $arg]]
    if {$token eq ""} {putserv "PRIVMSG $chan :Usage: !cprice TOKEN"; return 0}
    set info [get_cached_price $token]
    if {$info eq ""} {putserv "PRIVMSG $chan :Price for $token not found." ; return 0}
    putserv "PRIVMSG $chan :[format_crypto_message $info $token]"
    return 0
}

proc list_crypto_tokens {nick host handle chan arg} {
    global coin_data
    set max_tokens 50
    if {[array size coin_data]==0} {
        load_crypto_database_json
        if {[array size coin_data]==0} {
            putserv "PRIVMSG $chan :No tokens loaded"
            return 0
        }
    }
    
    set symbols [lsort [array names coin_data]]
    set arg [string trim $arg]

    if {$arg eq ""} {
        # Прикажи све осим PI_NETWORK специјалног кључа
        set filtered {}
        foreach s $symbols {
            if {$s ne "PI_NETWORK"} {lappend filtered $s}
        }
        set display_list [lrange $filtered 0 [expr {$max_tokens-1}]]
        set token_list [join $display_list ", "]
        putserv "PRIVMSG $chan :Tokens ([llength filtered]): $token_list"
    } else {
        set query [string toupper $arg]
        set results {}
        foreach s [array names coin_data] {
            if {$s eq "PI_NETWORK"} {continue}
            set data $coin_data($s)
            if {[string match "*$query*" $s] || [string match "*$query*" [string toupper [dict get $data name]]]} {
                lappend results $s
            }
        }
        if {[llength $results]==0} {
            putserv "PRIVMSG $chan :No tokens matching '$arg'"
            return 0
        }
        set display [join [lrange [lsort $results] 0 [expr {$max_tokens-1}]] ", "]
        putserv "PRIVMSG $chan :Found [llength $results] matching '$arg': $display"
    }
    return 0
}

# --- Init ---
putlog "Crypto Monitor v3.5 loaded"
load_crypto_database_json

# --- Provera vremena modifikacije JSON fajla ---
set skip_update 0
if {[file exists $pi_db_file]} {
    set file_mtime [file mtime $pi_db_file]
    set now [clock seconds]
    if {($now - $file_mtime) < 7200} {
        set skip_update 1
    }
}

if {!$skip_update} {
    after 5000 update_all_prices
} else {
    putlog "Crypto JSON is recent (<2h), skipping initial update."
}