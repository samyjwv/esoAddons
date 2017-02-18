local _addon = WYK_Toolbar

_addon.Feature.Toolbar.GetAP = function()
	local useCommas = _addon:GetOrDefault( true, _addon.Settings["ap_commas"] )
	local useIcon = _addon:GetOrDefault( true, _addon.Settings["ap_icon"] )
	local useTitle = _addon:GetOrDefault( false, _addon.Settings["ap_title"] )
	local val, c, title = GetAlliancePoints(), {.65,1,.76,1}, ""
	if useCommas then val = _addon:comma_value(val) end
	if useTitle then 
		title = _addon._DefaultLabelColor .. "AP:|r " 
	else
		if useIcon then
			local o = wykkydsToolbar.Tools[_addon.G.BAR_TOOL_AP].Control
			if o.Icon == nil then 
				o.Icon = _addon.Feature.Toolbar.MakeSpacerControl( o ); 
				o.Icon:SetTexture( GetAvARankIcon( GetUnitAvARank( "player" ) ) ) 
			end
			o.IconSize = 24
			o.BufferSize = 28
			if not o.UseIcon then
				o.Icon:SetDimensions( o.IconSize, o.IconSize )
				o.Icon:ClearAnchors()
				o.Icon:SetAnchor( RIGHT, o, LEFT, -2, 0 )
				o.Icon:SetHidden(false)
				local aBool, aPoint, aTarget, aTargetPoint, aX, aY = o:GetAnchor()
				o.PreviousAnchor = {aPoint, aTarget, aTargetPoint, aX, aY}
				o:ClearAnchors()
				o:SetAnchor( aPoint, aTarget, aTargetPoint, aX + o.BufferSize, aY )
			end
			o.UseIcon = true
		else
			local o = wykkydsToolbar.Tools[_addon.G.BAR_TOOL_AP].Control
			if o.UseIcon == true then
				o.Icon:SetDimensions( o.IconSize, o.IconSize )
				o.Icon:ClearAnchors()
				o.Icon:SetAnchor( RIGHT, o, LEFT, -2, 0 )
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
	return title .. val, c
end