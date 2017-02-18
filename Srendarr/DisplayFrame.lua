local Srendarr		= _G['Srendarr'] -- grab addon table from global
local L				= Srendarr:GetLocale()
local Aura			= Srendarr.Aura
local DisplayFrame	= {}

-- CONSTS --
local AURA_TYPE_TIMED		= Srendarr.AURA_TYPE_TIMED
local AURA_TYPE_TOGGLED		= Srendarr.AURA_TYPE_TOGGLED
local AURA_TYPE_PASSIVE		= Srendarr.AURA_TYPE_PASSIVE

local AURA_HEIGHT			= Srendarr.AURA_HEIGHT

local AURA_GROW_UP			= Srendarr.AURA_GROW_UP
local AURA_GROW_DOWN		= Srendarr.AURA_GROW_DOWN
local AURA_GROW_LEFT		= Srendarr.AURA_GROW_LEFT
local AURA_GROW_RIGHT		= Srendarr.AURA_GROW_RIGHT
local AURA_GROW_CENTERLEFT	= Srendarr.AURA_GROW_CENTERLEFT
local AURA_GROW_CENTERRIGHT	= Srendarr.AURA_GROW_CENTERRIGHT

local AURA_SORT_NAMEASC		= Srendarr.AURA_SORT_NAMEASC
local AURA_SORT_TIMEASC		= Srendarr.AURA_SORT_TIMEASC
local AURA_SORT_CASTASC		= Srendarr.AURA_SORT_CASTASC
local AURA_SORT_NAMEDESC	= Srendarr.AURA_SORT_NAMEDESC
local AURA_SORT_TIMEDESC	= Srendarr.AURA_SORT_TIMEDESC
local AURA_SORT_CASTDESC	= Srendarr.AURA_SORT_CASTDESC


-- UPVALUES --
local round					= zo_round
local tsort					= table.sort
local tinsert				= table.insert
local tremove				= table.remove
local AddControl			= Srendarr.AddControl


-- ------------------------
-- SORTING FUNCTIONS
-- ------------------------
local function SortAurasByTimeAsc(a, b)
	if (a.auraType == AURA_TYPE_TIMED and b.auraType == AURA_TYPE_TIMED) then -- timed auras, sort by time
		return a.finish > b.finish
	elseif (a.auraType == b.auraType) then -- non-timed auras, same type, sort by name
		return a.auraName < b.auraName
	else -- non-timed auras, different types, sort by type
		return a.auraType > b.auraType
	end
end

local function SortAurasByNameAsc(a, b)
	return a.auraName < b.auraName
end

local function SortAurasByCastAsc(a, b)
	return a.start < b.start
end

local function SortAurasByTimeDesc(a, b)
	if (a.auraType == AURA_TYPE_TIMED and b.auraType == AURA_TYPE_TIMED) then -- timed auras, sort by time
		return a.finish < b.finish
	elseif (a.auraType == b.auraType) then -- non-timed auras, same type, sort by name
		return a.auraName > b.auraName
	else -- non-timed auras, different types, sort by type
		return a.auraType < b.auraType
	end
end

local function SortAurasByNameDesc(a, b)
	return a.auraName > b.auraName
end

local function SortAurasByCastDesc(a, b)
	return a.start > b.start
end


-- ------------------------
-- DISPLAY FRAME
-- ------------------------
function DisplayFrame:Create(id, point, x, y, alpha, scale)
	local df = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_TOPLEVELCONTROL)
	df:SetKeyboardEnabled(false)
	df:SetMouseEnabled(false)
	df:SetMovable(false)
	df:SetClampedToScreen(true)
	df:SetDimensions(AURA_HEIGHT, AURA_HEIGHT)
	df:SetAnchor(point, GuiRoot, point, x, y)
	df:SetAlpha(alpha)	-- both values, if configured after load, are done directly)
	df:SetScale(scale)	-- both values, if configured after load, are done directly)

	df.displayAlpha	= alpha
	df.displayID	= id

	df:SetHandler('OnReceiveDrag', function(f)
		f:StartMoving()
	end)
	df:SetHandler('OnMouseUp', function(f)
		f:StopMovingOrResizing()
		local point, x, y = Srendarr:GetEdgeRelativePosition(f)
		Srendarr.db.displayFrames[f.displayID].base.point	= point
		Srendarr.db.displayFrames[f.displayID].base.x		= x
		Srendarr.db.displayFrames[f.displayID].base.y		= y
	end)

	df.aurasActive				= {}
	df.aurasInactive			= {}
	df.aurasSorted				= {}
	df.settings					= Srendarr.db.displayFrames[id]

	-- aura handling
	df['AddAuraToDisplay']		= DisplayFrame.AddAuraToDisplay
	df['OnAuraReleased']		= DisplayFrame.OnAuraReleased
	df['ConfigureAssignedAuras']= DisplayFrame.ConfigureAssignedAuras
	-- configuration
	df['Configure']				= DisplayFrame.Configure
--	df['UpdateDisplay']			= [Set By Configure]
	-- drag overlay
	df['EnableDragOverlay']		= DisplayFrame.EnableDragOverlay
	df['DisableDragOverlay']	= DisplayFrame.DisableDragOverlay
	df['ConfigureDragOverlay']	= DisplayFrame.ConfigureDragOverlay

	return df
end


-- ------------------------
-- AURA HANDLING
-- ------------------------
function DisplayFrame:AddAuraToDisplay(flagBurst, auraGroup, auraType, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
	local aura = tremove(self.aurasInactive, 1) -- grab an aura from inactive pool (if any)

	if (not aura) then -- no inactive auras, create one
		aura = Srendarr.Aura:Create(self)
		aura:Configure(self.settings)
	end

	aura:Initialize(auraGroup, auraType, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)

	self.aurasActive[aura.auraID] = aura

	tinsert(self.aurasSorted, aura)

	if (not flagBurst) then
		self:UpdateDisplay()
	end
end

function DisplayFrame:OnAuraReleased(flagBurst, aura)
	if (self.aurasActive[aura.auraID]) then -- aura is displayed here, remove it
		self.aurasActive[aura.auraID] = nil

		tinsert(self.aurasInactive, aura)

		for i, sortedAura in ipairs(self.aurasSorted) do
			if (sortedAura.auraID == aura.auraID) then
				tremove(self.aurasSorted, i)
				break
			end
		end

		if (not flagBurst) then
			self:UpdateDisplay()
		end
	end
end

function DisplayFrame:ConfigureAssignedAuras()
	for _, aura in pairs(self.aurasActive) do	-- configure all active auras assigned to this display frame
		aura:Configure(self.settings)
		aura:UpdateVisuals()
	end

	for _, aura in pairs(self.aurasInactive) do	-- configure all inactive auras in this display frame's pool
		aura:Configure(self.settings)
	end
end


-- ------------------------
-- CONFIGURATION
-- ------------------------
local function UpdateDisplayCentered(self)
	tsort(self.aurasSorted, self.SortAuras)

	local offsetI = self.displayOffsetX * ((#self.aurasSorted - 1) / 2)

	for i, aura in ipairs(self.aurasSorted) do
		aura:ClearAnchors()
		aura:SetAnchor(CENTER, self, CENTER, offsetI, 0)
		offsetI = offsetI - self.displayOffsetX
	end
end

local function UpdateDisplayDirectional(self)
	tsort(self.aurasSorted, self.SortAuras)

	for i, aura in ipairs(self.aurasSorted) do
		aura:ClearAnchors()
		aura:SetAnchor(self.displayPoint, self, self.displayPoint, self.displayOffsetX * (i - 1), self.displayOffsetY * (i - 1))
	end
end

function DisplayFrame:Configure()
	local db = self.settings

	if (db.auraSort == AURA_SORT_NAMEASC) then
		self['SortAuras'] = SortAurasByNameAsc
	elseif (db.auraSort == AURA_SORT_TIMEASC) then
		self['SortAuras'] = SortAurasByTimeAsc
	elseif (db.auraSort == AURA_SORT_CASTASC) then
		self['SortAuras'] = SortAurasByCastAsc
	elseif (db.auraSort == AURA_SORT_NAMEDESC) then
		self['SortAuras'] = SortAurasByNameDesc
	elseif (db.auraSort == AURA_SORT_TIMEDESC) then
		self['SortAuras'] = SortAurasByTimeDesc
	elseif (db.auraSort == AURA_SORT_CASTDESC) then
		self['SortAuras'] = SortAurasByCastDesc
	end

	if (db.auraGrowth == AURA_GROW_CENTERLEFT or db.auraGrowth == AURA_GROW_CENTERRIGHT) then
		self.displayOffsetX = round((db.auraPadding + AURA_HEIGHT) * ((db.auraGrowth == AURA_GROW_CENTERLEFT) and 1 or -1))
		self['UpdateDisplay'] = UpdateDisplayCentered
	else
		if (db.auraGrowth == AURA_GROW_UP) then
			self.displayPoint = BOTTOM
			self.displayOffsetX = 0
			self.displayOffsetY = round(-1 * (db.auraPadding + AURA_HEIGHT))
		elseif (db.auraGrowth == AURA_GROW_DOWN) then
			self.displayPoint = TOP
			self.displayOffsetX = 0
			self.displayOffsetY = round(db.auraPadding + AURA_HEIGHT)
		elseif (db.auraGrowth == AURA_GROW_LEFT) then
			self.displayPoint = RIGHT
			self.displayOffsetX = round(-1 * (db.auraPadding + AURA_HEIGHT))
			self.displayOffsetY = 0
		else -- AURA_GROW_RIGHT
			self.displayPoint = LEFT
			self.displayOffsetX = round(db.auraPadding + AURA_HEIGHT)
			self.displayOffsetY = 0
		end

		self['UpdateDisplay'] = UpdateDisplayDirectional
	end
end


-- ------------------------
-- DRAG OVERLAY
-- ------------------------
local function OnMouseEnter(self)
	self.dragOverlay.highlight:SetHidden(false)
	InitializeTooltip(InformationTooltip, self, TOP, 0, 4)
	InformationTooltip:AddLine(self.tooltipText, '$(BOLD_FONT)|14',  ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
end

local function OnMouseExit(self)
	self.dragOverlay.highlight:SetHidden(true)
	ClearTooltip(InformationTooltip)
end

local function CreateDragOverlay(self)
	local ctrl, anim

	local drag = AddControl(self, CT_TEXTURE, 3)
	drag:SetDimensions(AURA_HEIGHT, AURA_HEIGHT)
	drag:SetAnchor(CENTER)
	drag:SetTexture([[/esoui/art/actionbar/abilityframe64_up.dds]]) -- border (and root)
	-- OVERLAY ICON
	drag.icon, ctrl = AddControl(drag, CT_TEXTURE, 2)
	ctrl:SetDimensions(AURA_HEIGHT, AURA_HEIGHT)
	ctrl:SetAnchor(CENTER)
	ctrl:SetTexture[[/esoui/art/icons/ability_restorationstaff_001.dds]]
	-- MOUSEOVER HIGHLIGHT
	drag.highlight, ctrl = AddControl(drag, CT_TEXTURE, 4)
	ctrl:SetDimensions(AURA_HEIGHT, AURA_HEIGHT)
	ctrl:SetAnchor(CENTER)
	ctrl:SetTexture([[/esoui/art/actionbar/actionslot_toggledon.dds]])
	ctrl:SetColor(1, 0.82, 0)
	ctrl:SetHidden(true)
	-- LABEL
	drag.label, ctrl = AddControl(drag, CT_LABEL, 4)
	ctrl:SetFont('ZoFontWinH1')
	ctrl:SetDimensions(AURA_HEIGHT, AURA_HEIGHT)
	ctrl:SetAnchor(CENTER)
	ctrl:SetVerticalAlignment(1)
	ctrl:SetHorizontalAlignment(1)
	ctrl:SetColor(0.64, 0.52, 0, 1)
	ctrl:SetText(self.displayID)
	-- AURA OUTLINES
	drag.auraOutlines = {}
	for x = 1, 4 do
		drag.auraOutlines[x], ctrl = AddControl(drag, CT_BACKDROP, 1)
		ctrl:SetHeight(AURA_HEIGHT)
		ctrl:SetCenterColor(0, 0.5, 0.7, 0.24 / x)
		ctrl:SetEdgeColor(0, 0.5, 0.7, 0.32 / x)
		ctrl:SetEdgeTexture('', 8, 1, 0)
	end
	-- ANIMATION
	drag.timeline = ANIMATION_MANAGER:CreateTimeline()
	drag.timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, -1)
	anim = drag.timeline:InsertAnimation(ANIMATION_COLOR, drag.label, 0)
	anim:SetDuration(750)
	anim:SetEasingFunction(ZO_LinearEase)
	anim:SetColorValues(0.64, 0.52, 0, 1, 1, 0.82, 0, 1)
    anim = drag.timeline:InsertAnimation(ANIMATION_COLOR, drag.label, 750)
    anim:SetDuration(750)
    anim:SetEasingFunction(ZO_LinearEase)
    anim:SetColorValues(1, 0.82, 0, 1, 0.64, 0.52, 0, 1)

	self:SetHandler('OnMouseEnter', OnMouseEnter)
	self:SetHandler('OnMouseExit',	OnMouseExit)

	self.dragOverlay = drag
end

function DisplayFrame:ConfigureDragOverlay()
	if (not self.dragOverlay) then return end -- no overlay yet, so no need to configure it

	local db	= self.settings
	local drag	= self.dragOverlay
	local outline, offsetI

	local outlineWidth = AURA_HEIGHT
	local point = self.displayPoint
	self.tooltipText = zo_strformat('|cffffff<<Z:1>>|r', L.Group_Displayed_Here)

	local noGroups = true -- check if there are no groups assigned to this frame

	for group, frame in pairs(Srendarr.db.auraGroups) do
		if (frame == self.displayID) then -- this group is being show on this frame
			self.tooltipText = string.format('%s\n%s', self.tooltipText, Srendarr.auraGroupStrings[group])
			noGroups = false
		end
	end

	if (noGroups) then
		self.tooltipText = string.format('%s\n%s', self.tooltipText, L.Group_Displayed_None)
	end

	if (db.auraGrowth == AURA_GROW_CENTERLEFT or db.auraGrowth == AURA_GROW_CENTERRIGHT) then
		offsetI = self.displayOffsetX * 1.5
	elseif (db.auraGrowth == AURA_GROW_UP or db.auraGrowth == AURA_GROW_DOWN) then
		point = (db.barReverse and TOPRIGHT or TOPLEFT)
		outlineWidth = AURA_HEIGHT + 3 + db.barWidth
	end

	for x = 1, 4 do
		outline = drag.auraOutlines[x]
		outline:ClearAnchors()

		if (db.auraGrowth == AURA_GROW_CENTERLEFT or db.auraGrowth == AURA_GROW_CENTERRIGHT) then
			outline:SetAnchor(CENTER, self, CENTER, offsetI, 0)
			offsetI = offsetI - self.displayOffsetX
		else
			outline:SetAnchor(point, self, point, self.displayOffsetX * (x - 1), self.displayOffsetY * (x - 1))
		end

		outline:SetWidth(outlineWidth)
	end
end

function DisplayFrame:EnableDragOverlay()
	if (not self.dragOverlay) then
		CreateDragOverlay(self)
	end

	self:ConfigureDragOverlay()
	self:SetMouseEnabled(true)
	self:SetMovable(true)
	self.dragOverlay:SetHidden(false)
	self.dragOverlay.timeline:PlayFromStart()
end

function DisplayFrame:DisableDragOverlay()
	self:SetMouseEnabled(false)
	self:SetMovable(false)

	if (self.dragOverlay) then
		self.dragOverlay.timeline:Stop()
		self.dragOverlay:SetHidden(true)
	end
end


Srendarr.DisplayFrame = DisplayFrame
