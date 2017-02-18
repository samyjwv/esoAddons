local IIfA = IIfA

function IIfA:DeleteCharacterData(name)
	if (name) then
		--delete selected character
		for characterName, character in pairs(IIfA.data.accountCharacters) do
			if(characterName == name) then
				IIfA.data.accountCharacters[name] = nil
			end
		end
	end
end

function IIfA:DeleteGuildData(name)
	if (name) then
		--delete selected guild
		for guildName, guild in pairs(IIfA.data.guildBanks) do
			if guildName == name then
				IIfA.data.guildBanks[name] = nil
			end
        end
	end
end

function IIfA:CollectGuildBank()
	local DBv2 = IIfA.data.DBv2
	if(not DBv2)then
		IIfA.data.DBv2 = {}
		DBv2 = IIfA.data.DBv2
	end

	if not IIfA.data.bCollectGuildBankData then
		return
	end

	IIfA:DebugOut("Collecting Guild Bank Data")

	if not IIfA.data.guildBanks then IIfA.data.guildBanks = {} end
	local curGuild = GetGuildName(GetSelectedGuildBankId())

	if IIfA.data.guildBanks[curGuild] ~= nil then
		if not IIfA.data.guildBanks[curGuild].bCollectData then
			return
		end
	end

	SelectGuildBank(GetSelectedGuildBankId())
	local count = 0

	if(IIfA.data.guildBanks[curGuild] == nil) then
		IIfA.data.guildBanks[curGuild] = {}
		IIfA.data.guildBanks[curGuild].bCollectData = true		-- default to true just so it's here and ok
	end
	local guildData = IIfA.data.guildBanks[curGuild]
	guildData.items = #ZO_GuildBankBackpack.data
	guildData.lastCollected = GetDate() .. "@" .. GetFormattedTime();
	IIfA:ResetLocationCount(curGuild)
	for i=1, #ZO_GuildBankBackpack.data do
		local slotIndex = ZO_GuildBankBackpack.data[i].data.slotIndex
		IIfA:EvalBagItem(BAG_GUILDBANK, slotIndex)
	end
--	d("IIfA - Guild Bank Collected - " .. curGuild)
end


function IIfA:CheckForAgedGuildBankData( days )
	local results = false
	local days = days or 5
	if IIfA.data.bCollectGuildBankData then
		IIfA:CleanEmptyGuildBug()
		for guildName, guildData in pairs(IIfA.data.guildBanks)do
			local today = GetDate()
			local lastCollected = guildData.lastCollected:match('(........)')
			if(lastCollected and lastCollected ~= "")then
				if(today - lastCollected >= days)then
					d("[IIfA]:Warning - " .. guildName .. " Guild Bank data not collected in " .. days .. " or more days!")
					results = true
				end
			else
				d("[IIfA]:Warning - " .. guildName .. " Guild Bank data has not been collected!")
				results = true
			end
		end
		return results
	end
	return true
end

function IIfA:UpdateGuildBankData()
	if IIfA.data.bCollectGuildBankData then
		local tempGuildBankBag = {
			items = 0;
			lastCollected = "";
		}
		for index=1, GetNumGuilds() do
			local guildName = GetGuildName(index)
			local guildBank = IIfA.data.guildBanks[guildName]
			if(not guildBank) then
				IIfA.data.guildBanks[guildName] = tempGuildBankBag
			end
		end
	end
end

function IIfA:CleanEmptyGuildBug()
	local emptyGuild = IIfA.data.guildBanks[""]
	if(emptyGuild)then
		IIfA.data.guildBanks[""] = nil
	end
end

function IIfA:GuildBankReady()
	IIfA:DebugOut("GuildBankReady...")
	IIfA.isGuildBankReady = false
	IIfA:UpdateGuildBankData()
	IIfA:CleanEmptyGuildBug()
	IIfA:CollectGuildBank()
end

function IIfA:GuildBankDelayReady()
	IIfA:DebugOut("GuildBankDelayReady...")
	if not IIfA.isGuildBankReady then
		IIfA.isGuildBankReady = true
		zo_callLater(function() IIfA:GuildBankReady() end, 1500)
	end
end

function IIfA:GuildBankAddRemove()
	IIfA:DebugOut("Guild Bank Add or Remove...")
	IIfA:UpdateGuildBankData()
	IIfA:CleanEmptyGuildBug()
	IIfA:CollectGuildBank()
end

function IIfA:ActionLayerInventoryUpdate()
	IIfA:CollectAll()
end


--[[
Data collection notes:
	Currently crafting items are coming back from getitemlink with level info in them.
	If it's a crafting item, strip the level info and store only the item number as the itemKey
	Use function GetItemCraftingInfo, if usedInCraftingType indicates it's NOT a material, check for other item types

	When showing items in tooltips, check for both stolen & owned, show both
--]]


-- used by an event function - see iifaevents.lua for call
function IIfA:InventorySlotUpdate(eventCode, bagId, slotNum, isNewItem, itemSoundCategory, inventoryUpdateReason, qty)

-- when item leaves and slot is empty, no way to get link code
-- d(GetItemLink(bagId, slotNum, LINK_STYLE_NORMAL) .. "," .. eventCode .. ", " .. bagId .. ", " .. slotNum .. ", " .. inventoryUpdateReason .. ", " .. qty)

--	if bagId == BAG_VIRTUAL then -- we only need to do that if the crafting bag is accessed
		-- d("========================")
		-- d("InventorySlotUpdate called: " .. GetItemLink(bagId, slotNum))
--		IIfA:UpdateDatabaseItem(bagId, slotNum, true)
		self:EvalBagItem(bagId, slotNum)
--	end
end


local function GetBagIdFrom(itemLink)
	local stackCountBackpack, stackCountBank, stackCountCraftBag = GetItemLinkStacks(itemLink)

	if stackCountBank and stackCountBank > 0 then return BAG_BANK end
	if stackCountBackpack and stackCountBackpack > 0 then return BAG_BACKPACK end
	if stackCountCraftBag and stackCountCraftBag > 0 then return BAG_VIRTUAL end
	return BAG_WORN

end

local function assertValue(value, itemLink, getFunc)
	if value then return value end
	if getFunc == "" then return "" end
	return getFunc(itemLink)
end

local function getItemIntelFrom(itemLink)

	local filterType, 	itemType, 		weaponType, armorType, itemName  	= nil
	local iconFile, 	equipType, 	itemStyle, itemQuality  = nil

	local dbItemAttribs = IIfA.data.DBv2[itemLink]["attributes"]

	itemName = 		dbItemAttribs["itemName"] 		or GetItemLinkName(itemLink)
	filterType = 	dbItemAttribs["filterType"]  	or GetItemLinkName(itemLink)
	itemType = 		dbItemAttribs["itemType"]      	or GetItemLinkName(itemLink)
	weaponType = 	dbItemAttribs["weaponType"]    	or GetItemLinkName(itemLink)
	armorType = 	dbItemAttribs["armorType"]     	or GetItemLinkName(itemLink)

	return itemName, filterType, itemType, weaponType, armorType
end

local function IIfA_assertItemLink(itemLink, bagId, slotIndex)

	if itemLink ~= nil then
		return itemLink
	else
		if (bagId ~= nil and slotIndex ~= nil) then
			return GetItemLink(tonumber(bagId), tonumber(slotIndex))
		end
	end

	return nil
end

local function setItemFileEntry(array, key, value)

	if not value then return end
	if not array then return end
	if not array[key] then array[key] = {} end

	array[key] = value

end

function IIfA:GetItemCount(itemLink, bagId, slotIndex)

	if not bagId then
		bagId = GetBagIdFrom(itemLink)
	end
	local stackCountBackpack, stackCountBank, stackCountCraftBag = GetItemLinkStacks(itemLink)

	if bagId == BAG_BACKPACK then
		return stackCountBackpack
	elseif bagId == BAG_BANK then
		return stackCountBank
	elseif bagId == BAG_VIRTUAL then
		return stackCountCraftBag
	elseif bagId == BAG_WORN then
		return 1
	end
end

function IIfA:GetLocationIntel(itemLink, bagId, slotIndex)

	local location, localBagID = nil
	local worn = false

	if not bagId then
		bagId = GetBagIdFrom(itemLink)
	end
	if (bagId == BAG_WORN) then
		location = IIfA.currentCharacterId
		worn = true
	elseif (bagId ~= nil) then
		if (bagId == BAG_BACKPACK) then
			location = IIfA.currentCharacterId
		elseif (bagId == BAG_VIRTUAL) then
			location = "CraftingBag"
		else
			location = "Bank"
		end
	end

	localBagID = bagId

	return location, localBagID, worn

end

function IIfA:GetItemIntel(itemLink, bagId, slotIndex)

	if not itemLink and not bagId and not slotIndex then return end

	local itemName, filterType, itemType, weaponType, armorType	= nil

	if (bagId ~= nil and slotIndex ~= nil) then
		itemName 							= GetItemName(bagId, slotIndex)
		filterType 					 		= GetItemFilterTypeInfo(bagId, slotIndex)
		itemType 							= GetItemType(bagId, slotIndex)
		weaponType 					 		= GetItemWeaponType(bagId, slotIndex)
        armorType 					 		= GetItemArmorType(bagId, slotIndex)
	elseif itemLink then
		-- only call ZOS functions if we don't hold the values ourselves
		itemName, filterType,
		itemType, weaponType, armorType		= getItemIntelFrom(itemLink)
	end

	return itemName, filterType, itemType, weaponType, armorType

end

--[[
function IIfA:UpdateDatabaseItem(bagId, slotIndex, calledFromStorePCI)

	if bagId == nil then return end
	if slotIndex == nil then return end

	local itemLink = GetItemLink(bagId, slotIndex)

	if (itemLink == nil) or (itemLink == "") then return end
	local DBv2 = IIfA.data.DBv2

	local location, localBagID, worn = IIfA:GetLocationIntel(itemLink, bagId, slotIndex)

	if not IIfA.data.DBv2[itemLink] then
		IIfA.data.DBv2[itemLink] = {}
		IIfA.data.DBv2[itemLink]["attributes"] = {}

--		local location, localBagID, worn = IIfA:GetLocationIntel(itemLink, bagId, slotIndex)
		if location then
			IIfA.data.DBv2[itemLink][location] = {}
			IIfA.data.DBv2[itemLink][location].worn = worn
			IIfA.data.DBv2[itemLink][location].bagID = localBagID
--			setItemFileEntry(IIfA.data.DBv2[itemLink][location], "bagID", localBagID)
		end
	end

	local dbItem = IIfA.data.DBv2[itemLink]
	if not dbItem then return end
	dbItem["attributes"]["itemLink"] = itemLink

	local itemName, filterType, itemType, weaponType, armorType = IIfA:GetItemIntel(itemLink, bagId, slotIndex)
	local itemCount = IIfA:GetItemCount(itemLink, bagId, slotIndex)
	local iconFile, _, _, equipType, itemStyle = GetItemLinkInfo(itemLink)
	local itemQuality = GetItemLinkQuality(itemLink)

	if location ~= nil then
		if (dbItem[location] == nil) then
			dbItem[location] = {}
		end
		setItemFileEntry(dbItem[location], "itemCount", 	itemCount)
		setItemFileEntry(dbItem[location], "worn", 			worn)
		setItemFileEntry(dbItem[location], "bagID", 		localBagID)
		setItemFileEntry(dbItem[location], "slotIndex", 	slotIndex)
	end

	setItemFileEntry(dbItem["attributes"], "itemName", 		itemName)
	setItemFileEntry(dbItem["attributes"], "filterType", 	filterType)
	setItemFileEntry(dbItem["attributes"], "itemType", 		itemType)
	setItemFileEntry(dbItem["attributes"], "weaponType", 	weaponType)
	setItemFileEntry(dbItem["attributes"], "armorType", 	armorType)

	setItemFileEntry(dbItem["attributes"], "iconFile", 		iconFile)
	setItemFileEntry(dbItem["attributes"], "itemStyle", 	itemStyle)
	setItemFileEntry(dbItem["attributes"], "itemQuality", 	itemQuality)

	if (not DBv2[itemLink]) then
		if calledFromStorePCI then
			d("That should not have happened!")
		end
		return false
	end

end
--]]

function IIfA:EvalBagItem(bagId, slotNum)
	local DBv2 = IIfA.data.DBv2
	if(not DBv2)then
		IIfA.data.DBv2 = {}
		DBv2 = IIfA.data.DBv2
	end
	itemName = GetItemName(bagId, slotNum)
	if itemName > '' then
		itemLink = GetItemLink(bagId, slotNum, LINK_STYLE_BRACKETS)
		itemKey = itemLink
		local usedInCraftingType, itemType, extraInfo1, extraInfo2, extraInfo3 = GetItemCraftingInfo(bagId, slotNum)

--if usedInCraftingType > 0 then
--	d(itemName .. ", " .. usedInCraftingType .. ", " .. itemType)
--end

		if usedInCraftingType ~= CRAFTING_TYPE_INVALID and
		   itemType ~= ITEMTYPE_GLYPH_ARMOR and
		   itemType ~= ITEMTYPE_GLYPH_JEWELRY and
		   itemType ~= ITEMTYPE_GLYPH_WEAPON then
		   itemKey = IIfA:GetItemID(itemLink)
		else
			itemType = GetItemLinkItemType(itemLink)
			if  itemType == ITEMTYPE_STYLE_MATERIAL or
				itemType == ITEMTYPE_ARMOR_TRAIT or
				itemType == ITEMTYPE_WEAPON_TRAIT or
				itemType == ITEMTYPE_LOCKPICK or
				itemType == ITEMTYPE_RAW_MATERIAL or
				itemType == ITEMTYPE_RACIAL_STYLE_MOTIF or		-- 9-12-16 AM - added because motifs now appear to have level info in them
				itemType == ITEMTYPE_RECIPE then
				itemKey = IIfA:GetItemID(itemLink)
			end
		end

		local itemIconFile, itemCount, _, _, _, equipType, _, itemQuality = GetItemInfo(bagId, slotNum)
		itemFilterType = GetItemFilterTypeInfo(bagId, slotNum) or 0
		DBitem = DBv2[itemKey]
		location = ""
		if(equipType == 0 or bagId ~= BAG_WORN) then equipType = false end
		if(bagId == BAG_BACKPACK or bagId == BAG_WORN) then
			location = IIfA.currentCharacterId
		elseif(bagId == BAG_BANK) then
			location = "Bank"
		elseif(bagId == BAG_VIRTUAL) then
			location = "CraftBag"
		elseif(bagId == BAG_GUILDBANK) then
			location = GetGuildName(GetSelectedGuildBankId())
		end
		if(DBitem) then
			DBitemlocation = DBitem[location]
			if DBitemlocation then
				DBitemlocation.itemCount = DBitemlocation.itemCount + itemCount
				if DBitemlocation.bagSlot == nil then
					DBitemlocation.bagSlot = slotNum
				end
			else
				DBitem[location] = {}
				DBitem[location].bagID = bagId
				DBitem[location].itemCount = itemCount
				DBitem[location].bagSlot = slotNum
			end
		else
			DBv2[itemKey] = {}
			DBv2[itemKey].attributes ={}
			DBv2[itemKey].attributes.iconFile = itemIconFile
			DBv2[itemKey].attributes.filterType = itemFilterType
			DBv2[itemKey].attributes.itemQuality = itemQuality
			DBv2[itemKey].attributes.itemName = itemName
			DBv2[itemKey][location] = {}
			DBv2[itemKey][location].bagID = bagId
			DBv2[itemKey][location].bagSlot = slotNum
			DBv2[itemKey][location].itemCount = itemCount
		end
		if zo_strlen(itemKey) < 10 then
			DBv2[itemKey].attributes.itemLink = itemLink
		end
	end
end


function IIfA:CollectAll()
	local DBv2 = IIfA.data.DBv2
	if(not DBv2)then
		IIfA.data.DBv2 = {}
		DBv2 = IIfA.data.DBv2
	end

	local bagItems = nil
	local itemLink, dbItem = nil
	local itemKey
	local location = ""
	local BagList = {BAG_WORN, BAG_BACKPACK, BAG_BANK, BAG_VIRTUAL}

	for idx, bagId in ipairs(BagList) do
		bagItems = GetBagSize and GetBagSize(bagId)
		if(bagId == BAG_WORN)then	--location for BAG_BACKPACK and BAG_WORN is the same so only reset once
			IIfA:ResetLocationCount(IIfA.currentCharacterId)
		elseif(bagId == BAG_BANK)then
			IIfA:ResetLocationCount("Bank")
		elseif(bagId == BAG_VIRTUAL)then
			IIfA:ResetLocationCount("CraftBag")
		end
--		d("  BagItemCount=" .. bagItems)
		if bagId ~= BAG_VIRTUAL then
			for slotNum=0, bagItems, 1 do
				IIfA:EvalBagItem(bagId, slotNum)
			end
		else
			if HasCraftBagAccess() then
				slotNum = GetNextVirtualBagSlotId(nil)
				while slotNum ~= nil do
					IIfA:EvalBagItem(bagId, slotNum)
					slotNum = GetNextVirtualBagSlotId(slotNum)
				end
			end
		end

	end

-- 2015-3-7 Assembler Maniac - new code added to go through full inventory list, remove any un-owned items
	local n
	for itemLink, DBItem in pairs(DBv2) do
		n = 0
		for ItemOwner, ItemData in pairs(DBItem) do
			n = n + 1
			if ItemOwner ~= "Bank" and ItemOwner ~= "attributes" and ItemOwner ~= "CraftBag" then
				if ItemData.bagID == BAG_BACKPACK or ItemData.bagID == BAG_WORN then
					if IIfA.CharIdToName[ItemOwner] == nil then
						DBItem[ItemOwner] = nil
	  				end
				elseif ItemData.bagID == BAG_GUILDBANK then
					if IIfA.data.guildBanks[ItemOwner] == nil then
						DBItem[ItemOwner] = nil
					end
				end
			end
		end
		if (n == 1) then
			DBv2[itemLink] = nil
		end
	end
-- 2015-3-7 end of addition
end



function IIfA:ResetLocationCount(location)
	local DBv2 = IIfA.data.DBv2
	local itemLocation = nil
	local LocationCount = 0

	if(DBv2)then
		for itemName, slotIndex in pairs(IIfA.data.DBv2 ) do
			itemLocation = slotIndex[location]
			if(itemLocation)then
				slotIndex[location] = nil
			end
			LocationCount = 0
			for locationName, location in pairs(slotIndex) do
				if(locationName ~= "filterType") then
					LocationCount = LocationCount + 1
					break
				end
			end
			if(LocationCount == 0)then
				DBv2[itemName] = nil
			end
		end
	end
end

-- rewrite item links with proper level value in them, instead of random value based on who knows what
-- written by SirInsidiator
local function RewriteItemLink(itemLink)
    local requiredLevel = select(6, ZO_LinkHandler_ParseLink(itemLink))
    requiredLevel = tonumber(requiredLevel)
    local trueRequiredLevel = GetItemLinkRequiredLevel(itemLink)

    itemLink = string.gsub(itemLink, "|H(%d):item:(.*)" , "|H0:item:%2")

    if requiredLevel ~= trueRequiredLevel then
        itemLink = string.gsub(itemLink, "|H0:item:(%d+):(%d+):(%d+)(.*)" , "|H0:item:%1:%2:".. trueRequiredLevel .."%4")
    end

    return itemLink
end

local function GetItemIdentifier(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    local data = {zo_strsplit(":", itemLink:match("|H(.-)|h.-|h"))}
    local itemId = data[3]
    local level = GetItemLinkRequiredLevel(itemLink)
    local cp = GetItemLinkRequiredChampionPoints(itemLink)
--	local results
--	results.itemId = itemId
--	results.itemType = itemType
--	results.level = level
--	results.cp = cp
    if(itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR) then
        local trait = GetItemLinkTraitInfo(itemLink)
        return string.format("%s,%s,%d,%d,%d", itemId, data[4], trait, level, cp)
    elseif(itemType == ITEMTYPE_POISON or itemType == ITEMTYPE_POTION) then
        return string.format("%s,%d,%d,%s", itemId, level, cp, data[23])
    elseif(hasDifferentQualities[itemType]) then
        return string.format("%s,%s", itemId, data[4])
    else
        return itemId
    end
end

function IIfA:RenameItems()
	local DBv2 = IIfA.data.DBv2
	local item = nil
	local itemName

	if(DBv2)then
		for item, itemData in pairs(DBv2) do
			itemName = nil
			if item:match("|H") then
				itemName = GetItemLinkName(item)
			else
				itemName = GetItemLinkName(itemData.attributes.itemLink)
			end
			if itemName ~= nil then
				itemData.attributes.itemName = itemName
			end
		end
	end
end

