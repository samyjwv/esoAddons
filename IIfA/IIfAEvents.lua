local IIfA = IIfA

-- 2016-7-26 AM - added global funcs for events
-- the following functions are all globals, not tied to the IIfA class, but call the IIfA class member functions for event processing

-- 2015-3-7 AssemblerManiac - added code to collect inventory data at char disconnect
local function IIfA_EventOnPlayerUnloaded()
	-- update the stored inventory every time character logs out, will assure it's always right when viewing from other chars
	IIfA:CollectAll()

	IIfA.CharCurrencyFrame:UpdateAssets()
	IIfA.CharBagFrame:UpdateAssets()
--	IIfA.data.assets[IIfA.currentCharacterId] = {}
--	IIfA.data.assets[IIfA.currentCharacterId].gold = GetCarriedCurrencyAmount(CURT_MONEY)
--	IIfA.data.assets[IIfA.currentCharacterId].tv = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
--	IIfA.data.assets[IIfA.currentCharacterId].ap = GetCarriedCurrencyAmount(CURT_ALLIANCE_POINTS)
end

local function IIfA_GuildBankDelayReady()
	IIfA:GuildBankDelayReady()
end

local function IIfA_GuildBankAddRemove()
	IIfA:GuildBankAddRemove()
end

local function IIfA_ActionLayerInventoryUpdate()
	IIfA:ActionLayerInventoryUpdate()
end

local function IIfA_InventorySlotUpdate(...)
	IIfA:InventorySlotUpdate(...)
end

local function IIfA_EventProc(...)
	--d(...)
	local l = {...}
	local s = ""
	for name, data in pairs(l) do
		if type(data) ~= "table" then
			s = s .. name .. " = " .. tostring(data) .. "\r\n"
		else
			s = s .. name .. " = {" .. "\r\n"
			for name1, data1 in pairs(data) do
				if type(data1) ~= "table" then
					s = s .. "\t" .. name1 .. " = " .. tostring(data1) .. "\r\n"
				else
					s = s .. "\t" .. name1 .. " = {}" .. "\r\n"
				end
			end
			s = s .. "}\r\n"
		end
	end
	d(s)
end

function IIfA:RegisterForEvents()
	-- 2016-6-24 AM - commented this out, doing nothing at the moment, revisit later
	-- EVENT_MANAGER:RegisterForEvent("IIFA_PLAYER_LOADED_EVENTS", EVENT_PLAYER_ACTIVATED, IIfA_EventOnPlayerloaded)

	-- 2015-3-7 AssemblerManiac - added EVENT_PLAYER_DEACTIVATED event
	EVENT_MANAGER:RegisterForEvent("IIFA_PLAYER_UNLOADED_EVENTS", EVENT_PLAYER_DEACTIVATED, IIfA_EventOnPlayerUnloaded)

	-- when item comes into inventory
	EVENT_MANAGER:RegisterForEvent("IIFA_InventorySlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, IIfA_InventorySlotUpdate)
	EVENT_MANAGER:AddFilterForEvent("IIFA_InventorySlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

--	EVENT_MANAGER:RegisterForEvent("IIFA_unknown", EVENT_ITEM_SLOT_CHANGED, IIfA_EventProc)
--	EVENT_MANAGER:RegisterForEvent("IIFA_unknown", EVENT_INVENTORY_ITEM_USED, IIfA_EventProc)	-- arg 1 = event id, arg 2 = 27 (no clue)
--	EVENT_MANAGER:RegisterForEvent("IIFA_unknown", EVENT_INVENTORY_ITEM_DESTROYED, IIfA_EventProc)
--	EVENT_MANAGER:RegisterForEvent("IIFA_unknown", EVENT_JUSTICE_FENCE_UPDATE, IIfA_EventProc) -- # sold, # laundered is sent to event handler

-- not helpful, no link at all on this callback
--	SHARED_INVENTORY:RegisterCallback("SlotRemoved", IIfA_EventProc)

	-- Events for data collection
	EVENT_MANAGER:RegisterForEvent("IIFA_ALPUSH", EVENT_ACTION_LAYER_PUSHED, IIfA_ActionLayerInventoryUpdate)

	-- on opening guild bank:
	EVENT_MANAGER:RegisterForEvent("IIFA_GUILDBANK_LOADED", EVENT_GUILD_BANK_ITEMS_READY, IIfA_GuildBankDelayReady)

	-- on adding or removing an item from the guild bank:
	EVENT_MANAGER:RegisterForEvent("IIFA_GUILDBANK_ITEM_ADDED", EVENT_GUILD_BANK_ITEM_ADDED, IIfA_GuildBankAddRemove)
	EVENT_MANAGER:RegisterForEvent("IIFA_GUILDBANK_ITEM_REMOVED", EVENT_GUILD_BANK_ITEM_REMOVED, IIfA_GuildBankAddRemove)

	local function RebuildOptionsMenu()
		self:CreateOptionsMenu()
	end
	EVENT_MANAGER:RegisterForEvent("IIFA_GuildJoin", EVENT_GUILD_SELF_JOINED_GUILD, RebuildOptionsMenu)
	EVENT_MANAGER:RegisterForEvent("IIFA_GuildLeave", EVENT_GUILD_SELF_LEFT_GUILD, RebuildOptionsMenu)

--    ZO_QuickSlot:RegisterForEvent(EVENT_ABILITY_COOLDOWN_UPDATED, IIfA_EventProc)

end

--[[ maybe revisit this in the future
function IIfA_EventOnPlayerloaded()
	--Do these things only on the first load
	if(not IIfA.PlayerLoadedFired)then
		--if(IIfA.data.in2AgedGuildBankDataWarning) then IIfA:CheckForAgedGuildBankData() end
		--Set PlayerLoadedFired = true to prevent future execution during this session
		IIfA.PlayerLoadedFired = true
	end
	--Do these things on any load
	--Do a little dance...
	--Make a little love...
	--Get down tonight...
end
 --]]



--[[ registerfilter & events
define HOW to listen for events (minimize # of calls to event handler, less overhead of eso internals)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySlotUpdate)
EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,  REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,  REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
--]]


--[[ event for SHARED_INVENTORY:RegisterCallback sends as follows, and has no itemlink :(
arg 1 = 5		-- bag id
arg 2 = 71198		-- slot number
arg 3 = {
  inventory = {}
  condition = 100
  age = 6702.2509765625
  isPlaceableFurniture = false
  searchData = {}
  requiredLevel = 1
  stackCount = 1426
  stolen = false
  isPlayerLocked = false
  brandNew = true
  sellPrice = 2
  itemInstanceId = 3340100312
  statValue = 0
  rawName = rubedite ore
  locked = false
  isJunk = false
  stackSellPrice = 2852
  slotIndex = 71198
  specializedItemType = 0
  isBoPTradeable = false
  meetsUsageRequirement = true
  quality = 1
  filterData = {}
  equipType = 0
  name = Rubedite Ore
  itemType = 35
  bagId = 5
  stackLaunderPrice = 0
  uniqueId = 3.5176485852605e-319
  iconFile = /esoui/art/icons/crafting_jewelry_base_ruby_r1.dds
  launderPrice = 0
  }

--]]
