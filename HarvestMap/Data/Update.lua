
if not Harvest.Data then
	Harvest.Data = {}
end

-- This file handles updates of the serialized data. eg when something changes in the saveFile structure.
-- for instance after the DB update all itemIds for enchanting runes were removed.

local Harvest = _G["Harvest"]
local Data = Harvest.Data
local AS = LibStub("AceSerializer-3.0h")


-- In this file we use the old slower (de-)serialization methods of the ACE Serializer library.
-- I don't have old data, so I wouldn't be able to test, if the update functions work with the new (de-)serialization
local function Serialize(data)
	return AS:Serialize(data)
end

local function Deserialize(data)
	local success, result = AS:Deserialize(data)
	--  it seems some bug in HarvestMerge deleted the x or y coordinates
	if success then
		return result
	end
	return nil
end

-- updating the data can take quite some time
-- to prevent the game from freezing, we break each update process down into smaller parts
-- the smaller parts are executed with a small delay (see Harvest.OnUpdate(time) )
-- updating data as well as other heavy tasks such as importing data are added to the following queue
Harvest.updateQueue = {}
Harvest.updateQueue.first = 1
Harvest.updateQueue.afterLast = 1
function Harvest.IsUpdateQueueEmpty()
	return (Harvest.updateQueue.first == Harvest.updateQueue.afterLast)
end
-- adds a function to the back of the queue
function Harvest.AddToUpdateQueue(fun)
	Harvest.updateQueue[Harvest.updateQueue.afterLast] = fun
	Harvest.updateQueue.afterLast = Harvest.updateQueue.afterLast + 1
end
-- adds a funciton to the front of the queue
function Harvest.AddToFrontOfUpdateQueue(fun)
	Harvest.updateQueue.first = Harvest.updateQueue.first - 1
	Harvest.updateQueue[Harvest.updateQueue.first] = fun
end
-- executes the first function in the queue, if the player is activated yet
do
	local IsPlayerActivated = _G["IsPlayerActivated"]

	function Harvest.UpdateUpdateQueue() --shitty function name is shitty
		if not IsPlayerActivated() then return end
		local fun = Harvest.updateQueue[Harvest.updateQueue.first]
		Harvest.updateQueue[Harvest.updateQueue.first] = nil
		Harvest.updateQueue.first = Harvest.updateQueue.first + 1

		fun()

		if Harvest.IsUpdateQueueEmpty() then
			Harvest.updateQueue.first = 1
			Harvest.updateQueue.afterLast = 1
			Harvest.RefreshPins()
		end
	end
end

function Harvest.GetQueuePercent()
	return zo_floor((Harvest.updateQueue.first/Harvest.updateQueue.afterLast)*100)
end

------------------------
--#################################################
------------------------


local function DelayedUpdatePreHousingData(saveFile, pinTypes, nodes, mapIndex, pinTypeId, nodeIndex)
	local entry = nil
	local node
	local changed
	
	local targetPinType
	local newPinTypes = {[Harvest.MUSHROOM] = true, [Harvest.FLOWER] = true, [Harvest.WATERPLANT] = true}
	local newItemIdList
	
	if nodeIndex ~= nil then
		entry = nodes[nodeIndex]
	end
	-- in this frame we will process 2000 nodes
	for counter = 1,2000 do
		while nodeIndex == nil do
			pinTypeId = nil
			nodes = nil
			while pinTypeId == nil do
				mapIndex, pinTypes = next(saveFile.data, mapIndex)
				if mapIndex == nil then
					saveFile.dataVersion = 15
					d("HarvestMap finished updating pre-Housing data for this save file.")
					return
				end
				if pinTypes[Harvest.ALCHEMY] then
					-- add new pintypes (mushrooms are saved at the old alchemy location)
					pinTypes[Harvest.FLOWER] = {}
					pinTypes[Harvest.WATERPLANT] = {}
					pinTypeId = Harvest.ALCHEMY
					nodes = pinTypes[Harvest.ALCHEMY]
				else
					pinTypeId = nil
					nodes = nil
				end
				
			end
			nodeIndex, entry = next(nodes, nodeIndex)
		end
		-- here is the actual update part, all the stuff above is just used to delay the update over several frames
		changed = false
		node = Deserialize(entry)
		if node then -- check if something went wrong while deserializing
			-- delete the old node
			nodes[nodeIndex] = nil
			if node[Harvest.ITEMS] then
				-- split the node's item list into the new alchemy pin types
				newItemIdList = {max = 0, maxPinTypeId = 0}
				for itemId, stamp in pairs(node[Harvest.ITEMS]) do
					targetPinType = Harvest.itemId2PinType[itemId]
					if newPinTypes[targetPinType] then
						newItemIdList[targetPinType] = newItemIdList[targetPinType] or {}
						newItemIdList[targetPinType][itemId] = stamp
						if newItemIdList.max <= stamp then
							newItemIdList.max = stamp
							newItemIdList.maxPinTypeId = targetPinType
						end
					end
				end
				-- save the node as the new alchemy pin types
				if newItemIdList.maxPinTypeId ~= 0 then
					node[Harvest.TIME] = newItemIdList.max
					node[Harvest.ITEMS] = newItemIdList[newItemIdList.maxPinTypeId]
					pinTypes[newItemIdList.maxPinTypeId][nodeIndex] = Serialize(node)
				end
			end
		else -- node couldn't be deserialized, delete the corrupted data!
			nodes[nodeIndex] = nil
		end

		-- update stuff ends here
		nodeIndex, entry = next(nodes, nodeIndex)
	end
	-- add a new process to the front
	-- this way the next 2000 nodes will be updated
	-- (this needs to be added to the front, because at the back of the queue there could be updates for a newer data version
	-- the newer update should only be executed after this one has finished)
	Harvest.AddToFrontOfUpdateQueue(function()
		DelayedUpdatePreHousingData(saveFile, pinTypes, nodes, mapIndex, pinTypeId, nodeIndex)
	end)
end

local function UpdatePreHousingData( saveFile )
	-- if no save file was given, update all save files
	if saveFile == nil then
		if HarvestAD then
			UpdatePreHousingData( Data.savedVars["ADnodes"] )
		end
		if HarvestDC then
			UpdatePreHousingData( Data.savedVars["DCnodes"] )
		end
		if HarvestEP then
			UpdatePreHousingData( Data.savedVars["EPnodes"] )
		end
		UpdatePreHousingData( Data.savedVars["nodes"] )
		return
	end
	-- save file is already updated
	if (saveFile.dataVersion or 0) >= 15 then
		return
	end
	-- add the update process to the queue
	Harvest.AddToUpdateQueue(function()
		d("HarvestMap is updating pre-Housing data for a save file.")
		DelayedUpdatePreHousingData(saveFile, nil, nil, nil, nil, nil)
	end)
end

local function UpdatePreOneTamrielData( saveFile )
	if saveFile == nil then
		if HarvestAD then
			UpdatePreOneTamrielData( Data.savedVars["ADnodes"] )
		end
		if HarvestDC then
			UpdatePreOneTamrielData( Data.savedVars["DCnodes"] )
		end
		if HarvestEP then
			UpdatePreOneTamrielData( Data.savedVars["EPnodes"] )
		end
		UpdatePreOneTamrielData( Data.savedVars["nodes"] )
		return
	end

	if (saveFile.dataVersion or 0) >= 14 then
		return
	end

	Harvest.AddToUpdateQueue(function()
		d("HarvestMap is updating pre-OneTamriel data for a save file.")
		local newPinTypeData
		local pinTypeTransition = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
		pinTypeTransition[20] = 10
		pinTypeTransition[21] = 11
		local newPinType
		for map, pinTypeData in pairs(saveFile.data) do
			newPinTypeData = {}
			for pinTypeId, nodes in pairs(pinTypeData) do
				newPinType = pinTypeTransition[pinTypeId]
				if newPinType then
					newPinTypeData[newPinType] = nodes
				end
			end
			saveFile.data[map] = newPinTypeData
		end
		d("HarvestMap finished updating pre-OneTamriel data for this save file.")
		saveFile.dataVersion = 14
	end)
end


local function DelayedUpdatePreDBData(saveFile, pinTypes, nodes, mapIndex, pinTypeId, nodeIndex)
	local entry = nil
	local node
	local changed
	if nodeIndex ~= nil then
		entry = nodes[nodeIndex]
	end
	-- in this frame we will process 2000 nodes
	for counter = 1,2000 do
		while nodeIndex == nil do
			if pinTypes ~= nil then
				pinTypeId, nodes = next(pinTypes, pinTypeId)
			end
			while pinTypeId == nil do
				mapIndex, pinTypes = next(saveFile.data, mapIndex)
				if mapIndex == nil then
					saveFile.dataVersion = 13
					d("HarvestMap finished updating pre-Dark-Brotherhood data for this save file.")
					return
				end
				pinTypeId, nodes = next(pinTypes, pinTypeId)
			end
			nodeIndex, entry = next(nodes, nodeIndex)
		end
		-- here is the actual update part, all the stuff above is just used to delay the update over several frames
		changed = false
		node = Deserialize(entry)
		if node then -- check if something went wrong while deserializing
			-- node name list gets removed to reduce filesize
			-- the node name list isn't needed anymore as tooltips are calculated via the item ids
			node[3] = nil
			-- change the itemid list to a itemid -> timestamp table
			-- create itemid list if it doesn't exist (chests, fishing holes etc)
			if not node[4] or not Harvest.ShouldSaveItemId(pinTypeId) then
				node[4] = {}
			end
			-- i got reports of savefiles that are still in pre TG format
			-- to prevent the following lines from crashing, check for such a case and repair the file
			if type(node[4]) ~= "table" then
				node[4] = { node[4] }
			end
			-- change the itemid list to a itemid -> timestamp table
			local itemId2Timestamp = {}
			for _, itemId in pairs(node[4]) do
				itemId2Timestamp[itemId] = 0
			end
			node[4] = itemId2Timestamp
			-- serialize the changed data and save it
			nodes[nodeIndex] = Serialize(node)
		else -- node couldn't be deserialized, delete the corrupted data!
			nodes[nodeIndex] = nil
		end

		-- update stuff ends here
		nodeIndex, entry = next(nodes, nodeIndex)
	end
	-- add a new process to the front
	-- this way the next 2000 nodes will be updated
	-- (this needs to be added to the front, because at the back of the queue there could be updates for a newer data version
	-- the newer update should only be executed after this one has finished)
	Harvest.AddToFrontOfUpdateQueue(function()
		DelayedUpdatePreDBData(saveFile, pinTypes, nodes, mapIndex, pinTypeId, nodeIndex)
	end)
end

local function UpdatePreDBData( saveFile )
	-- if no save file was given, update all save files
	if saveFile == nil then
		if HarvestAD then
			UpdatePreDBData( Data.savedVars["ADnodes"] )
		end
		if HarvestDC then
			UpdatePreDBData( Data.savedVars["DCnodes"] )
		end
		if HarvestEP then
			UpdatePreDBData( Data.savedVars["EPnodes"] )
		end
		UpdatePreDBData( Data.savedVars["nodes"] )
		return
	end
	-- save file is already updated
	if (saveFile.dataVersion or 0) >= 13 then
		return
	end
	-- add the update process to the queue
	Harvest.AddToUpdateQueue(function()
		d("HarvestMap is updating pre-Dark-Brotherhood data for a save file.")
		DelayedUpdatePreDBData(saveFile, nil, nil, nil, nil, nil)
	end)
end

local function DelayedUpdateItemIdList(saveFile, pinTypes, nodes, mapIndex, pinTypeId, nodeIndex)
	local entry = nil
	local node
	local changed
	if nodeIndex ~= nil then
		entry = nodes[nodeIndex]
	end
	-- in this frame we will process 2000 nodes
	for counter = 1,2000 do
		while nodeIndex == nil do
			if pinTypes ~= nil then
				pinTypeId, nodes = next(pinTypes, pinTypeId)
			end
			while pinTypeId == nil do
				mapIndex, pinTypes = next(saveFile.data, mapIndex)
				if mapIndex == nil then
					saveFile.dataVersion = 11
					d("HarvestMap finished updating pre-Thieves-Guild data for this save file.")
					return
				end
				pinTypeId, nodes = next(pinTypes, pinTypeId)
			end
			nodeIndex, entry = next(nodes, nodeIndex)
		end
		-- here is the actual update part, all the stuff above is just used to delay the update over several frames
		changed = false
		node = Deserialize(entry)
		if node then -- check if something went wrong while deserializing
			if type(node[4]) == "number" then -- itemId (4th field) becomes a list
				node[4] = { node[4] }
				changed = true
			end
			if pinTypeId == Harvest.FISHING then
				node[3] = { "fish" }
				changed = true
			end
			-- no itemIds for fishing, chest and thieves troves
			if not Harvest.ShouldSaveItemId(pinTypeId) then
				node[4] = nil
				changed = true
			end
			if changed then -- serialize the data again and save it, if something was changed by the update routine
				nodes[nodeIndex] = Serialize(node)
			end
		else -- node couldn't be deserialized, delete the corrupted data!
			nodes[nodeIndex] = nil
		end

		-- update stuff ends here
		nodeIndex, entry = next(nodes, nodeIndex)
	end
	-- add a new process to the front
	-- this way the next 2000 nodes will be updated
	-- (this needs to be added to the front, because at the back of the queue there could be updates for a newer data version
	-- the newer update should only be executed after this one has finished)
	Harvest.AddToFrontOfUpdateQueue(function()
		DelayedUpdateItemIdList(saveFile, pinTypes, nodes, mapIndex, pinTypeId, nodeIndex)
	end)
end

local function UpdateItemIdList( saveFile )
	if saveFile == nil then
		if HarvestAD then
			UpdateItemIdList( Data.savedVars["ADnodes"] )
		end
		if HarvestDC then
			UpdateItemIdList( Data.savedVars["DCnodes"] )
		end
		if HarvestEP then
			UpdateItemIdList( Data.savedVars["EPnodes"] )
		end
		UpdateItemIdList( Data.savedVars["nodes"] )
		return
	end

	if (saveFile.dataVersion or 0) >= 11 then
		return
	end

	Harvest.AddToUpdateQueue(function()
		d("HarvestMap is updating pre-Thieves-Guild data for a save file.")
		DelayedUpdateItemIdList(saveFile, nil, nil, nil, nil, nil)
	end)
end

local function DelayedUpdatePreOrsiniumData(saveFile, pinTypes, nodes, mapIndex, pinTypeId, nodeIndex)
	local entry = nil
	if nodeIndex ~= nil then
		entry = nodes[nodeIndex]
	end
	for counter = 1,2000 do
		while nodeIndex == nil do
			if pinTypes ~= nil then
				pinTypeId, nodes = next(pinTypes, pinTypeId)
			end
			while pinTypeId == nil do
				mapIndex, pinTypes = next(saveFile.data, mapIndex)
				if mapIndex == nil then
					saveFile.dataVersion = 10
					d("HarvestMap finished updating pre-Orsinium data for this save file.")
					return
				end
				pinTypeId, nodes = next(pinTypes, pinTypeId)
			end
			nodeIndex, entry = next(nodes, nodeIndex)
		end
		if type(entry) == "table" then
			nodes[nodeIndex] = Serialize(entry)
		end
		nodeIndex, entry = next(nodes, nodeIndex)
	end
	Harvest.AddToFrontOfUpdateQueue(function()
		DelayedUpdatePreOrsiniumData(saveFile, pinTypes, nodes, mapIndex, pinTypeId, nodeIndex)
	end)
end

local function UpdatePreOrsiniumData( saveFile )
	saveFile = saveFile or Data.savedVars["nodes"]

	if (saveFile.dataVersion or 0) >= 10 then
		return
	end

	Harvest.AddToUpdateQueue(function()
		d("HarvestMap is updating pre-Orsinium data for a save file.")
		DelayedUpdatePreOrsiniumData(saveFile, nil, nil, nil, nil, nil)
	end)
end

-- check if saved data is from an older version,
-- update the data if needed
function Data:UpdateDataVersion( saveFile )
	-- import old data (Orsinium Update)
	UpdatePreOrsiniumData( saveFile )
	-- make itemID a list and fix the chest - fish - bug (Thieves Guild Update)
	UpdateItemIdList( saveFile )
	-- dark brotherhood update, simplify data by removing unused fields
	-- remove node name, change itemid list to itemid -> timestamp table
	UpdatePreDBData( saveFile )
	-- change pinTypeId structure (consecutive Ids)
	UpdatePreOneTamrielData( saveFile )
	-- split alchemy into mushroom, flower, waterplant
	UpdatePreHousingData( saveFile )
end

