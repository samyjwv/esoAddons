---------------------------------------------
-- French localization for MasterThief
---------------------------------------------
-- translated by Khrill
--[[
   à : \195\160    è : \195\168    ì : \195\172    ò : \195\178    ù : \195\185
   á : \195\161    é : \195\169    í : \195\173    ó : \195\179    ú : \195\186
   â : \195\162    ê : \195\170    î : \195\174    ô : \195\180    û : \195\187
   ã : \195\163    ë : \195\171    ï : \195\175    õ : \195\181    ü : \195\188
   ä : \195\164                    ñ : \195\177    ö : \195\182
   æ : \195\166                                    ø : \195\184
   ç : \195\167                                    œ : \197\147
   Ä : \195\132   Ö : \195\150   Ü : \195\156    ß : \195\159
]]


local localization_strings = {
	-- options checkboxes
	MASTER_THIEF_TEXT = "Active ou d\195\169sactive MasterThief",
	MT_SNEAK_MODE_NAME = "Mode furtif",
	MT_SNEAK_MODE_TEXT = "If enabled but you are not in sneak, it works like a safety net. So you can inspect all containers (except cash-boxes) without to autoloot things. This is helpful, if guards around and you just want to see what is there to steal without to steal automatically. In sneak, you steal like its fully off",
	MT_SHOW_MESSAGEBOX_NAME = "Afficher fen\195\170tre de message",
	MT_SHOW_MESSAGEBOX_TEXT = "Affiche la fen\195\170tre de message afin de pouvoir d\195\169finir son emplacement",
	MT_EXCLUDE_COMPARE_NAME = "Comparez aussi mes recettes",
	MT_EXCLUDE_COMPARE_TEXT = "This option put all my known recipes into a compare-pool.\nIf its disabled, then all known recipes of the others playerchars are still getting examined, as long they got this option enabled to share their recipe knowledge",
	MT_LOOT_UNKNOWN_RECIPES_NAME = "Unknown recipes below level",
	MT_LOOT_UNKNOWN_RECIPES_TEXT = "Loot all unknown recipes below set quality level. If off, you just loot at the given quality level or higher",
	MT_AUTOLOOT_FROM_LOOTLIST_NAME = "Lootlist autoloot",
	MT_AUTOLOOT_FROM_LOOTLIST_TEXT = "Si elle est activ\195\169e, alors vous faites voler automatiquement les articles que vous avez obtenu sur lootlist",
	
	-- options slider
	MT_MESSAGE_DELAY_NAME = "D\195\169lai des messages",
	MT_MESSAGE_DELAY_TEXT = "Fixe le d\195\169lai d'affichage des messages \195\160 l'\195\169cran\n\n1000 = une seconde",
	MT_FREE_SLOTS_LEFT_LIMIT_NAME = "Emplacements libres avant message",
	MT_FREE_SLOTS_LEFT_LIMIT_TEXT = "Fixe le seuil minimum d\195\169clenchant un message d'information sur les emplacements libres restants",
	MT_MIN_SELL_PRICE_AUTOLOOT_NAME = "Prix de vente minimum du butin automatique",
	MT_MIN_SELL_PRICE_AUTOLOOT_TEXT = "Fixe le prix de vente minimum \195\160 partir duquel les objets de butin sont r\195\169cup\195\169r\195\169s dans le sac\nTous les autres objets seront consid\195\169r\195\169s comme inutiles\n*Exception faite pour les recettes et motifs, ceux-ci \195\169tant g\195\169n\195\169ralement r\195\169cup\195\169r\195\169s automatiquement",

	-- options dropdown
	MT_RECIPE_QUALITY_NAME = "Qualit\195\169 minimum des recettes",
	MT_RECIPE_QUALITY_TEXT = "Choisir la qualit\195\169 minimum requise pour qu'une recette soit r\195\169cup\195\169r\195\169e automatiquement. Les recettes non apprises en dessous de ce niveau seront tout de m\195\170me int\195\169gr\195\169es au butin automatique",
	MT_RECIPE_COLOR_GREEN = "verte",
	MT_RECIPE_COLOR_BLUE = "bleue",
	MT_RECIPE_COLOR_EPIC = "\195\169pique",

	-- options submenu - announcements
	MT_SUB_ANNOUNCE_NAME = "Annonces",
	MT_SUB_ANNOUNCE_TEXT = "Toutes les annonces",
	MT_SUB_ANNOUNCE_ONSCREENMSG_NAME = "Annonce via message \195\160 l'\195\169cran",
	MT_SUB_ANNOUNCE_ONSCREENMSG_TEXT = "Les annonces des recettes et motifs se font par le biais d'un message au centre de l'\195\169cran",
	MT_SUB_ANNOUNCE_SPECIALS_NAME = "Annonce speciale dans le tchat",
	MT_SUB_ANNOUNCE_SPECIALS_TEXT = "Les annonces des recettes et motifs se font via un message syst\195\168me dans le tchat",
	MT_SUB_ANNOUNCE_REGULAR_NAME = "Informations dans le tchat",
	MT_SUB_ANNOUNCE_REGULAR_TEXT = "Concerne les annonces des informations comme les gains aupr\195\168s des gardes/receleurs, objets vendus, prime",	
	MT_SUB_ANNOUNCE_USELESS_NAME = "Objets inutiles",
	MT_SUB_ANNOUNCE_USELESS_TEXT = "Annonce les objets inutiles d\195\169finis par la limitation au niveau du prix\nVous pouvez lister ces objets avec la commande /mt_junk\n*Sont exclus les recettes et les motifs",
	MT_SUB_ANNOUNCE_BECAREFUL_NAME = "Message 'soyez vigilent' en \195\169tant furtif",
	MT_SUB_ANNOUNCE_BECAREFUL_TEXT = "Annonce SOYER VIGILENT, en raison de la distance pas assez \195\169loign\195\169e pour \195\170tre compl\195\168tement camoufl\195\169. Ceci peut vous aider \195\160 \195\170tre un peu plus prudent.",	
	MT_SUB_ANNOUNCE_KNOWN_RECIPES_NAME = "Recettes connues",
	MT_SUB_ANNOUNCE_KNOWN_RECIPES_TEXT = "Annonce les recettes d\195\169j\195\160 connues via un message syst\195\168me dans le tchat",	
	MT_SUB_ANNOUNCE_SELLS_TRANSFERS_NAME = "Objets vendus/transferts dans le tchat",
	MT_SUB_ANNOUNCE_SELLS_TRANSFERS_TEXT = "Annonce les objets vendus et les transferts au receleur via un message syst\195\168me dans le tchat",	
	MT_SUB_ANNOUNCE_MAX_FENCER_LIMITS_NAME = "Announce fencer limits",
	MT_SUB_ANNOUNCE_MAX_FENCER_LIMITS_TEXT = "Announce a message on chat, if you have reached the amximum limit for sells or transfers",	
	
	-- Binding-Names
	MT_BIND_ONOFF_TEXT = "Bascule On/Off",
	MT_BIND_TOGGLE_SNEAKMODE_TEXT = "Changer le Mode furtif",		
	MT_BIND_SHOW_STATISTIC_TEXT = "Montrer les Statistiques",	
	MT_BIND_SHOW_USELESS_TEXT = "Montrer les objets inutiles",
	MT_BIND_TOGGLE_ATTACK_INNOCENTS_TEXT = "Changer attaque innocent",
	MT_BIND_TOGGLE_LOOTLIST_TEXT = "Montrer lootlist",

	-- Misc Text
	MT_MISC_TRASH_TEXT = "Poubelle: ",
	MT_MISC_SOLD_FOR = " vendu pour ",
	MT_MISC_BOUNTY_IS = "Prime est de ",
	MT_MISC_BOUNTY_REMOVED_FROM_BODY = "La prime pour votre cadavre puant a \195\169t\195\169 retir\195\169e!",
	MT_MISC_ALL_STOLEN_ITEMS_REMOVED = "Tous les objets vol\195\169s ont \195\169t\195\169 confisqu\195\169s par le garde!",
	MT_MISC_YOU_PAID_BOUNTY = "Vous avez pay\195\169 la prime: ",
	MT_MISC_YOU_SOLD_AN_ITEM_FOR = "Vous avez transf\195\169r\195\169 un objet pour ",
	MT_MISC_SNEAKMODE_ACTIVE = "Mode furtif activ\195\169",
	MT_MISC_SNEAKMODE_SLEEPING = "Mode furtif d\195\169sactiv\195\169",
	MT_MISC_BE_CAREFUL = "Soyez vigilant !",
	MT_MISC_MASTERTHIEF_OFF = "MasterThief OFF",
	MT_MISC_SNEAKMODE_ON = "Mode furtif ON",
	MT_MISC_SNEAKMODE_OFF = "MasterThief ON - Mode furtif OFF",
	MT_MISC_IS_KNOWN = "D\195\169j\195\160 connu: ",
	MT_MISC_FREE_SLOTS_LEFT = "Emplacement libre restant: ",
	MT_MISC_SELL_MAXIMUM_REACHED = "Plafond de ventes au receleur atteint!",
	MT_MISC_TRANSFER_MAXIMUM_REACHED = "Plafond de transfert atteint!",
	MT_MISC_ITEM_DESTROYED = "...d\195\169truit!",
	MT_MISC_LIST_USELESS_ITEMS = "Liste des objets inutiles: ",
	MT_MISC_USELESS_ITEMS_FOUND = "Objets inutiles trouv\195\169s: ",
	MT_MISC_TYPE_COMMAND_DESTROY_ITEM = "Utiliser la commande '/mt_junk delete' pour les d\195\169truire",
	MT_MISC_NO_ITEMS_FOUND = "Aucun objet \195\160 d\195\169truire",
	MT_MISC_ITEMS_BELOW_VALUE_USELESS = "Les objets sous la valeur suivante sont consid\195\169r\195\169s comme inutile: ",
	MT_MISC_FOUND_ALOT_GOLD_TEXT = "Vous avez trouvé l'or. Volé: ",
	MT_MISC_ITS_KNOWN_BUT_WANTED_TEXT = "Connu, mais je voulais: ", 
	
	-- Text for statistic on chat
	MT_MISC_HEADER_STATISTIC = "------ Statistiques MasterThief ------",
	MT_MISC_STOLEN_VALUES_IN_BAG = "Valeur des objets vol\195\169s dans le sac:",
	MT_MISC_STOLEN_VALUES_SOLD = "Valeur des objets vol\195\169s vendus:",
	MT_MISC_BOUNTY_PAID = "Prime pay\195\169e:",
	MT_MISC_ACCOUNT_TOTAL = "Montant total:",
	MT_MISC_SELLS_MADE_TODAY = "Ventes r\195\169alis\195\169es aujourd'hui:",
	MT_MISC_TRANSFERS_MADE_TODAY = "Transferts effectu\195\169s aujourd'hui:",
	
	--Text for command list on chat
	MT_MISC_MASTERTHIEF_COMMANDS = "Commandes MasterThief:",
	MT_MISC_MASTERTHIEF_LISTCOMMANDS = "Liste de Commandes",
	MT_MISC_CMD_LIST_ALL_USELESS_ITEMS = "Liste de tous les objets inutiles",
	MT_MISC_CMD_DESTROY_ALL_USELESS_ITEMS = "d\195\169truit tous les objets inutiles",
	MT_MISC_CMD_RESET_ALL_VALUES = "r\195\169initialise toutes les valeurs / primes",
	MT_MISC_SYSTEM_ATTACK_INNOCENTS_OFF = "Attaque innocent OFF",
	MT_MISC_SYSTEM_ATTACK_INNOCENTS_ON = "Attaque innocent ON",
	
	--Text for recipe/searchpool actions
	MT_MISC_RECIPES_ADDED_TO_SEARCHPOOL = " recipe(s) added to comparepool",
	MT_MISC_RECIPES_REMOVED_FROM_SEARCHPOOL = " recipe(s) removed from comparepool",	
	
	--Text for recipe tooltip
	MT_MISC_TOOLTIP_RECIPE_CHARS = "Cette recette est connue par:",	
	
	--Text for Lootlist
	MT_MISC_LOOTLIST_DELETE = " retir\195\169 de lootlist",
	MT_MISC_ITEM_ADDED = " ajout\195\169 \195\161 lootlist",
	MT_MISC_ITEM_ALREADY_ON_LOOTLIST = "Le produit est d\195\169j\195\161 sur lootlist",
	MT_MISC_WORTHFUL_ITEMS = "Lootlist d'articles int\195\169ressants",
	MT_MISC_ITEM_TOOLTIP = "article est d\195\169j\195\161 sur lootlist",
	
	-- Text for Context-Menu
	MT_CONTEXTMENU_LOOT_MARK = "Mark pour autoloot",		
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end