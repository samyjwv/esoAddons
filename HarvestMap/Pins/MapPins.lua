
local LMP = LibStub("LibMapPins-1.0")

local Harvest = _G["Harvest"]
local pairs = _G["pairs"]
local IsUnitInCombat = _G["IsUnitInCombat"]

local CallbackManager = Harvest.callbackManager
local Events = Harvest.events

local MapPins = {}
Harvest.mapPins = MapPins

function MapPins:Initialize()
	self.pinTable = {} -- queue which stores pin creation and removal commands
	self.hasEntries = false -- stores if the queue has entries
	-- coords of the last pin update for the "display only nearby pins" option
	self.lastViewedX = -10
	self.lastViewedY = -10
	-- pin manager which is used to create or remove pins
	self.pinManager = LMP.pinManager
	
	-- register callbacks for events, that affect map pins:
	-- respawn timer:
	CallbackManager:RegisterForEvent(Events.CHANGED_NODE_HIDDEN_STATE, function(event, map, nodeId, newState)
		self:OnChangedNodeHiddenState(map, nodeId, newState)
	end)
	-- creating/updating a node (after harvesting something) or deletion of a node (via debug tools)
	local callback = function(...) self:OnNodeChangedCallback(...) end
	CallbackManager:RegisterForEvent(Events.NODE_DELETED, callback)
	CallbackManager:RegisterForEvent(Events.NODE_UPDATED, callback)
	CallbackManager:RegisterForEvent(Events.NODE_ADDED, callback)
	-- when a map related setting is changed
	CallbackManager:RegisterForEvent(Events.SETTING_CHANGED, function(...) self:OnSettingsChanged(...) end)
	
	-- load pin layouts
	self.layouts = Harvest.GetMapLayouts()
	
	-- pin type which is always visible to receive the global pin refresh callback
	-- if votan's or fyrakin's minimap are used, all nodes are of this pin type.
	-- this is because all pin types need to be refreshed at the same time, so the position of the player
	-- is the same. (the position is needed for the "display only nearby pins" option).
	-- FyrMM sometimes calls the refresh function for one specific pin type, so instead of multiple pin types, we use only one pin type.
	-- votan's minimap calls the refresh callback for each pin type with a delay of about 1sec. (probably to prevent lag when entering a city)
	-- so we use only one pintype again.
	-- if neither of the minimaps is used, we can use multiple pin types, because all refresh callbacks are called at the same time.
	self.defaultLayout = {
		level = self.layouts[1].level,
		texture = function(pin)
			local pinTypeId = self.mapCache.pinTypeId[pin.m_PinTag]
			if pinTypeId then --stuck pin, this happens sometimes when FyrMM is used
				-- After a pin refresh, the minimap doesn't only display the newly created pins by the refresh callback.
				-- The minimap instead caches all pins and draws all pins that were ever created by previous refresh callbacks.
				-- If a ressource node is deleted for instance, the minimap doesn't care and will try to draw a pin anyways,
				-- because the pin was created once in a previous refresh callback.
				return self.layouts[pinTypeId].texture
			end
			return self.defaultTexture
		end,
		size = Harvest.GetMapPinSize(0),
		tint = function(pin)
			local pinTypeId = self.mapCache.pinTypeId[pin.m_PinTag]
			if pinTypeId then --stuck pin, this happens sometimes when FyrMM is used. see above.
				return self.layouts[pinTypeId].tint
			end
			return self.defaultTint
		end,
	}
	self.defaultTexture = "EsoUI/Art/MapPins/hostile_pin.dds"
	self.defaultTint = ZO_ColorDef:New(1, 1, 1, 1)
	
	
	self.registeredPinTypeIds = {}
	
	LMP:AddPinType(
		Harvest.GetPinType( "0" ),
		function() MapPins:PinTypeRefreshCallback(0) end,
		nil,
		self.defaultLayout,
		Harvest.tooltipCreator
	)
	table.insert(self.registeredPinTypeIds, 0)
	
	-- the "real" pin types for each ressource and the farming helper tour.
	-- in case of FyrMM or votan's minimap, these ressource pins aren't used,
	-- but they are still created so we can add the filter checkboxes to the map's filter panel.
	for index, pinTypeId in pairs( Harvest.PINTYPES ) do
		self:InitializeMapPinType( pinTypeId )
	end
	
	Harvest.mapPinClickHandler:Push("defaultClick", MapPins.clickHandler)
end

-- called for each pinTypeId to register the pinType in the lib map pin library.
-- also adds a checkbox for the pinType in the map's filter panel
function MapPins:InitializeMapPinType( pinTypeId )
	local pinType = Harvest.GetPinType( pinTypeId )

	if pinTypeId == Harvest.TOUR then
	 -- todo redd this
	 --[[
		LMP:AddPinType(
			pinType,
			HarvestFarm.MapCallback,
			nil,
			Harvest.GetMapPinLayout( pinTypeId ),
			Harvest.tooltipCreator
		)
		--]]
	else
		-- create the pin type for this ressource
		LMP:AddPinType(
			pinType,
			function() end, -- no callback is used, because all pins are created together in the callback
			-- of the dummy pinType 0
			nil,
			Harvest.GetMapPinLayout( pinTypeId ),
			Harvest.tooltipCreator
		)
		
		-- add filter checkbox to the map's filter panel
		local pve, pvp, imperial = LMP:AddPinFilter(
			pinType,
			Harvest.GetLocalization( "pintype" .. pinTypeId ),
			false,
			Harvest.savedVars["settings"].isPinTypeVisible,
			pinTypeId, pinTypeId, pinTypeId
		)
		-- replace the callback function of the checkbox, so HarvestMap's settings function is called.
		local fun = function(button, visible)
			Harvest.SetMapPinTypeVisible( pinTypeId, visible )
			CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", Harvest.optionsPanel)
		end
		ZO_CheckButton_SetToggleFunction(pve, fun)
		ZO_CheckButton_SetToggleFunction(pvp, fun)
	end
	
	table.insert(self.registeredPinTypeIds, pinTypeId)
end

-- called whenever a ressource is harvested (which adds a node or updates an already existing node)
-- or when a node is deleted by the debug tool
function MapPins:OnNodeChangedCallback(event, map, pinTypeId, nodeId)
	local nodeAdded = (event == Events.NODE_ADDED)
	local nodeUpdated = (event == Events.NODE_UPDATED)
	local nodeDeleted = (event == Events.NODE_DELETED)
	
	-- when the heatmap is active, the map pins aren't used
	if Harvest.IsHeatmapActive() then
		return
	end
	
	-- the node isn't on the currently displayed map
	if not self:IsActiveMap(map) then
		return
	end
	
	-- if the node's pin type is visible, then we do not have to manipulate any pins
	if not Harvest.IsMapPinTypeVisible(pinTypeId) then
		return
	end
	
	-- queue the pin change
	if FyrMM then
		-- queued pin manipulation doesn't work with FyrMM so just refresh all pins
		
		-- known bug: the refresh is ignored by FyrMM if a node was deleted.
		-- probably because the deletion is performed while the minimap is hidden.
		
		-- known bug: when changing the position of a node (i.e. the player harvested something at a location,
		-- that already had a pin), then the minimap will sometimes display the old AND the new position.
		-- there will be two pins, one at the old position and one at the new one.
		-- probably because the minimap caches old pins and doesn't match the new and the old pin - even though
		-- they have the same pin tag.
		-- a similar issue is described in the function "MapPins.AddAndRemoveVisblePins" further below
		self:RefreshPins()
	else
		-- refresh a single pin by removing and recreating it
		if not nodeAdded then
			self:RemoveNode(nodeId, pinTypeId)
		end
		-- the (re-)creation of the pin is performed, if the pin isn't hidden by the respawn timer
		if not nodeDeleted and not self.mapCache:IsHidden(nodeId) then
			self:AddNode(nodeId)
		end
	end
end

-- called whenever a node is hidden by the respawn timer or when it becomes visible again.
function MapPins:OnChangedNodeHiddenState(map, nodeId, newState)
	if self:IsActiveMap(map) then
		local pinTypeId = self.mapCache.pinTypeId[nodeId]
		if not pinTypeId then return end
		
		if not Harvest.IsMapPinTypeVisible(pinTypeId) then
			return
		end
		-- remove the node, if it was hidden.
		-- otherwise create the pin because the node is visible again.
		if newState then
			self:RemoveNode(nodeId, pinTypeId)
		else
			self:AddNode(nodeId)
		end
	end
end

-- adds the node to the pin creation queue
function MapPins:AddNode(nodeId)
	if not self.mapCache then return end
	if self.pinTable[nodeId] and self.pinTable[nodeId] < 0 then
		self.pinTable[nodeId] = nil
	else
		self.pinTable[nodeId] = self.mapCache.pinTypeId[nodeId]
	end
	self.hasEntries = (next(self.pinTable) ~= nil)
end

-- removes the node from the map and clears it from the creation queue
function MapPins:RemoveNode(nodeId, pinTypeId)
	if not self.mapCache then return end
	self.pinTable[nodeId] = nil
	self.hasEntries = (next(self.pinTable) ~= nil)
	
	if FyrMM or VOTANS_MINIMAP then
		LMP:RemoveCustomPin(Harvest.GetPinType(0), nodeId)
	else
		LMP:RemoveCustomPin(Harvest.GetPinType(self.mapCache.pinTypeId[nodeId] or pinTypeId), nodeId)
	end
end

-- Clear the entire queue. Used when the currently viewed map changes or the pins are to be refreshed.
function MapPins:ClearQueue()
	self.pinTable = {}
	self.hasEntries = false
end

-- the pin listed in the creation queue are only created, if should delay returns false.
-- i.e. the creation of pins can be delayed when the player is in-fight or the map is closed, to improve the performance.
function MapPins:ShouldDelay()
	if Harvest.IsDelayedWhenMapClosed() and not ZO_WorldMap_IsWorldMapShowing() then
		return true
	end
	if Harvest.IsDelayedWhenInFight() and IsUnitInCombat("player") then
		return true
	end
	return false
end

-- refreshes all ressource pins or the farming helper tour pin.
-- if the given pintype is the tour, refresh only that pin
-- otherwise refresh all ressource pins.
function MapPins:RefreshPins( pinTypeId )
	-- refresh tour pin
	if pinTypeId == Harvest.TOUR then
		LMP:RefreshPins( Harvest.GetPinType( pinTypeId ))
		return
	end
	
	-- refresh all ressource pins
	self:RemovePins()
	
	for _, pinType in pairs(Harvest.PINTYPES) do
		if pinType ~= Harvest.TOUR then
			LMP:RefreshPins( Harvest.GetPinType( pinType ))
		end
	end
	LMP:RefreshPins( Harvest.GetPinType( "0" ))
end

-- called every few seconds to update the pins in the visible range
function MapPins:UpdateVisibleMapPins()
	if Harvest.IsHeatmapActive() then return end

	local map = Harvest.GetMap()
	local x, y = GetMapPlayerPosition("player")

	self:AddAndRemoveVisblePins(map, x, y)
end

-- If the player moved, some pins enter the visible radius while others leave it.
-- This function updates the queue with new creation/removal commands according to the movement.
function MapPins:AddAndRemoveVisblePins(map, x, y)
	-- if there is no pin data available, or the data doesn't match the current map, abort.
	if not self.mapCache then return end
	if self.mapCache.map ~= map then return end
	-- no pins are displayed when the heatmap mode is used.
	if Harvest.IsHeatmapActive() then return end
	
	-- add creation and removal commands to the pin queue.
	local shouldSaveCoords
	shouldSaveCoords = self.mapCache:SetPrevAndCurVisibleNodesToTable(self.lastViewedX, self.lastViewedY, x, y, self.pinTable)
	-- the queue is only updated if the distance of the player's current position and the position of the last update is large enough.
	-- if the distance was large enough, we have to save the current position
	if shouldSaveCoords then
		self.lastViewedX = x
		self.lastViewedY = y
	end

	self.hasEntries = (next(self.pinTable) ~= nil)
	
	-- queuing the pin changes doesn't work with FyrMM, instead just refresh the pins
	if self.hasEntries and FyrMM then
		self:ClearQueue()
		self:RefreshPins()
		-- known bug:
		-- FyrMM remembers all pins that were ever created.
		-- after the refresh callback, FyrMM will display the newly created pins AND all the saved
		-- pins which were created previously.
		-- As a result there will be a trail behind the players movement, because out of range pins are not removed.
		-- ....also this bug seems to be random and doesn't always happen.
		-- sometimes the minimap displays only the pins in the visible range and then after another refresh (e.g. harvesting or moving far enough)
		-- suddenly all previous pins appear again.
	end
end

-- removes all ressource pins from the map AND clears the pin queue.
function MapPins:RemovePins()
	self:ClearQueue()
	for _, pinTypeId in pairs(self.registeredPinTypeIds) do
		if pinTypeId ~= Harvest.TOUR then
			self.pinManager:RemovePins(Harvest.GetPinType(pinTypeId))
		end
	end
end

-- saves the current map and position
-- and loads the ressource data for the current map
function MapPins:SetToMapAndPosition(map, x, y, measurement, zoneIndex)
	-- save current map
	self.currentMap = map
	-- remove old cache and load the new one
	if self.mapCache then
		self.mapCache.accessed = self.mapCache.accessed - 1
	end
	self.mapCache = Harvest.Data:GetMapCache(nil, map, measurement, zoneIndex)
	-- if no data is available for this map, abort.
	if not self.mapCache then
		self.hasEntries = false
		return
	end
	self.mapCache.accessed = self.mapCache.accessed + 1
	-- set the last position of the player when the map pins were refreshed, for the "display only in range pins" option
	self.lastViewedX = x
	self.lastViewedY = y
end

---Adds the nodes of the given pin type to the creation queue.
function MapPins:AddVisibleNodesOfPinType(pinTypeId)
	if not self.mapCache then return end
	Harvest.Data:CheckPinTypeInCache(pinTypeId, self.mapCache)
	
	self.mapCache:GetVisibleNodes(self.lastViewedX, self.lastViewedY, pinTypeId, self.pinTable)
	self.hasEntries = (next(self.pinTable) ~= nil)
end

-- Creates and removes a bunch of queued pins.
function MapPins:PerformActions()
	if not self.hasEntries then
		-- queue is empty
		return
	end
	if self:ShouldDelay() then
		-- we need to delay the creation.
		-- e.g. the player is infight or the map is closed (can be changed in the settings)
		return
	end
	
	-- the number of pins we want to create/remove during this update
	local numNodes = Harvest.GetDisplaySpeed()
	local x, y, defaultPinTypeId, pinTypeName, pin
	-- if one of these minimap is active, all pins are created as pintype 0
	if FyrMM or VOTANS_MINIMAP then defaultPinTypeId = 0 end
	-- perform the update:
	for nodeId, pinTypeId in pairs(self.pinTable) do
		if pinTypeId > 0 then -- the pin is to be created
			pinTypeName = Harvest.GetPinType(defaultPinTypeId or pinTypeId)
			x = self.mapCache.localX[nodeId]
			y = self.mapCache.localY[nodeId]
			-- if a pin with this node already exists, move it to the new location
			-- this prevents stuck pins
			-- TODO FyrMM makes this return nil, so that might cause some bugs?
			pin = LMP:FindCustomPin(pinTypeName, nodeId)
			if pin then
				pin:SetLocation(x, y)
			else
				LMP:CreatePin(pinTypeName, nodeId, x, y)
			end
		else -- the pin has to be removed
			pinTypeName = Harvest.GetPinType(defaultPinTypeId or (-pinTypeId))
			x = self.mapCache.localX[nodeId]
			y = self.mapCache.localY[nodeId]
			LMP:RemoveCustomPin(pinTypeName, nodeId)
		end
		self.pinTable[nodeId] = nil
		numNodes = numNodes - 1
		if numNodes <= 0 then
			-- the queue isn't empty, but there were enough pin creations/removals for this update
			-- the rest is done in the next update
			return
		end
	end
	-- all entries in the queue were handled and the queue is now empty
	self.hasEntries = false
end

function MapPins:IsActiveMap(map)
	if not self.mapCache then return false end
	return (self.mapCache.map == map)
end

function MapPins:PinTypeRefreshCallback(pinTypeId)
	Harvest.Debug("Refresh of pins requested. pinType: " .. tostring(pinTypeId))
	-- remove previous pins and clear the queue
	if FyrMM and FyrMM.LoadingCustomPins[_G[Harvest.GetPinType(pinTypeId)]] then
		-- the callback was called for the minimap, so it doesn't create map pins
		-- do not remove the map pins but still clear the queue in case there is something stored.
		self:ClearQueue()
	else
		-- not sure what causes it but the old pins aren't always removed, before this callback is called.
		-- (maybe caused by some other addon?)
		-- removing the old pins prevents stuck pins, which are caused by re-creating already existing pins
		self:RemovePins(pinTypeId)
	end
	
	-- data is still being manipulated, better if we don't access it yet
	if not Harvest.IsUpdateQueueEmpty() then
		Harvest.Debug("your data is still being refactored/updated" )
		return
	end
	
	if Harvest.IsHeatmapActive() then
		Harvest.Debug("pins could not be refreshed, heatmap is active" )
		return
	end

	local map, x, y, measurement, zoneIndex = Harvest.GetLocation( true )
	
	self:SetToMapAndPosition(map, x, y, measurement, zoneIndex)
	for _, pinTypeId in ipairs(Harvest.PINTYPES) do
		if Harvest.IsMapPinTypeVisible(pinTypeId) then
			self:AddVisibleNodesOfPinType(pinTypeId)
		end
	end
	
	-- delayed pin creation doesn't work with fyrakin's minimap, so create the pins right now
	if FyrMM then
		self:PerformActions()
	end
	
	return
end

-- used by the debugHandler (click callback).
-- this is the string used in the click menu, when multiple pins are close to each other.
MapPins.nameFunction = function( pin )
	local lines = Harvest.GetLocalizedTooltip( pin, MapPins.mapCache )
	return table.concat(lines, "\n")
end

-- when the debug mode is enabled, this is the description of what happens if the player clicks on a pin.
-- if a pin is clicked, the node is deleted.
MapPins.clickHandler = {-- debugHandler = {
	{
		name = Harvest.mapPins.nameFunction,
		callback = function(...) Harvest.farm.helper:OnPinClicked(...) end,
		show = function(pin) 
			if not Harvest.farm.path then return false end
			
			local pinType, nodeId = pin:GetPinTypeAndTag()
			local index = Harvest.farm.path:GetIndex(nodeId)
			if not index then return false end
			
			return true
		end,
	},
	{
		name = MapPins.nameFunction,
		callback = function(pin)
			-- remove this callback if the debug mode is disabled
			if not Harvest.IsDebugEnabled() or IsInGamepadPreferredMode() then
				return
			end
			-- otherwise request the node to be deleted
			local pinType, nodeId = pin:GetPinTypeAndTag()
			local pinTypeId = MapPins.mapCache.pinTypeId[nodeId]
			local nodeIndex = MapPins.mapCache.nodeIndex[nodeId]
			local saveFile = Harvest.Data:GetSaveFile( MapPins.mapCache.map )
			if Harvest.AreDeletionsTracked() then
				Harvest.savedVars["global"].deletedNodes = Harvest.savedVars["global"].deletedNodes or {}
				local nodes = Harvest.savedVars["global"].deletedNodes
				nodes[MapPins.mapCache.map] = nodes[MapPins.mapCache.map] or {}
				nodes[MapPins.mapCache.map][pinTypeId] = nodes[MapPins.mapCache.map][pinTypeId] or {}
				table.insert(nodes[MapPins.mapCache.map][pinTypeId], saveFile.data[ MapPins.mapCache.map ][ pinTypeId ][ nodeIndex ])
			end
			MapPins.mapCache:Delete(nodeId)
			saveFile.data[ MapPins.mapCache.map ][ pinTypeId ][ nodeIndex ] = nil
			
		end,
		show = function() return Harvest.IsDebugEnabled() and not IsInGamepadPreferredMode() end,
		duplicates = function(pin1, pin2) return not Harvest.IsDebugEnabled() end,
		gamepadName = nameFun
	}
}

-- these settings are handled by simply refreshing the map pins.
MapPins.refreshOnSetting = {
	hasVisibleDistance = true,
	visibleDistance = true,
	heatmapActive = true,
}
function MapPins:OnSettingsChanged(event, setting, ...)
	if self.refreshOnSetting[setting] then
		self:RefreshPins()
	elseif setting == "mapPinTypeVisible" then
		-- the visiblity of a pin type was changed (e.g. a checkbox in the map's filter panel was used)
		-- enable the pin type and refresh the pins.
		local pinTypeId, visible = ...
		LMP:SetEnabled( Harvest.GetPinType(pinTypeId), visible )
		-- known bug:
		-- FyrMM doesn't refresh the pins
		-- probably because the minimap is hidden while the map's filter panel is visible
		self:RefreshPins()
	elseif setting == "debugModeEnabled" then
		--[[
		local enabled = ...
		if enabled and not IsInGamepadPreferredMode() then
			Harvest.mapPinClickHandler:Push("debug", debugHandler)
		else
			Harvest.mapPinClickHandler:Pop("debug")
		end
		--]]
	elseif setting == "pinTypeSize" then
		local pinTypeId, size = ...
		LMP:SetLayoutKey( Harvest.GetPinType( pinTypeId ), "size", size )
		self:RefreshPins()
	elseif setting == "pinTypeColor" then
		local pinTypeId, r, g, b = ...
		local layout = LMP:GetLayoutKey( Harvest.GetPinType( pinTypeId ), "tint" )
		layout:SetRGB( r, g, b )
		self:RefreshPins()
	elseif setting == "cacheCleared" then
		local map = ...
		if map == self.currentMap or not map then
			self:RefreshPins()
		end
	elseif setting == "pinAbovePoi" then
		local above = ...
		if above then
			self.defaultLayout.level = 55
		else
			self.defaultLayout.level = 20
		end
		self:RefreshPins()
	end
end

-- description for the map pin tooltips
Harvest.tooltipCreator = {
	creator = function( pin ) -- this function is called when the mouse is over a pin and a tooltip has to be displayed
		if not Harvest.AreDebugMessagesEnabled() then
			local lines = Harvest.GetLocalizedTooltip( pin, MapPins.mapCache )
			for _, line in ipairs(lines) do
				InformationTooltip:AddLine( line )
			end
		else
			local nodeId = pin.m_PinTag
			local pinTypeId = Harvest.mapPins.mapCache.pinTypeId[nodeId]
			local nodeIndex = MapPins.mapCache.nodeIndex[nodeId]
			local map = MapPins.mapCache.map
			
			InformationTooltip:AddLine( tostring(nodeIndex) .. ", " .. map)
			
			local saveFile = Harvest.Data:GetSaveFile( map )
			local ace = saveFile.data[ map ][ pinTypeId ][ nodeIndex ]
			
			InformationTooltip:AddLine( tostring(ace) )
		end
	end,
	tooltip = 1
}
