local HarvensTraitAndStyle = {}
local g_savedVars = {}

-- color values taken from INTERFACE_COLOR_TYPE_STAT_VALUE
-- in order to avoid errors when ZOS changes their names
local COLOR_ORANGE = ZO_ColorDef:New(220/255, 129/255, 34/255)
local COLOR_RED = ZO_ColorDef:New(255/255, 25/255, 25/255)

local UnknowableTraitTypes = {
	[ITEM_TRAIT_TYPE_NONE] = "none",
	[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = "weapon",
	[ITEM_TRAIT_TYPE_WEAPON_ORNATE] = "weapon",
	[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = "armor",
	[ITEM_TRAIT_TYPE_ARMOR_ORNATE] = "armor",
	[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = "jewelry",
	[ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = "jewelry",
	[ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = "jewelry",
	[ITEM_TRAIT_TYPE_JEWELRY_ORNATE] = "jewelry",
	[ITEM_TRAIT_TYPE_SPECIAL_STAT] = "special",
}

local TRAIT_RESEARCHABLE = 0
local TRAIT_KNOWN = 1
local TRAIT_RESEARCH_IN_PROGRESS = 2

local TraitStatusStrings =
{
	[TRAIT_RESEARCHABLE] = zo_strformat("<<1>>", GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)),
	[TRAIT_KNOWN] = zo_strformat(SI_ITEM_FORMAT_STR_KNOWN_ITEM_TYPE, GetString(SI_SMITHING_HEADER_TRAIT)),
	[TRAIT_RESEARCH_IN_PROGRESS] = zo_strformat("<<1>>", GetString(SI_SMITHING_RESEARCH_IN_PROGRESS)),
}

--local functions

local function getStyleHeaderLine(styleIndex)
	local style = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", styleIndex))
	local color = ZO_TOOLTIP_DEFAULT_COLOR

	if g_savedVars.colorizeStyle then
		if styleIndex >= ITEMSTYLE_RACIAL_BRETON and styleIndex <= ITEMSTYLE_RACIAL_KHAJIIT then
			color = GetItemQualityColor(ITEM_QUALITY_ARCANE)
		elseif styleIndex == ITEMSTYLE_RACIAL_IMPERIAL
			or styleIndex == ITEMSTYLE_AREA_DWEMER
			or styleIndex == ITEMSTYLE_AREA_XIVKYN
			or styleIndex == ITEMSTYLE_GLASS then
			color = GetItemQualityColor(ITEM_QUALITY_LEGENDARY)
		else
			color = GetItemQualityColor(ITEM_QUALITY_ARTIFACT)
		end
	end

	return color, style
end

local function getTraitHeaderLine(researchStatus, countBank, countPack, countWorn)
	local color = ZO_TOOLTIP_DEFAULT_COLOR
	local parts = {}

	if g_savedVars.colorizeTrait then
		if researchStatus == TRAIT_RESEARCHABLE then
			if countBank + countPack + countWorn > 1 then
				color = COLOR_ORANGE
			else
				color = COLOR_RED
			end
		elseif researchStatus == TRAIT_RESEARCH_IN_PROGRESS then
			color = COLOR_ORANGE
		end
	end

	if g_savedVars.duplicateItems and researchStatus == TRAIT_RESEARCHABLE then
		if countBank > 0 then
			parts[#parts + 1] = "|u2:2::"
			parts[#parts + 1] = countBank
			parts[#parts + 1] = "|u"
			parts[#parts + 1] = "|t24:24:esoui/art/icons/servicemappins/servicepin_bank.dds:inheritColor|t"
			parts[#parts + 1] = "|u4:0::|u " -- padding
		end
		if countPack > 0 then
			parts[#parts + 1] = "|u2:0::"
			parts[#parts + 1] = countPack
			parts[#parts + 1] = "|u"
			parts[#parts + 1] = "|t24:24:EsoUI/Art/Crafting/crafting_provisioner_inventorycolumn_icon.dds:inheritColor|t"
		end
	end

	if g_savedVars.showResearchInUpperRightCorner then
		parts[#parts + 1] = "("
		parts[#parts + 1] = tostring(TraitStatusStrings[researchStatus])
		parts[#parts + 1] = ")"
	end

	if #parts > 0 then
		local text = table.concat(parts, "")
		return color, text
	end

	return color
end

-- optionally appends research info to localized trait name
-- returns function that will restore the original string
local function hackTraitName(traitType, appendColor, appendString)
	if g_savedVars.appendResearchToTraitName and appendColor and appendString then
		local stringId = _G["SI_ITEMTRAITTYPE" .. traitType]
		local orgString = EsoStrings[stringId]
		EsoStrings[stringId] = ("%s |c%s(%s)|r"):format(orgString, appendColor:ToHex(), appendString)
		return function() EsoStrings[stringId] = orgString end
	else
		return function() end
	end
end

local function hookMethod(obj, name, hook)
	local orgFunc = obj[name]
	local function hookFunc(...)
		return hook(orgFunc, ...)
	end
	obj[name] = hookFunc
end

local function setValueIfNil(tab, name, defaultValue)
	if tab[name] == nil then
		tab[name] = defaultValue
		return true
	end
	return false
end

--exposable functions

function HarvensTraitAndStyle:GetSameTraitCount(bagId, armorType, weaponType, equipType, trait)
--[[
	if not g_savedVars.duplicateItems then
		return 0
	end
--]]
	local count = 0
	for slotIndex = 0, GetBagSize(bagId) - 1 do
		local itemType = GetItemType(bagId, slotIndex)
		if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
			if armorType == GetItemArmorType(bagId, slotIndex) and weaponType == GetItemWeaponType(bagId, slotIndex) and GetItemTrait(bagId, slotIndex) == trait then
				local _,_,_,_,_, otherEquipType = GetItemInfo(bagId, slotIndex)
				if otherEquipType == equipType then
					count = count + 1
				end
			end
		end
	end
	return count
end

function HarvensTraitAndStyle:GetItemLinkResearchStatus(link)
	local traitType = GetItemLinkTraitInfo(link)
	if UnknowableTraitTypes[traitType] then
		return nil
	end

	local itemType = GetItemLinkItemType(link)
	local tradeSkill
	local resIndex

	if itemType == ITEMTYPE_ARMOR then
		local armorType = GetItemLinkArmorType(link)
		local equipType = GetItemLinkEquipType(link)
		local resLines = self.armorTypeAndEquipTypeToResearchLineIndex[armorType]
		tradeSkill = self.tradeskillForArmorType[armorType]
		resIndex = resLines and resLines[equipType]
	elseif itemType == ITEMTYPE_WEAPON then
		local weaponType = GetItemLinkWeaponType(link)
		tradeSkill = self.tradeskillForWeaponType[weaponType]
		resIndex = self.weaponTypeToResearchLineIndex[weaponType]
	end
	
	if not tradeSkill or not resIndex then
		return nil
	end
	
	self.altsResearchStatus = {
		[TRAIT_RESEARCHABLE] = {},
		[TRAIT_KNOWN] = {},
		[TRAIT_RESEARCH_IN_PROGRESS] = {}
	}
	
	if g_savedVars.showAlts then
		for k,v in pairs(g_savedVars.characters) do
			if k ~= self.unitName and ( g_savedVars[self.unitName][k] == null or g_savedVars[self.unitName][k] == true ) then
				table.insert(self.altsResearchStatus[g_savedVars.characters[k][tradeSkill][resIndex][traitType]], k)
			end
		end
	end
	
	if not (g_savedVars.characters[self.unitName][tradeSkill] and resIndex) then
		return nil
	end

	return g_savedVars.characters[self.unitName][tradeSkill][resIndex][traitType]
end

function HarvensTraitAndStyle:AddStyleFromBagNoHack(tooltip, bagId, slotIndex)
	local equipType, itemStyle = select(6, GetItemInfo(bagId, slotIndex))
	if itemStyle ~= ITEMSTYLE_NONE then
		local styleColor, styleText = getStyleHeaderLine(itemStyle)
		tooltip:AddHeaderLine(styleText, "ZoFontWinT2", 2, TOOLTIP_HEADER_SIDE_LEFT, styleColor:UnpackRGB())
	end

	local traitType = GetItemTrait(bagId, slotIndex)
	local researchColor = nil
	local researchStatus = self:GetItemLinkResearchStatus(GetItemLink(bagId, slotIndex))
	if researchStatus then
		local armorType = GetItemArmorType(bagId, slotIndex)
		local weaponType = GetItemWeaponType(bagId, slotIndex)
		local countBank = self:GetSameTraitCount(BAG_BANK, armorType, weaponType, equipType, traitType)
		local countPack = self:GetSameTraitCount(BAG_BACKPACK, armorType, weaponType, equipType, traitType)
		local countWorn = self:GetSameTraitCount(BAG_WORN, armorType, weaponType, equipType, traitType)
		researchColor, traitText = getTraitHeaderLine(researchStatus, countBank, countPack, countWorn)
		if traitText then
			tooltip:AddHeaderLine(traitText, "ZoFontWinT2", 2, TOOLTIP_HEADER_SIDE_RIGHT, researchColor:UnpackRGB())
		end
		researchStatus = tostring(TraitStatusStrings[researchStatus])
	end

	return traitType, researchColor, researchStatus
end

function HarvensTraitAndStyle:AddStyleFromBag(tooltip, bagId, slotIndex)
	self.altsResearchStatus = nil
	return hackTraitName(self:AddStyleFromBagNoHack(tooltip, bagId, slotIndex))
end

function HarvensTraitAndStyle:AddStyleFromLink(tooltip, link)
	self.altsResearchStatus = nil
	local itemStyle = GetItemLinkItemStyle(link)
	if itemStyle ~= ITEMSTYLE_NONE then
		local styleColor, styleText = getStyleHeaderLine(itemStyle)
		tooltip:AddHeaderLine(styleText, "ZoFontWinT2", 2, TOOLTIP_HEADER_SIDE_LEFT, styleColor:UnpackRGB())
	end

	local traitType = GetItemLinkTraitInfo(link)
	local researchColor = nil
	local researchStatus = self:GetItemLinkResearchStatus(link)
	if researchStatus then
		local armorType = GetItemLinkArmorType(link)
		local weaponType = GetItemLinkWeaponType(link)
		local equipType = GetItemLinkEquipType(link)
		local countBank = self:GetSameTraitCount(BAG_BANK, armorType, weaponType, equipType, traitType)
		local countPack = self:GetSameTraitCount(BAG_BACKPACK, armorType, weaponType, equipType, traitType)
		local countWorn = self:GetSameTraitCount(BAG_WORN, armorType, weaponType, equipType, traitType)
		researchColor, traitText = getTraitHeaderLine(researchStatus, countBank, countPack, countWorn)
		if traitText then
			tooltip:AddHeaderLine(traitText, "ZoFontWinT2", 2, TOOLTIP_HEADER_SIDE_RIGHT, researchColor:UnpackRGB())
		end
		researchStatus = tostring(TraitStatusStrings[researchStatus])
	end

	return hackTraitName(traitType, researchColor, researchStatus)
end

function HarvensTraitAndStyle:AddAltsResearchStatus(tooltip)
	if not self.altsResearchStatus or not g_savedVars.showAlts then
		return
	end
	local line = "Researchable for: "
	for i=1,#self.altsResearchStatus[TRAIT_RESEARCHABLE] do
		if i > 1 then
			line = line..", "
		end
		line = line..self.altsResearchStatus[TRAIT_RESEARCHABLE][i]
	end
	if #self.altsResearchStatus[TRAIT_RESEARCHABLE] > 0 then
		local color = ZO_HIGHLIGHT_TEXT
		if g_savedVars.colorizeTrait then
				color = COLOR_RED
		end
		tooltip:AddVerticalPadding(8)
		tooltip:AddLine(line, "ZoFontWinT2", color:UnpackRGB())
	end
end

--hooks

local function HarvensTraitAndStyle_SetAttachedMailItem(orgFunc, tooltip, mailId, attachmentIndex, ...)
	local link = GetAttachedItemLink(mailId, attachmentIndex)
	local unhackTraitName = HarvensTraitAndStyle:AddStyleFromLink(tooltip, link)
	orgFunc(tooltip, mailId, attachmentIndex, ...)
	HarvensTraitAndStyle:AddAltsResearchStatus(tooltip)
	unhackTraitName()
end

local function HarvensTraitAndStyle_SetBagItem(orgFunc, tooltip, bagId, slotIndex, ...)
	local unhackTraitName = HarvensTraitAndStyle:AddStyleFromBag(tooltip, bagId, slotIndex)
	orgFunc(tooltip, bagId, slotIndex, ...)
	HarvensTraitAndStyle:AddAltsResearchStatus(tooltip)
	unhackTraitName()
end

local function HarvensTraitAndStyle_SetBuybackItem(orgFunc, tooltip, index, ...)
	local link = GetBuybackItemLink(index)
	local unhackTraitName = HarvensTraitAndStyle:AddStyleFromLink(tooltip, link)
	orgFunc(tooltip, index, ...)
	HarvensTraitAndStyle:AddAltsResearchStatus(tooltip)
	unhackTraitName()
end

local function HarvensTraitAndStyle_SetLink(orgFunc, tooltip, link,...)
	local unhackTraitName = HarvensTraitAndStyle:AddStyleFromLink(tooltip, link)
	orgFunc(tooltip, link, ...)
	HarvensTraitAndStyle:AddAltsResearchStatus(tooltip)
	unhackTraitName()
end

local function HarvensTraitAndStyle_SetLootItem(orgFunc, tooltip, lootId)
	local link = GetLootItemLink(lootId)
	local unhackTraitName = HarvensTraitAndStyle:AddStyleFromLink(tooltip, link)
	orgFunc(tooltip, lootId)
	HarvensTraitAndStyle:AddAltsResearchStatus(tooltip)
	unhackTraitName()
end

local function HarvensTraitAndStyle_SetQuestReward(orgFunc, tooltip, index, ...)
	local link = GetQuestRewardItemLink(index)
	local unhackTraitName = HarvensTraitAndStyle:AddStyleFromLink(tooltip, link)
	orgFunc(tooltip, index, ...)
	HarvensTraitAndStyle:AddAltsResearchStatus(tooltip)
	unhackTraitName()
end

local function HarvensTraitAndStyle_SetTradeItem(orgFunc, tooltip, who, tradeIndex, ...)
	local link = GetTradeItemLink(who, tradeIndex, LINK_STYLE_DEFAULT)
	local unhackTraitName = HarvensTraitAndStyle:AddStyleFromLink(tooltip, link)
	orgFunc(tooltip, who, tradeIndex, ...)
	HarvensTraitAndStyle:AddAltsResearchStatus(tooltip)
	unhackTraitName()
end

local function HarvensTraitAndStyle_SetPendingSmithingItem(orgFunc, tooltip, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex, ...)
	local link = GetSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex, LINK_STYLE_DEFAULT)
	local unhackTraitName = HarvensTraitAndStyle:AddStyleFromLink(tooltip, link)
	orgFunc(tooltip, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex, ...)
	unhackTraitName()
end

local function HarvensTraitAndStyle_SetSmithingImprovementResult(orgFunc, tooltip, ...)
	local unhackTraitName = HarvensTraitAndStyle:AddStyleFromBag(tooltip, ...)
	orgFunc(tooltip, ...)
	HarvensTraitAndStyle:AddAltsResearchStatus(tooltip)
	unhackTraitName()
end

local function HarvensTraitAndStyle_SetStoreItem(orgFunc, tooltip, index)
	local link = GetStoreItemLink(index)
	local unhackTraitName = HarvensTraitAndStyle:AddStyleFromLink(tooltip, link)
	orgFunc(tooltip, index)
	HarvensTraitAndStyle:AddAltsResearchStatus(tooltip)
	unhackTraitName()
end

local function HarvensTraitAndStyle_SetTradingHouseItem(orgFunc, tooltip, index)
	local link = GetTradingHouseSearchResultItemLink(index)
	local unhackTraitName = HarvensTraitAndStyle:AddStyleFromLink(tooltip, link)
	orgFunc(tooltip, index)
	HarvensTraitAndStyle:AddAltsResearchStatus(tooltip)
	unhackTraitName()
end

local function HarvensTraitAndStyle_SetTradingHouseListing(orgFunc, tooltip, index)
	local link = GetTradingHouseListingItemLink(index)
	local unhackTraitName = HarvensTraitAndStyle:AddStyleFromLink(tooltip, link)
	orgFunc(tooltip, index)
	HarvensTraitAndStyle:AddAltsResearchStatus(tooltip)
	unhackTraitName()
end

local function HarvensTraitAndStyle_SetWornItem(orgFunc, tooltip, equipSlot, ...)
	local unhackTraitName = HarvensTraitAndStyle:AddStyleFromBag(tooltip, BAG_WORN, equipSlot)
	orgFunc(tooltip, equipSlot, ...)
	HarvensTraitAndStyle:AddAltsResearchStatus(tooltip)
	unhackTraitName()
end

local function HarvensTraitAndStyle_CTTOnAddGameData(tooltip, gameDataType, equipSlot, ...)
	if gameDataType == TOOLTIP_GAME_DATA_EQUIPPED_INFO then
		-- NoHack because trait name in comparative tooltip is filled somewhere else
		HarvensTraitAndStyle:AddStyleFromBagNoHack(tooltip, BAG_WORN, equipSlot)
	end
end

function HarvensTraitAndStyle:InitHooks()
	hookMethod(ItemTooltip, "SetAttachedMailItem", HarvensTraitAndStyle_SetAttachedMailItem)
	hookMethod(ItemTooltip, "SetBagItem", HarvensTraitAndStyle_SetBagItem)
	hookMethod(ItemTooltip, "SetBuybackItem", HarvensTraitAndStyle_SetBuybackItem)
	hookMethod(PopupTooltip, "SetLink", HarvensTraitAndStyle_SetLink)
	hookMethod(ItemTooltip, "SetLootItem", HarvensTraitAndStyle_SetLootItem)
	hookMethod(ZO_SmithingTopLevelCreationPanelResultTooltip, "SetPendingSmithingItem", HarvensTraitAndStyle_SetPendingSmithingItem)
	hookMethod(ZO_SmithingTopLevelImprovementPanelResultTooltip, "SetSmithingImprovementResult", HarvensTraitAndStyle_SetSmithingImprovementResult)
	hookMethod(ItemTooltip, "SetStoreItem", HarvensTraitAndStyle_SetStoreItem)
	hookMethod(ItemTooltip, "SetTradingHouseItem", HarvensTraitAndStyle_SetTradingHouseItem)
	hookMethod(ItemTooltip, "SetTradingHouseListing", HarvensTraitAndStyle_SetTradingHouseListing)
	hookMethod(ItemTooltip, "SetWornItem", HarvensTraitAndStyle_SetWornItem)
	hookMethod(ItemTooltip, "SetQuestReward", HarvensTraitAndStyle_SetQuestReward)
	hookMethod(ItemTooltip, "SetTradeItem", HarvensTraitAndStyle_SetTradeItem)
	
	ZO_PreHookHandler(ComparativeTooltip1, "OnAddGameData", HarvensTraitAndStyle_CTTOnAddGameData)
	ZO_PreHookHandler(ComparativeTooltip2, "OnAddGameData", HarvensTraitAndStyle_CTTOnAddGameData)

	self.tradeskillForItemType = {
		[ITEMTYPE_ARMOR] = {
			CRAFTING_TYPE_BLACKSMITHING,
			CRAFTING_TYPE_CLOTHIER,
			CRAFTING_TYPE_WOODWORKING,
		},
		[ITEMTYPE_WEAPON] = {
			CRAFTING_TYPE_BLACKSMITHING,
			CRAFTING_TYPE_WOODWORKING,
		}
	}

	self.tradeskillForArmorType = {
		[ARMORTYPE_LIGHT] = CRAFTING_TYPE_CLOTHIER,
		[ARMORTYPE_MEDIUM] = CRAFTING_TYPE_CLOTHIER,
		[ARMORTYPE_HEAVY] = CRAFTING_TYPE_BLACKSMITHING
	}

	self.tradeskillForWeaponType = {
		[WEAPONTYPE_AXE] = CRAFTING_TYPE_BLACKSMITHING,
		[WEAPONTYPE_HAMMER] = CRAFTING_TYPE_BLACKSMITHING,
		[WEAPONTYPE_SWORD] = CRAFTING_TYPE_BLACKSMITHING,
		[WEAPONTYPE_TWO_HANDED_SWORD] = CRAFTING_TYPE_BLACKSMITHING,
		[WEAPONTYPE_TWO_HANDED_AXE] = CRAFTING_TYPE_BLACKSMITHING,
		[WEAPONTYPE_TWO_HANDED_HAMMER] = CRAFTING_TYPE_BLACKSMITHING,
		[WEAPONTYPE_PROP] = CRAFTING_TYPE_INVALID, --what's that?
		[WEAPONTYPE_BOW] = CRAFTING_TYPE_WOODWORKING,
		[WEAPONTYPE_HEALING_STAFF] = CRAFTING_TYPE_WOODWORKING,
		[WEAPONTYPE_RUNE] = CRAFTING_TYPE_INVALID,
		[WEAPONTYPE_DAGGER] = CRAFTING_TYPE_BLACKSMITHING,
		[WEAPONTYPE_FIRE_STAFF] = CRAFTING_TYPE_WOODWORKING,
		[WEAPONTYPE_FROST_STAFF] = CRAFTING_TYPE_WOODWORKING,
		[WEAPONTYPE_SHIELD] = CRAFTING_TYPE_WOODWORKING,
		[WEAPONTYPE_LIGHTNING_STAFF] = CRAFTING_TYPE_WOODWORKING,
	}

	self.armorTypeAndEquipTypeToResearchLineIndex = {
		[ARMORTYPE_HEAVY] = {
			[EQUIP_TYPE_HEAD] = 11,
			[EQUIP_TYPE_CHEST] = 8,
			[EQUIP_TYPE_SHOULDERS] = 13,
			[EQUIP_TYPE_WAIST] = 14,
			[EQUIP_TYPE_LEGS] = 12,
			[EQUIP_TYPE_FEET] = 9,
			[EQUIP_TYPE_HAND] = 10,
		},
		[ARMORTYPE_LIGHT] = {
			[EQUIP_TYPE_HEAD] = 4,
			[EQUIP_TYPE_CHEST] = 1,
			[EQUIP_TYPE_SHOULDERS] = 6,
			[EQUIP_TYPE_WAIST] = 7,
			[EQUIP_TYPE_LEGS] = 5,
			[EQUIP_TYPE_FEET] = 2,
			[EQUIP_TYPE_HAND] = 3,
		},
		[ARMORTYPE_MEDIUM] = {
			[EQUIP_TYPE_HEAD] = 11,
			[EQUIP_TYPE_CHEST] = 8,
			[EQUIP_TYPE_SHOULDERS] = 13,
			[EQUIP_TYPE_WAIST] = 14,
			[EQUIP_TYPE_LEGS] = 12,
			[EQUIP_TYPE_FEET] = 9,
			[EQUIP_TYPE_HAND] = 10,
		},
	}

	self.weaponTypeToResearchLineIndex = {
		[WEAPONTYPE_AXE] = 1,
		[WEAPONTYPE_BOW] = 1,
		[WEAPONTYPE_DAGGER] = 7,
		[WEAPONTYPE_FIRE_STAFF] = 2,
		[WEAPONTYPE_FROST_STAFF] = 3,
		[WEAPONTYPE_HAMMER] = 2,
		[WEAPONTYPE_HEALING_STAFF] = 5,
		[WEAPONTYPE_LIGHTNING_STAFF] = 4,
		[WEAPONTYPE_PROP] = 0,
		[WEAPONTYPE_RUNE] = 0,
		[WEAPONTYPE_SHIELD] = 6,
		[WEAPONTYPE_SWORD] = 3,
		[WEAPONTYPE_TWO_HANDED_AXE] = 4,
		[WEAPONTYPE_TWO_HANDED_HAMMER] = 5,
		[WEAPONTYPE_TWO_HANDED_SWORD] = 6,
	}
end

--settings

function HarvensTraitAndStyle:InitSettings()
	local LibHarvensAddonSettings = LibStub("LibHarvensAddonSettings-1.0")
	if not LibHarvensAddonSettings then return end

	local settings = LibHarvensAddonSettings:AddAddon("Harven's Trait and Style")
	if not settings then return end

	settings:AddSetting{
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Colorize style name",
		tooltip = "Show style name in the color of the corresponding Motif book",
		getFunction = function() return g_savedVars.colorizeStyle end,
		setFunction = function(value) g_savedVars.colorizeStyle = value end,
	}

	settings:AddSetting{
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Colorize trait knowledge",
		tooltip = "Make 'Researchable' red and 'Researching...' orange",
		getFunction = function() return g_savedVars.colorizeTrait end,
		setFunction = function(value) g_savedVars.colorizeTrait = value end,
	}

	settings:AddSetting{
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Show trait knowledge in tooltip corner",
		tooltip = "Show trait Known/Researching/Researchable in tooltip's upper right corner",
		getFunction = function() return g_savedVars.showResearchInUpperRightCorner end,
		setFunction = function(value) g_savedVars.showResearchInUpperRightCorner = value end,
	}

	settings:AddSetting{
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Show duplicate items info",
		tooltip = "Adds information how many items of the same researchable trait you have",
		getFunction = function() return g_savedVars.duplicateItems end,
		setFunction = function(value) g_savedVars.duplicateItems = value end,
	}

	settings:AddSetting{
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Append trait knowledge to trait name",
		tooltip = "This feature is experimental, and may need to be disabled or removed if something goes wrong",
		getFunction = function() return g_savedVars.appendResearchToTraitName end,
		setFunction = function(value) g_savedVars.appendResearchToTraitName = value end,
	}
	
	settings:AddSetting{
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Show alts info",
		tooltip = "Shows another line in the item tooltip telling you which one of your other characters can research this item trait",
		getFunction = function() return g_savedVars.showAlts end,
		setFunction = function(value) g_savedVars.showAlts = value end,
	}
	
	settings:AddSetting{
		type = LibHarvensAddonSettings.ST_SECTION,
		label = "Select alts"
	}
	
	for k,v in pairs(g_savedVars.characters) do
		if k ~= self.unitName then
			settings:AddSetting{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = k,
				tooltip = "Shows trait knowledge for "..k,
				getFunction = function() 
					if g_savedVars[self.unitName][k] == null then
						g_savedVars[self.unitName][k] = true
					end
					return g_savedVars[self.unitName][k]
				end,
				setFunction = function(value) g_savedVars[self.unitName][k] = value end,
			}
		end
	end
end

--event handlers

local function HarvensTraitAndStyle_OnResearchCompleted(eventType, craftingSkillType, researchLineIndex, traitIndex)
	if not g_savedVars.characters[HarvensTraitAndStyle.unitName][craftingSkillType] then
		return
	end
	local traitType = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
	g_savedVars.characters[HarvensTraitAndStyle.unitName][craftingSkillType][researchLineIndex][traitType] = TRAIT_KNOWN
end

local function HarvensTraitAndStyle_OnResearchStarted(eventType, craftingSkillType, researchLineIndex, traitIndex)
	if not g_savedVars.characters[HarvensTraitAndStyle.unitName][craftingSkillType] then
		return
	end
	local traitType = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
	g_savedVars.characters[HarvensTraitAndStyle.unitName][craftingSkillType][researchLineIndex][traitType] = TRAIT_RESEARCH_IN_PROGRESS
end

local function HarvensTraitAndStyle_OnLoaded(eventType, addonName)
	if addonName ~= "HarvensTraitAndStyle" then return end

	if HarvensTraitAndStyle_SavedVariables then
		g_savedVars = HarvensTraitAndStyle_SavedVariables
	else
		HarvensTraitAndStyle_SavedVariables = g_savedVars
	end

	HarvensTraitAndStyle.unitName = zo_strformat("<<1>>", GetUnitName("player"))
	
	setValueIfNil(g_savedVars, "showResearchInUpperRightCorner", true)
	setValueIfNil(g_savedVars, "showAlts", true)
	setValueIfNil(g_savedVars, HarvensTraitAndStyle.unitName, {})	
	setValueIfNil(g_savedVars, "characters", {})
	
	HarvensTraitAndStyle:InitHooks()
	HarvensTraitAndStyle:InitSettings()
	
	g_savedVars.characters[HarvensTraitAndStyle.unitName] = {
		[CRAFTING_TYPE_BLACKSMITHING] = {},
		[CRAFTING_TYPE_WOODWORKING] = {},
		[CRAFTING_TYPE_CLOTHIER] = {},		
	}
	
	for k,v in pairs(g_savedVars.characters[HarvensTraitAndStyle.unitName]) do
		for i=1, GetNumSmithingResearchLines(k) do
			local _,_, numTraits = GetSmithingResearchLineInfo(k, i)
			for t=1, numTraits do
				local traitType, _, known = GetSmithingResearchLineTraitInfo(k, i, t)
				setValueIfNil(g_savedVars.characters[HarvensTraitAndStyle.unitName][k], i, {})
				if known then
					g_savedVars.characters[HarvensTraitAndStyle.unitName][k][i][traitType] = TRAIT_KNOWN
				else
					local dur, remainig = GetSmithingResearchLineTraitTimes(k, i, t)
					if dur and remainig then
						g_savedVars.characters[HarvensTraitAndStyle.unitName][k][i][traitType] = TRAIT_RESEARCH_IN_PROGRESS
					else
						g_savedVars.characters[HarvensTraitAndStyle.unitName][k][i][traitType] = TRAIT_RESEARCHABLE
					end
				end
			end
		end
	end
	
	ZO_TOOLTIP_STYLES.harvensTraitAndStyle = {
		paddingTop = 30,
		paddingBottom = -30,
		customSpacing = 0,
		layoutPrimaryDirection = "right",
		layoutSecondaryDirection = "down",
		widthPercent = 100,
		fontSize = "$(GP_27)",
		uppercase = true,
	}

	local oldCallback = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP).AddTopLinesToTopSection
	GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP).AddTopLinesToTopSection = function(control, topSection, itemLink, ...)
		local itemStyle = GetItemLinkItemStyle(itemLink)
		if itemStyle ~= ITEMSTYLE_NONE then
			local styleColor, styleText = getStyleHeaderLine(itemStyle)
			
			styleText = styleColor:Colorize(styleText)
			
			local traitType = GetItemLinkTraitInfo(itemLink)
			local researchColor = nil
			local researchStatus = HarvensTraitAndStyle:GetItemLinkResearchStatus(itemLink)
			if researchStatus then
				local armorType = GetItemLinkArmorType(itemLink)
				local weaponType = GetItemLinkWeaponType(itemLink)
				local equipType = GetItemLinkEquipType(itemLink)
				local countBank = HarvensTraitAndStyle:GetSameTraitCount(BAG_BANK, armorType, weaponType, equipType, traitType)
				local countPack = HarvensTraitAndStyle:GetSameTraitCount(BAG_BACKPACK, armorType, weaponType, equipType, traitType)
				local countWorn = HarvensTraitAndStyle:GetSameTraitCount(BAG_WORN, armorType, weaponType, equipType, traitType)
				researchColor, traitText = getTraitHeaderLine(researchStatus, countBank, countPack, countWorn)
				if traitText then
					traitText = researchColor:Colorize(traitText)
					styleText = styleText.." "..traitText
				end
			end
			
			local styleLine = control:AcquireSection(control:GetStyle("harvensTraitAndStyle"))
			styleLine:AddLine(styleText)
			control:AddSection(styleLine)
		end
		local ret = oldCallback(control, topSection, itemLink, ...)
		return ret
	end
--[[
	local oldCallback2 = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP).AddTopLinesToTopSection
	GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP).AddTopLinesToTopSection = function(control, topSection, itemLink,...)
		topSection:AddLine()
		local ret = oldCallback2(control, topSection, itemLink, ...)
		return ret
	end
--]]	
	EVENT_MANAGER:RegisterForEvent("HarvensTraitAndStyleResearchCompleted", EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, HarvensTraitAndStyle_OnResearchCompleted)
	EVENT_MANAGER:RegisterForEvent("HarvensTraitAndStyleResearchStarted", EVENT_SMITHING_TRAIT_RESEARCH_STARTED, HarvensTraitAndStyle_OnResearchStarted)
end

EVENT_MANAGER:RegisterForEvent("HarvensTraitAndStyleOnLoaded", EVENT_ADD_ON_LOADED, HarvensTraitAndStyle_OnLoaded)
