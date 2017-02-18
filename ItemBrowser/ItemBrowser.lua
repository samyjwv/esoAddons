ItemBrowser = {
	name = "ItemBrowser",
	slashCommand = "/itembrowser",

	sortType = 1,

	colors = {
		health  = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER, POWERTYPE_HEALTH)),
		magicka = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER, POWERTYPE_MAGICKA)),
		stamina = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER, POWERTYPE_STAMINA)),
		violet  = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, ITEM_QUALITY_ARTIFACT)),
		gold    = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, ITEM_QUALITY_LEGENDARY)),
		brown   = ZO_ColorDef:New("885533"),
		teal    = ZO_ColorDef:New("66CCCC"),
		pink    = ZO_ColorDef:New("FF99CC"),
	},
};

function ItemBrowser.OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= ItemBrowser.name) then return end

	EVENT_MANAGER:UnregisterForEvent(ItemBrowser.name, EVENT_ADD_ON_LOADED);

	SLASH_COMMANDS[ItemBrowser.slashCommand] = ItemBrowser.HandleSlashCommand;

	ZO_CreateStringId("SI_BINDING_NAME_ITEMBROWSER", GetString(SI_ITEMBROWSER_TITLE));

	local allianceStyles = {
		[ALLIANCE_NONE]                = ITEMSTYLE_NONE,
		[ALLIANCE_ALDMERI_DOMINION]    = ITEMSTYLE_ALLIANCE_ALDMERI,
		[ALLIANCE_EBONHEART_PACT]      = ITEMSTYLE_ALLIANCE_EBONHEART,
		[ALLIANCE_DAGGERFALL_COVENANT] = ITEMSTYLE_ALLIANCE_DAGGERFALL,
	};

	ItemBrowser.allianceStyle = allianceStyles[GetUnitAlliance("player")];

	-- For multi-style items, such as crafted items, just pick a style matching the player's race.
	ItemBrowser.multiStyle = GetUnitRaceId("player");
	if (ItemBrowser.multiStyle == 10) then ItemBrowser.multiStyle = ITEMSTYLE_RACIAL_IMPERIAL end
end

function ItemBrowser.HandleSlashCommand( command )
	ItemBrowser.Toggle();
end

function ItemBrowser.Toggle( )
	if (not ItemBrowser.list) then
		-- Lazy initialization
		ItemBrowser.list = ItemBrowserList:New(ItemBrowserFrame);
	end

	if (ItemBrowserFrame:IsControlHidden()) then
		SCENE_MANAGER:Show("ItemBrowserScene");
	else
		SCENE_MANAGER:Hide("ItemBrowserScene");
	end
end

function ItemBrowser.AddToChat( message )
	StartChatInput(CHAT_SYSTEM.textEntry:GetText() .. message);
end

function ItemBrowser.CheckFlag( flags, flagToCheck )
	-- Lua is a scrub language with no native bitwise operators
	return(math.floor(flags / flagToCheck) % 2 == 1);
end

function ItemBrowser.GetZoneNameById( zoneId )
	if (zoneId < 0) then
		return(GetString("SI_ITEMBROWSER_SOURCE_SPECIAL", zoneId * -1));
	else
		return(LocalizeString("<<C:1>>", GetZoneNameByIndex(GetZoneIndex(zoneId))));
	end
end

function ItemBrowser.MakeItemLink( id, flags )
	local quality = 364;
	local crafted = 0;
	local health = 10000;

	if (ItemBrowser.CheckFlag(flags, ItemBrowserData.flags.crafted)) then
		quality = 370;
		crafted = 1;
	elseif (ItemBrowser.CheckFlag(flags, ItemBrowserData.flags.jewelry)) then
		quality = 363;
		health = 0;
	elseif (ItemBrowser.CheckFlag(flags, ItemBrowserData.flags.weapon)) then
		health = 500;
	end

	local style = ITEMSTYLE_NONE;

	if (ItemBrowser.CheckFlag(flags, ItemBrowserData.flags.allianceStyle)) then
		style = ItemBrowser.allianceStyle;
	elseif (ItemBrowser.CheckFlag(flags, ItemBrowserData.flags.multiStyle)) then
		style = ItemBrowser.multiStyle;
	end

	local itemLink = string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:%d:%d:0:0:%d:0|h|h", id, quality, style, crafted, health);

	if (crafted == 1) then
		-- Attach an enchantment to crafted gear

		local enchantments = {
			[ARMORTYPE_NONE]   = 0,
			[ARMORTYPE_HEAVY]  = 26580,
			[ARMORTYPE_LIGHT]  = 26582,
			[ARMORTYPE_MEDIUM] = 26588,
		};

		itemLink = itemLink:gsub("370:50:0:0:0", string.format("370:50:%d:370:50", enchantments[GetItemLinkArmorType(itemLink)]));
	end

	return(itemLink);
end

function ItemBrowser.GetSetBonuses( itemLink, numBonuses )
	local bonuses, description;

	if (numBonuses > 0) then
		bonuses = { };
		for i = 1, numBonuses do
			_, description = GetItemLinkSetBonusInfo(itemLink, false, i);
			table.insert(bonuses, description);
		end
	else
		-- Arena weapons are not sets; use the enchantment description instead
		_, _, description = GetItemLinkEnchantInfo(itemLink);
		bonuses = { description };
	end

	return(bonuses);
end

function ItemBrowser.CreateEntryFromRaw( rawEntry )
	local id = rawEntry[1];
	local flags = rawEntry[2];

	local itemLink = ItemBrowser.MakeItemLink(id, flags);
	local name, type, color, style, bonuses;
	local zoneType = { };

	if (ItemBrowser.CheckFlag(flags, ItemBrowserData.flags.weapon)) then
		name = LocalizeString("<<t:1>>", GetItemLinkName(itemLink));
		type = LocalizeString("<<C:1>>", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON));
		color = ItemBrowser.colors.gold;
		bonuses = 0;
	else
		_, name, bonuses = GetItemLinkSetInfo(itemLink);
		name = LocalizeString("<<C:1>>", name);

		if (ItemBrowser.CheckFlag(flags, ItemBrowserData.flags.crafted)) then
			type = string.format("%s (%d)", GetString(SI_ITEMBROWSER_TYPE_CRAFTED), rawEntry[4]);
			color = ItemBrowser.colors.pink;
			zoneType[0] = true;
		elseif (ItemBrowser.CheckFlag(flags, ItemBrowserData.flags.jewelry)) then
			type = GetString("SI_GAMEPADITEMCATEGORY", GAMEPAD_ITEM_CATEGORY_JEWELRY);
			color = ItemBrowser.colors.violet;
		elseif (ItemBrowser.CheckFlag(flags, ItemBrowserData.flags.monster)) then
			type = GetString(SI_ITEMBROWSER_TYPE_MONSTER);
			color = ItemBrowser.colors.brown;
		elseif (ItemBrowser.CheckFlag(flags, ItemBrowserData.flags.mixedWeights)) then
			type = GetString(SI_ITEMBROWSER_TYPE_MIXED);
			color = ItemBrowser.colors.teal;
		else
			armorType = GetItemLinkArmorType(itemLink);

			local armorColors = {
				[ARMORTYPE_NONE]   = ZO_DEFAULT_TEXT,
				[ARMORTYPE_HEAVY]  = ItemBrowser.colors.health,
				[ARMORTYPE_LIGHT]  = ItemBrowser.colors.magicka,
				[ARMORTYPE_MEDIUM] = ItemBrowser.colors.stamina,
			};

			type = LocalizeString("<<C:1>>", GetString("SI_ARMORTYPE", armorType));
			color = armorColors[armorType];
		end
	end

	local source = "";

	for i = 1, #rawEntry[3] do
		if (i > 1) then source = source .. ", " end
		source = source .. ItemBrowser.GetZoneNameById(rawEntry[3][i]);
		zoneType[ItemBrowserData.zoneClassification[rawEntry[3][i]]] = true;
	end

	if (ItemBrowser.CheckFlag(flags, ItemBrowserData.flags.monster)) then
		source = string.format("%s (%s)", source, ItemBrowserData.undauntedNames[rawEntry[4]]);
	end

	if ( not ItemBrowser.CheckFlag(flags, ItemBrowserData.flags.jewelry) and
	     not ItemBrowser.CheckFlag(flags, ItemBrowserData.flags.monster) and
	     not ItemBrowser.CheckFlag(flags, ItemBrowserData.flags.multiStyle) ) then

		if (ItemBrowser.CheckFlag(flags, ItemBrowserData.flags.allianceStyle)) then
			style = GetString(SI_ITEMBROWSER_STYLE_ALLIANCE);
		else
			style = GetString("SI_ITEMSTYLE", GetItemLinkItemStyle(itemLink));
		end
	end

	zoneType[(GetItemLinkBindType(itemLink) == BIND_TYPE_ON_EQUIP) and 5 or 6] = true;

	return({
		type = ItemBrowser.sortType,
		name = name,
		itemType = type,
		source = source,
		zoneType = zoneType,
		color = color,
		style = style,
		bonuses = bonuses,
		itemLink = itemLink,
	});
end

EVENT_MANAGER:RegisterForEvent(ItemBrowser.name, EVENT_ADD_ON_LOADED, ItemBrowser.OnAddOnLoaded);
