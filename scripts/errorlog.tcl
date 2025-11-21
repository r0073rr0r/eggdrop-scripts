# Error logging script - sends all errors to #services channel and logs to file
set errorlog_channel "#services"
set errorlog_file "logs/error.log"

# Bind to log events - capture all log levels that might contain errors
bind log - * log_to_channel_and_file

proc log_to_channel_and_file {level channel text} {
	global errorlog_channel errorlog_file
	
	# Check if it's an error (case-insensitive)
	set text_lower [string tolower $text]
	set is_error 0
	
	# Check for various error patterns - only log actual errors, not all "o" level messages
	if {$level == "e" || 
	    [string match "*Tcl error*" $text] ||
	    [string match "*Tcl error*" $text_lower] ||
	    [string match "*invalid command*" $text_lower] ||
	    [string match "*wrong # args*" $text_lower] ||
	    [string match "*can't*" $text_lower] ||
	    [string match "*doesn't exist*" $text_lower] ||
	    [string match "*no such*" $text_lower] ||
	    ([string match "*error*" $text_lower] && [string match "*Tcl error*" $text_lower])} {
		set is_error 1
	}
	
	if {$is_error} {
		# Log to file
		if {[catch {
			set fd [open $errorlog_file a]
			set timestamp [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
			puts $fd "\[$timestamp\] \[$level\] $text"
			close $fd
		} err]} {
			putlog "Error writing to error log file: $err"
		}
		
		# Send to IRC channel
		if {[validchan $errorlog_channel] && [botonchan $errorlog_channel]} {
			# Build message - avoid brackets to prevent Tcl interpretation issues
			set msg "ERROR - Level: $level - $text"
			putserv "PRIVMSG $errorlog_channel :$msg"
		}
	}
	return 0
}

putlog "Error logging script loaded - errors will be sent to $errorlog_channel and logged to $errorlog_file"
