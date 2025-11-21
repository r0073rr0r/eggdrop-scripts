# 🥚 Eggdrop Scripts Repository

![Eggdrop](https://img.shields.io/badge/Eggdrop-1.10.0+-blue.svg)
![TCL](https://img.shields.io/badge/TCL-8.6+-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

Repozitorijum sa kolekcijom TCL skripti za Eggdrop IRC bota. Skripte su razvijene za DBase Network (irc.dbase.in.rs) i pokrivaju različite funkcionalnosti od zabave do administracije.

## 📋 Sadržaj

- [🎮 TCL Skripte](#-tcl-skripte)
  - [Aktivne Skripte](#aktivne-skripte)
  - [⚠️ Zastarele Skripte](#️-zastarele-skripte)
- [📦 Zavisnosti](#-zavisnosti)
- [📝 Napomene](#-napomene)

---

## 🎮 TCL Skripte

### Aktivne Skripte

---

## 🎴 holdem.tcl

**Verzija:** 1.2.0  
**Autor:** Steve Church (rojo), modifikovao Velimir Majstorov (munZe)  
**Opis:** Kompletan Texas Hold'em poker sistem za IRC kanale. Podržava više igrača, bot igrače, sistem rangiranja, i kompletnu logiku pokera sa blindovima, betting rundama, i automatskim izračunavanjem pobednika.

**Komande:**
- `!holdem`, `!th`, `!texas`, `!texasholdem`, `!the` - Pokreni novu igru
- `!join` - Pridruži se igri u toku
- `!play` - Pokreni igru sa trenutnim igračima
- `!rankings` - Prikaži top 10 rangiranje (dodaj 'channel' za prikaz na kanalu)
- `!rank` - Prikaži svoje lično rangiranje
- `!cardmsg <notice|privmsg>` - Podesi kako primaš poruke sa kartama
- `!help` - Prikaži sve dostupne komande
- `!stop`, `!end`, `!endgame`, `!stfu`, `!quiet` - Zaustavi trenutnu igru (samo operatori ili pokretač igre)
- `!clearrankings` - Obriši sva rangiranja (samo operatori kanala)

**Konfiguracija:**
- `.chanset #channel +holdem` - Omogući skriptu na kanalu
- Podesive opcije: buy-in, blindovi, timeout, bot igrači, itd.

**Funkcionalnosti:**
- Sistem rangiranja sa automatskim resetovanjem svakog meseca
- Per-user preferencije za tip poruka sa kartama (NOTICE/PRIVMSG)
- Podrška za UTF-8 Unicode karaktere za karte
- AI bot igrači sa konfigurabilnom agresivnošću
- Statistike: igre odigrane, ruke osvojene, ukupni poeni

---

## 🔮 horoskop.tcl

**Verzija:** 3.1337  
**Autor:** tik-tak (original), modifikovao munZe  
**Opis:** Skripta za dohvatanje horoskopa sa sajta astrolook.com. Podržava dnevne, nedeljne, mesečne, ljubavne, godišnje horoskope i srećne dane.

**Komande:**
- `!horoskop <znak>` ili `!dnevni <znak>` - Dnevni horoskop
- `!nedeljni <znak>` - Nedeljni horoskop
- `!mesecni <znak>` - Mesečni horoskop
- `!ljubavni <znak>` - Ljubavni horoskop
- `!godisnji <znak>` - Godišnji horoskop
- `!srecni <znak>` ili `!srecni-dani <znak>` - Srećni dani

**Dostupni znakovi:** ovan, bik, blizanci, rak, lav, devica, vaga, skorpija/skorpion, strelac, jarac, vodolija, ribe

**Funkcionalnosti:**
- Flood protection sa dnevnim limitima
- Kesiranje na dnevnom nivou za brže učitavanje
- Podrška za HTTPS/TLS
- Privatne komande (MSG botu)
- Konfigurabilni način slanja (kanal/PRIVMSG/NOTICE)

**Konfiguracija:**
- `set saljina 1` - Slanje na kanal
- `set saljina 2` - Slanje na PRIVMSG (default)
- `set saljina 3` - Slanje na NOTICE

---

## 💻 cpu.tcl

**Verzija:** 1.0.0  
**Autor:** Velimir Majstorov (munZe)  
**Opis:** Monitoring sistema za praćenje CPU opterećenja i memorije. Automatski upozorava kada load average pređe konfigurisani threshold.

**Komande:**
- `!cpu` - Prikaži CPU load average (1min, 5min, 15min)
- `!mem` - Prikaži informacije o memoriji (free, available, used, total)
- `!timerz` - Lista svih aktivnih timera u botu

**Funkcionalnosti:**
- Automatsko periodično proveravanje CPU opterećenja
- Upozorenja na kanalu kada threshold bude prekoračen
- Ograničenje komandi na određeni kanal (#services)
- Autorizacija: admin nicks (munZe) ili master flag/operatori

**Konfiguracija:**
- `set cpu_monitor_channel "#services"` - Kanal za monitoring
- `set cpu_check_interval 300` - Interval provere (sekunde)
- `set cpu_threshold 5.0` - Threshold za upozorenja

---

## 😄 prcko.tcl

**Verzija:** 1.337  
**Autor:** Velimir Majstorov (munZe)  
**Opis:** Zabavne komande za IRC kanale sa različitim procenama i porukama. Uključuje flood protection.

**Komande:**
- `!prc <nick>` - Random "prc" poruka
- `!drka <nick>` - Random "drka" poruka
- `!izmeri <nick>` - Random veličina penisa (10-25 cm)
- `!sise <nick>` - Random veličina grudi
- `!sexy <nick>` - Random sexy procenat (0-100%)
- `!gay <nick>` - Random gay procenat (0-100%)
- `!hacker <nick>` - Random hacker procenat (0-100%)
- `!laze <nick>` - Random procenat laži (0-100%)
- `!istina <nick>` - Random procenat istine (0-100%)
- `!ozbiljan <nick>` / `!ozbiljna <nick>` - Random procenat ozbiljnosti
- `!neozbiljan <nick>` / `!neozbiljna <nick>` - Random procenat neozbiljnosti
- `!crnac <nick>` - Random procenat
- `!veverica <nick>` - Random procenat
- `!govedo <nick>` - Random procenat
- `!dupe <nick>` ili `!guza <nick>` - Random "dupe" poruka
- `!komande` - Lista svih dostupnih komandi
- `!iamon` - Lista kanala na kojima je bot (zahteva +n flag)
- `!ignore <nick>` - Dodaj korisnika na ignore listu (zahteva +m flag)

**Funkcionalnosti:**
- Flood protection sa automatskim banovanjem
- Lista izuzetih nickova sa posebnim odgovorima
- Interaktivni odgovori na određene fraze u kanalu

---

## 📰 rss-synd.tcl

**Verzija:** 0.5.2  
**Autor:** Andrew Scott, HM2K, modifikovao Velimir Majstorov (munZe)  
**Opis:** Asinhroni RSS i Atom feed reader sa podrškom za više feedova, gzip kompresiju, automatsko slanje na kanale, i custom triggere.

**Komande:**
- `!vesti` ili `!rss vesti` - Prikaži najnovije vesti (do 10 stavki)
- `!rss` - Lista svih dostupnih feedova

**Funkcionalnosti:**
- HTTPS/TLS podrška
- Gzip dekompresija (zahteva Trf paket - vidi sekciju Zavisnosti)
- Automatsko ažuriranje na konfigurisanim intervalima
- Debug logging na #services kanal
- Custom output formatiranje
- Baza podataka za praćenje novih stavki

**Konfiguracija:**
- Feedovi se konfigurišu direktno u skripti (rss() array)
- Baza podataka: `feeds/` (kreira se automatski)
- Debug logging: kontrolisano preko "debug" settinga

---

## 👋 massslap.tcl

**Verzija:** 1.0.0  
**Autor:** Velimir Majstorov (munZe)  
**Opis:** Komanda za slanje masovnih slap poruka svim korisnicima na kanalu. Podržava ACTION (/me) i PRIVMSG format.

**Komande:**
- `.call [opciona poruka]` - Pošalji mass slap svim korisnicima na kanalu

**Funkcionalnosti:**
- Dual autorizacija: autorizovani korisnici ili operatori/halfops
- Konfigurabilni format poruke (ACTION/PRIVMSG)
- Automatsko deljenje dugih poruka
- Rate limiting za sprečavanje floodovanja

**Konfiguracija:**
- `set authorized_users` - Lista autorizovanih korisnika
- `set use_action 1` - Koristi ACTION format (1) ili PRIVMSG (0)

---

## 🔄 rehash.tcl

**Verzija:** 1.0.0  
**Autor:** Velimir Majstorov (munZe)  
**Opis:** Omogućava autorizovanim korisnicima da rehashuju bot konfiguraciju preko IRC komande.

**Komande:**
- `!rehash` - Rehashuj bot konfiguraciju

**Funkcionalnosti:**
- Autorizacija preko liste korisnika
- Case-insensitive matching
- Provera i handle-a i nick-a

**Konfiguracija:**
- `set authorized_users` - Lista autorizovanih korisnika

---

## 📨 privmsg_forward.tcl

**Verzija:** 1.0.0  
**Autor:** Velimir Majstorov (munZe)  
**Opis:** Prosleđuje sve privatne poruke koje bot primi na konfigurisani kanal. Korisno za monitoring i logovanje.

**Funkcionalnosti:**
- Automatsko prosleđivanje svih PRIVMSG poruka
- Prikaz handle-a kada je dostupan
- Validacija kanala pre slanja

**Konfiguracija:**
- `set privmsg_channel "#services"` - Destinacioni kanal

---

## 🛡️ PIKbl.tcl

**Verzija:** 1.337  
**Autor:** Velimir Majstorov (munZe)  
**Opis:** Skripta za automatsko proveravanje IP adresa korisnika koji se povezuju na IRC server. Proverava IP adrese preko pricaonica.krstarica.com servisa i automatski banuje problematične IP adrese.

**Funkcionalnosti:**
- Automatsko hvatanje novih konekcija
- Provera IP adresa preko eksternog servisa
- Automatsko banovanje problematičnih IP adresa (GLINE/ZLINE)
- Obaveštenja na konfigurisanom kanalu
- Oper up na serveru za izvršavanje banova

**Konfiguracija:**
- `set BanAkoJeVeceOd` - Threshold za banovanje (default: 60.6)
- `set KanalZaObavestenja` - Kanal za obaveštenja (default: #services)
- `set bantype` - Tip bana (GLINE/ZLINE)
- `set bantime` - Trajanje bana (npr. "12h")
- `set opernick` / `set operpass` - Oper credentials za banovanje

---

### ⚠️ Zastarele Skripte

⚠️ **NAPOMENA:** Sledeće skripte su zastarele i trenutno ne rade. Mogu biti ispravljene u budućnosti.

---

## 🎾 tenis.tcl

**Status:** ⚠️ **ZASTARELO** - Ne radi trenutno  
**Verzija:** 0.1337  
**Autor:** Velimir Majstorov (munZe)  
**Opis:** Skripta za dohvatanje ATP tenis rangiranja sa atpworldtour.com. Prikazuje top 3 igrača sa detaljnim informacijama.

**Komande:**
- `!tenistop3` - Prikaži top 3 tenisera

**Funkcionalnosti:**
- Parsiranje HTML sajta
- Formatiranje i prikaz rangiranja
- HTTP podrška

**Razlog zastarelosti:** Verovatno promene na ATP sajtu ili HTTP strukture. Plan: Ispravka parsiranja i ažuriranje za novu strukturu sajta.

---

## 🌤️ vremenska-prognoza.tcl

**Status:** ⚠️ **ZASTARELO** - Ne radi trenutno  
**Verzija:** 1.0.0  
**Autor:** Velimir Majstorov (munZe)  
**Opis:** Skripta za dohvatanje vremenske prognoze za gradove u Srbiji sa sajta blic.rs. Prikazuje trenutne vremenske uslove sa detaljnim informacijama.

**Komande:**
- `!vreme <grad>` - Prikaži vremensku prognozu za odabrani grad

**Dostupni gradovi:** Beograd, Pristina, Crni-Vrh, Kikinda, Negotin, Sjenica, Valjevo, Krusevac, Pancevo, Kragujevac, Novi-Sad, Kopaonik, Dimitrovgrad, Kraljevo, Palic, Smederevo, Zrenjanin, Vrsac, Cacak, Subotica, Nis, Vranje, Loznica, Leskova, Ruma, Sremska-Mitrovica, Zlatibor, Knjazevac, Uzice

**Funkcionalnosti:**
- Parsiranje HTML sajta
- Prikaz trenutnih vremenskih uslova (temperatura, pritisak, vetar, vlažnost, vidljivost, UV index)
- UTF-8 encoding podrška

**Razlog zastarelosti:** Verovatno promene na blic.rs sajtu ili HTTP strukture. Plan: Rekreacija skripte za dohvatanje vremenske prognoze.

---

## 🌧️ vrijeme.tcl

**Status:** ⚠️ **ZASTARELO** - Ne radi trenutno  
**Verzija:** 1.0.0  
**Autor:** Velimir Majstorov (munZe)  
**Opis:** Skripta za dohvatanje vremenske prognoze za gradove u Bosni i Hercegovini sa sajta prognozavremena.info. Prikazuje trenutne vremenske uslove sa detaljnim informacijama.

**Komande:**
- `!vrijeme <grad>` - Prikaži vremensku prognozu za odabrani grad

**Dostupni gradovi:** Banja Luka, Bihac, Bijeljina, Brcko, Jahorina, Mostar, Neum, Sarajevo, Trebinje, Tuzla, Visegrad

**Funkcionalnosti:**
- Parsiranje HTML sajta
- Prikaz trenutnih vremenskih uslova (temperatura, pritisak, brzina vetra, vlažnost, vidljivost, subjektivno, naleti vetra, izlazak/zalazak sunca)
- UTF-8 encoding podrška

**Razlog zastarelosti:** Verovatno promene na prognozavremena.info sajtu ili HTTP strukture. Plan: Rekreacija skripte za dohvatanje vremenske prognoze.

---

## 📦 Zavisnosti

### 📦 trf2.1.5.tar.gz

**Opis:** Trf (Trf Extension) je TCL ekstenzija koja je potrebna za `rss-synd.tcl` skriptu. Originalna Trf ekstenzija je zastarela i ne radi sa novijim verzijama TCL-a (TCL 8.6+). 

**Status:** Modifikovana verzija uključena u repozitorijum je prilagođena da radi sa TCL 8.6. Modifikacije su urađene od strane autora (munZe) kako bi skripta `rss-synd.tcl` mogla da koristi gzip dekompresiju za RSS feedove koji su kompresovani.

**Instalacija:**
1. Raspakujte `trf2.1.5.tar.gz` arhivu
2. Kompajlirajte i instalirajte Trf ekstenziju prema uputstvima u paketu
3. Uverite se da je Trf ekstenzija dostupna u TCL okruženju pre pokretanja `rss-synd.tcl`

**Napomena:** Bez Trf ekstenzije, `rss-synd.tcl` će raditi, ali neće moći da dekompresuje gzip kompresovane RSS feedove.

---

## 📝 Napomene

- Većina skripti je razvijena za Eggdrop 1.10.0+
- TCL skripte zahtevaju standardne TCL pakete (http, tls)
- `rss-synd.tcl` zahteva Trf ekstenziju za gzip dekompresiju (vidi sekciju Zavisnosti)
- Sve skripte su testirane i optimizovane za TCL 8.6

---

## 📄 Licenca

Većina skripti je pod MIT licencom. Proverite header svake skripte za specifične licence.

---

## 👤 Autor

**Velimir Majstorov** (AKA munZe)  
🌐 DBase Network - irc.dbase.in.rs  
🔗 GitHub: [r0073rr0r/eggdrop-scripts](https://github.com/r0073rr0r/eggdrop-scripts)

---

*Poslednje ažuriranje: 2025*
