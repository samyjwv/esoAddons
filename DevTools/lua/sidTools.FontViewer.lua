local FONT_DATA = 1
local SAMPLE_TEXT = [[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
1234567890.:,;'"(!?)+-*/=
The quick brown fox jumps over the lazy dog. 1234567890]]

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

local function BuildFontList()
	local fonts = {}
	for varname, value in zo_insecurePairs(_G) do
		if(type(value) == "userdata" and value.GetFontInfo) then
			local definition = table.concat({value:GetFontInfo()}, ", ")
			fonts[#fonts + 1] = {
				name = varname,
				definition = definition,
				font = value
			}
		end
	end
	return fonts
end

local function InitializeFontList(window)
	local container = window:CreateControl("FontListContainer", CT_CONTROL)
	container:SetAnchor(TOPLEFT, nil, TOPLEFT, 10, 10)
	container:SetAnchor(BOTTOMRIGHT, nil, TOPRIGHT, -10, 300)

	local search = CreateControlFromVirtual("$(parent)Search", container, "sidFontListSearch")
	search:SetAnchor(TOPRIGHT, nil, TOPRIGHT, 0, 0)

	local searchBox = GetControl(search, "Box")
	ZO_EditDefaultText_Initialize(searchBox, "Enter Fontname ...")

	local headers = container:CreateControl("$(parent)Headers", CT_CONTROL)
	headers:SetAnchor(TOPLEFT, nil, TOPLEFT, 5, 5)
	headers:SetAnchor(TOPRIGHT, nil, TOPRIGHT, -5, 5)
	headers:SetHeight(32)

	local fontNameHeader = CreateControlFromVirtual("$(parent)FontName", headers, "ZO_SortHeader")
	ZO_SortHeader_Initialize(fontNameHeader, "FontName", "name", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
	fontNameHeader:SetAnchor(TOPLEFT, nil, TOPLEFT, 8, 0)
	fontNameHeader:SetDimensions(350, 32)

	local fontDefinitionHeader = CreateControlFromVirtual("$(parent)FontType", headers, "ZO_SortHeader")
	ZO_SortHeader_Initialize(fontDefinitionHeader, "FontDefinition", "definition", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
	fontDefinitionHeader:SetAnchor(TOPLEFT, fontNameHeader, TOPRIGHT, 32, 0)
	fontDefinitionHeader:SetDimensions(750, 32)

	local fontListControl = CreateControlFromVirtual("$(parent)List", container, "ZO_ScrollList")
	fontListControl:SetAnchor(TOPLEFT, headers, BOTTOMLEFT, 0, 3)
	fontListControl:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, -5, -5)

	local list = ZO_SortFilterList:New(container)
	list:SetAlternateRowBackgrounds(true)
	list:SetEmptyText("No fonts found")
	list.sortHeaderGroup:SelectHeaderByKey("name")

	local function SetupRow(control, data)
		list:SetupRow(control, data)

		local fontNameControl = GetControl(control, "FontName")
		fontNameControl:SetText(data.name)

		local fontDefinitionControl = GetControl(control, "FontDefinition")
		fontDefinitionControl:SetText(data.definition)
	end
	ZO_ScrollList_AddDataType(list.list, FONT_DATA, "sidFontListRow", 30, function(control, data) SetupRow(control, data) end)
	ZO_ScrollList_EnableHighlight(list.list, "ZO_ThinListHighlight")

	local masterList = BuildFontList()
	function list:BuildMasterList()
	-- fonts won't change so we only build it once
	end

	local LTF = LibStub("LibTextFilter")

	function list:FilterScrollList()
		local scrollData = ZO_ScrollList_GetDataList(self.list)
		ZO_ClearNumericallyIndexedTable(scrollData)

		local searchTerm = searchBox:GetText():lower()

		for i = 1, #masterList do
			local data = masterList[i]
			if(searchTerm == "" or LTF:Filter(data.name:lower() .. "\n" .. data.definition:lower(), searchTerm)) then
				table.insert(scrollData, ZO_ScrollList_CreateDataEntry(FONT_DATA, data))
			end
		end
	end

	local function SortEntries(listEntry1, listEntry2)
		local data1, data2 = listEntry1.data, listEntry2.data
		local value1, value2
		if(list.currentSortKey == "definition") then
			if(list.currentSortOrder == ZO_SORT_ORDER_UP) then
				value1, value2 = data1.definition, data2.definition
			else
				value2, value1 = data1.definition, data2.definition
			end
		else
			if(list.currentSortOrder == ZO_SORT_ORDER_UP) then
				value1, value2 = data1.name, data2.name
			else
				value2, value1 = data1.name, data2.name
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

		local fontNameControl = GetControl(control, "FontName")
		fontNameControl:SetColor(textColor:UnpackRGBA())

		local fontDefinitionControl = GetControl(control, "FontDefinition")
		fontDefinitionControl:SetColor(textColor:UnpackRGBA())
	end

	sidTools.FontListRow_OnMouseEnter = function(control)
		list:EnterRow(control)
	end

	sidTools.FontListRow_OnMouseExit = function(control)
		list:ExitRow(control)
	end

	sidTools.FontListRow_OnMouseUp = function(control, button, upInside)
		local data = ZO_ScrollList_GetData(control)
		if(button == MOUSE_BUTTON_INDEX_RIGHT) then
			StartChatInput(data.name)
		else
			window.sampleText:SetFont(data.name)
		end
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

	list:RefreshFilters()
	window.sampleText:SetFont(masterList[1].name)
end

local function Initialize(saveData)
	local fontWindow = CreateWindow("sidToolsFontView", "Font Viewer", nil, 300, 300, 1100, 500)
	local sampleText = fontWindow:CreateControl("$(parent)SampleText", CT_LABEL)
	sampleText:SetAnchor(TOPLEFT, fontWindow, TOPLEFT, 20, 350)
	sampleText:SetColor(1, 1, 1, 1)
	sampleText:SetText(SAMPLE_TEXT)
	fontWindow.sampleText = sampleText
	InitializeFontList(fontWindow)

    local fontsCmd = sidTools.fontsCmd

    local showCmd = fontsCmd:RegisterSubCommand()
    showCmd:AddAlias("show")
    showCmd:SetCallback(function()
        fontWindow:SetHidden(false)
    end)
    showCmd:SetDescription("Show the font viewer window")

    local hideCmd = fontsCmd:RegisterSubCommand()
    hideCmd:AddAlias("hide")
    hideCmd:SetCallback(function()
        fontWindow:SetHidden(true)
    end)
    hideCmd:SetDescription("Hide the font viewer window")

    local function ToggleFontViewer()
        if(fontWindow:IsHidden()) then
            showCmd()
        else
            hideCmd()
        end
    end
    sidTools.ToggleFontViewer = ToggleFontViewer

    fontsCmd:SetCallback(ToggleFontViewer)
end

sidTools.InitializeFontViewer = Initialize
