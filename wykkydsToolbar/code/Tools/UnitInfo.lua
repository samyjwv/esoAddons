local _addon = WYK_Toolbar
--local maxVRLevel = GetMaxVeteranRank()

_addon.Feature.Toolbar.GetUnit_Name = function()
    return "|cC0A27F"..GetUnitName("player").."|r", {215/255,213/255,205/255,.85}
end

_addon.Feature.Toolbar.GetUnit_Race = function()
    return "|cC0A27F"..GetUnitRace("player").."|r", {215/255,213/255,205/255,.85}
end

_addon.Feature.Toolbar.GetUnit_Class = function()
    return "|cC0A27F"..GetUnitClass("player").."|r", {215/255,213/255,205/255,.85}
end

_addon.Feature.Toolbar.GetUnit_Level = function()
    local useTitle, title = _addon:GetOrDefault( false, _addon.Settings["level_title"]), _addon._DefaultLabelColor .. "Level:|r "
    if not useTitle then title = "" end
    local lvl, c
    if IsUnitChampion('player') then
  --      local rank = GetPlayerChampionPointsEarned()
    --    if rank == maxVRLevel then
            lvl = "|cC9BC0Fcp|r" .. GetPlayerChampionPointsEarned()
     --   else
       --     lvl = "|cC9BC0Fcp|r" .. vet
       -- end
        c = {1,1,.76,.85}
    else
        lvl = GetUnitLevel("player")
        c = {215/255,213/255,205/255,.85}
    end
    return title..lvl, c
end
