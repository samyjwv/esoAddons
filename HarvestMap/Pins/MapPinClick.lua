local LMP = LibStub("LibMapPins-1.0")
local MapPinClickHandler = {}
Harvest.mapPinClickHandler = MapPinClickHandler

function MapPinClickHandler:Initialize()
	self.stack = {n = 0}
	self.handlers = {}
	
end

function MapPinClickHandler:RefreshHandler()
	local handler
	if self.stack.n > 0 then
		handler = self.handlers[self.stack[self.stack.n]]
	end
	for _, pinTypeId in pairs( Harvest.PINTYPES ) do
		if pinTypeId ~= Harvest.TOUR then
			local pinType = Harvest.GetPinType( pinTypeId )
			LMP:SetClickHandlers(pinType, handler, nil)
		end
	end
	local pinType = Harvest.GetPinType( 0 )
	LMP:SetClickHandlers(pinType, handler, nil)
end

function MapPinClickHandler:Push(identifier, handler)
	self.stack.n = self.stack.n + 1
	self.stack[self.stack.n] = identifier
	self.handlers[identifier] = handler
	self:RefreshHandler()
end

function MapPinClickHandler:Pop(poppedIdentifier)
	local n = self.stack.n
	local identifier
	for i = 0, n-1 do
		identifier = self.stack[n - i]
		if identifier == poppedIdentifier then
			self.stack[n - i] = nil
			if i == 0 then
				self.stack.n = self.stack.n - 1
				MapPinClickHandler:RefreshHandler()
			end
		end
	end
end
