--[[----------------------------------------------------------
	Azurah - Interface Enhanced
	----------------------------------------------------------
	* An addon designed to allow for user customization of the
	* stock interface with optional components to provide
	* additional information while maintaining the stock feel.
	*
	* Version 2.2.9g
	* Kith, Garkin, Phinix, Sounomi
	*
	*
]]--
local Azurah		= _G['Azurah'] -- grab addon table from global
local L				= Azurah:GetLocale()

Azurah.name			= 'Azurah'
Azurah.slash		= '/azurah'
Azurah.version		= '2.2.9g'
Azurah.versionDB	= 2

Azurah.movers		= {}
Azurah.snapToGrid	= true
Azurah.uiUnlocked	= false


-- ------------------------
-- ADDON INITIALIZATION
-- ------------------------
function Azurah.OnInitialize(code, addon)
	if (addon ~= Azurah.name) then return end

	local self = Azurah

	EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
	SLASH_COMMANDS[self.slash] = self.SlashCommand

	self.db = ZO_SavedVars:NewAccountWide('AzurahDB', self.versionDB, nil, self:GetDefaults())

	if (not self.db.useAccountWide) then -- not using global settings, generate (or load) character specific settings
		self.db = ZO_SavedVars:New('AzurahDB', self.versionDB, nil, self:GetDefaults())
	end

	self:InitializePlayer()					-- Player.lua
	self:InitializeTarget()					-- Target.lua
	self:InitializeBossbar()				-- Bossbar.lua
	self:InitializeActionBar()				-- ActionBar.lua
	self:InitializeExperienceBar()			-- ExperienceBar.lua
	self:InitializeBagWatcher()				-- BagWatcher.lua
	self:InitializeWerewolf()				-- Werewolf.lua

	self:InitializeSettings()

	-- register events for state changes
	EVENT_MANAGER:RegisterForEvent(Azurah.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,	self.OnPreferredModeChanged)
	EVENT_MANAGER:RegisterForEvent(Azurah.name, EVENT_PLAYER_COMBAT_STATE,				self.OnStateChanged)
	EVENT_MANAGER:RegisterForEvent(Azurah.name, EVENT_MOUNTED_STATE_CHANGED,			self.OnStateChanged)
	EVENT_MANAGER:RegisterForEvent(Azurah.name, EVENT_WEREWOLF_STATE_CHANGED,			self.OnStateChanged)
end

function Azurah.OnPlayerActivated()
	EVENT_MANAGER:UnregisterForEvent(Azurah.name, EVENT_PLAYER_ACTIVATED)

	Azurah:InitializeUnlock()

	-- done later in load to make sure fonts from other addons are available (if being used)
	Azurah:ConfigureAttributeOverlays()		-- Player.lua
	Azurah:ConfigureTargetOverlay()			-- Target.lua
	Azurah:ConfigureBossbarOverlay()		-- Bossbar.lua
	Azurah:ConfigureActionBarElements()		-- ActionBar.lua
	Azurah:ConfigureUltimateOverlays()		-- ActionBar.lua
	Azurah:ConfigureExperienceBarOverlay()	-- ExperienceBar.lua
	Azurah:ConfigureBagWatcher()			-- BagWatcher.lua
	Azurah:ConfigureThievery()				-- Thievery.lua
	Azurah:ConfigureWerewolf()				-- Werewolf.lua
end

function Azurah.OnStateChanged()
	Azurah:ConfigureAttributeFade()
end

function Azurah.OnPreferredModeChanged(evt, gamepadPreferred)
	if (Azurah.uiUnlocked) then
		Azurah:LockUI()
	end

	Azurah:InitializeUnlock()
	Azurah:ConfigureTargetIcons()
	Azurah:ConfigureActionBarElements()
	Azurah:ConfigureExperienceBarOverlay()

	if (gamepadPreferred) then
		Azurah:ConfigureBagWatcherGamepad()
	else
		Azurah:ConfigureBagWatcherKeyboard()
	end
	
	-- option to reloadui on keyboard/gamepad mode change (Phinix)
	if Azurah.db.modeChangeReload then
		ReloadUI()
	end

end

function Azurah.SlashCommand(text)
	if (text == 'lock') then
		Azurah:LockUI()
	elseif (text == 'unlock') then
		Azurah:UnlockUI()
	else
		CHAT_SYSTEM:AddMessage(L.Usage)
	end
end


-- ------------------------
-- OVERLAY BASE
-- ------------------------
local strformat			= string.format
local strgsub			= string.gsub
local captureStr		= '%1' .. L.ThousandsSeperator .. '%2'
local k

local function comma_value(amount)
	while (true) do
		amount, k = strgsub(amount, '^(-?%d+)(%d%d%d)', captureStr)

		if (k == 0) then
			break
		end
	end

	return amount
end

Azurah.overlayFuncs = {
	[1] = function(current, max, effMax)
		return '' -- dummy, returns an empty string
	end,
	-- standard overlays
	[2] = function(current, max, effMax)
		effMax = effMax > 0 and effMax or 1 -- ensure we don't do a divide by 0
		return strformat('%d / %d (%d%%)', current, effMax, (current / effMax) * 100)
	end,
	[3] = function(current, max, effMax)
		return strformat('%d / %d', current, effMax)
	end,
	[4] = function(current, max, effMax)
		effMax = effMax > 0 and effMax or 1 -- ensure we don't do a divide by 0
		return strformat('%d (%d%%)', current, (current / effMax) * 100)
	end,
	[5] = function(current, max, effMax)
		return strformat('%d', current)
	end,
	[6] = function(current, max, effMax)
		effMax = effMax > 0 and effMax or 1 -- ensure we don't do a divide by 0
		return strformat('%d%%', (current / effMax) * 100)
	end,
	-- comma-seperated overlays
	[12] = function(current, max, effMax)
		effMax = effMax > 0 and effMax or 1 -- ensure we don't do a divide by 0
		return strformat('%s / %s (%d%%)', comma_value(current), comma_value(effMax), (current / effMax) * 100)
	end,
	[13] = function(current, max, effMax)
		return strformat('%s / %s', comma_value(current), comma_value(effMax))
	end,
	[14] = function(current, max, effMax)
		effMax = effMax > 0 and effMax or 1 -- ensure we don't do a divide by 0
		return strformat('%s (%d%%)', comma_value(current), (current / effMax) * 100)
	end,
	[15] = function(current, max, effMax)
		return strformat('%s', comma_value(current))
	end,
	[16] = function(current, max, effMax)
		effMax = effMax > 0 and effMax or 1 -- ensure we don't do a divide by 0
		return strformat('%d%%', (current / effMax) * 100)
	end
}

function Azurah:CreateOverlay(parent, rel, relPoint, x, y, width, height, vAlign, hAlign)
	local o = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
	o:SetResizeToFitDescendents(true)
	o:SetInheritScale(false)
	o:SetDrawTier(DT_HIGH)
	o:SetDrawLayer(DL_OVERLAY)
	o:SetAnchor(rel, parent, relPoint, x, y)
	o:SetHorizontalAlignment(hAlign or TEXT_ALIGN_CENTER)
	o:SetVerticalAlignment(vAlign or TEXT_ALIGN_CENTER)

	return o
end


EVENT_MANAGER:RegisterForEvent(Azurah.name, EVENT_ADD_ON_LOADED,	Azurah.OnInitialize)
EVENT_MANAGER:RegisterForEvent(Azurah.name, EVENT_PLAYER_ACTIVATED,	Azurah.OnPlayerActivated)
