--[[
Created by: Adalan@Aruntas
Support, Fixes, Improvements by:


--]]

----------------------------------------
--- Contact me, before u make changes
--- or want to use code of this addon
---
--- at www.esoui.com                   
----------------------------------------
local bLockpickSuccessful = true
local iFreeSpaceLeft = 0
local bShowFenceSellLimitAgain = false
local bShowFenceTransferLimitAgain = false
local bFenceValuesUpdated = false
local bInSneak = false
local gPlayerChar = "unknown"
local scrollList = nil

local _EventList = {}
_EventList.timeSeconds = nil
_EventList.duration = nil
_EventList.eventName = nil
_EventList.message = nil

MasterThief = {}
-----------------------------------------
MasterThief.name = "MasterThief"
MasterThief.version = "1.56"
MasterThief.author = "Adalan@Aruntas"

-- special items
MasterThief.ItemTypes =
{
	ITEMTYPE_RACIAL_STYLE_MOTIF,
	ITEMTYPE_RECIPE,
}

-- see translation files
MasterThief.RecipeQualities =
{
	GetString(MT_RECIPE_COLOR_GREEN),
	GetString(MT_RECIPE_COLOR_BLUE),
	GetString(MT_RECIPE_COLOR_EPIC),
}

-- default values for saved variables
----------------------------------------- 
MasterThief.OptionsDefault = 
{
	--Activate/DeActivate all addon-functions
	MasterThiefActive = true,
	--Enable/Disable steal-functions on sneak-mode
	SneakModeActive = true,
	--Turn on/off Messagebox to move
	MoveMsgbox = false,	
	--Announce specials as OnScreen-Messages (recipes and motifs)
	SpecialOnScreenMsg = true,	
	--Announce specials as Chat-Message (recipes and motifs)
	SpecialChatMsg = true,		
	--Announce regular message as Chat-Message
	RegularChatMsg = true,
	--Announce useless items as Chat-Message (on pickpocking only)
	AnnounceUselessItem = false,
	--MessageBox delay
	MessageBoxDelay = 2000,
	--WindowPosition
	left = 100,
	top = 100,
	-- min. free slots left till warning
	MinFreeSlots = 1,
	-- min sell price to auto steal an item into the bag
	MinSellPrice = 30,
	-- Announce BE CAREFUL every time you are not far enough from your destination
	AnnounceBeCareful = true,
	-- Set the minimum quality level of a recipe to get autolooted. Unknown recipes below the given level will still be autolooted
	MinRecipeQuality = 2,
	-- Announce already known recipes on chat
	AnnounceKnownRecipes = true,
	-- Announce items sells or transfers at fence on chat
	AnnounceSellsTransfers = true,
	-- Announce max fence sell/transfer limits
	AnnounceMaxFencerLimits = false,
	-- to remember, what was set in SYSTEM-SETTING for stolen items (not used in own menu-options)
	SYSTEM_AutolootStolenItems = "",
	-- exclude this char on recipe compares (just the other chars)
	compareMyRecipes = true,
	-- loot all known recipes below set quality level
	LootUnknownRecipesBelowLevel = false,
	-- enable disable autoloot by lootlist
	lootlist = true,
}

MasterThief.StolenValuesDefault = 
{
	-- stolen gold sold at fencer
	stolenValuesTotal = 0,
	-- paid bounty total
	paidBountyTotal = 0,
}

MasterThief.KnownRecipes = {}
MasterThief.LootlistItems = {}
MasterThief.LootlistItems.Wortfhul = {}
local scrollListData = {}
----------------------------------------- 
-- Initialize
function MasterThief:Initialize()
	--set default or load SavedVariables
	MasterThief.SavedVarsValues = ZO_SavedVars:New("MasterThiefVars", 1, "Values", MasterThief.StolenValuesDefault)
	MasterThief.SavedVarsOptions = ZO_SavedVars:New("MasterThiefVars", 1, "Options", MasterThief.OptionsDefault)
	MasterThief.SavedVarsLoots = ZO_SavedVars:New("MasterThiefLoot", 1, nil, MasterThief.LootlistItems.Wortfhul)
	MasterThief.AccountSavedVariables = ZO_SavedVars:NewAccountWide("MasterThiefVars", 1, nil, MasterThief.KnownRecipes)

	
    --register keybindings
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_ONOFF", GetString(MT_BIND_ONOFF_TEXT))
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_SNEAKMODE", GetString(MT_BIND_TOGGLE_SNEAKMODE_TEXT))	
	ZO_CreateStringId("SI_BINDING_NAME_SHOW_STATISTICS", GetString(MT_BIND_SHOW_STATISTIC_TEXT))
	ZO_CreateStringId("SI_BINDING_NAME_LIST_JUNK", GetString(MT_BIND_SHOW_USELESS_TEXT))
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_ATTACK_INNOCENTS", GetString(MT_BIND_TOGGLE_ATTACK_INNOCENTS_TEXT))
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_LOOTLIST", GetString(MT_BIND_TOGGLE_LOOTLIST_TEXT))

	EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_PLAYER_ACTIVATED, function()
		-- start preHooks (context-menu etc)
		ZO_PreHook("ZO_InventorySlot_ShowContextMenu", MasterThief.CreateContextMenuEntry)
		--MessageBox position
		MasterThief:RestorePosition()	
		--Load AddOn Menu
		MasterThief:CreateSettingsMenu()
		--get stolen gold from saved vars
		stolenTotal = MasterThief.SavedVarsValues.stolenValuesTotal

		--Activate events, if settings does allow it
		MasterThief:SetEvents()

		local stealthState = GetUnitStealthState("player")
		if (MasterThief.SavedVarsOptions.MasterThiefActive and MasterThief.SavedVarsOptions.SneakModeActive) then
			if (stealthState == 3) then
				--already in stealth (but param is FALSE for toggling there, thats why i need FALSE to get into)
				bInSneak = false
			else
				--actually not in stealth (but param is TRUE for toggling there, thats why i need TRUE to get into)
				bInSneak = true
			end
			MasterThief:SetStealMode(stealthState)
		end
		
		gPlayerChar = GetUnitName("player")
		MasterThief:SaveKnownRecipes(nil, false)
		
		MasterThief:InventarTooltip()
		MasterThief:LootTooltip()
		-- learn new recipes if any for SavedVars
		EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_RECIPE_LEARNED, MasterThief.RecipeLearned)
		EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_PLAYER_ACTIVATED)
		--d("Bekannte Rezepte: "..table.getn(MasterThief.AccountSavedVariables.KnownRecipes))
		libScroll = LibStub:GetLibrary("LibScroll")
		scrollList = MasterThief:CreateScrollList()
		
		-- if table got nil, create a true empty table
		if (MasterThief.SavedVarsLoots.Wortfhul == nil) then
			MasterThief.SavedVarsLoots.Wortfhul = {}
		end
		
		-- read all saved wortful items fom SavedVariables into ScrollList
		for idx, obj in ipairs(MasterThief.SavedVarsLoots.Wortfhul) do
			table.insert(scrollListData, {obj[1]}) -- obj1=lootlink				
		end
		scrollList:Update(scrollListData)
	end)
end

------------------------------------------------------------------------------------
--- Direkt calls by events - START
----------------------------------
function MasterThief:UpdatedSlot(eventCode, iBagId, iSlotId, bNewItem, UpdateReason)
	--
	-- This is for pickpocking, which also do update the slot
	-- Just checking, whether an item is stolen, useless or special item which depends on settings (no destroy routines used)
	--
	-- Make sure, that its just and only a STOLEN ITEM, the CORRECT BAG and NORMAL INVENTORY UPDATE - if not, then return
	-- this is important, because if you use destroy routines in here it must be carefully handled
	-- At the moment it is used by a keybind function with double-opt-in to do it with a command (see MasterThief:DestroyUselessItems)
	--
	local _, iStack, iSellPrice, _, _, _, _, iQuality = GetItemInfo(iBagId, iSlotId) 
	local itemLink = GetItemLink(iBagId, iSlotId, LINK_STYLE_DEFAULT)
	local itemType = GetItemLinkItemType(itemLink)
	
	-- check about if its a stolen item, which we want here
	if (IsItemStolen(iBagId, iSlotId)) then -- did it double here for later use
		-- check for special item found and announce it
		local bSpecialItem = MasterThief:fCheckItemType(itemType)
		if (bSpecialItem) then
			MasterThief:ShowMessage(MasterThief:FixLinkName(itemLink),0)
		-- check for useless item found and announce it
		elseif (MasterThief:IsStolenItemUseless(itemType, iSellPrice) and MasterThief.SavedVarsOptions.AnnounceUselessItem) then 
			MasterThief:ShowMessage(GetString(MT_MISC_TRASH_TEXT)..MasterThief:FixLinkName(itemLink),1)
		end
		MasterThief:CheckFreeSlots()
		MasterThief:CheckMaxFenceLimit()
	end
end

-------------------------------------------------------------------------
-- this is for looting items out of wardrobes, cabinets or misc containers before you steal it
function MasterThief:LootUpdated()
	local iNumLootItems = GetNumLootItems()

	if (bLockpickSuccessful) then
		--LootMoney() -- do raise the LOOT-MONEY-UPDATED-EVENT. If its ID is 62, its stolen gold
		bLockpickSuccessful = false
	end
	
	LootMoney()
	for iLootIndex = 1, iNumLootItems do
		local iInstancedLootId, sName, icIcon, iCount, iQuality  = GetLootItemInfo(iLootIndex)
		local itemLootLink = GetLootItemLink(iInstancedLootId, LINK_STYLE_DEFAULT)
	    local _, iSellPrice = GetItemLinkInfo(itemLootLink)
		local itemType = GetItemLinkItemType(itemLootLink)

		if IsItemLinkStolen(itemLootLink) then
			--d(itemLootLink)
			if (MasterThief:isWortfulItemOnScrollList(itemLootLink) == true and MasterThief.SavedVarsOptions.lootlist == true) then
				LootItemById(iInstancedLootId)
			end			
			
			local bSpecialItem = MasterThief:fCheckItemType(itemType)
			if (bSpecialItem) then
				-- checkout, if its a recipe we want to loot or not
				if (itemType == ITEMTYPE_RECIPE) then 
					MasterThief:DoActionLootItemRecipe(sName, iQuality, iInstancedLootId, itemLootLink)
				else -- it is not a recipe - must be a valuable motif (or if defined, another nice item we want to steal)
					LootItemById(iInstancedLootId) 
				end
				-- else loot item by price limiter
			elseif MasterThief:IsSellPriceOk(iSellPrice) then
				LootItemById(iInstancedLootId)
			end
		end
	end
end


function MasterThief.FenceOpened(_EventCode)
	EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_SELL_RECEIPT, function (...) MasterThief.ItemSold(...) end)
	EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_CLOSE_STORE, function (...) MasterThief.FenceClosed(...) end)
end

function MasterThief:FenceClosed(eventCode)
	EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_SELL_RECEIPT)
	EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_CLOSE_STORE)
end

-- items sold at fencer
function MasterThief.ItemSold(eventCode, itemName, itemQuantity, money)
	if (MasterThief.SavedVarsOptions.AnnounceSellsTransfers) then 
		MasterThief:ShowMessage(itemQuantity.." x "..MasterThief:FixLinkName(itemName)..GetString(MT_MISC_SOLD_FOR)..money.."g",1) 
	end
	MasterThief:UpdateSavedVarsGold(money)
end

-- triggered, if you got caught and had to pay gold to the guard (or fencer)
function MasterThief.BountyPayoff(eventCode, oldBounty, newBounty) 
	if (newBounty == 0 and oldBounty > 0) then 
		MasterThief:ShowMessage(GetString(MT_MISC_BOUNTY_IS)..oldBounty.." gold",1)
	end
end

-- triggered, if you got killed by the guard
function MasterThief.JusticeGoldRemoved(eventCode, goldAmount)
	MasterThief:ShowMessage(GetString(MT_MISC_BOUNTY_REMOVED_FROM_BODY),1)
end

function MasterThief.JusticeStolenItemsRemoved(eventCode)
	MasterThief:ShowMessage(GetString(MT_MISC_ALL_STOLEN_ITEMS_REMOVED),1)
end

function MasterThief.OnMoneyUpdate(eventCode, newMoney, oldMoney, _reason) 
    local iMoney = (newMoney - oldMoney)
	--d("_reason: ".._reason..", iMoney: "..iMoney) -- DEBUG TEST
	
	if (_reason == 56) then -- fence vendor bounty paid reduced
		iMoney = iMoney * -1
		MasterThief:ShowMessage(GetString(MT_MISC_YOU_PAID_BOUNTY)..iMoney.." gold!",1)			
		MasterThief:UpdatePaidBounty(iMoney)	
	elseif (_reason == 47) then -- guard bounty paid reduced
		iMoney = iMoney * -1
		MasterThief:ShowMessage(GetString(MT_MISC_YOU_PAID_BOUNTY)..iMoney.." gold!",1)	
		MasterThief:UpdatePaidBounty(iMoney)
	elseif (_reason == 57) then -- guard bounty paid on kill (full price)
		iMoney = iMoney * -1
		MasterThief:ShowMessage(GetString(MT_MISC_YOU_PAID_BOUNTY)..iMoney.." gold!",1)
		MasterThief:UpdatePaidBounty(iMoney)
	elseif (_reason == 63) then -- fence item sold
	elseif (_reason == 60 and MasterThief.SavedVarsOptions.AnnounceSellsTransfers) then -- fence item laundry
		iMoney = iMoney * -1
		MasterThief:ShowMessage(GetString(MT_MISC_YOU_SOLD_AN_ITEM_FOR)..iMoney.." gold",1)
	elseif (_reason == 62) then -- stolen gold looted
		MasterThief:ShowMessage(GetString(MT_MISC_FOUND_ALOT_GOLD_TEXT)..iMoney.." gold",1)
	end
end

function MasterThief.CheckStealthMode(iEventCode, sUnitTag, iStealthState)
	if (sUnitTag ~= "player") then return end
	MasterThief:SetStealMode(iStealthState)
end

function MasterThief:SetStealMode(iStealthState)
	if (MasterThief.SavedVarsOptions.MasterThiefActive and MasterThief.SavedVarsOptions.SneakModeActive) then
		if (iStealthState == 3 and bInSneak == false) then -- to get into at first (i am already in stealth)
			MasterThief:ShowMessage(GetString(MT_MISC_SNEAKMODE_ACTIVE), 2)
			bInSneak = true
			EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function (...) MasterThief:UpdatedSlot(...) end)
			EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_LOOT_UPDATED, function (...) MasterThief:LootUpdated(...) end)
		elseif (iStealthState == 5 and MasterThief.SavedVarsOptions.AnnounceBeCareful) then
			local iStolenItems = MasterThief:CountStolenItems(1)
			local iStolenSpecials = MasterThief:CountStolenItems(2)
			if (iStolenItems + iStolenSpecials > 0) then 
				MasterThief:ShowMessage("|cFF3311"..GetString(MT_MISC_BE_CAREFUL).."|r", 2)
			else 
				MasterThief:ShowMessage(GetString(MT_MISC_BE_CAREFUL), 2)
			end
		elseif (iStealthState == 0 and bInSneak == true) then -- i am not in stealth mode, DEACTIVATE all EVENTS
			bInSneak = false
			MasterThief:ShowMessage(GetString(MT_MISC_SNEAKMODE_SLEEPING), 2)
			EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
			EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_LOOT_UPDATED) 
		end
	end
end

function MasterThief.BEGIN_LOCKPICK(eventCode)
	--d("BEGIN_LOCKPICK") -- DEBUG TEST
	EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_LOCKPICK_SUCCESS, function (...) MasterThief.LOCKPICK_SUCCESS(...) end)
	EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_LOOT_CLOSED, function (...) MasterThief.LOOT_CLOSED(...) end)	
end

function MasterThief.LOCKPICK_SUCCESS(eventCode)
	bLockpickSuccessful = true
end

function MasterThief.LOOT_CLOSED()
	bLockpickSuccessful = false
	MasterThief.UnregisterLockpick()
	--d("LOOT_CLOSED") -- DEBUG TEST
end
function MasterThief.UnregisterLockpick()
	EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_LOCKPICK_SUCCESS)
	EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_LOOT_CLOSED)
end

-- a new recipe is learned
-- add it to the comparelist in SavedVars
function MasterThief.RecipeLearned(eventCode, recipeListIndex, recipeIndex)
	if (MasterThief.SavedVarsOptions.compareMyRecipes) then 
		MasterThief:SaveKnownRecipes(nil, false)
	end
end 

----------------------------------
---- Direkt calls by EVENTS - END 
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
---- SUBROUTINES - START
------------------------
-- Checks, whether MasterThief is set ON or OFF and announce a message
-- 
function MasterThief:AnnounceStatus()
	if (MasterThief.SavedVarsOptions.MasterThiefActive) then
		if (MasterThief.SavedVarsOptions.SneakModeActive) then  
			zo_callLater(function() d(GetString(MT_MISC_SNEAKMODE_ON)) end, 1500)			
		elseif (MasterThief.SavedVarsOptions.SneakModeActive == false) then  
			zo_callLater(function() d(GetString(MT_MISC_SNEAKMODE_OFF)) end, 1500)					
		end
	elseif (MasterThief.SavedVarsOptions.MasterThiefActive == false) then  
		zo_callLater(function() d(GetString(MT_MISC_MASTERTHIEF_OFF)) end, 1000)		
	end 
end

-- If is itemtype = recipe, then check out what to do
-- return: TRUE for solved Recipe-Action, else False for other special items
function MasterThief:DoActionLootItemRecipe(sName, iQuality, iInstancedLootId, itemLootLink)
	-- do we know it already and want it for sure ? Or is it not known, so we need it ?
	local bKnown = MasterThief:SaveKnownRecipes(sName, true)
	-- Info: quality is here n-1, because we dont have white colored recipes in table
	if (bKnown) then
		-- found known recipe and Qualitylevel is equal or higher than needed
		-- definitively needed as marked by recipe limiter
		if (iQuality-1 >= MasterThief.SavedVarsOptions.MinRecipeQuality) then
			MasterThief:ShowMessage(GetString(MT_MISC_ITS_KNOWN_BUT_WANTED_TEXT),1)
			LootItemById(iInstancedLootId)
		elseif (MasterThief.SavedVarsOptions.MinRecipeQuality and MasterThief.SavedVarsOptions.AnnounceKnownRecipes) then 
			MasterThief:ShowMessage(GetString(MT_MISC_IS_KNOWN)..MasterThief:FixLinkName(itemLootLink),1)
		end
	-- found unknown recipe, but Qualitylevel is lower or equal than needed
	elseif (bKnown == false) then
		local itemQuality = iQuality - 1
		if (itemQuality <= MasterThief.SavedVarsOptions.MinRecipeQuality and MasterThief.SavedVarsOptions.LootUnknownRecipesBelowLevel) then
			LootItemById(iInstancedLootId)
		   -- found unknown recipe, which fit Qualitylevel or is higher than
		elseif (itemQuality >= MasterThief.SavedVarsOptions.MinRecipeQuality) then
			LootItemById(iInstancedLootId)
		end
	end
end

function MasterThief:SaveKnownRecipes(recipeNameFromLoot, bCompare)
	if (MasterThief.SavedVarsOptions.compareMyRecipes == true) then
		-- do update the recipe-list of savedvars with my known recipes
		local numRecipeLists = GetNumRecipeLists()
		local countAdded = 0

		for i = 1, numRecipeLists do
			local _Name, recipeListIndex = GetRecipeListInfo(i)
			for n = 1, recipeListIndex do
				local bKnown, recipeName, _, _, iQualityReq = GetRecipeInfo(i, n)
				local _lang = GetCVar("language.2")
				if (_lang == "de" or _lang == "fr") then 
					recipeName = MasterThief:FixLinkName(recipeName) 
				end
				
				if (bKnown) then -- known means here, that i read just all known recipes of my learned recipes
					-- proof recipe of own recipe list, whether its needed to add to SavedVars if not already in
					local nPos, bFound = MasterThief:IsKnownRecipeSaved(recipeName)
					if (bFound == false) then -- was not listed in savedvars
						MasterThief.AccountSavedVariables.KnownRecipes[nPos + 1] = {recipeName, {gPlayerChar} }
						countAdded = countAdded + 1
					else -- recipe is listet in savedvars
						-- add my charname, if not already added, because i got the same recipe
						local _arrPlayerchars = MasterThief:AddOrRemovePlayerchar(nPos, true) -- add playerchar to recipe list
						if (_arrPlayerchars ~= nil) then
							MasterThief.AccountSavedVariables.KnownRecipes[nPos] = {recipeName, _arrPlayerchars }
						end
					end
				end
			end
		end
		if (countAdded > 0) then d(countAdded..GetString(MT_MISC_RECIPES_ADDED_TO_SEARCHPOOL)) end
	else --remove all known recipes, which do match by name
		local numRecipeLists = GetNumRecipeLists()
		local countRemoved = 0
		for i = 1, numRecipeLists do
			local _Name, recipeListIndex = GetRecipeListInfo(i)
			for n = 1, recipeListIndex do
				local bKnown, recipeName, _, _, iQualityReq = GetRecipeInfo(i, n)

				local _lang = GetCVar("language.2")
				if (_lang == "de" or _lang == "fr") then 
					recipeName = MasterThief:FixLinkName(recipeName) 
				end
				
				if (bKnown) then -- known means here, that i read just all known recipes of my learned recipes
					-- proof recipe of own recipe list, whether its needed to remove from list
					local nPos, bFound = MasterThief:IsKnownRecipeSaved(recipeName)
					if (bFound) then --remove it ?
						local _arrPlayerchars = MasterThief:AddOrRemovePlayerchar(nPos, false) -- remove playerCharname
						if (_arrPlayerchars == nil) then --remove recipe from savedvars list (if no charname is left)
							table.remove(MasterThief.AccountSavedVariables.KnownRecipes, nPos)
							countRemoved = countRemoved + 1
						else -- just update the list in savedvars
							MasterThief.AccountSavedVariables.KnownRecipes[nPos] = {recipeName, _arrPlayerchars }
						end
					end
				end
			end
		end
		if (countRemoved > 0) then d(countRemoved..GetString(MT_MISC_RECIPES_REMOVED_FROM_SEARCHPOOL)) end
	end	
	-- do compare the recipe with all known recipes of the savedvars list, if compare is allowed 
	-- (for all chars who saved their knowledge shared)
	if (bCompare) then
		--_recipeNameFromLoot = MasterThief:trim(MasterThief:FixLinkName(recipeNameFromLoot))
		--local nPos, bFound = MasterThief:IsKnownRecipeSaved(_recipeNameFromLoot)
		local nPos, bFound = MasterThief:IsKnownRecipeSaved(recipeNameFromLoot)
		if (bFound) then
			return true -- recipe is known on list
		else return false -- is unknown
			-- one of the chars you are playing should learn the recipe
			-- if learned, an event do the work and add it to the list if allowed by options
		end
	end
end

-- search recipename, whether it exists on compare-pool (searchpool)
function MasterThief:IsKnownRecipeSaved(_recipeName)
	if (MasterThief.AccountSavedVariables.KnownRecipes == nil) then
		MasterThief.AccountSavedVariables.KnownRecipes = {}
	end
	local nEntries = table.getn(MasterThief.AccountSavedVariables.KnownRecipes)	
	for idx, obj in ipairs(MasterThief.AccountSavedVariables.KnownRecipes) do
		local sRecipeName = obj[1]
		local arrPlayerCharnames = obj[2]
		if (string.lower(MasterThief:trim(sRecipeName)) == string.lower(MasterThief:trim(_recipeName))) then
			return idx, true, arrPlayerCharnames
		end	
	end
	return nEntries, false
end

function MasterThief:AddOrRemovePlayerchar(nPos, bAdd)
	local obj = MasterThief.AccountSavedVariables.KnownRecipes[nPos]
	local _arrCharnames = obj[2]
	
	if (_arrCharnames == nil) then
		if (bAdd == false) then
			return nil -- no charname was found and table was empty (can get removed)
		elseif (bAdd) then -- initialize the array and add the actual playerCharname
			_arrCharnames = {}
			table.insert(_arrCharnames,gPlayerChar)
			return _arrCharnames
		end
	end

	if (bAdd) then -- add the actual Playercharname is wanted
		for idx, _Charname in ipairs(_arrCharnames) do
			if (_Charname == gPlayerChar and bAdd == true) then -- is already in list
				return nil 
			end
		end
		-- if no charname was found in list, which match with the actual charname then add me
		table.insert(_arrCharnames,gPlayerChar)
		return _arrCharnames		
	elseif (bAdd == false) then -- remove the actual Playercharname is wanted
		for idx, _Charname in ipairs(_arrCharnames) do
			if (_Charname == gPlayerChar and bAdd == false) then --remove playerchar
				table.remove(_arrCharnames,idx)
				if (table.getn(_arrCharnames) == 0) then return nil end
			end
		end
	end
	-- in case nothing was found, i give back the array
	return _arrCharnames
end


function MasterThief:trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- Fix the i.e ^n:m useless info on names or items
--
function MasterThief:FixLinkName(sString)
	return zo_strformat(SI_TOOLTIP_ITEM_NAME, sString)
end

-- Announce the given Message to: 0=both, 1=Chat, 2=Box
-- (0 depends on what is set in settings)
function MasterThief:ShowMessage(sText, ChatOrBox)
	-- info goes to MessageBox, to chat or both
	local delay = MasterThief.SavedVarsOptions.MessageBoxDelay
	
	if (ChatOrBox == 0) then
		if (MasterThief.SavedVarsOptions.SpecialOnScreenMsg) then
			--MasterThief:MessageHandler(sText, delay)
			ctlMasterThiefLabel:SetText(sText)
			MasterThief:ShowMsgBox(true)
			zo_callLater(function() MasterThief:ShowMsgBox(false) end, delay)
		end
		if (MasterThief.SavedVarsOptions.SpecialChatMsg) then
			d(sText)
		end
	-- info goes to chat only
	elseif (MasterThief.SavedVarsOptions.SpecialChatMsg and ChatOrBox == 1) then
		d(sText)
	--info goes to MessageBox only		
	elseif (MasterThief.SavedVarsOptions.SpecialOnScreenMsg and ChatOrBox == 2) then
		MasterThief:MessageHandler(sText, delay)
	end
end

-- Check for free slots have to be set as minimum left 
-- depends on what is set in settings
function MasterThief:CheckFreeSlots()
	local iMinFreeSlots = MasterThief.SavedVarsOptions.MinFreeSlots
	local iSlotsLeft = GetBagSize(BAG_BACKPACK) - GetNumBagUsedSlots(BAG_BACKPACK)
	if (iSlotsLeft - iMinFreeSlots <= 0) then
		if (iFreeSpaceLeft ~= iSlotsLeft) then 
			MasterThief:ShowMessage(GetString(MT_MISC_FREE_SLOTS_LEFT)..iSlotsLeft,0)
			iFreeSpaceLeft = iSlotsLeft
			return true
		end
	else return false
	end
end

-- Check, whether itemtype is listed on itemlist for special items (like recipe or motif)
-- Return TRUE or FALSE
function MasterThief:fCheckItemType(itemType)
	for i = 1,2,1 do
	    if (itemType == MasterThief.ItemTypes[i]) then return true end
	end
	return false
end


-- Check sell price and if its inside given range from settigs
-- Return TRUE or FALSE
function MasterThief:IsSellPriceOk(sellPrice)
	local iMinSellPrice = MasterThief.SavedVarsOptions.MinSellPrice
	if (sellPrice >= iMinSellPrice) then return true
	else return false end
end

-- Is this item a useless item ?
-- Return TRUE or FALSE
function MasterThief:IsStolenItemUseless(itemType, iSellPrice)
	local bSpecialItem = MasterThief:fCheckItemType(itemType)

	if (bSpecialItem == false and MasterThief.SavedVarsOptions.MinSellPrice > iSellPrice) then return true
	else return false
	end
end

-- Check the maximum for sells and transfers
-- Announce a warning, if maximum almost reached
function MasterThief:CheckMaxFenceLimit()
	local totalSells, sellsUsed = GetFenceSellTransactionInfo()
	local totalLaunders, laundersUsed = GetFenceLaunderTransactionInfo()
	if (MasterThief.SavedVarsOptions.AnnounceMaxFencerLimits == false) then return end

	local iStolenItems = MasterThief:CountStolenItems(1)
	local iStolenSpecials = MasterThief:CountStolenItems(2)
	local iCarriedSellsPlusSold, iCarriedSpecialsPlusTransfers = MasterThief:getStolenValuesForFence()
	-- its supressed if MaxSellLimit = 0
	if (iCarriedSellsPlusSold >= totalSells and totalSells > 0 and bShowFenceSellLimitAgain == false) then 
	   MasterThief:ShowMessage("MT: "..GetString(MT_MISC_SELL_MAXIMUM_REACHED).." ("..iCarriedSellsPlusSold.." / "..totalSells..")" ,1)
	   bShowFenceSellLimitAgain = true
	end
	-- its supressed if MaxTransferLimit = 0
	if (iCarriedSpecialsPlusTransfers >= totalLaunders and totalLaunders > 0 and bShowFenceTransferLimitAgain == false) then
	   if (bMaxiumReachedPrinted == false) then MasterThief:ShowMessage("Maximum reached",1) end
	   MasterThief:ShowMessage("MT: "..GetString(MT_MISC_TRANSFER_MAXIMUM_REACHED).." ("..iCarriedSpecialsPlusTransfers.." / "..totalLaunders..")" ,1)	   
	   bShowFenceTransferLimitAgain = true
	end	
end

-- Calculate made solds or transfers
-- Return: Updated iSoldsAtFence and iTransfersAtFence to give back the updated values 
function MasterThief:getStolenValuesForFence()
	local iStolenItems = MasterThief:CountStolenItems(1) --all stolen items (include useless), except specials
	local iStolenSpecials = MasterThief:CountStolenItems(2) --just special stolen items
	local totalSells, sellsUsed = GetFenceSellTransactionInfo()
	local totalLaunders, laundersUsed = GetFenceLaunderTransactionInfo()
	local iCarriedSellsPlusSold = iStolenItems + sellsUsed
	local iCarriedSpecialsPlusTransfers = iStolenSpecials + laundersUsed
	
	return iCarriedSellsPlusSold, iCarriedSpecialsPlusTransfers
end

-- Subroutine to get all special items (assuming those are getting transfered)
-- Return: All stolen special items
function MasterThief:CountStolenItems(value) -- 1=stolen items(except special), 2=special items
	local iUsedSlots = GetNumBagUsedSlots(BAG_BACKPACK)
	local iCounter = 0
	for i=1,iUsedSlots do
		if (IsItemStolen(BAG_BACKPACK, i)) then
			local itemLink = GetItemLink(BAG_BACKPACK, i, LINK_STYLE_DEFAULT)
			local itemType = GetItemLinkItemType(itemLink)
			local _, iStack = GetItemInfo(BAG_BACKPACK, i)
			local bSpecialItem = MasterThief:fCheckItemType(itemType)		
			if (value == 1 and bSpecialItem == false) then 
				iCounter = iCounter + iStack
			elseif (value == 2 and bSpecialItem == true) then 
				iCounter = iCounter + iStack
			end
		end
	end
	return iCounter
end

-- Update routine for total gold in SavedVars
--
function MasterThief:UpdateSavedVarsGold(iNewGold)
	MasterThief.SavedVarsValues.stolenValuesTotal = MasterThief.SavedVarsValues.stolenValuesTotal + iNewGold
end

-- Update routine for total paid bounty in SavedVars
--
function MasterThief:UpdatePaidBounty(iMoney)
	MasterThief.SavedVarsValues.paidBountyTotal = MasterThief.SavedVarsValues.paidBountyTotal + iMoney
end

-- Enable/Disable the messagebox
--
function MasterThief:ShowMsgBox(bValue)
	if (bValue) then 
		ctlMasterThief:SetHidden(false) 
	else 
		ctlMasterThief:SetHidden(true) 
	end
end

-- Get recipe color as string from table thru given idx
-- Return: string (i.e.: "blue")
function MasterThief:GetMinRecipeQuality(idx)
	return MasterThief.RecipeQualities[idx]
end
-- Set recipe id from table thru given string into SavedVars
-- Return: idx (i.e.: 2)
function MasterThief:SetMinRecipeQuality(sValue)
	for i=1,3 do
		if(string.lower(MasterThief.RecipeQualities[i]) == string.lower(sValue)) then
			MasterThief.SavedVarsOptions.MinRecipeQuality = i
		end
	end
end

-- add messages to the table _EventList
-- and call an Update-Event to throw those messages 
function MasterThief:MessageHandler(sMessage, _duration)
	if (_duration == nil) then _duration = 1000 end
	
	local _eventName = MasterThief.name.."_"..tostring(GetTimeStamp()) 
	local tab = {}
	tab.timeSeconds = GetGameTimeMilliseconds() 
	tab.duration = _duration
	tab.eventName = _eventName
	--tab.message = sMessage -- just to test
	
	local i = table.maxn(_EventList)
	if (i == 0) then
		EVENT_MANAGER:RegisterForUpdate("MT_DELETE_MESSAGE_EVENT", 1000, MasterThief.CheckForEvents)
	end
	
	-- add event to list
	table.insert(_EventList, tab)
	
	ctlMasterThief:SetHidden(false)
	ctlMasterThiefLabel:SetText(sMessage)
	EVENT_MANAGER:RegisterForUpdate(_eventName, _duration, MasterThief.ThrowMessage)	
end

-- dummy, but needed as call adress
--
function MasterThief.ThrowMessage()
	-- dummy
end

-- Check for registered events in table _EventList
-- remove and unregister them
--
local bMessageLocked = false
function MasterThief.CheckForEvents()
	local i = table.maxn(_EventList)
	if (i > 0) then
		bMessageLocked = true
		local _time = _EventList[1].timeSeconds
		local _duration = _EventList[1].duration 
		local _eventName = _EventList[1].eventName 
		local _Message = _EventList[1].message
		if (bMessageLocked == false) then -- to reduce process activity on multiple triggers
			ctlMasterThief:SetHidden(false)
			ctlMasterThief:SetText(_Message)
		end
		-- remove one of the events out of the event-list ?
		if (GetGameTimeMilliseconds() >= _time + _duration) then
			-- remove with FIFO rule
			local _deleted = table.remove(_EventList, 1)
			EVENT_MANAGER:UnregisterForUpdate(_eventName)
			bMessageLocked = false
			-- hide textwindow, if allowed by settings
			if (i == 1) then
				local canShow = MasterThief:IsMsgBoxHidden()
				if (canShow == false) then ctlMasterThief:SetHidden(true) end
			end
		end
	else -- unregister UpdateEvent, because its not needed anymore
		EVENT_MANAGER:UnregisterForUpdate("MT_DELETE_MESSAGE_EVENT")
	end
end
function MasterThief:IsMsgBoxHidden()
	return MasterThief.SavedVarsOptions.MoveMsgbox
end

-- Stop all registered MessageEvents
--
function MasterThief:StopAllHandledEvents()
	local i = table.maxn(_EventList)
	if (i > 0) then
		for n=1,i do
			EVENT_MANAGER:UnregisterForUpdate(_eventName)
			local _deleted = table.remove(_EventList, 1)			
		end
	end
	EVENT_MANAGER:UnregisterForUpdate("MT_DELETE_MESSAGE_EVENT")
end

-- save position on window move
function MasterThief:WinMoveStop()
  MasterThief.SavedVarsOptions.left = ctlMasterThief:GetLeft()
  MasterThief.SavedVarsOptions.top = ctlMasterThief:GetTop()
end

-- restore window position
function MasterThief:RestorePosition()
  local left = MasterThief.SavedVarsOptions.left
  local top = MasterThief.SavedVarsOptions.top
 
  ctlMasterThief:ClearAnchors()
  ctlMasterThief:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end
------------------------
---- SUBROUTINES - END
------------------------------------------------------------------------------------

------------------------------------------------------------------------
--- Keybind Subroutines - START
-------------------------------
function MasterThief:ToggleOnOff()
	if (MasterThief.SavedVarsOptions.MasterThiefActive) then
		MasterThief.SavedVarsOptions.MasterThiefActive = false
		MasterThief:SetEvents()
	else
		MasterThief.SavedVarsOptions.MasterThiefActive = true
		MasterThief:SetEvents()
	end
end

function MasterThief:ToggleSneakMode()
	if (MasterThief.SavedVarsOptions.MasterThiefActive and MasterThief.SavedVarsOptions.SneakModeActive) then
		MasterThief.SavedVarsOptions.SneakModeActive = false
		EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_LOOT_UPDATED) 			
		MasterThief:SetEvents()
	elseif (MasterThief.SavedVarsOptions.MasterThiefActive and MasterThief.SavedVarsOptions.SneakModeActive == false) then
		MasterThief.SavedVarsOptions.SneakModeActive = true
		MasterThief:SetEvents()
		local stealthState = GetUnitStealthState("player")
		bInSneak = true
		MasterThief:SetStealMode(stealthState)
	end
end

-- Remove as useless identified items from bag
-- BE CAREFUL - the items getting destroyed if bDestroyIt is set TRUE!!
function MasterThief:DestroyUselessItems(bDestroyIt)
	local _bagId = BAG_BACKPACK
	local iUsedSlots = GetNumBagUsedSlots(_bagId)
	local iUselessItemCounter = 0
	local sSuffix = ""
	if (bDestroyIt) then sSuffix = GetString(MT_MISC_ITEM_DESTROYED) end
	
	if (bDestroyIt == false) then d(GetString(MT_MISC_LIST_USELESS_ITEMS)) end
	for i=1,iUsedSlots do
		local itemLink = GetItemLink(_bagId, i, LINK_STYLE_DEFAULT)
		local itemType = GetItemLinkItemType(itemLink)
		local _, iSellPrice = GetItemLinkInfo(itemLink)
		local bSpecialItem = MasterThief:fCheckItemType(itemType)
		
		--if item is not special (like recipe or motif) but stolen and useless
		local bUseLessItem = MasterThief:IsStolenItemUseless(itemType, iSellPrice)
		if (IsItemStolen(_bagId, i) == true and bUseLessItem == true) then
			local iStack = GetSlotStackSize(_bagId, i) 
			iUselessItemCounter = iUselessItemCounter + 1
			if (bDestroyIt) then DestroyItem(_bagId, i) end --be careful on use ! 
			d(iStack.." x "..MasterThief:FixLinkName(itemLink)..sSuffix)
		end
	end
	if (bDestroyIt == false) then 
		d(GetString(MT_MISC_USELESS_ITEMS_FOUND)..iUselessItemCounter) 
		if (iUselessItemCounter > 0) then d(GetString(MT_MISC_TYPE_COMMAND_DESTROY_ITEM)) end
	else
		if (iUselessItemCounter == 0) then d(GetString(MT_MISC_NO_ITEMS_FOUND))  end
	end
	d(GetString(MT_MISC_ITEMS_BELOW_VALUE_USELESS)..MasterThief.SavedVarsOptions.MinSellPrice.."g !")
end

function MasterThief:ShowStatistics()
	--local iUsedSlots = GetNumBagUsedSlots(BAG_BACKPACK) --still wrong results ?
	local iUsedSlots = GetBagSize(BAG_BACKPACK) --used this coz of wrong result with GetNumBagUsedSlots
	local stolenGold = 0

	for i=1,iUsedSlots do
		local itemLink = GetItemLink(BAG_BACKPACK, i, LINK_STYLE_DEFAULT)
		local itemType = GetItemLinkItemType(itemLink)
		local _, iStack, iSellPrice = GetItemInfo(BAG_BACKPACK, i)
		local bSpecialItem = MasterThief:fCheckItemType(itemType)
		local iJunkValues = 0
		
		--if item is not special (like recipe or motif) 
		--then calculate the stolen values
		if (IsItemStolen(BAG_BACKPACK, i) and bSpecialItem == false) then
			stolenGold = stolenGold + (iStack * iSellPrice)
		end
	end

	local iStolenItems = MasterThief:CountStolenItems(1)
	local iStolenSpecials = MasterThief:CountStolenItems(2)
	local totalSells, sellsUsed = GetFenceSellTransactionInfo()
	local totalLaunders, laundersUsed = GetFenceLaunderTransactionInfo()
	
	d(GetString(MT_MISC_HEADER_STATISTIC))
	d("|cF1F1F1"..GetString(MT_MISC_STOLEN_VALUES_IN_BAG).."|r "..stolenGold)
	d("|cF1F1F1"..GetString(MT_MISC_STOLEN_VALUES_SOLD).."|r "..MasterThief.SavedVarsValues.stolenValuesTotal)
	d("|cF1F1F1"..GetString(MT_MISC_BOUNTY_PAID).."|r "..MasterThief.SavedVarsValues.paidBountyTotal)
	d("|c33ccff"..GetString(MT_MISC_ACCOUNT_TOTAL).."|r "..MasterThief.SavedVarsValues.stolenValuesTotal - MasterThief.SavedVarsValues.paidBountyTotal)
	d("------------------------------------")
	d("|cF1F1F1"..GetString(MT_MISC_SELLS_MADE_TODAY).."|r "..sellsUsed.."|c33ccff~"..iStolenItems.."|r / "..totalSells)
	d("|cF1F1F1"..GetString(MT_MISC_TRANSFERS_MADE_TODAY).."|r "..laundersUsed.."|c33ccff~"..iStolenSpecials.."|r / "..totalLaunders)
	d("------------------------------------")
	MasterThief:CheckFreeSlots()
end

function MasterThief:ResetValues(_value) --1=Total
	if (_value == 1) then -- Reset total values
		MasterThief.SavedVarsValues.stolenValuesTotal = 0
		MasterThief.SavedVarsValues.paidBountyTotal = 0
		MasterThief:ShowStatistics()
	end
end

function MasterThief:ToggleSystemAttackInnocents()
	local sPreventAttackInnocents = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS) 
	if (sPreventAttackInnocents == "1") then -- its ON, so set it OFF - set value to prevent to attack innocents
		SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, "0")
		d(GetString(MT_MISC_SYSTEM_ATTACK_INNOCENTS_ON))
	else -- its OFF, so set it ON - set value to attack innocents
		SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, "1")
		d(GetString(MT_MISC_SYSTEM_ATTACK_INNOCENTS_OFF))	
	end
end

function MasterThief:ChangeSystemSettings()
	local sIsAutoLootEnabled = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN) 
	if (sIsAutoLootEnabled == "1") then -- its ON, so set it OFF
		-- remember setting
		MasterThief.SavedVarsOptions.SYSTEM_AutolootStolenItems = sIsAutoLootEnabled
		-- set new value to get MasterThief run properly
		SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, "0")
	end
end
-------------------------------
--- Keybind Subroutines - END
------------------------------------------------------------------------

------------------------------------------------------------------------------------
---- Scroll-List/LootItems - START
------------------------
local tlw = nil
local lootScrollIsHidden = true
function MasterThief:ToggleLootList()
	if lootScrollIsHidden == false then
		tlw:SetHidden(true)
		lootScrollIsHidden = true
		if SCENE_MANAGER:IsInUIMode() then
			SCENE_MANAGER:SetInUIMode(false)
		end		
	else
		tlw:SetHidden(false)
		lootScrollIsHidden = false
		if not SCENE_MANAGER:IsInUIMode() then
			SCENE_MANAGER:SetInUIMode(true)
		end			
	end
end

-- This function creates a top level window to hold the scrollList
function MasterThief:CreateLootItem_ScrollWindow()
    tlw = WINDOW_MANAGER:CreateTopLevelWindow("MTScrollList")
    tlw:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    tlw:SetDimensions(600, 270)
	tlw:SetMovable(true)
	tlw:SetHidden(true)
	tlw:SetKeyboardEnabled(false)
	tlw:SetMouseEnabled(true)
	
    -- create a background
    tlw.bg = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Bg", tlw, "ZO_DefaultBackdrop")
    tlw.bg:SetAnchorFill()

	-- Window-Label erstellen
	local title = WINDOW_MANAGER:CreateControl("$(parent)Title", tlw, CT_LABEL)
	title:SetAnchor(TOPLEFT, tlw, TOPLEFT, 120, 0)
	title:SetFont("ZoFontHeader3")
	title:SetText(GetString(MT_MISC_WORTHFUL_ITEMS))
	title:SetColor(255,200,0,0.6)
	
	-- Window-Label erstellen (itemcounter)
	local title = WINDOW_MANAGER:CreateControl("$(parent)ItemCounter", tlw, CT_LABEL)
	title:SetAnchor(TOPLEFT, tlw, TOPLEFT, 10, 4)
	title:SetFont("ZoFontGame")
	title:SetText("Total: "..MasterThief:countItemsOnLootlist())
	--title:SetColor(0,50,150,0.6)
	title:SetColor(255,200,0,0.6)
		
	-- Close-Button erstellen
	local closeButton = WINDOW_MANAGER:GetControlByName("ZO_Loot_Control1", "")
	if (closeButton ~= nil) then return end
	-- A simple text-button to close the window
	local btn = WINDOW_MANAGER:CreateControlFromVirtual("closeButton", tlw, "ZO_DefaultTextButton")
	btn:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, -14, 4)
	btn:SetText("X")
	btn:SetWidth(20)
	btn:SetHandler("OnClicked" , function() MasterThief:ToggleLootList(); end)

    return tlw
end

-- Create the row setup callback function
function MasterThief.SetupDataRow(rowControl, data, scrollList)
    rowControl:SetText(data[1])
    rowControl:SetFont("ZoFontGame")

	-- Event for mouseclicks
	rowControl:SetHandler("OnMouseUp", function(self, button, upInside)
		if upInside then
			if button == 1 then --left button
				local bFound = false
			end
			if button == 2 then -- delete the item with right mouse-button
				if (MasterThief:removeFromList(data[1]) == true) then d(data[1]..GetString(MT_MISC_LOOTLIST_DELETE)) scrollList:Update(scrollListData) end
			end	
		end
    end)
end
 
-- Function that creates the scrollList 
function MasterThief:CreateScrollList()
    local mainWindow = MasterThief:CreateLootItem_ScrollWindow()
    
    local scrollData = {
        name = "MT_ScrollListData",
        parent = mainWindow,
        
        width = 600,
        height = 220,
        rowHeight = 30,
        
        setupCallback = MasterThief.SetupDataRow,
		selectCallback  = MasterThief.OnRowSelect,
		selectCallback = MasterThief.OnResizeStart,
		dataTypeSelectSound = SOUNDS.BOOK_CLOSE,
		--sortFunction    = MasterThief.SortScrollList,
    }
	
    scrollList = libScroll:CreateScrollList(scrollData)
    scrollList:SetAnchor(TOPLEFT, mainWindow, TOPLEFT, 20, 36)
	return scrollList
end

------ LOOT-Functions for Right-Mouse-Click on LootWindow
-----------------
function MasterThief:addToLootList(itemLootLink)
	local nEntries = table.getn(MasterThief.SavedVarsLoots.Wortfhul)
	if (MasterThief:isWortfulItemOnScrollList(itemLootLink) == true) then
		d(GetString(MT_MISC_ITEM_ALREADY_ON_LOOTLIST))
		return
	end	
	MasterThief.SavedVarsLoots.Wortfhul[nEntries + 1] = { itemLootLink }
	
	table.insert(scrollListData, {itemLootLink} )
	scrollList:Update(scrollListData)
	d(tlw:GetNamedChild("ItemCounter"):SetText("Total: "..MasterThief:countItemsOnLootlist()))
	d(itemLootLink..GetString(MT_MISC_ITEM_ADDED))
	
end

function MasterThief:removeFromList(itemLinkToCompare)
	for idx, obj in ipairs(MasterThief.SavedVarsLoots.Wortfhul) do
		local sItemName = obj[1]
		if (sItemName==itemLinkToCompare) then
			table.remove(scrollListData,idx)
			table.remove(MasterThief.SavedVarsLoots.Wortfhul, idx)	
			d(tlw:GetNamedChild("ItemCounter"):SetText("Total: "..MasterThief:countItemsOnLootlist()))
			return true
		end
	end
	return false
end

function MasterThief:isWortfulItemOnScrollList(itemLinkToCompare)
	for idx, obj in ipairs(MasterThief.SavedVarsLoots.Wortfhul) do
		local sItemName = obj[1]
		zo_strformat(SI_TOOLTIP_ITEM_NAME, sString)
		local rawName_lootItem = GetItemLinkName(itemLinkToCompare)
		local rawName_listItem = GetItemLinkName(sItemName)
		if (rawName_lootItem==rawName_listItem) then
			return true
		end
	end	
	return false
end
function MasterThief:countItemsOnLootlist()
	if (MasterThief.SavedVarsLoots.Wortfhul == nil) then 
		return 0
	end
	
	local iItems = table.getn(MasterThief.SavedVarsLoots.Wortfhul)
	return iItems
end


-- Create submenu-option on right mouse-click
-- its called by a ZO_PreHook to create contex-menu entries with use of addContextMenuEntry
function MasterThief.CreateContextMenuEntry(rowControl)
	-- contextmenu for loot-window only
	if (rowControl:GetOwningWindow():GetName() ~= "ZO_Loot" or rowControl:GetOwningWindow() == ZO_TradingHouse) then return end
	if rowControl:GetParent() ~= ZO_Character then 
		zo_callLater(function() MasterThief:addContextMenuEntry(rowControl:GetParent()) end, 100)
	end
end
function MasterThief:addContextMenuEntry(rowControl)
	local itemLootLink = GetLootItemLink(rowControl.dataEntry.data.lootId, LINK_STYLE_DEFAULT)
	--d("Loot_ID: "..rowControl.dataEntry.data.lootId.." - "..rowControl.dataEntry.data.name.." - "..itemLootLink)

	AddMenuItem(GetString(MT_CONTEXTMENU_LOOT_MARK), function() MasterThief:addToLootList(itemLootLink) end, MENU_ADD_OPTION_LABEL)
	ShowMenu()
end

-- InventarTooltip hook routine
--
function MasterThief:InventarTooltip()
    local InventarItemTooltip = ItemTooltip.SetBagItem
    ItemTooltip.SetBagItem = function(control, iBagId, iSlotId)
		local itemLink = GetItemLink(iBagId, iSlotId, LINK_STYLE_DEFAULT)
		local itemType = GetItemLinkItemType(itemLink)
		InventarItemTooltip(control, iBagId, iSlotId)
		
		if (itemType == ITEMTYPE_RECIPE) then
			_recipeName = GetItemLinkName(GetItemLinkRecipeResultItemLink(itemLink))
			_recipeName = MasterThief:FixLinkName(_recipeName)
			local idx, bKnown, arrPlayerCharnames = MasterThief:IsKnownRecipeSaved(_recipeName)
			if (bKnown and arrPlayerCharnames ~= nil) then
				local _CharsKnown = ""
				for _, _Charname in ipairs(arrPlayerCharnames) do
					_CharsKnown = _CharsKnown.."|c00A5C6".._Charname.."|r, "
				end
				_CharsKnown = string.sub (_CharsKnown, 1, string.len(_CharsKnown)-2)
				ZO_Tooltip_AddDivider(control)
				control:AddLine("|cB552AD"..GetString(MT_MISC_TOOLTIP_RECIPE_CHARS).."|r")
				control:AddLine(_CharsKnown, "ZoFontGame")
			end
		end
	end
end

-- LootTooltip hook routine
--
function MasterThief:LootTooltip()
    local LootItemTooltip = ItemTooltip.SetLootItem
    ItemTooltip.SetLootItem = function(control, iInstancedLootId)
		local itemLootLink = GetLootItemLink(iInstancedLootId, LINK_STYLE_DEFAULT)
		local itemType = GetItemLinkItemType(itemLootLink)
		LootItemTooltip(control, iInstancedLootId)

		if (MasterThief:isWortfulItemOnScrollList(itemLootLink) == true) then
			local itemOnLootList = GetString(MT_MISC_ITEM_TOOLTIP)
			ZO_Tooltip_AddDivider(control)
			control:AddLine("|c0092FF"..itemOnLootList.."|r")
		end
		
		if (itemType == ITEMTYPE_RECIPE) then
			_recipeName = GetItemLinkName(GetItemLinkRecipeResultItemLink(itemLootLink))
			_recipeName = MasterThief:FixLinkName(_recipeName)			
			local idx, bKnown, arrPlayerCharnames = MasterThief:IsKnownRecipeSaved(_recipeName)
			if (bKnown and arrPlayerCharnames ~= nil) then
				local _CharsKnown = ""
				for _, _Charname in ipairs(arrPlayerCharnames) do
					_CharsKnown = _CharsKnown.."|c00A5C6".._Charname.."|r, "
				end
				_CharsKnown = string.sub (_CharsKnown, 1, string.len(_CharsKnown)-2)
				ZO_Tooltip_AddDivider(control)
				control:AddLine("|cB552AD"..GetString(MT_MISC_TOOLTIP_RECIPE_CHARS).."|r")
				control:AddLine(_CharsKnown, "ZoFontGame")
			end
		end
	end
end

------------------------------------------------------------------------------------
---- Scroll-List/LootItems - END
------------------------

------------------------------------------------------------------------
-- activate / deactivate events - START
---------------------------------------
function MasterThief:SetEvents()
	
	if (MasterThief.SavedVarsOptions.MasterThiefActive) then
		EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_OPEN_FENCE, function (...) MasterThief.FenceOpened(...) end)
		--EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_CLOSE_FENCE, function (...) MasterThief.CloseFence(...) end) --event do not trigger !		
		EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_JUSTICE_GOLD_REMOVED, function (...) MasterThief.JusticeGoldRemoved(...) end) -- if you got killed by a guard
		EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_JUSTICE_STOLEN_ITEMS_REMOVED, function (...) MasterThief.JusticeStolenItemsRemoved(...) end) -- if you got killed by a guard or a guard caught you
		EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_JUSTICE_BOUNTY_PAYOFF_AMOUNT_UPDATED, function (...) MasterThief.BountyPayoff(...) end) -- if you got caught and have to pay to the guard
		EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_MONEY_UPDATE, function (...) MasterThief.OnMoneyUpdate(...) end)
		EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_BEGIN_LOCKPICK, function (...) MasterThief.BEGIN_LOCKPICK(...) end)
		
		MasterThief:ChangeSystemSettings()
		
		-- SneakMode FALSE
		-- if SneakModeActive is TRUE, the events below are ONLY GETTING ACTIVATED ON STEALTH MODE in function: MasterThief.CheckStealthMode
		if (MasterThief.SavedVarsOptions.SneakModeActive == false) then
			-- allow looting without to be in sneakmode
			-- unregister stealth-state-check (its not needed at this point)
			EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function (...) MasterThief:UpdatedSlot(...) end)
			EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_LOOT_UPDATED, function (...) MasterThief:LootUpdated(...) end)
			EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_STEALTH_STATE_CHANGED)
			MasterThief:AnnounceStatus()
		elseif (MasterThief.SavedVarsOptions.SneakModeActive) then
			-- register stealth-state-check, because only in active stealth you can loot 
			-- (if going inactive *means sleeping*, then looting should temporarily not be allowed)
			EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_STEALTH_STATE_CHANGED, function (...) MasterThief.CheckStealthMode(...) end)
			MasterThief:AnnounceStatus()
		end
	else
		EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_OPEN_FENCE)
		EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_JUSTICE_GOLD_REMOVED)
		EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_JUSTICE_STOLEN_ITEMS_REMOVED)		
		EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_JUSTICE_BOUNTY_PAYOFF_AMOUNT_UPDATED)
		EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_MONEY_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_BEGIN_LOCKPICK)		
		EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_LOOT_UPDATED) 
		-- make sure, that also stealth-state-event is unregistered
		EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_STEALTH_STATE_CHANGED)

		--stop all opened events and unregister event-handler
		MasterThief:StopAllHandledEvents()
		
		-- set back SYSTEM-Setting for stolen items
		if (MasterThief.SavedVarsOptions.SYSTEM_AutolootStolenItems ~= "") then
			SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, MasterThief.SavedVarsOptions.SYSTEM_AutolootStolenItems)
		end

		MasterThief:ShowMsgBox(false)
		zo_callLater(function() d(GetString(MT_MISC_MASTERTHIEF_OFF)) end, 1000)		
	end
end
---------------------------------------
-- activate / deactivate events - START
------------------------------------------------------------------------

-- OnLoad-Handler
function MasterThief.OnAddOnLoaded(event, addonName)
	if addonName == MasterThief.name then
	   MasterThief:Initialize()
	end
end 

-- Register Events for ADDON LOAD --
EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_ADD_ON_LOADED, MasterThief.OnAddOnLoaded)

--register slash-commands
local function MTDestroyUselessItemsFromBag(value)
	if (value == "delete") then MasterThief:DestroyUselessItems(true)
	else MasterThief:DestroyUselessItems(false) end
end
local function MTDisplayHelp()
	d(GetString(MT_MISC_MASTERTHIEF_COMMANDS))
	d("/mt_junk = "..GetString(MT_MISC_CMD_LIST_ALL_USELESS_ITEMS))
	d("/mt_junk delete = "..GetString(MT_MISC_CMD_DESTROY_ALL_USELESS_ITEMS))
	d("/mt_reset_statistic = "..GetString(MT_MISC_CMD_RESET_ALL_VALUES))
end
local function MTResetValues()
	MasterThief:ResetValues(1)
end
SLASH_COMMANDS["/masterthief"] = MTDisplayHelp
SLASH_COMMANDS["/mt_junk"] = MTDestroyUselessItemsFromBag
SLASH_COMMANDS["/mt_reset_statistic"] = MTResetValues