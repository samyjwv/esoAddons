local adr = ActionDurationReminder
local tinsert = table.insert

function adr.SettingsLoad()
	adr.soundChoices = {}
	for k,v in pairs(SOUNDS) do
		tinsert(adr.soundChoices, k)
	end
	table.sort(adr.soundChoices)
	adr.savedVarsDefaults = {
		showShiftActions = true,
		multipleTargetTracking = true,
		secondsBeforeFade = 5,
		minimumDurationSeconds = 3,
		labelFontName = "BOLD_FONT",
		labelFontSize = 18,
		labelYOffset = 0,
		cooldownVisible = true,
		cooldownColor = {1,1,0},
		cooldownOpacity = 100,
		cooldownThickness = 2,
		positionGap = 5,
		shiftBarOffsetX = 0,
		shiftBarOffsetY = 0,
		alertEnabled = false,
		alertPlaySound = true,
		alertSoundIndex = 266,
		alertAheadSeconds = 1,
		alertKeepSeconds = 2,
		alertIconSize = 50,
		alertFontName = "BOLD_FONT",
		alertFontSize = 32,
		alertOffsetX = 0,
		alertOffsetY = 0,
	}
	adr.savedVars = ZO_SavedVars:NewAccountWide( adr.savedVarsName, adr.savedVarsVersion, nil, adr.savedVarsDefaults )
end


function adr.SettingsMenu()
	local LAM2 = LibStub("LibAddonMenu-2.0")
	if LAM2 == nil then return end
	local panelData = {
		type = 'panel',
		name = adr.name,
		displayName = "ADR Settings",
		author = "Cloudor",
		version = adr.version,
		website = "http://www.esoui.com/downloads/info1536-ActionDurationReminder.html",
		slashCommand = "/adrset",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local optionsData = {
		--
		{
			type = "checkbox",
			name = "Multiple Target Tracking",
			getFunc = function() return adr.savedVars.multipleTargetTracking end,
			setFunc = function(value) adr.savedVars.multipleTargetTracking = value end,
			width = "full",
			default = adr.savedVarsDefaults.multipleTargetTracking,
		},
		--
		{
			type = "checkbox",
			name = "Shift Bar Enabled",
			getFunc = function() return adr.savedVars.showShiftActions end,
			setFunc = function(value) adr.savedVars.showShiftActions = value end,
			width = "full",
			default = adr.savedVarsDefaults.showShiftActions,
		},
		--
		{
			type = "button",
			name = "Move Shift Bar",
			func = function()
				SCENE_MANAGER:Hide("gameMenuInGame")
				adr.UtilOpenShiftBarFrame()
				zo_callLater(function()
					SetGameCameraUIMode(true)
				end, 10) 
			end,
			width = "full",
			disabled = function() return not adr.savedVars.showShiftActions end,
		},
		--
		{
			type = "slider",
			name = "Seconds to Keep Timer After Timeout",
			min = 0, max = 10, step = 1,
			getFunc = function() return adr.savedVars.secondsBeforeFade end,
			setFunc = function(value) adr.savedVars.secondsBeforeFade = value end,
			width = "full",
			default = adr.savedVarsDefaults.secondsBeforeFade,
		},
		--
		{
			type = "slider",
			name = "Exclude Short Duration Seconds",
			min = 2, max = 5, step = 0.5,
			getFunc = function() return adr.savedVars.minimumDurationSeconds end,
			setFunc = function(value) adr.savedVars.minimumDurationSeconds = value end,
			width = "full",
			default = adr.savedVarsDefaults.minimumDurationSeconds,
		},
		--
		{
			type = "dropdown",
			name = "Label Font Name",
			choices = {"MEDIUM_FONT", "BOLD_FONT", "CHAT_FONT", "ANTIQUE_FONT", "HANDWRITTEN_FONT", "STONE_TABLET_FONT", "GAMEPAD_MEDIUM_FONT", "GAMEPAD_BOLD_FONT"},
			getFunc = function() return adr.savedVars.labelFontName end,
			setFunc = function(value) adr.savedVars.labelFontName = value ; adr.UtilUpdateAllLabelsFont() end,
			width = "full",
			default = adr.savedVarsDefaults.labelFontName,
		},
		--
		{
			type = "slider",
			name = "Label Font Size",
			--tooltip = "",
			min = 12, max = 24, step = 1,
			getFunc = function() return adr.savedVars.labelFontSize end,
			setFunc = function(value) adr.savedVars.labelFontSize = value ; adr.UtilUpdateAllLabelsFont() end,
			width = "full",
			default = adr.savedVarsDefaults.labelFontSize,
		},
		--
		{
			type = "slider",
			name = "Label Vertical Offset",
			min = -50, max = 50, step = 5,
			getFunc = function() return adr.savedVars.labelYOffset end,
			setFunc = function(value) adr.savedVars.labelYOffset = value ; adr.UtilUpdateAllLabelsYOffset() end,
			width = "full",
			default = adr.savedVarsDefaults.labelYOffset,
		},
		--
		{
			type = "checkbox",
			name = "Line Enabled",
			getFunc = function() return adr.savedVars.cooldownVisible end,
			setFunc = function(value) adr.savedVars.cooldownVisible = value; adr.UtilUpdateAllCooldownVisible() end,
			width = "full",
			default = adr.savedVarsDefaults.cooldownVisible,
		},
		--
		{
			type = "slider",
			name = "Line Thickness",
			min = 1, max = 5, step = 1,
			getFunc = function() return adr.savedVars.cooldownThickness end,
			setFunc = function(value) adr.savedVars.cooldownThickness = value ; adr.UtilUpdateAllCooldownVisible() end,
			disabled = function() return not adr.savedVars.cooldownVisible end,
			width = "full",
			default = adr.savedVarsDefaults.cooldownThickness,
		},
		--
		{
			type = "slider",
			name = "Line Opacity %",
			min = 10, max = 100, step = 10,
			getFunc = function() return adr.savedVars.cooldownOpacity end,
			setFunc = function(value) adr.savedVars.cooldownOpacity = value ; adr.UtilUpdateAllCooldownOpacity() end,
			disabled = function() return not adr.savedVars.cooldownVisible end,
			width = "full",
			default = adr.savedVarsDefaults.cooldownOpacity,
		},
		--
		{
			type = "colorpicker",
			name = "Line Color",
			getFunc = function() return unpack(adr.savedVars.cooldownColor) end,
			setFunc = function(r,g,b,a) adr.savedVars.cooldownColor={r,g,b}; adr.UtilUpdateAllCooldownColor() end,
			width = "full",
			disabled = function() return not adr.savedVars.cooldownVisible end,
			default = {
				r = adr.savedVarsDefaults.cooldownColor[1],
				g = adr.savedVarsDefaults.cooldownColor[2],
				b = adr.savedVarsDefaults.cooldownColor[3],
			},
		},
		--
		{
			type = "slider",
			name = "Position Gap",
			--tooltip = "",
			min = 0, max = 20, step = 1,
			getFunc = function() return adr.savedVars.positionGap end,
			setFunc = function(value) adr.savedVars.positionGap = value;adr.UtilUpdateShiftPosition() end,
			width = "full",
			default = adr.savedVarsDefaults.positionGap,
		},
		--
		{
			type = "header",
			name = "Alert",
			width = "full",	
		},
		--
		{
			type = "checkbox",
			name = "Enabled",
			getFunc = function() return adr.savedVars.alertEnabled end,
			setFunc = function(value) adr.savedVars.alertEnabled = value end,
			width = "full",
			default = adr.savedVarsDefaults.alertEnabled,
		},
		--
		{
			type = "button",
			name = "Move Alert Frame",
			func = function()
				SCENE_MANAGER:Hide("gameMenuInGame")
				adr.UtilOpenAlertFrame()
				zo_callLater(function()
					SetGameCameraUIMode(true)
				end, 10) 
			end,
			width = "full",
			disabled = function() return not adr.savedVars.alertEnabled end,
		},
		--
		{
			type = "checkbox",
			name = "Sound Enabled",
			getFunc = function() return adr.savedVars.alertPlaySound end,
			setFunc = function(value) adr.savedVars.alertPlaySound = value end,
			disabled = function() return not adr.savedVars.alertEnabled end,
			width = "full",
			default = adr.savedVarsDefaults.alertPlaySound,
		},
		--
		{
			type = "slider",
			name = "Sound Select Index",
			--tooltip = "",
			min = 1, max = #adr.soundChoices, step = 1,
			getFunc = function() return adr.savedVars.alertSoundIndex end,
			setFunc = function(value) adr.savedVars.alertSoundIndex = value; PlaySound(SOUNDS[adr.soundChoices[adr.savedVars.alertSoundIndex]]) end,
			width = "full",
			disabled = function() return not adr.savedVars.alertPlaySound or not adr.savedVars.alertEnabled end,
			default = adr.savedVarsDefaults.alertSoundIndex,
		},
		--
		{
			type = "button",
			name = "Sound Test",
			func = function()
				PlaySound(SOUNDS[adr.soundChoices[adr.savedVars.alertSoundIndex]])
			end,
			width = "full",
			disabled = function() return not adr.savedVars.alertPlaySound or not adr.savedVars.alertEnabled end,
		},
		--
		{
			type = "slider",
			name = "Ahead Seconds",
			--tooltip = "",
			min = 0, max = 3, step = 0.5,
			getFunc = function() return adr.savedVars.alertAheadSeconds end,
			setFunc = function(value) adr.savedVars.alertAheadSeconds = value end,
			width = "full",
			disabled = function() return not adr.savedVars.alertEnabled end,
			default = adr.savedVarsDefaults.alertAheadSeconds,
		},
		--
		{
			type = "slider",
			name = "Show Seconds",
			--tooltip = "",
			min = 1, max = 5, step = 0.5,
			getFunc = function() return adr.savedVars.alertKeepSeconds end,
			setFunc = function(value) adr.savedVars.alertKeepSeconds = value end,
			width = "full",
			disabled = function() return not adr.savedVars.alertEnabled end,
			default = adr.savedVarsDefaults.alertKeepSeconds,
		},
		--
		{
			type = "dropdown",
			name = "Font Name",
			choices = {"MEDIUM_FONT", "BOLD_FONT", "CHAT_FONT", "ANTIQUE_FONT", "HANDWRITTEN_FONT", "STONE_TABLET_FONT", "GAMEPAD_MEDIUM_FONT", "GAMEPAD_BOLD_FONT"},
			getFunc = function() return adr.savedVars.alertFontName end,
			setFunc = function(value) adr.savedVars.alertFontName = value end,
			disabled = function() return not adr.savedVars.alertEnabled end,
			width = "full",
			default = adr.savedVarsDefaults.alertFontName,
		},
		--
		{
			type = "slider",
			name = "Font Size",
			--tooltip = "",
			min = 18, max = 48, step = 2,
			getFunc = function() return adr.savedVars.alertFontSize end,
			setFunc = function(value) adr.savedVars.alertFontSize = value end,
			disabled = function() return not adr.savedVars.alertEnabled end,
			width = "full",
			default = adr.savedVarsDefaults.alertFontSize,
		},
		--
		
	}
	LAM2:RegisterAddonPanel('ADRAddonOptions', panelData)
	LAM2:RegisterOptionControls('ADRAddonOptions', optionsData)
end