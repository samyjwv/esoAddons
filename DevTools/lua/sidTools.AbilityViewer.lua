local MAX_ABILITY_ID = 90000

local function CreateWindow(name, title, parent, x, y, width, height)
	local minWidth = 200
	local minHeight = 150

	local window = WINDOW_MANAGER:CreateTopLevelWindow(name)
	window:SetMouseEnabled(true)
	window:SetMovable(true)
	window:SetHidden(false)
	window:SetClampedToScreen(true)
	window:SetClampedToScreenInsets(-24)
	window:SetDimensions(width, height)
	window:SetDimensionConstraints(minWidth, minHeight)
	window:SetResizeHandleSize(16)
	if(parent) then
		window:SetAnchor(TOPLEFT, parent, TOPRIGHT, x, y)
	else
		window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
	end

	local bg = window:CreateControl("$(parent)Bg", CT_BACKDROP)
	bg:SetAnchor(TOPLEFT, window, TOPLEFT, -8, -6)
	bg:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 4, 4)
	bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, 32)
	bg:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
	bg:SetInsets(32, 32, -32, -32)
	bg:SetDimensionConstraints(minWidth, minHeight)
	window.bg = bg

	local divider = window:CreateControl("$(parent)Divider", CT_TEXTURE)
	divider:SetDimensions(4, 8)
	divider:SetAnchor(TOPLEFT, window, TOPLEFT, 20, 40)
	divider:SetAnchor(TOPRIGHT, window, TOPRIGHT, -20, 40)
	divider:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
	divider:SetTextureCoords(0.181640625, 0.818359375, 0, 1)
	window.divider = divider

	local label = window:CreateControl("$(parent)Label", CT_LABEL)
	label:SetText(title)
	label:SetFont("$(ANTIQUE_FONT)|24")
	label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
	local textHeight = label:GetTextHeight()
	label:SetDimensionConstraints(minWidth-60, textHeight, nil, textHeight)
	label:ClearAnchors()
	label:SetAnchor(TOPLEFT, window, TOPLEFT, 30, (40-textHeight)/2+5)
	label:SetAnchor(TOPRIGHT, window, TOPRIGHT, -30, (40-textHeight)/2+5)
	window.label = label
	window.SetLabel = function(self, text)
		self.label:SetText(text)
	end

	local container = window:CreateControl("$(parent)Container", CT_CONTROL)
	container:SetAnchor(TOPLEFT, window, TOPLEFT, 20, 42)
	container:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -20, -20)
	window.container = container
	window.CreateControl = function(self, name, type)
		return container:CreateControl("$(parent)" .. name, type)
	end

	return window
end

local ABILITY_DATA = 1

local function InitializeAbilityList(window)
	local container = window:CreateControl("AbilityListContainer", CT_CONTROL)
	container:SetAnchor(TOPLEFT, nil, TOPRIGHT, -480, 0)
	container:SetAnchor(BOTTOMRIGHT, nil, BOTTOMRIGHT, 0, 0)

	local search = CreateControlFromVirtual("$(parent)Search", container, "sidAbilityListSearch")
	search:SetAnchor(TOPRIGHT, nil, TOPRIGHT, -150, -30)

	local searchBox = GetControl(search, "Box")
	ZO_EditDefaultText_Initialize(searchBox, "Enter Abilityname ...")

	local headers = container:CreateControl("$(parent)Headers", CT_CONTROL)
	headers:SetAnchor(TOPLEFT, nil, TOPLEFT, 5, 5)
	headers:SetAnchor(TOPRIGHT, nil, TOPRIGHT, -5, 5)
	headers:SetHeight(32)

	local abilityIdHeader = CreateControlFromVirtual("$(parent)AbilityId", headers, "ZO_SortHeaderIcon")
	ZO_SortHeader_InitializeArrowHeader(abilityIdHeader, "id", ZO_SORT_ORDER_UP)
	ZO_SortHeader_SetTooltip(abilityIdHeader, "AbilityId")
	abilityIdHeader:SetAnchor(TOPLEFT, nil, TOPLEFT, 8, 0)
	abilityIdHeader:SetDimensions(32, 32)

	local abilityNameHeader = CreateControlFromVirtual("$(parent)AbilityName", headers, "ZO_SortHeader")
	ZO_SortHeader_Initialize(abilityNameHeader, "AbilityName", "name", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
	abilityNameHeader:SetAnchor(TOPLEFT, abilityIdHeader, TOPRIGHT, 32, 0)
	abilityNameHeader:SetDimensions(200, 32)

	local abilityTypeHeader = CreateControlFromVirtual("$(parent)AbilityType", headers, "ZO_SortHeader")
	ZO_SortHeader_Initialize(abilityTypeHeader, "AbilityType", "type", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
	abilityTypeHeader:SetAnchor(TOPLEFT, abilityNameHeader, TOPRIGHT, 32, 0)
	abilityTypeHeader:SetDimensions(100, 32)

	local abilityListControl = CreateControlFromVirtual("$(parent)List", container, "ZO_ScrollList")
	abilityListControl:SetAnchor(TOPLEFT, headers, BOTTOMLEFT, 0, 3)
	abilityListControl:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, -5, -5)

	local list = ZO_SortFilterList:New(container)
	list:SetAlternateRowBackgrounds(true)
	list:SetEmptyText("No abilities found")
	list.sortHeaderGroup:SelectHeaderByKey("id")

	local function SetupRow(control, data)
		list:SetupRow(control, data)

		local abilityIdControl = GetControl(control, "AbilityId")
		abilityIdControl:SetText(data.id)

		local abilityNameControl = GetControl(control, "AbilityName")
		abilityNameControl:SetText(data.name)

		local abilityTypeControl = GetControl(control, "AbilityType")
		abilityTypeControl:SetText(data.abilityType)
	end
	ZO_ScrollList_AddDataType(list.list, ABILITY_DATA, "sidAbilityListRow", 30, function(control, data) SetupRow(control, data) end)
	ZO_ScrollList_EnableHighlight(list.list, "ZO_ThinListHighlight")

	local masterList = {}
	function list:BuildMasterList()
	-- abilities won't change so we only build it once below
	end

	local LTF = LibStub("LibTextFilter")

	function list:FilterScrollList()
		local scrollData = ZO_ScrollList_GetDataList(self.list)
		ZO_ClearNumericallyIndexedTable(scrollData)

		local searchTerm = searchBox:GetText():lower()

		for i = 1, #masterList do
			local data = masterList[i]
			if(searchTerm == "" or LTF:Filter(data.name:lower(), searchTerm)) then
				table.insert(scrollData, ZO_ScrollList_CreateDataEntry(ABILITY_DATA, data))
			end
		end
	end

	local function SortEntries(listEntry1, listEntry2)
		local data1, data2 = listEntry1.data, listEntry2.data
		local value1, value2
		if(list.currentSortKey == "type") then
			if(list.currentSortOrder == ZO_SORT_ORDER_UP) then
				value1, value2 = data1.abilityType, data2.abilityType
			else
				value2, value1 = data1.abilityType, data2.abilityType
			end
		elseif(list.currentSortKey == "name") then
			if(list.currentSortOrder == ZO_SORT_ORDER_UP) then
				value1, value2 = data1.name, data2.name
			else
				value2, value1 = data1.name, data2.name
			end
		else
			if(list.currentSortOrder == ZO_SORT_ORDER_UP) then
				value1, value2 = data1.id, data2.id
			else
				value2, value1 = data1.id, data2.id
			end
		end
		return value1 < value2
	end

	function list:SortScrollList()
		if(self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
			local scrollData = ZO_ScrollList_GetDataList(self.list)
			table.sort(scrollData, SortEntries)
		end

		self:RefreshVisible()
	end

	function list:GetRowColors(data, selected)
		return ZO_SECOND_CONTRAST_TEXT
	end

	function list:ColorRow(control, data, mouseIsOver)
		local textColor = self:GetRowColors(data, mouseIsOver)

		local abilityIdControl = GetControl(control, "AbilityId")
		abilityIdControl:SetColor(textColor:UnpackRGBA())

		local abilityNameControl = GetControl(control, "AbilityName")
		abilityNameControl:SetColor(textColor:UnpackRGBA())

		local abilityTypeControl = GetControl(control, "AbilityType")
		abilityTypeControl:SetColor(textColor:UnpackRGBA())
	end

	sidTools.AbilityListRow_OnMouseEnter = function(control)
		list:EnterRow(control)
	end

	sidTools.AbilityListRow_OnMouseExit = function(control)
		list:ExitRow(control)
	end

	sidTools.AbilityListRow_OnMouseUp = function(control, button, upInside)
		local data = ZO_ScrollList_GetData(control)
		local abilityId = data.id
		if(button == MOUSE_BUTTON_INDEX_RIGHT) then
			StartChatInput(window.tooltip:CreateAbilityLink(abilityId, LINK_STYLE_BRACKETS))
		else
			window.tooltip:SetAnchor(TOPLEFT, window.container, TOPLEFT, 5, 30)
			window.tooltip:ShowTooltip(abilityId)
		end

		--* GetAbilityEffectDescription(*integer* _effectSlotId_)
		--** _Returns:_ *string* _description_
		--
		--* GetAbilityUpgradeLines(*integer* _abilityId_)
		--** _Uses variable returns..._
		--** _Returns:_ *string* _label_, *string* _oldValue_, *string* _newValue_
		--
		--* GetAbilityNewEffectLines(*integer* _abilityId_)
		--** _Uses variable returns..._
		--** _Returns:_ *string* _newEffect_
	end

	local function ClearCallLater(id)
		EVENT_MANAGER:UnregisterForUpdate("CallLaterFunction"..id)
	end

	local refreshFilterHandle
	local function RefreshFilters()
		list:RefreshFilters()
	end

	searchBox:SetHandler("OnTextChanged", function()
		ZO_EditDefaultText_OnTextChanged(searchBox)
		if(refreshFilterHandle) then
			ClearCallLater(refreshFilterHandle)
		end
		refreshFilterHandle = zo_callLater(RefreshFilters, 250)
	end)

	--	for skillType = 1, GetNumSkillTypes() do
	--		--GetString("SI_SKILLTYPE", skillType)
	--		for skillIndex = 1, GetNumSkillLines(skillType) do
	--			local name, rank = GetSkillLineInfo(skillType, skillIndex)
	--			local lastRankXP, nextRankXP, currentXP = GetSkillLineXPInfo(skillType, skillIndex)
	--			local startXP, nextRankStartXP = GetSkillLineRankXPExtents(skillType, skillIndex, rank)
	--
	--			local numAbilities = GetNumSkillAbilities(skillType, skillIndex)
	--			for abilityIndex = 1, numAbilities do
	--				local name, texture, earnedRank, passive, ultimate, purchased, progressionIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
	--				local showUpgrade = false
	--				local abilityId = GetSkillAbilityId(skillType, skillIndex, abilityIndex, showUpgrade)
	--				local currentUpgradeLevel, maxUpgradeLevel = GetSkillAbilityUpgradeInfo(skillType, skillIndex, abilityIndex)
	--				local name, texture, earnedRank = GetSkillAbilityNextUpgradeInfo(skillType, skillIndex, abilityIndex)
	--
	--				--				local abilityId = GetAbilityProgressionAbilityId(progressionIndex, morph, rank)
	--
	--			end
	--		end
	--	end

	--	for stype = 1, GetNumSkillTypes() do
	--		for sindex = 1, GetNumSkillLines(stype) do
	--			for aindex = 1, GetNumSkillAbilities(stype, sindex) do
	--				local name, texture, rank, passive, ultimate, purchased, pindex = GetSkillAbilityInfo(stype, sindex, aindex)
	--				local aid = GetSkillAbilityId(stype, sindex, aindex)
	--				local arank = GetAbilityProgressionRankFromAbilityId(aid)
	--				df("%d, %d, %d: %s |t100%%:100%%:%s|t: %d, %s, %s, %s, %s, %s", stype, sindex, aindex, name, texture, rank, tostring(arank), tostring(passive), tostring(ultimate), tostring(purchased), tostring(pindex))
	--			end
	--		end
	--	end

--	local function PrintAbilityInfo(abilityId)
--		local name = GetAbilityName(abilityId)
--		local icon = GetAbilityIcon(abilityId)
--		local hasProgression, progressionIndex, lastRankXp, nextRankXp, currentXp, atMorph = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
--		if(hasProgression and nextRankXp > 0) then -- not maxed
--			local rank = GetAbilityProgressionRankFromAbilityId(abilityId)
--			local percent = currentXp / nextRankXp * 100
--			df("%d: %s |t100%%:100%%:%s|t: %d (%.2f%%)", abilityId, name, icon, rank, percent)
--			return GetAbilityProgressionAbilityId(progressionIndex, 1, 1), GetAbilityProgressionAbilityId(progressionIndex, 2, 1)
--		end
--	end
--
--	for i = 1, GetNumAbilities() do
--		local morphA, morphB = PrintAbilityInfo(GetAbilityIdByIndex(i))
--		if(morphA) then PrintAbilityInfo(morphA) end
--		if(morphB) then PrintAbilityInfo(morphB) end
--	end


	--* GetNumAbilities()
	--** _Returns:_ *integer* _num_
	--
	--* GetAbilityInfoByIndex(*luaindex* _abilityIndex_)
	--** _Returns:_ *string* _name_, *string* _texture_, *integer* _rank_, *integer* _actionSlotType_, *bool* _passive_, *bool* _showInSpellbook_

	local id, count, throttle = 0, MAX_ABILITY_ID, 1000
	local emptyRow = GetControl(list.emptyRow, "Message")
	local function DoGenerate()
		for i = id, id + throttle - 1 do
			if(DoesAbilityExist(i)) then
				local name = GetAbilityName(i)
				local passive = IsAbilityPassive(i) and "passive" or "active"
				if(GetAbilityDescriptionHeader(i) ~= "") or (GetAbilityDescription(i) ~= "") then
					passive = "*" .. passive
				end
				masterList[#masterList + 1] = {
					type = ABILITY_DATA,
					id = i,
					name = zo_strformat("<<1>>", name),
					abilityType = passive,
				}
			end
		end
		if(id >= count) then
			list:RefreshData()
			emptyRow:SetText("No abilities found")
		else
			id = id + throttle
			emptyRow:SetText(("Processed %d of %d abilities"):format(id, count))
			zo_callLater(DoGenerate, 10)
		end
	end
	DoGenerate()
end

local function Initialize(saveData)
	local abilityWindow = CreateWindow("sidAbilityView", "Ability Viewer", nil, 170, 80, 950, 560)

	local LAT = LibStub("LibAbilityTooltip")
	LAT:SetAnchor(TOPLEFT, abilityWindow.container, TOPLEFT, 5, 30)
	LAT:ShowTooltip(2)
	abilityWindow.tooltip = LAT

	InitializeAbilityList(abilityWindow)

    local abilitiesCmd = sidTools.abilitiesCmd

    local showCmd = abilitiesCmd:RegisterSubCommand()
    showCmd:AddAlias("show")
    showCmd:SetCallback(function()
        abilityWindow:SetHidden(false)
    end)
    showCmd:SetDescription("Show the ability viewer window")

    local hideCmd = abilitiesCmd:RegisterSubCommand()
    hideCmd:AddAlias("hide")
    hideCmd:SetCallback(function()
        abilityWindow:SetHidden(true)
        abilityWindow.tooltip:HideTooltip()
    end)
    hideCmd:SetDescription("Hide the ability viewer window")

    local function ToggleAbilityViewer()
        if(abilityWindow:IsHidden()) then
            showCmd()
        else
            hideCmd()
        end
    end
    sidTools.ToggleAbilityViewer = ToggleAbilityViewer

    abilitiesCmd:SetCallback(ToggleAbilityViewer)
end

sidTools.InitializeAbilityViewer = Initialize
