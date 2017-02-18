local Azurah		= _G['Azurah'] -- grab addon table from global

local defaults = {
	uiData						= {},
	-- compass pins
	compassPinScale				= 1.0,
	compassHidePinLabel			= false,
	-- thievery
	theftPreventAccidental		= false,
	theftMakeSafer				= false,
	-- random options
	modeChangeReload			= false,
	attributes = {
		fadeMinAlpha			= 0,	-- when full
		fadeMaxAlpha			= 1,	-- when not full
		combatBars				= true,
		lockSize				= false,
		-- overlays
		healthOverlay			= 2,
		healthOverlayFancy		= false,
		healthFontFace			= 'Univers 67',
		healthFontColour		= {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
		healthFontOutline		= 'soft-shadow-thick',
		healthFontSize			= 16,
		magickaOverlay			= 2,
		magickaOverlayFancy		= false,
		magickaFontFace			= 'Univers 67',
		magickaFontColour		= {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
		magickaFontOutline		= 'soft-shadow-thick',
		magickaFontSize			= 16,
		staminaOverlay			= 2,
		staminaOverlayFancy		= false,
		staminaFontFace			= 'Univers 67',
		staminaFontColour		= {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
		staminaFontOutline		= 'soft-shadow-thick',
		staminaFontSize			= 16,
	},
	target = {
		lockSize				= false,
		RPName					= false,
		RPTitle					= false,
		RPInteract				= false,
		RPIcon					= false,
		colourByBar				= 2,
		colourByName			= 1,
		colourByLevel			= true,
		classShow				= false,
		classByName				= true,
		allianceShow			= false,
		allianceByName			= false,
		-- overlay
		overlay					= 2,
		overlayFancy			= false,
		fontFace				= 'Univers 67',
		fontColour				= {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
		fontOutline				= 'soft-shadow-thick',
		fontSize				= 16,
	},
	bossbar = {
		overlay					= 2,
		overlayFancy			= false,
		fontFace				= 'Univers 67',
		fontColour				= {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
		fontOutline				= 'soft-shadow-thick',
		fontSize				= 16,
	},
	actionBar = {
		hideBindBG				= false,
		hideBindText			= false,
		hideWeaponSwap			= false,
		-- overlays
		ultValueShow			= true,
		ultValueFontFace		= 'Univers 67',
		ultValueFontColour		= {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
		ultValueFontOutline		= 'soft-shadow-thick',
		ultValueFontSize		= 16,
		ultPercentShow			= true,
		ultPercentFontFace		= 'Univers 67',
		ultPercentFontColour	= {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
		ultPercentFontOutline	= 'soft-shadow-thick',
		ultPercentFontSize		= 16,
		ultPercentRelative		= false,
	},
	experienceBar = {
		displayStyle			= 1,
		-- overlay
		overlay					= 2,
		overlayFancy			= true,
		fontFace				= 'Univers 67',
		fontColour				= {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
		fontOutline				= 'soft-shadow-thick',
		fontSize				= 16,
	},
	bagWatcher = {
		enabled 				= false,
		reverseAlignment		= true,
		lowSpaceLock			= true,
		lowSpaceTrigger			= 10,
		-- overlay
		overlay					= 2,
		fontFace				= 'Univers 67',
		fontColour				= {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
		fontOutline				= 'soft-shadow-thick',
		fontSize				= 18,
	},
	werewolf = {
		enabled					= false,
		flashOnExtend			= true,
		iconOnRight				= false,
		fontFace				= 'Univers 67',
		fontColour				= {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
		fontOutline				= 'soft-shadow-thick',
		fontSize				= 20,
	}
}

function Azurah:GetDefaults()
	return defaults
end
