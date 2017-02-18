
if not Harvest.Data then
	Harvest.Data = {}
end

local Harvest = _G["Harvest"]

local Events = Harvest.events
local CallbackManager = Harvest.callbackManager

local zo_min = _G["zo_min"]
local zo_max = _G["zo_max"]
local zo_ceil = _G["zo_ceil"]
local zo_floor = _G["zo_floor"]
local pairs = _G["pairs"]
local ipairs = _G["ipairs"]

--[[
Each MapCache stores deserialized nodes for the given map.
If a map measurement is passed, the cache will also store the nodes' global coordinates and
will also create an addition cache system which subdivides the map into smaller squares.
When nodes near a certain position are requested, the cache must then only iterate over the nodes
in nearby squares instead of all nodes, which improves the performance.
--]]
local MapCache = ZO_Object:Subclass()
Harvest.Data.MapCache = MapCache

local GlobalDivisions = 200 -- 200 divisions on global scale

function MapCache:New(...)
	local obj = ZO_Object.New(self)
	obj:Initialize(...)
	return obj
end

function MapCache:Initialize(map, measurement, zoneIndex)
	self.time = GetFrameTimeSeconds()
	self.accessed = 0
	self.map = map
	self.measurement = measurement
	self.zoneIndex = zoneIndex
	self.lastNodeId = 0
	
	self.log = {}
	
	self.pinTypeId = {}
	self.nodeIndex = {} -- index of the node in the saved variables table data[map][pinTypeId][nodeIndex]
	self.localX = {}
	self.localY = {}
	self.worldZ = {}
	self.items = {}
	self.timestamp = {}
	self.version = {}
	self.hiddenTime = {}

	if measurement then
		self.globalX = {}
		self.globalY = {}
		
		self.divisions = {}
		for _, pinTypeId in ipairs(Harvest.PINTYPES) do
			self.divisions[pinTypeId] = {}
		end
		self.numDivisions = zo_ceil(GlobalDivisions * self.measurement.scaleX)
		self.worldSize = 4000 / 0.16 * measurement.scaleX--Harvest.GetMapWorldSize(map)
	end

	self.nodesOfPinType = {}
	self.nodesOfPinTypeSize = {}
	
	CallbackManager:FireCallbacks(Events.CACHE_CREATED, self)
end

function MapCache:InitializePinType(pinTypeId)
	self.nodesOfPinTypeSize[pinTypeId] = self.nodesOfPinTypeSize[pinTypeId] or 0
	self.nodesOfPinType[pinTypeId] = self.nodesOfPinType[pinTypeId] or {}
end

-----------------------------------------------------------
-- Methods to add, delete and update data in the cache
-----------------------------------------------------------

function MapCache:Add(pinTypeId, nodeIndex, x, y, z, items, timestamp, version)
	self.lastNodeId = self.lastNodeId + 1
	local nodeId = self.lastNodeId

	local pinTypeSize = self.nodesOfPinTypeSize[pinTypeId] + 1
	self.nodesOfPinTypeSize[pinTypeId] = pinTypeSize
	self.nodesOfPinType[pinTypeId][pinTypeSize] = nodeId
	if not nodeIndex then
		nodeIndex = pinTypeSize
	end

	self.pinTypeId[nodeId] = pinTypeId
	self.nodeIndex[nodeId] = nodeIndex
	self.localX[nodeId] = x
	self.localY[nodeId] = y
	self.worldZ[nodeId] = z
	self.timestamp[nodeId] = timestamp
	self.items[nodeId] = items
	self.version[nodeId] = version
	

	if self.measurement then
		self.globalX[nodeId] = x * self.measurement.scaleX + self.measurement.offsetX
		self.globalY[nodeId] = y * self.measurement.scaleY + self.measurement.offsetY
		local index = zo_floor(x * self.numDivisions) + zo_floor(y * self.numDivisions) * self.numDivisions
		local division = self.divisions[pinTypeId][index] or {}
		self.divisions[pinTypeId][index] = division
		division[#division+1] = nodeId
	end

	return nodeId
end

function MapCache:Delete(nodeId)
	
	local pinTypeId = self.pinTypeId[nodeId]
	if not pinTypeId then
		Harvest.Debug("Can not delete stuck pins, as they do not belong to the current map.")
		return
	end
	local nodesOfPinType = self.nodesOfPinType[pinTypeId]
	for i = 1, self.nodesOfPinTypeSize[pinTypeId] do
		if nodesOfPinType[i] == nodeId then
			nodesOfPinType[i] = nil
			break
		end
	end

	if self.measurement then
		self.globalX[nodeId] = nil
		self.globalY[nodeId] = nil
	
		local x = self.localX[nodeId]
		local y = self.localY[nodeId]
		local index = zo_floor(x * self.numDivisions) + zo_floor(y * self.numDivisions) * self.numDivisions
		local division = self.divisions[pinTypeId][index]
		for i, nId in pairs(division) do
			if nId == nodeId then
				division[i] = nil
				break
			end
		end
	end

	self.pinTypeId[nodeId] = nil
	self.nodeIndex[nodeId] = nil
	self.localX[nodeId] = nil
	self.localY[nodeId] = nil
	self.worldZ[nodeId] = nil
	self.items[nodeId] = nil
	self.timestamp[nodeId] = nil
	self.version[nodeId] = nil
	self.hiddenTime[nodeId] = nil
	
	CallbackManager:FireCallbacks(Events.NODE_DELETED, self.map, pinTypeId, nodeId)
end

function MapCache:Merge(nodeId, x, y, z, items, timestamp, version)
	-- merge items
	if items then
		local oldItems = self.items[nodeId]
		oldItems = oldItems or {}
		if type(items) == "table" then -- list of items was given
			for itemId, itemTimestamp in pairs(items) do
				oldItems[itemId] = zo_max(itemTimestamp, oldItems[itemId] or 0)
			end
		else -- only one item was given
			local itemId = items
			self.items[nodeId] = self.items[nodeId] or {}
			self.items[nodeId][itemId] = timestamp
		end
		self.items[nodeId] = oldItems
	end
	
	if timestamp >= self.timestamp[nodeId] then
		if self.measurement then
			self.globalX[nodeId] = x * self.measurement.scaleX + self.measurement.offsetX
			self.globalY[nodeId] = y * self.measurement.scaleY + self.measurement.offsetY
			local oldIndex = zo_floor(self.localX[nodeId] * self.numDivisions) + zo_floor(self.localY[nodeId] * self.numDivisions) * self.numDivisions
			local newIndex = zo_floor(x * self.numDivisions) + zo_floor(y * self.numDivisions) * self.numDivisions
			if oldIndex ~= newIndex then
				local pinTypeId = self.pinTypeId[nodeId]
				-- remove form old position
				local division = self.divisions[pinTypeId][oldIndex]
				for _, nId in pairs(division) do
					if nId == nodeId then
						division[nId] = nil
						break
					end
				end
				-- readd to new position
				division = self.divisions[pinTypeId][newIndex] or {}
				self.divisions[pinTypeId][newIndex] = division
				division[#division+1] = nodeId
			end
		end
		self.localX[nodeId] = x
		self.localY[nodeId] = y
		self.worldZ[nodeId] = z or self.worldZ[nodeId]
		self.timestamp[nodeId] = timestamp
		self.version[nodeId] = version
		
	end

	return self.localX[nodeId], self.localY[nodeId], self.worldZ[nodeId], self.items[nodeId], self.timestamp[nodeId], self.version[nodeId]
end

function MapCache:SetHidden(nodeId, isHidden)
	local wasHidden = (self.hiddenTime[nodeId] ~= nil)
	if isHidden then
		self.hiddenTime[nodeId] = GetFrameTimeMilliseconds()
	else
		self.hiddenTime[nodeId] = nil
	end
	if wasHidden ~= isHidden then
		Harvest.Debug("changed hidden state of a node")
		CallbackManager:FireCallbacks(Events.CHANGED_NODE_HIDDEN_STATE, self.map, nodeId, isHidden)
	end
end

function MapCache:IsHidden(nodeId)
	return self.hiddenTime[nodeId]
end

-----------------------------------------------------------
-- Methods to receive nodes that meet certain conditions
-----------------------------------------------------------

function MapCache:ForNearbyNodes(globalX, globalY, callback, ...)
	if not globalX then return end -- global coords can become nil on some maps (ie aurbis)
	self.time = GetFrameTimeSeconds()
	if not self.measurement then return end
	
	local localX = (globalX - self.measurement.offsetX) / self.measurement.scaleX 
	local localY = (globalY - self.measurement.offsetY) / self.measurement.scaleY
	if localX < 0 or localY < 0 or localX >= 1 or localY >= 1 then
		return
	end
	
	local globalMinDistance = Harvest.GetGlobalMinDistanceBetweenPins() * Harvest.GetVisitedRangeMultiplier()
	local divisionX = zo_floor(localX * self.numDivisions)
	local divisionY = zo_floor(localY * self.numDivisions)

	local divisions, division, dx, dy

	for _, pinTypeId in ipairs(Harvest.PINTYPES) do
		divisions = self.divisions[pinTypeId]
		for i = divisionX - 1, divisionX + 1 do
			for j = divisionY - 1, divisionY + 1 do
				division = divisions[i + j * self.numDivisions]
				if division then
					for _, nodeId in pairs(division) do
						dx = self.globalX[nodeId] - globalX
						dy = self.globalY[nodeId] - globalY
						if dx * dx + dy * dy < globalMinDistance then
							callback(self, nodeId, ...)
						end
					end
				end
			end
		end
	end
end

function MapCache:GetMergeableNode(pinTypeId, x, y)
	self.time = GetFrameTimeSeconds()
	if not self.measurement then return end
	
	Harvest.Data:CheckPinTypeInCache(pinTypeId, self)
	
	local globalBasedMinDistance = Harvest.GetGlobalMinDistanceBetweenPins() / (self.measurement.scaleX * self.measurement.scaleY)
	globalBasedMinDistance = globalBasedMinDistance / (self.measurement.distanceCorrection * self.measurement.distanceCorrection)
	globalBasedMinDistance = zo_min(globalBasedMinDistance, 0.07 * 0.07)
	local localMinDistance = Harvest.GetMinDistanceBetweenPins()
	local divisionX = zo_floor(x * self.numDivisions)
	local divisionY = zo_floor(y * self.numDivisions)

	local divisions = self.divisions[pinTypeId]
	local division, dx, dy, distance
	local startJ = zo_max(0, divisionY - 1)
	local endJ = zo_min(divisionY + 1, self.numDivisions-1)
	
	local bestDistance = math.huge
	local bestNodeId = nil
	
	for i = zo_max(0, divisionX - 1), zo_min(divisionX + 1, self.numDivisions-1) do
		for j = startJ, endJ do
			division = divisions[i + j * self.numDivisions]
			if division then
				for _, nodeId in pairs(division) do
					dx = self.localX[nodeId] - x
					dy = self.localY[nodeId] - y
					distance = dx * dx + dy * dy
					if distance < globalBasedMinDistance then --distance < localMinDistance or 
						if distance < bestDistance then
							bestNodeId = nodeId
							bestDistance = distance
						end
						--return nodeId
					end
				end
			end
		end
	end
	
	return bestNodeId
end

function MapCache:GetVisibleNodes(x, y, pinTypeId, output)
	self.time = GetFrameTimeSeconds()
	if not self.measurement then return end -- universe map
	if Harvest.HasPinVisibleDistance() then
		local maxDistance = Harvest.GetPinVisibleDistance()
		local divisionX = zo_floor(x * self.numDivisions)
		local divisionY = zo_floor(y * self.numDivisions)

		local globalX = x * self.measurement.scaleX
		local globalY = y * self.measurement.scaleY
		local range = zo_ceil(GlobalDivisions * maxDistance)
		maxDistance = maxDistance * maxDistance

		local division, dx, dy, divisions
		local centerX, centerY
		local startJ = zo_max(0, divisionY - range)
		local endJ = zo_min(divisionY + range, self.numDivisions-1)

		divisions = self.divisions[pinTypeId]
		for i = zo_max(0,divisionX - range), zo_min(divisionX + range, self.numDivisions-1)  do
			centerX = (i+0.5) / self.numDivisions * self.measurement.scaleX
			dx = centerX - globalX
			for j = startJ, endJ do
				centerY = (j+0.5) / self.numDivisions * self.measurement.scaleY
				dy = centerY - globalY
				if dx * dx + dy * dy < maxDistance then
					division = divisions[i + j * self.numDivisions]
					if division then
						for _, nodeId in pairs(division) do
							if not self.hiddenTime[nodeId] then
								output[nodeId] = pinTypeId
							end
						end
					end
				end
			end
		end
	else
		for _, nodeId in pairs(self.nodesOfPinType[pinTypeId]) do
			if not self.hiddenTime[nodeId] then
				output[nodeId] = pinTypeId
			end
		end
	end
end

---
-- used for the nearby map pins display
-- updates the position, adds newly visible pins to the output-queue and
-- removes newly out of range pins from the output-queue
function MapCache:SetPrevAndCurVisibleNodesToTable(previousX, previousY, currentX, currentY, output)
	self.time = GetFrameTimeSeconds()
	if not self.measurement then return end -- universe map
	local maxDistance = Harvest.GetPinVisibleDistance()
	local prevDivX = zo_floor(previousX * self.numDivisions)
	local prevDivY = zo_floor(previousY * self.numDivisions)
	local divX = zo_floor(currentX * self.numDivisions)
	local divY = zo_floor(currentY * self.numDivisions)
	if prevDivX == divX and prevDivY == divY then
		return false
	end

	local prevGlobalX = previousX * self.measurement.scaleX
	local prevGlobalY = previousY * self.measurement.scaleY
	local globalX = currentX * self.measurement.scaleX
	local globalY = currentY * self.measurement.scaleY

	local range = zo_ceil(GlobalDivisions * maxDistance)
	maxDistance = maxDistance * maxDistance

	local divisions, division, dx, dy, prevdx, prevdy, typeId
	local centerX, centerY
	local startJ = zo_max(0,divY - range)
	local endJ = zo_min(divY + range, self.numDivisions-1)
	
	for i = zo_max(0,divX - range), zo_min(divX + range, self.numDivisions-1)  do
		centerX = (i+0.5) / self.numDivisions * self.measurement.scaleX
		dx = centerX - globalX
		prevdx = centerX - prevGlobalX
		for j = startJ, endJ do
			centerY = (j+0.5) / self.numDivisions  * self.measurement.scaleY
			dy = centerY - globalY
			prevdy = centerY - prevGlobalY
			if dx * dx + dy * dy < maxDistance then -- inside current range
				if prevdx * prevdx + prevdy * prevdy >= maxDistance then -- outside previous range
					for _, pinTypeId in ipairs(Harvest.PINTYPES) do
						division = self.divisions[pinTypeId][i + j * self.numDivisions]
						if division then
							if Harvest.IsMapPinTypeVisible(pinTypeId) then
								for _, nodeId in pairs(division) do
									if not self.hiddenTime[nodeId] then
										if output[nodeId] and output[nodeId] < 0 then -- pin should be removed
											output[nodeId] = nil
										else
											output[nodeId] = pinTypeId
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	startJ = zo_max(0,prevDivY - range)
	endJ = zo_min(prevDivY + range, self.numDivisions-1)
	
	for i = zo_max(0,prevDivX - range), zo_min(prevDivX + range, self.numDivisions-1)  do
		centerX = (i+0.5) / self.numDivisions * self.measurement.scaleX
		dx = centerX - globalX
		prevdx = centerX - prevGlobalX
		for j = startJ, endJ do
			centerY = (j+0.5) / self.numDivisions * self.measurement.scaleY
			dy = centerY - globalY
			prevdy = centerY - prevGlobalY
			if dx * dx + dy * dy >= maxDistance then -- outside current range
				if prevdx * prevdx + prevdy * prevdy < maxDistance then -- inside previous range
					for _, pinTypeId in ipairs(Harvest.PINTYPES) do
						division = self.divisions[pinTypeId][i + j * self.numDivisions]
						if division then
							if Harvest.IsMapPinTypeVisible(pinTypeId) then
								for _, nodeId in pairs(division) do
									if not self.hiddenTime[nodeId] then
										if output[nodeId] and output[nodeId] > 0 then -- if pin should be created
											output[nodeId] = nil
										else
											output[nodeId] = -pinTypeId -- negative because the pin should be removed
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	return true
end

function MapCache:ForNodesInRange(globalX, globalY, heading, maxDistance, callback, ...)
	if not globalX then return end -- global coords can become nil on some maps (ie aurbis)
	if not self.measurement then return end
	
	globalX = globalX - self.measurement.offsetX
	globalY = globalY - self.measurement.offsetY
	local localX = globalX / self.measurement.scaleX 
	local localY = globalY / self.measurement.scaleY
	
	maxDistance = maxDistance / self.measurement.distanceCorrection
	
	local divisionX = zo_floor(localX * self.numDivisions)
	local divisionY = zo_floor(localY * self.numDivisions)

	local range = zo_ceil(GlobalDivisions * maxDistance)
	local distToCenter =  0.71 * self.measurement.scaleX / self.numDivisions
	maxDistance = maxDistance + distToCenter
	maxDistance = maxDistance * maxDistance
	
	local dirX = math.sin(heading)
	local dirY = math.cos(heading)
	
	local division, dx, dy, divisions
	local centerX, centerY, index
	local startJ = zo_max(0,divisionY - range)
	local endJ = zo_min(divisionY + range, self.numDivisions-1)
	
	divisions = self.divisions[pinTypeId]
	for i = zo_max(0,divisionX - range), zo_min(divisionX + range, self.numDivisions-1)  do
		centerX = (i+0.5) / self.numDivisions * self.measurement.scaleX
		dx = centerX - globalX
		for j = startJ, endJ do
			centerY = (j+0.5) / self.numDivisions * self.measurement.scaleY
			dy = centerY - globalY
			if dx * dirX + dy * dirY < distToCenter and dx * dx + dy * dy < maxDistance then
				index = i + j * self.numDivisions
				for _, pinTypeId in ipairs(Harvest.PINTYPES) do
					division = self.divisions[pinTypeId][index]
					if division then
						if Harvest.IsInRangePinTypeVisible(pinTypeId) then
							for _, nodeId in pairs(division) do
								if not self.hiddenTime[nodeId] then
									callback(self, nodeId, ...)
								end
							end
						end
					end
				end
			end
		end
	end
end
