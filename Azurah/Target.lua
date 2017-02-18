local Azurah		= _G['Azurah'] -- grab addon table from global
local LMP			= LibStub('LibMediaProvider-1.0')

-- UPVALUES --
local POWERTYPE_HEALTH		= POWERTYPE_HEALTH
local DoesUnitExist			= DoesUnitExist
local GetUnitPower			= GetUnitPower
local GetUnitReactionColor	= GetUnitReactionColor
local GetConColor			= GetConColor
local GetUnitLevel			= GetUnitLevel
local IsUnitPlayer			= IsUnitPlayer
local GetUnitClassId		= GetUnitClassId
local strformat				= string.format

local classIcons = {
	keyboard = {
		[1]		= [[/esoui/art/icons/class/class_dragonknight.dds]],
		[2]		= [[/esoui/art/icons/class/class_sorcerer.dds]],
		[3]		= [[/esoui/art/icons/class/class_nightblade.dds]],
		[6]		= [[/esoui/art/icons/class/class_templar.dds]]
	},
	gamepad = {
		[1]		= [[/esoui/art/icons/class/gamepad/gp_class_dragonknight.dds]],
		[2]		= [[/esoui/art/icons/class/gamepad/gp_class_sorcerer.dds]],
		[3]		= [[/esoui/art/icons/class/gamepad/gp_class_nightblade.dds]],
		[6]		= [[/esoui/art/icons/class/gamepad/gp_class_templar.dds]]
	}
}

local allianceIcons = {
	[1]			= [[/esoui/art/guild/guildbanner_icon_aldmeri.dds]],
	[2]			= [[/esoui/art/guild/guildbanner_icon_ebonheart.dds]],
	[3]			= [[/esoui/art/guild/guildbanner_icon_daggerfall.dds]],
	[100]		= [[/esoui/art/ava/ava_allianceflag_neutral.dds]]
}

local playerLevel = GetUnitLevel('player')

local reactR, reactG, reactB, conR, conG, conB, isTargetPlayer, isTargetChampion
local targetLeft, targetRight, targetName, targetLevel, targetChamp
local targetClass, targetAlliance
local origExpanded, origShrunk
local overlayTarget
local FormatTarget
local db

local function OnLevel(_, unit, level)
	if (unit == 'player') then
		if (IsUnitChampion(unit)) then
			playerLevel = 50
		else
			playerLevel = level
		end
	end
end

local function OnPowerUpdate(_, unit, _, powerType, powerValue, powerMax, powerEffMax)
	if (unit ~= 'reticleover') then return end -- only care about the target
	if (powerType ~= POWERTYPE_HEALTH) then return end -- only care about health

	overlayTarget:SetText(FormatTarget(powerValue, powerMax, powerEffMax))
end

local function OnTargetChanged()
	if (not DoesUnitExist('reticleover')) then return end -- no target, do nothing

	reactR, reactG, reactB	= GetUnitReactionColor('reticleover')
	conR, conG, conB		= GetConColor(GetUnitLevel('reticleover'), playerLevel)
	isTargetPlayer			= IsUnitPlayer('reticleover')
	isTargetChampion			= IsUnitChampion('reticleover')

	overlayTarget:SetText(FormatTarget(GetUnitPower('reticleover', POWERTYPE_HEALTH)))

	if (db.colourByBar == 2) then -- by reaction
		targetLeft:SetGradientColors(reactR * 0.64, reactG * 0.64, reactB * 0.64, 1, reactR * 0.8, reactG * 0.8, reactB * 0.8, 1)
		targetRight:SetGradientColors(reactR * 0.64, reactG * 0.64, reactB * 0.64, 1, reactR * 0.8, reactG * 0.8, reactB * 0.8, 1)
	elseif (db.colourByBar == 3) then -- by level difference
		targetLeft:SetGradientColors(conR * 0.64, conG * 0.64, conB * 0.64, 1, conR, conG, conB, 1)
		targetRight:SetGradientColors(conR * 0.64, conG * 0.64, conB * 0.64, 1, conR, conG, conB, 1)
	end

	if (db.colourByName == 2) then -- by reaction
		targetName:SetColor(reactR, reactG, reactB)
	elseif (db.colourByName == 3) then -- by level difference
		targetName:SetColor(conR, conG, conB)
	end

	if (db.colourByLevel) then -- by level difference
		targetLevel:SetColor(conR, conG, conB)
	end

	if (db.classShow and isTargetPlayer) then
		if not IsInGamepadPreferredMode() then
			targetClass:SetTexture(classIcons.keyboard[GetUnitClassId('reticleover')])
			targetClass:SetHidden(false)
		else
			targetClass:SetTexture(classIcons.gamepad[GetUnitClassId('reticleover')])
			targetClass:SetHidden(false)
		end

		if (db.classByName) then
			if (isTargetChampion) then
				targetClass:ClearAnchors()
				targetClass:SetAnchor(TOPRIGHT, targetChamp, TOPLEFT, -2, -6)
			else
				targetClass:ClearAnchors()

				if not IsInGamepadPreferredMode() then
					targetClass:SetAnchor(TOPRIGHT, targetLevel, TOPLEFT, -2, -4)
				else
					targetClass:SetAnchor(TOPRIGHT, targetLevel, TOPLEFT, -6, 6)
				end
			end
		else
			targetClass:SetAnchor(RIGHT, ZO_TargetUnitFramereticleoverFrameLeft, LEFT, 0, 0)
		end
	else
		targetClass:SetHidden(true)
	end

	if (db.allianceShow and isTargetPlayer) then
		targetAlliance:SetTexture(allianceIcons[GetUnitAlliance('reticleover')])
		targetAlliance:SetHidden(false)
	else
		targetAlliance:SetHidden(true)
	end
end

function Azurah:ConfigureTargetOverlay()
	if (db.overlay > 1) then -- showing overlay, enabled tracking
		EVENT_MANAGER:RegisterForEvent(self.name .. 'Target', EVENT_POWER_UPDATE, OnPowerUpdate)
	else -- no overlay being shown, disable tracking
		EVENT_MANAGER:UnregisterForEvent(self.name .. 'Target', EVENT_POWER_UPDATE)
	end

	local fontStr, value, max, maxEff

	if (db.overlay > 1) then
		fontStr = strformat('%s|%d|%s', LMP:Fetch('font', db.fontFace), db.fontSize, db.fontOutline)

		overlayTarget:SetFont(fontStr)
		overlayTarget:SetColor(db.fontColour.r, db.fontColour.g, db.fontColour.b, db.fontColour.a)
		overlayTarget:SetHidden(false)

		FormatTarget = self.overlayFuncs[db.overlay + ((db.overlayFancy) and 10 or 0)]

		if (DoesUnitExist('reticleover')) then
			value, max, maxEff = GetUnitPower('reticleover', POWERTYPE_HEALTH)

			overlayTarget:SetText(FormatTarget(value, max, maxEff))
		end
	else -- not showing
		overlayTarget:SetHidden(true)
	end
end

function Azurah:ConfigureTargetColouring()
	if (db.colourByBar == 1) then -- not colouring, return to default
		local r1, g1, b1, a1 = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH][1]:UnpackRGBA()
		local r2, g2, b2, a2 = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH][2]:UnpackRGBA()
		targetLeft:SetGradientColors(r1, g1, b1, a1, r2, g2, b2, a2)
		targetRight:SetGradientColors(r1, g1, b1, a1, r2, g2, b2, a2)
	end

	if (db.colourByName == 1) then -- not colouring, return to default
		targetName:SetColor(1, 1, 1)
	end

	if (not db.colourByLevel) then -- not colouring, return to default
		targetLevel:SetColor(1,1,1)
	end
end

function Azurah:ConfigureTargetIcons()
	if (db.allianceShow) then
		targetAlliance:ClearAnchors()

		if (db.allianceByName) then -- displaying icon by target name
			targetAlliance:SetAnchor(LEFT, ZO_TargetUnitFramereticleoverRankIcon, RIGHT, -4, 1)
		else -- displaying next to bar
			targetAlliance:SetAnchor(LEFT, ZO_TargetUnitFramereticleoverFrameRight, RIGHT, 0, 1)
		end
	end

	if (not IsInGamepadPreferredMode() or not db.classByName) then
		targetClass:SetDimensions(32, 32)
	else
		targetClass:SetDimensions(40, 40)
	end

	if (not IsInGamepadPreferredMode() or not db.allianceByName) then
		targetAlliance:SetDimensions(32, 32)
	else
		targetAlliance:SetDimensions(40, 40)
	end
end

function Azurah:ConfigureTargetSizeLock()
	for k, v in pairs(UNIT_FRAMES.staticFrames.reticleover.attributeVisualizer.visualModules) do
		if (v.expandedWidth) then -- this is the size changer
			if (not origExpanded) then -- haven't noted down defaults yet
				origExpanded, origShrunk = v.expandedWidth, v.shrunkWidth
			end

			if (db.lockSize) then -- locking attribute size
				v.expandedWidth, v.shrunkWidth = v.normalWidth, v.normalWidth
			else
				v.expandedWidth, v.shrunkWidth = origExpanded, origShrunk
			end
		end
	end
end

function Azurah:ConfigureRPTitle()

	-- Hide the @accountname in the target frame context.
	if (not db.RPTitle) then
		if (db.RPName) then
			local GetSecondary = ZO_GetSecondaryPlayerNameWithTitleFromUnitTag
				ZO_GetSecondaryPlayerNameWithTitleFromUnitTag = function(unitTag)
				if not IsUnitPlayer(unitTag) then
					return zo_strformat(GetUnitTitle(unitTag))
				else
					GetSecondary(unitTag)
				end
			end
		end
	else
		-- Also hide the target's title.
		local GetSecondary = ZO_GetSecondaryPlayerNameWithTitleFromUnitTag
			ZO_GetSecondaryPlayerNameWithTitleFromUnitTag = function(unitTag)
			if not IsUnitPlayer(unitTag) then
				return
			else
				GetSecondary(unitTag)
			end
		end
	end

	-- Hide the @accountname in the player interaction context.
	if (db.RPInteract) then
		ZO_GetPrimaryPlayerNameWithSecondary = function(displayName, characterName)
			return zo_strformat(characterName)
		end
	end

	-- Remove the player head icon from the target character name.
	if (db.RPIcon) then
		ZO_FormatUserFacingCharacterName = function(name) return name end
	end
	
end

-- ------------------------
-- INITIALIZATION
-- ------------------------
function Azurah:InitializeTarget()
	db = self.db.target

	-- local reference to target elements
	targetLeft	= ZO_TargetUnitFramereticleoverBarLeft
	targetRight	= ZO_TargetUnitFramereticleoverBarRight
	targetName	= ZO_TargetUnitFramereticleoverName
	targetLevel	= ZO_TargetUnitFramereticleoverLevel
	targetChamp	= ZO_TargetUnitFramereticleoverChampionIcon

	-- create overlay
	overlayTarget = self:CreateOverlay(ZO_TargetUnitFramereticleover, CENTER, CENTER, 0, -0.5)

	-- set 'dummy' display function
	FormatTarget = self.overlayFuncs[1]

	-- create icons
	targetClass = WINDOW_MANAGER:CreateControl(nil, ZO_TargetUnitFramereticleover, CT_TEXTURE)
	targetClass:SetHidden(true)
	targetAlliance = WINDOW_MANAGER:CreateControl(nil, ZO_TargetUnitFramereticleover, CT_TEXTURE)
	targetAlliance:SetHidden(true)

	self:ConfigureTargetColouring()
	self:ConfigureTargetIcons()
	self:ConfigureTargetSizeLock()
	self:ConfigureRPTitle()

	EVENT_MANAGER:RegisterForEvent(self.name .. 'Target', EVENT_LEVEL_UPDATE,			OnLevel)
	EVENT_MANAGER:RegisterForEvent(self.name .. 'Target', EVENT_CHAMPION_POINT_UPDATE,	OnLevel)
	EVENT_MANAGER:RegisterForEvent(self.name .. 'Target', EVENT_RETICLE_TARGET_CHANGED,	OnTargetChanged)
	EVENT_MANAGER:RegisterForEvent(self.name .. 'Target', EVENT_MOUSEOVER_CHANGED,		OnTargetChanged)
	EVENT_MANAGER:RegisterForEvent(self.name .. 'Target', EVENT_DISPOSITION_UPDATE,		OnTargetChanged)
end
