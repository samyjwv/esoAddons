--[[
Bank Manager Revived
Original by Benjamin Creusot - Todo
Reworked by SnowmanDK. Fully rewrited by Ayantir
Push & Pull items from/to inventory, bank and guildbank
Version: 7
Author: Ayantir
]]--
 
-- Global Vars

local db = nil
local addonName					= "BankManagerRevived"
local displayName					= "|c3366FFBank|r Manager |c990000Revived|r"
local author						= "Todo/SnowmanDK & Ayantir"
local version						= "7"
local isBanking					= false
local actualProfile				= 1
local inProgress					= false
local panel
local guildList
local checkingGBank
local currentGBank
local restartFromAtGBank
local hasAnyPullToDo
local hasAnySpecialPullToDo
local qtyMovedToGBank			= 0
local countMovedToGBank			= 0
local dataSorted

local ACTION_NOTSET				= 1
local ACTION_PUSH					= 2
local ACTION_PULL					= 3
local ACTION_PUSH_GBANK			= 4
local ACTION_PUSH_BOTH			= 5

local BMR_ITEMLINK				= 1
local BMR_BAG_AND_SLOT			= 2
--local startTimeInMs			= 0

-- Array of queues for moving items to handle bag/bank capacity limits
local pushQueue = {}
local pullQueue = {}
local movedItems = {
	[BAG_BACKPACK] = {},
	[BAG_BANK] = {},
}

-- Defaults structure for SV
-- memory is a bit wasted here, still need to try to find how to dynamically build defaults after the SV pull from file
local defaults = {
	actualProfile = 1,
	gui_x = -600,
	gui_y = -400,
	profiles = {
		[1] = {
			name = "",
			defined					= true,
			autoTransfert			= true,
			detailledDisplay		= true,
			summary				 	= true,
			protected				= true,
			moved						= true,
			detailledNotMoved		= true,
			initialWaitInSecs		= 2,
			overfill					= 0,
			pauseInMs				= 0,
		},
		[2] = {
			name = "",
			defined					= false,
			autoTransfert			= true,
			detailledDisplay		= true,
			summary				 	= true,
			protected				= true,
			moved						= true,
			detailledNotMoved		= true,
			initialWaitInSecs		= 2,
			overfill					= 0,
			pauseInMs				= 0,
		},
		[3] = {
			name = "",
			defined					= false,
			autoTransfert			= true,
			detailledDisplay		= true,
			summary				 	= true,
			protected				= true,
			moved						= true,
			detailledNotMoved		= true,
			initialWaitInSecs		= 2,
			overfill					= 0,
			pauseInMs				= 0,
		},
		[4] = {
			name = "",
			defined					= false,
			autoTransfert			= true,
			detailledDisplay		= true,
			summary				 	= true,
			protected				= true,
			moved						= true,
			detailledNotMoved		= true,
			initialWaitInSecs		= 2,
			overfill					= 0,
			pauseInMs				= 0,
		},
		[5] = {
			name = "",
			defined					= false,
			autoTransfert			= true,
			detailledDisplay		= true,
			summary				 	= true,
			protected				= true,
			moved						= true,
			detailledNotMoved		= true,
			initialWaitInSecs		= 2,
			overfill					= 0,
			pauseInMs				= 0,
		},
		[6] = {
			name = "",
			defined					= false,
			autoTransfert			= true,
			detailledDisplay		= true,
			summary				 	= true,
			protected				= true,
			moved						= true,
			detailledNotMoved		= true,
			initialWaitInSecs		= 2,
			overfill					= 0,
			pauseInMs				= 0,
		},
		[7] = {
			name = "",
			defined					= false,
			autoTransfert			= true,
			detailledDisplay		= true,
			summary				 	= true,
			protected				= true,
			moved						= true,
			detailledNotMoved		= true,
			initialWaitInSecs		= 2,
			overfill					= 0,
			pauseInMs				= 0,
		},
		[8] = {
			name = "",
			defined					= false,
			autoTransfert			= true,
			detailledDisplay		= true,
			summary				 	= true,
			protected				= true,
			moved						= true,
			detailledNotMoved		= true,
			initialWaitInSecs		= 2,
			overfill					= 0,
			pauseInMs				= 0,
		},
		[9] = {
			name = "",
			defined					= false,
			autoTransfert			= true,
			detailledDisplay		= true,
			summary				 	= true,
			protected				= true,
			moved						= true,
			detailledNotMoved		= true,
			initialWaitInSecs		= 2,
			overfill					= 0,
			pauseInMs				= 0,
		},
	}
}

-- BMR code

-- Display a movement
local function PrintItemsToBag(itemLink, itemIcon, bagIdTo, qty, currentGBankName)
	CHAT_SYSTEM:AddMessage(zo_strformat(BMR_ACTION_ITEMS_MOVED, zo_strformat(SI_TOOLTIP_ITEM_NAME, itemLink), itemIcon, qty, GetString("BMR_ACTION_ITEMS_MOVED_TO", bagIdTo), currentGBankName))
end

local function PrintItemsNotMovedToBag(itemLink, itemIcon, bagIdTo, qty, currentGBankName)
	CHAT_SYSTEM:AddMessage(zo_strformat(BMR_ACTION_ITEMS_NOT_MOVED, zo_strformat(SI_TOOLTIP_ITEM_NAME, itemLink), itemIcon, qty, GetString("BMR_ACTION_ITEMS_MOVED_TO", bagIdTo), currentGBankName))
end

-- Display movement summary
local function PrintSummaryToBag(bagIdTo, countMoved, qtyMoved, currentGBankName)
	CHAT_SYSTEM:AddMessage(zo_strformat(BMR_ACTION_ITEMS_SUMMARY, countMoved, qtyMoved, GetString("BMR_ACTION_ITEMS_MOVED_TO", bagIdTo), currentGBankName))
end

-- Display currency movement
local function PrintCurrencyToBank(currencyType, qtyMoved)
	CHAT_SYSTEM:AddMessage(zo_strformat(BMR_ACTION_CURRENCY_SUMMARY, ZO_CurrencyControl_FormatCurrencyAndAppendIcon(qtyMoved, true, currencyType), GetString(BMR_ACTION_ITEMS_MOVED_TO2)))
end

-- Display currency movement
local function PrintCurrencyToBag(currencyType, qtyMoved)
	CHAT_SYSTEM:AddMessage(zo_strformat(BMR_ACTION_CURRENCY_SUMMARY, ZO_CurrencyControl_FormatCurrencyAndAppendIcon(qtyMoved, true, currencyType), GetString(BMR_ACTION_ITEMS_MOVED_TO1)))
end

local function BuildWritsItems()
	
	local shouldBeWatched
	
	BankManagerRules.static.special.writsQuests = {}
	BankManagerRules.static.special.writsQuestsGlyphs = {}  -- Bit dirty, see how to improve - BankManagerRules.lua#271
	BankManagerRules.static.special.writsQuestsPots = {}	
	
	for journalQuestIndex = 1, GetNumJournalQuests() do
		if GetJournalQuestType(journalQuestIndex) == QUEST_TYPE_CRAFTING then
			if GetJournalQuestNumSteps(journalQuestIndex) == QUEST_MAIN_STEP_INDEX then
				for numConditions = 1, GetJournalQuestNumConditions(journalQuestIndex, QUEST_MAIN_STEP_INDEX) do
					local conditionText, current, max, _, isComplete = GetJournalQuestConditionInfo(journalQuestIndex, QUEST_MAIN_STEP_INDEX, numConditions)
					if conditionText ~= "" and current < max then
						conditionText = string.gsub(conditionText, " ", " ") -- First is a NO-BREAK SPACE, 2nd a SPACE, found somes.
						table.insert(BankManagerRules.static.special.writsQuests, {text = conditionText, qtyToMove = max})
						table.insert(BankManagerRules.static.special.writsQuestsGlyphs, {text = conditionText, qtyToMove = max})
						table.insert(BankManagerRules.static.special.writsQuestsPots, {text = conditionText, qtyToMove = max})
						shouldBeWatched = true
					end
				end
			end
		end
	end
	
	if not shouldBeWatched then
		hasAnySpecialPullToDo = false
	end
	
end

-- Reset all vars when finishing a GBank move
local function onCloseProcessAtGBank()

	restartFromAtGBank = nil
	qtyMovedToGBank = 0
	countMovedToGBank = 0
	inProgress = false
	pushQueue = {}
	
	EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_GUILD_BANK_TRANSFER_ERROR)
	EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_GUILD_BANK_ITEM_ADDED)
	
end

-- Build the push/pull array
local function queueAction(ruleName, bagId, slotId)
	
	local whichAction = db.profiles[actualProfile].rules[ruleName].action
	if (whichAction == ACTION_PUSH or whichAction == ACTION_PUSH_GBANK or whichAction == ACTION_PUSH_BOTH) and bagId == BAG_BACKPACK then
		-- Push item to bank
		--d("ACTION " .. whichAction .. " " .. ruleName .. " " .. bagId .. " " .. slotId)
		table.insert(pushQueue, {ruleName = ruleName, bagId = bagId, slotId = slotId, itemLink = GetItemLink(bagId, slotId), itemIcon = GetItemLinkInfo(GetItemLink(bagId, slotId))})
	elseif whichAction == ACTION_PULL and bagId == BAG_BANK then
		-- Pull item to bank
		--d("ACTION_PULL " .. ruleName .. " " .. bagId .. " " .. slotId)
		table.insert(pullQueue, {ruleName = ruleName, bagId = bagId, slotId = slotId, itemLink = GetItemLink(bagId, slotId), itemIcon = GetItemLinkInfo(GetItemLink(bagId, slotId))})
	end
	
end

-- return true if item is protected
local function IsItemProtected(bagId, slotId)
	
	if db.profiles[actualProfile].protected then
	
		-- ESOUI
		if IsItemPlayerLocked(bagId, slotId) then
			return true
		end
		
		--ItemSaver
		if ItemSaver_IsItemSaved then
			local isProtected, protectedSet = ItemSaver_IsItemSaved(bagId, slotId)
			--item is protected
			if isProtected then
				return true
			end
		end
		
		--FCOIsFiltered
		if FCOIsMarked then
			if (FCOIsMarked(GetItemInstanceId(bagId, slotId), -1) == true) then
				return true
			end
		end
		
	end
	
	return false

end

-- To sort array
local function sortByKeyAndPosition(array)

	local arrayTemp = {}
	for key, data in pairs(array) do table.insert(arrayTemp, {key=key, data=data}) end

	local function sortByPosition(a, b)

		if not a.data.position and not b.data.position then return a.data.ruleName < b.data.ruleName end
		if not a.data.position and b.data.position then return true end
		if a.data.position and not b.data.position then return false end
		if a.data.position and b.data.position then
			return a.data.position < b.data.position
		end

	end

	table.sort(arrayTemp, sortByPosition)
	return arrayTemp
	
end

local function pairsByKeysAndPosition(array)

	local i = 0
	local iter = function()
		i = i + 1
		if array and array[i] then
			return array[i].key, array[i].data
		else
			return
		end
	end
	
	return iter
	
end

-- Check if slotId match a rule
local function prepareItem(bagId, slotId, checkingGBank)

	-- Inits
	if (IsItemStolen(bagId, slotId)) then return end
	if (IsItemProtected(bagId, slotId)) then return end
	
	local itemLink = GetItemLink(bagId, slotId)
	
	-- Cannot be moved to bank
	if bagId == BAG_BACKPACK and GetItemLinkBindType(itemLink) == BIND_TYPE_ON_PICKUP_BACKPACK then return end
	
	-- Cannot be moved to GBank
	if checkingGBank and GetItemLinkBindType(itemLink) == BIND_TYPE_ON_PICKUP then return end
	
	local itemMatch = false
	local ruleMatch
	local forBankOnly = (not checkingGBank)
	
	-- For each item in bag, look all rules
	for ruleName, ruleData in pairsByKeysAndPosition(dataSorted) do
	
		local action = db.profiles[actualProfile].rules[ruleName].action
		local associatedGuild = db.profiles[actualProfile].rules[ruleName].associatedGuild
		
		-- Check first if item didn't matched a previous rule
		if (not itemMatch) then
		
			local shouldMove
			
			if checkingGBank then -- the 3rd is here to allow easy rules, see under
				shouldMove = (currentGBankName == associatedGuild) and ((bagId == BAG_BACKPACK and action == ACTION_PUSH_GBANK) or (bagId == BAG_BACKPACK and action == ACTION_PUSH_BOTH) or (bagId == BAG_BACKPACK and action == ACTION_PUSH))
			else
				if action == ACTION_PULL then
					if db.profiles[actualProfile].rules[ruleName].specialEnabled then
						hasAnySpecialPullToDo = true
					else
						hasAnyPullToDo = true
					end
				end
				shouldMove = (bagId == BAG_BACKPACK and action == ACTION_PUSH) or (bagId == BAG_BANK and action == ACTION_PULL) or (bagId == BAG_BACKPACK and action == ACTION_PUSH_BOTH)
			end
			
			-- If rule is well writen and set to do something
			if ruleData.params and shouldMove then

				for ruleParamIndex, ruleParamData in ipairs(ruleData.params) do
					
					local funcToUse = ruleParamData.func -- Our fonction stored
					local itemMatchValue
					
					if funcToUse then
						if ruleParamData.funcArgs == BMR_ITEMLINK then
							
							-- Is item matching values ?
							for funcChoices, funcMatches in ipairs(ruleParamData.values) do
								if funcToUse(itemLink) == funcMatches then
									itemMatchValue = true
								end
							end
							
						elseif ruleParamData.funcArgs == BMR_BAG_AND_SLOT then
							for funcChoices, funcMatches in ipairs(ruleParamData.values) do
								if funcToUse(bagId, slotId) == funcMatches then
									itemMatchValue = true
								end
							end
						
						end
					end
					
					-- The item didn't match our filter, don't try other params, go to next rule
					if (not itemMatchValue) then
						itemMatch = false
						ruleMatch = nil
						break
					else
						-- The item match our filter .. for now
						itemMatch = true
						ruleMatch = ruleName
						--d(itemLink .. " (" .. bagId .. " " .. slotId.. ") ruleMatch:" .. ruleName .. " #" .. ruleParamIndex)
					end
					
				end

				-- Our item matched a rule - was it an ACTION_PUSH + checkingGBank ?
				if itemMatch and checkingGBank and action == ACTION_PUSH then
					-- this item must not be queued, it has been flagged to go to bank only
					forBankOnly = true
					--d(itemLink .. " (" .. bagId .. " " .. slotId.. ") ruleMatch:" .. ruleMatch .. " set flag 'For Bank Only' ")
				end
			
			end
		else
			break
		end
	end
	
	if itemMatch then
		if checkingGBank then
			if (not forBankOnly) then
				--d(itemLink .. " (" .. bagId .. " " .. slotId.. ") ruleMatch:" .. ruleMatch .. " is not flagged for Bank Only. Will move")
				queueAction(ruleMatch, bagId, slotId)
			else
				--d(itemLink .. " (" .. bagId .. " " .. slotId.. ") ruleMatch:" .. ruleMatch .. " is flagged for Bank Only. Don't move")
			end
		else
			queueAction(ruleMatch, bagId, slotId)
		end
	end

end

-- Move all items defined in push/pull arrays
local function moveItems(atGBank, errorReasonAtGBank)

	-- Our bagcache, because game don't have it in realtime
	local tinyBagCache = {
		[BAG_BACKPACK] = {},
		[BAG_BANK] = {},
	}
	
	-- Our bagcache for qty, because game don't have it in realtime
	local qtyBagCache = {}
	
	-- Avoid checking first 230 slots if we already did it.
	local tinyBagCacheFirstSlot = {
		[BAG_BACKPACK] = 0,
		[BAG_BANK] = 0,
	}
	
	local freeSlots = {
		[BAG_BACKPACK] = 0,
		[BAG_BANK] = 0,
	}
	
	-- Items moved in psuh + pull actions
	local itemsMoved = 0
	local qtyMoved = 0
	local countMoved = 0
	local pushInProgress = true
	
	-- Thanks Merlight & circonian, FindFirstEmptySlotInBag don't refresh in realtime.
	local function FindEmptySlotInBag(bagId)
		if atGBank or freeSlots[bagId] > db.profiles[actualProfile].overfill then
			for slotIndex = tinyBagCacheFirstSlot[bagId], (GetBagSize(bagId) - 1) do
				if not SHARED_INVENTORY.bagCache[bagId][slotIndex] and not tinyBagCache[bagId][slotIndex] then
					--d("tinyBagCache -> " .. bagId .. " " .. slotIndex)
					tinyBagCache[bagId][slotIndex] = true
					tinyBagCacheFirstSlot[bagId] = slotIndex + 1
					freeSlots[bagId] = freeSlots[bagId] - 1
					return slotIndex
				end
			end
		end
		return nil
	end
	
	-- Return the slotIndex if the stack is not fulfilled or a newslot
	local function FindItemInBag(bagIdTo, bagIdFrom, slotIdFrom, maxStack)
		--d("FindItemInBag")
		local itemInstanceId = SHARED_INVENTORY.bagCache[bagIdFrom][slotIdFrom].itemInstanceId
		for slotId, data in pairs(SHARED_INVENTORY.bagCache[bagIdTo]) do
			if data.itemInstanceId == itemInstanceId and data.stackCount < maxStack then
				return data.slotIndex
			end
		end
		-- Not found or all stack are full
		return FindEmptySlotInBag(bagIdTo)
	end
	
	local function FindDestSlotInBag(stackCountTo, bagIdTo, bagIdFrom, slotIdFrom, maxStack)
		--d("FindDestSlotInBag " .. bagIdFrom .. " " .. slotIdFrom)
		if stackCountTo > 0 then
			return FindItemInBag(bagIdTo, bagIdFrom, slotIdFrom, maxStack)
		else
			return FindEmptySlotInBag(bagIdTo)
		end
		
	end
	
	local function moveItemInSlot(bagIdFrom, slotIdFrom, bagIdTo, slotIdTo, qtyToMove, itemLink)
		if IsProtectedFunction("RequestMoveItem") then
			CallSecureProtected("RequestMoveItem", bagIdFrom, slotIdFrom, bagIdTo, slotIdTo, qtyToMove)
		else
			RequestMoveItem(bagIdFrom, slotIdFrom, bagIdTo, slotIdTo, qtyToMove)
		end
		
		-- qtyBagCache[itemLink] is always set, because set just before.
		qtyBagCache[itemLink][bagIdTo] = qtyBagCache[itemLink][bagIdTo] + qtyToMove
		qtyBagCache[itemLink][bagIdFrom] = qtyBagCache[itemLink][bagIdFrom] - qtyToMove
		
		-- to check
		return true
		
	end
	
	-- Move a slot or a partial slot to GBank
	local function moveItemInGBank(bagIdFrom, slotIdFrom, qtyToMove, itemLink)
		
		--d("moveItemInGBank")
		if qtyToMove then
			--Partial slot, we need an empty slot
			local emptySlot = FindEmptySlotInBag(bagIdFrom)
			-- Local bag can be full
			if emptySlot then
				moveItemInSlot(bagIdFrom, slotIdFrom, bagIdFrom, emptySlot, qtyToMove, itemLink)
				TransferToGuildBank(bagIdFrom, emptySlot)
			end
		else
			TransferToGuildBank(bagIdFrom, slotIdFrom)
		end
		
		-- Temporary
		return true
		
	end

	local function StackInfoInBag(bagToCheck, slotIdFrom, bagIdFrom, itemLink)
		local stackCountBackpack, stackCountBank
		
		if not qtyBagCache[itemLink] then
			stackCountBackpack, stackCountBank = GetItemLinkStacks(itemLink) -- Not updated in realtime
			qtyBagCache[itemLink] = {}
			qtyBagCache[itemLink][BAG_BACKPACK] = stackCountBackpack
			qtyBagCache[itemLink][BAG_BANK] = stackCountBank
		else
			stackCountBackpack = qtyBagCache[itemLink][BAG_BACKPACK]
			stackCountBank = qtyBagCache[itemLink][BAG_BANK]
		end
		
		local stackSize, maxStack = GetSlotStackSize(bagIdFrom, slotIdFrom)
		if bagToCheck == BAG_BACKPACK then
			return stackCountBackpack >= maxStack, stackSize, maxStack, stackCountBackpack, stackCountBank
		elseif bagToCheck == BAG_BANK then
			return stackCountBank >= maxStack, stackSize, maxStack, stackCountBackpack, stackCountBank
		end
	end
	
	local function FinishBankMoves()
	
		-- Sometimes needed (2 stacks, first 79, 2nd 200, but limit is 200 -> will push 79 , then 121, resulting 2 stacks), maybe need to optimize tinyBagCache
		StackBag(BAG_BANK)
		StackBag(BAG_BACKPACK)
		
		hasAnyPullToDo = nil
		pushQueue = {}
		pullQueue = {}
		movedItems = {
			[BAG_BACKPACK] = {},
			[BAG_BANK] = {},
		}
		
		inProgress = false
		
	end

	local function tryMoveSlots(data, bagIdTo, restartAt)
		
		-- Need to push/pull?
		if not restartAt then restartAt = 1 end
		local moveData = data[restartAt]
		
		if moveData then
		
			-- Should not exceed 100 in a move or game will kick you
			if db.profiles[actualProfile].pauseInMs >= 100 or (itemsMoved < 98 and db.profiles[actualProfile].pauseInMs < 100) then
				--d(moveData.ruleName .. " will check qty and if, move " .. GetItemName(moveData.bagId, moveData.slotId))
				
				-- Is slot at max size in bank ?
				local isFullStack, stackSize, maxStack, stackCountBackpack, stackCountBank = StackInfoInBag(bagIdTo, moveData.slotId, moveData.bagId, moveData.itemLink)
				local itemMoved = false
				local qtyToMove, destSlot
				
				if BankManagerRules.data[moveData.ruleName].isSpecial then
				
					if bagIdTo == BAG_BACKPACK then
						qtyToMove = BankManagerRules.static.special[moveData.ruleName][moveData.itemLink]
						destSlot = FindDestSlotInBag(stackCountBackpack, bagIdTo, moveData.bagId, moveData.slotId, maxStack)
					end
					
					--d("qtyToMove " .. qtyToMove .. " destSlot " .. tostring(destSlot))
					if destSlot then
						--d(moveData.ruleName .. " is moving " .. GetItemName(moveData.bagId, moveData.slotId) .. " (not full stack)")
						itemMoved = moveItemInSlot(moveData.bagId, moveData.slotId, bagIdTo, destSlot, qtyToMove, moveData.itemLink)
					elseif db.profiles[actualProfile].detailledNotMoved then
						PrintItemsNotMovedToBag(moveData.itemLink, moveData.itemIcon, bagIdTo, qtyToMove)
					end
					
				elseif (not isFullStack) and db.profiles[actualProfile].rules[moveData.ruleName].onlyIfNotFullStack then
					
					if bagIdTo == BAG_BACKPACK then
						qtyToMove = math.min(stackSize, (maxStack - stackCountBackpack))
						destSlot = FindDestSlotInBag(stackCountBackpack, bagIdTo, moveData.bagId, moveData.slotId, maxStack)
					elseif bagIdTo == BAG_BANK then
						qtyToMove = math.min(stackSize, (maxStack - stackCountBank))
						destSlot = FindDestSlotInBag(stackCountBank, bagIdTo, moveData.bagId, moveData.slotId, maxStack)
					end
					
					--d("qtyToMove " .. qtyToMove .. " destSlot " .. tostring(destSlot))
					if destSlot then
						--d(moveData.ruleName .. " is moving " .. GetItemName(moveData.bagId, moveData.slotId) .. " (not full stack)")
						itemMoved = moveItemInSlot(moveData.bagId, moveData.slotId, bagIdTo, destSlot, qtyToMove, moveData.itemLink)
					elseif db.profiles[actualProfile].detailledNotMoved then
						PrintItemsNotMovedToBag(moveData.itemLink, moveData.itemIcon, bagIdTo, qtyToMove)
					end
				
				elseif (not db.profiles[actualProfile].rules[moveData.ruleName].onlyIfNotFullStack) then
					
					-- Still don't know why.
					if type(db.profiles[actualProfile].rules[moveData.ruleName].onlyStacks) == "boolean" then
						db.profiles[actualProfile].rules[moveData.ruleName].onlyStacks = 1
					end
					
					local stackCountInBag
					-- got 80 to push, bank got 350, stack is 200, 1st stack will receive 50, 2nd stack: 30 if maxStack = 3, or 50 and 0 because of maxStack = 2
					if bagIdTo == BAG_BACKPACK then
						stackCountInBag = stackCountBackpack
					elseif bagIdTo == BAG_BANK then
						stackCountInBag = stackCountBank
					end
					
					local maxQtyAuthorized = db.profiles[actualProfile].rules[moveData.ruleName].onlyStacks * maxStack
					qtyToMove = math.min(stackSize, maxStack - (stackCountInBag % maxStack))
					
					if qtyToMove + stackCountInBag <= maxQtyAuthorized then
						destSlot = FindDestSlotInBag(stackCountInBag, bagIdTo, moveData.bagId, moveData.slotId, maxStack)
						--d("maxQtyAuthorized: " .. maxQtyAuthorized .. " stackCountInBag: " .. stackCountInBag)
						if qtyToMove == stackSize or (qtyToMove < stackSize and qtyToMove + stackCountInBag == maxQtyAuthorized) then
							
							-- 1 push to do
							--d("1 push to do")
							--d("qtyToMove " .. qtyToMove .. " destSlot " .. tostring(destSlot))
							if stackCountInBag + qtyToMove <= maxQtyAuthorized then
								if destSlot then
									itemMoved = moveItemInSlot(moveData.bagId, moveData.slotId, bagIdTo, destSlot, qtyToMove, moveData.itemLink)
								elseif db.profiles[actualProfile].detailledNotMoved then
									PrintItemsNotMovedToBag(moveData.itemLink, moveData.itemIcon, bagIdTo, qtyToMove)
								end
							end
							
						else
							
							--d("2 push to do?")
							--d("qtyToMove " .. qtyToMove .. " destSlot " .. tostring(destSlot))
							-- 2 push to do, first will fulfil, 2nd will take the modulo
							if stackCountInBag + qtyToMove <= maxQtyAuthorized then --Already too late!
								if destSlot then
									--d("2 push to do -> destSlot1:" .. destSlot)
									itemMoved = moveItemInSlot(moveData.bagId, moveData.slotId, bagIdTo, destSlot, qtyToMove, moveData.itemLink)
								elseif db.profiles[actualProfile].detailledNotMoved then
									PrintItemsNotMovedToBag(moveData.itemLink, moveData.itemIcon, bagIdTo, qtyToMove)
								end
								
								-- Maybe move1 hit the limit?
								if stackCountInBag + qtyToMove < db.profiles[actualProfile].rules[moveData.ruleName].onlyStacks * maxStack then
									destSlot = FindEmptySlotInBag(bagIdTo)
									if destSlot then
										--d("2 push to do -> destSlot2:" .. destSlot)
										itemMoved = moveItemInSlot(moveData.bagId, moveData.slotId, bagIdTo, destSlot, stackSize - qtyToMove, moveData.itemLink)
										qtyToMove = stackSize -- to Display the correct value
									elseif db.profiles[actualProfile].detailledNotMoved then
										PrintItemsNotMovedToBag(moveData.itemLink, moveData.itemIcon, bagIdTo, qtyToMove)
									end
								end
							end
						end
						
					end
				
				end
				
				if (itemMoved) then
					qtyMoved = qtyMoved + qtyToMove
					countMoved = countMoved + 1
					itemsMoved = itemsMoved + 1
					if db.profiles[actualProfile].detailledDisplay then
						PrintItemsToBag(moveData.itemLink, moveData.itemIcon, bagIdTo, qtyToMove)
					end
				end
				
				zo_callLater(function() tryMoveSlots(data, bagIdTo, restartAt + 1) end, db.profiles[actualProfile].pauseInMs)
				
			else
				
				CHAT_SYSTEM:AddMessage(GetString(BMR_ZOS_LIMITATIONS))
				pushInProgress = false -- Don't do pull
				
				-- End of moves
				if qtyMoved > 0 then
					if db.profiles[actualProfile].summary then
						PrintSummaryToBag(bagIdTo, countMoved, qtyMoved)
					end
				end
				
				FinishBankMoves()
				return
				
			end
		elseif pushInProgress then
			
			-- End of push
			pushInProgress = false
			
			if qtyMoved > 0 then
				if db.profiles[actualProfile].summary then
					PrintSummaryToBag(bagIdTo, countMoved, qtyMoved)
				end
			end
			
			qtyMoved = 0
			countMoved = 0
			
			freeSlots[BAG_BACKPACK] = GetNumBagFreeSlots(BAG_BACKPACK)
			zo_callLater(function() tryMoveSlots(pullQueue, BAG_BACKPACK) end, db.profiles[actualProfile].pauseInMs)
			
		else
			
			-- End of pull
			if qtyMoved > 0 then
				if db.profiles[actualProfile].summary then
					PrintSummaryToBag(bagIdTo, countMoved, qtyMoved)
				end
			end
			
			FinishBankMoves()
			
		end
	
	end
	
	local function doSingleMove(moveData)
		
		if db.profiles[actualProfile].rules[moveData.ruleName].associatedGuild and db.profiles[actualProfile].rules[moveData.ruleName].associatedGuild == currentGBankName then
		
			--d(moveData.ruleName .. " will check qty and if, move " .. GetItemName(moveData.bagId, moveData.slotId))
					
			-- Is slot at max size in bank ?
			local isFullStack, stackSize, maxStack, stackCountBackpack, stackCountBank = StackInfoInBag(BAG_BANK, moveData.slotId, moveData.bagId, moveData.itemLink)
			local itemMoved = false
			local qtyToMove
			
			if db.profiles[actualProfile].rules[moveData.ruleName].onlyStacks == true
			or db.profiles[actualProfile].rules[moveData.ruleName].onlyStacks == false then
				db.profiles[actualProfile].rules[moveData.ruleName].onlyStacks = 1
			end
			
			if db.profiles[actualProfile].rules[moveData.ruleName].action == ACTION_PUSH_GBANK then
				
				--d(moveData.ruleName .. " is set to push everything to GBank (ACTION_PUSH_GBANK)")
				
				qtyToMove = stackSize
				if GetNumBagFreeSlots(BAG_GUILDBANK) > 0 then
					itemMoved = moveItemInGBank(moveData.bagId, moveData.slotId)
				elseif db.profiles[actualProfile].detailledNotMoved then
					PrintItemsNotMovedToBag(moveData.itemLink, moveData.itemIcon, BAG_GUILDBANK, qtyToMove, currentGBankName)
				end
			
			elseif db.profiles[actualProfile].rules[moveData.ruleName].onlyIfNotFullStack and stackSize + stackCountBank > maxStack then
				
				qtyToMove = math.min(stackSize, stackCountBank + stackSize - maxStack)
				
				--d("qtyToMove " .. qtyToMove)
				if GetNumBagFreeSlots(BAG_GUILDBANK) > 0 then
					if qtyToMove == stackSize then
						itemMoved = moveItemInGBank(moveData.bagId, moveData.slotId)
					else
						-- Qty is not available when transfering to GBank, it's a full slot
						itemMoved = moveItemInGBank(moveData.bagId, moveData.slotId, qtyToMove, moveData.itemLink)
					end
				elseif db.profiles[actualProfile].detailledNotMoved then
					PrintItemsNotMovedToBag(moveData.itemLink, moveData.itemIcon, BAG_GUILDBANK, qtyToMove, currentGBankName)
				end
			
			elseif (not db.profiles[actualProfile].rules[moveData.ruleName].onlyIfNotFullStack) and stackSize + stackCountBank > db.profiles[actualProfile].rules[moveData.ruleName].onlyStacks * maxStack then
				
				qtyToMove = math.min(stackSize, stackCountBank + stackSize - maxStack)
				
				--d("qtyToMove " .. qtyToMove)
				if GetNumBagFreeSlots(BAG_GUILDBANK) > 0 then
					if qtyToMove == stackSize then
						itemMoved = moveItemInGBank(moveData.bagId, moveData.slotId)
					else
						-- Qty is not available when transfering to GBank, it's a full slot
						itemMoved = moveItemInGBank(moveData.bagId, moveData.slotId, qtyToMove, moveData.itemLink)
					end
				elseif db.profiles[actualProfile].detailledNotMoved then
					PrintItemsNotMovedToBag(moveData.itemLink, moveData.itemIcon, BAG_GUILDBANK, qtyToMove, currentGBankName)
				end
			
			end
			
			if (itemMoved) then
				if db.profiles[actualProfile].detailledDisplay then
					PrintItemsToBag(moveData.itemLink, moveData.itemIcon, BAG_GUILDBANK, qtyToMove, currentGBankName)
				end
			else
				--d("Nothing moved for " .. GetItemName(moveData.bagId, moveData.slotId))
			end
			
			return itemMoved, qtyToMove
			
		else
			--d("Incorrect GBank for rule " .. moveData.ruleName)
		end
		
		return false
		
	end
	
	local function tryMoveSlotsToGBank()
		
		-- Need to push/pull?
		if #pushQueue > 0 then
			--d("#pushQueue " .. tostring(restartFromAtGBank) .. "/" .. tostring(#pushQueue))
			
			-- We can't loop for GBank, because we need to wait for server response, so use next()
			local moveIndex, moveData = next(pushQueue, restartFromAtGBank)
			--d("moveIndex = " .. tostring(moveIndex))
			
			if moveIndex then
				
				local itemMoved
				-- Even if itemMoved is true, it does not garantee that it has been really moved. It has just been Transfered to GBank
				local itemMoved, qtyMoved = doSingleMove(moveData)
				
				-- It will make the loop
				restartFromAtGBank = moveIndex
				
				-- If we didn't moved our item, EVENT_MANAGER won't send anything.
				if (not itemMoved) then
					tryMoveSlotsToGBank()
				else
					qtyMovedToGBank = qtyMovedToGBank + qtyMoved
					countMovedToGBank = countMovedToGBank + 1
				end

			else

				if qtyMovedToGBank > 0 then
					
					if db.profiles[actualProfile].summary then
						PrintSummaryToBag(BAG_GUILDBANK, countMovedToGBank, qtyMovedToGBank, currentGBankName)
					end
					
					-- Do a Roomba if the Addon is detected
					if Roomba and Roomba.BeginStackingProcess then Roomba.BeginStackingProcess() end
					
				end
				
				--d("End of loop")
				onCloseProcessAtGBank()
				
			end
			
		end
	
	end
	
	if atGBank then
		
		freeSlots[BAG_BACKPACK] = GetNumBagFreeSlots(BAG_BACKPACK)
		
		if not errorReasonAtGBank then
			tryMoveSlotsToGBank(errorReasonAtGBank)
		elseif errorReasonAtGBank == GUILD_BANK_TRANSFER_PENDING then -- Bank is busy, retry
			restartFromAtGBank = restartFromAtGBank - 1
			tryMoveSlotsToGBank()
		elseif errorReasonAtGBank == GUILD_BANK_NO_SPACE_LEFT then -- While we are interacting, other move can be done simultaneously
			onCloseProcessAtGBank()
		else
			tryMoveSlotsToGBank()
		end
		
	else
		
		freeSlots[BAG_BANK] = GetNumBagFreeSlots(BAG_BANK)
		tryMoveSlots(pushQueue, BAG_BANK)
		
	end
	
end

-- Move a currency
local function moveCurrency(ruleName, currencyType)
	
	-- Our currencies
	local currentCurrencyInInventory = GetCarriedCurrencyAmount(currencyType)
   local currentCurrencyInBank = GetBankedCurrencyAmount(currencyType)
	
	local inverted = db.profiles[actualProfile].rules[ruleName].keepInBank
	
	if (inverted) then
		-- Do I need to pull or push? If Inverted, addon push to inventory and pull from inventory
		local pushCurrency = currentCurrencyInBank > db.profiles[actualProfile].rules[ruleName].qtyToPush and (db.profiles[actualProfile].rules[ruleName].qtyToPush > 0 or (db.profiles[actualProfile].rules[ruleName].keepNothing and db.profiles[actualProfile].rules[ruleName].qtyToPush == 0))
		local pullCurrency = db.profiles[actualProfile].rules[ruleName].qtyToPull > 0 and currentCurrencyInBank < db.profiles[actualProfile].rules[ruleName].qtyToPull and currentCurrencyInInventory > 0
		
		if pullCurrency then
			local currencyToDeposit = db.profiles[actualProfile].rules[ruleName].qtyToPull - currentCurrencyInBank
			currencyToDeposit = math.min(currencyToDeposit, currentCurrencyInInventory)
			
			DepositCurrencyIntoBank(currencyType, currencyToDeposit)
			PrintCurrencyToBank(currencyType, currencyToDeposit)	
		elseif pushCurrency then
			local currencyToWithdraw = currentCurrencyInBank - db.profiles[actualProfile].rules[ruleName].qtyToPush		
			WithdrawCurrencyFromBank(currencyType, currencyToWithdraw)
			PrintCurrencyToBag(currencyType, currencyToWithdraw)
		end
	else
		-- Do I need to pull or push?
		local pushCurrency = currentCurrencyInInventory > db.profiles[actualProfile].rules[ruleName].qtyToPush and (db.profiles[actualProfile].rules[ruleName].qtyToPush > 0 or (db.profiles[actualProfile].rules[ruleName].keepNothing and db.profiles[actualProfile].rules[ruleName].qtyToPush == 0))
		local pullCurrency = db.profiles[actualProfile].rules[ruleName].qtyToPull > 0 and currentCurrencyInInventory < db.profiles[actualProfile].rules[ruleName].qtyToPull and currentCurrencyInBank > 0
		
		if pullCurrency then
			local currencyToWithdraw = db.profiles[actualProfile].rules[ruleName].qtyToPull - currentCurrencyInInventory
			currencyToWithdraw = math.min(currencyToWithdraw, currentCurrencyInBank)
			
			WithdrawCurrencyFromBank(currencyType, currencyToWithdraw)
			PrintCurrencyToBag(currencyType, currencyToWithdraw)	
		elseif pushCurrency then
			local currencyToDeposit = currentCurrencyInInventory - db.profiles[actualProfile].rules[ruleName].qtyToPush		
			DepositCurrencyIntoBank(currencyType, currencyToDeposit)
			PrintCurrencyToBank(currencyType, currencyToDeposit)
		end
	end

end

-- Move currencies
local function moveCurrencies()
	moveCurrency("currency" .. CURT_MONEY, CURT_MONEY)
	moveCurrency("currency" .. CURT_TELVAR_STONES, CURT_TELVAR_STONES)
end

-- move currencies, prepare items, build push/pull queue and move items
local function interactWithBank()
	
	if (not inProgress) then
		inProgress = true
		
		moveCurrencies()
		dataSorted = sortByKeyAndPosition(BankManagerRules.data)
		
		-- Prepare items, check if they must be moved and queue them
		for slotIndex in pairs(SHARED_INVENTORY.bagCache[BAG_BACKPACK]) do
			if not movedItems[BAG_BACKPACK][slotIndex] then
				prepareItem(BAG_BACKPACK, slotIndex)
			end
		end
		--d(GetGameTimeMilliseconds() - startTimeInMs)
		
		if db.profiles[actualProfile].rules["writsQuests"].specialEnabled then
			BuildWritsItems()
		end
		
		-- Prepare items, check if they must be moved and queue them
		if hasAnyPullToDo or hasAnySpecialPullToDo then -- Has already been check in 1st loop
			for slotIndex in pairs(SHARED_INVENTORY.bagCache[BAG_BANK]) do
				if not movedItems[BAG_BANK][slotIndex] then
					prepareItem(BAG_BANK, slotIndex)
				end
			end
		end
		--d(GetGameTimeMilliseconds() - startTimeInMs)
		
		-- items have been queued
		if #pushQueue > 0 or #pullQueue > 0 then
			moveItems() -- zo_CallLater inside, nothing behind this line should be run, but inside it.
		end
		
		--d(GetGameTimeMilliseconds() - startTimeInMs)
		
	end
	
end

-- Display UI with arrows if needed
local function displayUI(multipleProfiles)
	
	local ruleName = db.profiles[actualProfile].name
	
	if ruleName == "" then
		ruleName = zo_strformat(BMR_PROFILE, actualProfile)
	end
	
	if multipleProfiles then
		BankManager:GetNamedChild("Before"):SetHidden(false)
		BankManager:GetNamedChild("After"):SetHidden(false)
	else
		BankManager:GetNamedChild("Before"):SetHidden(true)
		BankManager:GetNamedChild("After"):SetHidden(true)
	end
	
	BankManager:GetNamedChild("RuleName"):SetText(ruleName)
	BankManager:SetHidden(false)

end

-- Move to previous/next rule
local function nextRule(step)
	
	local changed
	for i=actualProfile+step, 9, step do
		if db.profiles[i].defined then
			changed = true
			actualProfile = i
			break
		end
	end
	
	if not changed then
		actualProfile = 1
	end
	
	db.actualProfile = actualProfile
	
	-- Sync LAM
	CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", panel)
		
	local ruleName = db.profiles[actualProfile].name
	
	if ruleName == "" then
		ruleName = zo_strformat(BMR_PROFILE, actualProfile)
	end
	
	BankManager:GetNamedChild("RuleName"):SetText(ruleName)

end

-- onSingleSlotUpdate (only between onOpenBank and onOpenBank+2s)
local function onSingleSlotUpdate(_, bagId, slotId)
	
	-- if not, item has been moved elsewhere? We can't use SHARED_INVENTORY, it's still not updated.
	if GetItemType(bagId, slotId) ~= ITEMTYPE_NONE then
		if not movedItems[bagId] then movedItems[bagId] = {} end -- Handle other moves. BAG_WORN per exemple
		movedItems[bagId][slotId] = true
	end
	
end

-- onOpenBank
local function onOpenBank()
	
	isBanking = true
	
	-- Trace all items moved by another addon while BMR waits
	if db.profiles[actualProfile].moved then
		EVENT_MANAGER:RegisterForEvent(addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onSingleSlotUpdate)
	end
	
	-- CallLater to let the bagCache be refreshed by core UI
	zo_callLater(function()
		
		-- Stop tracing
		if db.profiles[actualProfile].moved then
			EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		end
		
		if isBanking then
		
			local multipleProfiles = false
			
			for i=2, 9 do
				if db.profiles[i].defined == true then
					multipleProfiles = true
					break
				end
			end
			
			-- Display UI only if 2 profiles are defined or if actual is on manual mode
			if not db.profiles[actualProfile].autoTransfert or multipleProfiles then
				displayUI(multipleProfiles)
			end
			
			if db.profiles[actualProfile].autoTransfert then
				interactWithBank()
			end
			
		end
	end, (db.profiles[actualProfile].initialWaitInSecs * 1000))
	
end

-- onCloseBank, resets
local function onCloseBank()
	
	isBanking = false	
	hasAnyPullToDo = nil
	pushQueue = {}
	pullQueue = {}
	movedItems = {
		[BAG_BACKPACK] = {},
		[BAG_BANK] = {},
	}
	
	inProgress = false	
	BankManager:SetHidden(true)
	
end

local function doInteractionWithGBank()
	
	if (not inProgress) then
		inProgress = true
		
		dataSorted = sortByKeyAndPosition(BankManagerRules.data)
		
		-- Prepare items, check if they must be moved and queue them
		for slotIndex, slotdata in pairs(SHARED_INVENTORY.bagCache[BAG_BACKPACK]) do
			if not movedItems[BAG_BACKPACK][slotIndex] then
				prepareItem(BAG_BACKPACK, slotIndex, checkingGBank)
			end
		end
		
		-- items have been queued
		if #pushQueue > 0 then
			
			--d("Registering events")
			-- This will make the loop, because GBank cannot be looped
			EVENT_MANAGER:RegisterForEvent(addonName, EVENT_GUILD_BANK_TRANSFER_ERROR, function() moveItems(true) end)
			EVENT_MANAGER:RegisterForEvent(addonName, EVENT_GUILD_BANK_ITEM_ADDED, function(_, errorReason) moveItems(true, errorReason) end)
		
			moveItems(true)
		else
			inProgress = false
		end

	end
	
end

-- interactWithGBank
local function interactWithGBank()

	-- The permission is maybe not allowed
	if DoesPlayerHaveGuildPermission(currentGBank, GUILD_PERMISSION_BANK_DEPOSIT) then
		
		local multipleProfiles = false
		
		for i=2, 9 do
			if db.profiles[i].defined == true then
				multipleProfiles = true
				break
			end
		end
		
		-- Display UI only if 2 profiles are defined or if actual is on manual mode
		if not db.profiles[actualProfile].autoTransfert or multipleProfiles then
			displayUI(multipleProfiles)
		end
		
		if db.profiles[actualProfile].autoTransfert then
			doInteractionWithGBank()
		end
		
	end
	
end

-- onGuildBankItemsReallyReady
local function onGuildBankItemsReallyReady()
	
	-- Because EVENT_GUILD_BANK_ITEMS_READY fires multiple times
	if (not checkingGBank) then
		checkingGBank = true
		interactWithGBank()
	end
	
end

-- onGuildBankItemsReady
local function onGuildBankItemsReady()
	-- Guild bank is evented to be ready, but wait a short while before processing. (multiple readys for big banks ~3/4)
	zo_callLater(onGuildBankItemsReallyReady, (db.profiles[actualProfile].initialWaitInSecs * 1000))
end

-- onGuildBankSelected
local function onGuildBankSelected(_, guildId)

	BankManager:SetHidden(true)
	checkingGBank = false
	currentGBank = guildId
	currentGBankName = GetGuildName(currentGBank)
	
	EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_GUILD_BANK_TRANSFER_ERROR)
	EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_GUILD_BANK_ITEM_ADDED)
	
end

-- onCloseGuildBank
local function onCloseGuildBank()

	checkingGBank = false
	currentGBank = nil
	currentGBankName = nil
	onCloseProcessAtGBank()
	BankManager:SetHidden(true)
	
end

-- Build 1 currency Panel for LAM
local function panelCurrencyPush(ruleName)

	local optionPanel = {
		type = "slider",
		name = GetString(BMR_CURRENCY_PUSH),
		tooltip = GetString(BMR_CURRENCY_PUSH_TOOLTIP),
		min = BankManagerRules.data[ruleName].min,
		max = BankManagerRules.data[ruleName].max,
		step = BankManagerRules.data[ruleName].step,
		getFunc = function() return db.profiles[actualProfile].rules[ruleName].qtyToPush end,
		setFunc = function(newValue) db.profiles[actualProfile].rules[ruleName].qtyToPush = newValue end,
		default = 0,
	}
	
	return optionPanel

end

-- Build 1 currency Panel for LAM
local function panelCurrencyPull(ruleName)

	local optionPanel = {
		type = "slider",
		name = GetString(BMR_CURRENCY_PULL),
		tooltip = GetString(BMR_CURRENCY_PULL_TOOLTIP),
		min = BankManagerRules.data[ruleName].min,
		max = BankManagerRules.data[ruleName].max,
		step = BankManagerRules.data[ruleName].step,
		getFunc = function() return db.profiles[actualProfile].rules[ruleName].qtyToPull end,
		setFunc = function(newValue) db.profiles[actualProfile].rules[ruleName].qtyToPull = newValue end,
		default = 0,
	}
	
	return optionPanel

end

-- Build 1 currency "Keep Nothing currency" for LAM
local function panelCurrencyNothing(ruleName, currencyType)

	local optionPanel = {
		type = "checkbox",
		name = zo_strformat(BMR_CURRENCY_NOTHING, GetString("SI_CURRENCYTYPE", currencyType)),
		tooltip = zo_strformat(BMR_CURRENCY_NOTHING_TOOLTIP, GetString("SI_CURRENCYTYPE", currencyType)),
		getFunc = function() return db.profiles[actualProfile].rules[ruleName].keepNothing end,
		setFunc = function(newValue) db.profiles[actualProfile].rules[ruleName].keepNothing = newValue end,
		default = false,
		disabled = function()
			-- db is not yet initialized
			if not db.profiles[actualProfile].rules[ruleName].qtyToPush then
				return false
			else
				return db.profiles[actualProfile].rules[ruleName].qtyToPush > 0
			end
		end,
	}
	
	return optionPanel

end

-- Build 1 currency "Keep in Bank Instead" for LAM
local function panelCurrencyKeepInBankInstead(ruleName, currencyType)

	local optionPanel = {
		type = "checkbox",
		name = zo_strformat(BMR_CURRENCY_KEEP_IN_BANK, GetString("SI_CURRENCYTYPE", currencyType)),
		tooltip = zo_strformat(BMR_CURRENCY_KEEP_IN_BANK_TOOLTIP, GetString("SI_CURRENCYTYPE", currencyType)),
		getFunc = function() return db.profiles[actualProfile].rules[ruleName].keepInBank end,
		setFunc = function(newValue) db.profiles[actualProfile].rules[ruleName].keepInBank = newValue end,
		default = false,
	}
	
	return optionPanel

end

-- Build 1 optionPanel for LAM
local function panelRule(ruleName)
	
	if BankManagerRules.data[ruleName] then
		local choices = {}
		choices[ACTION_NOTSET] = GetString(BMR_ACTION_NOTSET)
		choices[ACTION_PUSH] = GetString(BMR_ACTION_PUSH)
		choices[ACTION_PULL] = GetString(BMR_ACTION_PULL)
		choices[ACTION_PUSH_GBANK] = GetString(BMR_ACTION_PUSH_GBANK)
		choices[ACTION_PUSH_BOTH] = GetString(BMR_ACTION_PUSH_BOTH)
		
		local reverseChoices = {}
		reverseChoices[GetString(BMR_ACTION_NOTSET)]	= ACTION_NOTSET
		reverseChoices[GetString(BMR_ACTION_PUSH)] = ACTION_PUSH
		reverseChoices[GetString(BMR_ACTION_PULL)] = ACTION_PULL
		reverseChoices[GetString(BMR_ACTION_PUSH_GBANK)] = ACTION_PUSH_GBANK
		reverseChoices[GetString(BMR_ACTION_PUSH_BOTH)] = ACTION_PUSH_BOTH
		
		local optionPanel = {
			type = "dropdown",
			name = BankManagerRules.data[ruleName].name,
			tooltip = BankManagerRules.data[ruleName].tooltip,
			choices = {GetString(BMR_ACTION_NOTSET), GetString(BMR_ACTION_PUSH), GetString(BMR_ACTION_PULL), GetString(BMR_ACTION_PUSH_GBANK), GetString(BMR_ACTION_PUSH_BOTH)},
			getFunc = function() return choices[db.profiles[actualProfile].rules[ruleName].action] end,
			setFunc = function(value)
				if reverseChoices[value] then
					db.profiles[actualProfile].rules[ruleName].action = reverseChoices[value]
				else
					db.profiles[actualProfile].rules[ruleName].action = ACTION_NOTSET
				end
			end,
			default = GetString(BMR_ACTION_NOTSET),
		}
		
		return optionPanel
	end
	
end

-- Build the "Only if not full stack" optionPanel
local function panelOnlyIfNotFullStack(ruleNamePatern, ruleNameToFollow)

	local optionPanel = {
		type = "checkbox",
		name = GetString(BMR_ONLY_IF_NOT_FULL_STACK),
		tooltip = GetString(BMR_ONLY_IF_NOT_FULL_STACK_TOOLTIP),
		getFunc = function() return db.profiles[actualProfile].rules[ruleNameToFollow].onlyIfNotFullStack end,
		setFunc = function(value)
			for optionName, optionData in pairs(db.profiles[actualProfile].rules) do
				if type(optionData) == "table" then
					if string.find(optionName, ruleNamePatern) then
						optionData.onlyIfNotFullStack = value
					end
				end
			end
			db.profiles[actualProfile].rules[ruleNameToFollow].onlyIfNotFullStack = value
		end,
		width = "half",
		default = true,
	}
	
	return optionPanel

end

-- Build the "Max Stacks" optionPanel
local function panelMaxStacks(ruleNamePatern, onlyIfNotFullStackToFollow, ruleNameToFollow)

	local optionPanel = {
		type = "slider",
		name = GetString(BMR_MAX_STACK),
		tooltip = GetString(BMR_MAX_STACK_TOOLTIP),
		min = 1,
		max = 10,
		getFunc = function() return db.profiles[actualProfile].rules[ruleNameToFollow].onlyStacks end,
		setFunc = function(value)
			for optionName, optionData in pairs(db.profiles[actualProfile].rules) do
				if type(optionData) == "table" then
					if string.find(optionName, ruleNamePatern) then
						--d("Changing " .. optionName)
						optionData.onlyStacks = value -- Don't know why sometimes this value is set to true and not value ?
					end
				end
			end
			db.profiles[actualProfile].rules[ruleNameToFollow].onlyStacks = value
		end,
		default = true,
		disabled = function()
			if not db.profiles[actualProfile].rules[onlyIfNotFullStackToFollow].onlyIfNotFullStack then
				return false
			else
				return db.profiles[actualProfile].rules[onlyIfNotFullStackToFollow].onlyIfNotFullStack
			end
		end,
	}
	
	return optionPanel

end

-- List all active guilds
local function listOfActiveGuilds()

	guildList = {GetString(BMR_ACTION_NOTSET)}
	if GetNumGuilds() > 0 then
		for guild = 1, GetNumGuilds() do
			local guildId = GetGuildId(guild)
			local guildName = GetGuildName(guildId)
			if(not guildName or (guildName):len() < 1) then
				guildName = "Guild " .. guildId
			end
			table.insert(guildList, guildName)
		end
	end
	
end

-- Will change the name of the associatedGuild for all rules who match ruleNamePatern
local function panelGuildBank(ruleNamePatern, ruleNameToFollow)

	local optionPanel = {
		type = "dropdown",
		name = GetString(BMR_GUILD_LIST),
		tooltip = GetString(BMR_GUILD_LIST_TOOLTIP),
		choices = guildList,
		getFunc = function() return db.profiles[actualProfile].rules[ruleNameToFollow].associatedGuild end,
		setFunc = function(value)
			for optionName, optionData in pairs(db.profiles[actualProfile].rules) do
				if type(optionData) == "table" then
					if string.find(optionName, ruleNamePatern) then
						optionData.associatedGuild = value
					end
				end
			end
			db.profiles[actualProfile].rules[ruleNameToFollow].associatedGuild = value
		end,
		width = "half",
		default = GetString(BMR_ACTION_NOTSET),
	}
	
	return optionPanel

end

local function panelSpecialFilter(ruleName)
	
	local specialConvert = {
		writsQuests = {writsQuests = true, writsQuestsGlyphs = true, writsQuestsPots = true}
	}
	
	local optionPanel = {
		type = "checkbox",
		name = BankManagerRules.data[ruleName].name,
		tooltip = BankManagerRules.data[ruleName].tooltip,
		getFunc = function() return db.profiles[actualProfile].rules[ruleName].specialEnabled end,
		setFunc = function(newValue)
		
			for ruleNameToFollow, rulesData in pairs(specialConvert) do
				if type(rulesData) == "table" and ruleNameToFollow == ruleName then
					for realRule in pairs(rulesData) do
						if newValue then
							db.profiles[actualProfile].rules[realRule].action = ACTION_PULL
							db.profiles[actualProfile].rules[realRule].specialEnabled = newValue
						else
							db.profiles[actualProfile].rules[realRule].action = ACTION_NOTSET
							db.profiles[actualProfile].rules[realRule].specialEnabled = newValue
						end
					end
				end
			end
			
		end,
		default = false,
	}
	
	return optionPanel
	
end

-- Build a LAM SubMenu with a list of filters
local function LAMSubmenu(subMenu)

	local submenuControls = {}
	
	if subMenu == "gold" then
		table.insert(submenuControls, panelCurrencyPush("currency" .. CURT_MONEY))
		table.insert(submenuControls, panelCurrencyPull("currency" .. CURT_MONEY))
		table.insert(submenuControls, panelCurrencyNothing("currency" .. CURT_MONEY, CURT_MONEY))
		table.insert(submenuControls, panelCurrencyKeepInBankInstead("currency" .. CURT_MONEY, CURT_MONEY))
		
	elseif subMenu == "tvstones" then
		table.insert(submenuControls, panelCurrencyPush("currency" .. CURT_TELVAR_STONES))
		table.insert(submenuControls, panelCurrencyPull("currency" .. CURT_TELVAR_STONES))
		table.insert(submenuControls, panelCurrencyNothing("currency" .. CURT_TELVAR_STONES, CURT_TELVAR_STONES))
		table.insert(submenuControls, panelCurrencyKeepInBankInstead("currency" .. CURT_TELVAR_STONES, CURT_TELVAR_STONES))
	
	-- Traits
	elseif subMenu == "traits" then
		
		-- Adding our toplevel LAM controls
		table.insert(submenuControls, panelOnlyIfNotFullStack("trait", "traitAll"))
		table.insert(submenuControls, panelGuildBank("trait", "traitGBank"))
		
		table.insert(submenuControls, panelMaxStacks("trait", "traitAll", "traitStacks"))
		table.insert(submenuControls, panelRule("traitAll"))
		
		-- Horizontal Divider
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		
		-- Courtesy of Dustman (Garkin)
		for traitItemIndex = 1, GetNumSmithingTraitItems() do
			local traitType, itemName = GetSmithingTraitItemInfo(traitItemIndex)
			local itemLink = GetSmithingTraitItemLink(traitItemIndex, LINK_STYLE_DEFAULT)
			local itemType = GetItemLinkItemType(itemLink)
			if itemType ~= ITEMTYPE_NONE and traitType ~= ITEM_TRAIT_TYPE_NONE then
				table.insert(submenuControls, panelRule("trait" .. traitType))
			end
		end
	
	-- Styles
	elseif subMenu == "styles" then
	
		table.insert(submenuControls, panelOnlyIfNotFullStack("style", "styleAll"))
		table.insert(submenuControls, panelGuildBank("style", "styleGBank"))
		
		table.insert(submenuControls, panelMaxStacks("style", "styleAll", "styleStacks"))
		table.insert(submenuControls, panelRule("styleAll"))
		
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		for styleId, data in pairs(BankManagerRules.static.rawStyles) do
			table.insert(submenuControls, panelRule("styleRaw" .. styleId))
		end
		
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		for stylesItemIndex = 1, GetNumSmithingStyleItems() do
			local _, _, _, meetsUsageRequirement, itemStyle = GetSmithingStyleItemInfo(stylesItemIndex)
			if meetsUsageRequirement and itemStyle ~= ITEMSTYLE_UNIVERSAL then
				table.insert(submenuControls, panelRule("style" .. itemStyle))
			end
		end
	
	-- Blacksmithing
	elseif subMenu == "blacksmithing" then
		
		-- Here there is no "All" ruleset to rule them all, so we have created in BankManagerRules a false rule which will handle this setting
		-- 1st value is the pattern of filters to control, 2nd arg is the Lua Var to store the global value
		table.insert(submenuControls, panelOnlyIfNotFullStack("improvement" .. CRAFTING_TYPE_BLACKSMITHING, "improvementAll" .. CRAFTING_TYPE_BLACKSMITHING))
		table.insert(submenuControls, panelGuildBank("improvement" .. CRAFTING_TYPE_BLACKSMITHING, "improvementGBank" .. CRAFTING_TYPE_BLACKSMITHING))
		table.insert(submenuControls, panelMaxStacks("improvement" .. CRAFTING_TYPE_BLACKSMITHING, "improvementAll" .. CRAFTING_TYPE_BLACKSMITHING, "improvementStacks" .. CRAFTING_TYPE_BLACKSMITHING))
		
		for improvementItemIndex = 1, GetNumSmithingImprovementItems() do
			table.insert(submenuControls, panelRule("improvement" .. CRAFTING_TYPE_BLACKSMITHING .. improvementItemIndex))
		end
		
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		
		table.insert(submenuControls, panelRule("armorTypeWeight" .. ARMORTYPE_HEAVY))
		table.insert(submenuControls, panelRule("armorTypeTrait" .. ITEM_TRAIT_TYPE_ARMOR_INTRICATE .. "Weight" .. ARMORTYPE_HEAVY))
		table.insert(submenuControls, panelRule("armorTypeResearchableWeight" .. ARMORTYPE_HEAVY))
		table.insert(submenuControls, panelRule("weaponType" .. CRAFTING_TYPE_BLACKSMITHING))
		table.insert(submenuControls, panelRule("weaponType" .. CRAFTING_TYPE_BLACKSMITHING .. "Trait" .. ITEM_TRAIT_TYPE_ARMOR_INTRICATE))
		table.insert(submenuControls, panelRule("weaponTypeResearchable" .. CRAFTING_TYPE_BLACKSMITHING))
		
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		table.insert(submenuControls, panelOnlyIfNotFullStack("Material[A]?[l]?[l]?" .. CRAFTING_TYPE_BLACKSMITHING, "MaterialAll" .. CRAFTING_TYPE_BLACKSMITHING))
		table.insert(submenuControls, panelGuildBank("Material[A]?[l]?[l]?" .. CRAFTING_TYPE_BLACKSMITHING, "MaterialGBank" .. CRAFTING_TYPE_BLACKSMITHING))
		-- Adding a Max Stack Slider. It will follow "MaterialAll" .. CRAFTING_TYPE_BLACKSMITHING to know if the slider should be disabled or not.
		table.insert(submenuControls, panelMaxStacks("Material[A]?[l]?[l]?" .. CRAFTING_TYPE_BLACKSMITHING, "MaterialAll" .. CRAFTING_TYPE_BLACKSMITHING, "MaterialStacks" .. CRAFTING_TYPE_BLACKSMITHING))
		table.insert(submenuControls, panelRule("MaterialAll" .. CRAFTING_TYPE_BLACKSMITHING))
		table.insert(submenuControls, panelRule("refinedMaterialAll" .. CRAFTING_TYPE_BLACKSMITHING))
		table.insert(submenuControls, panelRule("rawMaterialAll" .. CRAFTING_TYPE_BLACKSMITHING))
		
		for materialIndex = 1, #BankManagerRules.static.refinedMaterial[CRAFTING_TYPE_BLACKSMITHING] do
			if BankManagerRules.static.refinedMaterial[CRAFTING_TYPE_BLACKSMITHING][materialIndex] ~= "" then
				table.insert(submenuControls, panelRule("refinedMaterial" .. CRAFTING_TYPE_BLACKSMITHING .. materialIndex))
			end
			if BankManagerRules.static.rawMaterial[CRAFTING_TYPE_BLACKSMITHING][materialIndex] ~= "" then
				table.insert(submenuControls, panelRule("rawMaterial" .. CRAFTING_TYPE_BLACKSMITHING .. materialIndex))
			end
		end
	
	-- Clothier
	elseif subMenu == "clothier" then
	
		table.insert(submenuControls, panelOnlyIfNotFullStack("improvement" .. CRAFTING_TYPE_CLOTHIER, "improvementAll" .. CRAFTING_TYPE_CLOTHIER))
		table.insert(submenuControls, panelGuildBank("improvement" .. CRAFTING_TYPE_CLOTHIER, "improvementGBank" .. CRAFTING_TYPE_CLOTHIER))
		table.insert(submenuControls, panelMaxStacks("improvement" .. CRAFTING_TYPE_CLOTHIER, "improvementAll" .. CRAFTING_TYPE_CLOTHIER, "improvementStacks" .. CRAFTING_TYPE_CLOTHIER))
		for improvementItemIndex = 1, GetNumSmithingImprovementItems() do
			table.insert(submenuControls, panelRule("improvement" .. CRAFTING_TYPE_CLOTHIER .. improvementItemIndex))
		end
		
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		table.insert(submenuControls, panelRule("armorTypeWeight" .. ARMORTYPE_LIGHT))
		table.insert(submenuControls, panelRule("armorTypeTrait" .. ITEM_TRAIT_TYPE_ARMOR_INTRICATE .. "Weight" .. ARMORTYPE_LIGHT))
		table.insert(submenuControls, panelRule("armorTypeResearchableWeight" .. ARMORTYPE_LIGHT))
		table.insert(submenuControls, panelRule("armorTypeWeight" .. ARMORTYPE_MEDIUM))
		table.insert(submenuControls, panelRule("armorTypeTrait" .. ITEM_TRAIT_TYPE_ARMOR_INTRICATE .. "Weight" .. ARMORTYPE_MEDIUM))
		table.insert(submenuControls, panelRule("armorTypeResearchableWeight" .. ARMORTYPE_MEDIUM))
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		
		table.insert(submenuControls, panelOnlyIfNotFullStack("Material[A]?[l]?[l]?" .. CRAFTING_TYPE_CLOTHIER, "MaterialAll" .. CRAFTING_TYPE_CLOTHIER))
		table.insert(submenuControls, panelGuildBank("Material[A]?[l]?[l]?" .. CRAFTING_TYPE_CLOTHIER, "MaterialGBank" .. CRAFTING_TYPE_CLOTHIER))
		table.insert(submenuControls, panelMaxStacks("Material[A]?[l]?[l]?" .. CRAFTING_TYPE_CLOTHIER, "MaterialAll" .. CRAFTING_TYPE_CLOTHIER, "MaterialStacks" .. CRAFTING_TYPE_CLOTHIER))
		table.insert(submenuControls, panelRule("MaterialAll" .. CRAFTING_TYPE_CLOTHIER))
		table.insert(submenuControls, panelRule("refinedMaterialAll" .. CRAFTING_TYPE_CLOTHIER))
		table.insert(submenuControls, panelRule("rawMaterialAll" .. CRAFTING_TYPE_CLOTHIER))
		
		for materialIndex = 1, #BankManagerRules.static.refinedMaterial[CRAFTING_TYPE_CLOTHIER] do
			if BankManagerRules.static.refinedMaterial[CRAFTING_TYPE_CLOTHIER][materialIndex] ~= "" then
				table.insert(submenuControls, panelRule("refinedMaterial" .. CRAFTING_TYPE_CLOTHIER .. materialIndex))
			end
			if BankManagerRules.static.rawMaterial[CRAFTING_TYPE_CLOTHIER][materialIndex] ~= "" then
				table.insert(submenuControls, panelRule("rawMaterial" .. CRAFTING_TYPE_CLOTHIER .. materialIndex))
			end
		end
		
		for materialIndex = 1, #BankManagerRules.static.refinedMaterial[CRAFTING_TYPE_CLOTHIER * 100] do
			if BankManagerRules.static.refinedMaterial[CRAFTING_TYPE_CLOTHIER * 100][materialIndex] ~= "" then
				table.insert(submenuControls, panelRule("refinedMaterial" .. (CRAFTING_TYPE_CLOTHIER * 100) .. materialIndex))
			end
			if BankManagerRules.static.rawMaterial[CRAFTING_TYPE_CLOTHIER * 100][materialIndex] ~= "" then
				table.insert(submenuControls, panelRule("rawMaterial" .. (CRAFTING_TYPE_CLOTHIER * 100) .. materialIndex))
			end
		end
	
	-- Woodworking
	elseif subMenu == "woodworking" then
	
		table.insert(submenuControls, panelOnlyIfNotFullStack("improvement" .. CRAFTING_TYPE_WOODWORKING, "improvementAll" .. CRAFTING_TYPE_WOODWORKING))
		table.insert(submenuControls, panelGuildBank("improvement" .. CRAFTING_TYPE_WOODWORKING, "improvementGBank" .. CRAFTING_TYPE_WOODWORKING))
		table.insert(submenuControls, panelMaxStacks("improvement" .. CRAFTING_TYPE_WOODWORKING, "improvementAll" .. CRAFTING_TYPE_WOODWORKING, "improvementStacks" .. CRAFTING_TYPE_WOODWORKING))
		for improvementItemIndex = 1, GetNumSmithingImprovementItems() do
			table.insert(submenuControls, panelRule("improvement" .. CRAFTING_TYPE_WOODWORKING .. improvementItemIndex))
		end
		
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		
		table.insert(submenuControls, panelRule("weaponType" .. CRAFTING_TYPE_WOODWORKING))
		table.insert(submenuControls, panelRule("weaponType" .. CRAFTING_TYPE_WOODWORKING .. "Trait" .. ITEM_TRAIT_TYPE_ARMOR_INTRICATE))	
		table.insert(submenuControls, panelRule("weaponTypeResearchable" .. CRAFTING_TYPE_WOODWORKING))
		
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		
		table.insert(submenuControls, panelOnlyIfNotFullStack("Material[A]?[l]?[l]?" .. CRAFTING_TYPE_WOODWORKING, "MaterialAll" .. CRAFTING_TYPE_WOODWORKING))
		table.insert(submenuControls, panelGuildBank("Material[A]?[l]?[l]?" .. CRAFTING_TYPE_WOODWORKING, "MaterialGBank" .. CRAFTING_TYPE_WOODWORKING))
		table.insert(submenuControls, panelMaxStacks("Material[A]?[l]?[l]?" .. CRAFTING_TYPE_WOODWORKING, "MaterialAll" .. CRAFTING_TYPE_WOODWORKING, "MaterialStacks" .. CRAFTING_TYPE_WOODWORKING))
		table.insert(submenuControls, panelRule("MaterialAll" .. CRAFTING_TYPE_WOODWORKING))
		table.insert(submenuControls, panelRule("refinedMaterialAll" .. CRAFTING_TYPE_WOODWORKING))
		table.insert(submenuControls, panelRule("rawMaterialAll" .. CRAFTING_TYPE_WOODWORKING))
		
		for materialIndex = 1, #BankManagerRules.static.refinedMaterial[CRAFTING_TYPE_WOODWORKING] do
			if BankManagerRules.static.refinedMaterial[CRAFTING_TYPE_WOODWORKING][materialIndex] ~= "" then
				table.insert(submenuControls, panelRule("refinedMaterial" .. CRAFTING_TYPE_WOODWORKING .. materialIndex))
			end
			if BankManagerRules.static.rawMaterial[CRAFTING_TYPE_WOODWORKING][materialIndex] ~= "" then
				table.insert(submenuControls, panelRule("rawMaterial" .. CRAFTING_TYPE_WOODWORKING .. materialIndex))
			end
		end
	
	-- Cooking
	elseif subMenu == "cooking" then
		table.insert(submenuControls, panelOnlyIfNotFullStack("cookingIngredients", "cookingIngredientsAll"))
		table.insert(submenuControls, panelGuildBank("cookingIngredients", "cookingIngredientsGBank"))
		table.insert(submenuControls, panelMaxStacks("cookingIngredients", "cookingIngredientsAll", "cookingIngredientsStacks"))
		
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		
		table.insert(submenuControls, panelRule("cookingIngredientsFood"))
		table.insert(submenuControls, panelRule("cookingIngredientsDrink"))
		table.insert(submenuControls, panelRule("cookingIngredientsRare"))
		table.insert(submenuControls, panelRule("cookingAmbrosia"))
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		
		table.insert(submenuControls, {type = "description", text="", width="half"}) -- Placeholder for next line
		table.insert(submenuControls, panelGuildBank("cookingRecipe", "cookingRecipeGBank"))
		table.insert(submenuControls, panelRule("cookingRecipeKnown"))
		table.insert(submenuControls, panelRule("cookingRecipeUnknown"))
	
	-- Alchemy
	elseif subMenu == "alchemy" then
		table.insert(submenuControls, panelOnlyIfNotFullStack("alchemy", "alchemyAll"))
		table.insert(submenuControls, panelGuildBank("alchemy", "alchemyGBank"))
		table.insert(submenuControls, panelMaxStacks("alchemy", "alchemyAll", "alchemyStacks"))
		
		table.insert(submenuControls, panelRule("alchemyAll"))
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		table.insert(submenuControls, panelRule("alchemyReagent"))
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		local MAX_ALCHEMY_SKILL = 8
		for alchemySkill=1, MAX_ALCHEMY_SKILL do
			table.insert(submenuControls, panelRule("alchemySolvent" .. alchemySkill))
		end
	
	-- Enchanting
	elseif subMenu == "enchanting" then
		table.insert(submenuControls, panelOnlyIfNotFullStack("enchanting", "enchantingAll"))
		table.insert(submenuControls, panelGuildBank("enchanting[A]+[P]+[E]+", "enchantingGBank"))
		table.insert(submenuControls, panelMaxStacks("enchanting", "enchantingAll", "enchantingStacks"))
		
		table.insert(submenuControls, panelRule("enchantingAll"))
		
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		
		table.insert(submenuControls, panelRule("enchantingEssence"))
		table.insert(submenuControls, panelRule("enchantingAspect"))
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		
		local MAX_ENCHANTING_SKILL = 10
		for enchantingSkill=1, MAX_ENCHANTING_SKILL do
			table.insert(submenuControls, panelRule("enchantingPotency" .. enchantingSkill))
		end
		
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		table.insert(submenuControls, {type = "description", text="", width="half"}) -- Placeholder for next line
		table.insert(submenuControls, panelGuildBank("enchantingGlyphs", "enchantingGlyphsGBank"))
		table.insert(submenuControls, panelRule("enchantingGlyphs"))
		
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		table.insert(submenuControls, panelOnlyIfNotFullStack("enchantingTa", "enchantingTa"))
		table.insert(submenuControls, panelGuildBank("enchantingTa", "enchantingTa"))
		table.insert(submenuControls, panelMaxStacks("enchantingTa", "enchantingTa", "enchantingTa"))
		table.insert(submenuControls, panelRule("enchantingTa"))
	
	-- Diverse
	elseif subMenu == "trophies" then
		table.insert(submenuControls, panelOnlyIfNotFullStack("trophy", "trophyAll"))
		table.insert(submenuControls, panelGuildBank("trophy", "trophyGBank"))
		table.insert(submenuControls, panelMaxStacks("trophy", "trophyAll", "trophyStacks"))
		
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		
		table.insert(submenuControls, panelRule("trophyTreasureMaps"))
		table.insert(submenuControls, panelRule("trophySurveys"))
		table.insert(submenuControls, panelRule("trophyFragMotifs"))
		table.insert(submenuControls, panelRule("trophyFragRecipe"))
		table.insert(submenuControls, panelRule("trophyICPVP"))
		table.insert(submenuControls, panelRule("trophyICPVE"))
		table.insert(submenuControls, panelRule("trophyQuests"))
	
	-- Diverse
	elseif subMenu == "misc" then
		table.insert(submenuControls, panelOnlyIfNotFullStack("Misc", "MiscAll"))
		table.insert(submenuControls, panelGuildBank("Misc", "MiscGBank"))
		table.insert(submenuControls, panelMaxStacks("Misc", "MiscAll", "MiscStacks"))
		
		table.insert(submenuControls, {type = "texture", image="EsoUI/Art/Miscellaneous/horizontalDivider.dds", imageWidth=510, imageHeight=4})
		
		table.insert(submenuControls, panelRule("MiscAvaRepair"))
		table.insert(submenuControls, panelRule("MiscDisguises"))
		table.insert(submenuControls, panelRule("MiscLockpick"))
		table.insert(submenuControls, panelRule("MiscLure"))
		table.insert(submenuControls, panelRule("MiscPotion"))
		table.insert(submenuControls, panelRule("MiscRacial"))
		table.insert(submenuControls, panelRule("MiscContainer"))
		table.insert(submenuControls, panelRule("MiscRepair"))
		table.insert(submenuControls, panelRule("MiscSoulGemsEmpty"))
		table.insert(submenuControls, panelRule("MiscSoulGemsFulfilled"))
	
	-- Diverse
	elseif subMenu == "special" then
		table.insert(submenuControls, panelSpecialFilter("writsQuests"))
	end
	
	return submenuControls

end

-- Build LAM panel
local function buildLAMPanel()
	
	local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
	
	local panelData = {
		type = "panel",
		name = addonName,
		displayName = displayName,
		author = author,
		version = version,
		registerForRefresh = true,
		registerForDefaults = true,
		slashCommand = "/bmr",
	}
	
	panel = LAM2:RegisterAddonPanel(addonName .. "LAM2Options", panelData)
	
	-- Get the SV data
	db = ZO_SavedVars:New("BMVars", 4, nil, defaults, nil)
	
	-- Load profile
	actualProfile = tonumber(db.actualProfile)
	
	-- Creating LAM optionPanel following the rules
	local goldSubmenuControls = LAMSubmenu("gold")
	local tvstonesSubmenuControls = LAMSubmenu("tvstones")
	local traitSubmenuControls = LAMSubmenu("traits")
	local styleSubmenuControls = LAMSubmenu("styles")
	local blacksmithingSubmenuControls = LAMSubmenu("blacksmithing")
	local clothierSubmenuControls = LAMSubmenu("clothier")
	local woodworkingSubmenuControls = LAMSubmenu("woodworking")
	local cookingSubmenuControls = LAMSubmenu("cooking")
	local enchantmentSubmenuControls = LAMSubmenu("enchanting")
	local alchemySubmenuControls = LAMSubmenu("alchemy")
	local trophiesSubmenuControls = LAMSubmenu("trophies")
	local diverseSubmenuControls = LAMSubmenu("misc")
	local specialFiltersControls = LAMSubmenu("special")
	
	local protectedTooltip = GetString(BMR_DONT_MOVE_PROTECTED_ITEMS_TOOLTIP)
	if (not (ItemSaver_IsItemSaved or FCOIsFiltered)) then
		protectedTooltip = protectedTooltip .. GetString(BMR_DONT_MOVE_PROTECTED_ITEMS_EXT)
	end
	
	local charactersKnown = {}
	if BMVars and BMVars.Default and BMVars.Default[GetDisplayName()] then
		for characterName, _ in pairs(BMVars.Default[GetDisplayName()]) do
			table.insert(charactersKnown, characterName)
		end
	end
	
	local listOfProfiles = {}
	for i=1, 9 do
		listOfProfiles[i] = i
	end
	
	-- Build panel
	local optionsTable = {
		{	-- Profile list
			type = "submenu",
			name = zo_strformat(GetString(BMR_PROFILES)),
			controls = {
				{
					type = "dropdown",
					name = GetString(BMR_PROFILE_LIST),
					tooltip = GetString(BMR_PROFILE_LIST_TOOLTIP),
					choices = listOfProfiles,
					width = "full",
					getFunc = function() return db.actualProfile end,
					setFunc = function(choice)
						actualProfile = tonumber(choice)
						db.actualProfile = choice
						db.profiles[actualProfile].defined = true
					end,
				},
				{
					type = "editbox",
					name = GetString(BMR_PROFILE_NAME),
					tooltip = GetString(BMR_PROFILE_NAME_TOOLTIP),
					width = "full",
					getFunc = function() return db.profiles[actualProfile].name end,
					setFunc = function(choice) db.profiles[actualProfile].name = choice end,
				},
				{
					type = "button",
					name = GetString(BMR_PROFILE_RESET),
					tooltip = GetString(BMR_PROFILE_RESET_TOOLTIP),
					width = "full",
					func = function()
						local profileToDelete = actualProfile
						actualProfile = 1
						db.actualProfile = "1"
						db.profiles[profileToDelete] = defaults.profiles[profileToDelete]
					end,
				},
			},
		},
		{
			type = "submenu",
			name = GetString(SI_GAMEPAD_OPTIONS_MENU),
			controls = {
				{	-- Auto Transfer
					type = "checkbox",
					name = GetString(BMR_AUTO_TRANSFERT),
					tooltip = GetString(BMR_AUTO_TRANSFERT_TOOLTIP),
					getFunc = function() return db.profiles[actualProfile].autoTransfert end,
					setFunc = function(value) db.profiles[actualProfile].autoTransfert = value end,
					default = true,
				},
				{	-- Detailed move/stack
					type = "checkbox",
					name = GetString(BMR_STACK_DETAILLED),
					tooltip = GetString(BMR_STACK_DETAILLED_TOOLTIP),
					getFunc = function() return db.profiles[actualProfile].detailledDisplay end,
					setFunc = function(value) db.profiles[actualProfile].detailledDisplay = value end,
					default = true,
				},
				{	-- Detailed non moved
					type = "checkbox",
					name = GetString(BMR_STACK_DETAILLED_NOTMOVED),
					tooltip = GetString(BMR_STACK_DETAILLED_NOTMOVED_TOOLTIP),
					getFunc = function() return db.profiles[actualProfile].detailledNotMoved end,
					setFunc = function(value) db.profiles[actualProfile].detailledNotMoved = value end,
					default = true,
				},
				{	-- Display Summary
					type = "checkbox",
					name = GetString(BMR_DISPLAY_SUMMARY),
					tooltip = GetString(BMR_DISPLAY_SUMMARY_TOOLTIP),
					getFunc = function() return db.profiles[actualProfile].summary end,
					setFunc = function(value) db.profiles[actualProfile].summary = value end,
					default = true,
				},
				{	-- Display Summary
					type = "checkbox",
					name = GetString(BMR_DONT_MOVE_PROTECTED_ITEMS),
					tooltip = protectedTooltip,
					getFunc = function() return db.profiles[actualProfile].protected end,
					setFunc = function(value) db.profiles[actualProfile].protected = value end,
					disabled = function()
						if ItemSaver_IsItemSaved or FCOIsFiltered then
							return false
						end
						return true
					end,
					default = true,
				},
				{	-- Protect 3rd party moves
					type = "checkbox",
					name = GetString(BMR_DONT_MOVE_MOVED_ITEMS),
					tooltip = GetString(BMR_DONT_MOVE_MOVED_ITEMS_TOOLTIP),
					getFunc = function() return db.profiles[actualProfile].moved end,
					setFunc = function(value) db.profiles[actualProfile].moved = value end,
					default = true,
				},
				{	-- Wait at startup
					type = "slider",
					name = GetString(BMR_WAIT_AT_STARTUP),
					tooltip = GetString(BMR_WAIT_AT_STARTUP_TOOLTIP),
					step = 0.5,
					min = 1,
					max = 4,
					getFunc = function() return db.profiles[actualProfile].initialWaitInSecs end,
					setFunc = function(value) db.profiles[actualProfile].initialWaitInSecs = value end,
					default = 2,
				},
				{	-- Don't overfill bags
					type = "slider",
					name = GetString(BMR_NO_OVERFILL),
					tooltip = GetString(BMR_NO_OVERFILL_TOOLTIP),
					step = 1,
					min = 0,
					max = 20,
					getFunc = function() return db.profiles[actualProfile].overfill end,
					setFunc = function(value) db.profiles[actualProfile].overfill = value end,
					default = 0,
				},
				{	-- Pause in Ms between moves
					type = "slider",
					name = GetString(BMR_DELAY_BETWEEN_MOVES),
					tooltip = GetString(BMR_DELAY_BETWEEN_MOVES_TOOLTIP),
					step = 10,
					min = 0,
					max = 110,
					getFunc = function() return db.profiles[actualProfile].pauseInMs end,
					setFunc = function(value) db.profiles[actualProfile].pauseInMs = value end,
					default = 0,
				},
			},
		},
		{
			type = "submenu",
			name = zo_strformat(GetString("SI_CURRENCYTYPE", CURT_MONEY)),
			controls = goldSubmenuControls,
		},
		{
			type = "submenu",
			name = zo_strformat(GetString("SI_CURRENCYTYPE", CURT_TELVAR_STONES)),
			controls = tvstonesSubmenuControls,
		},
		{
			type = "submenu",
			name = zo_strformat("<<1>> & <<2>>", GetString("SI_ITEMTYPE", ITEMTYPE_ARMOR_TRAIT), GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON_TRAIT)),
			controls = traitSubmenuControls,
		},
		{
			type = "submenu",
			name = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_STYLE_MATERIAL)),
			controls = styleSubmenuControls,
		},
		{
			type = "submenu",
			name = zo_strformat("<<1>>", GetString(BMR_TRADESKILL_BLACKSMITHING)),
			controls = blacksmithingSubmenuControls,
		},
		{
			type = "submenu",
			name = zo_strformat("<<1>>", GetString(BMR_TRADESKILL_CLOTHIER)),
			controls = clothierSubmenuControls,
		},
		{
			type = "submenu",
			name = zo_strformat("<<1>>", GetString(BMR_TRADESKILL_WOODWORKING)),
			controls = woodworkingSubmenuControls,
		},
		{
			type = "submenu",
			name = zo_strformat("<<1>>", GetString(BMR_TRADESKILL_PROVISIONING)),
			controls = cookingSubmenuControls,
		},
		{
			type = "submenu",
			name = zo_strformat("<<1>>", GetString(BMR_TRADESKILL_ENCHANTING)),
			controls = enchantmentSubmenuControls,
		},
		{
			type = "submenu",
			name = zo_strformat("<<1>>", GetString(BMR_TRADESKILL_ALCHEMY)),
			controls = alchemySubmenuControls,
		},
		{
			type = "submenu",
			name =  GetString("SI_ITEMTYPE", ITEMTYPE_TROPHY),
			controls = trophiesSubmenuControls,
		},
		{
			type = "submenu",
			name = GetString(SI_PLAYER_MENU_MISC),
			controls = diverseSubmenuControls,
		},
		{
			type = "submenu",
			name = zo_strformat("<<1>> : <<2>>", GetString(SI_JOURNAL_MENU_QUESTS), GetString("SI_QUESTTYPE", QUEST_TYPE_CRAFTING)),
			controls = specialFiltersControls,
		},
		{
			type = "dropdown",
			name = GetString(BMR_IMPORT),
			tooltip = GetString(BMR_IMPORT_DESC),
			choices = charactersKnown,
			width = "full",
			getFunc = function() return GetUnitName('player') end,
			setFunc = function(choice)
				db = BMVars.Default[GetDisplayName()][choice]
				BMVars.Default[GetDisplayName()][GetUnitName("player")] = BMVars.Default[GetDisplayName()][choice]
				ZO_SceneManager_ToggleGameMenuBinding()
				CHAT_SYSTEM:AddMessage(zo_strformat(BMR_IMPORTED, choice))
			end,
		},
	}
	
	LAM2:RegisterOptionControls(addonName .. "LAM2Options", optionsTable)
	
end

-- Move UI to its place
local function RebuildAnchorsGUI()
	BankManager:ClearAnchors()
	BankManager:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, db.gui_x, db.gui_y)
end

--Load Addon
local function onAddonLoaded(_, addon)

	if addon == addonName then
		if BankManagerRules then
		
			-- Load rules
			BankManagerRules.addFilters()
			BankManagerRules.addFiltersTaggedAll()
			
			-- Adding defaults values to all our rules
			BankManagerRules.defaults = BankManagerRules.addDefaultFilters(BankManagerRules.data, BankManagerRules.defaults)
			
			-- Load profiles defaults, Huge memory waste :'(
			for i=1, 9 do
				defaults.profiles[i].rules = BankManagerRules.defaults
			end
			
			-- Build it a single time to avoid unneeded loops
			listOfActiveGuilds()
			
			-- Build LAM
			buildLAMPanel()
			
			-- Move GUI to its saved position
			RebuildAnchorsGUI()
			
			-- Register / Unregister
			EVENT_MANAGER:RegisterForEvent(addonName, EVENT_OPEN_BANK, onOpenBank)
			EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CLOSE_BANK, onCloseBank)
			
			EVENT_MANAGER:RegisterForEvent(addonName, EVENT_GUILD_BANK_SELECTED, onGuildBankSelected)
			EVENT_MANAGER:RegisterForEvent(addonName, EVENT_GUILD_BANK_ITEMS_READY, onGuildBankItemsReady)
			EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CLOSE_GUILD_BANK, onCloseGuildBank)
			
			EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
			
		end
	end
	
end

-- Called by UI
function BankManagerRevived_nextRule(_, step)
	nextRule(step)
end

-- Called by UI
function BankManagerRevived_executeRule()
	
	--startTimeInMs = GetGameTimeMilliseconds()
	if checkingGBank then
		doInteractionWithGBank()
	else
		interactWithBank()
	end
	
end

-- Called by UI
function BankManagerRevived_saveGuiPosition()

	local _, _, rightScreen, bottomScreen = GuiRoot:GetScreenRect()
	local _, _, right, bottom = BankManager:GetScreenRect()

	db.gui_x = math.floor(right-rightScreen)
	db.gui_y = math.floor(bottom-bottomScreen)
	
end

-- Called by Bindings
function BankManagerRevived_runProfile(profile)

	if db.profiles[profile].defined then
		
		actualProfile = profile
		db.actualProfile = profile
		
		-- Sync LAM
		CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", panel)
		
		if isBanking then
		
			for i=2, 9 do
				if db.profiles[i].defined == true then
					multipleProfiles = true
					break
				end
			end
			
			-- Display UI only if 2 profiles are defined or if actual is on manual mode
			if not db.profiles[actualProfile].autoTransfert or multipleProfiles then
				displayUI(multipleProfiles)
			end
			
			if checkingGBank then
				doInteractionWithGBank()
			else
				interactWithBank()
			end
			
		end
		
	end

end

-- For API
function BankManagerRevived_inProgress()
	return inProgress
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, onAddonLoaded)