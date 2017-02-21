local Srendarr		= _G['Srendarr'] -- grab addon table from global
local L				= Srendarr:GetLocale()

-- CONSTS --
local ABILITY_TYPE_CHANGEAPPEARANCE	= ABILITY_TYPE_CHANGEAPPEARANCE
local ABILITY_TYPE_REGISTERTRIGGER	= ABILITY_TYPE_REGISTERTRIGGER
local BUFF_EFFECT_TYPE_DEBUFF		= BUFF_EFFECT_TYPE_DEBUFF

local GROUP_PLAYER_SHORT			= Srendarr.GROUP_PLAYER_SHORT
local GROUP_PLAYER_LONG				= Srendarr.GROUP_PLAYER_LONG
local GROUP_PLAYER_TOGGLED			= Srendarr.GROUP_PLAYER_TOGGLED
local GROUP_PLAYER_PASSIVE			= Srendarr.GROUP_PLAYER_PASSIVE
local GROUP_PLAYER_DEBUFF			= Srendarr.GROUP_PLAYER_DEBUFF
local GROUP_PLAYER_GROUND			= Srendarr.GROUP_PLAYER_GROUND
local GROUP_PLAYER_MAJOR			= Srendarr.GROUP_PLAYER_MAJOR
local GROUP_PLAYER_MINOR			= Srendarr.GROUP_PLAYER_MINOR
local GROUP_PLAYER_ENCHANT			= Srendarr.GROUP_PLAYER_ENCHANT
local GROUP_TARGET_BUFF				= Srendarr.GROUP_TARGET_BUFF
local GROUP_TARGET_DEBUFF			= Srendarr.GROUP_TARGET_DEBUFF
local GROUP_PROMINENT				= Srendarr.GROUP_PROMINENT
local GROUP_PROMINENT2				= Srendarr.GROUP_PROMINENT2
local GROUP_GROUP1					= Srendarr.GROUP_GROUP1	
local GROUP_GROUP2					= Srendarr.GROUP_GROUP2	
local GROUP_GROUP3					= Srendarr.GROUP_GROUP3	
local GROUP_GROUP4					= Srendarr.GROUP_GROUP4	
local GROUP_GROUP5					= Srendarr.GROUP_GROUP5	
local GROUP_GROUP6					= Srendarr.GROUP_GROUP6	
local GROUP_GROUP7					= Srendarr.GROUP_GROUP7	
local GROUP_GROUP8					= Srendarr.GROUP_GROUP8	
local GROUP_GROUP9					= Srendarr.GROUP_GROUP9	
local GROUP_GROUP10					= Srendarr.GROUP_GROUP10
local GROUP_GROUP11					= Srendarr.GROUP_GROUP11
local GROUP_GROUP12					= Srendarr.GROUP_GROUP12
local GROUP_GROUP13					= Srendarr.GROUP_GROUP13
local GROUP_GROUP14					= Srendarr.GROUP_GROUP14
local GROUP_GROUP15					= Srendarr.GROUP_GROUP15
local GROUP_GROUP16					= Srendarr.GROUP_GROUP16
local GROUP_GROUP17					= Srendarr.GROUP_GROUP17
local GROUP_GROUP18					= Srendarr.GROUP_GROUP18
local GROUP_GROUP19					= Srendarr.GROUP_GROUP19
local GROUP_GROUP20					= Srendarr.GROUP_GROUP20
local GROUP_GROUP21					= Srendarr.GROUP_GROUP21
local GROUP_GROUP22					= Srendarr.GROUP_GROUP22
local GROUP_GROUP23					= Srendarr.GROUP_GROUP23
local GROUP_GROUP24					= Srendarr.GROUP_GROUP24

local AURA_TYPE_TIMED				= Srendarr.AURA_TYPE_TIMED
local AURA_TYPE_TOGGLED				= Srendarr.AURA_TYPE_TOGGLED
local AURA_TYPE_PASSIVE				= Srendarr.AURA_TYPE_PASSIVE

-- UPVALUES --
local GetGameTimeMillis				= GetGameTimeMilliseconds
local IsToggledAura					= Srendarr.IsToggledAura
local IsMajorEffect					= Srendarr.IsMajorEffect	-- technically only used for major|minor buffs on the player, major|minor debuffs
local IsMinorEffect					= Srendarr.IsMinorEffect	-- are filtered to the debuff grouping before being checked for
local IsEnchantEffect				= Srendarr.IsEnchantEffect
local IsAlternateAura				= Srendarr.IsAlternateAura
local auraLookup					= Srendarr.auraLookup
local filteredAuras					= Srendarr.filteredAuras
local trackTargets					= {}
local prominentAuras				= {}
local prominentAuras2				= {}
local groupAuras					= {}
local displayFrameRef				= {}
local debugAuras					= {}
local playerName = zo_strformat("<<t:1>>",GetUnitName('player'))
local shortBuffThreshold, passiveEffectsAsPassive, filterDisguisesOnPlayer, filterDisguisesOnTarget

local displayFrameFake = {
	['AddAuraToDisplay'] = function()
 		-- do nothing : used to make the AuraHandler code more manageable, redirects unwanted auras to nil
	end,
}

local groupFrames = {
	[1] = {frame = GROUP_GROUP1},
	[2] = {frame = GROUP_GROUP2},
	[3] = {frame = GROUP_GROUP3},
	[4] = {frame = GROUP_GROUP4},
	[5] = {frame = GROUP_GROUP5},
	[6] = {frame = GROUP_GROUP6},
	[7] = {frame = GROUP_GROUP7},
	[8] = {frame = GROUP_GROUP8},
	[9] = {frame = GROUP_GROUP9},
	[10] = {frame = GROUP_GROUP10},
	[11] = {frame = GROUP_GROUP11},
	[12] = {frame = GROUP_GROUP12},
	[13] = {frame = GROUP_GROUP13},
	[14] = {frame = GROUP_GROUP14},
	[15] = {frame = GROUP_GROUP15},
	[16] = {frame = GROUP_GROUP16},
	[17] = {frame = GROUP_GROUP17},
	[18] = {frame = GROUP_GROUP18},
	[19] = {frame = GROUP_GROUP19},
	[20] = {frame = GROUP_GROUP20},
	[21] = {frame = GROUP_GROUP21},
	[22] = {frame = GROUP_GROUP22},
	[23] = {frame = GROUP_GROUP23},
	[24] = {frame = GROUP_GROUP24},
}

-- ------------------------
-- AURA HANDLER
-- ------------------------
local function checkUtag(s, groupSize)
	if FTC_VARS then
		local EnableFrames = FTC_VARS.Default[GetDisplayName()]["$AccountWide"].EnableFrames
		local RaidFrames = FTC_VARS.Default[GetDisplayName()]["$AccountWide"].RaidFrames
		if groupSize <= 4 and EnableFrames == true then
			return Srendarr.ftcGDB[s].tag
		elseif groupSize >= 5 and EnableFrames == true and RaidFrames == true then
			return Srendarr.ftcRDB[s].tag
		elseif groupSize <= 4 and EnableFrames == false then
			return Srendarr.stGDB[s].tag
		elseif groupSize >= 5 and (RaidFrames == false or EnableFrames == false) then
			return Srendarr.stRDB[s].tag
		end
	elseif not FTC_VARS then
		if groupSize <= 4 then
			return Srendarr.stGDB[s].tag
		elseif groupSize >= 5 then
			return Srendarr.stRDB[s].tag
		end
	end
end

local function AuraHandler(flagBurst, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID, groupChange)
	local groupBlacklist = Srendarr.db.groupBlacklist
	local IsGroupUnit = Srendarr.IsGroupUnit
	
	if (start ~= finish and (finish - start) < 2.25) then return end -- abort showing any timed auras with a duration of < 2.25s

	if filteredAuras[unitTag] ~= nil then
		if (filteredAuras[unitTag][abilityID]) then return end -- abort immediately if this is an ability we've filtered
	end
	
	if (auraLookup[unitTag][abilityID]) then -- aura exists, update its data (assume would not exist unless passed filters earlier)
		auraLookup[unitTag][abilityID]:Update(start, finish)

		if (unitTag == 'player') and (IsUnitGrouped('player')) then -- update duplicate tracking of player buffs on group frame
			if ((not groupBlacklist) and (groupAuras[abilityID])) or ((groupBlacklist) and (not groupAuras[abilityID])) then
				local groupSize = GetGroupSize()
				for s = 1, groupSize do
					local groupTag = GetGroupUnitTagByIndex(s)
					if (AreUnitsEqual(groupTag, 'player')) then
						if (auraLookup[groupTag][abilityID]) then
							auraLookup[groupTag][abilityID]:Update(start, finish)
							return
						end
					end
				end
			end
		end
		return
	end

	if (IsGroupUnit(unitTag)) then -- group aura detected, assign to appropriate window
		if ((not groupBlacklist) and (groupAuras[abilityID])) or ((groupBlacklist) and (not groupAuras[abilityID])) then
			local groupSize = GetGroupSize()
			for s = 1, groupSize do
				local groupTag = GetGroupUnitTagByIndex(s)
				if (AreUnitsEqual(groupTag, unitTag)) then
					local uTag = checkUtag(s, groupSize)
					if uTag and uTag ~= 0 then
						local groupFrame = groupFrames[tonumber(uTag)].frame
						displayFrameRef[groupFrame]:AddAuraToDisplay(flagBurst, groupFrame, AURA_TYPE_TIMED, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
						return
					end
				end
			end
		end
	end

	-- Prominent aura detected, assign to appropriate window
	if (prominentAuras[abilityID] and unitTag ~= 'reticleover') then
		displayFrameRef[GROUP_PROMINENT]:AddAuraToDisplay(flagBurst, GROUP_PROMINENT, AURA_TYPE_TIMED, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
		return
	end
	if (prominentAuras2[abilityID] and unitTag ~= 'reticleover') then
		displayFrameRef[GROUP_PROMINENT2]:AddAuraToDisplay(flagBurst, GROUP_PROMINENT2, AURA_TYPE_TIMED, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
		return
	end

	if (unitTag == 'reticleover') then -- new aura on target
		if (effectType == BUFF_EFFECT_TYPE_DEBUFF) then
			-- debuff on target, check for it being a passive (not sure they can be, but just to be sure as things break with a 'timed' passive)
			displayFrameRef[GROUP_TARGET_DEBUFF]:AddAuraToDisplay(flagBurst, GROUP_TARGET_DEBUFF, (start == finish) and AURA_TYPE_PASSIVE or AURA_TYPE_TIMED, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
		else
			-- buff on target, sort as passive, toggle or timed and add
			if (filterDisguisesOnTarget and abilityType == ABILITY_TYPE_CHANGEAPPEARANCE) then return end -- is a disguise and they are filtered

			if (start == finish) then -- toggled or passive
				displayFrameRef[GROUP_TARGET_BUFF]:AddAuraToDisplay(flagBurst, GROUP_TARGET_BUFF, (IsToggledAura(abilityID)) and AURA_TYPE_TOGGLED or AURA_TYPE_PASSIVE, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
			else -- timed buff
				displayFrameRef[GROUP_TARGET_BUFF]:AddAuraToDisplay(flagBurst, GROUP_TARGET_BUFF, AURA_TYPE_TIMED, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
			end
		end
	elseif (unitTag == 'player') then -- new aura on player
		if (effectType == BUFF_EFFECT_TYPE_DEBUFF) then
			-- debuff on player, check for it being a passive (not sure they can be, but just to be sure as things break with a 'timed' passive)
			displayFrameRef[GROUP_PLAYER_DEBUFF]:AddAuraToDisplay(flagBurst, GROUP_PLAYER_DEBUFF, (start == finish) and AURA_TYPE_PASSIVE or AURA_TYPE_TIMED, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
		else
			-- buff on player, sort as passive, toggled or timed and add
			if (filterDisguisesOnPlayer and abilityType == ABILITY_TYPE_CHANGEAPPEARANCE) then return end -- is a disguise and they are filtered

			if (start == finish) then -- toggled or passive
				if (IsMajorEffect(abilityID) and not passiveEffectsAsPassive) then -- major buff on player
					displayFrameRef[GROUP_PLAYER_MAJOR]:AddAuraToDisplay(flagBurst, GROUP_PLAYER_MAJOR, AURA_TYPE_PASSIVE, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
				elseif (IsMinorEffect(abilityID) and not passiveEffectsAsPassive) then -- minor buff on player
					displayFrameRef[GROUP_PLAYER_MINOR]:AddAuraToDisplay(flagBurst, GROUP_PLAYER_MINOR, AURA_TYPE_PASSIVE, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
				elseif (IsToggledAura(abilityID)) then -- toggled
					displayFrameRef[GROUP_PLAYER_TOGGLED]:AddAuraToDisplay(flagBurst, GROUP_PLAYER_TOGGLED, AURA_TYPE_TOGGLED, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
				else -- passive, including passive major and minor effects, not seperated out before
					displayFrameRef[GROUP_PLAYER_PASSIVE]:AddAuraToDisplay(flagBurst, GROUP_PLAYER_PASSIVE, AURA_TYPE_PASSIVE, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
				end
			else -- timed buff
				if (IsMajorEffect(abilityID)) then -- major buff on player
					displayFrameRef[GROUP_PLAYER_MAJOR]:AddAuraToDisplay(flagBurst, GROUP_PLAYER_MAJOR, AURA_TYPE_TIMED, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
				elseif (IsMinorEffect(abilityID)) then -- minor buff on player
					displayFrameRef[GROUP_PLAYER_MINOR]:AddAuraToDisplay(flagBurst, GROUP_PLAYER_MINOR, AURA_TYPE_TIMED, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
				elseif (IsEnchantEffect(abilityID)) then -- enchant proc on player
					displayFrameRef[GROUP_PLAYER_ENCHANT]:AddAuraToDisplay(flagBurst, GROUP_PLAYER_ENCHANT, AURA_TYPE_TIMED, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
				elseif ((finish - start) > shortBuffThreshold) then -- is considered a long duration buff
					displayFrameRef[GROUP_PLAYER_LONG]:AddAuraToDisplay(flagBurst, GROUP_PLAYER_LONG, AURA_TYPE_TIMED, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
				else
					displayFrameRef[GROUP_PLAYER_SHORT]:AddAuraToDisplay(flagBurst, GROUP_PLAYER_SHORT, AURA_TYPE_TIMED, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
				end

				if (IsUnitGrouped("player")) then -- allow duplicate tracking of player buffs on group frame
					if ((not groupBlacklist) and (groupAuras[abilityID])) or ((groupBlacklist) and (not groupAuras[abilityID])) then 
						local groupSize = GetGroupSize()
						for s = 1, groupSize do
							local groupTag = GetGroupUnitTagByIndex(s)
							if (AreUnitsEqual(groupTag, "player")) then
								local uTag = checkUtag(s, groupSize)
								if uTag and uTag ~= 0 then
									local groupFrame = groupFrames[tonumber(uTag)].frame
									displayFrameRef[groupFrame]:AddAuraToDisplay(flagBurst, groupFrame, AURA_TYPE_TIMED, auraName, groupTag, start, finish, icon, effectType, abilityType, abilityID)
									return
								end
							end
						end
					end
				end
			end
		end
	elseif (unitTag == 'groundaoe') then -- new ground aoe cast by player (assume always timed)
		displayFrameRef[GROUP_PLAYER_GROUND]:AddAuraToDisplay(flagBurst, GROUP_PLAYER_GROUND, AURA_TYPE_TIMED, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
	end
end

function Srendarr:ConfigureAuraHandler()
	for group, frameNum in pairs(self.db.auraGroups) do
		-- if a group is set to hidden, auras will be sent to a fake frame that does nothing (simplifies things)
		displayFrameRef[group] = (frameNum > 0) and self.displayFrames[frameNum] or displayFrameFake
	end

	shortBuffThreshold		= self.db.shortBuffThreshold
	passiveEffectsAsPassive	= self.db.passiveEffectsAsPassive
	filterDisguisesOnPlayer	= self.db.filtersPlayer.disguise
	filterDisguisesOnTarget	= self.db.filtersTarget.disguise

	for id in pairs(prominentAuras) do
		prominentAuras[id] = nil -- clean out prominent 1 auras list
	end

	for id in pairs(prominentAuras2) do
		prominentAuras2[id] = nil -- clean out prominent 2 auras list
	end

	for id in pairs(groupAuras) do
		groupAuras[id] = nil -- clean out group auras list
	end

	for _, abilityIDs in pairs(self.db.prominentWhitelist) do
		for id in pairs(abilityIDs) do
			prominentAuras[id] = true -- populate promience 1 list from saved database
		end
	end

	for _, abilityIDs in pairs(self.db.prominentWhitelist2) do
		for id in pairs(abilityIDs) do
			prominentAuras2[id] = true -- populate promience 2 list from saved database
		end
	end

	for _, abilityIDs in pairs(self.db.groupWhitelist) do
		for id in pairs(abilityIDs) do
			groupAuras[id] = true -- populate group list from saved database
		end
	end
	
end

-- hook function to pass update data from group events elsewhere (Phinix)
Srendarr.PassToAuraHandler = function(flagBurst, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID, groupChange)
	AuraHandler(flagBurst, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID, groupChange)
end


-- ------------------------
-- EVENT: EVENT_PLAYER_ACTIVATED, EVENT_PLAYER_ALIVE
do ------------------------
    local GetNumBuffs       	= GetNumBuffs
    local GetUnitBuffInfo   	= GetUnitBuffInfo
    local NUM_DISPLAY_FRAMES	= Srendarr.NUM_DISPLAY_FRAMES

	local auraLookup				= Srendarr.auraLookup
	local alternateAura				= Srendarr.alternateAura
    local numAuras, auraName, start, finish, stack, icon, effectType, abilityType, abilityID

	Srendarr.OnPlayerActivatedAlive = function()
		for _, auras in pairs(auraLookup) do -- iterate all aura lookups
			for _, aura in pairs(auras) do -- iterate all auras for each lookup
				aura:Release(true)
			end
		end

		numAuras = GetNumBuffs('player')

		if (numAuras > 0) then -- player has auras, scan and send to handle
			for i = 1, numAuras do
				auraName, start, finish, _, _, icon, _, effectType, abilityType, _, abilityID = GetUnitBuffInfo('player', i)

				if Srendarr.db.consolidateEnabled == true then -- Handles multi-aura passive abilities like Restoring Aura
					if (IsAlternateAura(abilityID)) then -- Consolidate multi-aura passive abilities
						AuraHandler(true, alternateAura[abilityID].altName, 'player', start, finish, icon, effectType, abilityType, abilityID)
					else
						AuraHandler(true, auraName, 'player', start, finish, icon, effectType, abilityType, abilityID)
					end
				else
					AuraHandler(true, auraName, 'player', start, finish, icon, effectType, abilityType, abilityID)
				end
			end
		end

		for x = 1, NUM_DISPLAY_FRAMES do
			Srendarr.displayFrames[x]:UpdateDisplay() -- update the display for all frames
		end
		
		Srendarr.OnGroupChanged()
	end
end

-- ------------------------
-- EVENT: EVENT_PLAYER_DEAD
do ------------------------
    local NUM_DISPLAY_FRAMES	= Srendarr.NUM_DISPLAY_FRAMES

    local auraLookup			= Srendarr.auraLookup

	Srendarr.OnPlayerDead = function()
		for _, auras in pairs(auraLookup) do -- iterate all aura lookups
			for _, aura in pairs(auras) do -- iterate all auras for each lookup
				aura:Release(true)
			end
		end

		for x = 1, NUM_DISPLAY_FRAMES do
			Srendarr.displayFrames[x]:UpdateDisplay() -- update the display for all frames
		end
	end
end

-- ------------------------
-- EVENT: EVENT_PLAYER_COMBAT_STATE
do -----------------------
    local NUM_DISPLAY_FRAMES	= Srendarr.NUM_DISPLAY_FRAMES

    local displayFramesScene	= Srendarr.displayFramesScene

	OnCombatState = function(e, inCombat)
		if (inCombat) then
			if (Srendarr.db.combatDisplayOnly) then
				for x = 1, NUM_DISPLAY_FRAMES do
					displayFramesScene[x]:SetHiddenForReason('combatstate', false)
				end
			end
		else
			if (Srendarr.db.combatDisplayOnly) then
				for x = 1, NUM_DISPLAY_FRAMES do
					displayFramesScene[x]:SetHiddenForReason('combatstate', true)
				end
			end
		end
	end

	function Srendarr:ConfigureOnCombatState()
		if (self.db.combatDisplayOnly) then
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, OnCombatState)

			OnCombatState(nil, IsUnitInCombat('player')) -- force an update
		else
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE)

			if (self.displayFramesScene[1]:IsHiddenForReason('combatstate')) then -- if currently hidden due to setting, show
				for x = 1, NUM_DISPLAY_FRAMES do
					self.displayFramesScene[x]:SetHiddenForReason('combatstate', false)
				end
			end
		end
	end

	Srendarr.OnCombatState = OnCombatState
end

-- ------------------------
-- EVENT: EVENT_ACTION_SLOT_ABILITY_USED
do ------------------------
	local ABILITY_TYPE_NONE 	= ABILITY_TYPE_NONE		-- no fakes have any specifc ability type
	local BUFF_EFFECT_TYPE_BUFF = BUFF_EFFECT_TYPE_BUFF -- all fakes are buffs or gtaoe

	local GetGameTimeMillis		= GetGameTimeMilliseconds
	local GetLatency			= GetLatency

	local slotData				= Srendarr.slotData
	local fakeAuras				= Srendarr.fakeAuras
	local slotAbilityName, currentTime

	Srendarr.OnActionSlotAbilityUsed = function(e, slotID)
		if (slotID < 3 or slotID > 8) then return end -- abort if not a main ability (or ultimate)

		slotAbilityName = slotData[slotID].abilityName

		if (not fakeAuras[slotAbilityName]) then return end -- no fake aura needed for this ability (majority case)

  		currentTime = GetGameTimeMillis() / 1000

		AuraHandler(
			false,
			slotAbilityName,
			fakeAuras[slotAbilityName].unitTag,
			currentTime,
			currentTime + fakeAuras[slotAbilityName].duration + (GetLatency() / 1000), -- + cooldown? GetSlotCooldownInfo(slotID)
			slotData[slotID].abilityIcon,
			BUFF_EFFECT_TYPE_BUFF,
			ABILITY_TYPE_NONE,
			fakeAuras[slotAbilityName].abilityID
		)
	end

	function Srendarr:ConfigureOnActionSlotAbilityUsed()
		if (self.db.auraFakeEnabled) then
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTION_SLOT_ABILITY_USED,	Srendarr.OnActionSlotAbilityUsed)
		else
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ACTION_SLOT_ABILITY_USED)
		end
	end
end

-- ------------------------
-- EVENT: EVENT_RETICLE_TARGET_CHANGED
do ------------------------
    local GetNumBuffs      			= GetNumBuffs
    local GetUnitBuffInfo  			= GetUnitBuffInfo
    local DoesUnitExist    			= DoesUnitExist
    local IsUnitDead				= IsUnitDead

	local alternateAura				= Srendarr.alternateAura
	local fakeTargetDebuffs			= Srendarr.fakeTargetDebuffs
	local auraLookupReticle			= Srendarr.auraLookup['reticleover'] -- local ref for speed, this functions expensive
	local targetDisplayFrame1		= false -- local refs to frames displaying target auras (if any)
	local targetDisplayFrame2		= false -- local refs to frames displaying target auras (if any)
	local hideOnDead				= false
	local currentTime
	local numAuras, auraName, start, finish, stack, icon, effectType, abilityType, abilityID, canClickOff, castByPlayer

	local function OnTargetChanged()

		local unitName = zo_strformat("<<t:1>>",GetUnitName('reticleover'))

		for _, aura in pairs(auraLookupReticle) do
			aura:Release(true) -- old auras cleaned out
		end

		if (DoesUnitExist('reticleover') and not (hideOnDead and IsUnitDead('reticleover'))) then -- have a target, scan for auras

			local function ActiveFakes() -- Check for active fake debuffs
				local total = 0
				for k,v in pairs(fakeTargetDebuffs) do
					currentTime = GetGameTimeMillis() / 1000
					if trackTargets[k] ~= nil and trackTargets[k][unitName] ~= nil then
						if trackTargets[k][unitName] < currentTime then
							trackTargets[k][unitName] = nil -- Clear expired targets from cache
						else
							total = total + 1
						end
					end
				end
				return total
			end

			numAuras = GetNumBuffs('reticleover') + ActiveFakes()

			if (numAuras > 0) then -- target has auras, scan and send to handler

				for k,v in pairs(fakeTargetDebuffs) do -- Reassign still-existing fake debuffs on target
					currentTime = GetGameTimeMillis() / 1000
					if trackTargets[k] ~= nil and trackTargets[k][unitName] ~= nil then
						if trackTargets[k][unitName] > currentTime then
							AuraHandler(
								false,
								GetAbilityName(k),
								'reticleover',
								currentTime,
								trackTargets[k][unitName],
								fakeTargetDebuffs[k].icon,
								BUFF_EFFECT_TYPE_DEBUFF,
								ABILITY_TYPE_NONE,
								k
							)
						end
					end
				end

				for i = 1, numAuras do
					auraName, start, finish, buffSlot, stack, icon, buffType, effectType, abilityType, statusType, abilityID, canClickOff, castByPlayer = GetUnitBuffInfo('reticleover', i)

					--[[ This won't help until the API can check if it is from the player on EVENT_EFFECT_CHANGED also
					if Srendarr.db.filtersTarget.onlyPlayer == true then -- option to only show player's debuffs on target
						if (effectType == BUFF_EFFECT_TYPE_DEBUFF) and (not castByPlayer) then return end
					end--]]

					if Srendarr.db.consolidateEnabled == true then -- Handles multi-aura passive abilities like Restoring Aura
						if (IsAlternateAura(abilityID)) then
							AuraHandler(true, alternateAura[abilityID].altName, 'reticleover', start, finish, icon, effectType, abilityType, abilityID)
						else
							AuraHandler(true, auraName, 'reticleover', start, finish, icon, effectType, abilityType, abilityID)
						end
					else
						AuraHandler(true, auraName, 'reticleover', start, finish, icon, effectType, abilityType, abilityID)
					end
				end
			end
		end

		-- no matter, update the display of the 1-2 frames displaying targets auras
		if (targetDisplayFrame1) then targetDisplayFrame1:UpdateDisplay() end
		if (targetDisplayFrame2) then targetDisplayFrame2:UpdateDisplay() end
	end

	function Srendarr:ConfigureOnTargetChanged()
		-- figure out which frames currently display target auras
		local targetBuff	= self.db.auraGroups[Srendarr.GROUP_TARGET_BUFF]
		local targetDebuff	= self.db.auraGroups[Srendarr.GROUP_TARGET_DEBUFF]

		targetDisplayFrame1 = (targetBuff ~= 0) and self.displayFrames[targetBuff] or false
		targetDisplayFrame2 = (targetDebuff ~= 0) and self.displayFrames[targetDebuff] or false
		
		targetBuffControl = self.displayFrames[targetBuff]
		targetDebuffControl = self.displayFrames[targetDebuff]

		hideOnDead			= self.db.hideOnDeadTargets -- set whether to show auras on dead targets

		if (targetDisplayFrame1 or targetDisplayFrame2) then -- event configured and needed, start tracking
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_TARGET_CHANGED,	OnTargetChanged)
		else -- not needed (not displaying any target auras)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_RETICLE_TARGET_CHANGED)
		end
	end

	Srendarr.OnTargetChanged = OnTargetChanged
end

-- ------------------------
-- EVENT: EVENT_EFFECT_CHANGED
-- http://wiki.esoui.com/EVENT_EFFECT_CHANGED
do ------------------------
	local EFFECT_RESULT_FADED			= EFFECT_RESULT_FADED
	local ABILITY_TYPE_AREAEFFECT		= ABILITY_TYPE_AREAEFFECT
--	local ABILITY_TYPE_REGISTERTRIGGER	= ABILITY_TYPE_REGISTERTRIGGER
	local AURA_TYPE_TIMED				= Srendarr.AURA_TYPE_TIMED
	local GetAbilityDescription			= GetAbilityDescription
	local crystalFragmentsPassive		= Srendarr.crystalFragmentsPassive -- special case for tracking fragments proc
	local alternateAura					= Srendarr.alternateAura
	local auraLookup					= Srendarr.auraLookup
	local IsGroupUnit					= Srendarr.IsGroupUnit
	local fadedAura

	Srendarr.OnEffectChanged = function(e, change, slot, auraName, unitTag, start, finish, stack, icon, buffType, effectType, abilityType, statusType, unitName, unitID, abilityID, castByPlayer)
		-- check the aura is on either the player, the target or is a ground aoe -- the description check filters a lot of extra auras attached to many ground effects

		unitTag = (unitTag == 'player' or unitTag == 'reticleover' or IsGroupUnit(unitTag)) and unitTag or (abilityType == ABILITY_TYPE_AREAEFFECT and GetAbilityDescription(abilityID) ~= '') and 'groundaoe' or nil

		-- possible castByPlayer values:
		--	COMBAT_UNIT_TYPE_NONE			= 0
		--	COMBAT_UNIT_TYPE_OTHER			= 5
		--	COMBAT_UNIT_TYPE_PLAYER			= 1
		--	COMBAT_UNIT_TYPE_PLAYER_PET		= 2
		--	COMBAT_UNIT_TYPE_TARGET_DUMMY	= 4

		if (unitTag == 'groundaoe' and castByPlayer ~= 1) then return end -- only track AOE created by the player
		if (not unitTag) then return end -- don't care about this unit and isn't a ground aoe, abort

		if (change == EFFECT_RESULT_FADED) then -- aura has faded
			fadedAura = auraLookup[unitTag][abilityID]

			if (fadedAura) then -- aura exists, tell it to expire if timed, or aaa otherwise
				if (fadedAura.auraType == AURA_TYPE_TIMED) then
					if (fadedAura.abilityType == ABILITY_TYPE_AREAEFFECT) then return end -- gtaoes expire internally (repeated casting, only one timer)

					fadedAura:SetExpired()
				else
					fadedAura:Release()
				end
			end

--			if (abilityType == ABILITY_TYPE_REGISTERTRIGGER and
			if (auraName == crystalFragmentsPassive) then -- special case for tracking fragments proc
				Srendarr:OnCrystalFragmentsProc(false)
			end
		else -- aura has been gained or changed, dispatch to handler

			if Srendarr.db.consolidateEnabled == true then -- Handles multi-aura passive abilities like Restoring Aura
				if (IsAlternateAura(abilityID)) then -- Consolidate multi-aura passive abilities
					AuraHandler(false, alternateAura[abilityID].altName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
				else
					AuraHandler(false, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
				end
			else
				AuraHandler(false, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
			end

--			if (abilityType == ABILITY_TYPE_REGISTERTRIGGER and
			if (auraName == crystalFragmentsPassive) then -- special case for tracking fragments proc
				Srendarr:OnCrystalFragmentsProc(true)
			end
		end
	end
end

-- ------------------------
-- EVENT: EVENT_COMBAT_EVENT
-- http://wiki.esoui.com/EVENT_COMBAT_EVENT
do ------------------------
	local ABILITY_TYPE_NONE 	= ABILITY_TYPE_NONE
	local BUFF_EFFECT_TYPE_BUFF = BUFF_EFFECT_TYPE_BUFF

	local GetGameTimeMillis		= GetGameTimeMilliseconds
	local GetLatency			= GetLatency
	local fakeProcs				= Srendarr.fakeProcs
	local releaseTriggers		= Srendarr.releaseTriggers
	local fakeTargetDebuffs		= Srendarr.fakeTargetDebuffs
	local debuffTarget
	local unitName
	local targetName
	local currentTime
	local stopTime

	Srendarr.OnCombatEvent = function(e, result, isError, aName, aGraphic, aActionSlotType, sName, sType, tName, tType, hitValue, pType, dType, log, sUnitId, tUnitId, abilityId)

		-- Debug mode for tracking new auras. Type /sdbclear or reloadui to reset (Phinix)
		if Srendarr.db.showCombatEvents == true then
			local function EventToChat()
				if (aName ~= "" and aName ~= nil) or (Srendarr.db.showNoNames == true) then
					local source = zo_strformat("<<t:1>>",sName)
					local target = zo_strformat("<<t:1>>",tName)
					local ability = zo_strformat("<<t:1>>",aName)
					if source == playerName then source = "Player" end
					if target == playerName then target = "Player" end
					if Srendarr.db.disableSpamControl == false then debugAuras[abilityId] = true end
					
					if not Srendarr.db.showVerboseDebug then
						d(abilityId..": "..ability.." --> [S] "..source.."  [T] "..target)
					else
						d(aName.." ("..abilityId..")")
						d("event: "..e.." || result: "..result.." || isError: "..tostring(isError).." || aName: "..ability.." || aGraphic: "..aGraphic.." || aActionSlotType: "..aActionSlotType.." || sName: "..source.." || sType: "..sType.." || tName: "..target.." || tType: "..tType.." || hitValue: "..hitValue.." || pType: "..pType.." || dType: "..dType.." || log: "..tostring(log).." || sUnitId: "..sUnitId.." || tUnitId: "..tUnitId.." || abilityId: "..abilityId)
						d("Icon: "..GetAbilityIcon(abilityId))
						d("=========================================================")
					end
				end
			end
			if Srendarr.db.disableSpamControl == true and Srendarr.db.manualDebug == false then
				EventToChat()
			else
				if debugAuras[abilityId] == nil then
					EventToChat()
				end
			end
		end

		if fakeProcs[abilityId] == nil and releaseTriggers[abilityId] == nil and fakeTargetDebuffs[abilityId] == nil then return end -- Combat event not a proc we track

		if releaseTriggers[abilityId] ~= nil then -- Release event for tracked proc so remove aura
			local expired = Srendarr.auraLookup['player'][releaseTriggers[abilityId].release]
			if expired ~= nil then expired:Release() end
		elseif (fakeProcs[abilityId] ~= nil) and (sName == "") then -- Tracked ability removed from bar so remove aura
			local expired = Srendarr.auraLookup['player'][abilityId]
			if expired ~= nil then expired:Release() end

	-- Adding a custom "invisible proc" aura (meaning an aura that doesn't show on the character sheet)

		elseif fakeTargetDebuffs[abilityId] ~= nil then -- New invisible debuff
			local source = zo_strformat("<<t:1>>",sName)
			if source ~= "" then
				currentTime = GetGameTimeMillis() / 1000
				stopTime = currentTime + fakeTargetDebuffs[abilityId].duration + (GetLatency() / 1000)
				unitName = zo_strformat("<<t:1>>",tName)
				if unitName == "" then return end

				if unitName == playerName then
					targetName = 'player'
				else
					if source ~= playerName then return end -- Only show player's fake debuffs on the target
					targetName = 'reticleover'
					trackTargets[abilityId] = trackTargets[abilityId] or {}
					trackTargets[abilityId] [unitName] = stopTime -- Simply unit name tracking, more is not possible
				end

				AuraHandler(
					false,
					zo_strformat("<<t:1>>",aName),
					targetName,
					currentTime,
					stopTime,
					fakeTargetDebuffs[abilityId].icon,
					BUFF_EFFECT_TYPE_DEBUFF,
					ABILITY_TYPE_NONE,
					abilityId
				)
			else -- Fake aura has faded (not working, no idea why)
				--	local expired = Srendarr.auraLookup['player'][abilityID]
				--	if expired ~= nil then expired:Release() end
			end
		else -- New invisible proc on the player
			currentTime = GetGameTimeMillis() / 1000
			if fakeProcs[abilityId].duration == 0 then -- use duration 0 to indicate this is a toggle/passive not timer
				stopTime = currentTime
			else
				stopTime = currentTime + fakeProcs[abilityId].duration + (GetLatency() / 1000)
			end

			AuraHandler(
				false,
				aName,
				fakeProcs[abilityId].unitTag,
				currentTime,
				stopTime,
				fakeProcs[abilityId].icon,
				BUFF_EFFECT_TYPE_BUFF,
				ABILITY_TYPE_NONE,
				abilityId
			)
		end
	end

	function Srendarr:ConfigureOnCombatEvent()
		EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT,	Srendarr.OnCombatEvent)
	end
end

Srendarr.ClearDebug = function()
	debugAuras = {}
end

Srendarr.dbAdd = function(option)
	option = tostring(option):gsub("%D",'')
	if option ~= "" then
		debugAuras[tonumber(option)] = true
		d('+'..option)
	end
end

Srendarr.dbRemove = function(option)
	option = tostring(option):gsub("%D",'')
	if option ~= "" then
		if debugAuras[tonumber(option)] ~= nil then
			debugAuras[tonumber(option)] = nil
			d('-'..option)
		end
	end
end

function Srendarr:InitializeAuraControl()
	-- setup debug system
	SLASH_COMMANDS['/sdbclear']		= Srendarr.ClearDebug
	SLASH_COMMANDS['/sdbadd']		= function(option) Srendarr.dbAdd(option) end
	SLASH_COMMANDS['/sdbremove']	= function(option) Srendarr.dbRemove(option) end
	
	-- setup event handlers
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED,			Srendarr.OnPlayerActivatedAlive) -- same action for both events
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ALIVE,				Srendarr.OnPlayerActivatedAlive) -- same action for both events
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_DEAD,				Srendarr.OnPlayerDead)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_EFFECT_CHANGED,				Srendarr.OnEffectChanged)

	self:ConfigureOnCombatState()			-- EVENT_PLAYER_COMBAT_STATE
	self:ConfigureOnTargetChanged()			-- EVENT_RETICLE_TARGET_CHANGED
	self:ConfigureOnActionSlotAbilityUsed()	-- EVENT_ACTION_SLOT_ABILITY_USED
	self:ConfigureOnCombatEvent()			-- EVENT_COMBAT_EVENT

	self:ConfigureAuraHandler()
end
