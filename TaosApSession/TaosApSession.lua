--[[
	Addon: Taos AP Session
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Global variables
]]--
local REFRESHRATE = 1000
local MAJOR = "1"
local MINOR = "3"
local PATCH = "2"

--[[
	Class ApSession
]]--
ApSession = {}

--[[
	Class Members
]]--
ApSession.Name = "TaosApSession"
ApSession.IsInAvA = false
ApSession.SessionAP = 0
ApSession.SessionDeaths = 0
ApSession.SessionKills = 0
ApSession.SessionStartTime = 0
ApSession.Default = {
			["PosX"] = 0,
			["PosY"] = 0,
			["Movable"] = true,
            ["IsLongStyle"] = false,
		}

--[[
	UpdateAP updates SessionAP with adding new AP
]]--
function ApSession.UpdateAP(eventCode, alliancePoints, playSound, difference)
	if (difference > 0) then
		ApSession.SessionAP = ApSession.SessionAP + difference
	end
end

--[[
	UpdateDeath updates SessionDeaths with adding new death
]]--
function ApSession.UpdateDeath(eventID)
	if (ApSession.IsInAvA) then
		ApSession.SessionDeaths = ApSession.SessionDeaths + 1
	end
end

--[[
	UpdateKills updates SessionKills with adding new kill
]]--
function ApSession.UpdateKills(eventCode, 
							   result, 
							   isError, 
							   abilityName, 
							   abilityGraphic, 
							   abilityActionSlotType, 
							   sourceName, 
							   sourceType, 
							   targetName, 
							   targetType, 
							   hitValue, 
							   powerType, 
							   damageType, 
							   log)
	if (ApSession.IsInAvA and
		result == ACTION_RESULT_KILLING_BLOW and 
		sourceType == COMBAT_UNIT_TYPE_PLAYER and 
		GetUnitName("player") == zo_strformat("<<1>>", sourceName)) then
		if (hitValue == 0) then return end
		if (zo_strformat("<<1>>", sourceName) == zo_strformat("<<1>>", targetName)) then return end
		
		ApSession.SessionKills = ApSession.SessionKills + 1
	end
end

--[[
	UpdateZone updates the IsInAva member and set visibility of ApSessionWindow
]]--
function ApSession.UpdateZone(eventCode)
	ApSession.IsInAvA = IsPlayerInAvAWorld()

    if (ApSession.Settings.IsLongStyle) then
	    ApSessionWindow:SetHidden(true)
        ApSessionWindowLong:SetHidden(not ApSession.IsInAvA)
    else
        ApSessionWindow:SetHidden(not ApSession.IsInAvA)
        ApSessionWindowLong:SetHidden(true)
    end
end

--[[
	UpdateSession updates session, calculating AP/H, K/D and showing in labels
]]--
function ApSession.UpdateSession(elapsed)
	if (ApSession.IsInAvA) then
		if (ApSession.SessionStartTime == 0) then 
			ApSession.SessionStartTime = elapsed
		end

		-- Calculate session time
		local sessionTime =  zo_round((elapsed - ApSession.SessionStartTime) / 1000)

		if (sessionTime > 0) then
			-- Calculate AP/H
			local aph = ApSession.SessionAP / (sessionTime * 0.000277778)
			
			-- Calculate K/D Ratio
			local kdRatio = 0
			
			if (ApSession.SessionKills > 0 and ApSession.SessionDeaths > 0) then
				kdRatio = ApSession.SessionKills / ApSession.SessionDeaths
			elseif (ApSession.SessionKills > 0) then
				kdRatio = ApSession.SessionKills
			end

			-- Generate Output to Labels
			local aphString = string.format("%.0f", aph)
			local ratioString = ApSession.SessionKills .. "/" .. 
								ApSession.SessionDeaths .. " - " .. 
								string.format("%.1f", kdRatio)
			
			local hours = math.floor(sessionTime / 3600) % 24
			local minutes = math.floor((sessionTime - hours * 3600) / 60) % 60
			local seconds = sessionTime % 60
			
			local sessionString = string.format("%02d", hours) .. ":" .. 
								  string.format("%02d", minutes) .. ":" .. 
								  string.format("%02d", seconds)
			
            if (ApSession.Settings.IsLongStyle) then
                ApSessionWindowLongValueApLabel:SetText(ApSession.SessionAP)
			    ApSessionWindowLongValueApHLabel:SetText(aphString)
			    ApSessionWindowLongValueKdRatioLabel:SetText(ratioString)
			    ApSessionWindowLongValueSessionLabel:SetText(sessionString)
            else
                ApSessionWindowValueApLabel:SetText(ApSession.SessionAP)
			    ApSessionWindowValueApHLabel:SetText(aphString)
			    ApSessionWindowValueKdRatioLabel:SetText(ratioString)
			    ApSessionWindowValueSessionLabel:SetText(sessionString)
            end
		end
	end
end

--[[
	UpdateMovable sets the Movable and MouseEnabled flag in UI elements
]]--
function ApSession.SetMovable()
    ApSessionWindow:SetMovable(ApSession.Settings.Movable)
	ApSessionWindow:SetMouseEnabled(ApSession.Settings.Movable)
    ApSessionWindowLong:SetMovable(ApSession.Settings.Movable)
	ApSessionWindowLong:SetMouseEnabled(ApSession.Settings.Movable)
end

--[[
	MakeSettingsWindow creates settings window
]]--
function ApSession.MakeSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Taos AP Session",
		author = "TProg Taonnor",
		version = MAJOR .. "." .. MINOR .. "." .. PATCH,
		slashCommand = "/taosapsession",
		registerForDefaults = true
	}

	local optionsData = {
		[1] = {
			type = "header",
			name = GetString(TAS_OPTIONS_HEADER),
		},
		[2] = {
			type = "checkbox",
			name = GetString(TAS_OPTIONS_DRAG_LABEL),
			tooltip = GetString(TAS_OPTIONS_DRAG_TOOLTIP),
			getFunc = function() return ApSession.Settings.Movable end,
			setFunc = function(value) 
				ApSession.Settings.Movable = value
                ApSession.SetMovable()
			end,
			default = ApSession.Default.Movable
		},
        [3] = {
			type = "checkbox",
			name = GetString(TAS_OPTIONS_LONG_STYLE_LABEL),
			tooltip = GetString(TAS_OPTIONS_LONG_STYLE_TOOLTIP),
			getFunc = function() return ApSession.Settings.IsLongStyle end,
			setFunc = function(value) 
				ApSession.Settings.IsLongStyle = value
				ApSession.UpdateZone() -- Set visibility
                ApSession.RestorePosition() -- Updates position
			end,
			default = ApSession.Default.IsLongStyle
		},
	}
	
	local LAM = LibStub("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("TaosApSessionSettings", panelData)
	LAM:RegisterOptionControls("TaosApSessionSettings", optionsData)
end

--[[
	RestorePosition sets ApSessionWindow on settings position
]]--
function ApSession.RestorePosition()
	ApSessionWindow:ClearAnchors()
	ApSessionWindow:SetAnchor(TOPLEFT, 
							  GuiRoot, 
							  TOPLEFT, 
							  ApSession.Settings.PosX, 
							  ApSession.Settings.PosY)

    ApSessionWindowLong:ClearAnchors()
	ApSessionWindowLong:SetAnchor(TOPLEFT, 
							      GuiRoot, 
							      TOPLEFT, 
							      ApSession.Settings.PosX, 
							      ApSession.Settings.PosY)
end

--[[
	OnApSessionWindowMoveStop saves current ApSessionWindow position to settings
]]--
function ApSession.OnApSessionWindowMoveStop()
	local left = ApSessionWindow:GetLeft()
	local top = ApSessionWindow:GetTop()

    if (ApSession.Settings.IsLongStyle) then
        left = ApSessionWindowLong:GetLeft()
	    top = ApSessionWindowLong:GetTop()
    end

	ApSession.Settings.PosX = left
	ApSession.Settings.PosY = top
end

--[[
	OnApSessionWindowButtonClicked resets the current session
]]--
function ApSession.OnApSessionWindowButtonClicked()
	ApSession.SessionAP = 0
	ApSession.SessionDeaths = 0
	ApSession.SessionKills = 0
	ApSession.SessionStartTime = 0
	
	-- Reset labels
	ApSessionWindowValueApLabel:SetText("0")
	ApSessionWindowValueApHLabel:SetText("0")
	ApSessionWindowValueKdRatioLabel:SetText("0/0 - 0.0")
	ApSessionWindowValueSessionLabel:SetText("00:00:00")

    ApSessionWindowLongValueApLabel:SetText("0")
	ApSessionWindowLongValueApHLabel:SetText("0")
	ApSessionWindowLongValueKdRatioLabel:SetText("0/0 - 0.0")
	ApSessionWindowLongValueSessionLabel:SetText("00:00:00")
end

--[[
	ApSession:initialize initializes addon
]]--
function ApSession:initialize()
	ApSession.Settings = ZO_SavedVars:NewAccountWide(ApSession.Name, 1 , nil, ApSession.Default)
		
	ApSession.MakeSettingsWindow()
	ApSession.RestorePosition()
	ApSession.UpdateZone()
    ApSession.SetMovable()
	
	-- Register events
	EVENT_MANAGER:RegisterForEvent(ApSession.Name, EVENT_ALLIANCE_POINT_UPDATE, ApSession.UpdateAP)
	EVENT_MANAGER:RegisterForEvent(ApSession.Name, EVENT_PLAYER_DEAD , ApSession.UpdateDeath)
	EVENT_MANAGER:RegisterForEvent(ApSession.Name, EVENT_COMBAT_EVENT, ApSession.UpdateKills)
	EVENT_MANAGER:RegisterForEvent(ApSession.Name, EVENT_PLAYER_ACTIVATED, ApSession.UpdateZone)
	
	-- Start timer
	EVENT_MANAGER:RegisterForUpdate(ApSession.Name, REFRESHRATE, ApSession.UpdateSession)
end

--[[
	OnAddOnLoaded if TaosApSession is loaded, initialize
]]--
local function OnAddOnLoaded(eventCode, addOnName)
	if addOnName == ApSession.Name then
		ApSession:initialize()
	end
end

EVENT_MANAGER:RegisterForEvent(ApSession.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded);