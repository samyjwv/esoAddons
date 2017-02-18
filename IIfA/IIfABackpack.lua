local IIfA = IIfA

local LMP = LibStub("LibMediaProvider-1.0")

IIfA.ScrollSortUp = true
IIfA.ActiveFilter = 0
IIfA.ActiveSubFilter = 0
IIfA.InventoryFilter = "All"

IIfA.InventoryListFilter = "All"

-- Get pointer to current settings based on user pref (global or per char)
function IIfA:GetSettings()
	if IIfA.data.saveSettingsGlobally then return IIfA.data end
	return IIfA.settings
end

-- this is for the dropdown menu
function IIfA:GetInventoryListFilter()
	if not IIfA.InventoryListFilter then return "All" end
	return IIfA.InventoryListFilter
end


-- this is for the buttons
local function enableFilterButton(num)
	local buttonName = "Button"..num
    local button = IIFA_GUI_Header_Filter:GetNamedChild(buttonName)
    if button then
        button:SetState(BSTATE_PRESSED)
    end
end
local function disableFilterButton(num)
    local button = IIFA_GUI_Header_Filter:GetNamedChild("Button"..num)
    if button then
        button:SetState(BSTATE_NORMAL)
    end
end

function IIfA:GetActiveFilter()
	if not IIfA.ActiveFilter then return 0 end
	return tonumber(IIfA.ActiveFilter)
end

function IIfA:SetActiveFilter(value)
	if value == nil then
		value = 0
	else
		value = tonumber(value)
	end
	local currentFilter = IIfA:GetActiveFilter()

	if tonumber(currentFilter) == value then
		value = 0
	end

	IIfA.ActiveFilter = value
	if currentFilter ~= value then
		disableFilterButton(currentFilter)
	end

	enableFilterButton(value)

	IIfA:UpdateScrollDataLinesData()

end

function IIfA:GetActiveSubFilter()
	if not IIfA.activeSubFilter then return 0 end
	return tonumber(IIfA.activeSubFilter)
end

function IIfA:SetActiveSubFilter(value)
	value = tonumber(value)
	if IIfA.GetActiveSubFilter() == value then
		IIfA.activeSubFilter = 0
	else
		IIfA.activeSubFilter = value
	end
	IIfA:UpdateScrollDataLinesData()
end


function IIfA:SetInventoryListFilter(value)
	if not value or value == "" then value = "All" end
	IIfA.InventoryListFilter = value

	IIfA.searchFilter = IIFA_GUI_SearchBox:GetText()

	IIfA:UpdateScrollDataLinesData()
	IIfA:UpdateInventoryScroll()
end



--[[----------------------------------------------------------------------]]
--[[----------------------------------------------------------------------]]
--[[------ GUI functions  ------------------------------------------------]]

function IIfA:GUIDoubleClick(control)
	if(control.itemLink) then
		if(control.itemLink ~= "") then
			ZO_ChatWindowTextEntryEditBox:SetText(ZO_ChatWindowTextEntryEditBox:GetText() .. zo_strformat(SI_TOOLTIP_ITEM_NAME, control.itemLink))
		end
	end
end

local function getItemLinkFromDB(itemLink, item)
	local iLink = ""
	if zo_strlen(itemLink) < 10 then
		iLink = item.attributes.itemLink
	else
		iLink = itemLink
	end
	return iLink
end


local function DoesInventoryMatchList(locationName, location)
	if locationName == "attributes" then return false end
	if( IIfA.InventoryListFilter == "All" ) then return true
	elseif(IIfA.InventoryListFilter == "All Banks") then
		return (location.bagID == BAG_BANK or location.bagID == BAG_GUILDBANK)
	elseif(IIfA.InventoryListFilter == "All Guild Banks") then
		return (location.bagID == BAG_GUILDBANK)
	elseif(IIfA.InventoryListFilter == "All Characters") then
		return (location.bagID == BAG_BACKPACK or location.bagID == BAG_WORN)
	elseif(IIfA.InventoryListFilter == "Bank and Characters") then
		return ( location.bagID == BAG_BANK
			or location.bagID == BAG_BACKPACK
			or location.bagID == BAG_WORN)
	elseif(IIfA.InventoryListFilter == "Bank and Current Character") then
		return ( location.bagID == BAG_BANK
			or (location.bagID == BAG_BACKPACK
			or location.bagID == BAG_WORN) and locationName == IIfA.currentCharacterId)
	elseif(IIfA.InventoryListFilter == "Bank Only") then
		return (location.bagID == BAG_BANK)
	elseif(IIfA.InventoryListFilter == "Craft Bag") then
		return (location.bagID == BAG_VIRTUAL)
	else --Not a preset, must be a specific guildbank or character
		if location.bagID == BAG_BACKPACK or location.bagID == BAG_WORN then
			-- it's a character name, convert to Id, check that against location Name in the dbv2 table
			if locationName == IIfA.CharNameToId[IIfA.InventoryListFilter] then return true end
		else
			-- it's a bank to compare, do it direct
			if locationName == IIfA.InventoryListFilter then return true end
		end
	end
end

local function matchCurrentInventory(locationName)
	if locationName == "attributes" then return false end
	local accountInventoryList = IIfA:GetAccountInventoryList()

	for i, inventoryName in ipairs(accountInventoryList) do
		if inventoryName == locationName then return true end
	end

	return (IIfA:GetInventoryListFilter() == "All")
end

local function matchFilter(itemName, itemLink)
    local ret = true
	local itemMatch = false

	local searchFilter = IIfA.searchFilter
    if not searchFilter then searchFilter = "" end
	searchFilter = string.lower(searchFilter)
    local name = string.lower(itemName)
    if not name then name = "" end

	-- text filter takes precedence
	ret = (string.match(name, searchFilter) ~= nil)
	local bWorn = false
	local equipType = 0
	local itemType = 0
	local subType

	if IIfA.filterGroup ~= "All" and ret then		-- it's not everything, and text search matches, filter by some more stuff
		if IIfA.filterGroup == "Weapons" or
			IIfA.filterGroup == "Consumable" or
			IIfA.filterGroup == "ConsumableRecipe" or
			IIfA.filterGroup == "Materials" or
			IIfA.filterGroup == "Misc" or
			IIfA.filterGroup == "Body" then
			if IIfA.filterGroup == "Weapons" then
				itemType = GetItemLinkWeaponType(itemLink)
			elseif IIfA.filterGroup == "Body" then
				-- Body takes extra arg at beginning of array, if array is used at all
				-- Item type (armor, non-armor)
				-- remaining args are the specific type of equipment
				itemType = 0
				_, _, _, equipType = GetItemLinkInfo(itemLink)
				-- pre-qual any body type item, if it's not wearable, it's not included

				if equipType == EQUIP_TYPE_INVALID or
					equipType == EQUIP_TYPE_POISON or
					equipType == EQUIP_TYPE_MAIN_HAND or
					equipType == EQUIP_TYPE_ONE_HAND or
					equipType == EQUIP_TYPE_TWO_HAND then
					itemType = 0
				elseif IIfA.filterTypes == nil then		-- if we're not searching for something specific
					-- quit searching, we're displaying anything worn
					itemType = 1		-- number doesn't matter
				else
					-- it's a wearable piece of some type
					bWorn = true
					itemType = GetItemLinkArmorType(itemLink)
				end
			elseif	IIfA.filterGroup == "Consumable" or
					IIfA.filterGroup == "ConsumableRecipe" or
					IIfA.filterGroup == "Materials" or
					IIfA.filterGroup == "Misc" then
				itemType = GetItemLinkItemType(itemLink)
				if IIfA.filterGroup == "ConsumableRecipe" then
					if itemType == ITEMTYPE_RECIPE then
						-- figure out if a subtype is selected
						subType = GetItemLinkRecipeCraftingSkillType(itemLink)
					else
						itemType = 0
					end
				end
			end
			if itemType == 0 and not bWorn then		-- it's not worn or armor and no type assigned, ret false
				ret = false
			else
				if IIfA.filterTypes ~= nil then
					if bWorn then
						if itemType == IIfA.filterTypes[1] then
							for i=2, #IIfA.filterTypes do
								if(equipType == IIfA.filterTypes[i]) then
									itemMatch = true
									break
								end
							end
						end
					else
--if name:find("axe of bah") ~= nil then
--	d("found axe")
--	d(subType)
--	d(itemType)
--end
						for i=1, #IIfA.filterTypes do
							if (subType == nil and itemType == IIfA.filterTypes[i]) or
							   (subType ~= nil and subType == IIfA.filterTypes[i]) then
								itemMatch = true
								break
							end
						end
					end
				else
					itemMatch = true
				end
				ret = ret and itemMatch
			end
		elseif IIfA.filterGroup == "Stolen" then
			ret = ret and IsItemLinkStolen(itemLink)
		end
	end
    return ret
end


--sort datalines
local function IIfA_FilterCompareUp(a, b)
	--local _, _, name1 = a.itemLink:match("|H(.-):(.-)|h(.-)|h")
	--local _, _, name2 = b.itemLink:match("|H(.-):(.-)|h(.-)|h")
	local name1 = a.name
	local name2 = b.name
	return (name1 or "") < (name2 or "")
end
local function IIfA_FilterCompareDown(a, b)
	return IIfA_FilterCompareUp(b, a)
end

local function sort(dataLines)
	if dataLines == nil then dataLines = IIFA_GUI_ListHolder.dataLines end

	if (IIfA.ScrollSortUp) then
		dataLines = table.sort(dataLines, IIfA_FilterCompareUp)
	elseif (not IIfA.ScrollSortUp) then
		dataLines = table.sort(dataLines, IIfA_FilterCompareDown)
	end
end

-- fill the shown item list with items that match current filter(s)
function IIfA:UpdateScrollDataLinesData()
	IIfA:DebugOut("UpdateScrollDataLinesData")

	if (not IIfA.searchFilter) or IIfA.searchFilter == "Click to search..." then
		IIfA.searchFilter = IIFA_GUI_SearchBox:GetText()
	end

	local index = 0
	local dataLines = {}
	local DBv2 = IIfA.data.DBv2
	local iLink, itemLink, iconFile, itemQuality, tempDataLine = nil
	local itemTypeFilter, itemCount = 0
	local match = false
	local bWorn = false

	if(DBv2)then
		for itemLink, item in pairs(IIfA.data.DBv2) do
			iLink = getItemLinkFromDB(itemLink, item)

			if (itemLink ~= "") then

				itemTypeFilter = 0
				if (item.attributes.filterType) then
					itemTypeFilter = item.attributes.filterType
				end

				itemCount = 0
				bWorn = false

				for locationName, location in pairs(item) do
					itemCount = itemCount + (location.itemCount or 0)
					if DoesInventoryMatchList(locationName, location) then
						match = true
					end
					if locationName ~= "attributes" then
						bWorn = bWorn or (location.bagID == BAG_WORN)
					end
				end

				tempDataLine = {
					link = iLink, 		-- getItemLinkFromDB(itemLink, item),
					qty = itemCount,
					icon = item.attributes.iconFile,
					name = item.attributes.itemName,
					quality = item.attributes.itemQuality,
					filter = itemTypeFilter,
					worn = bWorn
				}

				if(itemCount > 0) and matchFilter(item.attributes.itemName, iLink) and match then
					table.insert(dataLines, tempDataLine)
				end
				match = false
			end
		end
	end

	IIFA_GUI_ListHolder.dataLines = dataLines
	sort(IIFA_GUI_ListHolder.dataLines)
	IIFA_GUI_ListHolder.dataOffset = 0
	IIfA:UpdateInventoryScroll()
end


local function fillLine(curLine, curItem)
	if curItem == nil then
		curLine.itemLink = ""
		curLine.icon:SetTexture(nil)
		curLine.icon:SetAlpha(0)
		curLine.text:SetText("")
		curLine.qty:SetText("")
		curLine.worn:SetHidden(true)
		curLine.stolen:SetHidden(true)
	else
		local r, g, b, a = 255, 255, 255, 1
		if (curItem.quality) then
			color = GetItemQualityColor(curItem.quality)
			r, g, b, a = color:UnpackRGBA()
		end
		curLine.itemLink = curItem.link
		curLine.icon:SetTexture(curItem.icon)
		curLine.icon:SetAlpha(1)
		local text = zo_strformat(SI_TOOLTIP_ITEM_NAME, curItem.name)
		curLine.text:SetText(text)
		curLine.text:SetColor(r, g, b, a)
		curLine.qty:SetText(curItem.qty)
		curLine.worn:SetHidden(not curItem.worn)
		curLine.stolen:SetHidden(not IsItemLinkStolen(curItem.link))
	end
end

function IIfA:InitializeInventoryLines()
	IIfA:DebugOut("InitializeInventoryLines")

	local curLine, curData
	for i = 1, IIFA_GUI_ListHolder.maxLines do

		curLine = IIFA_GUI_ListHolder.lines[i]
		curData = IIFA_GUI_ListHolder.dataLines[IIFA_GUI_ListHolder.dataOffset + i]
		IIFA_GUI_ListHolder.lines[i] = curLine

		if( curData ~= nil) then
			fillLine(curLine, curData)
		else
			fillLine(curLine, nil)
		end
	end
end

function IIfA:UpdateInventoryScroll()
	local index = 0

	IIfA:DebugOut("UpdateInventoryScroll")

	------------------------------------------------------
	if IIFA_GUI_ListHolder.dataOffset < 0 then IIFA_GUI_ListHolder.dataOffset = 0 end
	if IIFA_GUI_ListHolder.maxLines == nil then
		IIFA_GUI_ListHolder.maxLines = 35
	end
	IIfA:InitializeInventoryLines()

	local total = #IIFA_GUI_ListHolder.dataLines - IIFA_GUI_ListHolder.maxLines
	IIFA_GUI_ListHolder_Slider:SetMinMax(0, total)
end


function IIfA:SetItemCountPosition()
	for i=1, IIFA_GUI_ListHolder.maxLines do
		line = IIFA_GUI_ListHolder.lines[i]
		line.text:ClearAnchors()
		line.qty:ClearAnchors()
		if IIfA:GetSettings().showItemCountOnRight then
			line.qty:SetAnchor(TOPRIGHT, line, TOPRIGHT, 0, 0)
			line.text:SetAnchor(TOPLEFT, line:GetNamedChild("Button"), TOPRIGHT, 18, 0)
			line.text:SetAnchor(TOPRIGHT, line.qty, TOPLEFT, -10, 0)
		else
			line.qty:SetAnchor(TOPLEFT, line:GetNamedChild("Button"), TOPRIGHT, 8, -3)
			line.text:SetAnchor(TOPLEFT, line.qty, TOPRIGHT, 18, 0)
			line.text:SetAnchor(TOPRIGHT, line, TOPLEFT, 0, 0)
		end
	end
end


function IIfA:CreateLine(i, predecessor, parent)
	local line = WINDOW_MANAGER:CreateControlFromVirtual("IIFA_ListItem_".. i, parent, "IIFA_SlotTemplate")

	line.icon = line:GetNamedChild("Button"):GetNamedChild("Icon")
	line.text = line:GetNamedChild("Name")
	line.qty = line:GetNamedChild("Qty")
	line.worn = line:GetNamedChild("IconWorn")
	line.stolen = line:GetNamedChild("IconStolen")

--	line.text:SetText(text)
--	line.itemLink = text
--	text=""

	line:SetHidden(false)
	line:SetMouseEnabled(true)
	line:SetHeight(IIFA_GUI_ListHolder.rowHeight)

	if i == 1 then
		line:SetAnchor(TOPLEFT, IIFA_GUI_ListHolder, TOPLEFT, 0, 0)
		line:SetAnchor(TOPRIGHT, IIFA_GUI_ListHolder, TOPRIGHT, 0, 0)
	else
		line:SetAnchor(TOPLEFT, predecessor, BOTTOMLEFT, 0, 0)
		line:SetAnchor(TOPRIGHT, predecessor, BOTTOMRIGHT, 0, 0)
	end

	line:SetHandler("OnMouseEnter", function(self) IIfA:GuiLineOnMouseEnter(self) end )
	line:SetHandler("OnMouseExit", function(self) IIfA:GuiLineOnMouseExit(self) end )
	line:SetHandler("OnMouseDoubleClick", function(self) IIfA:GUIDoubleClick(self) end )

	return line
end


function IIfA:CreateInventoryScroll()
	IIfA:DebugOut("CreateInventoryScroll")

	IIFA_GUI_ListHolder.dataOffset = 0

	IIFA_GUI_ListHolder.dataLines = {}
	IIFA_GUI_ListHolder.lines = {}
	IIFA_GUI_Header_SortBar.Icon = IIFA_GUI_Header_SortBar:GetNamedChild("_Sort"):GetNamedChild("_Icon")

	--local width = 250 -- IIFA_GUI_ListHolder:GetWidth()
	local text = "       No Collected Data"


	-- we set those to 35 because that's the amount of lines we can show
	-- within the dimension constraints
	IIFA_GUI_ListHolder.maxLines = 35
	local predecessor = nil
	for i=1, IIFA_GUI_ListHolder.maxLines do
		IIFA_GUI_ListHolder.lines[i] = IIfA:CreateLine(i, predecessor, IIFA_GUI_ListHolder)
		predecessor = IIFA_GUI_ListHolder.lines[i]
	end

	if IIfA:GetSettings().showItemCountOnRight then
		IIfA:SetItemCountPosition()
	end

	IIfA:UpdateScrollDataLinesData()

	-- setup slider
--	local tex = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
--	IIFA_GUI_ListHolder_Slider:SetThumbTexture(tex, tex, tex, 16, 50, 0, 0, 1, 1)
	IIFA_GUI_ListHolder_Slider:SetMinMax(0, #IIFA_GUI_ListHolder.dataLines - IIFA_GUI_ListHolder.maxLines)

	return IIFA_GUI_ListHolder.lines
end

function IIfA:GetAccountInventoryList()
	local accountInventories = { "All", "All Banks", "All Guild Banks", "All Characters", "Bank and Characters", "Bank and Current Character", "Bank Only", "Craft Bag" }

-- get character names, will present in same order as character selection screen
	for i=1, GetNumCharacters() do
		local charName, _, _, _, _, _, _, _ = GetCharacterInfo(i)
		charName = charName:sub(1, charName:find("%^") - 1)
		table.insert(accountInventories, charName)
	end

-- banks are same as toons, same order as player normally sees them
	if IIfA.data.bCollectGuildBankData then
		for i = 1, GetNumGuilds() do
			id = GetGuildId(i)
			guildName = GetGuildName(id)

			-- on the off chance that this doesn't exist already, create it
			if IIfA.data.guildBanks == nil then
				IIfA.data.guildBanks = {}
			end

			if IIfA.data.guildBanks[guildName] ~= nil then
				table.insert(accountInventories, guildName)
			end
		end
	end
	return accountInventories
end

function IIfA:QueryAccountInventory(itemLink)
	local queryItem = {
		link = itemLink,
		locations = {},
	}

	local queryItemsFound = 0
	local AlreadySavedLoc = false
	local newLocation = {}

	itemType = GetItemLinkItemType(itemLink)
	if itemType == ITEMTYPE_BLACKSMITHING_MATERIAL or
		itemType == ITEMTYPE_ARMOR_TRAIT or
		itemType == ITEMTYPE_BLACKSMITHING_BOOSTER or
		itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL or
		itemType == ITEMTYPE_CLOTHIER_BOOSTER or
		itemType == ITEMTYPE_CLOTHIER_MATERIAL or
		itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL or
		itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or
		itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or
		itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY or
		itemType == ITEMTYPE_FLAVORING or
		itemType == ITEMTYPE_INGREDIENT or
		itemType == ITEMTYPE_LOCKPICK or
		itemType == ITEMTYPE_LURE or
		itemType == ITEMTYPE_POISON_BASE or
		itemType == ITEMTYPE_POTION_BASE or
		itemType == ITEMTYPE_RAW_MATERIAL or
		itemType == ITEMTYPE_REAGENT or
		itemType == ITEMTYPE_RECIPE or
		itemType == ITEMTYPE_SPICE or
		itemType == ITEMTYPE_STYLE_MATERIAL or
		itemType == ITEMTYPE_WEAPON_TRAIT or
		itemType == ITEMTYPE_WOODWORKING_BOOSTER or
		itemType == ITEMTYPE_WOODWORKING_MATERIAL or
		itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL or
		itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
		itemLink = IIfA:GetItemID(itemLink)
	end

	local item = IIfA.data.DBv2[itemLink]

	-- the database holds all the information about the items. we need to get rid of this check. as soon as we have understood it.
	if ((queryItem.link ~= nil) and (item ~= nil)) then
		for locationName, location in pairs(item) do
			if (locationName ~= "attributes") then
				AlreadySavedLoc = false
				if location.bagID == BAG_WORN or location.bagID == BAG_BACKPACK then
					locationName = IIfA.CharIdToName[locationName]
				end
				for x, QILocation in pairs(queryItem.locations) do
					if (QILocation.name == locationName)then
						QILocation.itemsFound = QILocation.itemsFound + location.itemCount
						AlreadySavedLoc = true
					end
				end
				if location.itemCount then
					if (not AlreadySavedLoc) and (location.itemCount > 0) then
						newLocation = {}
						newLocation.name = locationName
						newLocation.itemsFound = location.itemCount
						if location.bagID == BAG_WORN then
							newLocation.worn = true
						end
						table.insert(queryItem.locations, newLocation)
					end
				end
			end
		end
	end
	return queryItem
end

function IIfA:CreateInventoryDropdown()
	local comboBox

	if IIFA_GUI_Header_Dropdown.comboBox ~= nil then
		comboBox = IIFA_GUI_Header_Dropdown.comboBox
	else
		comboBox = ZO_ComboBox_ObjectFromContainer(IIFA_GUI_Header_Dropdown)
		IIFA_GUI_Header_Dropdown.comboBox = comboBox
	end

	function OnItemSelect(_, choiceText, choice)
--		d("OnItemSelect", choiceText, choice)
		IIfA:SetInventoryListFilter(choiceText)
	  	PlaySound(SOUNDS.POSITIVE_CLICK)
	end

	comboBox:SetSortsItems(false)

	local validChoices =  IIfA:GetAccountInventoryList()

	for i = 1, #validChoices do
       	entry = comboBox:CreateItemEntry(validChoices[i], OnItemSelect)
		comboBox:AddItem(entry)
		if validChoices[i] == IIfA:GetInventoryListFilter() then
			comboBox:SetSelectedItem(validChoices[i])
		end
	end

	return IIFA_GUI_Header_Dropdown
end

function IIfA:SetSceneVisible(name, value)
	IIfA:GetSettings().frameSettings[name].hidden = not value
end

function IIfA:GetSceneVisible(name)
	if IIfA:GetSettings().frameSettings then
		return (not IIfA.GetSettings().frameSettings[name].hidden)
	else
		return true
	end
end

function IIfA:SetupBackpack()
	IIfA.InventoryListFilter = IIfA.data.in2DefaultInventoryFrameView
	IIfA:CreateInventoryScroll()
	IIfA:CreateInventoryDropdown()
	IIfA:GuiOnSort(true)
end

