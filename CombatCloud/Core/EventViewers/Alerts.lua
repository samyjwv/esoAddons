CombatCloud_AlertEventViewer = CombatCloud_EventViewer:Subclass()

local L = CombatCloudLocalization
local callLater = zo_callLater
local poolTypes = CombatCloudConstants.poolType
local alertTypes = CombatCloudConstants.alertType

function CombatCloud_AlertEventViewer:New(...)
    local obj = CombatCloud_EventViewer:New(...)
    obj:RegisterCallback(CombatCloudConstants.eventType.ALERT, function(...) self:OnEvent(...) end)
    self.locationOffset = 0  -- Simple way to avoid overlapping. When number of active notes is back to 0, the offset is also reset
    self.activeAlerts = 0
    return obj
end

function CombatCloud_AlertEventViewer:OnEvent(alertType, value)
    local S = CombatCloudSettings

    --Label setup
    local control, controlPoolKey = self.poolManager:GetPoolObject(poolTypes.CONTROL)

    local size, color, text
    --Cleanse
    if (alertType == alertTypes.CLEANSE) then
        color = S.colors.alertCleanse
        size = S.fontSizes.alert
        text = self:FormatString(S.formats.alertCleanse, { value = value, text = L.alertCleanse })
    --BLOCK
    elseif (alertType == alertTypes.BLOCK) then
        color = S.colors.alertBlock
        size = S.fontSizes.alert
        text = self:FormatString(S.formats.alertBlock, { value = value, text = L.alertBlock })
    --EXPLOIT
    elseif (alertType == alertTypes.EXPLOIT) then
        color = S.colors.alertExploit
        size = S.fontSizes.alert
        text = self:FormatString(S.formats.alertExploit, { value = value, text = L.alertExploit })
    --INTERRUPT
    elseif (alertType == alertTypes.INTERRUPT) then
        color = S.colors.alertInterrupt
        size = S.fontSizes.alert
        text = self:FormatString(S.formats.alertInterrupt, { value = value, text = L.alertInterrupt })
    --DODGE
    elseif (alertType == alertTypes.DODGE) then
        color = S.colors.alertDodge
        size = S.fontSizes.alert
        text = self:FormatString(S.formats.alertDodge, { value = value, text = L.alertDodge })
    --EXECUTE
    elseif (alertType == alertTypes.EXECUTE) then
        color = S.colors.alertExecute
        size = S.fontSizes.alert
        text = self:FormatString(S.formats.alertExecute, { value = value, text = L.alertExecute })
    end

    self:PrepareLabel(control.label, size, color, text)
    self:ControlLayout(control)

    --Control setup
    control:SetAnchor(CENTER, CombatCloud_Alert, TOP, 0, self.locationOffset * (S.fontSizes.alert + 5))
    self.locationOffset = self.locationOffset + 1
    self.activeAlerts = self.activeAlerts + 1

    --Get animation
    local animationPoolType = poolTypes.ANIMATION_ALERT
    local animation, animationPoolKey = self.poolManager:GetPoolObject(animationPoolType)
    animation:Apply(control)
    animation:Play()

    --Add items back into pool after animation
    callLater(function()
        self.poolManager:ReleasePoolObject(poolTypes.CONTROL, controlPoolKey)
        self.poolManager:ReleasePoolObject(animationPoolType, animationPoolKey)
        self.activeAlerts = self.activeAlerts - 1
        if (self.activeAlerts == 0) then self.locationOffset = 0 end
    end, animation:GetDuration())
end