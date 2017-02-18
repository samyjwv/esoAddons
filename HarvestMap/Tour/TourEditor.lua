
local TourEditor = {}
Harvest.tourEditor = TourEditor

function TourEditor:Initialize()
	self.tourHandler = {
		name = Harvest.mapPins.nameFunction
		callback = self.pinClickFunction
	}
	self.linkPool = ZO_ControlPool:New("HarvestLink", ZO_WorldMapContainer, "EditorLink")
end

function TourEditor:Open()
	self.path = {}
	if not self.isGeneratingPath then
		Harvest.mapPinClickHandler:Push("tour", self.tourHandler)
	end
end

function TourEditor:Close()
	Harvest.mapPinClickHandler:Pop("tour")
	self.path = nil
	self:RefreshPathDisplay()
end

TourEditor.pinClickFunction = function(pin)
	local pinType, nodeId = pin:GetPinTypeAndTag()
	
	local first = 1
	local last = #TourEditor.path
	
	if TourEditor.path[first] == nodeId then
		TourEditor:ConvertPathToTour()
	elseif TourEditor.path[last] == nodeId then
		TourEditor.path[last] = nil
	end
	TourEditor:RefreshPathDisplay()
end

function TourEditor:RefreshPathDisplay()
	self.linkPool:ReleaseAllObjects()
	if not self.path then return end
	-- create the line sections of the path
	-- each line section combines two points, so we need the previous point as well
	-- the "previous" point of the first point is the very last point of our tour.
	local lastNodeId = self.path[#self.path]
	local linkControl
	for _, nodeId in ipairs(self.bestPath) do
		linkControl = self.linkPool:AcquireObject()
		linkControl.startX = self.mapCache.localX[nodeId]
		linkControl.startY = self.mapCache.localX[nodeId]
		linkControl.endX = self.mapCache.localX[lastNodeId]
		linkControl.endY = self.mapCache.localX[lastNodeId]
		linkControl:SetTexture("EsoUI/Art/AvA/AvA_transitLine_dashed.dds")
		linkControl:SetColor(0,0,1,1)
		linkControl:SetDrawLevel(10)
		lastNodeId = nodeId
	end
	-- correctly display the line sections on the map
	local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()
	local links = self.linkPool:GetActiveObjects()
	for _, link in pairs(links) do
		local startX, startY, endX, endY = link.startX * mapWidth, link.startY * mapHeight, link.endX * mapWidth, link.endY * mapHeight
		ZO_Anchor_LineInContainer(link, nil, startX, startY, endX, endY)
	end
end

function TourEditor:ConvertPathToTour()
	
end

function TourEditor:StartGeneratingTour()
	self.path = {}
	self.isGeneratingPath = true
	Harvest.mapPinClickHandler:Pop("tour")
end


function TourEditor:FinishedGeneratingTour()
	Harvest.mapPinClickHandler:Push("tour", self.tourHandler)
end

function TourEditor:PromptSaveTour()

end

function TourEditor:PrompLoadTour()

end
