local Lib3D = LibStub("Lib3D")

if not Harvest.Data then
	Harvest.Data = {}
end

local Harvest = _G["Harvest"]
local Data = Harvest.Data
local CallbackManager = Harvest.callbackManager
local Events = Harvest.events

function Data:Initialize()
	-- cache the ACE deserialized nodes
	-- this way changing maps multiple times will create less lag
	self.mapCaches = {}
	self.numCaches = 0
	
	-- nodes are saved account wide
	self.savedVars = {}
	self.savedVars.nodes  = ZO_SavedVars:NewAccountWide("Harvest_SavedVars", 2, "nodes", { data = {} })
	if not self.savedVars.nodes.firstLoaded then
		self.savedVars.nodes.firstLoaded = Harvest.GetCurrentTimestamp()
	end
	self.savedVars.nodes.lastLoaded = Harvest.GetCurrentTimestamp()
	-- load other node addons, if they are activated
	if HarvestAD then
		self.savedVars.ADnodes = HarvestAD.savedVars
	end
	if HarvestEP then
		self.savedVars.EPnodes = HarvestEP.savedVars
	end
	if HarvestDC then
		self.savedVars.DCnodes = HarvestDC.savedVars
	end
	if HarvestDLC then
		self.savedVars.DLCnodes  = HarvestDLC.savedVars
	end
	
	-- check if saved data is from an older version,
	-- update the data if needed
	Data:UpdateDataVersion()
	
	-- move data to correct save files
	-- if AD was disabled while harvesting in AD, everything was saved in ["nodes"]
	-- when ad is enabled, everything needs to be moved to that save file
	-- HOWEVER, only execute this after the save files were updated!
	Harvest.AddToUpdateQueue(function() self:MoveData() end)
	
	-- when the time setting is changed, all caches need to be reloaded
	local clearCache = function(event, setting, value)
		if setting == "applyTimeDifference" then
			self.mapCaches = {}
			self.numCaches = 0
			CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "cacheCleared")
		end
	end
	CallbackManager:RegisterForEvent(Events.SETTING_CHANGED, clearCache)
	
	EVENT_MANAGER:RegisterForEvent("HarvestMapNewZone", EVENT_PLAYER_ACTIVATED, function() self:OnPlayerActivated() end)
end

-- imports all the nodes on 'map' from the table 'data' into the save file table 'saveFile'
-- if checkPinType is true, data will be skipped if Harvest.IsPinTypeSavedOnImport(pinTypeId) returns false
function Data:ImportFromMap( map, data, saveFile, checkPinType )
	local insert = table.insert
	local pairs = _G["pairs"]
	local zo_max = _G["zo_max"]
	local type = _G["type"]
	local next = _G["next"]

	-- nothing to merge, data can simply be copied
	if saveFile.data[ map ] == nil then
		saveFile.data[ map ] = data
		return
	end
	-- the target table contains already a bunch of nodes, so the data has to be merged
	local targetData = nil
	local newNode = nil
	local index = 0
	local oldNode = nil
	local distance = Harvest.GetMinDistanceBetweenPins()
	local timestamp = Harvest.GetCurrentTimestamp()
	local maxTimeDifference = Harvest.GetMaxTimeDifference()
	local success, x, y, x2, y2, z, items, stamp, version, dx, dy
	local isValid
	local cache = Data.MapCache:New(map)
	for _, pinTypeId in ipairs(Harvest.PINTYPES) do
		if (not checkPinType) or Harvest.IsPinTypeSavedOnImport( pinTypeId ) then
			cache:InitializePinType(pinTypeId)
			if saveFile.data[ map ][ pinTypeId ] == nil then
				-- nothing to merge for this pin type, just copy the data
				saveFile.data[ map ][ pinTypeId ] = data[ pinTypeId ]
			else
				-- deserialize target data and clear the serialized target data table (we'll fill it again at the end)
				local startIndex = cache.lastNodeId+1
				for nodeIndex, node in pairs( saveFile.data[ map ][ pinTypeId ] ) do
					success, x, y, z, items, stamp, version = self:Deserialize(node, pinTypeId)
					if success then -- check if something went wrong while deserializing the node
						cache:Add(pinTypeId, nil, x, y, z, items, stamp, version )
					end
				end
				local endIndex = cache.lastNodeId

				saveFile.data[ map ][ pinTypeId ] = {}
				-- deserialize every new node and merge them with the old nodes
				data[ pinTypeId ] = data[ pinTypeId ] or {}
				for nodeIndex, node in pairs( data[ pinTypeId ] ) do
					success, x, y, z, items, stamp, version = self:Deserialize(node, pinTypeId)
					if success then -- check if something went wrong while deserializing the node
						-- If the node is new enough to be saved
						isValid = true
						if maxTimeDifference > 0 and (timestamp - stamp) > maxTimeDifference then
							isValid = false
						end

						if isValid then
							-- If we have found this node already then we don't need to save it again
							for nodeId = startIndex, endIndex do
								x2 = cache.localX[nodeId]
								y2 = cache.localY[nodeId]

								dx = x - x2
								dy = y - y2
								-- the nodes are too close
								if dx * dx + dy * dy < distance then
									cache:Merge(nodeId, x, y, z, items, stamp, version)
									isValid = false
									break
								end
							end
						end

						if isValid then
							cache:Add(pinTypeId, nil, x, y, z, items, stamp, version )
						end
					end
				end
				-- serialize the new data
				for nodeIndex, nodeId in pairs( cache.nodesOfPinType[pinTypeId] ) do
					x = cache.localX[nodeId]
					y = cache.localY[nodeId]
					z = cache.worldZ[nodeId]
					items = cache.items[nodeId]
					stamp = cache.timestamp[nodeId]
					version = cache.version[nodeId]
					saveFile.data[ map ][ pinTypeId ][ nodeIndex ] = self:Serialize(x, y, z, items, stamp, version)
				end
			end
		end
	end
	-- as new data was added to the map, the appropiate cache has to be cleared
	local existingCache = self.mapCaches[map]
	if existingCache then
		self.mapCaches[map] = nil
		self.numCaches = self.numCaches - 1
		CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "cacheCleared", map)
	end
end

-- returns the correct table for the map (HarvestMap, HarvestMapAD/DC/EP save file tables)
-- will return HarvestMap's table if the correct table doesn't currently exist.
-- ie the HarvestMapAD addon isn't currently active
function Data:GetSaveFile( map )
	return self:GetSpecialSaveFile( map ) or self.savedVars["nodes"]
end

-- returns the correct (external) table for the map or nil if no such table exists
function Data:GetSpecialSaveFile( map )
	local zone = string.gsub( map, "/.*$", "" )
	if HarvestAD then
		if HarvestAD.zones[ zone ] then
			return self.savedVars["ADnodes"]
		end
	end
	if HarvestEP then
		if HarvestEP.zones[ zone ] then
			return self.savedVars["EPnodes"]
		end
	end
	if HarvestDC then
		if HarvestDC.zones[ zone ] then
			return self.savedVars["DCnodes"]
		end
	end
	if HarvestDLC then
		if HarvestDLC.zones[ zone ] then
			return self.savedVars["DLCnodes"]
		end
	end
	return nil
end

-- this function moves data from the HarvestMap addon to HarvestMapAD/DC/EP
function Data:MoveData()
	for map, data in pairs( self.savedVars["nodes"].data ) do
		local zone = string.gsub( map, "/.*$", "" )
		local file = self:GetSpecialSaveFile( map )
		if file ~= nil then
			Harvest.AddToUpdateQueue(function()
				self:ImportFromMap( map, data, file )
				self.savedVars["nodes"].data[ map ] = nil
				Harvest.Debug("Moving old data to the correct save files. " .. tostring(Harvest.GetQueuePercent()) .. "%")
			end)
		end
	end
end

-- data is stored as ACE strings
-- this functions deserializes the strings and saves the results in the cache
function Data:LoadToCache(pinTypeId, cache)
	cache:InitializePinType(pinTypeId)
	local map = cache.map
	local measurement = cache.measurement
	local saveFile = self:GetSaveFile(map)
	saveFile.data[ map ] = (saveFile.data[ map ]) or {}
	saveFile.data[ map ][ pinTypeId ] = (saveFile.data[ map ][ pinTypeId ]) or {}
	local serializedNodes = saveFile.data[ map ][ pinTypeId ]

	local currentTimestamp = Harvest.GetCurrentTimestamp()
	local maxTimeDifference = Harvest.GetMaxTimeDifference()
	local distance = Harvest.GetGlobalMinDistanceBetweenPins() / (measurement.distanceCorrection * measurement.distanceCorrection)
	local startIndex = cache.lastNodeId + 1
	
	local minGameVersion = Harvest.GetMinGameVersion()
	
	
	local valid, updated, globalX, globalY, addonVersion, gameVersion
	local success, x, y, z, names, items, timestamp, version
	local globalX2, globalY2, dx, dy, stamp, stamp2, items, items2
	-- deserialize the nodes
	for nodeIndex, node in pairs( serializedNodes ) do
		success, x, y, z, items, timestamp, version = self:Deserialize( node, pinTypeId )
		if not success then--or not x or not y then
			Harvest.AddToErrorLog(x)
		else
			valid = true
			updated = false
			-- remove nodes that are too old (either number of days or patch)
			if maxTimeDifference > 0 and currentTimestamp - timestamp > maxTimeDifference then
				valid = false
			end
			-- remove outdated item ids
			if isValid and items and maxTimeDifference > 0 then
				for itemId, itemStamp in pairs(items) do
					if (timestamp - itemStamp) > maxTimeDifference then
						items[itemId] = nil
						updated = true
					end
				end
			end
			
			if minGameVersion > 0 and zo_floor(version / 1000) < minGameVersion then
				valid = false
			end
			
			-- nodes must be inside the current map
			if valid then
				valid = (0 <= x and x < 1 and 0 <= y and x < 1)
				if not valid then
					Harvest.AddToErrorLog("invalid coord:" .. map .. node )
				end
			end
			if measurement and valid then
				globalX = x * measurement.scaleX + measurement.offsetX
				globalY = y * measurement.scaleY + measurement.offsetY
				-- remove nodes which were wrongfully saved on their global position
				addonVersion = version % 1000
				gameVersion = zo_floor(version / 1000)
				
				if addonVersion < 1 then
					if (globalX - x)^2 + (globalY - y)^2 < 0.009 then
						Harvest.AddToErrorLog("old addon version, global-local-bug:" .. map .. node )
						valid = false
					end
				end
				-- hew's bane was rescaled some time between 5th and 11th december (no patch maintenance, so it's really weird...)
				-- the same rescale also happened during the DB update (though the scaling was done in the other direction)
				-- let's try to repair it by merging nodes:
				-- the newer node is kept when two nodes can reconstruct each other by rescaling the map
				if valid then
					if map == "thievesguild/hewsbane_base" then
						for nodeId = startIndex, cache.lastNodeId do
							dx = cache.localX[nodeId] - x * 0.9871
							dy = cache.localY[nodeId] - y * 0.9871
							-- the nodes are too close
							if dx * dx + dy * dy < 0.00003 then
								x, y, z, items, timestamp, version = cache:Merge(nodeId, x, y, z, items, timestamp, version)
								-- update the old node
								serializedNodes[cache.nodeIndex[nodeId] ] = self:Serialize(x, y, z, items, timestamp, version)
								Harvest.AddToErrorLog("node was merged:" .. map .. node )
								valid = false -- set this to false, so the node isn't added to the cache
								break
							end
							dx = cache.localX[nodeId] - x / 0.9871
							dy = cache.localY[nodeId] - y / 0.9871
							-- the nodes are too close
							if dx * dx + dy * dy < 0.00003 then
								x, y, z, items, timestamp, version = cache:Merge(nodeId, x, y, z, items, timestamp, version)
								-- update the old node
								serializedNodes[cache.nodeIndex[nodeId] ] = self:Serialize(x, y, z, items, timestamp, version)
								Harvest.AddToErrorLog("node was merged:" .. map .. node )
								valid = false -- set this to false, so the node isn't added to the cache
								break
							end
						end
					end
				end
				
			end
			-- remove close nodes (ie duplicates on cities)
			if measurement and valid then
				-- compare distance to previous nodes
				for nodeId = startIndex, cache.lastNodeId do
					globalX2 = cache.globalX[nodeId]
					globalY2 = cache.globalY[nodeId]

					dx = globalX - globalX2
					dy = globalY - globalY2
					-- the nodes are too close
					if dx * dx + dy * dy < distance then
						x, y, z, items, timestamp, version = cache:Merge(nodeId, x, y, z, items, timestamp, version)
						-- update the old node
						serializedNodes[cache.nodeIndex[nodeId]] = self:Serialize(x, y, z, items, timestamp, version)
						Harvest.AddToErrorLog("node was merged:" .. map .. node )
						valid = false -- set this to false, so the node isn't added to the cache
						break
					end
				end

			end
			-- there are items saved even though, there shouldn't be items for this pin type
			if valid and not Harvest.ShouldSaveItemId(pinTypeId) and items then
				if next(items) then
					updated = true
				end
				items = nil
			end

			if valid then
				cache:Add(pinTypeId, nodeIndex, x, y, z, items, timestamp, version)
				if updated then
					serializedNodes[nodeIndex] = self:Serialize(x, y, z, items, timestamp, version)
				end
			else
				serializedNodes[nodeIndex] = nil
			end
		end
	end
end

-- loads the nodes to cache and returns them
function Data:GetMapCache(pinTypeId, map, measurement, zoneIndex)
	if not Harvest.IsUpdateQueueEmpty() then return end
	-- if the current map isn't in the cache, create the cache
	if not self.mapCaches[map] then
		if not measurement or not zoneIndex then return end
		
		local cache = Data.MapCache:New(map, measurement, zoneIndex)
		
		self.mapCaches[map] = cache
		self.numCaches = self.numCaches + 1
		
		local oldest = cache
		local oldestMap
		for i = 1, self.numCaches - Harvest.GetMaxCachedMaps() do
			for map, cache in pairs(self.mapCaches) do
				if cache.time < oldest.time and cache.accessed == 0 then
					oldest = cache
					oldestMap = map
				end
			end
			
			if not oldestMap then break end
			
			Harvest.Debug("Clear cache for map " .. oldestMap)
			self.mapCaches[oldestMap] = nil
			oldest = cache
			self.numCaches = self.numCaches - 1
		end
		
		-- fill the newly created cache with data
		for _, pinTypeId in ipairs(Harvest.PINTYPES) do
			if Harvest.IsPinTypeVisible(pinTypeId) then
				self:LoadToCache(pinTypeId, cache)
			end
		end
		
		if self.currentZoneCache and zoneIndex == self.currentZoneCache.zoneIndex then
			self.currentZoneCache.mapCaches[map] = cache
			cache.accessed = cache.accessed + 1
			CallbackManager:FireCallbacks(Events.MAP_ADDED_TO_ZONE, cache, self.currentZoneCache)
		end
		
		return cache
	end
	local cache = self.mapCaches[map]
	-- if there was a pin type given, make sure the given pin type is in the cache
	if pinTypeId then
		self:CheckPinTypeInCache(pinTypeId, cache)
	else
		for _, pinTypeId in ipairs(Harvest.PINTYPES) do
			if Harvest.IsPinTypeVisible(pinTypeId) then
				self:CheckPinTypeInCache(pinTypeId, cache)
			end
		end
	end

	return cache
end

function Data:GetCurrentZoneCache()
	return self.currentZoneCache
end

function Data:OnPlayerActivated()
	local zoneIndex = GetUnitZoneIndex("player")
	if not self.currentZoneCache or self.currentZoneCache.zoneIndex ~= zoneIndex then
		if self.currentZoneCache then
			self.currentZoneCache:Dispose()
		end
		self.currentZoneCache = self.ZoneCache:New(zoneIndex)
		for map, mapCache in pairs(self.mapCaches) do
			if mapCache.zoneIndex == zoneIndex then
				self.currentZoneCache.mapCaches[map] = mapCache
				mapCache.accessed = mapCache.accessed + 1
			end
		end
		
		local distanceCorrection = Lib3D:GetGlobalToWorldFactor(GetZoneId(zoneIndex))
		if distanceCorrection then
			-- usually 1 in global coords coresponds to 25 km, but some maps scale differently
			distanceCorrection = distanceCorrection / 25000
		else
			-- delves tend to be scaled down on the zone map, so we need to return a smaller value
			if mapType == MAP_CONTENT_DUNGEON and measurement.scaleX < 0.003 then
				distanceCorrection = math.sqrt(165)
			else
				distanceCorrection = 1
			end
		end
		
		CallbackManager:FireCallbacks(Events.NEW_ZONE_ENTERED, self.currentZoneCache, distanceCorrection)
	end
end

function Data:CheckPinTypeInCache(pinTypeId, mapCache)
	if not mapCache.nodesOfPinType[pinTypeId] then
		self:LoadToCache(pinTypeId, mapCache)
	end
end