local LAM = LibStub("LibAddonMenu-2.0")

local function CreateFilter( pinTypeId )
	local pinTypeId = pinTypeId
	local filter = {
		type = "checkbox",
		name = Harvest.GetLocalization( "pintype" .. pinTypeId ),
		tooltip = Harvest.GetLocalization( "pintypetooltip" .. pinTypeId ),
		getFunc = function()
			return Harvest.IsMapPinTypeVisible( pinTypeId )
		end,
		setFunc = function( value )
			Harvest.SetMapPinTypeVisible( pinTypeId, value )
		end,
		default = Harvest.defaultSettings.isPinTypeVisible[ pinTypeId ],
	}
	return filter
end

local function CreateGatherFilter( pinTypeId )
	local pinTypeId = pinTypeId
	local gatherFilter = {
		type = "checkbox",
		name = zo_strformat( Harvest.GetLocalization( "savepin" ), Harvest.GetLocalization( "pintype" .. pinTypeId ) ),
		tooltip = Harvest.GetLocalization( "savetooltip" ),
		getFunc = function()
			return Harvest.IsPinTypeSavedOnGather( pinTypeId )
		end,
		setFunc = function( value )
			Harvest.SetPinTypeSavedOnGather( pinTypeId, value )
		end,
		default = Harvest.defaultSettings.isPinTypeSavedOnGather[ pinTypeId ],
	}
	return gatherFilter
end

local function CreateSizeSlider( pinTypeId )
	local pinTypeId = pinTypeId
	local sizeSlider = {
		type = "slider",
		name = Harvest.GetLocalization( "pinsize" ),
		tooltip =  zo_strformat( Harvest.GetLocalization( "pinsizetooltip" ), Harvest.GetLocalization( "pintype" .. pinTypeId ) ),
		min = 16,
		max = 64,
		getFunc = function()
			return Harvest.GetMapPinSize( pinTypeId )
		end,
		setFunc = function( value )
			Harvest.SetMapPinSize( pinTypeId, value )
		end,
		default = Harvest.defaultSettings.mapLayouts[ pinTypeId ].size,
		width = "half",
	}
	return sizeSlider
end

local function CreateColorPicker( pinTypeId )
	local pinTypeId = pinTypeId
	local colorPicker = {
		type = "colorpicker",
		name = Harvest.GetLocalization( "pincolor" ),
		tooltip = zo_strformat( Harvest.GetLocalization( "pincolortooltip" ), Harvest.GetLocalization( "pintype" .. pinTypeId ) ),
		getFunc = function() return Harvest.GetPinColor( pinTypeId ) end,
		setFunc = function( r, g, b ) Harvest.SetPinColor( pinTypeId, r, g, b ) end,
		default = Harvest.defaultSettings.mapLayouts[ pinTypeId ].tint,
		width = "half",
	}
	return colorPicker
end

function Harvest.InitializeOptions()
	-- first LAM stuff, at the end of this function we will also create
	-- a custom checkbox in the map's filter menu for the heat map
	local panelData = {
		type = "panel",
		name = "HarvestMap",
		displayName = ZO_HIGHLIGHT_TEXT:Colorize("HarvestMap"),
		author = Harvest.author,
		version = Harvest.displayVersion,
		registerForRefresh = true,
		registerForDefaults = true,
		website = "http://www.esoui.com/downloads/info57",
	}

	local optionsTable = setmetatable({}, { __index = table })

	--[[
	optionsTable:insert({
		type = "description",
		title = nil,
		text = Harvest.GetLocalization("esouidescription"),
		width = "full",
	})

	optionsTable:insert({
		type = "button",
		name = Harvest.GetLocalization("openesoui"),
		func = function() RequestOpenUnsafeURL("http://www.esoui.com/downloads/info57") end,
		width = "half",
	})
	--]]
	optionsTable:insert({
		type = "description",
		title = nil,
		text = Harvest.GetLocalization("mergedescription"),
		width = "full",
	})

	optionsTable:insert({
		type = "button",
		name = Harvest.GetLocalization("openmerge"),
		func = function() RequestOpenUnsafeURL("http://www.teso-harvest-merge.de") end,
		width = "half",
	})
	
	optionsTable:insert({
		type = "description",
		title = nil,
		text = Harvest.GetLocalization("debuginfodescription"),
		width = "full",
	})
	
	optionsTable:insert({
		type = "button",
		name = Harvest.GetLocalization("printdebuginfo"),
		func = function() HarvestDebugClipboardOutputBox:SetText(Harvest.GenerateDebugInfo()) end,
		width = "half",
	})
	
	--[[
	optionsTable:insert({
		type = "header",
		name= Harvest.GetLocalization("outdateddata"),
	})
	
	optionsTable:insert({
		type = "button",
		name = Harvest.GetLocalization("apply"),
		func = Harvest.ApplyTimeDifference,
		width = "half",
		warning = Harvest.GetLocalization("applywarning")
	})
	--]]
	
	local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "submenu",
		name = Harvest.GetLocalization("outdateddata"),
		controls = submenuTable,
	})
	
	submenuTable:insert({
		type = "dropdown",
		name = Harvest.GetLocalization("mingameversion"),
		tooltip = Harvest.GetLocalization("mingameversiontooltip"),
		choices = Harvest.validGameVersionsDisplay,
		choicesValues = Harvest.validGameVersions,
		getFunc = Harvest.GetDisplayedMinGameVersion,
		setFunc = Harvest.SetDisplayedMinGameVersion,
		width = "half",
		--default = Harvest.defaultSettings.minGameVersion,
	})
	
	submenuTable:insert({--optionsTable
		type = "slider",
		name = Harvest.GetLocalization("timedifference"),
		tooltip = Harvest.GetLocalization("timedifferencetooltip"),
		warning = Harvest.GetLocalization("timedifferencewarning"),
		min = 0,
		max = 712,
		getFunc = function()
			return Harvest.GetDisplayedMaxTimeDifference() / 24
		end,
		setFunc = function( value )
			Harvest.SetDisplayedMaxTimeDifference(value * 24)
		end,
		width = "half",
		default = 0,
	})
	
	submenuTable:insert({
		type = "button",
		name = GetString(SI_APPLY),--Harvest.GetLocalization("apply"),
		func = Harvest.ApplyTimeDifference,
		width = "half",
		warning = Harvest.GetLocalization("applywarning")
	})

	optionsTable:insert({
		type = "header",
		name = "",
	})

	optionsTable:insert({
		type = "checkbox",
		name = Harvest.GetLocalization("account"),
		tooltip = Harvest.GetLocalization("accounttooltip"),
		getFunc = Harvest.AreSettingsAccountWide,
		setFunc = Harvest.SetSettingsAccountWide,
		width = "full",
		warning = Harvest.GetLocalization("accountwarning"),
		--requireReload = true, -- doesn't work?
	})
	
	
	local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "submenu",
		name = Harvest.GetLocalization("performance"),
		controls = submenuTable,
	})
	
	--[[
	optionsTable:insert({
		type = "checkbox",
		name = Harvest.GetLocalization("refreshonharvest"),
		tooltip = Harvest.GetLocalization("refreshonharvesttooltip"),
		getFunc = Harvest.ShouldRefreshPinsOnHarvest,
		setFunc = Harvest.SetRefreshPinsOnHarvest,
		default = Harvest.defaultSettings.refreshOnHarvest,
	})
	--]]
	
	submenuTable:insert({
		type = "checkbox",
		name = Harvest.GetLocalization("hasdrawdistance"),
		tooltip = Harvest.GetLocalization("hasdrawdistancetooltip"),
		getFunc = Harvest.HasPinVisibleDistance,
		setFunc = Harvest.SetHasPinVisibleDistance,
		default = Harvest.defaultSettings.hasMaxVisibleDistance,
		width = "half",
	})

	submenuTable:insert({
		type = "slider",
		name = Harvest.GetLocalization("drawdistance"),
		tooltip = Harvest.GetLocalization("drawdistancetooltip"),
		min = 100,
		max = 1000,
		getFunc = Harvest.GetDisplayPinVisibleDistance,
		setFunc = Harvest.SetPinVisibleDistance,
		default = 100,
		width = "half",
	})
	
	local disabled = (FyrMM ~= nil)
	local tooltip
	if disabled then
		tooltip = Harvest.GetLocalization("minimapconflict")
	else
		tooltip = Harvest.GetLocalization("drawspeedtooltip")
	end
	
	submenuTable:insert({
		type = "slider",
		name = Harvest.GetLocalization("drawspeed"),
		tooltip = tooltip,
		min = 10,
		max = 500,
		getFunc = Harvest.GetDisplaySpeed,
		setFunc = Harvest.SetDisplaySpeed,
		default = Harvest.defaultSettings.displaySpeed,
		disabled = disabled,
	})
	
	if disabled then
		tooltip = Harvest.GetLocalization("minimapconflict")
	else
		tooltip = Harvest.GetLocalization("delaywheninfighttooltip")
	end
	
	submenuTable:insert({
		type = "checkbox",
		name = Harvest.GetLocalization("delaywheninfight"),
		tooltip = tooltip,
		min = 10,
		max = 500,
		getFunc = Harvest.IsDelayedWhenInFight,
		setFunc = Harvest.SetDelayedWhenInFight,
		default = Harvest.defaultSettings.delayWhenInFight,
		width = "half",
		disabled = disabled,
	})
	
	if disabled then
		tooltip = Harvest.GetLocalization("minimapconflict")
	else
		tooltip = Harvest.GetLocalization("delaywhenmapclosedtooltip")
	end

	submenuTable:insert({
		type = "checkbox",
		name = Harvest.GetLocalization("delaywhenmapclosed"),
		tooltip = tooltip,
		min = 10,
		max = 500,
		getFunc = Harvest.IsDelayedWhenMapClosed,
		setFunc = Harvest.SetDelayedWhenMapClosed,
		default = Harvest.defaultSettings.delayUntilMapOpen,
		width = "half",
		disabled = disabled,
	})
	
	local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "submenu",
		name = Harvest.GetLocalization("farmandrespawn"),
		controls = submenuTable,
	})
	
	submenuTable:insert({
		type = "slider",
		name = Harvest.GetLocalization("rangemultiplier"),
		tooltip = Harvest.GetLocalization("rangemultipliertooltip"),
		min = 5,
		max = 20,
		getFunc = Harvest.GetDisplayedVisitedRangeMultiplier,
		setFunc = Harvest.SetDisplayedVisitedRangeMultiplier,
		default = 10,
	})
	
	local disabled = (FyrMM ~= nil)
	local tooltip
	if disabled then
		tooltip = Harvest.GetLocalization("minimapconflict")
	else
		tooltip = Harvest.GetLocalization("hiddentimetooltip")
	end
	
	submenuTable:insert({
		type = "slider",
		name = Harvest.GetLocalization("hiddentime"),
		tooltip = tooltip,
		warning = Harvest.GetLocalization("hiddentimewarning"),
		min = 0,
		max = 30,
		getFunc = Harvest.GetHiddenTime,
		setFunc = Harvest.SetHiddenTime,
		default = 0,
		disabled = disabled,
	})
	
	if disabled then
		tooltip = Harvest.GetLocalization("minimapconflict")
	else
		tooltip = Harvest.GetLocalization("hiddenonharvesttooltip")
	end

	submenuTable:insert({
		type = "checkbox",
		name = Harvest.GetLocalization("hiddenonharvest"),
		tooltip = tooltip,
		getFunc = Harvest.IsHiddenOnHarvest,
		setFunc = Harvest.SetHiddenOnHarvest,
		default = Harvest.defaultSettings.hiddenOnHarvest,
		disabled = disabled,
	})
	
	local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "submenu",
		name = Harvest.GetLocalization("compassandworld"),
		controls = submenuTable,
	})
	
	submenuTable:insert({
		type = "checkbox",
		name = Harvest.GetLocalization("compass"),
		tooltip = Harvest.GetLocalization("compasstooltip"),
		getFunc = Harvest.AreCompassPinsVisible,
		setFunc = function(...)
			Harvest.SetCompassPinsVisible(...)
			CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", HarvestMapInRangeMenu.panel)
		end,
		default = Harvest.defaultSettings.isCompassVisible,
	})

	submenuTable:insert({
		type = "slider",
		name = Harvest.GetLocalization("compassdistance"),
		tooltip = Harvest.GetLocalization("compassdistancetooltip"),
		min = 50,
		max = 250,
		getFunc = Harvest.GetDisplayedCompassDistance,
		setFunc = Harvest.SetDisplayedCompassDistance,
		default = 100,
	})
	
	submenuTable:insert({
		type = "checkbox",
		name = Harvest.GetLocalization("worldpins"),
		tooltip = Harvest.GetLocalization("worldpinstooltip"),
		warning = Harvest.GetLocalization("worldpinswarning"),
		getFunc = Harvest.AreWorldPinsVisible,
		setFunc = function(...)
			Harvest.SetWorldPinsVisible(...)
			CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", HarvestMapInRangeMenu.panel)
		end,
		default = Harvest.defaultSettings.worldPinsVisible,
	})

	submenuTable:insert({
		type = "slider",
		name = Harvest.GetLocalization("worlddistance"),
		tooltip = Harvest.GetLocalization("worlddistancetooltip"),
		min = 50,
		max = 250,
		getFunc = Harvest.GetDisplayedWorldDistance,
		setFunc = Harvest.SetDisplayedWorldDistance,
		default = 100,
	})
	
	submenuTable:insert({
		type = "slider",
		name = Harvest.GetLocalization("worldpinheight"),
		tooltip = Harvest.GetLocalization("worldpinheighttooltip"),
		min = 2,
		max = 10,
		getFunc = Harvest.GetWorldPinHeight,
		setFunc = Harvest.SetWorldPinHeight,
		default = Harvest.defaultSettings.worldPinHeight,
	})
	
	submenuTable:insert({
		type = "checkbox",
		name = Harvest.GetLocalization("worldpinsdepth"),
		tooltip = Harvest.GetLocalization("worldpinsdepthtooltip"),
		warning = Harvest.GetLocalization("worldpinsdepthwarning"),
		getFunc = Harvest.DoWorldPinsUseDepth,
		setFunc = Harvest.SetWorldPinsUseDepth,
		default = Harvest.defaultSettings.worldPinDepth,
	})
	--[[
	local res = Harvest.Get3DResolution()
	local uWidth, uHeight = Harvest.GetUIResolution()
	local sub = Harvest.GetSubSampling()
	optionsTable:insert({
		type = "description",
		title = nil,
		text = zo_strformat(Harvest.GetLocalization("worldpininfo"), res, uWidth, uHeight, sub )
	})
	
	optionsTable:insert({
		type = "button",
		name = Harvest.GetLocalization("worldpingraphic"),
		func = Harvest.SetToCompatibleGraphicSettings,
	})
	--]]
	
	local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "submenu",
		name = Harvest.GetLocalization("pinoptions"),
		controls = submenuTable,
	})
	
	submenuTable:insert({
		type = "checkbox",
		name = Harvest.GetLocalization("level"),
		tooltip = Harvest.GetLocalization("leveltooltip"),
		getFunc = Harvest.ArePinsAbovePOI,
		setFunc = Harvest.SetPinsAbovePOI,
		default = (Harvest.defaultSettings.mapLayouts[1].level > 50),
	})
	
	if FyrMM or VOTANS_MINIMAP then
		submenuTable:insert({
			type = "slider",
			name = Harvest.GetLocalization( "pinsize" ),
			--tooltip =  zo_strformat( Harvest.GetLocalization( "pinsizetooltip" ), Harvest.GetLocalization( "pintype" .. pinTypeId ) ),
			min = 16,
			max = 64,
			getFunc = function()
				return Harvest.GetMapPinSize( 0 )
			end,
			setFunc = function( value )
				Harvest.SetMapPinSize( 0, value )
			end,
			default = Harvest.defaultSettings.minimapPinSize,
			width = "half",
		})
	end
	
	for _, pinTypeId in ipairs( Harvest.PINTYPES ) do
		if pinTypeId ~= Harvest.TOUR then--and not Harvest.GetPinTypeInGroup(pinTypeId) then
			submenuTable:insert({
				type = "header",
				name = zo_strformat( Harvest.GetLocalization( "options" ), Harvest.GetLocalization( "pintype" .. pinTypeId ) )
			})
			submenuTable:insert( CreateFilter( pinTypeId ) )
			--optionsTable:insert( CreateImportFilter( pinTypeId ) ) -- moved to the HarvestImport folder
			submenuTable:insert( CreateGatherFilter( pinTypeId ) )
			submenuTable:insert( CreateColorPicker( pinTypeId ) )
			if not FyrMM and not VOTANS_MINIMAP then
				submenuTable:insert( CreateSizeSlider( pinTypeId ) )
			end
		end
	end

	optionsTable:insert({
		type = "header",
		name = Harvest.GetLocalization("debugoptions"),
	})

	optionsTable:insert({
		type = "checkbox",
		name = Harvest.GetLocalization( "debug" ),
		tooltip = Harvest.GetLocalization( "debugtooltip" ),
		getFunc = Harvest.AreDebugMessagesEnabled,
		setFunc = Harvest.SetDebugMessagesEnabled,
		default = Harvest.defaultSettings.debug,
	})

	Harvest.optionsPanel = LAM:RegisterAddonPanel("HarvestMapControl", panelData)
	LAM:RegisterOptionControls("HarvestMapControl", optionsTable)

	-- heat map check box in the map's filter menu:
	-- code based on LibMapPin, see Libs/LibMapPin-1.0/LibMapPins-1.0.lua for credits
	local function AddCheckbox(panel, pinCheckboxText)
		local checkbox = panel.checkBoxPool:AcquireObject()
		ZO_CheckButton_SetLabelText(checkbox, pinCheckboxText)
		panel:AnchorControl(checkbox)
		return checkbox
	end

	local pve = AddCheckbox(WORLD_MAP_FILTERS.pvePanel, Harvest.GetLocalization( "filterheatmap" ))
	local pvp = AddCheckbox(WORLD_MAP_FILTERS.pvpPanel, Harvest.GetLocalization( "filterheatmap" ))
	local imperialPvP = AddCheckbox(WORLD_MAP_FILTERS.imperialPvPPanel, Harvest.GetLocalization( "filterheatmap" ))
	local fun = function(button, state)
		Harvest.SetHeatmapActive(state)
	end
	ZO_CheckButton_SetToggleFunction(pve, fun)
	ZO_CheckButton_SetToggleFunction(pvp, fun)
	ZO_CheckButton_SetToggleFunction(imperialPvP, fun)

	local mapFilterType = GetMapFilterType()
	if mapFilterType == MAP_FILTER_TYPE_STANDARD then
		ZO_CheckButton_SetCheckState(pve, Harvest.IsHeatmapActive())
	elseif mapFilterType == MAP_FILTER_TYPE_AVA_CYRODIIL then
		ZO_CheckButton_SetCheckState(pvp, Harvest.IsHeatmapActive())
	elseif mapFilterType == MAP_FILTER_TYPE_AVA_IMPERIAL then
		ZO_CheckButton_SetCheckState(imperialPvP, Harvest.IsHeatmapActive())
	end
	
	pve = AddCheckbox(WORLD_MAP_FILTERS.pvePanel, Harvest.GetLocalization( "deletepinfilter" ))
	pvp = AddCheckbox(WORLD_MAP_FILTERS.pvpPanel, Harvest.GetLocalization( "deletepinfilter" ))
	imperialPvP = AddCheckbox(WORLD_MAP_FILTERS.imperialPvPPanel, Harvest.GetLocalization( "deletepinfilter" ))
	local fun = function(button, state)
		Harvest.SetDebugEnabled(state)
	end
	ZO_CheckButton_SetToggleFunction(pve, fun)
	ZO_CheckButton_SetToggleFunction(pvp, fun)
	ZO_CheckButton_SetToggleFunction(imperialPvP, fun)

	local mapFilterType = GetMapFilterType()
	if mapFilterType == MAP_FILTER_TYPE_STANDARD then
		ZO_CheckButton_SetCheckState(pve, Harvest.IsDebugEnabled())
	elseif mapFilterType == MAP_FILTER_TYPE_AVA_CYRODIIL then
		ZO_CheckButton_SetCheckState(pvp, Harvest.IsDebugEnabled())
	elseif mapFilterType == MAP_FILTER_TYPE_AVA_IMPERIAL then
		ZO_CheckButton_SetCheckState(imperialPvP, Harvest.IsDebugEnabled())
	end
end
