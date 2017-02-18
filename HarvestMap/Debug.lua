if not Harvest then
	Harvest = {}
end

function Harvest.GenerateDebugInfo()
	list = {}
	table.insert(list, "[spoiler][code]\n")
	table.insert(list, "Version:")
	table.insert(list, Harvest.displayVersion)
	table.insert(list, "\n")
	for key, value in pairs(Harvest.defaultSettings) do
		value = Harvest.savedVars["settings"][key]
		if type(value) ~= "table" then
			table.insert(list, key)
			table.insert(list, ":")
			table.insert(list, tostring(value))
			table.insert(list, "\n")
		else
			local k, v = next(value)
			if type(v) == "boolean" then
				table.insert(list, key)
				table.insert(list, ":")
				for k, v in ipairs(value) do
					if v then
						table.insert(list, "y")
					else
						table.insert(list, "n")
					end
				end
				table.insert(list, "\n")
			end
		end
	end
	table.insert(list, "Addons:\n")
	local addonManager = GetAddOnManager()
	for addonIndex = 1, addonManager:GetNumAddOns() do
		local name, _, _, _, enabled = addonManager:GetAddOnInfo(addonIndex)
		if enabled then
			table.insert(list, name)
			table.insert(list, "\n")
		end
	end
	table.insert(list, "[/code][/spoiler]")
	return table.concat(list)
end



function Harvest.Correlation()
	local correlation = {}
	local mapCache = Harvest.mapPins.mapCache
	
	for index, nodeId in pairs(mapCache.nodesOfPinType[Harvest.ALCHEMY]) do
		for itemId, timestamp in pairs(mapCache.items[nodeId]) do
			correlation[itemId] = correlation[itemId] or {}
			for itemId2, timestamp2 in pairs(mapCache.items[nodeId]) do
				correlation[itemId][itemId2] = (correlation[itemId][itemId2] or 0) + 1
			end
		end
	end
	
	local itemIds = {}
	local output = {}
	local line = {}
	local max
	for itemId, listOfItemIds in pairs(correlation) do
		table.insert(itemIds, itemId)
		table.insert(line, Harvest.itemId2Tooltip[itemId] or tostring(itemId))
		max = 0
		for itemId2, number in pairs(listOfItemIds) do
			max = zo_max(max, number)
		end
		for itemId2, number in pairs(listOfItemIds) do
			listOfItemIds[itemId2] = number / max
		end
	end
	--table.insert(output, table.concat(line," "))
	
	for _, itemId in pairs(itemIds) do
		line = {Harvest.itemId2Tooltip[itemId] or tostring(itemId)}
		for _, itemId2 in pairs(itemIds) do
			correlation[itemId][itemId2] = zo_round(correlation[itemId][itemId2] * 100)
			table.insert(line, tostring(correlation[itemId][itemId2])) 
		end
		table.insert(output, table.concat(line," "))
	end
	output = table.concat(output,"\n")
	d(output)
end