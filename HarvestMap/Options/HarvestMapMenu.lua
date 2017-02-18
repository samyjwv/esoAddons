local LMM = LibStub("LibMainMenu")

Menu = {}
Harvest.menu = Menu

function Menu:Initialize()
	-- Set Title
	ZO_CreateStringId("SI_HARVEST_MAIN_MENU_TITLE", "HarvestMap Pin Menu")
	
	-- add controls to the newly created panel
	-- the descriptions and sliders of LibAddonMenu are nice, I'm gonna steal them :)
	HarvestMapInRangeMenu.panel = HarvestMapInRangeMenu
	HarvestMapInRangeMenu.panel.data = {registerForRefresh = true}
	HarvestMapInRangeMenu.panel.controlsToRefresh = {}
	
	self:InitializeWorldControl()
	self:InitializeCompassControl()
	self:InitializeInRangeScene()
	self:InitializeColorScene()
	
	-- binding localization
	ZO_CreateStringId("SI_BINDING_NAME_HARVEST_SHOW_PANEL", "Toggle HarvestMap Pin Menu")
	
	local BASE_MENU_DATA =
	{
		binding = "HARVEST_SHOW_PANEL",
		categoryName = SI_HARVEST_MAIN_MENU_TITLE,
		descriptor = 18,--"HarvestSceneGroup",
		normal = "EsoUI/Art/Inventory/inventory_tabicon_quest_up.dds",
		pressed = "EsoUI/Art/Inventory/inventory_tabicon_quest_down.dds",
		highlight = "EsoUI/Art/Inventory/inventory_tabicon_quest_over.dds",
		callback = function() self:Show(true) end,
	}
	
	local iconData = {
		{
			categoryName = SI_HARVEST_INRANGE_MENU_TITLE,
			descriptor = "HarvestInRangeScene",
			normal = "EsoUI/Art/Inventory/inventory_tabicon_quest_up.dds",
			pressed = "EsoUI/Art/Inventory/inventory_tabicon_quest_down.dds",
			highlight = "EsoUI/Art/Inventory/inventory_tabicon_quest_over.dds",
		},
		-- TODO color menu
		--[[
		{
			categoryName = SI_HARVEST_COLOR_MENU_TITLE,
			descriptor = "HarvestColorScene",
			normal = "EsoUI/Art/Dye/dyes_toolicon_fill_up.dds",
			pressed = "EsoUI/Art/Dye/dyes_toolicon_fill_down.dds",
			highlight = "EsoUI/Art/Dye/dyes_toolicon_fill_over.dds",
		},
		--]]
        }
	
	self.BASE_MENU = LMM:AddCategory(BASE_MENU_DATA)
	-- Register Scenes and the group name
	self.sceneGroup = ZO_SceneGroup:New("HarvestInRangeScene", "HarvestColorScene")
        SCENE_MANAGER:AddSceneGroup("HarvestSceneGroup", self.sceneGroup)
        -- Register the group and add the buttons
        LMM:AddSceneGroup(self.BASE_MENU, "HarvestSceneGroup", iconData)
	-- add a button to the main menu
	self.mainMenuButton = ZO_MenuBar_AddButton(MAIN_MENU_KEYBOARD.categoryBar, BASE_MENU_DATA)
end

function Menu:InitializeColorScene()
	self.colorScene = ZO_Scene:New("HarvestColorScene", SCENE_MANAGER) 
    
	-- Mouse standard position and background
	self.colorScene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	self.colorScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    
	--  Background Right, it will set ZO_RightPanelFootPrint and its stuff.
	self.colorScene:AddFragment(RIGHT_BG_FRAGMENT)
    
	-- The title fragment
	self.colorScene:AddFragment(TITLE_FRAGMENT)
	
	-- Set Title
	ZO_CreateStringId("SI_HARVEST_COLOR_MENU_TITLE", "Pin Color Menu")
	
	local TITLE_FRAGMENT = ZO_SetTitleFragment:New(SI_HARVEST_MAIN_MENU_TITLE)
	self.colorScene:AddFragment(TITLE_FRAGMENT)
    
	-- Add the XML to our scene
	local MAIN_WINDOW = ZO_FadeSceneFragment:New(HarvestMapColorMenu)
	self.colorScene:AddFragment(MAIN_WINDOW)
	
	self.colorScene:AddFragment(MAIN_MENU_KEYBOARD.categoryBarFragment)
	self.colorScene:AddFragment(TOP_BAR_FRAGMENT)
end

function Menu:InitializeInRangeScene()
	self.inRangeScene = ZO_Scene:New("HarvestInRangeScene", SCENE_MANAGER)   
    
	-- Mouse standard position and background
	self.inRangeScene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	self.inRangeScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    
	--  Background Right, it will set ZO_RightPanelFootPrint and its stuff.
	self.inRangeScene:AddFragment(RIGHT_BG_FRAGMENT)
    
	-- The title fragment
	self.inRangeScene:AddFragment(TITLE_FRAGMENT)
    
	-- Set Title
	ZO_CreateStringId("SI_HARVEST_INRANGE_MENU_TITLE", "Pin Visibility Menu")
	local TITLE_FRAGMENT = ZO_SetTitleFragment:New(SI_HARVEST_MAIN_MENU_TITLE) -- The title at the left of the scene is the "global one" but we can change it
	self.inRangeScene:AddFragment(TITLE_FRAGMENT)
    
	-- Add the XML to our scene
	local MAIN_WINDOW = ZO_FadeSceneFragment:New(HarvestMapInRangeMenu)
	self.inRangeScene:AddFragment(MAIN_WINDOW)
	
	self.inRangeScene:AddFragment(MAIN_MENU_KEYBOARD.categoryBarFragment)
	self.inRangeScene:AddFragment(TOP_BAR_FRAGMENT)
end

function Menu:InitializeCompassControl()
	
	local definition = {
		type = "checkbox",
		name = "Compass Pins",
		getFunc = Harvest.AreCompassPinsVisible,
		setFunc = function(...)
			Harvest.SetCompassPinsVisible(...)
			CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", Harvest.optionsPanel)
		end,
	}
	local control = LAMCreateControl.checkbox(HarvestMapInRangeMenu, definition)
	control:ClearAnchors()
	control:SetAnchor(TOPLEFT, HarvestMapInRangeMenu, TOPLEFT, 340, 20)
	control:SetWidth(300)
	control.container:SetWidth(64)
	local lastControl = control
	
	definition = {
		type = "checkbox",
		name = "Override map pin filter",
		getFunc = Harvest.IsCompassFilterActive,
		setFunc = Harvest.SetCompassFilterActive,
	}
	local control = LAMCreateControl.checkbox(HarvestMapInRangeMenu, definition)
	control:ClearAnchors()
	control:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 40)
	control:SetWidth(300)
	control.container:SetWidth(64)
	lastControl = control
	
	for _, pinTypeId in pairs(Harvest.PINTYPES) do
		if pinTypeId ~= Harvest.TOUR then
			definition = {
				type = "checkbox",
				name = Harvest.GetLocalization( "pintype" .. pinTypeId ),
				disabled = function() return not Harvest.IsCompassFilterActive() end,
				getFunc = function()
					return Harvest.IsCompassPinTypeVisible(pinTypeId)
				end,
				setFunc = function( value )
					Harvest.SetCompassPinTypeVisible(pinTypeId, value)
				end,
			}
			local control = LAMCreateControl.checkbox(HarvestMapInRangeMenu, definition)
			control:ClearAnchors()
			control:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 20)
			control:SetWidth(300)
			control.container:SetWidth(64)
			lastControl = control
		end
	end
end

function Menu:InitializeWorldControl()
	
	local definition = {
		type = "checkbox",
		name = "3D Pins",
		getFunc = Harvest.AreWorldPinsVisible,
		setFunc = function(...)
			Harvest.SetWorldPinsVisible(...)
			CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", Harvest.optionsPanel)
		end,
	}
	local control = LAMCreateControl.checkbox(HarvestMapInRangeMenu, definition)
	control:ClearAnchors()
	control:SetAnchor(TOPLEFT, HarvestMapInRangeMenu, TOPLEFT, 0, 20)
	control:SetWidth(300)
	control.container:SetWidth(64)
	local lastControl = control
	
	definition = {
		type = "checkbox",
		name = "Override map pin filter",
		getFunc = Harvest.IsWorldFilterActive,
		setFunc = Harvest.SetWorldFilterActive,
	}
	local control = LAMCreateControl.checkbox(HarvestMapInRangeMenu, definition)
	control:ClearAnchors()
	control:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 40)
	control:SetWidth(300)
	control.container:SetWidth(64)
	lastControl = control
	
	for _, pinTypeId in pairs(Harvest.PINTYPES) do
		if pinTypeId ~= Harvest.TOUR then
			definition = {
				type = "checkbox",
				name = Harvest.GetLocalization( "pintype" .. pinTypeId ),
				disabled = function() return not Harvest.IsWorldFilterActive() end,
				getFunc = function()
					return Harvest.IsWorldPinTypeVisible(pinTypeId)
				end,
				setFunc = function( value )
					Harvest.SetWorldPinTypeVisible(pinTypeId, value)
				end,
			}
			local control = LAMCreateControl.checkbox(HarvestMapInRangeMenu, definition)
			control:ClearAnchors()
			control:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 20)
			control:SetWidth(300)
			control.container:SetWidth(64)
			lastControl = control
		end
	end
end

function Menu:Show(viaButton)
	if not self.sceneGroup:IsShowing() then
		LMM:ToggleCategory(self.BASE_MENU, viaButton)
	end
end

function Menu:Toggle(viaButton)
	LMM:ToggleCategory(self.BASE_MENU)
	if not viaButton then
		-- when opening the menu via the keybin, we have to reset the main menu buttons
		ZO_MenuBar_ClearSelection(MAIN_MENU_KEYBOARD.categoryBar)
	end
end