###############################################################################
# rehash.tcl - Eggdrop Rehash Command Script
#
# DESCRIPTION:
#   Allows authorized users to rehash the bot configuration via IRC command.
#   Supports multiple authorized users via configurable list.
#   Checks both handle and nick (case-insensitive) for authorization.
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
#   !rehash - Rehashes the bot configuration
#
# CONFIGURATION:
#   Set the authorized_users list below to add/remove users who can use !rehash
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
# FEATURES:
#   - Multiple authorized users: Supports unlimited number of authorized users
#   - Case-insensitive matching: Handles and nicks are compared case-insensitively
#   - Dual authentication: Checks both user handle AND current nick for authorization
#   - Special character support: Properly handles nicks with brackets [ ] using braces {}
#   - Global variable: Uses global authorized_users variable for easy configuration
#   - Return value: Returns 0 to prevent other scripts from processing the command
#   - Error handling: Provides clear access denied messages with user info
#
###############################################################################

# List of authorized users who can use !rehash command
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

# Bind !rehash command
bind pub - !rehash pub_rehash

proc pub_rehash {nick host handle chan arg} {
	global authorized_users
	
	# Convert to lowercase for case-insensitive comparison
	# This allows matching regardless of how the user types their nick/handle
	set nick_lower [string tolower $nick]
	set handle_lower [string tolower $handle]
	
	# Check if user is authorized (by handle or nick)
	# Checks both handle AND nick to allow flexibility (user might be using different nick)
	set is_authorized 0
	foreach authorized_user $authorized_users {
		# Trim whitespace and convert to lowercase for comparison
		set auth_lower [string tolower [string trim $authorized_user]]
		# Match if either handle or nick matches (case-insensitive)
		if {$handle_lower == $auth_lower || $nick_lower == $auth_lower} {
			set is_authorized 1
			break
		}
	}
	
	if {$is_authorized} {
		# Authorized: Send confirmation message and execute rehash
		putserv "PRIVMSG $chan :Rehashing bot configuration..."
		rehash
	} else {
		# Not authorized: Send access denied message with user info for debugging
		putserv "PRIVMSG $chan :Access denied. You are not authorized to use this command. (Your handle: $handle, nick: $nick)"
	}
	# Return 0 to prevent other scripts from processing this command
	return 0
}
