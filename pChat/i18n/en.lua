--[[
Author: Ayantir
Filename: en.lua
Version: 5
]]--

pChat = pChat or {}
pChat.lang = {}
PCHAT_CHANNEL_NONE = 99

-- Vars with -H are headers, -TT are tooltips

-- Messages settings

pChat.lang.optionsH = "Messages Settings"

pChat.lang.guildnumbers = "Guild numbers"
pChat.lang.guildnumbersTT = "Shows the guild number next to the guild tag"

pChat.lang.allGuildsSameColour = "Use same color for all guilds"
pChat.lang.allGuildsSameColourTT = "Makes all guild chats use the same color as /guild1"

pChat.lang.allZonesSameColour = "Use same color for all zone chats"
pChat.lang.allZonesSameColourTT = "Makes all zone chats use the same color as /zone"

pChat.lang.allNPCSameColour = "Use same color for all NPC lines"
pChat.lang.allNPCSameColourTT = "Makes all NPC lines use the same color as NPC say"

pChat.lang.delzonetags = "Remove zone tags"
pChat.lang.delzonetagsTT = "Remove tags such as says, yells at the beginning of the message"

pChat.lang.zonetagsay = "says"
pChat.lang.zonetagyell = "yells"
pChat.lang.zonetagparty = "Group"
pChat.lang.zonetagzone = "zone"

pChat.lang.carriageReturn = "Newline between name and message"
pChat.lang.carriageReturnTT = "Player names and chat texts are separated by a newline."

pChat.lang.useESOcolors = "Use ESO colors"
pChat.lang.useESOcolorsTT = "Use colors set in social settings instead pChat ones"

pChat.lang.diffforESOcolors = "Difference between ESO colors"
pChat.lang.diffforESOcolorsTT = "If using ESO colors and Use two colors option, you can adjust brightness difference between player name and message displayed"

pChat.lang.removecolorsfrommessages = "Remove colors from messages"
pChat.lang.removecolorsfrommessagesTT = "Stops people using things like rainbow colored text"

pChat.lang.preventchattextfading = "Prevent chat text fading"
pChat.lang.preventchattextfadingTT = "Prevents the chat text from fading (you can prevent the BG from fading in the Social options"

pChat.lang.augmentHistoryBuffer = "Augment # of lines displayed in chat"
pChat.lang.augmentHistoryBufferTT = "Per default, only the last 200 lines are displayed in chat. This feature raise this value up to 1000 lines"

pChat.lang.useonecolorforlines = "Use one color for lines"
pChat.lang.useonecolorforlinesTT = "Instead of having two colors per channel, only use 1st color"

pChat.lang.guildtagsnexttoentrybox = "Guild tags next to entry box"
pChat.lang.guildtagsnexttoentryboxTT = "Show the guild tag instead of the guild name next to where you type"

pChat.lang.disableBrackets = "Remove brackets around names"
pChat.lang.disableBracketsTT = "Remove the brackets [] around player names"

pChat.lang.defaultchannel = "Default channel"
pChat.lang.defaultchannelTT = "Select which channel to use at login"

pChat.lang.defaultchannelchoice = {}
pChat.lang.defaultchannelchoice[PCHAT_CHANNEL_NONE] = "Do not change"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_ZONE] = "/zone"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_SAY] = "/say"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_1] = "/guild1"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_2] = "/guild2"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_3] = "/guild3"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_4] = "/guild4"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_5] = "/guild5"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_1] = "/officer1"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_2] = "/officer2"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_3] = "/officer3"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_4] = "/officer4"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_5] = "/officer5"

pChat.lang.geoChannelsFormat = "Names format"
pChat.lang.geoChannelsFormatTT = "Names format for local channels (say, zone, tell)"

pChat.lang.defaultTab = "Default tab"
pChat.lang.defaultTabTT = "Select which tab to display at startup"

pChat.lang.addChannelAndTargetToHistory = "Switch channel when using history"
pChat.lang.addChannelAndTargetToHistoryTT = "Switch the channel when using arrow keys to match the channel previously used."

pChat.lang.urlHandling = "Detect and make URLs linkable"
pChat.lang.urlHandlingTT = "If a URL starting with http(s):// is linked in chat pChat will detect it and you'll be able to click on it to directly go on the concerned link with your system browser"

pChat.lang.enablecopy = "Enable copy"
pChat.lang.enablecopyTT = "Enable copy with a right click on text - Also enable the channel switch with a left click. Disable this option if you got problems to display links in chat"

-- Group Settings

pChat.lang.groupH = "Party channel tweaks"

pChat.lang.enablepartyswitch = "Enable Party Switch"
pChat.lang.enablepartyswitchTT = "Enabling Party switch will switch your current channel to party when joining a party and  switch back to your default channel when leaving a party"

pChat.lang.groupLeader = "Special color for party leader"
pChat.lang.groupLeaderTT = "Enabling this feature will let you set a special color for party leader messages"

pChat.lang.groupLeaderColor = "Party leader color"
pChat.lang.groupLeaderColorTT = "Color of party leader messages. 2nd color is only to set if \"Use ESO colors\" is set to Off"

pChat.lang.groupLeaderColor1 = "Color of messages for party leader"
pChat.lang.groupLeaderColor1TT = "Color of message for party leader. If \"Use ESO colors\" is set to Off, this option will be disabled. The color of the party leader will be the one set above and the party leader messages will be this one"

pChat.lang.groupNames = "Names format for groups"
pChat.lang.groupNamesTT = "Format of your groupmates names in party channel"

pChat.lang.groupNamesChoice = {}
pChat.lang.groupNamesChoice[1] = "@UserID"
pChat.lang.groupNamesChoice[2] = "Character Name"
pChat.lang.groupNamesChoice[3] = "Character Name@UserID"

-- Sync settings

pChat.lang.SyncH = "Syncing settings"

pChat.lang.chatSyncConfig = "Sync chat configuration"
pChat.lang.chatSyncConfigTT = "If the sync is enabled, all your chars will get the same chat configuration (colors, position, window dimensions, tabs)\nPS: Only enable this option after your chat is fully customized !"

pChat.lang.chatSyncConfigImportFrom = "Import chat settings from"
pChat.lang.chatSyncConfigImportFromTT = "You can at any time import chat settings from another character (colors, position, window dimensions, tabs)"

-- Apparence

pChat.lang.ApparenceMH = "Chat window settings"

pChat.lang.windowDarkness = "Chat window transparency"
pChat.lang.windowDarknessTT = "Increase the darkening of the chat window"

pChat.lang.chatMinimizedAtLaunch = "Chat minimized at startup"
pChat.lang.chatMinimizedAtLaunchTT = "Minimize chat window on the left side of the screen when the game starts"

pChat.lang.chatMinimizedInMenus = "Chat minimized in menus"
pChat.lang.chatMinimizedInMenusTT = "Minimize chat window on the left of the screen when you enter in menus (Guild, Stats, Crafting, etc)"

pChat.lang.chatMaximizedAfterMenus = "Restore chat after exiting menus"
pChat.lang.chatMaximizedAfterMenusTT = "Always restore the chat window after exiting menus"

pChat.lang.fontChange = "Chat Font"
pChat.lang.fontChangeTT = "Set the Chat font"

pChat.lang.tabwarning = "New message warning"
pChat.lang.tabwarningTT = "Set the warning color for tab name"

-- Whisper settings

pChat.lang.IMH = "Whisps"

pChat.lang.soundforincwhisps = "Sound for incoming whisps"
pChat.lang.soundforincwhispsTT = "Choose sound wich will be played when you receive a whisp"

pChat.lang.notifyIM = "Visual notification"
pChat.lang.notifyIMTT = "If you miss a whisp, a notification will appear in the top right corner of the chat allowing you to quickly access to it. Plus, if your chat was minimized at that time, a notification will be displayed in the minibar"

pChat.lang.soundforincwhispschoice = {}
pChat.lang.soundforincwhispschoice[SOUNDS.NONE] = "None"
pChat.lang.soundforincwhispschoice[SOUNDS.NEW_NOTIFICATION] = "Notification"
pChat.lang.soundforincwhispschoice[SOUNDS.DEFAULT_CLICK] = "Click"
pChat.lang.soundforincwhispschoice[SOUNDS.EDIT_CLICK] = "Write"

-- Restore chat settings

pChat.lang.restoreChatH = "Restore chat"

pChat.lang.restoreOnReloadUI = "After a ReloadUI"
pChat.lang.restoreOnReloadUITT = "After reloading game with a ReloadUI(), pChat will restore your chat and its history"

pChat.lang.restoreOnLogOut = "After a LogOut"
pChat.lang.restoreOnLogOutTT = "After a logoff, pChat will restore your chat and its history if you login in the allotted time set under"

pChat.lang.restoreOnAFK = "After being kicked"
pChat.lang.restoreOnAFKTT = "After being kicked from game after inactivity, flood or a network disconnect, pChat will restore your chat and its history if you login in the allotted time set under"

pChat.lang.restoreOnQuit = "After leaving game"
pChat.lang.restoreOnQuitTT = "After leaving game, pChat will restore your chat and its history if you login in the allotted time set under"

pChat.lang.timeBeforeRestore = "Maximum time for restoring chat"
pChat.lang.timeBeforeRestoreTT = "After this time (in hours), pChat will not attempt to restore the chat"

pChat.lang.restoreSystem = "Restore System Messages"
pChat.lang.restoreSystemTT = "Restore System Messages (Such as login notifications or add ons messages) when chat is restored"

pChat.lang.restoreSystemOnly = "Restore Only System messages"
pChat.lang.restoreSystemOnlyTT = "Restore Only System Messages (Such as login notifications or add ons messages) when chat is restored"

pChat.lang.restoreWhisps = "Restore Whispers"
pChat.lang.restoreWhispsTT = "Restore whispers sent and received after logoff, disconnect or quit. Whispers are always restored after a ReloadUI()"

pChat.lang.restoreTextEntryHistoryAtLogOutQuit  = "Restore Text entry history"
pChat.lang.restoreTextEntryHistoryAtLogOutQuitTT  = "Restore Text entry history available with arrow keys after logoff, disconnect or quit. History of text entry is always restored after a ReloadUI()"

-- Anti Spam settings

pChat.lang.antispamH = "Anti-Spam"

pChat.lang.floodProtect = "Enable anti-flood"
pChat.lang.floodProtectTT = "Prevents the players close to you from sending identical and repeated messages"

pChat.lang.floodGracePeriod = "Duration of anti-flood banishment"
pChat.lang.floodGracePeriodTT = "Number of seconds while the previous identical message will be ignored"

pChat.lang.lookingForProtect = "Ignore grouping messages"
pChat.lang.lookingForProtectTT = "Ignore the messages players seeking to establish / join group"

pChat.lang.wantToProtect = "Ignore Commercial messages"
pChat.lang.wantToProtectTT = "Ignore messages from players looking to buy, sell or trade"

pChat.lang.spamGracePeriod = "Temporarily stopping the spam"
pChat.lang.spamGracePeriodTT = "When you make yourself a research group message or trade, spam temporarily disables the function you have overridden the time to have an answer. It reactivates automatically after a period that can be set (in minutes)"

-- Nicknames settings

pChat.lang.nicknamesH = "Nicknames"
pChat.lang.nicknamesD = "You can add nicknames for the people you want, just type OldName = Newname\n\nE.g : @Ayantir = Little Blonde\nIt will change the name of all the account if OldName is a @UserID or only the specified Char if the OldName is a Character Name."
pChat.lang.nicknames = "List of Nicknames"
pChat.lang.nicknamesTT = "You can add nicknames for the people you want, just type OldName = Newname\n\nE.g : @Ayantir = Little Blonde\n\nIt will change the name of all the account if OldName is a @UserID or only the specified Char if the OldName is a Character Name."

-- Timestamp settings

pChat.lang.timestampH = "Timestamp"

pChat.lang.enabletimestamp = "Enable timestamp"
pChat.lang.enabletimestampTT = "Adds a timestamp to chat messages"

pChat.lang.timestampcolorislcol = "Timestamp color same as player one"
pChat.lang.timestampcolorislcolTT = "Ignore timestamp color and colorize timestamp same as player / NPC name"

pChat.lang.timestampformat = "Timestamp format"
pChat.lang.timestampformatTT = "FORMAT:\nHH: hours (24)\nhh: hours (12)\nH: hour (24, no leading 0)\nh: hour (12, no leading 0)\nA: AM/PM\na: am/pm\nm: minutes\ns: seconds"

pChat.lang.timestamp = "Timestamp"
pChat.lang.timestampTT = "Set color for the timestamp"

-- Guild settings

pChat.lang.nicknamefor = "Nickname"
pChat.lang.nicknameforTT = "Nickname for "

pChat.lang.officertag = "Officer chat tag"
pChat.lang.officertagTT = "Prefix for Officers chats"

pChat.lang.switchFor = "Switch for channel"
pChat.lang.switchForTT = "New switch for channel. Ex: /myguild"

pChat.lang.officerSwitchFor = "Switch for officer channel"
pChat.lang.officerSwitchForTT = "New switch for officer channel. Ex: /offs"

pChat.lang.nameformat = "Name format"
pChat.lang.nameformatTT = "Select how guild member names are formatted"

pChat.lang.formatchoice1 = "@UserID"
pChat.lang.formatchoice2 = "Character Name"
pChat.lang.formatchoice3 = "Character Name@UserID"

pChat.lang.setcolorsforTT = "Set colors for members of "
pChat.lang.setcolorsforchatTT = "Set colors for messages of "

pChat.lang.setcolorsforofficiersTT = "Set colors for members of Officer chat of "
pChat.lang.setcolorsforofficierschatTT = "Set colors for messages of Officer chat of "

pChat.lang.members = " - Players"
pChat.lang.chat = " - Messages"

pChat.lang.officersTT = " Officers"

-- Channel colors settings

pChat.lang.chatcolorsH = "Chat Colors"

pChat.lang.say = "Say - Player"
pChat.lang.sayTT = "Set player color for say channel"

pChat.lang.saychat = "Say - Chat"
pChat.lang.saychatTT = "Set chat color for say channel"

pChat.lang.zone = "Zone - Player"
pChat.lang.zoneTT = "Set player color for zone channel"

pChat.lang.zonechat = "Zone - Chat"
pChat.lang.zonechatTT = "Set chat color for zone channel"

pChat.lang.yell = "Yell - Player"
pChat.lang.yellTT = "Set player color for yell channel"

pChat.lang.yellchat = "Yell - Chat"
pChat.lang.yellchatTT = "Set chat color for yell channel"

pChat.lang.incomingwhispers = "Incoming whispers - Player"
pChat.lang.incomingwhispersTT = "Set player color for incoming whispers"

pChat.lang.incomingwhisperschat = "Incoming whispers - Chat"
pChat.lang.incomingwhisperschatTT = "Set chat color for incoming whispers"

pChat.lang.outgoingwhispers = "Outgoing whispers - Player"
pChat.lang.outgoingwhispersTT = "Set player color for outgoing whispers"

pChat.lang.outgoingwhisperschat = "Outgoing whispers - Chat"
pChat.lang.outgoingwhisperschatTT = "Set chat color for outgoing whispers"

pChat.lang.group = "Group - Player"
pChat.lang.groupTT = "Set player color for group chat"

pChat.lang.groupchat = "Group - Chat"
pChat.lang.groupchatTT = "Set chat color for group chat"

-- Other colors

pChat.lang.othercolorsH = "Other Colors"

pChat.lang.emotes = "Emotes - Player"
pChat.lang.emotesTT = "Set player color for emotes"

pChat.lang.emoteschat = "Emotes - Chat"
pChat.lang.emoteschatTT = "Set chat color for emotes"

pChat.lang.enzone = "EN Zone - Player"
pChat.lang.enzoneTT = "Set player color for English zone channel"

pChat.lang.enzonechat = "EN Zone - Chat"
pChat.lang.enzonechatTT = "Set chat color for English zone channel"

pChat.lang.frzone = "FR Zone - Player"
pChat.lang.frzoneTT = "Set player color for French zone channel"

pChat.lang.frzonechat = "FR Zone - Chat"
pChat.lang.frzonechatTT = "Set chat color for French zone channel"

pChat.lang.dezone = "DE Zone - Player"
pChat.lang.dezoneTT = "Set player color for German zone channel"

pChat.lang.dezonechat = "DE Zone - Chat"
pChat.lang.dezonechatTT = "Set chat color for German zone channel"

pChat.lang.jpzone = "JP Zone - Player"
pChat.lang.jpzoneTT = "Set player color for Japanese zone channel"

pChat.lang.jpzonechat = "JP Zone - Chat"
pChat.lang.jpzonechatTT = "Set chat color for Japanese zone channel"

pChat.lang.npcsay = "NPC Say - NPC name"
pChat.lang.npcsayTT = "Set NPC name color for NPC say"

pChat.lang.npcsaychat = "NPC Say - Chat"
pChat.lang.npcsaychatTT = "Set NPC chat color for NPC say"

pChat.lang.npcyell = "NPC Yell - NPC name"
pChat.lang.npcyellTT = "Set NPC name color for NPC yell"

pChat.lang.npcyellchat = "NPC Yell - Chat"
pChat.lang.npcyellchatTT = "Set NPC chat color for NPC yell"

pChat.lang.npcwhisper = "NPC Whisper - NPC name"
pChat.lang.npcwhisperTT = "Set NPC name color for NPC whisper"

pChat.lang.npcwhisperchat = "NPC Whisper - Chat"
pChat.lang.npcwhisperchatTT = "Set NPC chat color for NPC whisper"

pChat.lang.npcemotes = "NPC Emotes - NPC name"
pChat.lang.npcemotesTT = "Set NPC name color for NPC emotes"

pChat.lang.npcemoteschat = "NPC Emotes - Chat"
pChat.lang.npcemoteschatTT = "Set NPC chat color for NPC emotes"

-- Debug settings

pChat.lang.debugH = "Debug"

pChat.lang.debug = "Debug"
pChat.lang.debugTT = "Debug"

-- Various strings not in panel settings

pChat.lang.undockTextEntry = "Undock Text Entry"
pChat.lang.redockTextEntry = "Redock Text Entry"

pChat.lang.copyXMLTitle = "Copy text with Ctrl+C"
pChat.lang.copyXMLLabel = "Copy text with Ctrl+C"
pChat.lang.copyXMLTooLong = "Text is too long and is splitted"
pChat.lang.copyXMLNext = "Next"

pChat.lang.CopyMessageCT = "Copy message"
pChat.lang.CopyLineCT = "Copy line"
pChat.lang.CopyDiscussionCT = "Copy channel talk"
pChat.lang.AllCT = "Copy whole chat"

pChat.lang.switchToNextTabBinding = "Switch to next tab"
pChat.lang.toggleChatBinding = "Toggle Chat Window"
pChat.lang.whispMyTargetBinding = "Whisper my target"

pChat.lang.savMsgErrAlreadyExists = "Cannot save your message, this one already exists"
pChat.lang.PCHAT_AUTOMSG_NAME_DEFAULT_TEXT = "Example : ts3"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT = "Write here the text which will be sent when you'll be using the auto message function"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_TIP1_TEXT = "Newlines will be automatically deleted"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_TIP2_TEXT = "This message will be sent when you'll validate the message \"!nameOfMessage\". (ex: |cFFFFFF!ts3|r)"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_TIP3_TEXT = "To send a message in a specified channel, add its switch at the begenning of the message (ex: |cFFFFFF/g1|r)"
pChat.lang.PCHAT_AUTOMSG_NAME_HEADER = "Abbreviation of your message"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_HEADER = "Substitution message"
pChat.lang.PCHAT_AUTOMSG_ADD_TITLE_HEADER = "New automated message"
pChat.lang.PCHAT_AUTOMSG_EDIT_TITLE_HEADER = "Modify automated message"
pChat.lang.PCHAT_AUTOMSG_ADD_AUTO_MSG = "Add"
pChat.lang.PCHAT_AUTOMSG_EDIT_AUTO_MSG = "Edit"
pChat.lang.SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG = "Automated messages"
pChat.lang.PCHAT_AUTOMSG_REMOVE_AUTO_MSG = "Remove"

pChat.lang.clearBuffer = "Clear chat"