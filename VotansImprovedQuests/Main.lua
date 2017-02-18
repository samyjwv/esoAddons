local addon = {
	name = "VotansImprovedQuests",
}

local em = GetEventManager()
local QUEST_TYPE_ID = 1
local LOCATION_TYPE_ID = 2

local headerColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
local selectedColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
-- local disabledColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED))

local function HideRowHighlight(rowControl, hidden)
	if not rowControl then return end
	if not ZO_ScrollList_GetData(rowControl) then return end

	local highlight = rowControl:GetNamedChild("Highlight")

	if highlight then
		if not highlight.animation then
			highlight.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", highlight)
		end

		if highlight.animation:IsPlaying() then
			highlight.animation:Stop()
		end
		highlight:SetTexture("esoui/art/miscellaneous/listitem_highlight.dds")
		if hidden then
			highlight.animation:PlayBackward()
		else
			highlight.animation:PlayForward()
		end
	end
end

function addon:ShowLevel(levelLabel, level)
	if level and self.account.showLevels then
		levelLabel:SetText(level)
	else
		levelLabel:SetText("")
	end
end

function addon:SetupQuest(rowControl, rowData)
	local function onMouseEnter(rowControl)
		HideRowHighlight(rowControl, false)
		ZO_WorldMapQuestHeader_OnMouseEnter(rowControl)
	end
	local function onMouseExit(rowControl)
		ZO_WorldMapQuestHeader_OnMouseExit(rowControl)
		HideRowHighlight(rowControl, true)
	end
	local function onMouseClick(rowControl, button, upInside)
		WORLD_MAP_QUESTS:QuestHeader_OnClicked(rowControl, button)
		WORLD_MAP_QUESTS:RefreshHeaders()
	end

	local nameLabel = rowControl:GetNamedChild("Name")
	nameLabel:SetText(rowData.name)
	nameLabel:SetColor(selectedColor:UnpackRGB())

	-- Assisted State
	local isAssisted = ZO_QuestTracker.tracker:IsTrackTypeAssisted(TRACK_TYPE_QUEST, rowData.questIndex)
	local icon = rowControl:GetNamedChild("AssistedIcon")
	icon:SetHidden(not isAssisted)

	rowControl.data = rowData

	local levelLabel = rowControl:GetNamedChild("Level")
	self:ShowLevel(levelLabel, rowData.level)

	rowControl:SetHeight(25)
	rowControl:SetHandler("OnMouseEnter", onMouseEnter)
	rowControl:SetHandler("OnMouseExit", onMouseExit)
	rowControl:SetHandler("OnMouseUp", onMouseClick)
end

function addon:SetupQuestType(rowControl, rowData)
	local locationLabel = rowControl:GetNamedChild("Location")
	local texture = rowControl:GetNamedChild("Texture")

	texture:ClearAnchors()
	texture:SetDimensions(40, 40)
	texture:SetAnchor(BOTTOMLEFT)
	if rowData.zoneIndex then
		locationLabel:SetText(LocalizeString("<<!AC:1>>", GetZoneNameByIndex(rowData.zoneIndex)))
	elseif rowData.text then
		locationLabel:SetText(zo_strformat(GetString(rowData.text)))
	end
	texture:SetTexture(rowData.icon)
	rowControl:SetHeight(40)
	locationLabel:SetColor(headerColor:UnpackRGB())
end

local function HookQuests()
	WORLD_MAP_QUESTS_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWING then
			WORLD_MAP_QUESTS:LayoutList()
		end
	end )
	GAMEPAD_WORLD_MAP_QUESTS_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWING then
			GAMEPAD_WORLD_MAP_QUESTS:LayoutList()
		end
	end )
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
		(IsInGamepadPreferredMode() and GAMEPAD_WORLD_MAP_QUESTS or WORLD_MAP_QUESTS):LayoutList()
	end )

	local function CreateQuestsList(AddQuests)
		local currentZoneIndex = GetCurrentMapZoneIndex()
		AddQuests( { zoneIndex = currentZoneIndex, icon = "esoui/art/compass/quest_icon_assisted.dds" }, function(rowData)
			local questIndex = rowData.questIndex
			return IsJournalQuestInCurrentMapZone(questIndex) or GetJournalQuestStartingZone(questIndex) == currentZoneIndex
		end )
		AddQuests( { text = SI_CRAFTING_PERFORM_FREE_CRAFT, icon = "esoui/art/treeicons/gamepad/achievement_categoryicon_crafting.dds" }, function(rowData)
			return QUEST_TYPE_CRAFTING == rowData.questType
		end )
		AddQuests( { text = SI_MAIN_MENU_GUILDS, icon = "esoui/art/compass/repeatablequest_assistedareapin.dds" }, function(rowData)
			return QUEST_TYPE_GUILD == rowData.questType and INSTANCE_DISPLAY_TYPE_NONE == rowData.displayType
		end )
		AddQuests( { text = SI_VOTANSIMPROVEDQUESTS_OTHER_ZONES, icon = "esoui/art/compass/quest_icon_door_assisted.dds" }, function(rowData)
			local questIndex = rowData.questIndex
			local zoneIndex = GetJournalQuestStartingZone(questIndex)
			if zoneIndex <= 1 or zoneIndex > 2147483647 then return false end
			return not(IsJournalQuestInCurrentMapZone(questIndex) or zoneIndex == currentZoneIndex)
		end )
		AddQuests( { text = 0, icon = "esoui/art/tutorial/gamepad/gp_lfg_world.dds" }, function(rowData) return true end)
	end

	local function DoLayout()
		local scrollList = addon.QuestsScrollList
		local dataList = ZO_ScrollList_GetDataList(scrollList)

		ZO_ScrollList_Clear(scrollList)
		local IsJournalQuestInCurrentMapZone, GetJournalQuestStartingZone, ZO_ScrollList_CreateDataEntry = IsJournalQuestInCurrentMapZone, GetJournalQuestStartingZone, ZO_ScrollList_CreateDataEntry

		local quests = { unpack(WORLD_MAP_QUESTS.data.masterList) }

		local function AddQuests(captionData, filter)
			local caption = false
			for i = 1, #quests do
				if quests[i] and filter(quests[i]) then
					if not caption then
						caption = true
						dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(LOCATION_TYPE_ID, captionData, 1)
					end
					dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(QUEST_TYPE_ID, quests[i], 1)
					quests[i] = nil
				end
			end
		end
		CreateQuestsList(AddQuests)

		ZO_ScrollList_Commit(scrollList)
	end
	function WORLD_MAP_QUESTS:LayoutList()
		if WORLD_MAP_QUESTS_FRAGMENT:IsShowing() then
			addon.QuestsScrollList:SetHidden(not ZO_WorldMapQuestsData_Singleton.ShouldMapShowQuestsInList())
			self:RefreshNoQuestsLabel()
			DoLayout()
		end
	end
	function WORLD_MAP_QUESTS:RefreshHeaders()
		if WORLD_MAP_QUESTS_FRAGMENT:IsShowing() then
			ZO_ScrollList_RefreshVisible(addon.QuestsScrollList)
		end
	end
	do
		local identifier = "ZO_WorldMapQuests_RefreshNoQuestsLabel"
		function ZO_WorldMapQuests_Shared:RefreshNoQuestsLabel()
			em:UnregisterForUpdate(identifier)
			if ZO_WorldMapQuestsData_Singleton.ShouldMapShowQuestsInList() then
				self.noQuestsLabel:SetHidden(true)
				local function Check()
					em:UnregisterForUpdate(identifier)
					if #self.data.masterList == 0 then
						self.noQuestsLabel:SetHidden(false)
						self.noQuestsLabel:SetText(GetString(SI_WORLD_MAP_NO_QUESTS))
					end
				end
				em:RegisterForUpdate(identifier, 150, Check)
			else
				self.noQuestsLabel:SetHidden(false)
				self.noQuestsLabel:SetText(GetString(SI_WORLD_MAP_DOESNT_SHOW_QUESTS_DISTANCE))
			end
		end
	end

	---------------------------------------------
	do
		local function equalityFunction(data1, data2)
			return data1.questInfo.questIndex == data2.questInfo.questIndex
		end

		local function SetupQuestRow(...)
			local control, entryData = select(1, ...)
			local levelLabel = control:GetNamedChild("SubLabel1")
			addon:ShowLevel(levelLabel, entryData.questLevel)
			control.label:SetWidth(ZO_GAMEPAD_DEFAULT_LIST_ENTRY_WIDTH_AFTER_INDENT - levelLabel:GetWidth())
			ZO_SharedGamepadEntry_OnSetup(...)
			levelLabel:SetHidden(false)
		end
		GAMEPAD_WORLD_MAP_QUESTS.questList:AddDataTemplate("VotansGamepadQuestRow", SetupQuestRow, ZO_GamepadMenuEntryTemplateParametricListFunction, equalityFunction)
	end

	function GAMEPAD_WORLD_MAP_QUESTS:RefreshHeaders()
		if GAMEPAD_WORLD_MAP_QUESTS_FRAGMENT:IsShowing() then
			self:LayoutList()
		end
	end

	local unselectedColor = selectedColor:Lerp(ZO_ColorDef:New(0, 0, 0), 0.25)
	local function GoAssisted(rowData) return rowData.isAssisted end
	function GAMEPAD_WORLD_MAP_QUESTS:LayoutList()
		if GAMEPAD_WORLD_MAP_QUESTS_FRAGMENT:IsShowing() then

			self.questList:Clear()
			ZO_ClearTable(self.entriesByIndex)
			self.assistedEntryData = nil

			local questJournalObject = SYSTEMS:GetObject("questJournal")
			local quests = { unpack(self.data.masterList) }

			local template = addon.account.showLevels and "VotansGamepadQuestRow" or "ZO_GamepadSubMenuEntryTemplateWithStatusLowercase42"

			local function AddQuests(captionData, filter)
				local ZO_QuestTracker, GetJournalQuestLevel, ZO_GamepadEntryData = ZO_QuestTracker, GetJournalQuestLevel, ZO_GamepadEntryData
				for i = 1, #quests do
					local srcData = quests[i]
					if srcData and filter(srcData) then
						local questIndex = srcData.questIndex
						-- local questIcon = questJournalObject:GetIconTexture(srcData.questType, srcData.displayType)

						local entryData = ZO_GamepadEntryData:New(srcData.name, captionData.icon)
						self.entriesByIndex[questIndex] = entryData

						entryData.questInfo = srcData

						local isAssisted = ZO_QuestTracker.tracker:IsTrackTypeAssisted(TRACK_TYPE_QUEST, questIndex)
						entryData.isAssisted = isAssisted
						if isAssisted then
							self.assistedEntryData = entryData
						end

						local questLevel = GetJournalQuestLevel(questIndex)
						entryData.questLevel = questLevel

						entryData:SetNameColors(selectedColor, unselectedColor)
						entryData:SetFontScaleOnSelection(false)

						self.questList:AddEntry(template, entryData)
						quests[i] = nil
					end
				end
			end
			if ZO_WorldMapQuestsData_Singleton.ShouldMapShowQuestsInList() then
				CreateQuestsList(AddQuests)
			end

			self.questList:Commit()

			if self.assistedEntryData then
				self.questList:EnableAnimation(false)
				self.questList:SetSelectedDataByEval(GoAssisted)
				self.questList:EnableAnimation(true)
			end

			self:RefreshNoQuestsLabel()
		end
	end
end

function addon:SetupControls()
	ZO_WorldMapQuestsPane:SetHidden(true)
	local list = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)VotansQuestsList", ZO_WorldMapQuests, "ZO_ScrollList")
	self.QuestsScrollList = list
	list:SetAnchorFill()
	list.mode = 2

	ZO_ScrollList_AddDataType(list, QUEST_TYPE_ID, "VotansQuestRow", 25, function(...) addon:SetupQuest(...) end)
	ZO_ScrollList_AddDataType(list, LOCATION_TYPE_ID, "VotansQuestHeaderRow", 40, function(...) addon:SetupQuestType(...) end)
end

function addon:InitSettings()
	local LAM2 = LibStub("LibAddonMenu-2.0")

	-- self.player = ZO_SavedVars:NewCharacterIdSettings("VotansImprovedQuests_Data", 1, nil, { recent = { }, })

	local defaults = { showLevels = false, sortBy = SORT_LOCATION_NAME, allAllianceOnTop = false, }
	self.account = ZO_SavedVars:NewAccountWide("VotansImprovedQuests_Data", 1, nil, defaults)

	local panelData = {
		type = "panel",
		name = "Improved Quests",
		author = "votan",
		version = "v1.0.4",
		registerForRefresh = false,
		registerForDefaults = true,
		website = "http://www.esoui.com/downloads/info1523-VotansImprovedQuests.html",
	}
	LAM2:RegisterAddonPanel(addon.name, panelData)

	local optionsTable = {
		{
			-- Show Levels
			type = "checkbox",
			name = GetString(SI_VOTANSIMPROVEDQUESTS_SHOW_LEVELS),
			tooltip = nil,
			getFunc = function() return self.account.showLevels end,
			setFunc = function(value)
				if self.account.showLevels ~= value then
					self.account.showLevels = value
					ZO_ScrollList_RefreshVisible(self.QuestsScrollList)
				end
			end,
			width = "full",
			default = defaults.showLevels,
		},
	}

	LAM2:RegisterOptionControls(addon.name, optionsTable)
end

function addon:Initialize()
	self:SetupControls()
	self:InitSettings()
	HookQuests()
end

local function OnAddOnLoaded(event, addonName)
	if addonName == addon.name then
		em:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
		addon:Initialize()
	end
end

em:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)