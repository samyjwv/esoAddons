local addon = {
	name = "VotansImprovedLocations",
	allianceOrder =
	{
		[ALLIANCE_DAGGERFALL_COVENANT] =
		{
			[ALLIANCE_DAGGERFALL_COVENANT] = 1,
			[ALLIANCE_ALDMERI_DOMINION] = 2,
			[ALLIANCE_EBONHEART_PACT] = 3,
			[100] = 100,
			[999] = 999,
		},
		[ALLIANCE_ALDMERI_DOMINION] =
		{
			[ALLIANCE_ALDMERI_DOMINION] = 1,
			[ALLIANCE_EBONHEART_PACT] = 2,
			[ALLIANCE_DAGGERFALL_COVENANT] = 3,
			[100] = 100,
			[999] = 999,
		},
		[ALLIANCE_EBONHEART_PACT] =
		{
			[ALLIANCE_EBONHEART_PACT] = 1,
			[ALLIANCE_DAGGERFALL_COVENANT] = 2,
			[ALLIANCE_ALDMERI_DOMINION] = 3,
			[100] = 100,
			[999] = 999,
		},
	},
	-- Thanks to Enodoc
	levels =
	{
		-- difficulty
		{
			{ 4, 6 },
			{ 3, 15 },
			{ 16, 23 },
			{ 24, 31 },
			{ 31, 37 },
			{ 37, 43 },
		},
		{
			{ 90, 90 },
			{ 90, 90 },
			{ 120, 120 },
			{ 150, 150 },
			{ 180, 180 },
			{ 200, 200 },
		},
		{
			{ 210, 210 },
			{ 210, 210 },
			{ 210, 210 },
			{ 210, 210 },
			{ 210, 210 },
			{ 210, 210 },
		},
	},
	locations =
	{
		-- [1] =
		{
			-- "Tamriel",
			alliance = 999,
			zoneIndex = 0,
		},
		-- [2] =
		{
			-- "Glenumbra",
			alliance = ALLIANCE_DAGGERFALL_COVENANT,
			zoneIndex = 2,
			zoneOrder = 2,
		},
		-- [3] =
		{
			-- "Kluftspitze",
			alliance = ALLIANCE_DAGGERFALL_COVENANT,
			zoneIndex = 5,
			zoneOrder = 4,
		},
		-- [4] =
		{
			-- "Sturmhafen",
			alliance = ALLIANCE_DAGGERFALL_COVENANT,
			zoneIndex = 4,
			zoneOrder = 3,
		},
		-- [5] =
		{
			-- "Alik'r-Wüste",
			alliance = ALLIANCE_DAGGERFALL_COVENANT,
			zoneIndex = 17,
			zoneOrder = 5,
		},
		-- [6] =
		{
			-- "Bangkorai",
			alliance = ALLIANCE_DAGGERFALL_COVENANT,
			zoneIndex = 14,
			zoneOrder = 6,
		},
		-- [7] =
		{
			-- "Grahtwald",
			alliance = ALLIANCE_ALDMERI_DOMINION,
			zoneIndex = 180,
			zoneOrder = 3,
		},
		-- [8] =
		{
			-- "Malabal Tor",
			alliance = ALLIANCE_ALDMERI_DOMINION,
			zoneIndex = 11,
			zoneOrder = 5,
		},
		-- [9] =
		{
			-- "Schattenfenn",
			alliance = ALLIANCE_EBONHEART_PACT,
			zoneIndex = 19,
			zoneOrder = 4,
		},
		-- [10] =
		{
			-- "Deshaan",
			alliance = ALLIANCE_EBONHEART_PACT,
			zoneIndex = 10,
			zoneOrder = 3,
		},
		-- [11] =
		{
			-- "Steinfälle",
			alliance = ALLIANCE_EBONHEART_PACT,
			zoneIndex = 9,
			zoneOrder = 2,
		},
		-- [12] =
		{
			-- "Rift",
			alliance = ALLIANCE_EBONHEART_PACT,
			zoneIndex = 16,
			zoneOrder = 6,
		},
		-- [13] =
		{
			-- "Ostmarsch",
			alliance = ALLIANCE_EBONHEART_PACT,
			zoneIndex = 15,
			zoneOrder = 5,
		},
		-- [14] =
		{
			-- "Cyrodiil",
			alliance = 100,
			zoneIndex = 37,
		},
		-- [15] =
		{
			-- "Auridon",
			alliance = ALLIANCE_ALDMERI_DOMINION,
			zoneIndex = 178,
			zoneOrder = 2,
		},
		-- [16] =
		{
			-- "Grünschatten",
			alliance = ALLIANCE_ALDMERI_DOMINION,
			zoneIndex = 18,
			zoneOrder = 4,
		},
		-- [17] =
		{
			-- "Schnittermark",
			alliance = ALLIANCE_ALDMERI_DOMINION,
			zoneIndex = 179,
			zoneOrder = 6,
		},
		-- [18] =
		{
			-- "Bal Foyen",
			alliance = ALLIANCE_EBONHEART_PACT,
			zoneIndex = 110,
			zoneOrder = 1,
		},
		-- [19] =
		{
			-- "Stros M'Kai",
			alliance = ALLIANCE_DAGGERFALL_COVENANT,
			zoneIndex = 292,
			zoneOrder = 1,
		},
		-- [20] =
		{
			-- "Betnikh",
			alliance = ALLIANCE_DAGGERFALL_COVENANT,
			zoneIndex = 293,
			zoneOrder = 1,
		},
		-- [21] =
		{
			-- "Khenarthis Rast",
			alliance = ALLIANCE_ALDMERI_DOMINION,
			zoneIndex = 294,
			zoneOrder = 1,
		},
		-- [22] =
		{
			-- "Ödfels",
			alliance = ALLIANCE_EBONHEART_PACT,
			zoneIndex = 109,
			zoneOrder = 1,
		},
		-- [23] =
		{
			-- "Kalthafen",
			alliance = 100,
			zoneIndex = 154,
			zoneLevel = 7,
		},
		-- [24] =
		{
			-- "Aurbis",
			alliance = 999,
			zoneIndex = 0,
		},
		-- [25] =
		{
			-- "Kargstein",
			alliance = 100,
			zoneIndex = 353,
		},
		-- [26] =
		{
			-- "Kaiserstadt",
			alliance = 100,
			zoneIndex = 335,
		},
		-- [27] =
		{
			-- "Wrothgar",
			alliance = 100,
			zoneIndex = 396,
		},
		-- [28] =
		{
			-- "Abah's Landing",
			alliance = 100,
			zoneIndex = 513,
		},
		-- [29] =
		{
			-- "Gold Coast",
			alliance = 100,
			zoneIndex = 519,
		},
	},
}

local em = GetEventManager()
local am = GetAnimationManager()

local LOCATION_TYPE_ID = 2
local ALLIANCE_TYPE_ID = 3
local MAP_TYPE_ID = 4
local RECENT_TYPE_ID = 5

local headerColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
local selectedColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
local disabledColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED))

local SORT_LOCATION_NAME = "Name"
local SORT_LOCATION_LEVEL_ASC = "LevelAsc"
local SORT_LOCATION_LEVEL_DSC = "LevelDsc"

local SI_TOOLTIP_ITEM_NAME = GetString(SI_TOOLTIP_ITEM_NAME)

local function HideRowHighlight(rowControl, hidden, unselected)
	if not rowControl then return end
	if not ZO_ScrollList_GetData(rowControl) then return end

	local highlight = rowControl:GetNamedChild("Highlight")

	if highlight then
		if not highlight.animation then
			highlight.animation = am:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", highlight)
		end

		if highlight.animation:IsPlaying() then
			highlight.animation:Stop()
		end
		if unselected ~= false then
			highlight:SetTexture("esoui/art/miscellaneous/listitem_selectedhighlight.dds")
		else
			highlight:SetTexture("esoui/art/miscellaneous/listitem_highlight.dds")
		end
		if hidden and unselected ~= false then
			highlight.animation:PlayBackward()
		else
			highlight.animation:PlayForward()
		end
	end
end

function addon:ShowLevel(levelLabel, location)
	local function FormatLevel(allianceOrder, zoneOrder)
		if allianceOrder == 1 then
			return zo_iconFormatInheritColor("esoui/art/journal/journal_tabicon_cadwell_down.dds", 28, 28) .. zoneOrder
		elseif allianceOrder == 2 then
			return zo_iconFormatInheritColor("esoui/art/cadwell/cadwell_indexicon_silver_down.dds", 28, 28) .. zoneOrder
		elseif allianceOrder == 3 then
			return zo_iconFormatInheritColor("esoui/art/cadwell/cadwell_indexicon_gold_down.dds", 28, 28) .. zoneOrder
		else
			return zoneOrder
		end
	end

	if location and self.account.showLevels then
		if location.zoneOrder then
			levelLabel:SetText(FormatLevel(location.allianceOrder, location.zoneOrder))
		elseif location.zoneLevel then
			levelLabel:SetText(FormatLevel(1, location.zoneLevel))
		elseif location.mapContentType == MAP_CONTENT_AVA then
			levelLabel:SetText("|t23:23:/esoui/art/icons/mapkey/mapkey_keep.dds|t")
		else
			levelLabel:SetText("")
		end
		levelLabel:SetHidden(false)
	else
		levelLabel:SetText("")
		levelLabel:SetHidden(true)
	end
end

local function onMouseEnter(rowControl)
	HideRowHighlight(rowControl, false)
end

do
	local callback = { dataEntry = { data = { index = 1 } } }
	-- Fork functions called by original callback handler
	function callback:GetParent() return self end
	function callback:SetAnchor() end
	--
	function callback:PerformClick(index, button, upInside)
		self.dataEntry.data.index = index
		ZO_WorldMapLocationRowLocation_OnMouseUp(self, button, upInside)
	end

	function addon:SetupLocation(rowControl, rowData)
		local function onMouseExit(rowControl)
			local data = ZO_ScrollList_GetData(rowControl)
			HideRowHighlight(rowControl, true, WORLD_MAP_LOCATIONS.selectedMapIndex ~= data.index)
		end
		local function onMouseClick(rowControl, button, upInside)
			local data = ZO_ScrollList_GetData(rowControl)
			callback:PerformClick(data.index, button, upInside)
		end

		local listDisabled = WORLD_MAP_LOCATIONS:GetDisabled()
		local locationLabel = rowControl:GetNamedChild("Location")
		locationLabel:SetText(rowData.locationName)
		locationLabel:SetColor((listDisabled and disabledColor or selectedColor):UnpackRGB())

		local levelLabel = rowControl:GetNamedChild("Level")
		self:ShowLevel(levelLabel, self.locations[rowData.index])

		HideRowHighlight(rowControl, true, WORLD_MAP_LOCATIONS.selectedMapIndex ~= rowData.index)
		rowControl:SetMouseEnabled(not listDisabled)
		rowControl:SetHeight(25)
		rowControl:SetHandler("OnMouseEnter", onMouseEnter)
		rowControl:SetHandler("OnMouseExit", onMouseExit)
		rowControl:SetHandler("OnMouseUp", onMouseClick)
	end

	function addon:SetupRecentLocation(rowControl, rowData)
		local function onMouseExit(rowControl)
			HideRowHighlight(rowControl, true)
		end
		local function onMouseClick(rowControl, button, upInside)
			local rowData = ZO_ScrollList_GetData(rowControl)
			callback:PerformClick(self.player.recent[rowData.index], button, upInside)
		end

		local listDisabled = WORLD_MAP_LOCATIONS:GetDisabled()
		local locationLabel = rowControl:GetNamedChild("Location")
		local levelLabel = rowControl:GetNamedChild("Level")

		rowData = self.player.recent[rowData.index] or 0
		if rowData > 0 then
			local location = self.locations[rowData]

			locationLabel:SetText(location.locationName)
			rowControl:SetMouseEnabled(not listDisabled)

			local levelLabel = rowControl:GetNamedChild("Level")
			self:ShowLevel(levelLabel, location)
		else
			locationLabel:SetText("-")
			levelLabel:SetText("")
			rowControl:SetMouseEnabled(false)
		end

		locationLabel:SetColor((listDisabled and disabledColor or selectedColor):UnpackRGB())
		rowControl:SetHeight(25)
		rowControl:SetHandler("OnMouseEnter", onMouseEnter)
		rowControl:SetHandler("OnMouseExit", onMouseExit)
		rowControl:SetHandler("OnMouseUp", onMouseClick)
	end
end

function addon:SetupHeader(rowControl, rowData)
	local locationLabel = rowControl:GetNamedChild("Location")
	local texture = rowControl:GetNamedChild("Texture")

	texture:ClearAnchors()

	if rowData.alliance < 100 then
		locationLabel:SetText(zo_strformat(SI_ALLIANCE_NAME, GetAllianceName(rowData.alliance)))
		texture:SetTexture(ZO_GetAllianceIcon(rowData.alliance))
		texture:SetDimensions(32, 64)
		texture:SetAnchor(TOPLEFT)
		rowControl:SetHeight(50)
	elseif rowData.alliance == 100 then
		locationLabel:SetText(zo_strformat(GetString(SI_MAPTRANSITLINEALLIANCE1)))
		texture:SetTexture("esoui/art/compass/ava_flagneutral.dds")
		texture:SetDimensions(64, 64)
		texture:SetAnchor(TOPLEFT, nil, TOPLEFT, -16)
		rowControl:SetHeight(50)
	end

	locationLabel:SetColor(headerColor:UnpackRGB())
end

function addon:SetupMapType(rowControl, rowData)
	local locationLabel = rowControl:GetNamedChild("Location")
	local texture = rowControl:GetNamedChild("Texture")

	if rowData.alliance == 999 then
		locationLabel:SetText(zo_strformat(GetString(SI_MAP_MENU_WORLD_MAP)))
		texture:ClearAnchors()
		texture:SetTexture("esoui/art/tutorial/gamepad/gp_lfg_world.dds")
		texture:SetDimensions(32, 32)
		texture:SetAnchor(BOTTOMLEFT)
	elseif rowData.alliance == 1000 then
		locationLabel:SetText("")
		texture:ClearAnchors()
		texture:SetTexture("esoui/art/icons/mapkey/mapkey_elderscroll.dds")
		texture:SetDimensions(48, 48)
		texture:SetAnchor(TOPLEFT)
	end
	rowControl:SetHeight(40)
	locationLabel:SetColor(headerColor:UnpackRGB())
end

function addon:GetPlayerMapIndex()
	local zoneName = GetUnitZone("player")
	local mapIndex = self.zoneNameToMapIndex[zoneName]
	return mapIndex
end

function addon:UpdateRecent(mapIndex)
	local recent = self.player.recent
	local oldCount = #recent
	for i = oldCount, 1, -1 do
		if recent[i] and recent[i] == mapIndex then table.remove(recent, i) end
	end
	table.insert(recent, 1, mapIndex)

	local count = #recent
	while count > 5 do
		table.remove(recent, count)
		count = count - 1
	end
	return count > oldCount
end

function addon:BuildLocationList()
	local playerAlliance = GetUnitAlliance("player")
	local allianceOrder = addon.allianceOrder[playerAlliance]
	allianceOrder[100] = self.account.allAllianceOnTop and 0 or 100

	local location
	local mapData = self.mapData
	if not mapData then
		mapData = { }
		local GetMapInfo, LocalizeString = GetMapInfo, LocalizeString
		for i = 1, GetNumMaps() do
			local mapName, mapType, mapContentType, zoneIndex, description = GetMapInfo(i)
			if mapName ~= "" then
				location = self.locations[i]
				if location == nil then
					location = ZO_DeepTableCopy(addon.locations[27])
					addon.locations[i] = location
				end
				location.zoneIndex = zoneIndex + 1

				-- assert(location ~= nil, zo_strjoin(" ", "New yet unsupported zone ", i, mapName))
				location.allianceOrder = allianceOrder[location.alliance]
				location.locationName = LocalizeString(SI_TOOLTIP_ITEM_NAME, mapName)
				location.mapType = mapType
				location.mapContentType = mapContentType
				location.index = i
				location.description = description

				mapData[#mapData + 1] = location
			end
		end
		self.mapData = mapData

		local list = { }
		self.zoneNameToMapIndex = list
		local GetZoneNameByIndex = GetZoneNameByIndex
		for mapIndex, entry in pairs(self.locations) do
			list[GetZoneNameByIndex(entry.zoneIndex)] = mapIndex
		end
	else
		for i = 1, GetNumMaps() do
			location = self.locations[i]
			location.allianceOrder = allianceOrder[location.alliance]
		end
	end

	local sortLoc
	if self.account.sortBy == SORT_LOCATION_NAME then
		sortLoc = function(a, b) return a.locationName < b.locationName end
	elseif self.account.sortBy == SORT_LOCATION_LEVEL_ASC then
		sortLoc = function(a, b)
			if a.zoneOrder ~= b.zoneOrder then
				return a.zoneOrder < b.zoneOrder
			else
				return a.locationName < b.locationName
			end
		end
	else
		sortLoc = function(a, b)
			if a.zoneOrder ~= b.zoneOrder then
				return a.zoneOrder > b.zoneOrder
			else
				return a.locationName > b.locationName
			end
		end
	end

	table.sort(mapData, function(a, b)
		if a.allianceOrder == b.allianceOrder then
			if a.allianceOrder > 0 and a.allianceOrder < 100 then
				return sortLoc(a, b)
			else
				if a.mapContentType == b.mapContentType then
					return a.locationName < b.locationName
				else
					return a.mapContentType < b.mapContentType
				end
			end
		else
			return a.allianceOrder < b.allianceOrder
		end
	end )

	return self.mapData
end

local function HookLocations()
	ZO_ScrollList_AddDataType(WORLD_MAP_LOCATIONS.list, LOCATION_TYPE_ID, "VotansLocationRow", 25, function(control, rowData) addon:SetupLocation(control, rowData) end)
	ZO_ScrollList_AddDataType(WORLD_MAP_LOCATIONS.list, ALLIANCE_TYPE_ID, "VotansLocationHeaderRow", 50, function(control, rowData) addon:SetupHeader(control, rowData) end)
	ZO_ScrollList_AddDataType(WORLD_MAP_LOCATIONS.list, MAP_TYPE_ID, "VotansLocationHeaderRow", 40, function(control, rowData) addon:SetupMapType(control, rowData) end)
	ZO_ScrollList_AddDataType(WORLD_MAP_LOCATIONS.list, RECENT_TYPE_ID, "VotansLocationRow", 25, function(control, rowData) addon:SetupRecentLocation(control, rowData) end)

	function WORLD_MAP_LOCATIONS:BuildLocationList()
		ZO_ScrollList_Clear(self.list)

		local mapData = addon:BuildLocationList()

		self.list.mode = 2
		local scrollData = ZO_ScrollList_GetDataList(self.list)
		scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(MAP_TYPE_ID, { alliance = 1000, })
		for i = 1, #addon.player.recent do
			scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(RECENT_TYPE_ID, { index = i })
		end
		addon.nextRecentIndex = #scrollData

		local lastAlliance = -1
		for i = 1, #mapData do
			local entry = mapData[i]
			if entry.alliance ~= lastAlliance then
				lastAlliance = entry.alliance
				if entry.alliance < 999 then
					scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(ALLIANCE_TYPE_ID, entry)
				else
					scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(MAP_TYPE_ID, entry)
				end
			end

			scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(LOCATION_TYPE_ID, entry)
		end

		ZO_ScrollList_Commit(self.list)
	end

	local orgUpdateSelectedMap = WORLD_MAP_LOCATIONS.UpdateSelectedMap
	function WORLD_MAP_LOCATIONS:UpdateSelectedMap(...)
		local mapIndex = addon:GetPlayerMapIndex()
		if mapIndex and addon.player.recent[1] ~= mapIndex then
			local needUpdate = addon:UpdateRecent(mapIndex)

			if needUpdate then
				-- can be one new entry, only
				local scrollData = ZO_ScrollList_GetDataList(self.list)
				local count = addon.nextRecentIndex
				addon.nextRecentIndex = addon.nextRecentIndex + 1
				table.insert(scrollData, addon.nextRecentIndex, ZO_ScrollList_CreateDataEntry(RECENT_TYPE_ID, { index = count }))
				ZO_ScrollList_Commit(self.list)
			end
		end

		return orgUpdateSelectedMap(self, ...)
	end
end

local function HookGamepadLocations()
	GAMEPAD_WORLD_MAP_LOCATIONS.list:AddDataTemplate("VotansGamepadLocationRow", function(...)
		local control, entryData = select(1, ...)
		local levelLabel = control:GetNamedChild("SubLabel1")
		addon:ShowLevel(levelLabel, entryData)
		control.label:SetWidth(ZO_GAMEPAD_DEFAULT_LIST_ENTRY_WIDTH_AFTER_INDENT - levelLabel:GetWidth())

		local texture = control.icon
		if entryData.alliance < 100 then
			texture:SetTexture(ZO_GetAllianceIcon(entryData.alliance))
			texture:SetDimensions(32, 64)
		elseif entryData.alliance == 100 then
			texture:SetTexture("esoui/art/compass/ava_flagneutral.dds")
			texture:SetDimensions(64, 64)
		end
		control.icon:SetHidden(false)

		return GAMEPAD_WORLD_MAP_LOCATIONS:SetupLocation(...)
	end , ZO_GamepadMenuEntryTemplateParametricListFunction)

	GAMEPAD_WORLD_MAP_LOCATIONS.list:AddDataTemplate("VotansGamepadRecentLocationRow", function(...)
		local control, entryData = select(1, ...)
		local levelLabel = control:GetNamedChild("SubLabel1")
		addon:ShowLevel(levelLabel, entryData)
		control.label:SetWidth(ZO_GAMEPAD_DEFAULT_LIST_ENTRY_WIDTH_AFTER_INDENT - levelLabel:GetWidth())
		return GAMEPAD_WORLD_MAP_LOCATIONS:SetupLocation(...)
	end , ZO_GamepadMenuEntryTemplateParametricListFunction)

	local recentEntries = { }
	local locationEntries = { }
	function GAMEPAD_WORLD_MAP_LOCATIONS:BuildLocationList()
		self.list:Clear()

		local mapData = addon:BuildLocationList()

		for i = 1, #addon.player.recent do
			local entry = addon.locations[addon.player.recent[i]]
			local entryData = recentEntries[entry.locationName]
			if not entryData then
				entryData = ZO_GamepadEntryData:New(entry.locationName, "esoui/art/icons/mapkey/mapkey_elderscroll.dds")
				recentEntries[entry.locationName] = entryData
			end
			entryData:SetDataSource(entry)
			self.list:AddEntry("VotansGamepadRecentLocationRow", entryData)
		end

		for i = 1, #mapData do
			local entry = mapData[i]
			local entryData = locationEntries[entry.locationName]
			if not entryData then
				entryData = ZO_GamepadEntryData:New(entry.locationName)
				locationEntries[entry.locationName] = entryData
			end
			entryData:SetDataSource(entry)
			self.list:AddEntry("VotansGamepadLocationRow", entryData)
		end

		self.list:Commit()
	end

	local orgUpdateSelectedMap = GAMEPAD_WORLD_MAP_LOCATIONS.UpdateSelectedMap
	function GAMEPAD_WORLD_MAP_LOCATIONS:UpdateSelectedMap(...)
		local mapIndex = addon:GetPlayerMapIndex()
		if mapIndex and addon.player.recent[1] ~= mapIndex then
			addon:UpdateRecent(mapIndex)
			self:BuildLocationList()
		end

		return orgUpdateSelectedMap(self, ...)
	end
end

local function RefreshList()
	if IsInGamepadPreferredMode() then
		GAMEPAD_WORLD_MAP_LOCATIONS.list:RefreshVisible()
	else
		ZO_ScrollList_RefreshVisible(WORLD_MAP_LOCATIONS.list)
	end
end

local function RebuildList()
	if IsInGamepadPreferredMode() then
		GAMEPAD_WORLD_MAP_LOCATIONS:BuildLocationList()
	else
		WORLD_MAP_LOCATIONS:BuildLocationList()
	end
end

function addon:InitSettings()
	local LAM2 = LibStub("LibAddonMenu-2.0")

	self.player = ZO_SavedVars:NewCharacterIdSettings("VotansImprovedLocations_Data", 1, nil, { recent = { }, })

	local defaults = { showLevels = false, sortBy = SORT_LOCATION_NAME, allAllianceOnTop = false, }
	self.account = ZO_SavedVars:NewAccountWide("VotansImprovedLocations_Data", 1, nil, defaults)

	local panelData = {
		type = "panel",
		name = "Improved Locations",
		author = "votan",
		version = "v1.8.0",
		registerForRefresh = false,
		registerForDefaults = true,
		website = "http://www.esoui.com/downloads/info1096-VotansImprovedLocations.html",
	}
	LAM2:RegisterAddonPanel(addon.name, panelData)

	local optionsTable = {
		{
			-- Show Levels
			type = "checkbox",
			name = GetString(SI_VOTANSIMPROVEDLOCATIONS_SHOW_LEVELS),
			tooltip = nil,
			getFunc = function() return self.account.showLevels end,
			setFunc = function(value)
				if self.account.showLevels ~= value then
					self.account.showLevels = value
					RefreshList()
				end
			end,
			width = "full",
			default = defaults.showLevels,
		},
		{
			-- Sort Order
			type = "dropdown",
			name = GetString(SI_VOTANSIMPROVEDLOCATIONS_SORT),
			tooltip = nil,
			choices = { GetString(SI_VOTANSIMPROVEDLOCATIONS_SORT_NAME), GetString(SI_VOTANSIMPROVEDLOCATIONS_SORT_ASC), GetString(SI_VOTANSIMPROVEDLOCATIONS_SORT_DSC) },
			getFunc = function()
				local value = self.account.sortBy
				if value == SORT_LOCATION_NAME then
					value = GetString(SI_VOTANSIMPROVEDLOCATIONS_SORT_NAME)
				elseif value == SORT_LOCATION_LEVEL_ASC then
					value = GetString(SI_VOTANSIMPROVEDLOCATIONS_SORT_ASC)
				else
					value = GetString(SI_VOTANSIMPROVEDLOCATIONS_SORT_DSC)
				end
				return value
			end,
			setFunc = function(value)
				if value == GetString(SI_VOTANSIMPROVEDLOCATIONS_SORT_NAME) then
					value = SORT_LOCATION_NAME
				elseif value == GetString(SI_VOTANSIMPROVEDLOCATIONS_SORT_ASC) then
					value = SORT_LOCATION_LEVEL_ASC
				else
					value = SORT_LOCATION_LEVEL_DSC
				end
				if self.account.sortBy ~= value then
					self.account.sortBy = value
					RebuildList()
				end
			end,
			width = "full",

			default = defaults.sortBy,
		},
		{
			-- Show Levels
			type = "checkbox",
			name = GetString(SI_VOTANSIMPROVEDLOCATIONS_SHOW_ALL_ALLIANCE_ON_TOP),
			tooltip = nil,
			getFunc = function() return self.account.allAllianceOnTop end,
			setFunc = function(value)
				if self.account.allAllianceOnTop ~= value then
					self.account.allAllianceOnTop = value
					RebuildList()
				end
			end,
			width = "full",
			default = defaults.allAllianceOnTop,
		},
	}

	LAM2:RegisterOptionControls(addon.name, optionsTable)
end

function addon:Initialize()
	self:InitSettings()
	HookLocations()
	HookGamepadLocations()

	RebuildList()
	em:RegisterForEvent(addon.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, RebuildList)
end

local function OnAddOnLoaded(event, addonName)
	if addonName == addon.name then
		em:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
		addon:Initialize()
	end
end

em:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

VOTANS_IMPROVED_LOCATIONS = addon
