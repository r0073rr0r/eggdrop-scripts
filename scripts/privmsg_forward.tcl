###############################################################################
# privmsg_forward.tcl - Eggdrop Private Message Forwarding Script
#
# DESCRIPTION:
#   Forwards all private messages received by the bot to a configured channel.
#   Useful for monitoring and logging private communications. Includes user
#   handle information when available.
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
#   No user interaction required. Script automatically forwards all private
#   messages to the configured channel.
#
# CONFIGURATION:
#   Set privmsg_channel below to change the destination channel for forwarded
#   private messages.
#   - Default: "#services"
#   - Channel must exist and bot must be on the channel for forwarding to work
#
# FEATURES:
#   - Automatic forwarding: All private messages are automatically forwarded
#   - Handle detection: Shows user handle when available (registered users)
#   - Channel validation: Checks if channel exists and bot is on channel before forwarding
#   - Return value: Returns 0 to prevent other scripts from processing the message
#   - Logging: Logs when script is loaded with destination channel info
#
###############################################################################

# Configuration: Destination channel for forwarded private messages
# Change this to forward messages to a different channel
set privmsg_channel "#services"

# Bind to all private messages
bind msgm - * forward_privmsg

proc forward_privmsg {nick uhost hand text} {
	global privmsg_channel
	
	# Validate channel exists and bot is on channel before forwarding
	if {[validchan $privmsg_channel] && [botonchan $privmsg_channel]} {
		# Prepare handle text (only show if user has a registered handle)
		set handle_text ""
		if {$hand != "*"} {
			set handle_text " (handle: $hand)"
		}
		
		# Forward the private message to the configured channel
		putserv "PRIVMSG $privmsg_channel :\[PRIVMSG\] $nick$handle_text: $text"
	}
	
	# Return 0 to prevent other scripts from processing this message
	return 0
}

# Log script loading with configuration info
putlog "Private message forwarding loaded - all privmsgs will be sent to $privmsg_channel"
