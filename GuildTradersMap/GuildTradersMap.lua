-- GuildTradersMap addon by Sammy

-- local variables
local WM = GetWindowManager()
local EM = GetEventManager()
local _

-- create a namespace
if GTM == nil then GTM = {} end

-- The AddOn name
GTM.name = 'GuildTradersMap'
GTM.version = '0.0.1'
GTM.settings = {}
GTM.settingsVersion = '1'

-- default values for saved variables
GTM.defaults = {
  unitList = {}
}

--
-- Initialize
--
function GTM:Initialize(event, addon)
  -- check addon name
  if addon ~= GTM.name then return end

  -- remove register onload
  EM:UnregisterForEvent("GMTInitialize", EVENT_ADD_ON_LOADED)

  -- load saved variables
  GTM.settings = ZO_SavedVars:NewAccountWide(GTM.name .. "Settings", GTM.settingsVersion, nil, GTM.defaults)

  -- Override PriceTracker:OnUpdateTooltip
  GTM:OverrideOnUpdateTooltip();

  -- add Commands
  GTM:AddCommands()

  -- events
  EM:RegisterForEvent(GTM.name .. "OpenTradingHouse", EVENT_OPEN_TRADING_HOUSE, function(...) GTM:OpenTradingHouseHandler(...) end)

  --  Zos Hooks
  ZO_PreHook("ZO_InventorySlot_ShowContextMenu", function(...) GTM:ShowContectMenuHook() end)
end

function GTM:ShowContectMenuHook()
  local item = moc()
  local parent = item:GetParent()
  if not parent then return nil end
  local parentName = parent:GetName()

  if(parentName == "ZO_TradingHouseItemPaneSearchResultsContents") then
    local itemLink = GTM:GetItemLink(item)
    zo_callLater(function()
      AddCustomMenuItem("|cD32F2FClear Low Price", function() GTM:ClearItemLowPrice(itemLink) end)
      ShowMenu()
    end, 10)
  end
end

function GTM:ClearItemLowPrice(itemLink)

  local _, _, _, itemId = ZO_LinkHandler_ParseLink(itemLink)
  local level = PriceTracker:GetItemLevel(itemLink)
  local quality = GetItemLinkQuality(itemLink)

  local matches = PriceTracker:GetMatches(itemId, level, quality)
  if not matches then ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, 'Nothing to clean') return end

  local minItem = PriceTracker.mathUtils:Min(matches)

  local list = PriceTracker.settings.itemList[itemId];
  local listItem = list[level];
  for expiry, item in pairs(listItem) do
    if minItem.guildName == item.guildName and minItem.purchasePrice == item.purchasePrice then
      listItem[expiry] = nil
      ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.MESSAGE_BROADCAST, 'Low price cleaned')
      break
    end
  end
end

function GTM:GetItemLink(item)

  if item.bagId and item.slotIndex then
    return GetItemLink(item.bagId, item.slotIndex, LINK_STYLE_DEFAULT)
  end

  if item.dataEntry and item.dataEntry.data and item.dataEntry.data.bagId and item.dataEntry.data.slotIndex then
    return GetItemLink(item.bagId, item.slotIndex, LINK_STYLE_DEFAULT)
  end

  if item.dataEntry and item.dataEntry.data and item.dataEntry.data.slotIndex then
    return GetTradingHouseSearchResultItemLink(item.dataEntry.data.slotIndex, LINK_STYLE_DEFAULT)
  end

  return nil
end

--
-- Override function from PriceTracker Addon (PriceTracker:OnUpdateTooltip)
--
function GTM:OverrideOnUpdateTooltip()
  function PriceTracker:OnUpdateTooltip(item, tooltip)
    if not tooltip then tooltip = ItemTooltip end
    if not item or not item.dataEntry or not item.dataEntry.data or not self.menu:IsKeyPressed() or self.selectedItem[tooltip] == item then return end
    self.selectedItem[tooltip] = item
    local stackCount = item.dataEntry.data.stackCount or item.dataEntry.data.stack or item.dataEntry.data.count
    if not stackCount then return end

    local itemLink = self:GetItemLink(item)
    local _, _, _, itemId = ZO_LinkHandler_ParseLink(itemLink)
    local level = self:GetItemLevel(itemLink)
    local quality = GetItemLinkQuality(itemLink)

    if not itemLink then
      if item.dataEntry and item.dataEntry.data and item.dataEntry.data.itemId then
        itemId = item.dataEntry.data.itemId
        level = tonumber(item.dataEntry.data.level)
        quality = item.dataEntry.data.quality
      else
        return
      end
    end

    local matches = self:GetMatches(itemId, level, quality)
    if not matches then return end

    local item = self:SuggestPrice(matches)
    if not item then return end

    local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
    local function AddValuePair(leftText, rightText)
      tooltip:AddLine(leftText, "ZoFontGame", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
      tooltip:AddVerticalPadding(-32)
      tooltip:AddLine(rightText, "ZoFontGame", r, g, b, RIGHT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_RIGHT, true)
    end

    tooltip:AddVerticalPadding(15)
    ZO_Tooltip_AddDivider(tooltip)
    tooltip:AddLine("Price Tracker", "ZoFontHeader2")
    AddValuePair("Suggested price:", ("|cFFFFFF%d|r |t16:16:EsoUI/Art/currency/currency_gold.dds|t"):format(zo_round(item.purchasePrice / item.stackCount)))
    if stackCount > 1 then
      tooltip:AddVerticalPadding(-6)
      AddValuePair("Stack price:", ("|cFFFFFF%d|r |t16:16:EsoUI/Art/currency/currency_gold.dds|t"):format(zo_round(item.purchasePrice / item.stackCount * stackCount)))
    end
    if self.settings.showMinMax then
      local minItem = self.mathUtils:Min(matches)
      local maxItem = self.mathUtils:Max(matches)
      local minPrice = zo_round(minItem.purchasePrice / minItem.stackCount)
      local maxPrice = zo_round(maxItem.purchasePrice / maxItem.stackCount)
      local minGuild = minItem.guildName and zo_strjoin(nil, "   (", zo_strtrim(("%-12.12s"):format(minItem.guildName)), ")") or ""
      local maxGuild = maxItem.guildName and zo_strjoin(nil, "  (", zo_strtrim(("%-12.12s"):format(maxItem.guildName)), ")") or ""
      tooltip:AddVerticalPadding(-6)
      AddValuePair("Min (each / stack):" .. minGuild, ("|cFFFFFF%d|r / |cFFFFFF%d|r |t16:16:EsoUI/Art/currency/currency_gold.dds|t"):format(minPrice, minPrice * stackCount))
      GTM:AddGuildInformation(tooltip, minItem.guildName)
      tooltip:AddVerticalPadding(-6)
      AddValuePair("Max (each / stack):" .. maxGuild, ("|cFFFFFF%d|r / |cFFFFFF%d|r |t16:16:EsoUI/Art/currency/currency_gold.dds|t"):format(maxPrice, maxPrice * stackCount))
      GTM:AddGuildInformation(tooltip, maxItem.guildName)
    end
    if self.settings.showSeen then
      tooltip:AddLine("Seen " .. #matches .. " times", "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, false)
    end
  end
end

--
-- AddGuildInformation
--
local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
function GTM:AddGuildInformation(tooltip, nameGuild)
  local result = GTM:Find(nameGuild:lower())
  if not result then return end;
  local text = zo_strtrim(("%-47.47s"):format((('%s %s - %s (%s)'):format(result.mapName, result.zoneName, result.guildName, result.unitName))))
  tooltip:AddVerticalPadding(-6)
  tooltip:AddLine(('|cCFD8DC%s'):format(text), "ZoFontGame", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
end

--
-- add commands
--
function GTM:AddCommands()
  SLASH_COMMANDS["/gtm"] = function(...) GTM:CommandHandler(...) end
end

-- Handle slash commands
function GTM:CommandHandler(text)
  text = text:lower()

  -- no input or help
  if #text == 0 or text == "help" then
    GTM:CommandHelp()
    return
  end

  -- debug
  if text == "debug" then
    d(GTM.settings.unitList)
    return
  end

  -- list
  if text == "list" then
    GTM:CommandList()
    return
  end

  -- find
  if text:find("^find") then
    local query = select(3, text:find("^find (.+)"))
    GTM:CommandFind(query)
    return
  end

end

--
-- OpenTradingHouse Handler
--
function GTM:OpenTradingHouseHandler(event, unit)
  local unitName = GetUnitName("interact")
  local guildName = select(2, GetCurrentTradingHouseGuildDetails())
  local mapName = GetMapName()
  local zoneName = GetZoneNameByIndex(GetCurrentMapZoneIndex())

  GTM:AddGuild(unitName, guildName, mapName, zoneName)
end

--
-- Add Guild Trader
--
function GTM:AddGuild(unitName, guildName, mapName, zoneName)
  GTM.settings.unitList[guildName:lower()] = {
    unitName = unitName,
    guildName = guildName,
    mapName = mapName,
    zoneName = zoneName
  }
end

--
-- find by name Guild Trader
--
function GTM:Find(name)
  name = name:lower()
  if not GTM.settings.unitList or not GTM.settings.unitList[name] then
    return nil
  else
    return GTM.settings.unitList[name:lower()]
  end
end

--
-- Command Help
--
function GTM:CommandHelp()
  d("Help")
  d(" ")
  d("/gtm help - Show help")
  d("/gtm list")
  d("/gtm find <query> - Look for <query>")
  d("/gtm reset - Remove all Guild Traders")
end

--
-- Command List
--
function GTM:CommandList()
  d('Guild Traders:')
  for i, row in pairs(GTM.settings.unitList) do
    d( ('|c00B5FF%s (%s) |cE68983%s (%s)'):format(row.unitName, row.guildName, row.mapName, row.zoneName) )
  end
end

--
-- Command Find
--
function GTM:CommandFind(query)
  local result = GTM:Find(query:lower())
  if(result) then
    d( ('|c00B5FF%s (%s) |cE68983%s (%s)'):format(result.unitName, result.guildName, result.mapName, result.zoneName) )
  else
    d( ('|cD92E2ENot found'))
  end
end

--
-- Command Reset
--
function GTM:CommandReset()
  GTM.settings.unitList = {}
end

-- register addon loaded
EM:RegisterForEvent(GTM.name, EVENT_ADD_ON_LOADED, function(...) GTM:Initialize(...) end)
