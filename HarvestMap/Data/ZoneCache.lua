local Harvest = _G["Harvest"]

local ZoneCache = ZO_Object:Subclass()
Harvest.Data.ZoneCache = ZoneCache

function ZoneCache:New(...)
	local obj = ZO_Object.New(self)
	obj:Initialize(...)
	return obj
end

function ZoneCache:Initialize(zoneIndex)
	self.zoneIndex = zoneIndex
	self.mapCaches = {}
end


function ZoneCache:ForNearbyNodes(...)
	for _, mapCache in pairs(self.mapCaches) do
		mapCache:ForNearbyNodes(...)
	end
end

function ZoneCache:ForNodesInRange(...)
	for _, mapCache in pairs(self.mapCaches) do
		mapCache:ForNodesInRange(...)
	end
end

function ZoneCache:Dispose()
	for map, mapCache in pairs(self.mapCaches) do
		mapCache.accessed = mapCache.accessed - 1
	end
	self.mapCaches = nil
end

function ZoneCache:DoesHandleMap(map)
	return self.mapCaches[map]
end
