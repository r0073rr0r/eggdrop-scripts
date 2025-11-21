###############################################################################
# holdem.tcl version 1.2.0                                                    #
# Copyright 2011 Steve Church (rojo on EFnet). All rights reserved.           #
#                                                                             #
# Salt the settings below to taste, load the script, rehash, .chanset         #
# #channel +holdem, then !holdem to play.  It's not rocket surgery.           #
#                                                                             #
# A note about Unicode / UTF-8: If your bot is compiled with UTF-8 support    #
# (see http://eggwiki.org/Utf-8 for details) and you set settings(unicode)    #
# 1, cards are displayed with their suits as extended characters.  If         #
# players in your channel are not using a modern, updated IRC client;         #
# rather than seeing suits as intended, they may just see garbage.  More      #
# information for mIRC UTF-8 support is available at                          #
# http://www.mirc.net/newbie/unicode.php .  If your users use Mibbit,         #
# they'll probably see Unicode characters just fine.  Users using any         #
# other IRC client are probably intelligent enough to figure out how to       #
# handle UTF-8 on their own.                                                  #
#                                                                             #
# Thanks to the unnaturally lucky Sunset, Trex, turgsh01, and the rest of     #
# the EFnet #arcade group for helping me squash bugs.  If you find more       #
# bugs, please report them to rojo on EFnet.                                  #
#                                                                             #
# LICENSE                                                                     #
#                                                                             #
# Redistribution and use in source and binary forms, with or without          #
# modification, are permitted provided that the following conditions are      #
# met:                                                                        #
#                                                                             #
#   1. Redistributions of source code must retain the above copyright         #
#      notice, this list of conditions and the following disclaimer.          #
#                                                                             #
#   2. Redistributions in binary form must reproduce the above copyright      #
#      notice, this list of conditions and the following disclaimer in the    #
#      documentation and/or other materials provided with the distribution.   #
#                                                                             #
# THIS SOFTWARE IS PROVIDED BY STEVE CHURCH "AS IS" AND ANY EXPRESS OR        #
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES   #
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.     #
# IN NO EVENT SHALL STEVE CHURCH OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,    #
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES          #
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR          #
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)          #
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,         #
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING       #
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE          #
# POSSIBILITY OF SUCH DAMAGE.                                                 #
###############################################################################
#                                                                             #
# MODIFICATIONS AND FIXES                                                     #
#                                                                             #
# Additional modifications and bug fixes by Velimir Majstorov                 #
#   munZe @ irc.dbase.in.rs for channel #Poker                                #
#                                                                             #
# TCL VERSION: TCL 8.6+ (tested with TCL 8.6)                                 #
# EGGDROP VERSION: Tested with Eggdrop 1.10.0                                 #
#                                                                             #
# FIXES APPLIED:                                                              #
#                                                                             #
# 1. Fixed "invalid command name '1'" error:                                  #
#    - Removed newline within append statement in proc score (line ~1695)     #
#    - This was causing TCL to parse the next line as a new command           #
#                                                                             #
# 2. Fixed all newline issues that break TCL commands:                        #
#    - Consolidated array set hand_name definition (line ~109)                #
#    - Fixed nested lindex command in proc score (line ~1722)                 #
#    - Fixed multi-line expr statements in proc bot_play (lines ~2050,2070)   #
#    - Fixed multi-line foreach list in proc hand (line ~1963)                #
#    - Fixed multi-line expr statement in proc ai (line ~2286)                #
#    - All bracket commands [command] now properly on single lines            #
#                                                                             #
# 3. Fixed card color display issues:                                         #
#    - Changed card colors to use white background (00) for readability       #
#    - Updated hearts-color to 04,00 (red on white)                           #
#    - Updated diamonds-color to 13,00 (pink/magenta on white)                #
#    - Updated spades-color to 01,00 (black on white)                         #
#    - Updated clubs-color to 02,00 (blue on white)                           #
#    - Fixed render proc to properly reset colors after card display          #
#                                                                             #
# NEW FEATURES:                                                               #
#                                                                             #
# 1. Configurable card message type (settings(card-message-type)):            #
#    - New setting: set settings(card-message-type) notice                    #
#    - Options: "notice" (default) or "privmsg"                               #
#    - Controls how private card messages are sent to players                 #
#    - Default is "notice" for less intrusive card notifications              #
#    - Change to "privmsg" if you prefer PRIVMSG instead                      #
#    - Location: Line ~127 in configuration section                           #
#                                                                             #
# 2. Per-user card message preferences (!cardmsg command):                    #
#    - Users can set their own preference: !cardmsg notice or !cardmsg        #
#      privmsg                                                                #
#    - Overrides global settings(card-message-type) for individual users      #
#    - Use !cardmsg without arguments to view current setting                 #
#    - Preferences are stored per-user and persist during script runtime      #
#                                                                             #
# 3. Enhanced rankings system:                                                #
#    - Added games_played, hands_won, and total_points statistics             #
#    - Players with negative points are hidden from !rankings but shown in    #
#      !rank with accurate position                                           #
#    - Losers lose 128 points (all human losers, not just first)              #
#    - Negative points allowed, but only positive-point players shown in      #
#      public rankings                                                        #
#    - Rankings automatically reset on the 1st of each month                  #
#    - !clearrankings command for operators to manually clear rankings        #
#                                                                             #
# 4. Improved all-in command:                                                 #
#    - Now recognizes "all in", "all-in", and "all" by itself                 #
#    - More flexible regex matching for all-in bets                           #
#                                                                             #
# 5. Help command (!help):                                                    #
#    - Lists all available commands                                           #
#    - Shows operator commands only to channel operators                      #
#    - Displays user commands and game commands to everyone                   #
#                                                                             #
# 6. Enhanced command permissions:                                            #
#    - Stop commands (!stop, !end, !endgame, !stfu, !quiet) can only be       #
#      used by channel operators OR the user who started the game             #
#    - !clearrankings requires channel operator status (uses isop, not        #
#      matchattr)                                                             #
#                                                                             #
# CONFIGURATION:                                                              #
#                                                                             #
# settings(card-message-type):                                                #
#   - Type: string                                                            #
#   - Values: "notice" or "privmsg"                                           #
#   - Default: "notice"                                                       #
#   - Description: Global default for card message type. Individual users     #
#                  can override with !cardmsg command. NOTICE is less         #
#                  intrusive and recommended for most IRC clients.            #
#                                                                             #
# NEW COMMANDS:                                                               #
#                                                                             #
# !cardmsg <notice|privmsg> - Set your personal card message preference       #
# !cardtype <notice|privmsg> - Alias for !cardmsg                             #
# !help - Show all available commands                                         #
# !clearrankings - Clear all rankings (channel operator only)                 #
#                                                                             #
###############################################################################
namespace eval holdem { set settings(udef-flag) holdem ;# .chanset 
#channel|* +holdem
set settings(buy-in) 250 ;# amount of money each player starts with
set settings(small-blind) 5 ;# forced bet for the small blind
set settings(big-blind) 10 ;# forced bet for the big blind
set settings(denomination) {$} ;# dollars / euros / pounds / whatever
set settings(timeout) 60 ;# seconds to wait before starting 1st round / timing out a player
set settings(double-at-round) 5 ;# double the values of the blinds every x rounds
set settings(confidence) 5 ;# audacity of the bot for bluffing and so forth (0-10 = less to more aggressive)
set settings(unicode) 1 ;# is your eggdrop patched to handle utf-8 extended characters?  http://eggwiki.org/Utf-8
set settings(ignore-flags) bkqr|kqr 
set settings(triggers) {!holdem !th !texas !texasholdem !the}
set settings(stop-triggers) {!stop !end !endgame !stfu !quiet}
# card colors: 00 white 08 yellow 01 black 09 light green (lime) 02 blue 
# (navy) 10 teal (a green/blue cyan) 03 green 11 light cyan (cyan) (aqua) 
# 04 red 12 light blue (royal) 05 brown (maroon) 13 pink (magenta) 06 
# purple 14 gray 07 orange (olive) 15 light gray (silver) xx,yy 
# foreground,background
# Using dark foreground colors with white background (00) for readability
set settings(hearts-color) 04,00
set settings(diamonds-color) 13,00
set settings(spades-color) 01,00
set settings(clubs-color) 02,00
set settings(card-message-type) notice ;# how to send private card messages: "notice" or "privmsg" (default: notice)
set settings(diversions) {
	"relace his shoes" "sulk in the kitchen" "get more beer from the 
	gas station" "look at porn" "play Mario Kart" "hit on the girl next 
	door" "fire his spud gun from the back porch" "check his email" 
	"check on the steaks" "find a bathroom" "walk his dog" "work on 
	some coding" "change his pants" "sniff some glue" "lick himself"
}
set settings(bot-players) { "Ezmirelda McGillicuddy" "Mr. Croup" "Mr. 
	Vandemar" "Oliver Close-Auff" "Popeye the Vegan" "Mr. Pink" "that 
	little Asian kid" "Walt Sisname" "Four Finger Joe" "One-Eyed Pete" 
	"The Snoot" "my cleaning lady" "my next door neighbor" "the ginger 
	kid" "Mr. Miyagi" "Mr. Flibble" "Professor Farnsworth" "Buzz 
	Lightyear" "Rocket Girl" "Trapper Keeper" "Pippi No-stockings" 
	"Mrs. Phipps" "the mail man" "Harry Cooter"
}
#########################
# end of user variables #
#########################
set scriptver "1.2.0"
set settings(verbose) 1 ;# enable additional putlogs for development
variable settings
variable hands
variable ns [namespace current]
variable rankings_file "holdem_rankings.dat"
variable rankings
array set rankings {}
variable user_card_prefs
array set user_card_prefs {}
# Load rankings from file
# Rankings structure: rankings($player) is a dict with keys: games_played, hands_won, total_points
# For backward compatibility, old format (just points) is converted to new format
if {[file exists $rankings_file]} {
	if {[catch {
		set f [open $rankings_file r]
		set data [read $f]
		close $f
		# Only process if file has content
		if {[string trim $data] != ""} {
			array set temp_rankings $data
			# Convert old format to new format if needed
			foreach {player value} [array get temp_rankings] {
				if {[string is integer $value]} {
					# Old format: just points
					set rankings($player) [dict create games_played 0 hands_won 0 total_points $value]
				} else {
					# New format: dict with stats
					set rankings($player) $value
				}
			}
		}
	} err]} {
		putlog "Error loading rankings: $err"
	}
}
array set hand_name {
	0 {a high card} 1 {a pair} 2 {two pair} 3 {three of a kind} 4 {a straight} 5 {a flush} 6 {a full house} 7 {four of a kind} 8 {a straight flush}
}
variable hand_name
foreach t $settings(triggers) {
	bind pub * $t ${ns}::start
}
foreach t $settings(stop-triggers) {
	bind pub * $t ${ns}::stfu
}
bind pub * !rankings ${ns}::show_rankings
bind pub * !rank ${ns}::show_rank
bind pub * !help ${ns}::show_help
bind pub * !clearrankings ${ns}::clear_rankings
bind pub * !cardmsg ${ns}::set_card_message_type
bind pub * !cardtype ${ns}::set_card_message_type
bind time - "00 00 1 * *" ${ns}::check_monthly_reset
if {[info exists settings(udef-flag)] && [string length $settings(udef-flag)]} {
	setudef flag $settings(udef-flag)
}
variable newdeck [list]
foreach suit {H D S C} { 
	for {set i 2} {$i < 15} {incr i} {
		lappend newdeck [list $i $suit]
	}
}
proc shuffle {lst {iter 0}} { 
	variable settings
	set shuffled [list]
	while {[llength $lst]} {
		set draw [rand [llength $lst]]
		lappend shuffled [lindex $lst $draw]
		set lst [lreplace $lst $draw $draw]
	}
	incr iter
	if {$iter < 3} {
		return [shuffle $shuffled $iter]
	} else {
		return $shuffled
	}
}
# thanks thommey!
proc is_patched {} { catch {queuesize \u0754} err; expr {[string bytelength $err] - 45} }
proc check_patched {} {
	variable settings
	if {$settings(unicode) && ![is_patched]} {
		set settings(unicode) 0
		putlog "This eggdrop is not patched for UTF-8 / unicode output.  Please see http://eggwiki.org/Utf-8 for details.  For now, unicode output is disabled."
	}
}
proc render {card} { 
	variable settings
	# $card is a 2-element list containing value and suit
	if {[lindex $card 0] == 1} {
		set card [lreplace $card 0 0 14]
	}
	switch [lindex $card 1] {
		H { set out "\003$settings(hearts-color)\[" }
		D { set out "\003$settings(diamonds-color)\[" }
		S { set out "\003$settings(spades-color)\[" }
		C { set out "\003$settings(clubs-color)\[" }
	}
	# Unicode / UTF-8 extended character support: 
	# http://eggwiki.org/Utf-8
	if {$settings(unicode)} {
		# ♥ \u2665 ♦ \u2666 ♠ \u2660 ♣ \u2663
		array set suits [list H \u2665 D \u2666 S \u2660 C \u2663]
		append out $suits([lindex $card 1])
		append out [string map {14 A 13 K 12 Q 11 J} [lindex $card 0]]
		if {![string equal [encoding system] utf-8]} {
			set out [encoding convertto utf-8 $out]
		}
	} else {
		array set suits {H Hearts C Clubs D Diamonds S Spades}
		append out [string map {14 Ace 13 King 12 Queen 11 Jack} [lindex $card 0]]
		append out " of "
		append out $suits([lindex $card 1])
	}
	append out "\]\00300"
	return $out
}
proc list2pretty {lst} { 
	variable settings
	set last [lindex $lst end]
	set first [lreplace $lst end end]
	set first [join $first "\002, \002"]
	return "\002$first\002 and \002$last\002"
}
proc start {nick uhost hand chan txt} { 
	variable settings
	variable ns
	
	# Check if channel is valid
	if {![validchan $chan]} {
		return 0
	}
	
	# Check ignore flags
	if {[catch {matchattr $hand $settings(ignore-flags) $chan} result] || $result} {
		return 0
	}
	
	# Check channel flag
	if {[info exists settings(udef-flag)] && [string length $settings(udef-flag)]} {
		if {[catch {channel get $chan $settings(udef-flag)} flag_result]} {
			return 0
		}
		if {!$flag_result} {
			return 0
		}
	}
	
	# Initialize game
	dict set settings($chan) players [list $nick]
	dict set settings($chan) game_starter $nick
	puthelp "PRIVMSG $chan :\001ACTION and $nick sit down at the card table and start dividing up chips, snacks and beer.\001"
	puthelp "PRIVMSG $chan :Who else wants to play?  Type \002!join\002 to play some Hold 'Em with us.  Type \002!play\002 to start the game, or just wait $settings(timeout) seconds for the game to start automatically."
	bind pub * !join ${ns}::join_game
	bind pub * !play ${ns}::trigger_get_bot_players
	utimer $settings(timeout) [list ${ns}::get_bot_players $chan]
	if {$settings(unicode)} {
		utimer 5 ${ns}::check_patched
	}
	return 0
}
proc stfu {nick uhost hand chan txt} { 
	variable settings
	
	# Check if channel is valid
	if {![validchan $chan]} {
		return 0
	}
	
	# Check ignore flags
	if {[catch {matchattr $hand $settings(ignore-flags) $chan} result] || $result} {
		return 0
	}
	
	# Check if user is channel operator
	set is_channel_op [isop $nick $chan]
	
	# Check if user is the game starter
	set is_game_starter 0
	if {[info exists settings($chan)] && [dict exists $settings($chan) game_starter]} {
		if {[string equal $nick [dict get $settings($chan) game_starter]]} {
			set is_game_starter 1
		}
	}
	
	# Only allow channel operators or game starter to stop the game
	if {!$is_channel_op && !$is_game_starter} {
		return 0
	}
	
	clearqueue help
	if {[info exists settings($chan)]} {
		puthelp "PRIVMSG $chan :OK, shutting up now."
	}
	stop $chan
	return 0
}
proc stop {chan} { 
	variable ns
	variable settings
	
	# Get namespace name safely
	set ns_name [namespace current]
	
	catch {unbind pub * !join ${ns_name}::join_game}
	catch {unbind pub * !play ${ns_name}::trigger_get_bot_players}
	catch {unbind pubm * $chan* ${ns_name}::round_one}
	catch {unbind pubm * $chan* ${ns_name}::take_bet}
	catch {unbind pubm * $chan* ${ns_name}::keep_watching}
	
	foreach t [utimers] {
		if {[string match *${ns_name}* [lindex $t 1]]} {
			killutimer [lindex $t 2]
		}
	}
	
	if {[info exists settings($chan)]} {
		unset settings($chan)
	}
	return 0
}
proc join_game {nick uhost hand chan txt} { 
	variable settings
	
	# Check if channel is valid
	if {![validchan $chan]} {
		return 0
	}
	
	# Check ignore flags
	if {[catch {matchattr $hand $settings(ignore-flags) $chan} result] || $result} {
		return 0
	}
	
	# Check if game exists
	if {![info exists settings($chan)] || ![dict exists $settings($chan) players]} {
		return 0
	}
	
	# Get players list
	if {[catch {set players [dict get $settings($chan) players]} err]} {
		return 0
	}
	
	# Check if already in game
	if {[lsearch $players $nick] > -1} {
		return 0
	}
	
	# Add player
	dict lappend settings($chan) players $nick
	lappend players $nick
	
	if {[llength $players] == 2} {
		puthelp "PRIVMSG $chan :\001ACTION gives $nick his chair and goes off to\ [lindex $settings(diversions) [rand [llength $settings(diversions)]]].\001"
	} elseif {[llength $players] == 8} {
		puthelp "PRIVMSG $chan :The table is now full.  On with the game."
		round_one $nick $uhost $hand $chan skip
	} else {
		puthelp "PRIVMSG $chan :\001ACTION passes $nick a beer and waits for the game to start.\001"
	}
	return 0
}
proc get_next_player {chan b4 {iter 0}} { 
	variable settings
	foreach var {players players_this_round has_bet} {
		set $var [dict get $settings($chan) $var]
	}
	if {[llength $has_bet] == [llength $players_this_round]} {
		return ""
	}
	if {$iter > [llength $players]} {
		putlog "Something's wrong.  has_bet: $has_bet; players_this_round: $players_this_round"
		return ""
	}
	set idx [lsearch -exact $players $b4]
	incr idx
	if {$idx == [llength $players]} {
		set idx 0
	}
	set next [lindex $players $idx]
	if {[lsearch $players_this_round $next] < 0} {
		return [get_next_player $chan $next [incr iter]]
	}
	set cash [dict get $settings($chan) !$next cash]
	set bet [dict get $settings($chan) !$next bet]
	if {!$cash && !$bet} {
		return [get_next_player $chan $next [incr iter]]
	}
	return $next
}
proc trigger_get_bot_players {nick uhost hand chan txt} { 
	variable settings
	
	# Check if channel is valid and game exists
	if {![validchan $chan] || ![info exists settings($chan)] || ![dict exists $settings($chan) players]} {
		puthelp "PRIVMSG $chan :No game in progress. Type !holdem to start a game."
		return 0
	}
	
	# Call get_bot_players with error handling
	if {[catch {get_bot_players $chan} err]} {
		putlog "Error in trigger_get_bot_players: $err"
		puthelp "PRIVMSG $chan :Error starting game: $err"
		return 0
	}
	return 0
}
proc get_bot_players {chan} { 
	variable settings
	variable ns
	global botnick
	
	# Check if channel is valid and game exists
	if {![validchan $chan] || ![info exists settings($chan)] || ![dict exists $settings($chan) players]} {
		return 0
	}
	
	# Get namespace name safely
	set ns_name [namespace current]
	
	foreach t [utimers] {
		if {[string equal [lindex $t 1] [list ${ns_name}::get_bot_players $chan]]} {
			killutimer [lindex $t 2]
		}
	}
	catch {unbind pub * !join ${ns_name}::join_game}
	catch {unbind pub * !play ${ns_name}::trigger_get_bot_players}
	
	# Get players list with error handling
	if {[catch {set players [dict get $settings($chan) players]} err]} {
		return 0
	}
	
	if {[llength $players] == 1} {
		# Only one player - add bot automatically
		dict set settings($chan) !$botnick confidence [expr {[rand $settings(confidence)] + 5}]
		lappend players $botnick
		puthelp "PRIVMSG $chan :[lindex $players 0]: I guess it's just you and me, then. May I deal a few imaginary friends in? (How many more bot players in addition to myself? Type a number or 'skip' for 0)"
	} else {
		puthelp "PRIVMSG $chan :[list2pretty $players] seem ready to play. May I deal myself and a few imaginary friends in? (How many bot players? Type a number or 'skip' for 0)"
	}
	dict set settings($chan) players $players
	
	# Get namespace name safely for bind
	set ns_name [namespace current]
	bind pubm * $chan* ${ns_name}::round_one
	return 0
}
proc round_one {nick uhost hand chan txt} { 
	variable settings
	variable ns
	
	# Check if channel is valid and game exists
	if {![validchan $chan] || ![info exists settings($chan)] || ![dict exists $settings($chan) players]} {
		return 0
	}
	
	# Get namespace name safely
	set ns_name [namespace current]
	
	# Get players list with error handling
	if {[catch {set players [dict get $settings($chan) players]} err]} {
		return 0
	}
	
	if {[lsearch $players $nick] == -1} {
		return 0
	}
	
	# Check for skip, no, or number - also allow empty/just whitespace to default to 0
	if {![regexp -nocase {\y(skip|no(t|ne)?|\d+)\y} $txt - match]} {
		# If no match and text is empty/whitespace, default to 0 (skip)
		if {[string trim $txt] == ""} {
			set match 0
		} else {
			return 0
		}
	}
	
	catch {unbind pubm * $chan* ${ns_name}::round_one}
	
	if {[string equal -nocase $txt "skip"] || [string equal -nocase $txt "no"] || [string equal -nocase $txt "none"]} {
		set match 0
	}
	
	if {![string equal -nocase $txt "skip"]} {
		if {![string is integer -strict $match]} { 
			set match 0 
		}
		while {[expr {$match + [llength $players]}] > 8} { 
			incr match -1 
		}
		if {$match > 0} {
			if {[catch {set potential $settings(bot-players)} err]} {
				putlog "Error getting bot-players in round_one: $err"
				set match 0
			} else {
				for {set i 0} {$i < $match} {incr i} {
					if {[llength $potential] == 0} {
						break
					}
					set idx [rand [llength $potential]]
					set bot_name [lindex $potential $idx]
					lappend players $bot_name
					if {[catch {
						dict set settings($chan) !$bot_name confidence [expr {[rand $settings(confidence)] + 5}]
					} err]} {
						putlog "Error setting bot confidence in round_one: $err"
					}
					set potential [lreplace $potential $idx $idx]
				}
			}
		}
	}
	
	# Shuffle players with error handling
	if {[catch {set players [shuffle $players]} err]} {
		putlog "Error shuffling players in round_one: $err"
		return 0
	}
	
	# Validate players list
	if {[llength $players] < 2} {
		puthelp "PRIVMSG $chan :Need at least 2 players to start a game."
		return 0
	}
	
	# Set players with error handling
	if {[catch {
		dict set settings($chan) players $players
		dict set settings($chan) players_this_round $players
	} err]} {
		putlog "Error setting players in round_one: $err"
		return 0
	}
	
	# Initialize player cash and bets with error handling
	foreach p $players {
		if {[catch {
			dict set settings($chan) !$p cash $settings(buy-in)
			dict set settings($chan) !$p bet 0
		} err]} {
			putlog "Error initializing player $p in round_one: $err"
			return 0
		}
	}
	
	# Set dealer with error handling
	if {[llength $players] > 0} {
		set dealer [lindex $players [rand [llength $players]]]
		if {[catch {
			dict set settings($chan) dealer $dealer
			dict set settings($chan) has_bet [list]
			dict set settings($chan) round 0
			dict set settings($chan) sbvalue $settings(small-blind)
			dict set settings($chan) bbvalue $settings(big-blind)
			dict set settings($chan) folds 0
		} err]} {
			putlog "Error setting game state in round_one: $err"
			return 0
		}
	} else {
		putlog "Error: No players in round_one"
		return 0
	}
	
	# Send message and deal cards with error handling
	set d $settings(denomination)
	if {[catch {
		clearqueue help
		set buyin $settings(buy-in)
		set smallblind $settings(small-blind)
		set bigblind $settings(big-blind)
		set dval $d
		set buyinstr [string cat $dval $buyin]
		set smallblindstr [string cat $dval $smallblind]
		set bigblindstr [string cat $dval $bigblind]
		set msg [format "PRIVMSG %s :We have our players.  Players sit in the following order: %s.  Each player starts with %s.  Blinds are at %s / %s." $chan [list2pretty $players] $buyinstr $smallblindstr $bigblindstr]
		puthelp $msg
		deal $chan
	} err]} {
		putlog "Error in deal/puthelp in round_one: $err"
		puthelp "PRIVMSG $chan :Error starting game: $err"
		return 0
	}
	return 0
}
proc get_diff {chan nick} { 
	variable settings
	set bet [dict get $settings($chan) !$nick bet]
	set difference 0
	foreach p [dict get $settings($chan) players_this_round] {
		set bet_diff [expr {[dict get $settings($chan) !$p bet] - $bet}]
		if {$bet_diff > $difference} {
			set difference $bet_diff
		}
	}
	return $difference
}
proc deal {chan} { 
	variable settings
	variable newdeck
	variable ns
	global botnick
	
	foreach var {players round dealer sbvalue bbvalue} {
		if {[catch {set $var [dict get $settings($chan) $var]} err]} {
			putlog "Error getting $var in deal: $err"
			return 0
		}
	}
	set players_this_round $players
	set d $settings(denomination)
	set out "PRIVMSG $chan :\00304Current standings:\003"
	foreach p $players {
		dict set settings($chan) !$p bet 0
		if {![set cash [dict get $settings($chan) !$p cash]]} {
			set idx [lsearch -exact $players_this_round $p]
			set players_this_round [lreplace $players_this_round $idx $idx]
		} else {
			set cashval $cash
			set dval $d
			set cashstr [string cat $dval $cashval]
			append out " \002"
			append out $p
			append out "\002 has \00311"
			append out $cashstr
			append out "\003."
		}
	}
	puthelp $out
	dict set settings($chan) players_this_round $players_this_round
	dict set settings($chan) checks 0
	if {$settings(verbose)} {
		putlog "dealing to players: $players_this_round"
	}
	if {[catch {set dealer [get_next_player $chan $dealer]} err]} {
		putlog "Error getting next dealer in deal: $err"
		return 0
	}
	if {$dealer == ""} {
		putlog "Error: dealer is empty in deal"
		return 0
	}
	if {[llength $players_this_round] == 2} {
		set sbplayer $dealer
	} else {
		if {[catch {set sbplayer [get_next_player $chan $dealer]} err]} {
			putlog "Error getting sbplayer in deal: $err"
			return 0
		}
	}
	if {[catch {set bbplayer [get_next_player $chan $sbplayer]} err]} {
		putlog "Error getting bbplayer in deal: $err"
		return 0
	}
	foreach var {dealer sbplayer bbplayer players_this_round} {
		if {[catch {
			set var_value [set [set var]]
			dict set settings($chan) $var $var_value
		} err]} {
			putlog "Error setting $var in deal: $err (var=$var)"
			return 0
		}
	}
	set deck [shuffle $newdeck]
	set cards [list]
	set phase deal
	set has_bet [list]
	set skip_betting 0
	incr round
	if {[string equal $botnick $dealer]} {
		set dlr "I am"
	} else {
		set dlr "\002$dealer\002 is"
	}
	set out "PRIVMSG $chan :\00304Round $round\003.  "
	if {!($round % $settings(double-at-round))} {
		incr sbvalue $settings(small-blind)
		set bbvalue [expr {$sbvalue * 2}]
		set sbval $sbvalue
		set bbval $bbvalue
		set dval $d
		set sbstr [string cat $dval $sbval]
		set bbstr [string cat $dval $bbval]
		append out "\00304Blind values have been increased to \002"
		append out $sbstr
		append out "\002 / \002"
		append out $bbstr
		append out "\002.\003 "
	}
	dict set settings($chan) min_bet $bbvalue
	append out "$dlr dealing.  "
	if {[string equal $botnick $sbplayer]} {
		set dlr "I am"
	} else {
		set dlr "\002$sbplayer\002 is"
	}
	append out "$dlr the small blind this round; "
	if {[string equal $botnick $bbplayer]} {
		set dlr "I am"
	} else {
		set dlr "\002$bbplayer\002 is"
	}
	append out "$dlr the big blind.  Please wait...."
	puthelp $out
	set pot 0
	foreach p $players_this_round {
		set cash [dict get $settings($chan) !$p cash]
		set bet 0
		if {[string equal $p $bbplayer]} {
			if {$cash >= $bbvalue} {
				incr pot $bbvalue
				set bet $bbvalue
				incr cash -$bbvalue
			} else {
				incr pot $cash
				set bet $cash
				set cash 0
			}
		} elseif {[string equal $p $sbplayer]} {
			if {$cash >= $sbvalue} {
				incr pot $sbvalue
				set bet $sbvalue
				incr cash -$sbvalue
			} else {
				incr pot $cash
				set bet $cash
				set cash 0
			}
		}
		set cards [list [lindex $deck 0] [lindex $deck 1]]
		set deck [lreplace $deck 0 1]
		foreach val {bet cash cards} {
			dict set settings($chan) !$p $val [set $val]
		}
		set card_msg "Your cards this round:"
		foreach c $cards {
			append card_msg " [render $c]"
		}
		if {[string equal $p $botnick] || [lsearch -exact $settings(bot-players) $p] > -1} {
			if {$settings(verbose)} { putlog "[string toupper $settings(card-message-type)] $p :$card_msg" }
		} else {
			set msg_type [get_user_card_message_type $p]
			if {$settings(verbose)} { putlog "Sending cards [string toupper $msg_type] to $p: $card_msg" }
			putserv "[string toupper $msg_type] $p :$card_msg"
		}
	}
	dict set settings($chan) deck $deck
	if {$settings(verbose)} {
		putlog "Players this round: $players_this_round"
	}
	foreach var {cards phase round sbvalue bbvalue pot players_this_round has_bet skip_betting} {
		dict set settings($chan) $var [set $var]
	}
	if {$settings(verbose)} {
		putlog "At the end of deal, players_this_round: $players_this_round"
	}
	if {[llength $players_this_round] == 2} {
		set next_player $dealer
	} else {
		set next_player [get_next_player $chan $bbplayer]
	}
	dict set settings($chan) bet_round 0
	dict set settings($chan) better $next_player
	return [prompt $chan $next_player]
}
proc prompt {chan player} { 
	variable settings
	variable ns
	global botnick
	
	if {[string equal $player [dict get $settings($chan) better]]} {
		dict incr settings($chan) bet_round
	}
	foreach var {players sbplayer bbplayer sbvalue bbvalue pot phase better has_bet players_this_round skip_betting bet_round min_bet} {
		set $var [dict get $settings($chan) $var]
	}
	set cash 0
	set bets 0
	foreach p $players {
		incr cash [dict get $settings($chan) !$p cash]
		incr bets [dict get $settings($chan) !$p bet]
	}
	set total [expr {$cash + $bets}]
	set started_with [expr {[llength $players] * $settings(buy-in)}]
	set d $settings(denomination)
	if {$total != $started_with} {
		set cashval $cash
		set betsval $bets
		set totalval $total
		set startedval $started_with
		set dval $d
		set cashstr [string cat $dval $cashval]
		set betsstr [string cat $dval $betsval]
		set totalstr [string cat $dval $totalval]
		set startedstr [string cat $dval $startedval]
		set msg [format "PRIVMSG %s :1. Cash = %s; Bets = %s.  Total = %s.  %s != %s.  Stopping the game." $chan $cashstr $betsstr $totalstr $totalstr $startedstr]
		puthelp $msg
		stop $chan
	} elseif {$bets != $pot} {
		set betsval $bets
		set potval $pot
		set dval $d
		set betsstr [string cat $dval $betsval]
		set potstr [string cat $dval $potval]
		set msg [format "PRIVMSG %s :2. Bets = %s.  Pot = %s.  %s != %s.  Stopping the game." $chan $betsstr $potstr $betsstr $potstr]
		puthelp $msg
		foreach p $players {
			set betval [dict get $settings($chan) !$p bet]
			set betstr [string cat $dval $betval]
			putlog "$p bet: $betstr"
		}
		stop $chan
	} else {
		set total [expr {$cash + $pot}]
		if {$total != $started_with} {
			set cashval $cash
			set potval $pot
			set totalval $total
			set startedval $started_with
			set dval $d
			set cashstr [string cat $dval $cashval]
			set potstr [string cat $dval $potval]
			set totalstr [string cat $dval $totalval]
			set startedstr [string cat $dval $startedval]
			set msg [format "PRIVMSG %s :3. Cash = %s; Pot = %s.  Total = %s.  %s != %s.  Stopping the game." $chan $cashstr $potstr $totalstr $totalstr $startedstr]
			puthelp $msg
			stop $chan
		}
	}
	if {$skip_betting} { return [start_next_phase $chan] }
	set d $settings(denomination)
	set bet [dict get $settings($chan) !$player bet]
	set cash [dict get $settings($chan) !$player cash]
	set diff [get_diff $chan $player]
	if {$settings(verbose)} { putlog "Prompting $player.  Pot: $pot; Cash: $cash; Bet: $bet" }
	set output "PRIVMSG $chan :\00304\002\002$player\003: "
	if {[string equal $phase deal] && $bet_round == 1} {
		if {[string equal $player $bbplayer]} {
			append output "You are the \00311big blind\003.  "
			if {!$diff} {
				set has_cash [list]
				foreach p $players_this_round {
					if {[dict get $settings($chan) !$p cash]} {
						lappend has_cash $p
					}
				}
				if {[llength $has_cash] == 1 && [string equal [lindex $has_cash 0] $player]} {
					if {[string equal $player $botnick]} {
						puthelp "PRIVMSG $chan :\001ACTION checks.\001"
					} else {
						puthelp "PRIVMSG $chan :$player checks."
					}
					return [start_next_phase $chan]
				}
			}
		} elseif {[string equal $player $sbplayer]} {
			append output "You are the \00311small blind\003.  "
		}
	}
	if {$bet && !$cash} {
		append output "You are all-in."
		dict lappend settings($chan) has_bet $player
		if {[string equal $player $botnick]} {
			puthelp "PRIVMSG $chan :\001ACTION is all-in.\001"
		} else {
			puthelp $output
		}
		if {[string length [set next [get_next_player $chan $player]]]} {
			return [prompt $chan $next]
		} else {
			return [start_next_phase $chan]
		}
	}
	set diff [get_diff $chan $player]
	set bid [expr {$diff + $bet}]
	set potval $pot
	set bidval $bid
	set cashval $cash
	set diffval $diff
	set minbetval $min_bet
	set dval $d
	set potstr [string cat $dval $potval]
	set bidstr [string cat $dval $bidval]
	set cashstr [string cat $dval $cashval]
	set diffstr [string cat $dval $diffval]
	set minbetstr [string cat $dval $minbetval]
	append output "The current pot is worth "
	append output $potstr
	append output ".  "
	if {$diff} {
		append output "The bet is now at "
		append output $bidstr
		append output ".  "
	}
	append output "You have "
	append output $cashstr
	append output " remaining.  "
	if {$diff >= $cash} {
		append output "You must go all-in to stay in.  "
	} elseif {$diff} {
		append output "You can call for \00311"
		append output $diffstr
		append output "\003 to stay in.  "
	}
	append output "If you wish to raise, the minimum raise is \00311"
	append output $minbetstr
	append output "\003.  "
	if {$diff} {
		append output "Do you wish to \002call\002, \002raise\002, or \002fold\002?  If \002raise\002, how much (or \002all-in\002)?"
	} else {
		append output "Do you wish to \002check\002, \002raise\002, or \002fold\002?  If \002raise\002, how much (or \002all-in\002)?"
	}
	append output " Or if you need me to show you your \002cards\002 again, just ask."
	dict set settings($chan) waiting_for $player
	bind pubm * $chan* ${ns}::take_bet
	if {[string equal $player $botnick] || [lsearch -exact $settings(bot-players) $player] > -1} {
		bot_play $chan $player
		return
	} else {
		puthelp $output
		return
	}
}
bind dcc mn peek ${ns}::peek
proc peek {hand idx txt} { 
	variable settings
	variable hand_name
	foreach chan [array names settings] {
		if {![string match \#* $chan]} {
			continue
		}
		set deck [dict get $settings($chan) deck]
		set phase [dict get $settings($chan) phase]
		foreach p [dict get $settings($chan) players_this_round] {
			if {[string equal $phase deal]} {
				set cards [list]
			} else {
				set cards [dict get $settings($chan) cards]
			}
			set tmpdeck $deck
			while {[llength $cards] < 5} {
				lappend cards [lindex $tmpdeck 0]
				set tmpdeck [lreplace $tmpdeck 0 0]
			}
			set cards [concat [dict get $settings($chan) !$p cards] $cards]
			foreach {rank player res} [hand $cards $p] {
				set out "$player: $hand_name($rank)"
				foreach c $res {
					append out " [render $c]"
				}
				putlog $out
			}
		}
	}
}
proc all_in {chan nick} {
	variable settings
	global botnick
	set diff [get_diff $chan $nick]
	set bet [dict get $settings($chan) !$nick bet]
	set cash [dict get $settings($chan) !$nick cash]
	incr bet $cash
	dict incr settings($chan) pot $cash
	dict set settings($chan) !$nick bet $bet
	dict set settings($chan) !$nick cash 0
	dict set settings($chan) checks 0
	set d $settings(denomination)
	if {$cash > $diff} {
		dict set settings($chan) has_bet [list $nick]
	} else {
		dict lappend settings($chan) has_bet $nick
	}
	if {![string equal $nick $botnick]} {
		set out "PRIVMSG $chan :OK, $nick is \00313all-in\003"
		if {$cash > $diff} {
			set cashval $cash
			set betval $bet
			set dval $d
			set cashstr [string cat $dval $cashval]
			set betstr [string cat $dval $betval]
			append out "\002\002, raising the bet by \00311"
			append out $cashstr
			append out "\003 to \00311"
			append out $betstr
			append out "\003"
		}
		append out "."
		puthelp $out
	}
}
proc call {chan nick} { 
	variable settings
	global botnick
	set diff [get_diff $chan $nick]
	set bet [dict get $settings($chan) !$nick bet]
	set cash [dict get $settings($chan) !$nick cash]
	dict incr settings($chan) pot $diff
	incr bet $diff
	incr cash -$diff
	dict set settings($chan) !$nick bet $bet
	dict set settings($chan) !$nick cash $cash
	dict lappend settings($chan) has_bet $nick
	set d $settings(denomination)
	if {![string equal $nick $botnick]} {
		set diffval $diff
		set dval $d
		set diffstr [string cat $dval $diffval]
		set msg [format "PRIVMSG %s :OK, %s throws in %s and \00311calls\003." $chan $nick $diffstr]
		puthelp $msg
	}
}
proc raise {chan nick match} { 
	variable settings
	global botnick
	set diff [get_diff $chan $nick]
	set bet [dict get $settings($chan) !$nick bet]
	set cash [dict get $settings($chan) !$nick cash]
	dict set settings($chan) min_bet $match
	dict set settings($chan) checks 0
	incr match $diff
	dict incr settings($chan) pot $match
	incr bet $match
	incr cash -$match
	dict set settings($chan) !$nick bet $bet
	dict set settings($chan) !$nick cash $cash
	set d $settings(denomination)
	if {$match > $diff} {
		dict set settings($chan) has_bet [list $nick]
	} else {
		dict lappend settings($chan) has_bet $nick
	}
	if {![string equal $nick $botnick]} {
		set out "PRIVMSG $chan :$nick "
		if {$diff} {
			set diffval $diff
			set dval $d
			set diffstr [string cat $dval $diffval]
			append out "sees the remaining "
			append out $diffstr
		}
		set remainder [expr {$match - $diff}]
		if {$diff && $remainder} {
			append out ", and "
		} elseif {$diff} {
			append out "."
		}
		if {$remainder} {
			append out "\00313raises\003 the bet by "
			if {$diff} {
				append out "an additional "
			}
			set raiseval [expr {$match - $diff}]
			set betval [dict get $settings($chan) !$nick bet]
			set dval $d
			set raisestr [string cat $dval $raiseval]
			set betstr [string cat $dval $betval]
			append out "\00311"
			append out $raisestr
			append out "\003 to a total of "
			append out $betstr
			append out "."
		}
		puthelp $out
	}
}
proc dec2pct {what} {
	set what [expr {int(1000 * $what) * 0.1}]
	return [regsub {000000+\d$} $what ""]%
}
proc get_odds {chan nick} {
	# returns an array.  Should be called via "array set odds [get_odds 
	# $chan $nick]" or similar
	variable settings
	variable newdeck
	variable hand_name
	set deck $newdeck
	set players_this_round [llength [dict get $settings($chan) players_this_round]]
	set my_cards [dict get $settings($chan) !$nick cards]
	set all_cards [concat $my_cards [dict get $settings($chan) cards]]
	set undealt [expr {7 - [llength $all_cards]}]
	array set ret [list]
	if {[llength $all_cards] < 5} { return }
	foreach {rank nick my_hand} [hand $all_cards $nick] {}
	array set o {1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0}
	set outs 0
	foreach c $all_cards {
		set idx [lsearch -exact $deck $c]
		set deck [lreplace $deck $idx $idx]
	}
	foreach c $deck {
		set whatif $all_cards
		lappend whatif $c
		foreach {r n h} [hand $whatif $nick] {}
		foreach mc $my_cards {
			if {[lsearch $h $mc] > -1 && $r > $rank && $r > 1} {
				incr outs
				incr o($r)
			}
			break
		}
	}
	if {$outs} {
		foreach n [array names o] {
			if {$n > $rank && $o($n)} {
			set chance [prob $undealt 1 $o($n) [llength $deck]]
				if {$chance >= 0.001} {
					set ret($n) $chance
				}
			}
		}
	}
	set better 0
	set iter 0
	switch $undealt {
		0 { set lst {0 1} }
		1 { set lst {0 1 2} }
		2 { set lst {0 1 2 3} }
		default { set lst {0 1} }
	}
	set deck [make_deck_manageable $lst $all_cards $deck]
	while {[lindex $lst end]} {
		incr iter
		if {!($iter % 10000)} {
			putlog "Running ${iter}th simulation..."
		}
		set whatif [dict get $settings($chan) cards]
		foreach idx $lst {
			lappend whatif [lindex $deck $idx]
		}
		foreach {r n h} [hand $whatif opponent] {}
		if {$r > $rank} {
			incr better
		} elseif {$r == $rank && [lsearch [compare $h $my_hand] $h] > -1} {
			incr better
		}
		set lst [simul $lst $deck]
	}
	if {$iter == 0} {
		set p 0.0
	} else {
		set p [expr {1.0 * $better / $iter}]
	}
	# binom_dist 2 cards times players which aren't me, 2 cards needed, 
	# outs / total
	set opponent_odds [binom_dist [expr {($players_this_round - 1) * 2}] 2 $p]
	set ret(confidence) [expr {1.0 - $opponent_odds}]
	return [array get ret]
}
proc make_deck_manageable {lst all_cards deck} {
	if {[llength $lst] > 2} {
		set deck [list]
		for {set i 2} {$i < 15} {incr i} {
			set c [list]
			set S {S H C D}
			while {[llength $S] && ![llength $c]} {
				set idx [rand [llength $S]]
				set s [lindex $S $idx]
				set S [lreplace $S $idx $idx]
				if {[lsearch $all_cards [list $i $s]] < 0} {
					set c [list $i $s]
					break
				}
			}
			lappend deck $c
		}
	}
	return $deck
}
proc simul {lst deck} {
	# lst = index numerals -- i.e. 0 1 2 3 for [lindex $deck idx0] 
	# [lindex $deck idx1] etc
	for {set i [expr {[llength $lst] - 1}]} {$i > -1} {incr i -1} {
		set last [expr {[lindex $lst $i] + 1}]
		set lst [lreplace $lst $i $i $last]
		if {$last < [expr {[llength $deck] - ([llength $lst] - 1 - $i)}]} {
			for {set j [expr {$i + 1}]; set k [expr {$last + 1}]} {$j < [llength $lst]} {incr j; incr k} {
				set lst [lreplace $lst $j $j $k]
			}
			return $lst
		}
	}
	return 0
}
proc compare {args} {
	array set w [list]
	set sortme [list]
	for {set i 0} {$i < [llength $args]} {incr i} {
		set l [lindex $args $i]
		set h [list]
		foreach c $l {
			lappend h [lindex $c 0]
		}
		lappend w($h) [lindex $args $i]
		lappend sortme $h
	}
	set sortme [lsort -int -dec -index 0 [lsort -int -dec -index 1 [lsort -int -dec -index 2 [lsort -int -dec -index 3 [lsort -int -dec -index 4 $sortme]]]]]
	return $w([lindex $sortme 0])
}
proc binom {n k} {
	set k [expr {(($n-$k) > $k) ? $n-$k : $k}]
	if {$k > $n} { return 0 }
	if {$k == $n} { return 1 }
	set res 1
	set d 0
	while {$k < $n} {
		set res [expr {($res*[incr k])/[incr d]}]
	}
	set res
}
# P(X = k) = (n,k) * p^k * (1 - p)^(n - k)
proc binom_dist {n success p} {
	# n = cards to be drawn success = cards needed for success p = 
	# decimal value of likelihood of success (outs / unseen cards)
	set res 0
	for {set k $n} {$k >= $success} {incr k -1} {
		set b [expr {1.0 * [binom $n $k] * pow($p, $k) * pow((1.0 - $p), ($n - $k))}]
		set res [expr {$b + $res}]
	}
	#set p [expr {1.0 * $outs / $total}] expr {1.0 * [binom $n $k] * 
	#pow($p, $k) * pow((1.0 - $p), ($n - $k))}
	return $res
}
proc prob {draws needed outs {decksize 0}} {
	if {$decksize} {
		set p [expr {1.0 * $outs / $decksize}]
	} else {
		set p $outs
	}
	binom_dist $draws $needed $p
}
proc countdown_timeout {chan} { 
	variable settings
	variable ns
	global botnick
	
	set nick [dict get $settings($chan) waiting_for]
	set ns_name [namespace current]
	catch {unbind pubm * $chan* ${ns_name}::force_fold}
	
	foreach t [utimers] {
		if {[string equal [lindex $t 1] [list ${ns_name}::hurry_up $chan]]} {
			killutimer [lindex $t 2]
		}
	}
	set players [dict get $settings($chan) players]
	set humans 0 
	foreach p $players {
		if {![string equal $p $botnick] && [lsearch $settings(bot-players) $p] < 0} {
			incr humans
		}
	}
	if {$humans < 2} { return }
	set t [expr {$settings(timeout) + ([queuesize help] * 2)}]
	utimer $t [list ${ns}::hurry_up $chan]
}
proc hurry_up {chan} { 
	variable settings
	variable ns
	
	set nick [dict get $settings($chan) waiting_for]
	puthelp "PRIVMSG $chan :...$nick is taking forever to make a decision.  Shall I make $nick fold?"
	
	# Get namespace name safely
	set ns_name [namespace current]
	bind pubm * $chan* ${ns_name}::force_fold
}
proc force_fold {nick uhost hand chan txt} { 
	variable settings
	variable ns
	
	# Check if channel is valid and game exists
	if {![validchan $chan] || ![info exists settings($chan)]} {
		return 0
	}
	
	# Get namespace name safely
	set ns_name [namespace current]
	
	# Get waiting_for and players with error handling
	if {[catch {
		set waiting_for [dict get $settings($chan) waiting_for]
		set players [dict get $settings($chan) players]
	} err]} {
		return 0
	}
	
	if {[string equal $waiting_for $nick]} {
		return 0
	}
	
	if {[lsearch $players $nick] < 0} {
		return 0
	}
	
	if {[regexp -nocase {\y(yes|yep|do it|absolutely|uh huh|sure|affirmative)\y} $txt]} {
		take_bet $waiting_for - - $chan fold
	} elseif {![regexp -nocase {\y(no|don't|nah)} $txt]} {
		return 0
	}
	
	catch {unbind pubm * $chan* ${ns_name}::force_fold}
	return 0
}
proc take_bet {nick uhost hand chan txt} { 
	variable settings
	variable ns
	variable hand_name
	global botnick
	
	if {$settings(verbose)} {
		putlog "proc take_bet $nick $uhost $hand $chan $txt"
	}
	
	# Check if channel is valid and game exists
	if {![validchan $chan] || ![info exists settings($chan)]} {
		return 0
	}
	
	# Get namespace name safely
	set ns_name [namespace current]
	
	# Get waiting_for with error handling
	if {[catch {set waiting_for [dict get $settings($chan) waiting_for]} err]} {
		return 0
	}
	
	if {![string equal $waiting_for $nick]} {
		return 0
	}
	
	# if $txt contains a nick in the channel other than the bot's nick 
	# avoid using the number in someone's nick as a bet value.
	set rxp [regexp -inline -all -nocase -- {\y[a-z0-9\x5B-\x60\x7B-\x7D]+\y} $txt]
	foreach m $rxp {
		if {[onchan $m $chan] && [regexp {\d} $m]} {
			return 0
		}
	}
	
	catch {unbind pubm * $chan* ${ns_name}::take_bet}
	
	# Get game variables with error handling
	if {[catch {
		foreach var {pot phase players players_this_round has_bet bbvalue min_bet} {
			set $var [dict get $settings($chan) $var]
		}
		foreach var {cash bet} {
			set $var [dict get $settings($chan) !$nick $var]
		}
	} err]} {
		return 0
	}
	set d $settings(denomination)
	set diff [get_diff $chan $nick]
	set bid [expr {$diff + $bet}]
	countdown_timeout $chan
	if {[string match -nocase *cards* $txt]} {
		set card_msg "You are holding these cards:"
		set cards [dict get $settings($chan) !$nick cards]
		foreach c $cards {
			append card_msg " [render $c]"
		}
		if {![string equal $phase deal]} {
			set cards [concat $cards [dict get $settings($chan) cards]]
			set h [hand $cards $nick]
			set rank $hand_name([lindex $h 0])
			append card_msg " As it stands, your cards earn you \002$rank\002"
			array set odds [get_odds $chan $nick]
			if {[array size odds]} {
				foreach el [lsort -dict [array names odds]] {
					if {[string is integer $el]} { 
						append card_msg "; chance of getting $hand_name($el): \002[dec2pct $odds($el)]\002"
					}
				}
				append card_msg "; confidence in your winning this hand: \002[dec2pct $odds(confidence)]\002"
			} else {
				append card_msg "."
			}
		}
		set msg_type [get_user_card_message_type $nick]
		if {$settings(verbose)} { putlog "Sending cards [string toupper $msg_type] to $nick: $card_msg" }
		putserv "[string toupper $msg_type] $nick :$card_msg"
		bind pubm * $chan* ${ns_name}::take_bet
		return 0
	} elseif {[regexp -nocase {^\yall[\s-]*in\y|\yall\y$} $txt]} {
		if {![string equal $nick $botnick] && [lsearch $settings(bot-players) $nick] < 0} { clearqueue help } 
		all_in $chan $nick
	} elseif {[regexp -nocase {^(\w* *)?[0-9\,]+} $txt match]} {
		if {![string equal $nick $botnick] && [lsearch $settings(bot-players) $nick] < 0} { clearqueue help } 
		regexp {\d+} [string map {, ""} $match] match
		if {[expr {$match + $diff}] > $cash} {
			all_in $chan $nick
		} elseif {!$match} {
			call $chan $nick
		} elseif {$match < $min_bet} {
			set minbetval $min_bet
			set dval $d
			set minbetstr [string cat $dval $minbetval]
			set msg "PRIVMSG $chan :\001ACTION sighs and waits for a raise of at least \002"
			append msg $minbetstr
			append msg "\002 from $nick.\001"
			puthelp $msg
			bind pubm * $chan* ${ns}::take_bet
			return 0
		} else {
			raise $chan $nick $match
		}
	} elseif {[regexp -nocase {^\y(raise|bet)\y} $txt]} {
		puthelp "PRIVMSG $chan :$nick: OK, how much would you like to bet?"
		bind pubm * $chan* ${ns}::take_bet
		return 0
	} elseif {[regexp -nocase {^\ycall\y} $txt]} {
		if {![string equal $nick $botnick] && [lsearch $settings(bot-players) $nick] < 0} { clearqueue help }
		if {!$diff} {
			dict lappend settings($chan) has_bet $nick
			if {![string equal $nick $botnick]} {
				puthelp "PRIVMSG $chan :OK, $nick \00311checks\003."
			}
		} elseif {$diff > $cash} {
			all_in $chan $nick
		} else {
			call $chan $nick
		}
	} elseif {[regexp -nocase {^\ycheck\y} $txt]} {
		if {![string equal $nick $botnick] && [lsearch $settings(bot-players) $nick] < 0} { clearqueue help }
		if {$diff} {
			puthelp "PRIVMSG $chan :$nick: You haven't met the minimum bid.  You must either call, raise or fold."
			bind pubm * $chan* ${ns}::take_bet
			return 0
		} else {
			dict lappend settings($chan) has_bet $nick
			dict incr settings($chan) checks
			if {![string equal $nick $botnick]} {
				puthelp "PRIVMSG $chan :OK, $nick \00311checks\003."
			}
		}
	} elseif {[regexp -nocase {^\yfold\y} $txt]} {
		if {![string equal $nick $botnick]} {
			if {[lsearch $settings(bot-players) $nick] < 0} {
				clearqueue help
			}
			set cashval $cash
			set dval $d
			set cashstr [string cat $dval $cashval]
			set out "PRIVMSG $chan :$nick "
			append out "\026folds\026, saving "
			append out $cashstr
			append out " for better cards.  "
		} else {
			set out "PRIVMSG $chan :"
		}
		set idx [lsearch $players_this_round $nick]
		set players_this_round [lreplace $players_this_round $idx $idx]
		set idx [lsearch $has_bet $nick]
		if {$idx > -1} {
			set has_bet [lreplace $has_bet $idx $idx]
		}
		if {$settings(verbose)} {
			putlog "$nick folds.  players_this_round: $players_this_round"
		}
		foreach var {players_this_round has_bet} {
			dict set settings($chan) $var [set $var]
		}
		if {[llength $players_this_round] == 1} {
			if {[string equal $nick $botnick] || [lsearch $settings(bot-players) $nick] > -1} {
				set confidence [dict get $settings($chan) !$nick confidence]
				dict set settings($chan) !$nick confidence [expr {$confidence - 1}]
			}
			set p [lindex $players_this_round 0]
			set cash [dict get $settings($chan) !$p cash]
			incr cash $pot
			if {[string equal $p $botnick] || [lsearch $settings(bot-players) $p] > -1} {
				set confidence [dict get $settings($chan) !$p confidence]
				dict set settings($chan) !$p confidence [expr {$confidence + 1}]
			}
			# Track hand won for rankings (only for human players)
			if {![string equal $p $botnick] && [lsearch $settings(bot-players) $p] < 0} {
				update_player_stats $p 0 0 1
			}
			if {[string equal $p $botnick]} {
				append out "\00304I win the hand.\003"
			} else {
				append out "\00304$p wins the hand.\003"
			}
			puthelp $out
			dict set settings($chan) !$p cash $cash
			dict set settings($chan) phase score
			return [start_next_phase $chan]
		}
		puthelp $out
	} else {
		bind pubm * $chan* ${ns}::take_bet
		return 0
	}
	
	if {$settings(verbose)} {
		putlog "Took bet from $nick.  Pot: $pot; Cash: $cash; Bet: $bet; Has_bet: $has_bet"
		foreach p [dict get $settings($chan) players] {
			set betval [dict get $settings($chan) !$p bet]
			set dval $d
			set betstr [string cat $dval $betval]
			putlog "$p bet: $betstr"
		}
	}
	
	while {[lsearch -exact $players_this_round $nick] == -1} {
		set idx [lsearch -exact $players $nick]
		if {!$idx} {
			set nick [lindex $players end]
		} else {
			set nick [lindex $players [expr {$idx - 1}]]
		}
	}
	if {[string length [set p [get_next_player $chan $nick]]]} {
		return [prompt $chan $p]
	} else {
		return [start_next_phase $chan]
	}
}
proc start_next_phase {chan} { 
	variable settings
	variable ns
	global botnick
	if {$settings(verbose)} {
		putlog "proc start_next_phase $chan"
	}
	foreach val {phase players_this_round players bbvalue} {
		set $val [dict get $settings($chan) $val]
	}
	set has_cash 0
	foreach p $players_this_round {
		set l [dict get $settings($chan) !$p bet]
		set limit $l
		foreach p2 $players {
			if {$p2 != $p} {
				set l2 [dict get $settings($chan) !$p2 bet]
				if {$l > $l2} {
					incr limit $l2
				} else {
					incr limit $l
				}
			}
		}
		dict set settings($chan) !$p limit $limit
		if {[dict get $settings($chan) !$p cash]} {
			incr has_cash
		}
	}
	if {$has_cash < 2 && ![dict get $settings($chan) skip_betting] && [llength $players_this_round] > 1 && ![regexp {(river|score)} $phase]} {
		dict set settings($chan) skip_betting 1
		foreach p $players_this_round {
			set out "PRIVMSG $chan :$p's cards:"
			set C [dict get $settings($chan) !$p cards]
			foreach c $C {
				append out " [render $c]"
			}
			puthelp $out
		}
	}
	dict set settings($chan) bet_round 0
	dict set settings($chan) phase $phase
	dict set settings($chan) has_bet [list]
	dict set settings($chan) min_bet $bbvalue
	switch $phase {
		deal { set phase flop }
		flop { set phase turn }
		turn { set phase river }
		river { set phase score }
		score { set phase deal }
	}
	dict set settings($chan) phase $phase
	if {[string equal $phase deal]} {
		set humans 0
		foreach p $players {
			if {[lsearch -exact $settings(bot-players) $p] > -1 || [string equal $p $botnick]} {
				continue
			}
			if {[dict get $settings($chan) !$p cash]} {
				incr humans
				break
			}
		}
		if {!$humans} {
			puthelp "PRIVMSG $chan :The last human player has busted out.  Do you want to keep watching me play with myself?"
			bind pubm * $chan* ${ns}::keep_watching
			return
		}
	}
	if {[catch {$phase $chan} err]} {
		putlog $err
	}
}
proc keep_watching {nick uhost hand chan txt} { 
	variable ns
	
	# Check if channel is valid
	if {![validchan $chan]} {
		return 0
	}
	
	# Get namespace name safely
	set ns_name [namespace current]
	
	if {[string match -nocase *no* $txt]} {
		unbind pubm * $chan* ${ns_name}::keep_watching
		puthelp "PRIVMSG $chan :k.  Whatever."
		catch {stop $chan}
	} elseif {[string match -nocase *yes* $txt]} {
		unbind pubm * $chan* ${ns_name}::keep_watching
		catch {deal $chan}
	}
	return 0
}
proc flop {chan} { 
	variable settings
	if {$settings(verbose)} {
		putlog "proc flop $chan"
	}
	foreach var {players dealer bbplayer deck} {
		set $var [dict get $settings($chan) $var]
	}
	set cards [list [lindex $deck 0] [lindex $deck 1] [lindex $deck 2]]
	set deck [lreplace $deck 0 2]
	dict set settings($chan) deck $deck
	dict set settings($chan) cards $cards
	set out "PRIVMSG $chan :The flop:"
	foreach c $cards {
		append out " [render $c]"
	}
	puthelp $out
	
	set next_player [get_next_player $chan $dealer]
	
	prompt $chan $next_player
}
proc turn {chan} { 
	variable settings
	if {$settings(verbose)} {
		putlog "proc turn $chan"
	}
	foreach var {players dealer bbplayer deck cards} {
		set $var [dict get $settings($chan) $var]
	}
	set cards [concat $cards [list [lindex $deck 0]]]
	set deck [lreplace $deck 0 0]
	dict set settings($chan) deck $deck
	dict set settings($chan) cards $cards
	set out "PRIVMSG $chan :The turn:"
	foreach c $cards {
		append out " [render $c]"
	}
	puthelp $out
	
	set next_player [get_next_player $chan $dealer]
	
	prompt $chan $next_player
}
proc river {chan} { 
	variable settings
	if {$settings(verbose)} {
		putlog "proc river $chan"
	}
	foreach var {players dealer bbplayer deck cards} {
		set $var [dict get $settings($chan) $var]
	}
	set cards [concat $cards [list [lindex $deck 0]]]
	set deck [lreplace $deck 0 0]
	dict set settings($chan) deck $deck
	dict set settings($chan) cards $cards
	set out "PRIVMSG $chan :The river:"
	foreach c $cards {
		append out " [render $c]"
	}
	puthelp $out
	
	set next_player [get_next_player $chan $dealer]
	
	prompt $chan $next_player
}
proc score {chan} { 
	variable settings
	variable hand_name
	variable ns
	global botnick
	if {$settings(verbose)} {
		putlog "proc score $chan"
	}
	foreach var {players players_this_round cards pot} {
		set $var [dict get $settings($chan) $var]
	}
	set hands [list]
	set has_cash -2
	foreach p $players {
		if {[dict get $settings($chan) !$p cash]} {
			incr has_cash
		}
	}
	foreach p $players_this_round {
		set mycards [concat $cards [dict get $settings($chan) !$p cards]]
		set h [hand $mycards $p]
		lappend hands $h
		set out "PRIVMSG $chan :$p had $hand_name([lindex $h 0]):"
		foreach card [lindex $h 2] {
			append out " [render $card]"
		}
		if {[string equal $p $botnick] || [lsearch $settings(bot-players) $p] > -1} {
			set confidence [dict get $settings($chan) !$p confidence]
			dict set settings($chan) !$p confidence [expr {$confidence - 1}]
		}
		puthelp $out
	}
	set hands [lsort -integer -index 0 -decreasing $hands]
	set pot_total $pot
	set d $settings(denomination)
	set out "PRIVMSG $chan :"
	while {$pot && [llength $hands]} {
		set winning_score [lindex [lindex $hands 0] 0]
		set top [list [lindex $hands 0]]
		for {set i 1} {$i < [llength $players_this_round]} {incr i} {
			if {$winning_score > [lindex [lindex $hands $i] 0]} {
				break
			}
			lappend top [lindex $hands $i]
		}
		array set winnars [list]
		set sortme [list]
		foreach h $top {
			set C [lindex $h 2]
			set v [list]
			foreach c $C {
				lappend v [lindex $c 0]
			}
			if {![info exists winnars($v)] || [lsearch $winnars($v) [lindex $h 1]] == -1} {
				lappend winnars($v) [lindex $h 1]
			}
			lappend sortme $v
		}
		set sortme [lsort -int -dec -index 0 [lsort -int -dec -index 1 [lsort -int -dec -index 2 [lsort -int -dec -index 3 [lsort -int -dec -index 4 $sortme]]]]]
		set winning_hand [lindex $sortme 0]
		if {[llength $winnars($winning_hand)] > 1} {
			append out "[list2pretty $winnars($winning_hand)] split the pot.  "
		}
		# in case of split, even out the bets to avoid penalizing 
		# someone who went all-in when he didn't have to
		set num_win [llength $winnars($winning_hand)]
		set p [list]
		array set pre [list]
		foreach w $winnars($winning_hand) {
			lappend p [list $w [dict get $settings($chan) !$w bet]]
			set pre($w) 0
		}
		set p [lsort -int -index 1 $p]
		for {set i 0} {$pot && $i < [expr {$num_win - 1}]} {incr i} {
			set j [expr {$i + 1}]
			set this [lindex $p $i]
			set next [lindex $p $j]
			set name [lindex $next 0]
			set val [lindex $next 1]
			set cash [dict get $settings($chan) !$name cash]
			set diff [expr {$val - [lindex $this 1]}]
			if {$pot < $diff} {
				set diff $pot
			}
			incr cash $diff
			incr pot -$diff
			incr pre($name) $diff
			dict set settings($chan) !$name cash $cash
			set next [lreplace $next 1 1 [lindex $this 1]]
			set p [lreplace $p $j $j $next]
		}
		set potential [expr {int(ceil(1.0 * $pot / $num_win))}] 
		foreach winnar $winnars($winning_hand) {
			# Track hand won for rankings (only for human players)
			if {![string equal $winnar $botnick] && [lsearch $settings(bot-players) $winnar] < 0} {
				update_player_stats $winnar 0 0 1
			}
			for {set i 0} {$i < [llength $hands]} {incr i} {
				if {[string equal [lindex [lindex $hands $i] 1] $winnar]} {
					set hands [lreplace $hands $i $i] 
					break
				}
			}
			foreach var {limit cash bet} {
				set $var [dict get $settings($chan) !$winnar $var]
			}
			if {$potential > $pot} {
				set potential $pot
			}
			if {$potential > $limit} {
				set winnings $limit
			} else {
				set winnings $potential
			}
			incr pot -$winnings
			incr cash $winnings
			incr pre($winnar) $winnings
			
			if {$pre($winnar) > $bet} {
				if {[string equal $winnar $botnick] || [lsearch $settings(bot-players) $winnar] > -1} {
					set confidence [dict get $settings($chan) !$winnar confidence]
					dict set settings($chan) !$winnar confidence [expr {$confidence + 3}]
				}
				set preval [set pre($winnar)]
				set dval $d
				set prestr [string cat $dval $preval]
				append out $winnar
				append out " wins "
				append out $prestr
				append out ".  "
			} else {
				set preval [set pre($winnar)]
				set dval $d
				set prestr [string cat $dval $preval]
				append out $winnar
				append out " recovers "
				append out $prestr
				append out ".  "
			}
			dict set settings($chan) !$winnar cash $cash
		}
	}
	
	if {$pot} {
		append out "I ended up with $pot left over that I wasn't sure what to do with.  I'll just keep it I guess, and prolly crash the game or something."
	}
	set has_cash [list]
	set total_cash 0
	set losers [list]
	foreach p $players {
		set cash [dict get $settings($chan) !$p cash]
		if {$cash} {
			lappend has_cash $p
			incr total_cash $cash
		} else {
			lappend losers $p
		}
	}
	if {[llength $has_cash] == 1} {
		set winner [lindex $has_cash 0]
		set totalcashval $total_cash
		set dval $d
		set totalcashstr [string cat $dval $totalcashval]
		set msg [format "PRIVMSG %s :\002%s\002 wins the game with \00311%s\003!" $chan $winner $totalcashstr]
		puthelp $msg
		# Update rankings: winner gets +369 points and game won tracked
		variable rankings
		if {![string equal $winner $botnick] && [lsearch $settings(bot-players) $winner] < 0} {
			update_player_stats $winner 369 1 0
		}
		# All losers get -128 points (points can go negative)
		foreach loser $losers {
			if {![string equal $loser $botnick] && [lsearch $settings(bot-players) $loser] < 0} {
				update_player_stats $loser -128 0 0
			}
		}
		${ns}::stop $chan
	} else {
		puthelp $out
		dict set settings($chan) folds 0
		start_next_phase $chan
	}
}
proc straight_flush {lst} {
	return [flush [straight $lst]]
}
proc four_of_a_kind {lst} {
	array set f [list]
	set lst [lsort -integer -index 0 -decreasing $lst]
	for {set i 0} {$i < [llength $lst]} {incr i} {
		lappend f([lindex [lindex $lst $i] 0]) [lindex $lst $i]
	}
	foreach val [lsort -integer -decreasing [array names f]] {
		if {[llength $f($val)] > 3} {
			while {[llength $f($val)] < 5 && [llength $lst]} { 
				if {[lindex [lindex $lst 0] 0] != [lindex [lindex $f($val) 0] 0]} {
					lappend f($val) [lindex $lst 0]
				}
				set lst [lreplace $lst 0 0]
			}
			return $f($val)
		}
	}
	return [list]
}
proc full_house {lst} {
	set lst [lsort -integer -index 0 -decreasing $lst]
	set first [three_of_a_kind $lst]
	if {[llength $first]} {
		set first [lrange $first 0 2]
		foreach card $first {
			set idx [lsearch -exact $lst $card]
		set lst [lreplace $lst $idx $idx]
		}
		set last [one_pair $lst]
		if {[llength $last]} {
			set last [lrange $last 0 1]
			return [concat $first $last]
		}
	}
	return [list]
}
proc flush {lst} {
	set lst [lsort -integer -index 0 -decreasing $lst]
	array set f [list]
	for {set i 0} {$i < [llength $lst]} {incr i} {
		lappend f([lindex [lindex $lst $i] 1]) [lindex $lst $i]
	}
	foreach suit [array names f] {
		if {[llength $f($suit)] > 4} {
			return [lrange $f($suit) 0 4]
		}
	}
	return [list]
}
proc straight {lst} {
	# if flush, sort by suit before value to preserve straight flush
	set f [flush $lst]
	if {[llength $f]} {
		set lst $f
	} else {
		set lst [lsort -integer -index 0 -decreasing $lst]
	}
	set card [lindex $lst 0]
	if {[lindex $card 0] == 14} {
		lappend lst [list 1 [lindex $card 1]]
	}
	for {set i 0} {$i < [expr {[llength $lst] - 4}]} {incr i} {
		set hand [list [lindex $lst $i]]
		set tmplst $lst
		for {set j $i} {$j < [expr {[llength $tmplst] - 1}]} {incr j} {
			set this_val [lindex [lindex $tmplst $j] 0]
			set next [expr {$j + 1}]
			while {$this_val == [set next_val [lindex [lindex $tmplst $next] 0]] && $next < [llength $lst]} {
				set tmplst [lreplace $tmplst $next $next]
			}
			if {[expr {$this_val - 1}] == $next_val} {
				lappend hand [lindex $tmplst $next]
			} else {
				set hand [list [lindex $tmplst $next]]
			}
			if {[llength $hand] == 5} {
				return $hand
			}
		}
	}
	return [list]
}
proc three_of_a_kind {lst} {
	array set f [list]
	set lst [lsort -integer -index 0 -decreasing $lst]
	for {set i 0} {$i < [llength $lst]} {incr i} {
		lappend f([lindex [lindex $lst $i] 0]) [lindex $lst $i]
	}
	foreach val [lsort -integer -decreasing [array names f]] {
		if {[llength $f($val)] > 2} {
			while {[llength $f($val)] < 5 && [llength $lst]} { 
				if {[lindex [lindex $lst 0] 0] != [lindex [lindex $f($val) 0] 0]} {
					lappend f($val) [lindex $lst 0]
				}
				set lst [lreplace $lst 0 0]
			}
			return $f($val)
		}
	}
	return [list]
}
proc two_pair {lst} {
	set lst [lsort -integer -index 0 -decreasing $lst]
	set first [one_pair $lst]
	if {[llength $first]} {
		set first [lrange $first 0 1]
		foreach card $first {
			set idx [lsearch -exact $lst $card]
		set lst [lreplace $lst $idx $idx]
		}
		set last [one_pair $lst]
		if {[llength $last]} {
			set last [lrange $last 0 2]
			return [concat $first $last]
		}
	}
	return [list]
}
proc one_pair {lst} {
	array set f [list]
	set lst [lsort -integer -index 0 -decreasing $lst]
	
	for {set i 0} {$i < [llength $lst]} {incr i} {
		lappend f([lindex [lindex $lst $i] 0]) [lindex $lst $i]
	}
	foreach val [lsort -integer -decreasing [array names f]] {
		if {[llength $f($val)] > 1} {
			while {[llength $f($val)] < 5 && [llength $lst]} { 
				if {[lindex [lindex $lst 0] 0] != [lindex [lindex $f($val) 0] 0]} {
					lappend f($val) [lindex $lst 0]
				}
				set lst [lreplace $lst 0 0]
			}
			return $f($val)
		}
	}
	return [list]
}
proc high_card {lst} {
	return [lrange [lsort -integer -index 0 -decreasing $lst] 0 4]
}
proc hand {lst player} {
	variable settings
	# if {$settings(verbose)} { putlog "proc hand $lst $player" }
	foreach {p rank} { straight_flush 8 four_of_a_kind 7 full_house 6 flush 5 straight 4 three_of_a_kind 3 two_pair 2 one_pair 1 high_card 0 } {
		if {![catch {$p $lst} res] && [llength $res]} {
			return [list $rank $player $res]
		}
	}
}
proc bot_raise {chan nick} {
	variable settings
	if {$settings(verbose)} {
		putlog "proc bot_raise $chan"
	}
	foreach var {bet_round bbvalue phase min_bet} {
		set $var [dict get $settings($chan) $var]
	}
	foreach var {bet cash} {
		set $var [dict get $settings($chan) !$nick $var]
	}
	set diff [get_diff $chan $nick]
	if {$bet_round < 3} {
		set raise [expr {$min_bet * $bet_round}]
	} else {
		set raise $cash
	}
	if {$settings(verbose)} {
		putlog "bot_raise $raise"
	}
	if {$raise < $diff} {
		return $diff
	}
	if {$raise > $cash} {
		return $cash
	}
	return $raise
}
proc bot_play {chan nick} {
	variable settings
	if {$settings(verbose)} {
		putlog "proc bot_play $chan"
	}
	global botnick
	foreach var {cards bbvalue phase checks players players_this_round round} {
		set $var [dict get $settings($chan) $var]
	}
	foreach var {cash bet} {
		set $var [dict get $settings($chan) !$nick $var]
	}
	set diff [get_diff $chan $nick]
	set d $settings(denomination)
	set confidence [ai $chan $nick]
	if {$settings(verbose)} { putlog "ai: $confidence" }
	if {$confidence > 50} {
		if {$settings(verbose)} { putlog "confidence > 50" }
		if {!$diff && [bluff $chan $nick]} {
			set action check
		} else {
			set action all-in
		}
	} elseif {$confidence > 40} {
		if {$settings(verbose)} { putlog "confidence > 40" }
		if {[bluff $chan $nick]} {
			if {!$diff} {
				set action check
			} else {
				set action all-in
			}
		} elseif {$bet > $cash} {
			set action call
		} else {
			set action [expr {round([bot_raise $chan $nick] * 1.5)}]
			while {$action % 5} { incr action }
		}
	} elseif {$confidence > 30} {
		if {$settings(verbose)} { putlog "confidence > 30" }
		if {!$diff || [bluff $chan $nick]} {
			set action [bot_raise $chan $nick]
		} elseif {$diff < [expr {round($cash * 0.66)}]} {
			set action call
		} else {
			if {$diff} {
				set action fold
			} else {
				set action check
			}
		}
		if {[string is integer $action] && $cash > 100 && $action > [expr {$cash * 0.75}]} {
			if {$diff} {
				set action fold
			} else {
				set action check
			}
		}
	} elseif {$confidence > 20} {
		if {$settings(verbose)} { putlog "confidence > 20" }
		if {[bluff $chan $nick]} {
			set action [bot_raise $chan $nick]
		} elseif {$diff >= $cash} {
			set action fold
		} elseif {!$diff} {
			set action [bot_raise $chan $nick]
		} elseif {$diff < [expr {round($cash * 0.34)}]} {
			set action call
		} else {
			set action [bot_raise $chan $nick]
		}
		if {[string is integer $action] && $cash > 50 && $action > [expr {$cash * 0.50}]} {
			if {$diff} {
				set action fold
			} else {
				set action check
			}
		}
	} elseif {$confidence > 10} {
		if {$settings(verbose)} { putlog "confidence > 10" }
		if {!$diff} {
			if {[bluff $chan $nick]} {
				set action [bot_raise $chan $nick]
			} else {
				set action check
			}
		} elseif {$diff >= [expr {$cash / 2}]} {
			set action fold
		} elseif {$diff >= [expr {$cash / 6}]} {
			set action call
		} else {
			set action [bot_raise $chan $nick]
		}		
		if {[string is integer $action] && $cash > 25 && $action > [expr {$cash * 0.10}]} {
			if {$diff} {
				set action fold
			} else {
				set action check
			}
		}
	} else {
		if {$settings(verbose)} { putlog "no confidence" }
		if {!$diff} {
			set action check
		} else {
			set action fold
		}
	}
	if {$settings(verbose)} { putlog "action = $action; $checks checks." }
	if {[string is integer $action]} {
		if {!$action} {
			if {!$diff} {
				set action check
			} else {
				set action $diff
			}
		} elseif {$action == $diff} {
			set action call
		}
	}
	switch $action {
		call {
			if {!$diff} {
				set action check
			} elseif {$diff >= $cash} {
				set action all-in
			}
		}
		check {
			switch $phase {
				turn {
					set checks [expr {$checks * 2}]
				}
				river {
					set checks [expr {$checks * 3}]
				}
			}
			set checks [expr {$checks >= ([llength $players_this_round] * 2 - 1) ? 1 : ([llength $players_this_round] * 2) - $checks}]
			if {!([rand 100] % $checks)} {
				set action [bot_raise $chan $nick]
				if {$action >= $cash} {
					set action all-in
				}
			}
		}
		fold {
			if {![catch {dict get $settings($chan) !$nick kamikaze} kamikaze]} {
				if {[expr {$round - $kamikaze}] > 2} {
					dict unset settings($chan) !$nick kamikaze
					dict set settings($chan) !$nick confidence [expr {[rand $settings(confidence)] + 5}]
				}
				dict set settings($chan) folds 0
				set action call
			} else {
				dict incr settings($chan) folds
				set folds [dict get $settings($chan) folds]
				set has_cash 0
				foreach p $players {
					if {[dict get $settings($chan) !$p cash] || [dict get $settings($chan) !$p bet]} {
						incr has_cash
					}
				}
				if {$folds > [expr {$has_cash * 2}] || ($folds > $has_cash && !([rand 100] % $has_cash))} {
					dict set settings($chan) !$nick kamikaze $round
					set action call
				}
			}
		}
	}
	if {[string is integer $action]} {
		if {$action >= $cash} {
			set action all-in
		} elseif {$action < 5} {
			if {!$diff} {
				set action check
			} else {
				set action fold 
			}
		}
	}
	if {[string equal $nick $botnick]} {
		set dval $d
		switch $action {
			all-in {
				set cashval $cash
				set cashstr [string cat $dval $cashval]
				set out "PRIVMSG $chan :\001ACTION throws in \00311"
				append out $cashstr
				append out "\003 and goes \00313all-in\003\002\002"
				if {$cash > $diff} {
					set raiseval [expr {$cash - $diff}]
					set raisestr [string cat $dval $raiseval]
					append out ", raising the bet by \00311"
					append out $raisestr
					append out "\003"
				}
				append out ".\001"
				puthelp $out
			}
			check {
				set cashval $cash
				set cashstr [string cat $dval $cashval]
				set msg "PRIVMSG $chan :\001ACTION guards his "
				append msg $cashstr
				append msg " and \00311checks\003.\001"
				puthelp $msg
			}
			call {
				set diffval $diff
				set cashval $cash
				set diffstr [string cat $dval $diffval]
				set cashstr [string cat $dval $cashval]
				set msg "PRIVMSG $chan :\001ACTION tosses in "
				append msg $diffstr
				append msg " from his "
				append msg $cashstr
				append msg " and \00311calls\003.\001"
				puthelp $msg
			}
			fold {
				set cashval $cash
				set cashstr [string cat $dval $cashval]
				set msg "PRIVMSG $chan :\001ACTION hangs onto his "
				append msg $cashstr
				append msg " and \026folds\026.\001"
				puthelp $msg
			}
			default {
				set out "PRIVMSG $chan :\001ACTION "
				if {$diff} {
					set diffval $diff
					set diffstr [string cat $dval $diffval]
					append out "sees the remaining "
					append out $diffstr
					append out ", and "
				}
				set actionval $action
				set actionstr [string cat $dval $actionval]
				append out "\00313raises\003\ the bet by \00311"
				append out $actionstr
				append out "\003.\001"
				puthelp $out
			}
		}
	}
	take_bet $nick - - $chan $action
}
proc ai {chan nick} { 
	variable settings
	variable newdeck
	foreach var {players_this_round phase cards} {
		set $var [dict get $settings($chan) $var]
	}
	set mycards [lsort -integer -index 0 -decreasing [dict get $settings($chan) !$nick cards]]
	set all_cards [concat $cards $mycards]
	set confidence [dict get $settings($chan) !$nick confidence]
	if {$confidence > 10} {
		set confidence [expr {round($confidence / 2)}]
		dict set settings($chan) !$nick confidence $confidence
	}
	if {[bluff $chan $nick]} {
		if {$settings(verbose)} {
			putlog "ai: bluffing."
		}
		incr confidence 10
	}
	if {[string equal $phase deal]} {
		incr confidence [expr {(5 - [llength $players_this_round]) * 5}]
		set c1v [lindex [lindex $mycards 0] 0]
		set c1s [lindex [lindex $mycards 0] 1]
		set c2v [lindex [lindex $mycards 1] 0]
		set c2s [lindex [lindex $mycards 1] 1]
		if {$c1v == $c2v} {
			incr confidence [expr {$c1v * 2}]
		}
		if {$c1s == $c2s} {
			incr confidence 5
		}
		foreach v [list $c1v $c2v] {
			incr confidence [expr {$v == 14 ? 7 : ($v > 9 ? round($c1v / 3) : round($c1v / 4))}]
		}
		if {$settings(verbose)} {
			putlog "ai: $confidence"
		}
		return $confidence
	}
	array set odds [get_odds $chan $nick]
	if {$settings(verbose)} {
		putlog "$nick confidence: $odds(confidence) + $confidence"
	}
	incr confidence [expr {$odds(confidence) > 0.95 ? 40 : $odds(confidence) > 0.90 ? 30 : round($odds(confidence) * 25)}]
	set rank [lindex [hand $all_cards $nick] 0]
	incr confidence [expr {$rank * 10}]
	if {$settings(verbose)} {
		putlog "$nick confidence: $confidence"
	}
	if {$settings(verbose)} {
		putlog "ai: $confidence"
	}
	return $confidence
}
proc bluff {chan nick} { 
	variable settings
	set confidence [dict get $settings($chan) !$nick confidence]
	set bluff [expr {$confidence > 13 ? 2 : $confidence < 0 ? 15 : 15 - $confidence}]
	if {!([rand 100] % $bluff)} {
		return true
	} else {
		return false
	}
}
proc save_rankings {} {
	variable rankings_file
	variable rankings
	if {[catch {
		set f [open $rankings_file w]
		puts $f [array get rankings]
		close $f
	} err]} {
		putlog "Error saving rankings: $err"
	}
}

proc clear_rankings {nick uhost hand chan txt} {
	variable settings
	variable rankings
	variable rankings_file
	
	# Check if channel is valid
	if {![validchan $chan]} {
		return 0
	}
	
	# Check ignore flags
	if {[catch {matchattr $hand $settings(ignore-flags) $chan} result] || $result} {
		return 0
	}
	
	# Check if user is channel operator (not matchattr, must be actual channel op)
	if {![isop $nick $chan]} {
		return 0
	}
	
	# Clear all rankings
	array unset rankings
	array set rankings {}
	
	# Save empty rankings
	if {[catch {
		set f [open $rankings_file w]
		puts $f ""
		close $f
	} err]} {
		putlog "Error clearing rankings: $err"
		puthelp "PRIVMSG $chan :Error clearing rankings: $err"
		return 0
	}
	
	puthelp "PRIVMSG $chan :Rankings have been cleared by $nick."
	putlog "Hold 'Em rankings cleared by $nick ($hand)"
	return 0
}

proc check_monthly_reset {minute hour day month year} {
	variable rankings
	variable rankings_file
	variable settings
	
	# Check if it's the first day of the month (day == 1)
	if {$day == 1} {
		# Check if we've already reset this month
		set reset_file "${rankings_file}.reset"
		set current_month_year "$month-$year"
		
		if {[file exists $reset_file]} {
			set f [open $reset_file r]
			set last_reset [read $f]
			close $f
			if {[string equal $last_reset $current_month_year]} {
				# Already reset this month
				return
			}
		}
		
		# Reset rankings
		array unset rankings
		array set rankings {}
		
		# Save empty rankings
		if {[catch {
			set f [open $rankings_file w]
			puts $f ""
			close $f
		} err]} {
			putlog "Error resetting rankings: $err"
			return
		}
		
		# Mark that we've reset this month
		if {[catch {
			set f [open $reset_file w]
			puts $f $current_month_year
			close $f
		} err]} {
			putlog "Error saving reset marker: $err"
		}
		
		putlog "Hold 'Em rankings automatically reset for new month ($month/$year)"
		
		# Notify all channels with the holdem flag enabled
		foreach chan [channels] {
			if {[info exists settings(udef-flag)] && [string length $settings(udef-flag)]} {
				if {[catch {channel get $chan $settings(udef-flag)} flag_result]} {
					continue
				}
				if {$flag_result} {
					puthelp "PRIVMSG $chan :\00304\002Monthly Rankings Reset:\002\003 Rankings have been reset for the new month. Start fresh and compete for the top spots!"
				}
			}
		}
	}
}

proc init_player_stats {player} {
	variable rankings
	if {![info exists rankings($player)]} {
		set rankings($player) [dict create games_played 0 hands_won 0 total_points 0]
	} else {
		# Ensure all keys exist (for backward compatibility)
		# Check if it's old format (just an integer) or new format (dict)
		if {[string is integer $rankings($player)]} {
			# Old format: convert to new format
			set old_points $rankings($player)
			set rankings($player) [dict create games_played 0 hands_won 0 total_points $old_points]
		} else {
			# New format: ensure all keys exist
			if {![dict exists $rankings($player) games_played]} {
				dict set rankings($player) games_played 0
			}
			if {![dict exists $rankings($player) hands_won]} {
				dict set rankings($player) hands_won 0
			}
			if {![dict exists $rankings($player) total_points]} {
				dict set rankings($player) total_points 0
			}
		}
	}
}

proc update_player_stats {player {points 0} {game_won 0} {hand_won 0}} {
	variable rankings
	init_player_stats $player
	if {$game_won} {
		dict incr rankings($player) games_played
	}
	if {$hand_won} {
		dict incr rankings($player) hands_won
	}
	if {$points != 0} {
		dict incr rankings($player) total_points $points
	}
	save_rankings
}

proc show_rankings {nick uhost hand chan txt} {
	variable settings
	variable rankings
	variable ns
	
	# Check if channel is valid
	if {![validchan $chan]} {
		if {$settings(verbose)} { putlog "show_rankings: invalid channel $chan" }
		return 0
	}
	
	# Check ignore flags
	if {[catch {matchattr $hand $settings(ignore-flags) $chan} result] || $result} {
		if {$settings(verbose)} { putlog "show_rankings: ignored user $nick" }
		return 0
	}
	
	# Check channel flag
	if {[info exists settings(udef-flag)] && [string length $settings(udef-flag)]} {
		if {[catch {channel get $chan $settings(udef-flag)} flag_result]} {
			if {$settings(verbose)} { putlog "show_rankings: error checking flag: $flag_result" }
			return 0
		}
		if {!$flag_result} {
			if {$settings(verbose)} { putlog "show_rankings: channel flag not set for $chan" }
			return 0
		}
	}
	# Sort rankings by total_points (descending), but only show players with points >= 0 in !rankings
	set sorted [list]
	set sorted_all [list]
	foreach {player stats} [array get rankings] {
		init_player_stats $player
		set points [dict get $rankings($player) total_points]
		lappend sorted_all [list $player $points]
		# Only include players with non-negative points for !rankings display
		if {$points >= 0} {
			lappend sorted [list $player $points]
		}
	}
	set sorted [lsort -integer -index 1 -decreasing $sorted]
	set sorted_all [lsort -integer -index 1 -decreasing $sorted_all]
	# Get top 10 (only from non-negative points)
	set top10 [lrange $sorted 0 9]
	if {[llength $top10] == 0} {
		putserv "NOTICE $nick :No rankings yet. Play some games to earn points!"
		return
	}
	# Determine if we should use channel or notice (use notice by default, channel if requested)
	set use_channel 0
	if {[regexp -nocase {\y(channel|chan|pub)\y} $txt]} {
		set use_channel 1
	}
	if {$use_channel} {
		puthelp "PRIVMSG $chan :\00304\002Top 10 Hold 'Em Rankings:\002\003"
	} else {
		putserv "NOTICE $nick :\00304\002Top 10 Hold 'Em Rankings:\002\003"
	}
	set rank 1
	foreach entry $top10 {
		set player [lindex $entry 0]
		init_player_stats $player
		set games_played [dict get $rankings($player) games_played]
		set hands_won [dict get $rankings($player) hands_won]
		set total_points [dict get $rankings($player) total_points]
		set sign ""
		if {$total_points > 0} {
			set sign "+"
		}
		set output "\00304#$rank\003: \002$player\002 - ${sign}$total_points points | Games: $games_played | Hands Won: $hands_won"
		if {$use_channel} {
			puthelp "PRIVMSG $chan :$output"
		} else {
			putserv "NOTICE $nick :$output"
		}
		incr rank
	}
	# Show user's own rank (use sorted_all to include negative points for ranking calculation)
	set user_rank 0
	if {[info exists rankings($nick)]} {
		init_player_stats $nick
		set user_rank 0
		foreach entry $sorted_all {
			incr user_rank
			if {[string equal [lindex $entry 0] $nick]} {
				break
			}
		}
	}
	if {$user_rank > 0} {
		set user_games [dict get $rankings($nick) games_played]
		set user_hands [dict get $rankings($nick) hands_won]
		set user_points [dict get $rankings($nick) total_points]
		set user_sign ""
		if {$user_points > 0} {
			set user_sign "+"
		}
		# Show user's rank even if they have negative points (using sorted_all for ranking)
		set user_output "Your rank: \00304#$user_rank\003 - \002$nick\002: ${user_sign}$user_points points | Games: $user_games | Hands Won: $user_hands"
		if {$use_channel} {
			puthelp "PRIVMSG $chan :$user_output"
		} else {
			putserv "NOTICE $nick :$user_output"
		}
	} elseif {[info exists rankings($nick)]} {
		set user_games [dict get $rankings($nick) games_played]
		set user_hands [dict get $rankings($nick) hands_won]
		set user_points [dict get $rankings($nick) total_points]
		set user_sign ""
		if {$user_points > 0} {
			set user_sign "+"
		}
		# Show unranked status (user has negative points so not in top rankings)
		set user_output "Your rank: \00304Unranked\003 - \002$nick\002: ${user_sign}$user_points points | Games: $user_games | Hands Won: $user_hands"
		if {$use_channel} {
			puthelp "PRIVMSG $chan :$user_output"
		} else {
			putserv "NOTICE $nick :$user_output"
		}
	}
	if {!$use_channel} {
		putserv "NOTICE $nick :Use \002!rankings channel\002 to display in channel."
	}
}

proc show_rank {nick uhost hand chan txt} {
	variable settings
	variable rankings
	variable ns
	
	# Check if channel is valid
	if {![validchan $chan]} {
		if {$settings(verbose)} { putlog "show_rank: invalid channel $chan" }
		return 0
	}
	
	# Check ignore flags
	if {[catch {matchattr $hand $settings(ignore-flags) $chan} result] || $result} {
		if {$settings(verbose)} { putlog "show_rank: ignored user $nick" }
		return 0
	}
	
	# Check channel flag
	if {[info exists settings(udef-flag)] && [string length $settings(udef-flag)]} {
		if {[catch {channel get $chan $settings(udef-flag)} flag_result]} {
			if {$settings(verbose)} { putlog "show_rank: error checking flag: $flag_result" }
			return 0
		}
		if {!$flag_result} {
			if {$settings(verbose)} { putlog "show_rank: channel flag not set for $chan" }
			return 0
		}
	}
	
	# Sort rankings by total_points (descending)
	set sorted [list]
	foreach {player stats} [array get rankings] {
		init_player_stats $player
		set points [dict get $rankings($player) total_points]
		lappend sorted [list $player $points]
	}
	set sorted [lsort -integer -index 1 -decreasing $sorted]
	
	# Find user's rank
	set user_rank 0
	if {[info exists rankings($nick)]} {
		init_player_stats $nick
		set user_games [dict get $rankings($nick) games_played]
		set user_hands [dict get $rankings($nick) hands_won]
		set user_points [dict get $rankings($nick) total_points]
		set user_rank 0
		foreach entry $sorted {
			incr user_rank
			if {[string equal [lindex $entry 0] $nick]} {
				break
			}
		}
		set user_sign ""
		if {$user_points > 0} {
			set user_sign "+"
		}
		set output "Your rank: \00304#$user_rank\003 - \002$nick\002: ${user_sign}$user_points points | Games: $user_games | Hands Won: $user_hands"
	} else {
		set output "You are not ranked yet. Play some games to earn points!"
	}
	
	putserv "NOTICE $nick :$output"
	return 0
}

proc show_help {nick uhost hand chan txt} {
	variable settings
	variable ns
	
	# Check if channel is valid
	if {![validchan $chan]} {
		return 0
	}
	
	# Check ignore flags
	if {[catch {matchattr $hand $settings(ignore-flags) $chan} result] || $result} {
		return 0
	}
	
	# Check channel flag
	if {[info exists settings(udef-flag)] && [string length $settings(udef-flag)]} {
		if {[catch {channel get $chan $settings(udef-flag)} flag_result]} {
			return 0
		}
		if {!$flag_result} {
			return 0
		}
	}
	
	# Check if user is channel operator
	set is_op [isop $nick $chan]
	
	# Build help message
	set help_msg "\00304\002Hold 'Em Poker Commands:\002\003"
	
	# Send user commands
	putserv "NOTICE $nick :$help_msg"
	putserv "NOTICE $nick :\00303\002User Commands:\002\003"
	putserv "NOTICE $nick :  \002!holdem\002, \002!th\002, \002!texas\002, \002!texasholdem\002, \002!the\002 - Start a new game"
	putserv "NOTICE $nick :  \002!join\002 - Join a game in progress"
	putserv "NOTICE $nick :  \002!play\002 - Start the game with current players"
	putserv "NOTICE $nick :  \002!rankings\002 - Show top 10 rankings (use 'channel' to display in channel)"
	putserv "NOTICE $nick :  \002!rank\002 - Show your personal ranking"
	putserv "NOTICE $nick :  \002!cardmsg\002 <notice|privmsg> - Set how you receive card messages (default: notice)"
	putserv "NOTICE $nick :  \002!help\002 - Show this help message"
	putserv "NOTICE $nick :  \002!stop\002, \002!end\002, \002!endgame\002, \002!stfu\002, \002!quiet\002 - Stop current game (channel operator or game starter only)"
	
	# Send operator commands if user is operator
	if {$is_op} {
		putserv "NOTICE $nick :\00305\002Operator Commands:\002\003"
		putserv "NOTICE $nick :  \002!clearrankings\002 - Clear all rankings (channel operator only)"
	}
	
	putserv "NOTICE $nick :\00302\002Game Commands (during play):\002\003"
	putserv "NOTICE $nick :  \002call\002 - Match the current bet"
	putserv "NOTICE $nick :  \002check\002 - Pass when no bet is required"
	putserv "NOTICE $nick :  \002raise\002 <amount> - Raise the bet by specified amount"
	putserv "NOTICE $nick :  \002all-in\002, \002all in\002, or \002all\002 - Go all-in (bet all your chips)"
	putserv "NOTICE $nick :  \002fold\002 - Fold your hand"
	putserv "NOTICE $nick :  \002cards\002 - Show your cards again"
	
	return 0
}

proc get_user_card_message_type {nick} {
	variable settings
	variable user_card_prefs
	
	# Check if user has a preference set
	if {[info exists user_card_prefs($nick)]} {
		set msg_type [string tolower $user_card_prefs($nick)]
		if {[string equal $msg_type "notice"] || [string equal $msg_type "privmsg"]} {
			return $msg_type
		}
	}
	
	# Fall back to global setting
	set msg_type [string tolower $settings(card-message-type)]
	if {![string equal $msg_type "notice"] && ![string equal $msg_type "privmsg"]} {
		set msg_type "notice"
	}
	return $msg_type
}

proc set_card_message_type {nick uhost hand chan txt} {
	variable settings
	variable user_card_prefs
	
	# Check if channel is valid
	if {![validchan $chan]} {
		return 0
	}
	
	# Check ignore flags
	if {[catch {matchattr $hand $settings(ignore-flags) $chan} result] || $result} {
		return 0
	}
	
	# Parse the command argument
	set txt [string trim $txt]
	set msg_type [string tolower $txt]
	
	# Validate input
	if {[string equal $msg_type "notice"] || [string equal $msg_type "privmsg"]} {
		set user_card_prefs($nick) $msg_type
		putserv "NOTICE $nick :Card message type set to \002[string toupper $msg_type]\002. Your cards will be sent via $msg_type."
	} elseif {[string equal $msg_type ""]} {
		# Show current setting
		set current [get_user_card_message_type $nick]
		putserv "NOTICE $nick :Your current card message type is \002[string toupper $current]\002. Use \002!cardmsg notice\002 or \002!cardmsg privmsg\002 to change it."
	} else {
		putserv "NOTICE $nick :Invalid option. Use \002!cardmsg notice\002 or \002!cardmsg privmsg\002. Current setting: \002[string toupper [get_user_card_message_type $nick]]\002"
	}
	
	return 0
}

putlog "Hold 'Em $scriptver loaded."
}; # end namespace
