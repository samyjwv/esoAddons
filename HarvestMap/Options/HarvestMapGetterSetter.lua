local LMP = LibStub("LibMapPins-1.0")

if not Harvest then
	Harvest = {}
end

local CallbackManager = Harvest.callbackManager
local Events = Harvest.events

function Harvest.AreDeletionsTracked()
	return Harvest.savedVars["settings"].trackDeletions
end

function Harvest.SetDeletionTracking(isTracked)
	Harvest.savedVars["settings"].trackDeletions = isTracked
end

function Harvest.GetMinGameVersion()
	return Harvest.savedVars["global"].minGameVersion
end

local versionString
function Harvest.GetDisplayedMinGameVersion()
	if versionString then
		return versionString
	end
	local versionNumber = Harvest.savedVars["global"].minGameVersion
	local patch = tostring(versionNumber % 100)
	local update = tostring(zo_floor(versionNumber / 100) % 100)
	local version = tostring(zo_max(zo_floor(versionNumber / 10000),1))
	return table.concat({version, update, patch},".")
end

function Harvest.SetDisplayedMinGameVersion(version)
	versionString = version
end

function Harvest.GetUIResolution()
	local width, height = GuiRoot:GetDimensions()
	d(width, height)
	if GetSetting(SETTING_TYPE_UI, UI_SETTING_USE_CUSTOM_SCALE) ~= "0" then
		local scale = tonumber(GetSetting(SETTING_TYPE_UI, UI_SETTING_CUSTOM_SCALE))
		d(scale)
		width = width * scale
		height = height * scale
	end
	width = zo_round(width)
	height = zo_round(height)
	d(width, height)
	return width, height
end

function Harvest.Get3DResolution()
	return GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_RESOLUTION)
end

function Harvest.GetSubSampling()
	local level = tostring(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_SUB_SAMPLING, SUB_SAMPLING_MODE_NORMAL))
	return GetString(_G["SI_SUBSAMPLINGMODE" .. level])
end

function Harvest.SetToCompatibleGraphicSettings()
	local width, height = Harvest.GetUIResolution()
	SetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_RESOLUTION, tostring(width) .. "x" .. tostring(height))
	SetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_SUB_SAMPLING, SUB_SAMPLING_MODE_NORMAL)
end

function Harvest.GetWorldPinHeight()
	return Harvest.savedVars["settings"].worldPinHeight
end

function Harvest.SetWorldPinHeight(height)
	Harvest.savedVars["settings"].worldPinHeight = height
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "worldPinHeight", height)
end

function Harvest.DoWorldPinsUseDepth()
	return Harvest.savedVars["settings"].worldPinDepth
end

function Harvest.SetWorldPinsUseDepth(value)
	Harvest.savedVars["settings"].worldPinDepth = value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "worldPinsUseDepth", value)
end

function Harvest.GetDisplayedCompassDistance()
	local distance = Harvest.savedVars["settings"].compassDistance
	return zo_round(distance  / math.sqrt(Harvest.GetGlobalMinDistanceBetweenPins())) * 10
end

function Harvest.GetCompassDistance()
	return Harvest.savedVars["settings"].compassDistance
end

function Harvest.SetDisplayedCompassDistance( distance )
	Harvest.savedVars["settings"].compassDistance = distance * math.sqrt(Harvest.GetGlobalMinDistanceBetweenPins()) / 10
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "compassDistance", Harvest.savedVars["settings"].compassDistance)
end

function Harvest.GetWorldDistance()
	return Harvest.savedVars["settings"].worldDistance
end

function Harvest.SetDisplayedWorldDistance(distance)
	Harvest.savedVars["settings"].worldDistance = distance * math.sqrt(Harvest.GetGlobalMinDistanceBetweenPins()) / 10
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "worldDistance", Harvest.savedVars["settings"].worldDistance)
end

function Harvest.GetDisplayedWorldDistance()
	local distance = Harvest.savedVars["settings"].worldDistance
	return zo_round(distance  / math.sqrt(Harvest.GetGlobalMinDistanceBetweenPins())) * 10
end

function Harvest.GetWorldDistance()
	return Harvest.savedVars["settings"].worldDistance
end

function Harvest.SetWorldPinsVisible(visible)
	Harvest.savedVars["settings"].worldPinsVisible = visible
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "worldPinsVisible", visible)
end

function Harvest.AreWorldPinsVisible()
	return Harvest.savedVars["settings"].worldPinsVisible
end

function Harvest.SetWorldPinsSimple(simple)
	Harvest.savedVars["settings"].simpleWorldPins = simple
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "worldPinsSimple", simple)
end

function Harvest.AreWorldPinsSimple()
	return false
	-- not implemented yet
	--return Harvest.savedVars["settings"].simpleWorldPins
end

function Harvest.GetVisitedRangeMultiplier()
	return Harvest.savedVars["settings"].rangeMuliplier
end

function Harvest.GetDisplayedVisitedRangeMultiplier()
	return math.sqrt(Harvest.savedVars["settings"].rangeMuliplier) * 10
end

function Harvest.SetDisplayedVisitedRangeMultiplier(value)
	Harvest.savedVars["settings"].rangeMuliplier = value * value * 0.01
end

function Harvest.ShouldRefreshPinsOnHarvest()
	--return Harvest.savedVars["settings"].refreshOnHarvest
	return false
end

function Harvest.SetRefreshPinsOnHarvest(value)
	Harvest.savedVars["settings"].refreshOnHarvest = value
end

function Harvest.IsDelayedWhenMapClosed()
	if FyrMM then return false end
	return Harvest.savedVars["settings"].delayUntilMapOpen
end

function Harvest.SetDelayedWhenMapClosed(delayed)
	Harvest.savedVars["settings"].delayUntilMapOpen = delayed
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "delayMapClosed", delayed)
end

function Harvest.IsDelayedWhenInFight()
	if FyrMM then return false end
	return Harvest.savedVars["settings"].delayWhenInFight
end

function Harvest.SetDelayedWhenInFight(delayed)
	Harvest.savedVars["settings"].delayWhenInFight = delayed
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "delayInFight", delayed)
end

function Harvest.GetDisplaySpeed()
	if FyrMM then return math.huge end
	return Harvest.savedVars["settings"].displaySpeed
end

function Harvest.SetDisplaySpeed( speed )
	Harvest.savedVars["settings"].displaySpeed = speed
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "displaySpeed", speed)
end

function Harvest.HasPinVisibleDistance()
	return Harvest.savedVars["settings"].hasMaxVisibleDistance
end

function Harvest.SetHasPinVisibleDistance( enabled )
	Harvest.savedVars["settings"].hasMaxVisibleDistance = enabled
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "hasVisibleDistance", enabled)
end

function Harvest.GetDisplayPinVisibleDistance()
	local distance = Harvest.savedVars["settings"].maxVisibleDistance
	return zo_round(distance  / math.sqrt(Harvest.GetGlobalMinDistanceBetweenPins())) * 10
end

function Harvest.GetPinVisibleDistance()
	return Harvest.savedVars["settings"].maxVisibleDistance
end

function Harvest.SetPinVisibleDistance(distance)
	Harvest.savedVars["settings"].maxVisibleDistance = distance * math.sqrt(Harvest.GetGlobalMinDistanceBetweenPins()) / 10
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "visibleDistance", Harvest.savedVars["settings"].maxVisibleDistance)
end

function Harvest.GetMaxCachedMaps()
	return 5--Harvest.savedVars["settings"].maxCachedMaps
end

function Harvest.SetMaxCachedMaps( num )
	Harvest.savedVars["settings"].maxCachedMaps = num
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "maxCachedMaps", num)
end

function Harvest.IsArrowHidden()
	return Harvest.savedVars["settings"].hideArrow
end

function Harvest.SetArrowHidden( hidden )
	Harvest.savedVars["settings"].hideArrow = hidden
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "arrowHidden", hidden)
	if hidden then -- TODO via callback
		HarvestFarmCompassArrow:SetHidden(true)
	end
end

function Harvest.ArePinsAbovePOI()
	return (Harvest.savedVars["settings"].mapLayouts[1].level > 50)
end

function Harvest.SetPinsAbovePOI( above )
	local level = 20
	if above then
		level = 55
	end
	for pinTypeId, layout in pairs(Harvest.savedVars["settings"].mapLayouts) do
		if pinTypeId == Harvest.TOUR then
			layout.level = level + 1
		else
			layout.level = level
		end
	end
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "pinAbovePoi", above)
end

function Harvest.AreExactItemsShown()
	return true--Harvest.savedVars["settings"].showExactItems
end

function Harvest.SetShowExactItems( value )
	Harvest.savedVars["settings"].showExactItems = value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "showExactItems", value)
end

function Harvest.IsHiddenOnHarvest()
	return Harvest.savedVars["settings"].hiddenOnHarvest
end

function Harvest.SetHiddenOnHarvest( hidden )
	Harvest.savedVars["settings"].hiddenOnHarvest = hidden
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "hiddenOnHarvest", hidden)
end

function Harvest.GetHiddenTime()
	if FyrMM then return 0 end
	return Harvest.savedVars["settings"].hiddenTime
end

function Harvest.SetHiddenTime(hiddenTime)
	Harvest.savedVars["settings"].hiddenTime = hiddenTime
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "hiddenTime", hiddenTime)
	if hiddenTime == 0 then -- todo callback
		Harvest.RefreshPins()
	end
end

function Harvest.SetHeatmapActive( active )
	local prevValue = Harvest.savedVars["settings"].heatmap
	Harvest.savedVars["settings"].heatmap = active
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "heatmapActive", active)
	-- todo via callback
	HarvestHeat.RefreshHeatmap()
	if active then
		HarvestHeat.Initialize()
	else
		HarvestHeat.HideTiles()
	end
end

function Harvest.IsHeatmapActive()
	return (Harvest.savedVars["settings"].heatmap == true)
end

function Harvest.AreSettingsAccountWide()
	return Harvest.savedVars["global"].accountWideSettings
end

function Harvest.SetSettingsAccountWide( value )
	Harvest.savedVars["global"].accountWideSettings = value
	-- wanted to remove this, but it seems the require reload field in LAM doesn't work
	ReloadUI("ingame")
end

local difference -- temporary variable to save the new max timedifference until the apply button is hit
function Harvest.ApplyTimeDifference()
	if difference then
		Harvest.savedVars["global"].maxTimeDifference = difference
	end
	if versionString then
		local versionNumber = 0
		if versionString ~= "1.0.0" then
			local version, update, patch = string.match(versionString, "(%d+)%.(%d+)%.(%d+)")
			versionNumber = version * 10000 + update * 100 + patch
		end
		Harvest.savedVars["global"].minGameVersion = versionNumber
	end
	if difference or versionString then
		CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "applyTimeDifference", difference, versionString)
		difference = nil
		versionString = nil
	end
end

function Harvest.GetMaxTimeDifference()
	return Harvest.savedVars["global"].maxTimeDifference
end

function Harvest.GetDisplayedMaxTimeDifference()
	return difference or Harvest.savedVars["global"].maxTimeDifference
end

function Harvest.SetDisplayedMaxTimeDifference(value)
	difference = value
end

function Harvest.IsPinTypeSavedOnImport( pinTypeId )
	return not (Harvest.savedVars["settings"].isPinTypeSavedOnImport[ pinTypeId ] == false)
end

function Harvest.SetPinTypeSavedOnImport( pinTypeId, value )
	Harvest.savedVars["settings"].isPinTypeSavedOnImport[ pinTypeId ] = value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "importPinType", pinTypeId, value)
end

function Harvest.IsZoneSavedOnImport( zone )
	if Harvest.savedVars["settings"].isZoneSavedOnImport[ zone ] == nil then
		return true
	end
	return Harvest.savedVars["settings"].isZoneSavedOnImport[ zone ]
end

function Harvest.SetZoneSavedOnImport( zone, value )
	Harvest.savedVars["settings"].isZoneSavedOnImport[ zone ] = value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "importZone", value)
end

function Harvest.AreCompassPinsVisible()
	return Harvest.savedVars["settings"].isCompassVisible
end

function Harvest.SetCompassPinsVisible( value )
	Harvest.savedVars["settings"].isCompassVisible = value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "compassPinsVisible", value)
end

function Harvest.GetCompassLayouts()
	return Harvest.savedVars["settings"].compassLayouts
end

function Harvest.GetCompassPinLayout( pinTypeId )
	--pinTypeId = Harvest.GetPinTypeInGroup(pinTypeId) or pinTypeId
	return Harvest.savedVars["settings"].compassLayouts[ pinTypeId ]
end

function Harvest.GetMapLayouts()
	return Harvest.savedVars["settings"].mapLayouts
end

function Harvest.GetMapPinLayout( pinTypeId )
	--pinTypeId = Harvest.GetPinTypeInGroup(pinTypeId) or pinTypeId
	return Harvest.savedVars["settings"].mapLayouts[ pinTypeId ]
end

function Harvest.IsWorldFilterActive()
	return Harvest.savedVars.settings.isWorldFilterActive
end

function Harvest.SetWorldFilterActive(value)
	Harvest.savedVars.settings.isWorldFilterActive = value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "worldFilterActive", value)
end

function Harvest.IsWorldPinTypeVisible( pinTypeId )
	return Harvest.savedVars.settings.isWorldPinTypeVisible[ pinTypeId ]
end

function Harvest.SetWorldPinTypeVisible( pinTypeId, visible )
	Harvest.savedVars["settings"].isWorldPinTypeVisible[ pinTypeId ] = visible
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "worldPinTypeVisible", pinTypeId, visible)
end

function Harvest.IsCompassFilterActive()
	return Harvest.savedVars.settings.isCompassFilterActive
end

function Harvest.SetCompassFilterActive(value)
	Harvest.savedVars.settings.isCompassFilterActive = value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "compassFilterActive", value)
end

function Harvest.IsCompassPinTypeVisible( pinTypeId )
	return Harvest.savedVars.settings.isCompassPinTypeVisible[ pinTypeId ]
end

function Harvest.SetCompassPinTypeVisible( pinTypeId, visible )
	Harvest.savedVars["settings"].isCompassPinTypeVisible[ pinTypeId ] = visible
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "compassPinTypeVisible", pinTypeId, visible)
end

function Harvest.IsMapPinTypeVisible( pinTypeId )
	return Harvest.savedVars.settings.isPinTypeVisible[ pinTypeId ]
end

function Harvest.IsInRangePinTypeVisible( pinTypeId )
	local checkMap = not Harvest.IsCompassFilterActive() or not Harvest.IsWorldFilterActive()
	if Harvest.IsCompassFilterActive() and Harvest.IsCompassPinTypeVisible( pinTypeId ) then
		return true
	end
	if Harvest.IsWorldFilterActive() and Harvest.IsWorldPinTypeVisible( pinTypeId ) then
		return true
	end
	return checkMap and Harvest.IsMapPinTypeVisible( pinTypeId )
end

function Harvest.IsPinTypeVisible( pinTypeId )
	if Harvest.IsMapPinTypeVisible( pinTypeId ) then
		return true
	end
	if Harvest.IsCompassFilterActive() and Harvest.IsCompassPinTypeVisible( pinTypeId ) then
		return true
	end
	return Harvest.IsWorldFilterActive() and Harvest.IsWorldPinTypeVisible( pinTypeId )
end

function Harvest.SetMapPinTypeVisible( pinTypeId, visible )
	Harvest.savedVars["settings"].isPinTypeVisible[ pinTypeId ] = visible
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "mapPinTypeVisible", pinTypeId, visible)
	-- todo via callback
	HarvestHeat.RefreshHeatmap()
end

local debugEnabled = false
function Harvest.IsDebugEnabled()
	return debugEnabled
end

function Harvest.SetDebugEnabled( value )
	debugEnabled = value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "debugModeEnabled", value)
end

function Harvest.AreVerboseMessagesEnabled()
	return Harvest.savedVars["settings"].verbose
end

function Harvest.SetVerboseMessagesEnabled( value )
	Harvest.savedVars["settings"].verbose = value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "verboseMsgEnabled", value)
end

function Harvest.AreDebugMessagesEnabled()
	return Harvest.savedVars["settings"].debug
end

function Harvest.SetDebugMessagesEnabled( value )
	Harvest.savedVars["settings"].debug = value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "debugMsgEnabled", value)
end

function Harvest.IsPinTypeSavedOnGather( pinTypeId )
	--return true
	return not (Harvest.savedVars["settings"].isPinTypeSavedOnGather[ pinTypeId ] == false)
	-- nil is interpreted as true too
end

function Harvest.SetPinTypeSavedOnGather( pinTypeId, value )
	Harvest.savedVars["settings"].isPinTypeSavedOnGather[ pinTypeId ] = value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "savePinType", pinTypeId, value)
end

function Harvest.GetMapPinSize( pinTypeId )
	if pinTypeId == 0 then
		return Harvest.savedVars["settings"].minimapPinSize
	end
	return Harvest.savedVars["settings"].mapLayouts[ pinTypeId ].size
end

function Harvest.SetMapPinSize( pinTypeId, value )
	if pinTypeId == 0 then
		Harvest.savedVars["settings"].minimapPinSize = value
	else
		Harvest.savedVars["settings"].mapLayouts[ pinTypeId ].size = value
	end
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "pinTypeSize", pinTypeId, value)
end

function Harvest.GetPinColor( pinTypeId )
	return Harvest.savedVars["settings"].mapLayouts[ pinTypeId ].tint:UnpackRGB()
end

function Harvest.SetPinColor( pinTypeId, r, g, b )
	Harvest.savedVars["settings"].mapLayouts[ pinTypeId ].tint:SetRGB( r, g, b )
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "pinTypeColor", pinTypeId, r, g, b)
end