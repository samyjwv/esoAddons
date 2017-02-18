CombatCloud_CombatEllipseEventViewer = CombatCloud_EventViewer:Subclass()

local random, sqrt, min, max = math.random, math.sqrt, math.min, math.max
local format, tostring = string.format, tostring
local callLater = zo_callLater
local C = CombatCloudConstants
local poolTypes = C.poolType

function CombatCloud_CombatEllipseEventViewer:New(...)
    local obj = CombatCloud_EventViewer:New(...)
    obj:RegisterCallback(C.eventType.COMBAT, function(...) self:OnEvent(...) end)
    self.eventBuffer = {}
    self.lastTime = { [C.combatType.OUTGOING] = 0, [C.combatType.INCOMING] = 0 }
    self.timeToNext = { [C.combatType.OUTGOING] = 0, [C.combatType.INCOMING] = 0 }
    return obj
end

function CombatCloud_CombatEllipseEventViewer:OnEvent(combatType, powerType, value, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical)
    if (CombatCloudSettings.animation.animationType ~= 'ellipse') then return end

    local T = CombatCloudSettings.throttles

    if (isCritical and (isDamage or isHealing)) and (not CombatCloudSettings.toggles.throttleCriticals) then
        self:View(combatType, powerType, value, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical, 1)
    else
        local eventKey = format('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', combatType, powerType, abilityName, abilityId, damageType, tostring(isDamage), tostring(isHealing), tostring(isEnergize), tostring(isDrain), tostring(isDot), tostring(isHot), tostring(isMiss), tostring(isImmune), tostring(isParried), tostring(isReflected), tostring(isDamageShield), tostring(isDodged), tostring(isBlocked), tostring(isInterrupted), tostring(isCritical))
        if (self.eventBuffer[eventKey] == nil) then
            self.eventBuffer[eventKey] = { value = value, hits = 1 }
            local throttleTime = 0
            if (isDamage) then throttleTime = T.damage
            elseif (isDot) then throttleTime = T.dot
            elseif (isHealing) then throttleTime = T.healing
            elseif (isHot) then throttleTime = T.hot end
            local timeRemaining = self.lastTime[combatType] + self.timeToNext[combatType] - GetGameTimeMilliseconds()  
            if timeRemaining > throttleTime then
                throttleTime = timeRemaining
            end
            self.timeToNext[combatType] = self.timeToNext[combatType] - throttleTime
            callLater(function() self:ViewFromEventBuffer(combatType, powerType, eventKey, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical) end, throttleTime)
        else
            self.eventBuffer[eventKey].value = self.eventBuffer[eventKey].value + value
            self.eventBuffer[eventKey].hits = self.eventBuffer[eventKey].hits + 1
        end
    end
end

function CombatCloud_CombatEllipseEventViewer:ViewFromEventBuffer(combatType, powerType, eventKey, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical)
    if not self.eventBuffer[eventKey] then return end
    local value = self.eventBuffer[eventKey].value
    local hits = self.eventBuffer[eventKey].hits
    self.eventBuffer[eventKey] = nil
    self:View(combatType, powerType, value, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical, hits)
end

function CombatCloud_CombatEllipseEventViewer:View(combatType, powerType, value, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical, hits)
    local S = CombatCloudSettings

    local control, controlPoolKey = self.poolManager:GetPoolObject(poolTypes.CONTROL)

    local textFormat, fontSize, textColor = self:GetTextAtributes(powerType, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical)
    if (hits > 1 and S.toggles.showThrottleTrailer) then value = format('%d (%d)', value, hits) end

    self:PrepareLabel(control.label, fontSize, textColor, self:FormatString(textFormat, { text = abilityName, value = value, powerType = powerType, damageType = damageType }))
    self:ControlLayout(control, abilityId, combatType)

    local panel, point, relativePoint = CombatCloud_Outgoing, BOTTOMRIGHT, TOPRIGHT
    if (combatType == C.combatType.INCOMING) then
        panel = CombatCloud_Incoming
        if (S.animation.incoming.directionType == 'up') then
            point, relativePoint = TOPRIGHT, BOTTOMRIGHT
        end
    else
        if (S.animation.outgoing.directionType == 'up') then
            point, relativePoint = TOPRIGHT, BOTTOMRIGHT
        end
    end

    local offsetX, targetX = 0, -1
    local offsetY, targetY = 0, 1

    if (isDot or isHot or isEnergize or isDrain or isMiss or isImmune or isParried or isReflected or isDamageShield or isDodged or isBlocked or isInterrupted) then
        offsetY, targetY, targetX = 0.2, 0.8, -0.8
    end

    if (point == TOPRIGHT) then
        offsetY, targetY = -offsetY, -targetY
    end

--- Anchor points: -----------------------------
--  3 .. 1 .. 9
--  .    .    .
--  2 ..128.. 8
--  .    .    .
--  6 .. 4 .. 12
--
--  TOP + LEFT     = TOPLEFT     (1 + 2 = 3)
--  TOP + RIGHT    = TOPRIGHT    (1 + 8 = 9)
--  BOTTOM + LEFT  = BOTTOMLEFT  (4 + 2 = 6)
--  BOTTOM + RIGHT = BOTTOMRIGHT (4 + 8 = 12)
-------------------------------------------------

    if (panel:GetCenter()) > GuiRoot:GetWidth() / 2 then
        point, relativePoint = point - RIGHT + LEFT, relativePoint - RIGHT + LEFT
        targetX = -targetX
    end

    local w, h = panel:GetDimensions()
    control:SetAnchor(point, panel, relativePoint, offsetX * w, offsetY * h)

    local animationXPoolType, animationYPoolType
    if (isCritical and (isDamage or isHealing)) then
        animationXPoolType = poolTypes.ANIMATION_ELLIPSE_X_CRIT
        animationYPoolType = poolTypes.ANIMATION_ELLIPSE_Y_CRIT
    else
        animationXPoolType = poolTypes.ANIMATION_ELLIPSE_X
        animationYPoolType = poolTypes.ANIMATION_ELLIPSE_Y
    end

    local animationX, animationXPoolKey = self.poolManager:GetPoolObject(animationXPoolType)
    animationX:GetStepByName('scrollX'):SetDeltaOffsetX(targetX * w)
    animationX:Apply(control.icon)
    animationX:Play()

    local animationY, animationYPoolKey = self.poolManager:GetPoolObject(animationYPoolType)
    animationY:GetStepByName('scrollY'):SetDeltaOffsetY(targetY * h)
    animationY:Apply(control)
    animationY:Play()

    --info for throttling, critical damage and heals are excluded
    if (S.toggles.throttleCriticals) or (not (isCritical and (isDamage or isHealing))) then
        self.lastTime[combatType] = GetGameTimeMilliseconds()
        self.timeToNext[combatType] = self.timeToNext[combatType] + (animationY:GetDuration() * (fontSize + 4) / h) 
    end 
    
    -- Add items back into pool after use
    callLater(function()
        self.poolManager:ReleasePoolObject(poolTypes.CONTROL, controlPoolKey)
        self.poolManager:ReleasePoolObject(animationXPoolType, animationXPoolKey)
        self.poolManager:ReleasePoolObject(animationYPoolType, animationYPoolKey)
    end, animationY:GetDuration())
end
