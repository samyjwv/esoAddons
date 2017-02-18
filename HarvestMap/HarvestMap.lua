if not Harvest then
	Harvest = {}
end

local Harvest = _G["Harvest"]
local CallbackManager = Harvest.callbackManager
local Events = Harvest.events
local GPS = LibStub("LibGPS2")
local Lib3D = LibStub("Lib3D")

-- local references for global functions to improve the performance
-- of the functions called every frame
local GetMapPlayerPosition = _G["GetMapPlayerPosition"]
local GetInteractionType = _G["GetInteractionType"]
local INTERACTION_HARVEST = _G["INTERACTION_HARVEST"]
local pairs = _G["pairs"]
local tostring = _G["tostring"]
local zo_floor = _G["zo_floor"]

-- returns informations regarding the current location
-- if viewedMap is true, the data is relative to the currently viewed map
-- otherwise the data is related to the map the player is currently on
function Harvest.GetLocation( viewedMap )
	local mapChanged
	if not viewedMap then
		mapChanged = (SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED)
	end
	-- calculate the current map's measurement
	local returnToInitialMap = (viewedMap or false)
	local success, mapChangedWhileMeasurement = GPS:CalculateMapMeasurements( returnToInitialMap )
	-- the map might have changed. restore it
	if mapChangedWhileMeasurement and not viewedMap then
		SetMapToPlayerLocation()
	end
	
	local measurement = GPS:GetCurrentMapMeasurements()
	local map = Harvest.GetMap()
	local zoneIndex = GetCurrentMapZoneIndex()
	-- some maps are bugged, i.e. vaults of madness returns the index of coldharbor
	if DoesCurrentMapMatchMapForPlayerLocation() then
		zoneIndex = GetUnitZoneIndex("player")
	end
	
	measurement = Harvest.ModifyMeasurement(GetMapContentType(), map, measurement, zoneIndex)
	
	local x, y, heading = GetMapPlayerPosition( "player" )
	if mapChanged then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
	end
	return map, x, y, measurement, zoneIndex, heading
end

-- returns true if the measurement is modified for this map
function Harvest.ModifyMeasurement( mapType, map, measurement, zoneIndex)
	if not measurement then return end
	
	local zoneId = GetZoneId(zoneIndex)
	local distanceCorrection, computed = Lib3D:GetGlobalToWorldFactor(zoneId)
	if distanceCorrection then
		if computed then
			Harvest.savedVars["global"].measurements[map] = {distanceCorrection, Harvest.GetCurrentTimestamp(), zoneId}
		end
		-- usually 1 in global coords coresponds to 25 km, but some maps scale differently
		distanceCorrection = distanceCorrection / 25000
	elseif Harvest.savedVars["global"].measurements[map] then
		distanceCorrection = Harvest.savedVars["global"].measurements[map][1] / 25000
	else
		-- delves tend to be scaled down on the zone map, so we need to return a smaller value
		if mapType == MAP_CONTENT_DUNGEON and measurement.scaleX < 0.003 then
			distanceCorrection = math.sqrt(165)
		else
			distanceCorrection = 1
		end
	end
	
	
	measurement = {
		scaleX = measurement.scaleX,
		scaleY = measurement.scaleY,
		offsetX = measurement.offsetX,
		offsetY = measurement.offsetY,
		distanceCorrection = distanceCorrection,
	}
	
	return measurement
end

function Harvest.GetMap()
	local textureName = GetMapTileTexture()
	if Harvest.lastMapTexture ~= textureName then
		Harvest.lastMapTexture = textureName
		textureName = string.lower(textureName)
		textureName = string.gsub(textureName, "^.*maps/", "")
		textureName = string.gsub(textureName, "_%d+%.dds$", "")

		if textureName == "eyevea_base" then
			local worldMapName = GetUnitZone("player")
			worldMapName = string.lower(worldMapName)
			textureName = worldMapName .. "/" .. textureName
		else
			local heistMap = Harvest.IsHeistMap( textureName )
			if heistMap then
				Harvest.map = heistMap .. "_base"
				return Harvest.map
			end
		end

		Harvest.map = textureName
	end
	return Harvest.map
end

-- helper function to only display debug messages if the debug mode is enabled
function Harvest.Debug( message )
	if Harvest.AreDebugMessagesEnabled() or Harvest.AreVerboseMessagesEnabled() then
		d( message )
	end
end

function Harvest.Verbose( message )
	if Harvest.AreVerboseMessagesEnabled() then
		Harvest.Debug( message )
	end
end

-- this function returns the pinTypeId for the given item id and node name
function Harvest.GetPinTypeId( itemId, nodeName )
	-- get two pin types based on the item id and node name
	local itemIdPinType = Harvest.itemId2PinType[ itemId ]
	local nodeNamePinType = Harvest.nodeName2PinType[ zo_strlower( nodeName ) ]
	Harvest.Debug( "Item id " .. tostring(itemId) .. " returns pin type " .. tostring(itemIdPinType))
	Harvest.Debug( "Node name " .. tostring(nodeName) .. " returns pin type " .. tostring(nodeNamePinType))
	-- heavy sacks can contain material for different professions
	-- so don't use the item id to determine the pin type
	if Harvest.IsHeavySack( nodeName ) then
		return Harvest.HEAVYSACK
	end
	if Harvest.IsTrove( nodeName ) then
		return Harvest.TROVE
	end
	if Harvest.IsStash( nodeName ) then
		return Harvest.STASH
	end
	-- both returned the same pin type (or both are unknown/nil)
	if itemIdPinType == nodeNamePinType then
		return itemIdPinType
	end
	-- we allow this special case because of possible errors in the localization
	if nodeNamePinType == nil then
		return itemIdPinType
	end
	-- the pin types don't match, don't save the node as there is some error
	return nil
end

-- not just called by EVENT_LOOT_RECEIVED but also by Harvest.OnLootUpdated
function Harvest.OnLootReceived( eventCode, receivedBy, objectName, stackCount, soundCategory, lootType, lootedBySelf )
	-- don't touch the save files/tables while they are still being updated/refactored
	if not Harvest.IsUpdateQueueEmpty() then
		Harvest.Debug( "OnLootReceived failed: HarvestMap is updating" )
		return
	end

	if not lootedBySelf then
		Harvest.Debug( "OnLootReceived failed: wasn't looted by self" )
		return
	end
	
	local map, x, y, measurement, zoneIndex = Harvest.GetLocation()
	local isHeist = false
	-- only save something if we were harvesting or the target is a heavy sack, thieves trove or stash
	if (not Harvest.wasHarvesting) and (not Harvest.IsHeavySack( Harvest.lastInteractableName )) and (not Harvest.IsTrove( Harvest.lastInteractableName )) and not Harvest.IsStash( Harvest.lastInteractableName ) then
		-- additional check for heist containers
		if not (lootType == LOOT_TYPE_QUEST_ITEM) or not Harvest.IsHeistMap(map) then
			Harvest.Debug( "OnLootReceived failed: wasn't harvesting" )
			Harvest.Debug( "OnLootReceived failed: wasn't heist quest item" )
			Harvest.Debug( "Interactable name is:" .. tostring(Harvest.lastInteractableName))
			return
		else
			isHeist = true
		end
	end
	-- get the information we want to save
	local itemName, itemId
	local pinTypeId = nil
	if not isHeist then
		itemName, _, _, itemId = ZO_LinkHandler_ParseLink( objectName )
		itemId = tonumber(itemId)
		if itemId == nil then
			-- wait what? does this even happen?! abort mission!
			Harvest.Debug( "OnLootReceived failed: item id is nil" )
			return
		end
		-- get the pin type depending on the item we looted and the name of the harvest node
		-- eg jute will be saved as a clothing pin
		pinTypeId = Harvest.GetPinTypeId(itemId, Harvest.lastInteractableName)
		-- sometimes we can't get the pin type based on the itemId and node name
		-- ie some data in the localization is missing and nirncrux can be found in ore and wood
		-- abort if we couldn't find the correct pin type
		if pinTypeId == nil then
			Harvest.Debug( "OnLootReceived failed: pin type id is nil" )
			return
		end
		-- if this pin type is supposed to be saved
		if not Harvest.IsPinTypeSavedOnGather( pinTypeId ) then
			Harvest.Debug( "OnLootReceived failed: pin type is disabled in the options" )
			return
		end
	else
		pinTypeId = Harvest.JUSTICE
	end
	
	local z
	z = Harvest.lastInteractablePosition[2]
	if z == 0 then z = nil end
	
	Harvest.SaveData( map, x, y, z, measurement, zoneIndex, pinTypeId, itemId )
	Harvest.Debug( "Data was saved, set harvesting state to false" )
	-- tell the farming helper we harvested something, so it can update the statistics
	Harvest.farm.helper:FarmedANode(objectName, stackCount)
	
	-- reset the interactable name variable
	-- otherwise looting a container item after opening heavy sacks, thieves troves, stashes etc can cause wrong pins
	if pinTypeId == Harvest.HEAVYSACK or pinTypeId == Harvest.TROVE or pinTypeId == Harvest.STASH then
		Harvest.lastInteractableName = ""
	end
end

-- neded for those players that play without auto loot
function Harvest.OnLootUpdated()
	-- only save something if we were harvesting or the target is a heavy sack or thieves trove
	if (not Harvest.wasHarvesting) and (not Harvest.IsHeavySack( Harvest.lastInteractableName )) and (not Harvest.IsTrove( Harvest.lastInteractableName )) and not Harvest.IsStash( Harvest.lastInteractableName ) then
		Harvest.Debug( "OnLootUpdated failed: wasn't harvesting" )
		return
	end

	-- i usually play with auto loot on
	-- everything was programmed with auto loot in mind
	-- if auto loot is disabled (ie OnLootUpdated is called)
	-- let harvestmap believe auto loot is enabled by calling
	-- OnLootReceived for each item in the loot window
	local items = GetNumLootItems()
	Harvest.Debug( "HarvestMap will check " .. tostring(items) .. " items." )
	for lootIndex = 1, items do
		local lootId, _, _, count = GetLootItemInfo( lootIndex )
		Harvest.OnLootReceived( nil, nil, GetLootItemLink( lootId, LINK_STYLE_DEFAULT ), count, nil, nil, true )
	end

	-- when looting something, we have definitely finished the harvesting process
	if Harvest.wasHarvesting then
		Harvest.Debug( "All loot was handled. Set harvesting state to false." )
		Harvest.wasHarvesting = false
	end
end

-- refreshes the pins of the given pin type
-- if no pinType is given, all pins are refreshed
function Harvest.RefreshPins( pinTypeId )
	Harvest.mapPins:RefreshPins( pinTypeId )
	Harvest.InRangePins:RefreshCustomPins( pinTypeId )
	--Harvest.compassPins:RefreshPins( pinTypeId )
end

-- simple helper function which checks if a value is inside the table
-- does lua really not have a default function for this?
function Harvest.contains( table, value)
	for index, element in pairs(table) do
		if element == value then
			return index
		end
	end
	return false
end

-- this function tries to save the given data
-- this function is only used by the harvesting part of HarvestMap
function Harvest.SaveData( map, x, y, z, measurement, zoneIndex, pinTypeId, itemId )
	-- check input data
	if not map then
		Harvest.Debug( "SaveData failed: map is nil" )
		return
	end
	if type(x) ~= "number" or type(y) ~= "number" then
		Harvest.Debug( "SaveData failed: coordinates aren't numbers" )
		return
	end
	if not measurement then
		Harvest.Debug( "SaveData failed: measurement is nil" )
		return
	end
	if not pinTypeId then
		Harvest.Debug( "SaveData failed: pin type id is nil" )
		return
	end
	-- If the map is on the blacklist then don't save the data
	if Harvest.IsMapBlacklisted( map ) then
		Harvest.Debug( "SaveData failed: map " .. tostring(map) .. " is blacklisted" )
		return
	end

	if not Harvest.ShouldSaveItemId(pinTypeId) then
		itemId = nil
	end

	local saveFile = Harvest.Data:GetSaveFile( map )
	if not saveFile then return end
	-- save file tables might not exist yet
	saveFile.data[ map ] = saveFile.data[ map ] or {}
	saveFile.data[ map ][ pinTypeId ] = saveFile.data[ map ][ pinTypeId ] or {}

	local cache = Harvest.Data:GetMapCache( pinTypeId, map, measurement, zoneIndex )
	if not cache then return end

	local stamp = Harvest.GetCurrentTimestamp()

	-- If we have found this node already then we don't need to save it again
	local nodeId = cache:GetMergeableNode( pinTypeId, x, y )
	if nodeId then
		cache:Merge(nodeId, x, y, z, itemId, stamp, Harvest.nodeVersion)
		-- serialize the node for the save file
		local nodeIndex = cache.nodeIndex[ nodeId ]
		saveFile.data[ map ][ pinTypeId ][ nodeIndex ] = Harvest.Data:Serialize( x, y, z, cache.items[nodeId], stamp, Harvest.nodeVersion )

		CallbackManager:FireCallbacks(Events.NODE_UPDATED, map, pinTypeId, nodeId)

		-- hide the node, if the respawn timer is used for recently harvested resources
		if Harvest.IsHiddenOnHarvest() then
			cache:SetHidden( nodeId, true )
		end

		Harvest.Debug( "data was merged with a previous node" )
		return
	end

	local itemIds = nil
	if Harvest.ShouldSaveItemId( pinTypeId ) then
		itemIds = { [itemId] = stamp }
	end

	-- we need to save the data in serialized form in the save file,
	-- but also as deserialized table in the cache table for faster access.

	local nodeIndex = (#saveFile.data[ map ][ pinTypeId ]) + 1
	saveFile.data[ map ][ pinTypeId ][nodeIndex] = Harvest.Data:Serialize( x, y, z, itemIds, stamp, Harvest.nodeVersion )
	nodeId = cache:Add( pinTypeId, nodeIndex, x, y, z, itemIds, stamp, Harvest.nodeVersion )

	CallbackManager:FireCallbacks( Events.NODE_ADDED, map, pinTypeId, nodeId )

	-- hide the node, if the respawn timer is used for recently harvested resources
	if Harvest.IsHiddenOnHarvest() then
		cache:SetHidden( nodeId, true )
	end

	Harvest.Debug( "data was saved and a new pin was created" )
end

function Harvest.OnUpdate(timeInMs)

	-- update the update queue (importing/refactoring data)
	if not Harvest.IsUpdateQueueEmpty() then
		Harvest.UpdateUpdateQueue()
		return
	end

	local interactionType = GetInteractionType()
	local isHarvesting = (interactionType == INTERACTION_HARVEST)

	-- update the harvesting state. check if the character was harvesting something during the last two seconds
	if not isHarvesting then
		if Harvest.wasHarvesting and timeInMs - Harvest.harvestTime > 2000 then
			Harvest.Debug( "Two seconds since last harvesting action passed. Set harvesting state to false." )
			Harvest.wasHarvesting = false
		end
	else
		
		if not Harvest.wasHarvesting then
			Harvest.Debug( "Started harvesting. Set harvesting state to true." )
		end
		Harvest.wasHarvesting = true
		Harvest.harvestTime = timeInMs
	end

	-- the character started a new interaction
	if interactionType ~= Harvest.lastInteractType then
		Harvest.lastInteractType = interactionType
		-- the character started picking a lock
		if interactionType == INTERACTION_LOCKPICK then
			local z
			if IsInteractionUsingInteractCamera() then
				z = Harvest.GetCameraHeight()
			end
			-- if the interactable is owned by an NPC but the action isn't called "Steal From"
			-- then it wasn't a safebox but a simple door: don't place a chest pin
			if Harvest.lastInteractableOwned and Harvest.lastInteractableAction ~= GetString(SI_GAMECAMERAACTIONTYPE20) then
				Harvest.Debug( "not a chest or justice container(?)" )
				return
			end
			local map, x, y, measurement, zoneIndex = Harvest.GetLocation()
			-- normal chests aren't owned and their interaction is called "unlock"
			-- other types of chests (ie for heists) aren't owned but their interaction is "search"
			-- safeboxes are owned
			if (not Harvest.lastInteractableOwned) and Harvest.lastInteractableAction == GetString(SI_GAMECAMERAACTIONTYPE12) then
				-- normal chest
				if not Harvest.IsPinTypeSavedOnGather( Harvest.CHESTS ) then
					Harvest.Debug( "chests are disabled" )
					return
				end
				Harvest.SaveData( map, x, y, z, measurement, zoneIndex, Harvest.CHESTS )
			elseif Harvest.lastInteractableOwned then
				-- heist chest or safebox
				if not Harvest.IsPinTypeSavedOnGather( Harvest.JUSTICE ) then
					Harvest.Debug( "justice containers are disabled" )
					return
				end
				Harvest.SaveData( map, x, y, z, measurement, zoneIndex, Harvest.JUSTICE )
			end
		end
		-- the character started fishing
		if interactionType == INTERACTION_FISH then
			-- don't create new pin if fishing pins are disabled
			if not Harvest.IsPinTypeSavedOnGather( Harvest.FISHING ) then
				Harvest.Debug( "fishing spots are disabled" )
				return
			end
			local map, x, y, measurement, zoneIndex = Harvest.GetLocation()
			Harvest.SaveData( map, x, y, nil, measurement, zoneIndex, Harvest.FISHING )
		end
	end
	
	if Harvest.HasPinVisibleDistance() then
		if Harvest.lastViewedUpdate < timeInMs - 5000 then
			local map = Harvest.GetMap()
			local x, y = GetMapPlayerPosition("player")
			Harvest.mapPins:AddAndRemoveVisblePins(map, x, y)
			--Harvest.compassPins:AddAndRemoveVisblePins(map, x, y)
			Harvest.lastViewedUpdate = timeInMs
		end
	end
	
	if not FyrMM then
		Harvest.mapPins:PerformActions(true)
	end
	--Harvest.compassPins:PerformActions()

	if Harvest.GetHiddenTime() > 0 then
		Harvest.UpdateHiddenTime( timeInMs )
	end
end

function Harvest.UpdateHiddenTime( timeInMs )
	if not Harvest.IsHiddenOnHarvest() then
		local cache = Harvest.Data:GetCurrentZoneCache()
		local x, y = GPS:LocalToGlobal( GetMapPlayerPosition( "player" ) )
		-- some maps don't work (ie aurbis)
		if x then
			for _, mapCache in pairs(cache.mapCaches) do
				mapCache:ForNearbyNodes(x, y, mapCache.SetHidden, true)
			end
		end
	end

	local hiddenTime = Harvest.GetHiddenTime() * 60000
	for map, cache in pairs(Harvest.Data.mapCaches) do
		for nodeId, time in pairs(cache.hiddenTime) do
			if timeInMs - time > hiddenTime then
				cache:SetHidden( nodeId, false )
			end
		end
	end
end

-- this hack saves the name of the object that was last interacted with
local oldInteract = FISHING_MANAGER.StartInteraction
FISHING_MANAGER.StartInteraction = function(...)
	local action, name, blockedNode, isOwned = GetGameCameraInteractableActionInfo()
	Harvest.lastInteractableAction = action
	Harvest.lastInteractableName = name
	Harvest.lastInteractableOwned = isOwned
	if action then
		local pos = Harvest.lastInteractablePosition
		if IsMounted() then
			pos[2] = 0
		else
			-- only used for some debug purposes and to take measurements for lib3D
			--Harvest.PerformMeasurement()
			pos[1], pos[2], pos[3] = Harvest.Get3DPosition()
		end
	end
	
	return oldInteract(...)
end

-- some data structures canot be properly saved, this function restores them after the addon is fully loaded
function Harvest.FixSaveFile()
	-- tints cannot be saved (only as rgba table) so restore these tables to tint objects
	for _, layout in pairs( Harvest.GetMapLayouts() ) do
		if layout.color then
			layout.tint = ZO_ColorDef:New(unpack(layout.color))
			layout.color = nil
		else
			layout.tint = ZO_ColorDef:New(layout.tint)
		end
	end
end

-- returns hours since 1970
function Harvest.GetCurrentTimestamp()
	-- data is saved/serializes as string. to prevent the save file from bloating up, reduce the stamp to hours
	return zo_floor(GetTimeStamp() / 3600)
end

function Harvest.GetErrorLog()
	return Harvest.savedVars["global"].errorlog
end

function Harvest.AddToErrorLog(message)
	local log = Harvest.savedVars["global"].errorlog
	log.last = log.last + 1
	if log.last - log.start > 50 then
		log[log.start] = nil
		log.start = log.start + 1
	end
	log[log.last] = message
	if log.start > 50 then
		Harvest.ClearErrorLog()
		local newLog = Harvest.savedVars["global"].errorlog
		for i = log.start, log.last do
			newLog[i - log.start + 1] = log[i]
		end
	end
end

function Harvest.ClearErrorLog()
	Harvest.savedVars["global"].errorlog = {start = 1, last=0}
end

function Harvest.InitializeSavedVariables()
	Harvest.savedVars = {}
	-- global settings that are always account wide
	Harvest.savedVars["global"] = ZO_SavedVars:NewAccountWide("Harvest_SavedVars", 3, "global", Harvest.defaultGlobalSettings)
	if not Harvest.savedVars["global"].maxTimeDifference then --this setting was added in 3.0.8
		Harvest.savedVars["global"].maxTimeDifference = 0
	end
	if not Harvest.savedVars["global"].minGameVersion then -- added in 3.5.2 (it was previously bugged and a character setting)
		Harvest.savedVars["global"].minGameVersion = 0
	end
	if not Harvest.savedVars["global"].errorlog then --this log was added in 3.1.11
		Harvest.ClearErrorLog()
	end
	if not Harvest.savedVars["global"].errorlog.last then
		Harvest.ClearErrorLog()
	end
	if not Harvest.savedVars["global"].measurements then
		Harvest.savedVars["global"].measurements = {}
	end
	-- depending on the account wide setting, the settings may not be saved per character
	if Harvest.savedVars["global"].accountWideSettings then
		Harvest.savedVars["settings"] = ZO_SavedVars:NewAccountWide("Harvest_SavedVars", 3, "settings", Harvest.defaultSettings )
	else
		Harvest.savedVars["settings"] = ZO_SavedVars:New("Harvest_SavedVars", 3, "settings", Harvest.defaultSettings )
	end
	-- the settings might be from a previous HarvestMap version, in which case there might be missing attributes
	-- initilaize these missing attributes
	for key, value in pairs(Harvest.defaultSettings) do
		if Harvest.savedVars["settings"][key] == nil then
			Harvest.savedVars["settings"][key] = value
		end
	end
	-- changed the alchemy display in 3.5.1
	if Harvest.savedVars["settings"].compassLayouts[Harvest.MUSHROOM] ~= Harvest.defaultSettings.compassLayouts[Harvest.MUSHROOM] then
		Harvest.savedVars["settings"].compassLayouts[Harvest.MUSHROOM] = Harvest.defaultSettings.compassLayouts[Harvest.MUSHROOM]
		Harvest.savedVars["settings"].mapLayouts[Harvest.MUSHROOM] = Harvest.defaultSettings.mapLayouts[Harvest.MUSHROOM]
	end
end

function Harvest.OnLoad(eventCode, addOnName)
	if addOnName ~= "HarvestMap" then
		return
	end
	-- initialize temporary variables
	Harvest.wasHarvesting = false
	Harvest.action = nil
	Harvest.lastViewedUpdate = 0
	Harvest.lastInteractablePosition = {}
	-- 3d control which is used to calculate the player's position
	Harvest.measurementControl = HM_WorldPinsMeasurement
	Harvest.measurementControl:Create3DRenderSpace()
	Harvest.interactPosition = {}
	-- initialize save variables
	Harvest.InitializeSavedVariables()
	-- initialize the data/caching system
	Harvest.Data:Initialize()
	-- some data cannot be properly saved, ie functions or tints.
	-- repair this data
	Harvest.FixSaveFile()
	-- initialize pin callback functions
	Harvest.mapPinClickHandler:Initialize()
	Harvest.mapPins:Initialize()
	--Harvest.InitializeCompassMarkers()
	Harvest.InRangePins:Initialize()
	-- create addon option panels
	Harvest.InitializeOptions()
	Harvest.menu:Initialize()
	Harvest.filters:Initialize()
	Harvest.farm:Initialize()
	-- initialize bonus features
	if Harvest.IsHeatmapActive() then
		HarvestHeat.Initialize()
	end
	Harvest.menu:Finalize()

	EVENT_MANAGER:RegisterForUpdate("HarvestMap", 200, Harvest.OnUpdate)
	-- add these callbacks only after the addon has loaded to fix SnowmanDK's bug (comment section 20.12.15)
	EVENT_MANAGER:RegisterForEvent("HarvestMap", EVENT_LOOT_RECEIVED, Harvest.OnLootReceived)
	EVENT_MANAGER:RegisterForEvent("HarvestMap", EVENT_LOOT_UPDATED, Harvest.OnLootUpdated)
end

-- initialization which is dependant on other addons is done on EVENT_PLAYER_ACTIVATED
-- because harvestmap might've been loaded before them
function Harvest.OnActivated()
	Harvest.farm:PostInitialize()
	EVENT_MANAGER:UnregisterForEvent("HarvestMap", EVENT_PLAYER_ACTIVATED, Harvest.OnActivated)
end

EVENT_MANAGER:RegisterForEvent("HarvestMap", EVENT_ADD_ON_LOADED, Harvest.OnLoad)
EVENT_MANAGER:RegisterForEvent("HarvestMap", EVENT_PLAYER_ACTIVATED, Harvest.OnActivated)
