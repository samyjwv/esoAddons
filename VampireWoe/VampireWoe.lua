-------------------------------------------------------------------------------
-- Vampire's Woe
-------------------------------------------------------------------------------
--[[
-- Copyright (c) 2017 James A. Keene (Phinix) All rights reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation (the "Software"),
-- to operate the Software for personal use only. Permission is NOT granted
-- to modify, merge, publish, distribute, sublicense, re-upload, and/or sell
-- copies of the Software. Additionally, licensed use of the Software
-- will be subject to the following:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-------------------------------------------------------------------------------
--
-- DISCLAIMER:
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and/or other countries. All rights reserved.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--]]

local VWoe = _G['VWoeAddon']
VWoe.Name = "VampireWoe"
VWoe.Author = "Phinix"
VWoe.Version = "1.03a"

local AccountDefaults = { sSynergy = true, sBiteAlly = true, sDebug = true }

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Synergy hook
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function HookSynergy()
	ZO_PreHook(SYNERGY, "OnSynergyAbilityChanged",
	function(self)
		local synergyName, iconFilename = GetSynergyInfo()
		if (VWoe.ASV.sSynergy) then
			if iconFilename and iconFilename:find("ability_vampire_002") then
				if (not IsUnitPlayer('reticleover')) or ((IsUnitPlayer('reticleover')) and (not VWoe.ASV.sBiteAlly)) then
					SHARED_INFORMATION_AREA:SetHidden(self, true)
					return true
				end
			end
		end
	end)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Keybind functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
function VWoe.Swap()
	if (VWoe.ASV.sSynergy) then
		VWoe.ASV.sSynergy = false
		if (VWoe.ASV.sDebug) then d("Vampire feeding synergy is no longer supressed.") end
	elseif (not VWoe.ASV.sSynergy) then
		VWoe.ASV.sSynergy = true
		if (VWoe.ASV.sDebug) then d("Vampire feeding synergy is being supressed.") end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Set up the Addon Settings options panel
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateSettingsWindow(addonName)
	local panelData = {
		type					= "panel",
		name					= "Vampire's Woe",
		displayName				= "Vampire's Woe",
		author					= VWoe.Author,
		version					= VWoe.Version,
		registerForRefresh		= true,
		registerForDefaults		= true
	}

	local optionsData = {
	{
		type			= "description",
		text			= "Block the Vampire Feeding synergy from triggering."
	},
	{
		type			= "checkbox",
		name			= "Suppress Vampire Feeding Synergy",
		tooltip			= "Block the Vampire Feeding synergy from triggering.",
		getFunc			= function() return VWoe.ASV.sSynergy end,
		setFunc			= function(value) VWoe.ASV.sSynergy = value end,
		default			= AccountDefaults.sSynergy
	},
	{
		type			= "checkbox",
		name			= "Bite Ally When Suppressed",
		tooltip			= "Allows you to bite and pass vampirism to an ally even when the feeding synergy is suppressed.",
		getFunc			= function() return VWoe.ASV.sBiteAlly end,
		setFunc			= function(value) VWoe.ASV.sBiteAlly = value end,
		default			= AccountDefaults.sBiteAlly
	},
	{
		type			= "checkbox",
		name			= "Display Toggle Message",
		tooltip			= "Show a chat notice when vampire feeding is toggled on or off using the keybind.",
		getFunc			= function() return VWoe.ASV.sDebug end,
		setFunc			= function(value) VWoe.ASV.sDebug = value end,
		default			= AccountDefaults.sDebug
	}
	}

	local LAM = LibStub("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("VWoe_Panel", panelData)
	LAM:RegisterOptionControls("VWoe_Panel", optionsData)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Init
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function OnAddonLoaded(event, addonName)
	if addonName ~= VWoe.Name then return end
	EVENT_MANAGER:UnregisterForEvent(VWoe.Name, EVENT_ADD_ON_LOADED)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_SUPPRESSION", "Toggle Feeding Suppression")
	VWoe.ASV = ZO_SavedVars:NewAccountWide(VWoe.Name, 1.0, 'AccountSettings', AccountDefaults)
	CreateSettingsWindow(addonName)
	HookSynergy()
end

EVENT_MANAGER:RegisterForEvent(VWoe.Name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
