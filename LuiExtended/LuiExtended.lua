------------------
-- LUIE namespace
LUIE       = {}
LUIE.name  = "LuiExtended"
LUIE.components  = {}

local g_Version = "4.40"

-- Saved variables options
LUIE.SVName = 'LUIESV'
LUIE.SVVer  = 1

-- default settings
LUIE.D = {
	UnitFrames_Enabled      = true,
	InfoPanel_Enabled		= true,
	CombatInfo_Enabled		= true,
	SpellCastBuff_Enable	= true,
	DamageMeter_Enable		= false,
	StartupInfo				= false,
}
LUIE.SV = nil

local strformat = string.format

-- Global fonts table to use in other parts of this addon
LUIE.Fonts = {
	["ProseAntique"]			= "/EsoUI/Common/Fonts/ProseAntiquePSMT.otf",
	["Consolas"]				= "/EsoUI/Common/Fonts/consola.ttf",
	["Futura Condensed"]		= "/EsoUI/Common/Fonts/FTN57.otf",
	["Futura Condensed Bold"]	= "/EsoUI/Common/Fonts/FTN87.otf",
	["Futura Condensed Light"]	= "/EsoUI/Common/Fonts/FTN47.otf",
	["Skyrim Handwritten"]		= "/EsoUI/Common/Fonts/Handwritten_Bold.otf",
	["Trajan Pro"]				= "/EsoUI/Common/Fonts/trajanpro-regular.otf",
	["Univers 55"]				= "/EsoUI/Common/Fonts/univers55.otf",
	["Univers 57"]				= "/EsoUI/Common/Fonts/univers57.otf",
	["Univers 67"]				= "/EsoUI/Common/Fonts/univers67.otf",
	["Fontin Bold"]				= "/LuiExtended/assets/fontin_sans_b.otf",
	["Fontin Italic"]			= "/LuiExtended/assets/fontin_sans_i.otf",
	["Fontin Regular"]			= "/LuiExtended/assets/fontin_sans_r.otf",
	["Fontin SmallCaps"]		= "/LuiExtended/assets/fontin_sans_sc.otf",
	["EnigmaBold"]              = [[/LuiExtended/assets/EnigmaBold.ttf]],
	['Adventure']				= [[/LuiExtended/assets/adventure.ttf]],
	['Bazooka']					= [[/LuiExtended/assets/bazooka.ttf]],
	['Cooline']					= [[/LuiExtended/assets/cooline.ttf]],
	['Diogenes']				= [[/LuiExtended/assets/diogenes.ttf]],
	['Ginko']					= [[/LuiExtended/assets/ginko.ttf]],
	['Heroic']					= [[/LuiExtended/assets/heroic.ttf]],
	['Metamorphous']			= [[/LuiExtended/assets/metamorphous.otf]],
	['Porky']					= [[/LuiExtended/assets/porky.ttf]],
	['Roboto Bold']				= [[/LuiExtended/assets/Roboto-Bold.ttf]],
	['Roboto Bold Italic']		= [[/LuiExtended/assets/Roboto-BoldItalic.ttf]],
	['Talisman']				= [[/LuiExtended/assets/talisman.ttf]],
	['Transformers']			= [[/LuiExtended/assets/transformers.ttf]],
	['Yellowjacket']			= [[/LuiExtended/assets/yellowjacket.ttf]],
}

LUIE.StatusbarTextures = {
	["Aluminium"]				= '/LuiExtended/assets/Aluminium.dds',
	["Elder Scrolls Gradient"]	= '/LuiExtended/assets/ElderScrollsGrad.dds',
	["Glass"]					= '/LuiExtended/assets/Glass.dds',
	["Glaze"]					= '/LuiExtended/assets/Glaze.dds',
	["Horizontal Gradient 1"]	= '/LuiExtended/assets/HorizontalGrad.dds',
	["Horizontal Gradient 2"]	= '/LuiExtended/assets/HorizontalGradV2.dds',
	["Inner Glow"]				= '/LuiExtended/assets/InnerGlow.dds',
	["Inner Shadow"]			= '/LuiExtended/assets/InnerShadow.dds',
	["Inner Shadow Glossy"]		= '/LuiExtended/assets/InnerShadowGloss.dds',
	["Minimalistic"]			= '/LuiExtended/assets/Minimalistic.dds',
	["Round"]					= '/LuiExtended/assets/Round.dds',
	["Sand Paper 1"]			= '/LuiExtended/assets/SandPaper.dds',
	["Sand Paper 2"]			= '/LuiExtended/assets/SandPaperV2.dds',
	["Shadow"]					= '/LuiExtended/assets/Shadow.dds',
	["Smooth"]					= '/LuiExtended/assets/Smooth.dds',
}

--[[
 * Load saved settings
 ]]--
local function LUIE_LoadSavedVars()
	-- addon options
	LUIE.SV = ZO_SavedVars:NewAccountWide( LUIE.SVName, LUIE.SVVer, nil, LUIE.D )
end

--[[
 * Load additional fonts and status bar textures from LMP if it is present in environment
 ]]--
local function LUIE_LoadMedia()
	if LibStub == nil then return end
	local LMP = LibStub:GetLibrary("LibMediaProvider-1.0", true)
	if LMP == nil then return end
	
	-- Update Fonts
	for _, f in pairs(LMP:List(LMP.MediaType.FONT)) do
		if not LUIE.Fonts[f] then
			LUIE.Fonts[f] = LMP:Fetch(LMP.MediaType.FONT, f)
		end
	end
	
	-- Update StatusBar textures
	for _, s in pairs(LMP:List(LMP.MediaType.STATUSBAR)) do
		if not LUIE.StatusbarTextures[s] then
			LUIE.StatusbarTextures[s] = LMP:Fetch(LMP.MediaType.STATUSBAR, s)
		end
	end
end

--[[
 * Create Settings menu
 ]]--
local function LUIE_CreateSettings()
	if LibStub == nil then return end
	local LAM2 = LibStub("LibAddonMenu-2.0")
	if LAM2 == nil then return end

	local L = LUIE.GetLocale()

	-- helper local flag
	local l_BuffsMovingEnabled = false

	local FontsList = {}
	for f in pairs( LUIE.Fonts ) do
		table.insert(FontsList, f)
	end

	local FontsListCombatInfo = {}
	for key, _ in pairs( LUIE.CombatInfo.FontFamilies ) do
		table.insert( FontsListCombatInfo, key )
	end

	local StatusbarTexturesList = {}
	for key, _ in pairs( LUIE.StatusbarTextures ) do
		table.insert( StatusbarTexturesList, key )
	end

	local styleOptions = {"normal", "outline", "shadow", "soft-shadow-thick", "soft-shadow-thin", "thick-outline"}
	local NameDisplayOptions = {"Account", "Character"}

	local formatOptions = {
		"Nothing",
		"Current",
		"Current + Shield",
		"Max",
		"Percentage%",
		"Current / Max",
		"Current + Shield / Max",
		"Current / Max (Percentage%)",
		"Current + Shield / Max (Percentage%)",
		"Current (Percentage%)",
		"Current + Shield (Percentage%)"
	}
	local rotationOptions = { "Horizontal", "Vertical" }
	local rotationOptionsKeys = { ["Horizontal"] = 1, ["Vertical"] = 2 }
	local hAlignOptions = { L.Setting_Left, L.Setting_Center, L.Setting_Right }
	local vAlignOptions = { "Top", "Middle", "Bottom" }

	local panelData = {
		type = 'panel',
		name = LUIE.name,
		displayName = "LUIE Settings",
		author = "Upularity",
		version = g_Version,
		slashCommand = "/luiset",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local optionsData = {
		[1] = {
			type = "button",
			name = "Reload UI",
			tooltip = "This will reload UI",
			func = function() ReloadUI("ingame") end,
			width = "full",
		},
		[2] = {
			type = "submenu",
			name = "Info Panel Options",
			controls = {
				[1] = {
					type = "checkbox",
					name = "Show Info Panel",
					tooltip = "Info mini panel contains clock, framerate, latency, mount info, inventory and items durability status.",
					getFunc = function() return LUIE.SV.InfoPanel_Enabled end,
					setFunc = function(value) LUIE.SV.InfoPanel_Enabled = value end,
					width = "full",
					warning = "Will need to reload the UI.",
					default = LUIE.D.InfoPanel_Enabled,
				},
				[2] = {
					type = "checkbox",
					name = "Unlock panel",
					tooltip = "Allow mouse dragging for Info Panel.",
					getFunc = function() return LUIE.InfoPanel.panelUnlocked end,
					setFunc = LUIE.InfoPanel.SetMovingState,
					width = "half",
					default = false,
					disabled = function() return not LUIE.SV.InfoPanel_Enabled end,
					resetFunc = LUIE.InfoPanel.ResetPosition,
				},
				[3] = {
					type = "button",
					name = "Reset position",
					tooltip = "This will reset position of Info Panel into screen top right corner.",
					func = LUIE.InfoPanel.ResetPosition,
					width = "half",
				},
				[4] = {
					type = "slider",
					name = "Info Panel Scale, %",
					tooltip = "Used to magnify size of Info Panel on large resolution displays.",
					min = 100, max = 300, step = 10,
					getFunc = function() return LUIE.InfoPanel.SV.panelScale end,
					setFunc = function(value) LUIE.InfoPanel.SV.panelScale = value LUIE.InfoPanel.SetScale() end,
					width = "full",
					default = 100,
					disabled = function() return not LUIE.SV.InfoPanel_Enabled end,
				},
				[5] = {
					type = "header",
					name = "Info Panel elements",
					width = "full",
				},
				[6] = {
					type = "checkbox",
					name = "Show Latency",
					--tooltip = "",
					getFunc = function() return not LUIE.InfoPanel.SV.HideLatency end,
					setFunc = function(value) LUIE.InfoPanel.SV.HideLatency = not value LUIE.InfoPanel.RearrangePanel() end,
					width = "full",
					default = true,
					disabled = function() return not LUIE.SV.InfoPanel_Enabled end,
				},
				[7] = {
					type = "checkbox",
					name = "Show Clock",
					--tooltip = "",
					getFunc = function() return not LUIE.InfoPanel.SV.HideClock end,
					setFunc = function(value) LUIE.InfoPanel.SV.HideClock = not value LUIE.InfoPanel.RearrangePanel() end,
					width = "full",
					default = true,
					disabled = function() return not LUIE.SV.InfoPanel_Enabled end,
				},
				[8] = {
					type = "checkbox",
					name = "Show FPS",
					--tooltip = "",
					getFunc = function() return not LUIE.InfoPanel.SV.HideFPS end,
					setFunc = function(value) LUIE.InfoPanel.SV.HideFPS = not value LUIE.InfoPanel.RearrangePanel() end,
					width = "full",
					default = true,
					disabled = function() return not LUIE.SV.InfoPanel_Enabled end,
				},
				[9] = {
					type = "checkbox",
					name = "Show Mount Feed Timer |c00FFFF*|r",
					tooltip = "(*) Once you have trained your mount to maximum level this field will be automatically hidden for current character.",
					getFunc = function() return not LUIE.InfoPanel.SV.HideMountFeed end,
					setFunc = function(value) LUIE.InfoPanel.SV.HideMountFeed = not value LUIE.InfoPanel.RearrangePanel() end,
					width = "full",
					default = true,
					disabled = function() return not LUIE.SV.InfoPanel_Enabled end,
				},
				[10] = {
					type = "checkbox",
					name = "Show Armour Durability",
					--tooltip = "",
					getFunc = function() return not LUIE.InfoPanel.SV.HideArmour end,
					setFunc = function(value) LUIE.InfoPanel.SV.HideArmour = not value LUIE.InfoPanel.RearrangePanel() end,
					width = "full",
					default = true,
					disabled = function() return not LUIE.SV.InfoPanel_Enabled end,
				},
				[11] = {
					type = "checkbox",
					name = "Show Weapons Charges",
					--tooltip = "",
					getFunc = function() return not LUIE.InfoPanel.SV.HideWeapons end,
					setFunc = function(value) LUIE.InfoPanel.SV.HideWeapons = not value LUIE.InfoPanel.RearrangePanel() end,
					width = "full",
					default = true,
					disabled = function() return not LUIE.SV.InfoPanel_Enabled end,
				},
				[12] = {
					type = "checkbox",
					name = "Show Bags Space",
					--tooltip = "",
					getFunc = function() return not LUIE.InfoPanel.SV.HideBags end,
					setFunc = function(value) LUIE.InfoPanel.SV.HideBags = not value LUIE.InfoPanel.RearrangePanel() end,
					width = "full",
					default = true,
					disabled = function() return not LUIE.SV.InfoPanel_Enabled end,
				},
				[13] = {
					type = "checkbox",
					name = "Show Soul Gems",
					--tooltip = "",
					getFunc = function() return not LUIE.InfoPanel.SV.HideGems end,
					setFunc = function(value) LUIE.InfoPanel.SV.HideGems = not value LUIE.InfoPanel.RearrangePanel() end,
					width = "full",
					default = true,
					disabled = function() return not LUIE.SV.InfoPanel_Enabled end,
				},
				[14] = {
					type = "checkbox",
					name = "Show Imperial City Trophy count",
					--tooltip = "",
					getFunc = function() return LUIE.InfoPanel.SV.ShowTrophy end,
					setFunc = function(value) LUIE.InfoPanel.SV.ShowTrophy = value LUIE.InfoPanel.RearrangePanel() end,
					width = "full",
					default = false,
					disabled = function() return not LUIE.SV.InfoPanel_Enabled end,
				},
				[15] = {
					type = "header",
					name = "Miscellaneous",
					width = "full",
				},
				[16] = {
					type = "checkbox",
					name = "Disable colours on read-only values",
					tooltip = "This option allows you to disable value-dependent colour of the information label for items that you do not have direct control: Currently this includes FPS and Latency labels.",
					getFunc = function() return LUIE.InfoPanel.SV.DisableInfoColours end,
					setFunc = function(value) LUIE.InfoPanel.SV.DisableInfoColours = value end,
					width = "full",
					default = false,
					disabled = function() return not LUIE.SV.InfoPanel_Enabled end,
				},				
			},
		},
		[3] = {
			type = "submenu",
			name = "Combat Info Options",
			controls = {
				[1] = {
					type = "checkbox",
					name = "Show Combat Info",
					tooltip = "Displays various floating text for damage done, healing received, experience and alliance points gain.",
					getFunc = function() return LUIE.SV.CombatInfo_Enabled end,
					setFunc = function(value) LUIE.SV.CombatInfo_Enabled = value end,
					width = "full",
					warning = "Will need to reload the UI.",
					default = LUIE.D.CombatInfo_Enabled,
				},
				[2] = {
					type = "checkbox",
					name = "Display CoolDowns",
					tooltip = "Show cooldown timers for active abilities.",
					getFunc = function() return LUIE.CombatInfo.SV.CoolDown end,
					setFunc = function(value) LUIE.CombatInfo.SV.CoolDown = value end,
					width = "full",
					default = LUIE.CombatInfo.D.CoolDown,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
				},
				[3] = {
					type = "header",
					name = "Ultimate Tracking options",
					width = "full",
				},
				[4] = {
					type = "checkbox",
					name = "Show current Ultimate value",
					tooltip = "Display current ultimate ability resource level above ultimate skill slot.",
					getFunc = function() return LUIE.CombatInfo.SV.UltimateEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.UltimateEnabled = value LUIE.CombatInfo.OnSlotsFullUpdate(nil) end,
					width = "full",
					default = LUIE.CombatInfo.D.UltimateEnabled,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
				},
				[5] = {
					type = "checkbox",
					name = "Hide percent label when full",
					tooltip = "Remove percentage label from ultimate slot when ability becomes ready.",
					getFunc = function() return LUIE.CombatInfo.SV.UltimateHideFull end,
					setFunc = function(value) LUIE.CombatInfo.SV.UltimateHideFull = value end,
					width = "full",
					default = LUIE.CombatInfo.D.UltimateHideFull,
					disabled = function() return not ( LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.UltimateEnabled ) end,
				},
				[6] = {
					type = "checkbox",
					name = "Enable Ultimate Ready alert",
					tooltip = "Enable notification display when ability becomes ready.",
					getFunc = function() return LUIE.CombatInfo.SV.UltimateAlert end,
					setFunc = function(value) LUIE.CombatInfo.SV.UltimateAlert = value end,
					width = "full",
					default = LUIE.CombatInfo.D.UltimateAlert,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
				},
				[7] = {
					type = "checkbox",
					name = "Show Ultimate Generation texture",
					tooltip = "Display special texture under Ultimate skill button when in-combat ultimate generation is detected.",
					getFunc = function() return LUIE.CombatInfo.SV.UltimateGeneration end,
					setFunc = function(value) LUIE.CombatInfo.SV.UltimateGeneration = value end,
					width = "full",
					default = LUIE.CombatInfo.D.UltimateGeneration,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
				},
				[8] = {
					type = "header",
					name = "Cloud-type areas text options",
					width = "full",
				},
				[9] = {
					type = "checkbox",
					name = "Unlock Areas",
					tooltip = "Allow mouse dragging for different floating text areas.",
					getFunc = function() return LUIE.CombatInfo.panelUnlocked end,
					setFunc = LUIE.CombatInfo.SetMovingState,
					width = "half",
					default = false,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
					resetFunc = LUIE.CombatInfo.ResetPosition,
				},
				[10] = {
					type = "button",
					name = "Reset position",
					tooltip = "This will reset position of Info Panel into screen top right corner.",
					func = LUIE.CombatInfo.ResetPosition,
					width = "half",
				},
				[11] = {
					type = "checkbox",
					name = "Enable Cloud-type areas",
					--tooltip = "",
					getFunc = function() return LUIE.CombatInfo.SV.CloudTextEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.CloudTextEnabled = value end,
					width = "full",
					warning = "Will need to reload the UI.",
					default = LUIE.CombatInfo.D.CloudTextEnabled,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
				},
				[12] = {
					type = "slider",
					name = "Large Font Size",
					tooltip = "Large font is used to for critical damage hits and experience gain labels.",
					min = 20, max = 50, step = 2,
					getFunc = function() return LUIE.CombatInfo.SV.FontCloudSizeLarge end,
					setFunc = function(value) LUIE.CombatInfo.SV.FontCloudSizeLarge = value LUIE.CombatInfo.PrepareFonts(true) end,
					width = "full",
					default = LUIE.CombatInfo.D.FontCloudSizeLarge,
					disabled = function() return not (LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.CloudTextEnabled) end,
				},
				[13] = {
					type = "slider",
					name = "Medium Font Size",
					tooltip = "Medium font is used to for normal damage hits, alliance points gain and drain/energize labels.",
					min = 14, max = 40, step = 2,
					getFunc = function() return LUIE.CombatInfo.SV.FontCloudSizeMedium end,
					setFunc = function(value) LUIE.CombatInfo.SV.FontCloudSizeMedium = value LUIE.CombatInfo.PrepareFonts(true) end,
					width = "full",
					default = LUIE.CombatInfo.D.FontCloudSizeMedium,
					disabled = function() return not (LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.CloudTextEnabled) end,
				},
				[14] = {
					type = "slider",
					name = "Small Font Size",
					tooltip = "Small font is used to for DOT damage hits, all incoming damage and all healing done and received labels.",
					min = 12, max = 30, step = 2,
					getFunc = function() return LUIE.CombatInfo.SV.FontCloudSizeSmall end,
					setFunc = function(value) LUIE.CombatInfo.SV.FontCloudSizeSmall = value LUIE.CombatInfo.PrepareFonts(true) end,
					width = "full",
					default = LUIE.CombatInfo.D.FontCloudSizeSmall,
					disabled = function() return not (LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.CloudTextEnabled) end,
				},
				[15] = {
					type = "checkbox",
					name = "Show label icons",
					tooltip = "Display abilities icons (if available) next to each text label.",
					getFunc = function() return LUIE.CombatInfo.SV.ShowIconsCloud end,
					setFunc = function(value) LUIE.CombatInfo.SV.ShowIconsCloud = value end,
					width = "full",
					default = LUIE.CombatInfo.D.ShowIconsCloud,
					disabled = function() return not (LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.CloudTextEnabled) end,
				},
				[16] = {
					type = "header",
					name = "Scrolling-type areas text options",
					width = "full",
				},
				[17] = {
					type = "checkbox",
					name = "Enable Scrolling-type areas",
					--tooltip = "",
					getFunc = function() return LUIE.CombatInfo.SV.ScrollTextEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.ScrollTextEnabled = value end,
					width = "full",
					warning = "Will need to reload the UI.",
					default = LUIE.CombatInfo.D.ScrollTextEnabled,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
				},
				[18] = {
					type = "slider",
					name = "Large Font Size",
					tooltip = "Large font is used to for critical damage hits and experience gain labels.",
					min = 20, max = 50, step = 2,
					getFunc = function() return LUIE.CombatInfo.SV.FontScrollSizeLarge end,
					setFunc = function(value) LUIE.CombatInfo.SV.FontScrollSizeLarge = value LUIE.CombatInfo.PrepareFonts(true) end,
					width = "full",
					default = LUIE.CombatInfo.D.FontScrollSizeLarge,
					disabled = function() return not (LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.ScrollTextEnabled) end,
				},
				[19] = {
					type = "slider",
					name = "Medium Font Size",
					tooltip = "Medium font is used to for normal damage hits, alliance points gain and drain/energize labels.",
					min = 14, max = 40, step = 2,
					getFunc = function() return LUIE.CombatInfo.SV.FontScrollSizeMedium end,
					setFunc = function(value) LUIE.CombatInfo.SV.FontScrollSizeMedium = value LUIE.CombatInfo.PrepareFonts(true) end,
					width = "full",
					default = LUIE.CombatInfo.D.FontScrollSizeMedium,
					disabled = function() return not (LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.ScrollTextEnabled) end,
				},
				[20] = {
					type = "slider",
					name = "Small Font Size",
					tooltip = "Small font is used to for DOT damage hits, all incoming damage and all healing done and received labels.",
					min = 12, max = 30, step = 2,
					getFunc = function() return LUIE.CombatInfo.SV.FontScrollSizeSmall end,
					setFunc = function(value) LUIE.CombatInfo.SV.FontScrollSizeSmall = value LUIE.CombatInfo.PrepareFonts(true) end,
					width = "full",
					default = LUIE.CombatInfo.D.FontScrollSizeSmall,
					disabled = function() return not (LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.ScrollTextEnabled) end,
				},
				[21] = {
					type = "checkbox",
					name = "Show label icons",
					tooltip = "Display abilities icons (if available) next to each text label.",
					getFunc = function() return LUIE.CombatInfo.SV.ShowIconsScroll end,
					setFunc = function(value) LUIE.CombatInfo.SV.ShowIconsScroll = value end,
					width = "full",
					default = LUIE.CombatInfo.D.ShowIconsScroll,
					disabled = function() return not (LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.ScrollTextEnabled) end,
				},
				[22] = {
					type = "checkbox",
					name = "Allow drop of some queued events",
					tooltip = "If the event queue is getting too long during intensive fight allow to drop of some non too important events.",
					getFunc = function() return LUIE.CombatInfo.SV.PurgeExpiredScroll end,
					setFunc = function(value) LUIE.CombatInfo.SV.PurgeExpiredScroll = value end,
					width = "full",
					default = LUIE.CombatInfo.D.PurgeExpiredScroll,
					disabled = function() return not (LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.ScrollTextEnabled) end,
				},
				[23] = {
					type = "header",
					name = "Common options",
					width = "full",
				},
				[24] = {
					type = "dropdown",
					name = "Font family for labels",
					tooltip = "Font family to use on floating text labels.",
					choices = FontsListCombatInfo,
					getFunc = function() return LUIE.CombatInfo.SV.FontFamily end,
					setFunc = function(var) LUIE.CombatInfo.SV.FontFamily = var LUIE.CombatInfo.PrepareFonts(true) end,
					width = "full",
					sort = "name-up",
					default = LUIE.CombatInfo.D.FontFamily,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
				},
				[25] = {
					type = "checkbox",
					name = "Show combat related text",
					tooltip = "Display floating numbers for various combat related events (damage, healing, etc).",
					getFunc = function() return LUIE.CombatInfo.SV.CombatEventsEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.CombatEventsEnabled = value LUIE.CombatInfo.RegisterCombatEvent() end,
					width = "full",
					default = LUIE.CombatInfo.D.CombatEventsEnabled,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
				},
				[26] = {
					type = "checkbox",
					name = "Throttle values",
					tooltip = "Accumulates multiple hits into one label.",
					getFunc = function() return LUIE.CombatInfo.SV.ThrottleEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.ThrottleEnabled = value end,
					width = "full",
					default = LUIE.CombatInfo.D.ThrottleEnabled,
					disabled = function() return not ( LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.CombatEventsEnabled ) end,
				},
				[27] = {
					type = "checkbox",
					name = "Show Incoming Damage-Over-Time",
					tooltip = "Display floating numbers for incoming DOTs events",
					getFunc = function() return LUIE.CombatInfo.SV.DotsInEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.DotsInEnabled = value end,
					width = "full",
					default = LUIE.CombatInfo.D.DotsInEnabled,
					disabled = function() return not ( LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.CombatEventsEnabled ) end,
				},
				[28] = {
					type = "checkbox",
					name = "Show Outging Damage-Over-Time",
					tooltip = "Display floating numbers for outging DOTs events",
					getFunc = function() return LUIE.CombatInfo.SV.DotsOutEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.DotsOutEnabled = value end,
					width = "full",
					default = LUIE.CombatInfo.D.DotsOutEnabled,
					disabled = function() return not ( LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.CombatEventsEnabled ) end,
				},
				[29] = {
					type = "checkbox",
					name = "Show Incoming Healing",
					tooltip = "Display floating numbers for incoming healing events",
					getFunc = function() return LUIE.CombatInfo.SV.HealingInEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.HealingInEnabled = value end,
					width = "full",
					default = LUIE.CombatInfo.D.HealingInEnabled,
					disabled = function() return not ( LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.CombatEventsEnabled ) end,
				},
				[30] = {
					type = "checkbox",
					name = "Show Outging Healing",
					tooltip = "Display floating numbers for outgoing healing events",
					getFunc = function() return LUIE.CombatInfo.SV.HealingOutEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.HealingOutEnabled = value end,
					width = "full",
					default = LUIE.CombatInfo.D.HealingOutEnabled,
					disabled = function() return not ( LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.CombatEventsEnabled ) end,
				},
				[31] = {
					type = "checkbox",
					name = "Enable damage-type dependent colours",
					tooltip = "Make colours of labels for outgoing damage dependent on damage type.",
					getFunc = function() return LUIE.CombatInfo.SV.DamageColoured end,
					setFunc = function(value) LUIE.CombatInfo.SV.DamageColoured = value end,
					width = "full",
					default = LUIE.CombatInfo.D.DamageColoured,
					disabled = function() return not ( LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.CombatEventsEnabled ) end,
				},
				[32] = {
					type = "checkbox",
					name = "Show target crowd-control events",
					tooltip = "Display floating when target is stunned or interrupted.",
					getFunc = function() return LUIE.CombatInfo.SV.CombatCCEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.CombatCCEnabled = value LUIE.CombatInfo.RegisterCombatEvent() end,
					width = "full",
					default = LUIE.CombatInfo.D.CombatCCEnabled,
					disabled = function() return not ( LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.CombatEventsEnabled ) end,
				},
				[33] = {
					type = "checkbox",
					name = "Show Attributes Drain text",
					tooltip = "Display player magicka/stamina loss",
					getFunc = function() return LUIE.CombatInfo.SV.DrainEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.DrainEnabled = value end,
					width = "full",
					default = LUIE.CombatInfo.D.DrainEnabled,
					disabled = function() return not ( LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.CombatEventsEnabled ) end,
				},
				[34] = {
					type = "checkbox",
					name = "Show Attributes Energized text",
					tooltip = "Display player magicka/stamina return",
					getFunc = function() return LUIE.CombatInfo.SV.EnergizeEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.EnergizeEnabled = value end,
					width = "full",
					default = LUIE.CombatInfo.D.EnergizeEnabled,
					disabled = function() return not ( LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.CombatEventsEnabled ) end,
				},
				[35] = {
					type = "checkbox",
					name = "Show experience gain text",
					tooltip = "Display floating numbers of gained experience.",
					getFunc = function() return LUIE.CombatInfo.SV.ExperienceEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.ExperienceEnabled = value LUIE.CombatInfo.RegisterXPEvent() end,
					width = "full",
					default = LUIE.CombatInfo.D.ExperienceEnabled,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
				},
				[36] = {
					type = "checkbox",
					name = "Show alliance points gain text",
					tooltip = "Display floating numbers of gained alliance points.",
					getFunc = function() return LUIE.CombatInfo.SV.AllianceEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.AllianceEnabled = value LUIE.CombatInfo.RegisterAPEvent() end,
					width = "full",
					default = LUIE.CombatInfo.D.AllianceEnabled,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
				},
				[37] = {
					type = "checkbox",
					name = "Show TelVar stones update text",
					tooltip = "Display floating numbers of gained alliance points.",
					getFunc = function() return LUIE.CombatInfo.SV.TelVarEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.TelVarEnabled = value LUIE.CombatInfo.RegisterTSEvent() end,
					width = "full",
					default = LUIE.CombatInfo.D.TelVarEnabled,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
				},
				[38] = {
					type = "header",
					name = "Alerts options",
					width = "full",
				},
				[39] = {
					type = "checkbox",
					name = "Enable Active Combat Tips alerts",
					tooltip = "Display alerts to Block/Dodge/Exploit combat tips.",
					warning = "For this functionality to work properly, you also have go to Settings->Interface and select 'Always show' for 'Active Combat Tips' option.",
					getFunc = function() return LUIE.CombatInfo.SV.CombatTipsEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.CombatTipsEnabled = value LUIE.CombatInfo.RegisterCombatTipEvent() end,
					width = "full",
					default = LUIE.CombatInfo.D.CombatTipsEnabled,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
				},
				[40] = {
					type = "checkbox",
					name = "Hide ingame tips",
					tooltip = "Hide default Active Combat Tips window.",
					getFunc = function() return LUIE.CombatInfo.SV.HideIngameTips end,
					setFunc = function(value) LUIE.CombatInfo.SV.HideIngameTips = value ZO_ActiveCombatTips:SetHidden(value) end,
					width = "full",
					default = LUIE.CombatInfo.D.HideIngameTips,
					disabled = function() return not ( LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.CombatTipsEnabled ) end,
				},
				[41] = {
					type = "checkbox",
					name = "Enable group member death alert",
					tooltip = "Display an alert when group member dies.",
					getFunc = function() return LUIE.CombatInfo.SV.GroupDeathEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.GroupDeathEnabled = value LUIE.CombatInfo.RegisterDeathEvent() end,
					width = "full",
					default = LUIE.CombatInfo.D.GroupDeathEnabled,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
				},
				[42] = {
					type = "checkbox",
					name = "Low Attribute Notifications",
					tooltip = "Enable notification display when players Health, Magicka or Stamina drops below threshold level.",
					getFunc = function() return LUIE.CombatInfo.SV.LowEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.LowEnabled = value end,
					width = "full",
					default = LUIE.CombatInfo.D.LowEnabled,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
				},
				[43] = {
					type = "slider",
					name = "Threshold level, %",
					--tooltip = "Threshold value.",
					min = 10, max = 50, step = 5,
					getFunc = function() return LUIE.CombatInfo.SV.LowThreshold end,
					setFunc = function(value) LUIE.CombatInfo.SV.LowThreshold = value LUIE.CombatInfo.thresholdAttribute = 0.01 * value end,
					width = "half",
					default = LUIE.CombatInfo.D.LowThreshold,
					disabled = function() return not ( LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.LowEnabled ) end,
				},
				[44] = {
					type = "checkbox",
					name = "Notification Sound",
					tooltip = "Play sound when players Health, Magicka or Stamina drops below threshold level.",
					getFunc = function() return LUIE.CombatInfo.SV.LowSound end,
					setFunc = function(value) LUIE.CombatInfo.SV.LowSound = value end,
					width = "half",
					default = LUIE.CombatInfo.D.LowSound,
					disabled = function() return not ( LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.LowEnabled ) end,
				},
				[45] = {
					type = "checkbox",
					name = "Enable Execute alert",
					tooltip = "Enable notification display when targets health drops below specified threshold.",
					getFunc = function() return LUIE.CombatInfo.SV.ExecuteEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.ExecuteEnabled = value end,
					width = "full",
					default = LUIE.CombatInfo.D.ExecuteEnabled,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
				},
				[46] = {
					type = "slider",
					name = "Threshold level, %",
					--tooltip = "Threshold value.",
					min = 20, max = 35, step = 1,
					getFunc = function() return LUIE.CombatInfo.SV.ExecuteThreshold end,
					setFunc = function(value) LUIE.CombatInfo.SV.ExecuteThreshold = value LUIE.CombatInfo.thresholdExecute = 0.01 * value end,
					width = "half",
					default = LUIE.CombatInfo.D.ExecuteThreshold,
					disabled = function() return not ( LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.ExecuteEnabled ) end,
				},
				[47] = {
					type = "slider",
					name = "Repeat timeout",
					tooltip = "Minimum amount of seconds between repeating this notification.",
					min = 4, max = 20, step = 1,
					getFunc = function() return LUIE.CombatInfo.SV.ExecuteTimeout end,
					setFunc = function(value) LUIE.CombatInfo.SV.ExecuteTimeout = value end,
					width = "half",
					default = LUIE.CombatInfo.D.ExecuteTimeout,
					disabled = function() return not ( LUIE.SV.CombatInfo_Enabled and LUIE.CombatInfo.SV.ExecuteEnabled ) end,
				},
				[48] = {
					type = "header",
					name = "Miscellaneous",
					width = "full",
				},
				[49] = {
					type = "checkbox",
					name = "Enable Combat State notification",
					tooltip = "Enable notification when players enters or leaves combat.",
					getFunc = function() return LUIE.CombatInfo.SV.CombatStateEnabled end,
					setFunc = function(value) LUIE.CombatInfo.SV.CombatStateEnabled = value LUIE.CombatInfo.RegisterCombatStateEvent() end,
					width = "full",
					default = LUIE.CombatInfo.D.CombatStateEnabled,
					disabled = function() return not LUIE.SV.CombatInfo_Enabled end,
				},
			},
		},
		[4] = {
			type = "submenu",
			name = "Buffs and Debuffs Options",
			controls = {
				[1] = {
					type = "checkbox",
					name = "Enable Effects Tracking",
					tooltip = "Track and show various effects applied to Player and Target units.",
					getFunc = function() return LUIE.SV.SpellCastBuff_Enable end,
					setFunc = function(value) LUIE.SV.SpellCastBuff_Enable = value end,
					width = "full",
					warning = "Will need to reload the UI.",
					default = LUIE.D.SpellCastBuff_Enable,
				},
				[2] = {
					type = "checkbox",
					name = "Hard-Lock position to Unit Frames",
					tooltip = "Hard-Lock position of buffs windows to Health bar of unit frames (default one or custom). This will forbid changing windows position indemendently.",
					getFunc = function() return LUIE.SpellCastBuffs.SV.lockPositionToUnitFrames end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.lockPositionToUnitFrames = value end,
					width = "full",
					warning = "Will need to reload the UI.\nWhen this position is locked, you will not be able to move buffs.",
					default = LUIE.SpellCastBuffs.D.lockPositionToUnitFrames,
					disabled = function() return not LUIE.SV.SpellCastBuff_Enable end,
				},
				[3] = {
					type = "checkbox",
					name = "Unlock Buffs window",
					tooltip = "Unlock for dragging window with buffs icons. This will only unlock areas unaffected by previous option (if it is enabled).",
					getFunc = function() return l_BuffsMovingEnabled end,
					setFunc = function(value)
						l_BuffsMovingEnabled = value
						LUIE.SpellCastBuffs.SetMovingState(value)
						end,
					width = "half",
					default = false,
					resetFunc = LUIE.SpellCastBuffs.ResetTlwPosition,
				},
				[4] = {
					type = "button",
					name = "Reset position",
					tooltip = "This will reset position of all three buff icon containers into somewhat screen-center position.",
					func = LUIE.SpellCastBuffs.ResetTlwPosition,
					width = "half",
				},
				[5] = {
					type = "header",
					name = "Icon options",
					width = "full",
				},
				[6] = {
					type = "slider",
					name = "Buff Icon size",
					-- tooltip = "Slider's tooltip text.",
					min = 30, max = 60, step = 2,
					getFunc = function() return LUIE.SpellCastBuffs.SV.IconSize end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.IconSize = value LUIE.SpellCastBuffs.Reset() end,
					width = "full",
					default = LUIE.SpellCastBuffs.D.IconSize,
					disabled = function() return not LUIE.SV.SpellCastBuff_Enable end,
				},
				[7] = {
					type = "dropdown",
					name = "Horizontal Icons Alignment",
					tooltip = "Horizontal alignment of buff and debuff icons within container area.",
					choices = hAlignOptions,
					getFunc = function() return LUIE.SpellCastBuffs.SV.Alignment end,
					setFunc = LUIE.SpellCastBuffs.SetIconsAlignment,
					width = "full",
					default = LUIE.SpellCastBuffs.D.Alignment,
					disabled = function() return not LUIE.SV.SpellCastBuff_Enable end,
				},
				[8] = {
					type = "dropdown",
					name = "Descending sort direction",
					--tooltip = "",
					choices = L.Setting_OrderX,
					getFunc = function() return LUIE.SpellCastBuffs.SV.SortDirection end,
					setFunc = LUIE.SpellCastBuffs.SetSortDirection,
					width = "full",
					default = LUIE.SpellCastBuffs.D.SortDirection,
					disabled = function() return not LUIE.SV.SpellCastBuff_Enable end,
				},
				[9] = {
					type = "checkbox",
					name = "Glow icon border",
					tooltip = "Use coloured glow border around each (de)buff icon.",
					getFunc = function() return LUIE.SpellCastBuffs.SV.GlowIcons end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.GlowIcons = value LUIE.SpellCastBuffs.Reset() end,
					width = "full",
					default = LUIE.SpellCastBuffs.D.GlowIcons,
					disabled = function() return not LUIE.SV.SpellCastBuff_Enable end,
				},
				[10] = {
					type = "checkbox",
					name = "Display remaining border cooldown",
					tooltip = "Show border element, that run around icon as the buff is going to expire.",
					getFunc = function() return LUIE.SpellCastBuffs.SV.RemainingCooldown end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.RemainingCooldown = value LUIE.SpellCastBuffs.Reset() end,
					width = "full",
					default = LUIE.SpellCastBuffs.D.RemainingCooldown,
					disabled = function() return not LUIE.SV.SpellCastBuff_Enable end,
				},
				[11] = {
					type = "checkbox",
					name = "Fade out expiring icon",
					tooltip = "When Buff is about to expire, make an icon transparent.",
					getFunc = function() return LUIE.SpellCastBuffs.SV.FadeOutIcons end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.FadeOutIcons = value end,
					width = "full",
					default = LUIE.SpellCastBuffs.D.FadeOutIcons,
					disabled = function() return not LUIE.SV.SpellCastBuff_Enable end,
				},
				[12] = {
					type = "checkbox",
					name = "Display remaining time label",
					tooltip = "Show text label with number of seconds left until the buff expire.",
					getFunc = function() return LUIE.SpellCastBuffs.SV.RemainingText end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.RemainingText = value LUIE.SpellCastBuffs.Reset() end,
					width = "full",
					default = LUIE.SpellCastBuffs.D.RemainingText,
					disabled = function() return not LUIE.SV.SpellCastBuff_Enable end,
				},
				[13] = {
					type = "dropdown",
					name = "Font",
					tooltip = "Font to display all buff text labels.",
					choices = FontsList,
					sort = "name-up",
					getFunc = function() return LUIE.SpellCastBuffs.SV.BuffFontFace end,
					setFunc = function(var) LUIE.SpellCastBuffs.SV.BuffFontFace = var LUIE.SpellCastBuffs.ApplyFont() end,
					width = "full",
					default = LUIE.SpellCastBuffs.D.BuffFontFace,
					disabled = function() return not ( LUIE.SV.SpellCastBuff_Enable and LUIE.SpellCastBuffs.SV.RemainingText ) end,
				},
				[14] = {
					type = "slider",
					name = "Font Size",
					tooltip = "Font Size to be used on buff text labels.",
					min = 10, max = 30, step = 1,
					getFunc = function() return LUIE.SpellCastBuffs.SV.BuffFontSize end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.BuffFontSize = value LUIE.SpellCastBuffs.ApplyFont() end,
					width = "full",
					default = LUIE.SpellCastBuffs.D.BuffFontSize,
					disabled = function() return not ( LUIE.SV.SpellCastBuff_Enable and LUIE.SpellCastBuffs.SV.RemainingText ) end,
				},
				[15] = {
					type = "dropdown",
					name = "Font Style",
					--tooltip = "",
					choices = styleOptions,
					sort = "name-up",
					getFunc = function() return LUIE.SpellCastBuffs.SV.BuffFontStyle end,
					setFunc = function(var) LUIE.SpellCastBuffs.SV.BuffFontStyle = var LUIE.SpellCastBuffs.ApplyFont() end,
					width = "full",
					default = LUIE.SpellCastBuffs.D.BuffFontStyle,
					disabled = function() return not ( LUIE.SV.SpellCastBuff_Enable and LUIE.SpellCastBuffs.SV.RemainingText ) end,
				},
				[16] = {
					type = "checkbox",
					name = "Coloured time label",
					tooltip = "Set the colour of text label same as icon border or keep it white.",
					getFunc = function() return LUIE.SpellCastBuffs.SV.RemainingTextColoured end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.RemainingTextColoured = value LUIE.SpellCastBuffs.Reset() end,
					width = "full",
					default = LUIE.SpellCastBuffs.D.RemainingTextColoured,
					disabled = function() return not ( LUIE.SV.SpellCastBuff_Enable and LUIE.SpellCastBuffs.SV.RemainingText ) end,
				},
				[17] = {
					type = "checkbox",
					name = "Show second fractions",
					tooltip = "Format remaining text labes as \"12.3\" or keep only seconds \"12\".",
					getFunc = function() return LUIE.SpellCastBuffs.SV.RemainingTextMillis end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.RemainingTextMillis = value end,
					width = "full",
					default = LUIE.SpellCastBuffs.D.RemainingTextMillis,
					disabled = function() return not ( LUIE.SV.SpellCastBuff_Enable and LUIE.SpellCastBuffs.SV.RemainingText ) end,
				},
				[18] = {
					type = "header",
					name = "Long-term Effects",
					width = "full",
				},
				[19] = {
					type = "checkbox",
					name = "Show Long-term Effects for Player",
					tooltip = "Show Player icons for effects with duration greater then 2 minutes.",
					getFunc = function() return LUIE.SpellCastBuffs.SV.LongTermEffects_Player end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.LongTermEffects_Player = value end,
					width = "full",
					default = LUIE.SpellCastBuffs.D.LongTermEffects_Player,
					disabled = function() return not LUIE.SV.SpellCastBuff_Enable end,
				},
				[20] = {
					type = "checkbox",
					name = "Show Long-term Effects for Targer",
					tooltip = "Show Target icons for effects with duration greater then 2 minutes.",
					getFunc = function() return LUIE.SpellCastBuffs.SV.LongTermEffects_Target end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.LongTermEffects_Target = value end,
					width = "full",
					default = LUIE.SpellCastBuffs.D.LongTermEffects_Target,
					disabled = function() return not LUIE.SV.SpellCastBuff_Enable end,
				},
				[21] = {
					type = "checkbox",
					name = "Show Disguises",
					tooltip = "Set whether active disguises effects icons are shown.",
					getFunc = function() return not LUIE.SpellCastBuffs.SV.IgnoreDisguise end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.IgnoreDisguise = not value LUIE.SpellCastBuffs.ReloadEffects() end,
					width = "full",
					default = not LUIE.SpellCastBuffs.D.IgnoreDisguise,
					disabled = function() return not ( LUIE.SV.SpellCastBuff_Enable and ( LUIE.SpellCastBuffs.SV.LongTermEffects_Player or LUIE.SpellCastBuffs.SV.LongTermEffects_Target ) ) end,
				},
				[22] = {
					type = "checkbox",
					name = "Show Mundus Boons",
					tooltip = "Set whether Mundus Stone boons are shown.",
					getFunc = function() return not LUIE.SpellCastBuffs.SV.IgnoreMundus end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.IgnoreMundus = not value LUIE.SpellCastBuffs.ReloadEffects() end,
					width = "full",
					default = not LUIE.SpellCastBuffs.D.IgnoreMundus,
					disabled = function() return not ( LUIE.SV.SpellCastBuff_Enable and ( LUIE.SpellCastBuffs.SV.LongTermEffects_Player or LUIE.SpellCastBuffs.SV.LongTermEffects_Target ) ) end,
				},
				[23] = {
					type = "checkbox",
					name = "Show Equipment Effects",
					tooltip = "Set whether effects provided by wearing full set of equipment are shown.",
					getFunc = function() return not LUIE.SpellCastBuffs.SV.IgnoreEquipment end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.IgnoreEquipment = not value LUIE.SpellCastBuffs.ReloadEffects() end,
					width = "full",
					default = not LUIE.SpellCastBuffs.D.IgnoreEquipment,
					disabled = function() return not ( LUIE.SV.SpellCastBuff_Enable and ( LUIE.SpellCastBuffs.SV.LongTermEffects_Player or LUIE.SpellCastBuffs.SV.LongTermEffects_Target ) ) end,
				},
				[24] = {
					type = "checkbox",
					name = "Show Vampire / Werewolf",
					tooltip = "Set whether to show Vampirism and Lycanthropy buffs.",
					getFunc = function() return not LUIE.SpellCastBuffs.SV.IgnoreVampLycan end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.IgnoreVampLycan = not value LUIE.SpellCastBuffs.ReloadEffects() end,
					width = "full",
					default = not LUIE.SpellCastBuffs.D.IgnoreVampLycan,
					disabled = function() return not ( LUIE.SV.SpellCastBuff_Enable and ( LUIE.SpellCastBuffs.SV.LongTermEffects_Player or LUIE.SpellCastBuffs.SV.LongTermEffects_Target ) ) end,
				},
				[25] = {
					type = "checkbox",
					name = "Show Cyrodiil Bonuses",
					tooltip = "Set whether buffs provided during Cyrodiil AvA are shown.",
					getFunc = function() return not LUIE.SpellCastBuffs.SV.IgnoreCyrodiil end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.IgnoreCyrodiil = not value LUIE.SpellCastBuffs.ReloadEffects() end,
					width = "full",
					default = not LUIE.SpellCastBuffs.D.IgnoreCyrodiil,
					disabled = function() return not ( LUIE.SV.SpellCastBuff_Enable and ( LUIE.SpellCastBuffs.SV.LongTermEffects_Player or LUIE.SpellCastBuffs.SV.LongTermEffects_Target ) ) end,
				},
				[26] = {
					type = "checkbox",
					name = "Use separate control for Player effects",
					tooltip = "Move Player effects icons for long-term effects into independent separate control.",
					getFunc = function() return LUIE.SpellCastBuffs.SV.LongTermEffectsSeparate end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.LongTermEffectsSeparate = value LUIE.SpellCastBuffs.Reset() end,
					width = "full",
					default = LUIE.SpellCastBuffs.D.LongTermEffectsSeparate,
					disabled = function() return not ( LUIE.SV.SpellCastBuff_Enable and LUIE.SpellCastBuffs.SV.LongTermEffects_Player ) end,
				},
				[27] = {
					type = "dropdown",
					name = "Container orientation",
					--tooltip = "",
					choices = rotationOptions,
					getFunc = function() return rotationOptions[LUIE.SpellCastBuffs.SV.LongTermEffectsSeparateAlignment] end,
					--setFunc = function(value) LUIE.SpellCastBuffs.SV.LongTermEffectsSeparateAlignment = rotationOptionsKeys[value] LUIE.SpellCastBuffs.Reset() end,
					setFunc = function() return false end, -- FIXME
					width = "full",
					default = rotationOptions[2],
					--disabled = function() return not ( LUIE.SV.SpellCastBuff_Enable and LUIE.SpellCastBuffs.SV.LongTermEffects_Player and LUIE.SpellCastBuffs.SV.LongTermEffectsSeparate ) end,
					disabled = function() return true end, -- FIXME
				},
				[28] = {
					type = "header",
					name = "Miscellaneous",
					width = "full",
				},
				--[[ Ultimate Generation detection code in SCB module is broken
				[??] = {
					type = "checkbox",
					name = "Show Ultimate Generation icon",
					tooltip = "Display special buff icon when in-combat ultimate generation is detected.",
					getFunc = function() return LUIE.SpellCastBuffs.SV.UltimateGeneration end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.UltimateGeneration = value end,
					width = "full",
					default = LUIE.SpellCastBuffs.D.UltimateGeneration,
					disabled = function() return not LUIE.SV.SpellCastBuff_Enable end,
				},]]--
				[29] = {
					type = "checkbox",
					name = "Show Stealth icon",
					tooltip = "Display special buff icon when player is hidden or in stealth.",
					getFunc = function() return LUIE.SpellCastBuffs.SV.StealthState end,
					setFunc = function(value) LUIE.SpellCastBuffs.SV.StealthState = value end,
					width = "full",
					default = LUIE.SpellCastBuffs.D.StealthState,
					disabled = function() return not LUIE.SV.SpellCastBuff_Enable end,
				},
			},
		},
		[5] = {
			type = "submenu",
			name = "Damage Meter & Combat Log",
			controls = {
				[1] = {
					type = "checkbox",
					name = "Enable Damage Meter",
					tooltip = "Counts damage and healing done.",
					getFunc = function() return LUIE.SV.DamageMeter_Enable end,
					setFunc = function(value) LUIE.SV.DamageMeter_Enable = value end,
					width = "full",
					warning = "Will need to reload the UI.",
					default = LUIE.D.DamageMeter_Enable,
				},
				[2] = {
					type = "slider",
					name = "Timeout Threshold",
					tooltip = "Number of seconds without damage to signal encounter termination.",
					min = 1, max = 10, step = 1,
					getFunc = function() return LUIE.DamageMeter.SV.DamageTimeout end,
					setFunc = function(value) LUIE.DamageMeter.SV.DamageTimeout = value end,
					width = "full",
					disabled = function() return not LUIE.SV.DamageMeter_Enable end,
					default = LUIE.DamageMeter.D.DamageTimeout,
				},
				[3] = {
					type = "checkbox",
					name = "Update Damage Statistics in realtime",
					tooltip = "Update Full Damage Meter window during combat. Otherwise it is updated when being displayed with information of last combat.",
					getFunc = function() return LUIE.DamageMeter.SV.UpdateFullRealtime end,
					setFunc = function(value) LUIE.DamageMeter.SV.UpdateFullRealtime = value end,
					width = "full",
					disabled = function() return not LUIE.SV.DamageMeter_Enable end,
					default = LUIE.DamageMeter.D.UpdateFullRealtime,
				},
				[4] = {
					type = "checkbox",
					name = "Unlock window",
					tooltip = "Allow mouse dragging for Damage Meter window.",
					getFunc = function() return LUIE.DamageMeter.panelUnlocked end,
					setFunc = LUIE.DamageMeter.SetMovingState,
					width = "half",
					default = false,
					disabled = function() return not LUIE.SV.DamageMeter_Enable end,
					resetFunc = LUIE.DamageMeter.ResetTlwPosition,
				},
				[5] = {
					type = "button",
					name = "Reset position",
					tooltip = "This will reset position of Damage Meter window into screen top left corner.",
					func = LUIE.DamageMeter.ResetTlwPosition,
					width = "half",
				},
				[6] = {
					type = "header",
					name = "Meter Mini-panel",
					width = "full",
				},
				[7] = {
					type = "checkbox",
					name = "Show Fight time label",
					tooltip = "Include Fight time control as 4th element on mini-panel.",
					getFunc = function() return LUIE.DamageMeter.SV.FightTime end,
					setFunc = function(value) LUIE.DamageMeter.SV.FightTime = value LUIE.DamageMeter.LayoutMiniPanel() end,
					width = "full",
					default = LUIE.DamageMeter.D.FightTime,
					disabled = function() return not LUIE.SV.DamageMeter_Enable end,
				},
				[8] = {
					type = "checkbox",
					name = "Show Background on Mini-meter panel",
					tooltip = "Create mini-panel with background or leave it completely transparent.",
					getFunc = function() return LUIE.DamageMeter.SV.Backdrop end,
					setFunc = function(value) LUIE.DamageMeter.SV.Backdrop = value LUIE.DamageMeter.LayoutMiniPanel() end,
					width = "full",
					default = LUIE.DamageMeter.D.Backdrop,
					disabled = function() return not LUIE.SV.DamageMeter_Enable end,
				},
				[9] = {
					type = "header",
					name = "Notes",
					width = "full",
				},
				[10] = {
					type = "description",
					text = "You can click on incoming damage label to display full combat statistics for completed fight. Clicking on 'fight time' label will display graphical log of the fight. To report to chat your damage/healing performance click on damage and healing text labels on the meter mini-panel.",
				},
				[11] = {
					type = "description",
					text = "You can also setup unique key bindings for those actions in standard game 'Controls' menu.",
				},
				[12] = {
					type = "header",
					name = "Combat Log",
					width = "full",
				},
				[13] = {
					type = "checkbox",
					name = "Enable Combat Log",
					tooltip = "Enable Combat Log component to print combat related information into separate chat tab named 'Combat Log'.",
					getFunc = function() return LUIE.DamageMeter.SV.CombatLog end,
					setFunc = function(value) LUIE.DamageMeter.SV.CombatLog = value LUIE.DamageMeter.RegisterCombatStateEvent() LUIE.DamageMeter.RegisterEffectChangedEvent() end,
					width = "full",
					default = LUIE.DamageMeter.D.CombatLog,
					disabled = function() return not LUIE.SV.DamageMeter_Enable end,
				},
				[14] = {
					type = "checkbox",
					name = "Include Time Stamp",
					tooltip = "Include time of each combat event.",
					getFunc = function() return LUIE.DamageMeter.SV.LogTimeStamp end,
					setFunc = function(value) LUIE.DamageMeter.SV.LogTimeStamp = value end,
					width = "full",
					default = LUIE.DamageMeter.D.LogTimeStamp,
					disabled = function() return not (LUIE.SV.DamageMeter_Enable and LUIE.DamageMeter.SV.CombatLog) end,
				},
				[15] = {
					type = "checkbox",
					name = "Focus in combat",
					tooltip = "Switch active chat tab to CombatLog when enterring combat and resore the original one when finishing combat.",
					getFunc = function() return LUIE.DamageMeter.SV.CombatLogFocus end,
					setFunc = function(value) LUIE.DamageMeter.SV.CombatLogFocus = value LUIE.DamageMeter.RegisterCombatStateEvent() end,
					width = "full",
					default = LUIE.DamageMeter.D.CombatLogFocus,
					disabled = function() return not (LUIE.SV.DamageMeter_Enable and LUIE.DamageMeter.SV.CombatLog) end,
				},
				[16] = {
					type = "checkbox",
					name = "Log debuffs on player",
					tooltip = "Include in CombatLog events when negative effect was applied to player character.",
					getFunc = function() return LUIE.DamageMeter.SV.CombatLogDebuff end,
					setFunc = function(value) LUIE.DamageMeter.SV.CombatLogDebuff = value LUIE.DamageMeter.RegisterEffectChangedEvent() end,
					width = "full",
					default = LUIE.DamageMeter.D.CombatLogDebuff,
					disabled = function() return not (LUIE.SV.DamageMeter_Enable and LUIE.DamageMeter.SV.CombatLog) end,
				},
				[17] = {
					type = "slider",
					name = "Font Size Adjustment",
					tooltip = "Used to change size of Combat Log font with respect to default chat font size.",
					min = -3, max = 2, step = 1,
					getFunc = function() return LUIE.DamageMeter.SV.CombatLogFont end,
					setFunc = function(value) LUIE.DamageMeter.SV.CombatLogFont = value LUIE.DamageMeter.OnPlayerActivated() end,
					width = "full",
					default = LUIE.DamageMeter.D.CombatLogFont,
					disabled = function() return not (LUIE.SV.DamageMeter_Enable and LUIE.DamageMeter.SV.CombatLog) end,
				},
				[18] = {
					type = "checkbox",
					name = "Preserve between logins",
					tooltip = "Try to save last 20 log elements between character logins. Though this will not work if you game crashes instead exiting normally.",
					getFunc = function() return LUIE.DamageMeter.SVC.LogSaveEnable end,
					setFunc = function(value) LUIE.DamageMeter.SVC.LogSaveEnable = value end,
					width = "full",
					default = LUIE.DamageMeter.DC.LogSaveEnable,
					disabled = function() return not (LUIE.SV.DamageMeter_Enable and LUIE.DamageMeter.SV.CombatLog) end,
				},
				--[[[??] = {
					type = "header",
					name = "Notes",
					width = "full",
				},]]--
				[19] = {
					type = "description",
					text = "This component will create new chat tab 'CombatLog' and will send all combat related text into it. If you delete this tab it will be automatically recreated. If you wish to stop using this component, then first disable it here in menu and after it delete chat tab manually.",
				},
			},
		},
		[6] = {
			type = "submenu",
			name = "Chat Announcements Options",
			controls = {
				[1] = {
					type = "checkbox",
					name = "Include Time Stamp",
					tooltip = "Where possible prepend printed text with current time label.",
					getFunc = function() return LUIE.ChatAnnouncements.SV.TimeStamp end,
					setFunc = function(value) LUIE.ChatAnnouncements.SV.TimeStamp = value end,
					width = "full",
					default = LUIE.ChatAnnouncements.D.TimeStamp,
				},
				[2] = {
					type = "header",
					name = "Group Announcements",
					width = "full",
				},
				[3] = {
					type = "checkbox",
					name = "Enable group changes events in chat",
					tooltip = "Print message to chat when player joins or leaves the group.",
					getFunc = function() return LUIE.ChatAnnouncements.SV.GroupChatMsg end,
					setFunc = function(value) LUIE.ChatAnnouncements.SV.GroupChatMsg = value LUIE.ChatAnnouncements.RegisterGroupEvents() end,
					width = "full",
					default = LUIE.ChatAnnouncements.D.GroupChatMsg,
				},
				[4] = {
					type = "header",
					name = "Loot Announcements",
					width = "full",
				},
				[5] = {
					type = "checkbox",
					name = "Show Gold changes",
					--tooltip = "",
					getFunc = function() return LUIE.ChatAnnouncements.SV.GoldChange end,
					setFunc = function(value) LUIE.ChatAnnouncements.SV.GoldChange = value LUIE.ChatAnnouncements.RegisterGoldEvents() end,
					width = "full",
					default = LUIE.ChatAnnouncements.D.GoldChange,
				},
				[6] = {
					type = "checkbox",
					name = "Show looted items",
					--tooltip = "",
					getFunc = function() return LUIE.ChatAnnouncements.SV.Loot end,
					setFunc = function(value) LUIE.ChatAnnouncements.SV.Loot = value LUIE.ChatAnnouncements.RegisterLootEvents() end,
					width = "full",
					default = LUIE.ChatAnnouncements.D.Loot,
				},
				[7] = {
					type = "checkbox",
					name = "Include Group members loot",
					tooltip = "Rare or better loot that you party loots. Show loot must be enabled.",
					getFunc = function() return LUIE.ChatAnnouncements.SV.LootGroup end,
					setFunc = function(value) LUIE.ChatAnnouncements.SV.LootGroup = value end,
					width = "full",
					disabled = function() return not LUIE.ChatAnnouncements.SV.Loot end,
					default = LUIE.ChatAnnouncements.D.LootGroup,
				},
				[8] = {
					type = "checkbox",
					name = "Show looted items icons",
					--tooltip = "",
					getFunc = function() return LUIE.ChatAnnouncements.SV.LootIcons end,
					setFunc = function(value) LUIE.ChatAnnouncements.SV.LootIcons = value end,
					width = "full",
					default = LUIE.ChatAnnouncements.D.LootIcons,
				},
				[9] = {
					type = "header",
					name = "Experience Announcements",
					width = "full",
				},
				[10] = {
					type = "checkbox",
					name = "Show Experience gain",
					tooltip = "Print changes in player experience for non-combat events.",
					warning = "This feature depends on Combat Info Experience tracking and will not work without it.",
					getFunc = function() return LUIE.ChatAnnouncements.SV.Experience end,
					setFunc = function(value) LUIE.ChatAnnouncements.SV.Experience = value end,
					width = "full",
					default = LUIE.ChatAnnouncements.D.Experience,
				},
				[11] = {
					type = "header",
					name = "Achievements Announcements",
					width = "full",
				},
				[12] = {
					type = "checkbox",
					name = "Enable Achievements Tracking",
					tooltip = "Enables achievements tracking sub-module. Below you can select categories of achievements to be tracked.",
					getFunc = function() return LUIE.ChatAnnouncements.SV.Achievements end,
					setFunc = function(value) LUIE.ChatAnnouncements.SV.Achievements = value LUIE.ChatAnnouncements.RegisterAchievementsEvent() end,
					width = "full",
					default = LUIE.ChatAnnouncements.D.Achievements,
				},
				[13] = {
					type = "slider",
					name = "Achievements Step Size, %",
					tooltip = "Display achievement update information every #% to completion. Setting this value to 0 means to print achievement information on every update event.",
					min = 0, max = 10, step = 1,
					getFunc = function() return LUIE.ChatAnnouncements.SV.AchievementsStep end,
					setFunc = function(value) LUIE.ChatAnnouncements.SV.AchievementsStep = value end,
					width = "full",
					default = LUIE.ChatAnnouncements.D.AchievementsStep,
					disabled = function() return not LUIE.ChatAnnouncements.SV.Achievements end,
				},
				[14] = {
					type = "checkbox",
					name = "Show Detailed achievement info",
					--tooltip = "",
					getFunc = function() return LUIE.ChatAnnouncements.SV.AchievementsDetails end,
					setFunc = function(value) LUIE.ChatAnnouncements.SV.AchievementsDetails = value end,
					width = "full",
					default = LUIE.ChatAnnouncements.D.AchievementsDetails,
					disabled = function() return not LUIE.ChatAnnouncements.SV.Achievements end,
				},
			},
		},
		[7] = {
			type = "checkbox",
			name = "Disable startup message",
			tooltip = "This setting will disable add-on startup message.",
			getFunc = function() return LUIE.SV.StartupInfo end,
			setFunc = function(value) LUIE.SV.StartupInfo = value end,
			width = "full",
			default = LUIE.D.StartupInfo,
		},
	}

	for i = 1, GetNumAchievementCategories() do
		local name = GetAchievementCategoryInfo(i)
		local checkbox = {
					type = "checkbox",
					name = name,
					tooltip = "Enables achievements tracking in '" .. name .. "' category.",
					getFunc = function() return not LUIE.ChatAnnouncements.SV.AchIgnoreList[i] end,
					setFunc = function(value) if value then LUIE.ChatAnnouncements.SV.AchIgnoreList[i] = nil else LUIE.ChatAnnouncements.SV.AchIgnoreList[i] = true end end,
					width = "full",
					default = not LUIE.ChatAnnouncements.D.AchIgnoreList[i],
					disabled = function() return not LUIE.ChatAnnouncements.SV.Achievements end,
				}
		-- (!!!) hardcoded sub-panel index
		table.insert(optionsData[6].controls, checkbox)
	end

	local panelDataUnitFrames = {
		type = 'panel',
		name = LUIE.name .. ' - Unit Frames',
		displayName = "LUIE Unit Frames Settings",
		author = "SpellBuilder",
		version = g_Version,
		slashCommand = "/luiframes",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local optionsDataUnitFrames = {
		[1] = {
			type = "checkbox",
			name = "Enable Unit Frames Module",
			getFunc = function() return LUIE.SV.UnitFrames_Enabled end,
			setFunc = function(value) LUIE.SV.UnitFrames_Enabled = value end,
			width = "full",
			warning = "Will need to reload the UI.",
			default = LUIE.D.UnitFrames_Enabled,
		},
		[2] = {
			type = "description",
			text = "This module allows display of textual attributes information over default UI controls. It also creates custom frames for player and target. Many of the settings can be applied only after reload of UI.",
		},
		[3] = {
			type = "button",
			name = "Reload UI",
			tooltip = "This will reload UI",
			func = function() ReloadUI("ingame") end,
			width = "full",
		},
		[4] = {
			type = "checkbox",
			name = "Shorten numbers on all bars",
			tooltip = "Replace large numbers like 12,345 with 12.3k on all bars and labels related to unit frames.",
			getFunc = function() return LUIE.UnitFrames.SV.ShortenNumbers end,
			setFunc = function(value) LUIE.UnitFrames.SV.ShortenNumbers = value end,
			width = "full",
			default = LUIE.UnitFrames.D.ShortenNumbers,
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[5] = {
			type = "header",
			name = "Default Unit Frames",
			width = "full",
		},
		[6] = {
			type = "dropdown",
			name = "Default PLAYER Frame",
			--tooltip = "",
			choices = LUIE.UnitFrames.GetDefaultFramesOptions('Player'),
			getFunc = function() return LUIE.UnitFrames.GetDefaultFramesSetting('Player') end,
			setFunc = function(value) LUIE.UnitFrames.SetDefaultFramesSetting('Player', value) end,
			width = "full",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
			warning = "Will need to reload the UI.",
			default = LUIE.UnitFrames.GetDefaultFramesSetting('Player', true),
		},
		[7] = {
			type = "dropdown",
			name = "Default TARGET Frame",
			--tooltip = "",
			choices = LUIE.UnitFrames.GetDefaultFramesOptions('Target'),
			getFunc = function() return LUIE.UnitFrames.GetDefaultFramesSetting('Target') end,
			setFunc = function(value) LUIE.UnitFrames.SetDefaultFramesSetting('Target', value) end,
			width = "full",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
			warning = "Will need to reload the UI.",
			default = LUIE.UnitFrames.GetDefaultFramesSetting('Target', true),
		},
		[8] = {
			type = "dropdown",
			name = "Default Small GROUP Frame",
			--tooltip = "",
			choices = LUIE.UnitFrames.GetDefaultFramesOptions('Group'),
			getFunc = function() return LUIE.UnitFrames.GetDefaultFramesSetting('Group') end,
			setFunc = function(value) LUIE.UnitFrames.SetDefaultFramesSetting('Group', value) end,
			width = "full",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
			warning = "Will need to reload the UI.",
			default = LUIE.UnitFrames.GetDefaultFramesSetting('Group', true),
		},
		[9] = {
			type = "checkbox",
			name = "Reposition default player bars",
			tooltip = "Change position of default unit frames to be stuck in the center.",
			getFunc = function() return LUIE.UnitFrames.SV.RepositionFrames end,
			setFunc = function(value) LUIE.UnitFrames.SV.RepositionFrames = value end,
			width = "full",
			default = LUIE.UnitFrames.D.RepositionFrames,
			warning = "Will need to reload the UI.",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[10] = {
			type = "dropdown",
			name = "Format label text",
			tooltip = "Format of the label text over default unit frames.",
			choices = formatOptions,
			getFunc = function() return LUIE.UnitFrames.SV.Format end,
			setFunc = function(var) LUIE.UnitFrames.SV.Format = var end,
			width = "full",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
			default = LUIE.UnitFrames.D.Format,
		},
		[11] = {
			type = "slider",
			name = "Out-of-Combat bars transparency",
			tooltip = "This will change the value of transparency of default unit frames when player is out of combat. Default UI makes frames disappear completely, this value is 0.",
			min = 0, max = 100, step = 5,
			getFunc = function() return LUIE.UnitFrames.SV.DefaultOocTransparency end,
			setFunc = function(value) LUIE.UnitFrames.SetDefaultFramesTransparency(value, nil) end,
			width = "full",
			default = LUIE.UnitFrames.D.DefaultOocTransparency,
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[12] = {
			type = "slider",
			name = "In-Combat bars transparency",
			tooltip = "This will change the value of transparency of default unit frames when player is in combat. Default UI makes frames fully visible, this value is 100.",
			min = 0, max = 100, step = 5,
			getFunc = function() return LUIE.UnitFrames.SV.DefaultIncTransparency end,
			setFunc = function(value) LUIE.UnitFrames.SetDefaultFramesTransparency(nil, value) end,
			width = "full",
			default = LUIE.UnitFrames.D.DefaultIncTransparency,
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[13] = {
			type = "dropdown",
			name = "Font",
			tooltip = "Font to display all labels on default frames.",
			choices = FontsList,
			sort = "name-up",
			getFunc = function() return LUIE.UnitFrames.SV.DefaultFontFace end,
			setFunc = function(var) LUIE.UnitFrames.SV.DefaultFontFace = var LUIE.UnitFrames.DefaultFramesApplyFont() end,
			width = "full",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
			default = LUIE.UnitFrames.D.DefaultFontFace,
		},
		[14] = {
			type = "slider",
			name = "Font Size",
			tooltip = "Font Size to be used on all labels on the default unit frames bars.",
			min = 10, max = 30, step = 1,
			getFunc = function() return LUIE.UnitFrames.SV.DefaultFontSize end,
			setFunc = function(value) LUIE.UnitFrames.SV.DefaultFontSize = value LUIE.UnitFrames.DefaultFramesApplyFont() end,
			width = "full",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
			default = LUIE.UnitFrames.D.DefaultFontSize,
		},
		[15] = {
			type = "dropdown",
			name = "Font Style",
			--tooltip = "",
			choices = styleOptions,
			sort = "name-up",
			getFunc = function() return LUIE.UnitFrames.SV.DefaultFontStyle end,
			setFunc = function(var) LUIE.UnitFrames.SV.DefaultFontStyle = var LUIE.UnitFrames.DefaultFramesApplyFont() end,
			width = "full",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
			default = LUIE.UnitFrames.D.DefaultFontStyle,
		},
		[16] = {
			type = "colorpicker",
			name = "Colour of text labels",
			getFunc = function() return unpack(LUIE.UnitFrames.SV.DefaultTextColour) end,
			setFunc = function(r,g,b,a) LUIE.UnitFrames.SV.DefaultTextColour={r,g,b} LUIE.UnitFrames.DefaultFramesApplyColour() end,
			width = "full",
			default = { r=LUIE.UnitFrames.D.DefaultTextColour[1], g=LUIE.UnitFrames.D.DefaultTextColour[2], b=LUIE.UnitFrames.D.DefaultTextColour[3] },
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[17] = {
			type = "checkbox",
			name = "Target class icon",
			tooltip = "Display icon for target player class.",
			getFunc = function() return LUIE.UnitFrames.SV.TargetShowClass end,
			setFunc = function(value) LUIE.UnitFrames.SV.TargetShowClass = value end,
			width = "full",
			default = LUIE.UnitFrames.D.TargetShowClass,
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[18] = {
			type = "checkbox",
			name = "Target ignore/friend/guild icon",
			tooltip = "Display icon for target player if this player is ignored, or your friend, or in one of your guilds.",
			getFunc = function() return LUIE.UnitFrames.SV.TargetShowFriend end,
			setFunc = function(value) LUIE.UnitFrames.SV.TargetShowFriend = value end,
			width = "full",
			default = LUIE.UnitFrames.D.TargetShowFriend,
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[19] = {
			type = "checkbox",
			name = "Colour target name by reaction",
			tooltip = "Change the colour of targets name label according to unit reaction.",
			getFunc = function() return LUIE.UnitFrames.SV.TargetColourByReaction end,
			setFunc = LUIE.UnitFrames.TargetColourByReaction,
			width = "full",
			default = LUIE.UnitFrames.D.TargetColourByReaction,
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[20] = {
			type = "header",
			name = "Custom Unit Frames",
			width = "full",
		},
		[21] = {
			type = "checkbox",
			name = "Unlock Custom Frames",
			tooltip = "Allow mouse dragging for all unit frames. When frames are unlocked, the target frame is not being hidden and can display outdated information.",
			getFunc = function() return LUIE.UnitFrames.CustomFramesMovingState end,
			setFunc = LUIE.UnitFrames.CustomFramesSetMovingState,
			width = "half",
			default = false,
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
			resetFunc = LUIE.UnitFrames.CustomFramesResetPosition,
		},
		[22] = {
			type = "button",
			name = "Reset position",
			tooltip = "This will reset position of Custom Frames into original position.",
			func = LUIE.UnitFrames.CustomFramesResetPosition,
			width = "half",
		},
		[23] = {
			type = "dropdown",
			name = "Format left label text",
			tooltip = "Format first label for custom attribute bar.",
			choices = formatOptions,
			getFunc = function() return LUIE.UnitFrames.SV.CustomFormatOne end,
			setFunc = function(var) LUIE.UnitFrames.SV.CustomFormatOne = var LUIE.UnitFrames.CustomFramesFormatLabels() end,
			width = "full",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
			default = LUIE.UnitFrames.D.CustomFormatOne,
		},
		[24] = {
			type = "dropdown",
			name = "Format right label text",
			tooltip = "Format second label for custom attribute bar.",
			choices = formatOptions,
			getFunc = function() return LUIE.UnitFrames.SV.CustomFormatTwo end,
			setFunc = function(var) LUIE.UnitFrames.SV.CustomFormatTwo = var LUIE.UnitFrames.CustomFramesFormatLabels() end,
			width = "full",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
			default = LUIE.UnitFrames.D.CustomFormatTwo,
		},
		[25] = {
			type = "dropdown",
			name = "Font",
			tooltip = "Font to display all labels on custom frames.",
			choices = FontsList,
			sort = "name-up",
			getFunc = function() return LUIE.UnitFrames.SV.CustomFontFace end,
			setFunc = function(var) LUIE.UnitFrames.SV.CustomFontFace = var LUIE.UnitFrames.CustomFramesApplyFont() end,
			width = "full",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
			default = LUIE.UnitFrames.D.CustomFontFace,
		},
		[26] = {
			type = "slider",
			name = "Font Size (labels)",
			tooltip = "Font Size to be used to display unit name, caption, etc: everything not on bars.",
			min = 10, max = 30, step = 1,
			getFunc = function() return LUIE.UnitFrames.SV.CustomFontOther end,
			setFunc = function(value) LUIE.UnitFrames.SV.CustomFontOther = value LUIE.UnitFrames.CustomFramesApplyFont() end,
			width = "half",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
			default = LUIE.UnitFrames.D.CustomFontOther,
		},
		[27] = {
			type = "slider",
			name = "Font Size (bars)",
			tooltip = "Font Size to be used on all labels on the bars.",
			min = 10, max = 30, step = 1,
			getFunc = function() return LUIE.UnitFrames.SV.CustomFontBars end,
			setFunc = function(value) LUIE.UnitFrames.SV.CustomFontBars = value LUIE.UnitFrames.CustomFramesApplyFont() end,
			width = "half",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
			default = LUIE.UnitFrames.D.CustomFontBars,
		},
		[28] = {
			type = "dropdown",
			name = "Font Style",
			--tooltip = "",
			choices = styleOptions,
			sort = "name-up",
			getFunc = function() return LUIE.UnitFrames.SV.CustomFontStyle end,
			setFunc = function(var) LUIE.UnitFrames.SV.CustomFontStyle = var LUIE.UnitFrames.CustomFramesApplyFont() end,
			width = "full",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
			default = LUIE.UnitFrames.D.CustomFontStyle,
		},
		[29] = {
			type = "dropdown",
			name = "Texture",
			tooltip = "Texture to use on custom frames.",
			choices = StatusbarTexturesList,
			sort = "name-up",
			getFunc = function() return LUIE.UnitFrames.SV.CustomTexture end,
			setFunc = function(var) LUIE.UnitFrames.SV.CustomTexture = var LUIE.UnitFrames.CustomFramesApplyTexture() end,
			width = "full",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
			default = LUIE.UnitFrames.D.CustomTexture,
		},
		[30] = {
			type = "checkbox",
			name = "Display HoT / DoT Animations",
			--tooltip = "",
			getFunc = function() return LUIE.UnitFrames.SV.CustomEnableRegen end,
			setFunc = function(value) LUIE.UnitFrames.SV.CustomEnableRegen = value end,
			width = "full",
			default = LUIE.UnitFrames.D.CustomEnableRegen,
			warning = "Will need to reload the UI.",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[31] = {
			type = "colorpicker",
			name = "Health Bar Colour",
			getFunc = function() return unpack(LUIE.UnitFrames.SV.CustomColourHealth) end,
			setFunc = function(r,g,b,a) LUIE.UnitFrames.SV.CustomColourHealth={r,g,b} LUIE.UnitFrames.CustomFramesApplyColours() end,
			width = "full",
			default = { r=LUIE.UnitFrames.D.CustomColourHealth[1], g=LUIE.UnitFrames.D.CustomColourHealth[2], b=LUIE.UnitFrames.D.CustomColourHealth[3] },
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[32] = {
			type = "colorpicker",
			name = "Shield Bar Colour",
			getFunc = function() return LUIE.UnitFrames.SV.CustomColourShield[1], LUIE.UnitFrames.SV.CustomColourShield[2], LUIE.UnitFrames.SV.CustomColourShield[3]  end,
			setFunc = function(r,g,b,a) LUIE.UnitFrames.SV.CustomColourShield={r,g,b} LUIE.UnitFrames.CustomFramesApplyColours() end,
			width = "full",
			default = { r=LUIE.UnitFrames.D.CustomColourShield[1], g=LUIE.UnitFrames.D.CustomColourShield[2], b=LUIE.UnitFrames.D.CustomColourShield[3] },
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[33] = {
			type = "colorpicker",
			name = "Magicka Bar Colour",
			getFunc = function() return unpack(LUIE.UnitFrames.SV.CustomColourMagicka) end,
			setFunc = function(r,g,b,a) LUIE.UnitFrames.SV.CustomColourMagicka={r,g,b} LUIE.UnitFrames.CustomFramesApplyColours() end,
			width = "full",
			default = { r=LUIE.UnitFrames.D.CustomColourMagicka[1], g=LUIE.UnitFrames.D.CustomColourMagicka[2], b=LUIE.UnitFrames.D.CustomColourMagicka[3] },
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[34] = {
			type = "colorpicker",
			name = "Stamina Bar Colour",
			getFunc = function() return unpack(LUIE.UnitFrames.SV.CustomColourStamina) end,
			setFunc = function(r,g,b,a) LUIE.UnitFrames.SV.CustomColourStamina={r,g,b} LUIE.UnitFrames.CustomFramesApplyColours() end,
			width = "full",
			default = { r=LUIE.UnitFrames.D.CustomColourStamina[1], g=LUIE.UnitFrames.D.CustomColourStamina[2], b=LUIE.UnitFrames.D.CustomColourStamina[3] },
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[35] = {
			type = "checkbox",
			name = "Use Separate Shield Bar",
			tooltip = "Enable this option to make a Shield Bar on Player, Target and Small Group custom frames independent and not overlayed with Health Bar. If you are heavy shield user like many sorcerer players, then you may like this option.",
			getFunc = function() return LUIE.UnitFrames.SV.CustomShieldBarSeparate end,
			setFunc = function(value) LUIE.UnitFrames.SV.CustomShieldBarSeparate = value end,
			width = "full",
			default = LUIE.UnitFrames.D.CustomShieldBarSeparate,
			warning = "Will need to reload the UI.",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[36] = {
			type = "slider",
			name = "Separate Shield Bar Height",
			--tooltip = "",
			min = 4, max = 12, step = 1,
			getFunc = function() return LUIE.UnitFrames.SV.CustomShieldBarHeight end,
			setFunc = function(value) LUIE.UnitFrames.SV.CustomShieldBarHeight = value LUIE.UnitFrames.CustomFramesApplyLayoutPlayer() LUIE.UnitFrames.CustomFramesApplyLayoutGroup() end,
			width = "full",
			default = LUIE.UnitFrames.D.CustomShieldBarHeight,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomShieldBarSeparate ) end,
		},
		[37] = {
			type = "checkbox",
			name = "Overlay Full Height Shield Bar",
			tooltip = "(When Shield bar is NOT separate) Use full-sized shield bar on top of health bar for Player, Target and Small Group custom frames instead of default half-height overlay bar.",
			getFunc = function() return LUIE.UnitFrames.SV.CustomShieldBarFull end,
			setFunc = function(value) LUIE.UnitFrames.SV.CustomShieldBarFull = value end,
			width = "full",
			default = LUIE.UnitFrames.D.CustomShieldBarFull,
			warning = "Will need to reload the UI.",
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and not LUIE.UnitFrames.SV.CustomShieldBarSeparate ) end,
		},
		[38] = {
			type = "checkbox",
			name = "Use Smooth Bar Transition",
			tooltip = "Use smooth transition on all bars when value get changed. Disabling this option could improve performance a little.",
			getFunc = function() return LUIE.UnitFrames.SV.CustomSmoothBar end,
			setFunc = function(value) LUIE.UnitFrames.SV.CustomSmoothBar = value end,
			width = "full",
			default = LUIE.UnitFrames.D.CustomSmoothBar,
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[39] = {
			type = "header",
			name = "Custom Unit Frames (Player, Target)",
			width = "full",
		},
		[40] = {
			type = "checkbox",
			name = "Enable This Addon PLAYER frame",
			tooltip = "Create custom Player unit frames.",
			getFunc = function() return LUIE.UnitFrames.SV.CustomFramesPlayer end,
			setFunc = function(value) LUIE.UnitFrames.SV.CustomFramesPlayer = value end,
			width = "full",
			default = LUIE.UnitFrames.D.CustomFramesPlayer,
			warning = "Will need to reload the UI.",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[41] = {
			type = "checkbox",
			name = "Enable This Addon TARGET frame",
			tooltip = "Create custom Target unit frames.",
			getFunc = function() return LUIE.UnitFrames.SV.CustomFramesTarget end,
			setFunc = function(value) LUIE.UnitFrames.SV.CustomFramesTarget = value end,
			width = "full",
			default = LUIE.UnitFrames.D.CustomFramesTarget,
			warning = "Will need to reload the UI.",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[42] = {
			type = "slider",
			name = "Player Bars Width",
			--tooltip = "",
			min = 200, max = 500, step = 5,
			getFunc = function() return LUIE.UnitFrames.SV.PlayerBarWidth end,
			setFunc = function(value) LUIE.UnitFrames.SV.PlayerBarWidth = value LUIE.UnitFrames.CustomFramesApplyLayoutPlayer() end,
			width = "full",
			default = LUIE.UnitFrames.D.PlayerBarWidth,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesPlayer ) end,
		},
		[43] = {
			type = "slider",
			name = "Player Health Bar Height",
			--tooltip = "",
			min = 20, max = 70, step = 1,
			getFunc = function() return LUIE.UnitFrames.SV.PlayerBarHeightHealth end,
			setFunc = function(value) LUIE.UnitFrames.SV.PlayerBarHeightHealth = value LUIE.UnitFrames.CustomFramesApplyLayoutPlayer() end,
			width = "full",
			default = LUIE.UnitFrames.D.PlayerBarHeightHealth,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesPlayer ) end,
		},
		[44] = {
			type = "slider",
			name = "Player Magicka/Stamina Bars Height",
			--tooltip = "",
			min = 20, max = 70, step = 1,
			getFunc = function() return LUIE.UnitFrames.SV.PlayerBarHeightOther end,
			setFunc = function(value) LUIE.UnitFrames.SV.PlayerBarHeightOther = value LUIE.UnitFrames.CustomFramesApplyLayoutPlayer() end,
			width = "full",
			default = LUIE.UnitFrames.D.PlayerBarHeightOther,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesPlayer ) end,
		},
		[45] = {
			type = "slider",
			name = "Spacing between Player Bars",
			--tooltip = "",
			min = -1, max = 4, step = 1,
			getFunc = function() return LUIE.UnitFrames.SV.PlayerBarSpacing end,
			setFunc = function(value) LUIE.UnitFrames.SV.PlayerBarSpacing = value LUIE.UnitFrames.CustomFramesApplyLayoutPlayer() end,
			width = "full",
			default = LUIE.UnitFrames.D.PlayerBarSpacing,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesPlayer ) end,
		},
		[46] = {
			type = "checkbox",
			name = "Display Your name on Player Frame",
			tooltip = "Display your character name and level on the player frame.",
			getFunc = function() return LUIE.UnitFrames.SV.PlayerEnableYourname end,
			setFunc = function(value) LUIE.UnitFrames.SV.PlayerEnableYourname = value LUIE.UnitFrames.CustomFramesApplyLayoutPlayer() end,
			width = "full",
			default = LUIE.UnitFrames.D.PlayerEnableYourname,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesPlayer ) end,
		},
		[47] = {
			type = "checkbox",
			name = "Display Mount/Siege/Werewolf bar",
			tooltip = "Display alternative meaning bar to track mount stamina, siege weapon health, werewolf time left.",
			getFunc = function() return LUIE.UnitFrames.SV.PlayerEnableAltbarMSW end,
			setFunc = function(value) LUIE.UnitFrames.SV.PlayerEnableAltbarMSW = value LUIE.UnitFrames.CustomFramesSetupAlternative() end,
			width = "full",
			default = LUIE.UnitFrames.D.PlayerEnableAltbarMSW,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesPlayer ) end,
		},
		[48] = {
			type = "checkbox",
			name = "Display XP/ChampionXP bar",
			tooltip = "Display alternative meaning bar to track player experience.",
			getFunc = function() return LUIE.UnitFrames.SV.PlayerEnableAltbarXP end,
			setFunc = function(value) LUIE.UnitFrames.SV.PlayerEnableAltbarXP = value LUIE.UnitFrames.CustomFramesSetupAlternative() end,
			width = "full",
			default = LUIE.UnitFrames.D.PlayerEnableAltbarXP,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesPlayer ) end,
		},
		[49] = {
			type = "checkbox",
			name = "ChampionXP bar Point-Type Colour",
			tooltip = "Set colour of ChampionXP bar (Experience bar for vr14 players) to be dependent on type of Champion Point being earned.",
			getFunc = function() return LUIE.UnitFrames.SV.PlayerChampionColour end,
			setFunc = function(value) LUIE.UnitFrames.SV.PlayerChampionColour = value LUIE.UnitFrames.OnChampionPointGained() end,
			width = "full",
			default = LUIE.UnitFrames.D.PlayerChampionColour,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesPlayer and LUIE.UnitFrames.SV.PlayerEnableAltbarXP ) end,
		},
		[50] = {
			type = "checkbox",
			name = "Display Armor stat change",
			tooltip = "Display additional icon on unit health bar when unit has its armor affected. Also displays cracked texture over health bar when armor is decreased.",
			getFunc = function() return LUIE.UnitFrames.SV.PlayerEnableArmor end,
			setFunc = function(value) LUIE.UnitFrames.SV.PlayerEnableArmor = value end,
			width = "full",
			default = LUIE.UnitFrames.D.PlayerEnableArmor,
			warning = "Will need to reload the UI.",
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and ( LUIE.UnitFrames.SV.CustomFramesPlayer or LUIE.UnitFrames.SV.CustomFramesTarget ) ) end,
		},
		[51] = {
			type = "checkbox",
			name = "Display Power stat change",
			tooltip = "Display additional icon on unit health bar when unit has its power affected.",
			getFunc = function() return LUIE.UnitFrames.SV.PlayerEnablePower end,
			setFunc = function(value) LUIE.UnitFrames.SV.PlayerEnablePower = value end,
			width = "full",
			default = LUIE.UnitFrames.D.PlayerEnablePower,
			warning = "Will need to reload the UI.",
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and ( LUIE.UnitFrames.SV.CustomFramesPlayer or LUIE.UnitFrames.SV.CustomFramesTarget ) ) end,
		},
		[52] = {
			type = "slider",
			name = "Out-of-Combat frame opacity",
			tooltip = "Opacity of Player custom frame when not engaged in combat.",
			min = 0, max = 100, step = 5,
			getFunc = function() return LUIE.UnitFrames.SV.CustomOocAlpha end,
			setFunc = function(value) LUIE.UnitFrames.SV.CustomOocAlpha = value LUIE.UnitFrames.CustomFramesApplyInCombat() end,
			width = "full",
			default = LUIE.UnitFrames.D.CustomOocAlpha,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and ( LUIE.UnitFrames.SV.CustomFramesPlayer or LUIE.UnitFrames.SV.CustomFramesTarget ) ) end,
		},
		[53] = {
			type = "slider",
			name = "In-Combat frame opacity",
			tooltip = "Opacity of Player custom frame when engaged in combat.",
			min = 0, max = 100, step = 5,
			getFunc = function() return LUIE.UnitFrames.SV.CustomIncAlpha end,
			setFunc = function(value) LUIE.UnitFrames.SV.CustomIncAlpha = value LUIE.UnitFrames.CustomFramesApplyInCombat() end,
			width = "full",
			default = LUIE.UnitFrames.D.CustomIncAlpha,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and ( LUIE.UnitFrames.SV.CustomFramesPlayer or LUIE.UnitFrames.SV.CustomFramesTarget ) ) end,
		},
		[54] = {
			type = "checkbox",
			name = "Treat Missing Power as In-Combat",
			-- tooltip = "",
			getFunc = function() return LUIE.UnitFrames.SV.CustomOocAlphaPower end,
			setFunc = function(value) LUIE.UnitFrames.SV.CustomOocAlphaPower = value LUIE.UnitFrames.CustomFramesApplyInCombat() end,
			width = "full",
			default = LUIE.UnitFrames.D.CustomOocAlphaPower,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and ( LUIE.UnitFrames.SV.CustomFramesPlayer or LUIE.UnitFrames.SV.CustomFramesTarget ) ) end,
		},
		[55] = {
			type = "checkbox",
			name = "Apply same opacity to Target frame",
			tooltip = "Apply same transparency setting to Target frame as well. If this option is disabled, the Targets frame will have always 'In-Combat' values of opacity.",
			getFunc = function() return LUIE.UnitFrames.SV.CustomOocAlphaTarget end,
			setFunc = function(value) LUIE.UnitFrames.SV.CustomOocAlphaTarget = value LUIE.UnitFrames.CustomFramesApplyInCombat() end,
			width = "full",
			default = LUIE.UnitFrames.D.CustomOocAlphaTarget,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesTarget ) end,
		},
		[56] = {
			type = "slider",
			name = "Target Bars Width",
			--tooltip = "",
			min = 200, max = 500, step = 5,
			getFunc = function() return LUIE.UnitFrames.SV.TargetBarWidth end,
			setFunc = function(value) LUIE.UnitFrames.SV.TargetBarWidth = value LUIE.UnitFrames.CustomFramesApplyLayoutPlayer() end,
			width = "full",
			default = LUIE.UnitFrames.D.TargetBarWidth,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesTarget ) end,
		},
		[57] = {
			type = "slider",
			name = "Target Bar Height",
			--tooltip = "",
			min = 20, max = 70, step = 1,
			getFunc = function() return LUIE.UnitFrames.SV.TargetBarHeight end,
			setFunc = function(value) LUIE.UnitFrames.SV.TargetBarHeight = value LUIE.UnitFrames.CustomFramesApplyLayoutPlayer() end,
			width = "full",
			default = LUIE.UnitFrames.D.TargetBarHeight,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesTarget ) end,
		},
		[58] = {
			type = "checkbox",
			name = "Display Target class label",
			tooltip = "Display text label with target class name on target frame together with class icon.",
			getFunc = function() return LUIE.UnitFrames.SV.TargetEnableClass end,
			setFunc = function(value) LUIE.UnitFrames.SV.TargetEnableClass = value end,
			width = "full",
			default = LUIE.UnitFrames.D.TargetEnableClass,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesTarget ) end,
		},
		[59] = {
			type = "checkbox",
			name = "Display Skull Execute Texture",
			tooltip = "Display Skull texture next to custom target frame for low-health target that should be executed.",
			getFunc = function() return LUIE.UnitFrames.SV.TargetEnableSkull end,
			setFunc = function(value) LUIE.UnitFrames.SV.TargetEnableSkull = value end,
			width = "full",
			default = LUIE.UnitFrames.D.TargetEnableSkull,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesTarget ) end,
		},
		[60] = {
			type = "header",
			name = "Custom Unit Frames (Group)",
			width = "full",
		},
		[61] = {
			type = "checkbox",
			name = "Enable This Addon GROUP frames",
			tooltip = "Create custom GROUP unit frames.",
			getFunc = function() return LUIE.UnitFrames.SV.CustomFramesGroup end,
			setFunc = function(value) LUIE.UnitFrames.SV.CustomFramesGroup = value end,
			width = "full",
			default = LUIE.UnitFrames.D.CustomFramesGroup,
			warning = "Will need to reload the UI.",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[62] = {
			type = "checkbox",
			name = "Enable Default GROUP frames",
			tooltip = "This will show default UI small group unit frames when group size is less or equal then 4.",
			getFunc = function() return not ( LUIE.UnitFrames.SV.GroupDisableDefault and (LUIE.UnitFrames.SV.CustomFramesGroup or LUIE.UnitFrames.SV.CustomFramesRaid) ) end,
			setFunc = function(value) LUIE.UnitFrames.SV.GroupDisableDefault = not value LUIE.UnitFrames.CustomFramesGroupUpdate() end,
			width = "full",
			default = not LUIE.UnitFrames.D.GroupDisableDefault,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and (LUIE.UnitFrames.SV.CustomFramesGroup or LUIE.UnitFrames.SV.CustomFramesRaid) ) end,
		},
		[63] = {
			type = "checkbox",
			name = "Include Player in Group Frame",
			-- tooltip = "",
			getFunc = function() return not LUIE.UnitFrames.SV.GroupExcludePlayer end,
			setFunc = function(value) LUIE.UnitFrames.SV.GroupExcludePlayer = (not value) LUIE.UnitFrames.CustomFramesGroupUpdate() end,
			width = "full",
			default = not LUIE.UnitFrames.D.GroupExcludePlayer,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesGroup ) end,
		},
		[64] = {
			type = "slider",
			name = "Group Bars Width",
			--tooltip = "",
			min = 100, max = 400, step = 5,
			getFunc = function() return LUIE.UnitFrames.SV.GroupBarWidth end,
			setFunc = function(value) LUIE.UnitFrames.SV.GroupBarWidth = value LUIE.UnitFrames.CustomFramesApplyLayoutGroup() end,
			width = "full",
			default = LUIE.UnitFrames.D.GroupBarWidth,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesGroup ) end,
		},
		[65] = {
			type = "slider",
			name = "Group Bars Height",
			--tooltip = "",
			min = 20, max = 70, step = 1,
			getFunc = function() return LUIE.UnitFrames.SV.GroupBarHeight end,
			setFunc = function(value) LUIE.UnitFrames.SV.GroupBarHeight = value LUIE.UnitFrames.CustomFramesApplyLayoutGroup() end,
			width = "full",
			default = LUIE.UnitFrames.D.GroupBarHeight,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesGroup ) end,
		},
		[66] = {
			type = "slider",
			name = "Spacing between Group Bars",
			--tooltip = "",
			min = 20, max = 80, step = 2,
			getFunc = function() return LUIE.UnitFrames.SV.GroupBarSpacing end,
			setFunc = function(value) LUIE.UnitFrames.SV.GroupBarSpacing = value LUIE.UnitFrames.CustomFramesApplyLayoutGroup() end,
			width = "full",
			default = LUIE.UnitFrames.D.GroupBarSpacing,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesGroup ) end,
		},
		[67] = {
			type = "header",
			name = "Custom Unit Frames (Raid)",
			width = "full",
		},
		[68] = {
			type = "checkbox",
			name = "Enable This Addon RAID frames",
			tooltip = "Create custom RAID unit frames. If custom GROUP frames are used, then this raid frame will also be used for small groups.",
			getFunc = function() return LUIE.UnitFrames.SV.CustomFramesRaid end,
			setFunc = function(value) LUIE.UnitFrames.SV.CustomFramesRaid = value end,
			width = "full",
			default = LUIE.UnitFrames.D.CustomFramesRaid,
			warning = "Will need to reload the UI.",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[69] = {
			type = "checkbox",
			name = "Enable Default RAID frames",
			tooltip = "This will show default UI RAID unit frames when group size is larger then 4.",
			getFunc = function() return not ( LUIE.UnitFrames.SV.RaidDisableDefault and LUIE.UnitFrames.SV.CustomFramesRaid ) end,
			setFunc = function(value) LUIE.UnitFrames.SV.RaidDisableDefault = not value LUIE.UnitFrames.CustomFramesGroupUpdate() end,
			width = "full",
			default = not LUIE.UnitFrames.D.RaidDisableDefault,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesRaid ) end,
		},
		[70] = {
			type = "slider",
			name = "Raid Bars Width",
			--tooltip = "",
			min = 100, max = 500, step = 5,
			getFunc = function() return LUIE.UnitFrames.SV.RaidBarWidth end,
			setFunc = function(value) LUIE.UnitFrames.SV.RaidBarWidth = value LUIE.UnitFrames.CustomFramesApplyLayoutRaid() end,
			width = "full",
			default = LUIE.UnitFrames.D.RaidBarWidth,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesRaid ) end,
		},
		[71] = {
			type = "slider",
			name = "Raid Bars Height",
			--tooltip = "",
			min = 20, max = 70, step = 1,
			getFunc = function() return LUIE.UnitFrames.SV.RaidBarHeight end,
			setFunc = function(value) LUIE.UnitFrames.SV.RaidBarHeight = value LUIE.UnitFrames.CustomFramesApplyLayoutRaid() end,
			width = "full",
			default = LUIE.UnitFrames.D.RaidBarHeight,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesRaid ) end,
		},
		[72] = {
			type = "dropdown",
			name = "Raid Frame Layout",
			tooltip = "Select layout of raid frame in format 'columns*rows'.",
			choices = { '1 x 24', '2 x 12', '3 x 8', '4 x 6', '6 x 4' },
			-- sort = "name-up",
			getFunc = function() return LUIE.UnitFrames.SV.RaidLayout end,
			setFunc = function(var) LUIE.UnitFrames.SV.RaidLayout = var LUIE.UnitFrames.CustomFramesApplyLayoutRaid() end,
			width = "full",
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesRaid ) end,
			default = LUIE.UnitFrames.D.RaidLayout,
		},
		--[[
		[xx] = {
			type = "checkbox",
			name = "Sort Raid Frame",
			tooltip = "Perform alphabetic sort of members in raid-size group. This is a default UI behaviour. If for any reason you prefer to have raid members sorted according to internal game numbering, you can switch off this option.",
			getFunc = function() return LUIE.UnitFrames.SV.RaidSort end,
			setFunc = function(value) LUIE.UnitFrames.SV.RaidSort = value LUIE.UnitFrames.CustomFramesGroupUpdate() end,
			width = "full",
			default = LUIE.UnitFrames.D.RaidSort,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesRaid ) end,
		},]]
		[73] = {
			type = "checkbox",
			name = "Add Spacer for every 4 members",
			tooltip = "Add a small spacer between raid members frames to visualize default group splitting.",
			getFunc = function() return LUIE.UnitFrames.SV.RaidSpacers end,
			setFunc = function(value) LUIE.UnitFrames.SV.RaidSpacers = value LUIE.UnitFrames.CustomFramesApplyLayoutRaid() end,
			width = "full",
			default = LUIE.UnitFrames.D.RaidSpacers,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesRaid ) end,
		},
		[74] = {
			type = "header",
			name = "Custom Unit Frames (Boss)",
			width = "full",
		},
		[75] = {
			type = "checkbox",
			name = "Enable This Addon BOSS frames",
			tooltip = "Create custom BOSS unit frames. This will track health of up to 6 bosses in dungeons encounters.",
			getFunc = function() return LUIE.UnitFrames.SV.CustomFramesBosses end,
			setFunc = function(value) LUIE.UnitFrames.SV.CustomFramesBosses = value end,
			width = "full",
			default = LUIE.UnitFrames.D.CustomFramesBosses,
			warning = "Will need to reload the UI.",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[76] = {
			type = "header",
			name = "Custom Unit Frames (PvP Target Frame)",
			width = "full",
		},
		[77] = {
			type = "checkbox",
			name = "Enable additional PvP Target frame",
			tooltip = "Create additional custom target unit frames. This will track health of hostile pvp players only. It also by default has larger size, less information and positioned on screen center.",
			getFunc = function() return LUIE.UnitFrames.SV.AvaCustFramesTarget end,
			setFunc = function(value) LUIE.UnitFrames.SV.AvaCustFramesTarget = value end,
			width = "full",
			default = LUIE.UnitFrames.D.AvaCustFramesTarget,
			warning = "Will need to reload the UI.",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[78] = {
			type = "slider",
			name = "PvP Target Bars Width",
			--tooltip = "",
			min = 300, max = 700, step = 5,
			getFunc = function() return LUIE.UnitFrames.SV.AvaTargetBarWidth end,
			setFunc = function(value) LUIE.UnitFrames.SV.AvaTargetBarWidth = value LUIE.UnitFrames.CustomFramesApplyLayoutPlayer() end,
			width = "full",
			default = LUIE.UnitFrames.D.AvaTargetBarWidth,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.AvaCustFramesTarget ) end,
		},
		[79] = {
			type = "slider",
			name = "PvP Target Bar Height",
			--tooltip = "",
			min = 20, max = 70, step = 1,
			getFunc = function() return LUIE.UnitFrames.SV.AvaTargetBarHeight end,
			setFunc = function(value) LUIE.UnitFrames.SV.AvaTargetBarHeight = value LUIE.UnitFrames.CustomFramesApplyLayoutPlayer() end,
			width = "full",
			default = LUIE.UnitFrames.D.AvaTargetBarHeight,
			disabled = function() return not ( LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.AvaCustFramesTarget ) end,
		},
		[80] = {
			type = "header",
			name = "Common options",
			width = "full",
		},
		[81] = {
			type = "colorpicker",
			name = "Default Caption Colour",
			getFunc = function() return unpack(LUIE.UnitFrames.SV.Target_FontColour) end,
			setFunc = function(r,g,b,a) LUIE.UnitFrames.SV.Target_FontColour={r,g,b} end,
			width = "full",
			default = { r=LUIE.UnitFrames.D.Target_FontColour[1], g=LUIE.UnitFrames.D.Target_FontColour[2], b=LUIE.UnitFrames.D.Target_FontColour[3] },
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[82] = {
			type = "colorpicker",
			name = "Friendly NPC Font Colour",
			getFunc = function() return unpack(LUIE.UnitFrames.SV.Target_FontColour_FriendlyNPC) end,
			setFunc = function(r,g,b,a) LUIE.UnitFrames.SV.Target_FontColour_FriendlyNPC={r,g,b} end,
			width = "full",
			default = { r=LUIE.UnitFrames.D.Target_FontColour_FriendlyNPC[1], g=LUIE.UnitFrames.D.Target_FontColour_FriendlyNPC[2], b=LUIE.UnitFrames.D.Target_FontColour_FriendlyNPC[3] },
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[83] = {
			type = "colorpicker",
			name = "Friendly Player Font Colour",
			getFunc = function() return unpack(LUIE.UnitFrames.SV.Target_FontColour_FriendlyPlayer) end,
			setFunc = function(r,g,b,a) LUIE.UnitFrames.SV.Target_FontColour_FriendlyPlayer={r,g,b} end,
			width = "full",
			default = { r=LUIE.UnitFrames.D.Target_FontColour_FriendlyPlayer[1], g=LUIE.UnitFrames.D.Target_FontColour_FriendlyPlayer[2], b=LUIE.UnitFrames.D.Target_FontColour_FriendlyPlayer[3] },
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[84] = {
			type = "colorpicker",
			name = "Hostile Font Colour",
			getFunc = function() return unpack(LUIE.UnitFrames.SV.Target_FontColour_Hostile) end,
			setFunc = function(r,g,b,a) LUIE.UnitFrames.SV.Target_FontColour_Hostile={r,g,b} end,
			width = "full",
			default = { r=LUIE.UnitFrames.D.Target_FontColour_Hostile[1], g=LUIE.UnitFrames.D.Target_FontColour_Hostile[2], b=LUIE.UnitFrames.D.Target_FontColour_Hostile[3] },
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[85] = {
			type = "checkbox",
			name = "Apply same settings to reticle",
			tooltip = "Change the colour of reticle (cross-hair) according to unit reaction.",
			getFunc = function() return LUIE.UnitFrames.SV.ReticleColourByReaction end,
			setFunc = LUIE.UnitFrames.ReticleColourByReaction,
			width = "full",
			default = LUIE.UnitFrames.D.ReticleColourByReaction,
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
		},
		[86] = {
			type = "colorpicker",
			name = "Interactible Reticle Colour",
			getFunc = function() return unpack(LUIE.UnitFrames.SV.ReticleColour_Interact) end,
			setFunc = function(r,g,b,a) LUIE.UnitFrames.SV.ReticleColour_Interact={r,g,b} end,
			width = "full",
			default = { r=LUIE.UnitFrames.D.ReticleColour_Interact[1], g=LUIE.UnitFrames.D.ReticleColour_Interact[2], b=LUIE.UnitFrames.D.ReticleColour_Interact[3] },
			disabled = function() return not (LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.ReticleColourByReaction) end,
		},
		[87] = {
			type = "dropdown",
			name = "Target display name",
			--tooltip = "",
			choices = NameDisplayOptions,
			sort = "name-up",
			getFunc = function() return LUIE.UnitFrames.SV.DisplayOptions end,
			setFunc = function(var) LUIE.UnitFrames.SV.showNameAccChar = var LUIE.UnitFrames.UpdateStaticControls() end,
			width = "full",
			disabled = function() return not LUIE.SV.UnitFrames_Enabled end,
			default = LUIE.UnitFrames.D.Character,
		},
	}
	
--[[	
	[15] = {
					type = "dropdown",
					name = "Font Style",
					--tooltip = "",
					choices = styleOptions,
					sort = "name-up",
					getFunc = function() return LUIE.SpellCastBuffs.SV.BuffFontStyle end,
					setFunc = function(var) LUIE.SpellCastBuffs.SV.BuffFontStyle = var LUIE.SpellCastBuffs.ApplyFont() end,
					width = "full",
					default = LUIE.SpellCastBuffs.D.BuffFontStyle,
					disabled = function() return not ( LUIE.SV.SpellCastBuff_Enable and LUIE.SpellCastBuffs.SV.RemainingText ) end,
				},
]]
	LAM2:RegisterAddonPanel('LUIEAddonOptions', panelData)
	LAM2:RegisterOptionControls('LUIEAddonOptions', optionsData)

	LAM2:RegisterAddonPanel('LUIEUnitFramesOptions', panelDataUnitFrames)
	LAM2:RegisterOptionControls('LUIEUnitFramesOptions', optionsDataUnitFrames)
end

local function LUIE_LoadScreen()
	EVENT_MANAGER:UnregisterForEvent(LUIE.name, EVENT_PLAYER_ACTIVATED)

	if not LUIE.SV.StartupInfo then
		CHAT_SYSTEM:AddMessage("|ceeeeeeLUIE by |c00c000 Upularity and SpellBuilder|ceeeeee v"..g_Version.."|r")
	end
end

--[[ 
 * Runs on the EVENT_ACTION_LAYER_POPPED and EVENT_ACTION_LAYER_PUSHED listeners.
 * This handler is used to hide and show all GUI elements when player opens any sort of menu.
 ]]--
local function LUIE_ToggleVisibility(eventCode, layerIndex, activeLayerIndex)
	local hidden = ( activeLayerIndex > 2 )
	for _, control in pairs( LUIE.components ) do
		control:SetHidden( hidden )
	end
end 

local function LUIE_RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(LUIE.name, EVENT_PLAYER_ACTIVATED, LUIE_LoadScreen)
	EVENT_MANAGER:RegisterForEvent(LUIE.name, EVENT_ACTION_LAYER_POPPED, LUIE_ToggleVisibility)
	EVENT_MANAGER:RegisterForEvent(LUIE.name, EVENT_ACTION_LAYER_PUSHED, LUIE_ToggleVisibility)
end

-- LuiExtended Initialization
local function LUIE_OnAddOnLoaded(eventCode, addonName)
	-- Only initialize our own addon
	if LUIE.name ~= addonName then return end
	-- Once we know it's ours, lets unregister the event listener
	EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)

	-- Load additional media from LMP and other addons
	LUIE_LoadMedia()
	
	-- Load saved variables
	LUIE_LoadSavedVars()

	-- Initialize this addon modules according to user preferences
	LUIE.UnitFrames.Initialize( LUIE.SV.UnitFrames_Enabled )
	LUIE.InfoPanel.Initialize( LUIE.SV.InfoPanel_Enabled )
	LUIE.CombatInfo.Initialize( LUIE.SV.CombatInfo_Enabled )
	LUIE.SpellCastBuffs.Initialize( LUIE.SV.SpellCastBuff_Enable )
	LUIE.DamageMeter.Initialize(LUIE.SV.DamageMeter_Enable)
	LUIE.ChatAnnouncements.Initialize()

	-- Create settings menu for our addon
	LUIE_CreateSettings()

	-- register global event listeners
	LUIE_RegisterEvents()
end

--[[----------------------------------------------------------
	DELAY BUFFER
--]]----------------------------------------------------------
local delayBuffer = {}

function LUIE.DelayBuffer( key, buffer, currentTime )
	if key == nil then return end

	local buffer = buffer or 10
	local now    = currentTime or GetFrameTimeMilliseconds()

	if delayBuffer[key] == nil then
		delayBuffer[key] = now
		return true -- for first call of DelayBuffer we should return true
	end
	local eval = ( now - delayBuffer[key] ) >= buffer
	if eval then
		delayBuffer[key] = now
	end
	return eval
end

--[[----------------------------------------------------------
	Helper and utility functions
--]]----------------------------------------------------------

--[[ 
 * Returns a formatted number with commas
 ]]--
 
 --Function no comma to be added in a later date.
function LUIE.CommaValue(number, shorten, noncomma)
	if number > 0 and shorten then
		local value, suffix

		if number >= 1000000000 then
			value = number / 1000000000
			suffix = 'G'
		elseif number >= 1000000 then
			value = number / 1000000
			suffix = 'M'
		elseif number >= 1000 then
			value = number / 1000
			suffix = 'k'
		else
			value = number
		end
		
		-- if we could not conver even to 'G', return full number with commas
		if value >= 1000 then
			value = LUIE.CommaValue(number)
		elseif value >= 100 or suffix == nil then
			value = strformat('%d', value)
		elseif value >= 10 then
			value = strformat('%.1f', value)
		else
			value = strformat('%.2f', value)
		end

		if suffix ~= nil then
			value = value .. suffix
		end

		return value
	end

	local number = tostring(number)
	-- no shortening was done, so print number with commas
	local left,num,right = string.match(number,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

-- Hook initialization
EVENT_MANAGER:RegisterForEvent(LUIE.name, EVENT_ADD_ON_LOADED, LUIE_OnAddOnLoaded)
