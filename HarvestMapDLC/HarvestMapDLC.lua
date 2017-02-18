HarvestDLC = {}
HarvestDLC.dataVersion = 15
HarvestDLC.dataDefault = {
	data = {},
	dataVersion = HarvestDLC.dataVersion
}

HarvestDLC.zones = {
	--imperialcity, part of cyrodiil
	["wrothgar"] = true,
	["thievesguild"] = true,
	["darkbrotherhood"] = true,
	--dungeonthingy, does that one even have a prefix?
}

function HarvestDLC.GetCurrentTimestamp()
	-- data is saved as string, to prevent the save file from bloating up, reduce the stamp to hours
	return zo_floor(GetTimeStamp() / 3600)
end

function HarvestDLC.OnLoad(eventCode, addOnName)
	if addOnName ~= "HarvestMapDLC" then
		return
	end

	HarvestDLC.savedVars = ZO_SavedVars:NewAccountWide("HarvestDLC_SavedVars", 1, "nodes", HarvestDLC.dataDefault)
	if not HarvestDLC.savedVars.firstLoaded then
		HarvestDLC.savedVars.firstLoaded = HarvestDLC.GetCurrentTimestamp()
	end
	HarvestDLC.savedVars.lastLoaded = HarvestDLC.GetCurrentTimestamp()
end

EVENT_MANAGER:RegisterForEvent("HarvestMap-DLC-Zones", EVENT_ADD_ON_LOADED, HarvestDLC.OnLoad)
