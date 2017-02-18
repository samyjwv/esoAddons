--Edits to allow Vampand Werewolf XP to work after Ledgermain added to game.  9/18/15 - Ravalox

local _addon = WYK_Toolbar
local xyzzy
local name = ""
local rank = 0
local specialWorldSkill = 0
_addon.Feature.Toolbar.GetSpecialWorldXPBar = function()
	if GetNumSkillLines(SKILL_TYPE_WORLD) == 1 then return 0, _addon._DefaultLabelColor .. "Human:|r ", 1; end
	for xyzzy=1,GetNumSkillLines(SKILL_TYPE_WORLD) do
		worldSkillName, worldSkillLevel = GetSkillLineInfo(SKILL_TYPE_WORLD, xyzzy)
		if worldSkillName == "Vampire" then
			name = worldSkillName
			rank = worldSkillLevel
			specialWorldSkill = xyzzy
		elseif worldSkillName == "Werewolf" then
			name = worldSkillName
			rank = worldSkillLevel
			specialWorldSkill = xyzzy
		end
	end
	if name == "" then return 0 end
	local oldxp, xplvl, xp = GetSkillLineXPInfo( SKILL_TYPE_WORLD, specialWorldSkill )
	if xp == nil or xplvl == nil or oldxp == nil then return 0, _addon._DefaultLabelColor .. "Human:|r ", 1; end
	xp = xp - oldxp
	xplvl = xplvl - oldxp
	local title = _addon._DefaultLabelColor .. name .. ":|r "
	if tonumber(xplvl) == 0 then return 1, title, rank; end
	return _addon:Round((xp / xplvl),2), title, rank;
end
