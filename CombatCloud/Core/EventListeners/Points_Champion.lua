CombatCloud_PointsChampionEventListener = CombatCloud_EventListener:Subclass()

local callLater = zo_callLater

function CombatCloud_PointsChampionEventListener:New()
    local obj = CombatCloud_EventListener:New()
    obj:RegisterForEvent(EVENT_CHAMPION_POINT_UPDATE, function(...) self:OnEvent(...) end, REGISTER_FILTER_UNIT_TAG, 'player')
    self.gain = 0
    self.timeoutActive = false
    self.previousPoints = GetUnitChampionPoints('player')
    self.previousMaxPoints = 3600
    self.previousCP = GetUnitChampionPoints('player')
    self.maxCP = 3600
    self.hasMaxCP = self.previousCP == self.maxCP and self.previousPoints >= self.previousMaxPoints
    return obj
end

function CombatCloud_PointsChampionEventListener:OnEvent(unit, currentPoints, maxPoints, reason)
    if (CombatCloudSettings.toggles.showPointsChampion and not self.hasMaxCP) then

        local currentVR = GetUnitChampionPoints('player')

        -- Calculate gained CP
        if (currentVR == self.previousCP) then
            self.gain = self.gain + (currentPoints - self.previousPoints)
        else
            self.gain = self.gain + (self.previousMaxPoints - self.previousPoints) + currentPoints
        end

        -- Remember values
        self.previousPoints = currentPoints
        self.previousMaxPoints = maxPoints
        self.previousCP = currentVR
        self.hasMaxCP = self.hasMaxCP or (currentVR == self.maxCP and currentPoints >= maxPoints)

        -- Trigger custom event (500ms buffer)
        if (self.gain > 0 and not self.timeoutActive) then
            self.timeoutActive = true
            callLater(function()
                self:TriggerEvent(CombatCloudConstants.eventType.POINT, CombatCloudConstants.pointType.CHAMPION_POINTS, self.gain)
                self.gain = 0
                self.timeoutActive = false
            end, 500)
        end

    end
end