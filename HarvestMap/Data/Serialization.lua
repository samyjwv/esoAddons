
if not Harvest.Data then
	Harvest.Data = {}
end

local Harvest = _G["Harvest"]
local Data = Harvest.Data

local tonumber = _G["tonumber"]
local assert = _G["assert"]
local gmatch = string.gmatch
local tostring = _G["tostring"]
local insert = table.insert
local format = string.format
local concat = table.concat

local function GetNumberValue(getNextChunk)
	local number
	local typ, data = getNextChunk()
	if typ == "^N" then
		number = tonumber(data)
	elseif typ == "^F" then
		local typ2, data2 = getNextChunk()
		assert(typ2 == "^f")
		local mantissa = tonumber(data)
		local exponent = tonumber(data2)
		number = mantissa * (2^exponent)
	end
	return number
end

-- loads the node represented by serializedData without creating a node table
local function Deserialize(serializedData, pinTypeId)
	local x, y, z, items
	local timestamp = 0
	local version = 0

	local getNextChunk = gmatch(serializedData, "(^.)([^^]*)")
	assert(getNextChunk() == "^1") -- split the ^1 part
	assert(getNextChunk() == "^T") -- split the ^T part
	local i = 0
	for typ, data in getNextChunk do
		if typ == "^N" then
			if data == "1" then
				x = GetNumberValue(getNextChunk)
			elseif data == "2" then
				y = GetNumberValue(getNextChunk)
			elseif data == "3" then
				z = GetNumberValue(getNextChunk)
				if z == 0 then z = nil end -- harvest merge sets unknown z values to 0
			elseif data == "4" then
				assert(getNextChunk() == "^T",serializedData) -- split the ^T part
				if Harvest.ShouldSaveItemId(pinTypeId) then
					items = {}
					local itemId, stamp
					typ, data = getNextChunk()
					while typ == "^N" do -- while the table isn't over
						itemId = tonumber(data)
						typ, data = getNextChunk()
						assert(typ == "^N", serializedData)
						stamp = tonumber(data)
						items[itemId] = stamp
						typ, data = getNextChunk()
						i = i + 1
					end
					assert(typ == "^t",serializedData)
				else
					for typ in getNextChunk do
						if typ == "^t" then break end
					end
				end
			elseif data == "5" then
				typ, data = getNextChunk()
				assert(typ == "^N",serializedData)
				timestamp = tonumber(data)
			elseif data == "6" then
				typ, data = getNextChunk()
				assert(typ == "^N",serializedData)
				version = tonumber(data)
			end
		end
		i = i + 1
		if i > 30 then error(serializedData) end
	end
	assert(x)
	assert(y)
	return x, y, z, items, timestamp, version
end

function Data:Deserialize(serializedData, pinTypeId)
	return pcall(Deserialize, serializedData, pinTypeId)
end

function Data:Serialize(x, y, z, items, timestamp, version)
	local parts = {}
	insert(parts, "^1^T^N1^N")
	insert(parts, format("%.10f", x))
	insert(parts, "^N2^N")
	insert(parts, format("%.10f", y))
	if z then
		insert(parts, "^N3^N")
		insert(parts, format("%.1f", z))
	end
	if items then
		insert(parts, "^N4^T")
		for itemId, stamp in pairs(items) do
			insert(parts, "^N")
			insert(parts, tostring(itemId))
			insert(parts, "^N")
			insert(parts, tostring(stamp))
		end
		insert(parts, "^t")
	end
	insert(parts, "^N5^N")
	insert(parts, tostring(timestamp or 0))
	insert(parts, "^N6^N")
	insert(parts, tostring(version or 0))
	insert(parts, "^t^^")
	return concat(parts)
end