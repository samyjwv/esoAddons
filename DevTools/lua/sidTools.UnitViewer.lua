local function CreateMessageWindow(name, title, parent, x, y, width, height)
    local LIBMW = LibStub:GetLibrary("LibMsgWin-1.0")
    local window = LIBMW:CreateMsgWindow(name, title)
    window:ClearAnchors()
    if(parent) then
        window:SetAnchor(TOPLEFT, parent, TOPRIGHT, x, y)
    else
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    end
    window:SetDimensions(width, height)

    window.buffer = _G[name .. "Buffer"]
    window.slider = _G[name .. "Slider"]
    window.label = _G[name .. "Label"]

    window.SetLabel = function(self, text)
        self.label:SetText(text)
    end

    window.ScrollToTop = function(self)
        local buffer, slider = self.buffer, self.slider
        local visible = buffer:GetNumVisibleLines()
        buffer:SetScrollPosition(buffer:GetNumHistoryLines() - visible)
        slider:SetValue(0)
    end

    window.ScrollToTop = function(self)
        local buffer, slider = self.buffer, self.slider
        local visible = buffer:GetNumVisibleLines()
        buffer:SetScrollPosition(buffer:GetNumHistoryLines() - visible)
        slider:SetValue(0)
    end

    local bufferScrollPosition, sliderValue = 0, 0
    window.SaveScrollPosition = function(self)
        local buffer, slider = self.buffer, self.slider
        bufferScrollPosition, sliderValue = buffer:GetScrollPosition(), slider:GetValue()
    end

    window.RestoreScrollPosition = function(self)
        local buffer, slider = self.buffer, self.slider
        buffer:SetScrollPosition(bufferScrollPosition)
        slider:SetValue(sliderValue)
    end

    return window
end

local function Initialize(saveData)
    local unitWindow = CreateMessageWindow("sidToolsUnitView", "Unit Viewer", nil, 1600, 0, 320, 1080)
    unitWindow.buffer:SetFont("ZoFontGameSmall")

    local function AddLine(label, result)
        if(type(result) ~= "string") then result = tostring(result) end
        if(result == "") then result = "\"\"" end
        unitWindow:AddText(string.format("%s: %s", ZO_NORMAL_TEXT:Colorize(label), result), 1, 1, 1)
    end

    local unitTag = "player"
    local function UpdateUnitDetails(force)
        if(not DoesUnitExist(unitTag) and force ~= true) then return end
        unitWindow:SaveScrollPosition()
        unitWindow:ClearText()

        unitWindow:SetLabel(("Unit Details - %s"):format(unitTag))
        AddLine("DoesUnitExist", tostring(DoesUnitExist(unitTag)))
        AddLine("GetUnitName", GetUnitName(unitTag))
        AddLine("GetRawUnitName", GetRawUnitName(unitTag))
        AddLine("GetUnitGender", GetUnitGender(unitTag))
        AddLine("GetUnitClass", GetUnitClass(unitTag))
        AddLine("GetUnitClassId", GetUnitClassId(unitTag))
        AddLine("GetUnitLevel", GetUnitLevel(unitTag))
        AddLine("GetUnitChampionPoints", GetUnitChampionPoints(unitTag))
        AddLine("CanUnitGainChampionPoints", tostring(CanUnitGainChampionPoints(unitTag)))
        AddLine("GetUnitEffectiveLevel", GetUnitEffectiveLevel(unitTag))
        AddLine("GetUnitZone", GetUnitZone(unitTag))
        AddLine("GetUnitZoneIndex", GetUnitZoneIndex(unitTag))
        AddLine("GetUnitXP", GetUnitXP(unitTag))
        AddLine("GetUnitXPMax", GetUnitXPMax(unitTag))
        AddLine("IsUnitChampion", tostring(IsUnitChampion(unitTag)))
        AddLine("IsUnitUsingVeteranDifficulty", tostring(IsUnitUsingVeteranDifficulty(unitTag)))
        AddLine("IsUnitBattleLeveled", tostring(IsUnitBattleLeveled(unitTag)))
        AddLine("IsUnitChampionBattleLeveled", tostring(IsUnitChampionBattleLeveled(unitTag)))
        AddLine("GetUnitBattleLevel", GetUnitBattleLevel(unitTag))
        AddLine("GetUnitChampionBattleLevel", GetUnitChampionBattleLevel(unitTag))
        AddLine("GetUnitDrownTime", table.concat({GetUnitDrownTime(unitTag)}, ", "))
        AddLine("IsUnitInGroupSupportRange", tostring(IsUnitInGroupSupportRange(unitTag)))
        AddLine("GetUnitType", GetUnitType(unitTag))
        AddLine("CanUnitTrade", tostring(CanUnitTrade(unitTag)))
        AddLine("IsUnitGrouped", tostring(IsUnitGrouped(unitTag)))
        AddLine("IsUnitGroupLeader", tostring(IsUnitGroupLeader(unitTag)))
        AddLine("IsUnitSoloOrGroupLeader", tostring(IsUnitSoloOrGroupLeader(unitTag)))
        AddLine("IsUnitFriend", tostring(IsUnitFriend(unitTag)))
        AddLine("IsUnitIgnored", tostring(IsUnitIgnored(unitTag)))
        AddLine("IsUnitPlayer", tostring(IsUnitPlayer(unitTag)))
        AddLine("IsUnitPvPFlagged", tostring(IsUnitPvPFlagged(unitTag)))
        AddLine("IsUnitAttackable", tostring(IsUnitAttackable(unitTag)))
        AddLine("IsUnitJusticeGuard", tostring(IsUnitJusticeGuard(unitTag)))
        AddLine("IsUnitInvulnerableGuard", tostring(IsUnitInvulnerableGuard(unitTag)))
        AddLine("GetUnitAlliance", GetUnitAlliance(unitTag))
        AddLine("GetUnitRace", GetUnitRace(unitTag))
        AddLine("GetUnitRaceId", GetUnitRaceId(unitTag))
        AddLine("IsUnitFriendlyFollower", tostring(IsUnitFriendlyFollower(unitTag)))
        AddLine("GetUnitReaction", GetUnitReaction(unitTag))
        AddLine("GetUnitAvARankPoints", GetUnitAvARankPoints(unitTag))
        AddLine("GetUnitAvARank", GetUnitAvARank(unitTag))
        local color = ZO_ColorDef:New(GetUnitReactionColor(unitTag))
        AddLine("GetUnitReactionColor", color:Colorize(color:ToHex()))
        AddLine("IsUnitInCombat", tostring(IsUnitInCombat(unitTag)))
        AddLine("IsUnitDead", tostring(IsUnitDead(unitTag)))
        AddLine("IsUnitReincarnating", tostring(IsUnitReincarnating(unitTag)))
        AddLine("IsUnitDeadOrReincarnating", tostring(IsUnitDeadOrReincarnating(unitTag)))
        AddLine("IsUnitSwimming", tostring(IsUnitSwimming(unitTag)))
        AddLine("IsUnitResurrectableByPlayer", tostring(IsUnitResurrectableByPlayer(unitTag)))
        AddLine("IsUnitBeingResurrected", tostring(IsUnitBeingResurrected(unitTag)))
        AddLine("DoesUnitHaveResurrectPending", tostring(DoesUnitHaveResurrectPending(unitTag)))
        AddLine("GetUnitStealthState", GetUnitStealthState(unitTag))
        AddLine("GetUnitDisguiseState", GetUnitDisguiseState(unitTag))
        AddLine("GetUnitHidingEndTime", GetUnitHidingEndTime(unitTag))
        AddLine("IsUnitOnline", tostring(IsUnitOnline(unitTag)))
        AddLine("IsUnitInspectableSiege", tostring(IsUnitInspectableSiege(unitTag)))
        AddLine("IsUnitInDungeon", tostring(IsUnitInDungeon(unitTag)))
        AddLine("GetUnitCaption", GetUnitCaption(unitTag))
        AddLine("GetUnitSilhouetteTexture", GetUnitSilhouetteTexture(unitTag))

        local numPowerPools = 0
        for i = 1, NUM_POWER_POOLS do
            local powerType = GetUnitPowerInfo(unitTag, i)
            if(powerType) then numPowerPools = numPowerPools + 1 end
        end
        AddLine("GetUnitPowerInfo", numPowerPools)
        for i = 1, NUM_POWER_POOLS do
            local powerType, cur, max = GetUnitPowerInfo(unitTag, i)
            if(powerType) then
                AddLine(string.format("    %s (%d)", GetString("SI_COMBATMECHANICTYPE", powerType), powerType), string.format("%d/%d", cur, max))
            end
        end

        local combatMechanicTypes = {
            POWERTYPE_HEALTH,
            POWERTYPE_HEALTH_BONUS,
            POWERTYPE_MAGICKA,
            POWERTYPE_MOUNT_STAMINA,
            POWERTYPE_STAMINA,
            POWERTYPE_ULTIMATE,
            POWERTYPE_WEREWOLF
        }

        AddLine("GetUnitPower", #combatMechanicTypes)
        for i = 1, #combatMechanicTypes do
            local powerType = combatMechanicTypes[i]
            local cur, max, effectiveMax = GetUnitPower(unitTag, powerType)
            AddLine(string.format("    %s (%d)", GetString("SI_COMBATMECHANICTYPE", powerType), powerType), string.format("%d/%d/%d", cur, max, effectiveMax))
        end

        -- GetUnitAttributeVisualizerEffectInfo

        AddLine("GetUnitDifficulty", GetUnitDifficulty(unitTag))
        AddLine("GetUnitTitle", GetUnitTitle(unitTag))
        local isDps, isHealer, isTank = GetGroupMemberRoles(unitTag)
        AddLine("GetGroupMemberRoles", string.format("%s, %s, %s", tostring(isDps), tostring(isHealer), tostring(isTank)))
        AddLine("GetMapPlayerPosition", table.concat({GetMapPlayerPosition(unitTag)}, ", "))
        AddLine("GetMapPing", table.concat({GetMapPing(unitTag)}, ", "))
        local canJump, result = CanJumpToGroupMember(unitTag)
        AddLine("CanJumpToGroupMember", string.format("%s, %d", tostring(canJump), result))
        AddLine("GetGroupIndexByUnitTag", GetGroupIndexByUnitTag(unitTag))
        AddLine("IsGroupMemberInRemoteRegion", tostring(IsGroupMemberInRemoteRegion(unitTag)))
        AddLine("GetGroupMemberAssignedRole", GetGroupMemberAssignedRole(unitTag))
        AddLine("Buffs", GetNumBuffs(unitTag))
        for i = 1, GetNumBuffs(unitTag) do
            local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff = GetUnitBuffInfo(unitTag, i)
            AddLine(zo_iconTextFormat(iconFilename, 16, 16, buffName), string.format("ts: %d, te: %d, bs: %d, sc: %d, et: %d, at: %d, se: %d, id:%d, co: %s", timeStarted, timeEnding, buffSlot, stackCount, effectType, abilityType, statusEffectType, abilityId, tostring(canClickOff)))
        end

        unitWindow:RestoreScrollPosition()
    end

    EVENT_MANAGER:RegisterForUpdate("sidToolsUnitViewerUpdate", 500, UpdateUnitDetails)
    UpdateUnitDetails(true)

    local unitsCmd = sidTools.unitsCmd

    local showCmd = unitsCmd:RegisterSubCommand()
    showCmd:AddAlias("show")
    showCmd:SetCallback(function()
        UpdateUnitDetails(true)
        unitWindow:SetHidden(false)
        EVENT_MANAGER:RegisterForUpdate("sidToolsUnitViewerUpdate", 500, UpdateUnitDetails)
    end)
    showCmd:SetDescription("Show the unit viewer window")

    local hideCmd = unitsCmd:RegisterSubCommand()
    hideCmd:AddAlias("hide")
    hideCmd:SetCallback(function()
        unitWindow:SetHidden(true)
        EVENT_MANAGER:UnregisterForUpdate("sidToolsUnitViewerUpdate")
    end)
    hideCmd:SetDescription("Hide the unit viewer window")

    local function ToggleUnitViewer()
        if(unitWindow:IsHidden()) then
            showCmd()
        else
            hideCmd()
        end
    end
    sidTools.ToggleUnitViewer = ToggleUnitViewer

    unitsCmd:SetCallback(function(tag)
        if(tag and #tag > 0) then
            unitTag = tag
            UpdateUnitDetails(true)
        else
            ToggleUnitViewer()
        end
    end)

    local unitTagList = {}
    unitTagList[#unitTagList + 1] = "player"
    unitTagList[#unitTagList + 1] = "reticleover"
    unitTagList[#unitTagList + 1] = "reticleovertarget"
    unitTagList[#unitTagList + 1] = "interact"
    for i = 1, GROUP_SIZE_MAX do
        unitTagList[#unitTagList + 1] = ("group%d"):format(i)
    end
    for i = 1, 6 do
        unitTagList[#unitTagList + 1] = ("boss%d"):format(i)
    end
    unitsCmd:SetAutoComplete(unitTagList)
end

sidTools.InitializeUnitViewer = Initialize
