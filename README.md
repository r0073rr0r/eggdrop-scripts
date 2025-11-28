# 🥚 Eggdrop Scripts Repository

![Eggdrop](https://img.shields.io/badge/Eggdrop-1.10.1+-blue.svg)
![TCL](https://img.shields.io/badge/TCL-8.6+-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

A repository containing a collection of TCL scripts for Eggdrop IRC bot. Scripts are developed for DBase Network (irc.dbase.in.rs) and cover various functionalities from entertainment to administration.

**Language:** [🇷🇸 Serbian (Srpski)](README.sr.md) | [🇬🇧 English](README.md)

## 📋 Table of Contents

- [🎮 TCL Scripts](#-tcl-scripts)
  - [Active Scripts](#active-scripts)
  - [⚠️ Deprecated Scripts](#️-deprecated-scripts)
- [📦 Dependencies](#-dependencies)
- [📝 Notes](#-notes)
- [🤝 Contributing](#-contributing)
- [🔒 Security](#-security)

---

## 🎮 TCL Scripts

### Active Scripts

---

## 🎴 holdem.tcl

**Version:** 1.2.0  
**Author:** Steve Church (rojo), modified by Velimir Majstorov (munZe)  
**Description:** Complete Texas Hold'em poker system for IRC channels. Supports multiple players, bot players, ranking system, and complete poker logic with blinds, betting rounds, and automatic winner calculation.

**Commands:**

- `!holdem`, `!th`, `!texas`, `!texasholdem`, `!the` - Start a new game
- `!join` - Join a game in progress
- `!play` - Start the game with current players
- `!rankings` - Show top 10 rankings (add 'channel' to display on channel)
- `!rank` - Show your personal ranking
- `!cardmsg <notice|privmsg>` - Set how you receive card messages
- `!help` - Show all available commands
- `!stop`, `!end`, `!endgame`, `!stfu`, `!quiet` - Stop current game (operators or game starter only)
- `!clearrankings` - Clear all rankings (channel operators only)

**Configuration:**

- `.chanset #channel +holdem` - Enable script on channel
- Configurable options: buy-in, blinds, timeout, bot players, etc.

**Features:**

- Ranking system with automatic monthly reset
- Per-user preferences for card message type (NOTICE/PRIVMSG)
- UTF-8 Unicode character support for cards
- AI bot players with configurable aggressiveness
- Statistics: games played, hands won, total points

---

## 🔮 horoskop.tcl

**Version:** 3.1337  
**Author:** tik-tak (original), modified by munZe  
**Description:** Script for fetching horoscopes from astrolook.com. Supports daily, weekly, monthly, love, yearly horoscopes and lucky days.

**Commands:**

- `!horoskop <sign>` or `!dnevni <sign>` - Daily horoscope
- `!nedeljni <sign>` - Weekly horoscope
- `!mesecni <sign>` - Monthly horoscope
- `!ljubavni <sign>` - Love horoscope
- `!godisnji <sign>` - Yearly horoscope
- `!srecni <sign>` or `!srecni-dani <sign>` - Lucky days

**Available signs:** ovan, bik, blizanci, rak, lav, devica, vaga, skorpija/skorpion, strelac, jarac, vodolija, ribe

**Features:**

- Flood protection with daily limits
- Daily-level caching for faster loading
- HTTPS/TLS support
- Private commands (MSG to bot)
- Configurable sending method (channel/PRIVMSG/NOTICE)

**Configuration:**

- `set saljina 1` - Send to channel
- `set saljina 2` - Send via PRIVMSG (default)
- `set saljina 3` - Send via NOTICE

---

## 💻 cpu.tcl

**Version:** 1.0.0  
**Author:** Velimir Majstorov (munZe)  
**Description:** System monitoring for tracking CPU load and memory. Automatically warns when load average exceeds configured threshold.

**Commands:**

- `!cpu` - Show CPU load average (1min, 5min, 15min)
- `!mem` - Show memory information (free, available, used, total)
- `!timerz` - List all active timers in bot

**Features:**

- Automatic periodic CPU load checking
- Channel warnings when threshold is exceeded
- Command restriction to specific channel (#services)
- Authorization: admin nicks (munZe) or master flag/operators

**Configuration:**

- `set cpu_monitor_channel "#services"` - Channel for monitoring
- `set cpu_check_interval 300` - Check interval (seconds)
- `set cpu_threshold 5.0` - Threshold for warnings

---

## 😄 prcko.tcl

**Version:** 1.337  
**Author:** Velimir Majstorov (munZe)  
**Description:** Fun commands for IRC channels with various percentages and messages. Includes flood protection and interactive responses to certain phrases in the channel.

**Commands:**

- `!prc <nick>` - Random "prc" message
- `!drka <nick>` - Random "drka" message
- `!izmeri <nick>` - Random penis size (10-25 cm)
- `!sise <nick>` - Random breast size
- `!sexy <nick>` - Random sexy percentage (0-100%)
- `!gay <nick>` - Random gay percentage (0-100%)
- `!hacker <nick>` - Random hacker percentage (0-100%)
- `!laze <nick>` - Random lying percentage (0-100%)
- `!istina <nick>` - Random truth percentage (0-100%)
- `!ozbiljan <nick>` / `!ozbiljna <nick>` - Random seriousness percentage
- `!neozbiljan <nick>` / `!neozbiljna <nick>` - Random non-seriousness percentage
- `!crnac <nick>` - Random percentage
- `!veverica <nick>` - Random percentage
- `!govedo <nick>` - Random percentage
- `!dupe <nick>` or `!guza <nick>` - Random "dupe" message
- `!komande` - List all available commands
- `!iamon` - List channels bot is on (requires +n flag)
- `!ignore <nick>` - Add user to ignore list (requires +m flag)

**Interactive Responses:**

Script automatically responds to certain phrases in the channel:

- Responds to phrase "kako je" with answer
- Responds to certain vulgar phrases with answers
- Responds to phrase "nabijem" with answer

**Features:**

- Flood protection with automatic banning
- List of excluded nicks (`izuzmi`) with special responses
- Interactive responses to certain phrases in channel (pubm binds)
- Configurable flood parameters (floodTime, floodmsg, banDuration)
- Case-insensitive command matching
- Special responses for excluded nicks

**Configuration:**

- `set izuzmi [list "munZe" "\[85\]"]` - List of nicks with special responses
- `set floodTime 5` - Time window for flood detection (seconds)
- `set floodmsg 3` - Maximum messages in floodTime window
- `set banDuration 10` - Ban duration for flood (minutes)

---

## 📰 rss-synd.tcl

**Version:** 0.5.2  
**Author:** Andrew Scott, HM2K, modified by Velimir Majstorov (munZe)  
**Description:** Asynchronous RSS and Atom feed reader with support for multiple feeds, gzip compression, automatic sending to channels, and custom triggers.

**Commands:**

- `!vesti` or `!rss vesti` - Show latest news (up to 10 items)
- `!rss` - List all available feeds

**Features:**

- HTTPS/TLS support
- Gzip decompression (requires Trf package - see Dependencies section)
- Automatic updates at configured intervals
- Debug logging to #services channel
- Custom output formatting
- Database for tracking new items

**Configuration:**

- Feeds are configured directly in script (rss() array)
- Database: `feeds/` (created automatically)
- Debug logging: controlled via "debug" setting

---

## 👋 massslap.tcl

**Version:** 1.0.0  
**Author:** Velimir Majstorov (munZe)  
**Description:** Command for sending mass slap messages to all users on channel. Supports ACTION (/me) and PRIVMSG format.

**Commands:**

- `.call [optional message]` - Send mass slap to all users on channel

**Features:**

- Dual authorization: authorized users or operators/halfops
- Configurable message format (ACTION/PRIVMSG)
- Automatic splitting of long messages
- Rate limiting to prevent flooding

**Configuration:**

- `set authorized_users` - List of authorized users
- `set use_action 1` - Use ACTION format (1) or PRIVMSG (0)

---

## 🔄 rehash.tcl

**Version:** 1.0.0  
**Author:** Velimir Majstorov (munZe)  
**Description:** Allows authorized users to rehash bot configuration via IRC command.

**Commands:**

- `!rehash` - Rehash bot configuration

**Features:**

- Authorization via user list
- Case-insensitive matching
- Checks both handle and nick

**Configuration:**

- `set authorized_users` - List of authorized users

---

## 📨 privmsg_forward.tcl

**Version:** 1.0.0  
**Author:** Velimir Majstorov (munZe)  
**Description:** Forwards all private messages received by bot to configured channel. Useful for monitoring and logging.

**Features:**

- Automatic forwarding of all PRIVMSG messages
- Display handle when available
- Channel validation before sending

**Configuration:**

- `set privmsg_channel "#services"` - Destination channel

---

## 📚 nextcloud_ebooks.tcl

**Version:** 1.0.0  
**Author:** Velimir Majstorov (munZe)  
**Description:** Script for searching and sharing e-books from Nextcloud server. Allows users to search the e-book library and automatically creates share links for found books.

**Commands:**

- `!ebook <book name>` or `!knjiga <book name>` - Search e-book library and create share link

**Features:**

- E-book search in Nextcloud folder via WebDAV API
- Automatic creation of share links for found books
- UTF-8 encoding support (Serbian characters)
- HTTPS/TLS support for secure communication
- Base64 authentication with Nextcloud App Password
- URL encoding/decoding for proper file name handling
- Automatic finding of existing share links
- Display multiple results if multiple books match the term

**Configuration:**

- `set nextcloud_url "https://cloud.dbase.in.rs"` - Your Nextcloud server URL
- `set nextcloud_username "<your-username>"` - Your Nextcloud username
- `set nextcloud_app_password "<your-app-password>"` - App password (create in Nextcloud Settings > Security > Devices & sessions)

**Note:** Requires base64 TCL package for authentication. Script automatically checks package availability and reports errors if missing.

---

## 💰 pi_price.tcl

**Version:** 3.5.0  
**Author:** Velimir Majstorov (munZe)  
**Description:** Cryptocurrency price monitor from CoinMarketCap API. Automatically fetches and caches prices of all cryptocurrencies, updates every 2 hours. Supports search and price display for any token.

**Commands:**

- `!pi` - Show Pi Network price with invite link
- `!cprice TOKEN` - Show price for any cryptocurrency token (e.g., `!cprice BTC`, `!cprice ETH`)
- `!ctokens [query]` - List available tokens (without argument shows first 50, with argument searches by name or symbol)

**Features:**

- Automatic price fetching from CoinMarketCap Pro API
- Data caching to JSON file for fast access
- Automatic updates every 2 hours
- Support for all cryptocurrencies available on CoinMarketCap (up to 5000 tokens)
- Special support for Pi Network with automatic display on configured channels
- Token search by symbol or name
- Price formatting with 24h changes (green/red color)
- Automatic sending of Pi Network price to configured channels on each update

**Configuration:**

- `set pi_channels [list "#Pi"]` - List of channels for automatic Pi price sending
- `set pi_api_key "<your-API-key>"` - CoinMarketCap Pro API key (get at [coinmarketcap.com/api](https://coinmarketcap.com/api/))
- `set pi_api_url "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest"` - API endpoint
- `set pi_invite_link "https://minepi.com/Majstorov"` - Your Pi Network invite link
- `set pi_check_interval 7200` - Update interval in seconds (default: 7200 = 2 hours)
- `set pi_db_file "scripts/crypto_prices.json"` - Path to JSON database file
- `set pi_network_id "35697"` - Pi Network ID on CoinMarketCap

**Notes:**

- Requires `json` TCL package for parsing JSON responses
- Requires `curl` command for HTTP requests
- CoinMarketCap Pro API requires API key (free plan allows 333 requests per day)
- JSON database is automatically created and updated
- If JSON file is newer than 2 hours on startup, initial update is skipped

---

### ⚠️ Deprecated Scripts

⚠️ **NOTE:** The following scripts are deprecated and currently not working. They may be fixed in the future.

---

## 🎾 tenis.tcl

**Status:** ⚠️ **DEPRECATED** - Not working currently  
**Version:** 0.1337  
**Author:** Velimir Majstorov (munZe)  
**Description:** Script for fetching ATP tennis rankings from atpworldtour.com. Displays top 3 players with detailed information.

**Commands:**

- `!tenistop3` - Show top 3 tennis players

**Features:**

- HTML site parsing
- Ranking formatting and display
- HTTP support

**Reason for deprecation:** Likely changes on ATP website or HTTP structure. Plan: Fix parsing and update for new site structure.

---

## 🌤️ vremenska-prognoza.tcl

**Status:** ⚠️ **DEPRECATED** - Not working currently  
**Version:** 1.0.0  
**Author:** Velimir Majstorov (munZe)  
**Description:** Script for fetching weather forecast for cities in Serbia from blic.rs. Displays current weather conditions with detailed information.

**Commands:**

- `!vreme <city>` - Show weather forecast for selected city

**Available cities:** Beograd, Pristina, Crni-Vrh, Kikinda, Negotin, Sjenica, Valjevo, Krusevac, Pancevo, Kragujevac, Novi-Sad, Kopaonik, Dimitrovgrad, Kraljevo, Palic, Smederevo, Zrenjanin, Vrsac, Cacak, Subotica, Nis, Vranje, Loznica, Leskova, Ruma, Sremska-Mitrovica, Zlatibor, Knjazevac, Uzice

**Features:**

- HTML site parsing
- Display of current weather conditions (temperature, pressure, wind, humidity, visibility, UV index)
- UTF-8 encoding support

**Reason for deprecation:** Likely changes on blic.rs website or HTTP structure. Plan: Recreate script for fetching weather forecast.

---

## 🌧️ vrijeme.tcl

**Status:** ⚠️ **DEPRECATED** - Not working currently  
**Version:** 1.0.0  
**Author:** Velimir Majstorov (munZe)  
**Description:** Script for fetching weather forecast for cities in Bosnia and Herzegovina from prognozavremena.info. Displays current weather conditions with detailed information.

**Commands:**

- `!vrijeme <city>` - Show weather forecast for selected city

**Available cities:** Banja Luka, Bihac, Bijeljina, Brcko, Jahorina, Mostar, Neum, Sarajevo, Trebinje, Tuzla, Visegrad

**Features:**

- HTML site parsing
- Display of current weather conditions (temperature, pressure, wind speed, humidity, visibility, subjective, wind gusts, sunrise/sunset)
- UTF-8 encoding support

**Reason for deprecation:** Likely changes on prognozavremena.info website or HTTP structure. Plan: Recreate script for fetching weather forecast.

---

## 🛡️ PIKbl.tcl

**Status:** ⚠️ **DEPRECATED** - Not working currently  
**Version:** 1.337  
**Author:** Velimir Majstorov (munZe)  
**Description:** Script for automatic checking of IP addresses of users connecting to IRC server. Checks IP addresses via pricaonica.krstarica.com service and automatically bans problematic IP addresses.

**Features:**

- Automatic catching of new connections
- IP address checking via external service
- Automatic banning of problematic IP addresses (GLINE/ZLINE)
- Notifications on configured channel
- Oper up on server for executing bans

**Configuration:**

- `set BanAkoJeVeceOd` - Threshold for banning (default: 60.6)
- `set KanalZaObavestenja` - Channel for notifications (default: #services)
- `set bantype` - Ban type (GLINE/ZLINE)
- `set bantime` - Ban duration (e.g., "12h")
- `set opernick` / `set operpass` - Oper credentials for banning

**Reason for deprecation:** Likely changes on pricaonica.krstarica.com service or HTTP structure. Plan: Update script for new service structure or find alternative service for IP address checking.

---

## 📦 Dependencies

### 📦 trf2.1.5.tar.gz

**Description:** Trf (Trf Extension) is a TCL extension required for the `rss-synd.tcl` script. The original Trf extension is deprecated and does not work with newer versions of TCL (TCL 8.6+).

**Status:** Modified version included in repository is adapted to work with TCL 8.6. Modifications were made by the author (munZe) so that the `rss-synd.tcl` script can use gzip decompression for RSS feeds that are compressed.

**Installation:**

1. Extract `trf2.1.5.tar.gz` archive
2. Compile and install Trf extension according to instructions in package
3. Ensure Trf extension is available in TCL environment before running `rss-synd.tcl`

**Note:** Without Trf extension, `rss-synd.tcl` will work, but will not be able to decompress gzip compressed RSS feeds.

---

## 📝 Notes

- Most scripts are developed for Eggdrop 1.10.0+
- TCL scripts require standard TCL packages (http, tls)
- `rss-synd.tcl` requires Trf extension for gzip decompression (see Dependencies section)
- All scripts are tested and optimized for TCL 8.6

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on how to contribute to this project.

- 🐛 [Report a Bug](https://github.com/r0073rr0r/eggdrop-scripts/issues/new?template=bug_report.md)
- 💡 [Request a Feature](https://github.com/r0073rr0r/eggdrop-scripts/issues/new?template=feature_request.md)
- ❓ [Ask a Question](https://github.com/r0073rr0r/eggdrop-scripts/issues/new?template=question.md)

Please read our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

---

## 🔒 Security

If you discover a security vulnerability, please **DO NOT** open a public issue. Instead, please see our [Security Policy](SECURITY.md) for details on how to report it privately.

---

## 📄 License

Most scripts are licensed under MIT License. Check [LICENSE](LICENSE) file for details. Check header of each script for specific licenses.

---

## 👤 Author

**Velimir Majstorov** (AKA munZe)  
🌐 DBase Network - irc.dbase.in.rs  
🔗 GitHub: [r0073rr0r/eggdrop-scripts](https://github.com/r0073rr0r/eggdrop-scripts)

---

## Last Update

2025

