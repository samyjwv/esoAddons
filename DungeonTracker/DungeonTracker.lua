-------------------------------------------------------------------------------
-- Dungeon Tracker
-------------------------------------------------------------------------------
--
-- Copyright (c) 2017 James A. Keene (Phinix) All rights reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation (the "Software"),
-- to operate the Software for personal use only. Permission is NOT granted
-- to modify, merge, publish, distribute, sublicense, re-upload, and/or sell
-- copies of the Software. Additionally, licensed use of the Software
-- will be subject to the following:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-------------------------------------------------------------------------------
--
-- DISCLAIMER:
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and/or other countries. All rights reserved.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--
-------------------------------------------------------------------------------
local DTAddon = _G['DTAddon']
local L = DTAddon:GetLanguage()
DTAddon.Name = 'DungeonTracker'
DTAddon.Author = '|c66ccffPhinix|r'
DTAddon.Version = '1.02'

------------------------------------------------------------------------------------------------------------------------------------
-- Various functions used elsewhere.
------------------------------------------------------------------------------------------------------------------------------------
local function num2hex(ntable) -- Convert decimal r,g,b,a table to hex string
	local cstring = ""
	for i = 1, 3, 1 do
		local colornum = ntable[i] * 255
		local hexstr = "0123456789abcdef"
		local s = ""
		while colornum > 0 do
			local mod = math.fmod(colornum, 16)
			s = string.sub(hexstr, mod+1, mod+1) .. s
			colornum = math.floor(colornum / 16)
		end
		if #s == 1 then s = "0" .. s end
		if s == "" then s = "00" end
		cstring = cstring .. s
	end
	return cstring
end

local function LocalizeText(text) -- Remove special non-English characters
	if GetCVar('Language.2') == 'en' then
		return text
	else
		return zo_strformat("<<t:1>>",text)
	end
end

local function FindName(table, element)	-- Which key has the given data
	for key, value in pairs(table) do
		if value == element then
			return key
		end
	end
end

local function Contains(table, element)	-- If a given value exists in a given table
	for key, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

local function WrapNames(count, nTable, sTable) -- Allows centered custom width text wrap and non-color separator
	local namestring
	local cstring
	for i = 1, count do
		local name = nTable[i]
		local cname = sTable[i]
		if i == 1 then
			if count == i then
				InformationTooltip:AddVerticalPadding(-10)
				InformationTooltip:AddLine(name, "ZoFontGame")
			else
				if #name > 35 then
					InformationTooltip:AddVerticalPadding(-10)
					InformationTooltip:AddLine(name, "ZoFontGame")
				else
					namestring = name .. ", "
					cstring = cname .. ", "
				end
			end
		else
			if count == i then
				local tempa = namestring .. name
				local tempb = cstring .. cname
				if #tempb > 35 then
					InformationTooltip:AddVerticalPadding(-10)
					InformationTooltip:AddLine(namestring, "ZoFontGame")
					InformationTooltip:AddVerticalPadding(-10)
					InformationTooltip:AddLine(name, "ZoFontGame")
				else
					InformationTooltip:AddVerticalPadding(-10)
					InformationTooltip:AddLine(tempa, "ZoFontGame")
				end
			else
				if #name > 35 then
					InformationTooltip:AddVerticalPadding(-10)
					InformationTooltip:AddLine(name .. ", ", "ZoFontGame")
				else
					local tempa = namestring .. name .. ", "
					local tempb = cstring .. cname .. ","
					if #tempb > 35 then
						InformationTooltip:AddVerticalPadding(-10)
						InformationTooltip:AddLine(namestring, "ZoFontGame")
						namestring = name .. ", "
						cstring = cname .. ", "
					else
						namestring = tempa
						cstring = tempb
					end
				end
			end
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------------
-- Adds completion information to dungeon, trial, and delve tooltips
------------------------------------------------------------------------------------------------------------------------------------
local function CheckDungeons(ni)
	for i = 1, 32 do
		local tni = DTAddon.DungeonIndex[i].nodeIndex
		if tni == ni then
			return i
		end
	end
	return 0
end

local function CheckDelves(zi, pi)
	for i = 1, 18 do
		local tzi = DTAddon.DelveIndex[i].zoneIndex
		local tpi = DTAddon.DelveIndex[i].poiIndex
		if tzi == zi and tpi == pi then
			return i
		end
	end
	return 0
end

local function GetSortedNames(ct, it)
	local tNames = {}
	local sNames = {}
	for k, c in pairs(ct) do
		table.insert(tNames, c) 
	end
	for k, i in pairs(it) do
		table.insert(tNames, i) 
	end
	table.sort(tNames)
	for k, n in ipairs(tNames) do
		sNames[#sNames + 1] = n
	end
	return sNames
end

local function GetColorSortedNames(ct, it)
	local ccolor = "|c" .. tostring(DTAddon.ASV[800].cColorS)
	local icolor = "|c" .. tostring(DTAddon.ASV[800].iColorS)
	local aNames = {}
	local tNames = {}
	for k, c in pairs(ct) do
		local tagName = tostring(c) .. "1"
		table.insert(aNames, tagName) 
	end
	for k, i in pairs(it) do
		local tagName = tostring(i) .. "2"
		table.insert(aNames, tagName) 
	end
	table.sort(aNames)
	for k, n in ipairs(aNames) do
		if string.find(n, "1") then
			local colorName = ccolor .. tostring(n):gsub("1",'') .. "|r"
			tNames[#tNames + 1] = colorName
		elseif string.find(n, "2") then
			local colorName = icolor .. tostring(n):gsub("2",'') .. "|r"
			tNames[#tNames + 1] = colorName
		end
	end
	return tNames
end

local function ModifyDungeonTooltip(pin)
	local nIndex = pin:GetFastTravelNodeIndex()
	local pinType = pin:GetPinType()
	local zoneIndex = pin:GetPOIZoneIndex()
	local poiIndex = pin:GetPOIIndex()
	local poiName, _, _, _ = GetPOIInfo(zoneIndex, poiIndex)
	local inode = CheckDungeons(nIndex)
	local izpoi = CheckDelves(zoneIndex, poiIndex)
	local countshown = 0

	local function AddFormatLine(inode, countshown)
		local vIn = inode
		local vIIn = DTAddon.DungeonIndex[inode].vII
		local trackChar = DTAddon.SV.trackChar
		if vIn > vIIn then
			local vIInT = vIn
			vIn = vIIn
			vIIn = vIInT
		end
		local known1, _ = GetFastTravelNodeInfo(DTAddon.DungeonIndex[vIn].nodeIndex)
		local known2, _ = GetFastTravelNodeInfo(DTAddon.DungeonIndex[vIIn].nodeIndex)
		if known1 == true then
			local fP = DTAddon.DungeonIndex[inode].fP
			if fP ~= 0 then
				if trackChar == true and inode == vIn and DTAddon.ASV[800].showGFComp == true then
					local label = tostring(GetAchievementInfo(fP))
					label = LocalizeText(label)
					label = label .. ": "
					local numCriteria = GetAchievementNumCriteria(fP)
					local completed = 0
					for i = 1, numCriteria do
						local _, numCompleted, _ = GetAchievementCriterion(fP, i)
						if numCompleted == 1 then 
							completed = completed + 1
						end
					end
					-- Colorize achievement title by faction.
					if fP == 1073 then label = "|ce05a4c" .. label .. "|r"
					elseif fP == 1075 then label = "|cfff578" .. label .. "|r"
					elseif fP == 1074 then label = "|c6a91b6" .. label .. "|r" end
					ZO_Tooltip_AddDivider(InformationTooltip)
					label = DTAddon.DungeonIndex[inode].icon .. label .. tostring(completed) .. "/" .. tostring(numCriteria)
					InformationTooltip:AddLine(label, "ZoFontGameOutline")
				end
			end
		end
		if known1 == true or known2 == true then
			if countshown > 0 then
				-- Bottom separator line if anything is shown.
				ZO_Tooltip_AddDivider(InformationTooltip)
			end
		end
	end

	if inode ~= 0 then -- Add group dungeon tooltip info.
		local vII = DTAddon.DungeonIndex[inode].vII
		if vII ~= 0 then
			if vII < inode then
				if DTAddon.ASV[800].showNComp == true then
					local ct = DTAddon.ASV[inode].complete
					local it = DTAddon.ASV[inode].incomplete
					local cNames = GetColorSortedNames(ct, it)
					local sNames = GetSortedNames(ct, it)
					local count = #cNames
					if count > 0 then
						InformationTooltip:AddLine("|cffffff" .. L.DTAddon_CNormII .. "|r", "ZoFontGameOutline")
						WrapNames(count, cNames, sNames)
						countshown = countshown + 1
					end
				end
				if DTAddon.ASV[800].showVComp == true then
					local onode = inode + 100
					local ct = DTAddon.ASV[onode].complete
					local it = DTAddon.ASV[onode].incomplete
					local cNames = GetColorSortedNames(ct, it)
					local sNames = GetSortedNames(ct, it)
					local count = #cNames
					if count > 0 then
						InformationTooltip:AddLine("|cffffff" .. L.DTAddon_CVetII .. "|r", "ZoFontGameOutline")
						WrapNames(count, cNames, sNames)
						countshown = countshown + 1
					end
				end
				AddFormatLine(inode, countshown)
			elseif vII > inode then		
				if DTAddon.ASV[800].showNComp == true then
					local ct = DTAddon.ASV[inode].complete
					local it = DTAddon.ASV[inode].incomplete
					local cNames = GetColorSortedNames(ct, it)
					local sNames = GetSortedNames(ct, it)
					local count = #cNames
					if count > 0 then
						InformationTooltip:AddLine("|cffffff" .. L.DTAddon_CNormI .. "|r", "ZoFontGameOutline")
						WrapNames(count, cNames, sNames)
						countshown = countshown + 1
					end
				end
				if DTAddon.ASV[800].showVComp == true then
					local onode = inode + 100
					local ct = DTAddon.ASV[onode].complete
					local it = DTAddon.ASV[onode].incomplete
					local cNames = GetColorSortedNames(ct, it)
					local sNames = GetSortedNames(ct, it)
					local count = #cNames
					if count > 0 then
						InformationTooltip:AddLine("|cffffff" .. L.DTAddon_CVetI .. "|r", "ZoFontGameOutline")
						WrapNames(count, cNames, sNames, 1)
						countshown = countshown + 1
					end
				end
				AddFormatLine(inode, countshown)
			end
		elseif vII == 0 then
			if DTAddon.ASV[800].showNComp == true then
				local ct = DTAddon.ASV[inode].complete
				local it = DTAddon.ASV[inode].incomplete
				local cNames = GetColorSortedNames(ct, it)
				local sNames = GetSortedNames(ct, it)
				local count = #cNames
				if count > 0 then
					InformationTooltip:AddLine("|cffffff" .. L.DTAddon_CNorm .. "|r", "ZoFontGameOutline")
					WrapNames(count, cNames, sNames)
					countshown = countshown + 1
				end
			end
			if DTAddon.ASV[800].showVComp == true then
				local onode = inode + 100
				local ct = DTAddon.ASV[onode].complete
				local it = DTAddon.ASV[onode].incomplete
				local cNames = GetColorSortedNames(ct, it)
				local sNames = GetSortedNames(ct, it)
				local count = #cNames
				if count > 0 then
					InformationTooltip:AddLine("|cffffff" .. L.DTAddon_CVet .. "|r", "ZoFontGameOutline")
					WrapNames(count, cNames, sNames)
					countshown = countshown + 1
				end
			end
			if countshown > 0 then
				local trackChar = DTAddon.SV.trackChar
				-- Bottom separator line if anything is shown.
				ZO_Tooltip_AddDivider(InformationTooltip)
				local fP = DTAddon.DungeonIndex[inode].fP
				if fP ~= 0 then
					if trackChar == true and DTAddon.ASV[800].showGFComp == true then
						local label = tostring(GetAchievementInfo(fP))
						label = LocalizeText(label)
						label = label .. ": "
						local numCriteria = GetAchievementNumCriteria(fP)
						local completed = 0
						for i = 1, numCriteria do
							local _, numCompleted, _ = GetAchievementCriterion(fP, i)
							if numCompleted == 1 then 
								completed = completed + 1
							end
						end
						-- Colorize achievement title by faction.
						if fP == 1073 then label = "|ce05a4c" .. label .. "|r"
						elseif fP == 1075 then label = "|cfff578" .. label .. "|r"
						elseif fP == 1074 then label = "|c6a91b6" .. label .. "|r" end
						label = DTAddon.DungeonIndex[inode].icon .. label .. tostring(completed) .. "/" .. tostring(numCriteria)
						InformationTooltip:AddLine(label, "ZoFontGameOutline")
						ZO_Tooltip_AddDivider(InformationTooltip)
					end
				end
			end
		end
	elseif izpoi ~= 0 then -- Add group delve tooltip info.
		local showGCComp = DTAddon.ASV[800].showGCComp
		local showDBComp = DTAddon.ASV[800].showDBComp
		local showDFComp = DTAddon.ASV[800].showDFComp
		local trackChar = DTAddon.SV.trackChar
		if showGCComp == true or showDBComp == true or showDFComp == true then
			InformationTooltip:AddLine(DTAddon.DelveIndex[izpoi].icon, "ZoFontGameOutline")
			if trackChar == true and showDFComp == true then
				local fP = DTAddon.DelveIndex[izpoi].fP
				if fP ~= 0 then
					local label = tostring(GetAchievementInfo(fP))
					label = LocalizeText(label)
					label = label .. ": "
					local numCriteria = GetAchievementNumCriteria(fP)
					local completed = 0
					for i = 1, numCriteria do
						local _, numCompleted, _ = GetAchievementCriterion(fP, i)
						if numCompleted == 1 then 
							completed = completed + 1
						end
					end
					-- Colorize achievement title by faction.
					if fP == 1068 then label = "|ce05a4c" .. label .. "|r"
					elseif fP == 1069 then label = "|cfff578" .. label .. "|r"
					elseif fP == 1070 then label = "|c6a91b6" .. label .. "|r" end
					label = label .. tostring(completed) .. "/" .. tostring(numCriteria)
					InformationTooltip:AddLine(label, "ZoFontGameOutline")
				end
			end
			ZO_Tooltip_AddDivider(InformationTooltip)
		end

		if showGCComp == true then
			local onode = izpoi + 200
			local ct = DTAddon.ASV[onode].complete
			local it = DTAddon.ASV[onode].incomplete
			local cNames = GetColorSortedNames(ct, it)
			local sNames = GetSortedNames(ct, it)
			local count = #cNames
			if count > 0 then
				InformationTooltip:AddLine("|cffffff" .. L.DTAddon_CGChal .. "|r", "ZoFontGameOutline")
				WrapNames(count, cNames, sNames)
				countshown = countshown + 1
			end
		end
		if showDBComp == true then
			local onode = izpoi + 300
			local ct = DTAddon.ASV[onode].complete
			local it = DTAddon.ASV[onode].incomplete
			local cNames = GetColorSortedNames(ct, it)
			local sNames = GetSortedNames(ct, it)
			local count = #cNames
			if count > 0 then
				InformationTooltip:AddLine("|cffffff" .. L.DTAddon_CDBoss .. "|r", "ZoFontGameOutline")
				WrapNames(count, cNames, sNames)
				countshown = countshown + 1
			end
		end
	elseif pinType == 21 or pinType == 22 then
		InformationTooltip:AddLine(poiName, "ZoFontGame")
	end
end

local function ToggleActivityTooltip(control, op)
	if op == 1 then
		if DTAddon.ASV[800].showLFGt == true then
			local tooltip = ZO_ActivityFinderTemplateTooltip_Keyboard
			local data = control.node.data
			local lfgIndex = data.lfgIndex
			local levelMin = data.levelMin
			local trackChar = DTAddon.SV.trackChar
			local sVar
			local fP
			InitializeTooltip(InformationTooltip, tooltip, TOPRIGHT, -4, -3, TOPLEFT)

			if levelMin < GetMaxLevel() then
				sVar = DTAddon.FinderNormalIndex[lfgIndex].svI
				fP = DTAddon.DungeonIndex[sVar].fP
				local tsVar = DTAddon.FinderNormalIndex[lfgIndex].svI
				local ct = DTAddon.ASV[tsVar].complete
				local it = DTAddon.ASV[tsVar].incomplete
				local cNames = GetColorSortedNames(ct, it)
				local sNames = GetSortedNames(ct, it)
				local count = #cNames
				if count > 0 then
					InformationTooltip:AddLine("|cffffff" .. L.DTAddon_CNorm .. "|r", "ZoFontGameOutline")
					WrapNames(count, cNames, sNames)
				end
			else
				sVar = DTAddon.FinderVeteranIndex[lfgIndex].svI
				fP = DTAddon.DungeonIndex[sVar].fP
				local tsVar = DTAddon.FinderVeteranIndex[lfgIndex].svI + 100
				local ct = DTAddon.ASV[tsVar].complete
				local it = DTAddon.ASV[tsVar].incomplete
				local cNames = GetColorSortedNames(ct, it)
				local sNames = GetSortedNames(ct, it)
				local count = #cNames
				if count > 0 then
					InformationTooltip:AddLine("|cffffff" .. L.DTAddon_CVet .. "|r", "ZoFontGameOutline")
					WrapNames(count, cNames, sNames)
				end
			end

			-- Add dungeon unlock level to the LFG tooltip.
			InformationTooltip:AddLine("|cffffff" .. "Unlocks at Level: " .. levelMin .. "|r", "ZoFontGameOutline")

			if fP ~= 0 then -- Show faction achievement progress.
				if trackChar == true and DTAddon.ASV[800].showGFComp == true then
					ZO_Tooltip_AddDivider(InformationTooltip)
					local label = tostring(GetAchievementInfo(fP))
					label = LocalizeText(label)
					label = label .. ": "
					local numCriteria = GetAchievementNumCriteria(fP)
					local completed = 0
					for i = 1, numCriteria do
						local _, numCompleted, _ = GetAchievementCriterion(fP, i)
						if numCompleted == 1 then 
							completed = completed + 1
						end
					end
					-- Colorize achievement title by faction.
					if fP == 1073 then label = "|ce05a4c" .. label .. "|r"
					elseif fP == 1075 then label = "|cfff578" .. label .. "|r"
					elseif fP == 1074 then label = "|c6a91b6" .. label .. "|r" end
					label = DTAddon.DungeonIndex[sVar].icon .. label .. tostring(completed) .. "/" .. tostring(numCriteria)
					InformationTooltip:AddLine(label, "ZoFontGameOutline")
				end
			end
		end
	elseif op == 2 then
		ClearTooltip(InformationTooltip)
	end
end

local function HookDungeonTooltips()
	ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_SEEN].tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION
	ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_COMPLETE].tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION
	local TooltipCreatorFastTravel = ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE].creator
	ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE].creator = function(...)
		TooltipCreatorFastTravel(...)
		ModifyDungeonTooltip(...)
	end
	local TooltipCreatorPOISeen = ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_SEEN].creator
	ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_SEEN].creator = function(...)
		TooltipCreatorPOISeen(...)
		ModifyDungeonTooltip(...)
	end
	local TooltipCreatorPOIComplete = ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_COMPLETE].creator
	ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_COMPLETE].creator = function(...)
		TooltipCreatorPOIComplete(...)
		ModifyDungeonTooltip(...)
	end
	local DTAddonShowActivityTooltip = ZO_ActivityFinderTemplate_Keyboard.ShowActivityTooltip
	ZO_ActivityFinderTemplate_Keyboard.ShowActivityTooltip = function(self, control)
		DTAddonShowActivityTooltip(self, control)
		ToggleActivityTooltip(self, 1)
	end
	local DTAddonHideActivityTooltip = ZO_ActivityFinderTemplate_Keyboard.HideActivityTooltip
	ZO_ActivityFinderTemplate_Keyboard.HideActivityTooltip = function(self)
		DTAddonHideActivityTooltip(self)
		ToggleActivityTooltip(nil, 2)
	end
end

------------------------------------------------------------------------------------------------------------------------------------
-- Update character achievement progress
------------------------------------------------------------------------------------------------------------------------------------
local function AddName(dtable, playername)
	if not Contains(dtable, playername) then
		table.insert(dtable, #dtable + 1, playername)
	end
end

local function RemoveName(dtable, playername)
	if Contains(dtable, playername) then
		table.remove(dtable, FindName(dtable, playername))
	end
end

local function UpdateNormalDungeons()
	for cD = 1, 32 do
		local playername = GetUnitName("player")
		local status = {GetAchievementInfo(DTAddon.DungeonIndex[cD].nA)}
		local sVar = cD
		if status[5] == true then
			AddName(DTAddon.ASV[sVar].complete, playername)
			RemoveName(DTAddon.ASV[sVar].incomplete, playername)
		elseif status[5] == false then
			AddName(DTAddon.ASV[sVar].incomplete, playername)
			RemoveName(DTAddon.ASV[sVar].complete, playername)
		end
	end
end

local function UpdateVeteranDungeons()
	for cD = 1, 32 do
		local playername = GetUnitName("player")
		local status = {GetAchievementInfo(DTAddon.DungeonIndex[cD].vA)}
		local sVar = cD + 100
		if status[5] == true then
			AddName(DTAddon.ASV[sVar].complete, playername)
			RemoveName(DTAddon.ASV[sVar].incomplete, playername)
		elseif status[5] == false then
			AddName(DTAddon.ASV[sVar].incomplete, playername)
			RemoveName(DTAddon.ASV[sVar].complete, playername)
		end
	end
end

local function UpdateDelveSkillpoint()
	for cD = 1, 18 do
		local playername = GetUnitName("player")
		local status = {GetAchievementInfo(DTAddon.DelveIndex[cD].gA)}
		local sVar = cD + 200
		if status[5] == true then
			AddName(DTAddon.ASV[sVar].complete, playername)
			RemoveName(DTAddon.ASV[sVar].incomplete, playername)
		elseif status[5] == false then
			AddName(DTAddon.ASV[sVar].incomplete, playername)
			RemoveName(DTAddon.ASV[sVar].complete, playername)
		end
	end
end

local function UpdateDelveCompletion()
	for cD = 1, 18 do
		local playername = GetUnitName("player")
		local status = {GetAchievementInfo(DTAddon.DelveIndex[cD].bA)}
		local sVar = cD + 300
		if status[5] == true then
			AddName(DTAddon.ASV[sVar].complete, playername)
			RemoveName(DTAddon.ASV[sVar].incomplete, playername)
		elseif status[5] == false then
			AddName(DTAddon.ASV[sVar].incomplete, playername)
			RemoveName(DTAddon.ASV[sVar].complete, playername)
		end
	end
end

local function CheckTracking()
	if DTAddon.SV.trackChar == true then
		UpdateNormalDungeons()
		UpdateVeteranDungeons()
		UpdateDelveSkillpoint()
		UpdateDelveCompletion()
	elseif DTAddon.SV.trackChar == false then
		local playername = GetUnitName("player")
		for i = 1, 318 do
			if DTAddon.ASV[i] ~= nil then
				RemoveName(DTAddon.ASV[i].complete, playername)
				RemoveName(DTAddon.ASV[i].incomplete, playername)
			end
		end
	end
end

local function ClearDatabase() -- Remove all names from the database
	for i = 1, 318 do
		if DTAddon.ASV[i] ~= nil then
			DTAddon.ASV[i].complete = {}
			DTAddon.ASV[i].incomplete = {}
		end
	end
	CheckTracking()
end

local function AchievementCompleted(eventCode, name, points, id, link) -- Update database on achievement completion
	for a = 1, 32 do
		if DTAddon.DungeonIndex[a].nA == id or DTAddon.DungeonIndex[a].vA == id then
			CheckTracking()
		end
	end
	for b = 1, 18 do
		if DTAddon.DelveIndex[b].bA == id or DTAddon.DelveIndex[b].gA == id then
			CheckTracking()
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------------
-- Set up the options panel in Addon Settings
------------------------------------------------------------------------------------------------------------------------------------
local function CreateSettingsWindow(addonName)
	local panelData = {
		type					= "panel",
		name					= L.DTAddon_Title,
		displayName				= ZO_HIGHLIGHT_TEXT:Colorize(L.DTAddon_Title),
		author					= DTAddon.Author,
		version					= DTAddon.Version,
		registerForRefresh		= true,
		registerForDefaults		= true,
	}

	local optionsData = {
	{
		type = "header",
		name = ZO_HIGHLIGHT_TEXT:Colorize(L.DTAddon_GOpts),
	},
	{
		type = "checkbox",
		name = L.DTAddon_SLFGt,
		tooltip = L.DTAddon_SLFGtD,
		getFunc = function() return DTAddon.ASV[800].showLFGt end,
		setFunc = function(value) DTAddon.ASV[800].showLFGt = value end,
		width = "full",
		default = DTAddon.SVarDefaultA[800].showLFGt,
	},
	{
		type = "checkbox",
		name = L.DTAddon_SGFComp,
		tooltip = L.DTAddon_SGFCompD,
		getFunc = function() return DTAddon.ASV[800].showGFComp end,
		setFunc = function(value) DTAddon.ASV[800].showGFComp = value end,
		width = "full",
		default = DTAddon.SVarDefaultA[800].showGFComp,
		disabled = function() return not DTAddon.SV.trackChar end,
	},
	{
		type = "colorpicker",
		name = L.DTAddon_CNColor,
		tooltip = L.DTAddon_CNColorD,
		getFunc = function() return unpack(DTAddon.ASV[800].cColorT) end,
		setFunc = function(r, g, b, a)
					DTAddon.ASV[800].cColorT = { r, g, b, a }
					DTAddon.ASV[800].cColorS = num2hex(DTAddon.ASV[800].cColorT)
				end,
		width = "full",
		default = {r=DTAddon.SVarDefaultA[800].cColorT[1], g=DTAddon.SVarDefaultA[800].cColorT[2], b=DTAddon.SVarDefaultA[800].cColorT[3]},
	},
	{
		type = "colorpicker",
		name = L.DTAddon_NNColor,
		tooltip = L.DTAddon_NNColorD,
		getFunc = function() return unpack(DTAddon.ASV[800].iColorT) end,
		setFunc = function(r, g, b, a)
					DTAddon.ASV[800].iColorT = { r, g, b, a }
					DTAddon.ASV[800].iColorS = num2hex(DTAddon.ASV[800].iColorT)
				end,
		width = "full",
		default = {r=DTAddon.SVarDefaultA[800].iColorT[1], g=DTAddon.SVarDefaultA[800].iColorT[2], b=DTAddon.SVarDefaultA[800].iColorT[3]},
	},
	{
		type			= 'submenu',
		name			= L.DTAddon_MAPOpt,
		tooltip			= L.DTAddon_MAPOpt,
		controls		= {
						[1] = {
							type = "checkbox",
							name = L.DTAddon_SNComp,
							tooltip = L.DTAddon_SNCompD,
							getFunc = function() return DTAddon.ASV[800].showNComp end,
							setFunc = function(value) DTAddon.ASV[800].showNComp = value end,
							width = "full",
							default = DTAddon.SVarDefaultA[800].showNComp,
						},
						[2] = {
							type = "checkbox",
							name = L.DTAddon_SVComp,
							tooltip = L.DTAddon_SVCompD,
							getFunc = function() return DTAddon.ASV[800].showVComp end,
							setFunc = function(value) DTAddon.ASV[800].showVComp = value end,
							width = "full",
							default = DTAddon.SVarDefaultA[800].showVComp,
						},
						[3] = {
							type = "checkbox",
							name = L.DTAddon_SGCComp,
							tooltip = L.DTAddon_SGCCompD,
							getFunc = function() return DTAddon.ASV[800].showGCComp end,
							setFunc = function(value) DTAddon.ASV[800].showGCComp = value end,
							width = "full",
							default = DTAddon.SVarDefaultA[800].showGCComp,
						},
						[4] = {
							type = "checkbox",
							name = L.DTAddon_SDBComp,
							tooltip = L.DTAddon_SDBCompD,
							getFunc = function() return DTAddon.ASV[800].showDBComp end,
							setFunc = function(value) DTAddon.ASV[800].showDBComp = value end,
							width = "full",
							default = DTAddon.SVarDefaultA[800].showDBComp,
						},
						[5] = {
							type = "checkbox",
							name = L.DTAddon_SDFComp,
							tooltip = L.DTAddon_SDFCompD,
							getFunc = function() return DTAddon.ASV[800].showDFComp end,
							setFunc = function(value) DTAddon.ASV[800].showDFComp = value end,
							width = "full",
							default = DTAddon.SVarDefaultA[800].showDFComp,
							disabled = function() return not DTAddon.SV.trackChar end,
						},
						},
	},
	{
		type = "header",
		name = ZO_HIGHLIGHT_TEXT:Colorize(L.DTAddon_DBReset),
	},
	{
		type = "button",
		name = L.DTAddon_DBResetB,
		tooltip = L.DTAddon_DBResetD,
		width = "full",
		func = function()
			ClearDatabase()
		end,
    },
	{
		type = "header",
		name = ZO_HIGHLIGHT_TEXT:Colorize(L.DTAddon_COpts),
	},
	{
		type			= "checkbox",
		name			= L.DTAddon_CTrack,
		tooltip			= L.DTAddon_CTrackD,
		getFunc			= function() return DTAddon.SV.trackChar end,
		setFunc			= function(value)
							DTAddon.SV.trackChar = value
							CheckTracking()
						end,
		default			= DTAddon.SVarDefaultC.trackChar,
	}
	}

	local LAM = LibStub("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("DTAddon_Panel", panelData)
	LAM:RegisterOptionControls("DTAddon_Panel", optionsData)
end

------------------------------------------------------------------------------------------------------------------------------------
-- Init functions
------------------------------------------------------------------------------------------------------------------------------------
local function OnAddonLoaded(event, addonName)
	if addonName ~= DTAddon.Name then return end
	EVENT_MANAGER:UnregisterForEvent(DTAddon.Name, EVENT_ADD_ON_LOADED)
	DTAddon.SV = ZO_SavedVars:New(DTAddon.Name, 1.0, 'CharacterSettings', DTAddon.SVarDefaultC)
	DTAddon.ASV = ZO_SavedVars:NewAccountWide(DTAddon.Name, 1.0, 'AccountSettings', DTAddon.SVarDefaultA)
	CreateSettingsWindow(addonName)
	HookDungeonTooltips()
	CheckTracking()
end

EVENT_MANAGER:RegisterForEvent(DTAddon.Name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(DTAddon.Name, EVENT_ACHIEVEMENT_AWARDED, AchievementCompleted)
