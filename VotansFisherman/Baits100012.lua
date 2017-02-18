local data = {
	name = "VotansFisherman",
	eventId = "VotansFishermanBaits",
	BaitTypes =
	{
		-- Anywhere
		[42877] = { id = 0 },
		-- Foul Water
		[42871] = { id = 1 },
		[42873] = { id = 1 },
		-- Rivers
		[42872] = { id = 2 },
		[42874] = { id = 2 },
		-- Lakes
		[42870] = { id = 3 },
		[42876] = { id = 3 },
		-- Oceans
		[42875] = { id = 4 },
		[42869] = { id = 4 }
	},
	BaitNames = { }
}

local function GetBaitType(itemLink)
	local itemId = itemLink:match("|H[^:]+:item:([^:]+):")
	return data.BaitTypes[tonumber(itemId)]
end

local function AddBaitInfo(tooltip, bait)
	if bait then
		tooltip:AddVerticalPadding(20)
		tooltip:AddLine(GetString("SI_FISHERMAN_TOOLTIP", bait.id), "", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	end
end

local function TooltipHook(tooltipControl, method, linkFunc)
	local origMethod = tooltipControl[method]

	tooltipControl[method] = function(self, ...)
		origMethod(self, ...)
		AddBaitInfo(self, GetBaitType(linkFunc(...)))
	end
end

local mystyle = { fontSize = 34, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1, }
local function AddBaitInfo_Gamepad(tooltip, bait)
	if bait then
		tooltip:AddLine(GetString("SI_FISHERMAN_TOOLTIP", bait.id), mystyle, tooltip:GetStyle("bodySection"))
	end
end

local function TooltipHook_Gamepad(tooltipControl, method, linkFunc)
	local origMethod = tooltipControl[method]

	tooltipControl[method] = function(self, ...)
		local result = origMethod(self, ...)
		AddBaitInfo_Gamepad(self, GetBaitType(linkFunc(...)))
		return result
	end
end

local function ReturnItemLink(itemLink)
	return itemLink
end

local function HookBagTips()
	TooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
	TooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
	TooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
	TooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
	TooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
	TooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
	TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
	TooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
	TooltipHook(ItemTooltip, "SetLink", ReturnItemLink)

	TooltipHook(PopupTooltip, "SetLink", ReturnItemLink)

	TooltipHook_Gamepad(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "LayoutItem", ReturnItemLink)
	TooltipHook_Gamepad(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP), "LayoutItem", ReturnItemLink)
	TooltipHook_Gamepad(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP), "LayoutItem", ReturnItemLink)
end

local function HookQuickMenu(quickMenu)
	local orgFunc = quickMenu.menu.AddEntry
	quickMenu.menu.AddEntry = function(self, name, ...)
		local bait = data.BaitNames[name]
		if bait then
			return orgFunc(self, zo_strformat(SI_ZONE_DOOR_RETICLE_INSTANCE_TYPE_FORMAT, name, GetString("SI_FISHERMAN_QUICKMENU", bait.id)), ...)
		end
		return orgFunc(self, name, ...)
	end
end

local function CreateBaitNames()
	local itemLink
	local giln = GetItemLinkName
	local format = zo_strformat
	for id in pairs(data.BaitTypes) do
		-- get localized name
		itemLink = string.format("|H0:item:%i:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|htemp|h", id)
		data.BaitNames[format(SI_TOOLTIP_ITEM_NAME, giln(itemLink))] = data.BaitTypes[id]
	end
end

local function OnAddOnLoaded(event, addonName)
	if addonName == data.name then
		EVENT_MANAGER:UnregisterForEvent(data.eventId, EVENT_ADD_ON_LOADED)
		CreateBaitNames()
		HookBagTips()
		HookQuickMenu(FISHING_KEYBOARD)
		HookQuickMenu(FISHING_GAMEPAD)
	end
end

EVENT_MANAGER:RegisterForEvent(data.eventId, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
