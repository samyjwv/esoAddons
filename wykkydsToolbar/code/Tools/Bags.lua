local _addon = WYK_Toolbar

_addon.Feature.Toolbar.GetBagDetails = function()
	local bagSetting = _addon:GetOrDefault( "Used %", _addon.Settings["bag_setting"])
	local useIcon = _addon:GetOrDefault( true, _addon.Settings["bag_icon"] )
	local useTitle = _addon:GetOrDefault( false, _addon.Settings["bag_title"])
	local bagLow = tonumber(_addon:GetOrDefault( 10, _addon.Settings["bag_low"]))
	local bagMid = tonumber(_addon:GetOrDefault( 25, _addon.Settings["bag_mid"]))
	
	local c = {}
	
	local bagSize, bagUsed, bagFree = GetBagSize(1), GetNumBagUsedSlots(1), GetNumBagFreeSlots(1)
	
	c = {0,1,0,1}
	if tonumber(bagFree) <= bagMid then c = {1,1,0,1} end
	if tonumber(bagFree) <= bagLow then c = {1,0,0,1} end
	
	local retVal = ""
	
	if useTitle then 
		retVal = retVal .. _addon._DefaultLabelColor
		if bagSetting == "Used / Total" then retVal = retVal .. "Bags:|r " .. bagUsed .. "|cDFDDDE".." / " .. bagSize.."|r" end
		if bagSetting == "Used Space" then retVal = retVal .. "Used Space:|r " .. bagUsed end
		if bagSetting == "Used %" then retVal = retVal .. "Used Space:|r " .. _addon:Round((bagUsed / bagSize)*100, 0) .. "%" end
		if bagSetting == "Free Space" then retVal = retVal .. "Free Space:|r " .. bagFree .. " slots" end
		if bagSetting == "Free %" then retVal = retVal .. "Free Space:|r " .. _addon:Round((bagFree / bagSize)*100, 0) .. "%" end
	else
		if bagSetting == "Used / Total" then retVal = retVal .. bagUsed .. "|cDFDDDE".." / " .. bagSize.."|r" end
		if bagSetting == "Used Space" then retVal = retVal .. bagUsed end
		if bagSetting == "Used %" then retVal = retVal .. _addon:Round((bagUsed / bagSize)*100, 0) .. "%" end
		if bagSetting == "Free Space" then retVal = retVal .. bagFree .. " slots" end
		if bagSetting == "Free %" then retVal = retVal .. _addon:Round((bagFree / bagSize)*100, 0) .. "%" end
		if useIcon then
			local o = wykkydsToolbar.Tools[_addon.G.BAR_TOOL_BAGS].Control
			if o.Icon == nil then o.Icon = _addon.Feature.Toolbar.MakeSpacerControl( o ); o.Icon:SetTexture( "/esoui/art/mainmenu/menubar_inventory_up.dds" ) end
			o.IconSize = 24
			o.BufferSize = 28
			if not o.UseIcon then
				o.Icon:SetDimensions( o.IconSize, o.IconSize )
				o.Icon:ClearAnchors()
				o.Icon:SetAnchor( RIGHT, o, LEFT, -4, 0 )
				o.Icon:SetHidden(false)
				local aBool, aPoint, aTarget, aTargetPoint, aX, aY = o:GetAnchor()
				o.PreviousAnchor = {aPoint, aTarget, aTargetPoint, aX, aY}
				o:ClearAnchors()
				o:SetAnchor( aPoint, aTarget, aTargetPoint, aX + o.BufferSize, aY )
			end
			o.UseIcon = true
		else
			local o = wykkydsToolbar.Tools[_addon.G.BAR_TOOL_BAGS].Control
			if o.UseIcon == true then
				o.Icon:SetDimensions( o.IconSize, o.IconSize )
				o.Icon:ClearAnchors()
				o.Icon:SetAnchor( RIGHT, o, LEFT, -4, 0 )
				o.Icon:SetHidden(true)
				if o.PreviousAnchor ~= nil then
					o:ClearAnchors()
					o:SetAnchor( o.PreviousAnchor[1], o.PreviousAnchor[2], o.PreviousAnchor[3], o.PreviousAnchor[4], o.PreviousAnchor[5] )
				end
				o.PreviousAnchor = nil
			end
			o.UseIcon = false
		end
	end
	
	return retVal, c
end