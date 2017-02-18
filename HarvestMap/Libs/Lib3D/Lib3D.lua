-- lib3D by Shinni
-- this library keeps 3D controls at their world location
-- even if the world's origin moves (happens after teleporting or when moving 1km away from the last origin)

local LIB_NAME = "Lib3D"
local lib = LibStub:NewLibrary(LIB_NAME, 9)
if not lib then return end

local GPS = LibStub("LibGPS2")
local LMP = LibStub("LibMapPing")

local d = function() end
if false then -- set to true for debug output
	d = _G["d"]
	function GlobalPos()
		local x, y = GetMapPlayerPosition("player")
		x, y = GPS:LocalToGlobal(x, y)
		d(x,y)
	end
end

local MAXIMUM_CAMERA_DISTANCE = 10 * 10
local VALID_ORIGIN_RANGE = 1000 * 1000
local CRITICAL_LEVELS = {
	{	-- normal state, call OnUpdate ocasionally
		range = -1,
		frameTime = 1500, -- 1.5 seconds
	},
	{	-- critical state, call OnUpdate more often, but not every frame
		range = 800 * 800,
		frameTime = 100, -- 0.1 seconds
	},
	{	-- emergency state, call OnUpdate every single frame
		range = 950 * 950,
		frameTime = 0, -- every frame
	},
}
local NUM_CRITICAL_LEVELS = #CRITICAL_LEVELS

-- control which is used to take 3d world coordinate measurements
local measurementControl = CreateControl(LIB_NAME .. "MeasurementControl", GuiRoot, CT_CONTROL)
measurementControl:Create3DRenderSpace()
-- the current critical level
local currentLevel = 1
-- registered callbacks and controls
local worldChangeCallbacks = {}
local registeredControls = {}

local currentOriginGlobalX
local currentOriginGlobalY

local initialized = false
lib.computedFactors = {}

-- when the UI is reloaded, the origin is not reset, so we need to save the origin coordinates
ZO_PreHook("ReloadUI", function()
	ZO_Ingame_SavedVariables["Lib3D"] = {currentOriginGlobalX, currentOriginGlobalY, currentLevel}
end)

-- the passed zoneId should be the player's current zoneId
local function ComputeGlobalToWorldFactor(zoneId)
	if not SetPlayerWaypointByWorldLocation then return end -- pre-housing API
	if lib.computedFactors[zoneId] then
		return lib.computedFactors[zoneId]
	end
	local result = nil
	local setMapResult = SetMapToMapListIndex(TAMRIEL_MAP_INDEX)
	
	-- save current map ping, so we can restore it later
	local hasMapPing = LMP:HasMapPing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
	local originalX, originalY = LMP:GetMapPing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
	
	-- set two waypoints that are 25 km in X and Y direction apart from each other
	LMP:SuppressPing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
	local success = SetPlayerWaypointByWorldLocation(-125000, 0, -125000)
	if success then
		local firstX, firstY = LMP:GetMapPing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
		success = SetPlayerWaypointByWorldLocation(125000, 0, 125000)
		if success then
			local secondX, secondY = LMP:GetMapPing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
			result = 2 * 2500 / (secondX - firstX + secondY - firstY)
			if firstX == secondX or firstY == secondY then result = nil end
		end
	end
	LMP:UnsuppressPing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
	
	-- restore waypoint
	LMP:MutePing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
	if hasMapPing then
		PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, originalX, originalY)
	else
		RemovePlayerWaypoint()
	end
	LMP:UnmutePing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
	
	if setMapResult == SET_MAP_RESULT_MAP_CHANGED then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
	end
	
	lib.computedFactors[zoneId] = result
	return result
end

local function UpdateOriginOfControls(dx, dy)
	d("move control by", dx, dy)
	local worldX, worldY, worldZ
	for control, _ in pairs(registeredControls) do
		d(control)
		worldX, worldY, worldZ = control:Get3DRenderSpaceOrigin()
		control:Set3DRenderSpaceOrigin(worldX + dx, worldY, worldZ + dy)
	end
end

local function OnUpdate()
	local x, y = GetMapPlayerPosition("player")
	x, y = GPS:LocalToGlobal(x, y)
	if not x then return end -- universe map is open :(
	
	local dx = (currentOriginGlobalX - x) * currentGlobalToWorldFactor
	local dy = (currentOriginGlobalY - y) * currentGlobalToWorldFactor
	local dist2 = dx * dx + dy * dy
	-- the barrier was crossed and the game has set a new origin to the player's current location
	if dist2 > VALID_ORIGIN_RANGE  then
		UpdateOriginOfControls(dx, dy)
		d("new origin", x, y)
		currentOriginGlobalX = x
		currentOriginGlobalY = y
		
		currentLevel = 1
		EVENT_MANAGER:UnregisterForUpdate(LIB_NAME)
		EVENT_MANAGER:RegisterForUpdate(LIB_NAME, CRITICAL_LEVELS[currentLevel].frameTime, OnUpdate)
		return
	end
	
	-- update the critical levels
	
	local range 
	if currentLevel > 1 then
		range = CRITICAL_LEVELS[currentLevel].range
		if dist2 < range then
			currentLevel = currentLevel - 1
			d("level lower", currentLevel)
			EVENT_MANAGER:UnregisterForUpdate(LIB_NAME)
			EVENT_MANAGER:RegisterForUpdate(LIB_NAME, CRITICAL_LEVELS[currentLevel].frameTime, OnUpdate)
		end
	end
	
	if currentLevel < NUM_CRITICAL_LEVELS then
		range = CRITICAL_LEVELS[currentLevel+1].range
		if dist2 > range then
			currentLevel  = currentLevel + 1
			d("level up", currentLevel)
			EVENT_MANAGER:UnregisterForUpdate(LIB_NAME)
			EVENT_MANAGER:RegisterForUpdate(LIB_NAME, CRITICAL_LEVELS[currentLevel].frameTime, OnUpdate)
		end
	end
end

local function OnPlayerActivated()
	-- check if the player entered a new world
	local zoneIndex = GetUnitZoneIndex("player")
	local newWorld = currentZoneIndex ~= zoneIndex
	-- check if the player is close to the origin
	-- if the player is close to the origin, then he might have ported via wayshrine in the same zone
	local worldX, worldY, worldZ = lib:GetPlayerCurrentWorldCoordsApproximation()--GetCameraCurrentWorldCoords()
	d("world camera coords", worldX, worldY, worldZ)
	local closeOrigin = (worldX * worldX + worldZ * worldZ < 1)--MAXIMUM_CAMERA_DISTANCE + 1)
	d("new World", newWorld, "close Origin", closeOrigin)
	if newWorld or closeOrigin then
		local x, y = GetMapPlayerPosition("player")
		
		x, y = GPS:LocalToGlobal(x, y)
		d("new origin global coords", x, y)
		-- the origin has moved because of the teleport, move the controls
		if not newWorld then
			UpdateOriginOfControls(
				(currentOriginGlobalX-x) * currentGlobalToWorldFactor,
				(currentOriginGlobalY-y) * currentGlobalToWorldFactor)
		end
		currentOriginGlobalX = x
		currentOriginGlobalY = y
		
		currentLevel = 1
		EVENT_MANAGER:UnregisterForUpdate(LIB_NAME)
		EVENT_MANAGER:RegisterForUpdate(LIB_NAME, CRITICAL_LEVELS[currentLevel].frameTime, OnUpdate)
	end
	-- the player actually moved and the loading screen wasn't the result of lag etc
	if newWorld then
		currentZoneIndex = zoneIndex
		currentZoneId = GetZoneId(zoneIndex)
		
		currentGlobalToWorldFactor = ComputeGlobalToWorldFactor(currentZoneId)
		if not currentGlobalToWorldFactor then -- fallback
			d("used fallback global to world factor")
			currentGlobalToWorldFactor = lib.SPECIAL_GLOBAL_TO_WORLD_FACTORS[currentZoneId] or lib.DEFAULT_GLOBAL_TO_WORLD_FACTOR
		end
		d("global to world factor is", currentGlobalToWorldFactor)
		
		currentWorldToGlobalFactor = 1 / currentGlobalToWorldFactor -- this value is need in the
		-- on update loop and multiplication is faster than division in lua
		
		if not lib:IsInitialized() and not closeOrigin then
			-- the player used reloadui and the origin data is lost :(
			local data = ZO_Ingame_SavedVariables["Lib3D"]
			if data then
				d("loaded previous origin")
				currentOriginGlobalX = data[1]
				currentOriginGlobalY = data[2]
				d(currentOriginGlobalX, currentOriginGlobalY)
				currentLevel = data[3]
				EVENT_MANAGER:UnregisterForUpdate(LIB_NAME)
				EVENT_MANAGER:RegisterForUpdate(LIB_NAME, CRITICAL_LEVELS[currentLevel].frameTime, OnUpdate)
			else
				d("try reconstructing origin")
				-- well this is bad...
				-- let's hope the player isn't mounted, so we get proper coordinates...
				--worldX, worldY, worldZ = lib:GetPlayerCurrentWorldCoordsApproximation()
				--d(worldX, worldY, worldZ)
				-- the origin variables contain the player position, translate the origin by the calculated distance to the real origin
				currentOriginGlobalX = currentOriginGlobalX - worldX * currentWorldToGlobalFactor
				currentOriginGlobalY = currentOriginGlobalY - worldZ * currentWorldToGlobalFactor
				-- restore the correct critical level
				local dist2 = worldX * worldX + worldZ * worldZ
				for level = 1, NUM_CRITICAL_LEVELS do
					if dist2 > CRITICAL_LEVELS[level].range then
						currentLevel = level
					end
				end
				EVENT_MANAGER:UnregisterForUpdate(LIB_NAME)
				EVENT_MANAGER:RegisterForUpdate(LIB_NAME, CRITICAL_LEVELS[currentLevel].frameTime, OnUpdate)
			end
		end
		
		ZO_Ingame_SavedVariables["Lib3D"] = nil
		
		initialized = true
		registeredControls = {}
		for identifier, callback in pairs(worldChangeCallbacks) do
			callback(identifier, zoneIndex, currentZoneId)
		end
	end
end
EVENT_MANAGER:RegisterForEvent(LIB_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
EVENT_MANAGER:RegisterForEvent(LIB_NAME, EVENT_PLAYER_ALIVE, OnPlayerActivated)

---
-- This function expects an identifier in addition to the callback. The identifier can be
-- used to unregister the callback.
-- The registered callback will be fired when the player enters a new 3d world. (i.e. a delve is entered)
-- The callbacks arguments are the identifier and the current 3d world's zoneIndex and zoneId
function lib:RegisterWorldChangeCallback(identifier, callback)
	worldChangeCallbacks[identifier] = callback
end

---
-- Unregisters the callback which belongs to the given identifier
function lib:UnregisterWorldChangeCallback(identifier)
	worldChangeCallbacks[identifier] = nil
end

---
-- Registers the control.
-- Registered controls will stay at their location even if the world's origin moves.
-- The control will be unregistered when a new 3d world is entered.
-- Register a a WorldChangeCallback to get notified when this is the case.
function lib:RegisterControl(control)
	registeredControls[control] = true
end

---
-- Unregisters the control.
-- This addon will no longer translate the pin when the world origin moves.
function lib:UnregisterControl(control)
	registeredControls[control] = nil
end

---
-- Returns the global coordsystem to world system factor for the current zone.
-- Returns nil if the factor isn't known.
-- The 2nd return value tells you, if the value was computed or if it is a hardcoded fallback value
-- This factor can be used to convert distances between global coords to distances in meters.
function lib:GetGlobalToWorldFactor(zoneId)
	local result = lib.computedFactors[zoneId]
	if result then
		return result, true
	end
	return lib.SPECIAL_GLOBAL_TO_WORLD_FACTORS[zoneId], false
end

---------------------------------------------------------------------
-- coordinate conversion functions
-- first map to world coords
-- then world coords to map coords further below
---------------------------------------------------------------------

---
-- Expects a point given in global map coordinates and returns
-- the point's world x and z coords in relation to the current world origin.
function lib:GetCurrentWorldCoordsFromGlobal(x, y)
	x = x - currentOriginGlobalX
	y = y - currentOriginGlobalY
	x = x * currentGlobalToWorldFactor
	y = y * currentGlobalToWorldFactor
	return x, y
end

---
-- Expects a point given in local map coordinates and returns
-- the point's world x and z coords in relation to the current world origin.
function lib:GetCurrentWorldCoordsFromLocal(x, y)
	x, y = GPS:LocalToGlobal(x, y)
	return self:GetCurrentWorldCoordsFromGlobal(x, y)
end

---
-- Expects a point given in global map coordinates and returns
-- the point's world x and z coords in relation to an origin at the north eastern corner of the tamriel map
function lib:GetPersistentWorldCoordsFromGlobal(x, y)
	x = x * currentGlobalToWorldFactor
	y = y * currentGlobalToWorldFactor
	return x, y
end

---
-- Expects a point given in local map coordinates and returns
-- the point's world x and z coords in relation to an origin at the north eastern corner of the tamriel map
function lib:GetPersistentWorldCoordsFromLocal(x, y)
	x, y = GPS:LocalToGlobal(x, y)
	return self:GetPersistentWorldCoordsFromGlobal(x, y)
end


---
-- Expects a point given in world x and z coords in relation to the current world origin
-- and returns the point in global map coordinates
function lib:GetGlobalFromCurrentWorldCoords(x, z)
	x = x * currentWorldToGlobalFactor
	z = z * currentWorldToGlobalFactor
	x = x + currentOriginGlobalX
	z = z + currentOriginGlobalY
	return x, y
end

---
-- Expects a point given in world x and z coords in relation to the current world origin
-- and returns the point in local map coordinates
function lib:GetLocalFromCurrentWorldCoords(x, z)
	x, z = self:GetGlobalFromCurrentWorldCoords(x, z)
	x, z = GPS:GlobalToLocal(x, z)
	return x, z
end

---
-- Expects a point given in world x and z coords in relation to an origin in the north eastern corner of the tamriel map
-- and returns the point in global map coordinates
function lib:GetGlobalFromPersistentWorldCoords(x, z)
	x = x * currentWorldToGlobalFactor
	z = z * currentWorldToGlobalFactor
	return x, z
end

---
-- Expects a point given in world x and z coords in relation to an origin in the north eastern corner of the tamriel map
-- and returns the point in local map coordinates
function lib:GetPersistentWorldCoordsFromLocal(x, z)
	x, z = self:GetGlobalFromPersistentWorldCoords(x, z)
	x, z = GPS:LocalToGlobal(x, z)
	return x, z
end

---
-- Returns the position of the persistant world origin in relation to the current world origin
function lib:GetPersistentWorldOrigin()
	local x = -currentOriginGlobalX * currentGlobalToWorldFactor
	local z = -currentOriginGlobalY * currentGlobalToWorldFactor
	return x, z
end

---
-- Returns the camera position in world coordinates in relation to the current world origin.
function lib:GetCameraCurrentWorldCoords()
	Set3DRenderSpaceToCurrentCamera(measurementControl:GetName())
	return measurementControl:Get3DRenderSpaceOrigin()
end

function lib:GetCameraCurrentWorldRenderSpace()
	Set3DRenderSpaceToCurrentCamera(measurementControl:GetName())
	local x, y, z = measurementControl:Get3DRenderSpaceOrigin()
	local forwardX, forwardY, forwardZ = measurementControl:Get3DRenderSpaceForward()
	local rightX, rightY, rightZ = measurementControl:Get3DRenderSpaceRight()
	local upX, upY, upZ = measurementControl:Get3DRenderSpaceUp()
	return x, y, z, forwardX, forwardY, forwardZ, rightX, rightY, rightZ, upX, upY, upZ
end

---
-- Returns an approximation of the player's current world coordinates in relation to the current world origin
-- The returned values are the position of the first person camera.
-- If the toggle between first and third person camera doesn't work (i.e the player is mounted), then the third person camera's cooridnates are returned.
-- Note that calling this function will toggle the camera twice, which can result in screen flickering when called outside of a key <Down> or <Up> callback.
-- Use with care!
function lib:GetPlayerCurrentWorldCoordsApproximation()
	if IsMounted() then return self:GetCameraCurrentWorldCoords() end
	
	Set3DRenderSpaceToCurrentCamera(measurementControl:GetName())
	local preToggleX, preToggleY, preToggleZ = measurementControl:Get3DRenderSpaceOrigin()
	ToggleGameCameraFirstPerson()
	Set3DRenderSpaceToCurrentCamera(measurementControl:GetName())
	local toggledX, toggledY, toggledZ = measurementControl:Get3DRenderSpaceOrigin()
	ToggleGameCameraFirstPerson()
	Set3DRenderSpaceToCurrentCamera(measurementControl:GetName())
	local reToggleX, reToggleY, reToggleZ = measurementControl:Get3DRenderSpaceOrigin()
	-- unfortunately there is no api function to get the current camera state (first person or third person)
	-- but for some reason the distance between the camera position before the first toggle and after the 2nd toggle
	-- is only zero, if the camera toggled from first person to third person to first person
	if preToggleX == reToggleX and preToggleY == reToggleY and preToggleZ == reToggleZ then
		-- the camera toggled from first person to third person to first person
		return preToggleX, preToggleY, preToggleZ -- first person coords
	end
	-- the camera toggled from third person to first person to third person
	return toggledX, toggledY, toggledZ -- first person coords
end

---
-- Returns true when the addon is initialized. Calling library function earlier can result in errors.
-- Initialization is performed during the player activated event.
function lib:IsInitialized()
	return initialized
end
