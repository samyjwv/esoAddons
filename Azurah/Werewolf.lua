local Azurah		= _G['Azurah']					-- grab addon table from global
local Werewolf		= _G['Azurah_WerewolfTimer']	-- grab werewolf control
local LMP			= LibStub('LibMediaProvider-1.0')

-- UPVALUES --
local GetGameTimeMillis	= GetGameTimeMilliseconds

local flashOnExtend		= false
local SetFinishTime		-- onupdate external function ref
local db


-- ------------------------
-- TIMER UPDATE HANDLER
do ------------------------
	local strformat		= string.format

	local UPDATE_RATE	= 0.1
	local nextUpdate	= 0
	local finishTime	= 0
	local timeRemaining

	local function OnUpdate(self, updateTime)
		if (updateTime >= nextUpdate) then
			timeRemaining = finishTime - updateTime

			if (timeRemaining <= 0) then -- time expired before event was called, hide just incase
				self:SetHidden(true)
			else
				self.overlay:SetText(strformat('%ds', timeRemaining))
			end

			nextUpdate = updateTime + UPDATE_RATE
		end
	end

	SetFinishTime = function(finish)
		if (flashOnExtend and (finish > (finishTime + 2.5))) then -- duration has been increased notably, so flash
			if (not Werewolf.flashAnim:IsPlaying()) then
				Werewolf.flashAnim:PlayFromStart()
			end
		end

		finishTime = finish -- set value locally for speed
	end

	Werewolf:SetHandler('OnUpdate', OnUpdate)
end

-- ------------------------
-- EVENT HANDLERS
-- ------------------------
local function OnWerewolfStateChanged(evt, isWerewolf)
	if (isWerewolf) then
		SetFinishTime((GetGameTimeMillis() / 1000) + 30)
		Werewolf:SetHidden(false)
	else
		Werewolf:SetHidden(true)
	end
end

local function OnPowerUpdate(evt, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffMax)
	SetFinishTime((GetGameTimeMillis() / 1000) + (powerValue * 0.03))
end


-- ------------------------
-- CONSTRUCTION
-- ------------------------
local function AddControl(parent, cType, level)
	local c = WINDOW_MANAGER:CreateControl(nil, parent, cType)
	c:SetDrawLayer(DL_CONTROLS)
	c:SetDrawLevel(level)
	return c, c
end

local function BuildWerewolfTimer()
	local ctrl

	Werewolf.icon, ctrl = AddControl(Werewolf, CT_TEXTURE, 2)
	ctrl:SetDimensions(48, 48)
	ctrl:SetTexture([[esoui/art/progression/progression_indexicon_world_up.dds]])

	Werewolf.flashIcon, ctrl = AddControl(Werewolf, CT_TEXTURE, 1)
	ctrl:SetDimensions(48, 48)
	ctrl:SetTexture([[esoui/art/progression/progression_indexicon_world_down.dds]])
	ctrl:SetAnchor(CENTER, Werewolf.icon, CENTER, 0, 0)
	ctrl:SetAlpha(0)

	Werewolf.overlay = Azurah:CreateOverlay(Werewolf.icon, LEFT, RIGHT, -3, 0, nil, nil, nil, TEXT_ALIGN_LEFT)

	-- animation for when remaining time increases
	ctrl = ANIMATION_MANAGER:CreateTimeline()
	ctrl:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
	Werewolf.flashAnim = ctrl
	ctrl = Werewolf.flashAnim:InsertAnimation(ANIMATION_ALPHA, Werewolf.flashIcon, 0)
	ctrl:SetDuration(50)
	ctrl:SetEasingFunction(ZO_LinearEase)
	ctrl:SetAlphaValues(0, 1)
	ctrl = Werewolf.flashAnim:InsertAnimation(ANIMATION_ALPHA, Werewolf.flashIcon, 250)
	ctrl:SetDuration(200)
	ctrl:SetEasingFunction(ZO_LinearEase)
	ctrl:SetAlphaValues(1, 0)

	Werewolf:SetHidden(true)
end


-- ------------------------
-- CONFIGURATION
-- ------------------------
function Azurah:ConfigureWerewolf()
	if (db.enabled) then
		if (not Werewolf.icon) then -- build timer
			BuildWerewolfTimer()
		end

		Werewolf.icon:ClearAnchors()
		Werewolf.overlay:ClearAnchors()
		Werewolf.overlay:SetFont(string.format('%s|%d|%s', LMP:Fetch('font', db.fontFace), db.fontSize, db.fontOutline))
		Werewolf.overlay:SetColor(db.fontColour.r, db.fontColour.g, db.fontColour.b, db.fontColour.a)

		if (db.iconOnRight) then
			Werewolf.icon:SetAnchor(RIGHT, Werewolf, RIGHT, 0, 0)
			Werewolf.overlay:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			Werewolf.overlay:SetAnchor(RIGHT, Werewolf.icon, LEFT, 3, 0)
		else
			Werewolf.icon:SetAnchor(LEFT, Werewolf, LEFT, 0, 0)
			Werewolf.overlay:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			Werewolf.overlay:SetAnchor(LEFT, Werewolf.icon, RIGHT, -3, 0)
		end

		flashOnExtend = db.flashOnExtend

		EVENT_MANAGER:RegisterForEvent(self.name .. 'Werewolf',		EVENT_WEREWOLF_STATE_CHANGED,	OnWerewolfStateChanged)
		EVENT_MANAGER:RegisterForEvent(self.name .. 'Werewolf',		EVENT_POWER_UPDATE,				OnPowerUpdate)
		EVENT_MANAGER:AddFilterForEvent(self.name .. 'Werewolf',	EVENT_POWER_UPDATE, 			REGISTER_FILTER_POWER_TYPE, POWERTYPE_WEREWOLF)
		EVENT_MANAGER:AddFilterForEvent(self.name .. 'Werewolf',	EVENT_POWER_UPDATE, 			REGISTER_FILTER_UNIT_TAG,	'player')
	else
		EVENT_MANAGER:UnregisterForEvent(self.name .. 'Werewolf',	EVENT_WEREWOLF_STATE_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(self.name .. 'Werewolf',	EVENT_POWER_UPDATE)

		Werewolf:SetHidden(true)
	end
end


-- ------------------------
-- INITIALIZATION
-- ------------------------
function Azurah:InitializeWerewolf()
	db = self.db.werewolf		-- local db reference
end
