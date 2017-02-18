--[[
Author: Ayantir
Filename: de.lua
Version: 5

Ä = \195\132
ä = \195\164
Ö = \195\150
ö = \195\182
Ü = \195\156
ü = \195\188
ß = \195\159

Many Thanks to Phidias & Baetram for their work

]]--

pChat = pChat or {}
pChat.lang = {}
PCHAT_CHANNEL_NONE = 99

-- Vars with -H are headers, -TT are tooltips

-- Messages settings

pChat.lang.optionsH = "Nachrichtenoptionen"

pChat.lang.guildnumbers = "Gildennummer"
pChat.lang.guildnumbersTT = "Zeigt die Gildennummer neben dem Gildenkürzel an."

pChat.lang.allGuildsSameColour = "Nutze eine Farbe für alle Gilden"
pChat.lang.allGuildsSameColourTT = "Für alle 'Gildenchats' gilt die gleiche Farbeinstellung wie für die erste Gilde (/g1)."

pChat.lang.allZonesSameColour = "Nutze eine Farbe für alle 'Zonenchats'"
pChat.lang.allZonesSameColourTT = "Für alle 'Zonenchats' gilt die gleiche Farbeinstellung wie für (/zone)."

pChat.lang.allNPCSameColour = "Nutze eine Farbe für alle NSCs"
pChat.lang.allNPCSameColourTT = "Füe alle Texte von Nicht-Spieler-Charakteren (NSCs / NPCs) gilt die Farbeinstellung für 'NSC Sagen'."

pChat.lang.delzonetags = "Bezeichnung entfernen"
pChat.lang.delzonetagsTT = "Bezeichnungen ('tags') wie Schreien oder Zone am Anfang der Nachrichten entfernen."

pChat.lang.zonetagsay = "Sagen"
pChat.lang.zonetagyell = "Schreien"
pChat.lang.zonetagparty = "Gruppe"
pChat.lang.zonetagzone = "Zone"

pChat.lang.carriageReturn = "Spielernamen und Chattexte in eigenen Zeilen"
pChat.lang.carriageReturnTT = "Spielernamen und Chattexte werden durch einen Zeilenvorschub getrennt."

pChat.lang.useESOcolors = "ESO Standardfarben"
pChat.lang.useESOcolorsTT = "Verwendet statt der pchat Vorgabe die The Elder Scrolls Online Standard-Chat-Farben."

pChat.lang.diffforESOcolors = "Namen Farbig absetzen"
pChat.lang.diffforESOcolorsTT = "Bestimmt den Helligkeitsunterschied zwischen Charakternamen / Chat-Kanal und Nachrichtentext."

pChat.lang.removecolorsfrommessages = "Entferne Farbe aus Nachrichten"
pChat.lang.removecolorsfrommessagesTT = "Verhindert die Anzeige von Farben in Nachrichten (z.B. Regenbogentext von Mitspielern)."

pChat.lang.augmentHistoryBuffer = "Augment # of lines in displayed n chat"
pChat.lang.augmentHistoryBufferTT = "Per default, only the last 200 lines are displayed in chat. This feature raise this value up to 1000 lines"

pChat.lang.preventchattextfading = "Textausblenden unterbinden"
pChat.lang.preventchattextfadingTT = "Verhindert,daß der Chat-Text ausgeblendet wird (Einstellungen zum Chat-Hintergrund finden sich unter Einstellungen: Soziales - Minimale Transparenz)"

pChat.lang.useonecolorforlines = "Einfarbige Zeilen"
pChat.lang.useonecolorforlinesTT = "Verwendet nur eine Farbe pro Chat-Kanal, anstatt zwei Farben nur die Erste."

pChat.lang.guildtagsnexttoentrybox = "Gildenkürzel neben der Eingabe"
pChat.lang.guildtagsnexttoentryboxTT = "Zeigt das Gildenkürzel anstelle des Gildennamens neben der Eingabezeile an."

pChat.lang.disableBrackets = "Klammern um Namen entfernen"
pChat.lang.disableBracketsTT = "Entfernt Klammern [] um die Namen der Spieler"

pChat.lang.defaultchannel = "Standardkanal"
pChat.lang.defaultchannelTT = "Bestimmt welcher Chat-Kanal nach der Anmeldung automatisch zuerst verwendet wird."

pChat.lang.defaultchannelchoice = {}
pChat.lang.defaultchannelchoice[PCHAT_CHANNEL_NONE] = "Ändern Sie nicht"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_ZONE] = "/zone"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_SAY] = "/sagen"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_1] = "/gilde1"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_2] = "/gilde2"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_3] = "/gilde3"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_4] = "/gilde4"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_5] = "/gilde5"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_1] = "/offizier1"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_2] = "/offizier2"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_3] = "/offizier3"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_4] = "/offizier4"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_5] = "/offizier5"

pChat.lang.geoChannelsFormat = "Names format"
pChat.lang.geoChannelsFormatTT = "Names format for local channels (say, zone, tell)"

pChat.lang.defaultTab = "Default tab"
pChat.lang.defaultTabTT = "Select which tab to display at startup"

pChat.lang.addChannelAndTargetToHistory = "Switch channel when using history"
pChat.lang.addChannelAndTargetToHistoryTT = "Switch the channel when using arrow keys to match the channel previously used."

pChat.lang.urlHandling = "Detect and make URLs linkable"
pChat.lang.urlHandlingTT = "If a URL starting with http(s):// is linked in chat pChat will detect it and you'll be able to click on it to directly go on the concerned link with your system browser"

pChat.lang.enablecopy = "Kopie/Chat Kanal Wechsel aktivieren"
pChat.lang.enablecopyTT = "Aktivieren Sie das Kopieren von Text mit einem Rechtsklick.\nDies ermöglicht ebenfalls den Chat Kanal-Wechsel mit einem Linksklick.\n\nDeaktivieren Sie diese Option, wenn Sie Probleme mit der Anzeige von Links im Chat haben."

-- Group Settings

pChat.lang.groupH = "Party channel tweaks"

pChat.lang.enablepartyswitch = "Enable Party Switch"
pChat.lang.enablepartyswitchTT = "Enabling Party switch will switch your current channel to party when joinin a party and  switch back to your default channel when leaving a party"

pChat.lang.groupLeader = "Special color for party leader"
pChat.lang.groupLeaderTT = "Enabling this feature will let you set a special color for party leader messages"

pChat.lang.groupLeaderColor = "Party leader color"
pChat.lang.groupLeaderColorTT = "Color of party leader messages. 2nd color is only to set if \"Use ESO colors\" is set to Off"

pChat.lang.groupLeaderColor1 = "Color of messages for party leader"
pChat.lang.groupLeaderColor1TT = "Color of message for party leader. If \"Use ESO colors\" is set to Off, this option will be disabled. The color of the party leader will be the one set above and the party leader messages will be this one"

pChat.lang.groupNames = "Names format for groups"
pChat.lang.groupNamesTT = "Format of your groupmates names in party channel"

pChat.lang.groupNamesChoice = {}
pChat.lang.groupNamesChoice[1] = "@Accountname"
pChat.lang.groupNamesChoice[2] = "Charaktername"
pChat.lang.groupNamesChoice[3] = "Charaktername@Accountname"

-- Sync settings

pChat.lang.SyncH = "Synchronisierungseinstellungen"

pChat.lang.chatSyncConfig = "Chat-Konfiguration synchronisieren"
pChat.lang.chatSyncConfigTT = "Wenn die Synchronisierung aktiviert ist, werden alle Charaktere die gleiche Chat-Konfiguration (Farben, Position, Fensterabmessungen, Reiter) bekommen:\nAktivieren Sie diese Option, nachdem Sie Ihren Chat vollständig angepasst haben, und er wird für alle anderen Charaktere gleich eingestellt!"

pChat.lang.chatSyncConfigImportFrom = "Chat Einstellungen übernehmen von"
pChat.lang.chatSyncConfigImportFromTT = "Sie können jederzeit die Chat-Einstellungen von einem anderen Charakter importieren (Farbe, Ausrichtung, Fenstergröße, Reiter).\nWählen Sie hier Ihren 'Vorlage Charakter' aus."

-- Apparence

pChat.lang.ApparenceMH = "Chatfenster Aussehen"

pChat.lang.tabwarning = "Neue Nachricht Warnung"
pChat.lang.tabwarningTT = "Legen Sie die Farbe für die Warnmeldung im Chat Reiter fest."

pChat.lang.windowDarkness = "Transparenz des Chat-Fensters"
pChat.lang.windowDarknessTT = "Erhöhen Sie die Verdunkelung des Chat-Fensters"

pChat.lang.chatMinimizedAtLaunch = "Chat beim Start minimiert"
pChat.lang.chatMinimizedAtLaunchTT = "Chat-Fenster auf der linken Seite des Bildschirms minimieren, wenn das Spiel startet"

pChat.lang.chatMinimizedInMenus = "Chat in Menüs minimiert"
pChat.lang.chatMinimizedInMenusTT = "Chat-Fenster auf der linken Seite des Bildschirms minimieren, wenn Menüs (Gilde, Charakter, Handwerk, etc.) geöffnet werden"

pChat.lang.chatMaximizedAfterMenus = "Chat nach Menüs wieder herstellen"
pChat.lang.chatMaximizedAfterMenusTT = "Zeigt das Chat Fenster, nach dem Verlassen von Menüs, wieder an"

pChat.lang.fontChange = "Schriftart"
pChat.lang.fontChangeTT = "Wählen Sie die Schriftart für den Chat aus.\nStandard: 'ESO Standard Font'"

-- Whisper settings

pChat.lang.IMH = "Flüstern"

pChat.lang.soundforincwhisps = "Ton für eingehende Flüsternachricht"
pChat.lang.soundforincwhispsTT = "Wählen Sie Sound, der abgespielt wird, wenn Sie ein Flüstern erhalten"

pChat.lang.notifyIM = "Visuelle Hinweise anzeigen"
pChat.lang.notifyIMTT = "Wenn Sie eine Flüsternachricht verpassen, wird eine Meldung in der oberen rechten Ecke des Chat-Fenster angezeigt. Wenn Sie auf diese Meldung klicken werden Sie direkt zur Flüsternachricht im Chat gebracht.\nWar Ihr Chat zum Zeitpunkt des Nachrichteneinganges minimiert, wird in der Chat Mini-Leiste ebenfalls eine Benachrichtigung angezeigt."

pChat.lang.soundforincwhispschoice = {}
pChat.lang.soundforincwhispschoice[SOUNDS.NONE] = "-KEIN TON-"
pChat.lang.soundforincwhispschoice[SOUNDS.NEW_NOTIFICATION] = "Benachrichtigung"
pChat.lang.soundforincwhispschoice[SOUNDS.DEFAULT_CLICK] = "Klicken"
pChat.lang.soundforincwhispschoice[SOUNDS.EDIT_CLICK] = "Schreiben"

-- Restore chat settings

pChat.lang.restoreChatH = "Chat wiederherstellen"

pChat.lang.restoreOnReloadUI = "Nach ReloadUI"
pChat.lang.restoreOnReloadUITT = "Nach dem Neuladen der Benutzeroberfläche (/reloadui) wird pChat den vorherigen Chat + Historie wieder herstellen. Sie können somit Ihre vorherige Konversation wieder aufnehmen."

pChat.lang.restoreOnLogOut = "Nach LogOut"
pChat.lang.restoreOnLogOutTT = "Nach dem Ausloggen wird pChat den vorherigen Chat + Historie wieder herstellen. Sie können somit Ihre vorherige Konversation wieder aufnehmen.\nAchtung: Dies wird nur passieren, wenn Sie sich in der unten eingestellten 'Maximale Zeit für Wiederherstellung' erneut anmelden!"

pChat.lang.restoreOnAFK = "Nach Kick (z.B. Inaktivität)"
pChat.lang.restoreOnAFKTT = "Nachdem Sie vom Spiel rausgeschmissen wurden, z.B. durch Inaktivität, Senden zuvieler Nachrichten oder einer Netzwerk Trennung, wird pChat den Chat + Historie wieder herstellen. Sie können somit Ihre vorherige Konversation wieder aufnehmen.\nAchtung: Dies wird nur passieren, wenn Sie sich in der unten eingestellten 'Maximale Zeit für Wiederherstellung' erneut anmelden!"

pChat.lang.restoreOnQuit = "Nach dem Verlassen"
pChat.lang.restoreOnQuitTT = "Wenn Sie das Spiel selbstständig verlassen, wird pChat den Chat + Historie wieder herstellen. Sie können somit Ihre vorherige Konversation wieder aufnehmen.\nAchtung: Dies wird nur passieren, wenn Sie sich in der unten eingestellten 'Maximale Zeit für Wiederherstellung' erneut anmelden!"

pChat.lang.timeBeforeRestore = "Maximale Zeit für Wiederherstellung"
pChat.lang.timeBeforeRestoreTT = "NACH dieser Zeit (in Stunden), wird pChat nicht mehr versuchen, den Chat wieder herzustellen"

pChat.lang.restoreSystem = "Systemnachrichten wiederherstellen"
pChat.lang.restoreSystemTT = "Stelle auch Systemnachrichten wieder her (z.B. Login Nachrichten, Addon Nachrichten) wenn der Chat + Historie wiederhergestellt werden"

pChat.lang.restoreSystemOnly = "Nur Systemnachrichten wiederherstellen"
pChat.lang.restoreSystemOnlyTT = "Restore Only System Messages (Such as login notifications or add ons messages) when chat is restored"

pChat.lang.restoreWhisps = "Restore Whispers"
pChat.lang.restoreWhispsTT = "Restore whispers sent and received after logoff, disconnect or quit. Whispers are always restored after a ReloadUI()"

pChat.lang.restoreTextEntryHistoryAtLogOutQuit  = "Restore Text entry history"
pChat.lang.restoreTextEntryHistoryAtLogOutQuitTT  = "Restore Text entry history available with arrow keys after logoff, disconnect or quit. History of text entry is always restored after a ReloadUI()"

-- Anti Spam settings

pChat.lang.antispamH = "Anti-Spam"

pChat.lang.floodProtect = "Aktiviere Anti-Flood"
pChat.lang.floodProtectTT = "Verhindert, dass Ihnen sich wiederholende, identische Nachrichten von Spielern angezeigt werden"

pChat.lang.floodGracePeriod = "Dauer Anti-Flood Verbannung"
pChat.lang.floodGracePeriodTT = "Anzahl der Sekunden in denen sich wiederholende, identische Nachrichten ignoriert werden"

pChat.lang.lookingForProtect = "Ignoriere Gruppen(suche)nachrichten"
pChat.lang.lookingForProtectTT = "Ignoriert Nachrichten, mit denen nach Gruppen/Gruppenmitgliedern gesucht wird"

pChat.lang.wantToProtect = "Ignoriere Handelsnachrichten "
pChat.lang.wantToProtectTT = "Ignoriert Nachrichten von Spielern, die etwas handeln oder ver-/kaufen möchten"

pChat.lang.spamGracePeriod = "Anti-Flood temporär deaktivieren"
pChat.lang.spamGracePeriodTT = "Wenn Sie selber eine Gruppe suchen, einen Handel oder Ver-/Kauf über den Chat kommunizieren, wird der Anti-Flood Schutz temporär aufgehoben.\nDiese Einstellung legt die Minuten fest, nachdem der Anti-Flood Schutz wieder aktiviert wird."

-- Nicknames settings

pChat.lang.nicknamesH = "Nicknames"
pChat.lang.nicknamesD = "You can add nicnknames for the people you want, just type OldName = Newname\n\nE.g : @Ayantir = Little Blonde\nIt will change the name of all the account if OldName is a @UserID or only the specified Char if the OldName is a Character Name."
pChat.lang.nicknames = "List of Nicknames"
pChat.lang.nicknamesTT = "You can add nicnknames for the people you want, just type OldName = Newname\n\nE.g : @Ayantir = Little Blonde\n\nIt will change the name of all the account if OldName is a @UserID or only the specified Char if the OldName is a Character Name."

-- Timestamp settings

pChat.lang.timestampH = "Zeitstempel"

pChat.lang.enabletimestamp = "Aktiviere Zeitstempel"
pChat.lang.enabletimestampTT = "Fügt Chat-Nachrichten einen Zeitstempel hinzu."

pChat.lang.timestampcolorislcol = "Zeitstempel und Spielernamen gleich färben"
pChat.lang.timestampcolorislcolTT = "Für den Zeitstempel gilt die gleiche Farbeinstellung wie für den Spielernamen, oder Nicht-Spieler-Charakter (NSC / NPC)"

pChat.lang.timestampformat = "Zeitstempelformat"
pChat.lang.timestampformatTT = "FORMAT:\nHH: Stunden (24)\nhh: Stunden (12)\nH: Stunde (24, keine vorangestellte 0)\nh: Stunde (12, keine vorangestellte 0)\nA: AM/PM\na: am/pm\nm: Minuten\ns: Sekunden"

pChat.lang.timestamp = "Zeitstempel"
pChat.lang.timestampTT = "Legt die Farbe des Zeitstempels fest."

-- Guild settings

pChat.lang.nicknamefor = "Spitzname"
pChat.lang.nicknameforTT = "Spitzname für "

pChat.lang.officertag = "Offizierskanal"
pChat.lang.officertagTT = "Seperates Präfix für den Offizierskanal verwenden."

pChat.lang.switchFor = "Switch for channel"
pChat.lang.switchForTT = "New switch for channel. Ex: /myguild"

pChat.lang.officerSwitchFor = "Switch for officer channel"
pChat.lang.officerSwitchForTT = "New switch for officer channel. Ex: /offs"

pChat.lang.nameformat = "Namensformat"
pChat.lang.nameformatTT = "Legt die Formatierung für die Namensanzeige von Gildenmitgliedern fest."

pChat.lang.formatchoice1 = "@Accountname"
pChat.lang.formatchoice2 = "Charaktername"
pChat.lang.formatchoice3 = "Charaktername@Accountname"

pChat.lang.setcolorsforTT = "Farbe für Mitglieder von "
pChat.lang.setcolorsforchatTT = "Farbe für Nachrichten von "

pChat.lang.setcolorsforofficiersTT = "Farbe für Mitglieder des 'Offiziers-Chats' von "
pChat.lang.setcolorsforofficierschatTT = "Farbe für Nachrichten des 'Offiziers-Chats' von "

pChat.lang.members = " - Spieler"
pChat.lang.chat = " - Nachrichten"

pChat.lang.officersTT = " Offiziere"

-- Channel colors settings

pChat.lang.chatcolorsH = "Chat-Farben"

pChat.lang.say = "Sagen - Spieler"
pChat.lang.sayTT = "Legt die Farbe für vom Spieler verfasste Nachrichten im Chat-Kanal: Sagen fest."

pChat.lang.saychat = "Sagen - Chat"
pChat.lang.saychatTT = "Legt die Farbe der Nachrichten im Chat-Kanal: Sagen fest."

pChat.lang.zone = "Zone - Spieler"
pChat.lang.zoneTT = "Legt die Farbe für vom Spieler verfasste Nachrichten im Chat-Kanal: Zone fest."

pChat.lang.zonechat = "Zone - Chat"
pChat.lang.zonechatTT = "Legt die Farbe der Nachrichten im Chat-Kanal: Zone fest."

pChat.lang.yell = "Schreien - Spieler"
pChat.lang.yellTT = "Legt die Farbe für vom Spieler verfasste Nachrichten im Chat-Kanal: Schreien fest."

pChat.lang.yellchat = "Schreien - Chat"
pChat.lang.yellchatTT = "Legt die Farbe der Nachrichten im Chat-Kanal: Schreien fest."

pChat.lang.incomingwhispers = "Eingehendes Flüstern - Spieler"
pChat.lang.incomingwhispersTT = "Legt die Farbe für vom Spieler verfasste Nachrichten im Chat-Kanal: eingehendes Flüstern fest."

pChat.lang.incomingwhisperschat = "Eingehendes Flüstern - Chat"
pChat.lang.incomingwhisperschatTT = "Legt die Farbe der Nachrichten im Chat-Kanal: eingehendes Flüstern fest."

pChat.lang.outgoingwhispers = "Ausgehendes Flüstern - Spieler"
pChat.lang.outgoingwhispersTT = "Legt die Farbe für vom Spieler verfasste Nachrichten im Chat-Kanal: ausgehendes Flüstern fest."

pChat.lang.outgoingwhisperschat = "Ausgehendes Flüstern - Chat"
pChat.lang.outgoingwhisperschatTT = "Legt die Farbe der Nachrichten im Chat-Kanal: ausgehendes Flüstern fest."

pChat.lang.group = "Gruppe - Spieler"
pChat.lang.groupTT = "Legt die Farbe für vom Spieler verfasste Nachrichten im Chat-Kanal: Gruppe fest."

pChat.lang.groupchat = "Gruppe - Chat"
pChat.lang.groupchatTT = "Legt die Farbe der Nachrichten im Chat-Kanal: Gruppe fest."

-- Other colors

pChat.lang.othercolorsH = "Sonstige Farben"

pChat.lang.emotes = "'Emotes' - Spieler"
pChat.lang.emotesTT = "Legt die Farbe für vom Spieler ausgeführte 'Emotes' fest."

pChat.lang.emoteschat = "Emotes - Chat"
pChat.lang.emoteschatTT = "Legt die Farbe von 'Emotes' im Chat fest."

pChat.lang.enzone = "EN Zone - Spieler"
pChat.lang.enzoneTT = "Legt die Farbe für vom Spieler verfasste Nachrichten im englischsprachigen Chat-Kanal fest."

pChat.lang.enzonechat = "EN Zone - Chat"
pChat.lang.enzonechatTT = "Legt die Farbe der Nachrichten im englischsprachigen Chat-Kanal fest."

pChat.lang.frzone = "FR Zone - Spieler"
pChat.lang.frzoneTT = "Legt die Farbe für vom Spieler verfasste Nachrichten im französischsprachigen Chat-Kanal fest."

pChat.lang.frzonechat = "FR Zone - Chat"
pChat.lang.frzonechatTT = "Legt die Farbe der Nachrichten im französischsprachigen Chat-Kanal fest."

pChat.lang.dezone = "DE Zone - Spieler"
pChat.lang.dezoneTT = "Legt die Farbe für vom Spieler verfasste Nachrichten im deutschsprachigen Chat-Kanal fest."

pChat.lang.dezonechat = "DE Zone - Chat"
pChat.lang.dezonechatTT = "Legt die Farbe der Nachrichten im deutschsprachigen Chat-Kanal fest."

pChat.lang.jpzone = "JP Zone - Spieler"
pChat.lang.jpzoneTT = "Legt die Farbe für vom Spieler verfasste Nachrichten im japanisch Chat-Kanal fest."

pChat.lang.jpzonechat = "JP Zone - Chat"
pChat.lang.jpzonechatTT = "Legt die Farbe der Nachrichten im japanisch Chat-Kanal fest."

pChat.lang.npcsay = "NSC Sagen - NSC Name"
pChat.lang.npcsayTT = "Legt die Farbe des Namens des Nicht-Spieler-Charakters (NSC - NPC) in NSC-Texten fest."

pChat.lang.npcsaychat = "NSC Sagen - Chat"
pChat.lang.npcsaychatTT = "Legt die Farbe für Nicht-Spieler-Charaktertexte fest."

pChat.lang.npcyell = "NSC Schreien - NSC Name"
pChat.lang.npcyellTT = "Legt die Farbe des Namens des Nicht-Spieler-Charakters (NSC - NPC) in geschrienen NSC-Texten fest."

pChat.lang.npcyellchat = "NSC Schreien - Chat"
pChat.lang.npcyellchatTT = "Legt die Farbe für geschriene Nicht-Spieler-Charaktertexte fest."

pChat.lang.npcwhisper = "NSC Flüstern - NSC Name"
pChat.lang.npcwhisperTT = "Legt die Farbe des Namens des Nicht-Spieler-Charakters (NSC - NPC) in geflüsterten NSC-Texten fest."

pChat.lang.npcwhisperchat = "NSC Flüstern - Chat"
pChat.lang.npcwhisperchatTT = "Legt die Farbe für geflüsterte Nicht-Spieler-Charaktertexte fest."

pChat.lang.npcemotes = "NSC 'Emote' - NSC Name"
pChat.lang.npcemotesTT = "Legt die Farbe des Namens des Nicht-Spieler-Charakters (NSC - NPC) der ein 'Emote' ausführt fest."

pChat.lang.npcemoteschat = "NSC 'Emote' - Chat"
pChat.lang.npcemoteschatTT = "Legt die Farbe für 'Nicht-Spieler-Charakter-Emotes' im Chat fest."

-- Debug settings

pChat.lang.debugH = "Debug"

pChat.lang.debug = "Debug"
pChat.lang.debugTT = "Debug"

-- Various strings not in panel settings

pChat.lang.CopyMessageCT = "Nachricht kopieren"
pChat.lang.CopyLineCT = "Zeile kopieren"
pChat.lang.CopyDiscussionCT = "Diskussion kopieren"
pChat.lang.AllCT = "Ganzes Plaudern kopieren"

pChat.lang.copyXMLTitle = "Kopiere Text mit STRG+C"
pChat.lang.copyXMLLabel = "Kopiere Text mit STRG+C"
pChat.lang.copyXMLTooLong = "Text ist uzu lang und wurde aufgeteilt"
pChat.lang.copyXMLNext = "Nächster"

pChat.lang.switchToNextTabBinding = "Zur nächsten Registerkarte"
pChat.lang.toggleChatBinding = "Toggle Chat-Fenster"
pChat.lang.whispMyTargetBinding = "Flüsternachricht mein Zielperson"

pChat.lang.savMsgErrAlreadyExists = "Cannot save your message, this one already exists"
pChat.lang.PCHAT_AUTOMSG_NAME_DEFAULT_TEXT = "Example : ts3"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT = "Write here the text which will be sent when you'll be using the auto message function"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_TIP1_TEXT = "Newlines will be automatically deleted"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_TIP2_TEXT = "This message will be sent when you'll validate the message \"!nameOfMessage\". (ex: |cFFFFFF!ts3|r)"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_TIP3_TEXT = "To send a message in a specified channel, add its switch at the begenning of the message (ex: |cFFFFFF/g1|r)"
pChat.lang.PCHAT_AUTOMSG_NAME_HEADER = "Acronym of your message"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_HEADER = "Substitution message"
pChat.lang.PCHAT_AUTOMSG_ADD_TITLE_HEADER = "New automated message"
pChat.lang.PCHAT_AUTOMSG_EDIT_TITLE_HEADER = "Modify automated message"
pChat.lang.PCHAT_AUTOMSG_ADD_AUTO_MSG = "Add"
pChat.lang.PCHAT_AUTOMSG_EDIT_AUTO_MSG = "Edit"
pChat.lang.SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG = "Automated messages"
pChat.lang.PCHAT_AUTOMSG_REMOVE_AUTO_MSG = "Remove"

pChat.lang.clearBuffer = "Clear chat"