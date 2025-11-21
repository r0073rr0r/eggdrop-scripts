# -*- tab-width: 4; indent-tabs-mode: t; -*-
# rss-synd.tcl -- 0.5.2
#
#   Highly configurable asynchronous RSS & Atom feed reader for Eggdrops 
#     written in TCL. Supports multiple feeds, gzip compressed feeds,
#     automatically messaging channels with updates at set intervals,
#     custom private/channel triggers and more.
#
# Copyright (c) 2011 Andrew Scott, HM2K
# Copyright (c) 2025 Velimir Majstorov (AKA munZe)
#
# Name: RSS & Atom Syndication Script for Eggdrop
# Author: Andrew Scott <andrew.scott@wizzer-it.com>
# Author: HM2K <irc@hm2k.org>
# Author: Velimir Majstorov (AKA munZe) <irc.dbase.in.rs>
# 
# License: See LICENSE file
# Link: https://github.com/r0073rr0r/eggdrop-scripts
# Tags: rss, atom, syndication
# Updated: 21-Nov-2025
#
# ============================================================================
# MODIFICATIONS & REQUIREMENTS (2025-11-21)
# ============================================================================
#
# REQUIREMENTS:
#   - Tcl http package (standard, usually included)
#   - Tcl tls package (REQUIRED for HTTPS feeds)
#     * Install: tcl-tls package on most Linux distributions
#     * Or compile from source if needed
#   - Tcl Trf package (OPTIONAL, for gzip decompression support)
#     * Install: tcltrf package on most Linux distributions
#     * If not available, feeds will work but gzip compression won't be handled
#
# MODIFICATIONS MADE:
#   1. HTTPS/TLS Support:
#      - Added explicit HTTPS handler registration in ::rss-synd::init
#      - Registers ::tls::socket for HTTPS connections (port 443)
#      - Uses -autoservername true for SNI support
#      - Prevents "invalid command name ::rss-synd::tls_socket" errors
#
#   2. Gzip Decompression Handling:
#      - Improved error handling for gzip decompression failures
#      - If decompression fails (e.g., server sends gzip header but content
#        isn't actually compressed), script continues with raw data
#      - Handles cases where servers incorrectly claim gzip encoding
#      - Added comprehensive debug logging for troubleshooting
#
#   3. Feed Output Formatting:
#      - Custom output format for 'vesti' feed: [Vesti] title - link
#      - Title displayed in bold (\002)
#      - Link displayed with underline (\037)
#      - Configurable via rss-synd-settings.tcl
#
#   4. Feed Limits & Configuration:
#      - Default announce-output and trigger-output set to 10 items
#      - Update interval: 30 minutes (configurable per feed)
#      - Manual triggers show all items up to limit (no old data comparison)
#      - Automatic updates only show new items (compares against database)
#
#   5. Debug Logging:
#      - Added extensive debug logging throughout feed processing pipeline
#      - Logs HTTP request start, callback invocation, data processing steps
#      - Helps identify issues with feed fetching, parsing, and output
#
# CONFIGURATION:
#   - Feed settings: scripts/rss-synd-settings.tcl
#   - Database location: scripts/feeds/ (created automatically)
#   - Logs: Check logs/eggdrop.log and logs/error.log for issues
#
# USAGE:
#   - Manual trigger: !vesti or !rss vesti (shows up to trigger-output items)
#   - Automatic updates: Every update-interval minutes (shows only new items)
#   - Feed checks: Bot checks feeds every minute, updates when interval expires
#
# ============================================================================
#

#
# Settings Configuration
#
namespace eval ::rss-synd {
	variable rss
	variable default

	set rss(vesti) {
		"url"			"https://vesti.dbase.in.rs/i/?a=rss&user=Perun&token=&hours=168"
		"channels"		"#Vesti"
		"database"		"/home/ircd/eggdrop/scripts/feeds/vesti.db"
		"output"		"\[\002Vesti\002\] \002@@item!title@@@@entry!title@@\002 - \037@@item!link@@@@entry!link!=href@@\037"
		"trigger"		"!@@feedid@@"
		"announce-output"	10
		"trigger-output"	10
		"evaluate-tcl"	0
	}

	#set rss(test1) {
	#	"url"			"http://www.pheedo.com/f/newscientist_space/atom10"
	#	"channels"		"#test"
	#	"database"		"./scripts/feeds/test1.db"
	#	"trigger"		"!@@feedid@@"
	#}

	#set rss(test2) {
	#	"url"			"http://milw0rm.com/rss.php"
	#	"channels"		"#test"
	#	"database"		"./scripts/feeds/test2.db"
	#	"trigger"		"!@@feedid@@"
	#}

	#set rss(test3) {
	#	"url"			"http://www.kvirc.net/rss.php"
	#	"channels"		"#test"
	#	"database"		"./scripts/feeds/test3.db"
	#	"output"		"\[\002@@channel!title@@\002\] @@item!title@@ - @@item!guid@@"
	#	"trigger"		"!@@feedid@@"
	#}

	#set rss(test4) {
	#	"url"			"http://www.imaginascience.com/xml/rss.xml"
	#	"channels"		"#test"
	#	"database"		"./scripts/feeds/test4.db"
	#	"trigger"		"!@@feedid@@"
	#}

	# Doesn't work with "charset" "utf-8" because TCL converts characters
	#  with umlauts in to multibyte characters (eg: ü = Ã¼). Works fine
	#  without.
	#set rss(test5) {
	#	"url"			"http://www.heise.de/newsticker/heise-atom.xml"
	#	"channels"		"#test"
	#	"database"		"./scripts/feeds/test5.db"
	#	"trigger"		"!@@feedid@@"
	#}

	#set rss(test6) {
	#	"url"			"http://news.google.ru/?output=rss"
	#	"channels"		"#test"
	#	"charset"		"utf-8"
	#	"database"		"./scripts/feeds/test6.db"
	#	"trigger"		"!@@feedid@@"
	#}

	#set rss(test7) {
	#	"url"			"http://news.google.cn/?output=rss"
	#	"channels"		"#test"
	#	"charset"		"utf-8"
	#	"database"		"./scripts/feeds/test7.db"
	#	"trigger"		"!@@feedid@@"
	#}

	#set rss(test8) {
	#	"url"			"http://news.google.it/?output=rss"
	#	"channels"		"#test"
	#	"charset"		"utf-8"
	#	"database"		"./scripts/feeds/test8.db"
	#	"trigger"		"!@@feedid@@"
	#}

	# The default settings, If any setting isn't set for an individual feed
	#   it'll use the defaults listed here.
	#
	# WARNING: You can change the options here, but DO NOT REMOVE THEM, doing
	#   so will create errors.
	set default {
		"announce-output"	3
		"trigger-output"	3
		"remove-empty"		1
		"trigger-type"		0:2
		"announce-type"		0
		"max-depth"			5
		"evaluate-tcl"		0
		"update-interval"	30
		"output-order"		0
		"timeout"			60000
		"channels"			"#Vesti"
		"trigger"			"!rss @@feedid@@"
		"output"			"\[\002@@channel!title@@@@title@@\002\] @@item!title@@@@entry!title@@ - @@item!link@@@@entry!link!=href@@"
		"user-agent"		"Mozilla/5.0 (Windows; U; Windows NT 6.1; en-GB; rv:1.9.2.2) Gecko/20100316 Firefox/3.6.2"
	}
}

proc ::rss-synd::init {args} {
	variable rss
	variable default
	variable version
	variable packages

	set version(number)	0.5.2
	set version(date)	"2025-11-21"

	package require http
	set packages(base64) [catch {package require base64}]; # http auth
	set packages(tls) [catch {package require tls}]; # https
	set packages(trf) [catch {package require Trf}]; # gzip compression

	foreach feed [array names rss] {
		array set tmp $default
		array set tmp $rss($feed)

		set required [list "announce-output" "trigger-output" "max-depth" "update-interval" "timeout" "channels" "output" "user-agent" "url" "database" "trigger-type" "announce-type"]
		foreach {key value} [array get tmp] {
			if {[set ptr [lsearch -exact $required $key]] >= 0} {
				set required [lreplace $required $ptr $ptr]
			}
		}

		if {[llength $required] == 0} {
			regsub -nocase -all -- {@@feedid@@} $tmp(trigger) $feed tmp(trigger)

			set ulist [regexp -nocase -inline -- {(http(?:s?))://(?:(.[^:]+:.[^@]+)?)(?:@?)(.*)} $tmp(url)]

			if {[llength $ulist] == 0} {
				[namespace current]::error_log "Unable to parse URL, Invalid format for feed \"$feed\"."
				unset rss($feed)
				continue
			}

			set tmp(url) "[lindex $ulist 1]://[lindex $ulist 3]"

			if {[lindex $ulist 1] == "https"} {
				if {$packages(tls) != 0} {
					[namespace current]::error_log "Unable to find tls package required for https, unloaded feed \"$feed\"."
					unset rss($feed)
					continue
				}

				# Register HTTPS handler if not already registered
				if {![info exists ::rss-synd::tls_registered]} {
					if {[catch {::http::register https 443 [list ::tls::socket -autoservername true]} err]} {
						[namespace current]::error_log "Failed to register HTTPS: 443 $err"
					} else {
						set ::rss-synd::tls_registered 1
					}
				}
			}

			if {(![info exists tmp(url-auth)]) || ($tmp(url-auth) == "")} {
				set tmp(url-auth) ""

				if {[lindex $ulist 2] != ""} {
					if {$packages(base64) != 0} {
						[namespace current]::error_log "Unable to find base64 package required for http authentication, unloaded feed \"$feed\"."
						unset rss($feed)
						continue
					}

					set tmp(url-auth) [::base64::encode [lindex $ulist 2]]
				}
			}

			if {[regexp {^[0123]{1}:[0123]{1}$} $tmp(trigger-type)] != 1} {
				[namespace current]::error_log "Invalid 'trigger-type' syntax for feed \"$feed\"."
				unset rss($feed)
				continue
			}

			set tmp(trigger-type) [split $tmp(trigger-type) ":"]

			if {([info exists tmp(charset)]) && ([lsearch -exact [encoding names] [string tolower $tmp(charset)]] < 0)} {
				putlog "\002RSS Error\002: Unable to load feed \"$feed\", unknown encoding \"$tmp(charset)\"."
				unset rss($feed)
				continue
			}
			
			if {([info exists tmp(feedencoding)]) && ([lsearch -exact [encoding names] [string tolower $tmp(feedencoding)]] < 0)} {
				putlog "\002RSS Error\002: Unable to load feed \"$feed\", unknown feedencoding \"$tmp(feedencoding)\"."
				unset rss($feed)
				continue
			}

			set tmp(updated) 0
			if {([file exists $tmp(database)]) && ([set mtime [file mtime $tmp(database)]] < [unixtime])} {
				set tmp(updated) [file mtime $tmp(database)]
			}

			set rss($feed) [array get tmp]
		} else {
			[namespace current]::error_log "Unable to load feed \"$feed\", missing one or more required settings. \"[join $required ", "]\""
			unset rss($feed)
		}

		unset tmp
	}

	bind evnt -|- prerehash [namespace current]::deinit
	bind time -|- {* * * * *} [namespace current]::feed_get
	bind pubm -|- {* *} [namespace current]::trigger
	bind msgm -|- {*} [namespace current]::trigger

	putlog "\002RSS Syndication Script v$version(number)\002 ($version(date)): Loaded."
}

proc ::rss-synd::deinit {args} {
	catch {unbind evnt -|- prerehash [namespace current]::deinit}
	catch {unbind time -|- {* * * * *} [namespace current]::feed_get}
	catch {unbind pubm -|- {* *} [namespace current]::trigger}
	catch {unbind msgm -|- {*} [namespace current]::trigger}

	foreach child [namespace children] {
		catch {[set child]::deinit}
	}

	namespace delete [namespace current]
}

#
# Trigger Function
##

# Error logging to #services channel
proc ::rss-synd::error_log {msg} {
	set error_channel "#services"
	if {[validchan $error_channel] && [botonchan $error_channel]} {
		putserv "PRIVMSG $error_channel :\002RSS Error\002: $msg"
	}
	putlog "\002RSS Error\002: $msg"
}

proc ::rss-synd::trigger {nick user handle args} {
	variable rss
	variable default
	variable packages

	set i 0
	set chan ""
	if {[llength $args] == 2} {
		set chan [lindex $args 0]
		incr i
	}
	set text [string trim [lindex $args $i]]

	array set tmp $default

	# Check for default trigger format (!rss)
	if {[info exists tmp(trigger)]} {
		regsub -all -- {@@(.*?)@@} $tmp(trigger) "" tmp_trigger
		set tmp_trigger [string trimright $tmp_trigger]

		if {[string equal -nocase $text $tmp_trigger]} {
			set list_feeds [list]
		} elseif {[regexp -nocase -- "^$tmp_trigger\\s+(.+)$" $text -> feed_id]} {
			# Handle "!rss <feedid>" format
			set feed_id [string tolower [string trim $feed_id]]
			if {[info exists rss($feed_id)]} {
				array set feed $rss($feed_id)
				if {(![[namespace current]::check_channel $feed(channels) $chan]) && \
				    ([string length $chan] != 0)} {
					return
				}
				set feed(nick) $nick
				if {$chan != ""} {
					set feed(type) [lindex $feed(trigger-type) 0]
					set feed(channels) $chan
				} else {
					set feed(type) [lindex $feed(trigger-type) 1]
					set feed(channels) ""
				}
				if {[catch {set data [[namespace current]::feed_read]} error] == 0} {
					if {[string length $data] == 0} {
						# Database doesn't exist or is empty - feed hasn't been fetched yet
						if {$chan != ""} {
							putserv "PRIVMSG $chan :Feed '$feed_id' hasn't been loaded yet. The feed will be fetched automatically. Please try again in a few moments."
						}
						# Trigger an immediate feed fetch - preserve nick and channels for notification
						variable packages
						set feed(type) $feed(announce-type)
						set feed(manual-trigger) 1
						set feed(manual-nick) $nick
						set feed(manual-chan) $chan
						set feed(headers) [list]
						if {$feed(url-auth) != ""} {
							lappend feed(headers) "Authorization" "Basic $feed(url-auth)"
						}
						# Only request gzip if Trf package is available for decompression
						if {([info exists feed(enable-gzip)]) && ($feed(enable-gzip) == 1) && ($packages(trf) == 0)} {
							lappend feed(headers) "Accept-Encoding" "gzip"
						}
					::http::config -useragent $feed(user-agent)
					if {[catch {set token [::http::geturl "$feed(url)" -command "[namespace current]::feed_callback {[array get feed] depth 0}" -timeout $feed(timeout) -headers $feed(headers)]} http_error]} {
						[namespace current]::error_log "Failed to start HTTP request for '$feed_id': $http_error"
						if {$chan != ""} {
							putserv "PRIVMSG $chan :Error starting feed fetch: $http_error"
						}
					} else {
						putlog "\002RSS Debug\002: Started HTTP request for '$feed_id', token: $token"
					}
					return
					}
					if {![[namespace current]::feed_info $data]} {
						[namespace current]::error_log "Invalid feed database file format ($feed(database))! File may be corrupted."
						if {$chan != ""} {
							putserv "PRIVMSG $chan :Feed database is corrupted. Attempting to refresh..."
						}
					# Try to fetch fresh data
					variable packages
					set feed(type) $feed(announce-type)
					set feed(headers) [list]
					if {$feed(url-auth) != ""} {
						lappend feed(headers) "Authorization" "Basic $feed(url-auth)"
					}
					# Only request gzip if Trf package is available for decompression
					if {([info exists feed(enable-gzip)]) && ($feed(enable-gzip) == 1) && ($packages(trf) == 0)} {
						lappend feed(headers) "Accept-Encoding" "gzip"
					}
						::http::config -useragent $feed(user-agent)
						catch {::http::geturl "$feed(url)" -command "[namespace current]::feed_callback {[array get feed] depth 0}" -timeout $feed(timeout) -headers $feed(headers)}
						return
					}
					if {$feed(trigger-output) > 0} {
						set feed(announce-output) $feed(trigger-output)
						[namespace current]::feed_output $data
					}
				} else {
					[namespace current]::error_log "Feed read error for '$feed_id': $error"
					if {$chan != ""} {
						putserv "PRIVMSG $chan :Error reading feed database: $error"
					}
				}
				return
			} else {
				# Feed not found
				if {$chan != ""} {
					putserv "PRIVMSG $chan :Feed '$feed_id' not found. Use '$tmp_trigger' to list available feeds."
				}
				return
			}
		}
	}

	unset -nocomplain tmp tmp_trigger

	foreach name [array names rss] {
		array set feed $rss($name)

		if {(![info exists list_feeds]) && \
		    ([string equal -nocase $text $feed(trigger)])} {
			if {(![[namespace current]::check_channel $feed(channels) $chan]) && \
			    ([string length $chan] != 0)} {
				continue
			}

			set feed(nick) $nick

			if {$chan != ""} {
				set feed(type) [lindex $feed(trigger-type) 0]
				set feed(channels) $chan
			} else {
				set feed(type) [lindex $feed(trigger-type) 1]
				set feed(channels) ""
			}

			if {[catch {set data [[namespace current]::feed_read]} error] == 0} {
				if {[string length $data] == 0} {
					# Database doesn't exist or is empty - feed hasn't been fetched yet
					if {$chan != ""} {
						putserv "PRIVMSG $chan :Feed '$name' hasn't been loaded yet. The feed will be fetched automatically. Please try again in a few moments."
					}
					# Trigger an immediate feed fetch - preserve nick and channels for notification
					set feed(type) $feed(announce-type)
					set feed(manual-trigger) 1
					set feed(manual-nick) $nick
					set feed(manual-chan) $chan
					set feed(headers) [list]
					if {$feed(url-auth) != ""} {
						lappend feed(headers) "Authorization" "Basic $feed(url-auth)"
					}
					if {([info exists feed(enable-gzip)]) && ($feed(enable-gzip) == 1)} {
						lappend feed(headers) "Accept-Encoding" "gzip"
					}
					::http::config -useragent $feed(user-agent)
					if {[catch {set token [::http::geturl "$feed(url)" -command "[namespace current]::feed_callback {[array get feed] depth 0}" -timeout $feed(timeout) -headers $feed(headers)]} http_error]} {
						[namespace current]::error_log "Failed to start HTTP request for '$name': $http_error"
						if {$chan != ""} {
							putserv "PRIVMSG $chan :Error starting feed fetch: $http_error"
						}
					} else {
						putlog "\002RSS Debug\002: Started HTTP request for '$name', token: $token"
					}
					continue
				}
				if {![[namespace current]::feed_info $data]} {
					[namespace current]::error_log "Invalid feed database file format ($feed(database))! File may be corrupted."
					if {$chan != ""} {
						putserv "PRIVMSG $chan :Feed database is corrupted. Attempting to refresh..."
					}
					# Try to fetch fresh data
					set feed(type) $feed(announce-type)
					set feed(headers) [list]
					if {$feed(url-auth) != ""} {
						lappend feed(headers) "Authorization" "Basic $feed(url-auth)"
					}
					if {([info exists feed(enable-gzip)]) && ($feed(enable-gzip) == 1)} {
						lappend feed(headers) "Accept-Encoding" "gzip"
					}
					::http::config -useragent $feed(user-agent)
					catch {::http::geturl "$feed(url)" -command "[namespace current]::feed_callback {[array get feed] depth 0}" -timeout $feed(timeout) -headers $feed(headers)}
					continue
				}

				if {$feed(trigger-output) > 0} {
					set feed(announce-output) $feed(trigger-output)

					[namespace current]::feed_output $data
				}
			} else {
				[namespace current]::error_log "Feed read error for '$name': $error"
				if {$chan != ""} {
					putserv "PRIVMSG $chan :Error reading feed database: $error"
				}
			}
		} elseif {[info exists list_feeds]} {
			if {$chan != ""} {
				# triggered from a channel
				if {[[namespace current]::check_channel $feed(channels) $chan]} {
					lappend list_feeds $feed(trigger)
				}
			} else {
				# triggered from a privmsg
				foreach tmp_chan $feed(channels) {
					if {([catch {botonchan $tmp_chan}] == 0) && \
					    ([onchan $nick $tmp_chan])} {
						lappend list_feeds $feed(trigger)
						continue
					}
				}
			}
		}
	}

	if {[info exists list_feeds]} {
		if {[llength $list_feeds] == 0} {
			lappend list_feeds "None"
		}

		set list_msgs [list]
		lappend list_msgs "Available feeds: [join $list_feeds ", "]."

		if {$chan != ""} {
			set list_type [lindex $feed(trigger-type) 0]
			set list_targets $chan
		} else {
			set list_type [lindex $feed(trigger-type) 1]
			set list_targets ""
		}

		[namespace current]::feed_msg $list_type $list_msgs $list_targets $nick
	}
}

#
# Feed Retrieving Functions
##

proc ::rss-synd::feed_get {args} {
	variable rss
	variable packages

	set i 0
	foreach name [array names rss] {
		if {$i == 3} { break }

		array set feed $rss($name)

		if {$feed(updated) <= [expr { [unixtime] - ($feed(update-interval) * 60) }]} {
			::http::config -useragent $feed(user-agent)

			set feed(type) $feed(announce-type)
			set feed(headers) [list]

			if {$feed(url-auth) != ""} {
				lappend feed(headers) "Authorization" "Basic $feed(url-auth)"
			}

			# Only request gzip if Trf package is available for decompression
			if {([info exists feed(enable-gzip)]) && ($feed(enable-gzip) == 1) && ($packages(trf) == 0)} {
				lappend feed(headers) "Accept-Encoding" "gzip"
			}

			catch {::http::geturl "$feed(url)" -command "[namespace current]::feed_callback {[array get feed] depth 0}" -timeout $feed(timeout) -headers $feed(headers)} debug

			set feed(updated) [unixtime]
			set rss($name) [array get feed]
			incr i
		}

		unset feed
	}
}

proc ::rss-synd::feed_callback {feedlist args} {
	set token [lindex $args end]
	array set feed $feedlist

	upvar 0 $token state

	putlog "\002RSS Debug\002: feed_callback called for URL: $state(url), status: $state(status)"

	if {[set status $state(status)] != "ok"} {
		if {$status == "error"} { set status $state(error) }
		[namespace current]::error_log "HTTP Error: $state(url) (State: $status)"
		if {[info exists feed(manual-trigger)] && $feed(manual-trigger) == 1 && [info exists feed(manual-chan)] && $feed(manual-chan) != ""} {
			putserv "PRIVMSG $feed(manual-chan) :HTTP Error fetching feed: $status"
		}
		::http::cleanup $token
		return 1
	}

	array set meta $state(meta)

	if {([::http::ncode $token] == 302) || ([::http::ncode $token] == 301)} {
		set feed(depth) [expr {$feed(depth) + 1 }]

		if {$feed(depth) < $feed(max-depth)} {
			# Update feed array with new depth and pass full feed array to callback
			set feedlist [array get feed]
			catch {::http::geturl "$meta(Location)" -command "[namespace current]::feed_callback {$feedlist}" -timeout $feed(timeout) -headers $feed(headers)}
		} else {
			[namespace current]::error_log "HTTP Error: $state(url) (State: timeout, max refer limit reached)"
		}

		::http::cleanup $token
		return 1
	} elseif {[::http::ncode $token] != 200} {
		[namespace current]::error_log "HTTP Error: $state(url) ($state(http))"
		::http::cleanup $token
		return 1
	}

	set data ""
	if {[catch {
		set data [::http::data $token]
		putlog "\002RSS Debug\002: Got HTTP data, length: [string length $data]"
		
		if {[info exists feed(feedencoding)]} {
			if {[catch {set data [encoding convertfrom [string tolower $feed(feedencoding)] $data]} err]} {
				error "Error converting from feedencoding '$feed(feedencoding)': $err"
			}
			putlog "\002RSS Debug\002: Converted from feedencoding: $feed(feedencoding)"
		}

		if {[info exists feed(charset)]} {
			if {[string tolower $feed(charset)] == "utf-8" && [is_utf8_patched]} {
				#do nothing, already utf-8
			} else {
				if {[catch {set data [encoding convertto [string tolower $feed(charset)] $data]} err]} {
					error "Error converting to charset '$feed(charset)': $err"
				}
				putlog "\002RSS Debug\002: Converted to charset: $feed(charset)"
			}
		}

		if {[info exists meta(Content-Encoding)]} {
			set content_encoding [string tolower [string trim $meta(Content-Encoding)]]
			if {[string equal $content_encoding "gzip"]} {
				putlog "\002RSS Debug\002: Content is gzip encoded, attempting decompression"
				if {[catch {set data [[namespace current]::feed_gzip $data]} err]} {
					# If gzip decompression fails, try to continue anyway
					# Some feeds send gzip encoding header but the content isn't actually compressed
					[namespace current]::error_log "Warning: Feed claims to be gzip compressed but decompression failed: $err. Attempting to parse as plain XML."
					putlog "\002RSS Debug\002: Continuing with data as-is (may not actually be compressed)"
					# Continue with the data as-is, it might not actually be compressed
				} else {
					putlog "\002RSS Debug\002: Successfully decompressed gzip data"
				}
			}
		}

		putlog "\002RSS Debug\002: Attempting to parse XML, data length: [string length $data]"
	} err]} {
		[namespace current]::error_log "Error processing HTTP data: $err"
		if {[info exists feed(manual-trigger)] && $feed(manual-trigger) == 1 && [info exists feed(manual-chan)] && $feed(manual-chan) != ""} {
			putserv "PRIVMSG $feed(manual-chan) :Error processing feed data. Check #services for details."
		}
		::http::cleanup $token
		return 1
	}
	if {[catch {[namespace current]::xml_list_create $data} data] != 0} {
		[namespace current]::error_log "Unable to parse feed properly, parser returned error. \"$state(url)\": $data"
		if {[info exists feed(manual-trigger)] && $feed(manual-trigger) == 1 && [info exists feed(manual-chan)] && $feed(manual-chan) != ""} {
			putserv "PRIVMSG $feed(manual-chan) :Error parsing feed XML. Check #services for details."
		}
		::http::cleanup $token
		return 1
	}
	putlog "\002RSS Debug\002: XML parsed successfully, data length: [string length $data]"

	if {[string length $data] == 0} {
		[namespace current]::error_log "Unable to parse feed properly, no data returned. \"$state(url)\""
		if {[info exists feed(manual-trigger)] && $feed(manual-trigger) == 1 && [info exists feed(manual-chan)] && $feed(manual-chan) != ""} {
			putserv "PRIVMSG $feed(manual-chan) :Error: Feed returned empty data. Check #services for details."
		}
		::http::cleanup $token
		return 1
	}

	set odata ""
	# For manual triggers, don't compare against old data - show all items
	if {![info exists feed(manual-trigger)] || $feed(manual-trigger) != 1} {
		if {[catch {set odata [[namespace current]::feed_read]} error] != 0} {
			putlog "\002RSS Warning\002: $error."
		}
	}

	putlog "\002RSS Debug\002: Checking feed_info"
	if {![[namespace current]::feed_info $data]} {
		# Debug: Check what we got
		set debug_info [[namespace current]::xml_get_info $data [list -1 "*"]]
		[namespace current]::error_log "Invalid feed format ($state(url))! Feed may not be valid RSS/Atom. XML elements found: $debug_info"
		if {[info exists feed(manual-trigger)] && $feed(manual-trigger) == 1 && [info exists feed(manual-chan)] && $feed(manual-chan) != ""} {
			putserv "PRIVMSG $feed(manual-chan) :Error: Invalid feed format. Check #services for details."
		}
		::http::cleanup $token
		return 1
	}
	putlog "\002RSS Debug\002: feed_info check passed"

	::http::cleanup $token

	putlog "\002RSS Debug\002: Attempting to write database to: $feed(database)"
	if {[catch {[namespace current]::feed_write $data} error] != 0} {
		[namespace current]::error_log "Database Error: $error."
		if {[info exists feed(manual-trigger)] && $feed(manual-trigger) == 1 && [info exists feed(manual-chan)] && $feed(manual-chan) != ""} {
			putserv "PRIVMSG $feed(manual-chan) :Error saving feed database: $error"
		}
		return 1
	}
	putlog "\002RSS Debug\002: Database written successfully"

	# Notify user if this was a manual trigger
	putlog "\002RSS Debug\002: Checking for manual trigger, manual-trigger exists: [info exists feed(manual-trigger)]"
	if {[info exists feed(manual-trigger)] && $feed(manual-trigger) == 1} {
		putlog "\002RSS Debug\002: Manual trigger detected, finding feed name"
		putlog "\002RSS Debug\002: Looking for database: $feed(database)"
		set feed_name ""
		set rss_array_names [array names ::rss-synd::rss]
		putlog "\002RSS Debug\002: Available feeds: $rss_array_names"
		foreach name $rss_array_names {
			array set tmp_feed $::rss-synd::rss($name)
			putlog "\002RSS Debug\002: Checking feed '$name', database: $tmp_feed(database)"
			if {$tmp_feed(database) == $feed(database)} {
				set feed_name $name
				putlog "\002RSS Debug\002: Match found! Feed name: $feed_name"
				break
			}
			unset tmp_feed
		}
		putlog "\002RSS Debug\002: Found feed name: $feed_name"
		if {$feed_name != ""} {
			set notify_chan ""
			if {[info exists feed(manual-chan)] && $feed(manual-chan) != ""} {
				set notify_chan $feed(manual-chan)
			} elseif {[info exists feed(channels)] && $feed(channels) != ""} {
				set notify_chan $feed(channels)
			}
			putlog "\002RSS Debug\002: Notify channel: $notify_chan"
			if {$notify_chan != ""} {
				# For manual triggers, use trigger-output instead of announce-output
				set original_announce $feed(announce-output)
				putlog "\002RSS Debug\002: trigger-output exists: [info exists feed(trigger-output)], value: [expr {[info exists feed(trigger-output)] ? $feed(trigger-output) : "N/A"}]"
				if {[info exists feed(trigger-output)] && $feed(trigger-output) > 0} {
					set feed(announce-output) $feed(trigger-output)
					set feed(channels) $notify_chan
					set feed(type) 0
					if {[info exists feed(manual-nick)]} {
						set feed(nick) $feed(manual-nick)
					}
					putlog "\002RSS Debug\002: Calling feed_output with announce-output=$feed(announce-output), channels=$feed(channels)"
					# Output the feed items immediately
					if {[catch {[namespace current]::feed_output $data $odata} err]} {
						[namespace current]::error_log "Error outputting feed '$feed_name' after manual trigger: $err"
						putserv "PRIVMSG $notify_chan :Error displaying feed items. Check #services for details."
					} else {
						putlog "\002RSS Debug\002: feed_output completed successfully"
					}
					set feed(announce-output) $original_announce
				} else {
					putlog "\002RSS Debug\002: trigger-output is 0 or doesn't exist, sending success message"
					putserv "PRIVMSG $notify_chan :Feed '$feed_name' has been successfully loaded! You can now use !$feed_name or !rss $feed_name"
				}
			}
		}
	} elseif {$feed(announce-output) > 0} {
		putlog "\002RSS Debug\002: Regular automatic feed update, announce-output=$feed(announce-output)"
		# Regular automatic feed updates
		if {[catch {[namespace current]::feed_output $data $odata} err]} {
			[namespace current]::error_log "Error outputting feed update: $err"
		}
	} else {
		putlog "\002RSS Debug\002: No output (announce-output=$feed(announce-output), manual-trigger=[expr {[info exists feed(manual-trigger)] ? $feed(manual-trigger) : "N/A"}])"
	}
}

proc ::rss-synd::feed_info {data {target "feed"}} {
	upvar 1 $target feed
	set length [[namespace current]::xml_get_info $data [list -1 "*"]]

	for {set i 0} {$i < $length} {incr i} {
		set type [[namespace current]::xml_get_info $data [list $i "*"] "name"]

		# tag-name: the name of the element that contains each article and its data
		# tag-list: the position in the xml structure where all 'tag-name' reside
		switch [string tolower $type] {
			rss {
				# RSS v0.9x & x2.0
				set feed(tag-list) [list 0 "channel"]
				set feed(tag-name) "item"
				break
			}
			rdf:rdf {
				# RSS v1.0
				set feed(tag-list) [list]
				set feed(tag-name) "item"
				break
			}
			feed {
				# ATOM
				set feed(tag-list) [list]
				set feed(tag-name) "entry"
				break
			}
		}
	}

	if {![info exists feed(tag-list)]} {
		return 0
	}

	set feed(tag-feed) [list 0 $type]

	return 1
}

# decompress gzip formatted data
proc ::rss-synd::feed_gzip {cdata} {
	variable packages

	if {(![info exists packages(trf)]) || \
	    ($packages(trf) != 0)} {
		error "Trf package not found."
	}

	# remove the 10 byte gzip header and 8 byte footer
	set cdata [string range $cdata 10 [expr { [string length $cdata] - 9 } ]]

	# decompress the raw data
	if {[catch {zip -mode decompress -nowrap 1 $cdata} data] != 0} {
		error $data
	}

	return $data
}

proc ::rss-synd::feed_read { } {
	upvar 1 feed feed

	if {![file exists $feed(database)]} {
		return ""
	}

	if {[catch {open $feed(database) "r"} fp] != 0} {
		error $fp
	}

	set data [read -nonewline $fp]

	close $fp

	return $data
}

proc ::rss-synd::feed_write {data} {
	upvar 1 feed feed

	# Ensure the directory exists
	set db_dir [file dirname $feed(database)]
	if {![file exists $db_dir]} {
		if {[catch {file mkdir $db_dir} err] != 0} {
			error "Failed to create directory $db_dir: $err"
		}
	}

	if {[catch {open $feed(database) "w+"} fp] != 0} {
		error $fp
	}

	set data [string map { "\n" "" "\r" "" } $data]

	puts -nonewline $fp $data

	close $fp
}

#
# XML Functions
##

proc ::rss-synd::xml_list_create {xml_data} {
	set xml_list [list]
	set ns_current [namespace current]

	set ptr 0
	while {[set tag_start [${ns_current}::xml_get_position $xml_data $ptr]] != ""} {
		set tag_start_first [lindex $tag_start 0]
		set tag_start_last [lindex $tag_start 1]

		set tag_string [string range $xml_data $tag_start_first $tag_start_last]

		# move the pointer to the next character after the current tag
		set last_ptr $ptr
		set ptr [expr { $tag_start_last + 2 }]

		array set tag [list]
		# match 'special' tags that dont close
		if {[regexp -nocase -- {^!(\[CDATA|--|DOCTYPE)} $tag_string]} {
			set tag_data $tag_string

			regexp -nocase -- {^!\[CDATA\[(.*?)\]\]$} $tag_string -> tag_data
			regexp -nocase -- {^!--(.*?)--$} $tag_string -> tag_data

			if {[info exists tag_data]} {
				set tag(data) [${ns_current}::xml_escape $tag_data]
			}
		} else {
			# we should only ever encounter opening tags, if we hit a closing one somethings wrong
			if {[string match {[/]*} $tag_string]} {
				putlog "\002RSS Malformed Feed\002: Tag not open: \"<$tag_string>\" ($tag_start_first => $tag_start_last)"
				continue
			}

			# split up the tag name and attributes
			regexp -- {(.[^ \/\n\r]*)(?: |\n|\r\n|\r|)(.*?)$} $tag_string -> tag_name tag_args
			set tag(name) [${ns_current}::xml_escape $tag_name]

			# split up all of the tags attributes
			set tag(attrib) [list]
			if {[string length $tag_args] > 0} {
				set values [regexp -inline -all -- {(?:\s*|)(.[^=]*)=["'](.[^"']*)["']} $tag_args]

				foreach {r_match r_tag r_value} $values {
					lappend tag(attrib) [${ns_current}::xml_escape $r_tag] [${ns_current}::xml_escape $r_value]
				}
			}

			# find the end tag of non-self-closing tags
			if {(![regexp {(\?|!|/)(\s*)$} $tag_args]) || \
			    (![string match "\?*" $tag_string])} {
				set tmp_num 1
				set tag_success 0
				set tag_end_last $ptr

				# find the correct closing tag if there are nested elements
				#  with the same name
				while {$tmp_num > 0} {
					# search for a possible closing tag
					set tag_success [regexp -indices -start $tag_end_last -- "</$tag_name>" $xml_data tag_end]

					set last_tag_end_last $tag_end_last

					set tag_end_first [lindex $tag_end 0]
					set tag_end_last [lindex $tag_end 1]

					# check to see if there are any NEW opening tags within the
					#  previous closing tag and the new closing one
					incr tmp_num [regexp -all -- "<$tag_name\(\[\\s\\t\\n\\r\]+\(\[^/>\]*\)?\)?>" [string range $xml_data $last_tag_end_last $tag_end_last]]

					incr tmp_num -1
				}

				if {$tag_success == 0} {
					putlog "\002RSS Malformed Feed\002: Tag not closed: \"<$tag_name>\""
					return
				}

				# set the pointer to after the last closing tag
				set ptr [expr { $tag_end_last + 1 }]

				# remember tag_start*'s character index doesnt include the tag start and end characters
				set xml_sub_data [string range $xml_data [expr { $tag_start_last + 2 }] [expr { $tag_end_first - 1 }]]

				# recurse the data within the currently open tag
				set result [${ns_current}::xml_list_create $xml_sub_data]

				# set the list data returned from the recursion we just performed
				if {[llength $result] > 0} {
					set tag(children) $result

				# set the current data we have because we're already at the end of a branch
				#  (ie: the recursion didnt return any data)
				} else {
					set tag(data) [${ns_current}::xml_escape $xml_sub_data]
				}
			}
		}

		# insert any plain data that appears before the current element
		if {$last_ptr != [expr { $tag_start_first - 1 }]} {
			lappend xml_list [list "data" [${ns_current}::xml_escape [string range $xml_data $last_ptr [expr { $tag_start_first - 2 }]]]]
		}

		# inset tag data
		lappend xml_list [array get tag]

		unset tag
	}

	# if there is still plain data left add it
	if {$ptr < [string length $xml_data]} {
		lappend xml_list [list "data" [${ns_current}::xml_escape [string range $xml_data $ptr end]]]
	}

	return $xml_list
}

# simple escape function
proc ::rss-synd::xml_escape {string} {
	regsub -all -- {([\{\}])} $string {\\\1} string

	return $string
}

# this function is to replace:
#  regexp -indices -start $ptr {<(!\[CDATA\[.+?\]\]|!--.+?--|!DOCTYPE.+?|.+?)>} $xml_data -> tag_start
# which doesnt work correctly with tcl's re_syntax
proc ::rss-synd::xml_get_position {xml_data ptr} {
	set tag_start [list -1 -1]

	regexp -indices -start $ptr {<(.+?)>} $xml_data -> tmp(tag)
	regexp -indices -start $ptr {<(!--.*?--)>} $xml_data -> tmp(comment)
	regexp -indices -start $ptr {<(!DOCTYPE.+?)>} $xml_data -> tmp(doctype)
	regexp -indices -start $ptr {<(!\[CDATA\[.+?\]\])>} $xml_data -> tmp(cdata)

	# 'tag' regexp should be compared last
	foreach name [lsort [array names tmp]] {
		set tmp_s [split $tmp($name)]
		if {( ([lindex $tmp_s 0] < [lindex $tag_start 0]) && \
		      ([lindex $tmp_s 0] > -1) ) || \
            ([lindex $tag_start 0] == -1)} {
			set tag_start $tmp($name)
		}
	}

	if {([lindex $tag_start 0] == -1) || \
	    ([lindex $tag_start 1] == -1)}  {
		set tag_start ""
	}

	return $tag_start
}

# recursivly flatten all data without tags or attributes
proc ::rss-synd::xml_list_flatten {xml_list {level 0}} {
	set xml_string ""

	foreach e_list $xml_list {
		if {[catch {array set e_array $e_list}] != 0} {
			return $xml_list
		}

		if {[info exists e_array(children)]} {
			append xml_string [[namespace current]::xml_list_flatten $e_array(children) [expr { $level + 1 }]]
		} elseif {[info exists e_array(data)]} {
			append xml_string $e_array(data)
		}

		unset e_array
	}

	return $xml_string
}

# returns information on a data structure when given a path.
#  paths can be specified using: [struct number] [struct name] <...>
proc ::rss-synd::xml_get_info {xml_list path {element "data"}} {
	set i 0

	foreach {t_data} $xml_list {
		array set t_array $t_data

		# if the name doesnt exist set it so we can still reference the data
		#  using the 'stuct name' *
		if {![info exists t_array(name)]} {
			set t_array(name) ""
		}

		if {[string match -nocase [lindex $path 1] $t_array(name)]} {

			if {$i == [lindex $path 0]} {
				set result ""

				if {([llength $path] == 2) && \
				    ([info exists t_array($element)])} {
					set result $t_array($element)
				} elseif {[info exists t_array(children)]} {
					# shift the first path reference of the front of the path and recurse
					set result [[namespace current]::xml_get_info $t_array(children) [lreplace $path 0 1] $element]
				}

				return $result
			}

			incr i
		}

		unset t_array
	}

	if {[lindex $path 0] == -1} {
		return $i
	}
}

# converts 'args' into a list in the same order
proc ::rss-synd::xml_join_tags {args} {
	set list [list]

	foreach tag $args {
		foreach item $tag {
			if {[string length $item] > 0} {
				lappend list $item
			}
		}
	}

	return $list
}

#
# Output Feed Functions
##

proc ::rss-synd::feed_output {data {odata ""}} {
	upvar 1 feed feed
	set msgs [list]

	if {![info exists feed(tag-feed)] || ![info exists feed(tag-list)] || ![info exists feed(tag-name)]} {
		[namespace current]::error_log "feed_output: Missing required feed structure (tag-feed, tag-list, or tag-name)"
		return
	}

	set path [[namespace current]::xml_join_tags $feed(tag-feed) $feed(tag-list) -1 $feed(tag-name)]
	set count [[namespace current]::xml_get_info $data $path]

	if {$count == 0} {
		[namespace current]::error_log "feed_output: No items found in feed (count=0)"
		return
	}

	for {set i 0} {($i < $count) && ($i < $feed(announce-output))} {incr i} {
		set tmpp [[namespace current]::xml_join_tags $feed(tag-feed) $feed(tag-list) $i $feed(tag-name)]
		set tmpd [[namespace current]::xml_get_info $data $tmpp "children"]

		if {[[namespace current]::feed_compare $odata $tmpd]} {
			break
		}

		set tmp_msg [[namespace current]::cookie_parse $data $i]
		if {(![info exists feed(output-order)]) || \
		    ($feed(output-order) == 0)} {
			set msgs [linsert $msgs 0 $tmp_msg]
		} else {
			lappend msgs $tmp_msg
		}
	}

	if {[llength $msgs] == 0} {
		[namespace current]::error_log "feed_output: No messages generated (all items matched old data or empty)"
		return
	}

	set nick [expr {[info exists feed(nick)] ? $feed(nick) : ""}]

	[namespace current]::feed_msg $feed(type) $msgs $feed(channels) $nick
}

proc ::rss-synd::feed_msg {type msgs targets {nick ""}} {
	# check if our target is a nick
	if {(($nick != "") && \
	     ($targets == "")) || \
	    ([regexp -- {[23]} $type])} {
		set targets $nick
	}

	foreach msg $msgs {
		foreach chan $targets {
			if {([catch {botonchan $chan}] == 0) || \
			    ([regexp -- {^[#&]} $chan] == 0)} {
				foreach line [split $msg "\n"] {
					if {($type == 1) || ($type == 3)} {
						putserv "NOTICE $chan :$line"
					} else {
						putserv "PRIVMSG $chan :$line"
					}
				}
			}
		}
	}
}

proc ::rss-synd::feed_compare {odata data} {
	if {$odata == ""} {
		return 0
	}

	upvar 1 feed feed
	array set ofeed [list]
	[namespace current]::feed_info $odata "ofeed"

	if {[array size ofeed] == 0} {
		putlog "\002RSS Error\002: Invalid feed format ($feed(database))!"
		return 0
	}

	if {[string equal -nocase [lindex $feed(tag-feed) 1] "feed"]} {
		set cmp_items [list {0 "id"} "children" "" 3 {0 "link"} "attrib" "href" 2 {0 "title"} "children" "" 1]
	} else {
		set cmp_items [list {0 "guid"} "children" "" 3 {0 "link"} "children" "" 2 {0 "title"} "children" "" 1]
	}

	set path [[namespace current]::xml_join_tags $ofeed(tag-feed) $ofeed(tag-list) -1 $ofeed(tag-name)]
	set count [[namespace current]::xml_get_info $odata $path]

	for {set i 0} {$i < $count} {incr i} {
		# extract the current article from the database
		set tmpp [[namespace current]::xml_join_tags $ofeed(tag-feed) $ofeed(tag-list) $i $ofeed(tag-name)]
		set tmpd [[namespace current]::xml_get_info $odata $tmpp "children"]

		set w 0; # weight value
		set m 0; # item tag matches
		foreach {cmp_path cmp_element cmp_attrib cmp_weight} $cmp_items {
			# try and extract the tag info from the current article
			set oresult [[namespace current]::xml_get_info $tmpd $cmp_path $cmp_element]
			if {$cmp_element == "attrib"} {
				array set tmp $oresult
				catch {set oresult $tmp($cmp_attrib)}
				unset tmp
			}

			# if the tag doesnt exist in the article ignore it
			if {$oresult == ""} { continue }

			incr m

			# extract the tag info from the current article
			set result [[namespace current]::xml_get_info $data $cmp_path $cmp_element]
			if {$cmp_element == "attrib"} {
				array set tmp $result
				catch {set result $tmp($cmp_attrib)}
				unset tmp
			}

			if {[string equal -nocase $oresult $result]} {
				set w [expr { $w + $cmp_weight }]
			}
		}

		# value of 100 or more means its a match
		if {($m > 0) && \
		    ([expr { round(double($w) / double($m) * 100) }] >= 100)} {
			return 1
		}
	}

	return 0
}

#
# Cookie Parsing Functions
##

proc ::rss-synd::cookie_parse {data current} {
	upvar 1 feed feed
	set output $feed(output)

	set eval 0
	if {([info exists feed(evaluate-tcl)]) && ($feed(evaluate-tcl) == 1)} { set eval 1 }
	set variable_index 0

	set matches [regexp -inline -nocase -all -- {@@(.*?)@@} $output]
	foreach {match tmpc} $matches {
		set tmpc [split $tmpc "!"]
		set index 0
		set cookie [list]
		incr variable_index
		foreach piece $tmpc {
			set tmpp [regexp -nocase -inline -all -- {^(.*?)\((.*?)\)|(.*?)$} $piece]

			if {[lindex $tmpp 3] == ""} {
				lappend cookie [lindex $tmpp 2] [lindex $tmpp 1]
			} else {
				lappend cookie 0 [lindex $tmpp 3]
			}
		}

		# replace tag-item's index with the current article
		if {[string equal -nocase $feed(tag-name) [lindex $cookie 1]]} {
			set cookie [[namespace current]::xml_join_tags $feed(tag-list) [lreplace $cookie $index $index $current]]
		}

		set cookie [[namespace current]::xml_join_tags $feed(tag-feed) $cookie]

		if {[set tmp [[namespace current]::cookie_replace $cookie $data]] != ""} {
			set tmp [[namespace current]::xml_list_flatten $tmp]

			regsub -all -- {([\"\$\[\]\{\}\(\)\\])} $match {\\\1} match
			set feed_data "[string map { "&" "\\\x26" } [[namespace current]::html_decode $eval $tmp]]"
			if {$eval == 1} {
				# We are going to eval this string so we can't insert untrusted
				# text. Instead create variables and insert references to those
				# variables that will be expanded in the subst call below.
				set cookie_val($variable_index) $feed_data
				regsub -- $match $output "\$cookie_val($variable_index)" output
			} else {
				regsub -- $match $output $feed_data output
			}
		}
	}

	# remove empty cookies
	if {(![info exists feed(remove-empty)]) || ($feed(remove-empty) == 1)} {
		regsub -nocase -all -- "@@.*?@@" $output "" output
	}

	# evaluate tcl code
	if {$eval == 1} {
		if {[catch {set output [subst $output]} error] != 0} {
			putlog "\002RSS Eval Error\002: $error"
		}
	}

	return $output
}

proc ::rss-synd::cookie_replace {cookie data} {
	set element "children"

	set tags [list]
	foreach {num section} $cookie {
		if {[string equal "=" [string range $section 0 0]]} {
			set attrib [string range $section 1 end]
			set element "attrib"
			break
		} else {
			lappend tags $num $section
		}
	}

	set return [[namespace current]::xml_get_info $data $tags $element]

	if {[string equal -nocase "attrib" $element]} {
		array set tmp $return

		if {[catch {set return $tmp($attrib)}] != 0} {
			return
		}
	}

	return $return
}

#
# Misc Functions
##

proc ::rss-synd::html_decode {eval data {loop 0}} {
	if {![string match *&* $data]} {return $data}
	array set chars {
			 nbsp	\x20 amp	\x26 quot	\x22 lt		\x3C
			 gt		\x3E iexcl	\xA1 cent	\xA2 pound	\xA3
			 curren	\xA4 yen	\xA5 brvbar	\xA6 brkbar	\xA6
			 sect	\xA7 uml	\xA8 die	\xA8 copy	\xA9
			 ordf	\xAA laquo	\xAB not	\xAC shy	\xAD
			 reg	\xAE hibar	\xAF macr	\xAF deg	\xB0
			 plusmn	\xB1 sup2	\xB2 sup3	\xB3 acute	\xB4
			 micro	\xB5 para	\xB6 middot	\xB7 cedil	\xB8
			 sup1	\xB9 ordm	\xBA raquo	\xBB frac14	\xBC
			 frac12	\xBD frac34	\xBE iquest	\xBF Agrave	\xC0
			 Aacute	\xC1 Acirc	\xC2 Atilde	\xC3 Auml	\xC4
			 Aring	\xC5 AElig	\xC6 Ccedil	\xC7 Egrave	\xC8
			 Eacute	\xC9 Ecirc	\xCA Euml	\xCB Igrave	\xCC
			 Iacute	\xCD Icirc	\xCE Iuml	\xCF ETH	\xD0
			 Dstrok	\xD0 Ntilde	\xD1 Ograve	\xD2 Oacute	\xD3
			 Ocirc	\xD4 Otilde	\xD5 Ouml	\xD6 times	\xD7
			 Oslash	\xD8 Ugrave	\xD9 Uacute	\xDA Ucirc	\xDB
			 Uuml	\xDC Yacute	\xDD THORN	\xDE szlig	\xDF
			 agrave	\xE0 aacute	\xE1 acirc	\xE2 atilde	\xE3
			 auml	\xE4 aring	\xE5 aelig	\xE6 ccedil	\xE7
			 egrave	\xE8 eacute	\xE9 ecirc	\xEA euml	\xEB
			 igrave	\xEC iacute	\xED icirc	\xEE iuml	\xEF
			 eth	\xF0 ntilde	\xF1 ograve	\xF2 oacute	\xF3
			 ocirc	\xF4 otilde	\xF5 ouml	\xF6 divide	\xF7
			 oslash	\xF8 ugrave	\xF9 uacute	\xFA ucirc	\xFB
			 uuml	\xFC yacute	\xFD thorn	\xFE yuml	\xFF
			 ensp	\x20 emsp	\x20 thinsp	\x20 zwnj	\x20
			 zwj	\x20 lrm	\x20 rlm	\x20 euro	\x80
			 sbquo	\x82 bdquo	\x84 hellip	\x85 dagger	\x86
			 Dagger	\x87 circ	\x88 permil	\x89 Scaron	\x8A
			 lsaquo	\x8B OElig	\x8C oelig	\x8D lsquo	\x91
			 rsquo	\x92 ldquo	\x93 rdquo	\x94 ndash	\x96
			 mdash	\x97 tilde	\x98 scaron	\x9A rsaquo	\x9B
			 Yuml	\x9F apos	\x27
			}

	regsub -all -- {<(.[^>]*)>} $data " " data

	if {$eval != 1} {
		regsub -all -- {([\$\[\]\{\}\(\)\\])} $data {\\\1} data
	} else {
		regsub -all -- {([\$\[\]\{\}\(\)\\])} $data {\\\\\\\1} data
	}

	regsub -all -- {&#(\d+);} $data {[subst -nocomm -novar [format \\\u%04x [scan \1 %d]]]} data
	regsub -all -- {&#x(\w+);} $data {[format %c [scan \1 %x]]} data
	regsub -all -- {&([0-9a-zA-Z#]*);} $data {[if {[catch {set tmp $chars(\1)} char] == 0} { set tmp }]} data
	regsub -all -- {&([0-9a-zA-Z#]*);} $data {[if {[catch {set tmp [string tolower $chars(\1)]} char] == 0} { set tmp }]} data

	regsub -nocase -all -- "\\s{2,}" $data " " data

	set data [subst $data]
	if {[incr loop] == 1} {
		set data [[namespace current]::html_decode 0 $data $loop]
	}

	return $data
}

proc ::rss-synd::is_utf8_patched {} { catch {queuesize a} err1; catch {queuesize \u0754} err2; expr {[string bytelength $err2]!=[string bytelength $err1]} }

proc ::rss-synd::check_channel {chanlist chan} {
	foreach match [split $chanlist] {
		if {[string equal -nocase $match $chan]} {
			return 1
		}
	}

	return 0
}

proc ::rss-synd::urldecode {str} {
	regsub -all -- {([\"\$\[\]\{\}\(\)\\])} $str {\\\1} str

	regsub -all -- {%([aAbBcCdDeEfF0-9][aAbBcCdDeEfF0-9]);?} $str {[format %c [scan \1 %x]]} str

	return [subst $str]
}

::rss-synd::init
