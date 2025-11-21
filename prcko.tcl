###############################################################################
# prcko.tcl - Eggdrop Fun Commands Script
#
# DESCRIPTION:
#   A collection of humorous IRC commands for entertainment purposes.
#   Provides various percentage-based "rating" commands and interactive
#   responses to channel messages. Includes flood protection to prevent abuse.
#
# VERSION:
#   1.337
#   Last update: 26.05.2013
#   - Added flood protect
#
# AUTHOR:
#   Velimir Majstorov (AKA munZe) <velimir@majstorov.rs>
#   Created for DBase Network (irc.dbase.in.rs)
#
# LICENSE:
#   MIT License
#
#   Copyright (c) 2013-2025 Velimir Majstorov (AKA munZe)
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
#   Various commands available:
#   !prc <nick> - Random "prc" message
#   !drka <nick> - Random "drka" message
#   !izmeri <nick> - Random penis size measurement
#   !sise <nick> - Random breast size description
#   !sexy <nick> - Random sexy percentage
#   !gay <nick> - Random gay percentage
#   !hacker <nick> - Random hacker percentage
#   !laze <nick> - Random lying percentage
#   !istina <nick> - Random truth-telling percentage
#   !ozbiljan <nick> - Random seriousness percentage (male)
#   !ozbiljna <nick> - Random seriousness percentage (female)
#   !neozbiljan <nick> - Random non-seriousness percentage (male)
#   !neozbiljna <nick> - Random non-seriousness percentage (female)
#   !crnac <nick> - Random "crnac" percentage
#   !veverica <nick> - Random "veverica" percentage
#   !govedo <nick> - Random "govedo" percentage
#   !dupe <nick> or !guza <nick> - Random "dupe" message
#   !komande - Lists available commands
#   !iamon - Shows channels bot is on (requires +n flag)
#   !ignore <nick> - Adds user to ignore list (requires +m flag)
#
# CONFIGURATION:
#   izuzmi - List of nicks to exclude from certain commands (special responses)
#   floodTime - Time window in seconds for flood detection (default: 5)
#   floodmsg - Maximum messages allowed in floodTime window (default: 3)
#   banDuration - Duration in minutes for flood ban (default: 10)
#
###############################################################################

# Ne smaraj nickove - List of nicks to exclude from certain commands
set izuzmi [list "munZe" "\[85\]"]

# Bind public commands
bind pub - !prc pub_prc
bind pub - !drka pub_drka
bind pub - !izmeri pub_izmeri
bind pub - !komande pub_komande
bind pub - !sise pub_sise
bind pub - !sexy pub_sexy
bind pub - !laze pub_laze
bind pub - !istina pub_istina
bind pub - !gay pub_gay
bind pub - !ozbiljan pub_ozbiljan
bind pub - !ozbiljna pub_ozbiljna
bind pub - !neozbiljan pub_ozbiljan
bind pub - !neozbiljna pub_ozbiljna
bind pub - !crnac pub_crnac
bind pub - !hacker pub_hacker
bind pubm - "*kako je*" pub_blato
bind pubm - "*pusi kurac*" pub_kurac
bind pubm - "*pusi kµ®ä©*" pub_kurac
bind pubm - "*nabijem*" pub_nabijem

# Ignore command - requires +m flag
bind pub mn|mn !ignore ignoreSmaracha

###############################################################################
# PROC: ignoreSmaracha
#
# DESCRIPTION:
#   Adds a user to the bot's ignore list. If the provided text doesn't contain
#   a hostmask format (!*@*), it automatically appends !*@* to create a
#   proper hostmask.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   host - The hostmask of the user executing the command
#   handle - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - The nick or hostmask to ignore
#
# RETURNS:
#   None
###############################################################################
proc ignoreSmaracha {nick host handle chan text} { 
    if {![string match *!*@* $text]} { 
        set im "$text!*@*" 
    } else { 
        set im $text 
    }
    newignore $im $handle "Ignored by $nick" 0
    putserv "PRIVMSG $chan :Now ignoring $text"
}

###############################################################################
# PROC: pub_iamon
#
# DESCRIPTION:
#   Displays a list of all channels the bot is currently on.
#   Requires +n flag (owner/master).
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Unused
#
# RETURNS:
#   None
###############################################################################
bind pub n|n !iamon pub_iamon
proc pub_iamon {nick mask hand chan text} {
    putserv "privmsg $chan :I`m on [chans]"
}

###############################################################################
# PROC: pub_blato
#
# DESCRIPTION:
#   Responds to messages containing "kako je" with a humorous response
#   about mud when it rains.
#
# PARAMETERS:
#   nick - The nick of the user who triggered the response
#   mask - The hostmask of the user
#   hand - The handle of the user
#   chan - The channel where the message was sent
#   text - The message text
#
# RETURNS:
#   None
###############################################################################
proc pub_blato {nick mask hand chan text} {
    putserv "privmsg $chan $nick ... kad je kisha blato je :D"
}

###############################################################################
# PROC: pub_kurac
#
# DESCRIPTION:
#   Responds to messages containing "pusi kurac" (or variations) with
#   humorous responses.
#
# PARAMETERS:
#   nick - The nick of the user who triggered the response
#   mask - The hostmask of the user
#   hand - The handle of the user
#   chan - The channel where the message was sent
#   text - The message text
#
# RETURNS:
#   None
###############################################################################
proc pub_kurac {nick mask hand chan text} {
    putserv "privmsg $chan $nick volis da pushish kurac,a?"
    putact $chan "daje $nick svog pitona da ga glodje :)"
}

###############################################################################
# PROC: pub_nabijem
#
# DESCRIPTION:
#   Responds to messages containing "nabijem" with humorous responses.
#
# PARAMETERS:
#   nick - The nick of the user who triggered the response
#   mask - The hostmask of the user
#   hand - The handle of the user
#   chan - The channel where the message was sent
#   text - The message text
#
# RETURNS:
#   None
###############################################################################
proc pub_nabijem {nick mask hand chan text} {
    putserv "privmsg $chan $nick, a bi voleo/la da ja tebe nabijem malo,a? :D"
    putact $chan "skinuo gace i stavio $nick u krilo... Skaci $nick,skaciiii!! Toooo!!!! TOooooo!!!!! :)"
}

###############################################################################
# PROC: pub_komande
#
# DESCRIPTION:
#   Displays a list of available commands in the channel.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Unused
#
# RETURNS:
#   None
###############################################################################
proc pub_komande {nick mask hand chan text} {
    putact $chan "trenutno forsira komande \002 !drka <nick> \037-\037 !izmeri <nick> \037-\037 !prc <nick> \037-\037 !sise <nick> \037-\037 !hacker <nick> \037-\037 !gay <nick>"
    putact $chan "\002 !sexy <nick> \037-\037 !laze <nick> \037-\037 !istina <nick> \037-\037 !ozbiljan <nick> \037-\037 !ozbiljna <nick> \037-\037 !crnac <nick> \037-\037 !veverica <nick> \037-\037 !govedo <nick> \037-\037 !dupe <nick>"
}

###############################################################################
# PROC: pub_hacker
#
# DESCRIPTION:
#   Generates a random "hacker" percentage (0-100%) for a specified nick.
#   If the nick is in the izuzmi list, returns 100%. If no nick is specified,
#   rates the command executor.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, rates the executor)
#
# RETURNS:
#   None
###############################################################################
proc pub_hacker {nick mask hand chan text} {
    global izuzmi
    if {[checkUserAbuse $nick $chan] == "1"} {
        set hacker [expr {int(rand()*100)}]
        if {[string match -nocase *$text* $izuzmi] != "1"} { 
            putserv "PRIVMSG $chan $nick, $text 15 h4ck3r $hacker%"
        } elseif {$text == ""} { 
            putserv "PRIVMSG $chan $nick 15 h4ck3r $hacker%"
        } elseif {[string match -nocase *$text* $izuzmi] == "1"} { 
            putserv "PRIVMSG $chan $text 15 h4ck3r 100%"
        } else { 
            return 
        }
    }
}

###############################################################################
# PROC: pub_sexy
#
# DESCRIPTION:
#   Generates a random "sexy" percentage (0-100%) for a specified nick.
#   If the nick is in the izuzmi list, returns 100%. If no nick is specified,
#   rates the command executor.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, rates the executor)
#
# RETURNS:
#   None
###############################################################################
proc pub_sexy {nick mask hand chan text} {
    global izuzmi
    if {[checkUserAbuse $nick $chan] == "1"} {
        set sexy [expr {int(rand()*100)}]
        if {[string match -nocase *$text* $izuzmi] != "1"} { 
            putserv "PRIVMSG $chan $nick, $text is sexy $sexy%" 
        } elseif {$text == ""} { 
            putserv "PRIVMSG $chan $nick is sexy $sexy%" 
        } elseif {[string match -nocase *$text* $izuzmi] == "1"} { 
            putserv "PRIVMSG $chan $text is sexy 100%"
        } else { 
            return 
        }
    }
}

###############################################################################
# PROC: pub_gay
#
# DESCRIPTION:
#   Generates a random "gay" percentage (0-100%) for a specified nick.
#   If the nick is in the izuzmi list, returns a special message.
#   If no nick is specified, rates the command executor.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, rates the executor)
#
# RETURNS:
#   None
###############################################################################
proc pub_gay {nick mask hand chan text} {
    global izuzmi
    if {[checkUserAbuse $nick $chan] == "1"} {
        set gay [expr {int(rand()*100)}]
        if {[string match -nocase *$text* $izuzmi] != "1"} { 
            putserv "PRIVMSG $chan $nick, $text is gay $gay%"
        } elseif {$text == ""} { 
            putserv "PRIVMSG $chan $nick is gay $gay%"
        } elseif {[string match -nocase *$text* $izuzmi] == "1"} { 
            putserv "PRIVMSG $chan $text nije gay, on voli zene! :P"
        } else { 
            return 
        }
    }
}

###############################################################################
# PROC: pub_laze
#
# DESCRIPTION:
#   Generates a random "lying" percentage (0-100%) for a specified nick.
#   If the nick is in the izuzmi list, returns a special message.
#   If no nick is specified, rates the command executor.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, rates the executor)
#
# RETURNS:
#   None
###############################################################################
proc pub_laze {nick mask hand chan text} {
    global izuzmi
    if {[checkUserAbuse $nick $chan] == "1"} {
        set gay [expr {int(rand()*100)}]
        if {[string match -nocase *$text* $izuzmi] != "1"} { 
            putserv "PRIVMSG $chan $nick, $text laze $gay%"
        } elseif {$text == ""} { 
            putserv "PRIVMSG $chan $nick is gay $gay%"
        } elseif {[string match -nocase *$text* $izuzmi] == "1"} { 
            putserv "PRIVMSG $chan $text nikada ne laze! Sve sto kaze je istina! :P"
        } else { 
            return 
        }
    }
}

###############################################################################
# PROC: pub_istina
#
# DESCRIPTION:
#   Generates a random "truth-telling" percentage (0-100%) for a specified nick.
#   If the nick is in the izuzmi list, returns a special message.
#   If no nick is specified, rates the command executor.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, rates the executor)
#
# RETURNS:
#   None
###############################################################################
proc pub_istina {nick mask hand chan text} {
    global izuzmi
    if {[checkUserAbuse $nick $chan] == "1"} {
        set gay [expr {int(rand()*100)}]
        if {[string match -nocase *$text* $izuzmi] != "1"} { 
            putserv "PRIVMSG $chan $nick, $text govori/pise istinu $gay%"
        } elseif {$text == ""} { 
            putserv "PRIVMSG $chan $nick is gay $gay%"
        } elseif {[string match -nocase *$text* $izuzmi] == "1"} { 
            putserv "PRIVMSG $chan $text uvek govori istinu BRE! ;-)"
        } else { 
            return 
        }
    }
}

###############################################################################
# PROC: pub_ozbiljan
#
# DESCRIPTION:
#   Generates a random "seriousness" percentage (0-100%) for a specified nick (male).
#   If the nick is in the izuzmi list, returns a special message.
#   If no nick is specified, rates the command executor.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, rates the executor)
#
# RETURNS:
#   None
###############################################################################
proc pub_ozbiljan {nick mask hand chan text} {
    global izuzmi
    if {[checkUserAbuse $nick $chan] == "1"} {
        set gay [expr {int(rand()*100)}]
        if {[string match -nocase *$text* $izuzmi] != "1"} { 
            putserv "PRIVMSG $chan $nick, $text je ozbiljan $gay%"
        } elseif {$text == ""} { 
            putserv "PRIVMSG $chan $nick is gay $gay%"
        } elseif {[string match -nocase *$text* $izuzmi] == "1"} { 
            putserv "PRIVMSG $chan $text je uvek ozbiljan osim kad se zajebava :))"
        } else { 
            return 
        }
    }
}

###############################################################################
# PROC: pub_ozbiljna
#
# DESCRIPTION:
#   Generates a random "seriousness" percentage (0-100%) for a specified nick (female).
#   If the nick is in the izuzmi list, returns a special message.
#   If no nick is specified, rates the command executor.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, rates the executor)
#
# RETURNS:
#   None
###############################################################################
proc pub_ozbiljna {nick mask hand chan text} {
    global izuzmi
    if {[checkUserAbuse $nick $chan] == "1"} {
        set gay [expr {int(rand()*100)}]
        if {[string match -nocase *$text* $izuzmi] != "1"} { 
            putserv "PRIVMSG $chan $nick, $text je ozbiljna $gay%"
        } elseif {$text == ""} { 
            putserv "PRIVMSG $chan $nick is gay $gay%"
        } elseif {[string match -nocase *$text* $izuzmi] == "1"} { 
            putserv "PRIVMSG $chan $text je uvek ozbiljna osim kad se zajebava :))"
        } else { 
            return 
        }
    }
}

###############################################################################
# PROC: pub_neozbiljan
#
# DESCRIPTION:
#   Generates a random "non-seriousness" percentage (0-100%) for a specified nick (male).
#   Actually uses the same logic as pub_ozbiljan. If the nick is in the izuzmi list,
#   returns a special message. If no nick is specified, rates the command executor.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, rates the executor)
#
# RETURNS:
#   None
###############################################################################
proc pub_neozbiljan {nick mask hand chan text} {
    global izuzmi
    if {[checkUserAbuse $nick $chan] == "1"} {
        set gay [expr {int(rand()*100)}]
        if {[string match -nocase *$text* $izuzmi] != "1"} { 
            putserv "PRIVMSG $chan $nick, $text je ozbiljan $gay%"
        } elseif {$text == ""} { 
            putserv "PRIVMSG $chan $nick is gay $gay%"
        } elseif {[string match -nocase *$text* $izuzmi] == "1"} { 
            putserv "PRIVMSG $chan $text je uvek ozbiljan osim kad se zajebava :))"
        } else { 
            return 
        }
    }
}

###############################################################################
# PROC: pub_neozbiljna
#
# DESCRIPTION:
#   Generates a random "non-seriousness" percentage (0-100%) for a specified nick (female).
#   Actually uses the same logic as pub_ozbiljna. If the nick is in the izuzmi list,
#   returns a special message. If no nick is specified, rates the command executor.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, rates the executor)
#
# RETURNS:
#   None
###############################################################################
proc pub_neozbiljna {nick mask hand chan text} {
    global izuzmi
    if {[checkUserAbuse $nick $chan] == "1"} {
        set gay [expr {int(rand()*100)}]
        if {[string match -nocase *$text* $izuzmi] != "1"} { 
            putserv "PRIVMSG $chan $nick, $text je ozbiljna $gay%"
        } elseif {$text == ""} { 
            putserv "PRIVMSG $chan $nick is gay $gay%"
        } elseif {[string match -nocase *$text* $izuzmi] == "1"} { 
            putserv "PRIVMSG $chan $text je uvek ozbiljna osim kad se zajebava :))"
        } else { 
            return 
        }
    }
}

###############################################################################
# PROC: pub_crnac
#
# DESCRIPTION:
#   Generates a random "crnac" percentage (0-100%) for a specified nick.
#   If the nick is in the izuzmi list, returns a special message.
#   If no nick is specified, rates the command executor.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, rates the executor)
#
# RETURNS:
#   None
###############################################################################
proc pub_crnac {nick mask hand chan text} {
    global izuzmi
    if {[checkUserAbuse $nick $chan] == "1"} {
        set gay [expr {int(rand()*100)}]
        if {[string match -nocase *$text* $izuzmi] != "1"} { 
            putserv "PRIVMSG $chan $nick, $text je crnac $gay%"
        } elseif {$text == ""} { 
            putserv "PRIVMSG $chan $nick je crnac $gay%"
        } elseif {[string match -nocase *$text* $izuzmi] == "1"} { 
            putserv "PRIVMSG $chan $text je skinhead! :))"
        } else { 
            return 
        }
    }
}

###############################################################################
# PROC: pub_veverica
#
# DESCRIPTION:
#   Generates a random "veverica" percentage (0-100%) for a specified nick.
#   If the nick is in the izuzmi list, returns a special message.
#   If no nick is specified, rates the command executor.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, rates the executor)
#
# RETURNS:
#   None
###############################################################################
bind pub - !veverica pub_veverica
proc pub_veverica {nick mask hand chan text} {
    global izuzmi
    if {[checkUserAbuse $nick $chan] == "1"} {
        set gay [expr {int(rand()*100)}]
        if {[string match -nocase *$text* $izuzmi] != "1"} { 
            putserv "PRIVMSG $chan $nick, $text je veverica $gay%"
        } elseif {$text == ""} { 
            putserv "PRIVMSG $chan $nick je veverica $gay%"
        } elseif {[string match -nocase *$text* $izuzmi] == "1"} { 
            putserv "PRIVMSG $chan $text nije veverica,zamenio si ga sa CarevicFTW! :))"
        } else { 
            return 
        }
    }
}

###############################################################################
# PROC: pub_govedo
#
# DESCRIPTION:
#   Generates a random "govedo" percentage (0-100%) for a specified nick.
#   If the nick is in the izuzmi list, returns a special message.
#   If no nick is specified, rates the command executor.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, rates the executor)
#
# RETURNS:
#   None
###############################################################################
bind pub - !govedo pub_govedo
proc pub_govedo {nick mask hand chan text} {
    global izuzmi
    if {[checkUserAbuse $nick $chan] == "1"} {
        set gay [expr {int(rand()*100)}]
        if {[string match -nocase *$text* $izuzmi] != "1"} { 
            putserv "PRIVMSG $chan $nick, $text je govedo $gay%"
        } elseif {$text == ""} { 
            putserv "PRIVMSG $chan $nick je govedo $gay%"
        } elseif {[string match -nocase *$text* $izuzmi] == "1"} { 
            putserv "PRIVMSG $chan $text nije govedo, najveca goveda mozes naci na #goveda ! :))"
        } else { 
            return 
        }
    }
}

###############################################################################
# PROC: pub_dupe
#
# DESCRIPTION:
#   Generates a random "dupe" (butt) message for a specified nick.
#   If the nick is in the izuzmi list, returns a special response.
#   If no nick is specified, uses the command executor.
#   Can be triggered by either !dupe or !guza commands.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, uses the executor)
#
# RETURNS:
#   None
###############################################################################
bind pub - !dupe pub_dupe
bind pub - !guza pub_dupe
proc pub_dupe {nick mask hand chan text} {
    global izuzmi dupe

    set prcko [lindex $text 0]
    if {[checkUserAbuse $nick $chan] == "1"} {
        if {$prcko != "" && [string match -nocase *$prcko* $izuzmi] != "1"} {
            putserv "PRIVMSG $chan :$prcko [lindex $dupe [rand [llength $dupe]]]"
        } elseif {[string match -nocase *$prcko* $izuzmi] == "1"} { 
            putact $chan "svrsava po $nick guzi!"
        } else { 
            putserv "PRIVMSG $chan :$prcko [lindex $dupe [rand [llength $dupe]]]" 
        }
    }
}

# List of "dupe" messages
set dupe {
    "voli da daje svoju guzu svima sa chata!"
    "ima najbolju guzu na serveru, a i shire!"
}

###############################################################################
# PROC: pub_prc
#
# DESCRIPTION:
#   Generates a random "prc" message for a specified nick.
#   If the nick is in the izuzmi list, returns a special response.
#   If no nick is specified, uses the command executor.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, uses the executor)
#
# RETURNS:
#   None
###############################################################################
proc pub_prc {nick mask hand chan text} {
    global izuzmi
    global prc

    set prcko [lindex $text 0]
    if {[checkUserAbuse $nick $chan] == "1"} {
        if {$prcko != "" && [string match -nocase *$prcko* $izuzmi] != "1"} {
            putact $chan "prca $prcko sa [lindex $prc [rand [llength $prc]]]"
        } elseif {[string match -nocase *$prcko* $izuzmi] == "1"} { 
            putact $chan "prca $nick jel` ne voli incest!"
        } else { 
            putact $chan "prca $nick sa [lindex $prc [rand [llength $prc]]]" 
        }
    }
}

# List of "prc" messages
set prc {
    "velikim dildom u guzu!"
    "velikim dildom u picu!"
    "velikim dildom u uvo!"
    "kalabasterom u guzu!"
    "kalabasterom u picu!"
    "lubenicom u prdaru!"
    "metlom u guzu!"
    "burgijom u picu"
}

###############################################################################
# PROC: pub_drka
#
# DESCRIPTION:
#   Generates a random "drka" message for a specified nick.
#   If the nick is in the izuzmi list, returns a special response.
#   If no nick is specified, uses the command executor.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, uses the executor)
#
# RETURNS:
#   None
###############################################################################
proc pub_drka {nick mask hand chan text} {
    global izuzmi
    global drka

    set drkadzija [lindex $text 0]
    if {[checkUserAbuse $nick $chan] == "1"} {
        if {$drkadzija != "" && [string match -nocase *$drkadzija* $izuzmi] != "1"} {
            putact $chan "oseca da ga $drkadzija drka [lindex $drka [rand [llength $drka]]]"
        } elseif {[string match -nocase *$drkadzija* $izuzmi] == "1"} { 
            putact $chan "zna da je $nick zesci drkadzija, a $text ima redovan sex sa $nick mamom i ne mora da ga drvi! :P"
        } else { 
            putact $chan "oseca da ga $nick drka [lindex $drka [rand [llength $drka]]]" 
        }
    }
}

# List of "drka" messages
set drka {
    "jednom na dan!"
    "dva puta na dan!"
    "tri puta na dan!"
    "vise puta na dan!"
    "brate po ceo dan! Ti si pravi drkadzija!"
}

###############################################################################
# PROC: pub_izmeri
#
# DESCRIPTION:
#   Generates a random penis size measurement (10-25 cm) for a specified nick.
#   If the nick is in the izuzmi list, uses the command executor instead.
#   If no nick is specified, uses the command executor.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, uses the executor)
#
# RETURNS:
#   None
###############################################################################
proc pub_izmeri {nick mask hand chan text} {
    global izuzmi
    global izmeri

    set meritelj [lindex $text 0]
    if {[checkUserAbuse $nick $chan] == "1"} {
        if {$meritelj != "" && [string match -nocase *$meritelj* $izuzmi] != "1"} {
            putact $chan "zaviruje $meritelj u gace, vadi mikroskop i kaze... $meritelj ima kurac [lindex $izmeri [rand [llength $izmeri]]]"
        } elseif {[string match -nocase *$meritelj* $izuzmi] == "1"} { 
            putact $chan "zaviruje $nick u gace, vadi mikroskop i kaze... $nick ima kurac [lindex $izmeri [rand [llength $izmeri]]]"
        } else { 
            putact $chan "zaviruje $nick u gace, vadi mikroskop i kaze... $nick ima kurac [lindex $izmeri [rand [llength $izmeri]]]" 
        }
    }
}

# List of measurement sizes
set izmeri {
    "10 cm!"
    "11 cm!"
    "12 cm!"
    "13 cm!"
    "14 cm!"
    "15 cm!"
    "16 cm!"
    "17 cm!"
    "18 cm!"
    "19 cm!"
    "20 cm!"
    "21 cm!"
    "22 cm!"
    "23 cm!"
    "24 cm!"
    "25 cm!"
}

###############################################################################
# PROC: pub_sise
#
# DESCRIPTION:
#   Generates a random breast size description for a specified nick.
#   Special case: If the nick is "Anqa", returns a special message.
#   If the nick is in the izuzmi list, returns a special response.
#   If no nick is specified, uses the command executor.
#
# PARAMETERS:
#   nick - The nick of the user executing the command
#   mask - The hostmask of the user executing the command
#   hand - The handle of the user executing the command
#   chan - The channel where the command was executed
#   text - Optional nick to rate (if empty, uses the executor)
#
# RETURNS:
#   None
###############################################################################
proc pub_sise {nick mask hand chan text} {
    global izuzmi
    global sise
    set sisata $text
    if {[checkUserAbuse $nick $chan] == "1"} {
        if {$sisata == "Anqa"} { 
            putact $chan "pipa $nick za grudi i procenjuje da Anqa ima najvecu sisu koju je ikad video!!! VAUUU Anqa, hoce li mi dati munZe da pipnem? :)"
        }
        if {$sisata != "" && [string match -nocase *$sisata* $izuzmi] != "1"} { 
            putact $chan "pipa $sisata za grudi i procenjuje da $sisata [lindex $sise [rand [llength $sise]]]"
        } elseif {[string match -nocase *$sisata* $izuzmi] == "1"} { 
            putact $chan "pipa $nick kevu i kaze da $nick mama ima dobru sisu :)"
        } else { 
            putact $chan "pipa $nick za grudi i procenjuje da $nick [lindex $sise [rand [llength $sise]]]" 
        }
    }
}

# List of breast size descriptions
set sise {
    "ima malene dvojke!"
    "ima solidne trojke!"
    "ima dobre cetvorke!"
    "ima zadovoljavajuce petice! Uh kolke siseee!!! :)"
    "nema nikakve sise u obliku plavog patlidzana!"
    "ima silikone! Zajebala te majka priroda pa si davala pare za operaciju! Pu! Ali daj da mesim malo :)"
    "ima silikone! Zajebala te majka priroda pa si davala pare za operaciju! Pu! Ali daj da mesim malo :)"
    "nema neku sisu... ali kad je skinula brus, bradavica kao kompakt disk!"
    "ima sisu ki pirinach :)"
    "ima sisu ki dve zelene jabuke :)"
    "ima sise velicine treshnjica :)"
    "ima sise u obliku limuna."
    "ima sise ko breskve"
    "ima sise u obliku kruske"
    "ima sise u obliku papaje"
    "ima sise ko staze za ski skokove"
    "ima sise ko flashe za vodu"
    "ima sise ko kesice za caj"
    "ima sise ko lubenice"
    "ima sise ki lonci za supu"
    "ima sise ki mango"
    "ima sise ko kugle za kuglanje"
}

######################
#	Flood protect	 #
######################

# Flood protection settings
set floodTime 5
set floodmsg 3
set banDuration 10

###############################################################################
# PROC: initCmdUser
#
# DESCRIPTION:
#   Initializes a new user entry in the flood protection tracking array.
#   Creates an entry with 0 ban time and a list containing the current time.
#
# PARAMETERS:
#   host - The hostmask of the user to initialize
#   time - The current unix timestamp
#
# RETURNS:
#   None
###############################################################################
proc initCmdUser {host time} {
    global usersbanovani
    set usersbanovani($host) [list 0 [list $time]]
    return
}

###############################################################################
# PROC: checkUserAbuse
#
# DESCRIPTION:
#   Checks if a user is flooding commands. Tracks message timestamps for each
#   user's hostmask. If a user sends more than floodmsg messages within
#   floodTime seconds, they are temporarily banned from using commands for
#   banDuration minutes.
#
#   The function maintains a per-hostmask tracking system:
#   - First time users are automatically allowed
#   - Users currently banned are blocked until ban expires
#   - Message timestamps older than floodTime are removed
#   - If message count exceeds floodmsg, user is banned
#
# PARAMETERS:
#   nick - The nick of the user to check
#   chan - The channel where the command was executed
#
# RETURNS:
#   1 if user is allowed to use commands, 0 if banned/flooding
###############################################################################
proc checkUserAbuse {nick chan} {
    set host [getchanhost $nick $chan]
    global usersbanovani banDuration floodTime floodmsg
    set time [unixtime]
    if {![array exists usersbanovani]} {
        initCmdUser $host $time
        return 1
    }
    set seenNick 0
    foreach user [array names usersbanovani] {
        if {$user == $host} {set seenNick 1; break}
    }
    if {$seenNick == 0} {
        initCmdUser $host $time
        return 1
    }
    if {[lindex $usersbanovani($host) 0] != 0} {
        if {[lindex $usersbanovani($host) 0] <= $time} {
            array set usersbanovani [list $host [list 0 [list $time]]]
            return 1
        }
        return 0
    }
    set messages {}
    foreach m [lindex $usersbanovani($host) 1] {
        if {[expr $time-$m] <= $floodTime} {
            lappend messages $m
        }
    }
    lappend messages $time
    array set usersbanovani [list $host [list 0 $messages]]
    if {[llength $messages] > $floodmsg} {
        set host [getchanhost $nick]
        array set usersbanovani [list $host [list [expr $time+($banDuration*60)] {}]]
        return 0
    }
    return 1
}
######################

putlog "Skripta za prcanje v1.337 je uspesno ucitana ..."
