local MAX_ITEM_ID = 120000

local ItemLinkWrapper = sidTools.ItemLinkWrapper

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

local ITEM_DATA = 1

local function InitializeItemList(window)
	local container = window:CreateControl("ItemListContainer", CT_CONTROL)
	container:SetAnchor(TOPLEFT, nil, TOPRIGHT, -480, 0)
	container:SetAnchor(BOTTOMRIGHT, nil, BOTTOMRIGHT, 0, 0)

	local search = CreateControlFromVirtual("$(parent)Search", container, "sidItemListSearch")
	search:SetAnchor(TOPRIGHT, nil, TOPRIGHT, -150, -30)

	local searchBox = GetControl(search, "Box")
	ZO_EditDefaultText_Initialize(searchBox, "Enter Itemname ...")

	local headers = container:CreateControl("$(parent)Headers", CT_CONTROL)
	headers:SetAnchor(TOPLEFT, nil, TOPLEFT, 5, 5)
	headers:SetAnchor(TOPRIGHT, nil, TOPRIGHT, -5, 5)
	headers:SetHeight(32)

	local itemIDHeader = CreateControlFromVirtual("$(parent)ItemID", headers, "ZO_SortHeaderIcon")
	ZO_SortHeader_InitializeArrowHeader(itemIDHeader, "id", ZO_SORT_ORDER_UP)
	ZO_SortHeader_SetTooltip(itemIDHeader, "ItemID")
	itemIDHeader:SetAnchor(TOPLEFT, nil, TOPLEFT, 8, 0)
	itemIDHeader:SetDimensions(32, 32)

	local itemNameHeader = CreateControlFromVirtual("$(parent)ItemName", headers, "ZO_SortHeader")
	ZO_SortHeader_Initialize(itemNameHeader, "ItemName", "name", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
	itemNameHeader:SetAnchor(TOPLEFT, itemIDHeader, TOPRIGHT, 32, 0)
	itemNameHeader:SetDimensions(200, 32)

	local itemTypeHeader = CreateControlFromVirtual("$(parent)ItemType", headers, "ZO_SortHeader")
	ZO_SortHeader_Initialize(itemTypeHeader, "ItemType", "type", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
	itemTypeHeader:SetAnchor(TOPLEFT, itemNameHeader, TOPRIGHT, 32, 0)
	itemTypeHeader:SetDimensions(100, 32)

	local itemListControl = CreateControlFromVirtual("$(parent)List", container, "ZO_ScrollList")
	itemListControl:SetAnchor(TOPLEFT, headers, BOTTOMLEFT, 0, 3)
	itemListControl:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, -5, -5)

	local list = ZO_SortFilterList:New(container)
	list:SetAlternateRowBackgrounds(true)
	list:SetEmptyText("No items found")
	list.sortHeaderGroup:SelectHeaderByKey("id")

	local function SetupRow(control, data)
		list:SetupRow(control, data)

		local itemIDControl = GetControl(control, "ItemID")
		itemIDControl:SetText(data.id)

		local itemNameControl = GetControl(control, "ItemName")
		itemNameControl:SetText(data.name)

		local itemTypeControl = GetControl(control, "ItemType")
		itemTypeControl:SetText(data.typeName)
	end
	ZO_ScrollList_AddDataType(list.list, ITEM_DATA, "sidItemListRow", 30, function(control, data) SetupRow(control, data) end)
	ZO_ScrollList_EnableHighlight(list.list, "ZO_ThinListHighlight")

	local masterList = {}
	function list:BuildMasterList()
		window:SetItemID(masterList[1].id)
	end

	local LTF = LibStub("LibTextFilter")

	function list:FilterScrollList()
		local scrollData = ZO_ScrollList_GetDataList(self.list)
		ZO_ClearNumericallyIndexedTable(scrollData)

		local searchTerm = searchBox:GetText():lower()

		for i = 1, #masterList do
			local data = masterList[i]
			if(searchTerm == "" or LTF:Filter((data.name .. "\n" .. data.typeName):lower(), searchTerm)) then
				table.insert(scrollData, ZO_ScrollList_CreateDataEntry(ITEM_DATA, data))
			end
		end
	end

	local function SortEntries(listEntry1, listEntry2)
		local data1, data2 = listEntry1.data, listEntry2.data
		local value1, value2
		if(list.currentSortKey == "type") then
			if(list.currentSortOrder == ZO_SORT_ORDER_UP) then
				value1, value2 = data1.typeName, data2.typeName
			else
				value2, value1 = data1.typeName, data2.typeName
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

		local itemIDControl = GetControl(control, "ItemID")
		itemIDControl:SetColor(textColor:UnpackRGBA())

		local itemNameControl = GetControl(control, "ItemName")
		itemNameControl:SetColor(textColor:UnpackRGBA())

		local itemTypeControl = GetControl(control, "ItemType")
		itemTypeControl:SetColor(textColor:UnpackRGBA())
	end

	sidTools.ItemListRow_OnMouseEnter = function(control)
		list:EnterRow(control)
	end

	sidTools.ItemListRow_OnMouseExit = function(control)
		list:ExitRow(control)
	end

	sidTools.ItemListRow_OnMouseUp = function(control, button, upInside)
		local data = ZO_ScrollList_GetData(control)
		window:SetItemID(data.id)
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

	local id, count, throttle = 0, MAX_ITEM_ID, 1000
	local emptyRow = GetControl(list.emptyRow, "Message")
	local function DoGenerate()
		for i = id, id + throttle - 1 do
			local link = ("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(i)
			local name = GetItemLinkName(link)
			if(name ~= "") then
				local type = GetItemLinkItemType(link)
				if type == ITEMTYPE_DYE_STAMP then
					masterList[#masterList + 1] = {
						id = i,
						name = zo_strformat("<<1>>", name),
						itemType = type,
						typeName = GetString("SI_ITEMTYPE", type)
					}
					if not string.find(name, "PROTO") then
						if string.find(name, "Unamed") then
							d("[".. i .."] = false,")
						else
							d("[".. i .."] = true,")
						end
					end
				end
			end
		end
		if(id >= count) then
			list:RefreshData()
			emptyRow:SetText("No items found")
		else
			id = id + throttle
			emptyRow:SetText(("Processed %d of %d links"):format(id, count))
			zo_callLater(DoGenerate, 10)
		end
	end
	DoGenerate()
end

local function Initialize(saveData)
	local itemWindow = CreateWindow("sidItemView", "Item Viewer", nil, 170, 80, 1580, 720)
	local itemLink = ItemLinkWrapper:New()
	itemWindow.itemLink = itemLink

	local linkLabel = itemWindow:CreateControl("LinkLabel", CT_LABEL)
	linkLabel:SetAnchor(BOTTOMLEFT)
	linkLabel:SetColor(1, 1, 1, 1)
	linkLabel:SetFont("ZoFontGameMedium")
	linkLabel:SetMouseEnabled(true)

	local tooltip = CreateControlFromVirtual("sidItemViewTooltip", itemWindow.container, "ZO_ItemIconTooltip")
	tooltip:ClearAnchors()
	tooltip:SetAnchor(TOPLEFT, itemWindow.container, TOPLEFT, 5, 5)
	tooltip:SetHidden(false)
	tooltip.Refresh = function(self)
		local link = itemLink:GetLink()
		if(self.link == link) then return end
		self:ClearLines()
		if(GetItemLinkName(link) ~= "") then
			self:SetLink(link)
			linkLabel:SetText(link)
			if(sidItemViewLinkInput) then
				sidItemViewLinkInput.editbox:SetText(link)
			end

			--			saveData.qualityList = itemLink:ExportQualityList()
			--			itemLink:ExportEnchantmentList(function(list) saveData.enchantmentList = list end)
		else
			linkLabel:SetText("Invalid link")
			if(sidItemViewLinkInput) then
				sidItemViewLinkInput.editbox:SetText("")
			end
		end
		self.link = link
	end
	tooltip:Refresh()
	itemWindow.tooltip = tooltip

	linkLabel:SetHandler("OnMouseUp", function(self, button, upInside, ...)
		if(upInside) then
			ZO_LinkHandler_OnLinkClicked(tooltip.link, button, self)
		end
	end)

	local panel = itemWindow:CreateControl("Controls", CT_CONTROL)
	panel.data = {}
	panel:SetAnchor(TOPLEFT, itemWindow.container, TOPLEFT, 470, 10)
	panel:SetWidth(500)

	local inputs, inputControls = {}, {}
	local function AddInput(type, name, min, max, step, refreshCallback)
		local getFunc = itemLink[("Get%s"):format(name)]
		local setFunc = itemLink[("Set%s"):format(name)]
		inputs[#inputs + 1] = {
			type = type,
			name = name,
			width = "half",
			min = min,
			max = max,
			step = step,
			getFunc = function()
				local value = getFunc(itemLink)
				if(type == "checkbox") then
					value = (value == 1)
				end
				return value
			end,
			setFunc = function(value)
				if(type == "checkbox") then
					value = value and 1 or 0
				end
				setFunc(itemLink, value)
				if(refreshCallback) then
					refreshCallback()
				end
				tooltip:Refresh()
			end,
			reference = ("sidItemView%sInput"):format(name)
		}
	end

	AddInput("editbox", "ItemID", 0, MAX_ITEM_ID, 1)
	AddInput("slider", "Quality", 0, 420, 1)
	AddInput("slider", "Level", 0, 255, 1)
	AddInput("slider", "EnchantmentType", 0, 100000, 1)
	AddInput("slider", "EnchantmentStrength1", 0, 100, 1)
	AddInput("slider", "EnchantmentStrength2", 0, 100, 1)
	for i = 7, 15 do
		AddInput("slider", "Field" .. i, 0, 100, 1)
	end
	AddInput("slider", "Style", 0, 100, 1)
	AddInput("checkbox", "Crafted")
	AddInput("slider", "Bound", 0, 10, 1)
	AddInput("checkbox", "Stolen")
	AddInput("slider", "Condition", 0, 100000, 1)
	AddInput("editbox", "InstanceData", 0, 100000, 1)
	AddInput("editbox", "Link", nil, nil, nil, function()
		for i = 1, #inputControls - 1 do
			local data, control = inputs[i], inputControls[i]
			local value = itemLink[("Get%s"):format(data.name)](itemLink)
			if(data.type == "checkbox") then
				value = (value == 1)
			end
			control:UpdateValue(false, value)
			if(data.type == "editbox") then
				control.editbox:SetText(value)
			end
		end
	end)

	zo_callLater(function()
		local lcc = LAMCreateControl
		local constructor, control, data
		local lastControl = panel
		for i = 1, #inputs do
			if(i == 12) then
				lastControl = panel
			end
			data = inputs[i]
			constructor = lcc[data.type]
			control = constructor(panel, data, data.reference)
			control:SetAnchor(TOPLEFT, lastControl, (i == 1 or i == 12) and TOPLEFT or BOTTOMLEFT, (i == 12) and 280 or 0, 5)
			lastControl = control
			inputControls[i] = control
		end

		local itemIDInput = sidItemViewItemIDInput
		function itemWindow:SetItemID(id)
			itemIDInput:UpdateValue(false, id)
			itemIDInput.editbox:SetText(id)
		end

		InitializeItemList(itemWindow)
	end, 1)

    local itemsCmd = sidTools.itemsCmd

    local showCmd = itemsCmd:RegisterSubCommand()
    showCmd:AddAlias("show")
    showCmd:SetCallback(function()
        itemWindow:SetHidden(false)
    end)
    showCmd:SetDescription("Show the item viewer window")

    local hideCmd = itemsCmd:RegisterSubCommand()
    hideCmd:AddAlias("hide")
    hideCmd:SetCallback(function()
        itemWindow:SetHidden(true)
    end)
    hideCmd:SetDescription("Hide the item viewer window")

    local function ToggleItemViewer()
        if(itemWindow:IsHidden()) then
            showCmd()
        else
            hideCmd()
        end
    end
    sidTools.ToggleItemViewer = ToggleItemViewer

    itemsCmd:SetCallback(ToggleItemViewer)
end

sidTools.InitializeItemViewer = Initialize
