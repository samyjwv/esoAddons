---------------------------------------------
-- German localization for MasterThief
---------------------------------------------
-- translated by Adalan@Aruntas

-- Ä = \195\132
-- ä = \195\164
-- ö = \195\182
-- Ö = \195\150
-- Ü = \195\156
-- ü = \195\188
-- ß = \195\159

local localization_strings = {
	-- options checkboxes
	MASTER_THIEF_TEXT = "MasterThief On/Off",
	MT_SNEAK_MODE_NAME = "Schleichen und Klauen",
	MT_SNEAK_MODE_TEXT = "Wenn aktiv, dann funktioniert das automatische Klauen nur w\195\164hrend du schleichst. Aktiv, aber nicht am Schleichen, dann kannst du in Ruhe Kisten durchw\195\188hlen, ohne dass du etwas entwendest.",
	MT_SHOW_MESSAGEBOX_NAME = "Infobox anzeigen",
	MT_SHOW_MESSAGEBOX_TEXT = "Zeigt die Infobox auf der UI-Oberfl\195\164che an, damit sie verschoben werden kann",
	MT_EXCLUDE_COMPARE_NAME = "Vergleiche auch meine Rezepte",
	MT_EXCLUDE_COMPARE_TEXT = "Diese Option legt die Rezepte von diesem Spielerchar f\195\188r einen Rezeptvergleich mit in den Vergleichspool aller Chars. Es werden immer nur Rezepte geklaut, die nicht im Vergleichspool liegen.",
	MT_LOOT_UNKNOWN_RECIPES_NAME = "Unbekannte Rezepte unter Level",
	MT_LOOT_UNKNOWN_RECIPES_TEXT = "Sammle trotzdem alle unbekannten Rezepte ein, die unter dem festgelegten Mindestqualit\195\164tslevel liegen",
	MT_AUTOLOOT_FROM_LOOTLIST_NAME = "Lootliste autoloot",
	MT_AUTOLOOT_FROM_LOOTLIST_TEXT = "Wenn aktiviert, klaust du die Gegenst\195\164nde automatisch, die in der Lootliste enthalten sind",
	
	-- options slider
	MT_MESSAGE_DELAY_NAME = "Dauer der OnScreen-Infos",
	MT_MESSAGE_DELAY_TEXT = "Die Dauer zum Anzeigen der OnScreen-Infos, bis sie verschwinden soll\n\n1000 = eine Sekunde",
	MT_FREE_SLOTS_LEFT_LIMIT_NAME = "Info-Limit freier Pl\195\164tze",
	MT_FREE_SLOTS_LEFT_LIMIT_TEXT = "Der maximale Wert, bei dem vor Erreichen von Platzmangel gewarnt wird",
	MT_MIN_SELL_PRICE_AUTOLOOT_NAME = "Mindestpreis zum Autolooten",
	MT_MIN_SELL_PRICE_AUTOLOOT_TEXT = "Mindestpreis, ab dem automatisch der Gegenstand eingesammelt werden soll\nAlle anderen Items von geringerem Wert werden als nicht wertvoll und daher nutzlos angesehen\n*Rezepte und Motifs werden allerdings weiterhin automatisch eingesammelt - entsprechend der Einstellungen",

	-- options dropdown
	MT_RECIPE_QUALITY_NAME = "Mindestqualit\195\164t der Rezepte",
	MT_RECIPE_QUALITY_TEXT = "Mindestqualit\195\164tslevel der Rezepte, ab der sie automatisch eingesammelt werden sollen\nUnbekannte Rezepte unter diesem Qualit\195\164tslevel werden nur eingesammelt, wenn das explizit erlaubt wurde ",
	MT_RECIPE_COLOR_GREEN = "gr\195\188n",
	MT_RECIPE_COLOR_BLUE = "blau",
	MT_RECIPE_COLOR_EPIC = "lila",
	
	-- options submenu - announcements
	MT_SUB_ANNOUNCE_NAME = "Benachrichtigungen",
	MT_SUB_ANNOUNCE_TEXT = "Einstellungen zu allen Benachrichtigungen",
	MT_SUB_ANNOUNCE_ONSCREENMSG_NAME = "Benachrichtigung OnScreen",
	MT_SUB_ANNOUNCE_ONSCREENMSG_TEXT = "Benachrichtigung von Rezepten und Motif-B\195\188chern als OnScreen-Nachricht",
	MT_SUB_ANNOUNCE_SPECIALS_NAME = "Benachrichtigung zu speziellen Items",
	MT_SUB_ANNOUNCE_SPECIALS_TEXT = "Benachrichtigung zu Rezepten und Motif-B\195\188chern im Chat ausgeben (nur f\195\188r dich sichtbar)",
	MT_SUB_ANNOUNCE_REGULAR_NAME = "Benachrichtung allgemeiner Chatinfos",
	MT_SUB_ANNOUNCE_REGULAR_TEXT = "Benachrichtigungen, wie Strafzahlungen an Wachen/Hehlern, verkauften Gegenst\195\164nden, Kopfgeld",	
	MT_SUB_ANNOUNCE_USELESS_NAME = "Benachrichtung zu nutzlosen Gegenst\195\164nde",
	MT_SUB_ANNOUNCE_USELESS_TEXT = "Ausgabe von Meldungen im Chat \195\188ber eingesammelte Gegenst\195\164nde, die per Limit als nicht Wertvoll angesehen sind\nDu kannst Dir diese Sachen auflisten lassen mit dem Chatbefehl /mt_junk\n*Betrifft nicht die Rezepte oder Motifs",
	MT_SUB_ANNOUNCE_BECAREFUL_NAME = "Ausgabe von 'Sei vorsichtig'",
	MT_SUB_ANNOUNCE_BECAREFUL_TEXT = "Die Ausgabe von 'SEI VORSICHTIG' wird Dir angezeigt, wenn du dich nicht weit genug von NPCs entfernt befindest, um komplett unentdeckt zu bleiben. Solltest Du dazu noch gestohlene Sachen bei Dir tragen, wird die Meldung deutlicher dargestellt.",	
	MT_SUB_ANNOUNCE_KNOWN_RECIPES_NAME = "Nachricht zu bekannten Rezepten",
	MT_SUB_ANNOUNCE_KNOWN_RECIPES_TEXT = "Meldungen \195\188ber gefundene, aber bereits bekannte Rezepte im Chat ausgeben",	
	MT_SUB_ANNOUNCE_SELLS_TRANSFERS_NAME = "Meldungen zu Verk\195\164ufen/Transfers beim Hehler",
	MT_SUB_ANNOUNCE_SELLS_TRANSFERS_TEXT = "Zu jeder Transaktion beim Hehler im Verkauf oder Transfer eine Meldung im Chat ausgeben",	
	MT_SUB_ANNOUNCE_MAX_FENCER_LIMITS_NAME = "Chatinfo zum max. Hehler-Limit",
	MT_SUB_ANNOUNCE_MAX_FENCER_LIMITS_TEXT = "Gibt eine Info in den Chat aus, sobald des maximale Verkaufs- oder Transferlimt erreicht wurde",

	-- Binding-Names
	MT_BIND_ONOFF_TEXT = "Toggle OnOff",
	MT_BIND_TOGGLE_SNEAKMODE_TEXT = "Toggle Schleichmodus",		
	MT_BIND_SHOW_STATISTIC_TEXT = "Zeige Statistiken",	
	MT_BIND_SHOW_USELESS_TEXT = "Zeige nutzlose items",
	MT_BIND_TOGGLE_ATTACK_INNOCENTS_TEXT = "Toggle unschuldige angreifen",
	MT_BIND_TOGGLE_LOOTLIST_TEXT = "Zeige Lootliste",

	-- Misc Text
	MT_MISC_TRASH_TEXT = "M\195\188ll: ",
	MT_MISC_SOLD_FOR = " verkauft f\195\188r ",
	MT_MISC_BOUNTY_IS = "Volles Kopfgeld sind ",
	MT_MISC_BOUNTY_REMOVED_FROM_BODY = "Volles Kopfgeld wurde deinem stinkenden Kadaver entnommen!",
	MT_MISC_ALL_STOLEN_ITEMS_REMOVED = "Alle gestohlenen Items wurden von der Wache beschlagnahmt!",
	MT_MISC_YOU_PAID_BOUNTY = "Du hast an Kopfgeld gezahlt: ",
	MT_MISC_YOU_SOLD_AN_ITEM_FOR = "Du hast ein Item verschoben f\195\188r ",
	MT_MISC_SNEAKMODE_ACTIVE = "Schleichen und Klauen aktiv",
	MT_MISC_SNEAKMODE_SLEEPING = "Schleichen und Klauen inaktiv",
	MT_MISC_BE_CAREFUL = "Sei vorsichtig !",
	MT_MISC_MASTERTHIEF_OFF = "MasterThief AUS",
	MT_MISC_SNEAKMODE_ON = "Schleichmodus AN",
	MT_MISC_SNEAKMODE_OFF = "MasterThief AN - Schleichmodus AUS",
	MT_MISC_IS_KNOWN = "Bereits bekannt: ",
	MT_MISC_FREE_SLOTS_LEFT = "Noch freie Pl\195\164tze: ",
	MT_MISC_SELL_MAXIMUM_REACHED = "Verkaufsmaximum erreicht!",
	MT_MISC_TRANSFER_MAXIMUM_REACHED = "Transfermaximum erreich!",
	MT_MISC_ITEM_DESTROYED = "...zerst\195\182rt!",
	MT_MISC_LIST_USELESS_ITEMS = "Liste aller nutzlosen Items: ",
	MT_MISC_USELESS_ITEMS_FOUND = "Nutzloses Item: ",
	MT_MISC_TYPE_COMMAND_DESTROY_ITEM = "Tippe /mt_junk um die Items zu zerst\195\182ren",
	MT_MISC_NO_ITEMS_FOUND = "Keine Gegenst\195\164nde zum Zerst\195\182ren gefunden",
	MT_MISC_ITEMS_BELOW_VALUE_USELESS = "Wertgrenze f\195\188r nutzlose Items ist: ",
	MT_MISC_FOUND_ALOT_GOLD_TEXT = "Du hast Gold gefunden. Erbeutet: ",
	MT_MISC_ITS_KNOWN_BUT_WANTED_TEXT = "Rezept bekannt, aber will ich haben: ",
	
	-- Text for statistic on chat
	MT_MISC_HEADER_STATISTIC = "------ MasterThief Statistik ------",
	MT_MISC_STOLEN_VALUES_IN_BAG = "Geklaute Werte in den Taschen:",
	MT_MISC_STOLEN_VALUES_SOLD = "Geklaute Werte verkauft: ",
	MT_MISC_BOUNTY_PAID = "Kopfgeld gezahlt:",
	MT_MISC_ACCOUNT_TOTAL = "Gesamtsumme betr\195\164gt:",
	MT_MISC_SELLS_MADE_TODAY = "Anzahl verkaufte Beute:",
	MT_MISC_TRANSFERS_MADE_TODAY = "Anzahl verschobene Beute:",
	
	--Text for command list on chat
	MT_MISC_MASTERTHIEF_COMMANDS = "MasterThief Kommandos:",
	MT_MISC_MASTERTHIEF_LISTCOMMANDS = "Listet die Chatkommandos auf",
	MT_MISC_CMD_LIST_ALL_USELESS_ITEMS = "Liste aller nutzlosen Items",
	MT_MISC_CMD_DESTROY_ALL_USELESS_ITEMS = "Alle nutzlosen Items zerst\195\182ren",
	MT_MISC_CMD_RESET_ALL_VALUES = "Alle Werte resetten (Verk\195\164ufe, Transfers, Bounty)",
	MT_MISC_SYSTEM_ATTACK_INNOCENTS_OFF = "Unschuldige angreifen OFF",
	MT_MISC_SYSTEM_ATTACK_INNOCENTS_ON = "Unschuldige angreifen ON",

	--Text for recipe/searchpool actions
	MT_MISC_RECIPES_ADDED_TO_SEARCHPOOL = " Rezept(e) zum Vergleichspool hinzugef\195\188gt",
	MT_MISC_RECIPES_REMOVED_FROM_SEARCHPOOL = " Rezept(e) aus dem Vergleichspool entfernt",	
	
	--Text for recipe tooltip
	MT_MISC_TOOLTIP_RECIPE_CHARS = "Das Rezept kennt:",
	
	--Text for Lootlist
	MT_MISC_LOOTLIST_DELETE = " von der Lootliste entfernt",
	MT_MISC_ITEM_ADDED = " hinzugef\195\188gt",
	MT_MISC_ITEM_ALREADY_ON_LOOTLIST = "Gegenstand ist bereits in der Lootliste",
	MT_MISC_WORTHFUL_ITEMS = "Lootliste interessanter Gegenst\195\164nde",
	MT_MISC_ITEM_TOOLTIP = "Gegenstand ist auf der Lootliste",
	
	-- Text for Context-Menu
	MT_CONTEXTMENU_LOOT_MARK = "Markieren zum Klauen",
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end