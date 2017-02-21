-- This libray is currently only for internal use and its API might change a lot between versions
local lib = LibStub:NewLibrary("LibAbilityTooltip", 2)

if not lib then
	return	-- already loaded and no upgrade necessary
end

local LIB_IDENTIFIER = "LibAbilityTooltip"
local ABILITY_LINK = "LATAbility"
local CURRENT_VERSION = 1
local ABILITY_LINK_MATCH1 = "(|H.-:.-:.-|h.-|h)"
local ABILITY_LINK_MATCH2 = ("|H(.-):.-%s:(.-):(.-)|h.-|h"):format(ABILITY_LINK)
local ABILITY_LINK_TEMPLATE = ("|cFF7B52|H%%d:%s:%%d:%%d|h%%s|h|r"):format(ABILITY_LINK)
local ABILITY_LINK_WRAPPED_TEMPLATE = ("|H%%d:book:851:%s:%%d:%%d|h|h"):format(ABILITY_LINK)

local function CreateControls()
	local container = CreateTopLevelWindow("LibAbilityTooltipWindow")
	container:SetDrawTier(DT_HIGH)
	container:SetDrawLevel(ZO_HIGH_TIER_TOOLTIPS)

	local tooltip = CreateControlFromVirtual("LibAbilityTooltipControl", container, "ZO_BaseTooltip")
	tooltip:SetResizeToFitPadding(32, 40)
	tooltip:SetDimensionConstraints(384, nil, 384, nil)
	tooltip:SetHidden(true)
	tooltip:SetAnchor(CENTER)

	local fadeLeft = tooltip:CreateControl("$(parent)FadeLeft", CT_TEXTURE)
	fadeLeft:SetTexture("EsoUI/Art/ItemToolTip/iconStrip.dds")
	fadeLeft:SetExcludeFromResizeToFitExtents(true)
	fadeLeft:SetDimensions(100, 4)
	fadeLeft:SetTextureCoords(1, 0)
	fadeLeft:SetAnchor(TOPRIGHT, nil, TOP)

	local fadeRight = tooltip:CreateControl("$(parent)FadeRight", CT_TEXTURE)
	fadeRight:SetTexture("EsoUI/Art/ItemToolTip/iconStrip.dds")
	fadeRight:SetExcludeFromResizeToFitExtents(true)
	fadeRight:SetDimensions(100, 4)
	fadeRight:SetAnchor(TOPLEFT, nil, TOP)

	local missingIcon = tooltip:CreateControl("$(parent)MissingIcon", CT_TEXTURE)
	missingIcon:SetTexture("EsoUI/Art/Icons/icon_missing.dds")
	missingIcon:SetExcludeFromResizeToFitExtents(true)
	missingIcon:SetDimensions(64, 64)
	missingIcon:SetAnchor(CENTER, nil, TOP)

	local icon = tooltip:CreateControl("$(parent)Icon", CT_TEXTURE)
	icon:SetExcludeFromResizeToFitExtents(true)
	icon:SetDimensions(64, 64)
	icon:SetAnchor(CENTER, nil, TOP)
	icon:SetHandler("OnTextureLoaded", function()
		missingIcon:SetHidden(true)
	end)
	local originalSetTexture = icon.SetTexture
	icon.SetTexture = function(...)
		originalSetTexture(...)
		if(not icon:IsTextureLoaded()) then
			missingIcon:SetHidden(false)
		end
	end

	local closeButton = CreateControlFromVirtual("$(parent)Close", tooltip, "ZO_CloseButton")
	closeButton:SetExcludeFromResizeToFitExtents(true)
	closeButton:SetAnchor(TOPRIGHT, nil, nil, -6, 6)
	closeButton:SetHandler("OnClicked", function() lib:HideTooltip() end)
	closeButton:SetHidden(true)

	lib.container = container
	lib.tooltip = tooltip
	lib.icon = icon
	lib.closeButton = closeButton
end

local function AquireTooltip()
	if(not lib.tooltip) then
		CreateControls()
	end
	return lib.tooltip
end

local function AquireContainer()
	if(not lib.container) then
		CreateControls()
	end
	return lib.container
end

local function AquireIcon()
	if(not lib.icon) then
		CreateControls()
	end
	return lib.icon
end

local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
function lib:SetAbility(abilityId)
	if(self.abilityId == abilityId) then return end
	local tooltip = AquireTooltip()
	tooltip:ClearLines()
	if(DoesAbilityExist(abilityId)) then
		local icon = AquireIcon()
		icon:SetTexture(GetAbilityIcon(abilityId))
		tooltip:AddLine(" ", "ZoFontGameMedium", r, g, b, nil, nil, TEXT_ALIGN_CENTER, true)
		tooltip:SetAbilityId(abilityId)
	else
		tooltip:AddLine("Invalid Ability", "ZoFontGameMedium", r, g, b, nil, nil, TEXT_ALIGN_CENTER, true)
	end
	self.abilityId = abilityId
end

function lib:SetAnchor(...)
	local tooltip = AquireTooltip()
	tooltip:ClearAnchors()
	tooltip:SetAnchor(...)
end

function lib:ShowTooltip(abilityId, isPopupTooltip)
	self:SetAbility(abilityId)
	local tooltip = AquireTooltip()
	tooltip:SetHidden(false)

	lib.closeButton:SetHidden(not isPopupTooltip)
	if(isPopupTooltip and not lib.wasPopupTooltip) then
		lib.wasPopupTooltip = true
		tooltip:ClearAnchors()
		tooltip:SetAnchor(CENTER, GuiRoot, CENTER)
		tooltip:SetMovable(true)
		tooltip:SetMouseEnabled(true)
	elseif(not isPopupTooltip and lib.wasPopupTooltip) then
		lib.wasPopupTooltip = false
		tooltip:SetMovable(false)
		tooltip:SetMouseEnabled(false)
	end
end

function lib:HideTooltip()
	local tooltip = AquireTooltip()
	tooltip:SetHidden(true)
end

local function ParseAbilityLink(link)
	local linkStyle, version, abilityId = link:match(ABILITY_LINK_MATCH2)
	return tonumber(linkStyle), tonumber(version), tonumber(abilityId)
end

local function ReplaceLink(link)
	local linkStyle, version, abilityId = ParseAbilityLink(link)
	if(linkStyle == nil) then return end
	if(version == CURRENT_VERSION and linkStyle ~= nil and DoesAbilityExist(abilityId)) then
		local name = GetAbilityName(abilityId)
		if(linkStyle == LINK_STYLE_BRACKETS) then name = "[" .. name .. "]" end
		return ABILITY_LINK_TEMPLATE:format(linkStyle, version, abilityId, name)
	end
end

function lib:ReplaceAbilityLinks(message)
	message = message:gsub(ABILITY_LINK_MATCH1, ReplaceLink)
	return message
end

function lib:CreateAbilityLink(abilityId, linkStyle)
	if(not linkStyle or (linkStyle ~= LINK_STYLE_DEFAULT and linkStyle ~= LINK_STYLE_BRACKETS)) then linkStyle = LINK_STYLE_DEFAULT end
	return ABILITY_LINK_WRAPPED_TEMPLATE:format(linkStyle, CURRENT_VERSION, abilityId)
end

if(not lib.HasHookedChat) then
	lib.HasHookedChat = true

	lib.AddWindow_Orig = SharedChatContainer.AddWindow
	lib.AddMessage_Orig = {}
	SharedChatContainer.AddWindow = function(...)
		local window = lib.AddWindow_Orig(...)
		local buffer = window.buffer

		local AddMessage_Orig = buffer.AddMessage
		lib.AddMessage_Orig[buffer] = AddMessage_Orig
		buffer.AddMessage = function(self, message, ...)
			if(message and #message > 0) then
				message = lib:ReplaceAbilityLinks(message)
			end
			AddMessage_Orig(self, message, ...)
		end

		return window
	end
end

EVENT_MANAGER:UnregisterForEvent(LIB_IDENTIFIER, EVENT_PLAYER_ACTIVATED)
EVENT_MANAGER:RegisterForEvent(LIB_IDENTIFIER, EVENT_PLAYER_ACTIVATED, function()
	EVENT_MANAGER:UnregisterForEvent(LIB_IDENTIFIER, EVENT_PLAYER_ACTIVATED)

	local function HandleAbilityLink(link, button, control, color, linkType, copyBufferIndex, messageIndex)
		if(linkType == ABILITY_LINK) then
			local _, version, abilityId = ParseAbilityLink(link)
			if(version == CURRENT_VERSION) then
				lib:ShowTooltip(abilityId, true)
			end
			return true
		end
	end

	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, HandleAbilityLink)
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, HandleAbilityLink)
end)
