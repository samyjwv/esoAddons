---------------------------------------------
-- English localization for MasterThief
---------------------------------------------
-- translated by Adalan@Aruntas
-- improved by Vlad


local localization_strings = {
	-- settings panel name
	MASTER_THIEF_NAME = "Master Thief",
	
	-- options checkboxes
	MASTER_THIEF_TEXT = "Enable or disable Master Thief entirely.",
	MT_SNEAK_MODE_NAME = "Sneak and steal mode",
	MT_SNEAK_MODE_TEXT = "If enabled but you are not in sneak, it works like a safety net. So you can inspect all containers (except cash-boxes) without to auto-loot items. This is helps if guards are around and you just want to see if there is anything to steal without auto-looting. In sneak mode auto-loot is enabled and you steal like if this setting is fully Off.",
	MT_SHOW_MESSAGEBOX_NAME = "Show message frame",
	MT_SHOW_MESSAGEBOX_TEXT = "Force show the message frame on screen to allowing moving and positioning.",
	MT_EXCLUDE_COMPARE_NAME = "Share my recipes knowledge",
	MT_EXCLUDE_COMPARE_TEXT = "This option makes all your known recipes available for comparison to other characters. If it's disabled then all known recipes of the others player characters are still getting inspected and compared as long they have this option enabled and share their recipe knowledge.",
	MT_LOOT_UNKNOWN_RECIPES_NAME = "Force loot unknown recipes",
	MT_LOOT_UNKNOWN_RECIPES_TEXT = "Loot all unknown recipes regardless of set quality level. If it's Off then you will just auto-loot only recipes of the set quality level or higher.",
	MT_AUTOLOOT_FROM_LOOTLIST_NAME = "Lootlist autoloot",	
	MT_AUTOLOOT_FROM_LOOTLIST_TEXT = "If activated, then you do steal automatically those items you got on lootlist",
	
	-- options slider
	MT_MESSAGE_DELAY_NAME = "Message delay",
	MT_MESSAGE_DELAY_TEXT = "Set your on-screen message delay in milliseconds, i.e. 1000 units = 1 second.",
	MT_FREE_SLOTS_LEFT_LIMIT_NAME = "Free bag slots warning threshold",
	MT_FREE_SLOTS_LEFT_LIMIT_TEXT = "Set the minimum number of left slot in your bag to get a warning message displayed about free slots left.",
	MT_MIN_SELL_PRICE_AUTOLOOT_NAME = "Minimum sell price for auto-looting",
	MT_MIN_SELL_PRICE_AUTOLOOT_TEXT = "Set the minimum sell price to enable automatic looting of stolen items. Note that this exclude recipes and motifs, which are controlled my out auto-loot settings and in general are always auto-looted.",

	-- options dropdown
	MT_RECIPE_QUALITY_NAME = "Minimal quality of recipes",
	MT_RECIPE_QUALITY_TEXT = "Choose the minimum quality level of a recipe to be auto-looted. Unknown recipes below the given level will be auto-looted only if you allow it explicitly.",
	MT_RECIPE_COLOR_GREEN = "green",
	MT_RECIPE_COLOR_BLUE = "blue",
	MT_RECIPE_COLOR_EPIC = "epic",

	-- options submenu - announcements
	MT_SUB_ANNOUNCE_NAME = "Announcements",
	MT_SUB_ANNOUNCE_TEXT = "All announcements",
	MT_SUB_ANNOUNCE_ONSCREENMSG_NAME = "Announce with on-screen message",
	MT_SUB_ANNOUNCE_ONSCREENMSG_TEXT = "Announce recipes and motifs as on-screen message.",
	MT_SUB_ANNOUNCE_SPECIALS_NAME = "Announce special items in chat",
	MT_SUB_ANNOUNCE_SPECIALS_TEXT = "Announce recipes and motifs in chat. Only you will see these announcements, they are not shared with any other players.",
	MT_SUB_ANNOUNCE_REGULAR_NAME = "Announce information in chat",
	MT_SUB_ANNOUNCE_REGULAR_TEXT = "Announce information like payoffs to guards/launders, sold items, bounty, etc in chat.",	
	MT_SUB_ANNOUNCE_USELESS_NAME = "Announce junk items",
	MT_SUB_ANNOUNCE_USELESS_TEXT = "Announce junk items as defined by minimal auto-loot price limiter. You can list these items with /mt_junk command. Exclude recipes or motifs.",
	MT_SUB_ANNOUNCE_BECAREFUL_NAME = "Announce \"Be careful\" in sneak",
	MT_SUB_ANNOUNCE_BECAREFUL_TEXT = "Show \"Be careful\" message, because of the distance to NPCs is not far enough to be fully stealthed. This should assist you in fully stealthed sneaking and stealing.",	
	MT_SUB_ANNOUNCE_KNOWN_RECIPES_NAME = "Announce known recipes",
	MT_SUB_ANNOUNCE_KNOWN_RECIPES_TEXT = "Print a message about looting of already known recipes in chat.",	
	MT_SUB_ANNOUNCE_SELLS_TRANSFERS_NAME = "Announce item fence/launder in chat",
	MT_SUB_ANNOUNCE_SELLS_TRANSFERS_TEXT = "Print a message about fence and launder transactions in chat.",	
	MT_SUB_ANNOUNCE_MAX_FENCER_LIMITS_NAME = "Announce fencer limits",
	MT_SUB_ANNOUNCE_MAX_FENCER_LIMITS_TEXT = "Print a message about in chat if you have reached your maximum daily limit for fence or launder.",

	-- Binding-Names
	MT_BIND_ONOFF_TEXT = "Toggle On/Off",
	MT_BIND_TOGGLE_SNEAKMODE_TEXT = "Toggle sneak mode",		
	MT_BIND_SHOW_STATISTIC_TEXT = "Show statistics",	
	MT_BIND_SHOW_USELESS_TEXT = "Show junk items",
	MT_BIND_TOGGLE_ATTACK_INNOCENTS_TEXT = "Toggle attack innocents",
	MT_BIND_TOGGLE_LOOTLIST_TEXT = "Show lootlist",

	-- Misc Text
	MT_MISC_TRASH_TEXT = "Junk: ",
	MT_MISC_SOLD_FOR = " sold for ",
	MT_MISC_BOUNTY_IS = "Bounty is ",
	MT_MISC_BOUNTY_REMOVED_FROM_BODY = "Full bounty got removed from your dead body!",
	MT_MISC_ALL_STOLEN_ITEMS_REMOVED = "All stolen items were removed by a guard!",
	MT_MISC_YOU_PAID_BOUNTY = "You've paid bounty: ",
	MT_MISC_YOU_SOLD_AN_ITEM_FOR = "You've fenced an item for ",
	MT_MISC_SNEAKMODE_ACTIVE = "Sneak and steal active",
	MT_MISC_SNEAKMODE_SLEEPING = "Sneak and steal inactive",
	MT_MISC_BE_CAREFUL = "Be careful!",
	MT_MISC_MASTERTHIEF_OFF = "MasterThief is Off",
	MT_MISC_SNEAKMODE_ON = "Sneak mode is On",
	MT_MISC_SNEAKMODE_OFF = "Sneak mode is Off",
	MT_MISC_IS_KNOWN = "Already known: ",
	MT_MISC_FREE_SLOTS_LEFT = "Free slots left: ",
	MT_MISC_SELL_MAXIMUM_REACHED = "Fence maximum per day reached!",
	MT_MISC_TRANSFER_MAXIMUM_REACHED = "Launder maximum pre day reached!",
	MT_MISC_ITEM_DESTROYED = "...destroyed!",
	MT_MISC_LIST_USELESS_ITEMS = "List of junk items: ",
	MT_MISC_USELESS_ITEMS_FOUND = "Junk items found: ",
	MT_MISC_TYPE_COMMAND_DESTROY_ITEM = "Type /mt_junk delete to destroy them",
	MT_MISC_NO_ITEMS_FOUND = "No items found to destroy",
	MT_MISC_ITEMS_BELOW_VALUE_USELESS = "Items below this sell price are junk: ",
	MT_MISC_FOUND_ALOT_GOLD_TEXT = "You've looted gold. Stolen: ",
	MT_MISC_ITS_KNOWN_BUT_WANTED_TEXT = "Known, but looted: ",

	-- Text for statistic on chat
	MT_MISC_HEADER_STATISTIC = "------ MasterThief Statistics ------",
	MT_MISC_STOLEN_VALUES_IN_BAG = "Value of stolen items in bag:",
	MT_MISC_STOLEN_VALUES_SOLD = "Value of sold stolen items:",
	MT_MISC_BOUNTY_PAID = "Bounty paid:",
	MT_MISC_ACCOUNT_TOTAL = "Account is total:",
	MT_MISC_SELLS_MADE_TODAY = "Items fenced today:",
	MT_MISC_TRANSFERS_MADE_TODAY = "Items laundered today:",

	--Text for command list on chat
	MT_MISC_MASTERTHIEF_COMMANDS = "MasterThief commands:",
	MT_MISC_MASTERTHIEF_LISTCOMMANDS = "List all chat commands",
	MT_MISC_CMD_LIST_ALL_USELESS_ITEMS = "List of all junk items",
	MT_MISC_CMD_DESTROY_ALL_USELESS_ITEMS = "destroy all junk items",
	MT_MISC_CMD_RESET_ALL_VALUES = "reset all values/bounty",
	MT_MISC_SYSTEM_ATTACK_INNOCENTS_OFF = "Attack innocents is Off",
	MT_MISC_SYSTEM_ATTACK_INNOCENTS_ON = "Attack innocents is On",
	
	--Text for recipe/searchpool actions
	MT_MISC_RECIPES_ADDED_TO_SEARCHPOOL = " recipe(s) shared for compare",
	MT_MISC_RECIPES_REMOVED_FROM_SEARCHPOOL = " recipe(s) un-shared for compare",
	
	--Text for recipe tooltip
	MT_MISC_TOOLTIP_RECIPE_CHARS = "This recipe is known by:",

	--Text for Lootlist
	MT_MISC_LOOTLIST_DELETE = " removed from lootlist",
	MT_MISC_ITEM_ADDED = " added to lootlist",
	MT_MISC_ITEM_ALREADY_ON_LOOTLIST = "Item is already on lootlist",
	MT_MISC_WORTHFUL_ITEMS = "Lootlist of interesting items",
	MT_MISC_ITEM_TOOLTIP = "item is already on lootlist",
	
	-- Text for Context-Menu
	MT_CONTEXTMENU_LOOT_MARK = "Mark for autoloot",	
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end