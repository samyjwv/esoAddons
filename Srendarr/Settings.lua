local Srendarr		= _G['Srendarr'] -- grab addon table from global
local L				= Srendarr:GetLocale()
local LAM			= LibStub('LibAddonMenu-2.0')
local LMP			= LibStub('LibMediaProvider-1.0')

-- CONSTS --
local AURA_STYLE_FULL		= Srendarr.AURA_STYLE_FULL
local AURA_STYLE_ICON		= Srendarr.AURA_STYLE_ICON
local AURA_STYLE_MINI		= Srendarr.AURA_STYLE_MINI

local AURA_GROW_UP			= Srendarr.AURA_GROW_UP
local AURA_GROW_DOWN		= Srendarr.AURA_GROW_DOWN
local AURA_GROW_LEFT		= Srendarr.AURA_GROW_LEFT
local AURA_GROW_RIGHT		= Srendarr.AURA_GROW_RIGHT
local AURA_GROW_CENTERLEFT	= Srendarr.AURA_GROW_CENTERLEFT
local AURA_GROW_CENTERRIGHT	= Srendarr.AURA_GROW_CENTERRIGHT

local AURA_TYPE_TIMED		= Srendarr.AURA_TYPE_TIMED
local AURA_TYPE_TOGGLED		= Srendarr.AURA_TYPE_TOGGLED
local AURA_TYPE_PASSIVE		= Srendarr.AURA_TYPE_PASSIVE

local AURA_SORT_NAMEASC		= Srendarr.AURA_SORT_NAMEASC
local AURA_SORT_TIMEASC		= Srendarr.AURA_SORT_TIMEASC
local AURA_SORT_CASTASC		= Srendarr.AURA_SORT_CASTASC
local AURA_SORT_NAMEDESC	= Srendarr.AURA_SORT_NAMEDESC
local AURA_SORT_TIMEDESC	= Srendarr.AURA_SORT_TIMEDESC
local AURA_SORT_CASTDESC	= Srendarr.AURA_SORT_CASTDESC

local AURA_TIMERLOC_HIDDEN	= Srendarr.AURA_TIMERLOC_HIDDEN
local AURA_TIMERLOC_OVER	= Srendarr.AURA_TIMERLOC_OVER
local AURA_TIMERLOC_ABOVE	= Srendarr.AURA_TIMERLOC_ABOVE
local AURA_TIMERLOC_BELOW	= Srendarr.AURA_TIMERLOC_BELOW

local GROUP_PLAYER_SHORT	= Srendarr.GROUP_PLAYER_SHORT
local GROUP_PLAYER_LONG		= Srendarr.GROUP_PLAYER_LONG
local GROUP_PLAYER_TOGGLED	= Srendarr.GROUP_PLAYER_TOGGLED
local GROUP_PLAYER_PASSIVE	= Srendarr.GROUP_PLAYER_PASSIVE
local GROUP_PLAYER_DEBUFF	= Srendarr.GROUP_PLAYER_DEBUFF
local GROUP_PLAYER_GROUND	= Srendarr.GROUP_PLAYER_GROUND
local GROUP_PLAYER_MAJOR	= Srendarr.GROUP_PLAYER_MAJOR
local GROUP_PLAYER_MINOR	= Srendarr.GROUP_PLAYER_MINOR
local GROUP_PLAYER_ENCHANT	= Srendarr.GROUP_PLAYER_ENCHANT
local GROUP_TARGET_BUFF		= Srendarr.GROUP_TARGET_BUFF
local GROUP_TARGET_DEBUFF	= Srendarr.GROUP_TARGET_DEBUFF
local GROUP_PROMINENT		= Srendarr.GROUP_PROMINENT
local GROUP_PROMINENT2		= Srendarr.GROUP_PROMINENT2

local STR_PROMBYID			= Srendarr.STR_PROMBYID
local STR_PROMBYID2			= Srendarr.STR_PROMBYID2
local STR_BLOCKBYID			= Srendarr.STR_BLOCKBYID

-- UPVALUES --
local WM					= GetWindowManager()
local CM					= CALLBACK_MANAGER
local tinsert	 			= table.insert
local tremove				= table.remove
local tsort		 			= table.sort
local strformat				= string.format
local GetAbilityName		= GetAbilityName

-- DROPDOWN CHOICES --
local dropProminentAuras	= {}
local dropProminentAuras2	= {}

local dropBlacklistAuras	= {}

local dropGroup				= {L.DropGroup_1, L.DropGroup_2, L.DropGroup_3, L.DropGroup_4, L.DropGroup_5, L.DropGroup_6, L.DropGroup_7, L.DropGroup_8, L.DropGroup_None}
local dropGroupRef			= {[L.DropGroup_1] = 1, [L.DropGroup_2] = 2, [L.DropGroup_3] = 3, [L.DropGroup_4] = 4, [L.DropGroup_5] = 5, [L.DropGroup_6] = 6, [L.DropGroup_7] = 7, [L.DropGroup_8] = 8, [L.DropGroup_None] = 0}

local dropStyle				= {L.DropStyle_Full, L.DropStyle_Icon, L.DropStyle_Mini}
local dropStyleRef			= {[L.DropStyle_Full] = AURA_STYLE_FULL, [L.DropStyle_Icon] = AURA_STYLE_ICON, [L.DropStyle_Mini] = AURA_STYLE_MINI}

local dropGrowthFullMini	= {L.DropGrowth_Up, L.DropGrowth_Down}
local dropGrowthIcon		= {L.DropGrowth_Up, L.DropGrowth_Down, L.DropGrowth_Left, L.DropGrowth_Right, L.DropGrowth_CenterLeft, L.DropGrowth_CenterRight}
local dropGrowthRef			= {[L.DropGrowth_Up] = AURA_GROW_UP, [L.DropGrowth_Down] = AURA_GROW_DOWN, [L.DropGrowth_Left] = AURA_GROW_LEFT, [L.DropGrowth_Right] = AURA_GROW_RIGHT, [L.DropGrowth_CenterLeft] = AURA_GROW_CENTERLEFT, [L.DropGrowth_CenterRight] = AURA_GROW_CENTERRIGHT}

local dropSort				= {L.DropSort_NameAsc, L.DropSort_TimeAsc, L.DropSort_CastAsc, L.DropSort_NameDesc, L.DropSort_TimeDesc, L.DropSort_CastDesc}
local dropSortRef			= {[L.DropSort_NameAsc] = AURA_SORT_NAMEASC, [L.DropSort_TimeAsc] = AURA_SORT_TIMEASC, [L.DropSort_CastAsc] = AURA_SORT_CASTASC, [L.DropSort_NameDesc] = AURA_SORT_NAMEDESC, [L.DropSort_TimeDesc] = AURA_SORT_TIMEDESC, [L.DropSort_CastDesc] = AURA_SORT_CASTDESC}

local dropTimerFull			= {L.DropTimer_Hidden, L.DropTimer_Over}
local dropTimerIcon			= {L.DropTimer_Hidden, L.DropTimer_Over, L.DropTimer_Above, L.DropTimer_Below}
local dropTimerRef			= {[L.DropTimer_Hidden] = AURA_TIMERLOC_HIDDEN, [L.DropTimer_Over] = AURA_TIMERLOC_OVER, [L.DropTimer_Above] = AURA_TIMERLOC_ABOVE, [L.DropTimer_Below] = AURA_TIMERLOC_BELOW}

local dropFontStyle			= {'none', 'outline', 'thin-outline', 'thick-outline', 'shadow', 'soft-shadow-thin', 'soft-shadow-thick'}

local tabButtons			= {}
local tabPanels				= {}
local tabDisplayWidgetRef	= {}	-- reference to widgets of the DisplayFrame settings for manipulation
local lastAddedControl		= {}
local settingsGlobalStr		= strformat('%s_%s', Srendarr.name, 'Settings')
local settingsGlobalStrBtns	= strformat('%s_%s', settingsGlobalStr, 'TabButtons')
local currentDisplayFrame	= 1		-- set that the display frame settings refer to the given display frame ID
local controlPanel, controlPanelWidth, tabButtonsPanel, displayDB, tabPanelData
local prominentAurasWidgetRef, prominentAurasSelectedAura
local prominentAurasWidgetRef2, prominentAurasSelectedAura2
local blacklistAurasWidgetRef, blacklistAurasSelectedAura

local profileGuard			= false
local profileCopyList		= {}
local profileDeleteList		= {}
local profileCopyToCopy, profileDeleteToDelete, profileDeleteDropRef

local sampleAurasActive		= false


-- ------------------------
-- SAMPLE AURAS
-- ------------------------
local sampleAuraData = {
	-- player timed
	[116001] = {auraName = strformat('%s %d', L.SampleAura_PlayerTimed, 1),		unitTag = 'player', duration = 10,	icon = [[/esoui/art/icons/ability_destructionstaff_001.dds]],	effectType = BUFF_EFFECT_TYPE_BUFF,		abilityType = ABILITY_TYPE_BONUS},
	[116002] = {auraName = strformat('%s %d', L.SampleAura_PlayerTimed, 2),		unitTag = 'player', duration = 20,	icon = [[/esoui/art/icons/ability_destructionstaff_002.dds]],	effectType = BUFF_EFFECT_TYPE_BUFF,		abilityType = ABILITY_TYPE_BONUS},
	[116003] = {auraName = strformat('%s %d', L.SampleAura_PlayerTimed, 3),		unitTag = 'player', duration = 30,	icon = [[/esoui/art/icons/ability_destructionstaff_003.dds]],	effectType = BUFF_EFFECT_TYPE_BUFF,		abilityType = ABILITY_TYPE_BONUS},
	[116004] = {auraName = strformat('%s %d', L.SampleAura_PlayerTimed, 4),		unitTag = 'player', duration = 60,	icon = [[/esoui/art/icons/ability_destructionstaff_004.dds]],	effectType = BUFF_EFFECT_TYPE_BUFF,		abilityType = ABILITY_TYPE_BONUS},
	[116005] = {auraName = strformat('%s %d', L.SampleAura_PlayerTimed, 5),		unitTag = 'player', duration = 120,	icon = [[/esoui/art/icons/ability_destructionstaff_005.dds]],	effectType = BUFF_EFFECT_TYPE_BUFF,		abilityType = ABILITY_TYPE_BONUS},
	[116006] = {auraName = strformat('%s %d', L.SampleAura_PlayerTimed, 6),		unitTag = 'player', duration = 600,	icon = [[/esoui/art/icons/ability_destructionstaff_006.dds]],	effectType = BUFF_EFFECT_TYPE_BUFF,		abilityType = ABILITY_TYPE_BONUS},
	-- player toggled
	[116007] = {auraName = strformat('%s %d', L.SampleAura_PlayerToggled, 1),	unitTag = 'player', duration = 0,	icon = [[esoui/art/icons/ability_mageguild_001.dds]],			effectType = BUFF_EFFECT_TYPE_BUFF,		abilityType = ABILITY_TYPE_BONUS},
	[116008] = {auraName = strformat('%s %d', L.SampleAura_PlayerToggled, 2),	unitTag = 'player', duration = 0,	icon = [[esoui/art/icons/ability_mageguild_002.dds]],			effectType = BUFF_EFFECT_TYPE_BUFF,		abilityType = ABILITY_TYPE_BONUS},
	-- player passive
	[116009] = {auraName = strformat('%s %d', L.SampleAura_PlayerPassive, 1),	unitTag = 'player', duration = 0,	icon = [[esoui/art/icons/ability_restorationstaff_001.dds]],	effectType = BUFF_EFFECT_TYPE_BUFF,		abilityType = ABILITY_TYPE_BONUS},
	[116010] = {auraName = strformat('%s %d', L.SampleAura_PlayerPassive, 2),	unitTag = 'player', duration = 0,	icon = [[esoui/art/icons/ability_restorationstaff_002.dds]],	effectType = BUFF_EFFECT_TYPE_BUFF,		abilityType = ABILITY_TYPE_BONUS},
	-- player debuff
	[116011] = {auraName = strformat('%s %d', L.SampleAura_PlayerDebuff, 1),	unitTag = 'player', duration = 10,	icon = [[esoui/art/icons/ability_nightblade_001.dds]],			effectType = BUFF_EFFECT_TYPE_DEBUFF,	abilityType = ABILITY_TYPE_BONUS},
	[116012] = {auraName = strformat('%s %d', L.SampleAura_PlayerDebuff, 2),	unitTag = 'player', duration = 30,	icon = [[esoui/art/icons/ability_nightblade_002.dds]],			effectType = BUFF_EFFECT_TYPE_DEBUFF,	abilityType = ABILITY_TYPE_BONUS},
	-- player ground (co opting the abilityID of ranks 2 and 3 of Path of Darkness to bypass the description check
	[37751]  = {auraName = strformat('%s %d', L.SampleAura_PlayerGround, 1),	unitTag = '', 		duration = 10,	icon = [[/esoui/art/icons/ability_destructionstaff_008.dds]],	effectType = BUFF_EFFECT_TYPE_BUFF,		abilityType = ABILITY_TYPE_AREAEFFECT},
	[37757]  = {auraName = strformat('%s %d', L.SampleAura_PlayerGround, 2),	unitTag = '', 		duration = 30,	icon = [[/esoui/art/icons/ability_destructionstaff_011.dds]],	effectType = BUFF_EFFECT_TYPE_BUFF,		abilityType = ABILITY_TYPE_AREAEFFECT},
	-- player major|minor buffs (co opting abilityIDs from existing spells to properly filter the samples
	[62175] = {auraName = strformat('%s %d', L.SampleAura_PlayerMajor, 1),		unitTag = 'player', duration = 30,	icon = [[/esoui/art/icons/ability_sorcerer_boundless_storm.dds]], effectType = BUFF_EFFECT_TYPE_BUFF,	abilityType = ABILITY_TYPE_BONUS},
	[61898] = {auraName = strformat('%s %d', L.SampleAura_PlayerMinor, 1),		unitTag = 'player', duration = 30,	icon = [[/esoui/art/icons/ability_sorcerer_boundless_storm.dds]], effectType = BUFF_EFFECT_TYPE_BUFF,	abilityType = ABILITY_TYPE_BONUS},
	-- target buff (2 timeds and 1 passive)
	[116015] = {auraName = strformat('%s %d', L.SampleAura_TargetBuff, 1),		unitTag = 'reticleover', duration = 10,	icon = [[esoui/art/icons/ability_restorationstaff_004.dds]],	effectType = BUFF_EFFECT_TYPE_BUFF,		abilityType = ABILITY_TYPE_BONUS},
	[116016] = {auraName = strformat('%s %d', L.SampleAura_TargetBuff, 2),		unitTag = 'reticleover', duration = 30,	icon = [[esoui/art/icons/ability_restorationstaff_005.dds]],	effectType = BUFF_EFFECT_TYPE_BUFF,		abilityType = ABILITY_TYPE_BONUS},
	[116017] = {auraName = strformat('%s %d', L.SampleAura_TargetBuff, 3),		unitTag = 'reticleover', duration = 0,	icon = [[/esoui/art/icons/ability_armor_001.dds]],				effectType = BUFF_EFFECT_TYPE_BUFF,		abilityType = ABILITY_TYPE_BONUS},
	-- target debuff
	[116018] = {auraName = strformat('%s %d', L.SampleAura_TargetDebuff, 1),	unitTag = 'reticleover', duration = 10,	icon = [[esoui/art/icons/ability_nightblade_003.dds]],			effectType = BUFF_EFFECT_TYPE_DEBUFF,	abilityType = ABILITY_TYPE_BONUS},
	[116019] = {auraName = strformat('%s %d', L.SampleAura_TargetDebuff, 2),	unitTag = 'reticleover', duration = 30,	icon = [[esoui/art/icons/ability_nightblade_004.dds]],			effectType = BUFF_EFFECT_TYPE_DEBUFF,	abilityType = ABILITY_TYPE_BONUS},
}

local function ShowSampleAuras()
	for _, fragment in pairs(Srendarr.displayFramesScene) do
		SCENE_MANAGER:AddFragment(fragment)	-- make sure displayframes are visible while in the options panel
	end

	Srendarr.OnPlayerActivatedAlive() -- reset to a clean slate

	local current = GetGameTimeMilliseconds() / 1000

	for id, data in pairs(sampleAuraData) do
		Srendarr.OnEffectChanged(nil, EFFECT_RESULT_GAINED, nil, data.auraName, data.unitTag, current, current + data.duration, nil, data.icon, nil, data.effectType, data.abilityType, nil, nil, nil, id)
	end
end


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
	local usingGlobal	= SrendarrDB.Default[GetDisplayName()]['$AccountWide'].useAccountWide
	local destProfile	= (usingGlobal) and '$AccountWide' or GetUnitName('player')
	local sourceData, destData

	for account, accountData in pairs(SrendarrDB.Default) do
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
		CHAT_SYSTEM:AddMessage(strformat('%s: %s', L.Srendarr, L.Profile_CopyCannotCopy))
	else
		CopyTable(sourceData, destData)
		ReloadUI()
	end
end

local function DeleteProfile()
	for account, accountData in pairs(SrendarrDB.Default) do
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
	local usingGlobal	= SrendarrDB.Default[GetDisplayName()]['$AccountWide'].useAccountWide
	local currentPlayer	= GetUnitName('player')
	local versionDB		= Srendarr.versionDB

	for account, accountData in pairs(SrendarrDB.Default) do
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
function Srendarr:PopulateProminentAurasDropdown()
	for i in pairs(dropProminentAuras) do
		dropProminentAuras[i] = nil -- clean out dropdown
	end

	tinsert(dropProminentAuras, L.GenericSetting_ClickToViewAuras) -- insert 'dummy' first entry

	for name in pairs(Srendarr.db.prominentWhitelist) do
		if (name == STR_PROMBYID) then -- special case for auras added by abilityID
			for id in pairs(Srendarr.db.prominentWhitelist[STR_PROMBYID]) do
				tinsert(dropProminentAuras, strformat('[%d] %s', id, GetAbilityName(id)))
			end
		else
			tinsert(dropProminentAuras, name) -- add current aura selection
		end
	end

	prominentAurasWidgetRef:UpdateChoices()
	prominentAurasWidgetRef:UpdateValue()
end

function Srendarr:PopulateProminentAurasDropdown2()
	for i in pairs(dropProminentAuras2) do
		dropProminentAuras2[i] = nil -- clean out dropdown
	end

	tinsert(dropProminentAuras2, L.GenericSetting_ClickToViewAuras) -- insert 'dummy' first entry

	for name in pairs(Srendarr.db.prominentWhitelist2) do
		if (name == STR_PROMBYID2) then -- special case for auras added by abilityID
			for id in pairs(Srendarr.db.prominentWhitelist2[STR_PROMBYID2]) do
				tinsert(dropProminentAuras2, strformat('[%d] %s', id, GetAbilityName(id)))
			end
		else
			tinsert(dropProminentAuras2, name) -- add current aura selection
		end
	end

	prominentAurasWidgetRef2:UpdateChoices()
	prominentAurasWidgetRef2:UpdateValue()
end

local function PopulateBlacklistAurasDropdown()
	for i in pairs(dropBlacklistAuras) do
		dropBlacklistAuras[i] = nil -- clean out dropdown
	end

	tinsert(dropBlacklistAuras, L.GenericSetting_ClickToViewAuras) -- insert 'dummy' first entry

	for name in pairs(Srendarr.db.blacklist) do
		if (name == STR_BLOCKBYID) then -- special case for auras added by abilityID
			for id in pairs(Srendarr.db.blacklist[STR_BLOCKBYID]) do
				tinsert(dropBlacklistAuras, strformat('[%d] %s', id, GetAbilityName(id)))
			end
		else
			tinsert(dropBlacklistAuras, name) -- add current aura selection
		end
	end

	blacklistAurasWidgetRef:UpdateChoices()
	blacklistAurasWidgetRef:UpdateValue()
end

local function CreateWidgets(panelID, panelData)
	local panel = tabPanels[panelID]
	local isLastHalf = false
	local anchorOffset = 0

	for entry, widgetData in ipairs(panelData) do
		local widgetType = widgetData.type
		local widget = LAMCreateControl[widgetType](panel, widgetData)

		if (panelID ~= 10 and widget.data.widgetRightAlign) then -- display frames (10) does its own config
			widget.thumb:ClearAnchors()
			widget.thumb:SetAnchor(RIGHT, widget.color, RIGHT, 0, 0)
		end

		if (panelID ~= 10 and widget.data.widgetPositionAndResize) then -- display frames (10) does its own config
			widget:SetAnchor(TOPLEFT, lastAddedControl[panelID], TOPLEFT, 0, 0) -- overlay widget with previous
			widget:SetWidth(controlPanelWidth - (controlPanelWidth / 3) + widget.data.widgetPositionAndResize) -- shrink widget to give appearance of sharing a row
		else
			widget:SetAnchor(TOPLEFT, lastAddedControl[panelID], BOTTOMLEFT, 0, 15)
			lastAddedControl[panelID] = widget
		end

		if (panelID == 2 and widgetData.isProminentAurasWidget) then -- General panel, grab the 1st prominent auras dropdown list for later
			prominentAurasWidgetRef = widget
		elseif (panelID == 2 and widgetData.isProminentAurasWidget2) then -- General panel, grab the 2nd prominent auras dropdown list for later
			prominentAurasWidgetRef2 = widget
		elseif (panelID == 2 and widgetData.isBlacklistAurasWidget) then -- Filters panel, grab the blacklist auras dropdown list for later
			blacklistAurasWidgetRef = widget
		elseif (panelID == 5 and widgetData.isProfileDeleteDrop) then -- Profile panel, grab the delete dropdown list for later
			profileDeleteDropRef = widget
		elseif (panelID == 10) then -- make a reference to each widget for the Display Frames settings
			tabDisplayWidgetRef[entry] = widget
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
		name = (panelID < 10 and panelID ~= 2) and L['TabHeader' .. panelID] or L.Filter_BlacklistHeader, -- header is set for display frames later
	})
	ctrl:SetAnchor(TOPLEFT)

	panel.headerRef = ctrl -- set reference to header for later update

	if (panelID == 10) then -- add string below header (shows aura groups on the given DisplayFrame)
		ctrl = WM:CreateControl(nil, panel, CT_LABEL)
		ctrl:SetFont('$(CHAT_FONT)|14|soft-shadow-thin')
		ctrl:SetText('')
		ctrl:SetDimensions(controlPanelWidth)
		ctrl:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
		ctrl:SetAnchor(TOPLEFT, panel.headerRef, BOTTOMLEFT, 0, 1)

		panel.groupRef = ctrl -- set reference to string for later update
	end

	lastAddedControl[panelID] = ctrl

	CreateWidgets(panelID, tabPanelData[panelID]) -- create the actual setting elements

	if (panelID == 2) then -- populate blacklist and prominent auras dropdown lists
		PopulateBlacklistAurasDropdown()
		Srendarr:PopulateProminentAurasDropdown()
		Srendarr:PopulateProminentAurasDropdown2()
	end
end


-- ------------------------
-- PANEL CONFIGURATION
-- ------------------------
local function ConfigurePanelDisplayFrame(fromStyleFlag)
	if (not fromStyleFlag) then -- set the header for the current display frame (unless called by a style change which doesn't change these)
		tabPanels[10].headerRef.data.name = strformat('%s [|cffd100%d|r]', L.TabHeaderDisplay, currentDisplayFrame)

		-- set the displayed groups info entry for the current display frame
		local groupText = strformat('%s: ', L.Group_Displayed_Here)
		local noGroups = true

		for group, frame in pairs(Srendarr.db.auraGroups) do
			if (frame == currentDisplayFrame) then -- this group is being show on this frame
				groupText = strformat('%s |cffd100%s|r,', groupText, Srendarr.auraGroupStrings[group])
				noGroups = false
			end
		end

		if (noGroups) then
			groupText = strformat('%s |cffd100%s|r,', groupText, L.Group_Displayed_None)
		end

		tabPanels[10].groupRef:SetText(string.sub(groupText, 1, -2))
	end

	lastAddedControl[10] = tabDisplayWidgetRef[4] -- the style choice box, grab ref for future anchoring

	local displayStyle = displayDB[currentDisplayFrame].style -- get the style for current frame

	for entry, widget in ipairs(tabDisplayWidgetRef) do
		if (entry > 4) then -- we never need to adjust the first 4 widgets
			if (widget.data.hideOnStyle[displayStyle]) then -- should widget be visible with the current display frame's style
				widget:SetHidden(true)
			else -- widget is visible, reanchor to maintain the appearance of the settings panel
				widget:SetHidden(false)

				if (widget.data.widgetRightAlign) then
					widget.thumb:ClearAnchors() -- widget needs manipulation, anchor swatch to the right for later
					widget.thumb:SetAnchor(RIGHT, widget.color, RIGHT, 0, 0)
				end

				if (widget.data.widgetPositionAndResize) then
					widget:SetAnchor(TOPLEFT, lastAddedControl[10], TOPLEFT, 0, 0) -- overlay widget with previous
					widget:SetWidth(controlPanelWidth - (controlPanelWidth / 3) + widget.data.widgetPositionAndResize)
				else
					widget:SetAnchor(TOPLEFT, lastAddedControl[10], BOTTOMLEFT, 0, 15)
					lastAddedControl[10] = widget
				end
			end
		end
	end
end

local function OnStyleChange(style)
	if (style == AURA_STYLE_FULL or style == AURA_STYLE_MINI) then -- these styles have restricted auraGrowth options
		if (displayDB[currentDisplayFrame].auraGrowth ~= AURA_GROW_UP and displayDB[currentDisplayFrame].auraGrowth ~= AURA_GROW_DOWN) then
			displayDB[currentDisplayFrame].auraGrowth = AURA_GROW_DOWN -- force (now) invalid growth choice to a valid setting

			Srendarr.displayFrames[currentDisplayFrame]:Configure()		-- growth has changed, update DisplayFrame
			Srendarr.displayFrames[currentDisplayFrame]:ConfigureDragOverlay()
			Srendarr.displayFrames[currentDisplayFrame]:UpdateDisplay()
		end
	end

	if (style == AURA_STYLE_FULL) then -- this style has restricted timerLocation options
		if (displayDB[currentDisplayFrame].timerLocation ~= AURA_TIMERLOC_OVER and displayDB[currentDisplayFrame].timerLocation ~= AURA_TIMERLOC_HIDDEN) then
			displayDB[currentDisplayFrame].timerLocation = AURA_TIMERLOC_OVER -- force (now) invalid placement choice to a valid setting
		end
	end

	Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras() -- auras have changed style, update their appearance
end

-- ------------------------
-- TAB BUTTON HANDLER
-- ------------------------
local function TabButtonOnClick(self)
	if (not tabPanels[self.panelID]) then
		CreateTabPanel(self.panelID) -- call to create appropriate panel if not created yet
	end

	for x = 1, 13 do
		tabButtons[x].button:SetState(0) -- unset selected state for all buttons
	end

	if (self.buttonID == 4) then -- display frames primary button
		for x = 6, 13 do
			tabButtons[x]:SetHidden(false) -- show display frame tab buttons
		end

		tabButtons[currentDisplayFrame + 5].button:SetState(1, true) -- set current display button selected

		ConfigurePanelDisplayFrame() -- configure the settings for Display Frames (changes for multiple reasons)
	elseif (self.buttonID >= 6) then -- one of the display frame buttons
		currentDisplayFrame = self.displayID
		tabButtons[4].button:SetState(1, true) -- set display primary selected

		ConfigurePanelDisplayFrame() -- configure the settings for Display Frames (changes for multiple reasons)
	else -- one of the other 3 tab buttons
		for x = 6, 13 do
			tabButtons[x]:SetHidden(true) -- hide display frame tab buttons
		end
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

	for x = 1, 13 do
		btn = LAMCreateControl.button(tabButtonsPanel, { -- create our tab buttons
			type = 'button',
			name = (x <= 5) and L['TabButton' .. x] or tostring(x - 5),
			func = TabButtonOnClick,
		})
		btn.button.buttonID = x -- reference lookup to refer to buttons

		if (x <= 5) then -- main tab buttons (General, Filters, Display Frames & Profiles)
			btn:SetWidth((controlPanelWidth / 5) - 2)
			btn.button:SetWidth((controlPanelWidth / 5) - 2)
			btn:SetAnchor(TOPLEFT, tabButtonsPanel, TOPLEFT, (x == 1) and 0 or ((controlPanelWidth / 5) * (x - 1)), 0)

			btn.button.panelID = (x == 4) and 10 or x -- reference lookup to refer to panels
		else -- display frame tab buttons
			btn:SetWidth((controlPanelWidth / 8) - 2)
			btn.button:SetWidth((controlPanelWidth / 8) - 2)
			btn:SetAnchor(TOPLEFT, tabButtonsPanel, TOPLEFT, (x == 6) and 0 or ((controlPanelWidth / 8) * (x - 6)), 34)
			btn:SetHidden(true)

			btn.button.panelID		= 10	-- reference lookup to refer to panels (special case for display frames)
			btn.button.displayID	= x - 5	-- for later reference to relate to DisplayFrames
		end

		tabButtons[x] = btn
	end

	tabButtons[1].button:SetState(1, true) -- set selected state for first (General) panel

	CreateTabPanel(1) -- create first (General) panel on settings first load

	-- build a button to show sample castbar
	btn = WM:CreateControlFromVirtual(nil, controlPanel, 'ZO_DefaultButton')
	btn:SetWidth((controlPanelWidth / 3) - 30)
	btn:SetText(L.Show_Example_Castbar)
	btn:SetAnchor(TOPRIGHT, controlPanel, TOPRIGHT, -60, -4)
	btn:SetHandler('OnClicked', function()
		local currentTime = GetGameTimeMilliseconds() / 1000

		Srendarr.Cast:OnCastStart(
			true,
			strformat('%s - %s', L.Srendarr_Basic, L.CastBar),
			currentTime,
			currentTime + 600,
			[[esoui/art/icons/ability_mageguild_001.dds]],
			116016
		)
		Srendarr.Cast:SetHidden(false)
	end)

	-- build a button to trigger sample auras
	btn = WM:CreateControlFromVirtual(nil, controlPanel, 'ZO_DefaultButton')
	btn:SetWidth((controlPanelWidth / 3) - 30)
	btn:SetText(L.Show_Example_Auras)
	btn:SetAnchor(TOPRIGHT, controlPanel, TOPRIGHT, -230, -4)
	btn:SetHandler('OnClicked', function()
		sampleAurasActive = true
		ShowSampleAuras()
	end)



	PopulateProfileLists() -- populate available profiles

	ZO_PreHookHandler(tabButtonsPanel, 'OnEffectivelyHidden', function()
    	showSampleAuras = false
		Srendarr.OnPlayerActivatedAlive() -- closed options, reset auras

		if (Srendarr.uiLocked) then -- stop any ongoing (most likely faked) casts if the ui isn't unlocked
			Srendarr.Cast:DisableDragOverlay() -- using existing function to save time
		end
    end)
end

function Srendarr:InitializeSettings()
	displayDB = self.db.displayFrames -- local reference just to make things easier

	local panelData = {
		type = 'panel',
		name = L.Srendarr_Basic,
		displayName = L.Srendarr,
		author = 'Kith, Phinix, Garkin & silentgecko',
		version = self.version,
		registerForRefresh = true,
		registerForDefaults = false,
	}

	controlPanel = LAM:RegisterAddonPanel(settingsGlobalStr, panelData)

	local optionsData = {
		[1] = {
			type = 'custom',
			reference = settingsGlobalStrBtns,
		},
	}

	LAM:RegisterOptionControls(settingsGlobalStr, optionsData)

	CM:RegisterCallback("LAM-PanelControlsCreated", CompleteInitialization)
end


-- -----------------------
-- OPTIONS DATA TABLES
-- -----------------------
tabPanelData = {
	-- -----------------------
	-- GENERAL SETTINGS
	-- -----------------------
	[1] = {
		{
			type = 'description',
			text = L.General_UnlockDesc,
		},
		{
			type = 'button',
			name = L.General_UnlockUnlock,
			func = function(btn)
				if (Srendarr.uiLocked) then
					Srendarr.SlashCommand('unlock')
					btn:SetText(L.General_UnlockLock)

					for _, fragment in pairs(Srendarr.displayFramesScene) do
						SCENE_MANAGER:AddFragment(fragment)	-- make sure displayframes are visible
					end
				else
					Srendarr.SlashCommand('lock')
					btn:SetText(L.General_UnlockUnlock)
				end
			end,
		},
		{
			type = 'button',
			name = L.General_UnlockReset,
			func = function(btn)
				if (btn.resetCheck) then -- button has been clicked twice, perform the reset
					local defaults = (Srendarr:GetDefaults()).displayFrames -- get original positions

					for frame = 1, Srendarr.NUM_DISPLAY_FRAMES do
						local point, x, y = defaults[frame].base.point, defaults[frame].base.x, defaults[frame].base.y
						-- update player settings to defaults
						Srendarr.db.displayFrames[frame].base.point = point
						Srendarr.db.displayFrames[frame].base.x = x
						Srendarr.db.displayFrames[frame].base.y = y
						-- set displayframes to original locations
						Srendarr.displayFrames[frame]:ClearAnchors()
						Srendarr.displayFrames[frame]:SetAnchor(point, GuiRoot, point, x, y)
					end

					-- reset cast bar
					defaults = (Srendarr:GetDefaults()).castBar.base

					Srendarr.db.castBar.base.point = defaults.point
					Srendarr.db.castBar.base.x = defaults.x
					Srendarr.db.castBar.base.y = defaults.y

					Srendarr.Cast:ClearAnchors()
					Srendarr.Cast:SetAnchor(defaults.point, GuiRoot, defaults.point, defaults.x, defaults.y)


					btn.resetCheck = false
					btn:SetText(L.General_UnlockReset)
				else -- first time click in a reset attempt
					btn.resetCheck = true
					btn:SetText(L.General_UnlockResetAgain)
				end
			end,
			widgetPositionAndResize	= -200,
		},
		{
			type = 'checkbox',
			name = L.General_CombatOnly,
			tooltip = L.General_CombatOnlyTip,
			getFunc = function()
				return Srendarr.db.combatDisplayOnly
			end,
			setFunc = function(v)
				Srendarr.db.combatDisplayOnly = v
				Srendarr:ConfigureOnCombatState()
			end,
		},
		{
			type = 'checkbox',
			name = L.General_AuraFakeEnabled,
			tooltip = L.General_AuraFakeEnabledTip,
			getFunc = function()
				return Srendarr.db.auraFakeEnabled
			end,
			setFunc = function(v)
				Srendarr.db.auraFakeEnabled = v
				Srendarr:ConfigureOnActionSlotAbilityUsed()
			end,
		},
		{
			type = 'checkbox',
			name = L.General_ConsolidateEnabled,
			tooltip = L.General_ConsolidateEnabledTip,
			getFunc = function()
				return Srendarr.db.consolidateEnabled
			end,
			setFunc = function(v)
				Srendarr.db.consolidateEnabled = v
				Srendarr:ConfigureOnActionSlotAbilityUsed()
			end,
		},
		{
			type = 'checkbox',
			name = L.General_PassiveEffectsAsPassive,
			tooltip = L.General_PassiveEffectsAsPassiveTip,
			getFunc = function()
				return Srendarr.db.passiveEffectsAsPassive
			end,
			setFunc = function(v)
				Srendarr.db.passiveEffectsAsPassive = v
				Srendarr:ConfigureAuraHandler()
			end,
		},
		{
			type = 'slider',
			name = L.General_AuraFadeout,
			tooltip = L.General_AuraFadeoutTip,
			min = 0,
			max = 5000,
			step = 100,
			getFunc = function()
				return Srendarr.db.auraFadeTime * 1000
			end,
			setFunc = function(v)
				Srendarr.db.auraFadeTime = v / 1000
				Srendarr:ConfigureAuraFadeTime()
			end,
		},
		{
			type = 'slider',
			name = L.General_ShortThreshold,
			tooltip = L.General_ShortThresholdTip,
			warning = L.General_ShortThresholdWarn,
			min = 10,
			max = 120,
			getFunc = function()
				return Srendarr.db.shortBuffThreshold
			end,
			setFunc = function(v)
				Srendarr.db.shortBuffThreshold = v
				Srendarr:ConfigureAuraHandler()
			end,
		},
		{
			type = 'checkbox',
			name = L.General_ProcEnableAnims,
			tooltip = L.General_ProcEnableAnimsTip,
			getFunc = function()
				return Srendarr.db.procEnableAnims
			end,
			setFunc = function(v)
				Srendarr.db.procEnableAnims = v
				Srendarr:ConfigureProcs()
			end,
		},
		{
			type = 'dropdown',
			name = L.General_ProcPlaySound,
			tooltip = L.General_ProcPlaySoundTip,
			choices = LMP:List('sound'),
			getFunc = function()
				return Srendarr.db.procPlaySound
			end,
			setFunc = function(v)
				PlaySound(LMP:Fetch('sound', v))
				Srendarr.db.procPlaySound = v
				Srendarr:ConfigureProcs()
			end,
		},
		-- -----------------------
		-- AURA CONTROL: DISPLAY GROUPS
		-- -----------------------
		{
			type = 'header',
			name = L.General_ControlHeader,
		},
		{
			type = 'dropdown',
			name = L.Group_Player_Short,
			tooltip = strformat('%s\n\n%s', L.General_ControlBaseTip, L.General_ControlShortTip),
			choices = dropGroup,
			getFunc = function()
				-- just handle a special case with the 'dont display' setting internally being 0 and the settings menu wanting a >1 number
				return dropGroup[((Srendarr.db.auraGroups[GROUP_PLAYER_SHORT] == 0) and 9 or Srendarr.db.auraGroups[GROUP_PLAYER_SHORT])]
			end,
			setFunc = function(v)
				Srendarr.db.auraGroups[GROUP_PLAYER_SHORT] = dropGroupRef[v]
				Srendarr:ConfigureAuraHandler()

				if (sampleAurasActive) then
					ShowSampleAuras() -- sample auras calls OnPlayerActivatedAlive as well
				else
					Srendarr.OnPlayerActivatedAlive()
				end
			end,
		},
		{
			type = 'dropdown',
			name = L.Group_Player_Long,
			tooltip = strformat('%s\n\n%s', L.General_ControlBaseTip, L.General_ControlLongTip),
			choices = dropGroup,
			getFunc = function()
				-- just handle a special case with the 'dont display' setting internally being 0 and the settings menu wanting a >1 number
				return dropGroup[((Srendarr.db.auraGroups[GROUP_PLAYER_LONG] == 0) and 9 or Srendarr.db.auraGroups[GROUP_PLAYER_LONG])]
			end,
			setFunc = function(v)
				Srendarr.db.auraGroups[GROUP_PLAYER_LONG] = dropGroupRef[v]
				Srendarr:ConfigureAuraHandler()

				if (sampleAurasActive) then
					ShowSampleAuras() -- sample auras calls OnPlayerActivatedAlive as well
				else
					Srendarr.OnPlayerActivatedAlive()
				end
			end,
		},
		{
			type = 'dropdown',
			name = L.Group_Player_Major,
			tooltip = strformat('%s\n\n%s', L.General_ControlBaseTip, L.General_ControlMajorTip),
			choices = dropGroup,
			getFunc = function()
				-- just handle a special case with the 'dont display' setting internally being 0 and the settings menu wanting a >1 number
				return dropGroup[((Srendarr.db.auraGroups[GROUP_PLAYER_MAJOR] == 0) and 9 or Srendarr.db.auraGroups[GROUP_PLAYER_MAJOR])]
			end,
			setFunc = function(v)
				Srendarr.db.auraGroups[GROUP_PLAYER_MAJOR] = dropGroupRef[v]
				Srendarr:ConfigureAuraHandler()

				if (sampleAurasActive) then
					ShowSampleAuras() -- sample auras calls OnPlayerActivatedAlive as well
				else
					Srendarr.OnPlayerActivatedAlive()
				end
			end,
		},
		{
			type = 'dropdown',
			name = L.Group_Player_Minor,
			tooltip = strformat('%s\n\n%s', L.General_ControlBaseTip, L.General_ControlMinorTip),
			choices = dropGroup,
			getFunc = function()
				-- just handle a special case with the 'dont display' setting internally being 0 and the settings menu wanting a >1 number
				return dropGroup[((Srendarr.db.auraGroups[GROUP_PLAYER_MINOR] == 0) and 9 or Srendarr.db.auraGroups[GROUP_PLAYER_MINOR])]
			end,
			setFunc = function(v)
				Srendarr.db.auraGroups[GROUP_PLAYER_MINOR] = dropGroupRef[v]
				Srendarr:ConfigureAuraHandler()

				if (sampleAurasActive) then
					ShowSampleAuras() -- sample auras calls OnPlayerActivatedAlive as well
				else
					Srendarr.OnPlayerActivatedAlive()
				end
			end,
		},
		{
			type = 'dropdown',
			name = L.Group_Player_Enchant,
			tooltip = strformat('%s\n\n%s', L.General_ControlBaseTip, L.General_ControlEnchantTip),
			choices = dropGroup,
			getFunc = function()
				-- just handle a special case with the 'dont display' setting internally being 0 and the settings menu wanting a >1 number
				return dropGroup[((Srendarr.db.auraGroups[GROUP_PLAYER_ENCHANT] == 0) and 9 or Srendarr.db.auraGroups[GROUP_PLAYER_ENCHANT])]
			end,
			setFunc = function(v)
				Srendarr.db.auraGroups[GROUP_PLAYER_ENCHANT] = dropGroupRef[v]
				Srendarr:ConfigureAuraHandler()

				if (sampleAurasActive) then
					ShowSampleAuras() -- sample auras calls OnPlayerActivatedAlive as well
				else
					Srendarr.OnPlayerActivatedAlive()
				end
			end,
		},
		{
			type = 'dropdown',
			name = L.Group_Player_Toggled,
			tooltip = strformat('%s\n\n%s', L.General_ControlBaseTip, L.General_ControlToggledTip),
			choices = dropGroup,
			getFunc = function()
				-- just handle a special case with the 'dont display' setting internally being 0 and the settings menu wanting a >1 number
				return dropGroup[((Srendarr.db.auraGroups[GROUP_PLAYER_TOGGLED] == 0) and 9 or Srendarr.db.auraGroups[GROUP_PLAYER_TOGGLED])]
			end,
			setFunc = function(v)
				Srendarr.db.auraGroups[GROUP_PLAYER_TOGGLED] = dropGroupRef[v]
				Srendarr:ConfigureAuraHandler()

				if (sampleAurasActive) then
					ShowSampleAuras() -- sample auras calls OnPlayerActivatedAlive as well
				else
					Srendarr.OnPlayerActivatedAlive()
				end
			end,
		},
		{
			type = 'dropdown',
			name = L.Group_Player_Passive,
			tooltip = strformat('%s\n\n%s', L.General_ControlBaseTip, L.General_ControlPassiveTip),
			choices = dropGroup,
			getFunc = function()
				-- just handle a special case with the 'dont display' setting internally being 0 and the settings menu wanting a >1 number
				return dropGroup[((Srendarr.db.auraGroups[GROUP_PLAYER_PASSIVE] == 0) and 9 or Srendarr.db.auraGroups[GROUP_PLAYER_PASSIVE])]
			end,
			setFunc = function(v)
				Srendarr.db.auraGroups[GROUP_PLAYER_PASSIVE] = dropGroupRef[v]
				Srendarr:ConfigureAuraHandler()

				if (sampleAurasActive) then
					ShowSampleAuras() -- sample auras calls OnPlayerActivatedAlive as well
				else
					Srendarr.OnPlayerActivatedAlive()
				end
			end,
		},
		{
			type = 'dropdown',
			name = L.Group_Player_Debuff,
			tooltip = strformat('%s\n\n%s', L.General_ControlBaseTip, L.General_ControlDebuffTip),
			choices = dropGroup,
			getFunc = function()
				-- just handle a special case with the 'dont display' setting internally being 0 and the settings menu wanting a >1 number
				return dropGroup[((Srendarr.db.auraGroups[GROUP_PLAYER_DEBUFF] == 0) and 9 or Srendarr.db.auraGroups[GROUP_PLAYER_DEBUFF])]
			end,
			setFunc = function(v)
				Srendarr.db.auraGroups[GROUP_PLAYER_DEBUFF] = dropGroupRef[v]
				Srendarr:ConfigureAuraHandler()

				if (sampleAurasActive) then
					ShowSampleAuras() -- sample auras calls OnPlayerActivatedAlive as well
				else
					Srendarr.OnPlayerActivatedAlive()
				end
			end,
		},
		{
			type = 'dropdown',
			name = L.Group_Player_Ground,
			tooltip = strformat('%s\n\n%s', L.General_ControlBaseTip, L.General_ControlGroundTip),
			choices = dropGroup,
			getFunc = function()
				-- just handle a special case with the 'dont display' setting internally being 0 and the settings menu wanting a >1 number
				return dropGroup[((Srendarr.db.auraGroups[GROUP_PLAYER_GROUND] == 0) and 9 or Srendarr.db.auraGroups[GROUP_PLAYER_GROUND])]
			end,
			setFunc = function(v)
				Srendarr.db.auraGroups[GROUP_PLAYER_GROUND] = dropGroupRef[v]
				Srendarr:ConfigureAuraHandler()

				if (sampleAurasActive) then
					ShowSampleAuras() -- sample auras calls OnPlayerActivatedAlive as well
				else
					Srendarr.OnPlayerActivatedAlive()
				end
			end,
		},
		{
			type = 'dropdown',
			name = L.Group_Target_Buff,
			tooltip = strformat('%s\n\n%s', L.General_ControlBaseTip, L.General_ControlTargetBuffTip),
			choices = dropGroup,
			getFunc = function()
				-- just handle a special case with the 'dont display' setting internally being 0 and the settings menu wanting a >1 number
				return dropGroup[((Srendarr.db.auraGroups[GROUP_TARGET_BUFF] == 0) and 9 or Srendarr.db.auraGroups[GROUP_TARGET_BUFF])]
			end,
			setFunc = function(v)
				Srendarr.db.auraGroups[GROUP_TARGET_BUFF] = dropGroupRef[v]
				Srendarr:ConfigureOnTargetChanged()
				Srendarr:ConfigureAuraHandler()

				if (sampleAurasActive) then
					ShowSampleAuras() -- sample auras calls OnPlayerActivatedAlive as well
				else
					Srendarr.OnPlayerActivatedAlive()
				end
			end,
		},
		{
			type = 'dropdown',
			name = L.Group_Target_Debuff,
			tooltip = strformat('%s\n\n%s', L.General_ControlBaseTip, L.General_ControlTargetDebuffTip),
			choices = dropGroup,
			getFunc = function()
				-- just handle a special case with the 'dont display' setting internally being 0 and the settings menu wanting a >1 number
				return dropGroup[((Srendarr.db.auraGroups[GROUP_TARGET_DEBUFF] == 0) and 9 or Srendarr.db.auraGroups[GROUP_TARGET_DEBUFF])]
			end,
			setFunc = function(v)
				Srendarr.db.auraGroups[GROUP_TARGET_DEBUFF] = dropGroupRef[v]
				Srendarr:ConfigureOnTargetChanged()
				Srendarr:ConfigureAuraHandler()

				if (sampleAurasActive) then
					ShowSampleAuras() -- sample auras calls OnPlayerActivatedAlive as well
				else
					Srendarr.OnPlayerActivatedAlive()
				end
			end,
		},
		-- -----------------------
		-- DEBUG OPTIONS
		-- -----------------------
		{
			type = 'header',
			name = L.General_DebugOptions,
		},
		{
			type = 'description',
			text = L.General_DebugOptionsDesc,
		},
		{
			type = 'checkbox',
			name = L.General_DisplayAbilityID,
			tooltip = L.General_DisplayAbilityIDTip,
			getFunc = function()
				return Srendarr.db.displayAbilityID
			end,
			setFunc = function(v)
				Srendarr.db.displayAbilityID = v
				Srendarr:ConfigureDisplayAbilityID()

				for frame = 1, Srendarr.NUM_DISPLAY_FRAMES do
					Srendarr.displayFrames[frame]:ConfigureAssignedAuras()
				end

				if (sampleAurasActive) then
					ShowSampleAuras() -- sample auras calls OnPlayerActivatedAlive as well
				else
					Srendarr.OnPlayerActivatedAlive()
				end
			end,
		},
		{
			type = 'checkbox',
			name = L.General_ShowCombatEvents,
			tooltip = L.General_ShowCombatEventsTip,
			getFunc = function()
				return Srendarr.db.showCombatEvents
			end,
			setFunc = function(v)
				Srendarr.db.showCombatEvents = v
			end,
		},
		{
			type = 'checkbox',
			name = L.General_DisableSpamControl,
			tooltip = L.General_DisableSpamControlTip,
			getFunc = function()
				return Srendarr.db.disableSpamControl
			end,
			setFunc = function(v)
				Srendarr.db.disableSpamControl = v
			end,
			disabled = function() return not Srendarr.db.showCombatEvents end,
		},
		{
			type = 'checkbox',
			name = L.General_AllowManualDebug,
			tooltip = L.General_AllowManualDebugTip,
			getFunc = function()
				return Srendarr.db.manualDebug
			end,
			setFunc = function(v)
				Srendarr.db.manualDebug = v
			end,
			disabled = function() return not Srendarr.db.showCombatEvents end,
		},
		{
			type = 'checkbox',
			name = L.General_ShowNoNames,
			tooltip = L.General_ShowNoNamesTip,
			getFunc = function()
				return Srendarr.db.showNoNames
			end,
			setFunc = function(v)
				Srendarr.db.showNoNames = v
			end,
			disabled = function() return not Srendarr.db.showCombatEvents end,
		},
	},
	-- -----------------------
	-- FILTER SETTINGS
	-- -----------------------
	[2] = {
		-- -----------------------
		-- AURA BLACKLIST
		-- -----------------------
		{
			type = 'editbox',
			name = L.Filter_BlacklistAdd,
			tooltip = L.Filter_BlacklistAddTip,
			warning = L.Filter_BlacklistAddWarn,
			getFunc = function ()
				return ''
			end,
			setFunc = function(v)
				if (v ~= '') then
					-- need to add to blacklist
					Srendarr:BlacklistAuraAdd(v)
					Srendarr.OnPlayerActivatedAlive()
				end

				PopulateBlacklistAurasDropdown()
			end,
			isMultiline = false,
		},
		{
			type = 'dropdown',
			name = L.Filter_BlacklistList,
			tooltip = L.Filter_BlacklistListTip,
			choices = dropBlacklistAuras,
			sort = 'name-down',
			getFunc = function()
				blacklistAurasSelectedAura = nil
				return dropBlacklistAuras[1]
			end,
			setFunc = function(v)
				blacklistAurasSelectedAura = (v ~= '' and v ~= L.GenericSetting_ClickToViewAuras) and v or nil
			end,
			isBlacklistAurasWidget = true,
		},
		{
			type = 'button',
			name = L.Filter_BlacklistRemove,
			func = function(btn)
				if (blacklistAurasSelectedAura) then
					if (string.find(blacklistAurasSelectedAura, '%[%d+%]')) then -- this is a 'by abilityID' aura
						blacklistAurasSelectedAura = string.match(blacklistAurasSelectedAura, '%d+') -- correct user display to just abilityID
					end

					Srendarr:BlacklistAuraRemove(blacklistAurasSelectedAura)
					Srendarr.OnPlayerActivatedAlive()
				end

				PopulateBlacklistAurasDropdown()
			end,
		},
		-- -----------------------
		-- PROMINENT BUFFS 12
		-- -----------------------
		{
			type = 'header',
			name = L.General_ProminentHeader,
		},
		{
			type = 'description',
			text = L.General_ProminentDesc,
		},
		{
			type = 'dropdown',
			name = L.Group_Prominent,
			tooltip = strformat('%s\n\n%s', L.General_ControlBaseTip, L.General_ControlProminentTip),
			choices = dropGroup,
			getFunc = function()
				-- just handle a special case with the 'dont display' setting internally being 0 and the settings menu wanting a >1 number
				return dropGroup[((Srendarr.db.auraGroups[GROUP_PROMINENT] == 0) and 9 or Srendarr.db.auraGroups[GROUP_PROMINENT])]
			end,
			setFunc = function(v)
				Srendarr.db.auraGroups[GROUP_PROMINENT] = dropGroupRef[v]
				Srendarr:ConfigureAuraHandler()

				if (sampleAurasActive) then
					ShowSampleAuras() -- sample auras calls OnPlayerActivatedAlive as well
				else
					Srendarr.OnPlayerActivatedAlive()
				end
			end,
		},
		{
			type = 'editbox',
			name = L.General_ProminentAdd,
			tooltip = L.General_ProminentAddTip,
			warning = L.General_ProminentAddWarn,
			getFunc = function ()
				return ''
			end,
			setFunc = function(v)
				if (v ~= '') then
					Srendarr:ProminentAuraAdd(v)
					Srendarr.OnPlayerActivatedAlive()
				end

				Srendarr:PopulateProminentAurasDropdown()
			end,
			isMultiline = false,
		},
		{
			type = 'dropdown',
			name = L.General_ProminentList,
			tooltip = L.General_ProminentListTip,
			choices = dropProminentAuras,
			sort = 'name-down',
			getFunc = function()
				prominentAurasSelectedAura = nil
				return dropProminentAuras[1]
			end,
			setFunc = function(v)
				prominentAurasSelectedAura = (v ~= '' and v ~= L.GenericSetting_ClickToViewAuras) and v or nil
			end,
			isProminentAurasWidget = true,
		},
		{
			type = 'button',
			name = L.General_ProminentRemove1,
			func = function(btn)
				if (prominentAurasSelectedAura) then
					if (string.find(prominentAurasSelectedAura, '%[%d+%]')) then -- this is a 'by abilityID' aura
						prominentAurasSelectedAura = string.match(prominentAurasSelectedAura, '%d+') -- correct user display to just abilityID
					end

					Srendarr:ProminentAuraRemove(prominentAurasSelectedAura)
					Srendarr.OnPlayerActivatedAlive()
				end

				Srendarr:PopulateProminentAurasDropdown()
			end,
		},
		-- -----------------------
		-- PROMINENT BUFFS 2
		-- -----------------------
		{
			type = 'header',
		},

		{
			type = 'dropdown',
			name = L.Group_Prominent2,
			tooltip = strformat('%s\n\n%s', L.General_ControlBaseTip, L.General_ControlProminentTip),
			choices = dropGroup,
			getFunc = function()
				-- just handle a special case with the 'dont display' setting internally being 0 and the settings menu wanting a >1 number
				return dropGroup[((Srendarr.db.auraGroups[GROUP_PROMINENT2] == 0) and 9 or Srendarr.db.auraGroups[GROUP_PROMINENT2])]
			end,
			setFunc = function(v)
				Srendarr.db.auraGroups[GROUP_PROMINENT2] = dropGroupRef[v]
				Srendarr:ConfigureAuraHandler()

				if (sampleAurasActive) then
					ShowSampleAuras() -- sample auras calls OnPlayerActivatedAlive as well
				else
					Srendarr.OnPlayerActivatedAlive()
				end
			end,
		},
		{
			type = 'editbox',
			name = L.General_ProminentAdd,
			tooltip = L.General_ProminentAddTip,
			warning = L.General_ProminentAddWarn,
			getFunc = function ()
				return ''
			end,
			setFunc = function(v)
				if (v ~= '') then
					Srendarr:ProminentAuraAdd2(v)
					Srendarr.OnPlayerActivatedAlive()
				end

				Srendarr:PopulateProminentAurasDropdown2()
			end,
			isMultiline = false,
		},
		{
			type = 'dropdown',
			name = L.General_ProminentList,
			tooltip = L.General_ProminentListTip,
			choices = dropProminentAuras2,
			sort = 'name-down',
			getFunc = function()
				prominentAurasSelectedAura2 = nil
				return dropProminentAuras2[1]
			end,
			setFunc = function(v)
				prominentAurasSelectedAura2 = (v ~= '' and v ~= L.GenericSetting_ClickToViewAuras) and v or nil
			end,
			isProminentAurasWidget2 = true,
		},
		{
			type = 'button',
			name = L.General_ProminentRemove2,
			func = function(btn)
				if (prominentAurasSelectedAura2) then
					if (string.find(prominentAurasSelectedAura2, '%[%d+%]')) then -- this is a 'by abilityID' aura
						prominentAurasSelectedAura2 = string.match(prominentAurasSelectedAura2, '%d+') -- correct user display to just abilityID
					end

					Srendarr:ProminentAuraRemove2(prominentAurasSelectedAura2)
					Srendarr.OnPlayerActivatedAlive()
				end

				Srendarr:PopulateProminentAurasDropdown2()
			end,
		},
		-- -----------------------
		-- FILTERS FOR PLAYER
		-- -----------------------
		{
			type = 'header',
			name = L.Filter_PlayerHeader,
		},
		{
			type = 'description',
			text = L.Filter_Desc,
		},
		{
			type = 'checkbox',
			name = L.Filter_Block,
			tooltip = L.Filter_BlockPlayerTip,
			getFunc = function()
				return Srendarr.db.filtersPlayer.block
			end,
			setFunc = function(v)
				Srendarr.db.filtersPlayer.block = v
				Srendarr:PopulateFilteredAuras()
				Srendarr.OnPlayerActivatedAlive()
			end,
		},
		{
			type = 'checkbox',
			name = L.Filter_Cyrodiil,
			tooltip = L.Filter_CyrodiilPlayerTip,
			getFunc = function()
				return Srendarr.db.filtersPlayer.cyrodiil
			end,
			setFunc = function(v)
				Srendarr.db.filtersPlayer.cyrodiil = v
				Srendarr:PopulateFilteredAuras()
				Srendarr.OnPlayerActivatedAlive()
			end,
		},
		{
			type = 'checkbox',
			name = L.Filter_Disguise,
			tooltip = L.Filter_DisguisePlayerTip,
			getFunc = function()
				return Srendarr.db.filtersPlayer.disguise
			end,
			setFunc = function(v)
				Srendarr.db.filtersPlayer.disguise = v
				Srendarr:PopulateFilteredAuras()
				Srendarr.OnPlayerActivatedAlive()
			end,
		},
		{
			type = 'checkbox',
			name = L.Filter_MundusBoon,
			tooltip = L.Filter_MundusBoonPlayerTip,
			getFunc = function()
				return Srendarr.db.filtersPlayer.mundusBoon
			end,
			setFunc = function(v)
				Srendarr.db.filtersPlayer.mundusBoon = v
				Srendarr:PopulateFilteredAuras()
				Srendarr.OnPlayerActivatedAlive()
			end,
		},
		{
			type = 'checkbox',
			name = L.Filter_SoulSummons,
			tooltip = L.Filter_SoulSummonsPlayerTip,
			getFunc = function()
				return Srendarr.db.filtersPlayer.soulSummons
			end,
			setFunc = function(v)
				Srendarr.db.filtersPlayer.soulSummons = v
				Srendarr:PopulateFilteredAuras()
				Srendarr.OnPlayerActivatedAlive()
			end,
		},
		{
			type = 'checkbox',
			name = L.Filter_VampLycan,
			tooltip = L.Filter_VampLycanPlayerTip,
			getFunc = function()
				return Srendarr.db.filtersPlayer.vampLycan
			end,
			setFunc = function(v)
				Srendarr.db.filtersPlayer.vampLycan = v
				Srendarr:PopulateFilteredAuras()
				Srendarr.OnPlayerActivatedAlive()
			end,
		},
		{
			type = 'checkbox',
			name = L.Filter_VampLycanBite,
			tooltip = L.Filter_VampLycanBitePlayerTip,
			getFunc = function()
				return Srendarr.db.filtersPlayer.vampLycanBite
			end,
			setFunc = function(v)
				Srendarr.db.filtersPlayer.vampLycanBite = v
				Srendarr:PopulateFilteredAuras()
				Srendarr.OnPlayerActivatedAlive()
			end,
		},
		-- -----------------------
		-- FILTERS FOR TARGET
		-- -----------------------
		{
			type = 'header',
			name = L.Filter_TargetHeader,
		},
		{
			type = 'description',
			text = L.Filter_Desc,
		},
		{
			type = 'checkbox',
			name = L.Filter_Block,
			tooltip = L.Filter_BlockTargetTip,
			getFunc = function()
				return Srendarr.db.filtersTarget.block
			end,
			setFunc = function(v)
				Srendarr.db.filtersTarget.block = v
				Srendarr:PopulateFilteredAuras()
			end,
		},
		{
			type = 'checkbox',
			name = L.Filter_Cyrodiil,
			tooltip = L.Filter_CyrodiilTargetTip,
			getFunc = function()
				return Srendarr.db.filtersTarget.cyrodiil
			end,
			setFunc = function(v)
				Srendarr.db.filtersTarget.cyrodiil = v
				Srendarr:PopulateFilteredAuras()
			end,
		},
		{
			type = 'checkbox',
			name = L.Filter_Disguise,
			tooltip = L.Filter_DisguiseTargetTip,
			getFunc = function()
				return Srendarr.db.filtersTarget.disguise
			end,
			setFunc = function(v)
				Srendarr.db.filtersTarget.disguise = v
				Srendarr:PopulateFilteredAuras()
			end,
		},
		{
			type = 'checkbox',
			name = L.Filter_MajorEffects,
			tooltip = L.Filter_MajorEffectsTargetTip,
			getFunc = function()
				return Srendarr.db.filtersTarget.majorEffects
			end,
			setFunc = function(v)
				Srendarr.db.filtersTarget.majorEffects = v
				Srendarr:PopulateFilteredAuras()
			end,
		},
		{
			type = 'checkbox',
			name = L.Filter_MinorEffects,
			tooltip = L.Filter_MinorEffectsTargetTip,
			getFunc = function()
				return Srendarr.db.filtersTarget.minorEffects
			end,
			setFunc = function(v)
				Srendarr.db.filtersTarget.minorEffects = v
				Srendarr:PopulateFilteredAuras()
			end,
		},
		{
			type = 'checkbox',
			name = L.Filter_MundusBoon,
			tooltip = L.Filter_MundusBoonTargetTip,
			getFunc = function()
				return Srendarr.db.filtersTarget.mundusBoon
			end,
			setFunc = function(v)
				Srendarr.db.filtersTarget.mundusBoon = v
				Srendarr:PopulateFilteredAuras()
			end,
		},
		{
			type = 'checkbox',
			name = L.Filter_SoulSummons,
			tooltip = L.Filter_SoulSummonsTargetTip,
			getFunc = function()
				return Srendarr.db.filtersTarget.soulSummons
			end,
			setFunc = function(v)
				Srendarr.db.filtersTarget.soulSummons = v
				Srendarr:PopulateFilteredAuras()
			end,
		},
		{
			type = 'checkbox',
			name = L.Filter_VampLycan,
			tooltip = L.Filter_VampLycanTargetTip,
			getFunc = function()
				return Srendarr.db.filtersTarget.vampLycan
			end,
			setFunc = function(v)
				Srendarr.db.filtersTarget.vampLycan = v
				Srendarr:PopulateFilteredAuras()
			end,
		},
		{
			type = 'checkbox',
			name = L.Filter_VampLycanBite,
			tooltip = L.Filter_VampLycanBiteTargetTip,
			getFunc = function()
				return Srendarr.db.filtersTarget.vampLycanBite
			end,
			setFunc = function(v)
				Srendarr.db.filtersTarget.vampLycanBite = v
				Srendarr:PopulateFilteredAuras()
			end,
		},
	},
	-- -----------------------
	-- CAST BAR SETTINGS
	-- -----------------------
	[3] = {
		{
			type = 'checkbox',
			name = L.CastBar_Enable,
			tooltip = L.CastBar_EnableTip,
			getFunc = function()
				return Srendarr.db.castBar.enabled
			end,
			setFunc = function(v)
				Srendarr.db.castBar.enabled = v
				Srendarr:ConfigureCastBar()
			end,
		},
		{
			type = 'slider',
			name = L.CastBar_Alpha,
			tooltip = L.CastBar_AlphaTip,
			min = 5,
			max = 100,
			step = 5,
			getFunc = function()
				return Srendarr.db.castBar.base.alpha * 100
			end,
			setFunc = function(v)
				Srendarr.db.castBar.base.alpha = v / 100
				Srendarr.Cast:SetAlpha(v / 100)
			end,
		},
		{
			type = 'slider',
			name = L.CastBar_Scale,
			tooltip = L.CastBar_ScaleTip,
			min = 50,
			max = 150,
			step = 5,
			getFunc = function()
				return Srendarr.db.castBar.base.scale * 100
			end,
			setFunc = function(v)
				Srendarr.db.castBar.base.scale = v / 100
				Srendarr.Cast:SetScale(v / 100)
			end,
		},
		-- -----------------------
		-- CASTED ABILITY TEXT SETTINGS
		-- -----------------------
		{
			type = 'header',
			name = L.CastBar_NameHeader,
		},
		{
			type = 'checkbox',
			name = L.CastBar_NameShow,
			getFunc = function()
				return Srendarr.db.castBar.nameShow
			end,
			setFunc = function(v)
				Srendarr.db.castBar.nameShow = v
				Srendarr:ConfigureCastBar()
			end,
		},
		{
			type = 'dropdown',
			name = L.GenericSetting_NameFont,
			choices = LMP:List('font'),
			getFunc = function()
				return Srendarr.db.castBar.nameFont
			end,
			setFunc = function(v)
				Srendarr.db.castBar.nameFont = v
				Srendarr:ConfigureCastBar()
			end,
		},
		{
			type = 'dropdown',
			name = L.GenericSetting_NameStyle,
			choices = dropFontStyle,
			getFunc = function()
				return Srendarr.db.castBar.nameStyle
			end,
			setFunc = function(v)
				Srendarr.db.castBar.nameStyle = v
				Srendarr:ConfigureCastBar()
			end,
		},
		{
			type = 'colorpicker',
			getFunc = function()
				return unpack(Srendarr.db.castBar.nameColour)
			end,
			setFunc = function(r, g, b, a)
				Srendarr.db.castBar.nameColour[1] = r
				Srendarr.db.castBar.nameColour[2] = g
				Srendarr.db.castBar.nameColour[3] = b
				Srendarr.db.castBar.nameColour[4] = a
				Srendarr:ConfigureCastBar()
			end,
			widgetRightAlign		= true,
			widgetPositionAndResize	= -15,
		},
		{
			type = 'slider',
			name = L.GenericSetting_NameSize,
			min = 8,
			max = 32,
			getFunc = function()
				return Srendarr.db.castBar.nameSize
			end,
			setFunc = function(v)
				Srendarr.db.castBar.nameSize = v
				Srendarr:ConfigureCastBar()
			end,
		},
		-- -----------------------
		-- CAST TIMER TEXT SETTINGS
		-- -----------------------
		{
			type = 'header',
			name = L.CastBar_TimerHeader,
		},
		{
			type = 'checkbox',
			name = L.CastBar_TimerShow,
			getFunc = function()
				return Srendarr.db.castBar.timerShow
			end,
			setFunc = function(v)
				Srendarr.db.castBar.timerShow = v
				Srendarr:ConfigureCastBar()
			end,
		},
		{
			type = 'dropdown',
			name = L.GenericSetting_TimerFont,
			choices = LMP:List('font'),
			getFunc = function()
				return Srendarr.db.castBar.timerFont
			end,
			setFunc = function(v)
				Srendarr.db.castBar.timerFont = v
				Srendarr:ConfigureCastBar()
			end,
		},
		{
			type = 'dropdown',
			name = L.GenericSetting_TimerStyle,
			choices = dropFontStyle,
			getFunc = function()
				return Srendarr.db.castBar.timerStyle
			end,
			setFunc = function(v)
				Srendarr.db.castBar.timerStyle = v
				Srendarr:ConfigureCastBar()
			end,
		},
		{
			type = 'colorpicker',
			getFunc = function()
				return unpack(Srendarr.db.castBar.timerColour)
			end,
			setFunc = function(r, g, b, a)
				Srendarr.db.castBar.timerColour[1] = r
				Srendarr.db.castBar.timerColour[2] = g
				Srendarr.db.castBar.timerColour[3] = b
				Srendarr.db.castBar.timerColour[4] = a
				Srendarr:ConfigureCastBar()
			end,
			widgetRightAlign		= true,
			widgetPositionAndResize	= -15,
		},
		{
			type = 'slider',
			name = L.GenericSetting_TimerSize,
			min = 8,
			max = 32,
			getFunc = function()
				return Srendarr.db.castBar.timerSize
			end,
			setFunc = function(v)
				Srendarr.db.castBar.timerSize = v
				Srendarr:ConfigureCastBar()
			end,
		},
		-- -----------------------
		-- STATUSBAR SETTINGS
		-- -----------------------
		{
			type = 'header',
			name = L.CastBar_BarHeader,
		},
		{
			type = 'checkbox',
			name = L.CastBar_BarReverse,
			tooltip = L.CastBar_BarReverseTip,
			getFunc = function()
				return Srendarr.db.castBar.barReverse
			end,
			setFunc = function(v)
				Srendarr.db.castBar.barReverse = v
				Srendarr:ConfigureCastBar()
			end,
		},
		{
			type = 'checkbox',
			name = L.CastBar_BarGloss,
			tooltip = L.CastBar_BarGlossTip,
			getFunc = function()
				return Srendarr.db.castBar.barGloss
			end,
			setFunc = function(v)
				Srendarr.db.castBar.barGloss = v
				Srendarr:ConfigureCastBar()
			end,
		},
		{
			type = 'slider',
			name = L.CastBar_BarWidth,
			tooltip = L.CastBar_BarWidthTip,
			min = 200,
			max = 400,
			step = 5,
			getFunc = function()
				return Srendarr.db.castBar.barWidth
			end,
			setFunc = function(v)
				Srendarr.db.castBar.barWidth = v
				Srendarr:ConfigureCastBar()
			end,
		},
		{
			type = 'colorpicker',
			name = L.CastBar_BarColour,
			tooltip = L.CastBar_BarColourTip,
			getFunc = function()
				local colours = Srendarr.db.castBar.barColour
				return colours.r2, colours.g2, colours.b2
			end,
			setFunc = function(r, g, b)
				Srendarr.db.castBar.barColour.r2 = r
				Srendarr.db.castBar.barColour.g2 = g
				Srendarr.db.castBar.barColour.b2 = b
				Srendarr:ConfigureCastBar()
			end,
			widgetRightAlign		= true,
		},
		{
			type = 'colorpicker',
			tooltip = L.CastBar_BarColourTip,
			getFunc = function()
				local colours = Srendarr.db.castBar.barColour
				return colours.r1, colours.g1, colours.b1
			end,
			setFunc = function(r, g, b)
				Srendarr.db.castBar.barColour.r1 = r
				Srendarr.db.castBar.barColour.g1 = g
				Srendarr.db.castBar.barColour.b1 = b
				Srendarr:ConfigureCastBar()
			end,
			widgetRightAlign		= true,
			widgetPositionAndResize	= 127,
		},
	},
	-- -----------------------
	-- PROFILE SETTINGS
	-- -----------------------
	[5] = {
		[1] = {
			type = 'description',
			text = L.Profile_Desc
		},
		[2] = {
			type = 'checkbox',
			name = L.Profile_UseGlobal,
			warning = L.Profile_UseGlobalWarn,
			getFunc = function()
				return SrendarrDB.Default[GetDisplayName()]['$AccountWide'].useAccountWide
			end,
			setFunc = function(v)
				SrendarrDB.Default[GetDisplayName()]['$AccountWide'].useAccountWide = v
				ReloadUI()
			end,
			disabled = function()
				return not profileGuard
			end
		},
		[3] = {
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
		[4] = {
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
		[5] = {
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
		[6] = {
			type = 'button',
			name = L.Profile_DeleteButton,
			func = function(btn)
				DeleteProfile()
			end,
			disabled = function()
				return not profileGuard
			end
		},
		[7] = {
			type = 'description'
		},
		[8] = {
			type = 'header'
		},
		[9] = {
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
	-- -----------------------
	-- DISPLAY FRAME SETTINGS
	-- -----------------------
	[10] = {
		{
			type = 'slider',
			name = L.DisplayFrame_Alpha,
			tooltip = L.DisplayFrame_AlphaTip,
			min = 5,
			max = 100,
			step = 5,
			getFunc = function()
				return displayDB[currentDisplayFrame].base.alpha * 100
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].base.alpha = v / 100
				Srendarr.displayFrames[currentDisplayFrame]:SetAlpha(v / 100)
				Srendarr.displayFrames[currentDisplayFrame].displayAlpha = v / 100
			end,
		},
		{
			type = 'slider',
			name = L.DisplayFrame_Scale,
			tooltip = L.DisplayFrame_ScaleTip,
			min = 50,
			max = 150,
			step = 5,
			getFunc = function()
				return displayDB[currentDisplayFrame].base.scale * 100
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].base.scale = v / 100
				Srendarr.displayFrames[currentDisplayFrame]:SetScale(v / 100)
			end,
		},
		-- -----------------------
		-- AURA DISPLAY SETTINGS
		-- -----------------------
		{
			type = 'header',
			name = L.DisplayFrame_AuraHeader,
		},
		{
			type = 'dropdown',
			name = L.DisplayFrame_Style,
			tooltip = L.DisplayFrame_StyleTip,
			choices = dropStyle,
			getFunc = function()
				return dropStyle[displayDB[currentDisplayFrame].style]
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].style = dropStyleRef[v]

				OnStyleChange(dropStyleRef[v]) -- update several options dependent on current style

				ConfigurePanelDisplayFrame(true) -- changing this changes a lot of the following options
			end,
		},
		{						-- auraGrowth					FULL, MINI
			type = 'dropdown',
			name = L.DisplayFrame_Growth,
			tooltip = L.DisplayFrame_GrowthTip,
			choices = dropGrowthFullMini,
			getFunc = function()
				return dropGrowthFullMini[displayDB[currentDisplayFrame].auraGrowth]
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].auraGrowth = dropGrowthRef[v]
				Srendarr.displayFrames[currentDisplayFrame]:Configure()
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureDragOverlay()
				Srendarr.displayFrames[currentDisplayFrame]:UpdateDisplay()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = false}
		},
		{						-- auraGrowth 					ICON
			type = 'dropdown',
			name = L.DisplayFrame_Growth,
			tooltip = L.DisplayFrame_GrowthTip,
			choices = dropGrowthIcon,
			getFunc = function()
				return dropGrowthIcon[displayDB[currentDisplayFrame].auraGrowth]
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].auraGrowth = dropGrowthRef[v]
				Srendarr.displayFrames[currentDisplayFrame]:Configure()
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureDragOverlay()
				Srendarr.displayFrames[currentDisplayFrame]:UpdateDisplay()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = true, [AURA_STYLE_ICON] = false, [AURA_STYLE_MINI] = true}
		},
		{						-- auraPadding					FULL, ICON, MINI
			type = 'slider',
			name = L.DisplayFrame_Padding,
			tooltip = L.DisplayFrame_PaddingTip,
			min = -25,
			max = 75,
			getFunc = function()
				return displayDB[currentDisplayFrame].auraPadding
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].auraPadding = v
				Srendarr.displayFrames[currentDisplayFrame]:Configure()
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureDragOverlay()
				Srendarr.displayFrames[currentDisplayFrame]:UpdateDisplay()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = false, [AURA_STYLE_MINI] = false}
		},
		{						-- auraSort						FULL, ICON, MINI
			type = 'dropdown',
			name = L.DisplayFrame_Sort,
			tooltip = L.DisplayFrame_SortTip,
			choices = dropSort,
			sort = 'name-up',
			getFunc = function()
				return dropSort[displayDB[currentDisplayFrame].auraSort]
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].auraSort = dropSortRef[v]
				Srendarr.displayFrames[currentDisplayFrame]:Configure()
				Srendarr.displayFrames[currentDisplayFrame]:UpdateDisplay()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = false, [AURA_STYLE_MINI] = false}
		},
		{						-- highlightToggled				FULL, ICON
			type = 'checkbox',
			name = L.DisplayFrame_Highlight,
			tooltip = L.DisplayFrame_HighlightTip,
			getFunc = function()
				return displayDB[currentDisplayFrame].highlightToggled
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].highlightToggled = v
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = false, [AURA_STYLE_MINI] = true}
		},
		{						-- enableTooltips				ICON
			type = 'checkbox',
			name = L.DisplayFrame_Tooltips,
			tooltip = L.DisplayFrame_TooltipsTip,
			warning = L.DisplayFrame_TooltipsWarn,
			getFunc = function()
				return displayDB[currentDisplayFrame].enableTooltips
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].enableTooltips = v
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = true, [AURA_STYLE_ICON] = false, [AURA_STYLE_MINI] = true}
		},
		-- -----------------------
		-- ABILITY TEXT SETTINGS
		-- -----------------------
		{					-- nameHeader					FULL, MINI
			type = 'header',
			name = L.DisplayFrame_NameHeader,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = false}
		},
		{					-- nameFont						FULL, MINI
			type = 'dropdown',
			name = L.GenericSetting_NameFont,
			choices = LMP:List('font'),
			getFunc = function()
				return displayDB[currentDisplayFrame].nameFont
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].nameFont = v
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = false}
		},
		{					-- nameStyle					FULL, MINI
			type = 'dropdown',
			name = L.GenericSetting_NameStyle,
			choices = dropFontStyle,
			getFunc = function()
				return displayDB[currentDisplayFrame].nameStyle
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].nameStyle = v
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = false}
		},
		{					-- nameColour					FULL, MINI
			type = 'colorpicker',
			getFunc = function()
				return unpack(displayDB[currentDisplayFrame].nameColour)
			end,
			setFunc = function(r, g, b, a)
				displayDB[currentDisplayFrame].nameColour[1] = r
				displayDB[currentDisplayFrame].nameColour[2] = g
				displayDB[currentDisplayFrame].nameColour[3] = b
				displayDB[currentDisplayFrame].nameColour[4] = a
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			widgetRightAlign		= true,
			widgetPositionAndResize	= -15,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = false}
		},
		{					-- nameSize						FULL, MINI
			type = 'slider',
			name = L.GenericSetting_NameSize,
			min = 8,
			max = 32,
			getFunc = function()
				return displayDB[currentDisplayFrame].nameSize
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].nameSize = v
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = false}
		},
		-- -----------------------
		-- TIMER TEXT SETTINGS
		-- -----------------------
		{					-- timerHeader					FULL, ICON, MINI
			type = 'header',
			name = L.DisplayFrame_TimerHeader,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = false, [AURA_STYLE_MINI] = false}
		},
		{					-- timerFont					FULL, ICON, MINI
			type = 'dropdown',
			name = L.GenericSetting_TimerFont,
			choices = LMP:List('font'),
			getFunc = function()
				return displayDB[currentDisplayFrame].timerFont
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].timerFont = v
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = false, [AURA_STYLE_MINI] = false}
		},
		{					-- timerStyle					FULL, ICON, MINI
			type = 'dropdown',
			name = L.GenericSetting_TimerStyle,
			choices = dropFontStyle,
			getFunc = function()
				return displayDB[currentDisplayFrame].timerStyle
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].timerStyle = v
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = false, [AURA_STYLE_MINI] = false}
		},
		{					-- timerColour					FULL, ICON, MINI
			type = 'colorpicker',
			getFunc = function()
				return unpack(displayDB[currentDisplayFrame].timerColour)
			end,
			setFunc = function(r, g, b, a)
				displayDB[currentDisplayFrame].timerColour[1] = r
				displayDB[currentDisplayFrame].timerColour[2] = g
				displayDB[currentDisplayFrame].timerColour[3] = b
				displayDB[currentDisplayFrame].timerColour[4] = a
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			widgetRightAlign		= true,
			widgetPositionAndResize	= -15,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = false, [AURA_STYLE_MINI] = false}
		},
		{					-- timerSize					FULL, ICON, MINI
			type = 'slider',
			name = L.GenericSetting_TimerSize,
			min = 8,
			max = 32,
			getFunc = function()
				return displayDB[currentDisplayFrame].timerSize
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].timerSize = v
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = false, [AURA_STYLE_MINI] = false}
		},
		{					-- timerLocation				FULL
			type = 'dropdown',
			name = L.DisplayFrame_TimerLocation,
			tooltip = L.DisplayFrame_TimerLocationTip,
			choices = dropTimerFull,
			getFunc = function()
				return dropTimerFull[displayDB[currentDisplayFrame].timerLocation]
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].timerLocation = dropTimerRef[v]
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = true}
		},
		{					-- timerLocation				ICON
			type = 'dropdown',
			name = L.DisplayFrame_TimerLocation,
			tooltip = L.DisplayFrame_TimerLocationTip,
			choices = dropTimerIcon,
			getFunc = function()
				return dropTimerIcon[displayDB[currentDisplayFrame].timerLocation]
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].timerLocation = dropTimerRef[v]
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = true, [AURA_STYLE_ICON] = false, [AURA_STYLE_MINI] = true}
		},
		{					-- timerHMS						FULL, ICON, MINI
			type = 'checkbox',
			name = L.DisplayFrame_TimerHMS,
			tooltip = L.DisplayFrame_TimerHMSTip,
			getFunc = function()
				return displayDB[currentDisplayFrame].timerHMS
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].timerHMS = v
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = false, [AURA_STYLE_MINI] = false}
		},
		-- -----------------------
		-- STATUSBAR SETTINGS
		-- -----------------------
		{					-- barHeader					FULL, MINI
			type = 'header',
			name = L.DisplayFrame_BarHeader,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = false}
		},
		{					-- barReverse					FULL, MINI
			type = 'checkbox',
			name = L.DisplayFrame_BarReverse,
			tooltip = L.DisplayFrame_BarReverseTip,
			getFunc = function()
				return displayDB[currentDisplayFrame].barReverse
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].barReverse = v
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureDragOverlay()
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = false}
		},
		{					-- barGloss						FULL, MINI
			type = 'checkbox',
			name = L.DisplayFrame_BarGloss,
			tooltip = L.DisplayFrame_BarGlossTip,
			getFunc = function()
				return displayDB[currentDisplayFrame].barGloss
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].barGloss = v
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = false}
		},
		{					-- barWidth						FULL, MINI
			type = 'slider',
			name = L.DisplayFrame_BarWidth,
			tooltip = L.DisplayFrame_BarWidthTip,
			min = 40,
			max = 240,
			step = 5,
			getFunc = function()
				return displayDB[currentDisplayFrame].barWidth
			end,
			setFunc = function(v)
				displayDB[currentDisplayFrame].barWidth = v
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureDragOverlay()
			end,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = false}
		},
		{					-- barColour[TIMED]:2			FULL, MINI
			type = 'colorpicker',
			name = L.DisplayFrame_BarTimed,
			tooltip = L.DisplayFrame_BarTimedTip,
			getFunc = function()
				local colours = displayDB[currentDisplayFrame].barColours[AURA_TYPE_TIMED]
				return colours.r2, colours.g2, colours.b2
			end,
			setFunc = function(r, g, b)
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_TIMED].r2 = r
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_TIMED].g2 = g
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_TIMED].b2 = b
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			widgetRightAlign		= true,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = false}
		},
		{					-- barColour[TIMED]:1			FULL, MINI
			type = 'colorpicker',
			tooltip = L.DisplayFrame_BarTimedTip,
			getFunc = function()
				local colours = displayDB[currentDisplayFrame].barColours[AURA_TYPE_TIMED]
				return colours.r1, colours.g1, colours.b1
			end,
			setFunc = function(r, g, b)
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_TIMED].r1 = r
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_TIMED].g1 = g
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_TIMED].b1 = b
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			widgetRightAlign		= true,
			widgetPositionAndResize	= 127,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = false}
		},
		{					-- barColour[TOGGLED]:2			FULL, MINI
			type = 'colorpicker',
			name = L.DisplayFrame_BarToggled,
			tooltip = L.DisplayFrame_BarToggledTip,
			getFunc = function()
				local colours = displayDB[currentDisplayFrame].barColours[AURA_TYPE_TOGGLED]
				return colours.r2, colours.g2, colours.b2
			end,
			setFunc = function(r, g, b)
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_TOGGLED].r2 = r
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_TOGGLED].g2 = g
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_TOGGLED].b2 = b
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			widgetRightAlign		= true,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = false}
		},
		{					-- barColour[TOGGLED]:1			FULL, MINI
			type = 'colorpicker',
			tooltip = L.DisplayFrame_BarToggledTip,
			getFunc = function()
				local colours = displayDB[currentDisplayFrame].barColours[AURA_TYPE_TOGGLED]
				return colours.r1, colours.g1, colours.b1
			end,
			setFunc = function(r, g, b)
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_TOGGLED].r1 = r
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_TOGGLED].g1 = g
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_TOGGLED].b1 = b
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			widgetRightAlign		= true,
			widgetPositionAndResize	= 127,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = false}
		},
		{					-- barColour[PASSIVE]:2			FULL, MINI
			type = 'colorpicker',
			name = L.DisplayFrame_BarPassive,
			tooltip = L.DisplayFrame_BarPassiveTip,
			getFunc = function()
				local colours = displayDB[currentDisplayFrame].barColours[AURA_TYPE_PASSIVE]
				return colours.r2, colours.g2, colours.b2
			end,
			setFunc = function(r, g, b)
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_PASSIVE].r2 = r
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_PASSIVE].g2 = g
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_PASSIVE].b2 = b
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			widgetRightAlign		= true,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = false}
		},
		{					-- barColour[PASSIVE]:1			FULL, MINI
			type = 'colorpicker',
			tooltip = L.DisplayFrame_BarPassiveTip,
			getFunc = function()
				local colours = displayDB[currentDisplayFrame].barColours[AURA_TYPE_PASSIVE]
				return colours.r1, colours.g1, colours.b1
			end,
			setFunc = function(r, g, b)
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_PASSIVE].r1 = r
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_PASSIVE].g1 = g
				displayDB[currentDisplayFrame].barColours[AURA_TYPE_PASSIVE].b1 = b
				Srendarr.displayFrames[currentDisplayFrame]:ConfigureAssignedAuras()
			end,
			widgetRightAlign		= true,
			widgetPositionAndResize	= 127,
			hideOnStyle = {[AURA_STYLE_FULL] = false, [AURA_STYLE_ICON] = true, [AURA_STYLE_MINI] = false}
		},
	}
}
