local ADDON_NAME	= "AddonSelector"
local AddonSelector = {}
local CODE_VERSION	= 1.424
local lang = GetCVar("language.2")
local langArray = {
	["en"] = {
		["packName"]			= "Pack name:",
		["selectPack"]			= "Select pack:",
    	["ERRORpackMissing"] 	= "ADDON SELECTOR: Pack name missing.",
        ["autoReloadUIHint"]	= "Auto-Reload UI on pack selection.",
        ["autoReloadUIHintTooltip"] = "Auto-Reload UI: When ON this will prevent editing addon packs. You will need to turn it off to edit packs.",
        ["saveButton"]			= "Save",
        ["deleteButton"]		= "Delete",
    },
	["fr"] = {
		["packName"]			= "Nom du paquet:",
		["selectPack"]			= "Sélectionnez paquet:",
    	["ERRORpackMissing"] 	= "ADDON SELECTOR: Nom du paquet manquant.",
        ["autoReloadUIHint"]	= "Auto-Reload UI sur la sélection de paquets",
        ["autoReloadUIHintTooltip"] = "Auto-Reload UI: Lorsque ON cela empêchera l'édition du paquets d'addon . Vous aurez besoin de le désactiver pour modifier les paquets.",
        ["saveButton"]			= "Sauvegarder",
        ["deleteButton"]		= "Effacer",
    },
	["de"] = {
		["packName"]			= "Pack Name:",
		["selectPack"]			= "Pack wählen:",
    	["ERRORpackMissing"] 	= "ADDON SELECTOR: Pack Name fehlt.",
        ["autoReloadUIHint"]	= "Autom. Reload UI nach Pack Auswahl!",
        ["autoReloadUIHintTooltip"] = "Auto-Reload UI: Wenn diese Option aktiviert wurde können keine AddOn Packs geändert werden. Sie müssen diese Option deaktivieren, um AddOn Packs ändern zu können.",
        ["saveButton"]			= "Sichern",
        ["deleteButton"]		= "Löschen",
    },
	["ru"] = {
        ["packName"]            = "Îaçáaîèe:",
        ["selectPack"]          = "Áÿàop:",
        ["ERRORpackMissing"]    = "ADDON SELECTOR: Îeò Îaçáaîèü äìü îaàopa.",
        ["autoReloadUIHint"]    = "Ïepeçaâpóçèòö UI ïpè ïepeêìôùeîèè îaàopa.",
        ["autoReloadUIHintTooltip"] = "Aáòo-ïepeçaâpóçêa UI: Ecìè còoèò âaìêa, òo áêìôùaeòcü çaïpeò îa peäaêòèpoáaîèe îaàopoá. Áaí îóæîo cîüòö âaìêó äìü peäaêòèpoáaîèü.",
        ["saveButton"]          = "Coxpaîèòö",
        ["deleteButton"]        = "Óäaìèòö",
    },
}

-- Toggles Enabled state when a row is clicked
local function Addon_Toggle_Enabled(rowControl)
	local addonIndex 	= rowControl.data.index
	local enabledBtn 	= rowControl:GetNamedChild("Enabled")
	local state 		= ZO_TriStateCheckButton_GetState(enabledBtn)
	
	if state == TRISTATE_CHECK_BUTTON_CHECKED then
		-- changed so it automatically refreshes the multiButton (reload UI)
		--ADD_ON_MANAGER:ChangeEnabledState(addonIndex, TRISTATE_CHECK_BUTTON_UNCHECKED)
		ADD_ON_MANAGER:OnEnabledButtonClicked(enabledBtn, TRISTATE_CHECK_BUTTON_UNCHECKED)
		return
	end
	--ADD_ON_MANAGER:ChangeEnabledState(addonIndex, TRISTATE_CHECK_BUTTON_CHECKED)
	ADD_ON_MANAGER:OnEnabledButtonClicked(enabledBtn, TRISTATE_CHECK_BUTTON_CHECKED)
end

-- When an item is selected in the comboBox go through all available
-- addons & compare them against the selected addon pack.
-- Enable all addons that are in the selected addon pack, disable the rest.
local function OnClickDDL(comboBox, packName, packData, selectionChanged)
	-- Clear the edit box:
	AddonSelector.editBox:Clear()
	
	local addonTable = packData.addonTable
	local scrollListData = ZO_ScrollList_GetDataList(ZO_AddOnsList)
	
	for k, addonData in pairs(scrollListData) do
		local fileName = addonData.data.addOnFileName
		local addonIndex = addonData.data.index
		
		if packData.addonTable[fileName] then
			ADD_ON_MANAGER:ChangeEnabledState(addonIndex, TRISTATE_CHECK_BUTTON_CHECKED)
		else
			ADD_ON_MANAGER:ChangeEnabledState(addonIndex, TRISTATE_CHECK_BUTTON_UNCHECKED)
		end
	end
	if AddonSelector.acwsv.autoReloadUI == BSTATE_PRESSED then
		ReloadUI("ingame")
	else
		ADD_ON_MANAGER:RefreshData()
		ADD_ON_MANAGER.isDirty = true
		ADD_ON_MANAGER:RefreshMultiButton()
	end
end

-- Create ItemEntry table for the ddl
function AddonSelector:CreateItemEntry(packName, addonTable)
	return {name = packName, callback = OnClickDDL, addonTable = addonTable}
end

-- Called on load or when a new addon pack is saved & added to the comboBox
-- Clear & re-add all items, including new ones. Easier/quicker than
-- trying to see if an item already exists & editing it, just Adding 
-- a new item would result in duplicates when editing a pack.
function AddonSelector:UpdateDDL()
	local addonPacks = AddonSelector.acwsv.addonPacks
	local packTable = {}
		
	for packName, addonTable in pairs(addonPacks) do
		local itemData = self:CreateItemEntry(packName, addonTable)
		table.insert(packTable, itemData)
	end
	self.comboBox:ClearItems()
	self.comboBox:AddItems(packTable)
end

-- On text changed, when user types in the editBox
-- Clear the comboBox, check to make sure the text is not empty
-- I don't want it clearing the ddl when I manually call editBox:Clear()
function AddonSelector_TextChanged(self)
	local newText = self:GetText()
	
	if newText and newText ~= "" then
		local comboBox = AddonSelector.comboBox
		comboBox:SetSelectedItem("")
		comboBox.m_selectedItemData = nil
	end
end

-- called from clicking the label
local function OnClick_AutoReloadLabel(self, button, upInside, ctrl, alt, shift, command)
	if not upInside then return end
	if not button == 1 then return end
	
	local autoReloadBtn = AddonSelector.autoReloadBtn
	local curReloadState = autoReloadBtn:GetState()
	local newState = BSTATE_PRESSED
	
	if curReloadState ~= BSTATE_NORMAL then
		newState = BSTATE_NORMAL
	end
	
	AddonSelector.acwsv.autoReloadUI = newState
	autoReloadBtn:SetState(newState)
end
-- called from clicking the button
local function OnClick_AutoReload(self, button, upInside, ctrl, alt, shift, command)
	if not upInside then return end
	if not button == 1 then return end
	
	AddonSelector.acwsv.autoReloadUI = self:GetState()
end
-- When the save button is clicked, creates a table containing all
-- enabled addons:  { [AddOnFileName] = AddonStrippedName, ...}
local function OnClick_Save()
	local aad = ZO_ScrollList_GetDataList(ZO_AddOnsList)
	local packName = AddonSelector.editBox:GetText()
	
	if not packName or packName == "" then
		local itemData = AddonSelector.comboBox:GetSelectedItemData()
		if not itemData then
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, langArray[lang]["ERRORpackMissing"] or langArray["en"]["ERRORpackMissing"])
			return
		end
		packName = itemData.name
	end
	
	-- Create the pack table or nil it out if it exists:
	AddonSelector.acwsv.addonPacks[packName] = {}
	
	-- Add all of the enabled addOn to the pack table
	for k, addonData in pairs(aad) do
		local data = addonData.data
		local isEnabled = data.addOnEnabled
		
		if isEnabled then
			local fileName = data.addOnFileName
			local addonName = data.strippedAddOnName
			
			AddonSelector.acwsv.addonPacks[packName][fileName] = addonName
		end
	end
	-- Create a temporary copy of the itemEntry data so we can select it
	-- after the ddl is updated
	local addonTable = AddonSelector.acwsv.addonPacks[packName]
	local itemData = AddonSelector:CreateItemEntry(packName, addonTable)
	
	AddonSelector.editBox:Clear()
	AddonSelector:UpdateDDL()
	AddonSelector.comboBox:SelectItem(itemData)
end

-- When delete is clicked, remove the selected addon pack
local function OnClick_Delete()
	local itemData = AddonSelector.comboBox:GetSelectedItemData()
	if not itemData then 
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "ADDON SELECTOR: You must select a pack to delete.")
		return 
	end
	
	local selectedPackName = itemData.name
	
	AddonSelector.acwsv.addonPacks[selectedPackName] = nil
	
	AddonSelector:UpdateDDL()
	AddonSelector.editBox:Clear()
end

-- Used to change the layout of the Addon scrollList to
-- make room for the AddonSelector control
function AddonSelector:ChangeLayout()
	local template = ZO_AddOns
	local divider = ZO_AddOnsDivider
	local list = ZO_AddOnsList
	local bg = ZO_AddonsBGLeft
	list:ClearAnchors()
	list:SetAnchor(TOPLEFT, self.addonSelector, BOTTOMLEFT, 0, 10)
	-- This does not work ?? Items get cut off. 
	--list:SetAnchor(BOTTOMRIGHT, bg, BOTTOMRIGHT, -20, -100)
	--list:SetDimensions(885, 560)
	ZO_ScrollList_SetHeight(ZO_AddOnsList, 600)
	ZO_ScrollList_Commit(ZO_AddOnsList)
end

-- Create the AddonSelector control, set references to controls
-- and click handlers for the save/delete buttons
function AddonSelector:CreateControlReferences()
	-- Create Controls:
    local addonSelector = CreateControlFromVirtual("AddonSelector", ZO_AddOns, "AddonSelector")
	
	-- Assign references:
	self.addonSelector = addonSelector
	
	self.editBox 	= addonSelector:GetNamedChild("EditBox")
	self.ddl 		= addonSelector:GetNamedChild("ddl")
	self.comboBox	= self.ddl.m_comboBox
	self.saveBtn 	= addonSelector:GetNamedChild("Save")
	self.deleteBtn 	= addonSelector:GetNamedChild("Delete")
	self.autoReloadBtn = addonSelector:GetNamedChild("AutoReloadUI")
	self.autoReloadLabel = self.autoReloadBtn:GetNamedChild("Label")
	
	-- Set Saved Btn State:
	local checkedState = AddonSelector.acwsv.autoReloadUI
	self.autoReloadBtn:SetState(checkedState)
	
	-- Add Tooltips for AutoReloadUI
	local function OnMouseEnter()
		local toolTipText = langArray[lang]["autoReloadUIHintTooltip"] or langArray["en"]["autoReloadUIHintTooltip"]
		InitializeTooltip(InformationTooltip, self.autoReloadLabel, LEFT, 26, 0, RIGHT)
		InformationTooltip:AddLine(toolTipText)
	end
	local function OnMouseExit()
		ClearTooltip(InformationTooltip)
	end
	
	-- SetHandlers:
	self.saveBtn:SetHandler("OnMouseUp", OnClick_Save)
	self.deleteBtn:SetHandler("OnMouseUp", OnClick_Delete)
	self.autoReloadBtn:SetHandler("OnMouseUp", OnClick_AutoReload)
	self.autoReloadLabel:SetHandler("OnMouseUp", OnClick_AutoReloadLabel)
	self.autoReloadBtn:SetHandler("OnMouseEnter", OnMouseEnter)
	self.autoReloadBtn:SetHandler("OnMouseExit", OnMouseExit)
	self.autoReloadLabel:SetHandler("OnMouseEnter", OnMouseEnter)
	self.autoReloadLabel:SetHandler("OnMouseExit", OnMouseExit)
end


---[[
local OrigAddonGetRowSetupFunc = ZO_AddOnManager.GetRowSetupFunction
function ZO_AddOnManager:GetRowSetupFunction()
	local func = OrigAddonGetRowSetupFunc(self)
	
    return function(control, data)
			control:SetMouseEnabled(true)
			control:SetHandler("OnMouseUp", Addon_Toggle_Enabled)
			func(control, data)
		end
end
--]]

--====================================--
--====  Initialize ====--
--====================================--
function AddonSelector:Initialize()
	local SAVED_VAR_VERSION = 1
	local defaultSavedVars = {
		addonPacks = {},
		autoReloadUI = BSTATE_NORMAL,
	}
	self.acwsv = ZO_SavedVars:NewAccountWide("AddonSelectorSavedVars", SAVED_VAR_VERSION, nil, defaultSavedVars)
	
	self:CreateControlReferences()
	self:UpdateDDL()
	self:ChangeLayout()
	
	-- Very hacky, but easiest method: Wipe out the games 
	-- TYPE_ID = 1 dataType and recreate it using my own template.
	-- Done to make the row controls mouseEnabled
	ADD_ON_MANAGER.list.dataTypes = {}
	ZO_ScrollList_AddDataType(ADD_ON_MANAGER.list, 1, "ZO_AddOnRow", 30, ADD_ON_MANAGER:GetRowSetupFunction())

    --Change the description texts now
    AddonSelectorNameLabel:SetText(langArray[lang]["packName"] or langArray["en"]["packName"])
    AddonSelectorSave:SetText(langArray[lang]["saveButton"] or langArray["en"]["saveButton"])
    AddonSelectorSelectLabel:SetText(langArray[lang]["selectPack"] or langArray["en"]["selectPack"])
    AddonSelectorDelete:SetText(langArray[lang]["deleteButton"] or langArray["en"]["deleteButton"])
    AddonSelectorAutoReloadUILabel:SetText(langArray[lang]["autoReloadUIHint"] or langArray["en"]["autoReloadUIHint"])
end
-------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------
local function OnAddOnLoaded(event, addonName)
	if addonName ~= ADDON_NAME then return end
	AddonSelector:Initialize()
	
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

---------------------------------------------------------------------
--  Register Events --
---------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

