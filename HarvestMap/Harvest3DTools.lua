
--[[
function Harvest.Get3DPosition()
	local control = Harvest.measurementControl
	Set3DRenderSpaceToCurrentCamera(control:GetName())
	local preToggleX, preToggleY, preToggleZ = control:Get3DRenderSpaceOrigin()
	ToggleGameCameraFirstPerson()
	Set3DRenderSpaceToCurrentCamera(control:GetName())
	local toggledX, toggledY, toggledZ = control:Get3DRenderSpaceOrigin()
	ToggleGameCameraFirstPerson()
	Set3DRenderSpaceToCurrentCamera(control:GetName())
	local reToggleX, reToggleY, reToggleZ = control:Get3DRenderSpaceOrigin()
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
--]]

local Lib3D = LibStub("Lib3D")

function Harvest.Get3DPosition()
	return Lib3D:GetPlayerCurrentWorldCoordsApproximation()
end

-- the rest is internal stuff for testing and not used by the addon

function Harvest.GetCameraHeight()
	local control = Harvest.measurementControl
	Set3DRenderSpaceToCurrentCamera(control:GetName())
	local _, y = control:Get3DRenderSpaceOrigin()
	return y
end

local mapSizes = {
	["craglorn/craglorn_base"] = 3500,
	["auridon/auridon_base"] = 3950,
	--eastmarch 4000
}

function Harvest.GetMapWorldSize(map)
	return mapSizes[map]
end

--[[
This function receives two lines given in the format: point + t * direction
p1x, p1y, p1z, d1x, d1y, d1z is the first line and 
p2x, p2y, p2z, d2x, d2y, d2z is the second line.
dirDot is the dot product of the two given lines and can be ommited
This function will calculate the point which minimizes the sum of the distances to the two lines.
use case:
When the two lines are two camera view directions, then the returned point is approximately the player's position.

unused for now, as there are problems with edge cases like the camera's movement right after the character dismounts
--]]
function Harvest.GetCenterPoint(lineA, lineB, minT, maxT)
	local p1x = lineA.px
	local p1y = lineA.py
	local p1z = lineA.pz
	local d1x = lineA.dx
	local d1y = lineA.dy
	local d1z = lineA.dz
	
	local p2x = lineB.px
	local p2y = lineB.py
	local p2z = lineB.pz
	local d2x = lineB.dx
	local d2y = lineB.dy
	local d2z = lineB.dz
	
	local dirDot = d1x * d2x + d1y * d2y + d1z * d2z
	-- calculate the vector P2P1 = P1 - P2
	local p1p2x = p1x - p2x
	local p1p2y = p1y - p2y
	local p1p2z = p1z - p2z
	
	-- calculate the dot products: < D1, P2P1 > and < D2, P2P1 >
	local d1Dot = d1x * p1p2x + d1y * p1p2y + d1z * p1p2z
	local d2Dot = d2x * p1p2x + d2y * p1p2y + d2z * p1p2z
	
	-- the factor t1 for which P1 + t1 * D1 is the closest point to the second line
	local t1 = (dirDot * d2Dot - d1Dot) / (1 - dirDot * dirDot)
	-- the factor t2 for which P2 + t2 * D2 is the closest point to the first line
	local t2 = (dirDot * d1Dot - d2Dot) / (1 - dirDot * dirDot)
	-- averaging these two closest points results in the center point
	local x = 0.5 * ((p1x + t1 * d1x) + (p2x - t2 * d2x))
	local y = 0.5 * ((p1y + t1 * d1y) + (p2y - t2 * d2y))
	local z = 0.5 * ((p1z + t1 * d1z) + (p2z - t2 * d2z))
	
	local dx = x - (p2x - t2 * d2x)
	local dy = y - (p2y - t2 * d2y)
	local dz = z - (p2z - t2 * d2z)
	d("distance " .. math.sqrt(dx*dx+dy*dy+dz*dz))
	d("t values " .. t1 .. " " .. t2)
	
	return (t1 > minT and t1 < maxT), x, y, z
end

function Harvest.PerformMeasurement()
	local map, x, y, measurement = Harvest.GetLocation()
	Harvest.savedVars["global"][map] = Harvest.savedVars["global"][map] or {}
	local n = #Harvest.savedVars["global"][map] + 1
	Harvest.savedVars["global"][map][n] = {x,y,Harvest.Get3DPosition()}
	if n == 2 then
		measure = Harvest.savedVars["global"][map][1]
		measure2 = {x,y,Harvest.Get3DPosition()}
		width = (measure[3] - measure2[3]) / (measure[1] - measure2[1])
		height = (measure[5] - measure2[5]) / (measure[2] - measure2[2])
		d(width, height)
		Harvest.savedVars["global"][map].width = width
		Harvest.savedVars["global"][map].height = height
		Harvest.savedVars["global"][map].factor = (width + height) / (measurement.scaleX + measurement.scaleY)
		Harvest.savedVars["global"][map].zone = GetZoneId(GetUnitZoneIndex("player"))
	end
end

function Harvest.ClearMeasurement()
	local map, x, y = Harvest.GetLocation()
	Harvest.savedVars["global"][map] = {}
end