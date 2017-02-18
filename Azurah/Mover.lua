local Azurah		= _G['Azurah'] -- grab addon table from global
local Mover			= {}

local rootWidth, rootHeight
local OnUpdate

-- UPVALUES --
local WM			= GetWindowManager()
local round			= zo_round
local GuiRoot		= GuiRoot
local unpack		= unpack
local abs			= math.abs

-- Anchor frame to target based on offset from GuiRoot center
local function AnchorFrameToTarget(frame, target)
	local x, y = target:GetLeft() + (target:GetWidth() / 2), target:GetTop() + (target:GetHeight() / 2)
	x, y = x - (GuiRoot:GetWidth() / 2), y - (GuiRoot:GetHeight() / 2)
	frame:ClearAnchors()
	frame:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
end

-- Get the anchor of the frame relative to nearest GuiRoot edge
local function GetAnchorRelativeToScreen(frame)
	local left, top		= frame:GetLeft(), frame:GetTop()
	local right, bottom	= frame:GetRight(), frame:GetBottom()
	local rootW, rootH	= GuiRoot:GetWidth(), GuiRoot:GetHeight()
	local point			= 0
	local x, y

	-- special case for Magicka/Stamina frames to keep 'expansion' alignment (provided by Garkin)
	if (frame == ZO_PlayerAttributeMagicka) then
		x		= right - rootW
		y		= (bottom + top) / 2 - rootH / 2
		point	= RIGHT
	elseif (frame == ZO_PlayerAttributeStamina) then
		x		= left
		y		= (bottom + top) / 2 - rootH / 2
		point	= LEFT
	else
		if (left < (rootW - right) and left < math.abs((left + right) / 2 - rootW / 2)) then
			x, point = left, 2 -- 'LEFT'
		elseif ((rootW - right) < math.abs((left + right) / 2 - rootW / 2)) then
			x, point = right - rootW, 8 -- 'RIGHT'
		else
			x, point = (left + right) / 2 - rootW / 2, 0
		end

		if (bottom < (rootH - top) and bottom < math.abs((bottom + top) / 2 - rootH / 2)) then
			y, point = top, point + 1 -- 'TOP|TOPLEFT|TOPRIGHT'
		elseif ((rootH - top) < math.abs((bottom + top) / 2 - rootH / 2)) then
			y, point = bottom - rootH, point + 4 -- 'BOTTOM|BOTTOMLEFT|BOTTOMRIGHT'
		else
			y = (bottom + top) / 2 - rootH / 2
		end

		point = (point == 0) and 128 or point -- 'CENTER'
	end

	return point, x, y
end

local function Sync(self)
	AnchorFrameToTarget(self, self.targetFrame)
end

local function Show(self)
	self:SetHidden(false)
end

local function Hide(self)
	self:SetHidden(true)
end

local function SetLabelText(self, text)
	self.labelText = (text) and text or ''
	self.label:SetText(self.labelText)
end

local function OnMouseEnter(self)
	self.label:SetText(self.labelText)
end

local function OnMouseExit(self)
	self.label:SetText(self.labelText)
end

local function OnMouseWheel(self, delta)
	self.targetFrame:SetScale(self.targetFrame:GetScale() + (delta > 0 and 0.01 or -0.01))
	self:SetDimensions(self.targetFrame:GetWidth(), self.targetFrame:GetHeight())
	self.label:SetText('(' .. round(self.targetFrame:GetScale() * 100) .. '%)')

	local point, x, y = GetAnchorRelativeToScreen(self.targetFrame) -- get screen relative anchor for callback
	Azurah:RecordUserData(self.targetFrame:GetName(), point, x, y, self.targetFrame:GetScale())
end

local function OnMouseDown(self)
	self.label:SetText(self.labelText) -- ensure the overlay label shows the name and not scaling percent
	self:SetDimensions(self.targetFrame:GetWidth(), self.targetFrame:GetHeight()) -- ensure overlay size is consistant with target (scaling outside of lib)
	-- Register GuiRoot current dimensions (saves having to constantly monitor for scaling changes)
	rootWidth, rootHeight = GuiRoot:GetWidth(), GuiRoot:GetHeight()
	self:SetHandler('OnUpdate', OnUpdate)
end

local function OnMouseUp(self)
	self.label:SetText(self.labelText) -- ensure the overlay label shows the name and not scaling percent
	self:SetHandler('OnUpdate', nil)
	self:StopMovingOrResizing()
	self.targetFrame:StopMovingOrResizing()

	local point, x, y = GetAnchorRelativeToScreen(self.targetFrame)

	self.targetFrame:ClearAnchors()
	self.targetFrame:SetAnchor(point, GuiRoot, point, x, y)

	Azurah:RecordUserData(self.targetFrame:GetName(), point, x, y, self.targetFrame:GetScale())

	AnchorFrameToTarget(self, self.targetFrame) -- ensure Handler is placed relative to target
end

do
	local gridSize = 10
	local width, height, offsetHorz, offsetVert, nearLR, nearTB

	OnUpdate = function(self)
		self.targetFrame:ClearAnchors()
		-- get relative offset from the CENTER of GuiRoot to the CENTER of self
		width, height = self:GetWidth(), self:GetHeight()
		offsetHorz = (self:GetLeft() + (width / 2)) - (rootWidth / 2)
		offsetVert = (self:GetTop() + (height / 2)) - (rootHeight / 2)

		if (Azurah.snapToGrid) then -- update offset to snapped values if enabled
			offsetHorz	= round(offsetHorz / gridSize) * gridSize
			offsetVert	= round(offsetVert / gridSize) * gridSize

			nearLR, nearTB = 0, 0

			if (self:GetLeft() - gridSize < 0) then
				nearLR = -1 -- near left edge
			elseif (self:GetRight() + gridSize > rootWidth) then
				nearLR = 1 -- near right edge
			end

			if (self:GetTop() - gridSize < 0) then
				nearTB = -1 -- near top edge
			elseif (self:GetBottom() + gridSize > rootHeight) then
				nearTB = 1 -- near bottom edge
			end

			self.targetFrame:SetAnchor(CENTER, GuiRoot, CENTER,
				(nearLR == 0) and offsetHorz or nearLR * ((rootWidth / 2) - (width / 2)),
				(nearTB == 0) and offsetVert or nearTB * ((rootHeight / 2) - (height / 2))
			)
		else
			self.targetFrame:SetAnchor(CENTER, GuiRoot, CENTER, offsetHorz, offsetVert)
		end
	end
end

function Mover:New(target, text)
	local new = WM:CreateControlFromVirtual(nil, GuiRoot, 'Azurah_Mover')

	new.targetFrame					= target
	new.labelText					= (text) and text or ''

	new['Sync']						= Sync
	new['Show']						= Show
	new['Hide']						= Hide
	new['SetLabelText']				= SetLabelText

	new:SetHandler('OnMouseEnter',	OnMouseEnter)
	new:SetHandler('OnMouseExit',	OnMouseExit)
	new:SetHandler('OnMouseWheel',	OnMouseWheel)
	new:SetHandler('OnMouseDown',	OnMouseDown)
	new:SetHandler('OnMouseUp',		OnMouseUp)

	new:SetDimensions(target:GetWidth(), target:GetHeight())
	new:SetDrawLayer(4)
	new:SetParent(GuiRoot)
	new:SetMouseEnabled(true)
	new:SetMovable(true)
	new:SetClampedToScreen(true)

	-- overlay
	new.overlay = WM:CreateControl(nil, new, CT_BACKDROP)
	new.overlay:SetDrawLevel(2)
	new.overlay:SetAnchorFill(target)
	new.overlay:SetCenterColor(0, 0.5, 0.7, 0.32)
	new.overlay:SetEdgeColor(0, 0.5, 0.7, 1)
	new.overlay:SetEdgeTexture('', 8, 1, 0)
	-- label
	new.label = WM:CreateControl(nil, new, CT_LABEL)
	new.label:SetDrawLevel(3)
	new.label:SetAnchorFill(target)
	new.label:SetFont('ZoFontWinH5')
	new.label:SetColor(1, 0.82, 0, 0.9)
	new.label:SetHorizontalAlignment(1)
	new.label:SetVerticalAlignment(1)
	new.label:SetText(new.labelText)

	AnchorFrameToTarget(new, target)

	Azurah.movers[target] = new

	return new
end

Azurah.Mover = Mover
