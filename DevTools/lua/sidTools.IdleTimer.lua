local RegisterForEvent = sidTools.RegisterForEvent
local UnregisterForEvent = sidTools.UnregisterForEvent

local IdleTimer = ZO_Object:Subclass()
sidTools.IdleTimer = IdleTimer

local MAX_IDLE_TIME = 900
local TIME_LOW_THRESHOLD = 120
local TIME_CRITICAL_THRESHOLD = 30
local NORMAL_COLOR = ZO_ColorDef:New("ffffff")
local CRITICAL_COLOR = ZO_ColorDef:New("ff0000")

function IdleTimer:New(parent, saveData)
	local timer = ZO_Object.New(self)

	local label = parent:CreateControl("$(parent)IdleTimer", CT_LABEL)
	label:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
	label:SetDimensions(200, 20)
	label:SetColor(1, 1, 1, 1)
	label:SetFont("ZoFontWindowTitle")
	timer.label = label
	timer.saveData = saveData
	timer.active = false
	if(not saveData.lastActivity or saveData.lastActivity > GetGameTimeMilliseconds()) then
		timer:ResetTimer()
	end
	timer.lastX, timer.lastY = GetMapPlayerPosition("player")

	return timer
end

function IdleTimer:ResetTimer()
	self.saveData.lastActivity = GetGameTimeMilliseconds()
	self:UpdateLabel()
end

local function FormatCountdown(timeLeft)
	local sign = timeLeft < 0 and "-" or ""
	timeLeft = timeLeft < 0 and -timeLeft or timeLeft
	local minutes = math.floor(timeLeft / 60)
	local seconds = timeLeft % 60
	return sign .. ("0" .. minutes):sub(-2) .. ":" .. ("0" .. seconds):sub(-2)
end

function IdleTimer:GetTimeLeft()
	return MAX_IDLE_TIME - math.floor((GetGameTimeMilliseconds() - self.saveData.lastActivity) / 1000)
end

function IdleTimer:UpdateLabel()
	local timeLeft = self:GetTimeLeft()
	self.label:SetText(FormatCountdown(timeLeft))
	local color = (timeLeft < TIME_LOW_THRESHOLD) and CRITICAL_COLOR or NORMAL_COLOR
	self.label:SetColor(color:UnpackRGBA())
end

function IdleTimer:Activate()
	if(self.active) then return end
	self.active = true

	local function Update()
		local x, y = GetMapPlayerPosition("player")
		local hasMoved = x ~= self.lastX or y ~= self.lastY
		self.lastX, self.lastY = x, y
		if(hasMoved) then
			self:ResetTimer()
		else
			self:UpdateLabel()
		end
		if(self:GetTimeLeft() < TIME_CRITICAL_THRESHOLD) then
			PlaySound(SOUNDS.COUNTDOWN_WARNING)
		end
	end
	self.updateHandler = "sidToolsIdleTimerUpdate"
	EVENT_MANAGER:RegisterForUpdate(self.updateHandler, 1000, Update)

	local characterName = GetRawUnitName("player")
	self.combatEventHandler = RegisterForEvent(EVENT_COMBAT_EVENT, function(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log)
		if(abilityName == "" or sourceName ~= characterName) then return end
		self:ResetTimer()
	end)
	local filters = {
		REGISTER_FILTER_UNIT_TAG, "player",
		REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED,
	}
	EVENT_MANAGER:AddFilterForEvent(self.combatEventHandler, EVENT_COMBAT_EVENT, unpack(filters))

	Update()
end

function IdleTimer:Deactivate()
	if(not self.active) then return end
	self.active = false

	EVENT_MANAGER:UnregisterForUpdate(self.updateHandler)
	self.updateHandler = nil

	UnregisterForEvent(EVENT_COMBAT_EVENT, self.combatEventHandler)
	self.combatEventHandler = nil
end
