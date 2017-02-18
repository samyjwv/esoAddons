local Azurah		= _G['Azurah'] -- grab addon table from global
local LMP			= LibStub('LibMediaProvider-1.0')

-- UPVALUES --
local POWERTYPE_HEALTH	= POWERTYPE_HEALTH
local POWERTYPE_MAGICKA	= POWERTYPE_MAGICKA
local POWERTYPE_STAMINA	= POWERTYPE_STAMINA
local strformat			= string.format

local overlayHealth, overlayMagicka, overlayStamina
local FormatHealth,	FormatMagicka, FormatStamina
local origExpanded, origShrunk
local db

local function OnPowerUpdate(_, unit, _, powerType, powerValue, powerMax, powerEffMax)
	if (unit ~= 'player') then return end -- only care about the player

	if (powerType == POWERTYPE_HEALTH) then
		overlayHealth:SetText(FormatHealth(powerValue, powerMax, powerEffMax))
	elseif (powerType == POWERTYPE_MAGICKA) then
		overlayMagicka:SetText(FormatMagicka(powerValue, powerMax, powerEffMax))
	elseif (powerType == POWERTYPE_STAMINA) then
		overlayStamina:SetText(FormatStamina(powerValue, powerMax, powerEffMax))
	end
end

function Azurah:ConfigureAttributeOverlays()
	if (db.healthOverlay > 1 or db.magickaOverlay > 1 or db.staminaOverlay > 1) then -- showing at least one overlay, enable tracking
		EVENT_MANAGER:RegisterForEvent(self.name .. 'Attributes', EVENT_POWER_UPDATE, OnPowerUpdate)
	else -- no overlays being shown, disable tracking
		EVENT_MANAGER:UnregisterForEvent(self.name .. 'Attributes', EVENT_POWER_UPDATE)
	end

	local fontStr, value, max, maxEff

	-- configure health overlay
	if (db.healthOverlay > 1) then
		fontStr = strformat('%s|%d|%s', LMP:Fetch('font', db.healthFontFace), db.healthFontSize, db.healthFontOutline)

		overlayHealth:SetFont(fontStr)
		overlayHealth:SetColor(db.healthFontColour.r, db.healthFontColour.g, db.healthFontColour.b, db.healthFontColour.a)
		overlayHealth:SetHidden(false)

		FormatHealth = self.overlayFuncs[db.healthOverlay + ((db.healthOverlayFancy) and 10 or 0)]

		value, max, maxEff = GetUnitPower('player', POWERTYPE_HEALTH)

		overlayHealth:SetText(FormatHealth(value, max, maxEff))
	else -- not showing
		overlayHealth:SetHidden(true)
	end

	-- configure magicka overlay
	if (db.magickaOverlay > 1) then
		fontStr = strformat('%s|%d|%s', LMP:Fetch('font', db.magickaFontFace), db.magickaFontSize, db.magickaFontOutline)

		overlayMagicka:SetFont(fontStr)
		overlayMagicka:SetColor(db.magickaFontColour.r, db.magickaFontColour.g, db.magickaFontColour.b, db.magickaFontColour.a)
		overlayMagicka:SetHidden(false)

		FormatMagicka = self.overlayFuncs[db.magickaOverlay + ((db.magickaOverlayFancy) and 10 or 0)]

		value, max, maxEff = GetUnitPower('player', POWERTYPE_MAGICKA)

		overlayMagicka:SetText(FormatMagicka(value, max, maxEff))
	else -- not showing
		overlayMagicka:SetHidden(true)
	end

	-- configure stamina overlay
	if (db.staminaOverlay > 1) then
		fontStr = strformat('%s|%d|%s', LMP:Fetch('font', db.staminaFontFace), db.staminaFontSize, db.staminaFontOutline)

		overlayStamina:SetFont(fontStr)
		overlayStamina:SetColor(db.staminaFontColour.r, db.staminaFontColour.g, db.staminaFontColour.b, db.staminaFontColour.a)
		overlayStamina:SetHidden(false)

		FormatStamina = self.overlayFuncs[db.staminaOverlay + ((db.staminaOverlayFancy) and 10 or 0)]

		value, max, maxEff = GetUnitPower('player', POWERTYPE_STAMINA)

		overlayStamina:SetText(FormatStamina(value, max, maxEff))
	else -- not showing
		overlayStamina:SetHidden(true)
	end
end

function Azurah:ConfigureAttributeFade()
	local minH, minM, minS, maxH, maxM, maxS
	local curH, curM, curS, curMS, emaxH, emaxM, emaxS, emaxS, emaxMS

	local inCombat		= IsUnitInCombat('player') and true or false

	curH, _, emaxH		= GetUnitPower("player", POWERTYPE_HEALTH)
	curM, _, emaxM		= GetUnitPower("player", POWERTYPE_MAGICKA)
	curS, _, emaxS		= GetUnitPower("player", POWERTYPE_STAMINA)
	curMS, _, emaxMS	= GetUnitPower("player", POWERTYPE_MOUNT_STAMINA)

	if (db.combatBars and inCombat) then
		minH = db.fadeMaxAlpha
		maxH = db.fadeMaxAlpha
		minM = db.fadeMaxAlpha
		maxM = db.fadeMaxAlpha
		minS = db.fadeMaxAlpha
		maxS = db.fadeMaxAlpha
	else
		minH = db.fadeMinAlpha
		maxH = db.fadeMaxAlpha
		minM = db.fadeMinAlpha
		maxM = db.fadeMaxAlpha
		minS = db.fadeMinAlpha
		maxS = db.fadeMaxAlpha
	end

	ZO_PlayerAttributeHealth.playerAttributeBarObject.timeline:GetAnimation():SetAlphaValues(minH, maxH)
	ZO_PlayerAttributeStamina.playerAttributeBarObject.timeline:GetAnimation():SetAlphaValues(minM, maxM)
	ZO_PlayerAttributeMagicka.playerAttributeBarObject.timeline:GetAnimation():SetAlphaValues(minS, maxS)

	ZO_PlayerAttributeMountStamina.playerAttributeBarObject.timeline:GetAnimation():SetAlphaValues(0, maxS)
	ZO_PlayerAttributeWerewolf.playerAttributeBarObject.timeline:GetAnimation():SetAlphaValues(0, maxM)
	ZO_PlayerAttributeSiegeHealth.playerAttributeBarObject.timeline:GetAnimation():SetAlphaValues(0, maxH)

	if (curH >= emaxH) then
		ZO_PlayerAttributeHealth:SetAlpha(minH)
	end
	if (curM >= emaxM) then
		ZO_PlayerAttributeMagicka:SetAlpha(minM)
	end
	if (curS >= emaxS and curMS >= emaxMS) then
		ZO_PlayerAttributeStamina:SetAlpha(minS)
	end
end

function Azurah:ConfigureAttributeSizeLock()
	for k, v in pairs(PLAYER_ATTRIBUTE_BARS.attributeVisualizer.visualModules) do
		if (v.expandedWidth) then -- this is the size changer
			if (not origExpanded) then -- haven't noted down defaults yet
				origExpanded, origShrunk = v.expandedWidth, v.shrunkWidth
			end

			if (db.lockSize) then -- locking attribute size
				v.expandedWidth, v.shrunkWidth = v.normalWidth, v.normalWidth
				-- fire off some 'fake' events to remove any active size alterations
				PLAYER_ATTRIBUTE_BARS.attributeVisualizer:OnUnitAttributeVisualRemoved('player', 1, 7,  100, -2,100,100) -- health
				PLAYER_ATTRIBUTE_BARS.attributeVisualizer:OnUnitAttributeVisualRemoved('player', 1, 4,  100, -2,100,100) -- magicka
				PLAYER_ATTRIBUTE_BARS.attributeVisualizer:OnUnitAttributeVisualRemoved('player', 1, 29, 100, -2,100,100) -- stamina
			else
				v.expandedWidth, v.shrunkWidth = origExpanded, origShrunk
			end
		end
	end
end


-- ------------------------
-- INITIALIZATION
-- ------------------------
function Azurah:InitializePlayer()
	db = self.db.attributes

	-- create overlays
	overlayHealth	= self:CreateOverlay(ZO_PlayerAttributeHealth, CENTER, CENTER, 0, 0)
	overlayMagicka	= self:CreateOverlay(ZO_PlayerAttributeMagicka, CENTER, CENTER, 0, 0)
	overlayStamina	= self:CreateOverlay(ZO_PlayerAttributeStamina, CENTER, CENTER, 0, 0)

	-- set 'dummy' display functions
	FormatHealth	= self.overlayFuncs[1]
	FormatMagicka	= self.overlayFuncs[1]
	FormatStamina	= self.overlayFuncs[1]

	self:ConfigureAttributeFade()
	self:ConfigureAttributeSizeLock()
end
