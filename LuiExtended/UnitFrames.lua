------------------
-- Default Unit Frames namespace
LUIE.UnitFrames = {}

-- Performance Enhancement
local UF			= LUIE.UnitFrames
local UI			= LUIE.UI
local CommaValue	= LUIE.CommaValue
local DelayBuffer	= LUIE.DelayBuffer
local ParseLanguageString = LUIE.ParseLanguageString
local strformat = string.format
local strsub = string.sub 
local tinsert = table.insert
local tsort = table.sort
local pairs = pairs

local moduleName	= LUIE.name .. '_UnitFrames'

local classIcons = {
	[0] = '/esoui/art/progression/progression_indexicon_race_down.dds',
	[1] = '/esoui/art/icons/class/class_dragonknight.dds',
	[2] = '/esoui/art/icons/class/class_sorcerer.dds',
	[3] = '/esoui/art/icons/class/class_nightblade.dds',
	[6] = '/esoui/art/icons/class/class_templar.dds',
}

local g_playerAlliance

UF.Enabled = false
UF.D = {
	ShortenNumbers = false,
	RepositionFrames = true,
	DefaultOocTransparency = 75,
	DefaultIncTransparency = 100,
	DefaultFramesPlayer = nil, -- this 3 default settings HAS TO BE nil!!!
	DefaultFramesTarget = nil,
	DefaultFramesGroup = nil,
	Format = "Current + Shield / Max",
	DefaultFontFace = "Univers 67",
	DefaultFontStyle = "soft-shadow-thick",
	DefaultFontSize = 16,
	DefaultTextColour = { 240/255, 235/255, 190/255 },
	TargetShowClass = true,
	TargetShowFriend = true,
	TargetColourByReaction = false,
	CustomFormatOne = "Current + Shield / Max",
	CustomFormatTwo = "Percentage%",
	CustomFontFace = "Fontin SmallCaps",
	CustomFontStyle = "soft-shadow-thin",
	CustomFontBars	= 14,
	CustomFontOther	= 16,
	CustomTexture = "Sand Paper 1",
	CustomEnableRegen = true,
	CustomOocAlpha = 75,
	CustomIncAlpha = 95,
	CustomOocAlphaPower = true,
	CustomOocAlphaTarget = false,
	CustomColourHealth =	{212/255,  38/255,  38/255},
	CustomColourShield =	{   1,    192/255,    0   }, -- .a=0.5 for overlay and .a = 1 for separate
	CustomColourMagicka =	{ 23/255,  77/255, 199/255},
	CustomColourStamina =	{204/255, 163/255,  10/255},
	CustomShieldBarSeparate = false,
	CustomShieldBarHeight = 8,
	CustomShieldBarFull	= false,
	CustomSmoothBar = true,
	CustomFramesPlayer = true,
	CustomFramesTarget = true,
	PlayerBarWidth = 300,
	TargetBarWidth = 300,
	PlayerBarHeightHealth	= 32,
	PlayerBarHeightOther	= 28,
	PlayerBarSpacing		= 0,
	TargetBarHeight			= 36,
	PlayerEnableYourname = true,
	PlayerEnableAltbarMSW = true,
	PlayerEnableAltbarXP = true,
	--PlayerEnableAltbarForceCXP = false, -- Removed as of Removal of Veteran Ranks.
	PlayerChampionColour = true,
	PlayerEnableArmor = true,
	PlayerEnablePower = true,
	TargetEnableClass = false,
	TargetEnableSkull = true,
	CustomFramesGroup	= true,
	GroupDisableDefault	= true,
	GroupExcludePlayer	= false,
	GroupBarWidth	= 250,
	GroupBarHeight	= 36,
	GroupBarSpacing	= 40,
	CustomFramesRaid	= true,
	RaidDisableDefault	= true,
	RaidBarWidth	= 200,
	RaidBarHeight	= 30,
	RaidLayout		= '2 x 12',
	--RaidSort		= true,
	RaidSpacers		= false,
	CustomFramesBosses = true,
	AvaCustFramesTarget = false,
	AvaTargetBarWidth	= 450,
	AvaTargetBarHeight	= 36,
	Target_FontColour				= { 1, 1, 1 },
	Target_FontColour_FriendlyNPC	= { 0, 1, 0 },
	Target_FontColour_FriendlyPlayer= { 0.7, 0.7, 1 },
	Target_FontColour_Hostile		= { 1, 0, 0 },
	Target_FontColour_Neutral		= { 1, 1, 0 },
	Target_Neutral_UseDefaultColour	= true,
	ReticleColour_Interact	= { 1, 1, 0 },		
	ReticleColourByReaction	= false,
}
UF.SV = nil

-- tables to store numerical values
local g_savedHealth = {}
local g_statFull = {}
-- tables to store UI controls
local g_DefaultFrames = {} -- Default Unit Frames are not referenced by external modules
UF.CustomFrames = {} -- Custom Unit Frames on contrary are!
local g_AvaCustFrames = {} -- Another set of custom frames. Currently designed only to provide AvA Player Target reticleover frame
UF.CustomFramesMovingState = false
local g_customLeaderIcon
local g_PendingUpdate = {
	Group		= { flag = false, delay = 200 , name = moduleName .. '_PendingGroupUpdate' },
	VeteranXP	= { flag = false, delay = 5000, name = moduleName .. '_PendingVeteranXP' },
}

-- reference to default UI target unit frame
local g_targetUnitFrame
-- reference to default UI target name label
local g_defaultTargetNameLabel

local g_defaultThreshold = 25
local g_targetThreshold

local g_powerError = {}

-- font to be used on default UI overlay labels
local defaultLabelFont = '/LuiExtended/assets/fontin_sans_sc.otf|15|outline'

-- keet this value in local constant
local g_MaxChampionPoint = GetChampionPointsPlayerProgressionCap()

--[[
 * Default Regen/degen animation used on default group frames and custom frames
 ]]--
local function CreateRegenAnimation(parent, anchors, dims, alpha, degen)
	if #dims ~= 2 then dims = { parent:GetDimensions() } end

	-- create regen control
	local control = UI.Texture(parent, anchors, dims, "/LuiExtended/assets/regen.dds", 2, true)
	if alpha then control:SetAlpha(alpha) end
	if degen then control:SetTextureRotation(3.14159) end
	-- create animation
	local animation, timeline = CreateSimpleAnimation(ANIMATION_TEXTURE, control)
	animation:SetImageData(1, 16)
	animation:SetFramerate(16)
	animation:SetDuration(1000)
	timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
	control.timeline = timeline

	return control
end

--[[
 * Decreased armour overlay visuals
 ]]--
local function CreateDecreasedArmorOverlay( parent, small )
	local control = UI.Control( parent, {CENTER,CENTER}, {512,32}, false )
	control.smallTex = UI.Texture(control, {CENTER,CENTER}, {512,32}, "/EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_decreasedArmor_small.dds", 2, false)
	control.smallTex:SetDrawTier(HIGH)
	--control.smallTexGlow = UI.Texture(control, {CENTER,CENTER}, {512,32}, "/EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_decreasedArmor_small_glow.dds", 2, false)
	--control.smallTexGlow:SetDrawTier(HIGH)
	if not small then
		control.normalTex = UI.Texture(control, {CENTER,CENTER}, {512,32}, "/EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_decreasedArmor_standard.dds", 2, false)
		control.normalTex:SetDrawTier(HIGH)
		--control.normalTexGlow = UI.Texture(control, {CENTER,CENTER}, {512,32}, "/EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_decreasedArmor_standard_glow.dds", 2, false)
		--control.normalTexGlow:SetDrawTier(HIGH)
	end
	
	return control
end

--[[
 * Very simple and crude translation support of common labels
 ]]--
local strDead		= GetString(SI_UNIT_FRAME_STATUS_DEAD)
local strOffline	= GetString(SI_UNIT_FRAME_STATUS_OFFLINE)

--[[
 * Following settings will be used in options menu to define DefaultFrames behaviour
 ]]--
local g_DefaultFramesOptions = {
	[1] = 'Disable',								-- false
	[2] = 'Do nothing (keep default)',				-- nil
	[3] = 'Use Extender (display text overlay)',	-- true
}
function UF.GetDefaultFramesOptions(frame)
	local retval = {}
	for k,v in pairs(g_DefaultFramesOptions) do
		if k ~= 1 or frame == 'Player' or frame == 'Target' then
			tinsert( retval, v )
		end
	end
	return retval
end

function UF.SetDefaultFramesSetting(frame, value)
	local key = 'DefaultFrames' .. tostring(frame)
	if value == g_DefaultFramesOptions[3] then
		UF.SV[key] = true
	elseif value == g_DefaultFramesOptions[1] then
		UF.SV[key] = false
	else
		UF.SV[key] = nil
	end
end

function UF.GetDefaultFramesSetting(frame, default)
	local key = 'DefaultFrames' .. tostring(frame)
	local from = default and UF.D or UF.SV
	local value = from[key]
	local out_key = (value == true) and 3 or (value == false) and 1 or 2
	return g_DefaultFramesOptions[out_key]
end

--[[
 * Used to create default frames extender controls for player and target.
 * Called from UF.Initialize
 ]]--
local function CreateDefaultFrames()

	-- Create text overlay for default unit frames for player and reticleover.
	local default_controls = {}
	
	if UF.SV.DefaultFramesPlayer then
		default_controls.player = {
			[POWERTYPE_HEALTH]	= ZO_PlayerAttributeHealth,
			[POWERTYPE_MAGICKA]	= ZO_PlayerAttributeMagicka,
			[POWERTYPE_STAMINA]	= ZO_PlayerAttributeStamina,
		}
	end
	if UF.SV.DefaultFramesTarget then
		default_controls.reticleover = {
			[POWERTYPE_HEALTH]  = ZO_TargetUnitFramereticleover,
		}

	-- g_DefaultFrames.reticleover should be always present to hold target classIcon and friendIcon
	else
		g_DefaultFrames.reticleover = { ["unitTag"] = "reticleover" }
	end
	-- now loop through `default_controls` table and create actual labels (if any)
	for unitTag,fields in pairs(default_controls) do
		g_DefaultFrames[unitTag] = { ["unitTag"] = unitTag }
		for powerType,parent in pairs(fields) do
			g_DefaultFrames[unitTag][powerType] = { ["label"] = UI.Label( parent, {CENTER,CENTER}, nil, nil, nil, nil, false ), ["colour"] = UF.SV.DefaultTextColour }
		end
	end

	-- reference to target unit frame. this is not an UI control! Used to add custom controls to existing fade-out components table
	g_targetUnitFrame = ZO_UnitFrames_GetUnitFrame("reticleover")

	-- when default Target frame is enabled set the threshold value to change colour of label and add label to default fade list
	if g_DefaultFrames.reticleover[POWERTYPE_HEALTH] then
		g_DefaultFrames.reticleover[POWERTYPE_HEALTH].threshold = g_targetThreshold
		tinsert( g_targetUnitFrame.fadeComponents, g_DefaultFrames.reticleover[POWERTYPE_HEALTH].label )
	end

	-- create classIcon and friendIcon: they should work even when default unit frames extender is disabled
	g_DefaultFrames.reticleover.classIcon = UI.Texture(g_targetUnitFrame.frame, nil, {32,32}, nil, nil, true)
	g_DefaultFrames.reticleover.friendIcon = UI.Texture(g_targetUnitFrame.frame, nil, {32,32}, nil, nil, true)
	g_DefaultFrames.reticleover.friendIcon:SetAnchor(TOPLEFT, ZO_TargetUnitFramereticleoverTextArea, TOPRIGHT, 30, -4)
	-- add those 2 icons to automatic fade list, so fading will be done automatically by game
	tinsert( g_targetUnitFrame.fadeComponents, g_DefaultFrames.reticleover.classIcon )
	tinsert( g_targetUnitFrame.fadeComponents, g_DefaultFrames.reticleover.friendIcon )
	
	-- when default Group frame in use, then create dummy boolean field, so this setting remain constant between /reloadui calls
	if UF.SV.DefaultFramesGroup then
		g_DefaultFrames.SmallGroup = true
	end

	-- Apply fonts
	UF.DefaultFramesApplyFont()

	-- Instead of using Default Unit Frames Extender, the player could wish simply to disable and hide default UI frames
	if UF.SV.DefaultFramesPlayer == false then
		local frames = { 'Health' , 'Stamina' , 'Magicka' , 'MountStamina' , 'Werewolf', 'SiegeHealth' }
		for i = 1 , #frames do
			local frame = _G["ZO_PlayerAttribute"..frames[i]]
			frame:UnregisterForEvent(EVENT_POWER_UPDATE)
			frame:UnregisterForEvent(EVENT_INTERFACE_SETTING_CHANGED)
			frame:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
			EVENT_MANAGER:UnregisterForUpdate("ZO_PlayerAttribute"..frames[i].."FadeUpdate")
			frame:SetHidden(true)
		end
	end

end

--[[
 * Used to create custom frames extender controls for player and target.
 * Called from UF.Initialize
 ]]--
local function CreateCustomFrames()

	-- Create Custom unit frames
	if UF.SV.CustomFramesPlayer then
		-- Player Frame
		local playerTlw = UI.TopLevel( nil, nil )
		playerTlw.customPositionAttr = 'CustomFramesPlayerFramePos'
		playerTlw.preview = LUIE.UI.Backdrop( playerTlw, "fill", nil, nil, nil, true )
		local player = UI.Control( playerTlw, {TOPLEFT,TOPLEFT}, nil, false )
		local topInfo = UI.Control( player, {BOTTOM,TOP,0,-3}, nil, false )
		local botInfo = UI.Control( player, {TOP,BOTTOM,0,2}, nil, false )
		local phb = LUIE.UI.Backdrop( player, {TOP,TOP,0,0}, nil, nil, nil, false )
		local pmb = LUIE.UI.Backdrop( player, nil, nil, nil, nil, false )
		local psb = LUIE.UI.Backdrop( player, nil, nil, nil, nil, false )
		local alt = LUIE.UI.Backdrop( botInfo, {RIGHT,RIGHT}, nil, nil , {0,0,0,1}, false )
		local pli = UI.Texture( topInfo, nil, {20,20}, nil, nil, false )

		-- collect all together
		UF.CustomFrames.player = {
			["unitTag"]		= "player",
			["tlw"]			= playerTlw,
			["control"]		= player,
			[POWERTYPE_HEALTH] = {
				["backdrop"]= phb,
				["labelOne"]= UI.Label( phb, {LEFT,LEFT,5,0}, nil, {0,1}, nil, "xx / yy", false ),
				["labelTwo"]= UI.Label( phb, {RIGHT,RIGHT,-5,0}, nil, {2,1}, nil, "zz%", false ),
				["bar"]		= UI.StatusBar( phb, nil, nil, nil, false ),
				["shield"]	= UI.StatusBar( phb, nil, nil, nil, true ),
			},
			[POWERTYPE_MAGICKA] = {
				["backdrop"]= pmb,
				["labelOne"]= UI.Label( pmb, {LEFT,LEFT,5,0}, nil, {0,1}, nil, "xx / yy", false ),
				["labelTwo"]= UI.Label( pmb, {RIGHT,RIGHT,-5,0}, nil, {2,1}, nil, "zz%", false ),
				["bar"]		= UI.StatusBar( pmb, nil, nil, nil, false ),
			},
			[POWERTYPE_STAMINA] = {
				["backdrop"]= psb,
				["labelOne"]= UI.Label( psb, {LEFT,LEFT,5,0}, nil, {0,1}, nil, "xx / yy", false ),
				["labelTwo"]= UI.Label( psb, {RIGHT,RIGHT,-5,0}, nil, {2,1}, nil, "zz%", false ),
				["bar"]		= UI.StatusBar( psb, nil, nil, nil, false ),
			},
			["alternative"] = {
				["backdrop"]= alt,
				["bar"]		= UI.StatusBar( alt, nil, nil, nil, false ),
				["icon"]	= UI.Texture( alt, {RIGHT,LEFT,-2,0}, {20,20}, nil, nil, false ),
			},
			["topInfo"]		= topInfo,
			["name"]		= UI.Label( topInfo, {BOTTOMLEFT,BOTTOMLEFT}, nil, {0,4}, nil, 'Player Name', false ),
			["levelIcon"]	= pli,
			["level"]		= UI.Label( topInfo, {LEFT,RIGHT,1,0,pli}, nil, {0,1}, nil, 'level', false ),
			["classIcon"]	= UI.Texture( topInfo, {RIGHT,RIGHT,-1,0}, {22,22}, nil, nil, false ),
			["botInfo"]		= botInfo,
			["buffs"]		= UI.Control( playerTlw, nil, nil, false ),
			["debuffs"]		= UI.Control( playerTlw, {BOTTOM,TOP,0,-2,topInfo}, nil, false ),
		}
		UF.CustomFrames.controlledsiege	= { -- placeholder for alternative bar when using siege weapon
			["unitTag"]		= "controlledsiege",
		}
	end

	if UF.SV.CustomFramesTarget then
		-- Target Frame
		local targetTlw = UI.TopLevel( nil, nil )
		targetTlw.customPositionAttr = 'CustomFramesTargetFramePos'
		targetTlw.preview = LUIE.UI.Backdrop( targetTlw, "fill", nil, nil, nil, true )
		targetTlw.previewLabel = UI.Label( targetTlw.preview, {CENTER,CENTER}, nil, nil, 'ZoFontGameMedium', "Target Frame", false )
		local target = UI.Control( targetTlw, {TOPLEFT,TOPLEFT}, nil, false )
		local topInfo = UI.Control( target, {BOTTOM,TOP,0,-3}, nil, false )
		local botInfo = UI.Control( target, {TOP,BOTTOM,0,2}, nil, false )
		local thb = LUIE.UI.Backdrop(target, {TOP,TOP,0,0}, nil, nil, nil, false )
		local tli = UI.Texture( topInfo, nil, {20,20}, nil, nil, false )
		local ari = UI.Texture( botInfo, {RIGHT,RIGHT,-1,0}, {20,20}, nil, nil, false )

		-- collect all together
		UF.CustomFrames.reticleover = {
			["unitTag"]		= "reticleover",
			["tlw"]			= targetTlw,
			["control"]		= target,
			["canHide"]		= true,
			[POWERTYPE_HEALTH] = {
				["backdrop"]= thb,
				["labelOne"]= UI.Label( thb, {LEFT,LEFT,5,0}, nil, {0,1}, nil, "xx / yy", false ),
				["labelTwo"]= UI.Label( thb, {RIGHT,RIGHT,-5,0}, nil, {2,1}, nil, "zz%", false ),
				["bar"]		= UI.StatusBar( thb, nil, nil, nil, false ),
				["shield"]	= UI.StatusBar( thb, nil, nil, nil, true ),
				["threshold"] = g_targetThreshold,
			},
			["topInfo"]		= topInfo,
			["name"]		= UI.Label( topInfo, {BOTTOMLEFT,BOTTOMLEFT}, nil, {0,4}, nil, 'Target Name', false ),
			["levelIcon"]	= tli,
			["level"]		= UI.Label( topInfo, {LEFT,RIGHT,1,0,tli}, nil, {0,1}, nil, 'level', false ),
			["classIcon"]	= UI.Texture( topInfo, {RIGHT,RIGHT,-1,0}, {22,22}, nil, nil, false ),
			["className"]	= UI.Label( topInfo, {BOTTOMRIGHT,TOPRIGHT,-1,-1}, nil, {2,4}, nil, 'Class', false ),
			["friendIcon"]	= UI.Texture( topInfo, {RIGHT,RIGHT,-20,0}, {22,22}, nil, nil, false ),
			["botInfo"]		= botInfo,
			["title"]		= UI.Label( botInfo, {TOPLEFT,TOPLEFT}, nil, {0,3}, nil, '<Title>', false ),
			["avaRankIcon"]	= ari,
			["avaRank"]		= UI.Label( botInfo, {RIGHT,LEFT,-1,0,ari}, nil, {2,3}, nil, 'ava', false ),
			["dead"]		= UI.Label( thb, {LEFT,LEFT,5,0}, nil, {0,1}, nil, "Status", true ),
			["skull"]		= UI.Texture( target, {RIGHT,LEFT,-8,0}, nil, "/LuiExtended/assets/exec_1.dds", nil, true ),
			["buffs"]		= UI.Control( targetTlw, {TOP,BOTTOM,0,2,botInfo}, nil, false ),
			["debuffs"]		= UI.Control( targetTlw, {BOTTOM,TOP,0,-2,topInfo}, nil, false ),
		}
		UF.CustomFrames.reticleover.className:SetDrawLayer( DL_BACKGROUND )
	end

	if UF.SV.AvaCustFramesTarget then
		-- Target Frame
		local targetTlw = UI.TopLevel( nil, nil )
		targetTlw.customPositionAttr = 'AvaCustFramesTargetFramePos'
		targetTlw.preview = LUIE.UI.Backdrop( targetTlw, "fill", nil, nil, nil, true )
		targetTlw.previewLabel = UI.Label( targetTlw.preview, {CENTER,CENTER}, nil, nil, 'ZoFontGameMedium', "PvP Player Target Frame", false )
		local target = UI.Control( targetTlw, {TOPLEFT,TOPLEFT}, nil, false )
		local topInfo = UI.Control( target, {BOTTOM,TOP,0,-3}, nil, false )
		local botInfo = UI.Control( target, {TOP,BOTTOM,0,2}, nil, false )
		local thb = LUIE.UI.Backdrop(target, {TOP,TOP,0,0}, nil, nil, nil, false )
		local cn = UI.Label( botInfo, {TOP,TOP}, nil, {1,3}, nil, 'Class', false )

		-- collect all together
		-- Notice, that we put this table into same UF.CustomFrames table.
		-- This is done to apply formating more easier
		-- Later this table will be referenced from g_AvaCustFrames
		UF.CustomFrames.AvaPlayerTarget = {
			["unitTag"]		= "reticleover",
			["tlw"]			= targetTlw,
			["control"]		= target,
			["canHide"]		= true,
			[POWERTYPE_HEALTH] = {
				["backdrop"]= thb,
				["label"]	= UI.Label( thb, {CENTER,CENTER}, nil, {1,1}, nil, "zz%", false ),
				["labelOne"]= UI.Label( thb, {LEFT,LEFT,5,0}, nil, {0,1}, nil, "xx + ss", false ),
				["labelTwo"]= UI.Label( thb, {RIGHT,RIGHT,-5,0}, nil, {2,1}, nil, "yy", false ),
				["bar"]		= UI.StatusBar( thb, nil, nil, nil, false ),
				["shield"]	= UI.StatusBar( thb, nil, nil, nil, true ),
				["threshold"] = g_targetThreshold,
			},
			["topInfo"]		= topInfo,
			["name"]		= UI.Label( topInfo, {BOTTOM,BOTTOM}, nil, {1,4}, nil, 'Target Name', false ),
			["classIcon"]	= UI.Texture( topInfo, {LEFT,LEFT}, {20,20}, nil, nil, false ),
			["avaRankIcon"]	= UI.Texture( topInfo, {RIGHT,RIGHT}, {20,20}, nil, nil, false ),
			["botInfo"]		= botInfo,
			["className"]	= cn,
			["title"]		= UI.Label( botInfo, {TOP,BOTTOM,0,0,cn}, nil, {1,3}, nil, '<Title>', false ),
			["avaRank"]		= UI.Label( botInfo, {TOPRIGHT,TOPRIGHT}, nil, {2,3}, nil, 'ava', false ),
			["dead"]		= UI.Label( thb, {LEFT,LEFT,5,0}, nil, {0,1}, nil, "Status", true ),
		}
		
		UF.CustomFrames.AvaPlayerTarget[POWERTYPE_HEALTH].label.fmt = "Percentage%"
		UF.CustomFrames.AvaPlayerTarget[POWERTYPE_HEALTH].labelOne.fmt = "Current + Shield"
		UF.CustomFrames.AvaPlayerTarget[POWERTYPE_HEALTH].labelTwo.fmt = "Max"

		-- Put in into table with secondary frames so it can be accessed by other functions in this module
		g_AvaCustFrames.reticleover = UF.CustomFrames.AvaPlayerTarget
	end
	
	-- loop through Small Group members
	if UF.SV.CustomFramesGroup then
		-- Group Frame
		local group = UI.TopLevel( nil, nil )
		group.customPositionAttr = 'CustomFramesGroupFramePos'
		group.preview = LUIE.UI.Backdrop( group, "fill", nil, nil, nil, true )
		group.previewLabel = UI.Label( group.preview, {BOTTOM,TOP,0,-1,group}, nil, nil, 'ZoFontGameMedium', "Small Group", false )

		for i = 1, 4 do
			local unitTag = 'SmallGroup' .. i
			local control = UI.Control( group, nil, nil, false )
			local topInfo = UI.Control( control, {BOTTOMRIGHT,TOPRIGHT,0,-3}, nil, false )
			local ghb = LUIE.UI.Backdrop( control, {TOPLEFT,TOPLEFT}, nil, nil, nil, false )
			local gli = UI.Texture( topInfo, nil, {20,20}, nil, nil, false )

			UF.CustomFrames[unitTag] = {
				["tlw"]			= group,
				["control"]		= control,
				[POWERTYPE_HEALTH] = {
					["backdrop"]= ghb,
					["labelOne"]= UI.Label( ghb, {LEFT,LEFT,5,0}, nil, {0,1}, nil, "xx / yy", false ),
					["labelTwo"]= UI.Label( ghb, {RIGHT,RIGHT,-5,0}, nil, {2,1}, nil, "zz%", false ),
					["bar"]		= UI.StatusBar( ghb, nil, nil, nil, false ),
					["shield"]	= UI.StatusBar( ghb, nil, nil, nil, true ),
				},
				["topInfo"]		= topInfo,
				["name"]		= UI.Label( topInfo, {BOTTOMLEFT,BOTTOMLEFT}, nil, {0,4}, nil, unitTag, false ),
				["levelIcon"]	= gli,
				["level"]		= UI.Label( topInfo, {LEFT,RIGHT,1,0,gli}, nil, {0,1}, nil, 'level', false ),
				["classIcon"]	= UI.Texture( topInfo, {RIGHT,RIGHT,-1,0}, {22,22}, nil, nil, false ),
				["friendIcon"]	= UI.Texture( topInfo, {RIGHT,RIGHT,-20,0}, {22,22}, nil, nil, false ),
				["dead"]		= UI.Label( ghb, {LEFT,LEFT,5,0}, nil, {0,1}, nil, "Status", false ),
			}
			--UF.CustomFrames[unitTag].leader = {RIGHT, LEFT, 0, 0, UF.CustomFrames[unitTag].classIcon, 0}
			UF.CustomFrames[unitTag].leader = {BOTTOMLEFT, TOPLEFT, 0, 0, ghb}
		end
	end

	-- loop through Raid Group members
	if UF.SV.CustomFramesRaid then
		-- Raid Frame
		local raid = UI.TopLevel( nil, nil )
		raid.customPositionAttr = 'CustomFramesRaidFramePos'
		raid.preview = LUIE.UI.Backdrop( raid, {TOPLEFT,TOPLEFT}, nil, nil, nil, true )
		raid.preview2 = LUIE.UI.Backdrop( raid.preview, nil, nil, nil, nil, false )
		raid.previewLabel = UI.Label( raid.preview, {BOTTOM,TOP,0,-1,raid}, nil, nil, 'ZoFontGameMedium', "Raid Group", false )

		for i = 1, 24 do
			local unitTag = 'RaidGroup' .. i
			local control = UI.Control( raid, nil, nil, false )
			local rhb = LUIE.UI.Backdrop( control, "fill", nil, nil, nil, false )

			UF.CustomFrames[unitTag] = {
				["tlw"]			= raid,
				["control"]		= control,
				[POWERTYPE_HEALTH] = {
					["backdrop"]= rhb,
					["bar"]		= UI.StatusBar( rhb, nil, nil, nil, false ),
					["shield"]	= UI.StatusBar( rhb, nil, nil, nil, true ),
				},
				["name"]		= UI.Label( rhb, {LEFT,LEFT,5,0}, nil, {0,1}, nil, unitTag, false ),
				["dead"]		= UI.Label( rhb, {RIGHT,RIGHT,-5,0}, nil, {2,1}, nil, "Status", false ),
				["stealth"]		= UI.Texture( rhb, {RIGHT,RIGHT,-2,0}, {24,24}, nil, 2, false ),
			}
			UF.CustomFrames[unitTag].leader = {RIGHT, RIGHT, -20, 0, UF.CustomFrames[unitTag].control, true}
		end
	end

	-- loop through Bosses
	if UF.SV.CustomFramesBosses then
		-- Bosses Frame
		local bosses = UI.TopLevel( nil, nil )
		bosses.customPositionAttr = 'CustomFramesBossesFramePos'
		bosses.preview = LUIE.UI.Backdrop( bosses, "fill", nil, nil, nil, true )
		bosses.previewLabel = UI.Label( bosses.preview, {BOTTOM,TOP,0,-1,bosses}, nil, nil, 'ZoFontGameMedium', "Bosses Group", false )

		for i = 1, 6 do
			local unitTag = 'boss' .. i
			local control = UI.Control( bosses, nil, nil, false )
			local bhb = LUIE.UI.Backdrop( control, "fill", nil, nil, nil, false )

			UF.CustomFrames[unitTag] = {
				["unitTag"]		= unitTag,
				["tlw"]			= bosses,
				["control"]		= control,
				[POWERTYPE_HEALTH] = {
					["backdrop"]= bhb,
					["label"]	= UI.Label( bhb, {RIGHT,RIGHT,-5,0}, nil, {2,1}, nil, "zz%", false ),
					["bar"]		= UI.StatusBar( bhb, nil, nil, nil, false ),
					["shield"]	= UI.StatusBar( bhb, nil, nil, nil, true ),
					["threshold"] = g_targetThreshold,
				},
				["name"]		= UI.Label( bhb, {LEFT,LEFT,5,0}, nil, {0,1}, nil, unitTag, false ),
			}
			UF.CustomFrames[unitTag][POWERTYPE_HEALTH].label.fmt = "Percentage%"
		end
	end

	-- callback used to hide anchor coords preview label on movement start
	local tlwOnMoveStart = function(self)
		EVENT_MANAGER:RegisterForUpdate( moduleName .. "previewMove", 200, function()
			self.preview.anchorLabel:SetText(strformat("%d, %d", self:GetLeft(), self:GetTop()))
		end)
	end
	-- callback used to save new position of frames
	local tlwOnMoveStop = function(self)
		EVENT_MANAGER:UnregisterForUpdate( moduleName .. "previewMove" )
		UF.SV[self.customPositionAttr] = { self:GetLeft(), self:GetTop() }
	end

	-- common actions for all created frames:
	for _, baseName in pairs( { 'player', 'reticleover', 'SmallGroup', 'RaidGroup', 'boss', 'AvaPlayerTarget' } ) do
		-- set mouse handlers for all created tlws and create anchor coords preview labels
		local unitFrame = UF.CustomFrames[baseName] or UF.CustomFrames[baseName .. '1'] or nil
		if unitFrame ~= nil then
			-- Movement handlers
			unitFrame.tlw:SetHandler( 'OnMoveStart', tlwOnMoveStart )
			unitFrame.tlw:SetHandler( 'OnMoveStop', tlwOnMoveStop )
			
			-- Create Texture and a label for Anchor Preview
			unitFrame.tlw.preview.anchorTexture = UI.Texture( unitFrame.tlw.preview, {TOPLEFT,TOPLEFT}, {16,16}, '/esoui/art/reticle/border_topleft.dds', DL_OVERLAY, false )
			unitFrame.tlw.preview.anchorTexture:SetColor(1, 1, 0, 0.9)
			
			unitFrame.tlw.preview.anchorLabel = UI.Label( unitFrame.tlw.preview, {BOTTOMLEFT,TOPLEFT,0,-1}, nil, {0,2}, 'ZoFontGameSmall', "xxx, yyy", false )
			unitFrame.tlw.preview.anchorLabel:SetColor(1, 1, 0 , 1)
			unitFrame.tlw.preview.anchorLabel:SetDrawLayer(DL_OVERLAY)
			unitFrame.tlw.preview.anchorLabel:SetDrawTier(1)
			unitFrame.tlw.preview.anchorLabelBg = UI.Backdrop( unitFrame.tlw.preview.anchorLabel, "fill", nil, {0,0,0,1}, {0,0,0,1}, false )
			unitFrame.tlw.preview.anchorLabelBg:SetDrawLayer(DL_OVERLAY)
			unitFrame.tlw.preview.anchorLabelBg:SetDrawTier(0)
		end

		-- now we have to anchor all bars to their backdrops
		local shieldOverlay = ( baseName == 'RaidGroup' or baseName == 'boss' ) or not UF.SV.CustomShieldBarSeparate
		local shieldFull = ( baseName == 'RaidGroup' or baseName == 'boss' ) or UF.SV.CustomShieldBarFull
		for i = 0, 24 do
			local unitTag = (i==0) and baseName or ( baseName .. i )
			if UF.CustomFrames[unitTag] then
				for _, powerType in pairs( {POWERTYPE_HEALTH, POWERTYPE_MAGICKA, POWERTYPE_STAMINA, "alternative"} ) do
					local powerBar = UF.CustomFrames[unitTag][powerType]
					if powerBar then
						powerBar.bar:SetAnchor( TOPLEFT, powerBar.backdrop, TOPLEFT, 1, 1 )
						powerBar.bar:SetAnchor( BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1 )

						if powerBar.shield then
							if shieldOverlay then
								powerBar.shield:SetAnchor( TOPLEFT, powerBar.backdrop, shieldFull and TOPLEFT or LEFT, 1, 1 )
								powerBar.shield:SetAnchor( BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1 )
							else
								-- in non-overlay mode we need to create separate backdrop for shield
								powerBar.shieldbackdrop = LUIE.UI.Backdrop( UF.CustomFrames[unitTag].control, nil, nil, nil, nil, true )
								powerBar.shield:SetAnchor( TOPLEFT, powerBar.shieldbackdrop, TOPLEFT, 1, 1 )
								powerBar.shield:SetAnchor( BOTTOMRIGHT, powerBar.shieldbackdrop, BOTTOMRIGHT, -1, -1 )
							end
						end
					end
				end
			end
		end
	end
	
	-- Create Raid leader icon only once, and later move it around different controls
	-- We will create this icon always. Even if group or raid frames are not used
	g_customLeaderIcon = UI.Texture( ZO_UnitFramesGroups, nil, {24,24}, "/esoui/art/icons/guildranks/guild_rankicon_misc01.dds", 2, true )

	-- Create DOT / HOT animations for all attributes bars
	-- we will use this ugly loop over too-many controls, but it will keep things clean and uni-style
	if UF.SV.CustomEnableRegen then
		for _, baseName in pairs( { 'player', 'reticleover', 'SmallGroup', 'RaidGroup', 'boss', 'AvaPlayerTarget' } ) do
			for i = 0, 24 do
				local unitTag = (i==0) and baseName or ( baseName .. i )
				if UF.CustomFrames[unitTag] then
					for _, powerType in pairs( {POWERTYPE_HEALTH, POWERTYPE_MAGICKA, POWERTYPE_STAMINA} ) do
						if UF.CustomFrames[unitTag][powerType] then
							local backdrop = UF.CustomFrames[unitTag][powerType].backdrop
							UF.CustomFrames[unitTag][powerType].regen = CreateRegenAnimation( backdrop, {CENTER,CENTER,0,0}, { backdrop:GetWidth()-20, 14 }, 0.55, false )
							UF.CustomFrames[unitTag][powerType].degen = CreateRegenAnimation( backdrop, {CENTER,CENTER,0,0}, { backdrop:GetWidth()-20, 14 }, 0.55, true )							
						end
					end
				end
			end
		end
	end

	-- Create armor stat change UI for player and target
	if UF.SV.PlayerEnableArmor then
		for _, baseName in pairs( { 'player', 'reticleover', 'boss', 'AvaPlayerTarget' } ) do
			for i = 0, 6 do
				local unitTag = (i==0) and baseName or ( baseName .. i )
				if UF.CustomFrames[unitTag] then
					-- assume that unitTag DO have [POWERTYPE_HEALTH] field
					if UF.CustomFrames[unitTag][POWERTYPE_HEALTH].stat == nil then UF.CustomFrames[unitTag][POWERTYPE_HEALTH].stat = {} end
					local backdrop = UF.CustomFrames[unitTag][POWERTYPE_HEALTH].backdrop
					UF.CustomFrames[unitTag][POWERTYPE_HEALTH].stat[STAT_ARMOR_RATING] = {
						["dec"] = CreateDecreasedArmorOverlay( backdrop, false ),
						["single"] = UI.Texture( backdrop, {CENTER,CENTER,13,0}, {24,24}, "/esoui/art/lfg/lfg_normaldungeon_down.dds", 2, true ),
					}
				end
			end
		end
	end

	-- Create power stat change UI for player and target
	if UF.SV.PlayerEnablePower then
		for _, baseName in pairs( { 'player', 'reticleover', 'boss' } ) do
			for i = 0, 6 do
				local unitTag = (i==0) and baseName or ( baseName .. i )
				if UF.CustomFrames[unitTag] then
					-- assume that unitTag DO have [POWERTYPE_HEALTH] field
					if UF.CustomFrames[unitTag][POWERTYPE_HEALTH].stat == nil then UF.CustomFrames[unitTag][POWERTYPE_HEALTH].stat = {} end
					local backdrop = UF.CustomFrames[unitTag][POWERTYPE_HEALTH].backdrop
					UF.CustomFrames[unitTag][POWERTYPE_HEALTH].stat[STAT_POWER] = {
						["single"] = UI.Texture( backdrop, {CENTER,CENTER,-13,0}, {24,24}, "/esoui/art/lfg/lfg_dps_down.dds", 2, true ),
					}
				end
			end
		end
	end

	-- set proper anchors according to user preferences
	UF.CustomFramesApplyLayoutPlayer()
	UF.CustomFramesApplyLayoutGroup()
	UF.CustomFramesApplyLayoutRaid()
	UF.CustomFramesApplyLayoutBosses()
	-- Set positions of tlws using saved values or default ones
	UF.CustomFramesSetPositions()
	-- apply formatting for labels
	UF.CustomFramesFormatLabels()
	-- Apply bar colours
	UF.CustomFramesApplyColours()
	-- Apply textures
	UF.CustomFramesApplyTexture()
	-- Apply fonts
	UF.CustomFramesApplyFont()

	-- Add this top level window to global controls list, so it can be hidden
	for _, unitTag in pairs( { 'player', 'reticleover', 'SmallGroup1', 'RaidGroup1', 'boss1', 'AvaPlayerTarget' } ) do
		if UF.CustomFrames[unitTag] then
			LUIE.components[ moduleName .. '_CustomFrame_' .. unitTag ] = UF.CustomFrames[unitTag].tlw
		end
	end

end
 
--[[
 * Main entry point to this module
 ]]--
function UF.Initialize( enabled )
	-- load settings
	UF.SV = ZO_SavedVars:NewAccountWide( LUIE.SVName, LUIE.SVVer, 'UnitFrames', UF.D )

	if UF.SV.DefaultOocTransparency < 0 or UF.SV.DefaultOocTransparency > 100 then UF.SV.DefaultOocTransparency = UF.D.DefaultOocTransparency end
	if UF.SV.DefaultIncTransparency < 0 or UF.SV.DefaultIncTransparency > 100 then UF.SV.DefaultIncTransparency = UF.D.DefaultIncTransparency end
	
	-- if User does not want the InfoPanel then exit right here
	if not enabled then return end
	UF.Enabled = true

	-- Even if used do not want to use neither DefaultFrames nor CustomFrames, let us still create tables to hold health and shield values
	-- { powerValue, powerMax, powerEffectiveMax, shield }
	g_savedHealth.player		= {1,1,1,0}
	g_savedHealth.controlledsiege = {1,1,1,0}
	g_savedHealth.reticleover	= {1,1,1,0}
	for i = 1, 24 do
		g_savedHealth['group' .. i] = {1,1,1,0}
	end
	for i = 1, 6 do
		g_savedHealth['boss' .. i] = {1,1,1,0}
	end

	-- query for player alliance for future use
	g_playerAlliance = GetUnitAlliance( 'player' )

	-- For Sorcerer players we will change Target label colour on 20% instead of 25%
	g_targetThreshold = ( GetUnitClassId('player') == 2 ) and 20 or g_defaultThreshold

	CreateDefaultFrames()

	CreateCustomFrames()

	-- reposition frames
	if UF.SV.RepositionFrames then
		-- shift to center magicka and stamina bars
		ZO_PlayerAttributeHealth:ClearAnchors()
		ZO_PlayerAttributeHealth:SetAnchor( BOTTOM, ActionButton5, TOP, 0, -47 )
		ZO_PlayerAttributeMagicka:ClearAnchors()
		ZO_PlayerAttributeMagicka:SetAnchor( TOPRIGHT, ZO_PlayerAttributeHealth, BOTTOM, -1, 2 )
		ZO_PlayerAttributeStamina:ClearAnchors()
		ZO_PlayerAttributeStamina:SetAnchor( TOPLEFT, ZO_PlayerAttributeHealth, BOTTOM, 1, 2 )
		-- shift to the right siege weapon health and ram control
		ZO_PlayerAttributeSiegeHealth:ClearAnchors()
		ZO_PlayerAttributeSiegeHealth:SetAnchor( CENTER, ZO_PlayerAttributeHealth, CENTER, 300, 0 )
		ZO_RAM.control:ClearAnchors()
		ZO_RAM.control:SetAnchor( BOTTOM, ZO_PlayerAttributeHealth, TOP, 300, 0 )
		-- shift a little upwards small group unit frames
		ZO_SmallGroupAnchorFrame:ClearAnchors()
		ZO_SmallGroupAnchorFrame:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, 20, 80 ) -- default is 28,100
	end

	UF.SetDefaultFramesTransparency()

	-- set event handlers
	EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, UF.OnPlayerActivated )
	EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_POWER_UPDATE,     UF.OnPowerUpdate )
	EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED,   UF.OnVisualizationAdded )
	EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, UF.OnVisualizationRemoved )
	EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, UF.OnVisualizationUpdated )
	EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_TARGET_CHANGE, UF.OnTargetChange )
	EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_RETICLE_TARGET_CHANGED, UF.OnReticleTargetChanged )
	EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_DISPOSITION_UPDATE, UF.OnDispositionUpdate )
	EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_UNIT_CREATED, UF.OnUnitCreated )
	EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_LEVEL_UPDATE,        UF.OnLevelUpdate )
	EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_CHAMPION_POINT_UPDATE, UF.OnLevelUpdate )
	
	-- next events make sense only for CustomFrames
	if UF.CustomFrames.player or UF.CustomFrames.reticleover or UF.CustomFrames.SmallGroup1 or UF.CustomFrames.RaidGroup1 or UF.CustomFrames.boss1 then
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_COMBAT_EVENT,			UF.OnCombatEvent )
		EVENT_MANAGER:AddFilterForEvent(moduleName, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, true )
		
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_UNIT_DESTROYED,		UF.OnUnitDestroyed )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_FRIEND_ADDED,			UF.OnUnitDestroyed ) -- this will request group frame redraw
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_FRIEND_REMOVED,		UF.OnUnitDestroyed ) -- this will request group frame redraw
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_PLAYER_COMBAT_STATE,	UF.OnPlayerCombatState )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_WEREWOLF_STATE_CHANGED,	UF.OnWerewolf )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_BEGIN_SIEGE_CONTROL,		UF.OnSiege )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_END_SIEGE_CONTROL,			UF.OnSiege )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_LEAVE_RAM_ESCORT,			UF.OnSiege )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_MOUNTED_STATE_CHANGED,		UF.OnMount )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_EXPERIENCE_UPDATE,			UF.OnXPUpdate )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_CHAMPION_POINT_GAINED,		UF.OnChampionPointGained )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_GROUP_SUPPORT_RANGE_UPDATE,	UF.OnGroupSupportRangeUpdate )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_GROUP_MEMBER_CONNECTED_STATUS,	UF.OnGroupMemberConnectedStatus )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED,	UF.OnDeath )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_LEADER_UPDATE,			UF.OnLeaderUpdate )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_BOSSES_CHANGED,	UF.OnBossesChanged )

		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_STEALTH_STATE_CHANGED,	UF.OnStealthState )
		EVENT_MANAGER:AddFilterForEvent(moduleName, EVENT_STEALTH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group" )

		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_GUILD_SELF_LEFT_GUILD,		UF.InvalidateGuildMemberIndex )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_GUILD_SELF_JOINED_GUILD,	UF.OnGuildSelfJoinedGuild )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_GUILD_MEMBER_ADDED,				UF.OnGuildMemberAdded )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_GUILD_MEMBER_CHARACTER_UPDATED,	UF.OnGuildMemberAdded )
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_GUILD_MEMBER_REMOVED,	UF.OnGuildMemberRemoved )

	end
	
	-- New AvA frames
	if false then
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_CURRENT_CAMPAIGN_CHANGED, UF.OnCurrentCampaignChanged) -- (integer eventCode, integer newCurrentCampaignId)
		EVENT_MANAGER:RegisterForEvent(moduleName, EVENT_CAMPAIGN_EMPEROR_CHANGED, UF.OnCampaignEmperorChanged) -- (integer eventCode, integer campaignId)
	end

	g_defaultTargetNameLabel = ZO_TargetUnitFramereticleoverName

	-- Initialize colouring. This is actually needed when user does NOT want those features
	UF.TargetColourByReaction()
	UF.ReticleColourByReaction()
end

--[[
 * Sets out-of-combat transparency values for default user-frames
 ]]--
function UF.SetDefaultFramesTransparency(min_pct_value, max_pct_value)

	if min_pct_value ~= nil then
		UF.SV.DefaultOocTransparency = min_pct_value
	end

	if max_pct_value ~= nil then
		UF.SV.DefaultIncTransparency = max_pct_value
	end

	local min_value = UF.SV.DefaultOocTransparency / 100
	local max_value = UF.SV.DefaultIncTransparency / 100

	ZO_PlayerAttributeHealth.playerAttributeBarObject.timeline:GetAnimation():SetAlphaValues(min_value, max_value)
	ZO_PlayerAttributeMagicka.playerAttributeBarObject.timeline:GetAnimation():SetAlphaValues(min_value, max_value)
	ZO_PlayerAttributeStamina.playerAttributeBarObject.timeline:GetAnimation():SetAlphaValues(min_value, max_value)

	local inCombat = IsUnitInCombat('player')
	ZO_PlayerAttributeHealth:SetAlpha(inCombat and max_value or min_value)
	ZO_PlayerAttributeStamina:SetAlpha(inCombat and max_value or min_value)
	ZO_PlayerAttributeMagicka:SetAlpha(inCombat and max_value or min_value)

end

--[[
 * Update selection for target name colouring
 ]]--
function UF.TargetColourByReaction(value)
	-- if we have a parameter, save it
	if value ~= nil then
		UF.SV.TargetColourByReaction = value
	end
	-- if this Target name colouring is not required, revert it back to white
	if not value then g_defaultTargetNameLabel:SetColor(1,1,1,1) end
end

--[[
 * Update selection for target name colouring
 ]]--
function UF.ReticleColourByReaction(value)
	if value ~= nil then
		UF.SV.ReticleColourByReaction = value
	end
	-- if this Reticle colouring is not required, revert it back to white
	if not value then ZO_ReticleContainerReticle:SetColor(1, 1, 1) end
end

--[[
 * Update format for labels on CustomFrames
 ]]--
function UF.CustomFramesFormatLabels()
	-- search CustomFrames for attribute bars with correct labels
	for _, baseName in pairs( { 'player', 'reticleover', 'SmallGroup' } ) do
		for i = 0, 4 do
			local unitTag = (i==0) and baseName or ( baseName .. i )
			if UF.CustomFrames[unitTag] then
				for _, powerType in pairs( {POWERTYPE_HEALTH, POWERTYPE_MAGICKA, POWERTYPE_STAMINA} ) do
					if UF.CustomFrames[unitTag][powerType] then
						if UF.CustomFrames[unitTag][powerType].labelOne then UF.CustomFrames[unitTag][powerType].labelOne.fmt = UF.SV.CustomFormatOne end
						if UF.CustomFrames[unitTag][powerType].labelTwo then UF.CustomFrames[unitTag][powerType].labelTwo.fmt = UF.SV.CustomFormatTwo end
					end
				end
			end
		end
	end
end

--[[
 * Runs on the EVENT_PLAYER_ACTIVATED listener.
 * This handler fires every time the player is loaded. Used to set initial values.
 ]]--
function UF.OnPlayerActivated(eventCode)

	-- reload values for player frames
	UF.ReloadValues("player")
	UF.UpdateRegen( "player", STAT_MAGICKA_REGEN_COMBAT, ATTRIBUTE_MAGICKA, POWERTYPE_MAGICKA )
	UF.UpdateRegen( "player", STAT_STAMINA_REGEN_COMBAT, ATTRIBUTE_STAMINA, POWERTYPE_STAMINA )

	-- create UI elements for default group members frames
	if g_DefaultFrames.SmallGroup then
		for i = 1, 24 do
			local unitTag = 'group' .. i
			if DoesUnitExist(unitTag) then
				UF.DefaultFramesCreateUnitGroupControls(unitTag)
			end
		end
	end

	-- if CustomFrames are used then values will be reloaded in following function
	if UF.CustomFrames.SmallGroup1 ~= nil or UF.CustomFrames.RaidGroup1 ~= nil then
		UF.CustomFramesGroupUpdate()

	-- else we need to manually scan and update DefaultFrames
	elseif g_DefaultFrames.SmallGroup then
		for i = 1, 24 do
			local unitTag = 'group' .. i
			if DoesUnitExist(unitTag) then
				UF.ReloadValues(unitTag)
			end
		end
	end
	
	UF.OnReticleTargetChanged(nil)

	UF.OnBossesChanged()

	UF.OnPlayerCombatState(EVENT_PLAYER_COMBAT_STATE, IsUnitInCombat("player") )
	UF.CustomFramesSetupAlternative()
end

--[[
 * Runs on the EVENT_POWER_UPDATE listener.
 * This handler fires every time unit attribute changes.
 ]]--
function UF.OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	-- save Health value for future reference -- do it only for tracked unitTags that were defined on initialization
	if powerType == POWERTYPE_HEALTH and g_savedHealth[unitTag] then
		g_savedHealth[unitTag] = { powerValue, powerMax, powerEffectiveMax, g_savedHealth[unitTag][4] or 0 }			
	end

	--[[ DEBUG code. Normally should be commented out because it is redundant
	if g_DefaultFrames[unitTag] and g_DefaultFrames[unitTag].unitTag ~= unitTag then
		CHAT_SYSTEM:AddMessage('LUIE_DBG DF: ' .. tostring(g_DefaultFrames[unitTag].unitTag) .. ' ~= ' .. tostring(unitTag) )
	end
	if UF.CustomFrames[unitTag] and UF.CustomFrames[unitTag].unitTag ~= unitTag then
		CHAT_SYSTEM:AddMessage('LUIE_DBG CF: ' .. tostring(UF.CustomFrames[unitTag].unitTag) .. ' ~= ' .. tostring(unitTag) )
	end
	if g_AvaCustFrames[unitTag] and g_AvaCustFrames[unitTag].unitTag ~= unitTag then
		CHAT_SYSTEM:AddMessage('LUIE_DBG AF: ' .. tostring(g_AvaCustFrames[unitTag].unitTag) .. ' ~= ' .. tostring(unitTag) )
	end --]]

	-- update frames ( if we manually not forbade it )
	if g_DefaultFrames[unitTag] then UF.UpdateAttribute( g_DefaultFrames[unitTag][powerType], powerValue, powerEffectiveMax, (powerType == POWERTYPE_HEALTH) and g_savedHealth[unitTag][4] or nil, eventCode == nil ) end
	if UF.CustomFrames[unitTag] then UF.UpdateAttribute( UF.CustomFrames[unitTag][powerType], powerValue, powerEffectiveMax, (powerType == POWERTYPE_HEALTH) and g_savedHealth[unitTag][4] or nil, eventCode == nil ) end
	if g_AvaCustFrames[unitTag] then UF.UpdateAttribute( g_AvaCustFrames[unitTag][powerType], powerValue, powerEffectiveMax, (powerType == POWERTYPE_HEALTH) and g_savedHealth[unitTag][4] or nil, eventCode == nil ) end

	-- record state of power loss to change transparency of player frame
	if unitTag == 'player' and ( powerType == POWERTYPE_HEALTH or powerType == POWERTYPE_MAGICKA or powerType == POWERTYPE_STAMINA or powerType == POWERTYPE_MOUNT_STAMINA ) then
		g_statFull[powerType] = ( powerValue == powerEffectiveMax )
		UF.CustomFramesApplyInCombat()
	end

	-- if players powerValue is zero, issue new blinking event on Custom Frames
	if unitTag == 'player' and powerValue == 0 then
		-- Sometimes when werewolf power goes to zero the EVENT_WEREWOLF_STATE_CHANGED is not always issued. Thus try to track it manually.
		if powerType == POWERTYPE_WEREWOLF then
			if UF.CustomFrames.player and UF.CustomFrames.player[POWERTYPE_WEREWOLF] then
				UF.OnWerewolf( eventCode, false )
			end
		
		-- otherwise - we need to manually trugger blinking of powerbar
		else
			UF.OnCombatEvent( eventCode, nil, true, nil, nil, nil, nil, COMBAT_UNIT_TYPE_PLAYER, nil, COMBAT_UNIT_TYPE_PLAYER, 0, powerType, nil, false )
		end
	end

	-- display skull icon for alive execute-level targets
	if unitTag == 'reticleover' and
		powerType == POWERTYPE_HEALTH and
		UF.CustomFrames.reticleover and
		UF.CustomFrames.reticleover.hostile then

		-- hide skull when target dies
		if powerValue == 0 then
			UF.CustomFrames.reticleover.skull:SetHidden( true )
		-- but show for _below_threshold_ level targets
		elseif 100*powerValue/powerEffectiveMax < UF.CustomFrames.reticleover[POWERTYPE_HEALTH].threshold then
			UF.CustomFrames.reticleover.skull:SetHidden( false )
		end
	end
end

 --[[
 * Runs on the EVENT_UNIT_CREATED listener.
 * Used to create DefaultFrames UI controls and request delayed CustomFrames group frame update
 ]]--
function UF.OnUnitCreated(eventCode, unitTag)
	--CHAT_SYSTEM:AddMessage( strformat('[%s] OnUnitCreated: %s (%s)', GetTimeString(), unitTag, GetUnitName(unitTag)) )

	-- create on-fly UI controls for default UI group member and reread his values
	if g_DefaultFrames.SmallGroup then
		UF.DefaultFramesCreateUnitGroupControls(unitTag)
	end

	-- if CustomFrames are used then values for unitTag will be reloaded in delayed full group update
	if UF.CustomFrames.SmallGroup1 ~= nil or UF.CustomFrames.RaidGroup1 ~= nil then

		-- make sure we do not try to update bars on this unitTag before full group update is complete
		if "group" == strsub(unitTag, 0, 5) then
			UF.CustomFrames[unitTag] = nil
		end

		-- we should avoid calling full update on CustomFrames too often
		if not g_PendingUpdate.Group.flag then
			g_PendingUpdate.Group.flag = true
			EVENT_MANAGER:RegisterForUpdate(g_PendingUpdate.Group.name, g_PendingUpdate.Group.delay, UF.CustomFramesGroupUpdate )
		end

	-- else we need to manually update this unitTag in g_DefaultFrames
	elseif g_DefaultFrames.SmallGroup then
		UF.ReloadValues(unitTag)
	end
end

--[[
 * Runs on the EVENT_UNIT_DESTROYED listener.
 * Used to request delayed CustomFrames group frame update
 ]]--
function UF.OnUnitDestroyed(eventCode, unitTag)
	--CHAT_SYSTEM:AddMessage( strformat('[%s] OnUnitDestroyed: %s (%s)', GetTimeString(), unitTag, GetUnitName(unitTag)) )

	-- make sure we do not try to update bars on this unitTag before full group update is complete
	if "group" == strsub(unitTag, 0, 5) then
		UF.CustomFrames[unitTag] = nil
	end

	-- we should avoid calling full update on CustomFrames too often
	if not g_PendingUpdate.Group.flag then
		g_PendingUpdate.Group.flag = true
		EVENT_MANAGER:RegisterForUpdate(g_PendingUpdate.Group.name, g_PendingUpdate.Group.delay, UF.CustomFramesGroupUpdate )
	end
end

--[[
 * Creates default group unit UI controls on-fly
 ]]--
function UF.DefaultFramesCreateUnitGroupControls(unitTag)
	-- first make preparation for "groupN" unitTag labels
	if g_DefaultFrames[unitTag] == nil then -- if unitTag is already in our list, then skip this
		if "group" == strsub(unitTag, 0, 5) then -- if it is really a group member unitTag
			local i = strsub(unitTag, 6)
			if _G['ZO_GroupUnitFramegroup' .. i] then
				local parentBar		= _G['ZO_GroupUnitFramegroup' .. i .. 'Hp']
				local parentName	= _G['ZO_GroupUnitFramegroup' .. i .. 'Name']
				-- prepare dimension of regen bar
				local width, height = parentBar:GetDimensions()
				-- populate UI elements
				g_DefaultFrames[unitTag] = {
					["unitTag"] = unitTag,
					[POWERTYPE_HEALTH] = {
						label = UI.Label( parentBar, {TOP,BOTTOM}, nil, nil, nil, nil, false ),
						colour = UF.SV.DefaultTextColour,
						regen = CreateRegenAnimation( parentBar, {LEFT,LEFT,0,0}, {width-height,height*1.3}, nil, false ),
						degen = CreateRegenAnimation( parentBar, {LEFT,LEFT,0,0}, {width-height,height*1.3}, nil, true ), 
						shield = UI.StatusBar( parentBar, {BOTTOM,BOTTOM,0,0}, {width-height,height}, {1,0.75,0,0.5}, true ),
					},
					["classIcon"]	= UI.Texture( parentName, {RIGHT,LEFT,-4,2},  {24,24}, nil, nil, true ),
					["friendIcon"]	= UI.Texture( parentName, {RIGHT,LEFT,-4,24}, {24,24}, nil, nil, true ),
				}
				-- apply selected font
				UF.DefaultFramesApplyFont(unitTag)
			end
		end
	end
end

--[[
 * Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED listener.
 ]]--
function UF.OnVisualizationAdded(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
	if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
		UF.UpdateShield(unitTag, value, maxValue)
	elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER then
		UF.UpdateRegen(unitTag, statType, attributeType, powerType )
	elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT then
		UF.UpdateStat(unitTag, statType, attributeType, powerType )
	end
end

--[[
 * Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED listener.
 ]]--
function UF.OnVisualizationRemoved(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
	if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
		UF.UpdateShield(unitTag, 0, maxValue)
	elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER then
		UF.UpdateRegen(unitTag, statType, attributeType, powerType )
	elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT then
		UF.UpdateStat(unitTag, statType, attributeType, powerType )
	end
end

--[[
 * Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED listener.
 ]]--
function UF.OnVisualizationUpdated(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
	if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
		UF.UpdateShield(unitTag, newValue, newMaxValue)
	elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT then
		UF.UpdateStat(unitTag, statType, attributeType, powerType )
	end
end

 --[[
 * Runs on the EVENT_TARGET_CHANGE listener.
 * This handler fires every time the someone target changes.
 * This function is needed in case the player teleports via Way Shrine
 ]]--
function UF.OnTargetChange(eventCode, unitTag)
	if unitTag ~= "player" then return end
	UF.OnReticleTargetChanged(eventCode)
end

 --[[
 * Runs on the EVENT_RETICLE_TARGET_CHANGED listener.
 * This handler fires every time the player's reticle target changes.
 * Used to read initial values of target's health and shield.
 ]]--
function UF.OnReticleTargetChanged(eventCode)
	if DoesUnitExist('reticleover') then

		UF.ReloadValues( 'reticleover' )

		local isWithinRange = IsUnitInGroupSupportRange('reticleover')

		-- Now select appropriate custom colour to target name and (possibly) reticle
		local colour, reticle_colour
		local interactableCheck = false
		local reactionType = GetUnitReaction('reticleover')
		local attackable = IsUnitAttackable('reticleover')
		-- select colour accordingly to reactionType, attackable and interactable
		if reactionType == UNIT_REACTION_HOSTILE then
			colour = UF.SV.Target_FontColour_Hostile
			reticle_colour = attackable and UF.SV.Target_FontColour_Hostile or UF.SV.Target_FontColour
			interactableCheck = true
		elseif reactionType == UNIT_REACTION_PLAYER_ALLY then
			colour			= UF.SV.Target_FontColour_FriendlyPlayer
			reticle_colour	= UF.SV.Target_FontColour_FriendlyPlayer
		elseif attackable and reactionType ~= UNIT_REACTION_HOSTILE then -- those are neutral targets that can become hostile on attack
			colour			= UF.SV.Target_FontColour
			reticle_colour	= colour
		else
			-- rest cases are ally/friendly/npc, and with possibly interactable
			colour = ( reactionType == UNIT_REACTION_FRIENDLY or reactionType == UNIT_REACTION_NPC_ALLY ) and UF.SV.Target_FontColour_FriendlyNPC or UF.SV.Target_FontColour
			reticle_colour = colour
			interactableCheck = true
		end

		-- here we need to check if interaction is possible, and then rewrite reticle_colour variable
		if interactableCheck then 
			local interactableAction = GetGameCameraInteractableActionInfo()
			-- action, interactableName, interactionBlocked, isOwned, additionalInfo, context
			if interactableAction ~= nil then
				reticle_colour = UF.SV.ReticleColour_Interact
			end
		end

		-- is current target Critter? In Update 6 they all have 9 health
		local isCritter = ( g_savedHealth.reticleover[3] <= 9 )

		-- Hide custom label on Default Frames for critters.
		if g_DefaultFrames.reticleover[POWERTYPE_HEALTH] then
			g_DefaultFrames.reticleover[POWERTYPE_HEALTH].label:SetHidden( isCritter )
		end

		-- Update colour of default target if requested
		if UF.SV.TargetColourByReaction then g_defaultTargetNameLabel:SetColor( colour[1], colour[2], colour[3], isWithinRange and 1 or 0.5 ) end
		if UF.SV.ReticleColourByReaction then ZO_ReticleContainerReticle:SetColor(reticle_colour[1], reticle_colour[2], reticle_colour[3] ) end

		-- and colour of custom target name always. Also change 'labelOne' for critters
		if UF.CustomFrames.reticleover then
			UF.CustomFrames.reticleover.hostile = ( reactionType == UNIT_REACTION_HOSTILE ) and UF.SV.TargetEnableSkull
			UF.CustomFrames.reticleover.skull:SetHidden( not UF.CustomFrames.reticleover.hostile or ( g_savedHealth.reticleover[1] == 0 ) or ( 100*g_savedHealth.reticleover[1]/g_savedHealth.reticleover[3] > UF.CustomFrames.reticleover[POWERTYPE_HEALTH].threshold ) )
			UF.CustomFrames.reticleover.name:SetColor( colour[1], colour[2], colour[3] )
			UF.CustomFrames.reticleover.className:SetColor( colour[1], colour[2], colour[3] )
			if isCritter then
				UF.CustomFrames.reticleover[POWERTYPE_HEALTH].labelOne:SetText( "-critter-" )
			end
			UF.CustomFrames.reticleover[POWERTYPE_HEALTH].labelTwo:SetHidden( isCritter or not UF.CustomFrames.reticleover.dead:IsHidden() )
			-- finally show custom target frame
			UF.CustomFrames.reticleover.control:SetHidden( false )
		end
		-- unhide second target frame only for player enemies
		if UF.CustomFrames.AvaPlayerTarget then
			UF.CustomFrames.AvaPlayerTarget.control:SetHidden( not ( UF.CustomFrames.AvaPlayerTarget.isPlayer and (reactionType == UNIT_REACTION_HOSTILE) and not IsUnitDead('reticleover') ) )
		end

		-- Update position of default target class icon
		if UF.SV.TargetShowClass and g_DefaultFrames.reticleover.isPlayer then
			g_DefaultFrames.reticleover.classIcon:ClearAnchors()
			g_DefaultFrames.reticleover.classIcon:SetAnchor(TOPRIGHT, ZO_TargetUnitFramereticleoverTextArea, TOPLEFT, g_DefaultFrames.reticleover.isChampion and (-32) or (-2), -4)
		else
			g_DefaultFrames.reticleover.classIcon:SetHidden(true)
		end
		-- Update position of default target ignore/friend/guild icon
		--[[ 2015-09-13: It seams avaRank 0 also has an icon, so we do not need to reposition our custom friend icon anymore
		if UF.SV.TargetShowFriend and g_DefaultFrames.reticleover.isPlayer then
			g_DefaultFrames.reticleover.friendIcon:ClearAnchors()
			g_DefaultFrames.reticleover.friendIcon:SetAnchor(TOPLEFT, ZO_TargetUnitFramereticleoverTextArea, TOPRIGHT, ( g_DefaultFrames.reticleover.avaRankValue > 0 ) and 30 or 2, -4)
		else
			g_DefaultFrames.reticleover.friendIcon:SetHidden(true)
		end
		]]--
		-- Instead just make sure it is hidden
		if not UF.SV.TargetShowFriend or not g_DefaultFrames.reticleover.isPlayer then
			g_DefaultFrames.reticleover.friendIcon:SetHidden(true)
		end

	-- Target is invalid: reset stored values to defaults
	else
		g_savedHealth.reticleover = {1,1,1,0}
		if g_DefaultFrames.reticleover[POWERTYPE_HEALTH] then
			g_DefaultFrames.reticleover[POWERTYPE_HEALTH].label:SetHidden(true)
		end
		g_DefaultFrames.reticleover.classIcon:SetHidden(true)
		g_DefaultFrames.reticleover.friendIcon:SetHidden(true)

		-- Hide target frame bars control, LTE will clear buffs and remove then itself, SCB should continue to display ground buffs
		if UF.CustomFrames.reticleover then
			UF.CustomFrames.reticleover.hostile = false
			UF.CustomFrames.reticleover.skull:SetHidden( true )
			UF.CustomFrames.reticleover.control:SetHidden( true ) --UF.CustomFrames.reticleover.canHide )
		end
		-- Hide second target frame
		if UF.CustomFrames.AvaPlayerTarget then
			UF.CustomFrames.AvaPlayerTarget.control:SetHidden( true ) --UF.CustomFrames.AvaPlayerTarget.canHide )
		end

		-- Revert back the colour of reticle to white
		if UF.SV.ReticleColourByReaction then ZO_ReticleContainerReticle:SetColor(1, 1, 1) end

	end

	-- finally if user does not want to have default target frame we have to hide it here all the time
	if not g_DefaultFrames.reticleover[POWERTYPE_HEALTH] and UF.SV.DefaultFramesTarget == false then
		ZO_TargetUnitFramereticleover:SetHidden( true )
	end
end

 --[[ 
 * Runs on the EVENT_DISPOSITION_UPDATE listener.
 * Used to reread parameters of the target
 ]]--
function UF.OnDispositionUpdate(eventCode, unitTag)
	if unitTag == 'reticleover' then
		UF.OnReticleTargetChanged(eventCode)
	end
end

--[[
 * Used to query initial values and display them in corresponding control
 ]]--
function UF.ReloadValues( unitTag )

	-- build list of powerTypes this unitTag has in both DefaultFrames and CustomFrames
	local powerTypes = {}
	if g_DefaultFrames[unitTag] then for powerType,_ in pairs( g_DefaultFrames[unitTag] ) do if type(powerType) == "number" then powerTypes[powerType] = true end end end
	if UF.CustomFrames[unitTag] then for powerType,_ in pairs( UF.CustomFrames[unitTag] ) do if type(powerType) == "number" then powerTypes[powerType] = true end end end
	if g_AvaCustFrames[unitTag] then for powerType,_ in pairs( g_AvaCustFrames[unitTag] ) do if type(powerType) == "number" then powerTypes[powerType] = true end end end

	-- For all attributes query its value and force updating
	for powerType,_ in pairs(powerTypes) do
		UF.OnPowerUpdate(nil, unitTag, nil, powerType, GetUnitPower(unitTag, powerType))
	end

	-- update shield value on controls; this will also update health attribute value, again.
	local shield, _ = GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH)
	UF.UpdateShield( unitTag, shield or 0, nil )

	-- now we need to update Name labels, classIcon
	UF.UpdateStaticControls( g_DefaultFrames[unitTag] )
	UF.UpdateStaticControls( UF.CustomFrames[unitTag] )
	UF.UpdateStaticControls( g_AvaCustFrames[unitTag] )

	-- get regen/degen values
	UF.UpdateRegen(unitTag, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH)
	
	-- get initial stats
	UF.UpdateStat(unitTag, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH)
	UF.UpdateStat(unitTag, STAT_POWER,        ATTRIBUTE_HEALTH, POWERTYPE_HEALTH)
	
	if unitTag == 'player' then
		g_statFull[POWERTYPE_HEALTH] = ( g_savedHealth.player[1] == g_savedHealth.player[3] )
		UF.CustomFramesApplyInCombat()
	end
end

--[[
 * Helper tables for next function
 ]]--
local HIDE_LEVEL_REACTIONS = {
    [UNIT_REACTION_FRIENDLY] = true,
    [UNIT_REACTION_NPC_ALLY] = true,
}
local HIDE_LEVEL_TYPES = {
    [UNIT_TYPE_SIEGEWEAPON] = true,
    [UNIT_TYPE_INTERACTFIXTURE] = true,
    [UNIT_TYPE_INTERACTOBJ] = true,
    [UNIT_TYPE_SIMPLEINTERACTFIXTURE] = true,
    [UNIT_TYPE_SIMPLEINTERACTOBJ] = true,
}
--[[
 * Updates text labels, classIcon, etc
 ]]--
function UF.UpdateStaticControls( unitFrame )
	if unitFrame == nil then return end

	unitFrame.isPlayer	= IsUnitPlayer( unitFrame.unitTag )
	unitFrame.isChampion = IsUnitChampion( unitFrame.unitTag )
	unitFrame.isLevelCap = ( GetUnitChampionPoints( unitFrame.unitTag ) == g_MaxChampionPoint  )
	unitFrame.avaRankValue = GetUnitAvARank( unitFrame.unitTag )

	-- first update classIcon and friendIcon, so then we can set maximal length of name label

	-- if unitFrame has unit classIcon control
	if unitFrame.classIcon ~= nil then
		local unitDifficulty = GetUnitDifficulty( unitFrame.unitTag )
		local classIcon = classIcons[GetUnitClassId(unitFrame.unitTag)]
		local showClass = ( unitFrame.isPlayer and classIcon ~= nil ) or ( unitDifficulty > 1 )
		if unitFrame.isPlayer then
			unitFrame.classIcon:SetTexture(classIcon)
		elseif unitDifficulty == 2 then
			unitFrame.classIcon:SetTexture("/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_champion.dds")
		elseif unitDifficulty >= 3 then
			unitFrame.classIcon:SetTexture("/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_champion.dds")
		end
		if unitFrame.unitTag == 'player' then
			unitFrame.classIcon:SetHidden( not UF.SV.PlayerEnableYourname )
		else
			unitFrame.classIcon:SetHidden( not showClass )
		end
	end
	-- unitFrame frame also have a text label for class name: right now only target
	if unitFrame.className then
		local className = GetUnitClass( unitFrame.unitTag )
		local showClass = unitFrame.isPlayer and className ~= nil and UF.SV.TargetEnableClass
		if showClass then
			unitFrame.className:SetText( className:gsub("%^%a+","") )
		end
		-- this condition is somehow extra, but let keep it to be in consistency with all others
		if unitFrame.unitTag == 'player' then
			unitFrame.className:SetHidden( not UF.SV.PlayerEnableYourname )
		else
			unitFrame.className:SetHidden( not showClass )
		end
	end

	-- if unitFrame has unit classIcon control
	if unitFrame.friendIcon ~= nil then
		local isIgnored = unitFrame.isPlayer and IsUnitIgnored( unitFrame.unitTag )
		local isFriend = unitFrame.isPlayer and IsUnitFriend( unitFrame.unitTag )
		local isGuild = unitFrame.isPlayer and (not isFriend) and (not isIgnored) and UF.GetGuildDisplayNameInfo( GetUnitDisplayName( unitFrame.unitTag ) )
		if isIgnored or isFriend or isGuild then
			unitFrame.friendIcon:SetTexture( isIgnored and "/esoui/art/contacts/tabicon_ignored_down.dds" or isFriend and "/esoui/art/campaign/campaignbrowser_friends.dds" or "/esoui/art/campaign/campaignbrowser_guild.dds" )
			unitFrame.friendIcon:SetHidden(false)
		else
			unitFrame.friendIcon:SetHidden(true)
		end
	end

	-- if unitFrame has unit name label control
	if unitFrame.name ~= nil then
		-- update max width of label
		if unitFrame.name:GetParent() == unitFrame.topInfo then
			local width = unitFrame.topInfo:GetWidth()
			if unitFrame.classIcon and not unitFrame.classIcon:IsHidden() then
				width = width - unitFrame.classIcon:GetWidth()
			end
			if unitFrame.friendIcon and not unitFrame.friendIcon:IsHidden() then
				width = width - unitFrame.friendIcon:GetWidth() * 5/6
			end
			if unitFrame.level then
				width = width - 2.3 * unitFrame.levelIcon:GetWidth()
			end			
			unitFrame.name:SetWidth(width)
		end
		unitFrame.name:SetText( GetUnitName( unitFrame.unitTag ) )
	end
	
	-- if unitFrame has level label control
	if unitFrame.level ~= nil then
		--show level for players and non-friendly NPCs
		local showLevel = unitFrame.isPlayer or not ( IsUnitInvulnerableGuard( unitFrame.unitTag ) or HIDE_LEVEL_TYPES[GetUnitType( unitFrame.unitTag )] or HIDE_LEVEL_REACTIONS[GetUnitReaction( unitFrame.unitTag )] )
		if showLevel then
			unitFrame.levelIcon:ClearAnchors()
			unitFrame.levelIcon:SetAnchor( LEFT, unitFrame.topInfo, LEFT, unitFrame.name:GetTextWidth()+1, 0 )
			unitFrame.levelIcon:SetTexture( unitFrame.isChampion and "/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_champion.dds" or "/esoui/art/lfg/lfg_normaldungeon_down.dds" )
			-- level label should be already anchored
			unitFrame.level:SetText( tostring( unitFrame.isChampion and GetUnitChampionPoints( unitFrame.unitTag ) or GetUnitLevel( unitFrame.unitTag ) ) )
		end
		if unitFrame.unitTag == 'player' then
			unitFrame.levelIcon:SetHidden( not UF.SV.PlayerEnableYourname )
			unitFrame.level:SetHidden( not UF.SV.PlayerEnableYourname )
		else
			unitFrame.levelIcon:SetHidden( not showLevel )
			unitFrame.level:SetHidden( not showLevel )
		end
	end

	-- if unitFrame has unit title label control
	if unitFrame.title ~= nil then
		local title = GetUnitCaption(unitFrame.unitTag)
		if unitFrame.isPlayer then
			title = GetUnitTitle(unitFrame.unitTag)
			title = (title ~= '') and title or GetAvARankName( GetUnitGender(unitFrame.unitTag) , unitFrame.avaRankValue )
		end
		title = title or ''
		unitFrame.title:SetText( title:gsub("%^%a+","") )
	end

	-- if unitFrame has unit AVA rank control
	if unitFrame.avaRank ~= nil then
		if unitFrame.isPlayer then
			if unitFrame.avaRankValue > 0 then
				unitFrame.avaRank:SetText( tostring( unitFrame.avaRankValue ) )
				unitFrame.avaRank:SetHidden(false)
			else
				unitFrame.avaRank:SetHidden(true)
			end
			unitFrame.avaRankIcon:SetTexture( GetAvARankIcon( unitFrame.avaRankValue ) )
			unitFrame.avaRankIcon:SetHidden(false)
			local alliance = GetUnitAlliance( unitFrame.unitTag )
			local colour
			if g_playerAlliance == alliance then
				colour = { r=1, g=1, b=1 }
			else
				colour = GetAllianceColor( alliance )
			end
			unitFrame.avaRankIcon:SetColor( colour.r, colour.g, colour.b )
		else
			unitFrame.avaRank:SetHidden(true)
			unitFrame.avaRankIcon:SetHidden(true)
		end
	end

	-- if unitFrame has also stealth icon, then query for current state
	if unitFrame.stealth ~= nil then
		UF.OnStealthState( EVENT_STEALTH_STATE_CHANGED, unitFrame.unitTag, GetUnitStealthState( unitFrame.unitTag ) )
	end

	-- if unitFrame has dead/offline indicator, then query its state and act accordingly
	if unitFrame.dead ~= nil then
		if not IsUnitOnline( unitFrame.unitTag ) then
			UF.OnGroupMemberConnectedStatus( nil, unitFrame.unitTag, false )
		elseif IsUnitDead( unitFrame.unitTag ) then
			UF.OnDeath( nil, unitFrame.unitTag, true )
		else
			UF.CustomFramesSetDeadLabel( unitFrame, nil )
		end
		
	end

	-- finally set transparency for group frames that has .control field
	if "group" == strsub(unitFrame.unitTag, 0, 5) and unitFrame.control then
		unitFrame.control:SetAlpha( IsUnitInGroupSupportRange(unitFrame.unitTag) and 1 or 0.5 )
	end
end

 --[[
 * Updates single attribute.
 * Usually called from OnPowerUpdate handler.
 --]]
function UF.UpdateAttribute( attributeFrame, powerValue, powerEffectiveMax, shield, forceInit )
	if attributeFrame == nil then return end

	local pct = math.floor(100*powerValue/powerEffectiveMax)

	-- update text values for this attribute. can be on up to 3 different labels
	local shield = ( shield and shield > 0 ) and shield or nil

	for _, label in pairs( { "label", "labelOne", "labelTwo" } ) do
		if attributeFrame[label] ~= nil then
			-- format specific to selected label
			local fmt = tostring( attributeFrame[label].fmt or UF.SV.Format )
			local str = fmt:gsub("Percentage", tostring(pct) )
				:gsub("Max", CommaValue(powerEffectiveMax, UF.SV.ShortenNumbers))
				:gsub("Current", CommaValue(powerValue, UF.SV.ShortenNumbers))
				:gsub( "+ Shield", shield and ("+ "..CommaValue(shield, UF.SV.ShortenNumbers)) or "" )
				:gsub("Nothing", "")

			-- change text
			attributeFrame[label]:SetText( str )

			-- and colour it RED if attribute value is lower then threshold
			attributeFrame[label]:SetColor( unpack( ( pct < ( attributeFrame.threshold or g_defaultThreshold ) ) and {1,0.25,0.38} or attributeFrame.colour or {1,1,1} ) )
		end
	end

	-- if attribute has also custom statusBar, update its value
	if attributeFrame.bar ~= nil then
		if UF.SV.CustomSmoothBar then
			-- make it twice faster then default UI ones: last argument .085
			ZO_StatusBar_SmoothTransition(attributeFrame.bar, powerValue, powerEffectiveMax, forceInit, nil, 250)
		else
			attributeFrame.bar:SetMinMax(0, powerEffectiveMax)
			attributeFrame.bar:SetValue( powerValue )
		end
	end
end

--[[
 * Updates shield value for given unit.
 * Called from EVENT_UNIT_ATTRIBUTE_VISUAL_* listeners.
 --]]
function UF.UpdateShield( unitTag, value, maxValue )
	if g_savedHealth[unitTag] == nil then
		--d( 'LUIE DEBUG: Stored health is nil: ', unitTag )
		return
	end

	g_savedHealth[unitTag][4] = value
	
	local healthValue, _ , healthEffectiveMax, _ = unpack(g_savedHealth[unitTag])
	-- update frames
	if g_DefaultFrames[unitTag] then
		UF.UpdateAttribute( g_DefaultFrames[unitTag][POWERTYPE_HEALTH], healthValue, healthEffectiveMax, value, false )
		UF.UpdateShieldBar( g_DefaultFrames[unitTag][POWERTYPE_HEALTH], value, healthEffectiveMax )
	end
	if UF.CustomFrames[unitTag] then
		UF.UpdateAttribute( UF.CustomFrames[unitTag][POWERTYPE_HEALTH], healthValue, healthEffectiveMax, value, false )
		UF.UpdateShieldBar( UF.CustomFrames[unitTag][POWERTYPE_HEALTH], value, healthEffectiveMax )
	end
	if g_AvaCustFrames[unitTag] then
		UF.UpdateAttribute( g_AvaCustFrames[unitTag][POWERTYPE_HEALTH], healthValue, healthEffectiveMax, value, false )
		UF.UpdateShieldBar( g_AvaCustFrames[unitTag][POWERTYPE_HEALTH], value, healthEffectiveMax )
	end
end

--[[
 * Here actual update of shield bar on attribute is done
 ]]--
function UF.UpdateShieldBar( attributeFrame, shieldValue, healthEffectiveMax)
	if attributeFrame == nil or attributeFrame.shield == nil then return end

	local hideShield = not (shieldValue > 0)
	
	if hideShield then
		attributeFrame.shield:SetValue(0)
	else
		if UF.SV.CustomSmoothBar then
			-- make it twice faster then default UI ones: last argument .085
			ZO_StatusBar_SmoothTransition(attributeFrame.shield, shieldValue, healthEffectiveMax, false, nil, 250)
		else
			attributeFrame.shield:SetMinMax(0, healthEffectiveMax)
			attributeFrame.shield:SetValue( shieldValue )
		end
	end

	attributeFrame.shield:SetHidden(hideShield)
	if attributeFrame.shieldbackdrop then attributeFrame.shieldbackdrop:SetHidden(hideShield) end
end

--[[
 * Reroutes call for regen/degen animation for given unit.
 * Called from EVENT_UNIT_ATTRIBUTE_VISUAL_* listeners.
 ]]--
function UF.UpdateRegen(unitTag, statType, attributeType, powerType )
	-- calculate actual value, and fallback to 0 if we call this function with nil parameters
	local value = (GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, statType, attributeType, powerType) or 0)
				+ (GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, statType, attributeType, powerType) or 0)

	-- here we assume, that every unitTag entry in tables has POWERTYPE_HEALTH key
	if g_DefaultFrames[unitTag] and g_DefaultFrames[unitTag][powerType] then
		UF.DisplayRegen( g_DefaultFrames[unitTag][powerType].regen, value > 0 )
		UF.DisplayRegen( g_DefaultFrames[unitTag][powerType].degen, value < 0 )
	end
	if UF.CustomFrames[unitTag] and UF.CustomFrames[unitTag][powerType] then
		UF.DisplayRegen( UF.CustomFrames[unitTag][powerType].regen, value > 0 )
		UF.DisplayRegen( UF.CustomFrames[unitTag][powerType].degen, value < 0 )
	end
	if g_AvaCustFrames[unitTag] and g_AvaCustFrames[unitTag][powerType] then
		UF.DisplayRegen( g_AvaCustFrames[unitTag][powerType].regen, value > 0 )
		UF.DisplayRegen( g_AvaCustFrames[unitTag][powerType].degen, value < 0 )
	end
end

--[[
 * Performs actual display of animation control if any
 ]]--
function UF.DisplayRegen( control, isShown )
	if control == nil then return end

	control:SetHidden( not isShown )
	if isShown then 
		control.timeline:PlayFromStart()
	else
		control.timeline:Stop()
	end
end

--[[
 * Updates decreasedArmor texture for given unit.
 * While this applicable only to custom frames, we do not need to split this function into 2 different ones
 * Called from EVENT_UNIT_ATTRIBUTE_VISUAL_* listeners.
 ]]--
function UF.UpdateStat(unitTag, statType, attributeType, powerType )
	-- build a list of UI controls to hold this statType on different UnitFrames lists
	local statControls = {}
	
	if ( UF.CustomFrames[unitTag] and UF.CustomFrames[unitTag][powerType] and UF.CustomFrames[unitTag][powerType].stat and UF.CustomFrames[unitTag][powerType].stat[statType] ) then
		tinsert(statControls, UF.CustomFrames[unitTag][powerType].stat[statType])
	end
	if ( g_AvaCustFrames[unitTag] and g_AvaCustFrames[unitTag][powerType] and g_AvaCustFrames[unitTag][powerType].stat and g_AvaCustFrames[unitTag][powerType].stat[statType] ) then
		tinsert(statControls, g_AvaCustFrames[unitTag][powerType].stat[statType])
	end
	
	-- if we have a control, proceed next
	if #statControls > 0 then
	
		-- calculate actual value, and fallback to 0 if we call this function with nil parameters
		local value = (GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, statType, attributeType, powerType) or 0)
					+ (GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, statType, attributeType, powerType) or 0)

		for _, control in pairs(statControls) do
			-- hide proper controls if they exist
			if control.dec then control.dec:SetHidden( value >= 0 ) end
			if control.inc then control.inc:SetHidden( value <= 0 ) end
			if control.single then
				control.single:SetHidden( value == 0 )
				control.single:SetColor( unpack( value < 0 and {1,0,0,0.7} or {0,1,0,0.7} ) )
			end
		end
	end
end


--[[
 * Forces to reload static information on unit frames.
 * Called from EVENT_LEVEL_UPDATE and EVENT_VETERAN_RANK_UPDATE listeners.
 ]]--
function UF.OnLevelUpdate(eventCode, unitTag, level)
	UF.UpdateStaticControls( g_DefaultFrames[unitTag] )
	UF.UpdateStaticControls( UF.CustomFrames[unitTag] )
	UF.UpdateStaticControls( g_AvaCustFrames[unitTag] )

	-- for Custom Player Frame we have to setup experience bar
	if unitTag == 'player' and UF.CustomFrames.player and UF.CustomFrames.player.Experience then
		UF.CustomFramesSetupAlternative( false, false, false )
	end
end

--[[ 
 * Runs on the EVENT_PLAYER_COMBAT_STATE listener.
 * This handler fires every time player enters or leaves combat
 ]]--
function UF.OnPlayerCombatState(eventCode, inCombat)
	g_statFull.combat = not inCombat
	UF.CustomFramesApplyInCombat()
end

--[[ 
 * Runs on the EVENT_WEREWOLF_STATE_CHANGED listener.
 ]]--
function UF.OnWerewolf(eventCode, werewolf)
	UF.CustomFramesSetupAlternative( werewolf, false, false )
end

--[[ 
 * Runs on the EVENT_BEGIN_SIEGE_CONTROL, EVENT_END_SIEGE_CONTROL, EVENT_LEAVE_RAM_ESCORT listeners.
 ]]--
function UF.OnSiege(eventCode)
	UF.CustomFramesSetupAlternative( false, nil, false )
end

--[[ 
 * Runs on the EVENT_MOUNTED_STATE_CHANGED listener.
 ]]--
function UF.OnMount(eventCode, mounted)
	UF.CustomFramesSetupAlternative( false, false, mounted )
end

--[[
 * Runs on the EVENT_EXPERIENCE_UPDATE listener.
 ]]--
function UF.OnXPUpdate( eventCode, unitTag, currentExp, maxExp, reason )
	if unitTag ~= 'player' or not UF.CustomFrames.player then return end

	if UF.CustomFrames.player.isChampion then
		-- query for Veteran and Champion XP not more then once every 5 seconds
		if not g_PendingUpdate.VeteranXP.flag then
			g_PendingUpdate.VeteranXP.flag = true
			EVENT_MANAGER:RegisterForUpdate( g_PendingUpdate.VeteranXP.name, g_PendingUpdate.VeteranXP.delay, UF.UpdateVeteranXP )
		end
	elseif UF.CustomFrames.player.Experience then
		UF.CustomFrames.player.Experience.bar:SetValue( currentExp )
	end
end

--[[
 * Helper function that updates Champion XP bar. Called from event listener with 5 sec delay
 ]]--
function UF.UpdateVeteranXP()
	-- unregister update function
	EVENT_MANAGER:UnregisterForUpdate( g_PendingUpdate.VeteranXP.name )

	if UF.CustomFrames.player then
		if UF.CustomFrames.player.Experience then
			UF.CustomFrames.player.Experience.bar:SetValue( GetUnitChampionPoints('player') )
		elseif UF.CustomFrames.player.ChampionXP then
			UF.CustomFrames.player.ChampionXP.bar:SetValue( GetPlayerChampionXP() )
		end
	end

	-- clear local flag
	g_PendingUpdate.VeteranXP.flag = false
end

--[[
 * Runs on the EVENT_GROUP_SUPPORT_RANGE_UPDATE listener.
 ]]--
function UF.OnGroupSupportRangeUpdate(eventCode, unitTag, status)
	if UF.CustomFrames[unitTag] and UF.CustomFrames[unitTag].control then
		UF.CustomFrames[unitTag].control:SetAlpha( status and 1 or 0.5 )
	end
end

--[[
 * Runs on the EVENT_GROUP_MEMBER_CONNECTED_STATUS listener.
 ]]--
function UF.OnGroupMemberConnectedStatus(eventCode, unitTag, isOnline)
	--CHAT_SYSTEM:AddMessage( strformat('DC: %s - %s', unitTag, isOnline and 'Online' or 'Offline' ) )
	if UF.CustomFrames[unitTag] and UF.CustomFrames[unitTag].dead then
		UF.CustomFramesSetDeadLabel( UF.CustomFrames[unitTag], isOnline and nil or strOffline )
	end
end

--[[ 
 * Runs on the EVENT_UNIT_DEATH_STATE_CHANGED listener.
 * This handler fires every time a valid unitTag dies or is resurrected
 ]]--
function UF.OnDeath(eventCode, unitTag, isDead)
	--CHAT_SYSTEM:AddMessage( strformat('%s - %s', unitTag, isDead and 'Dead' or 'Alive' ) )
	if UF.CustomFrames[unitTag] and UF.CustomFrames[unitTag].dead then
		UF.CustomFramesSetDeadLabel( UF.CustomFrames[unitTag], isDead and strDead or nil )
	end

	-- manually hide regen/degen animation as well as stat-changing icons, because game does not always issue corresponding event before unit is dead
	if isDead and UF.CustomFrames[unitTag] and UF.CustomFrames[unitTag][POWERTYPE_HEALTH] then
		local thb = UF.CustomFrames[unitTag][POWERTYPE_HEALTH] -- not a backdrop
		-- 1. regen/degen
		UF.DisplayRegen( thb.regen, false )
		UF.DisplayRegen( thb.degen, false )
		-- 2. stats
		if thb.stat then
			for _, statControls in pairs( thb.stat ) do
				if statControls.dec then statControls.dec:SetHidden( true ) end
				if statControls.inc then statControls.inc:SetHidden( true ) end
				if statControls.single then statControls.single:SetHidden( true ) end
			end
		end
	end
end

--[[
 * Runs on the EVENT_STEALTH_STATE_CHANGED listener.
 ]]--
function UF.OnStealthState(eventCode, unitTag, stealthState)
	if UF.CustomFrames[unitTag] and UF.CustomFrames[unitTag].stealth then
		local stealth = ( stealthState == STEALTH_STATE_HIDDEN or stealthState == STEALTH_STATE_HIDDEN_ALMOST_DETECTED )
		UF.CustomFrames[unitTag].stealth:SetTexture( stealth and "/esoui/art/icons/guildranks/guild_rankicon_misc06.dds" or "/esoui/art/icons/guildranks/guild_rankicon_misc12.dds" )
		UF.CustomFrames[unitTag].stealth:SetAlpha( stealth and 1 or 0.1 )
	end
end

--[[
 * Runs on the EVENT_LEADER_UPDATE listener.
 ]]--
function UF.OnLeaderUpdate(eventCode, leaderTag)
	if UF.CustomFrames[leaderTag] and UF.CustomFrames[leaderTag].leader then
		local anchors = UF.CustomFrames[leaderTag].leader
		g_customLeaderIcon:SetParent( UF.CustomFrames[leaderTag].control )
		g_customLeaderIcon:ClearAnchors()
		g_customLeaderIcon:SetAnchor( anchors[1], anchors[5], anchors[2], anchors[3], anchors[4]  )
		g_customLeaderIcon:SetHidden( anchors[6] and not UF.CustomFrames[leaderTag].dead:IsHidden() )

		-- SmallGroup need special treatment
		if UF.CustomFrames[leaderTag].classIcon then
			local size = UF.CustomFrames[leaderTag].classIcon:GetWidth() *1.3
			g_customLeaderIcon:SetDimensions( size, size )
			UF.CustomFrames[leaderTag].topInfo:SetWidth( UF.SV.GroupBarWidth-size*5/6 )

		-- RaidGroup need just reset of icon size
		else
			g_customLeaderIcon:SetDimensions( 24, 24 )
		end

	else
		g_customLeaderIcon:SetHidden(true)
	end

	-- restore last leader label width
	if g_customLeaderIcon.unitTag and UF.CustomFrames[g_customLeaderIcon.unitTag] and UF.CustomFrames[g_customLeaderIcon.unitTag].topInfo then
		UF.CustomFrames[g_customLeaderIcon.unitTag].topInfo:SetWidth( UF.SV.GroupBarWidth-5 )
	end
	-- and set current leader tag
	g_customLeaderIcon.unitTag = leaderTag
end

--[[
 * This function is used to setup alternative bar for player
 * Priority order:
 * Werewolf -> Siege -> Mount -> ChampionXP / Experience
 ]]--
local XP_BAR_COLOURS = ZO_XP_BAR_GRADIENT_COLORS[2]
function UF.CustomFramesSetupAlternative( isWerewolf, isSiege, isMounted )
	if not UF.CustomFrames.player then return end

	-- if any of input parameters are nil, we need to query them
	if isWerewolf == nil then isWerewolf = IsWerewolf() end
	if isSiege == nil then isSiege = ( IsPlayerControllingSiegeWeapon() or IsPlayerEscortingRam() ) end
	if isMounted == nil then isMounted = IsMounted() end

	local center, colour, icon
	local hidden = false
	
	if UF.SV.PlayerEnableAltbarMSW and isWerewolf then
		icon	= "/esoui/art/progression/progression_indexicon_world_down.dds"
		center	= { 0.05, 0, 0, 0.9 }
		colour	= { 0.8,  0, 0, 0.9 }

		UF.CustomFrames.player[POWERTYPE_WEREWOLF] = UF.CustomFrames.player.alternative
		UF.CustomFrames.controlledsiege[POWERTYPE_HEALTH] = nil
		UF.CustomFrames.player[POWERTYPE_MOUNT_STAMINA] = nil
		UF.CustomFrames.player.ChampionXP = nil
		UF.CustomFrames.player.Experience = nil
		
		UF.OnPowerUpdate(nil, 'player', nil, POWERTYPE_WEREWOLF, GetUnitPower('player', POWERTYPE_WEREWOLF))

	elseif UF.SV.PlayerEnableAltbarMSW and isSiege then
		icon	= "/esoui/art/worldmap/map_ava_tabicon_resourcedefense_down.dds"
		center	= { 0.05, 0, 0, 0.9 }
		colour	= { 0.8,  0, 0, 0.9 }

		UF.CustomFrames.player[POWERTYPE_WEREWOLF] = nil
		UF.CustomFrames.controlledsiege[POWERTYPE_HEALTH] = UF.CustomFrames.player.alternative
		UF.CustomFrames.player[POWERTYPE_MOUNT_STAMINA] = nil
		UF.CustomFrames.player.ChampionXP = nil
		UF.CustomFrames.player.Experience = nil

		UF.OnPowerUpdate(nil, 'controlledsiege', nil, POWERTYPE_HEALTH, GetUnitPower('controlledsiege', POWERTYPE_HEALTH))

	elseif UF.SV.PlayerEnableAltbarMSW and isMounted then
		icon	= "/esoui/art/mounts/tabicon_mounts_up.dds"
		center	= { 0.1*UF.SV.CustomColourStamina[1], 0.1*UF.SV.CustomColourStamina[2], 0.1*UF.SV.CustomColourStamina[3], 0.9 }
		colour	= { UF.SV.CustomColourStamina[1], UF.SV.CustomColourStamina[2], UF.SV.CustomColourStamina[3], 0.9 }

		UF.CustomFrames.player[POWERTYPE_WEREWOLF] = nil
		UF.CustomFrames.controlledsiege[POWERTYPE_HEALTH] = nil
		UF.CustomFrames.player[POWERTYPE_MOUNT_STAMINA] = UF.CustomFrames.player.alternative
		UF.CustomFrames.player.ChampionXP = nil
		UF.CustomFrames.player.Experience = nil

		UF.OnPowerUpdate(nil, 'player', nil, POWERTYPE_MOUNT_STAMINA, GetUnitPower('player', POWERTYPE_MOUNT_STAMINA))

	elseif UF.SV.PlayerEnableAltbarXP and ( UF.CustomFrames.player.isLevelCap or ( UF.CustomFrames.player.isChampion )) then
		UF.CustomFrames.player[POWERTYPE_WEREWOLF] = nil
		UF.CustomFrames.controlledsiege[POWERTYPE_HEALTH] = nil
		UF.CustomFrames.player[POWERTYPE_MOUNT_STAMINA] = nil
		UF.CustomFrames.player.ChampionXP = UF.CustomFrames.player.alternative
		UF.CustomFrames.player.Experience = nil
		
		UF.OnChampionPointGained() -- setup bar colour and proper icon

		UF.CustomFrames.player.ChampionXP.bar:SetMinMax( 0 , 400000 )
		UF.CustomFrames.player.ChampionXP.bar:SetValue( GetPlayerChampionXP() )

	elseif UF.SV.PlayerEnableAltbarXP then
		icon	= "/esoui/art/journal/journal_tabicon_quest_down.dds"
		center	= { 0, 0.1, 0.1, 0.9 }
		colour	= { XP_BAR_COLOURS.r, XP_BAR_COLOURS.g, XP_BAR_COLOURS.b, 0.9 } -- { 0, 0.9, 0.9, 0.9 }

		UF.CustomFrames.player[POWERTYPE_WEREWOLF] = nil
		UF.CustomFrames.controlledsiege[POWERTYPE_HEALTH] = nil
		UF.CustomFrames.player[POWERTYPE_MOUNT_STAMINA] = nil
		UF.CustomFrames.player.ChampionXP = nil
		UF.CustomFrames.player.Experience = UF.CustomFrames.player.alternative

		UF.CustomFrames.player.Experience.bar:SetMinMax( 0 , UF.CustomFrames.player.isChampion and GetNumChampionXPInChampionPoint('player')  or GetUnitXPMax('player') )
		UF.CustomFrames.player.Experience.bar:SetValue( UF.CustomFrames.player.isChampion and GetUnitChampionPoints('player') or GetUnitXP('player') )

	-- Otherwise bar should be hidden and no tracking be done
	else
		UF.CustomFrames.player[POWERTYPE_WEREWOLF] = nil
		UF.CustomFrames.controlledsiege[POWERTYPE_HEALTH] = nil
		UF.CustomFrames.player[POWERTYPE_MOUNT_STAMINA] = nil
		UF.CustomFrames.player.ChampionXP = nil
		UF.CustomFrames.player.Experience = nil

		hidden = true
	end

	-- setup of bar colours and icon
	if center then UF.CustomFrames.player.alternative.backdrop:SetCenterColor( unpack(center) ) end
	if colour then UF.CustomFrames.player.alternative.bar:SetColor( unpack(colour) ) end
	if icon then UF.CustomFrames.player.alternative.icon:SetTexture( icon ) end

	-- hide bar and reanchor buffs
	UF.CustomFrames.player.botInfo:SetHidden( hidden )
	UF.CustomFrames.player.buffs:ClearAnchors()
	UF.CustomFrames.player.buffs:SetAnchor( TOP, hidden and UF.CustomFrames.player.control or UF.CustomFrames.player.botInfo, BOTTOM, 0, 5 )
end

--[[
 * This icon will be used for alternative bar when using ChampionXP
 --]]
local CHAMPION_ATTRIBUTE_HUD_ICONS =
{
	[ATTRIBUTE_NONE] = "/esoui/art/mainmenu/menubar_champion_up.dds",
    [ATTRIBUTE_HEALTH] = "/esoui/art/champion/champion_points_health_icon-hud-32.dds",
    [ATTRIBUTE_MAGICKA] = "/esoui/art/champion/champion_points_magicka_icon-hud-32.dds",
    [ATTRIBUTE_STAMINA] = "/esoui/art/champion/champion_points_stamina_icon-hud-32.dds",
}
local CP_BAR_COLOURS = ZO_CP_BAR_GRADIENT_COLORS

--[[
 * Runs on EVENT_CHAMPION_POINT_GAINED event listener
 * Used to change icon on alternative bar for next champion point type
 ]]--
function UF.OnChampionPointGained(eventCode)
	if UF.CustomFrames.player and UF.CustomFrames.player.ChampionXP then
		local attribute = GetChampionPointAttributeForRank( GetPlayerChampionPointsEarned()+1 )
		local colour = ( UF.SV.PlayerChampionColour and CP_BAR_COLOURS[attribute] ) and CP_BAR_COLOURS[attribute][2] or XP_BAR_COLOURS
		UF.CustomFrames.player.ChampionXP.backdrop:SetCenterColor( 0.1*colour.r, 0.1*colour.g, 0.1*colour.b, 0.9 )
		UF.CustomFrames.player.ChampionXP.bar:SetColor( colour.r, colour.g, colour.b, 0.9 )
		UF.CustomFrames.player.ChampionXP.icon:SetTexture( CHAMPION_ATTRIBUTE_HUD_ICONS[ attribute ] )
	end
end

--[[ 
 * Runs on the EVENT_COMBAT_EVENT listener.
 ]]--
function UF.OnCombatEvent( eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log )
	if isError
		and sourceType == COMBAT_UNIT_TYPE_PLAYER
		and targetType == COMBAT_UNIT_TYPE_PLAYER
		and UF.CustomFrames.player ~= nil
		and UF.CustomFrames.player[powerType] ~= nil
		and UF.CustomFrames.player[powerType].backdrop ~= nil then

		if g_powerError[powerType] then return end

		g_powerError[powerType] = true
		-- save original center colour and colour to red
		local backdrop = UF.CustomFrames.player[powerType].backdrop
		local r,g,b = backdrop:GetCenterColor()
		backdrop:SetCenterColor( 0.4, 0, 0, 0.9 )
		
		-- make a delayed call to return original colour
		local uniqueId = moduleName .. '_powerError_' .. powerType
		local firstRun = true

		EVENT_MANAGER:RegisterForUpdate(uniqueId, 300, function()
			if firstRun then
				backdrop:SetCenterColor( r, g, b, 0.9 )
				firstRun = false
			else
				EVENT_MANAGER:UnregisterForUpdate(uniqueId)
				g_powerError[powerType] = false
			end
		end)
	end
end

--[[
 * Helper function to update visibility of 'death/offline' label and hide bars and bar labels
 ]]--
function UF.CustomFramesSetDeadLabel( unitFrame, newValue )

	unitFrame.dead:SetHidden( newValue == nil )
	if newValue ~= nil then unitFrame.dead:SetText( newValue ) end

	if unitFrame[POWERTYPE_HEALTH] then
		if unitFrame[POWERTYPE_HEALTH].bar ~= nil then unitFrame[POWERTYPE_HEALTH].bar:SetHidden( newValue ~= nil ) end
		if unitFrame[POWERTYPE_HEALTH].label ~= nil then unitFrame[POWERTYPE_HEALTH].label:SetHidden( newValue ~= nil ) end
		if unitFrame[POWERTYPE_HEALTH].labelOne ~= nil then unitFrame[POWERTYPE_HEALTH].labelOne:SetHidden( newValue ~= nil ) end
		if unitFrame[POWERTYPE_HEALTH].labelTwo ~= nil then unitFrame[POWERTYPE_HEALTH].labelTwo:SetHidden( newValue ~= nil ) end
	end
	if unitFrame.stealth ~= nil then unitFrame.stealth:SetHidden( newValue ~= nil ) end

	-- finally small check if we want to hide leader icon from control - this is required for RaidGroup
	if GetGroupLeaderUnitTag() == unitFrame.unitTag and unitFrame.leader and unitFrame.leader[6] then
		g_customLeaderIcon:SetHidden( newValue ~= nil )
	end
end

--[[
 * Repopulate group members, but try to update only those, that require it
 ]]--
function UF.CustomFramesGroupUpdate()
	--CHAT_SYSTEM:AddMessage( strformat('[%s] GroupUpdate', GetTimeString()) )

	-- unregister update function and clear local flag
	EVENT_MANAGER:UnregisterForUpdate( g_PendingUpdate.Group.name )
	g_PendingUpdate.Group.flag = false

	if ( UF.CustomFrames.SmallGroup1 == nil and UF.CustomFrames.RaidGroup1 == nil ) then return end

	local disableGroup = UF.SV.GroupDisableDefault and (UF.CustomFrames.SmallGroup1 ~= nil)
	local disableRaid = UF.SV.RaidDisableDefault and (UF.CustomFrames.RaidGroup1 ~= nil)

	-- first hide default group frame, but if player has this option:
	-- could be 4 possibilities never hide, hide only for small, hide only for large
	ZO_UnitFramesGroups:SetHidden( ( disableGroup and disableRaid ) or
									( disableGroup and GetGroupSize() <= 4 ) or
									( disableRaid and GetGroupSize() > 4 ) )
	
	-- This requires some tricks if we want to keep list alphabetically sorted
	local groupList = {}
	
	-- First we query all group unitTag for existence and save them to local list
	-- At the same time we will calculate how many group members we have and then will hide rest of custom control elements
	local n = 0 -- counter used to reference custom frames. it always continuous while games unitTag could have gaps
	for i = 1, 24 do
		local unitTag = 'group' .. i
		if DoesUnitExist(unitTag) then
			-- save this member for later sorting
			tinsert(groupList, { ["unitTag"] = unitTag, ["unitName"] = GetUnitName(unitTag) } )
			-- CustomFrames
			n = n + 1
		else
			-- for non-existing unitTags we will remove reference from CustomFrames table
			UF.CustomFrames[unitTag] = nil
		end
	end

	-- chose which of custom group frames we are going to use now
	local raid = nil

	-- now we have to hide all excessive custom group controls
	if n > 4 then
		if UF.CustomFrames.SmallGroup1 then -- custom group frames cannot be used for large groups
			UF.CustomFramesUnreferenceGroupControl('SmallGroup', 1)
		end
		if UF.CustomFrames.RaidGroup1 then -- real group is large and custom raid frames are enabled
			UF.CustomFramesUnreferenceGroupControl('RaidGroup', n+1)
			raid = true
		end
	else
		if UF.CustomFrames.SmallGroup1 then -- custom group frames are enabled and used for small group
			UF.CustomFramesUnreferenceGroupControl('SmallGroup', n+1)
			raid = false
			if UF.CustomFrames.RaidGroup1 then -- in this case just hide all raid frames if they are enabled
				UF.CustomFramesUnreferenceGroupControl('RaidGroup', 1)
			end
		elseif UF.CustomFrames.RaidGroup1 then -- fallback option to use custom raid frames for small group
			UF.CustomFramesUnreferenceGroupControl('RaidGroup', n+1)
			raid = true
		end
	end

	-- here we can check unlikely situation when neither custom frames were selected
	if raid == nil then return end

	-- now for small group we can exclude player from the list
	if raid == false and UF.SV.GroupExcludePlayer then
		for i = 1, #groupList do
			if AreUnitsEqual( 'player', groupList[i].unitTag ) then
				-- dereference game unitTag from CustomFrames table
				UF.CustomFrames[groupList[i].unitTag] = nil
				-- remove element from saved table
				table.remove(groupList, i)
				-- also remove last used (not removed on previous step) SmallGroup unitTag
				-- variable 'n' is still holding total number of group members
				-- thus we need to remove n-th one
				local unitTag = 'SmallGroup' .. n
				UF.CustomFrames[unitTag].unitTag = nil
				UF.CustomFrames[unitTag].control:SetHidden( true )
				break
			end
		end
	end

	-- now we have local list with valid units and we are ready to sort it
	-- FIXME: Sorting is again hardcoded to be done always
	--if not raid or UF.SV.RaidSort then
		tsort( groupList, function(x,y) return x.unitName < y.unitName end )
	--end

	-- loop through sorted list and put unitTag references into CustomFrames table
	local n = 0
	for _, v in ipairs(groupList) do
		-- increase local counter
		n = n + 1
		UF.CustomFrames[v.unitTag] = UF.CustomFrames[ (raid and 'RaidGroup' or 'SmallGroup' ) .. n]
		UF.CustomFrames[v.unitTag].control:SetHidden( false )

		-- for SmallGroup reset topInfo width
		if not raid then UF.CustomFrames[v.unitTag].topInfo:SetWidth( UF.SV.GroupBarWidth-5 ) end
		
		UF.CustomFrames[v.unitTag].unitTag = v.unitTag
		UF.ReloadValues(v.unitTag)
	end

	-- clear previously stored leader unitTag and call function to update current leader
	g_customLeaderIcon.unitTag = nil
	UF.OnLeaderUpdate( nil, GetGroupLeaderUnitTag() )
end

--[[
 * Helper function to hide and remove unitTag reference from unused group controls
 ]]--
function UF.CustomFramesUnreferenceGroupControl( groupType, first )
	local last
	if groupType == 'SmallGroup' then
		last = 4
	elseif groupType == 'RaidGroup' then
		last = 24
	else return end

	for i = first, last do
		local unitTag =  groupType .. i
		UF.CustomFrames[unitTag].unitTag = nil
		UF.CustomFrames[unitTag].control:SetHidden( true )
	end
end

--[[
 * Runs EVENT_BOSSES_CHANGED listener
 ]]--
function UF.OnBossesChanged( eventCode )
	if not UF.CustomFrames.boss1 then return end
	
	for i = 1, 6 do
		local unitTag = 'boss' .. i
		if DoesUnitExist(unitTag) then
			UF.CustomFrames[unitTag].control:SetHidden(false)
			UF.ReloadValues(unitTag)
		else
			UF.CustomFrames[unitTag].control:SetHidden(true)
		end
	end

end

--[[
 * Set anchors for all top level windows of CustomFrames
 ]]--
function UF.CustomFramesSetPositions()

	local default_anchors = {
		['player']		= {TOP,CENTER,-400,200},
		['reticleover']	= {TOP,CENTER,400,200},
		['SmallGroup1']	= {TOPLEFT,TOPLEFT,4,400},
		['RaidGroup1']	= {TOPLEFT,TOPLEFT,4,380},
		['boss1']		= {TOP,TOP,400,150},
		['AvaPlayerTarget'] = {TOP,TOP,0,200},
	}

	for _, unitTag in pairs( { 'player', 'reticleover', 'SmallGroup1', 'RaidGroup1', 'boss1', 'AvaPlayerTarget' } ) do
		if UF.CustomFrames[unitTag] then
			local savedPos = UF.SV[UF.CustomFrames[unitTag].tlw.customPositionAttr]
			local anchors = ( savedPos ~= nil and #savedPos == 2 ) and { TOPLEFT, TOPLEFT, savedPos[1], savedPos[2] } or default_anchors[unitTag]
			UF.CustomFrames[unitTag].tlw:ClearAnchors()
			UF.CustomFrames[unitTag].tlw:SetAnchor( anchors[1], GuiRoot, anchors[2], anchors[3], anchors[4] )
			UF.CustomFrames[unitTag].tlw.preview.anchorLabel:SetText( ( savedPos ~= nil and #savedPos == 2 ) and strformat("%d, %d", savedPos[1], savedPos[2]) or "default" )
		end
	end

end

--[[
 * Reset anchors for all top level windows of CustomFrames
 ]]--
function UF.CustomFramesResetPosition()
	for _, unitTag in pairs( { 'player', 'reticleover', 'SmallGroup1', 'RaidGroup1', 'boss1', 'AvaPlayerTarget' } ) do
		if UF.CustomFrames[unitTag] then
			UF.SV[UF.CustomFrames[unitTag].tlw.customPositionAttr] = nil
		end
	end
	UF.CustomFramesSetPositions()
end

--[[
 * Unlock CustomFrames for moving. Called from Settings Menu.
 ]]--
function UF.CustomFramesSetMovingState( state )

	UF.CustomFramesMovingState = state

	-- Unlock individual frames
	for _, unitTag in pairs( { 'player', 'reticleover', 'SmallGroup1', 'RaidGroup1', 'boss1', 'AvaPlayerTarget' } ) do
		if UF.CustomFrames[unitTag] then
			local tlw = UF.CustomFrames[unitTag].tlw
			if tlw.preview then tlw.preview:SetHidden( not state ) end -- player frame does not have 'preview' control
			tlw:SetMouseEnabled( state )
			tlw:SetMovable( state )
			tlw:SetHidden( false )
		end
	end

	-- Unlock buffs for Player ( preview control is created in SCB module )
	if UF.CustomFrames.player then
		if UF.CustomFrames.player.buffs.preview then
			UF.CustomFrames.player.buffs.preview:SetHidden( not state )
		end
		if UF.CustomFrames.player.debuffs.preview then
			UF.CustomFrames.player.debuffs.preview:SetHidden( not state )
		end
	end

	-- Unlock buffs and debuffs for Target ( preview controls are created in LTE and SCB modules )
	if UF.CustomFrames.reticleover then
		if UF.CustomFrames.reticleover.buffs.preview then
			UF.CustomFrames.reticleover.buffs.preview:SetHidden( not state )
		end
		if UF.CustomFrames.reticleover.debuffs.preview then
			UF.CustomFrames.reticleover.debuffs.preview:SetHidden( not state )
		end
		-- make this hack so target window is not going to be hidden:
		-- Target Frame will now always display old information
		UF.CustomFrames.reticleover.canHide = not state
	end

end

--[[
 * Apply selected colours for all known bars on custom unit frames
 ]]--
function UF.CustomFramesApplyColours()

	local health = { UF.SV.CustomColourHealth[1], UF.SV.CustomColourHealth[2], UF.SV.CustomColourHealth[3], 0.9 }
	local shield = { UF.SV.CustomColourShield[1], UF.SV.CustomColourShield[2], UF.SV.CustomColourShield[3], 0 } -- .a value will be fixed in the loop
	local magicka = { UF.SV.CustomColourMagicka[1], UF.SV.CustomColourMagicka[2], UF.SV.CustomColourMagicka[3], 0.9 }
	local stamina = { UF.SV.CustomColourStamina[1], UF.SV.CustomColourStamina[2], UF.SV.CustomColourStamina[3], 0.9 }

	local health_bg = { 0.1*UF.SV.CustomColourHealth[1], 0.1*UF.SV.CustomColourHealth[2], 0.1*UF.SV.CustomColourHealth[3], 0.9 }
	local shield_bg = { 0.1*UF.SV.CustomColourShield[1], 0.1*UF.SV.CustomColourShield[2], 0.1*UF.SV.CustomColourShield[3], 0.9 }
	local magicka_bg = { 0.1*UF.SV.CustomColourMagicka[1], 0.1*UF.SV.CustomColourMagicka[2], 0.1*UF.SV.CustomColourMagicka[3], 0.9 }
	local stamina_bg = { 0.1*UF.SV.CustomColourStamina[1], 0.1*UF.SV.CustomColourStamina[2], 0.1*UF.SV.CustomColourStamina[3], 0.9 }

	-- after colour is applied unhide frames, so player can see changes even from menu
	for _, baseName in pairs( { 'player', 'reticleover', 'SmallGroup', 'RaidGroup', 'boss', 'AvaPlayerTarget' } ) do
		shield[4] = ( UF.SV.CustomShieldBarSeparate and not ( baseName == 'RaidGroup' or baseName == 'boss' ) ) and 0.9 or 0.5
		for i = 0, 24 do
			local unitTag = (i==0) and baseName or ( baseName .. i )
			if UF.CustomFrames[unitTag] then
				local unitFrame = UF.CustomFrames[unitTag]
				local thb = unitFrame[POWERTYPE_HEALTH] -- not a backdrop
				thb.bar:SetColor( unpack(health) )
				thb.backdrop:SetCenterColor( unpack(health_bg) )
				thb.shield:SetColor( unpack(shield) )
				if thb.shieldbackdrop then thb.shieldbackdrop:SetCenterColor( unpack(shield_bg) ) end
				if i == 0 or i == 1 then
					unitFrame.tlw:SetHidden( false )
				end
			end
		end
	end

	-- player frame also requires setting of magicka and stamina bars
	if UF.CustomFrames.player then
		UF.CustomFrames.player[POWERTYPE_MAGICKA].bar:SetColor( unpack(magicka) )
		UF.CustomFrames.player[POWERTYPE_MAGICKA].backdrop:SetCenterColor( unpack(magicka_bg) )
		UF.CustomFrames.player[POWERTYPE_STAMINA].bar:SetColor( unpack(stamina) )
		UF.CustomFrames.player[POWERTYPE_STAMINA].backdrop:SetCenterColor( unpack(stamina_bg) )
	end
end

--[[
 * Apply selected texture for all known bars on custom unit frames
 ]]--
function UF.CustomFramesApplyTexture()

	local texture = LUIE.StatusbarTextures[UF.SV.CustomTexture]

	-- after texture is applied unhide frames, so player can see changes even from menu
	if UF.CustomFrames.player then
		UF.CustomFrames.player[POWERTYPE_HEALTH].backdrop:SetCenterTexture(texture)
		UF.CustomFrames.player[POWERTYPE_HEALTH].bar:SetTexture(texture)
		if UF.CustomFrames.player[POWERTYPE_HEALTH].shieldbackdrop then UF.CustomFrames.player[POWERTYPE_HEALTH].shieldbackdrop:SetCenterTexture(texture) end
		UF.CustomFrames.player[POWERTYPE_HEALTH].shield:SetTexture(texture)
		UF.CustomFrames.player[POWERTYPE_MAGICKA].backdrop:SetCenterTexture(texture)
		UF.CustomFrames.player[POWERTYPE_MAGICKA].bar:SetTexture(texture)
		UF.CustomFrames.player[POWERTYPE_STAMINA].backdrop:SetCenterTexture(texture)
		UF.CustomFrames.player[POWERTYPE_STAMINA].bar:SetTexture(texture)
		UF.CustomFrames.player.alternative.backdrop:SetCenterTexture(texture)
		UF.CustomFrames.player.alternative.bar:SetTexture(texture)
		UF.CustomFrames.player.tlw:SetHidden( false )
	end
	if UF.CustomFrames.reticleover then
		UF.CustomFrames.reticleover[POWERTYPE_HEALTH].backdrop:SetCenterTexture(texture)
		UF.CustomFrames.reticleover[POWERTYPE_HEALTH].bar:SetTexture(texture)
		if UF.CustomFrames.reticleover[POWERTYPE_HEALTH].shieldbackdrop then UF.CustomFrames.reticleover[POWERTYPE_HEALTH].shieldbackdrop:SetCenterTexture(texture) end
		UF.CustomFrames.reticleover[POWERTYPE_HEALTH].shield:SetTexture(texture)
		UF.CustomFrames.reticleover.tlw:SetHidden( false )
	end
	if UF.CustomFrames.AvaPlayerTarget then
		UF.CustomFrames.AvaPlayerTarget[POWERTYPE_HEALTH].backdrop:SetCenterTexture(texture)
		UF.CustomFrames.AvaPlayerTarget[POWERTYPE_HEALTH].bar:SetTexture(texture)
		if UF.CustomFrames.AvaPlayerTarget[POWERTYPE_HEALTH].shieldbackdrop then UF.CustomFrames.AvaPlayerTarget[POWERTYPE_HEALTH].shieldbackdrop:SetCenterTexture(texture) end
		UF.CustomFrames.AvaPlayerTarget[POWERTYPE_HEALTH].shield:SetTexture(texture)
		UF.CustomFrames.AvaPlayerTarget.tlw:SetHidden( false )
	end
	if UF.CustomFrames.SmallGroup1 then
		for i = 1, 4 do
			local unitTag = 'SmallGroup' .. i
			UF.CustomFrames[unitTag][POWERTYPE_HEALTH].backdrop:SetCenterTexture(texture)
			UF.CustomFrames[unitTag][POWERTYPE_HEALTH].bar:SetTexture(texture)
			if UF.CustomFrames[unitTag][POWERTYPE_HEALTH].shieldbackdrop then UF.CustomFrames[unitTag][POWERTYPE_HEALTH].shieldbackdrop:SetCenterTexture(texture) end
			UF.CustomFrames[unitTag][POWERTYPE_HEALTH].shield:SetTexture(texture)
		end
		UF.CustomFrames.SmallGroup1.tlw:SetHidden( false )
	end
	if UF.CustomFrames.RaidGroup1 then
		for i = 1, 24 do
			local unitTag = 'RaidGroup' .. i
			UF.CustomFrames[unitTag][POWERTYPE_HEALTH].backdrop:SetCenterTexture(texture)
			UF.CustomFrames[unitTag][POWERTYPE_HEALTH].bar:SetTexture(texture)
			UF.CustomFrames[unitTag][POWERTYPE_HEALTH].shield:SetTexture(texture)
		end
		UF.CustomFrames.RaidGroup1.tlw:SetHidden( false )
	end
	if UF.CustomFrames.boss1 then
		for i = 1, 6 do
			local unitTag = 'boss' .. i
			UF.CustomFrames[unitTag][POWERTYPE_HEALTH].backdrop:SetCenterTexture(texture)
			UF.CustomFrames[unitTag][POWERTYPE_HEALTH].bar:SetTexture(texture)
			UF.CustomFrames[unitTag][POWERTYPE_HEALTH].shield:SetTexture(texture)
		end
		UF.CustomFrames.boss1.tlw:SetHidden( false )
	end
end

--[[
 * Apply selected font for all known label on default unit frames
 ]]--
function UF.DefaultFramesApplyFont(unitTag)

	-- first try selecting font face
	local fontName = LUIE.Fonts[UF.SV.DefaultFontFace]
	if not fontName or fontName == '' then
		CHAT_SYSTEM:AddMessage('LUIE_CustomFrames: There was a problem with selecting required font. Falling back to game default.')
		fontName = "$(BOLD_FONT)"
	end

	local fontStyle = ( UF.SV.DefaultFontStyle and UF.SV.DefaultFontStyle ~= '' ) and UF.SV.DefaultFontStyle or 'soft-shadow-thick'
	local fontSize = ( UF.SV.DefaultFontSize and UF.SV.DefaultFontSize > 0 ) and UF.SV.DefaultFontSize or 16

	local __applyFont = function(unitTag)
		if g_DefaultFrames[unitTag] then
			local unitFrame = g_DefaultFrames[unitTag]
			for _, powerType in pairs( {POWERTYPE_HEALTH, POWERTYPE_MAGICKA, POWERTYPE_STAMINA} ) do
				if unitFrame[powerType] then
					unitFrame[powerType].label:SetFont( strformat( '%s|%d|%s', fontName, fontSize, fontStyle ) )
				end
			end
		end
	end

	-- apply setting only for one requested unitTag
	if unitTag then
		__applyFont(unitTag)

	-- otherwise do it for all possible unitTags
	else
		__applyFont("player")
		__applyFont("reticleover")
		for i = 0, 24 do
			__applyFont("group" .. i)
		end
	end

end

--[[
 * Reapplies colour for default unit frames extender module labels
 ]]--
function UF.DefaultFramesApplyColour()

	-- helper function
	local __applyColour = function(unitTag)
		if g_DefaultFrames[unitTag] then
			local unitFrame = g_DefaultFrames[unitTag]
			for _, powerType in pairs( {POWERTYPE_HEALTH, POWERTYPE_MAGICKA, POWERTYPE_STAMINA} ) do
				if unitFrame[powerType] then
					unitFrame[powerType].colour = UF.SV.DefaultTextColour
					unitFrame[powerType].label:SetColor( UF.SV.DefaultTextColour[1], UF.SV.DefaultTextColour[2], UF.SV.DefaultTextColour[3] )
				end
			end
		end
	end

	-- apply setting for all possible unitTags
	__applyColour("player")
	__applyColour("reticleover")
	for i = 0, 24 do
		__applyColour("group" .. i)
	end

end

--[[
 * Apply selected font for all known label on custom unit frames
 ]]--
function UF.CustomFramesApplyFont()

	-- first try selecting font face
	local fontName = LUIE.Fonts[UF.SV.CustomFontFace]
	if not fontName or fontName == '' then
		CHAT_SYSTEM:AddMessage('LUIE_CustomFrames: There was a problem with selecting required font. Falling back to game default.')
		fontName = "$(MEDIUM_FONT)"
	end

	local fontStyle = ( UF.SV.CustomFontStyle and UF.SV.CustomFontStyle ~= '' ) and UF.SV.CustomFontStyle or 'soft-shadow-thin'
	local sizeCaption = ( UF.SV.CustomFontOther and UF.SV.CustomFontOther > 0 ) and UF.SV.CustomFontOther or 16
	local sizeBars = ( UF.SV.CustomFontBars and UF.SV.CustomFontBars > 0 ) and UF.SV.CustomFontBars or 14
	
	local __mkFont = function(size) return strformat( '%s|%d|%s', fontName, size, fontStyle ) end

	-- after fonts is applied unhide frames, so player can see changes even from menu
	for _, baseName in pairs( { 'player', 'reticleover', 'SmallGroup', 'RaidGroup', 'boss', 'AvaPlayerTarget' } ) do
		for i = 0, 24 do
			local unitTag = (i==0) and baseName or ( baseName .. i )
			if UF.CustomFrames[unitTag] then
				local unitFrame = UF.CustomFrames[unitTag]
				if unitFrame.name then unitFrame.name:SetFont( __mkFont( (unitFrame.name:GetParent() == unitFrame.topInfo) and sizeCaption or sizeBars ) ) end
				if unitFrame.level then unitFrame.level:SetFont( __mkFont(sizeCaption) ) end
				if unitFrame.className then unitFrame.className:SetFont( __mkFont(sizeCaption) ) end
				if unitFrame.title then unitFrame.title:SetFont( __mkFont(sizeCaption) ) end
				if unitFrame.avaRank then unitFrame.avaRank:SetFont( __mkFont(sizeCaption) ) end
				if unitFrame.dead then unitFrame.dead:SetFont( __mkFont(sizeBars) ) end
				for _, powerType in pairs( {POWERTYPE_HEALTH, POWERTYPE_MAGICKA, POWERTYPE_STAMINA} ) do
					if unitFrame[powerType] then
						if unitFrame[powerType].label    then unitFrame[powerType].label:SetFont( __mkFont(sizeBars) ) end
						if unitFrame[powerType].labelOne then unitFrame[powerType].labelOne:SetFont( __mkFont(sizeBars) ) end
						if unitFrame[powerType].labelTwo then unitFrame[powerType].labelTwo:SetFont( __mkFont(sizeBars) ) end
					end
				end
				if i == 0 or i == 1 then
					unitFrame.tlw:SetHidden( false )
				end
			end
		end
	end
	
	-- Adjust height of Name and Title labels on Player, Target and SmallGroup frames
	for _, baseName in pairs( { 'player', 'reticleover', 'SmallGroup', 'AvaPlayerTarget' } ) do
		for i = 0, 4 do
			local unitTag = (i==0) and baseName or ( baseName .. i )
			if UF.CustomFrames[unitTag] then
				local unitFrame = UF.CustomFrames[unitTag]
				-- name should always be present
				unitFrame.name:SetHeight( 2 * sizeCaption )
				local nameHeight = unitFrame.name:GetTextHeight()
				-- update height of name container (topInfo)
				unitFrame.topInfo:SetHeight( nameHeight )
				-- levelIcon also should exit
				if unitFrame.levelIcon then
					unitFrame.levelIcon:SetDimensions( nameHeight, nameHeight )
					unitFrame.levelIcon:ClearAnchors()
					unitFrame.levelIcon:SetAnchor( LEFT, unitFrame.topInfo, LEFT, unitFrame.name:GetTextWidth()+1, 0 )
				end
				-- classIcon too - it looks better if a little bigger
				unitFrame.classIcon:SetDimensions( nameHeight+2, nameHeight+2 )
				-- friendIcon if exist - same idea
				if unitFrame.friendIcon then
					unitFrame.friendIcon:SetDimensions( nameHeight+2, nameHeight+2 )
					unitFrame.friendIcon:ClearAnchors()
					unitFrame.friendIcon:SetAnchor( RIGHT, unitFrame.classIcon, LEFT, nameHeight/6, 0)
				end
				-- botInfo contain alt bar or title/ava
				if unitFrame.botInfo then
					unitFrame.botInfo:SetHeight( nameHeight )
					-- alternative bar present on Player
					if unitFrame.alternative then
						unitFrame.alternative.backdrop:SetHeight( math.ceil( nameHeight / 3 )+2 )
						unitFrame.alternative.icon:SetDimensions( nameHeight, nameHeight )
					end
					-- title present only on Target
					if unitFrame.title then
						unitFrame.title:SetHeight( 2 * sizeCaption )
					end
				end
			end
		end
	end
end

--[[
 * Set dimensions of custom group frame and anchors or raid group members
 ]]--
function UF.CustomFramesApplyLayoutPlayer()

	-- Player frame
	if UF.CustomFrames.player then
		local player = UF.CustomFrames.player

		local phb = player[POWERTYPE_HEALTH] -- not a backdrop
		local pmb = player[POWERTYPE_MAGICKA] -- not a backdrop
		local psb = player[POWERTYPE_STAMINA] -- not a backdrop
		local alt = player.alternative -- not a backdrop
		
		player.tlw:SetDimensions( UF.SV.PlayerBarWidth, UF.SV.PlayerBarHeightHealth + 2*UF.SV.PlayerBarHeightOther + 2*UF.SV.PlayerBarSpacing + (phb.shieldbackdrop and UF.SV.CustomShieldBarHeight or 0) )
		player.control:SetDimensions( UF.SV.PlayerBarWidth, UF.SV.PlayerBarHeightHealth + 2*UF.SV.PlayerBarHeightOther + 2*UF.SV.PlayerBarSpacing + (phb.shieldbackdrop and UF.SV.CustomShieldBarHeight or 0) )
		player.topInfo:SetWidth( UF.SV.PlayerBarWidth )
		player.botInfo:SetWidth( UF.SV.PlayerBarWidth )

		player.name:SetWidth( UF.SV.PlayerBarWidth-50 )
		player.buffs:SetWidth( UF.SV.PlayerBarWidth )
		player.debuffs:SetWidth( UF.SV.PlayerBarWidth )

		player.levelIcon:ClearAnchors()
		player.levelIcon:SetAnchor( LEFT, player.topInfo, LEFT, player.name:GetTextWidth()+1, 0 )

		player.name:SetHidden( not UF.SV.PlayerEnableYourname )
		player.level:SetHidden( not UF.SV.PlayerEnableYourname )
		player.levelIcon:SetHidden( not UF.SV.PlayerEnableYourname )
		player.classIcon:SetHidden( not UF.SV.PlayerEnableYourname )

		local altW = math.ceil(UF.SV.PlayerBarWidth * 2/3)

		phb.backdrop:SetDimensions( UF.SV.PlayerBarWidth, UF.SV.PlayerBarHeightHealth )
		pmb.backdrop:ClearAnchors()
		if phb.shieldbackdrop then
			phb.shieldbackdrop:ClearAnchors()
			phb.shieldbackdrop:SetAnchor( TOP, phb.backdrop, BOTTOM, 0, 0 )
			phb.shieldbackdrop:SetDimensions( UF.SV.PlayerBarWidth, UF.SV.CustomShieldBarHeight )
			pmb.backdrop:SetAnchor( TOP, phb.shieldbackdrop, BOTTOM, 0, UF.SV.PlayerBarSpacing )
		else
			pmb.backdrop:SetAnchor( TOP, phb.backdrop, BOTTOM, 0, UF.SV.PlayerBarSpacing )
		end
		pmb.backdrop:SetDimensions( UF.SV.PlayerBarWidth, UF.SV.PlayerBarHeightOther )
		psb.backdrop:ClearAnchors()
		psb.backdrop:SetAnchor( TOP, pmb.backdrop, BOTTOM, 0, UF.SV.PlayerBarSpacing )
		psb.backdrop:SetDimensions( UF.SV.PlayerBarWidth, UF.SV.PlayerBarHeightOther )
		alt.backdrop:SetWidth( altW )
	
		phb.labelOne:SetDimensions( UF.SV.PlayerBarWidth-50, UF.SV.PlayerBarHeightHealth-2 )
		phb.labelTwo:SetDimensions( UF.SV.PlayerBarWidth-50, UF.SV.PlayerBarHeightHealth-2 )
		pmb.labelOne:SetDimensions( UF.SV.PlayerBarWidth-50, UF.SV.PlayerBarHeightOther-2 )
		pmb.labelTwo:SetDimensions( UF.SV.PlayerBarWidth-50, UF.SV.PlayerBarHeightOther-2 )
		psb.labelOne:SetDimensions( UF.SV.PlayerBarWidth-50, UF.SV.PlayerBarHeightOther-2 )
		psb.labelTwo:SetDimensions( UF.SV.PlayerBarWidth-50, UF.SV.PlayerBarHeightOther-2 )

		player.tlw:SetHidden(false)
	end

	-- Target frame
	if UF.CustomFrames.reticleover then
		local target = UF.CustomFrames.reticleover

		local thb = target[POWERTYPE_HEALTH] -- not a backdrop

		target.tlw:SetDimensions( UF.SV.TargetBarWidth, UF.SV.TargetBarHeight + (thb.shieldbackdrop and UF.SV.CustomShieldBarHeight or 0) )
		target.control:SetDimensions( UF.SV.TargetBarWidth, UF.SV.TargetBarHeight + (thb.shieldbackdrop and UF.SV.CustomShieldBarHeight or 0) )
		target.topInfo:SetWidth( UF.SV.TargetBarWidth )
		target.botInfo:SetWidth( UF.SV.TargetBarWidth )

		target.name:SetWidth( UF.SV.TargetBarWidth-50 )
		target.title:SetWidth( UF.SV.TargetBarWidth-50 )
		target.buffs:SetWidth( UF.SV.TargetBarWidth )
		target.debuffs:SetWidth( UF.SV.TargetBarWidth )

		target.levelIcon:ClearAnchors()
		target.levelIcon:SetAnchor( LEFT, target.topInfo, LEFT, target.name:GetTextWidth()+1, 0 )

		target.skull:SetDimensions( 2*UF.SV.TargetBarHeight, 2*UF.SV.TargetBarHeight )

		thb.backdrop:SetDimensions( UF.SV.TargetBarWidth, UF.SV.TargetBarHeight )
		if thb.shieldbackdrop then
			thb.shieldbackdrop:ClearAnchors()
			thb.shieldbackdrop:SetAnchor( TOP, thb.backdrop, BOTTOM, 0, 0 )
			thb.shieldbackdrop:SetDimensions( UF.SV.TargetBarWidth, UF.SV.CustomShieldBarHeight )
		end

		thb.labelOne:SetDimensions( UF.SV.TargetBarWidth-50, UF.SV.TargetBarHeight-2 )
		thb.labelTwo:SetDimensions( UF.SV.TargetBarWidth-50, UF.SV.TargetBarHeight-2 )

		target.tlw:SetHidden(false)
		target.control:SetHidden(false)
	end

	-- Another Target frame (for PvP)
	if UF.CustomFrames.AvaPlayerTarget then
		local target = UF.CustomFrames.AvaPlayerTarget

		local thb = target[POWERTYPE_HEALTH] -- not a backdrop

		target.tlw:SetDimensions( UF.SV.AvaTargetBarWidth, UF.SV.AvaTargetBarHeight + (thb.shieldbackdrop and UF.SV.CustomShieldBarHeight or 0) )
		target.control:SetDimensions( UF.SV.AvaTargetBarWidth, UF.SV.AvaTargetBarHeight + (thb.shieldbackdrop and UF.SV.CustomShieldBarHeight or 0) )
		target.topInfo:SetWidth( UF.SV.AvaTargetBarWidth )
		target.botInfo:SetWidth( UF.SV.AvaTargetBarWidth )
		
		target.name:SetWidth( UF.SV.AvaTargetBarWidth-50 )

		thb.backdrop:SetDimensions( UF.SV.AvaTargetBarWidth, UF.SV.AvaTargetBarHeight )
		if thb.shieldbackdrop then
			thb.shieldbackdrop:ClearAnchors()
			thb.shieldbackdrop:SetAnchor( TOP, thb.backdrop, BOTTOM, 0, 0 )
			thb.shieldbackdrop:SetDimensions( UF.SV.AvaTargetBarWidth, UF.SV.CustomShieldBarHeight )
		end

		thb.label:SetHeight( UF.SV.AvaTargetBarHeight-2 )
		thb.labelOne:SetHeight( UF.SV.AvaTargetBarHeight-2 )
		thb.labelTwo:SetHeight( UF.SV.AvaTargetBarHeight-2 )

		target.tlw:SetHidden(false)
		target.control:SetHidden(false)
	end
end
	
--[[
 * Set dimensions of custom group frame and anchors or raid group members
 ]]--
function UF.CustomFramesApplyLayoutGroup()
	if not UF.CustomFrames.SmallGroup1 then return end

	local groupBarHeight = UF.SV.GroupBarHeight
	if UF.SV.CustomShieldBarSeparate then
		groupBarHeight = groupBarHeight + UF.SV.CustomShieldBarHeight
	end		
	
	local group = UF.CustomFrames.SmallGroup1.tlw
	group:SetDimensions( UF.SV.GroupBarWidth, groupBarHeight*4 + UF.SV.GroupBarSpacing*3.5 )
	
	for i = 1, 4 do
		local unitFrame = UF.CustomFrames['SmallGroup' .. i]

		local ghb = unitFrame[POWERTYPE_HEALTH] -- this is not a backdrop

		unitFrame.control:ClearAnchors()
		unitFrame.control:SetAnchor( TOPLEFT, group, TOPLEFT, 0, 0.5*UF.SV.GroupBarSpacing + (groupBarHeight + UF.SV.GroupBarSpacing)*(i-1) )
		unitFrame.control:SetDimensions(UF.SV.GroupBarWidth, groupBarHeight)
		unitFrame.topInfo:SetWidth( UF.SV.GroupBarWidth-5 )

		unitFrame.name:SetWidth(UF.SV.GroupBarWidth-80)

		unitFrame.levelIcon:ClearAnchors()
		unitFrame.levelIcon:SetAnchor( LEFT, unitFrame.topInfo, LEFT, unitFrame.name:GetTextWidth()+1, 0 )

		ghb.backdrop:SetDimensions(UF.SV.GroupBarWidth, UF.SV.GroupBarHeight)
		if ghb.shieldbackdrop then
			ghb.shieldbackdrop:ClearAnchors()
			ghb.shieldbackdrop:SetAnchor( TOP, ghb.backdrop, BOTTOM, 0, 0 )
			ghb.shieldbackdrop:SetDimensions( UF.SV.GroupBarWidth, UF.SV.CustomShieldBarHeight )
		end

		ghb.labelOne:SetDimensions(UF.SV.GroupBarWidth-50, UF.SV.GroupBarHeight-2)
		ghb.labelTwo:SetDimensions(UF.SV.GroupBarWidth-50, UF.SV.GroupBarHeight-2)
	end

	group:SetHidden( false )
end

--[[
 * Set dimensions of custom raid frame and anchors or raid group members
 ]]--
function UF.CustomFramesApplyLayoutRaid()
	if not UF.CustomFrames.RaidGroup1 then return end

	local itemsPerColumn = 
		( UF.SV.RaidLayout == '6 x 4' ) and 4 or
		( UF.SV.RaidLayout == '4 x 6' ) and 6 or
		( UF.SV.RaidLayout == '3 x 8' ) and 8 or
		( UF.SV.RaidLayout == '2 x 12' ) and 12 or
		24

	local spacerHeight = 3
	local spacersPerColumn = { [4] = 1, [6] = 1.5, [8] = 2, [12] = 3, [24] = 6 }

	local raid = UF.CustomFrames.RaidGroup1.tlw
	
	raid:SetDimensions( UF.SV.RaidBarWidth * (24/itemsPerColumn) + (UF.SV.RaidSpacers and spacerHeight*(itemsPerColumn/4) or 0), UF.SV.RaidBarHeight * itemsPerColumn )

	-- for preview let us consider that large raid consists of 2 groups of 12 players, and display 2 independent preview backdrops
	-- they do not overlap, except for the case of '3 x 8' layout
	local groupWigth = UF.SV.RaidBarWidth * ( itemsPerColumn == 24 and 1 or math.floor(0.5 + 12/itemsPerColumn) )
	local groupHeight = UF.SV.RaidBarHeight * math.min(12,itemsPerColumn)

	raid.preview:SetDimensions( groupWigth, groupHeight )
	raid.preview2:SetDimensions( groupWigth, groupHeight )
	-- raid.preview is already anchored to TOPLEFT,TOPLEFT,0,0
	raid.preview2:ClearAnchors()
	raid.preview2:SetAnchor(TOPLEFT, raid, TOPLEFT, UF.SV.RaidBarWidth*math.floor(12/itemsPerColumn), UF.SV.RaidBarHeight*( itemsPerColumn == 24 and 12 or 0 ) )

	local column = 0	-- 0,1,2,3,4,5
	local row = 0		-- 1,2,3,...,24
	for i = 1, 24 do
		if row == itemsPerColumn then
			column = column + 1
			row = 1
		else
			row = row + 1
		end

		local unitFrame = UF.CustomFrames['RaidGroup' .. i]

		unitFrame.control:ClearAnchors()
		unitFrame.control:SetAnchor( TOPLEFT, raid, TOPLEFT, UF.SV.RaidBarWidth*column, UF.SV.RaidBarHeight*(row-1) + (UF.SV.RaidSpacers and spacerHeight*(math.floor((i-1)/4)-math.floor(column*itemsPerColumn/4)) or 0) )
		unitFrame.control:SetDimensions( UF.SV.RaidBarWidth, UF.SV.RaidBarHeight )

		unitFrame.name:SetDimensions( UF.SV.RaidBarWidth-45, UF.SV.RaidBarHeight-2 )
		unitFrame.dead:SetDimensions( 75, UF.SV.RaidBarHeight-2 )

	end

	raid:SetHidden( false )
end

--[[
 * Set dimensions of custom raid frame and anchors or raid group members
 ]]--
function UF.CustomFramesApplyLayoutBosses()
	if not UF.CustomFrames.boss1 then return end

	local bosses = UF.CustomFrames.boss1.tlw
	
	bosses:SetDimensions( UF.SV.PlayerBarWidth, UF.SV.TargetBarHeight * 6 + 2 * 5)

	for i = 1, 6 do
		local unitFrame = UF.CustomFrames['boss' .. i]

		unitFrame.control:ClearAnchors()
		unitFrame.control:SetAnchor( TOPLEFT, bosses, TOPLEFT, 0, (UF.SV.TargetBarHeight+2)*(i-1) )
		unitFrame.control:SetDimensions( UF.SV.PlayerBarWidth, UF.SV.TargetBarHeight )

		unitFrame.name:SetDimensions( UF.SV.PlayerBarWidth-50, UF.SV.TargetBarHeight-2 )

		unitFrame[POWERTYPE_HEALTH].label:SetDimensions( UF.SV.PlayerBarWidth-50, UF.SV.TargetBarHeight-2 )
	end

	bosses:SetHidden( false )
end

--[[
 * This function reduces opacity of custom frames when player is out of combat and has full attributes
 ]]--
function UF.CustomFramesApplyInCombat()
	local idle = true
	if UF.SV.CustomOocAlphaPower then
		for _, value in pairs(g_statFull) do
			idle = idle and value
		end
	else
		idle = g_statFull.combat
	end
	
	local oocAlpha = 0.01 * UF.SV.CustomOocAlpha
	local incAlpha = 0.01 * UF.SV.CustomIncAlpha

	-- this applies only to player and target
	if UF.CustomFrames.player then
		UF.CustomFrames.player.control:SetAlpha( idle and oocAlpha or incAlpha )
	end
	if UF.CustomFrames.reticleover then
		UF.CustomFrames.reticleover.control:SetAlpha( ( idle and UF.SV.CustomOocAlphaTarget ) and oocAlpha or incAlpha )
	end
end

--[[----------------------------------------------------------
 * DEBUG FUNCTIONS
--]]----------------------------------------------------------
function UF.CustomFramesDebugGroup()
	for i = 1, 4 do
		local unitTag = 'SmallGroup' .. i
		UF.CustomFrames[unitTag].unitTag = 'player'
		UF.CustomFrames[unitTag].control:SetHidden(false)
		UF.UpdateStaticControls( UF.CustomFrames[unitTag] )
	end
	UF.CustomFrames.SmallGroup1.friendIcon:SetHidden(false)
	UF.CustomFrames.SmallGroup1.friendIcon:SetTexture("/esoui/art/campaign/campaignbrowser_friends.dds")
	UF.OnLeaderUpdate( nil, 'SmallGroup1' )
end

function UF.CustomFramesDebugRaid()
	for i = 1, 24 do
		local unitTag = 'RaidGroup' .. i
		UF.CustomFrames[unitTag].unitTag = 'player'
		UF.CustomFrames[unitTag].control:SetHidden(false)
		UF.UpdateStaticControls( UF.CustomFrames[unitTag] )
	end
	UF.OnLeaderUpdate( nil, 'RaidGroup1' )
end

--[[----------------------------------------------------------
	GUILD MEMBER INDEX

	Following functions and data structures are used to keep local index
	of all characters and players for all 5 possible guilds
--]]----------------------------------------------------------

local g_guildMemberIndexDirty = true
local g_guildMemberIndexDisplayNames = nil

--[[
 * Used to invalidate local index. Called on several event listeners
 ]]--
function UF.InvalidateGuildMemberIndex()
	g_guildMemberIndexDirty = true
end

--[[
 * Used to rebuild from scratch local index
 ]]--
function UF.RebuildGuildMemberIndex()
	-- clear tables
	g_guildMemberIndexDisplayNames = {}

	for i = 1, MAX_GUILDS do
		UF.OnGuildSelfJoinedGuild(EVENT_GUILD_SELF_JOINED_GUILD, GetGuildId(i))
	end
	g_guildMemberIndexDirty = false
end

local function UpdateGuildMember( gid, mid )
	local displayName = GetGuildMemberInfo(gid, mid)

	-- remember in which guilds is this player
	if g_guildMemberIndexDisplayNames[displayName] then
		g_guildMemberIndexDisplayNames[displayName][gid] = true
	else
		g_guildMemberIndexDisplayNames[displayName] = { [gid] = true }
	end
end

--[[
 * Used to add characters from one specific guild.
 * Called on EVENT_GUILD_SELF_JOINED_GUILD listener
 ]]--
function UF.OnGuildSelfJoinedGuild(eventCode, guildId)
	if not g_guildMemberIndexDisplayNames then return end
	if not guildId or guildId == 0 then return end

	local memberCount = GetNumGuildMembers(guildId)
	for mid = 1, memberCount, 1 do
		UpdateGuildMember( guildId, mid )
	end

	-- finally purge information about yourself
	g_guildMemberIndexDisplayNames[GetDisplayName()] = nil
end

--[[
 * Used to update information on single player in single guild
 * Called on EVENT_GUILD_MEMBER_ADDED and EVENT_GUILD_MEMBER_CHARACTER_UPDATED listeners
 ]]--
function UF.OnGuildMemberAdded(eventCode, guildId, displayName)
	if not g_guildMemberIndexDisplayNames then return end
	if not guildId or guildId == 0 then return end

	local memberCount = GetNumGuildMembers(guildId)
	for mid = 1, memberCount, 1 do
		if GetGuildMemberInfo(guildId, mid) == displayName then
			UpdateGuildMember( guildId, mid )
		end
	end
end

--[[
 * Used to remove single player from local list
 * Called on EVENT_GUILD_MEMBER_REMOVED  event listeners
 ]]--
function UF.OnGuildMemberRemoved(eventCode, guildId, displayName, characterName)
	if not g_guildMemberIndexDisplayNames then return end
	if not guildId or guildId == 0 then return end

	if not g_guildMemberIndexDisplayNames[displayName] then return end

	g_guildMemberIndexDisplayNames[displayName][guildId] = nil
	-- if this player is not in any other of your guilds, then purge remaining information
	if #g_guildMemberIndexDisplayNames[displayName] == 0 then
		g_guildMemberIndexDisplayNames[displayName] = nil
	end
end

--[[
 * Used to query if characterName is local list
 ]]--
function UF.GetGuildDisplayNameInfo( displayName )
	if g_guildMemberIndexDirty then UF.RebuildGuildMemberIndex() end
	return g_guildMemberIndexDisplayNames[displayName]
end
