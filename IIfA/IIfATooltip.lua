local IIfA = IIfA
IIfA.LastActiveRowControl = nil

IIfA.PopupLink = nil

function IIfA:CreateTooltips()
	WINDOW_MANAGER:CreateControlFromVirtual("IIFA_ITEM_TOOLTIP", ItemTooltipTopLevel, "IIFA_ITEM_TOOLTIP")
	WINDOW_MANAGER:CreateControlFromVirtual("IIFA_POPUP_TOOLTIP", ItemTooltipTopLevel, "IIFA_POPUP_TOOLTIP")

	ZO_PreHookHandler(PopupTooltip, 'OnAddGameData', IIfA_TooltipOnTwitch)
	ZO_PreHookHandler(PopupTooltip, 'OnHide', IIfA_HideTooltip)

	ZO_PreHookHandler(ItemTooltip, 'OnAddGameData', IIfA_TooltipOnTwitch)
	ZO_PreHookHandler(ItemTooltip, 'OnHide', IIfA_HideTooltip)

	ZO_PreHook("ZO_PopupTooltip_SetLink", function(itemLink) IIfA.PopupLink = itemLink end)

	IIfA:SetTooltipFont(IIfA:GetSettings().in2TooltipsFont)
end

function IIfA:SetTooltipFont(font)
	if not font or font == "" then font = "ZoFontGameMedium" end
--	d("SetTooltipFont called with " .. tostring(font))
	IIfA:GetSettings().in2TooltipsFont = font
	IIFA_ITEM_TOOLTIP:GetNamedChild("_Label"):SetFont(font)
	IIFA_POPUP_TOOLTIP:GetNamedChild("_Label"):SetFont(font)
end

local function getTex(name)
	return ("IIfA/assets/icons/" .. name .. ".dds")
end


IIfA.racialTextures = {
	[0]		= { styleName = "", styleTexture = ""},
	[1]		= { styleName = "Breton", styleTexture = getTex("breton")},
	[2]		= { styleName = "Redguard", styleTexture = getTex("redguard")},
	[3]		= { styleName = "Orc", styleTexture = getTex("orsimer")},
	[4]		= { styleName = "Dunmer", styleTexture = getTex("dunmer")},
	[5]		= { styleName = "Nord", styleTexture = getTex("nord")},
	[6]		= { styleName = "Argonian", styleTexture = getTex("argonian")},
	[7]		= { styleName = "Altmer", styleTexture = getTex("altmer")},
	[8]		= { styleName = "Bosmer", styleTexture = getTex("bosmer")},
	[9]		= { styleName = "Khajiit", styleTexture = getTex("khajit")},
	[10]  	= { styleName = "Unique", styleTexture = getTex("telvanni")},
	[11] 	= { styleName = "Thieves guild", styleTexture = getTex("thief")},
	[12] 	= { styleName = "Dark Brotherhood", styleTexture = getTex("darkbrotherhood")},
	[13] 	= { styleName = "Malacath", styleTexture = getTex("malacath")},
	[14] 	= { styleName = "Dwemer", styleTexture = getTex("dwemer")},
	[15] 	= { styleName = "Ancient Elf",styleTexture = getTex("ancient")},
	[16] 	= { styleName = "Order of the Hour", styleTexture = getTex("akatosh")},
	[17] 	= { styleName = "Barbaric", styleTexture = getTex("reach")},
	[18] 	= { styleName = "Bandit", styleTexture = getTex("bandit")},
	[19] 	= { styleName = "Primal", styleTexture = getTex("primitive")},
	[20] 	= { styleName = "Daedric", styleTexture = getTex("daedric")},
	[21] 	= { styleName = "Trinimac", styleTexture = getTex("trinimac")},
	[22] 	= { styleName = "Ancient Orc", styleTexture = getTex("orsimer")},
	[23] 	= { styleName = "Daggerfall Covenant", styleTexture = getTex("daggerfall")}, -- Imperial City Smurf
	[24] 	= { styleName = "Ebonheart Pact", styleTexture = getTex("ebonheart")}, -- Imperial City Pact
	[25] 	= { styleName = "Aldmeri Dominion", styleTexture = getTex("ancient")}, -- Imperial City Banana
	[26] 	= { styleName = "Undaunted", styleTexture = getTex("laurel")},
	[27] 	= { styleName = "Celestial", styleTexture = getTex("dragonknight")},
	[28] 	= { styleName = "Glass", styleTexture = getTex("templar")}, -- Glass
	[29] 	= { styleName = "Xivkyn", styleTexture = getTex("nightblade")}, -- Imperial Daedric / Xivkyn
	[30] 	= { styleName = "Soulshriven", styleTexture = getTex("soulshriven")},
	[31] 	= { styleName = "Draugr", styleTexture = getTex("skull")},  --undead
	[32] 	= { styleName = "Maormer", styleTexture = getTex("maormer")},  --sea elves
	[33] 	= { styleName = "Akaviri", styleTexture = getTex("akaviri")},  --samurai
	[34] 	= { styleName = "Imperial", styleTexture = getTex("imperial")},
	[35] 	= { styleName = "Yokudan", styleTexture = getTex("akaviri")},
	[36] 	= { styleName = "Universal", styleTexture = getTex("imperial")},
	[37] 	= { styleName = "Winterborn", styleTexture = getTex("reach")},
	[38] 	= { styleName = "Worm Cult", styleTexture = getTex("wormcult")},
	[39] 	= { styleName = "Minotaur", styleTexture = getTex("minotaur")},
	[40] 	= { styleName = "Ebony", styleTexture = getTex("ebony")},
	[41] 	= { styleName = "Abah's Watch", styleTexture = getTex("abahswatch")},
	[42] 	= { styleName = "Skinchanger", styleTexture = getTex("skinchanger")},
	[43] 	= { styleName = "Morag Tong", styleTexture = getTex("moragtong")},
	[44] 	= { styleName = "Ra Gada", styleTexture = getTex("ragada")},
	[45] 	= { styleName = "Dro-m'Athra", styleTexture = getTex("dromathra")},
	[46] 	= { styleName = "Assassins League", styleTexture = getTex("assassin")},
	[47] 	= { styleName = "Outlaw", styleTexture = getTex("bandit")},
	[48] 	= { styleName = "unused 11", styleTexture = getTex("telvanni")},
	[49] 	= { styleName = "unused 12", styleTexture = getTex("telvanni")},
	[50] 	= { styleName = "unused 13", styleTexture = getTex("telvanni")},
	[51] 	= { styleName = "unused 14", styleTexture = getTex("telvanni")},
	[52] 	= { styleName = "unused 15", styleTexture = getTex("telvanni")},
	[53] 	= { styleName = "Frostcaster", styleTexture = getTex("telvanni")},
	[54] 	= { styleName = "Ashlander", styleTexture = getTex("cliffracer")},
	[55] 	= { styleName = "Necromancer", styleTexture = getTex("skull_nice")},
	[56] 	= { styleName = "Silken Ring", styleTexture = getTex("kothringi")},
	[57] 	= { styleName = "Mazzatun", styleTexture = getTex("lizard")},
	[58] 	= { styleName = "Grim Harlequin", styleTexture = getTex("harlequin")},
	[59] 	= { styleName = "Hollowjack", styleTexture = getTex("hollowjack")},
}
--[[ -- those aren't used right now. Not sure whether or not we actually want to.
IIfA.itemEquipTypeTextures = {
	[EQUIP_TYPE_CHEST]  =   "/esoui/art/inventory/inventory_tabicon_armor_up.dds",
	[EQUIP_TYPE_COSTUME]  =   "/esoui/art/inventory/inventory_tabicon_armor_up.dds",
	[EQUIP_TYPE_FEET]  =   "/esoui/art/inventory/inventory_tabicon_armor_up.dds",
	[EQUIP_TYPE_HAND]  =   "/esoui/art/inventory/inventory_tabicon_armor_up.dds",
	[EQUIP_TYPE_HEAD]  =   "/esoui/art/inventory/inventory_tabicon_armor_up.dds",
	[EQUIP_TYPE_INVALID]  =   "",
	[EQUIP_TYPE_LEGS]  =   "/esoui/art/inventory/inventory_tabicon_armor_up.dds",
	[EQUIP_TYPE_MAIN_HAND]  =   "/esoui/art/inventory/inventory_tabicon_weapons_up.dds",
	[EQUIP_TYPE_NECK]  =   "/esoui/art/inventory/inventory_tabicon_armor_up.dds",
	[EQUIP_TYPE_OFF_HAND]  =   "/esoui/art/inventory/inventory_tabicon_armor_up.dds",
	[EQUIP_TYPE_ONE_HAND]  =   "/esoui/art/inventory/inventory_tabicon_weapons_up.dds",
	[EQUIP_TYPE_RING]  =   "/esoui/art/inventory/inventory_tabicon_armor_up.dds",
	[EQUIP_TYPE_SHOULDERS]  =   "/esoui/art/inventory/inventory_tabicon_armor_up.dds",
	[EQUIP_TYPE_TWO_HAND]  =   "/esoui/art/inventory/inventory_tabicon_weapons_up.dds",
	[EQUIP_TYPE_WAIST]  =   "/esoui/art/inventory/inventory_tabicon_armor_up.dds"
}

IIfA.gearslotTextures = {
	[EQUIP_TYPE_CHEST] = "/esoui/art/characterwindow/gearslot_chest.dds",
	[EQUIP_TYPE_COSTUME] = "/esoui/art/characterwindow/gearslot_costume.dds",
	[EQUIP_TYPE_FEET] = "/esoui/art/characterwindow/gearslot_feet.dds",
	[EQUIP_TYPE_HAND] = "/esoui/art/characterwindow/gearslot_hands.dds",
	[EQUIP_TYPE_HEAD] = "/esoui/art/characterwindow/gearslot_head.dds",
	[EQUIP_TYPE_LEGS] = "/esoui/art/characterwindow/gearslot_legs.dds",
	[EQUIP_TYPE_MAIN_HAND] = "/esoui/art/characterwindow/gearslot_mainhand.dds",
	[EQUIP_TYPE_NECK] = "/esoui/art/characterwindow/gearslot_neck.dds",
	[EQUIP_TYPE_OFF_HAND] = "/esoui/art/characterwindow/gearslot_offhand.dds",
	[EQUIP_TYPE_ONE_HAND] = "/esoui/art/characterwindow/gearslot_mainhand.dds",
	[EQUIP_TYPE_RING] = "/esoui/art/characterwindow/gearslot_ring.dds",
	[EQUIP_TYPE_SHOULDERS] = "/esoui/art/characterwindow/gearslot_shoulders.dds",
	[EQUIP_TYPE_TWO_HAND] = "/esoui/art/characterwindow/gearslot_mainhand.dds",
	[EQUIP_TYPE_WAIST] = "/esoui/art/characterwindow/gearslot_belt.dds",
	[15] = "/esoui/art/characterwindow/gearslot_tabard.dds"
}
--]]

local controlTooltips = {
	["LineShare"] 	= "Doubleclick an item to add link to chat.",
	["close"] 		= "close",
	["toggle"] 		= "toggle",
	["Search"] 		= "Search item name..."
}

local function getStyleIntel(itemLink)
	if not itemLink then
		return nil
	end
	if IIfA.GetSettings().showStyleInfo == false then
		return nil
	end

	local data = itemLink:match("|H.:item:(.-)|h.-|h")
	-- d(data)
	-- d(zo_strsplit(':', data))
	local itemID,
		_,
		itemLevel,
		itemEnchantmentType,
		itemEnchantmentStrength1,
		itemEnchantmentStrength2,
		_, _, _, _, _, _, _, _, _,
		itemStyle,
		_,
		itemIsBound,
		itemChargeStatus = zo_strsplit(':', data)

	return IIfA.racialTextures[tonumber(itemStyle)]
end

local function anchorFrame(frame, parentTooltip)
	if(frame:GetTop() < parentTooltip:GetBottom()) then
		frame:ClearAnchors()
		frame:SetAnchor(BOTTOM, parentTooltip, TOP, 0, 0)
	elseif(frame:GetBottom() > parentTooltip:GetTop()) then
		frame:ClearAnchors()
		frame:SetAnchor(TOP, parentTooltip, BOTTOM, 0, 0)
	end
end

function IIfA_HideTooltip(control, ...)
	if control == ItemTooltip then
		IIFA_ITEM_TOOLTIP:SetHidden(true)
	elseif control == PopupTooltip then
		IIFA_POPUP_TOOLTIP:SetHidden(true)
	end
end

function IIfA_TooltipOnTwitch(control, eventNum)
	-- this is called whenever there's any data added to the ingame tooltip
	if eventNum == 7 or eventNum == 3 then
		if control == ItemTooltip then
			-- item tooltips appear where mouse is
			return IIfA:UpdateTooltip(IIFA_ITEM_TOOLTIP)
		elseif control == PopupTooltip then
			-- popup tooltips have the X in the corner and usually pop up in center screen
			IIfA.CurrentLink = PopupTooltip.lastLink
			return IIfA:UpdateTooltip(IIFA_POPUP_TOOLTIP)
		end
	end
end


--function getControlTooltip(key)
-- 	if not key then return "" end
--	return controlTooltips[key]
--end

--function IIFA_GUISearchboxShowTooltip(control, key)
--	ZO_Tooltips_ShowTextTooltip(control.parent, TOP, getControlTooltip(key))
--end

function IIfA:GetEquippedItemLink(mouseOverControl)
	local fullSlotName = mouseOverControl:GetName()
	local slotName = string.gsub(fullSlotName, "ZO_CharacterEquipmentSlots", "")
	local index = 0

	if 		(slotName == "Head")		then index = 0
	elseif	(slotName == "Neck") 		then index = 1
	elseif	(slotName == "Chest") 		then index = 2
	elseif	(slotName == "Shoulder") 	then index = 3
	elseif	(slotName == "MainHand") 	then index = 4
	elseif	(slotName == "OffHand") 	then index = 5
	elseif	(slotName == "Belt") 		then index = 6
	elseif	(slotName == "Costume") 	then index = 7
	elseif	(slotName == "Leg") 		then index = 8
	elseif	(slotName == "Foot") 		then index = 9
	elseif	(slotName == "Ring1") 		then index = 11
	elseif	(slotName == "Ring2") 		then index = 12
	elseif	(slotName == "Glove") 		then index = 16
	elseif	(slotName == "BackupMain") 	then index = 20
	elseif	(slotName == "BackupOff") 	then index = 20
	end

	-- debug for bag stuff
	--[[ for bagSlot = 1	, (GetBagSize and GetBagSize(bagId_WORN) or select(2, GetBagInfo(bagId_WORN))), 1 do
		if (GetItemLink(0, bagSlot) ~= "") then
			d(bagIdSlot .. ": " .. GetItemLink(0, bagSlot))
		end
	end]]

	local itemLink = GetItemLink(0, index, LINK_STYLE_BRACKETS)
	return itemLink
end


local function getMouseoverLink()
	local data
	local mouseOverControl = moc()
	if not mouseOverControl then return end

	local name = nil
	if mouseOverControl:GetParent() then
		name = mouseOverControl:GetParent():GetName()
	else
		name = mouseOverControl:GetName()
	end

	-- do we show IIfA info?
	if IIfA:GetSettings().showToolTipWhen == "Never" or
		(IIfA:GetSettings().showToolTipWhen == "IIfA" and name ~= "IIFA_GUI_ListHolder") then
		return nil
	end

	if	name == 'ZO_CraftBagListContents' or
		name == 'ZO_EnchantingTopLevelInventoryBackpackContents' or
		name == 'ZO_GuildBankBackpackContents' or
		name == 'ZO_PlayerBankBackpackContents' or
		name == 'ZO_PlayerInventoryListContents' or
		name == 'ZO_QuickSlotListContents' or
		name == 'ZO_SmithingTopLevelDeconstructionPanelInventoryBackpackContents' or
		name == 'ZO_SmithingTopLevelImprovementPanelInventoryBackpackContents' or
		name == 'ZO_SmithingTopLevelRefinementPanelInventoryBackpackContents' or
		name == 'ZO_PlayerInventoryBackpackContents' then
		if not mouseOverControl.dataEntry then return end
		data = mouseOverControl.dataEntry.data
		return GetItemLink(data.bagId, data.slotIndex, LINK_STYLE_BRACKETS)

	elseif name == "ZO_LootAlphaContainerListContents" then						-- is loot item
		if not mouseOverControl.dataEntry then return end
		data = mouseOverControl.dataEntry.data
		return GetLootItemLink(data.lootId, LINK_STYLE_BRACKETS)

	elseif name == "ZO_InteractWindowRewardArea" then							-- is reward item
		return GetQuestRewardItemLink(mouseOverControl.index, LINK_STYLE_BRACKETS)

	elseif name == "ZO_Character" then											-- is worn item
		return IIfA:GetEquippedItemLink(mouseOverControl)

	elseif name == "ZO_StoreWindowListContents" then							-- is store item
		return GetStoreItemLink(mouseOverControl.index, LINK_STYLE_BRACKETS)

	elseif name == "ZO_BuyBackListContents" then								-- is buyback item
		return GetBuybackItemLink(mouseOverControl.index, LINK_STYLE_BRACKETS)

	-- following 4 if's derived directly from MasterMerchant
	elseif string.sub(name, 1, 14) == "MasterMerchant" then
		local mocGPGP = mouseOverControl:GetParent():GetParent()
		if mocGPGP then
			name = mocGPGP:GetName()
			if	name == 'MasterMerchantWindowListContents' or
				name == 'MasterMerchantWindowList' or
				name == 'MasterMerchantGuildWindowListContents' then
				if mouseOverControl.GetText then
					return mouseOverControl:GetText()
				end
			end
		end
	elseif name == 'ZO_LootAlphaContainerListContents' then
		return GetLootItemLink(mouseOverControl.dataEntry.data.lootId)
	elseif name == 'ZO_MailInboxMessageAttachments' then
		return GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), mouseOverControl.id, LINK_STYLE_DEFAULT)
	elseif name == 'ZO_MailSendAttachments' then
		return GetMailQueuedAttachmentLink(mouseOverControl.id, LINK_STYLE_DEFAULT)

	elseif name == "ZO_MailInboxMessageAttachments" then
		return nil

	elseif name == "IIFA_GUI_ListHolder" then
		-- falls out, returns default current link

	elseif name:sub(1, 13) == "IIFA_ListItem" then
		return mouseOverControl.itemLink

	elseif name:sub(1, 44) == "ZO_TradingHouseItemPaneSearchResultsContents" then
		data = mouseOverControl.dataEntry
		if data then data = data.data end
	    -- The only thing with 0 time remaining should be guild tabards, no
    	-- stats on those!
    	if not data or data.timeRemaining == 0 then return nil end
		return GetTradingHouseSearchResultItemLink(data.slotIndex)

	elseif name == "ZO_TradingHousePostedItemsListContents" then
		return GetTradingHouseListingItemLink(mouseOverControl.dataEntry.data.slotIndex)

  	elseif name == 'ZO_TradingHouseLeftPanePostItemFormInfo' then
    	if mouseOverControl.slotIndex and mouseOverControl.bagId then
			return GetItemLink(mouseOverControl.bagId, mouseOverControl.slotIndex)
		end

	else
--		d(mouseOverControl:GetName(), mouseOverControl)
		IIfA:DebugOut("Tooltip not processed - '" .. name .. "'")

		if IIfA.CurrentLink then
			IIfA:DebugOut("Current Link - " .. IIfA.CurrentLink)
		end

		return nil
	end

	return IIfA.CurrentLink
end

local function getLastLink(tooltip)
	local ret = nil
	if tooltip == IIFA_POPUP_TOOLTIP then
		ret = IIfA.PopupLink
	elseif tooltip == IIFA_ITEM_TOOLTIP then
		ret = getMouseoverLink()
	end

	if (not ret) then
		if not IIfA.LastActiveRowControl then return ret end
		ret = IIfA.LastActiveRowControl:GetText()
	end

	return ret
end


function IIfA:UpdateTooltip(frame)
	local itemLink

--	if UpdateFromOnScroll == nil then
--	   UpdateFromOnScroll = false
		itemLink = getLastLink(frame)
--	elseif UpdateFromOnScroll then
--		itemLink = moc().itemLink
--	end
	local parentTooltip = nil
	if frame == IIFA_POPUP_TOOLTIP then parentTooltip = PopupTooltip end
	if frame == IIFA_ITEM_TOOLTIP then parentTooltip = ItemTooltip end

-- see master merchant for the RIGHT way to do this
--[[	if parentTooltip.IIFA_TT_Ext == nil then
		tControl = CreateControlFromVirtual("IIFA_TT_Extension", parentTooltip, "IIFA_TOOLTIP_EXTENSION")
		parentTooltip.IIFA_TT_Ext = tControl
	else
		tControl = parentTooltip.IIFA_TT_Ext
	end

	parentTooltip:AddControl(tControl)
	tControl:SetAnchor(CENTER)
	ZO_Tooltip_AddDivider(parentTooltip)
--]]

	local queryResults = IIfA:QueryAccountInventory(itemLink)
	local itemStyleTexArray = getStyleIntel(itemLink)
	if not itemStyleTexArray then itemStyleTexArray = {["styleTexture"] = "", ["styleName"] = ""} end
	if itemStyleTexArray.styleName == nil then itemStyleTexArray = {["styleTexture"] = "", ["styleName"] = ""} end

	if (not itemLink) or ((#queryResults.locations == 0) and (itemStyleTexArray.styleName == "")) then
		frame:SetHidden(true)
		return
	end

	frame:ClearLines()
	frame:SetHidden(false)
	frame:SetHeight(0)

	frame:SetWidth(parentTooltip:GetWidth())

	if itemStyleTexArray.styleName ~= "" then
		frame:AddLine(" ");
	end

	if(queryResults) then
		if #queryResults.locations > 0 then
			if itemStyleTexArray.styleName ~= "" then
				ZO_Tooltip_AddDivider(frame)
			end
			for x, location in pairs(queryResults.locations) do
				local textOut
				textOut = location.name .. " x" .. location.itemsFound
				IIfA:DebugOut(textOut)
				if location.worn then
					textOut = textOut .. " *"
				end
				textOut = IIfA.colorHandler:Colorize(textOut)
				frame:AddLine(textOut)
			end
		end
	end

	local styleIcon = frame:GetNamedChild("_StyleIcon")
	local styleLabel = frame:GetNamedChild("_StyleLabel")

	-- update the style icon
	styleIcon:SetTexture(itemStyleTexArray.styleTexture)
	styleLabel:SetText(itemStyleTexArray.styleName)

	styleLabel:SetHidden(itemStyleTexArray.styleName == "")
	styleIcon:SetHidden(itemStyleTexArray.styleName == "")
	anchorFrame(frame, parentTooltip)
end
