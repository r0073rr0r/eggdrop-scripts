###############################################################################
# cpu.tcl - CPU and Memory monitoring script for Eggdrop                      #
# Version: 1.0.0                                                              #
#                                                                             #
# Description:                                                                #
#   This script provides IRC bot commands for monitoring system resources:    #
#   - !cpu: Displays CPU load average (1min, 5min, 15min) and warns if        #
#           threshold exceeded                                                #
#   - !mem: Shows memory usage statistics (free, available, used, total)      #
#   - !timerz: Lists all active timers in the bot                             #
#                                                                             #
#   Commands are restricted to a specified channel (#services by default) and #
#   can only be used by authorized admins (munZe) or users with master flags/ #
#   channel ops. The script also includes periodic CPU monitoring that        #
#   automatically warns when load average exceeds the configured threshold.   #
#                                                                             #
# Author: Velimir Majstorov AKA munZe from DBase                              #
# Network: irc.dbase.in.rs                                                    #
# --------------------------------------------------------------------------- #
# MIT License                                                                 #
#                                                                             #
# Copyright (c) 2024 Velimir Majstorov AKA munZe from DBase                   #
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

bind pub - !cpu cpuv
bind pub - !mem memv
bind pub - !timerz listtimers

set cpu_monitor_channel "#services"
set cpu_check_interval 300
set cpu_threshold 5.0

# Admin nicks allowed to use commands
set admin_nicks [list "munZe"]

# Check if user is admin
proc is_admin {nick handle chan} {
	global admin_nicks
	# Check if nick is in admin list (munZe)
	if {[lsearch -nocase $admin_nicks $nick] != -1} {
		return 1
	}
	# If not munZe, check if handle has master flags OR user is channel operator
	if {$handle != "*" && [matchattr $handle m]} {
		return 1
	}
	if {[isop $nick $chan]} {
		return 1
	}
	return 0
}

proc listtimers {nick host handle chan arg} {
	global cpu_monitor_channel botnick
	
	# Check channel restriction
	if {[string tolower $chan] != [string tolower $cpu_monitor_channel]} {
		return 0
	}
	
	# Check admin status
	if {![is_admin $nick $handle $chan]} {
		return 0
	}
	
	set timer_list [timers]
	if {[llength $timer_list] == 0} {
		putserv "PRIVMSG $chan :$botnick No active timers."
		return 0
	}
	
	putserv "PRIVMSG $chan :$botnick Active Timers ([llength $timer_list]):"
	set count 1
	foreach timer $timer_list {
		set interval [lindex $timer 0]
		set command [lindex $timer 1]
		set timer_id [lindex $timer 2]
		set repeat [lindex $timer 3]
		
		# Format command for display
		if {[llength $command] > 1} {
			# Command is a list, get the first element (proc name)
			set cmd_name [lindex $command 0]
			set cmd_display "$cmd_name ..."
		} else {
			set cmd_display $command
		}
		
		# Truncate if too long
		if {[string length $cmd_display] > 40} {
			set cmd_display [string range $cmd_display 0 37]...
		}
		
		# Determine timer type
		set type "Other"
		if {[string match "*cpuv*" $cmd_display] || [string match "*cpuv*" $command]} {
			set type "CPU Monitor (retry)"
		} elseif {[string match "*check_cpu_periodic*" $cmd_display] || [string match "*check_cpu_periodic*" $command]} {
			set type "CPU Periodic Check"
		}
		
		putserv "PRIVMSG $chan :$botnick   $count. ${interval}s - $type - ID: $timer_id - Repeat: $repeat"
		incr count
	}
	return 0
}

proc cpuv {nick host handle chan arg} { 
	global botnick cpu_threshold cpu_monitor_channel
	
	# Check channel restriction
	if {[string tolower $chan] != [string tolower $cpu_monitor_channel]} {
		return 0
	}
	
	# Check admin status
	if {![is_admin $nick $handle $chan]} {
		return 0
	}
	
	if {[catch {
		set fd [open /proc/loadavg r]
		set load [read $fd]
		close $fd
		set load [string trim $load]
	} error]} {
		putserv "PRIVMSG $chan :Error reading load average: $error"
		return 0
	}
	
	set load_parts [split $load " "]
	putserv "PRIVMSG $chan :$botnick LoadAvg:\002 \0034 [lindex $load_parts 0] [lindex $load_parts 1] [lindex $load_parts 2]" 
	
	if { [lindex $load_parts 1] > $cpu_threshold } { 
		putserv "PRIVMSG $chan :$botnick LoadAvg:\002 \0034 WARNING!! SERVER LOAD ABOVE $cpu_threshold FOR THE PAST 5 MINUTES" 
	} 
	
	return 0
}

# Periodic CPU monitoring
proc check_cpu_periodic {} {
	global botnick cpu_monitor_channel cpu_threshold cpu_check_interval
	
	if {[catch {
		set fd [open /proc/loadavg r]
		set load [read $fd]
		close $fd
		set load [string trim $load]
	} error]} {
		return
	}
	
	set load_parts [split $load " "]
	set load_5min [lindex $load_parts 1]
	
	if {$load_5min > $cpu_threshold} {
		if {[validchan $cpu_monitor_channel] && [botonchan $cpu_monitor_channel]} {
			putserv "PRIVMSG $cpu_monitor_channel :\[CPU WARNING\] Load average (5min): $load_5min (threshold: $cpu_threshold) - Current: [lindex $load_parts 0], 5min: [lindex $load_parts 1], 15min: [lindex $load_parts 2]"
		}
	}
	
	# Schedule next check
	timer $cpu_check_interval check_cpu_periodic
}

# Start periodic CPU monitoring on init-server
bind evnt - init-server start_cpu_monitor

proc start_cpu_monitor {type} {
	global cpu_check_interval
	timer $cpu_check_interval check_cpu_periodic
	putlog "CPU monitoring started - checking every $cpu_check_interval seconds"
}

proc memv {nick host handle chan arg} { 
	global botnick cpu_monitor_channel
	
	# Check channel restriction
	if {[string tolower $chan] != [string tolower $cpu_monitor_channel]} {
		return 0
	}
	
	# Check admin status
	if {![is_admin $nick $handle $chan]} {
		return 0
	}
	
	if {[catch {set meminfo [exec free -m]} error]} {
		putserv "PRIVMSG $chan :Error reading memory info: $error"
		return 0
	}
	
	# Parse the Mem: line from free -m output
	# Format: Mem:  total  used  free  shared  buff/cache  available
	set lines [split $meminfo "\n"]
	set mem_line [lindex $lines 1]
	set mem_fields [regexp -all -inline {\S+} $mem_line]
	
	# mem_fields[0] = "Mem:", [1] = total, [2] = used, [3] = free, [4] = shared, [5] = buff/cache, [6] = available
	set total_mem [lindex $mem_fields 1]
	set used_mem [lindex $mem_fields 2]
	set free_mem [lindex $mem_fields 3]
	set available_mem [lindex $mem_fields 6]
	
	putserv "PRIVMSG $chan :Free Memory on $botnick:\002 \0034 ${free_mem}MB free, ${available_mem}MB available (${used_mem}MB used / ${total_mem}MB total)" 
	return 0
}
