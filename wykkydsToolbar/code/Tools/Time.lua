local _addon = WYK_Toolbar

_addon.Feature.Toolbar.GetTime = function()
	local timeKind = _addon:GetOrDefault( "12 hour", _addon.Settings["clock_type"])
	local useTitle = _addon:GetOrDefault( false, _addon.Settings["clock_title"])
	local useAmPm = _addon:GetOrDefault( true, _addon.Settings["clock_suffix"])
	local retVal, val, c = "", GetTimeString(), {215/255,213/255,205/255,1}
	local hh, mm, ss = val:match("([^:]+):([^:]+):([^:]+)")
	local ampm, del = " am", "|cA0A0CF:|r"
	ss = "|cAAAAAA"..ss.."|r"
	
	if string.lower(timeKind) == "24 hour" then
		val = hh ..del.. mm ..del.. ss
		if useTitle then retVal = _addon._DefaultLabelColor .. "Time:|r " .. val
		else retVal = val end
	elseif string.lower(timeKind) == "12 hour" then
		if tonumber(hh) > 12 then hh = hh - 12; ampm = " pm"; end
		if tonumber(hh) == 12 then ampm = " pm"; end
		if tonumber(hh) == 0 then hh = 12; end
		if useAmPm then val = hh ..del.. mm ..del.. ss .. _addon._DefaultLabelColor..ampm.."|r"
		else val = hh ..del.. mm ..del.. ss end
		if useTitle then retVal = _addon._DefaultLabelColor .. "Time:|r " .. val
		else retVal = val end
	end
	
	return retVal, c
end