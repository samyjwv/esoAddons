local Azurah		= _G['Azurah'] -- grab addon table from global
local LMP			= LibStub('LibMediaProvider-1.0')

-- UPVALUES --
local POWERTYPE_ULTIMATE	= POWERTYPE_ULTIMATE
local GetSlotAbilityCost	= GetSlotAbilityCost
local GetUnitPower			= GetUnitPower
local math_min				= math.min
local math_max				= math.max
local strformat				= string.format

local ultFuncs = {
	[1] = function(current) -- plain number
		return strformat('%d', current)
	end,
	[2] = function(current) -- value / ultimate cost
		local cost = GetSlotAbilityCost(8)
		return strformat('%d / %d', current, cost)
	end,
	[3] = function(current) -- value / ultimate cost ("no overshoot")
		local cost = GetSlotAbilityCost(8)
		return strformat('%d / %d', math_min(current, cost), cost)
	end
}

local ultPercentFuncs = {
	[1] = function(current, max, effMax) -- relative percent
		effMax = math_max(1, GetSlotAbilityCost(8))
		return strformat('%d%%', (current / effMax) * 100)
	end,
	[2] = function(current, max, effMax) -- total percent
		effMax = effMax > 0 and effMax or 1 -- ensure we don't do a divide by 0
		return strformat('%d%%', (current / effMax) * 100)
	end
}

local overlayUltValue, overlayUltPercent
local FormatUlt, FormatUltPercent
local db

local function OnPowerUpdate(_, unit, _, powerType, powerValue, powerMax, powerEffMax)
	if (unit ~= 'player') then return end -- only care about the player
	if (powerType ~= POWERTYPE_ULTIMATE) then return end -- only care about ultimate

	overlayUltValue:SetText(FormatUlt(powerValue))
	overlayUltPercent:SetText(FormatUltPercent(powerValue, powerMax, powerEffMax))
end

local function OnWeaponPairChanged()
	overlayUltValue:SetText(FormatUlt(GetUnitPower('player', POWERTYPE_ULTIMATE)))
end

function Azurah:ConfigureUltimateOverlays()
	if (db.ultValueShow or db.ultPercentShow) then -- showing overlay, enable tracking\
		EVENT_MANAGER:RegisterForEvent(self.name .. 'Ultimate', EVENT_POWER_UPDATE, 				OnPowerUpdate)
		EVENT_MANAGER:RegisterForEvent(self.name .. 'Ultimate', EVENT_ACTIVE_WEAPON_PAIR_CHANGED,	OnWeaponPairChanged)

	else -- no overlay being shown, disable tracking
		EVENT_MANAGER:UnregisterForEvent(self.name .. 'Ultimate', EVENT_POWER_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(self.name .. 'Ultimate', EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
	end

	local fontStr, value, max, maxEff

	if (db.ultValueShow) then
		fontStr = strformat('%s|%d|%s', LMP:Fetch('font', db.ultValueFontFace), db.ultValueFontSize, db.ultValueFontOutline)

		overlayUltValue:SetFont(fontStr)
		overlayUltValue:SetColor(db.ultValueFontColour.r, db.ultValueFontColour.g, db.ultValueFontColour.b, db.ultValueFontColour.a)
		overlayUltValue:SetHidden(false)

		FormatUlt = ultFuncs[db.ultValueShowCost and 2 or 1]

		overlayUltValue:SetText(FormatUlt(GetUnitPower('player', POWERTYPE_ULTIMATE)))
	else
		overlayUltValue:SetHidden(true)
	end

	if (db.ultPercentShow) then
		fontStr = strformat('%s|%d|%s', LMP:Fetch('font', db.ultPercentFontFace), db.ultPercentFontSize, db.ultPercentFontOutline)

		overlayUltPercent:SetFont(fontStr)
		overlayUltPercent:SetColor(db.ultPercentFontColour.r, db.ultPercentFontColour.g, db.ultPercentFontColour.b, db.ultPercentFontColour.a)
		overlayUltPercent:SetHidden(false)

		FormatUltPercent = ultPercentFuncs[(db.ultPercentRelative) and 1 or 2]

		overlayUltPercent:SetText(FormatUltPercent(GetUnitPower('player', POWERTYPE_ULTIMATE)))
	else
		overlayUltPercent:SetHidden(true)
	end
end

function Azurah:ConfigureActionBarElements()
	ZO_ActionBar1WeaponSwap:SetAlpha(db.hideWeaponSwap and 0 or 1)
	ZO_ActionBar1WeaponSwapLock:SetAlpha(db.hideWeaponSwap and 0 or 1)

	ZO_ActionBar1KeybindBG:SetAlpha(db.hideBindBG and 0 or 1)

	for x = 3, 9 do
		if (x ~= 8) then
			_G['ActionButton' .. x .. 'ButtonText']:SetAlpha(db.hideBindText and 0 or 1)
			_G['ActionButton' .. x .. 'ButtonText']:SetHidden(db.hideBindText)
		end
	end

	if (IsInGamepadPreferredMode()) then -- special case to handle changes to ultimate button in Gamepad mode
		_G['ActionButton8LBkey']:SetAlpha(db.hideBindText and 0 or 1)
		_G['ActionButton8LBkey']:SetHidden(db.hideBindText)

		_G['ActionButton8RBkey']:SetAlpha(db.hideBindText and 0 or 1)
		_G['ActionButton8RBkey']:SetHidden(db.hideBindText)

	-- prevent ultimate border from scaling incorrectly in gamepad mode (Phinix)
		local scale = ZO_ActionBar1:GetScale()
		local leftFill = ActionButton8FillAnimationLeft
		local rightFill = ActionButton8FillAnimationRight

		if leftFill ~= nil then
			leftFill:ClearAnchors()
			leftFill:SetAnchor(TOPRIGHT, ActionButton8Backdrop, TOP, 0, (-24 * scale))
			leftFill:SetAnchor(BOTTOMLEFT, ActionButton8Backdrop, BOTTOMLEFT, (-24 * scale), (24 * scale))
		end

		if rightFill ~= nil then
			rightFill:ClearAnchors()
			rightFill:SetAnchor(TOPLEFT, ActionButton8Backdrop, TOP, 0, (-24 * scale))
			rightFill:SetAnchor(BOTTOMRIGHT, ActionButton8Backdrop, BOTTOMRIGHT, (24 * scale), (24 * scale))
		end
	else
		_G['ActionButton8ButtonText']:SetAlpha(db.hideBindText and 0 or 1)
		_G['ActionButton8ButtonText']:SetHidden(db.hideBindText)
	end
end

-- ------------------------
-- INITIALIZATION
-- ------------------------
function Azurah:InitializeActionBar()
	db = self.db.actionBar

	-- create overlays
	overlayUltValue		= self:CreateOverlay(ActionButton8, BOTTOM, TOP, -1, 0)
	overlayUltPercent	= self:CreateOverlay(ActionButton8, BOTTOM, BOTTOM, 0, -2, 60)

	-- set 'dummy' display function
	FormatUlt			= ultFuncs[1]
	FormatUltPercent	= ultPercentFuncs[2]

	-- Fix for scaling issue
	ActionButton8Decoration:SetAnchor(CENTER, ActionButton8, CENTER, 0, 0)
end
