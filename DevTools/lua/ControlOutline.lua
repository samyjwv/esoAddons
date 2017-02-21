
local LAM2 = LibStub("LibAddonMenu-2.0")
local ADDON_NAME	= "DevTools"
local CODE_VERSION 	= 1.5

--===================================--
--===================================--
local SAVED_VAR_VERSION = 1.3
--===================================--
--===================================--
	
local ControlOutline = {
	pool = {},
	outlinedControls = {},
}

local function GetNextEdgeColorKey(edgeColorKey)
	local numColors = ControlOutline.sv["NUM_EDGE_COLORS"]
	
	local newKey = (edgeColorKey % numColors) + 1
	return (edgeColorKey % numColors) + 1
end

--===================================================--
--======== Create Control Outline =========--
--===================================================--
function ControlOutline:CreateOutline(control, edgeColorKey)
	-- Does an outline already exist
	local controlKey = control.ControlOutlinePoolKey
	if controlKey then return false end
	
	local outlineTLW, iKey = ControlOutline.pool:AcquireObject()
	local outlineControl = outlineTLW:GetNamedChild("Outline")
	
	-- Save the key in the control & save a reference to the control
	-- for clearing it out later
	control.ControlOutlinePoolKey = iKey
	ControlOutline.outlinedControls[iKey] = control
	
	outlineTLW:ClearAnchors()
	outlineTLW:SetAnchor(TOPLEFT, control, TOPLEFT)
	outlineTLW:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT)
	
	if self.sv["CHILD_OUTLINES"] then
		outlineTLW:SetParent(control)
	end
	
	local edgeColorKey = edgeColorKey or 1
	local edgeColorTable = self.sv["EDGE_COLORS"][edgeColorKey]
	
	outlineControl:SetEdgeColor(unpack(edgeColorTable))
	outlineControl:SetEdgeTexture(nil, 2, 2, self.sv["EDGE_SIZE"], 0)
end

--===================================================--
--======== GetChildren() =========--
--===================================================--
function ControlOutline:GetChildren(control)
	if not control.GetChildren then
		control.GetChildren = control.GetChildren or function(self)
			local children = {}
			local numChildren = self:GetNumChildren()
			
			for childIndex=1, numChildren do
				local child = self:GetChild(childIndex)
				if child then
					children[childIndex] = child
				end
			end
			return children
		end
	end
	
	return control:GetChildren()
end

--===================================================--
--======== Outline Controls =========--
--===================================================--
function ControlOutline_ToggleOutline()
	local control = moc()
	if control == GuiRoot then return end
	
	local controlKey = control.ControlOutlinePoolKey
	if controlKey then
		ControlOutline.pool:ReleaseObject(controlKey)
		control.ControlOutlinePoolKey = nil
		ControlOutline.outlinedControls[controlKey] = nil
		return
	end
	
	-- Outline parent control
	ControlOutline:CreateOutline(control, 1)
end

function ControlOutline:OutlineControlAndChildren(control, edgeColorKey)
	local edgeColorKey = edgeColorKey or 1
	local children = self:GetChildren(control)
	
	-- Outline Children first
	for k,childControl in pairs(children) do
		local nextEdgeColorKey = GetNextEdgeColorKey(edgeColorKey)
		
		self:OutlineControlAndChildren(childControl, nextEdgeColorKey)
	end
	
	-- Outline parent control
	if self.sv["OUTLINE_HIDDEN_CONTROLS"] or not control:IsHidden() then
		self:CreateOutline(control, edgeColorKey)
	end
end

--===================================================--
--======== Starting moc() Function =========--
--===================================================--
function ControlOutline_OutlineParentChildControls()
	local control = moc()
	if control == GuiRoot then return end
	
	ControlOutline:OutlineControlAndChildren(control)
end

--===================================================--
--======== Release =========--
--===================================================--
function ControlOutline_ReleaseAllOutlines()
	ControlOutline.pool:ReleaseAllObjects()
	
	local outlinedControls = ControlOutline.outlinedControls
	for controlKey, control in pairs(outlinedControls) do
		control.ControlOutlinePoolKey = nil
	end
	ControlOutline.outlinedControls = {}
end

-------------------------------------------------------------------
--  On Player Activation  --
-------------------------------------------------------------------
function ControlOutline:Initialize()
	
	--===== Control Pool =====--
	ControlOutline.pool = ZO_ControlPool:New("ControlOutline_DevOutline", nil)
	local function CustomPoolResetBehavior(control)
		control:SetParent(nil)
	end
	ControlOutline.pool:SetCustomResetBehavior(CustomPoolResetBehavior)
	
	--===== Saved Vars =====--
	local defaultSavedVars = {
		["OUTLINE_HIDDEN_CONTROLS"] = false,
		["CHILD_OUTLINES"] 			= true,
		["EDGE_SIZE"] 				= 4,
		["NUM_EDGE_COLORS"] 		= 3,
		["EDGE_COLORS"] = {
			[1] = {1, 0, 0, 1},	-- Red
			[2] = {0, 1, 0, 1},	-- Green
			[3] = {0, 0, 1, 1},	-- Blue
			[4] = {1, 1, 0, 1},	-- Yellow
			[5] = {0, 1, 1, 1},	-- Cyan
			[6] = {1, 1, 1, 1},	-- White
		},
	}
	self.sv = ZO_SavedVars:New("ControlOutlineSavedVars", SAVED_VAR_VERSION, nil, defaultSavedVars)
	
	--==== Settings Menu ====--
	self:CreateSettingsMenu()
end
-------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------
local function OnAddOnLoaded(event, addonName)
	if addonName == ADDON_NAME then
		ControlOutline:Initialize()
	end
end

---------------------------------------------------------------------
--  Register Events --
---------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

--==============================--
--======  Settings Menu =======--
--==============================--
function ControlOutline:CreateSettingsMenu()
	local panelData = {
		type = "panel",
		name = "Control Outlines",
		displayName = "|cFF0000 Circonians |c00FFFF Control Outlines",
		author = "Circonian",
		version = CODE_VERSION,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Circonians_Control_Outline", panelData)
	
	local optionsData = {
		[1] = {
			type = "checkbox",
			name = "Outline Hidden Controls",
			tooltip = "When OFF it will only outline controls that are not hidden. When ON it will outline all controls whether they are visible or not (can slow things down).",
			default = false,
			getFunc = function() return ControlOutline.sv["OUTLINE_HIDDEN_CONTROLS"] end,
			setFunc = function(bValue) ControlOutline.sv["OUTLINE_HIDDEN_CONTROLS"] = bValue end,
		},
		[2] = {
			type = "checkbox",
			name = "Child Outlines",
			tooltip = "When ON the outlines will become children of the control they are outlining. This will allow them to be shown/hidden with the parent, BUT on some game controls it can cause errors to occur.",
			default = false,
			getFunc = function() return ControlOutline.sv["CHILD_OUTLINES"] end,
			setFunc = function(bValue) ControlOutline.sv["CHILD_OUTLINES"] = bValue end,
		},
		[3] = {
			type = "slider",
			name = "Edge Size",
			tooltip = "Adjust the size/thickness of the outline.",
			min = 1,
			max = 6,
			step = 1,
			default = 4,
			getFunc = function() return ControlOutline.sv["EDGE_SIZE"] end,
			setFunc = function(iValue) ControlOutline.sv["EDGE_SIZE"] = iValue end,
		},
		[4] = {
			type = "slider",
			name = "Number Of Edge Colors",
			tooltip = "When greater than 1: the edge colors will alternate using this many colors. The parent will use the 1st edge color, its children will use the 2nd edge color, those childrens children will use the 3rd edge color, exc...",
			min = 1,
			max = 6,
			step = 1,
			default = 1,
			getFunc = function() return ControlOutline.sv["NUM_EDGE_COLORS"] end,
			setFunc = function(iValue) ControlOutline.sv["NUM_EDGE_COLORS"] = iValue end,
		},
		[5] = {
			type = "submenu",
			name = "Edge Colors",
			controls = {
				[1] = {
					type = "colorpicker",
					name = "First Edge Color",
					tooltip = "Changes the first level outline color.",
					getFunc = function() return unpack(ControlOutline.sv["EDGE_COLORS"][1]) end,
					setFunc = function(r,g,b,a) ControlOutline.sv["EDGE_COLORS"][1] = {r,g,b,a} end,
				},
				[2] = {
					type = "colorpicker",
					name = "Second Edge Color",
					tooltip = "Changes the second level outline color.",
					getFunc = function() return unpack(ControlOutline.sv["EDGE_COLORS"][2]) end,
					setFunc = function(r,g,b,a) ControlOutline.sv["EDGE_COLORS"][2] = {r,g,b,a} end,
				},
				[3] = {
					type = "colorpicker",
					name = "Third Edge Color",
					tooltip = "Changes the third level outline color",
					getFunc = function() return unpack(ControlOutline.sv["EDGE_COLORS"][3]) end,
					setFunc = function(r,g,b,a) ControlOutline.sv["EDGE_COLORS"][3] = {r,g,b,a} end,
				},
				[4] = {
					type = "colorpicker",
					name = "Fourth Edge Color",
					tooltip = "Changes the third level outline color.",
					getFunc = function() return unpack(ControlOutline.sv["EDGE_COLORS"][4]) end,
					setFunc = function(r,g,b,a) ControlOutline.sv["EDGE_COLORS"][4] = {r,g,b,a} end,
				},
				[5] = {
					type = "colorpicker",
					name = "Fifth Edge Color",
					tooltip = "Changes the fifth level outline color.",
					getFunc = function() return unpack(ControlOutline.sv["EDGE_COLORS"][5]) end,
					setFunc = function(r,g,b,a) ControlOutline.sv["EDGE_COLORS"][5] = {r,g,b,a} end,
				},
				[6] = {
					type = "colorpicker",
					name = "Sixth Edge Color",
					tooltip = "Changes the sixth level outline color.",
					getFunc = function() return unpack(ControlOutline.sv["EDGE_COLORS"][6]) end,
					setFunc = function(r,g,b,a) ControlOutline.sv["EDGE_COLORS"][6] = {r,g,b,a} end,
				},
			},
		},
	}
	LAM2:RegisterOptionControls("Circonians_Control_Outline", optionsData)
end

 