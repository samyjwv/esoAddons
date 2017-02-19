--[[
-------------------------------------------------------------------------------
-- PersonnalAssistant, by Ayantir
-------------------------------------------------------------------------------
This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at : 
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
]]

local ADDON_NAME = "PersonnalAssistant"

local function CreateBindings()
	
	local assistants = {
		[267] = true,
		[300] = true,
		[301] = true,
		[396] = true,
		[397] = true,
	}
	
	for assistantIndex in pairs(assistants) do
	
		local assistantName, _, _, _, unlocked = GetCollectibleInfo(assistantIndex)
		
		if unlocked then
			ZO_CreateStringId("SI_BINDING_NAME_PERSONNALASSISTANT_" .. assistantIndex, zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, assistantName))
		end
		
	end

end

local function onAddonLoaded(event, addonName)

	if addonName == ADDON_NAME then
	
		CreateBindings()
		
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COLLECTION_UPDATED, CreateBindings)
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	
	end
	
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, onAddonLoaded)