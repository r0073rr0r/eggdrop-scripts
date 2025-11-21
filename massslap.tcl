###############################################################################
# massslap.tcl - Eggdrop Mass Slap Command Script
#
# DESCRIPTION:
#   Allows authorized users to send mass slap messages to all users in a channel.
#   Authorization can be granted in two ways:
#   1. Users listed in authorized_users list (can use command regardless of operator status)
#   2. Channel operators (@) or halfops (%) (can use command even if not in authorized list)
#   Supports both ACTION (/me) and PRIVMSG formats (configurable). Supports optional 
#   custom message text that will be split into multiple lines if too long.
#   Message format can be configured: ACTION format (like /me on mIRC) or regular PRIVMSG.
#
# VERSION:
#   1.0.0
#   Updated: 21-Nov-2025
#
# AUTHOR:
#   Velimir Majstorov (AKA munZe) <velimir@majstorov.rs>
#   Created for DBase Network (irc.dbase.in.rs)
#
# LICENSE:
#   MIT License
#
#   Copyright (c) 2025 Velimir Majstorov (AKA munZe)
#
#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
#
#   The above copyright notice and this permission notice shall be included in all
#   copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#   SOFTWARE.
#
# USAGE:
#   .call [optional message text]
#   - Sends mass slap to all users in the channel
#   - If message text is provided, it will be displayed in formatted blocks
#   - Message text will be automatically split if longer than 250 characters
#
# CONFIGURATION:
#   Set the authorized_users list below to add/remove users who can use .call
#   Users can be specified by handle or nick (case-insensitive)
#   
#   IMPORTANT: For users with special characters (like [ or ] in nick):
#   - Use braces {} instead of quotes: {[85]}
#   - Examples:
#     * Normal user: "munze"
#     * User with brackets: {[85]}
#
#   CURRENT AUTHORIZED USERS:
#   - "munze" (normal user, using quotes)
#   - {[85]} (user with brackets in nick, using braces to escape special characters)
#
#   AUTHORIZATION LOGIC:
#   - Users in authorized_users list can use the command WITHOUT needing operator/halfop status
#   - Users NOT in authorized_users list can still use the command IF they are channel 
#     operator (@) or halfop (%)
#   - This allows flexibility: trusted users don't need operator status, while operators
#     can use the command even if not explicitly listed
#
#   MESSAGE FORMAT CONFIGURATION:
#   - use_action: Set to 1 to use ACTION format (/me), or 0 to use PRIVMSG format
#     * 1 = ACTION format: "* BotNick slaps user1 user2 ..." (like /me on mIRC)
#     * 0 = PRIVMSG format: "BotNick: slaps user1 user2 ..." (regular message)
#   - Default: 1 (uses ACTION format)
#
# FEATURES:
#   - Multiple authorized users: Supports unlimited number of authorized users
#   - Case-insensitive matching: Handles and nicks are compared case-insensitively
#   - Dual authentication: Checks both user handle AND current nick for authorization
#   - Flexible authorization: Users in authorized list don't need operator status;
#     operators/halfops can use command even if not in authorized list
#   - Special character support: Properly handles nicks with brackets [ ] using braces {}
#   - Configurable message format: Choose between ACTION (/me) or PRIVMSG format
#   - Global variables: Uses global authorized_users and use_action for easy configuration
#   - Return value: Returns 0 to prevent other scripts from processing the command
#   - Error handling: Provides clear access denied messages with user info
#   - Message splitting: Automatically splits long messages into chunks of 250 chars
#   - Rate limiting: Uses delay between message blocks to prevent flooding
#
###############################################################################

# Configuration: Message format
# Set to 1 to use ACTION format (/me), or 0 to use PRIVMSG format
# 1 = ACTION format: "* BotNick slaps user1 user2 ..." (like /me on mIRC)
# 0 = PRIVMSG format: "BotNick: slaps user1 user2 ..." (regular message)
set use_action 1

# List of authorized users who can use .call command
# Add handles or nicks here (case-insensitive matching)
# NOTE: For users with special characters like [ or ], use braces {} instead of quotes ""
# Example: {[85]}
set authorized_users {
	"munze"
	{[85]}
	# Add more users here, one per line:
	# "user1"
	# "user2"
}

# Bind .call command
bind pub - .call massslap

proc massslap {nick uhost hand chan text} {
	global authorized_users
	global use_action
	
	# Convert to lowercase for case-insensitive comparison
	set nick_lower [string tolower $nick]
	set handle_lower [string tolower $hand]
	
	# Check if user is authorized (by handle or nick)
	set is_authorized 0
	foreach authorized_user $authorized_users {
		set auth_lower [string tolower [string trim $authorized_user]]
		if {$handle_lower == $auth_lower || $nick_lower == $auth_lower} {
			set is_authorized 1
			break
		}
	}
	
	# Authorization logic:
	# - If user is in authorized_users list, allow access (no operator/halfop check needed)
	# - If user is NOT in authorized_users list, require channel operator (@) or halfop (%) status
	if {!$is_authorized} {
		# User is not in authorized list, check if they are operator or halfop
		if {![isop $nick $chan] && ![ishalfop $nick $chan]} {
			putserv "PRIVMSG $chan :<$nick> You are not authorized to use this command! You must either be in the authorized users list or be a channel operator (@) or halfop (%)."
			return 0
		}
		# User is operator/halfop but not in authorized list - allow access
	}
	# If user is authorized (in list), allow access without operator/halfop check
	
	# Build list of users in channel
	set lista "slaps"
	foreach userraw [chanlist $chan] {
		set lista "${lista} $userraw"
	}
	
	# Determine message format based on configuration
	if {$use_action} {
		# Use ACTION format (/me) - Format: \001ACTION text\001
		set slap_format "\001ACTION $lista\001"
		set msg_format "\001ACTION \00301 >>> \00302 %s \00301 <<<\001"
	} else {
		# Use PRIVMSG format (regular message)
		set slap_format "\002\002 $lista \002"
		set msg_format "\002\00301 >>> \00302 %s \00301 <<< \002"
	}
	
	# If custom message text is provided
	if {$text != ""} {
		# Send the slap list first
		putserv "PRIVMSG $chan :$slap_format"
		
		# Split message into chunks of max 250 characters (respecting word boundaries)
		set msgs [regexp -all -inline {.{1,250}[^ ]* *} $text]
		
		# Send each message chunk with formatting
		# Note: Eggdrop has built-in flood protection, so we send messages sequentially
		set delay_seconds 0
		foreach msg $msgs {
			if {$delay_seconds > 0} {
				# Schedule message with delay to prevent flooding
				if {$use_action} {
					utimer $delay_seconds [list putserv "PRIVMSG $chan :\001ACTION \00301 >>> \00302 $msg \00301 <<<\001"]
				} else {
					utimer $delay_seconds [list putserv "PRIVMSG $chan :\002\00301 >>> \00302 $msg \00301 <<< \002"]
				}
			} else {
				# Send first message immediately
				if {$use_action} {
					putserv "PRIVMSG $chan :\001ACTION \00301 >>> \00302 $msg \00301 <<<\001"
				} else {
					putserv "PRIVMSG $chan :\002\00301 >>> \00302 $msg \00301 <<< \002"
				}
			}
			# Add 1 second delay for next message
			incr delay_seconds
		}
	} else {
		# No custom message, just send the slap list
		putserv "PRIVMSG $chan :$slap_format"
	}
	
	# Return 0 to prevent other scripts from processing this command
	return 0
}
