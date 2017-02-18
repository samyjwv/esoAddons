--[[----------------------------------------------------------
	Srendarr - Aura (Buff & Debuff) Tracker
	----------------------------------------------------------
	*
	* Version 2.3.4g
	* Kith, Phinix, Garkin, silentgecko
	*
	*
]]--
local Srendarr				= _G['Srendarr'] -- grab addon table from global
local L						= Srendarr:GetLocale()

Srendarr.name				= 'Srendarr'
Srendarr.slash				= '/srendarr'
Srendarr.version			= '2.3.4g'
Srendarr.versionDB			= 3

Srendarr.displayFrames		= {}
Srendarr.displayFramesScene	= {}

Srendarr.slotData			= {}

Srendarr.auraLookup			= {
	['player']				= {},
	['reticleover']			= {},
	['groundaoe']			= {}
}

Srendarr.auraGroupStrings = {		-- used in several places to display the aura grouping text
	[Srendarr.GROUP_PLAYER_SHORT]	= L.Group_Player_Short,
	[Srendarr.GROUP_PLAYER_LONG]	= L.Group_Player_Long,
	[Srendarr.GROUP_PLAYER_TOGGLED]	= L.Group_Player_Toggled,
	[Srendarr.GROUP_PLAYER_PASSIVE]	= L.Group_Player_Passive,
	[Srendarr.GROUP_PLAYER_DEBUFF]	= L.Group_Player_Debuff,
	[Srendarr.GROUP_PLAYER_GROUND]	= L.Group_Player_Ground,
	[Srendarr.GROUP_PLAYER_MAJOR]	= L.Group_Player_Major,
	[Srendarr.GROUP_PLAYER_MINOR]	= L.Group_Player_Minor,
	[Srendarr.GROUP_PLAYER_ENCHANT]	= L.Group_Player_Enchant,
	[Srendarr.GROUP_TARGET_BUFF]	= L.Group_Target_Buff,
	[Srendarr.GROUP_TARGET_DEBUFF]	= L.Group_Target_Debuff,
	[Srendarr.GROUP_PROMINENT]		= L.Group_Prominent,
	[Srendarr.GROUP_PROMINENT2]		= L.Group_Prominent2
}

Srendarr.uiLocked			= true -- flag for whether the UI is current drag enabled


-- ------------------------
-- ADDON INITIALIZATION
-- ------------------------
function Srendarr.OnInitialize(code, addon)
	if (addon ~= Srendarr.name) then return end

	local self = Srendarr

	EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
	SLASH_COMMANDS[self.slash] = self.SlashCommand

	self.db = ZO_SavedVars:NewAccountWide('SrendarrDB', self.versionDB, nil, self:GetDefaults())

	if (not self.db.useAccountWide) then -- not using global settings, generate (or load) character specific settings
		self.db = ZO_SavedVars:New('SrendarrDB', self.versionDB, nil, self:GetDefaults())
	end

	local displayBase

	-- create display frames
	for x = 1, self.NUM_DISPLAY_FRAMES do
		displayBase = self.db.displayFrames[x].base

		self.displayFrames[x] = self.DisplayFrame:Create(x, displayBase.point, displayBase.x, displayBase.y, displayBase.alpha, displayBase.scale)
		self.displayFrames[x]:Configure()

		-- add each frame to the ZOS scene manager to control visibility
		self.displayFramesScene[x] = ZO_HUDFadeSceneFragment:New(self.displayFrames[x], 0, 0)

		HUD_SCENE:AddFragment(self.displayFramesScene[x])
		HUD_UI_SCENE:AddFragment(self.displayFramesScene[x])
		SIEGE_BAR_SCENE:AddFragment(self.displayFramesScene[x])

		self.displayFrames[x]:SetHandler('OnEffectivelyShown', function(f)
			f:SetAlpha(f.displayAlpha) -- ensure alpha is reset after a scene fade
		end)
	end

	self:PopulateFilteredAuras()		-- AuraData.lua
	self:ConfigureAuraFadeTime()		-- Aura.lua
	self:ConfigureDisplayAbilityID()	-- Aura.lua
	self:InitializeAuraControl()		-- AuraControl.lua
	self:InitializeCastBar()			-- CastBar.lua
	self:InitializeProcs()				-- Procs.lua
	self:InitializeSettings()			-- Settings.lua

	-- setup events to handle actionbar slotted abilities (used for procs and the castbar)
	for slot = 3, 8 do
		self.slotData[slot] = {}
		self.OnActionSlotUpdated(nil, slot) -- populate initial data (before events registered so no triggers before setup is done)
	end

	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTION_SLOTS_FULL_UPDATE,	self.OnActionSlotsFullUpdate)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTION_SLOT_UPDATED,		self.OnActionSlotUpdated)
end

function Srendarr.SlashCommand(text)
	if (text == 'lock') then
		for x = 1, Srendarr.NUM_DISPLAY_FRAMES do
			Srendarr.displayFrames[x]:DisableDragOverlay()
		end

		Srendarr.Cast:DisableDragOverlay()

		Srendarr.uiLocked = true
	elseif (text == 'unlock') then
		for x = 1, Srendarr.NUM_DISPLAY_FRAMES do
			Srendarr.displayFrames[x]:EnableDragOverlay()
		end

		Srendarr.Cast:EnableDragOverlay()

		Srendarr.uiLocked = false
	else
		CHAT_SYSTEM:AddMessage(L.Usage)
	end
end


-- ------------------------
-- SLOTTED ABILITY DATA HANDLING
-- ------------------------
do
	local GetSlotBoundId		= GetSlotBoundId
	local GetAbilityName		= GetAbilityName
	local GetAbilityCastInfo	= GetAbilityCastInfo
	local GetAbilityIcon		= GetAbilityIcon
	local procAbilityNames		= Srendarr.procAbilityNames

	local abilityID, abilityName, slotData, isChannel, castTime, channelTime

	function Srendarr.OnActionSlotsFullUpdate()
		for slot = 3, 8 do
			Srendarr.OnActionSlotUpdated(nil, slot)
		end
	end

	function Srendarr.OnActionSlotUpdated(evt, slot)
		if (slot < 3 or slot > 8) then return end -- abort if not a main ability (or ultimate)

		abilityID	= GetSlotBoundId(slot)
		slotData	= Srendarr.slotData[slot]

		if (slotData.abilityID == abilityID) then return end -- nothing has changed, abort

		abilityName				= GetAbilityName(abilityID)

		slotData.abilityID		= abilityID
		slotData.abilityName	= abilityName
		slotData.abilityIcon	= GetAbilityIcon(abilityID)

		isChannel, castTime, channelTime = GetAbilityCastInfo(abilityID)

		if (castTime > 0 or channelTime > 0) then
			slotData.isDelayed		= true			-- check for needing a cast bar
			slotData.isChannel		= isChannel
			slotData.castTime		= castTime
			slotData.channelTime	= channelTime
		else
			slotData.isDelayed		= false
		end

		if (procAbilityNames[abilityName]) then -- this is currently a proc'd ability (or special case for crystal fragments)
			Srendarr:ProcAnimationStart(slot)
		elseif (slot ~= 8) then -- cannot have procs on ultimate slot
			Srendarr:ProcAnimationStop(slot)
		end
	end
end


-- ------------------------
-- BLACKLIST AND PROMINENT AURAS CONTROL
do ------------------------
	local STR_PROMBYID			= Srendarr.STR_PROMBYID
	local STR_PROMBYID2			= Srendarr.STR_PROMBYID2
	local STR_BLOCKBYID			= Srendarr.STR_BLOCKBYID

	local DoesAbilityExist		= DoesAbilityExist
	local GetAbilityName		= GetAbilityName
	local GetAbilityDuration	= GetAbilityDuration
	local GetAbilityDescription	= GetAbilityDescription
	local IsAbilityPassive		= IsAbilityPassive

	local fakeAuras				= Srendarr.fakeAuras

	function Srendarr:RemoveAltProminent(auraName, list, listFormat)
		local removed = 0
		local checkID = 0
		if listFormat == 1 then
			checkID = zo_strformat("<<t:1>>",GetAbilityName(tostring(auraName)))
		end

		if list == 1 then
			if (self.db.prominentWhitelist[STR_PROMBYID]) then
				for k, v in pairs(self.db.prominentWhitelist[STR_PROMBYID]) do
					if zo_strformat("<<t:1>>",GetAbilityName(k)) == auraName then
						self.db.prominentWhitelist[STR_PROMBYID][k] = nil
						removed = removed + 1
					end
				end
			end
			if (self.db.prominentWhitelist[STR_PROMBYID]) and (self.db.prominentWhitelist[STR_PROMBYID][auraName]) then
				self.db.prominentWhitelist[STR_PROMBYID][auraName] = nil
				removed = removed + 1
			end
			if (self.db.prominentWhitelist[auraName]) then
				for id in pairs(self.db.prominentWhitelist[auraName]) do
					self.db.prominentWhitelist[auraName][id] = nil
				end
				self.db.prominentWhitelist[auraName] = nil
				removed = removed + 1
			end
			if checkID ~= 0 then
				if (self.db.prominentWhitelist[checkID]) then
					for id in pairs(self.db.prominentWhitelist[checkID]) do
						self.db.prominentWhitelist[checkID][id] = nil
					end
					self.db.prominentWhitelist[checkID] = nil
					removed = removed + 1
				end
			end
			if removed > 0 then
				Srendarr:PopulateProminentAurasDropdown()
			end
		elseif list == 2 then 
			if (self.db.prominentWhitelist2[STR_PROMBYID2]) then
				for k, v in pairs(self.db.prominentWhitelist2[STR_PROMBYID2]) do
					if zo_strformat("<<t:1>>",GetAbilityName(k)) == auraName then
						self.db.prominentWhitelist2[STR_PROMBYID2][k] = nil
						removed = removed + 1
					end
				end
			end
			if (self.db.prominentWhitelist2[STR_PROMBYID2]) and (self.db.prominentWhitelist2[STR_PROMBYID2][auraName]) then
				self.db.prominentWhitelist2[STR_PROMBYID2][auraName] = nil
				removed = removed + 1
			end
			if (self.db.prominentWhitelist2[auraName]) then
				for id in pairs(self.db.prominentWhitelist2[auraName]) do
					self.db.prominentWhitelist2[auraName][id] = nil
				end
				self.db.prominentWhitelist2[auraName] = nil
				removed = removed + 1
			end
			if checkID ~= 0 then
				if (self.db.prominentWhitelist2[checkID]) then
					for id in pairs(self.db.prominentWhitelist2[checkID]) do
						self.db.prominentWhitelist2[checkID][id] = nil
					end
					self.db.prominentWhitelist2[checkID] = nil
					removed = removed + 1
				end
			end
			if removed > 0 then
				Srendarr:PopulateProminentAurasDropdown2()
			end
		end
	end

	function Srendarr:ProminentAuraAdd(auraName)
		auraName = zo_strformat("<<t:1>>",auraName) -- strip out any control characters player may have entered
		if (auraName == STR_PROMBYID) then return end -- make sure we don't mess with internal table
		if (tonumber(auraName)) then -- number entered, assume is an abilityID
			auraName = tonumber(auraName)
			if (auraName > 0 and auraName < 250000 and DoesAbilityExist(auraName) and (GetAbilityDuration(auraName) > 0 or not IsAbilityPassive(auraName))) then
				-- can only add timed abilities to the prominence whitelist
				Srendarr:RemoveAltProminent(auraName, 2, 1) -- Can't add same ability to both prominent lists
				if (not self.db.prominentWhitelist[STR_PROMBYID]) then
					self.db.prominentWhitelist[STR_PROMBYID] = {} -- ensure the by ID table is present
				end
				self.db.prominentWhitelist[STR_PROMBYID][auraName] = true
				CHAT_SYSTEM:AddMessage(string.format('%s: [%d] (%s) %s', L.Srendarr, auraName, GetAbilityName(auraName), L.Prominent_AuraAddSuccess)) -- inform user of successful addition
				Srendarr:ConfigureAuraHandler() -- update handler ref
			else
				CHAT_SYSTEM:AddMessage(string.format('%s: [%s] %s', L.Srendarr, auraName, L.Prominent_AuraAddFailByID)) -- inform user of failed addition
			end
		else
			if (self.db.prominentWhitelist[auraName]) then return end -- already added this aura
			local matchedIDs = {}
			local compareName
			for id = 1, 100000 do -- scan all abilityIDs looking for this auraName
				if (DoesAbilityExist(id) and (GetAbilityDuration(id) > 0 or not IsAbilityPassive(id))) then
					compareName = zo_strformat("<<t:1>>",GetAbilityName(id)) -- strip out any control characters from the ability name
					if (compareName == auraName) then -- matching ability with a duration (no toggles or passives in prominence)
						table.insert(matchedIDs, id)
					end
				end
			end
			if (fakeAuras[auraName]) then -- a fake aura exists for this ability, add its ID
				table.insert(matchedIDs, fakeAuras[auraName].abilityID)
			end
			if (#matchedIDs > 0) then -- matches were found
				Srendarr:RemoveAltProminent(auraName, 2, 0) -- Can't add same ability to both prominent lists
				self.db.prominentWhitelist[auraName] = {} -- add a new whitelist entry
				for _, id in ipairs(matchedIDs) do
					self.db.prominentWhitelist[auraName][id] = true
				end
				Srendarr:ConfigureAuraHandler() -- update handler ref
				CHAT_SYSTEM:AddMessage(string.format('%s: %s %s', L.Srendarr, auraName, L.Prominent_AuraAddSuccess)) -- inform user of successful addition
			else
				CHAT_SYSTEM:AddMessage(string.format('%s: %s %s', L.Srendarr, auraName, L.Prominent_AuraAddFail)) -- inform user of failed addition
			end
		end
	end

	function Srendarr:ProminentAuraAdd2(auraName)
		auraName = zo_strformat("<<t:1>>",auraName) -- strip out any control characters player may have entered
		if (auraName == STR_PROMBYID2) then return end -- make sure we don't mess with internal table
		if (tonumber(auraName)) then -- number entered, assume is an abilityID
			auraName = tonumber(auraName)
			if (auraName > 0 and auraName < 250000 and DoesAbilityExist(auraName) and (GetAbilityDuration(auraName) > 0 or not IsAbilityPassive(auraName))) then
				-- can only add timed abilities to the prominence whitelist
				Srendarr:RemoveAltProminent(auraName, 1, 1) -- Can't add same ability to both prominent lists
				if (not self.db.prominentWhitelist2[STR_PROMBYID2]) then
					self.db.prominentWhitelist2[STR_PROMBYID2] = {} -- ensure the by ID table is present
				end
				self.db.prominentWhitelist2[STR_PROMBYID2][auraName] = true
				CHAT_SYSTEM:AddMessage(string.format('%s: [%d] (%s) %s', L.Srendarr, auraName, GetAbilityName(auraName), L.Prominent_AuraAddSuccess2)) -- inform user of successful addition
				Srendarr:ConfigureAuraHandler() -- update handler ref
			else
				CHAT_SYSTEM:AddMessage(string.format('%s: [%s] %s', L.Srendarr, auraName, L.Prominent_AuraAddFailByID)) -- inform user of failed addition
			end
		else
			if (self.db.prominentWhitelist2[auraName]) then return end -- already added this aura
			local matchedIDs = {}
			local compareName
			for id = 1, 100000 do -- scan all abilityIDs looking for this auraName
				if (DoesAbilityExist(id) and (GetAbilityDuration(id) > 0 or not IsAbilityPassive(id))) then
					compareName = zo_strformat("<<t:1>>",GetAbilityName(id)) -- strip out any control characters from the ability name
					if (compareName == auraName) then -- matching ability with a duration (no toggles or passives in prominence)
						table.insert(matchedIDs, id)
					end
				end
			end
			if (fakeAuras[auraName]) then -- a fake aura exists for this ability, add its ID
				table.insert(matchedIDs, fakeAuras[auraName].abilityID)
			end
			if (#matchedIDs > 0) then -- matches were found
				Srendarr:RemoveAltProminent(auraName, 1, 0) -- Can't add same ability to both prominent lists
				self.db.prominentWhitelist2[auraName] = {} -- add a new whitelist entry
				for _, id in ipairs(matchedIDs) do
					self.db.prominentWhitelist2[auraName][id] = true
				end
				Srendarr:ConfigureAuraHandler() -- update handler ref
				CHAT_SYSTEM:AddMessage(string.format('%s: %s %s', L.Srendarr, auraName, L.Prominent_AuraAddSuccess2)) -- inform user of successful addition
			else
				CHAT_SYSTEM:AddMessage(string.format('%s: %s %s', L.Srendarr, auraName, L.Prominent_AuraAddFail)) -- inform user of failed addition
			end
		end
	end

	function Srendarr:ProminentAuraRemove(auraName)
		auraName = zo_strformat("<<t:1>>",auraName) -- strip out any control characters player may have entered
		if (auraName == STR_PROMBYID) then return end -- make sure we don't mess with internal table
		if (tonumber(auraName)) then -- trying to remove by number, assume is an abilityID
			auraName = tonumber(auraName)
			if (self.db.prominentWhitelist[STR_PROMBYID][auraName]) then -- ID is in list, remove and inform user
				self.db.prominentWhitelist[STR_PROMBYID][auraName] = nil
				Srendarr:ConfigureAuraHandler() -- update handler ref
				CHAT_SYSTEM:AddMessage(string.format('%s: %s %s', L.Srendarr, auraName, L.Prominent_AuraRemoved)) -- inform user of removal
			end
		else
			if (not self.db.prominentWhitelist[auraName]) then return end -- not in whitelist, abort
			for id in pairs(self.db.prominentWhitelist[auraName]) do
				self.db.prominentWhitelist[auraName][id] = nil -- clean out whitelist entry
			end
			self.db.prominentWhitelist[auraName] = nil -- remove whitelist entrys
			Srendarr:ConfigureAuraHandler() -- update handler ref
			CHAT_SYSTEM:AddMessage(string.format('%s: %s %s', L.Srendarr, auraName, L.Prominent_AuraRemoved)) -- inform user of removal
		end
	end

	function Srendarr:ProminentAuraRemove2(auraName)
		auraName = zo_strformat("<<t:1>>",auraName) -- strip out any control characters player may have entered
		if (auraName == STR_PROMBYID2) then return end -- make sure we don't mess with internal table
		if (tonumber(auraName)) then -- trying to remove by number, assume is an abilityID
			auraName = tonumber(auraName)
			if (self.db.prominentWhitelist2[STR_PROMBYID2][auraName]) then -- ID is in list, remove and inform user
				self.db.prominentWhitelist2[STR_PROMBYID2][auraName] = nil
				Srendarr:ConfigureAuraHandler() -- update handler ref
				CHAT_SYSTEM:AddMessage(string.format('%s: %s %s', L.Srendarr, auraName, L.Prominent_AuraRemoved2)) -- inform user of removal
			end
		else
			if (not self.db.prominentWhitelist2[auraName]) then return end -- not in whitelist, abort
			for id in pairs(self.db.prominentWhitelist2[auraName]) do
				self.db.prominentWhitelist2[auraName][id] = nil -- clean out whitelist entry
			end
			self.db.prominentWhitelist2[auraName] = nil -- remove whitelist entrys
			Srendarr:ConfigureAuraHandler() -- update handler ref
			CHAT_SYSTEM:AddMessage(string.format('%s: %s %s', L.Srendarr, auraName, L.Prominent_AuraRemoved2)) -- inform user of removal
		end
	end
	
	function Srendarr:BlacklistAuraAdd(auraName)
		auraName = zo_strformat("<<t:1>>",auraName) -- strip out any control characters player may have entered
		if (auraName == STR_BLOCKBYID) then return end -- make sure we don't mess with internal table
		if (tonumber(auraName)) then -- number entered, assume is an abilityID
			auraName = tonumber(auraName)
			if (auraName > 0 and auraName < 250000) then -- sanity check on the ID given
				if (not self.db.blacklist[STR_BLOCKBYID]) then
					self.db.blacklist[STR_BLOCKBYID] = {} -- ensure the by ID table is present
				end
				self.db.blacklist[STR_BLOCKBYID][auraName] = true
				Srendarr:PopulateFilteredAuras() -- update filtered aura IDs
				CHAT_SYSTEM:AddMessage(string.format('%s: [%d] (%s) %s', L.Srendarr, auraName, GetAbilityName(auraName), L.Blacklist_AuraAddSuccess)) -- inform user of successful addition
			else
				CHAT_SYSTEM:AddMessage(string.format('%s: [%s] %s', L.Srendarr, auraName, L.Blacklist_AuraAddFailByID)) -- inform user of failed addition
			end
		else
			if (self.db.blacklist[auraName]) then return end -- already added this aura
			local matchedIDs = {}
			local compareName
			for id = 1, 100000 do -- scan all abilityIDs looking for this auraName
				if (DoesAbilityExist(id)) then
					compareName = zo_strformat("<<t:1>>",GetAbilityName(id)) -- strip out any control characters from the ability name
					if (compareName == auraName) then -- found a matching ability
						table.insert(matchedIDs, id)
					end
				end
			end
			if (fakeAuras[auraName]) then -- a fake aura exists for this ability, add its ID
				table.insert(matchedIDs, fakeAuras[auraName].abilityID)
			end
			if (#matchedIDs > 0) then -- matches were found
				self.db.blacklist[auraName] = {} -- add a new blacklist entry
				for _, id in ipairs(matchedIDs) do
					self.db.blacklist[auraName][id] = true
				end
				Srendarr:PopulateFilteredAuras() -- update filtered aura IDs
				CHAT_SYSTEM:AddMessage(string.format('%s: %s %s', L.Srendarr, auraName, L.Blacklist_AuraAddSuccess)) -- inform user of successful addition
			else
				CHAT_SYSTEM:AddMessage(string.format('%s: %s %s', L.Srendarr, auraName, L.Blacklist_AuraAddFail)) -- inform user of failed addition
			end
		end
	end

	function Srendarr:BlacklistAuraRemove(auraName)
		auraName = zo_strformat("<<t:1>>",auraName) -- strip out any control characters player may have entered
		if (auraName == STR_BLOCKBYID) then return end -- make sure we don't mess with internal table
		if (tonumber(auraName)) then -- trying to remove by number, assume is an abilityID
			auraName = tonumber(auraName)
			if (self.db.blacklist[STR_BLOCKBYID][auraName]) then -- ID is in list, remove and inform user
				self.db.blacklist[STR_BLOCKBYID][auraName] = nil
				Srendarr:PopulateFilteredAuras() -- update filtered aura IDs
				CHAT_SYSTEM:AddMessage(string.format('%s: %s %s', L.Srendarr, auraName, L.Blacklist_AuraRemoved)) -- inform user of removal
			end
		else
			if (not self.db.blacklist[auraName]) then return end -- not in blacklist, abort
			for id in pairs(self.db.blacklist[auraName]) do
				self.db.blacklist[auraName][id] = nil -- clean out blacklist entry
			end
			self.db.blacklist[auraName] = nil -- remove blacklist entrys
			Srendarr:PopulateFilteredAuras() -- update filtered aura IDs
			CHAT_SYSTEM:AddMessage(string.format('%s: %s %s', L.Srendarr, auraName, L.Blacklist_AuraRemoved)) -- inform user of removal
		end
	end
end


-- ------------------------
-- UI HELPER FUNCTIONS
-- ------------------------
do
	local math_abs				= math.abs
	local WM					= WINDOW_MANAGER

	function Srendarr:GetEdgeRelativePosition(object)
		local left, top     = object:GetLeft(),		object:GetTop()
		local right, bottom = object:GetRight(),	object:GetBottom()
		local rootW, rootH  = GuiRoot:GetWidth(),	GuiRoot:GetHeight()
		local point         = 0
		local x, y

		if (left < (rootW - right) and left < math_abs((left + right) / 2 - rootW / 2)) then
			x, point = left, 2 -- 'LEFT'
		elseif ((rootW - right) < math_abs((left + right) / 2 - rootW / 2)) then
			x, point = right - rootW, 8 -- 'RIGHT'
		else
			x, point = (left + right) / 2 - rootW / 2, 0
		end

		if (bottom < (rootH - top) and bottom < math_abs((bottom + top) / 2 - rootH / 2)) then
			y, point = top, point + 1 -- 'TOP|TOPLEFT|TOPRIGHT'
		elseif ((rootH - top) < math_abs((bottom + top) / 2 - rootH / 2)) then
			y, point = bottom - rootH, point + 4 -- 'BOTTOM|BOTTOMLEFT|BOTTOMRIGHT'
		else
			y = (bottom + top) / 2 - rootH / 2
		end

		point = (point == 0) and 128 or point -- 'CENTER'
		return point, x, y
	end

	function Srendarr.AddControl(parent, cType, level)
		local c = WM:CreateControl(nil, parent, cType)
		c:SetDrawLayer(DL_OVERLAY)
		c:SetDrawLevel(level)
		return c, c
	end
end


EVENT_MANAGER:RegisterForEvent(Srendarr.name, EVENT_ADD_ON_LOADED, Srendarr.OnInitialize)
