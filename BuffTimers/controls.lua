local WM = WINDOW_MANAGER

function BuffTimers:InitializeControls()

	self.bar = {}
	for i=1, self.svars.numberBars do
	
		self.bar[i] = WM:CreateTopLevelWindow("BuffTimersBar"..i) 
		self.bar[i]:SetHandler("OnMoveStop", function() self:OnDisplayPosChange(i) end)
		self.bar[i]:SetClampedToScreen(true)
		
		self.bar[i].bg = WM:CreateControl("$(parent)Bg", self.bar[i], CT_BACKDROP)
		self.bar[i].bg:SetAnchorFill()
		self.bar[i].bg:SetDrawLayer(1)
		self.bar[i].bg:SetEdgeTexture(nil, 1, 1, 2, 0) 
		
		self.bar[i].bar = WM:CreateControl("$(parent)Bar", self.bar[i], CT_STATUSBAR)
		self.bar[i].bar:SetAnchor(TOPLEFT, self.bar[i], TOPLEFT, 2,2)
		self.bar[i].bar:SetAnchor(BOTTOMRIGHT, self.bar[i], BOTTOMRIGHT, -2,-2)
		self.bar[i].bar:SetMinMax(0, 1) 
		
		self.bar[i].label = WM:CreateControl("$(parent)Label", self.bar[i], CT_LABEL)
		self.bar[i].label:SetAnchor(TOPLEFT, self.bar[i], TOPLEFT, 2,2)
		self.bar[i].label:SetAnchor(BOTTOMRIGHT, self.bar[i], BOTTOMRIGHT, -2,-2)	
		self.bar[i].label:SetVerticalAlignment(1)
		self.bar[i].label:SetHorizontalAlignment(1)
		self.bar[i].label:SetColor(1,1,1,1)

		self.bar[i].icon = WM:CreateControl("$(parent)Icon", self.bar[i], CT_TEXTURE)
		self.bar[i].icon:SetAnchor(RIGHT, self.bar[i], LEFT, -1,0)		
	end
	
	self.announce = WM:CreateTopLevelWindow("BuffTimersControl") 
	self.announce:SetHandler("OnMoveStop", function() self:OnDisplayPosChangeAnnounce() end)
	if self.svars.announcePos["x"] == 0 then	--if first start then find middle of screen
		self.announce:SetAnchor(CENTER, GuiRoot, CENTER, 0, -100)
		self.svars.announcePos["x"] = self.announce:GetLeft()
		self.svars.announcePos["y"] = self.announce:GetTop()
		self.announce:ClearAnchors()
	end
	self.announce:SetClampedToScreen(true)
	self.announce:SetResizeToFitDescendents(true)
	
	self.announce.label = WM:CreateControl("$(parent)Label", self.announce, CT_LABEL)
	self.announce.label:SetAnchor(TOP, self.announce, TOP, 0,0)
	self.announce.label:SetVerticalAlignment(1)
	self.announce.label:SetHorizontalAlignment(1)
	self.announce.label:SetFont("ZoFontCallout3")
	
	-- self.announce.bg = WM:CreateControl("$(parent)Bg", self.announce, CT_BACKDROP)
	-- self.announce.bg:SetAnchorFill()
	-- self.announce.bg:SetEdgeTexture(nil, 1, 1, 2, 0) 
	-- self.announce.bg:SetEdgeColor(1,0,0,1)		
	-- self.announce.bg:SetCenterColor(0,0,0,0)
	
	-- self.announce.label.bg = WM:CreateControl("$(parent)Bg", self.announce.label, CT_BACKDROP)
	-- self.announce.label.bg:SetAnchorFill()
	-- self.announce.label.bg:SetEdgeTexture(nil, 1, 1, 1, 0) 
	-- self.announce.label.bg:SetEdgeColor(0,0,1,1)		
	-- self.announce.label.bg:SetCenterColor(0,0,0,0)
	
	self:SetControlSettings(self.svars.numberBars)
end

function BuffTimers:SetControlSettings(numBars)
	for i=1, self.svars.numberBars do
		self.bar[i]:SetHeight(self.svars.barData[i].height)
		self.bar[i]:SetWidth(self.svars.barData[i].width)
		self.bar[i]:ClearAnchors()
		self.bar[i]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.svars.barData[i].offset["x"], self.svars.barData[i].offset["y"])
		self.bar[i]:SetMouseEnabled(not self.svars.barData[i].locked)
		self.bar[i]:SetMovable(not self.svars.barData[i].locked)
		self.bar[i]:SetHidden(not self.svars.barData[i].alwaysShow and self.svars.barData[i].locked)
		
		self.bar[i].bg:SetEdgeColor(unpack(self.svars.barData[i].colorEdge))		
		self.bar[i].bg:SetCenterColor(unpack(self.svars.barData[i].colorBg))
		
		if self.svars.barData[i].locked then self.bar[i].bar:SetValue(0) else self.bar[i].bar:SetValue(1) end		
		self.bar[i].bar:SetGradientColors(unpack(self.svars.barData[i].colorBar)) 
		
		self.bar[i].label:SetFont("$(BOLD_FONT)|"..tostring(self.svars.barData[i].textSize).."|soft-shadow-thin")
		if self.svars.barData[i].locked then self.bar[i].label:SetText("") else self.bar[i].label:SetText("Bar "..i) end	

		self.bar[i].icon:SetWidth(self.svars.barData[i].iconSize)
		self.bar[i].icon:SetHeight(self.svars.barData[i].iconSize)
		if self.svars.barData[i].customIcon then 
			self.bar[i].icon:SetTexture(self.svars.barData[i].customIconTex)
		else
			self.bar[i].icon:SetTexture(self.svars.barData[i].iconTexture) 
		end
		self.bar[i].icon:SetHidden(not self.svars.barData[i].showIcon)		
	end
	
	for i=self.svars.numberBars+1, numBars do
		self.bar[i]:SetMouseEnabled(false)
		self.bar[i]:SetMovable(false)
		self.bar[i]:SetHidden(true)
		self.bar[i].icon:SetHidden(true)
	end
	
	self.announce:ClearAnchors()
	self.announce:SetAnchor(TOP, GuiRoot, TOPLEFT, self.svars.announcePos["x"], self.svars.announcePos["y"])
	self.announce.label:SetColor(unpack(self.svars.announceColor))
end

function BuffTimers:OnDisplayPosChangeAnnounce()
	self.svars.announcePos["x"] = self.announce:GetLeft()+self.announce:GetWidth()/2 
	self.svars.announcePos["y"] = self.announce:GetTop()
end
function BuffTimers:OnDisplayPosChange(bar)
	self.svars.barData[bar].offset["x"] = self.bar[bar]:GetLeft()
	self.svars.barData[bar].offset["y"] = self.bar[bar]:GetTop()
end

function BuffTimers:LockBar(bar, isLocked)
	if not self.svars.barData[bar].alwaysShow then self.bar[bar]:SetHidden(isLocked) end
	self.bar[bar]:SetMouseEnabled(not isLocked)
	self.bar[bar]:SetMovable(not isLocked)
	self.bar[bar].bar:SetMinMax(0,1)
	self.bar[bar].bar:SetValue(1)
end

function BuffTimers:SetSettingsExample(bar)	
		self.bar[bar].bar:SetMinMax(0, 1) 
		self.bar[bar].bar:SetValue(1) 
		self.bar[bar].label:SetText("Bar "..bar)
		self.bar[bar].icon:SetTexture(self.svars.barData[bar].iconTexture)	
end