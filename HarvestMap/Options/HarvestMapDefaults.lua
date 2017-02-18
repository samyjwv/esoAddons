if not Harvest then
	Harvest = {}
end

Harvest.defaultGlobalSettings = {
	accountWideSettings = false,
	maxTimeDifference = 0
}

Harvest.defaultSettings = {
	-- which pins are displayed on the map/compass
	isPinTypeVisible = {
		[Harvest.BLACKSMITH]  = true,
		[Harvest.CLOTHING]    = true,
		[Harvest.ENCHANTING]  = true,
		[Harvest.MUSHROOM]     = true,
		[Harvest.FLOWER]     = true,
		[Harvest.WATERPLANT]     = true,
		[Harvest.WOODWORKING] = true,
		[Harvest.CHESTS]      = true,
		[Harvest.WATER]       = true,
		[Harvest.FISHING]     = true,
		[Harvest.HEAVYSACK]   = true,
		[Harvest.TROVE]       = true,
		[Harvest.JUSTICE]     = true,
		[Harvest.STASH]       = true,
		[Harvest.TOUR]        = true,
		[Harvest.GetPinType( "Debug" )] = false
	},
	
	isWorldFilterActive = false,
	isWorldPinTypeVisible = {
		[Harvest.BLACKSMITH]  = false,
		[Harvest.CLOTHING]    = false,
		[Harvest.ENCHANTING]  = false,
		[Harvest.MUSHROOM]     = false,
		[Harvest.FLOWER]     = false,
		[Harvest.WATERPLANT]     = false,
		[Harvest.WOODWORKING] = false,
		[Harvest.CHESTS]      = false,
		[Harvest.WATER]       = false,
		[Harvest.FISHING]     = false,
		[Harvest.HEAVYSACK]   = false,
		[Harvest.TROVE]       = false,
		[Harvest.JUSTICE]     = false,
		[Harvest.STASH]       = false,
		[Harvest.TOUR]        = false,
		[Harvest.GetPinType( "Debug" )] = false
	},
	
	isCompassFilterActive = false,
	isCompassPinTypeVisible = {
		[Harvest.BLACKSMITH]  = false,
		[Harvest.CLOTHING]    = false,
		[Harvest.ENCHANTING]  = false,
		[Harvest.MUSHROOM]     = false,
		[Harvest.FLOWER]     = false,
		[Harvest.WATERPLANT]     = false,
		[Harvest.WOODWORKING] = false,
		[Harvest.CHESTS]      = false,
		[Harvest.WATER]       = false,
		[Harvest.FISHING]     = false,
		[Harvest.HEAVYSACK]   = false,
		[Harvest.TROVE]       = false,
		[Harvest.JUSTICE]     = false,
		[Harvest.STASH]       = false,
		[Harvest.TOUR]        = false,
		[Harvest.GetPinType( "Debug" )] = false
	},
	-- which pin types are skipped while importing
	isPinTypeSavedOnImport = {
		[Harvest.BLACKSMITH]     = true,
		[Harvest.CLOTHING]       = true,
		[Harvest.ENCHANTING]     = true,
		[Harvest.MUSHROOM]     = true,
		[Harvest.FLOWER]     = true,
		[Harvest.WATERPLANT]     = true,
		[Harvest.WOODWORKING]    = true,
		[Harvest.CHESTS]         = true,
		[Harvest.WATER]          = true,
		[Harvest.FISHING]        = true,
		[Harvest.HEAVYSACK]      = true,
		[Harvest.TROVE]          = true,
		[Harvest.JUSTICE]        = true,
		[Harvest.STASH]          = true,
	},
	-- which pin types are skipped when gathered
	isPinTypeSavedOnGather = {
		[Harvest.BLACKSMITH]     = true,
		[Harvest.CLOTHING]       = true,
		[Harvest.ENCHANTING]     = true,
		[Harvest.MUSHROOM]     = true,
		[Harvest.FLOWER]     = true,
		[Harvest.WATERPLANT]     = true,
		[Harvest.WOODWORKING]    = true,
		[Harvest.CHESTS]         = true,
		[Harvest.WATER]          = true,
		[Harvest.FISHING]        = true,
		[Harvest.HEAVYSACK]      = true,
		[Harvest.TROVE]          = true,
		[Harvest.JUSTICE]        = true,
		[Harvest.STASH]          = true,
	},

	isZoneSavedOnImport = {
		["alikr"]                 = true,     --Alik'r Desert
		["auridon"]               = true,     --Auridon, Khenarthi's Roost
		["bangkorai"]             = true,     --Bangkorai
		["coldharbor"]            = true,     --Coldharbour
		["craglorn"]              = true,     --Craglorn
		["cyrodiil"]              = true,     --Cyrodiil
		["deshaan"]               = true,     --"Deshaan"
		["eastmarch"]             = true,     --Eastmarch
		["glenumbra"]             = true,     --Glenumbra, Betnikh, Stros M'Kai
		["grahtwood"]             = true,     --Grahtwood
		["greenshade"]            = true,     --Greenshade
		["malabaltor"]            = true,     --Malabal Tor
		["reapersmarch"]          = true,     --Reaper's March
		["rivenspire"]            = true,     --Rivenspire
		["shadowfen"]             = true,     --Shadowfen
		["stonefalls"]            = true,     --Stonefalls, Bal Foyen, Bleakrock Isle
		["stormhaven"]            = true,     --Stormhaven
		["therift"]               = true,     --The Rift
		["wrothgar"]              = true,
		["thievesguild"]          = true, --hew's bane
		["darkbrotherhood"]       = true, -- gold coast
	},

	mapLayouts = {
		[Harvest.BLACKSMITH]  = { level = 20, texture = "HarvestMap/Textures/Map/mining.dds", size = 20, tint = ZO_ColorDef:New(0.447, 0.49, 1, 1) },
		[Harvest.CLOTHING]    = { level = 20, texture = "HarvestMap/Textures/Map/clothing.dds", size = 20, tint = ZO_ColorDef:New(0.588, 0.988, 1, 1) },
		[Harvest.ENCHANTING]  = { level = 20, texture = "HarvestMap/Textures/Map/enchanting.dds", size = 20, tint = ZO_ColorDef:New(1, 0.455, 0.478, 1) },
		[Harvest.MUSHROOM]     = { level = 20, texture = "HarvestMap/Textures/Map/mushroom.dds", size = 20, tint = ZO_ColorDef:New(0.451, 0.569, 0.424, 1) },
		[Harvest.FLOWER]     = { level = 20, texture = "HarvestMap/Textures/Map/flower.dds", size = 20, tint = ZO_ColorDef:New(0.557, 1, 0.541, 1) },
		[Harvest.WATERPLANT]     = { level = 20, texture = "HarvestMap/Textures/Map/waterplant.dds", size = 20, tint = ZO_ColorDef:New(0.439, 0.937, 0.808, 1) },
		[Harvest.WOODWORKING] = { level = 20, texture = "HarvestMap/Textures/Map/wood.dds", size = 20, tint = ZO_ColorDef:New(1, 0.694, 0.494, 1) },
		[Harvest.CHESTS]      = { level = 20, texture = "HarvestMap/Textures/Map/chest.dds", size = 20, tint = ZO_ColorDef:New(1, 0.937, 0.38, 1) },
		[Harvest.WATER]       = { level = 20, texture = "HarvestMap/Textures/Map/solvent.dds", size = 20, tint = ZO_ColorDef:New(0.569, 0.827, 1, 1) },
		[Harvest.FISHING]     = { level = 20, texture = "HarvestMap/Textures/Map/fish.dds", size = 20, tint = ZO_ColorDef:New(1, 1, 1, 1) },
		[Harvest.HEAVYSACK]   = { level = 20, texture = "HarvestMap/Textures/Map/heavysack.dds", size = 20, tint = ZO_ColorDef:New(0.424, 0.69, .36, 1) },
		[Harvest.TROVE]       = { level = 20, texture = "HarvestMap/Textures/Map/trove.dds", size = 20, tint = ZO_ColorDef:New(0.780, 0.404, 1, 1) },
		[Harvest.JUSTICE]     = { level = 20, texture = "HarvestMap/Textures/Map/justice.dds", size = 20, tint = ZO_ColorDef:New(1, 1, 1, 1) },
		[Harvest.STASH]       = { level = 20, texture = "HarvestMap/Textures/Map/stash.dds", size = 20, tint = ZO_ColorDef:New(1, 1, 1, 1) },
		[Harvest.TOUR]        = { level = 25, texture = "HarvestMap/Textures/Map/tour.dds", size = 32, tint = ZO_ColorDef:New(1, 0, 0, 1) },
	},

	compassLayouts = {
		[Harvest.BLACKSMITH]  = {texture = "HarvestMap/Textures/Compass/mining.dds", },
		[Harvest.CLOTHING]    = {texture = "HarvestMap/Textures/Compass/clothing.dds", },
		[Harvest.ENCHANTING]  = {texture = "HarvestMap/Textures/Compass/enchanting.dds", },
		[Harvest.MUSHROOM]     = {texture = "HarvestMap/Textures/Compass/mushroom.dds", },
		[Harvest.FLOWER]     = {texture = "HarvestMap/Textures/Compass/flower.dds", },
		[Harvest.WATERPLANT]     = {texture = "HarvestMap/Textures/Compass/waterplant.dds", },
		[Harvest.WOODWORKING] = {texture = "HarvestMap/Textures/Compass/wood.dds", },
		[Harvest.CHESTS]      = {texture = "HarvestMap/Textures/Compass/chest.dds", },
		[Harvest.WATER]       = {texture = "HarvestMap/Textures/Compass/solvent.dds", },
		[Harvest.FISHING]     = {texture = "HarvestMap/Textures/Compass/fish.dds", },
		[Harvest.HEAVYSACK]   = {texture = "HarvestMap/Textures/Compass/heavysack.dds", },
		[Harvest.TROVE]       = {texture = "HarvestMap/Textures/Compass/trove.dds", },
		[Harvest.JUSTICE]     = {texture = "HarvestMap/Textures/Compass/justice.dds", },
		[Harvest.STASH]       = {texture = "HarvestMap/Textures/Compass/stash.dds", },
		[Harvest.TOUR]        = {texture = "HarvestMap/Textures/Compass/tour.dds", },
	},

	isCompassVisible = true,
	debug = false,
	verbose = false,
	hiddenTime = 0,
	showExactItems = false,
	hiddenOnHarvest = false,
	hideArrow = false,
	hideFarmingInterface = false,
	maxVisibleDistance = 0.004062019202318,
	hasMaxVisibleDistance = false,
	displaySpeed = 500,
	delayWhenInFight = true,
	delayUntilMapOpen = false,
	rangeMuliplier = 1,
	worldPinsVisible = true,
	simpleWorldPins = false,
	compassDistance = 0.004062019202318,
	worldDistance = 0.004062019202318,
	worldPinDepth = true,
	worldPinHeight = 2,
	minimapPinSize = 20,
	minGameVersion = 0,
}