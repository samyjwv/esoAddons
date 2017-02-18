local Azurah	= _G['Azurah'] -- grab addon table from global
local LAM		= LibStub('LibAddonMenu-2.0')
local LMP		= LibStub('LibMediaProvider-1.0')
local L			= Azurah:GetLocale()

-- UPVALUES --
local WM					= GetWindowManager()
local CM					= CALLBACK_MANAGER
local tinsert 				= table.insert
local tremove				= table.remove
local tsort					= table.sort
local strformat				= string.format

-- DROPDOWN CHOICES --
local dropOverlay			= {L.DropOverlay1, L.DropOverlay2, L.DropOverlay3, L.DropOverlay4, L.DropOverlay5, L.DropOverlay6}
local dropOverlayRef		= {[L.DropOverlay1] = 1, [L.DropOverlay2] = 2, [L.DropOverlay3] = 3, [L.DropOverlay4] = 4, [L.DropOverlay5] = 5, [L.DropOverlay6] = 6}
local dropColourBy			= {L.DropColourBy1, L.DropColourBy2, L.DropColourBy3}
local dropColourByRef		= {[L.DropColourBy1] = 1, [L.DropColourBy2] = 2, [L.DropColourBy3] = 3}
local dropExpBarStyle		= {L.DropExpBarStyle1, L.DropExpBarStyle2, L.DropExpBarStyle3}
local dropExpBarStyleRef	= {[L.DropExpBarStyle1] = 1, [L.DropExpBarStyle2] = 2, [L.DropExpBarStyle3] = 3}
local dropFontStyle			= {'none', 'outline', 'thin-outline', 'thick-outline', 'shadow', 'soft-shadow-thin', 'soft-shadow-thick'}

local tabButtons			= {}
local tabPanels				= {}
local lastAddedControl		= {}
local settingsGlobalStr		= strformat('%s_%s', Azurah.name, 'Settings')
local settingsGlobalStrBtns	= strformat('%s_%s', settingsGlobalStr, 'TabButtons')
local controlPanel, controlPanelWidth, tabButtonsPanel, tabPanelData

local profileGuard			= false
local profileCopyList		= {}
local profileDeleteList		= {}
local profileCopyToCopy, profileDeleteToDelete, profileDeleteDropRef


-- ------------------------
-- PROFILE FUNCTIONS
-- ------------------------
local function CopyTable(src, dest)
	if (type(dest) ~= 'table') then
		dest = {}
	end

	if (type(src) == 'table') then
		for k, v in pairs(src) do
			if (type(v) == 'table') then
				CopyTable(v, dest[k])
			end

			dest[k] = v
		end
	end
end

local function CopyProfile()
	local usingGlobal	= AzurahDB.Default[GetDisplayName()]['$AccountWide'].useAccountWide
	local destProfile	= (usingGlobal) and '$AccountWide' or GetUnitName('player')
	local sourceData, destData

	for account, accountData in pairs(AzurahDB.Default) do
		for profile, data in pairs(accountData) do
			if (profile == profileCopyToCopy) then
				sourceData = data -- get source data to copy
			end

			if (profile == destProfile) then
				destData = data -- get destination to copy to
			end
		end
	end

	if (not sourceData or not destData) then -- something went wrong, abort
		CHAT_SYSTEM:AddMessage(strformat('%s: %s', L.Azurah, 'Error copying profile!'))
	else
		CopyTable(sourceData, destData)
		ReloadUI()
	end
end

local function DeleteProfile()
	for account, accountData in pairs(AzurahDB.Default) do
		for profile, data in pairs(accountData) do
			if (profile == profileDeleteToDelete) then -- found unwanted profile
				accountData[profile] = nil
				break
			end
		end
	end

	for i, profile in ipairs(profileDeleteList) do
		if (profile == profileDeleteToDelete) then
			tremove(profileDeleteList, i)
			break
		end
	end

	profileDeleteToDelete = false
	profileDeleteDropRef:UpdateChoices()
	profileDeleteDropRef:UpdateValue()
end

local function PopulateProfileLists()
	local usingGlobal	= AzurahDB.Default[GetDisplayName()]['$AccountWide'].useAccountWide
	local currentPlayer	= GetUnitName('player')
	local versionDB		= Azurah.versionDB

	for account, accountData in pairs(AzurahDB.Default) do
		for profile, data in pairs(accountData) do
			if (data.version == versionDB) then -- only populate current DB version
				if (usingGlobal) then
					if (profile ~= '$AccountWide') then
						tinsert(profileCopyList, profile) -- don't add accountwide to copy selection
						tinsert(profileDeleteList, profile) -- don't add accountwide to delete selection
					end
				else
					if (profile ~= currentPlayer) then
						tinsert(profileCopyList, profile) -- don't add current player to copy selection

						if (profile ~= '$AccountWide') then
							tinsert(profileDeleteList, profile) -- don't add accountwide or current player to delete selection
						end
					end
				end
			end
		end
	end

	tsort(profileCopyList)
	tsort(profileDeleteList)
end


-- ------------------------
-- PANEL CONSTRUCTION
-- ------------------------
local function CreateWidgets(panelID, panelData)
	local panel = tabPanels[panelID]

	for entry, widgetData in ipairs(panelData) do
		local widgetType = widgetData.type
		local widget = LAMCreateControl[widgetType](panel, widgetData)

		if (widget.data.isFontColour) then -- special case for font colour widgets
			widget.thumb:ClearAnchors()
			widget.thumb:SetAnchor(RIGHT, widget.color, RIGHT, 0, 0)

			widget:SetAnchor(TOPLEFT, lastAddedControl[panelID], TOPLEFT, 0, 0) -- overlay widget with previous
			widget:SetWidth(controlPanelWidth - (controlPanelWidth / 3) - 15) -- shrink widget to give appearance of sharing a row
		else
			widget:SetAnchor(TOPLEFT, lastAddedControl[panelID], BOTTOMLEFT, 0, 15)
			lastAddedControl[panelID] = widget
		end

		if (widget.data.isProfileDeleteDrop) then
			profileDeleteDropRef = widget -- need a reference for this dropdown to refresh choices list
		end
	end
end

local function CreateTabPanel(panelID)
	local panel = WM:CreateControl(nil, controlPanel.scroll, CT_CONTROL)
	panel.panel = controlPanel
	panel:SetWidth(controlPanelWidth)
	panel:SetAnchor(TOPLEFT, tabButtonsPanel, BOTTOMLEFT, 0, 6)
	panel:SetResizeToFitDescendents(true)

	tabPanels[panelID] = panel

	local ctrl = LAMCreateControl.header(panel, {
		type = 'header',
		name = L['TabHeader' .. panelID],
	})
	ctrl:SetAnchor(TOPLEFT)

	lastAddedControl[panelID] = ctrl

	CreateWidgets(panelID, tabPanelData[panelID]) -- create the actual setting elements
end


-- ------------------------
-- TAB BUTTON HANDLER
-- ------------------------
local function TabButtonOnClick(self)
	if (not tabPanels[self.panelID]) then
		CreateTabPanel(self.panelID) -- call to create appropriate panel if not created yet
	end

	for x = 1, 8 do
		tabButtons[x].button:SetState(0) -- unset selected state for all buttons
	end

	tabButtons[self.buttonID].button:SetState(1, true) -- set selected state for current button

	for id, panel in pairs(tabPanels) do
		panel:SetHidden(not (id == self.panelID)) -- hide all other tab panels but intended
	end
end


-- -----------------------
-- INITIALIZATION
-- -----------------------
local function CompleteInitialization(panel)
	if (panel ~= controlPanel) then return end -- only proceed if this is our settings panel

	tabButtonsPanel		= _G[settingsGlobalStrBtns] -- setup reference to tab buttons (custom) panel
	controlPanelWidth	= controlPanel:GetWidth() - 60 -- used several times

	local btn

	for x = 1, 8 do
		btn = LAMCreateControl.button(tabButtonsPanel, { -- create our tab buttons
			type = 'button',
			name = L['TabButton' .. x],
			func = TabButtonOnClick,
		})
		btn.button.buttonID	= x -- reference lookup to refer to buttons
		btn.button.panelID	= x -- reference lookup to refer to panels

		btn:SetWidth((controlPanelWidth / 4) - 2)
		btn.button:SetWidth((controlPanelWidth / 4) - 2)
		btn:SetAnchor(TOPLEFT, tabButtonsPanel, TOPLEFT, (controlPanelWidth / 4) * ((x - 1) % 4), (x <= 4) and 0 or 34)

		tabButtons[x] = btn
	end

	tabButtons[1].button:SetState(1, true) -- set selected state for first (General) panel

	CreateTabPanel(1) -- create first (General) panel on settings first load

	PopulateProfileLists() -- populate available profiles for copy and deletion
end

function Azurah:InitializeSettings()
	local panelData = {
		type = 'panel',
		name = self.name,
		displayName = L.Azurah,
		author = 'Kith, Garkin, Phinix, Sounomi',
		version = self.version,
		registerForRefresh = true,
		registerForDefaults = false,
	}

	controlPanel = LAM:RegisterAddonPanel(settingsGlobalStr, panelData)

	local optionsData = {
		[1] = {
			type = 'custom',
			reference = settingsGlobalStrBtns,
		}
	}

	LAM:RegisterOptionControls(settingsGlobalStr, optionsData)

	CM:RegisterCallback('LAM-PanelControlsCreated', CompleteInitialization)
end


-- -----------------------
-- OPTIONS DATA TABLES
-- -----------------------
tabPanelData = {
	-- -----------------------
	-- GENERAL PANEL
	-- -----------------------
	[1] = {
		{
			type = "description",
			text = L.GeneralAnchorDesc,
		},
		{
			type = "button",
			name = L.GeneralAnchorUnlock,
			func = function()
				Azurah.SlashCommand('unlock')

			end,
		},
		{
			type = 'checkbox',
			name = L.General_ModeChange,
			tooltip = L.General_ModeChangeTip,
			getFunc = function()
				return Azurah.db.modeChangeReload
			end,
			setFunc = function(v)
				Azurah.db.modeChangeReload = v
			end,
		},
		-- -----------------------
		-- COMPASS PINS
		-- -----------------------
		{
			type = "header",
			name = L.GeneralCompassPins,
		},
		{
			type = "slider",
			name = L.GeneralPinScale,
			tooltip = L.GeneralPinScaleTip,
			min = 60,
			max = 110,
			getFunc = function()
				return Azurah.db.compassPinScale * 100
			end,
			setFunc = function(arg)
				Azurah.db.compassPinScale = arg / 100
				Azurah:ConfigureCompass()
			end,
		},
		{
			type = "checkbox",
			name = L.GeneralPinLabel,
			tooltip = L.GeneralPinLabelTip,
			getFunc = function()
				return Azurah.db.compassHidePinLabel
			end,
			setFunc = function(arg)
				Azurah.db.compassHidePinLabel = arg
				Azurah:ConfigureCompass()
			end,
		},
		-- -----------------------
		-- THIEVERY
		-- -----------------------
		{
			type = 'header',
			name = L.General_TheftHeader
		},
		{
			type = 'checkbox',
			name = L.General_TheftPrevent,
			tooltip = L.General_TheftPreventTip,
			getFunc = function()
				return Azurah.db.theftPreventAccidental
			end,
			setFunc = function(v)
				Azurah.db.theftPreventAccidental = v
				Azurah:ConfigureThievery()
			end,
		},
		{
			type = 'checkbox',
			name = L.General_TheftSafer,
			tooltip = L.General_TheftSaferTip,
			warning = L.General_TheftSaferWarn,
			getFunc = function()
				return Azurah.db.theftMakeSafer
			end,
			setFunc = function(v)
				Azurah.db.theftMakeSafer = v
				Azurah:ConfigureThievery()
			end,
			disabled = function()
				return not Azurah.db.theftPreventAccidental
			end
		},
	},
	-- -----------------------
	-- ATTRIBUTES PANEL
	-- -----------------------
	[2] = {
		{
			type = "slider",
			name = L.AttributesFadeMin,
			tooltip = L.AttributesFadeMinTip,
			min = 0,
			max = 100,
			step = 5,
			getFunc = function() return Azurah.db.attributes.fadeMinAlpha * 100 end,
			setFunc = function(arg)
					Azurah.db.attributes.fadeMinAlpha = arg / 100
					Azurah:ConfigureAttributeFade()
				end,
		},
		{
			type = "slider",
			name = L.AttributesFadeMax,
			tooltip = L.AttributesFadeMaxTip,
			min = 0,
			max = 100,
			step = 5,
			getFunc = function() return Azurah.db.attributes.fadeMaxAlpha * 100 end,
			setFunc = function(arg)
					Azurah.db.attributes.fadeMaxAlpha = arg / 100
					Azurah:ConfigureAttributeFade()
				end,
		},
		{
			type = "checkbox",
			name = L.AttributesCombatBars,
			tooltip = L.AttributesCombatBarsTip,
			getFunc = function() return Azurah.db.attributes.combatBars end,
			setFunc = function(arg)
				Azurah.db.attributes.combatBars = arg
				Azurah:ConfigureAttributeFade()
			end,
		},
		{
			type = "checkbox",
			name = L.AttributesLockSize,
			tooltip = L.AttributesLockSizeTip,
			getFunc = function() return Azurah.db.attributes.lockSize end,
			setFunc = function(arg)
					Azurah.db.attributes.lockSize = arg
					Azurah:ConfigureAttributeSizeLock()
				end,
			warning = L.AttributesLockSizeWarn,
		},
		-- -----------------------
		-- OVERLAY: HEALTH
		-- -----------------------
		{
			type = "header",
			name = L.AttributesOverlayHealth,
		},
		{
			type = "dropdown",
			name = L.SettingOverlayFormat,
			tooltip = L.AttributesOverlayFormatTip,
			choices = dropOverlay,
			getFunc = function() return dropOverlay[Azurah.db.attributes.healthOverlay] end,
			setFunc = function(arg)
					Azurah.db.attributes.healthOverlay = dropOverlayRef[arg]
					Azurah:ConfigureAttributeOverlays()
				end,
		},
		{
			type = "checkbox",
			name = L.SettingOverlayFancy,
			tooltip = L.SettingOverlayFancyTip,
			getFunc = function() return Azurah.db.attributes.healthOverlayFancy end,
			setFunc = function(arg)
					Azurah.db.attributes.healthOverlayFancy = arg
					Azurah:ConfigureAttributeOverlays()
				end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayFont,
			choices = LMP:List('font'),
			getFunc = function()
				return Azurah.db.attributes.healthFontFace
			end,
			setFunc = function(v)
				Azurah.db.attributes.healthFontFace = v
				Azurah:ConfigureAttributeOverlays()
			end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayStyle,
			choices = dropFontStyle,
			getFunc = function()
				return Azurah.db.attributes.healthFontOutline
			end,
			setFunc = function(v)
				Azurah.db.attributes.healthFontOutline = v
				Azurah:ConfigureAttributeOverlays()
			end,
		},
		{
			type = 'colorpicker',
			getFunc = function()
				return Azurah.db.attributes.healthFontColour.r, Azurah.db.attributes.healthFontColour.g, Azurah.db.attributes.healthFontColour.b, Azurah.db.attributes.healthFontColour.a
			end,
			setFunc = function(r, g, b, a)
				Azurah.db.attributes.healthFontColour.r = r
				Azurah.db.attributes.healthFontColour.g = g
				Azurah.db.attributes.healthFontColour.b = b
				Azurah.db.attributes.healthFontColour.a = a
				Azurah:ConfigureAttributeOverlays()
			end,
			isFontColour = true,
		},
		{
			type = 'slider',
			name = L.SettingOverlaySize,
			min = 8,
			max = 32,
			getFunc = function()
				return Azurah.db.attributes.healthFontSize
			end,
			setFunc = function(v)
				Azurah.db.attributes.healthFontSize = v
				Azurah:ConfigureAttributeOverlays()
			end,
		},
		-- -----------------------
		-- OVERLAY: MAGICKA
		-- -----------------------
		{
			type = "header",
			name = L.AttributesOverlayMagicka,
		},
		{
			type = "dropdown",
			name = L.SettingOverlayFormat,
			tooltip = L.AttributesOverlayFormatTip,
			choices = dropOverlay,
			getFunc = function() return dropOverlay[Azurah.db.attributes.magickaOverlay] end,
			setFunc = function(arg)
					Azurah.db.attributes.magickaOverlay = dropOverlayRef[arg]
					Azurah:ConfigureAttributeOverlays()
				end,
		},
		{
			type = "checkbox",
			name = L.SettingOverlayFancy,
			tooltip = L.SettingOverlayFancyTip,
			getFunc = function() return Azurah.db.attributes.magickaOverlayFancy end,
			setFunc = function(arg)
					Azurah.db.attributes.magickaOverlayFancy = arg
					Azurah:ConfigureAttributeOverlays()
				end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayFont,
			choices = LMP:List('font'),
			getFunc = function()
				return Azurah.db.attributes.magickaFontFace
			end,
			setFunc = function(v)
				Azurah.db.attributes.magickaFontFace = v
				Azurah:ConfigureAttributeOverlays()
			end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayStyle,
			choices = dropFontStyle,
			getFunc = function()
				return Azurah.db.attributes.magickaFontOutline
			end,
			setFunc = function(v)
				Azurah.db.attributes.magickaFontOutline = v
				Azurah:ConfigureAttributeOverlays()
			end,
		},
		{
			type = 'colorpicker',
			getFunc = function()
				return Azurah.db.attributes.magickaFontColour.r, Azurah.db.attributes.magickaFontColour.g, Azurah.db.attributes.magickaFontColour.b, Azurah.db.attributes.magickaFontColour.a
			end,
			setFunc = function(r, g, b, a)
				Azurah.db.attributes.magickaFontColour.r = r
				Azurah.db.attributes.magickaFontColour.g = g
				Azurah.db.attributes.magickaFontColour.b = b
				Azurah.db.attributes.magickaFontColour.a = a
				Azurah:ConfigureAttributeOverlays()
			end,
			isFontColour = true,
		},
		{
			type = 'slider',
			name = L.SettingOverlaySize,
			min = 8,
			max = 32,
			getFunc = function()
				return Azurah.db.attributes.magickaFontSize
			end,
			setFunc = function(v)
				Azurah.db.attributes.magickaFontSize = v
				Azurah:ConfigureAttributeOverlays()
			end,
		},
		-- -----------------------
		-- OVERLAY: STAMINA
		-- -----------------------
		{
			type = "header",
			name = L.AttributesOverlayStamina,
		},
		{
			type = "dropdown",
			name = L.SettingOverlayFormat,
			tooltip = L.AttributesOverlayFormatTip,
			choices = dropOverlay,
			getFunc = function() return dropOverlay[Azurah.db.attributes.staminaOverlay] end,
			setFunc = function(arg)
					Azurah.db.attributes.staminaOverlay = dropOverlayRef[arg]
					Azurah:ConfigureAttributeOverlays()
				end,
		},
		{
			type = "checkbox",
			name = L.SettingOverlayFancy,
			tooltip = L.SettingOverlayFancyTip,
			getFunc = function() return Azurah.db.attributes.staminaOverlayFancy end,
			setFunc = function(arg)
					Azurah.db.attributes.staminaOverlayFancy = arg
					Azurah:ConfigureAttributeOverlays()
				end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayFont,
			choices = LMP:List('font'),
			getFunc = function()
				return Azurah.db.attributes.staminaFontFace
			end,
			setFunc = function(v)
				Azurah.db.attributes.staminaFontFace = v
				Azurah:ConfigureAttributeOverlays()
			end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayStyle,
			choices = dropFontStyle,
			getFunc = function()
				return Azurah.db.attributes.staminaFontOutline
			end,
			setFunc = function(v)
				Azurah.db.attributes.staminaFontOutline = v
				Azurah:ConfigureAttributeOverlays()
			end,
		},
		{
			type = 'colorpicker',
			getFunc = function()
				return Azurah.db.attributes.staminaFontColour.r, Azurah.db.attributes.staminaFontColour.g, Azurah.db.attributes.staminaFontColour.b, Azurah.db.attributes.staminaFontColour.a
			end,
			setFunc = function(r, g, b, a)
				Azurah.db.attributes.staminaFontColour.r = r
				Azurah.db.attributes.staminaFontColour.g = g
				Azurah.db.attributes.staminaFontColour.b = b
				Azurah.db.attributes.staminaFontColour.a = a
				Azurah:ConfigureAttributeOverlays()
			end,
			isFontColour = true,
		},
		{
			type = 'slider',
			name = L.SettingOverlaySize,
			min = 8,
			max = 32,
			getFunc = function()
				return Azurah.db.attributes.staminaFontSize
			end,
			setFunc = function(v)
				Azurah.db.attributes.staminaFontSize = v
				Azurah:ConfigureAttributeOverlays()
			end,
		},
	},
	-- -----------------------
	-- TARGET PANEL
	-- -----------------------
	[3] = {
		{
			type = "checkbox",
			name = L.TargetLockSize,
			tooltip = L.TargetLockSizeTip,
			getFunc = function() return Azurah.db.target.lockSize end,
			setFunc = function(arg)
					Azurah.db.target.lockSize = arg
					Azurah:ConfigureTargetSizeLock()
				end
		},
		{
			type = "checkbox",
			name = L.TargetRPName,
			tooltip = L.TargetRPNameTip,
			getFunc = function() return Azurah.db.target.RPName end,
			setFunc = function(arg)
					Azurah.db.target.RPName = arg
				end,
			warning = L.TargetRPTitleWarn,
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = L.TargetRPTitle,
			tooltip = L.TargetRPTitleTip,
			getFunc = function() return Azurah.db.target.RPTitle end,
			setFunc = function(arg)
					Azurah.db.target.RPTitle = arg
				end,
			warning = L.TargetRPTitleWarn,
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = L.TargetRPInteract,
			tooltip = L.TargetRPInteractTip,
			getFunc = function() return Azurah.db.target.RPInteract end,
			setFunc = function(arg)
					Azurah.db.target.RPInteract = arg
				end,
			warning = L.TargetRPTitleWarn,
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = L.TargetRPIcon,
			tooltip = L.TargetRPIconTip,
			getFunc = function() return Azurah.db.target.RPIcon end,
			setFunc = function(arg)
					Azurah.db.target.RPIcon = arg
				end,
			warning = L.TargetRPTitleWarn,
			requiresReload = true,
		},
		{
			type = "dropdown",
			name = L.TargetColourByBar,
			tooltip = L.TargetColourByBarTip,
			choices = dropColourBy,
			getFunc = function() return dropColourBy[Azurah.db.target.colourByBar] end,
			setFunc = function(arg)
					Azurah.db.target.colourByBar = dropColourByRef[arg]
					Azurah:ConfigureTargetColouring()
				end,
		},
		{
			type = "dropdown",
			name = L.TargetColourByName,
			tooltip = L.TargetColourByNameTip,
			choices = dropColourBy,
			getFunc = function() return dropColourBy[Azurah.db.target.colourByName] end,
			setFunc = function(arg)
					Azurah.db.target.colourByName = dropColourByRef[arg]
					Azurah:ConfigureTargetColouring()
				end,
		},
		{
			type = "checkbox",
			name = L.TargetColourByLevel,
			tooltip = L.TargetColourByLevelTip,
			getFunc = function() return Azurah.db.target.colourByLevel end,
			setFunc = function(arg)
					Azurah.db.target.colourByLevel = arg
					Azurah:ConfigureTargetColouring()
				end,
		},
		{
			type = "checkbox",
			name = L.TargetIconClassShow,
			tooltip = L.TargetIconClassShowTip,
			getFunc = function() return Azurah.db.target.classShow end,
			setFunc = function(arg)
					Azurah.db.target.classShow = arg
					Azurah:ConfigureTargetIcons()
				end,
		},
		{
			type = "checkbox",
			name = L.TargetIconClassByName,
			tooltip = L.TargetIconClassByNameTip,
			getFunc = function() return Azurah.db.target.classByName end,
			setFunc = function(arg)
					Azurah.db.target.classByName = arg
					Azurah:ConfigureTargetIcons()
				end,
		},
		{
			type = "checkbox",
			name = L.TargetIconAllianceShow,
			tooltip = L.TargetIconAllianceShowTip,
			getFunc = function() return Azurah.db.target.allianceShow end,
			setFunc = function(arg)
					Azurah.db.target.allianceShow = arg
					Azurah:ConfigureTargetIcons()
				end,
		},
		{
			type = "checkbox",
			name = L.TargetIconAllianceByName,
			tooltip = L.TargetIconAllianceByNameTip,
			getFunc = function() return Azurah.db.target.allianceByName end,
			setFunc = function(arg)
					Azurah.db.target.allianceByName = arg
					Azurah:ConfigureTargetIcons()
				end,
		},
		{
			type = "dropdown",
			name = L.SettingOverlayFormat,
			tooltip = L.TargetOverlayFormatTip,
			choices = dropOverlay,
			getFunc = function() return dropOverlay[Azurah.db.target.overlay] end,
			setFunc = function(arg)
					Azurah.db.target.overlay = dropOverlayRef[arg]
					Azurah:ConfigureTargetOverlay()
				end,
		},
		{
			type = "checkbox",
			name = L.SettingOverlayFancy,
			tooltip = L.SettingOverlayFancyTip,
			getFunc = function() return Azurah.db.target.overlayFancy end,
			setFunc = function(arg)
					Azurah.db.target.overlayFancy = arg
					Azurah:ConfigureTargetOverlay()
				end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayFont,
			choices = LMP:List('font'),
			getFunc = function()
				return Azurah.db.target.fontFace
			end,
			setFunc = function(v)
				Azurah.db.target.fontFace = v
				Azurah:ConfigureTargetOverlay()
			end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayStyle,
			choices = dropFontStyle,
			getFunc = function()
				return Azurah.db.target.fontOutline
			end,
			setFunc = function(v)
				Azurah.db.target.fontOutline = v
				Azurah:ConfigureTargetOverlay()
			end,
		},
		{
			type = 'colorpicker',
			getFunc = function()
				return Azurah.db.target.fontColour.r, Azurah.db.target.fontColour.g, Azurah.db.target.fontColour.b, Azurah.db.target.fontColour.a
			end,
			setFunc = function(r, g, b, a)
				Azurah.db.target.fontColour.r = r
				Azurah.db.target.fontColour.g = g
				Azurah.db.target.fontColour.b = b
				Azurah.db.target.fontColour.a = a
				Azurah:ConfigureTargetOverlay()
			end,
			isFontColour = true,
		},
		{
			type = 'slider',
			name = L.SettingOverlaySize,
			min = 8,
			max = 32,
			getFunc = function()
				return Azurah.db.target.fontSize
			end,
			setFunc = function(v)
				Azurah.db.target.fontSize = v
				Azurah:ConfigureTargetOverlay()
			end,
		},
		-- -----------------------
		-- BOSSBAR SETTINGS
		-- -----------------------
		{
			type = "header",
			name = L.BossbarHeader,
		},
		{
			type = "dropdown",
			name = L.SettingOverlayFormat,
			tooltip = L.BossbarOverlayFormatTip,
			choices = dropOverlay,
			getFunc = function() return dropOverlay[Azurah.db.bossbar.overlay] end,
			setFunc = function(arg)
					Azurah.db.bossbar.overlay = dropOverlayRef[arg]
					Azurah:ConfigureBossbarOverlay()
				end,
		},
		{
			type = "checkbox",
			name = L.SettingOverlayFancy,
			tooltip = L.SettingOverlayFancyTip,
			getFunc = function() return Azurah.db.bossbar.overlayFancy end,
			setFunc = function(arg)
					Azurah.db.bossbar.overlayFancy = arg
					Azurah:ConfigureBossbarOverlay()
				end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayFont,
			choices = LMP:List('font'),
			getFunc = function()
				return Azurah.db.bossbar.fontFace
			end,
			setFunc = function(v)
				Azurah.db.bossbar.fontFace = v
				Azurah:ConfigureBossbarOverlay()
			end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayStyle,
			choices = dropFontStyle,
			getFunc = function()
				return Azurah.db.bossbar.fontOutline
			end,
			setFunc = function(v)
				Azurah.db.bossbar.fontOutline = v
				Azurah:ConfigureBossbarOverlay()
			end,
		},
		{
			type = 'colorpicker',
			getFunc = function()
				return Azurah.db.bossbar.fontColour.r, Azurah.db.bossbar.fontColour.g, Azurah.db.bossbar.fontColour.b, Azurah.db.bossbar.fontColour.a
			end,
			setFunc = function(r, g, b, a)
				Azurah.db.bossbar.fontColour.r = r
				Azurah.db.bossbar.fontColour.g = g
				Azurah.db.bossbar.fontColour.b = b
				Azurah.db.bossbar.fontColour.a = a
				Azurah:ConfigureBossbarOverlay()
			end,
			isFontColour = true,
		},
		{
			type = 'slider',
			name = L.SettingOverlaySize,
			min = 8,
			max = 32,
			getFunc = function()
				return Azurah.db.bossbar.fontSize
			end,
			setFunc = function(v)
				Azurah.db.bossbar.fontSize = v
				Azurah:ConfigureBossbarOverlay()
			end,
		},
	},
	-- -----------------------
	-- ACTION BAR PANEL
	-- -----------------------
	[4] = {
		{
			type = "checkbox",
			name = L.ActionBarHideBindBG,
			tooltip = L.ActionBarHideBindBGTip,
			getFunc = function() return Azurah.db.actionBar.hideBindBG end,
			setFunc = function(arg)
					Azurah.db.actionBar.hideBindBG = arg
					Azurah:ConfigureActionBarElements()
				end,
		},
		{
			type = "checkbox",
			name = L.ActionBarHideBindText,
			tooltip = L.ActionBarHideBindTextTip,
			getFunc = function() return Azurah.db.actionBar.hideBindText end,
			setFunc = function(arg)
					Azurah.db.actionBar.hideBindText = arg
					Azurah:ConfigureActionBarElements()
				end,
		},
		{
			type = "checkbox",
			name = L.ActionBarHideWeaponSwap,
			tooltip = L.ActionBarHideWeaponSwapTip,
			getFunc = function() return Azurah.db.actionBar.hideWeaponSwap end,
			setFunc = function(arg)
					Azurah.db.actionBar.hideWeaponSwap = arg
					Azurah:ConfigureActionBarElements()
				end,
		},
		-- ----------------------------
		-- OVERLAY: ULTIMATE (VALUE)
		-- ----------------------------
		{
			type = "header",
			name = L.ActionBarOverlayUltValue,
		},
		{
			type = "checkbox",
			name = L.ActionBarOverlayShow,
			tooltip = L.ActionBarOverlayUltValueShowTip,
			getFunc = function() return Azurah.db.actionBar.ultValueShow end,
			setFunc = function(arg)
					Azurah.db.actionBar.ultValueShow = arg
					Azurah:ConfigureUltimateOverlays()
				end,
		},
		{
			type = "checkbox",
			name = L.ActionBarOverlayUltValueShowCost,
			tooltip = L.ActionBarOverlayUltValueShowCostTip,
			getFunc = function() return Azurah.db.actionBar.ultValueShowCost end,
			setFunc = function(arg)
					Azurah.db.actionBar.ultValueShowCost = arg
					Azurah:ConfigureUltimateOverlays()
				end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayFont,
			choices = LMP:List('font'),
			getFunc = function()
				return Azurah.db.actionBar.ultValueFontFace
			end,
			setFunc = function(v)
				Azurah.db.actionBar.ultValueFontFace = v
				Azurah:ConfigureUltimateOverlays()
			end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayStyle,
			choices = dropFontStyle,
			getFunc = function()
				return Azurah.db.actionBar.ultValueFontOutline
			end,
			setFunc = function(v)
				Azurah.db.actionBar.ultValueFontOutline = v
				Azurah:ConfigureUltimateOverlays()
			end,
		},
		{
			type = 'colorpicker',
			getFunc = function()
				return Azurah.db.actionBar.ultValueFontColour.r, Azurah.db.actionBar.ultValueFontColour.g, Azurah.db.actionBar.ultValueFontColour.b, Azurah.db.actionBar.ultValueFontColour.a
			end,
			setFunc = function(r, g, b, a)
				Azurah.db.actionBar.ultValueFontColour.r = r
				Azurah.db.actionBar.ultValueFontColour.g = g
				Azurah.db.actionBar.ultValueFontColour.b = b
				Azurah.db.actionBar.ultValueFontColour.a = a
				Azurah:ConfigureUltimateOverlays()
			end,
			isFontColour = true,
		},
		{
			type = 'slider',
			name = L.SettingOverlaySize,
			min = 8,
			max = 32,
			getFunc = function()
				return Azurah.db.actionBar.ultValueFontSize
			end,
			setFunc = function(v)
				Azurah.db.actionBar.ultValueFontSize = v
				Azurah:ConfigureUltimateOverlays()
			end,
		},
		-- ----------------------------
		-- OVERLAY: ULTIMATE (PERCENT)
		-- ----------------------------
		{
			type = "header",
			name = L.ActionBarOverlayUltPercent,
		},
		{
			type = "checkbox",
			name = L.ActionBarOverlayShow,
			tooltip = L.ActionBarOverlayUltPercentShowTip,
			getFunc = function() return Azurah.db.actionBar.ultPercentShow end,
			setFunc = function(arg)
					Azurah.db.actionBar.ultPercentShow = arg
					Azurah:ConfigureUltimateOverlays()
				end,
		},
		{
			type = "checkbox",
			name = L.ActionBarOverlayUltPercentRelative,
			tooltip = L.ActionBarOverlayUltPercentRelativeTip,
			getFunc = function() return Azurah.db.actionBar.ultPercentRelative end,
			setFunc = function(arg)
					Azurah.db.actionBar.ultPercentRelative = arg
					Azurah:ConfigureUltimateOverlays()
				end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayFont,
			choices = LMP:List('font'),
			getFunc = function()
				return Azurah.db.actionBar.ultPercentFontFace
			end,
			setFunc = function(v)
				Azurah.db.actionBar.ultPercentFontFace = v
				Azurah:ConfigureUltimateOverlays()
			end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayStyle,
			choices = dropFontStyle,
			getFunc = function()
				return Azurah.db.actionBar.ultPercentFontOutline
			end,
			setFunc = function(v)
				Azurah.db.actionBar.ultPercentFontOutline = v
				Azurah:ConfigureUltimateOverlays()
			end,
		},
		{
			type = 'colorpicker',
			getFunc = function()
				return Azurah.db.actionBar.ultPercentFontColour.r, Azurah.db.actionBar.ultPercentFontColour.g, Azurah.db.actionBar.ultPercentFontColour.b, Azurah.db.actionBar.ultPercentFontColour.a
			end,
			setFunc = function(r, g, b, a)
				Azurah.db.actionBar.ultPercentFontColour.r = r
				Azurah.db.actionBar.ultPercentFontColour.g = g
				Azurah.db.actionBar.ultPercentFontColour.b = b
				Azurah.db.actionBar.ultPercentFontColour.a = a
				Azurah:ConfigureUltimateOverlays()
			end,
			isFontColour = true,
		},
		{
			type = 'slider',
			name = L.SettingOverlaySize,
			min = 8,
			max = 32,
			getFunc = function()
				return Azurah.db.actionBar.ultPercentFontSize
			end,
			setFunc = function(v)
				Azurah.db.actionBar.ultPercentFontSize = v
				Azurah:ConfigureUltimateOverlays()
			end,
		},
	},
	-- ----------------------------
	-- EXPERIENCE BAR PANEL
	-- ----------------------------
	[5] = {
		{
			type = "dropdown",
			name = L.ExperienceDisplayStyle,
			tooltip = L.ExperienceDisplayStyleTip,
			choices = dropExpBarStyle,
			getFunc = function() return dropExpBarStyle[Azurah.db.experienceBar.displayStyle] end,
			setFunc = function(arg)
					Azurah.db.experienceBar.displayStyle = dropExpBarStyleRef[arg]
					Azurah:ConfigureExperienceBarDisplay()
				end,
		},
		{
			type = "dropdown",
			name = L.SettingOverlayFormat,
			tooltip = L.ExperienceOverlayFormatTip,
			choices = dropOverlay,
			getFunc = function() return dropOverlay[Azurah.db.experienceBar.overlay] end,
			setFunc = function(arg)
					Azurah.db.experienceBar.overlay = dropOverlayRef[arg]
					Azurah:ConfigureExperienceBarOverlay()
				end,
		},
		{
			type = "checkbox",
			name = L.SettingOverlayFancy,
			tooltip = L.SettingOverlayFancyTip,
			getFunc = function() return Azurah.db.experienceBar.overlayFancy end,
			setFunc = function(arg)
					Azurah.db.experienceBar.overlayFancy = arg
					Azurah:ConfigureExperienceBarOverlay()
				end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayFont,
			choices = LMP:List('font'),
			getFunc = function()
				return Azurah.db.experienceBar.fontFace
			end,
			setFunc = function(v)
				Azurah.db.experienceBar.fontFace = v
				Azurah:ConfigureExperienceBarOverlay()
			end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayStyle,
			choices = dropFontStyle,
			getFunc = function()
				return Azurah.db.experienceBar.fontOutline
			end,
			setFunc = function(v)
				Azurah.db.experienceBar.fontOutline = v
				Azurah:ConfigureExperienceBarOverlay()
			end,
		},
		{
			type = 'colorpicker',
			getFunc = function()
				return Azurah.db.experienceBar.fontColour.r, Azurah.db.experienceBar.fontColour.g, Azurah.db.experienceBar.fontColour.b, Azurah.db.experienceBar.fontColour.a
			end,
			setFunc = function(r, g, b, a)
				Azurah.db.experienceBar.fontColour.r = r
				Azurah.db.experienceBar.fontColour.g = g
				Azurah.db.experienceBar.fontColour.b = b
				Azurah.db.experienceBar.fontColour.a = a
				Azurah:ConfigureExperienceBarOverlay()
			end,
			isFontColour = true,
		},
		{
			type = 'slider',
			name = L.SettingOverlaySize,
			min = 8,
			max = 32,
			getFunc = function()
				return Azurah.db.experienceBar.fontSize
			end,
			setFunc = function(v)
				Azurah.db.experienceBar.fontSize = v
				Azurah:ConfigureExperienceBarOverlay()
			end,
		},
	},

	-- ----------------------------
	-- BAG WATCHER PANEL
	-- ----------------------------
	[6] = {
		{
			type = 'description',
			text = L.Bag_Desc,
		},
		{
			type = 'checkbox',
			name = L.Bag_Enable,
			getFunc = function()
				return Azurah.db.bagWatcher.enabled
			end,
			setFunc = function(v)
				Azurah.db.bagWatcher.enabled = v
				Azurah:ConfigureBagWatcher()
			end,
		},
		{
			type = 'checkbox',
			name = L.Bag_ReverseAlignment,
			tooltip = L.Bag_ReverseAlignmentTip,
			getFunc = function()
				return Azurah.db.bagWatcher.reverseAlignment
			end,
			setFunc = function(v)
				Azurah.db.bagWatcher.reverseAlignment = v
				Azurah:ConfigureBagWatcher()
			end
		},
		{
			type = 'checkbox',
			name = L.Bag_LowSpaceLock,
			tooltip = L.Bag_LowSpaceLockTip,
			getFunc = function()
				return Azurah.db.bagWatcher.lowSpaceLock
			end,
			setFunc = function(v)
				Azurah.db.bagWatcher.lowSpaceLock = v
			end
		},
		{
			type = 'slider',
			name = L.Bag_LowSpaceTrigger,
			tooltip = L.Bag_LowSpaceTriggerTip,
			min = 1,
			max = GetBagSize(BAG_BACKPACK),
			getFunc = function()
				return Azurah.db.bagWatcher.lowSpaceTrigger
			end,
			setFunc = function(v)
				Azurah.db.bagWatcher.lowSpaceTrigger = v
			end
		},
		{
			type = "dropdown",
			name = L.SettingOverlayFormat,
			tooltip = L.ExperienceOverlayFormatTip,
			choices = dropOverlay,
			getFunc = function() return dropOverlay[Azurah.db.bagWatcher.overlay] end,
			setFunc = function(arg)
					Azurah.db.bagWatcher.overlay = dropOverlayRef[arg]
					Azurah:ConfigureBagWatcher()
				end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayFont,
			choices = LMP:List('font'),
			getFunc = function()
				return Azurah.db.bagWatcher.fontFace
			end,
			setFunc = function(v)
				Azurah.db.bagWatcher.fontFace = v
				Azurah:ConfigureBagWatcher()
			end,
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayStyle,
			choices = dropFontStyle,
			getFunc = function()
				return Azurah.db.bagWatcher.fontOutline
			end,
			setFunc = function(v)
				Azurah.db.bagWatcher.fontOutline = v
				Azurah:ConfigureBagWatcher()
			end,
		},
		{
			type = 'colorpicker',
			getFunc = function()
				return Azurah.db.bagWatcher.fontColour.r, Azurah.db.bagWatcher.fontColour.g, Azurah.db.bagWatcher.fontColour.b, Azurah.db.bagWatcher.fontColour.a
			end,
			setFunc = function(r, g, b, a)
				Azurah.db.bagWatcher.fontColour.r = r
				Azurah.db.bagWatcher.fontColour.g = g
				Azurah.db.bagWatcher.fontColour.b = b
				Azurah.db.bagWatcher.fontColour.a = a
				Azurah:ConfigureBagWatcher()
			end,
			isFontColour = true,
		},
		{
			type = 'slider',
			name = L.SettingOverlaySize,
			min = 8,
			max = 32,
			getFunc = function()
				return Azurah.db.bagWatcher.fontSize
			end,
			setFunc = function(v)
				Azurah.db.bagWatcher.fontSize = v
				Azurah:ConfigureBagWatcher()
			end,
		},
	},
	-- ----------------------------
	-- WEREWOLF PANEL
	-- ----------------------------
	[7] = {
		-- -----------------------
		-- WEREWOLF
		-- -----------------------
		{
			type = 'description',
			text = L.Werewolf_Desc
		},
		{
			type = 'checkbox',
			name = L.Werewolf_Enable,
			getFunc = function()
				return Azurah.db.werewolf.enabled
			end,
			setFunc = function(v)
				Azurah.db.werewolf.enabled = v
				Azurah:ConfigureWerewolf()
			end,
		},
		{
			type = 'checkbox',
			name = L.Werewolf_Flash,
			tooltip = L.Werewolf_FlashTip,
			getFunc = function()
				return Azurah.db.werewolf.flashOnExtend
			end,
			setFunc = function(v)
				Azurah.db.werewolf.flashOnExtend = v
				Azurah:ConfigureWerewolf()
			end,
			disabled = function()
				return not Azurah.db.werewolf.enabled
			end
		},
		{
			type = 'checkbox',
			name = L.Werewolf_IconOnRight,
			tooltip = L.Werewolf_IconOnRightTip,
			getFunc = function()
				return Azurah.db.werewolf.iconOnRight
			end,
			setFunc = function(v)
				Azurah.db.werewolf.iconOnRight = v
				Azurah:ConfigureWerewolf()
			end,
			disabled = function()
				return not Azurah.db.werewolf.enabled
			end
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayFont,
			choices = LMP:List('font'),
			getFunc = function()
				return Azurah.db.werewolf.fontFace
			end,
			setFunc = function(v)
				Azurah.db.werewolf.fontFace = v
				Azurah:ConfigureWerewolf()
			end,
			disabled = function()
				return not Azurah.db.werewolf.enabled
			end
		},
		{
			type = 'dropdown',
			name = L.SettingOverlayStyle,
			choices = dropFontStyle,
			getFunc = function()
				return Azurah.db.werewolf.fontOutline
			end,
			setFunc = function(v)
				Azurah.db.werewolf.fontOutline = v
				Azurah:ConfigureWerewolf()
			end,
			disabled = function()
				return not Azurah.db.werewolf.enabled
			end
		},
		{
			type = 'colorpicker',
			getFunc = function()
				return Azurah.db.werewolf.fontColour.r, Azurah.db.werewolf.fontColour.g, Azurah.db.werewolf.fontColour.b, Azurah.db.werewolf.fontColour.a
			end,
			setFunc = function(r, g, b, a)
				Azurah.db.werewolf.fontColour.r = r
				Azurah.db.werewolf.fontColour.g = g
				Azurah.db.werewolf.fontColour.b = b
				Azurah.db.werewolf.fontColour.a = a
				Azurah:ConfigureWerewolf()
			end,
			disabled = function()
				return not Azurah.db.werewolf.enabled
			end,
			isFontColour = true,
		},
		{
			type = 'slider',
			name = L.SettingOverlaySize,
			min = 8,
			max = 32,
			getFunc = function()
				return Azurah.db.werewolf.fontSize
			end,
			setFunc = function(v)
				Azurah.db.werewolf.fontSize = v
				Azurah:ConfigureWerewolf()
			end,
			disabled = function()
				return not Azurah.db.werewolf.enabled
			end
		},
	},
	-- ----------------------------
	-- PROFILES PANEL
	-- ----------------------------
	[8] = {
		{
			type = 'description',
			text = L.Profile_Desc
		},
		{
			type = 'checkbox',
			name = L.Profile_UseGlobal,
			warning = L.Profile_UseGlobalWarn,
			getFunc = function()
				return AzurahDB.Default[GetDisplayName()]['$AccountWide'].useAccountWide
			end,
			setFunc = function(v)
				AzurahDB.Default[GetDisplayName()]['$AccountWide'].useAccountWide = v
				ReloadUI()
			end,
			disabled = function()
				return not profileGuard
			end
		},
		{
			type = 'dropdown',
			name = L.Profile_Copy,
			tooltip = L.Profile_CopyTip,
			choices = profileCopyList,
			getFunc = function()
				if (#profileCopyList >= 1) then -- there are entries, set first as default
					profileCopyToCopy = profileCopyList[1]
					return profileCopyList[1]
				end
			end,
			setFunc = function(v)
				profileCopyToCopy = v
			end,
			disabled = function()
				return not profileGuard
			end
		},
		{
			type = 'button',
			name = L.Profile_CopyButton,
			warning = L.Profile_CopyButtonWarn,
			func = function(btn)
				CopyProfile()
			end,
			disabled = function()
				return not profileGuard
			end
		},
		{
			type = 'dropdown',
			name = L.Profile_Delete,
			tooltip = L.Profile_DeleteTip,
			choices = profileDeleteList,
			getFunc = function()
				if (#profileDeleteList >= 1) then
					if (not profileDeleteToDelete) then -- nothing selected yet, return first
						profileDeleteToDelete = profileDeleteList[1]
						return profileDeleteList[1]
					else
						return profileDeleteToDelete
					end
				end
			end,
			setFunc = function(v)
				profileDeleteToDelete = v
			end,
			disabled = function()
				return not profileGuard
			end,
			isProfileDeleteDrop = true
		},
		{
			type = 'button',
			name = L.Profile_DeleteButton,
			func = function(btn)
				DeleteProfile()
			end,
			disabled = function()
				return not profileGuard
			end
		},
		{
			type = 'description'
		},
		{
			type = 'header'
		},
		{
			type = 'checkbox',
			name = L.Profile_Guard,
			getFunc = function()
				return profileGuard
			end,
			setFunc = function(v)
				profileGuard = v
			end,
		},
	},
}
