-- This file is part of CyrHUD
--
-- (C) 2014 Scott Yeskie (Sasky)
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

CyrHUD = CyrHUD or {}

local function n0(val) if val == nil then return 0 end return val end

-- Setup class
CyrHUD.Battle = {}
CyrHUD.Battle.__index = CyrHUD.Battle
CyrHUD.Battle.type = "Battle"
setmetatable(CyrHUD.Battle, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

local shortenResourceName = function(str)
    return str:gsub("%^.d$", "")
        :gsub("Castle ","")
        :gsub("[fF]ort ","")
        :gsub("Keep ","")
        :gsub("Lumber ","")
        :gsub("Feste ","")
        :gsub("Kastell ","")
        :gsub("Burg ","")
        :gsub("Holz.+lager", "")

end

local shortenKeepName = function(str)
    return str:gsub(",..$", ""):gsub("%^.d$", "")
    --FR
        :gsub("avant.poste d[eu] ", "")
        :gsub("bastille d[eu]s? ", "")
        :gsub("fort de la ", "")
end


----------------------------------------------
-- Creation
----------------------------------------------
CyrHUD.Battle.new = function(keepID)
    local self = setmetatable({}, CyrHUD.Battle)
    self.startBattle = GetTimeStamp()
    self.endBattle = nil
    self.keepID = keepID
    self.keepName = shortenKeepName(GetKeepName(keepID))
    self.keepType = GetKeepType(keepID)
    if self.keepType == KEEPTYPE_RESOURCE then
        self.keepType = 10 + GetKeepResourceType(keepID)
        self.keepName = shortenResourceName(self.keepName)
    end
    self.siege = {}
    self:update()
    return self
end

----------------------------------------------
-- Label update
----------------------------------------------
--Label fields
local L_ICON, L_UA = "img1", "img2"
local L_NAME, L_ATT_SIEGE, L_DEF_SIEGE, L_TIME = "txt1", "txt2", "txt3", "txt4"

function CyrHUD.Battle:configureLabel(label)
    label:exposeControls(2,4)

    label:positionControl(L_ICON, 40, 40, -2, -2)
    -- Objective icon
    label:getControl(L_ICON):SetDrawLayer(2)
    -- Under attack graphic
    label:positionControl(L_UA, 40, 40, -2, -2)
    local ua = label:getControl(L_UA)
    ua:SetDrawLayer(1)
    ua:SetTexture(CyrHUD.info.underAttack)

    --Objective name
    label:positionControl(L_NAME, 150, 30, 35, 5)
    --Defensive siege count
    label:positionControl(L_DEF_SIEGE, 30, 30, 220, 5)
    --Attacker siege count
    label:positionControl(L_ATT_SIEGE, 30, 30, 190, 5)
    --Time
    label:positionControl(L_TIME, 30, 30, 250, 5)
end

function CyrHUD.Battle:updateLabel(label)
    --Keep icon
    label:getControl(L_ICON):SetTexture(self:getIcon())
    label:getControl(L_UA):SetHidden(not self.keepUA)
    --Keep name
    local name = label:getControl(L_NAME)
    name:SetText(self.keepName)
    name:SetColor(CyrHUD.info[self.defender].color:UnpackRGBA())
    --Time
    label:getControl(L_TIME):SetText(self:getDuration())
    --Defensive siege
    local ds, dc = self:getDefSiege()
    local defSiege = label:getControl(L_DEF_SIEGE)
    defSiege:SetText(ds)
    defSiege:SetColor(dc:UnpackRGBA())
    label:getControl(L_ICON):SetColor(dc:UnpackRGBA())
    --Attacing siege
    local as, ac = self:getAttSiege()
    local attSiege = label:getControl(L_ATT_SIEGE)
    attSiege:SetText(as)
    attSiege:SetColor(ac:UnpackRGBA())
    --Background color
    label.main:SetCenterColor(self:getBGColor():UnpackRGBA())
end


----------------------------------------------
-- Model update
----------------------------------------------
function CyrHUD.Battle:update()
    self.defender = GetKeepAlliance(self.keepID, CyrHUD.battleContext)
    self.keepUA = GetKeepUnderAttack(self.keepID, CyrHUD.battleContext)
    self.siege[ALLIANCE_ALDMERI_DOMINION] = GetNumSieges(self.keepID, CyrHUD.battleContext, ALLIANCE_ALDMERI_DOMINION)
    self.siege[ALLIANCE_DAGGERFALL_COVENANT] = GetNumSieges(self.keepID, CyrHUD.battleContext, ALLIANCE_DAGGERFALL_COVENANT)
    self.siege[ALLIANCE_EBONHEART_PACT] = GetNumSieges(self.keepID, CyrHUD.battleContext, ALLIANCE_EBONHEART_PACT)

    if not self:isBattle() then
        if self.endBattle then
            --Remove after time
            if GetDiffBetweenTimeStamps(GetTimeStamp(), self.endBattle) > 15 then
                CyrHUD.battles[self.keepID] = nil
            end
        else
            self.endBattle = GetTimeStamp()
        end
    end
end

function CyrHUD.Battle:restart()
    self.endBattle = nil
end

----------------------------------------------
-- Getters
----------------------------------------------

--[[
    @return red, green, blue, alpha for background color
        all in range [0,1]
--]]
function CyrHUD.Battle:getBGColor()
    if self.endBattle then
        if self.defender == GetUnitAlliance("player") then
            return CyrHUD.info.defendedColor
        end
        return CyrHUD.info.endAttackColor
    end
    local delta = GetDiffBetweenTimeStamps(GetTimeStamp(), self.startBattle)
    if delta < 60 then
        CyrHUD.info.newAttackColor:Lerp(CyrHUD.info.defaultBGColor, delta/120)
    end

    return CyrHUD.info.defaultBGColor
end

--[[
    @return elapsed time of battle event
        if an end is specified, will show total lenth
        otherwise will show current length
--]]
function CyrHUD.Battle:getDuration()
    local time = self.endBattle or GetTimeStamp()
    local delta = GetDiffBetweenTimeStamps(time, self.startBattle)
    local out = CyrHUD.formatTime(delta)
    return out
end

--[[
    @return numSiege, color
        numSiege - number of defending siege equipment
        color - color for the defending faction
]]
function CyrHUD.Battle:getDefSiege()
    local siege = self.siege[self.defender]
    if siege == 0 then siege = "" end
    return siege, CyrHUD.info[self.defender].color
end

--[[
    @return numSiege, color
        numSiege - number of defending siege equipment
        color - color for the defending faction
    @note If two attacking factions, will sum the siege and show white for color
]]
function CyrHUD.Battle:getAttSiege()
    local count, faction = 0, nil
    for f,c in pairs(self.siege) do
        if f ~= self.defender and c > 0 then
            count = count + c
            if faction == nil then
                faction = f
            else
                faction = 0
            end
        end
    end
    local color = CyrHUD.info[ALLIANCE_NONE].color
    if faction and faction ~= 0 then
        color = CyrHUD.info[faction].color
    end
    if count == 0 then
        if not self.keepUA and n0(self.siege[self.defender]) > 0 then
            count = "?"
        else
            count = ""
        end
    end
    return count, color
end

--[[
    @return true iff battle is active
        a) keep is under attack status
        b) there is siege setup at keep
--]]
function CyrHUD.Battle:isBattle()
    if self.keepUA then return true end
    local count = (self.siege[ALLIANCE_ALDMERI_DOMINION] + self.siege[ALLIANCE_DAGGERFALL_COVENANT] + self.siege[ALLIANCE_EBONHEART_PACT])
    return count > 0
end

--[[
    @return icon for battle
        icon is based on resource type, faction, and whether it is under attack
    @see CyrHUD.info
]]
function CyrHUD.Battle:getIcon()
    --Debug code
    if CyrHUD.icons[self.keepType] == nil then

        return CyrHUD.info.noIcon
    end
    return CyrHUD.icons[self.keepType]
end