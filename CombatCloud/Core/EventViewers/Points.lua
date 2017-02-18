CombatCloud_PointEventViewer = CombatCloud_EventViewer:Subclass()

local callLater = zo_callLater
local L = CombatCloudLocalization
local poolTypes = CombatCloudConstants.poolType
local pointTypes = CombatCloudConstants.pointType

function CombatCloud_PointEventViewer:New(...)
    local obj = CombatCloud_EventViewer:New(...)
    obj:RegisterCallback(CombatCloudConstants.eventType.POINT, function(...) self:OnEvent(...) end)
    self.locationOffset = 0  -- Simple way to avoid overlapping. When number of active notes is back to 0, the offset is also reset
    self.activePoints = 0
    return obj
end

function CombatCloud_PointEventViewer:OnEvent(pointType, value)
    local S = CombatCloudSettings

    --Label setup
    local control, controlPoolKey = self.poolManager:GetPoolObject(poolTypes.CONTROL)

    local size, color, text
---------------------------------------------------------------------------------------------------------------------------------------
    --//POINTS//--
---------------------------------------------------------------------------------------------------------------------------------------
    if (pointType == pointTypes.ALLIANCE_POINTS) then
        color = S.colors.pointsAlliance
        size = S.fontSizes.point
        text = self:FormatString(S.formats.pointsAlliance, { value = value, text = L.pointsAlliance })
    elseif (pointType == pointTypes.EXPERIENCE_POINTS) then
        color = S.colors.pointsExperience
        size = S.fontSizes.point
        text = self:FormatString(S.formats.pointsExperience, { value = value, text = L.pointsExperience })
    elseif (pointType == pointTypes.CHAMPION_POINTS) then
        color = S.colors.pointsChampion
        size = S.fontSizes.point
        text = self:FormatString(S.formats.pointsChampion, { value = value, text = L.pointsChampion })
---------------------------------------------------------------------------------------------------------------------------------------
    --//COMBAT STATE//--
---------------------------------------------------------------------------------------------------------------------------------------
    elseif (pointType == pointTypes.IN_COMBAT) then
        color = S.colors.inCombat
        size = S.fontSizes.combatState
        text = self:FormatString(S.formats.inCombat, { value = value, text = L.inCombat })
    elseif (pointType == pointTypes.OUT_COMBAT) then
        color = S.colors.outCombat
        size = S.fontSizes.combatState
        text = self:FormatString(S.formats.outCombat, { value = value, text = L.outCombat })
    end

    self:PrepareLabel(control.label, size, color, text)
    self:ControlLayout(control)

    --Control setup
    control:SetAnchor(CENTER, CombatCloud_Point, TOP, 0, self.locationOffset * (S.fontSizes.point + 5))
    self.locationOffset = self.locationOffset + 1
    self.activePoints = self.activePoints + 1

    --Get animation
    local animationPoolType
    if (pointType == pointTypes.IN_COMBAT or pointType == pointTypes.OUT_COMBAT) then
        animationPoolType = poolTypes.ANIMATION_COMBATSTATE
    else
        animationPoolType = poolTypes.ANIMATION_POINT
    end
    local animation, animationPoolKey = self.poolManager:GetPoolObject(animationPoolType)
    animation:Apply(control)
    animation:Play()

    --Add items back into pool after animation
    callLater(function()
        self.poolManager:ReleasePoolObject(poolTypes.CONTROL, controlPoolKey)
        self.poolManager:ReleasePoolObject(animationPoolType, animationPoolKey)
        self.activePoints = self.activePoints - 1
        if (self.activePoints == 0) then self.locationOffset = 0 end
    end, animation:GetDuration())
end