local Azurah		= _G['Azurah']				-- grab addon table from global
local LMP			= LibStub('LibMediaProvider-1.0')

-- UPVALUES --
local GetGameCameraInteractableActionInfo	= GetGameCameraInteractableActionInfo
local STR_LOOT_STEAL						= GetString(SI_LOOT_STEAL)

local customStealthStates = { -- so we can manipulate 'safer theft'
	[STEALTH_STATE_NONE]					= false,
	[STEALTH_STATE_DETECTED]				= true,
	[STEALTH_STATE_HIDING]					= true,
	[STEALTH_STATE_HIDDEN]					= true,
	[STEALTH_STATE_STEALTH]					= true,
	[STEALTH_STATE_HIDDEN_ALMOST_DETECTED]	= true,
	[STEALTH_STATE_STEALTH_ALMOST_DETECTED]	= true,
}
local theftPreventAccidental, theftMakeSafer
local interactAction, interactIsOwned
local StartInteractionOrig
local isHidden


local function Azurah_StartInteraction(...)
	interactAction, _, _, interactIsOwned = GetGameCameraInteractableActionInfo()

	if ((not isHidden) and interactIsOwned and interactAction == STR_LOOT_STEAL) then
		return true
	else
		return StartInteractionOrig(...)
	end
end

local function OnStealthStateChanged(evt, unit, stealthState)
	if (unit ~= 'player') then return end

	isHidden = customStealthStates[stealthState]
end


-- ------------------------
-- CONFIGURATION
-- ------------------------
function Azurah:ConfigureThievery()
	-- setup local refs to database entries
	theftPreventAccidental	= self.db.theftPreventAccidental
	theftMakeSafer			= self.db.theftMakeSafer

	if (theftPreventAccidental) then
		customStealthStates[STEALTH_STATE_DETECTED]					= (not theftMakeSafer)
		customStealthStates[STEALTH_STATE_HIDING]					= (not theftMakeSafer)
		customStealthStates[STEALTH_STATE_STEALTH]					= (not theftMakeSafer)
		customStealthStates[STEALTH_STATE_STEALTH_ALMOST_DETECTED]	= (not theftMakeSafer)

		EVENT_MANAGER:RegisterForEvent(self.name .. 'Thievery', EVENT_STEALTH_STATE_CHANGED, OnStealthStateChanged)

		isHidden = customStealthStates[GetUnitStealthState('player')]

		if (not StartInteractionOrig) then
			StartInteractionOrig = FISHING_MANAGER.StartInteraction
		end

		FISHING_MANAGER.StartInteraction = Azurah_StartInteraction
	else
		EVENT_MANAGER:UnregisterForEvent(self.name .. 'Thievery', EVENT_STEALTH_STATE_CHANGED)

		if (StartInteractionOrig) then -- only unset if we set it in this session
			FISHING_MANAGER.StartInteraction = StartInteractionOrig
		end
	end
end
