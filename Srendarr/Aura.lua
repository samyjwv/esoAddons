local Srendarr		= _G['Srendarr'] -- grab addon table from global
local L				= Srendarr:GetLocale()
local LMP			= LibStub('LibMediaProvider-1.0')
local Aura			= {}

-- CONSTS --
local AURA_TYPE_TIMED		= Srendarr.AURA_TYPE_TIMED
local AURA_TYPE_TOGGLED		= Srendarr.AURA_TYPE_TOGGLED
local AURA_TYPE_PASSIVE		= Srendarr.AURA_TYPE_PASSIVE

local AURA_HEIGHT			= Srendarr.AURA_HEIGHT

local AURA_STYLE_FULL		= Srendarr.AURA_STYLE_FULL
local AURA_STYLE_ICON		= Srendarr.AURA_STYLE_ICON
local AURA_STYLE_MINI		= Srendarr.AURA_STYLE_MINI

local AURA_TIMERLOC_HIDDEN	= Srendarr.AURA_TIMERLOC_HIDDEN
local AURA_TIMERLOC_OVER	= Srendarr.AURA_TIMERLOC_OVER
local AURA_TIMERLOC_ABOVE	= Srendarr.AURA_TIMERLOC_ABOVE
local AURA_TIMERLOC_BELOW	= Srendarr.AURA_TIMERLOC_BELOW

-- UPVALUES --
local WM					= WINDOW_MANAGER
local TEXT_ALIGN_TOP		= TEXT_ALIGN_TOP
local TEXT_ALIGN_BOTTOM		= TEXT_ALIGN_BOTTOM
local TEXT_ALIGN_CENTER		= TEXT_ALIGN_CENTER
local TEXT_ALIGN_LEFT		= TEXT_ALIGN_LEFT
local TEXT_ALIGN_RIGHT		= TEXT_ALIGN_LEFT
local GetGameTimeMillis		= GetGameTimeMilliseconds
local strformat				= string.format
local math_floor			= math.floor
local tremove				= table.remove
local tinsert				= table.insert
local zo_strformat			= zo_strformat
local AddControl			= Srendarr.AddControl

local tTenths				= L.Time_Tenths
local tSec					= L.Time_Seconds
local tMin					= L.Time_Minutes
local tHour					= L.Time_Hours
local tDay					= L.Time_Days
local tToggle				= L.Time_Toggle
local tPassive				= L.Time_Passive

local auraLookup			= Srendarr.auraLookup
local auraID				= 1		-- incremental counter to give each aura object a unique identifier
local activeTimedAuras		= {}	-- all active auras with timers, referenced by their auraID
local currentTime, colours


-- ------------------------
-- CONFIGURE ABILITY ID DISPLAY
-- ------------------------
local showAbilityID			= false

function Srendarr:ConfigureDisplayAbilityID()
	showAbilityID = self.db.displayAbilityID
end


-- ------------------------
-- TIME FORMAT FUNCTION
-- ------------------------
local function FormatTime(remaining, frame)
	if (remaining <= 0) then -- Hide when expires
		return ""
	elseif (remaining < 2) then -- 10ths of seconds
		return strformat(tTenths, remaining)
	elseif (remaining < 60) then -- seconds
		return strformat(tSec, remaining)
	elseif (remaining < 3600) then -- minutes
		return strformat(tMin, math_floor(remaining / 60))
	elseif (remaining > 172800) then -- days (2+, revert to hours when between 24-48hrs)
		return strformat(tDay, math_floor(remaining / 86400))
	else -- hours
		if (Srendarr.db.displayFrames[frame].timerHMS) then
			local sub = math_floor(remaining / 3600) * 60
			local hours = math_floor(remaining / 3600)
			local hourstring = strformat(tHour, hours)
			local minutes = math_floor(remaining / 60) - sub
			local minutestring = strformat(tMin, minutes)
			local secondstring = strformat(tSec, math_floor(remaining - (hours * 3600) - (minutes * 60)))
			if minutes > 0 then
				return hourstring..minutestring
			else
				return hourstring..secondstring
			end
		else
			return strformat(tHour, math_floor(remaining / 3600)).."+"
		end
	end
end


-- ------------------------
-- TOOLTIP HANDLERS
-- ------------------------
local function OnMouseEnter(aura)
	InitializeTooltip(InformationTooltip, aura, BOTTOMLEFT, 0, - 2, TOPLEFT)

	if (aura.abilityID < 116000 and GetAbilityDescription(aura.abilityID) ~= '') then
		InformationTooltip:SetAbilityId(aura.abilityID)
	else
		SetTooltipText(InformationTooltip, aura.auraName)
	end
end

local function OnMouseExit()
	ClearTooltip(InformationTooltip)
end


-- ------------------------
-- TIMER UPDATE HANDLER
do ------------------------
	local RATE				= Srendarr.AURA_UPDATE_RATE

	local strformat			= string.format
	local math_max			= math.max
	local GetFormattedTime	= FormatTime

	local timedAuras		= activeTimedAuras
	local auraFadeTime		= -2 -- need a base value before being set by config
	local nextUpdate		= 0
	local timeRemaining

	local function OnUpdate(self, updateTime)
		if (updateTime >= nextUpdate) then
			for _, aura in pairs(timedAuras) do
				timeRemaining = aura.finish - updateTime

				if (timeRemaining <= auraFadeTime) then -- expired and finished fading, done
					aura:Release()
				elseif (timeRemaining <= 0) then -- expired, but not done fading yet
					if (not aura.isFading) then
						aura:SetExpired() -- set expired if we should be but aren't yet
					end

					aura:SetAlpha(math_max(0, 1 - (timeRemaining / auraFadeTime)))
				else -- normal countdown
					aura.bar:SetValue(1 - ((updateTime - aura.start) / (aura.finish - aura.start)))
					aura.timer:SetText(GetFormattedTime(timeRemaining, Srendarr.db.auraGroups[aura.auraGroup]))
				end
			end

			nextUpdate = updateTime + RATE
		end
	end

	Srendarr:SetHandler('OnUpdate', OnUpdate)

	function Srendarr:ConfigureAuraFadeTime()
		auraFadeTime = self.db.auraFadeTime * -1
	end
end


-- ------------------------
-- AURA
-- ------------------------
function Aura:Create(displayParent)
	local aura, ctrl

	aura, ctrl = AddControl(displayParent, CT_TEXTURE, 2)
	ctrl:SetDimensions(AURA_HEIGHT, AURA_HEIGHT)
	-- ICON
	aura.icon, ctrl = AddControl(aura, CT_TEXTURE, 1)
	ctrl:SetDimensions(AURA_HEIGHT - 4, AURA_HEIGHT - 4)
	ctrl:SetAnchor(CENTER)
	-- ICON BACKGROUND
	aura.iconBG, ctrl = AddControl(aura.icon, CT_TEXTURE, 0)
	ctrl:SetDimensions(AURA_HEIGHT - 4, AURA_HEIGHT - 4)
	ctrl:SetAnchor(CENTER)
	ctrl:SetTexture([[/esoui/art/actionbar/abilityinset.dds]])
	-- TOGGLED HIGHLIGHT
	aura.highlight, ctrl = AddControl(aura, CT_TEXTURE, 3)
	ctrl:SetDimensions(AURA_HEIGHT -2, AURA_HEIGHT -2)
	ctrl:SetAnchor(CENTER)
	ctrl:SetTexture([[/esoui/art/actionbar/actionslot_toggledon.dds]])
	ctrl:SetHidden(true)
	-- LABELS
	aura.name, ctrl = AddControl(aura, CT_LABEL, 4)
	ctrl:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
	ctrl:SetInheritScale(false)
	aura.timer, ctrl = AddControl(aura, CT_LABEL, 4)
	ctrl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	ctrl:SetInheritScale(false)
	-- BAR
	aura.bar, ctrl = AddControl(aura, CT_STATUSBAR, 2)
	ctrl:SetHeight(16)
	ctrl:SetTexture([[/esoui/art/miscellaneous/progressbar_genericfill.dds]])
	ctrl:SetTextureCoords(0, 1, 0, 0.625)
	ctrl:SetLeadingEdge([[/esoui/art/miscellaneous/progressbar_genericfill_leadingedge.dds]], 8, 32)
	ctrl:SetLeadingEdgeTextureCoords(0, 1, 0, 0.625)
	ctrl:EnableLeadingEdge(true)
	ctrl:SetMinMax(0, 1)
	ctrl:SetHandler('OnValueChanged', function(bar, value) bar.gloss:SetValue(value) end) -- change gloss value as main bar changes
	-- BAR GLOSS
	aura.bar.gloss, ctrl = AddControl(aura.bar, CT_STATUSBAR, 3)
	ctrl:SetHeight(16)
	ctrl:SetAnchor(TOPLEFT)
	ctrl:SetTexture([[/esoui/art/miscellaneous/progressbar_genericfill_gloss.dds]])
	ctrl:SetTextureCoords(0, 1, 0, 0.625)
	ctrl:SetLeadingEdge([[/esoui/art/miscellaneous/progressbar_genericfill_leadingedge_gloss.dds]], 8, 32)
	ctrl:SetLeadingEdgeTextureCoords(0, 1, 0, 0.625)
	ctrl:EnableLeadingEdge(true)
	ctrl:SetMinMax(0, 1)
	-- BAR FRAME
	aura.barBorderL, ctrl = AddControl(aura.bar, CT_TEXTURE, 4)
	ctrl:SetDimensions(10, 16)
	ctrl:SetAnchor(TOPLEFT)
	ctrl:SetTexture([[/esoui/art/miscellaneous/progressbar_frame.dds]])
	aura.barBorderR, ctrl = AddControl(aura.bar, CT_TEXTURE, 4)
	ctrl:SetDimensions(10, 16)
	ctrl:SetAnchor(TOPRIGHT)
	ctrl:SetTexture([[/esoui/art/miscellaneous/progressbar_frame.dds]])
	aura.barBorderM, ctrl = AddControl(aura.bar, CT_TEXTURE, 4)
	ctrl:SetHeight(16)
	ctrl:SetAnchor(TOPLEFT, aura.bar, TOPLEFT, 10, 0)
	ctrl:SetTexture([[/esoui/art/miscellaneous/progressbar_frame.dds]])
	ctrl:SetTextureCoords(0.019500000402331, 0.58980000019073, 0, 0.625)
	-- BAR BACKDROP
	aura.barBackdropEnd, ctrl = AddControl(aura.bar, CT_TEXTURE, 1)
	ctrl:SetDimensions(10, 16)
	ctrl:SetTexture([[/esoui/art/miscellaneous/progressbar_genericfill_leadingedge.dds]])
	ctrl:SetColor(0,0,0,0.4)
	aura.barBackdrop, ctrl = AddControl(aura.bar, CT_TEXTURE, 1)
	ctrl:SetHeight(16)
	ctrl:SetTexture('')
	ctrl:SetColor(0,0,0,0.4)

	aura.displayParent		= displayParent
	aura.auraID				= auraID
	auraID					= auraID + 1

	aura.highlightToggled	= false	-- will both be set by the Configure function
	aura.barColours			= {}

	-- aura exec
	aura['Initialize']		= Aura.Initialize
	aura['Update']			= Aura.Update
	aura['SetExpired']		= Aura.SetExpired
	aura['Release']			= Aura.Release
	-- configuration
	aura['Configure']		= Aura.Configure
	aura['UpdateVisuals']	= Aura.UpdateVisuals

	return aura
end


-- ------------------------
-- AURA EXECUTION
do ------------------------
	local alteredIcons = Srendarr.alteredAuraIcons

	function Aura:Initialize(auraGroup, auraType, auraName, unitTag, start, finish, icon, effectType, abilityType, abilityID)
		self.auraGroup		= auraGroup
		self.auraType		= auraType
		self.auraName		= auraName
		self.unitTag		= unitTag or 'notag' -- ensure something is set here
		self.start			= start
		self.finish			= finish
		self.effectType		= effectType
		self.abilityType	= abilityType
		self.abilityID		= abilityID
		self.isFading		= false		-- make sure to note aura is enabled again

		auraLookup[unitTag][abilityID] = self -- add self to the aura lookup reference

		if (showAbilityID) then
			if (self.auraStyle == AURA_STYLE_ICON) then
				self.name:SetText(abilityID)
			else
				self.name:SetText(zo_strformat(SI_ABILITY_TOOLTIP_NAME, auraName) .. ' [' .. abilityID .. ']')
			end
		else
			self.name:SetText(zo_strformat(SI_ABILITY_TOOLTIP_NAME, auraName))
		end

		self.icon:SetTexture((alteredIcons[abilityID]) and alteredIcons[abilityID] or icon)
		self.icon:SetDesaturation(0)
		self.highlight:SetHidden(true)
		self:SetAlpha(1)

		if (auraType == AURA_TYPE_TIMED) then
			currentTime = GetGameTimeMillis() / 1000

			self.timer:SetText(FormatTime(finish - currentTime, Srendarr.db.auraGroups[auraGroup]))
			self.bar:SetValue(1 - ((currentTime - start) / (finish - start)))

			activeTimedAuras[self.auraID] = self -- is a timed aura, add to timer tracking table (used in OnUpdate)
		elseif (auraType == AURA_TYPE_TOGGLED) then
			self.timer:SetText('')
			self.bar:SetValue(0.99)
			self.highlight:SetHidden(not self.highlightToggled)
		else -- AURA_TYPE_PASSIVE
			self.timer:SetText('')
			self.bar:SetValue(0.99)
		end

		colours = self.barColours[auraType]
		self.bar:SetGradientColors(colours.r1, colours.g1, colours.b1, 1, colours.r2, colours.g2, colours.b2, 1)

		self:SetHidden(false)
	end
end

function Aura:Update(start, finish)
	if (self.start == start and self.finish == finish) then return end -- if they are the same nothing changed (repeat event firings probably), do nothing

	currentTime = GetGameTimeMillis() / 1000
	self.start	= start
	self.finish	= finish

	self.timer:SetText(FormatTime(finish - currentTime, Srendarr.db.auraGroups[self.auraGroup]))
	self.bar:SetValue(1 - ((currentTime - start) / (finish - start)))

	if (self.isFading) then -- aura (most likely) had expired in game but was still active internally due to fadeout
		self.isFading = false
		self:SetAlpha(1)
		self.icon:SetDesaturation(0)
	end

	self.displayParent:UpdateDisplay() -- time has changed, update parent display as ordering may have been altered
end

function Aura:SetExpired()
	if (not self.isFading) then -- if not already expired and fading, start
		self.finish = GetGameTimeMillis() / 1000 -- times up, make sure our internal finish time agrees
		self.icon:SetDesaturation(1)

		self.isFading = true -- note that its time to start fading
	end
end

function Aura:Release(flagBurst)
	self:SetHidden(true)

	activeTimedAuras[self.auraID] = nil -- whether timed aura or not, this removes self from tracking table

	auraLookup[self.unitTag][self.abilityID] = nil -- remove self from the aura lookup reference

	self.displayParent:OnAuraReleased(flagBurst, self)
end


-- ------------------------
-- CONFIGURATION
-- ------------------------
function Aura:Configure(settings)
	self.auraStyle = settings.style -- internal ref for currently active style

	-- configure local references for things that can change from ability to ability on the same aura object
	self.highlightToggled	= settings.highlightToggled
	self.barColours[AURA_TYPE_TIMED]	= settings.barColours[AURA_TYPE_TIMED]
	self.barColours[AURA_TYPE_TOGGLED]	= settings.barColours[AURA_TYPE_TOGGLED]
	self.barColours[AURA_TYPE_PASSIVE]	= settings.barColours[AURA_TYPE_PASSIVE]

	self.name:SetFont(strformat('%s|%d|%s', LMP:Fetch('font', settings.nameFont), settings.nameSize, settings.nameStyle))
	self.name:SetColor(settings.nameColour[1], settings.nameColour[2], settings.nameColour[3], settings.nameColour[4])

	self.timer:SetFont(strformat('%s|%d|%s', LMP:Fetch('font', settings.timerFont), settings.timerSize, settings.timerStyle))
	self.timer:SetColor(settings.timerColour[1], settings.timerColour[2], settings.timerColour[3], settings.timerColour[4])
	self.timer:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)

	-- configure tooltip control
	if (settings.style == AURA_STYLE_ICON and settings.enableTooltips) then -- only in icon mode
		if (not self:GetHandler('OnMouseEnter')) then
			self:SetHandler('OnMouseEnter',	OnMouseEnter)
			self:SetHandler('OnMouseExit',	OnMouseExit)
		end

		self:SetMouseEnabled(true)
	else
		self:SetMouseEnabled(false)

		if (self:GetHandler('OnMouseEnter')) then
			self:SetHandler('OnMouseEnter', nil)
			self:SetHandler('OnMouseExit', nil)
		end
	end

	if (settings.style == AURA_STYLE_FULL) then -- full style, must be growing up or down
		-- configure icon
		self:SetTexture([[/esoui/art/actionbar/abilityframe64_up.dds]])
		self.icon:SetHidden(false)
		self.highlight:SetAlpha(1) -- allow toggle highlight to be seen again if set (is a hack, but it works without a lot of checking)
		-- configure timer
		self.timer:ClearAnchors()
		self.timer:SetAnchor(BOTTOM, self, BOTTOM, 0, -1) -- in full style, the timer is either over or hidden
		self.timer:SetHidden(settings.timerLocation == AURA_TIMERLOC_HIDDEN)

		-- configure bar display
		self.bar:SetDimensions(settings.barWidth, 16)
		self.bar:SetLeadingEdge([[/esoui/art/miscellaneous/progressbar_genericfill_leadingedge.dds]], 8, 32)
		self.bar.gloss:SetDimensions(settings.barWidth, 16)
		self.bar.gloss:SetLeadingEdge([[/esoui/art/miscellaneous/progressbar_genericfill_leadingedge_gloss.dds]], 8, 32)
		self.bar.gloss:SetHidden(not settings.barGloss)
		self.barBorderL:SetHeight(16)
		self.barBorderR:SetHeight(16)
		self.barBorderM:SetDimensions(settings.barWidth - 20, 16)
		self.barBackdrop:ClearAnchors()
		self.barBackdrop:SetDimensions(settings.barWidth - 10, 16)
		self.barBackdropEnd:ClearAnchors()
		self.barBackdropEnd:SetHeight(16)

		self.name:ClearAnchors()
		self.name:SetHidden(false)
		self.bar:ClearAnchors()
		self.bar:SetHidden(false)

		if (settings.barReverse) then
			self.barBackdrop:SetAnchor(TOPRIGHT, self.bar, TOPRIGHT, 0, 0)
			self.barBackdropEnd:SetAnchor(TOPLEFT, self.bar, TOPLEFT, 0, 0)
			self.bar:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
			self.bar.gloss:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
			self.barBorderL:SetTextureCoords(0.6133000254631, 0.59380000829697, 0, 0.625)
			self.barBorderR:SetTextureCoords(0.019500000402331, 0, 0, 0.625)
			self.barBackdropEnd:SetTextureCoords(1, 0, 0, 0.625)

			self.name:SetAnchor(BOTTOMRIGHT, self.bar, TOPRIGHT, -2, -1)
			self.name:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			self.bar:SetAnchor(BOTTOMRIGHT, self, BOTTOMLEFT, -3, 0)
		else
			self.barBackdrop:SetAnchor(TOPLEFT, self.bar, TOPLEFT, 0, 0)
			self.barBackdropEnd:SetAnchor(TOPRIGHT, self.bar, TOPRIGHT, 0, 0)
			self.bar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
			self.bar.gloss:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
			self.barBorderL:SetTextureCoords(0, 0.019500000402331, 0, 0.625)
			self.barBorderR:SetTextureCoords(0.59380000829697, 0.6133000254631, 0, 0.625)
			self.barBackdropEnd:SetTextureCoords(0, 1, 0, 0.625)

			self.name:SetAnchor(BOTTOMLEFT, self.bar, TOPLEFT, 2, -1)
			self.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			self.bar:SetAnchor(BOTTOMLEFT, self, BOTTOMRIGHT, 3, 0)
		end
	elseif (settings.style == AURA_STYLE_ICON) then -- icon only style, hide unused elements
		-- configure icon
		self:SetTexture([[/esoui/art/actionbar/abilityframe64_up.dds]])
		self.icon:SetHidden(false)
		self.highlight:SetAlpha(1) -- allow toggle highlight to be seen again if set (is a hack, but it works without a lot of checking)
		-- configure timer
		self.timer:ClearAnchors()

		if (settings.timerLocation == AURA_TIMERLOC_ABOVE) then
			self.timer:SetAnchor(BOTTOM, self, TOP, 0, 0)
		elseif (settings.timerLocation == AURA_TIMERLOC_BELOW) then
			self.timer:SetAnchor(TOP, self, BOTTOM, 0, -1)
			self.timer:SetVerticalAlignment(TEXT_ALIGN_TOP)
		else -- settings.timerLocation == AURA_TIMERLOC_OVER (or hidden, makes no difference)
			self.timer:SetAnchor(BOTTOM, self, BOTTOM, 0, -1)
		end

		self.timer:SetHidden(settings.timerLocation == AURA_TIMERLOC_HIDDEN)

		if (showAbilityID) then -- repurpose name display for abilityID display
			self.name:SetFont(strformat('%s|13|soft-shadow-thin', LMP:Fetch('font', 'Univers 57')))
			self.name:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
			self.name:ClearAnchors()
			self.name:SetAnchor(TOP, self, TOP, 0, 1)
			self.name:SetHidden(false)
		else
			self.name:SetHidden(true)
		end

		self.bar:SetHidden(true)
	else -- style == AURA_STYLE_MINI
		-- configure icon
		self:SetTexture(0, 0, 0, 0)	-- make icon inivisble (cannot set alpha as it is the base of the aura object)
		self.icon:SetHidden(true)	-- hide the icon for this ability
		self.highlight:SetAlpha(0)	-- disable toggle highlight (is a hack, but it works without a lot of checking)
		-- configure timer
		self.timer:SetHidden(true) -- no timer text in this style

		-- configure bar display
		self.bar:SetDimensions(settings.barWidth, 9)
		self.bar:SetLeadingEdge([[/esoui/art/miscellaneous/progressbar_genericfill_leadingedge.dds]], 8, 18)
		self.bar.gloss:SetDimensions(settings.barWidth, 9)
		self.bar.gloss:SetLeadingEdge([[/esoui/art/miscellaneous/progressbar_genericfill_leadingedge_gloss.dds]], 8, 18)
		self.bar.gloss:SetHidden(not settings.barGloss)
		self.barBorderL:SetHeight(9)
		self.barBorderR:SetHeight(9)
		self.barBorderM:SetDimensions(settings.barWidth - 20, 9)
		self.barBackdrop:ClearAnchors()
		self.barBackdrop:SetDimensions(settings.barWidth - 10, 9)
		self.barBackdropEnd:ClearAnchors()
		self.barBackdropEnd:SetHeight(9)

		self.name:ClearAnchors()
		self.name:SetHidden(false)
		self.bar:ClearAnchors()
		self.bar:SetHidden(false)

		if (settings.barReverse) then
			self.barBackdrop:SetAnchor(TOPRIGHT, self.bar, TOPRIGHT, 0, 0)
			self.barBackdropEnd:SetAnchor(TOPLEFT, self.bar, TOPLEFT, 0, 0)
			self.bar:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
			self.bar.gloss:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
			self.barBorderL:SetTextureCoords(0.6133000254631, 0.59380000829697, 0, 0.625)
			self.barBorderR:SetTextureCoords(0.019500000402331, 0, 0, 0.625)
			self.barBackdropEnd:SetTextureCoords(1, 0, 0, 0.625)

			self.name:SetAnchor(BOTTOMRIGHT, self.bar, TOPRIGHT, -2, -1)
			self.name:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			self.bar:SetAnchor(BOTTOMRIGHT, self, BOTTOMRIGHT, 0, -5)
		else
			self.barBackdrop:SetAnchor(TOPLEFT, self.bar, TOPLEFT, 0, 0)
			self.barBackdropEnd:SetAnchor(TOPRIGHT, self.bar, TOPRIGHT, 0, 0)
			self.bar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
			self.bar.gloss:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
			self.barBorderL:SetTextureCoords(0, 0.019500000402331, 0, 0.625)
			self.barBorderR:SetTextureCoords(0.59380000829697, 0.6133000254631, 0, 0.625)
			self.barBackdropEnd:SetTextureCoords(0, 1, 0, 0.625)

			self.name:SetAnchor(BOTTOMLEFT, self.bar, TOPLEFT, 2, -1)
			self.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			self.bar:SetAnchor(BOTTOMLEFT, self, BOTTOMLEFT, 0, -5)
		end
	end
end

function Aura:UpdateVisuals() -- updates visuals on active auras, only called by settings changes
	if (self.auraType and self.auraType == AURA_TYPE_TOGGLED) then
		self.highlight:SetHidden(not self.highlightToggled) -- update toggle highlighting
	end

	colours = self.barColours[self.auraType]
	self.bar:SetGradientColors(colours.r1, colours.g1, colours.b1, 1, colours.r2, colours.g2, colours.b2, 1)
end


Srendarr.Aura = Aura
