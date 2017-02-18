local _addon = WYK_Toolbar

_addon.Feature.Toolbar.GetSoulGems = function()
    local style = _addon:GetOrDefault( "Empty / Full", _addon.Settings["soulgem_setting"])
    local useIcon = _addon:GetOrDefault( true, _addon.Settings["soulgem_icon"] )
    local retVal, c = "", {215/255,213/255,205/255,1}
    local name, icon, icon2, stackCount = "", "", "", 0
    local myLevel = GetUnitEffectiveLevel("player")
    local emptyCount, fullCount = 0, 0
    name, icon, stackCount = GetSoulGemInfo(SOUL_GEM_TYPE_EMPTY, myLevel, true); emptyCount = stackCount;
    name, icon2, stackCount = GetSoulGemInfo(SOUL_GEM_TYPE_FILLED, myLevel, true); fullCount = stackCount;
    if style == "Empty / Full" then retVal = emptyCount .. " / ".. "|c00FF00"..fullCount.."|r"
    elseif style == "Empty" then retVal = emptyCount
    elseif style == "Full" then retVal = "|c00FF00"..fullCount.."|r" end
    if (icon2 ~= "" and icon2 ~= nil) and icon2 ~= "/esoui/art/icons/icon_missing.dds" then icon = icon2 end
    if useIcon then
        local o = wykkydsToolbar.Tools[_addon.G.BAR_TOOL_GEMS].Control
        if o.Icon == nil then o.Icon = _addon.Feature.Toolbar.MakeSpacerControl( o ); end
        o.Icon:SetTexture( icon )
        o.IconSize = 16
        o.BufferSize = 28
        if not o.UseIcon then
            o.Icon:SetDimensions( o.IconSize, o.IconSize )
            o.Icon:ClearAnchors()
            o.Icon:SetAnchor( RIGHT, o, LEFT, -8, 0 )
            o.Icon:SetHidden(false)
            local aBool, aPoint, aTarget, aTargetPoint, aX, aY = o:GetAnchor()
            o.PreviousAnchor = {aPoint, aTarget, aTargetPoint, aX, aY}
            o:ClearAnchors()
            o:SetAnchor( aPoint, aTarget, aTargetPoint, aX + o.BufferSize, aY )
        end
        o.UseIcon = true
    else
        local o = wykkydsToolbar.Tools[_addon.G.BAR_TOOL_GEMS].Control
        if o.UseIcon == true then
            o.Icon:SetDimensions( o.IconSize, o.IconSize )
            o.Icon:ClearAnchors()
            o.Icon:SetAnchor( RIGHT, o, LEFT, -8, 0 )
            o.Icon:SetHidden(true)
            if o.PreviousAnchor ~= nil then
                o:ClearAnchors()
                o:SetAnchor( o.PreviousAnchor[1], o.PreviousAnchor[2], o.PreviousAnchor[3], o.PreviousAnchor[4], o.PreviousAnchor[5] )
            end
            o.PreviousAnchor = nil
        end
        o.UseIcon = false
    end
    return retVal, c
end