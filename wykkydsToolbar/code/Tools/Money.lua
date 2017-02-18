local _addon = WYK_Toolbar

_addon.Feature.Toolbar.GetMoney = function()
	local useCommas = _addon:GetOrDefault( true, _addon.Settings["gold_commas"])
	local useIcon = _addon:GetOrDefault( true, _addon.Settings["gold_icon"] )
	local useTitle = _addon:GetOrDefault( false, _addon.Settings["gold_title"])
	local val, c, title = GetCurrentMoney(), {1,1,.76,1}, ""
	if useCommas then val = _addon:comma_value(val) end
	if useTitle then 
		title = _addon._DefaultLabelColor .. "Gold:|r " 
	else
		if useIcon then
			local o = wykkydsToolbar.Tools[_addon.G.BAR_TOOL_GOLD].Control
			if o.Icon == nil then 
				o.Icon = _addon.Feature.Toolbar.MakeSpacerControl( o ); 
				o.Icon:SetTexture( "/esoui/art/guild/guildhistory_indexicon_guildstore_up.dds" ) 
			end
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
			local o = wykkydsToolbar.Tools[_addon.G.BAR_TOOL_GOLD].Control
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
	return title .. val, c
end