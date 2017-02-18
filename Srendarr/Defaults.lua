local Srendarr		= _G['Srendarr'] -- grab addon table from global

-- CONST DECLARATIONS : referenced locally in other files when needed --
Srendarr.AURA_UPDATE_RATE		= 0.05
Srendarr.CAST_UPDATE_RATE		= 0.02

Srendarr.NUM_DISPLAY_FRAMES		= 8

Srendarr.GROUP_PLAYER_SHORT		= 1		-- categories to divide up auras for positioning in
Srendarr.GROUP_PLAYER_LONG		= 2		-- the (player chosen) display frames
Srendarr.GROUP_PLAYER_TOGGLED	= 3
Srendarr.GROUP_PLAYER_PASSIVE	= 4
Srendarr.GROUP_PLAYER_DEBUFF	= 5
Srendarr.GROUP_PLAYER_GROUND	= 6
Srendarr.GROUP_PLAYER_MAJOR		= 7
Srendarr.GROUP_PLAYER_MINOR		= 8
Srendarr.GROUP_PLAYER_ENCHANT	= 9
Srendarr.GROUP_TARGET_BUFF		= 10
Srendarr.GROUP_TARGET_DEBUFF	= 11
Srendarr.GROUP_PROMINENT		= 100	-- special case, only assigned to auras when whitelisted
Srendarr.GROUP_PROMINENT2		= 101	-- special case, only assigned to auras when whitelisted

Srendarr.AURA_TYPE_TIMED		= 1
Srendarr.AURA_TYPE_TOGGLED		= 2
Srendarr.AURA_TYPE_PASSIVE		= 3

Srendarr.AURA_HEIGHT			= 40

Srendarr.AURA_STYLE_FULL		= 1
Srendarr.AURA_STYLE_ICON		= 2
Srendarr.AURA_STYLE_MINI		= 3

Srendarr.AURA_GROW_UP			= 1
Srendarr.AURA_GROW_DOWN			= 2
Srendarr.AURA_GROW_LEFT			= 3
Srendarr.AURA_GROW_RIGHT		= 4
Srendarr.AURA_GROW_CENTERLEFT	= 5
Srendarr.AURA_GROW_CENTERRIGHT	= 6

Srendarr.AURA_SORT_NAMEASC		= 1
Srendarr.AURA_SORT_TIMEASC		= 2
Srendarr.AURA_SORT_CASTASC		= 3
Srendarr.AURA_SORT_NAMEDESC		= 4
Srendarr.AURA_SORT_TIMEDESC		= 5
Srendarr.AURA_SORT_CASTDESC		= 6

Srendarr.AURA_TIMERLOC_HIDDEN	= 1
Srendarr.AURA_TIMERLOC_OVER		= 2
Srendarr.AURA_TIMERLOC_ABOVE	= 3
Srendarr.AURA_TIMERLOC_BELOW	= 4

Srendarr.STR_PROMBYID			= 'ProminentByID'
Srendarr.STR_PROMBYID2			= 'ProminentByID2'
Srendarr.STR_BLOCKBYID			= 'BlockByID'


-- register our new default sound with LibMediaProvider (cannot be a localized name for consistant internal refs)
LibStub('LibMediaProvider-1.0'):Register('sound', 'Srendarr Ability Proc', SOUNDS.DEATH_RECAP_KILLING_BLOW_SHOWN)


local defaults = {
	-- general
	combatDisplayOnly			= false,
	auraFakeEnabled				= true,
	consolidateEnabled			= true,
	auraFadeTime				= 2,
	shortBuffThreshold			= 35,
	procEnableAnims				= true,
	procPlaySound				= 'Srendarr Ability Proc',	-- can be set to None by user
	passiveEffectsAsPassive		= false,
	showCombatEvents			= false,
	disableSpamControl			= false,
	manualDebug					= true,
	showNoNames					= false,
	displayAbilityID			= false,
	hideOnDeadTargets			= false,
	auraGroups = {
		[Srendarr.GROUP_PLAYER_SHORT]	= 1,	-- set the displayFrame that will display this grouping
		[Srendarr.GROUP_PLAYER_LONG]	= 2,	-- multiple groupings can go to a given frame
		[Srendarr.GROUP_PLAYER_TOGGLED]	= 2,
		[Srendarr.GROUP_PLAYER_PASSIVE]	= 2,	-- a setting of 0 means don't display this grouping at all
		[Srendarr.GROUP_PLAYER_DEBUFF]	= 3,
		[Srendarr.GROUP_PLAYER_GROUND]	= 4,
		[Srendarr.GROUP_PLAYER_MAJOR]	= 1,
		[Srendarr.GROUP_PLAYER_MINOR]	= 1,
		[Srendarr.GROUP_PLAYER_ENCHANT]	= 1,
		[Srendarr.GROUP_TARGET_BUFF]	= 5,
		[Srendarr.GROUP_TARGET_DEBUFF]	= 6,
		[Srendarr.GROUP_PROMINENT]		= 0,
		[Srendarr.GROUP_PROMINENT2]		= 0,
	},
	prominentWhitelist			= {},			-- list of auras that are filtered to the 1st prominent group
	prominentWhitelist2			= {},			-- list of auras that are filtered to the 2nd prominent group
	blacklist					= {},			-- list of auras that are to be blacklisted from display
	-- filters
	filtersPlayer = {
		block					= false,		-- as these are filters, false means DO show this filter category
		cyrodiil				= false,
		disguise				= false,
		mundusBoon				= false,
		soulSummons				= false,
		vampLycan				= false,
		vampLycanBite			= false,
	},
	filtersTarget = {
		block					= false,		-- as these are filters, false means DO show this filter category
		cyrodiil				= false,
		disguise				= false,
		majorEffects			= false,
		minorEffects			= false,
		mundusBoon				= false,
		soulSummons				= false,
		vampLycan				= false,
		vampLycanBite			= false,
	},
	castBar = {
		enabled					= true,
		base					= {point = BOTTOM, x = 0, y = -160, alpha = 1.0, scale = 1.0},
		nameShow				= true,
		nameFont				= 'Univers 67',
		nameStyle				= 'soft-shadow-thick',
		nameSize				= 15,
		nameColour				= {0.9, 0.9, 0.9, 1.0},
		timerShow				= true,
		timerFont				= 'Univers 67',
		timerStyle				= 'soft-shadow-thick',
		timerSize				= 15,
		timerColour				= {0.9, 0.9, 0.9, 1.0},
		barReverse				= false,							-- bar alignment direction
		barGloss				= true,
		barWidth				= 255,
		barColour				= {r1 = 0, g1 = 0.1843, b1 = 0.5098, r2 = 0.3215, g2 = 0.8431, b2 = 1},
	},
	displayFrames = {
		[1] = {
			base				= {point = BOTTOMRIGHT, x = 0, y = 0, alpha = 1.0, scale = 1.0},
			style				= Srendarr.AURA_STYLE_FULL,		-- FULL|ICON|MINI
			auraGrowth			= Srendarr.AURA_GROW_UP,		-- UP|DOWN|LEFT|LEFTCENTER|RIGHT|RIGHTCENTER (valid choices vary based on style)
			auraPadding			= 3,
			auraSort			= Srendarr.AURA_SORT_TIMEASC,	-- NAME|TIME|CAST + ASC|DESC
			highlightToggled	= true,							-- shows the same 'toggled on' highlight action buttons do on toggles
			enableTooltips		= false,						-- show mouseover tooltip for auraName in ICON mode
			nameFont			= 'Univers 67',
			nameStyle			= 'soft-shadow-thick',
			nameSize			= 16,
			nameColour			= {0.9, 0.9, 0.9, 1.0},
			timerFont			= 'Univers 67',
			timerStyle			= 'soft-shadow-thick',
			timerSize			= 14,
			timerColour			= {0.9, 0.9, 0.9, 1.0},
			timerLocation		= Srendarr.AURA_TIMERLOC_OVER,	-- ABOVE|BELOW|OVER|HIDE (valid choices based on style)
			timerHMS			= true,
			barReverse			= true,							-- bar alignment direction (and icon placement in the FULL style)
			barGloss			= true,
			barWidth			= 160,
			barColours = {
				[Srendarr.AURA_TYPE_TIMED]		= {r1 = 0,		g1 = 0.1843, b1 = 0.5098, r2 = 0.3215, g2 = 0.8431, b2 = 1},
				[Srendarr.AURA_TYPE_TOGGLED]	= {r1 = 0.7764,	g1 = 0.6000, b1 = 0.1137, r2 = 0.9725, g2 = 0.8745, b2 = 0.2941},
				[Srendarr.AURA_TYPE_PASSIVE]	= {r1 = 0.4196,	g1 = 0.3803, b1 = 0.2313, r2 = 0.4196, g2 = 0.3803, b2 = 0.2313},
			},
		},
		[2] = {
			base				= {point = BOTTOMRIGHT, x = -210, y = 0, alpha = 1.0, scale = 1.0},
			style				= Srendarr.AURA_STYLE_FULL,		-- FULL|ICON|MINI
			auraGrowth			= Srendarr.AURA_GROW_UP,		-- UP|DOWN|LEFT|RIGHT|CENTERLEFT|CENTERRIGHT (valid choices vary based on style)
			auraPadding			= 3,
			auraSort			= Srendarr.AURA_SORT_TIMEASC,	-- NAME|TIME|CAST + ASC|DESC
			highlightToggled	= true,							-- shows the same 'toggled on' highlight action buttons do on toggles
			enableTooltips		= false,						-- show mouseover tooltip for auraName in ICON mode
			nameFont			= 'Univers 67',
			nameStyle			= 'soft-shadow-thick',
			nameSize			= 16,
			nameColour			= {0.9, 0.9, 0.9, 1.0},
			timerFont			= 'Univers 67',
			timerStyle			= 'soft-shadow-thick',
			timerSize			= 14,
			timerColour			= {0.9, 0.9, 0.9, 1.0},
			timerLocation		= Srendarr.AURA_TIMERLOC_OVER,	-- ABOVE|BELOW|OVER|HIDE (valid choices based on style)
			timerHMS			= true,
			barReverse			= true,							-- bar alignment direction (and icon placement in the FULL style)
			barGloss			= true,
			barWidth			= 160,
			barColours = {
				[Srendarr.AURA_TYPE_TIMED]		= {r1 = 0,		g1 = 0.1843, b1 = 0.5098, r2 = 0.3215, g2 = 0.8431, b2 = 1},
				[Srendarr.AURA_TYPE_TOGGLED]	= {r1 = 0.7764,	g1 = 0.6000, b1 = 0.1137, r2 = 0.9725, g2 = 0.8745, b2 = 0.2941},
				[Srendarr.AURA_TYPE_PASSIVE]	= {r1 = 0.4196,	g1 = 0.3803, b1 = 0.2313, r2 = 0.4196, g2 = 0.3803, b2 = 0.2313},
			},
		},
		[3] = {
			base				= {point = TOPRIGHT, x = 0, y = 0, alpha = 1.0, scale = 1.0},
			style				= Srendarr.AURA_STYLE_FULL,		-- FULL|ICON|MINI
			auraGrowth			= Srendarr.AURA_GROW_DOWN,		-- UP|DOWN|LEFT|RIGHT|CENTERLEFT|CENTERRIGHT (valid choices vary based on style)
			auraPadding			= 3,
			auraSort			= Srendarr.AURA_SORT_TIMEASC,	-- NAME|TIME|CAST + ASC|DESC
			highlightToggled	= true,							-- shows the same 'toggled on' highlight action buttons do on toggles
			enableTooltips		= false,						-- show mouseover tooltip for auraName in ICON mode
			nameFont			= 'Univers 67',
			nameStyle			= 'soft-shadow-thick',
			nameSize			= 16,
			nameColour			= {0.9, 0.9, 0.9, 1.0},
			timerFont			= 'Univers 67',
			timerStyle			= 'soft-shadow-thick',
			timerSize			= 14,
			timerColour			= {0.9, 0.9, 0.9, 1.0},
			timerLocation		= Srendarr.AURA_TIMERLOC_OVER,	-- ABOVE|BELOW|OVER|HIDE (valid choices based on style)
			timerHMS			= true,
			barReverse			= true,							-- bar alignment direction (and icon placement in the FULL style)
			barGloss			= true,
			barWidth			= 160,
			barColours = {
				[Srendarr.AURA_TYPE_TIMED]		= {r1 = 0,		g1 = 0.1843, b1 = 0.5098, r2 = 0.3215, g2 = 0.8431, b2 = 1},
				[Srendarr.AURA_TYPE_TOGGLED]	= {r1 = 0.7764,	g1 = 0.6000, b1 = 0.1137, r2 = 0.9725, g2 = 0.8745, b2 = 0.2941},
				[Srendarr.AURA_TYPE_PASSIVE]	= {r1 = 0.4196,	g1 = 0.3803, b1 = 0.2313, r2 = 0.4196, g2 = 0.3803, b2 = 0.2313},
			},
		},
		[4] = {
			base				= {point = TOPLEFT, x = 0, y = 0, alpha = 1.0, scale = 1.0},
			style				= Srendarr.AURA_STYLE_FULL,		-- FULL|ICON|MINI
			auraGrowth			= Srendarr.AURA_GROW_DOWN,		-- UP|DOWN|LEFT|RIGHT|CENTERLEFT|CENTERRIGHT (valid choices vary based on style)
			auraPadding			= 3,
			auraSort			= Srendarr.AURA_SORT_TIMEASC,	-- NAME|TIME|CAST + ASC|DESC
			highlightToggled	= true,							-- shows the same 'toggled on' highlight action buttons do on toggles
			enableTooltips		= false,						-- show mouseover tooltip for auraName in ICON mode
			nameFont			= 'Univers 67',
			nameStyle			= 'soft-shadow-thick',
			nameSize			= 16,
			nameColour			= {0.9, 0.9, 0.9, 1.0},
			timerFont			= 'Univers 67',
			timerStyle			= 'soft-shadow-thick',
			timerSize			= 14,
			timerColour			= {0.9, 0.9, 0.9, 1.0},
			timerLocation		= Srendarr.AURA_TIMERLOC_OVER,	-- ABOVE|BELOW|OVER|HIDE (valid choices based on style)
			timerHMS			= true,
			barReverse			= false,						-- bar alignment direction (and icon placement in the FULL style)
			barGloss			= true,
			barWidth			= 160,
			barColours = {
				[Srendarr.AURA_TYPE_TIMED]		= {r1 = 0,		g1 = 0.1843, b1 = 0.5098, r2 = 0.3215, g2 = 0.8431, b2 = 1},
				[Srendarr.AURA_TYPE_TOGGLED]	= {r1 = 0.7764,	g1 = 0.6000, b1 = 0.1137, r2 = 0.9725, g2 = 0.8745, b2 = 0.2941},
				[Srendarr.AURA_TYPE_PASSIVE]	= {r1 = 0.4196,	g1 = 0.3803, b1 = 0.2313, r2 = 0.4196, g2 = 0.3803, b2 = 0.2313},
			},
		},
		[5] = {
			base				= {point = TOP, x = 220, y = 88, alpha = 1.0, scale = 0.8},
			style				= Srendarr.AURA_STYLE_ICON,		-- FULL|ICON|MINI
			auraGrowth			= Srendarr.AURA_GROW_RIGHT,		-- UP|DOWN|LEFT|RIGHT|CENTERLEFT|CENTERRIGHT (valid choices vary based on style)
			auraPadding			= 4,
			auraSort			= Srendarr.AURA_SORT_TIMEASC,	-- NAME|TIME|CAST + ASC|DESC
			highlightToggled	= true,							-- shows the same 'toggled on' highlight action buttons do on toggles
			enableTooltips		= false,						-- show mouseover tooltip for auraName in ICON mode
			nameFont			= 'Univers 67',
			nameStyle			= 'soft-shadow-thick',
			nameSize			= 16,
			nameColour			= {0.9, 0.9, 0.9, 1.0},
			timerFont			= 'Univers 67',
			timerStyle			= 'soft-shadow-thick',
			timerSize			= 14,
			timerColour			= {0.9, 0.9, 0.9, 1.0},
			timerLocation		= Srendarr.AURA_TIMERLOC_BELOW,	-- ABOVE|BELOW|OVER|HIDE (valid choices based on style)
			timerHMS			= true,
			barReverse			= true,							-- bar alignment direction (and icon placement in the FULL style)
			barGloss			= true,
			barWidth			= 160,
			barColours = {
				[Srendarr.AURA_TYPE_TIMED]		= {r1 = 0,		g1 = 0.1843, b1 = 0.5098, r2 = 0.3215, g2 = 0.8431, b2 = 1},
				[Srendarr.AURA_TYPE_TOGGLED]	= {r1 = 0.7764,	g1 = 0.6000, b1 = 0.1137, r2 = 0.9725, g2 = 0.8745, b2 = 0.2941},
				[Srendarr.AURA_TYPE_PASSIVE]	= {r1 = 0.4196,	g1 = 0.3803, b1 = 0.2313, r2 = 0.4196, g2 = 0.3803, b2 = 0.2313},
			},
		},
		[6] = {
			base				= {point = TOP, x = -220, y = 88, alpha = 1.0, scale = 0.8},
			style				= Srendarr.AURA_STYLE_ICON,		-- FULL|ICON|MINI
			auraGrowth			= Srendarr.AURA_GROW_LEFT,		-- UP|DOWN|LEFT|RIGHT|CENTERLEFT|CENTERRIGHT (valid choices vary based on style)
			auraPadding			= 4,
			auraSort			= Srendarr.AURA_SORT_TIMEASC,	-- NAME|TIME|CAST + ASC|DESC
			highlightToggled	= true,							-- shows the same 'toggled on' highlight action buttons do on toggles
			enableTooltips		= false,						-- show mouseover tooltip for auraName in ICON mode
			nameFont			= 'Univers 67',
			nameStyle			= 'soft-shadow-thick',
			nameSize			= 16,
			nameColour			= {0.9, 0.9, 0.9, 1.0},
			timerFont			= 'Univers 67',
			timerStyle			= 'soft-shadow-thick',
			timerSize			= 14,
			timerColour			= {0.9, 0.9, 0.9, 1.0},
			timerLocation		= Srendarr.AURA_TIMERLOC_BELOW,	-- ABOVE|BELOW|OVER|HIDE (valid choices based on style)
			timerHMS			= true,
			barReverse			= true,							-- bar alignment direction (and icon placement in the FULL style)
			barGloss			= true,
			barWidth			= 160,
			barColours = {
				[Srendarr.AURA_TYPE_TIMED]		= {r1 = 0,		g1 = 0.1843, b1 = 0.5098, r2 = 0.3215, g2 = 0.8431, b2 = 1},
				[Srendarr.AURA_TYPE_TOGGLED]	= {r1 = 0.7764,	g1 = 0.6000, b1 = 0.1137, r2 = 0.9725, g2 = 0.8745, b2 = 0.2941},
				[Srendarr.AURA_TYPE_PASSIVE]	= {r1 = 0.4196,	g1 = 0.3803, b1 = 0.2313, r2 = 0.4196, g2 = 0.3803, b2 = 0.2313},
			},
		},
		[7] = {
			base				= {point = TOPLEFT, x = 500, y = 0, alpha = 1.0, scale = 1.0},
			style				= Srendarr.AURA_STYLE_ICON,		-- FULL|ICON|MINI
			auraGrowth			= Srendarr.AURA_GROW_LEFT,		-- UP|DOWN|LEFT|RIGHT|CENTERLEFT|CENTERRIGHT (valid choices vary based on style)
			auraPadding			= 4,
			auraSort			= Srendarr.AURA_SORT_TIMEASC,	-- NAME|TIME|CAST + ASC|DESC
			highlightToggled	= true,							-- shows the same 'toggled on' highlight action buttons do on toggles
			enableTooltips		= false,						-- show mouseover tooltip for auraName in ICON mode
			nameFont			= 'Univers 67',
			nameStyle			= 'soft-shadow-thick',
			nameSize			= 16,
			nameColour			= {0.9, 0.9, 0.9, 1.0},
			timerFont			= 'Univers 67',
			timerStyle			= 'soft-shadow-thick',
			timerSize			= 14,
			timerColour			= {0.9, 0.9, 0.9, 1.0},
			timerLocation		= Srendarr.AURA_TIMERLOC_BELOW,	-- ABOVE|BELOW|OVER|HIDE (valid choices based on style)
			timerHMS			= true,
			barReverse			= true,							-- bar alignment direction (and icon placement in the FULL style)
			barGloss			= true,
			barWidth			= 160,
			barColours = {
				[Srendarr.AURA_TYPE_TIMED]		= {r1 = 0,		g1 = 0.1843, b1 = 0.5098, r2 = 0.3215, g2 = 0.8431, b2 = 1},
				[Srendarr.AURA_TYPE_TOGGLED]	= {r1 = 0.7764,	g1 = 0.6000, b1 = 0.1137, r2 = 0.9725, g2 = 0.8745, b2 = 0.2941},
				[Srendarr.AURA_TYPE_PASSIVE]	= {r1 = 0.4196,	g1 = 0.3803, b1 = 0.2313, r2 = 0.4196, g2 = 0.3803, b2 = 0.2313},
			},
		},
		[8] = {
			base				= {point = TOPRIGHT, x = -500, y = 0, alpha = 1.0, scale = 1.0},
			style				= Srendarr.AURA_STYLE_ICON,		-- FULL|ICON|MINI
			auraGrowth			= Srendarr.AURA_GROW_RIGHT,		-- UP|DOWN|LEFT|RIGHT|CENTERLEFT|CENTERRIGHT (valid choices vary based on style)
			auraPadding			= 4,
			auraSort			= Srendarr.AURA_SORT_TIMEASC,	-- NAME|TIME|CAST + ASC|DESC
			highlightToggled	= true,							-- shows the same 'toggled on' highlight action buttons do on toggles
			enableTooltips		= false,						-- show mouseover tooltip for auraName in ICON mode
			nameFont			= 'Univers 67',
			nameStyle			= 'soft-shadow-thick',
			nameSize			= 16,
			nameColour			= {0.9, 0.9, 0.9, 1.0},
			timerFont			= 'Univers 67',
			timerStyle			= 'soft-shadow-thick',
			timerSize			= 14,
			timerColour			= {0.9, 0.9, 0.9, 1.0},
			timerLocation		= Srendarr.AURA_TIMERLOC_BELOW,	-- ABOVE|BELOW|OVER|HIDE (valid choices based on style)
			timerHMS			= true,
			barReverse			= true,							-- bar alignment direction (and icon placement in the FULL style)
			barGloss			= true,
			barWidth			= 160,
			barColours = {
				[Srendarr.AURA_TYPE_TIMED]		= {r1 = 0,		g1 = 0.1843, b1 = 0.5098, r2 = 0.3215, g2 = 0.8431, b2 = 1},
				[Srendarr.AURA_TYPE_TOGGLED]	= {r1 = 0.7764,	g1 = 0.6000, b1 = 0.1137, r2 = 0.9725, g2 = 0.8745, b2 = 0.2941},
				[Srendarr.AURA_TYPE_PASSIVE]	= {r1 = 0.4196,	g1 = 0.3803, b1 = 0.2313, r2 = 0.4196, g2 = 0.3803, b2 = 0.2313},
			},
		},
	}
}

function Srendarr:GetDefaults()
	return defaults
end
