CombatCloud_ResourcesPowerEventListener = CombatCloud_EventListener:Subclass()

function CombatCloud_ResourcesPowerEventListener:New()
    local obj = CombatCloud_EventListener:New()
    obj:RegisterForEvent(EVENT_POWER_UPDATE, function(...) self:OnEvent(...) end)
    self.powerInfo = {
        [POWERTYPE_HEALTH]  = { wasWarned = false, resourceType = CombatCloudConstants.resourceType.LOW_HEALTH },
        [POWERTYPE_STAMINA] = { wasWarned = false, resourceType = CombatCloudConstants.resourceType.LOW_STAMINA },
        [POWERTYPE_MAGICKA] = { wasWarned = false, resourceType = CombatCloudConstants.resourceType.LOW_MAGICKA }
    }
    self.executeAlerts = {}
    return obj
end

function CombatCloud_ResourcesPowerEventListener:OnEvent(unit, powerPoolIndex, powerType, power, powerMax)
    if (unit == 'player' and self.powerInfo[powerType] ~= nil) then
        local t = CombatCloudSettings.toggles
        local threshold
        
        if power <= 0 then
            return
        elseif powerType == POWERTYPE_HEALTH then
            if not t.showLowHealth then return end
            threshold = CombatCloudSettings.healthThreshold or 35
        elseif powerType == POWERTYPE_STAMINA then
            if not t.showLowStamina then return end
            threshold = CombatCloudSettings.staminaThreshold or 35
        elseif powerType == POWERTYPE_MAGICKA then
            if not t.showLowMagicka then return end
            threshold = CombatCloudSettings.magickaThreshold or 35
        end

        local percent = power / powerMax * 100

        -- Check if we need to show the warning, else clear the warning
        if (percent < threshold and not self.powerInfo[powerType].wasWarned) then
            self:TriggerEvent(CombatCloudConstants.eventType.RESOURCE, self.powerInfo[powerType].resourceType, power)
            self.powerInfo[powerType].wasWarned = true
        elseif (percent > threshold + 10) then -- Add 10 to create some sort of buffer, else the warning can fire more than once depending on the power regen of the player
            self.powerInfo[powerType].wasWarned = false
        end
    --EXECUTE ALERT
    elseif (CombatCloudSettings.toggles.showAlertExecute and unit == 'reticleover' and powerType == POWERTYPE_HEALTH and IsUnitAttackable('reticleover') and GetUnitReaction('reticleover') ~= UNIT_REACTION_NEUTRAL and not IsUnitDead('reticleover')) then
        local threshold = CombatCloudSettings.executeThreshold or 20
        local alertFrequency = CombatCloudSettings.executeFrequency or 8
        local unitName = GetRawUnitName('reticleover')

        local percent = power / powerMax * 100
        local now = GetFrameTimeSeconds()
        local alertTime = self.executeAlerts[unitName] or 0

        if percent <= threshold then
            if now - alertTime > alertFrequency then
                self:TriggerEvent(CombatCloudConstants.eventType.ALERT, CombatCloudConstants.alertType.EXECUTE, zo_round(percent))
                self.executeAlerts[unitName] = now
            end
        else
            for name, alertTime in pairs(self.executeAlerts) do
                if now - alertTime > alertFrequency then
                    self.executeAlerts[name] = nil
                end
            end
        end
    end
end