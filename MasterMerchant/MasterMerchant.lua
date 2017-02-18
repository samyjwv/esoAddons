-- MasterMerchant Main Addon File
-- Last Updated September 15, 2014
-- Written July 2014 by Dan Stone (@khaibit) - dankitymao@gmail.com
-- Extended Feb 2015 - Oct 2016 by (@Philgo68) - Philgo68@gmail.com
-- Released under terms in license accompanying this file.
-- Distribution without license is prohibited!

local OriginalGetTradingHouseSearchResultItemInfo
local OriginalGetTradingHouseListingItemInfo
local OriginalSetupPendingPost
local Original_ZO_LinkHandler_OnLinkMouseUp
local Original_ZO_InventorySlot_OnSlotClicked
g_slotActions = nil

local ITEMS = 'full'
local GUILDS = 'half'
local LISTINGS = 'listings'

function MasterMerchant:setupGuildColors()
  local nextGuild = 0
  while nextGuild < GetNumGuilds() do
    nextGuild = nextGuild + 1
    local nextGuildID = GetGuildId(nextGuild)
    local nextGuildName = GetGuildName(nextGuildID)
    local r, g, b = GetChatCategoryColor(CHAT_CHANNEL_GUILD_1 - 3 + nextGuild)
    self.guildColor[nextGuildName] = {r, g, b};
  end
end

function MasterMerchant:TimeCheck()
    -- setup focus info
    local range = self:ActiveSettings().defaultDays
    if IsControlKeyDown() and IsShiftKeyDown() then
      range = self:ActiveSettings().ctrlShiftDays 
    elseif IsControlKeyDown() then
      range = self:ActiveSettings().ctrlDays 
    elseif IsShiftKeyDown() then
      range = self:ActiveSettings().shiftDays 
    end

    local daysRange = 10000
    if range == GetString(MM_RANGE_NONE) then return -1, -1 end
    if range == GetString(MM_RANGE_FOCUS1) then daysRange = self:ActiveSettings().focus1 end
    if range == GetString(MM_RANGE_FOCUS2) then daysRange = self:ActiveSettings().focus2 end

    return GetTimeStamp() - (86400 * daysRange), daysRange
end

-- Computes the weighted moving average across available data
function MasterMerchant:toolTipStats(itemID, itemIndex, skipDots, goBack, clickable)
  local returnData = {['avgPrice'] = nil, ['numSales'] = nil, ['numDays'] = 10000, ['numItems'] = nil}

  -- make sure we have a list of sales to work with
  if self.salesData[itemID] and self.salesData[itemID][itemIndex] and self.salesData[itemID][itemIndex]['sales'] and #self.salesData[itemID][itemIndex]['sales'] > 0 then
    
    local list = self.salesData[itemID][itemIndex]['sales']
    
    local lowerBlacklist = self:ActiveSettings().blacklist and self:ActiveSettings().blacklist:lower() or ""

    local timeCheck, daysRange = self:TimeCheck()

    if timeCheck == -1 then return returnData end

    -- setup some initial values
    local initMean = 0
    local initCount = 0
    local oldestTime = nil
    local newestTime = nil
    local lowPrice = nil
    local highPrice = nil
    local daysHistory = 0
    for _, item in ipairs(list) do
      if (item.timestamp > timeCheck) and 
      (not zo_plainstrfind(lowerBlacklist, item.buyer:lower())) and 
      (not zo_plainstrfind(lowerBlacklist, item.seller:lower())) and 
      (not zo_plainstrfind(lowerBlacklist, item.guild:lower())) then
        if oldestTime == nil or oldestTime > item.timestamp then oldestTime = item.timestamp end
        if newestTime == nil or newestTime < item.timestamp then newestTime = item.timestamp end
        initMean = initMean + item.price
        initCount = initCount + item.quant
      end
    end

    if (initCount == 0 and goBack) then 
      daysRange = 10000
      timeCheck = GetTimeStamp() - (86400 * daysRange)
      initMean = 0
      initCount = 0
      oldestTime = nil
      newestTime = nil
      lowPrice = nil
      highPrice = nil
      daysHistory = 0
      for _, item in ipairs(list) do
        if (not zo_plainstrfind(lowerBlacklist, item.buyer:lower())) and 
        (not zo_plainstrfind(lowerBlacklist, item.seller:lower())) and 
        (not zo_plainstrfind(lowerBlacklist, item.guild:lower())) then
          if oldestTime == nil or oldestTime > item.timestamp then oldestTime = item.timestamp end
          if newestTime == nil or newestTime < item.timestamp then newestTime = item.timestamp end
          initMean = initMean + item.price
          initCount = initCount + item.quant
        end
      end
    end

    if initCount == 0 then 
      returnData = {['avgPrice'] = nil, ['numSales'] = nil, ['numDays'] = daysRange, ['numItems'] = nil}
      return returnData
    end

    if (daysRange == 10000) then
      daysHistory = math.floor((GetTimeStamp() - oldestTime) / 86400.0) + 1
    else
      daysHistory = daysRange
    end

    initMean = initMean / initCount

    -- calc standard deviation
    local standardDeviation = 0
    local sampleCount = 0
    for _, item in ipairs(list) do
      if (item.timestamp > timeCheck) and 
      (not zo_plainstrfind(lowerBlacklist, item.buyer:lower())) and 
      (not zo_plainstrfind(lowerBlacklist, item.seller:lower())) and 
      (not zo_plainstrfind(lowerBlacklist, item.guild:lower())) then
        sampleCount = sampleCount+item.quant
        standardDeviation = standardDeviation + ((((item.price / item.quant) - initMean) ^ 2) * item.quant)
      end
    end
    standardDeviation = math.sqrt(standardDeviation / sampleCount)

    local timeInterval = newestTime - oldestTime
    local avgPrice = 0
    local countSold = 0
    local weigtedCountSold = 0
    local legitSales = 0
    local salesPoints = {}
    -- If all sales data covers less than a day, we'll just do a plain average, nothing to weight
    if timeInterval < 86400 then
      for _, item in ipairs(list) do
        if (item.timestamp > timeCheck) and 
          (not zo_plainstrfind(lowerBlacklist, item.buyer:lower())) and 
          (not zo_plainstrfind(lowerBlacklist, item.seller:lower())) and 
          (not zo_plainstrfind(lowerBlacklist, item.guild:lower())) and 
          ((not self:ActiveSettings().trimOutliers) or math.abs((item.price/item.quant) - initMean) <= (3 * standardDeviation)) then
          avgPrice = avgPrice + item.price
          countSold = countSold + item.quant
          legitSales = legitSales + 1
          if lowPrice == nil or lowPrice > item.price/item.quant then lowPrice = item.price/item.quant end
          if highPrice == nil or highPrice < item.price/item.quant then highPrice = item.price/item.quant end
          if not skipDots then 
            local tooltip = nil
            if clickable then
              local stringPrice = '';
              if self:ActiveSettings().trimDecimals then
                stringPrice = string.format('%.0f', item.price/item.quant)
              else
                stringPrice = string.format('%.2f', item.price/item.quant)
              end
              stringPrice = self.LocalizedNumber(stringPrice)
              if item.quant == 1 then 
                tooltip = 
                  string.format( GetString(MM_GRAPH_TIP_SINGLE), item.guild, item.seller, zo_strformat('<<t:1>>', GetItemLinkName(item.itemLink)), item.buyer, stringPrice)
              else
                tooltip = 
                  string.format( GetString(MM_GRAPH_TIP), item.guild, item.seller, zo_strformat('<<t:1>>', GetItemLinkName(item.itemLink)), item.quant, item.buyer, stringPrice)
              end
            end
            table.insert(salesPoints, {item.timestamp, item.price/item.quant, self.guildColor[item.guild], tooltip}) 
          end
        end
      end
      avgPrice = avgPrice / countSold
      returnData = {['avgPrice'] = avgPrice, ['numSales'] = legitSales, ['numDays']= daysHistory, ['numItems'] = countSold,
                    ['graphInfo'] = {['oldestTime'] = oldestTime, ['low'] = lowPrice, ['high'] = highPrice, ['points'] = salesPoints}}
    -- For a weighted average, the latest data gets a weighting of X, where X is the number of
    -- days the data covers, thus making newest data worth more.
    else
      local dayInterval = math.floor((GetTimeStamp() - oldestTime) / 86400.0) + 1
      for _, item in ipairs(list) do
        if (item.timestamp > timeCheck) and 
          (not zo_plainstrfind(lowerBlacklist, item.buyer:lower())) and 
          (not zo_plainstrfind(lowerBlacklist, item.seller:lower())) and 
          (not zo_plainstrfind(lowerBlacklist, item.guild:lower())) and 
          ((not self:ActiveSettings().trimOutliers) or math.abs((item.price/item.quant) - initMean) <= (3 * standardDeviation)) then
          local weightValue = dayInterval - math.floor((GetTimeStamp() - item.timestamp) / 86400.0)
          avgPrice = avgPrice + (item.price * weightValue)
          countSold = countSold + item.quant
          weigtedCountSold = weigtedCountSold + (item.quant * weightValue)
          legitSales = legitSales + 1
          if lowPrice == nil or lowPrice > item.price/item.quant then lowPrice = item.price/item.quant end
          if highPrice == nil or highPrice < item.price/item.quant then highPrice = item.price/item.quant end
          if not skipDots then 
            local tooltip = nil
            if clickable then
              local stringPrice = '';
              if self:ActiveSettings().trimDecimals then
                stringPrice = string.format('%.0f', item.price/item.quant)
              else
                stringPrice = string.format('%.2f', item.price/item.quant)
              end
              stringPrice = self.LocalizedNumber(stringPrice)
              if item.quant == 1 then 
                tooltip = 
                  string.format( GetString(MM_GRAPH_TIP_SINGLE), item.guild, item.seller, zo_strformat('<<t:1>>', GetItemLinkName(item.itemLink)),  item.buyer, stringPrice)
              else
                tooltip = 
                  string.format( GetString(MM_GRAPH_TIP), item.guild, item.seller, zo_strformat('<<t:1>>', GetItemLinkName(item.itemLink)), item.quant, item.buyer, stringPrice)
              end
            end
            table.insert(salesPoints, {item.timestamp, item.price/item.quant, self.guildColor[item.guild], tooltip}) 
          end
        end
      end
      avgPrice = avgPrice / weigtedCountSold
      returnData = {['avgPrice'] = avgPrice, ['numSales'] = legitSales, ['numDays'] = daysHistory, ['numItems'] = countSold,
                    ['graphInfo'] = {['oldestTime'] = oldestTime, ['low'] = lowPrice, ['high'] = highPrice, ['points'] = salesPoints}}
    end
  end
  return returnData
end

function MasterMerchant:itemStats(itemLink, clickable)
  local itemID = tonumber(string.match(itemLink, '|H.-:item:(.-):'))
  local itemIndex = MasterMerchant.makeIndexFromLink(itemLink)
  return MasterMerchant:toolTipStats(itemID, itemIndex, nil, nil, clickable)
end

function MasterMerchant:itemHasSales(itemLink)
  local itemID = tonumber(string.match(itemLink, '|H.-:item:(.-):'))
  local itemIndex = MasterMerchant.makeIndexFromLink(itemLink)
  return self.salesData[itemID] and self.salesData[itemID][itemIndex] and self.salesData[itemID][itemIndex]['sales'] and #self.salesData[itemID][itemIndex]['sales'] > 0
end

function MasterMerchant:itemPriceTip(itemLink, chatText, clickable)

  local tipStats = MasterMerchant:itemStats(itemLink, clickable)
  if tipStats.avgPrice then

    local tipFormat
    if tipStats['numDays'] < 2 then
      tipFormat = GetString(MM_TIP_FORMAT_SINGLE)
    else 
      tipFormat = GetString(MM_TIP_FORMAT_MULTI)
    end
    local avePriceString = '';
    if self:ActiveSettings().trimDecimals then
      avePriceString = string.format('%.0f', tipStats['avgPrice'])
      --tipFormat = string.gsub(tipFormat, '.2f', '.0f')
    else
      avePriceString = string.format('%.2f', tipStats['avgPrice'])
    end
    avePriceString = self.LocalizedNumber(avePriceString)
    tipFormat = string.gsub(tipFormat, '.2f', 's')
    tipFormat = string.gsub(tipFormat, 'M.M.', 'MM')

    if not chatText then tipFormat = tipFormat .. '|t16:16:EsoUI/Art/currency/currency_gold.dds|t' end 
    local salesString = zo_strformat(GetString(SK_PRICETIP_SALES), tipStats['numSales'])
    if tipStats['numSales'] ~= tipStats['numItems'] then
      salesString = salesString .. zo_strformat(GetString(MM_PRICETIP_ITEMS), tipStats['numItems'])
    end
    return string.format(tipFormat, salesString, tipStats['numDays'], avePriceString), tipStats['avgPrice'], tipStats['graphInfo']
    --return string.format(tipFormat, zo_strformat(GetString(SK_PRICETIP_SALES), tipStats['numSales']), tipStats['numDays'], tipStats['avgPrice']), tipStats['avgPrice'], tipStats['graphInfo']
  else
    return nil, tipStats['numDays'], nil
  end
end


-- Copyright (c) 2014 Matthew Miller (Mattmillus)
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use,
-- copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following
-- conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.

function MasterMerchant:onItemActionLinkStatsLink(itemLink)
  local tipLine, days = MasterMerchant:itemPriceTip(itemLink, true)
  if not tipLine then 
    if days == 10000 then
      tipLine = GetString(MM_TIP_FORMAT_NONE) 
    else
      tipLine = string.format(GetString(MM_TIP_FORMAT_NONE_RANGE), days) 
    end
  end
  if tipLine then
    tipLine = string.gsub(tipLine, 'M.M.', 'MM')
    local ChatEditControl = CHAT_SYSTEM.textEntry.editControl
    if (not ChatEditControl:HasFocus()) then StartChatInput() end
    local itemText = string.gsub(itemLink, '|H0', '|H1')
    ChatEditControl:InsertText(MasterMerchant.concat(tipLine, GetString(MM_TIP_FOR), itemText))
  end  
end

function MasterMerchant:onItemActionPopupInfoLink(itemLink)
  ZO_PopupTooltip_SetLink(itemLink)
end

function MasterMerchant:myZO_LinkHandler_OnLinkMouseUp(link, button, control)
    if (type(link) == 'string' and #link > 0) then
		local handled = LINK_HANDLER:FireCallbacks(LINK_HANDLER.LINK_MOUSE_UP_EVENT, link, button, ZO_LinkHandler_ParseLink(link))
		if (not handled) then
            Original_ZO_LinkHandler_OnLinkMouseUp(link, button, control)
            if (button == 2 and link ~= '') then				
              --AddMenuItem(GetString(MM_POPUP_ITEM_DATA), function() self:onItemActionPopupInfoLink(link) end)
              AddMenuItem(GetString(MM_STATS_TO_CHAT), function() self:onItemActionLinkStatsLink(link) end)
              ShowMenu(control)
            end
        end
    end
end

function MasterMerchant:my_NameHandler_OnLinkMouseUp(player, button, control)
  if (type(player) == 'string' and #player > 0) then
    if (button == 2 and player ~= '') then
      ClearMenu()
      AddMenuItem(GetString(SI_SOCIAL_LIST_SEND_MESSAGE), function() StartChatInput(nil, CHAT_CHANNEL_WHISPER, player) end)
      AddMenuItem(GetString(SI_SOCIAL_MENU_SEND_MAIL), function() MAIL_SEND:ComposeMailTo(player) end)
      ShowMenu(control)
    end
  end
end

function MasterMerchant.PostPendingItem(self)
  local itemLink = GetItemLink(BAG_BACKPACK, self.m_pendingItemSlot)  
  local _, stackCount, _ = GetItemInfo(BAG_BACKPACK, self.m_pendingItemSlot)
  local settingsToUse = MasterMerchant:ActiveSettings()

  local theIID = string.match(itemLink, '|H.-:item:(.-):')
  local itemIndex = MasterMerchant.makeIndexFromLink(itemLink)

  settingsToUse.pricingData = settingsToUse.pricingData or {}
  settingsToUse.pricingData[tonumber(theIID)] = settingsToUse.pricingData[tonumber(theIID)] or {}
  settingsToUse.pricingData[tonumber(theIID)][itemIndex] = self.m_invoiceSellPrice.sellPrice / stackCount

  if settingsToUse.displayListingMessage then
    local selectedGuildId = GetSelectedTradingHouseGuildId()
    CHAT_SYSTEM:AddMessage(string.format(MasterMerchant.concat(GetString(MM_APP_MESSAGE_NAME), GetString(MM_LISTING_ALERT)),
      zo_strformat('<<t:1>>', itemLink), stackCount, self.m_invoiceSellPrice.sellPrice, GetGuildName(selectedGuildId)))
  end
end

-- End Copyright (c) 2014 Matthew Miller (Mattmillus)



MasterMerchant.CustomDealCalc = {
  ['@Causa'] = function(setPrice, salesCount, purchasePrice, stackCount)
    local deal = -1
    local margin = 0
    local profit = -1
    if (setPrice) then
      local unitPrice = purchasePrice / stackCount
      profit =(setPrice - unitPrice) * stackCount
      margin = tonumber(string.format('%.2f',(((setPrice * .92) - unitPrice) / unitPrice) * 100))

      if (margin >= 100) then
        deal = 5
      elseif (margin >= 75) then
        deal = 4
      elseif (margin >= 50) then
        deal = 3
      elseif (margin >= 25) then
        deal = 2
      elseif (margin >= 0) then
        deal = 1
      else
        deal = 0
      end
    else
      -- No sales seen
      deal = -2
      margin = nil
    end
    return deal, margin, profit
  end
} 

MasterMerchant.CustomDealCalc['@freakyfreak'] = MasterMerchant.CustomDealCalc['@Causa']


function MasterMerchant:myZO_InventorySlot_ShowContextMenu(inventorySlot)
    local st = ZO_InventorySlot_GetType(inventorySlot)
    link = nil
    if st == SLOT_TYPE_ITEM or st == SLOT_TYPE_EQUIPMENT or st == SLOT_TYPE_BANK_ITEM or st == SLOT_TYPE_GUILD_BANK_ITEM or 
       st == SLOT_TYPE_TRADING_HOUSE_POST_ITEM or st == SLOT_TYPE_REPAIR or st == SLOT_TYPE_CRAFTING_COMPONENT or st == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or 
       st == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or st == SLOT_TYPE_PENDING_CRAFTING_COMPONENT then
        local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
        link = GetItemLink(bag, index)
    end
    if st == SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
        link = GetTradingHouseSearchResultItemLink(ZO_Inventory_GetSlotIndex(inventorySlot))
    end
    if st == SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING then
        link = GetTradingHouseListingItemLink(ZO_Inventory_GetSlotIndex(inventorySlot), linkStyle)
    end
    if link then 
		zo_callLater(function() 
            AddMenuItem(GetString(MM_POPUP_ITEM_DATA), function() self:onItemActionPopupInfoLink(link) end, MENU_ADD_OPTION_LABEL)
            AddMenuItem(GetString(MM_STATS_TO_CHAT), function() self:onItemActionLinkStatsLink(link) end, MENU_ADD_OPTION_LABEL)
            ShowMenu(self) 
        end, 50)
    end
end

-- Calculate some stats based on the player's sales
-- and return them as a table.
function MasterMerchant:SalesStats(statsDays)
  -- Initialize some values as we'll be using accumulation in the loop
  -- SK_STATS_TOTAL is a key for the overall stats as a guild is unlikely
  -- to be named that, except maybe just to mess with me :D
  local itemsSold = {['SK_STATS_TOTAL'] = 0}
  local goldMade = {['SK_STATS_TOTAL'] = 0}
  local largestSingle = {['SK_STATS_TOTAL'] = {0, nil}}
  local oldestTime = 0
  local newestTime = 0
  local overallOldestTime = 0
  local kioskSales = {['SK_STATS_TOTAL'] = 0}

  -- Set up the guild chooser, with the all guilds/overall option first
  --(other guilds will be added below)
  local guildDropdown = ZO_ComboBox_ObjectFromContainer(MasterMerchantStatsGuildChooser)
  guildDropdown:ClearItems()
  local allGuilds = guildDropdown:CreateItemEntry(GetString(SK_STATS_ALL_GUILDS), function() self:UpdateStatsWindow('SK_STATS_TOTAL') end)
  guildDropdown:AddItem(allGuilds)

  -- 86,400 seconds in a day; this will be the epoch time statsDays ago
  -- (roughly, actual time computations are a LOT more complex but meh)
  local statsDaysEpoch = GetTimeStamp() - (86400 * statsDays)

  -- Loop through the player's sales and create the stats as appropriate
  -- (everything or everything with a timestamp after statsDaysEpoch)
  local seenIndexes = {}
  for _, indexes in pairs(self.SSIndex) do
    for i = 1, #indexes do
      local itemID = indexes[i][1]
      local itemData = indexes[i][2]
      local itemIndex = indexes[i][3]
      if seenIndexes[itemID] == nil then
        seenIndexes[itemID] = {}
      end
      if seenIndexes[itemID][itemData] == nil then
        seenIndexes[itemID][itemData] = {}
      end

      if seenIndexes[itemID][itemData][itemIndex] == nil then
        seenIndexes[itemID][itemData][itemIndex] = true
        local theItem = self.salesData[itemID][itemData]['sales'][itemIndex]
        if theItem.timestamp > statsDaysEpoch then
          -- Items Sold
          itemsSold['SK_STATS_TOTAL'] = itemsSold['SK_STATS_TOTAL'] + 1
          if itemsSold[theItem.guild] ~= nil then
            itemsSold[theItem.guild] = itemsSold[theItem.guild] + 1
          else
            itemsSold[theItem.guild] = 1
          end

          -- Kiosk sales
          if theItem.wasKiosk then
            kioskSales['SK_STATS_TOTAL'] = kioskSales['SK_STATS_TOTAL'] + 1
            if kioskSales[theItem.guild] ~= nil then
              kioskSales[theItem.guild] = kioskSales[theItem.guild] + 1
            else
              kioskSales[theItem.guild] = 1
            end
          end

          -- Gold made
          goldMade['SK_STATS_TOTAL'] = goldMade['SK_STATS_TOTAL'] + theItem.price
          if goldMade[theItem.guild] ~= nil then
            goldMade[theItem.guild] = goldMade[theItem.guild] + theItem.price
          else
            goldMade[theItem.guild] = theItem.price
          end

          -- Check to see if we need to update the newest or oldest timestamp we've seen
          if oldestTime == 0 or theItem.timestamp < oldestTime then oldestTime = theItem.timestamp end
          if newestTime == 0 or theItem.timestamp > newestTime then newestTime = theItem.timestamp end

          -- Largest single sale
          if theItem.price > largestSingle['SK_STATS_TOTAL'][1] then largestSingle['SK_STATS_TOTAL'] = {theItem.price, theItem.itemLink} end
          if largestSingle[theItem.guild] == nil or theItem.price > largestSingle[theItem.guild][1] then
            largestSingle[theItem.guild] = {theItem.price, theItem.itemLink}
          end
        end
        -- Check to see if we need to update the overall oldest time (used to set slider range)
        if overallOldestTime == 0 or theItem.timestamp < overallOldestTime then
          overallOldestTime = theItem.timestamp
        end
      end
    end
  end
  seenIndexes = nil

  -- Newest timestamp seen minus oldest timestamp seen is the number of seconds between
  -- them; divided by 86,400 it's the number of days (or at least close enough for this)
  local timeWindow = newestTime - oldestTime
  local dayWindow = 1
  if timeWindow > 86400 then dayWindow = math.floor(timeWindow / 86400) + 1 end

  local overallTimeWindow = newestTime - overallOldestTime
  local overallDayWindow = 1
  if overallTimeWindow > 86400 then overallDayWindow = math.floor(overallTimeWindow / 86400) + 1 end

  local goldPerDay = {}
  local kioskPercentage = {}
  local showFullPrice = self:ActiveSettings().showFullPrice

  -- Here we'll tweak stats as needed as well as add guilds to the guild chooser
  for theGuildName, guildItemsSold in pairs(itemsSold) do
    goldPerDay[theGuildName] = math.floor(goldMade[theGuildName] / dayWindow)
    local kioskSalesTemp = 0
    if kioskSales[theGuildName] ~= nil then kioskSalesTemp = kioskSales[theGuildName] end
    kioskPercentage[theGuildName] = math.floor((kioskSalesTemp / guildItemsSold) * 100)

    if theGuildName ~= 'SK_STATS_TOTAL' then
      local guildEntry = guildDropdown:CreateItemEntry(theGuildName, function() self:UpdateStatsWindow(theGuildName) end)
      guildDropdown:AddItem(guildEntry)
    end

    -- If they have the option set to show prices post-cut, calculate that here
    if not showFullPrice then
      local cutMult = 1 - (GetTradingHouseCutPercentage() / 100)
      goldMade[theGuildName] = math.floor(goldMade[theGuildName] * cutMult + 0.5)
      goldPerDay[theGuildName] = math.floor(goldPerDay[theGuildName] * cutMult + 0.5)
      largestSingle[theGuildName][1] = math.floor(largestSingle[theGuildName][1] * cutMult + 0.5)
    end
  end

  -- Return the statistical data in a convenient table
  return { numSold = itemsSold,
           numDays = dayWindow,
           totalDays = overallDayWindow,
           totalGold = goldMade,
           avgGold = goldPerDay,
           biggestSale = largestSingle,
           kioskPercent = kioskPercentage, }
end

-- LibAddon init code
function MasterMerchant:LibAddonInit()
  local LAM = LibStub('LibAddonMenu-2.0')
  if LAM then
    local LMP = LibStub('LibMediaProvider-1.0')
    if LMP then
      local panelData = {
        type = 'panel',
        name = 'Master Merchant',
        displayName = GetString(MM_APP_NAME),
        author = GetString(MM_APP_AUTHOR),
        version = self.version,
        registerForDefaults = true,
      }
      LAM:RegisterAddonPanel('MasterMerchantOptions', panelData)

      local settingsToUse = MasterMerchant:ActiveSettings()
      local optionsData = {
        -- Sound and Alert options
        [1] = {
          type = 'submenu',
          name = GetString(SK_ALERT_OPTIONS_NAME),
          tooltip = GetString(SK_ALERT_OPTIONS_TIP),
          controls = {
            -- On-Screen Alerts
            [1] = {
              type = 'checkbox',
              name = GetString(SK_ALERT_ANNOUNCE_NAME),
              tooltip = GetString(SK_ALERT_ANNOUNCE_TIP),
              getFunc = function() return self:ActiveSettings().showAnnounceAlerts end,
              setFunc = function(value) self:ActiveSettings().showAnnounceAlerts = value end,
            },
            [2] = {
              type = 'checkbox',
              name = GetString(SK_ALERT_CYRODIIL_NAME),
              tooltip = GetString(SK_ALERT_CYRODIIL_TIP),
              getFunc = function() return self:ActiveSettings().showCyroAlerts end,
              setFunc = function(value) self:ActiveSettings().showCyroAlerts = value end,
            },
            -- Chat Alerts
            [3] = {
              type = 'checkbox',
              name = GetString(SK_ALERT_CHAT_NAME),
              tooltip = GetString(SK_ALERT_CHAT_TIP),
              getFunc = function() return self:ActiveSettings().showChatAlerts end,
              setFunc = function(value) self:ActiveSettings().showChatAlerts = value end,
            },
            -- Sound to use for alerts
            [4] = {
              type = 'dropdown',
              name = GetString(SK_ALERT_TYPE_NAME),
              tooltip = GetString(SK_ALERT_TYPE_TIP),
              choices = self:SoundKeys(),
              getFunc = function() return self:SearchSounds(self:ActiveSettings().alertSoundName) end,
              setFunc = function(value) 
                self:ActiveSettings().alertSoundName = self:SearchSoundNames(value) 
                PlaySound(self:ActiveSettings().alertSoundName)
              end,
            },
            -- Whether or not to show multiple alerts for multiple sales
            [5] = {
              type = 'checkbox',
              name = GetString(SK_MULT_ALERT_NAME),
              tooltip = GetString(SK_MULT_ALERT_TIP),
              getFunc = function() return self:ActiveSettings().showMultiple end,
              setFunc = function(value) self:ActiveSettings().showMultiple = value end,
            },
            -- Offline sales report
            [6] = {
              type = 'checkbox',
              name = GetString(SK_OFFLINE_SALES_NAME),
              tooltip = GetString(SK_OFFLINE_SALES_TIP),
              getFunc = function() return self:ActiveSettings().offlineSales end,
              setFunc = function(value) self:ActiveSettings().offlineSales = value end,
            },
          },
        },
        -- Tip display and calculation options
        [2] = {
          type = 'submenu',
          name = GetString(MM_CALC_OPTIONS_NAME),
          tooltip = GetString(MM_CALC_OPTIONS_TIP),
          controls = {
            -- On-Screen Alerts
            [1] = {
              type = 'slider',
              name = GetString(MM_DAYS_FOCUS_ONE_NAME),
              tooltip = GetString(MM_DAYS_FOCUS_ONE_TIP),
              min = 1,
              max = 90,
              getFunc = function() return self:ActiveSettings().focus1 end,
              setFunc = function(value) self:ActiveSettings().focus1 = value end,
            },            
            [2] = {
              type = 'slider',
              name = GetString(MM_DAYS_FOCUS_TWO_NAME),
              tooltip = GetString(MM_DAYS_FOCUS_TWO_TIP),
              min = 1,
              max = 90,
              getFunc = function() return self:ActiveSettings().focus2 end,
              setFunc = function(value) self:ActiveSettings().focus2 = value end,
            },
            -- default time range            
            [3] = {
              type = 'dropdown',
              name = GetString(MM_DEFAULT_TIME_NAME),
              tooltip = GetString(MM_DEFAULT_TIME_TIP),
              choices = {GetString(MM_RANGE_ALL),GetString(MM_RANGE_FOCUS1),GetString(MM_RANGE_FOCUS2),GetString(MM_RANGE_NONE)},
              getFunc = function() return self:ActiveSettings().defaultDays end,
              setFunc = function(value) self:ActiveSettings().defaultDays = value end,
            },
            -- shift time range            
            [4] = {
              type = 'dropdown',
              name = GetString(MM_SHIFT_TIME_NAME),
              tooltip = GetString(MM_SHIFT_TIME_TIP),
              choices = {GetString(MM_RANGE_ALL),GetString(MM_RANGE_FOCUS1),GetString(MM_RANGE_FOCUS2),GetString(MM_RANGE_NONE)},
              getFunc = function() return self:ActiveSettings().shiftDays end,
              setFunc = function(value) self:ActiveSettings().shiftDays = value end,
            },
            -- ctrl time range            
            [5] = {
              type = 'dropdown',
              name = GetString(MM_CTRL_TIME_NAME),
              tooltip = GetString(MM_CTRL_TIME_TIP),
              choices = {GetString(MM_RANGE_ALL),GetString(MM_RANGE_FOCUS1),GetString(MM_RANGE_FOCUS2),GetString(MM_RANGE_NONE)},
              getFunc = function() return self:ActiveSettings().ctrlDays end,
              setFunc = function(value) self:ActiveSettings().ctrlDays = value end,
            },
            -- ctrl-shift time range            
            [6] = {
              type = 'dropdown',
              name = GetString(MM_CTRLSHIFT_TIME_NAME),
              tooltip = GetString(MM_CTRLSHIFT_TIME_TIP),
              choices = {GetString(MM_RANGE_ALL),GetString(MM_RANGE_FOCUS1),GetString(MM_RANGE_FOCUS2),GetString(MM_RANGE_NONE)},
              getFunc = function() return self:ActiveSettings().ctrlShiftDays end,
              setFunc = function(value) self:ActiveSettings().ctrlShiftDays = value end,
            },
            [7] = {
              type = 'slider',
              name = GetString(MM_NO_DATA_DEAL_NAME),
              tooltip = GetString(MM_NO_DATA_DEAL_TIP),
              min = 0,
              max = 5,
              getFunc = function() return self:ActiveSettings().noSalesInfoDeal end,
              setFunc = function(value) self:ActiveSettings().noSalesInfoDeal = value end,
            },
            -- blacklisted players and guilds            
            [8] = {
              type = 'editbox',
              name = GetString(MM_BLACKLIST_NAME),
              tooltip = GetString(MM_BLACKLIST_TIP),
              getFunc = function() return self:ActiveSettings().blacklist end,
              setFunc = function(value) self:ActiveSettings().blacklist = value end,
            },
            -- customTimeframe
            [9] = {
              type = 'slider',
              name = GetString(MM_CUSTOM_TIMEFRAME_NAME),
              tooltip = GetString(MM_CUSTOM_TIMEFRAME_TIP),
              min = 1,
              max = 24 * 31,
              getFunc = function() return self:ActiveSettings().customTimeframe end,
              setFunc = function(value) self:ActiveSettings().customTimeframe = value 
                self:ActiveSettings().customTimeframeText = self:ActiveSettings().customTimeframe .. ' ' .. self:ActiveSettings().customTimeframeType
              end,
            },
            -- shift time range            
            [10] = {
              type = 'dropdown',
              name = GetString(MM_CUSTOM_TIMEFRAME_SCALE_NAME),
              tooltip = GetString(MM_CUSTOM_TIMEFRAME_SCALE_TIP),
              choices = {GetString(MM_CUSTOM_TIMEFRAME_HOURS),GetString(MM_CUSTOM_TIMEFRAME_DAYS),GetString(MM_CUSTOM_TIMEFRAME_WEEKS),GetString(MM_CUSTOM_TIMEFRAME_GUILD_WEEKS)},
              getFunc = function() return self:ActiveSettings().customTimeframeType end,
              setFunc = function(value) self:ActiveSettings().customTimeframeType = value 
                self:ActiveSettings().customTimeframeText = self:ActiveSettings().customTimeframe .. ' ' .. self:ActiveSettings().customTimeframeType
              end,
            },
          },
        },
        -- Open main window with mailbox scenes
        [3] = {
          type = 'checkbox',
          name = GetString(SK_OPEN_MAIL_NAME),
          tooltip = GetString(SK_OPEN_MAIL_TIP),
          getFunc = function() return self:ActiveSettings().openWithMail end,
          setFunc = function(value)
            self:ActiveSettings().openWithMail = value
            local theFragment = ((settingsToUse.viewSize == ITEMS) and self.uiFragment) or ((settingsToUse.viewSize == GUILDS) and self.guildUiFragment) or self.listingUiFragment
            if value then
              -- Register for the mail scenes
              MAIL_INBOX_SCENE:AddFragment(theFragment)
              MAIL_SEND_SCENE:AddFragment(theFragment)
            else
              -- Unregister for the mail scenes
              MAIL_INBOX_SCENE:RemoveFragment(theFragment)
              MAIL_SEND_SCENE:RemoveFragment(theFragment)
            end
          end,
        },
        -- Open main window with trading house scene
        [4] = {
          type = 'checkbox',
          name = GetString(SK_OPEN_STORE_NAME),
          tooltip = GetString(SK_OPEN_STORE_TIP),
          getFunc = function() return self:ActiveSettings().openWithStore end,
          setFunc = function(value)
            self:ActiveSettings().openWithStore = value
            local theFragment = ((settingsToUse.viewSize == ITEMS) and self.uiFragment) or ((settingsToUse.viewSize == GUILDS) and self.guildUiFragment) or self.listingUiFragment
            if value then
              -- Register for the store scene
              TRADING_HOUSE_SCENE:AddFragment(theFragment)
            else
              -- Unregister for the store scene
              TRADING_HOUSE_SCENE:RemoveFragment(theFragment)
            end
          end,
        },
        -- Show full sale price or post-tax price
        [5] = {
          type = 'checkbox',
          name = GetString(SK_FULL_SALE_NAME),
          tooltip = GetString(SK_FULL_SALE_TIP),
          getFunc = function() return self:ActiveSettings().showFullPrice end,
          setFunc = function(value)
            self:ActiveSettings().showFullPrice = value
            MasterMerchant.listIsDirty[ITEMS] = true
            MasterMerchant.listIsDirty[GUILDS] = true
            MasterMerchant.listIsDirty[LISTINGS] = true
          end,
        },
        -- Scan frequency (in seconds)
        [6] = {
          type = 'slider',
          name = GetString(SK_SCAN_FREQ_NAME),
          tooltip = GetString(SK_SCAN_FREQ_TIP),
          min = 30,
          max = 600,
          getFunc = function() return self:ActiveSettings().scanFreq end,
          setFunc = function(value)
            self:ActiveSettings().scanFreq = value

            EVENT_MANAGER:UnregisterForUpdate(self.name)
            local scanInterval = value * 1000
            EVENT_MANAGER:RegisterForUpdate(self.name, scanInterval, function() self:ScanStores(false) end)
          end,
        },
        -- Size of sales history
        [7] = {
          type = 'slider',
          name = GetString(SK_HISTORY_DEPTH_NAME),
          tooltip = GetString(SK_HISTORY_DEPTH_TIP),
          min = 1,
          max = 90,
          getFunc = function() return self.systemSavedVariables.historyDepth end,
          setFunc = function(value) self.systemSavedVariables.historyDepth = value end,
        },
        -- Min Number of Items before Purge
        [8] = {
          type = 'slider',
          name = GetString(MM_MIN_ITEM_COUNT_NAME),
          tooltip = GetString(MM_MIN_ITEM_COUNT_TIP),
          min = 1,
          max = 100,
          getFunc = function() return self.systemSavedVariables.minItemCount end,
          setFunc = function(value) self.systemSavedVariables.minItemCount = value end,
        },
        -- Max number of Items
        [9] = {
          type = 'slider',
          name = GetString(MM_MAX_ITEM_COUNT_NAME),
          tooltip = GetString(MM_MAX_ITEM_COUNT_TIP),
          min = 100,
          max = 10000,
          getFunc = function() return self.systemSavedVariables.maxItemCount end,
          setFunc = function(value) self.systemSavedVariables.maxItemCount = value end,
        },
        -- Whether or not to show the pricing data in tooltips
        [10] = {
          type = 'checkbox',
          name = GetString(SK_SHOW_PRICING_NAME),
          tooltip = GetString(SK_SHOW_PRICING_TIP),
          getFunc = function() return self:ActiveSettings().showPricing end,
          setFunc = function(value) self:ActiveSettings().showPricing = value end,
        },
        -- Whether or not to show the pricing graph in tooltips
        [11] = {
          type = 'checkbox',
          name = GetString(SK_SHOW_GRAPH_NAME),
          tooltip = GetString(SK_SHOW_GRAPH_TIP),
          getFunc = function() return self:ActiveSettings().showGraph end,
          setFunc = function(value) self:ActiveSettings().showGraph = value end,
        },
        
        -- Whether or not to show tooltips on the graph points
        [12] = {
          type = 'checkbox',
          name = GetString(MM_GRAPH_INFO_NAME),
          tooltip = GetString(MM_GRAPH_INFO_TIP),
          getFunc = function() return self:ActiveSettings().displaySalesDetails end,
          setFunc = function(value) self:ActiveSettings().displaySalesDetails = value end,
        },
        -- Whether or not to show the quality/level adjustment buttons
        [13] = {
          type = 'checkbox',
          name = GetString(MM_LEVEL_QUALITY_NAME),
          tooltip = GetString(MM_LEVEL_QUALITY_TIP),
          getFunc = function() return self:ActiveSettings().displayItemAnalysisButtons end,
          setFunc = function(value) self:ActiveSettings().displayItemAnalysisButtons = value end,
        },

        -- Should we show the stack price calculator?
        [14] = {
          type = 'checkbox',
          name = GetString(SK_CALC_NAME),
          tooltip = GetString(SK_CALC_TIP),
          getFunc = function() return self:ActiveSettings().showCalc end,
          setFunc = function(value) self:ActiveSettings().showCalc = value end,   
        },     
        -- should we trim outliers prices?
        [15] = {
          type = 'checkbox',
          name = GetString(SK_TRIM_OUTLIERS_NAME),
          tooltip = GetString(SK_TRIM_OUTLIERS_TIP),
          getFunc = function() return self:ActiveSettings().trimOutliers end,
          setFunc = function(value) self:ActiveSettings().trimOutliers = value end,   
        },   
        -- should we trim off decimals?
        [16] = {
          type = 'checkbox',
          name = GetString(SK_TRIM_DECIMALS_NAME),
          tooltip = GetString(SK_TRIM_DECIMALS_TIP),
          getFunc = function() return self:ActiveSettings().trimDecimals end,
          setFunc = function(value) self:ActiveSettings().trimDecimals = value end,   
        },   
        -- should we replace inventory values?
        [17] = {
          type = 'checkbox',
          name = GetString(MM_REPLACE_INVENTORY_VALUES_NAME),
          tooltip = GetString(MM_REPLACE_INVENTORY_VALUES_TIP),
          getFunc = function() return self:ActiveSettings().replaceInventoryValues end,
          setFunc = function(value) self:ActiveSettings().replaceInventoryValues = value end,   
        },   
        -- should we delay initialization?
        [18] = {
          type = 'checkbox',
          name = GetString(SK_DELAY_INIT_NAME),
          tooltip = GetString(SK_DELAY_INIT_TIP),
          getFunc = function() return self.systemSavedVariables.delayInit end,
          setFunc = function(value) self.systemSavedVariables.delayInit = value end,   
        },  
        -- should we display info on guild roster?
        [19] = {
          type = 'checkbox',
          name = GetString(SK_ROSTER_INFO_NAME),
          tooltip = GetString(SK_ROSTER_INFO_TIP),
          getFunc = function() return self:ActiveSettings().diplayGuildInfo end,
          setFunc = function(value) self:ActiveSettings().diplayGuildInfo = value end,   
        },  
        -- should we display profit instead of margin?
        [20] = {
          type = 'checkbox',
          name = GetString(MM_SAUCY_NAME),
          tooltip = GetString(MM_SAUCY_TIP),
          getFunc = function() return self:ActiveSettings().saucy end,
          setFunc = function(value) self:ActiveSettings().saucy = value end,   
        },  
        -- should we display a Min Profit Filter in AGS?
        [21] = {
          type = 'checkbox',
          name = GetString(MM_MIN_PROFIT_FILTER_NAME),
          tooltip = GetString(MM_MIN_PROFIT_FILTER_TIP),
          getFunc = function() return self:ActiveSettings().minProfitFilter end,
          setFunc = function(value) self:ActiveSettings().minProfitFilter = value end,   
        },
        -- should we auto advance to the next page?
        [22] = {
          type = 'checkbox',
          name = GetString(MM_AUTO_ADVANCE_NAME),
          tooltip = GetString(MM_AUTO_ADVANCE_TIP),
          getFunc = function() return self:ActiveSettings().autoNext end,
          setFunc = function(value) self:ActiveSettings().autoNext = value end,   
        },      
        -- should we display the item listed message?
        [23] = {
          type = 'checkbox',
          name = GetString(MM_DISPLAY_LISTING_MESSAGE_NAME),
          tooltip = GetString(MM_DISPLAY_LISTING_MESSAGE_TIP),
          getFunc = function() return self:ActiveSettings().displayListingMessage end,
          setFunc = function(value) self:ActiveSettings().displayListingMessage = value end,   
        },                
        -- Font to use
        [24] = {
          type = 'dropdown',
          name = GetString(SK_WINDOW_FONT_NAME),
          tooltip = GetString(SK_WINDOW_FONT_TIP),
          choices = LMP:List(LMP.MediaType.FONT),
          getFunc = function() return self:ActiveSettings().windowFont end,
          setFunc = function(value)
            self:ActiveSettings().windowFont = value
            self:UpdateFonts()
            if self:ActiveSettings().viewSize == ITEMS then self.scrollList:RefreshVisible()
            elseif self:ActiveSettings().viewSize == GUILDS then self.guildScrollList:RefreshVisible() 
            else self.listingScrollList:RefreshVisible() end 
          end,
        },
        -- Make all settings account-wide (or not)
        [25] = {
          type = 'checkbox',
          name = GetString(SK_ACCOUNT_WIDE_NAME),
          tooltip = GetString(SK_ACCOUNT_WIDE_TIP),
          getFunc = function() return self.acctSavedVariables.allSettingsAccount end,
          setFunc = function(value)
            if value then
              self.acctSavedVariables.showChatAlerts = self.savedVariables.showChatAlerts
              self.acctSavedVariables.showChatAlerts = self.savedVariables.showMultiple
              self.acctSavedVariables.openWithMail = self.savedVariables.openWithMail
              self.acctSavedVariables.openWithStore = self.savedVariables.openWithStore
              self.acctSavedVariables.showFullPrice = self.savedVariables.showFullPrice
              self.acctSavedVariables.winLeft = self.savedVariables.winLeft
              self.acctSavedVariables.winTop = self.savedVariables.winTop
              self.acctSavedVariables.guildWinLeft = self.savedVariables.guildWinLeft
              self.acctSavedVariables.guildWinTop = self.savedVariables.guildWinTop
              self.acctSavedVariables.statsWinLeft = self.savedVariables.statsWinLeft
              self.acctSavedVariables.statsWinTop = self.savedVariables.statsWinTop
              self.acctSavedVariables.windowFont = self.savedVariables.windowFont
              self.acctSavedVariables.showCalc = self.savedVariables.showCalc
              self.acctSavedVariables.showPricing = self.savedVariables.showPricing
              self.acctSavedVariables.showGraph = self.savedVariables.showGraph
              self.acctSavedVariables.scanFreq = self.savedVariables.scanFreq
              self.acctSavedVariables.showAnnounceAlerts = self.savedVariables.showAnnounceAlerts
              self.acctSavedVariables.alertSoundName = self.savedVariables.alertSoundName
              self.acctSavedVariables.showUnitPrice = self.savedVariables.showUnitPrice
              self.acctSavedVariables.viewSize = self.savedVariables.viewSize
              self.acctSavedVariables.offlineSales = self.savedVariables.offlineSales
              self.acctSavedVariables.feedbackWinLeft = self.savedVariables.feedbackWinLeft
              self.acctSavedVariables.feedbackWinTop = self.savedVariables.feedbackWinTop
              self.acctSavedVariables.trimOutliers = self.savedVariables.trimOutliers
              self.acctSavedVariables.trimDecimals = self.savedVariables.trimDecimals
              self.acctSavedVariables.replaceInventoryValues = self.savedVariables.replaceInventoryValues
              self.acctSavedVariables.diplayGuildInfo = self.savedVariables.diplayGuildInfo
              self.acctSavedVariables.focus1 = self.savedVariables.focus1
              self.acctSavedVariables.focus2 = self.savedVariables.focus2
              self.acctSavedVariables.defaultDays = self.savedVariables.defaultDays
              self.acctSavedVariables.shiftDays = self.savedVariables.shiftDays
              self.acctSavedVariables.ctrlDays = self.savedVariables.ctrlDays
              self.acctSavedVariables.ctrlShiftDays = self.savedVariables.ctrlShiftDays
              self.acctSavedVariables.blacklisted = self.savedVariables.blacklisted
              self.acctSavedVariables.saucy = self.savedVariables.saucy
              self.acctSavedVariables.minProfitFilter = self.savedVariables.minProfitFilter
              self.acctSavedVariables.autoNext = self.savedVariables.autoNext
              self.acctSavedVariables.displayListingMessage = self.savedVariables.displayListingMessage
              self.acctSavedVariables.noSalesInfoDeal = self.savedVariables.noSalesInfoDeal
              self.acctSavedVariables.displaySalesDetails = self.savedVariables.displaySalesDetails
              self.acctSavedVariables.displayItemAnalysisButtons = self.savedVariables.displayItemAnalysisButtons
            else
              self.savedVariables.showChatAlerts = self.acctSavedVariables.showChatAlerts
              self.savedVariables.showChatAlerts = self.acctSavedVariables.showMultiple
              self.savedVariables.openWithMail = self.acctSavedVariables.openWithMail
              self.savedVariables.openWithStore = self.acctSavedVariables.openWithStore
              self.savedVariables.showFullPrice = self.acctSavedVariables.showFullPrice
              self.savedVariables.winLeft = self.acctSavedVariables.winLeft
              self.savedVariables.winTop = self.acctSavedVariables.winTop
              self.savedVariables.guildWinLeft = self.acctSavedVariables.guildWinLeft
              self.savedVariables.guildWinTop = self.acctSavedVariables.guildWinTop
              self.savedVariables.statsWinLeft = self.acctSavedVariables.statsWinLeft
              self.savedVariables.statsWinTop = self.acctSavedVariables.statsWinTop
              self.savedVariables.windowFont = self.acctSavedVariables.windowFont
              self.savedVariables.showPricing = self.acctSavedVariables.showPricing
              self.savedVariables.showGraph = self.acctSavedVariables.showGraph
              self.savedVariables.showCalc = self.acctSavedVariables.showCalc
              self.savedVariables.scanFreq = self.acctSavedVariables.scanFreq
              self.savedVariables.showAnnounceAlerts = self.acctSavedVariables.showAnnounceAlerts
              self.savedVariables.alertSoundName = self.acctSavedVariables.alertSoundName
              self.savedVariables.showUnitPrice = self.acctSavedVariables.showUnitPrice
              self.savedVariables.viewSize = self.acctSavedVariables.viewSize
              self.savedVariables.offlineSales = self.acctSavedVariables.offlineSales
              self.savedVariables.feedbackWinLeft = self.acctSavedVariables.feedbackWinLeft
              self.savedVariables.feedbackWinTop = self.acctSavedVariables.feedbackWinTop
              self.savedVariables.trimOutliers = self.acctSavedVariables.trimOutliers
              self.savedVariables.trimDecimals = self.acctSavedVariables.trimDecimals
              self.savedVariables.replaceInventoryValues = self.acctSavedVariables.replaceInventoryValues
              self.savedVariables.diplayGuildInfo = self.acctSavedVariables.diplayGuildInfo
              self.savedVariables.focus1 = self.acctSavedVariables.focus1
              self.savedVariables.focus2 = self.acctSavedVariables.focus2
              self.savedVariables.defaultDays = self.acctSavedVariables.defaultDays
              self.savedVariables.shiftDays = self.acctSavedVariables.shiftDays
              self.savedVariables.ctrlDays = self.acctSavedVariables.ctrlDays
              self.savedVariables.ctrlShiftDays = self.acctSavedVariables.ctrlShiftDays
              self.savedVariables.blacklisted = self.acctSavedVariables.blacklisted
              self.savedVariables.saucy = self.acctSavedVariables.saucy
              self.savedVariables.minProfitFilter = self.acctSavedVariables.minProfitFilter
              self.savedVariables.autoNext = self.acctSavedVariables.autoNext
              self.savedVariables.displayListingMessage = self.acctSavedVariables.displayListingMessage
              self.savedVariables.noSalesInfoDeal = self.acctSavedVariables.noSalesInfoDeal
              self.savedVariables.displaySalesDetails = self.acctSavedVariables.displaySalesDetails
              self.savedVariables.displayItemAnalysisButtons = self.acctSavedVariables.displayItemAnalysisButtons
            end
            self.acctSavedVariables.allSettingsAccount = value
          end,
        },
      }

      -- And make the options panel
      LAM:RegisterOptionControls('MasterMerchantOptions', optionsData)
    end
  end
end



function MasterMerchant:PurgeDups()

  if not self.isScanning then
    self.isScanning = true
    MasterMerchantResetButton:SetEnabled(false)
    MasterMerchantGuildResetButton:SetEnabled(false)
    MasterMerchantRefreshButton:SetEnabled(false)
    MasterMerchantGuildRefreshButton:SetEnabled(false)
	  MasterMerchantWindowLoadingIcon:SetHidden(false)
	  MasterMerchantWindowLoadingIcon.animation:PlayForward()
	  MasterMerchantGuildWindowLoadingIcon:SetHidden(false)
	  MasterMerchantGuildWindowLoadingIcon.animation:PlayForward()
	  MasterMerchantGuildWindowLoadingIcon:SetHidden(false)
	  MasterMerchantGuildWindowLoadingIcon.animation:PlayForward()

    --DEBUG
    local start = GetTimeStamp()

    local count = 0
      
    --spin thru history and remove dups
    for itemNumber, itemNumberData in pairs(self.salesData) do
      for itemType, dataList in pairs(itemNumberData) do
        for i = #dataList['sales'], 2, -1 do

          local checking = dataList['sales'][i]
          local dup = false;
          for j = 1, i - 1 do
            local against = dataList['sales'][j]
            if against.id ~= nil and checking.id == against.id then
              dup = true
              break
            end
            if checking.id == nil and 
              checking.buyer == against.buyer and
              checking.guild == against.guild and
              checking.quant == against.quant and
              checking.price == against.price and
              checking.seller == against.seller and
              string.match(checking.itemLink, '|H(.-)|h') == string.match(against.itemLink, '|H(.-)|h') and 
              checking.timestamp == against.timestamp and 
              (math.abs(checking.timestamp - against.timestamp) < 1) then 
              dup = true
              break
            end
          end
          if dup then 
            table.remove(dataList['sales'], i) 
            count = count + 1
          end
        end
      end
    end
    
    --DEBUG
    d('Dup purge: ' .. GetTimeStamp() - start .. ' seconds to clear ' .. count .. ' duplicates.')

    local LEQ = LibStub('LibExecutionQueue-1.0')
    if count > 0 then
      --rebuild everything
      self.SRIndex = {}
      self.SSIndex = {}
  
      self.guildPurchases = nil
      self.guildSales = nil
      self.guildItems = nil
      self.myItems = {}
      LEQ:Add(function () self:InitPurchaseHistory() end, 'InitPurchaseHistory')
      LEQ:Add(function () self:InitItemHistory() end, 'InitItemHistory')
      LEQ:Add(function () self:InitSalesHistory() end, 'InitSalesHistory')
      LEQ:Add(function () self:InitIndexes(true) end, 'InitIndexes')
    end
    LEQ:Add(function () 
      self.isScanning = false
      MasterMerchantResetButton:SetEnabled(true)
      MasterMerchantGuildResetButton:SetEnabled(true)
      MasterMerchantRefreshButton:SetEnabled(true)
      MasterMerchantGuildRefreshButton:SetEnabled(true)
      MasterMerchantWindowLoadingIcon:SetHidden(true)
      MasterMerchantWindowLoadingIcon.animation:Stop()
      MasterMerchantGuildWindowLoadingIcon:SetHidden(true)
      MasterMerchantGuildWindowLoadingIcon.animation:Stop()
      MasterMerchantGuildWindowLoadingIcon:SetHidden(true)
      MasterMerchantGuildWindowLoadingIcon.animation:Stop()    
    end, 'LetScanningContinue')
    LEQ:Start()
  end
end


function MasterMerchant:CleanOutBad()

  if not self.isScanning then
    self.isScanning = true
    MasterMerchantResetButton:SetEnabled(false)
    MasterMerchantGuildResetButton:SetEnabled(false)
    MasterMerchantRefreshButton:SetEnabled(false)
    MasterMerchantGuildRefreshButton:SetEnabled(false)
	  MasterMerchantWindowLoadingIcon:SetHidden(false)
	  MasterMerchantWindowLoadingIcon.animation:PlayForward()
	  MasterMerchantGuildWindowLoadingIcon:SetHidden(false)
	  MasterMerchantGuildWindowLoadingIcon.animation:PlayForward()
	  MasterMerchantGuildWindowLoadingIcon:SetHidden(false)
	  MasterMerchantGuildWindowLoadingIcon.animation:PlayForward()

    --DEBUG
    local start = GetTimeStamp()

    local count = 0
    
    for k, v in pairs(self.salesData) do
      for j, dataList in pairs(v) do
        -- We iterate backwards here so we can remove entries without breaking
        -- the for loop
        if dataList['sales'] then
          for i = #dataList['sales'], 1, -1 do
            if (dataList['sales'][i]['timestamp'] == nil) 
               or (dataList['sales'][i]['timestamp'] and type(dataList['sales'][i]['timestamp']) ~= 'number') 
               or dataList['sales'][i]['guild'] == nil 
               or (not string.match(dataList['sales'][i]['itemLink'], 'item')) then 
              table.remove(dataList['sales'], i) 
              count = count + 1
            end
          end
        end
        -- If we just deleted all instances of this ID/data combo, clear the bucket out
        if (dataList['sales'] == nil) or (#dataList['sales'] < 1) then v[j] = nil end
      end
      -- Similarly, if we just deleted all data combos of this ID, clear the bucket out
      if NonContiguousCount(v) < 1 then self.salesData[k] = nil end
    end
      
    --DEBUG
    d('Cleaning: ' .. GetTimeStamp() - start .. ' seconds to clean ' .. count .. ' bad records.')

    local LEQ = LibStub('LibExecutionQueue-1.0')
    if count > 0 then
      --rebuild everything
      self.SRIndex = {}
      self.SSIndex = {}
  
      self.guildPurchases = {}
      self.guildSales = {}
      self.guildItems = {}
      self.myItems = {}
      LEQ:Add(function () self:InitPurchaseHistory() end, 'InitPurchaseHistory')
      LEQ:Add(function () self:InitItemHistory() end, 'InitItemHistory')
      LEQ:Add(function () self:InitSalesHistory() end, 'InitSalesHistory')
      LEQ:Add(function () self:InitIndexes(true) end, 'InitIndexes')
    end
    LEQ:Add(function () 
      self.isScanning = false
      MasterMerchantResetButton:SetEnabled(true)
      MasterMerchantGuildResetButton:SetEnabled(true)
      MasterMerchantRefreshButton:SetEnabled(true)
      MasterMerchantGuildRefreshButton:SetEnabled(true)
      MasterMerchantWindowLoadingIcon:SetHidden(true)
      MasterMerchantWindowLoadingIcon.animation:Stop()
      MasterMerchantGuildWindowLoadingIcon:SetHidden(true)
      MasterMerchantGuildWindowLoadingIcon.animation:Stop()
      MasterMerchantGuildWindowLoadingIcon:SetHidden(true)
      MasterMerchantGuildWindowLoadingIcon.animation:Stop()    
    end, 'LetScanningContinue')
    LEQ:Start()
  end
end


function MasterMerchant:SpecialMessage(force)
  if GetDisplayName() == '@sylviermoone' or (GetDisplayName() == '@Philgo68' and force) then
    local daysCount = math.floor(((GetTimeStamp() - (1460980800 + 38 * 86400 + 19 * 3600)) / 86400) * 4) / 4
    if (daysCount > (self.systemSavedVariables.daysPast or 0)) or force then
      self.systemSavedVariables.daysPast = daysCount

      local rem = daysCount - math.floor(daysCount)
      daysCount = math.floor(daysCount)

      if rem == 0 then
        CENTER_SCREEN_ANNOUNCE:AddMessage('MasterMerchantAlert', CSA_EVENT_SMALL_TEXT, "Objective_Complete",
          string.format("Keep it up!!  You've made it %s complete days!!", daysCount))
      end
    
      if rem == 0.25 then
        CENTER_SCREEN_ANNOUNCE:AddMessage('MasterMerchantAlert', CSA_EVENT_SMALL_TEXT, "Objective_Complete",
          string.format("Working your way through day %s...", daysCount + 1))
      end

      if rem == 0.5 then
        CENTER_SCREEN_ANNOUNCE:AddMessage('MasterMerchantAlert', CSA_EVENT_SMALL_TEXT, "Objective_Complete",
          string.format("Day %s half way done!", daysCount + 1))
      end
   
      if rem == 0.75 then
        CENTER_SCREEN_ANNOUNCE:AddMessage('MasterMerchantAlert', CSA_EVENT_SMALL_TEXT, "Objective_Complete",
          string.format("Just a little more to go in day %s...", daysCount + 1))
      end

    end
  end
end

function MasterMerchant:ExportLastWeek()
  local export = ZO_SavedVars:NewAccountWide('ShopkeeperSavedVars', 1, "EXPORT", {}, nil)

  local dataSet = MasterMerchant.guildPurchases
  local dataSet = MasterMerchant.guildSales

  local numGuilds = GetNumGuilds()
  local guildNum = self.guildNumber
  if guildNum > numGuilds then 
    CHAT_SYSTEM:AddMessage("Invalid Guild Number.")
    return 
  end

    local guildID = GetGuildId(guildNum)
    local guildName = GetGuildName(guildID)

    d(guildName)
    export[guildName] = {}
    local list = export[guildName]

    local numGuildMembers = GetNumGuildMembers(guildID)
    for guildMemberIndex = 1, numGuildMembers do       
        local displayName, note, rankIndex, status, secsSinceLogoff = GetGuildMemberInfo(guildID, guildMemberIndex)
        local online = (status ~= PLAYER_STATUS_OFFLINE)
        local rankId = GetGuildRankId(guildID, rankIndex)

        local amountBought = 0
        if MasterMerchant.guildPurchases and 
            MasterMerchant.guildPurchases[guildName] and 
            MasterMerchant.guildPurchases[guildName].sellers and 
            MasterMerchant.guildPurchases[guildName].sellers[displayName] and 
            MasterMerchant.guildPurchases[guildName].sellers[displayName].sales then 
            amountBought = MasterMerchant.guildPurchases[guildName].sellers[displayName].sales[4] or 0
        end

        local amountSold = 0
        if MasterMerchant.guildSales and 
            MasterMerchant.guildSales[guildName] and 
            MasterMerchant.guildSales[guildName].sellers and 
            MasterMerchant.guildSales[guildName].sellers[displayName] and 
            MasterMerchant.guildSales[guildName].sellers[displayName].sales then 
            amountSold = MasterMerchant.guildSales[guildName].sellers[displayName].sales[4] or 0
        end

        -- sample [2] = "@Name&Sales&Purchases&Rank"
        table.insert(list, displayName .. "&"  .. amountSold .. "&"  .. amountBought .. "&" .. rankIndex)
    end

end


function MasterMerchant:ExportSalesData()
  local export = ZO_SavedVars:NewAccountWide('ShopkeeperSavedVars', 1, "SALES", {}, nil)

  local numGuilds = GetNumGuilds()
  local guildNum = self.guildNumber
  local guildID 
  local guildName

  if guildNum > numGuilds then 
    guildName = 'ALL'
  else
    guildID = GetGuildId(guildNum)
    guildName = GetGuildName(guildID)
  end
  export[guildName] = {}
  local list = export[guildName]

  local epochBack = GetTimeStamp() - (86400 * 10)
  for k, v in pairs(self.salesData) do
    for j, dataList in pairs(v) do
      if dataList['sales'] then
        for _, sale in pairs(dataList['sales']) do
          if sale.timestamp >= epochBack and (guildName == 'ALL' or guildName == sale.guild) then
            local itemDesc = dataList['itemDesc']
            itemDesc = itemDesc:gsub("%^.*$","",1)
            itemDesc = string.gsub(" "..itemDesc, "%s%l", string.upper):sub(2)

            table.insert(list, 
              sale.seller .. "&" .. 
              sale.buyer .. "&" .. 
              sale.itemLink .. "&" .. 
              sale.quant .. "&" .. 
              sale.timestamp .. "&" .. 
              tostring(sale.wasKiosk) .. "&" .. 
              sale.price .. "&" .. 
              sale.guild .. "&" .. 
              itemDesc .. "&" .. 
              dataList['itemAdderText']
              )

          end
        end
      end
    end
  end

end



-- Called after store scans complete, re-creates indexes if need be,
-- and updates the slider range. Once this is done it updates the
-- displayed table, sending a message to chat if the scan was initiated
-- via the 'refresh' or 'reset' buttons.

function MasterMerchant:PostScan(doAlert)
  -- If the index is blank (first scan after login or after reset),
  -- build the indexes now that we have a scanned table.
  self.veryFirstScan = false
  if self.SRIndex == {} then MasterMerchant:indexHistoryTables(true) end
  local settingsToUse = MasterMerchant:ActiveSettings()
  if doAlert then CHAT_SYSTEM:AddMessage(MasterMerchant.concat(GetString(MM_APP_MESSAGE_NAME),GetString(SK_REFRESH_DONE))) end
  
  -- If there's anything in the alert queue, handle it.
  if #self.alertQueue > 0 then
    -- Play an alert chime once if there are any alerts in the queue
    if settingsToUse.showChatAlerts or settingsToUse.showAnnounceAlerts then
      PlaySound(settingsToUse.alertSoundName)
    end

    local numSold = 0
    local totalGold = 0
    local numAlerts = #self.alertQueue
    local lastEvent = {}
    for i = 1, numAlerts do
      local theEvent = table.remove(self.alertQueue, 1)
      numSold = numSold + 1

      -- Adjust the price if they want the post-cut prices instead
      local dispPrice = theEvent.salePrice
      if not settingsToUse.showFullPrice then
        local cutPrice = dispPrice * (1 - (GetTradingHouseCutPercentage() / 100))
        dispPrice = math.floor(cutPrice + 0.5)
      end
      totalGold = totalGold + dispPrice

      -- Offline sales report
      if self.isFirstScan and settingsToUse.offlineSales then
        local stringPrice = self.LocalizedNumber(dispPrice)
        local textTime = self.TextTimeSince(theEvent.saleTime, true)
        if i == 1 then CHAT_SYSTEM:AddMessage(MasterMerchant.concat(GetString(MM_APP_MESSAGE_NAME), GetString(SK_SALES_REPORT))) end
        CHAT_SYSTEM:AddMessage(zo_strformat('<<t:1>>', theEvent.itemName) .. GetString(MM_APP_TEXT_TIMES) .. theEvent.quant .. ' -- ' .. stringPrice .. ' |t16:16:EsoUI/Art/currency/currency_gold.dds|t -- ' .. theEvent.guild)
        if i == numAlerts then 
          -- Total of offline sales
          CHAT_SYSTEM:AddMessage(string.format(GetString(SK_SALES_ALERT_GROUP), numAlerts, self.LocalizedNumber(totalGold)))
          CHAT_SYSTEM:AddMessage(MasterMerchant.concat(GetString(MM_APP_MESSAGE_NAME), GetString(SK_SALES_REPORT_END))) 
       end
      -- Subsequent scans
      else
        -- If they want multiple alerts, we'll alert on each loop iteration
        -- or if there's only one.
        if settingsToUse.showMultiple or numAlerts == 1 then
          -- Insert thousands separators for the price
          local stringPrice = self.LocalizedNumber(dispPrice)

          -- On-screen alert; map index 37 is Cyrodiil
          if settingsToUse.showAnnounceAlerts and
            (settingsToUse.showCyroAlerts or GetCurrentMapZoneIndex ~= 37) then

            -- We'll add a numerical suffix to avoid queueing two identical messages in a row
            -- because the alerts will 'miss' if we do
            local textTime = self.TextTimeSince(theEvent.saleTime, true)
            local alertSuffix = ''
            if lastEvent[1] ~= nil and theEvent.itemName == lastEvent[1].itemName and textTime == lastEvent[2] then
              lastEvent[3] = lastEvent[3] + 1
              alertSuffix = ' (' .. lastEvent[3] .. ')'
            else
              lastEvent[1] = theEvent
              lastEvent[2] = textTime
              lastEvent[3] = 1
            end
            -- German word order differs so argument order also needs to be changed
            -- Also due to plurality differences in German, need to differentiate
            -- single item sold vs. multiple of an item sold.
            if self.locale == 'de' then
              if theEvent.quant > 1 then
                CENTER_SCREEN_ANNOUNCE:AddMessage('MasterMerchantAlert', CSA_EVENT_SMALL_TEXT, SOUNDS.NONE,
                  string.format(GetString(SK_SALES_ALERT_COLOR), theEvent.quant, zo_strformat('<<t:1>>', theEvent.itemName),
                                stringPrice, theEvent.guild, textTime) .. alertSuffix)
              else
                CENTER_SCREEN_ANNOUNCE:AddMessage('MasterMerchantAlert', CSA_EVENT_SMALL_TEXT, SOUNDS.NONE,
                  string.format(GetString(SK_SALES_ALERT_SINGLE_COLOR),zo_strformat('<<t:1>>', theEvent.itemName),
                                stringPrice, theEvent.guild, textTime) .. alertSuffix)
              end
            else
              CENTER_SCREEN_ANNOUNCE:AddMessage('MasterMerchantAlert', CSA_EVENT_SMALL_TEXT, SOUNDS.NONE,
                string.format(GetString(SK_SALES_ALERT_COLOR), zo_strformat('<<t:1>>', theEvent.itemName),
                              theEvent.quant, stringPrice, theEvent.guild, textTime) .. alertSuffix)
            end
          end

          -- Chat alert
          if settingsToUse.showChatAlerts then
            if self.locale == 'de' then
              if theEvent.quant > 1 then
                CHAT_SYSTEM:AddMessage(string.format(MasterMerchant.concat(GetString(MM_APP_MESSAGE_NAME), GetString(SK_SALES_ALERT)),
                                      theEvent.quant, zo_strformat('<<t:1>>', theEvent.itemName), stringPrice, theEvent.guild, self.TextTimeSince(theEvent.saleTime, true)))
              else
                CHAT_SYSTEM:AddMessage(string.format(MasterMerchant.concat(GetString(MM_APP_MESSAGE_NAME), GetString(SK_SALES_ALERT_SINGLE)),
                                      zo_strformat('<<t:1>>', theEvent.itemName), stringPrice, theEvent.guild, self.TextTimeSince(theEvent.saleTime, true)))
              end
            else
              CHAT_SYSTEM:AddMessage(string.format(MasterMerchant.concat(GetString(MM_APP_MESSAGE_NAME), GetString(SK_SALES_ALERT)),
                                    zo_strformat('<<t:1>>', theEvent.itemName), theEvent.quant, stringPrice, theEvent.guild, self.TextTimeSince(theEvent.saleTime, true)))
            end
          end
        end
      end

      -- Otherwise, we'll just alert once with a summary at the end
      if not settingsToUse.showMultiple and numAlerts > 1 then
        -- Insert thousands separators for the price
        local stringPrice = self.LocalizedNumber(totalGold)

        if settingsToUse.showAnnounceAlerts then
          CENTER_SCREEN_ANNOUNCE:AddMessage('MasterMerchantAlert', CSA_EVENT_SMALL_TEXT, settingsToUse.alertSoundName,
            string.format(GetString(SK_SALES_ALERT_GROUP_COLOR), numSold, stringPrice))
        else
          CHAT_SYSTEM:AddMessage(string.format(MasterMerchant.concat(GetString(MM_APP_MESSAGE_NAME), GetString(SK_SALES_ALERT_GROUP)),
                                numSold, stringPrice))
        end
      end
    end
  end
  
  self:SpecialMessage(false)
  
  -- Set the stats slider past the max if this is brand new data
  if self.isFirstScan and doAlert then MasterMerchantStatsWindowSlider:SetValue(15) end
  self.isFirstScan = false
  -- We only have to refresh scroll list data if the window is actually visible; methods
  -- to show these windows refresh data before display
  if settingsToUse.viewSize == ITEMS then
    if not MasterMerchantWindow:IsHidden() then 
      self.scrollList:RefreshData()
    else 
      self.listIsDirty[ITEMS] = true 
    end
    self.listIsDirty[GUILDS] = true
    self.listIsDirty[LISTINGS] = true
  elseif settingsToUse.viewSize == GUILDS then
    if not MasterMerchantGuildWindow:IsHidden() then 
      self.guildScrollList:RefreshData()
    else 
      self.listIsDirty[GUILDS] = true 
    end
    self.listIsDirty[ITEMS] = true
    self.listIsDirty[LISTINGS] = true
  else 
    if not MasterMerchantListingWindow:IsHidden() then 
      self.listingScrollList:RefreshData()
    else 
      self.listIsDirty[LISTINGS] = true 
    end
    self.listIsDirty[ITEMS] = true
    self.listIsDirty[GUILDS] = true
  end 

end

-- Makes sure all the necessary data is there, and adds the passed-in event theEvent
-- to the SalesData table.  If doAlert is true, also adds it to alertQueue,
-- which means an alert may fire during PostScan.
function MasterMerchant:InsertEvent(theEvent, doAlert, checkForDups)
  local thePlayer = string.lower(GetDisplayName())
  local settingsToUse = MasterMerchant:ActiveSettings()

  if theEvent.itemName ~= nil and theEvent.seller ~= nil and theEvent.buyer ~= nil and theEvent.salePrice ~= nil then
    -- Insert the entry into the SalesData table and associated indexes
    local added = MasterMerchant:addToHistoryTables(theEvent, checkForDups)

    -- And then, if it's the player's sale, check here if it's the initial
    -- scan and they want offline sales reports, or if they've enabled chat/on-screen alerts
    -- and it's appropriate to do so (doAlert is false for resets so you don't get spammed.)
    -- If so, add the event to the alert queue for PostScan to pick up.
    if added and not self.veryFirstScan and string.lower(theEvent.seller) == thePlayer and ((self.isFirstScan and settingsToUse.offlineSales) or
       (doAlert and (settingsToUse.showChatAlerts or settingsToUse.showAnnounceAlerts))) then
        table.insert(self.alertQueue, theEvent)
    end
  end
end

  
function MasterMerchant:ProcessSome(guildNum, lastSaleTime, startIndex, endIndex, loopIncrement)
  
    local addedEvents = 0
    local guildID = GetGuildId(guildNum)
    local guildName = GetGuildName(guildID)
    
    local guildMemberInfo = {}
    -- Index the table with the account names themselves as they're
    -- (hopefully!) unique - search much faster
    for i = 1, GetNumGuildMembers(guildID) do
      local guildMemInfo, _, _, _, _ = GetGuildMemberInfo(guildID, i)
      guildMemberInfo[string.lower(guildMemInfo)] = true
    end

    for i = startIndex, endIndex, loopIncrement do
      local theEvent = {}
      theEvent.eventType, theEvent.secsSince, theEvent.seller, theEvent.buyer,
      theEvent.quant, theEvent.itemName, theEvent.salePrice = GetGuildEventInfo(guildID, GUILD_HISTORY_STORE, i)
      theEvent.guild = guildName
      theEvent.saleTime = GetTimeStamp() - theEvent.secsSince

      -- as we move toward the newest event always set the newest item we've seen 
      -- because they may logoff during the scanning loop and we would end up adding the same event twice
      self.systemSavedVariables.newestItem[guildName] = theEvent.saleTime 

      if theEvent.eventType == GUILD_EVENT_ITEM_SOLD and theEvent.eventType ~= GUILD_HISTORY_STORE_HIRED_TRADER and theEvent.eventType ~= GUILD_EVENT_GUILD_KIOSK_PURCHASED then

        --DEBUG
        --if theEvent.eventType ~= GUILD_EVENT_ITEM_SOLD then d(theEvent) end
        
        
        -- If we didn't add an entry to guildMemberInfo earlier setting the
        -- buyer's name index to true, then this was either bought at a kiosk
        -- or the buyer left the guild after buying but before we scanned.
        -- Close enough!
        theEvent.kioskSale = (guildMemberInfo[string.lower(theEvent.buyer)] == nil)
        --theEvent.itemName = self:UpdateItemLink(theEvent.itemName)
        theEvent.id = Id64ToString(GetGuildEventId(guildID, GUILD_HISTORY_STORE, i))

        -- Now that we know when the last sale in that guild happened, check the timestamp of this event against that one.
        -- Yes, we'll miss sales that happened the SAME second as one we've already seen but somehow didn't get with the
        -- previous scan, but that's life. :P  If checkOlder is true, then we'll call InsertEvent with the second parameter
        -- false so it knows not to add it to the alert queue (unless it's the first scan after login and they want an
        -- offline sales report).

        -- Don't trust ZOS at all, always check for Dups, except for the very first scan to save some time
        addedEvents = addedEvents + 1 
        self:InsertEvent(theEvent, (not checkOlder), not self.veryFirstScan)

        --[[
        if GetDiffBetweenTimeStamps(theEvent.saleTime, lastSaleTime) > 4 then
          addedEvents = addedEvents + 1 
          --DEBUG
          --d(theEvent.saleTime .. ' - ' .. lastSaleTime)
          self:InsertEvent(theEvent, (not checkOlder), false)
        elseif self.checkingForMissingSales or GetDiffBetweenTimeStamps(theEvent.saleTime, lastSaleTime) > -3 then
          addedEvents = addedEvents + 1 
          self:InsertEvent(theEvent, (not checkOlder), true)
        end
        --]]

        if GuildSalesAssistant and GuildSalesAssistant.MasterMerchantEdition then
          GuildSalesAssistant:InsertEvent(theEvent)
        end

        if addedEvents > 100 then
          --DEBUG
          --d(addedEvents)
          startIndex = i + loopIncrement
          break
        end
      end
    end

    if addedEvents <= 100 then
      startIndex = 0
      endIndex = 0
      loopIncrement = 0
    end
    
    return startIndex, endIndex, loopIncrement

  end
  
-- Actually carries out of the scan of a specific guild store's sales history.
-- Grabs all the members of the guild first to determine if a sale came from the
-- guild's kiosk (guild trader) or not.
-- Calls InsertEvent to actually insert the event into the ScanResults table;
-- afterwards, will start scan of the next guild or call postscan if no more guilds.
function MasterMerchant:DoScan(guildNum, checkOlder, doAlert, lastSaleTime, startIndex, endIndex, loopIncrement)
  
  local guildID = GetGuildId(guildNum)
  local numEvents = GetNumGuildEvents(guildID, GUILD_HISTORY_STORE)
  local guildName = GetGuildName(guildID)
  
  if loopIncrement ~= nil and loopIncrement ~= 0 then
    startIndex, endIndex, loopIncrement = self:ProcessSome(guildNum, lastSaleTime, startIndex, endIndex, loopIncrement)
  else
    local prevEvents = 0

    if self.numEvents[guildName] ~= nil then prevEvents = self.numEvents[guildName] end

    if numEvents > prevEvents then

      --d('|cFFFF00Processing ' .. numEvents - prevEvents .. ' records in ' .. guildName .. '.|r')

      -- Depending on what order the API returned events in, new events
      -- are either at the start (index 1 is newest item) or the end
      -- (last index is the newest item).  Really ZOS?
      startIndex = prevEvents + 1
      endIndex = numEvents
      loopIncrement = 1

      if self.IsNewestFirst(guildID) then
        startIndex = numEvents - prevEvents
        endIndex = 1
        loopIncrement = -1
      end  

      -- We'll grab the most recent sale from this guild, if any, to use as a timestamp
      -- to check against.  If no data can be found for this guild, we'll default
      -- to the time of the last scan (little less precise).
      lastSaleTime = self.systemSavedVariables.newestItem[guildName] or self.systemSavedVariables.lastScan[guildName] or 0
      --DEBUG
      --d('Lastsale:' .. lastSaleTime)
      if GuildSalesAssistant and GuildSalesAssistant.MasterMerchantEdition then
        GuildSalesAssistant:InitLastSaleTime(guildName)
      end

      startIndex, endIndex, loopIncrement = self:ProcessSome(guildNum, lastSaleTime, startIndex, endIndex, loopIncrement)
    else
      loopIncrement = 0;
    end
  end

  -- if it's just yielded to us wait a little bit then continue
  if loopIncrement ~= 0 then
    zo_callLater(function() self:DoScan(guildNum, checkOlder, doAlert, lastSaleTime, startIndex, endIndex, loopIncrement) end, 50)
    return
  end
  
  -- We got through any new (to us) events, so update the timestamp and number of events
  self.systemSavedVariables.lastScan[guildName] = self.requestTimestamp
  self.numEvents[guildName] = numEvents

  if GuildSalesAssistant and GuildSalesAssistant.MasterMerchantEdition then
    GuildSalesAssistant:GuildScanDone(guildName, self.requestTimestamp)
  end

  --d('|cFFFF00Finished adding events from ' .. guildName .. '.|r')
  
  -- If we have another guild to scan, see if we need to check older and scan it
  if guildNum < GetNumGuilds() then
    local nextGuild = guildNum + 1
    local nextGuildID = GetGuildId(nextGuild)
    local nextGuildName = GetGuildName(nextGuildID)

    -- If we don't have any event info for the next guild, do a deep scan
    local nextCheckOlder = (self.numEvents[nextGuildName] == nil or self.numEvents[nextGuildName] == 0)
    self.requestTimestamp = GetTimeStamp()
    RequestGuildHistoryCategoryNewest(nextGuildID, GUILD_HISTORY_STORE)
    if nextCheckOlder then 
        zo_callLater(function() self:ScanOlder(nextGuild, doAlert) end, 1500)
    else 
        zo_callLater(function() self:DoScan(nextGuild, false, doAlert) end, 1500) 
    end
  -- Otherwise, start the postscan routines
  else
    self.isScanning = false
    self.checkingForMissingSales = false
    MasterMerchantResetButton:SetEnabled(true)
    MasterMerchantGuildResetButton:SetEnabled(true)
    MasterMerchantRefreshButton:SetEnabled(true)
    MasterMerchantGuildRefreshButton:SetEnabled(true)
    MasterMerchantWindowLoadingIcon:SetHidden(true)
    MasterMerchantWindowLoadingIcon.animation:Stop()
    MasterMerchantGuildWindowLoadingIcon:SetHidden(true)
    MasterMerchantGuildWindowLoadingIcon.animation:Stop()
    MasterMerchantGuildWindowLoadingIcon:SetHidden(true)
    MasterMerchantGuildWindowLoadingIcon.animation:Stop()
    self:PostScan(doAlert)
  end

end

-- Repeatedly checks for older events until there aren't anymore,
-- then calls DoScan to pick up sales events
function MasterMerchant:ScanOlder(guildNum, doAlert, oldNumEvents, badLoads)
  local guildID = GetGuildId(guildNum)
  local guildName = GetGuildName(guildID)
  local numEvents = GetNumGuildEvents(guildID, GUILD_HISTORY_STORE)
  local _, secsSinceFirst, _, _, _, _, _, _ = GetGuildEventInfo(guildID, GUILD_HISTORY_STORE, 1)
  local _, secsSinceLast, _, _, _, _, _, _ = GetGuildEventInfo(guildID, GUILD_HISTORY_STORE, numEvents)
  local timeToUse = GetTimeStamp() - math.max(secsSinceFirst, secsSinceLast)
  badLoads = badLoads or 0
  oldNumEvents = oldNumEvents or 0

  --DEBUG remove true 
  if self.veryFirstScan or self.checkingForMissingSales then
    d(MasterMerchant.concat(guildName, ZO_FormatDurationAgo(math.max(secsSinceFirst, secsSinceLast))))
  end
  
  if numEvents > 0 then
    -- If there's more events and we haven't run past the timestamp we've seen
    -- previously, recurse.
    if numEvents > oldNumEvents then badLoads = 0 else badLoads = badLoads + 1 end

    if DoesGuildHistoryCategoryHaveMoreEvents(guildID, GUILD_HISTORY_STORE) and
       ( badLoads < 10) and 
       (self.checkingForMissingSales or
        self.systemSavedVariables.lastScan[guildName] == nil or
        timeToUse > self.systemSavedVariables.lastScan[guildName]) then
      RequestGuildHistoryCategoryOlder(guildID, GUILD_HISTORY_STORE)
      zo_callLater(function() self:ScanOlder(guildNum, doAlert, numEvents, badLoads) end, 1500)
    -- Otherwise we've got all the new stuff, so call DoScan.
    else zo_callLater(function() self:DoScan(guildNum, true, doAlert) end, 1500) end
  -- If there's no events in the guild, call DoScan just so later guilds get scanned
  -- Don't really need a delay in this case.
  else self:DoScan(guildNum, true, doAlert) end
end

-- Scans all stores a player has access to with delays between them.
function MasterMerchant:ScanStores(doAlert)
  -- If it's been less than 45 seconds since we last scanned the store,
  -- don't do it again so we don't hammer the server either accidentally
  -- or on purpose
  local timeLimit = GetTimeStamp() - 45
  local guildNum = GetNumGuilds()
  -- Nothing to scan!
  if guildNum == 0 then return end

  -- Grab some info about the first guild (since we now know there's at least one)
  local firstGuildID = GetGuildId(1)
  local firstGuildName = GetGuildName(firstGuildID)

  -- Right, let's actually request some events, assuming we haven't already done so recently
  if not self.isScanning and (doAlert or (self.systemSavedVariables.lastScan[firstGuildName] == nil) or (timeLimit > self.systemSavedVariables.lastScan[firstGuildName])) then
    self.isScanning = true
    MasterMerchantResetButton:SetEnabled(false)
    MasterMerchantGuildResetButton:SetEnabled(false)
    MasterMerchantRefreshButton:SetEnabled(false)
    MasterMerchantGuildRefreshButton:SetEnabled(false)
	  MasterMerchantWindowLoadingIcon:SetHidden(false)
	  MasterMerchantWindowLoadingIcon.animation:PlayForward()
	  MasterMerchantGuildWindowLoadingIcon:SetHidden(false)
	  MasterMerchantGuildWindowLoadingIcon.animation:PlayForward()
	  MasterMerchantGuildWindowLoadingIcon:SetHidden(false)
	  MasterMerchantGuildWindowLoadingIcon.animation:PlayForward()
    self.requestTimestamp = GetTimeStamp()
    RequestGuildHistoryCategoryNewest(firstGuildID, GUILD_HISTORY_STORE)

    -- If we are scanning for missing sales or have no event info for this guild, let's do a full scan
    if self.checkingForMissingSales or self.numEvents[firstGuildName] == nil or self.numEvents[firstGuildName] == 0 then 
        zo_callLater(function() self:ScanOlder(1, doAlert) end, 2000)
    -- Otherwise we'll assume 100 events haven't gone by since the last scan and just go straight to DoScan
    else 
        -- Let's always call Scan Older to make sure we don't miss something.
        zo_callLater(function() self:ScanOlder(1, doAlert) end, 2000)
        --zo_callLater(function() self:DoScan(1, false, doAlert) end, 1500) 
    end
  end
end

-- Handle the refresh button - do a scan if it's been more than a minute
-- since the last successful one.
function MasterMerchant:DoRefresh()
  local timeStamp = GetTimeStamp()

  -- If it's been less than 30 seconds since we last scanned the store,
  -- don't do it again so we don't hammer the server either accidentally
  -- or on purpose, otherwise add a message to chat updating the user and
  -- kick off the scan
  local timeLimit = timeStamp - 29
  local guildNum = GetNumGuilds()
  if guildNum > 0 then
    local firstGuildName = GetGuildName(1)
    if self.systemSavedVariables.lastScan[firstGuildName] == nil or timeLimit > self.systemSavedVariables.lastScan[firstGuildName] then
      CHAT_SYSTEM:AddMessage(MasterMerchant.concat(GetString(MM_APP_MESSAGE_NAME), GetString(SK_REFRESH_START)))
      self:ScanStores(true)

    else CHAT_SYSTEM:AddMessage(MasterMerchant.concat(GetString(MM_APP_MESSAGE_NAME), GetString(SK_REFRESH_WAIT))) end
  end
end

function MasterMerchant:initGMTools()
  -- Stub for GM Tools init
end

function MasterMerchant:initPurchaseTracking()
  -- Stub for Purchase Tracking init
end

function MasterMerchant:initSellingAdvice() 
  if MasterMerchant.originalSellingSetupCallback then return end
    
  local dataType = TRADING_HOUSE.m_postedItemsList.dataTypes[2]

  MasterMerchant.originalSellingSetupCallback = dataType.setupCallback
  if MasterMerchant.originalSellingSetupCallback then
      dataType.setupCallback = function(...)
          local row, data = ...
          MasterMerchant.originalSellingSetupCallback(...)
          zo_callLater(function() MasterMerchant.AddSellingAdvice(row, data) end, 25)
      end
  else
      d(GetString(MM_ADVICE_ERROR))
  end    
end

function MasterMerchant.AddSellingAdvice(rowControl, result)
    local sellingAdvice = rowControl:GetNamedChild('SellingAdvice')
		if(not sellingAdvice) then
			local controlName = rowControl:GetName() .. 'SellingAdvice'
			sellingAdvice = rowControl:CreateControl(controlName, CT_LABEL)
      local anchorControl = rowControl:GetNamedChild('SellPrice')
			sellingAdvice:SetAnchor(RIGHT, anchorControl, RIGHT, -170, 6)
			sellingAdvice:SetFont('/esoui/common/fonts/univers67.otf|14|soft-shadow-thin')
	  end

    local sellerName, dealString, margin = zo_strsplit(';', result.sellerName)
    local dealValue = tonumber(dealString)
    if dealValue then 
      if dealValue > -1 then
        if MasterMerchant:ActiveSettings().saucy then
          sellingAdvice:SetText(margin .. ' |t16:16:EsoUI/Art/currency/currency_gold.dds|t')  
        else
          sellingAdvice:SetText(margin .. '%')  
        end
        local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, dealValue)
        if dealValue == 0 then r = 0.98; g = 0.01; b = 0.01; end
        sellingAdvice:SetColor(r, g, b, 1)
        sellingAdvice:SetHidden(false)    
      else
        sellingAdvice:SetHidden(true)
      end
      --local sellerControl = rowControl:GetNamedChild('SellerName')
      --sellerControl:SetText(zo_strsplit(';', sellerControl:GetText()))
    else
      sellingAdvice:SetHidden(true)
    end
    sellingAdvice = nil
end


function MasterMerchant:initBuyingAdvice() 
  if MasterMerchant.originalSetupCallback then return end
    
  local dataType = TRADING_HOUSE.m_searchResultsList.dataTypes[1]

  MasterMerchant.originalSetupCallback = dataType.setupCallback
  if MasterMerchant.originalSetupCallback then
      dataType.setupCallback = function(...)
          local row, data = ...
          MasterMerchant.originalSetupCallback(...)
          zo_callLater(function() MasterMerchant.AddBuyingAdvice(row, data) end, 25)
      end
  else
      d(GetString(MM_ADVICE_ERROR))
  end    
end

function MasterMerchant.AddBuyingAdvice(rowControl, result)
    local buyingAdvice = rowControl:GetNamedChild('BuyingAdvice')
		if(not buyingAdvice) then
			local controlName = rowControl:GetName() .. 'BuyingAdvice'
			buyingAdvice = rowControl:CreateControl(controlName, CT_LABEL)
            local anchorControl = rowControl:GetNamedChild('TimeRemaining')
			buyingAdvice:SetAnchor(RIGHT, anchorControl, LEFT, -20, 6)
			buyingAdvice:SetFont('/esoui/common/fonts/univers67.otf|14|soft-shadow-thin')
	  end
    
    local sellerName, dealString, margin = zo_strsplit(';', result.sellerName)
    --local margin = result.marginString
    local dealValue = tonumber(dealString)
    if dealValue then 
      if dealValue > -1 then
        if MasterMerchant:ActiveSettings().saucy then
          buyingAdvice:SetText(margin .. ' |t16:16:EsoUI/Art/currency/currency_gold.dds|t')  
        else
          buyingAdvice:SetText(margin .. '%')  
        end        
        local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, dealValue)
        if dealValue == 0 then r = 0.98; g = 0.01; b = 0.01; end
        buyingAdvice:SetColor(r, g, b, 1)
        buyingAdvice:SetHidden(false)    
      else
        buyingAdvice:SetHidden(true)
      end
      local sellerControl = rowControl:GetNamedChild('SellerName')
      sellerControl:SetText(zo_strsplit(';', sellerControl:GetText()))
    else
      buyingAdvice:SetHidden(true)
    end
    buyingAdvice = nil
end

function MasterMerchant:initRosterStats() 
  if MasterMerchant.originalRosterStatsCallback then return end
    
  self:InitRosterChanges()

  local dataType = GUILD_ROSTER_KEYBOARD.list.dataTypes[GUILD_MEMBER_DATA]

  MasterMerchant.originalRosterStatsCallback = dataType.setupCallback
  if MasterMerchant.originalRosterStatsCallback then
      dataType.setupCallback = function(...)
          local row, data = ...
          MasterMerchant.originalRosterStatsCallback(...)
          zo_callLater(function() MasterMerchant.AddRosterStats(row, data) end, 25)
      end
  else
      d(GetString(MM_ADVICE_ERROR))
  end    
end

function MasterMerchant:BuildMasterList()
    if not self.masterList then return end

    MasterMerchant.originalRosterBuildMasterList(self)
    
    local settingsToUse = MasterMerchant:ActiveSettings()

    for i = 1, #self.masterList do
        local data = self.masterList[i]
          local amountBought = 0
          if MasterMerchant.guildPurchases and 
             MasterMerchant.guildPurchases[self.guildName] and 
             MasterMerchant.guildPurchases[self.guildName].sellers and 
             MasterMerchant.guildPurchases[self.guildName].sellers[data.displayName] and 
             MasterMerchant.guildPurchases[self.guildName].sellers[data.displayName].sales then 
             amountBought = MasterMerchant.guildPurchases[self.guildName].sellers[data.displayName].sales[settingsToUse.rankIndexRoster or 1] or 0
          end
          data.bought = amountBought

          local amountSold = 0
          local saleCount = 0
          local priorWeek = 0
          if MasterMerchant.guildSales and 
             MasterMerchant.guildSales[self.guildName] and 
             MasterMerchant.guildSales[self.guildName].sellers and 
             MasterMerchant.guildSales[self.guildName].sellers[data.displayName] and 
             MasterMerchant.guildSales[self.guildName].sellers[data.displayName].sales then 
             amountSold = MasterMerchant.guildSales[self.guildName].sellers[data.displayName].sales[settingsToUse.rankIndexRoster or 1] or 0
             saleCount = MasterMerchant.guildSales[self.guildName].sellers[data.displayName].count[settingsToUse.rankIndexRoster or 1] or 0
             priorWeek = MasterMerchant.guildSales[self.guildName].sellers[data.displayName].sales[(settingsToUse.rankIndexRoster or 1) + 1] or 0
          end
          data.sold = amountSold
          data.count = saleCount

          --local perChange = -101
          --if (settingsToUse.rankIndexRoster == 1 or settingsToUse.rankIndexRoster == 3 or settingsToUse.rankIndexRoster == 4) and priorWeek > 0 then
          --   perChange = math.floor(((amountSold - priorWeek)/priorWeek) * 1000 + 0.5)/10
          --end
          --data.perChange = perChange
        
          data.perChange = math.floor(data.sold * 0.035)
    end
end

--/script ZO_SharedRightBackground:SetWidth(1088)
function MasterMerchant:InitRosterChanges()
  local additionalWidth = 360  -- Remember to up size of MM_ExtraBackground in xml

  GUILD_ROSTER_ENTRY_SORT_KEYS['bought'] = { tiebreaker = 'displayName', isNumeric = true }
  GUILD_ROSTER_ENTRY_SORT_KEYS['sold'] = { tiebreaker = 'displayName', isNumeric = true }
  GUILD_ROSTER_ENTRY_SORT_KEYS['count'] = { tiebreaker = 'displayName', isNumeric = true }
  GUILD_ROSTER_ENTRY_SORT_KEYS['perChange'] = { tiebreaker = 'sold', isNumeric = true }

  MasterMerchant.originalRosterBuildMasterList = ZO_GuildRosterManager.BuildMasterList
  ZO_GuildRosterManager.BuildMasterList = MasterMerchant.BuildMasterList

  local background = CreateControlFromVirtual(ZO_GuildRoster:GetName() .. 'MMBiggerBackground', ZO_GuildRoster, 'MM_ExtraBackground')
  background:SetAnchor(TOPLEFT, ZO_GuildRoster, TOPLEFT, 0, 0)
  background:SetDrawLayer(0)
  background:GetNamedChild('ImageLeft'):SetTextureCoords(0,(additionalWidth + 60)/1024,0,1)
  background:GetNamedChild('ImageLeft'):SetColor(1,1,1,.8)
  background:SetHidden(false)
    
  headers = ZO_GuildRosterHeaders
    
  local controlName = headers:GetName() .. 'Bought'
  local boughtHeader = CreateControlFromVirtual(controlName, headers, 'ZO_SortHeader')
  ZO_SortHeader_Initialize(boughtHeader, GetString(SK_PURCHASES_COLUMN), 'bought', ZO_SORT_ORDER_DOWN, TEXT_ALIGN_RIGHT, 'ZoFontGameLargeBold')

  local origWidth = ZO_GuildRoster:GetWidth()
  ZO_GuildRoster:SetWidth(origWidth + additionalWidth)
  local anchorControl = headers:GetNamedChild('Level')
  boughtHeader:SetAnchor(TOPLEFT, anchorControl, TOPRIGHT, 20, 0)
  anchorControl.sortHeaderGroup:AddHeader(boughtHeader)

  boughtHeader:SetDimensions(110,32)
  boughtHeader:SetHidden(false)

  controlName = headers:GetName() .. 'Sold'
  local soldHeader = CreateControlFromVirtual(controlName, headers, 'ZO_SortHeader')
  ZO_SortHeader_Initialize(soldHeader, GetString(SK_SALES_COLUMN), 'sold', ZO_SORT_ORDER_DOWN, TEXT_ALIGN_RIGHT, 'ZoFontGameLargeBold')
  boughtHeader.sortHeaderGroup:AddHeader(soldHeader)
  soldHeader:SetAnchor(LEFT, boughtHeader, RIGHT, 0, 0)
  soldHeader:SetDimensions(110,32)
  soldHeader:SetHidden(false)

  controlName = headers:GetName() .. 'PerChg'
  local percentHeader = CreateControlFromVirtual(controlName, headers, 'ZO_SortHeader')
  ZO_SortHeader_Initialize(percentHeader, GetString(SK_PER_CHANGE_COLUMN), 'perChange', ZO_SORT_ORDER_DOWN, TEXT_ALIGN_RIGHT, 'ZoFontGameLargeBold')
  boughtHeader.sortHeaderGroup:AddHeader(percentHeader)
  percentHeader:SetAnchor(LEFT, soldHeader, RIGHT, 10, 0)
  percentHeader:SetDimensions(70,32)
  percentHeader:SetHidden(false)
  percentHeader.data = {
    tooltipText = GetString(SK_PER_CHANGE_TIP)
  }
  percentHeader:SetMouseEnabled(true)
  percentHeader:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
  percentHeader:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)


  controlName = headers:GetName() .. 'Count'
  local countHeader = CreateControlFromVirtual(controlName, headers, 'ZO_SortHeader')
  ZO_SortHeader_Initialize(countHeader, GetString(SK_COUNT_COLUMN), 'count', ZO_SORT_ORDER_DOWN, TEXT_ALIGN_RIGHT, 'ZoFontGameLargeBold')
  boughtHeader.sortHeaderGroup:AddHeader(countHeader)
  countHeader:SetAnchor(LEFT, percentHeader, RIGHT, 0, 0)
  countHeader:SetDimensions(80,32)
  countHeader:SetHidden(false)

  local settingsToUse = MasterMerchant:ActiveSettings()
   -- Guild Time dropdown choice box
  local MasterMerchantGuildTime = CreateControlFromVirtual('MasterMerchantRosterTimeChooser', ZO_GuildRoster, 'MasterMerchantStatsGuildDropdown')
  MasterMerchantGuildTime:SetDimensions(180,25)
  MasterMerchantGuildTime:SetAnchor(TOPRIGHT, ZO_GuildRoster, BOTTOMRIGHT, -120, -5)
  MasterMerchantGuildTime.m_comboBox:SetSortsItems(false)
  
  local timeDropdown = ZO_ComboBox_ObjectFromContainer(MasterMerchantRosterTimeChooser)
  timeDropdown:ClearItems()
  
  settingsToUse.rankIndexRoster = settingsToUse.rankIndexRoster or 1
  
  local timeEntry = timeDropdown:CreateItemEntry(GetString(MM_INDEX_TODAY), function() self:UpdateRosterWindow(1) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndexRoster == 1 then timeDropdown:SetSelectedItem(GetString(MM_INDEX_TODAY)) end
  
  timeEntry = timeDropdown:CreateItemEntry(GetString(MM_INDEX_3DAY), function() self:UpdateRosterWindow(2) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndexRoster == 2 then timeDropdown:SetSelectedItem(GetString(MM_INDEX_3DAY)) end
  
  timeEntry = timeDropdown:CreateItemEntry(GetString(MM_INDEX_THISWEEK), function() self:UpdateRosterWindow(3) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndexRoster == 3 then timeDropdown:SetSelectedItem(GetString(MM_INDEX_THISWEEK)) end
  
  timeEntry = timeDropdown:CreateItemEntry(GetString(MM_INDEX_LASTWEEK), function() self:UpdateRosterWindow(4) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndexRoster == 4 then timeDropdown:SetSelectedItem(GetString(MM_INDEX_LASTWEEK)) end
  
  timeEntry = timeDropdown:CreateItemEntry(GetString(MM_INDEX_PRIORWEEK), function() self:UpdateRosterWindow(5) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndexRoster == 5 then timeDropdown:SetSelectedItem(GetString(MM_INDEX_PRIORWEEK)) end
  
  timeEntry = timeDropdown:CreateItemEntry(GetString(MM_INDEX_7DAY), function() self:UpdateRosterWindow(8) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndexRoster == 8 then timeDropdown:SetSelectedItem(GetString(MM_INDEX_7DAY)) end
  
  timeEntry = timeDropdown:CreateItemEntry(GetString(MM_INDEX_10DAY), function() self:UpdateRosterWindow(6) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndexRoster == 6 then timeDropdown:SetSelectedItem(GetString(MM_INDEX_10DAY)) end
      
  timeEntry = timeDropdown:CreateItemEntry(GetString(MM_INDEX_28DAY), function() self:UpdateRosterWindow(7) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndexRoster == 7 then timeDropdown:SetSelectedItem(GetString(MM_INDEX_28DAY)) end

  timeEntry = timeDropdown:CreateItemEntry(settingsToUse.customTimeframeText, function() self:UpdateRosterWindow(9) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndexRoster == 9 then timeDropdown:SetSelectedItem(settingsToUse.customTimeframeText) end

  GUILD_ROSTER_MANAGER:RefreshData()

end

function MasterMerchant.AddRosterStats(rowControl, result)

    if result == nil then return end

    local settingsToUse = MasterMerchant:ActiveSettings()
    local anchorControl
    local bought = rowControl:GetNamedChild('Bought')

		if(not bought) then
			local controlName = rowControl:GetName() .. 'Bought'
			bought = rowControl:CreateControl(controlName, CT_LABEL)
      anchorControl = rowControl:GetNamedChild('Level')
			bought:SetAnchor(LEFT, anchorControl, RIGHT, 0, 0)
			bought:SetFont('ZoFontGame')
      bought:SetWidth(110)
      bought:SetHidden(false)    
      bought:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

      local level = rowControl:GetNamedChild('Level')
      local note = rowControl:GetNamedChild('Note')
      note:ClearAnchors()
      note:SetAnchor(LEFT, level, RIGHT, -18, 0)
	  end
    
    local sold = rowControl:GetNamedChild('Sold')
		if(not sold) then
			local controlName = rowControl:GetName() .. 'Sold'
			sold = rowControl:CreateControl(controlName, CT_LABEL)
			sold:SetAnchor(LEFT, bought, RIGHT, 0, 0)
			sold:SetFont('ZoFontGame')
      sold:SetWidth(110)
      sold:SetHidden(false) 
      sold:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	  end

    local percent = rowControl:GetNamedChild('Percent')
		if(not percent) then
			local controlName = rowControl:GetName() .. 'Percent'
			percent = rowControl:CreateControl(controlName, CT_LABEL)
			percent:SetAnchor(LEFT, sold, RIGHT, 0, 0)
			percent:SetFont('ZoFontGame')
      percent:SetWidth(80)
      percent:SetHidden(false) 
      percent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	  end

    local count = rowControl:GetNamedChild('Count')
		if(not count) then
			local controlName = rowControl:GetName() .. 'Count'
			count = rowControl:CreateControl(controlName, CT_LABEL)
			count:SetAnchor(LEFT, percent, RIGHT, 0, 0)
			count:SetFont('ZoFontGame')
      count:SetWidth(65)
      count:SetHidden(false) 
      count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	  end

    local stringBought = MasterMerchant.LocalizedNumber(result.bought)
    bought:SetText(stringBought .. ' |t16:16:EsoUI/Art/currency/currency_gold.dds|t')

    local stringSold = MasterMerchant.LocalizedNumber(result.sold)
    sold:SetText(stringSold .. ' |t16:16:EsoUI/Art/currency/currency_gold.dds|t')

    --local stringPercent = '---'
    --if result.perChange ~= -101 then
    --   stringPercent = MasterMerchant.LocalizedNumber(result.perChange) .. '%'
    --end    
    --percent:SetText(stringPercent)
    local stringPercent = MasterMerchant.LocalizedNumber(math.floor(result.sold * 0.035))
    percent:SetText(stringPercent .. ' |t16:16:EsoUI/Art/currency/currency_gold.dds|t')

    local stringCount = MasterMerchant.LocalizedNumber(result.count)
    count:SetText(stringCount)
end




-- Handle the reset button - clear out the search and scan tables,
-- and set the time of the last scan to nil, then force a scan.
function MasterMerchant:DoReset()
  self.salesData = {}
  self.SRIndex = {}
  self.SSIndex = {}
  
  MM00Data.savedVariables.SalesData = {}
  MM01Data.savedVariables.SalesData = {}
  MM02Data.savedVariables.SalesData = {}
  MM03Data.savedVariables.SalesData = {}
  MM04Data.savedVariables.SalesData = {}
  MM05Data.savedVariables.SalesData = {}
  MM06Data.savedVariables.SalesData = {}
  MM07Data.savedVariables.SalesData = {}
  MM08Data.savedVariables.SalesData = {}
  MM09Data.savedVariables.SalesData = {}
  MM10Data.savedVariables.SalesData = {}
  MM11Data.savedVariables.SalesData = {}
  MM12Data.savedVariables.SalesData = {}
  MM13Data.savedVariables.SalesData = {}
  MM14Data.savedVariables.SalesData = {}
  MM15Data.savedVariables.SalesData = {}
  
  self.guildPurchases = {}
  self.guildSales = {}
  self.guildItems = {}
  self.myItems = {}
  self.systemSavedVariables.lastScan = {}
  if MasterMerchantGuildWindow:IsHidden() then MasterMerchant.scrollList:RefreshData()
  else MasterMerchant.guildScrollList:RefreshData() end
  self.isScanning = false
  self.numEvents = {}
  self.systemSavedVariables.newestItem = {}
  CHAT_SYSTEM:AddMessage(MasterMerchant.concat(GetString(MM_APP_MESSAGE_NAME), GetString(SK_RESET_DONE)))
  CHAT_SYSTEM:AddMessage(MasterMerchant.concat(GetString(MM_APP_MESSAGE_NAME), GetString(SK_REFRESH_START)))
  self.veryFirstScan = true
  self:ScanStores(true)
end

function MasterMerchant:AdjustItems(otherData)
  if not (otherData.savedVariables.ItemsConverted or false) then 
    local somethingConverted = false
    for k, v in pairs(otherData.savedVariables.SalesData) do
        for j, dataList in pairs(v) do
            for i = 1, #dataList.sales, 1 do
                dataList.sales[i].itemLink = self:UpdateItemLink(dataList.sales[i].itemLink)
                somethingConverted = true
            end
        end
    end
    otherData.savedVariables.ItemsConverted = true
    if somethingConverted then
      EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function() 
        ReloadUI('ingame')
      end)
      error(otherData.name .. ' converted.  Please /reloadui to convert the next file...')    
    end
  end
end


function MasterMerchant:ReferenceSales(otherData)
  for k, v in pairs(otherData.savedVariables.SalesData) do
    self.salesData[k] = v
  end
end

function MasterMerchant:ReIndexSales(otherData)
  local needToReindex = false
  local needToAddDescription = false
  for _, v in pairs(otherData.savedVariables.SalesData) do
    if v then 
      for j, dataList in pairs(v) do
        local _, count = string.gsub(j, ':', ':')
        needToReindex = (count ~= 4) 
        needToAddDescription = (dataList['itemDesc'] == nil)
        break
      end
      break
    end
  end
  if needToReindex then
    local tempSales = otherData.savedVariables.SalesData
    otherData.savedVariables.SalesData = {}
    
    for k, v in pairs(tempSales) do
      for j, dataList in pairs(v) do
        for i, item in ipairs(dataList['sales']) do
          local itemIndex = self.makeIndexFromLink(item.itemLink)
          if not otherData.savedVariables.SalesData[k] then otherData.savedVariables.SalesData[k] = {} end
          if otherData.savedVariables.SalesData[k][itemIndex] then
            table.insert(otherData.savedVariables.SalesData[k][itemIndex]['sales'], item)
          else
            otherData.savedVariables.SalesData[k][itemIndex] = {
              ['itemIcon'] = dataList.itemIcon,
              ['itemAdderText'] = self.addedSearchToItem(item.itemLink),
              ['sales'] = {item},
              ['itemDesc'] = GetItemLinkName(item.itemLink)
            }
          end          
        end
      end 
    end
  elseif needToAddDescription then
    -- spin through and split Item Description into a seperate string
    for _, v in pairs(otherData.savedVariables.SalesData) do
      for _, dataList in pairs(v) do
        _, item = next(dataList['sales'], nil) 
        dataList['itemAdderText'] = self.addedSearchToItem(item.itemLink)
        dataList['itemDesc'] = GetItemLinkName(item.itemLink)
      end
    end
  elseif (not self.systemSavedVariables.switchedToChampionRanks) and (GetAPIVersion() >= 100015) then
    for _, v in pairs(otherData.savedVariables.SalesData) do
      for _, dataList in pairs(v) do
        _, item = next(dataList['sales'], nil) 
        dataList['itemAdderText'] = self.addedSearchToItem(item.itemLink)
      end
    end
  end
  self.systemSavedVariables.switchedToChampionRanks = (GetAPIVersion() >= 100015)
end

function MasterMerchant.SetupPendingPost(self)
	OriginalSetupPendingPost(self)
	
	if (self.m_pendingItemSlot) then
		local itemLink = GetItemLink(BAG_BACKPACK, self.m_pendingItemSlot)
		local _, stackCount, _ = GetItemInfo(BAG_BACKPACK, self.m_pendingItemSlot)
    
    local settingsToUse = MasterMerchant:ActiveSettings()
    
    local theIID = string.match(itemLink, '|H.-:item:(.-):')
    local itemIndex = MasterMerchant.makeIndexFromLink(itemLink)
    
    if settingsToUse.pricingData and settingsToUse.pricingData[tonumber(theIID)] and settingsToUse.pricingData[tonumber(theIID)][itemIndex] then		
			self:SetPendingPostPrice(math.floor(settingsToUse.pricingData[tonumber(theIID)][itemIndex] * stackCount))
		else
      local tipStats = MasterMerchant:itemStats(itemLink)
      if (tipStats.avgPrice) then
        self:SetPendingPostPrice(math.floor(tipStats.avgPrice * stackCount))
      end
		end
	end
end

-- Init function
function MasterMerchant:Initialize()
  -- SavedVar defaults
  local Defaults =  {
    ['showChatAlerts'] = false,
    ['showMultiple'] = true,
    ['openWithMail'] = true,
    ['openWithStore'] = true,
    ['showFullPrice'] = true,
    ['winLeft'] = 30,
    ['winTop'] = 30,
    ['guildWinLeft'] = 30,
    ['guildWinTop'] = 30,
    ['statsWinLeft'] = 720,    
    ['statsWinTop'] = 820,
    ['feedbackWinLeft'] = 720,
    ['feedbackWinTop'] = 420,
    ['windowFont'] = 'ProseAntique',
    ['historyDepth'] = 30,
    ['scanFreq'] = 120,
    ['showAnnounceAlerts'] = true,
    ['showCyroAlerts'] = true,
    ['alertSoundName'] = 'Book_Acquired',
    ['showUnitPrice'] = false,
    ['viewSize'] = ITEMS,
    ['offlineSales'] = true,
    ['showPricing'] = true,
    ['showGraph'] = true,
    ['showCalc'] = true,
    ['rankIndex'] = 1,
    ['rankIndexRoster'] = 1,
    ['viewBuyerSeller'] = 'buyer',
    ['viewGuildBuyerSeller'] = 'seller',
    ['trimOutliers'] = false,
    ['trimDecimals'] = false,
    ['replaceInventoryValues'] = false,
    ['delayInit'] = false,
    ['diplayGuildInfo'] = false,
    ['displaySalesDetails'] = false,
    ['displayItemAnalysisButtons'] = false,
    ['noSalesInfoDeal'] = 2,
    ['focus1'] = 10,
    ['focus2'] = 3,
    ['blacklist'] = '',
    ['defaultDays'] = GetString(MM_RANGE_ALL),
    ['shiftDays'] = GetString(MM_RANGE_FOCUS1),
    ['ctrlDays'] = GetString(MM_RANGE_FOCUS2),
    ['ctrlShiftDays'] = GetString(MM_RANGE_NONE),
    ['saucy'] = false,
    ['autoNext'] = false,
    ['displayListingMessage'] = false,
  }

  local acctDefaults = {
    ['lastScan'] = {},
    ['newestItem'] = {},
    ['SalesData'] = {},
    ['SSIndex'] = {},
    ['allSettingsAccount'] = false,
    ['showChatAlerts'] = false,
    ['showMultiple'] = true,
    ['openWithMail'] = true,
    ['openWithStore'] = true,
    ['showFullPrice'] = true,
    ['winLeft'] = 30,
    ['winTop'] = 30,
    ['guildWinLeft'] = 30,
    ['guildWinTop'] = 30,
    ['statsWinLeft'] = 720,
    ['statsWinTop'] = 820,
    ['feedbackWinLeft'] = 720,
    ['feedbackWinTop'] = 420,
    ['windowFont'] = 'ProseAntique',
    ['historyDepth'] = 30,
    ['scanFreq'] = 120,
    ['showAnnounceAlerts'] = true,
    ['showCyroAlerts'] = true,
    ['alertSoundName'] = 'Book_Acquired',
    ['showUnitPrice'] = false,
    ['viewSize'] = ITEMS,
    ['offlineSales'] = true,
    ['showPricing'] = true,
    ['showGraph'] = true,
    ['showCalc'] = true,
    ['rankIndex'] = 1,
    ['rankIndexRoster'] = 1,
    ['viewBuyerSeller'] = 'buyer',
    ['viewGuildBuyerSeller'] = 'seller',
    ['trimOutliers'] = false,
    ['trimDecimals'] = false,
    ['replaceInventoryValues'] = false,
    ['delayInit'] = false,
    ['diplayGuildInfo'] = false,
    ['displaySalesDetails'] = false,
    ['displayItemAnalysisButtons'] = false,
    ['noSalesInfoDeal'] = 2,
    ['focus1'] = 10,
    ['focus2'] = 3,
    ['blacklist'] = '',
    ['defaultDays'] = GetString(MM_RANGE_ALL),
    ['shiftDays'] = GetString(MM_RANGE_FOCUS1),
    ['ctrlDays'] = GetString(MM_RANGE_FOCUS2),
    ['ctrlShiftDays'] = GetString(MM_RANGE_NONE),
    ['saucy'] = false,
    ['autoNext'] = false,
    ['displayListingMessage'] = false,
  }

  -- Populate savedVariables
  self.savedVariables = ZO_SavedVars:New('ShopkeeperSavedVars', 1, GetDisplayName(), Defaults)
  self.acctSavedVariables = ZO_SavedVars:NewAccountWide('ShopkeeperSavedVars', 1, GetDisplayName(), acctDefaults)
  self.systemSavedVariables = ZO_SavedVars:NewAccountWide('ShopkeeperSavedVars', 1, nil, {}, nil, 'MasterMerchant')

  -- Convert the old linear sales history to the new format
  if self.acctSavedVariables.scanHistory then
    for i = 1, #self.acctSavedVariables.scanHistory do
      local v = self.acctSavedVariables.scanHistory[i]
      local theIID = string.match(v[3], '|H.-:item:(.-):')
      theIID = tonumber(theIID)
      local itemIndex = self.makeIndexFromLink(v[3])
      if not self.acctSavedVariables.SalesData[theIID] then self.acctSavedVariables.SalesData[theIID] = {} end
      if MasterMerchant.acctSavedVariables.SalesData[theIID][itemIndex] then
        table.insert(MasterMerchant.acctSavedVariables.SalesData[theIID][itemIndex]['sales'],
          {buyer = v[1], guild = v[2], itemLink = v[3], quant = v[5], timestamp = v[6], price = v[7], seller = v[8], wasKiosk = v[9]})
      else
        MasterMerchant.acctSavedVariables.SalesData[theIID][itemIndex] = {
          ['itemIcon'] = v[4],
          ['sales'] = {{buyer = v[1], guild = v[2], itemLink = v[3], quant = v[5], timestamp = v[6], price = v[7], seller = v[8], wasKiosk = v[9]}}}
      end

      -- We track newest sales items in a savedVar now since we don't have a linear list to easily grab from
      if not self.acctSavedVariables.newestItem[v[2]] then self.acctSavedVariables.newestItem[v[2]] = v[6]
      elseif self.acctSavedVariables.newestItem[v[2]] < v[6] then self.acctSavedVariables.newestItem[v[2]] = v[6] end
    end

    -- Now that we're done with it, clear it out and change the one setting that has changed in magnitude
    self.acctSavedVariables.scanHistory = nil

    self.systemSavedVariables.historyDepth = 30

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function() 
        ReloadUI('ingame')
    end)
    error('Please /reloadui to convert move to the next step...')  

  end

  -- Move the guild scanning variables to a system wide area
  if (self.systemSavedVariables.delayInit == nil) then
    self.systemSavedVariables.delayInit = self.acctSavedVariables.delayInit or false;
  end
  if (self.systemSavedVariables.newestItem == nil) then
    self.systemSavedVariables.newestItem = self.acctSavedVariables.newestItem or {};
  end
  if (self.systemSavedVariables.lastScan == nil) then
    self.systemSavedVariables.lastScan = self.acctSavedVariables.lastScan or {};
  end

  self.acctSavedVariables.delayInit = nil
  self.acctSavedVariables.newestItem = nil
  self.acctSavedVariables.lastScan = nil

  self.savedVariables.delayInit = nil
  self.savedVariables.newestItem = nil
  self.savedVariables.lastScan = nil

  -- Default in the 'focus' settings
  if (MasterMerchant:ActiveSettings().focus1 == nil) then
      MasterMerchant:ActiveSettings().focus1 = 10
      MasterMerchant:ActiveSettings().focus2 = 3
      MasterMerchant:ActiveSettings().defaultDays = GetString(MM_RANGE_ALL)
      MasterMerchant:ActiveSettings().shiftDays = GetString(MM_RANGE_FOCUS1)
      MasterMerchant:ActiveSettings().ctrlDays = GetString(MM_RANGE_FOCUS2)
      MasterMerchant:ActiveSettings().ctrlShiftDays = GetString(MM_RANGE_NONE)
  end

  if (MasterMerchant:ActiveSettings().customTimeframe == nil) then
    MasterMerchant:ActiveSettings().customTimeframe = 2
    MasterMerchant:ActiveSettings().customTimeframeType = GetString(MM_CUSTOM_TIMEFRAME_GUILD_WEEKS)
  end
  MasterMerchant:ActiveSettings().customTimeframeText = MasterMerchant:ActiveSettings().customTimeframe .. ' ' .. MasterMerchant:ActiveSettings().customTimeframeType

  if (MasterMerchant:ActiveSettings().blacklist == nil) then MasterMerchant:ActiveSettings().blacklist = '' end

  -- Move the historyDepth variable to a system wide area
  if (self.systemSavedVariables.historyDepth == nil) then
    self.systemSavedVariables.historyDepth = MasterMerchant:ActiveSettings().historyDepth or 30;
  end

  -- Default in the Min/Max Item count settings
  if (self.systemSavedVariables.minItemCount == nil) then
      self.systemSavedVariables.minItemCount = 20
      self.systemSavedVariables.maxItemCount = 5000
  end

  -- Default in the replace inventory values setting
  if (MasterMerchant:ActiveSettings().replaceInventoryValues == nil) then
      MasterMerchant:ActiveSettings().replaceInventoryValues = false
  end

  if (MasterMerchant:ActiveSettings().noSalesInfoDeal == nil) then 
    MasterMerchant:ActiveSettings().noSalesInfoDeal = 2
  end

  -- Move the old single addon sales history to the multi addon sales history
  if self.acctSavedVariables.SalesData then
    local action = {
      [0] = function (k, v) MM00Data.savedVariables.SalesData[k] = v end,
      [1] = function (k, v) MM01Data.savedVariables.SalesData[k] = v end,
      [2] = function (k, v) MM02Data.savedVariables.SalesData[k] = v end,
      [3] = function (k, v) MM03Data.savedVariables.SalesData[k] = v end,
      [4] = function (k, v) MM04Data.savedVariables.SalesData[k] = v end,
      [5] = function (k, v) MM05Data.savedVariables.SalesData[k] = v end,
      [6] = function (k, v) MM06Data.savedVariables.SalesData[k] = v end,
      [7] = function (k, v) MM07Data.savedVariables.SalesData[k] = v end,
      [8] = function (k, v) MM08Data.savedVariables.SalesData[k] = v end,
      [9] = function (k, v) MM09Data.savedVariables.SalesData[k] = v end,
      [10] = function (k, v) MM10Data.savedVariables.SalesData[k] = v end,
      [11] = function (k, v) MM11Data.savedVariables.SalesData[k] = v end,
      [12] = function (k, v) MM12Data.savedVariables.SalesData[k] = v end,
      [13] = function (k, v) MM13Data.savedVariables.SalesData[k] = v end,
      [14] = function (k, v) MM14Data.savedVariables.SalesData[k] = v end,
      [15] = function (k, v) MM15Data.savedVariables.SalesData[k] = v end
    }    
    
    for k, v in pairs(self.acctSavedVariables.SalesData) do
      local hash  
      for j, dataList in pairs(v) do
        local item = dataList['sales'][1]
        hash = MasterMerchant.hashString(string.lower(GetItemLinkName(item.itemLink)))          
        break
      end
      action[hash](k, v)
    end
    self.acctSavedVariables.SalesData = nil
  end

  -- Covert each data file as needed
  if GetAPIVersion() == 100011 then
    self:AdjustItems(MM00Data)
    self:AdjustItems(MM01Data)
    self:AdjustItems(MM02Data)
    self:AdjustItems(MM03Data)
    self:AdjustItems(MM04Data)
    self:AdjustItems(MM05Data)
    self:AdjustItems(MM06Data)
    self:AdjustItems(MM07Data)
    self:AdjustItems(MM08Data)
    self:AdjustItems(MM09Data)
    self:AdjustItems(MM10Data)
    self:AdjustItems(MM11Data)
    self:AdjustItems(MM12Data)
    self:AdjustItems(MM13Data)
    self:AdjustItems(MM14Data)
    self:AdjustItems(MM15Data)
  end
 
  -- Check for and reindex if the item structure has changed
  self:ReIndexSales(MM00Data)
  self:ReIndexSales(MM01Data)
  self:ReIndexSales(MM02Data)
  self:ReIndexSales(MM03Data)
  self:ReIndexSales(MM04Data)
  self:ReIndexSales(MM05Data)
  self:ReIndexSales(MM06Data)
  self:ReIndexSales(MM07Data)
  self:ReIndexSales(MM08Data)
  self:ReIndexSales(MM09Data)
  self:ReIndexSales(MM10Data)
  self:ReIndexSales(MM11Data)
  self:ReIndexSales(MM12Data)
  self:ReIndexSales(MM13Data)
  self:ReIndexSales(MM14Data)
  self:ReIndexSales(MM15Data)
  
  -- Bring seperate lists together we can still access the sales history all together
  self:ReferenceSales(MM00Data)
  self:ReferenceSales(MM01Data)
  self:ReferenceSales(MM02Data)
  self:ReferenceSales(MM03Data)
  self:ReferenceSales(MM04Data)
  self:ReferenceSales(MM05Data)
  self:ReferenceSales(MM06Data)
  self:ReferenceSales(MM07Data)
  self:ReferenceSales(MM08Data)
  self:ReferenceSales(MM09Data)
  self:ReferenceSales(MM10Data)
  self:ReferenceSales(MM11Data)
  self:ReferenceSales(MM12Data)
  self:ReferenceSales(MM13Data)
  self:ReferenceSales(MM14Data)
  self:ReferenceSales(MM15Data)

  if GuildSalesAssistant and GuildSalesAssistant.MasterMerchantEdition then 
      GuildSalesAssistant:InitializeMM()
      GuildSalesAssistant:LoadInitialData(self.salesData)
  end

  if not self.systemSavedVariables.delayInit then
    self:TruncateHistory()
    self:InitPurchaseHistory()
    self:InitItemHistory()
    self:InitSalesHistory()
    self:InitIndexes(false)
  else
    -- Queue them for later      
    local LEQ = LibStub('LibExecutionQueue-1.0')
    LEQ:Add(function () self:TruncateHistory() end, 'TruncateHistory')
    LEQ:Add(function () self:InitPurchaseHistory() end, 'InitPurchaseHistory')
    LEQ:Add(function () self:InitItemHistory() end, 'InitItemHistory')
    LEQ:Add(function () self:InitSalesHistory() end, 'InitSalesHistory')
    LEQ:Add(function () self:InitIndexes(true) end, 'InitIndexes')
    LEQ:Add(function () self:InitScrollLists() end, 'InitScrollLists')
  end

  -- We'll grab their locale now, it's really only used for a couple things as
  -- most localization is handled by the i18n/$(language).lua files
  -- Defaults to English because bias, that's why. :P
  self.locale = GetCVar('Language.2')
  if self.locale ~= 'en' and self.locale ~= 'de' and self.locale ~= 'fr' then
    self.locale = 'en'
  end

  self:setupGuildColors()
  
  -- Setup the options menu and main windows
  self:LibAddonInit()
  self:SetupMasterMerchantWindow()
  self:RestoreWindowPosition()

  -- Add the MasterMerchant window to the mail and trading house scenes if the
  -- player's settings indicate they want that behavior
  self.uiFragment = ZO_FadeSceneFragment:New(MasterMerchantWindow)
  self.guildUiFragment = ZO_FadeSceneFragment:New(MasterMerchantGuildWindow)


  Original_ZO_LinkHandler_OnLinkMouseUp = ZO_LinkHandler_OnLinkMouseUp
  ZO_LinkHandler_OnLinkMouseUp = function(itemLink, button, control) self:myZO_LinkHandler_OnLinkMouseUp(itemLink, button, control) end

  ZO_PreHook('ZO_InventorySlot_ShowContextMenu', function(rowControl) self:myZO_InventorySlot_ShowContextMenu(rowControl) end)

  local settingsToUse = MasterMerchant:ActiveSettings()
  local theFragment = ((settingsToUse.viewSize == ITEMS) and self.uiFragment) or ((settingsToUse.viewSize == GUILDS) and self.guildUiFragment) or self.listingUiFragment
    if settingsToUse.openWithMail then
    MAIL_INBOX_SCENE:AddFragment(theFragment)
    MAIL_SEND_SCENE:AddFragment(theFragment)
  end

  if settingsToUse.openWithStore then
    TRADING_HOUSE_SCENE:AddFragment(theFragment)
  end

  -- Because we allow manual toggling of the MasterMerchant window in those scenes (without
  -- making that setting permanent), we also have to hide the window on closing them
  -- if they're not part of the scene.
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_CLOSE_MAILBOX, function()
    if not settingsToUse.openWithMail then 
      self:ActiveWindow():SetHidden(true)
      MasterMerchantStatsWindow:SetHidden(true)
    end
  end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_TRADING_HOUSE, function()
    if not settingsToUse.openWithStore then 
      self:ActiveWindow():SetHidden(true)
      MasterMerchantStatsWindow:SetHidden(true)
    end
  end)

  -- We also want to make sure the MasterMerchant windows are hidden in the game menu
  ZO_PreHookHandler(ZO_GameMenu_InGame, 'OnShow', function()
    self:ActiveWindow():SetHidden(true)
    MasterMerchantStatsWindow:SetHidden(true)
    MasterMerchantFeedback:SetHidden(true)
  end)

  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE, function (eventCode, slotId, isPending)
    if settingsToUse.showCalc and isPending and GetSlotStackSize(1, slotId) > 1 then
      local theLink = GetItemLink(1, slotId, LINK_STYLE_DEFAULT)
      local theIID = string.match(theLink, '|H.-:item:(.-):')
      local theIData = self.makeIndexFromLink(theLink)
      local postedStats = self:toolTipStats(tonumber(theIID), theIData)
      MasterMerchantPriceCalculatorStack:SetText(GetString(MM_APP_TEXT_TIMES) .. GetSlotStackSize(1, slotId))
      local floorPrice = 0
      if postedStats.avgPrice then floorPrice = string.format('%.2f', postedStats['avgPrice']) end
      MasterMerchantPriceCalculatorUnitCostAmount:SetText(floorPrice)
      MasterMerchantPriceCalculatorTotal:SetText(GetString(MM_TOTAL_TITLE) .. self.LocalizedNumber(math.floor(floorPrice * GetSlotStackSize(1, slotId))) .. ' |t16:16:EsoUI/Art/currency/currency_gold.dds|t')
      MasterMerchantPriceCalculator:SetHidden(false)
    else MasterMerchantPriceCalculator:SetHidden(true) end
  end)
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, function (_, responseType, result)
    if responseType == TRADING_HOUSE_RESULT_POST_PENDING and result == TRADING_HOUSE_RESULT_SUCCESS then MasterMerchantPriceCalculator:SetHidden(true) end
    -- Set up guild store buying advice
    self:initBuyingAdvice()
    self:initSellingAdvice()
  end)

  -- I could do this with action layer pop/push, but it's kind've a pain
  -- when it's just these I want to hook
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK, function() self:ActiveWindow():SetHidden(true) end)
--    MasterMerchantWindow:SetHidden(true)
--    MasterMerchantGuildWindow:SetHidden(true)
--  end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_GUILD_BANK, function() self:ActiveWindow():SetHidden(true) end)
--    MasterMerchantWindow:SetHidden(true)
--    MasterMerchantGuildWindow:SetHidden(true)
--  end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_STORE, function() self:ActiveWindow():SetHidden(true) end)
--    MasterMerchantWindow:SetHidden(true)
--    MasterMerchantGuildWindow:SetHidden(true)
--  end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_END_CRAFTING_STATION_INTERACT, function() self:ActiveWindow():SetHidden(true) end)
--    MasterMerchantWindow:SetHidden(true)
--    MasterMerchantGuildWindow:SetHidden(true)
--  end)

  -- We'll add stats to tooltips for items we have data for, if desired
  ZO_PreHookHandler(PopupTooltip, 'OnUpdate', function() self:addStatsPopupTooltip() end)
	ZO_PreHookHandler(PopupTooltip, 'OnHide', function() self:remStatsPopupTooltip() end)
  ZO_PreHookHandler(ItemTooltip, 'OnUpdate', function() self:addStatsItemTooltip() end)
	ZO_PreHookHandler(ItemTooltip, 'OnHide', function() self:remStatsItemTooltip() end)
  
  OriginalSetupPendingPost = TRADING_HOUSE.SetupPendingPost
	TRADING_HOUSE.SetupPendingPost = MasterMerchant.SetupPendingPost
	
  ZO_PreHook(TRADING_HOUSE, 'PostPendingItem', MasterMerchant.PostPendingItem)
  
  -- Set up GM Tools, if also installed
  self:initGMTools()

  -- Set up purchase tracking, if also installed
  self:initPurchaseTracking()

  --Set up code to add Deal info to the guild store results
  self:InitializeFilterFunction()

  --Watch inventory listings
  for _,i in pairs(PLAYER_INVENTORY.inventories) do
		local listView = i.listView
		if listView and listView.dataTypes and listView.dataTypes[1] then
			local originalCall = listView.dataTypes[1].setupCallback				
			
			listView.dataTypes[1].setupCallback = function(control, slot)						
				originalCall(control, slot)
        self:SwitchPrice(control, slot)
			end
		end
	end

  -- Watch Decon list
  local originalCall = ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack.dataTypes[1].setupCallback
	ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack.dataTypes[1].setupCallback = function(control, slot)
		originalCall(control, slot)
		self:SwitchPrice(control, slot)
	end
  
  -- Right, we're all set up, so wait for the player activated event
  -- and then do an initial (deep) scan in case it's been a while since the player
  -- logged on, then use RegisterForUpdate to set up a timed scan.
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function() 

    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED )

    --[[self:playSounds()
    local mmPlaySound = PlaySound
    PlaySound = function(soundId)
      mmPlaySound(soundId)
      d(soundId)
    end

    local mmPlaySoundQueue = ZO_QueuedSoundPlayer.PlaySound
    ZO_QueuedSoundPlayer.PlaySound = function(self, soundName, soundLength)
      mmPlaySoundQueue(self,soundName, soundLength)
      d(MasterMerchant.concat(soundName, soundLength))
    end
    --]]

    if self:ActiveSettings().autoNext then

      local localRunInitialSetup = TRADING_HOUSE.RunInitialSetup
      TRADING_HOUSE.RunInitialSetup = function (self, ...) 
        localRunInitialSetup(self, ...)

        local localOriginalPrevious = TRADING_HOUSE.m_search.SearchPreviousPage
        TRADING_HOUSE.m_search.SearchPreviousPage = function (self, ...) 
          MasterMerchant.lastDirection = -1
          localOriginalPrevious(self, ...)
        end

        local localOriginalNext = TRADING_HOUSE.m_search.SearchNextPage
        TRADING_HOUSE.m_search.SearchNextPage = function (self, ...) 
          MasterMerchant.lastDirection = 1
          localOriginalNext(self, ...)
        end

        local localDoSearch = TRADING_HOUSE.m_search.DoSearch
        TRADING_HOUSE.m_search.DoSearch = function (self, ...) 
          MasterMerchant.lastDirection = 1
          localDoSearch(self, ...)
        end

        local originalOnSearchCooldownUpdate = TRADING_HOUSE.OnSearchCooldownUpdate
        TRADING_HOUSE.OnSearchCooldownUpdate = function (self, ...) 
          originalOnSearchCooldownUpdate(self, ...)
          if GetTradingHouseCooldownRemaining() == 0 then
            if zo_plainstrfind(self.m_resultCount:GetText(), '(0)') and self.m_search:HasNextPage() and (MasterMerchant.lastDirection == 1) then
              self.m_search:SearchNextPage()    
            end
            if zo_plainstrfind(self.m_resultCount:GetText(), '(0)') and self.m_search:HasPreviousPage() and (MasterMerchant.lastDirection == -1) then
              MasterMerchant.lastDirection = 0
              self.m_search:SearchPreviousPage()    
            end
          end
        end
      end
    end

    if self.systemSavedVariables.delayInit then
      -- Finish the init after the player has loaded....
      --DEBUG
      --self.startTime = GetTimeStamp()
      zo_callLater(function()
      d("|cFFFF00Master Merchant Initializing...|r")
--      LEQ:Add(function () self:TruncateHistory() end, 'TruncateHistory')
--      LEQ:Add(function () self:InitPurchaseHistory() end, 'InitPurchaseHistory')
--      LEQ:Add(function () self:InitItemHistory() end, 'InitItemHistory')
--      LEQ:Add(function () self:InitSalesHistory() end, 'InitSalesHistory')
--      LEQ:Add(function () self:InitIndexes(true) end, 'InitIndexes')
--      LEQ:Add(function () self:InitScrollLists() end, 'InitScrollLists')

      local LEQ = LibStub('LibExecutionQueue-1.0')
      LEQ:Start()
      end, 10)
    else
      -- The others were already done... 
      self:InitScrollLists()
    end

	end)  
end

function MasterMerchant:SwitchPrice(control, slot)
  if MasterMerchant:ActiveSettings().replaceInventoryValues then
    local bagId = control.dataEntry.data.bagId
	  local slotIndex = control.dataEntry.data.slotIndex
	  local itemLink = bagId and GetItemLink(bagId, slotIndex) or GetItemLink(slotIndex)
        
    if itemLink then
      local theIID = string.match(itemLink, '|H.-:item:(.-):')
      local itemIndex = MasterMerchant.makeIndexFromLink(itemLink)
      local tipStats = MasterMerchant:toolTipStats(tonumber(theIID), itemIndex, true, true)
      if tipStats.avgPrice then
          --[[
          if control.dataEntry.data.rawName == "Fortified Nirncrux" then
          MasterMerchant.ShowChildren(control, 20)
          --d(control.dataEntry.data.rawName)
          d(control.dataEntry.data.bagId)
          d(control.dataEntry.data.slotIndex)
          d(control.dataEntry.data.statPrice)
          d(control.dataEntry.data.sellPrice)
          d(control.dataEntry.data.stackSellPrice)
          --d(control.dataEntry.data)
          end
          --]]
          if not control.dataEntry.data.mmOriginalPrice then
            control.dataEntry.data.mmOriginalPrice = control.dataEntry.data.sellPrice
            control.dataEntry.data.mmOriginalStackPrice = control.dataEntry.data.stackSellPrice
          end

          control.dataEntry.data.mmPrice = tonumber(string.format('%.0f',tipStats.avgPrice))
          control.dataEntry.data.stackSellPrice = tonumber(string.format('%.0f',tipStats.avgPrice * control.dataEntry.data.stackCount))
          control.dataEntry.data.sellPrice = control.dataEntry.data.mmPrice

          local sellPriceControl = control:GetNamedChild("SellPrice")
          if (sellPriceControl) then
            sellPrice = MasterMerchant.LocalizedNumber(control.dataEntry.data.stackSellPrice)
            sellPrice = '|cEEEE33' .. sellPrice .. '|r |t16:16:EsoUI/Art/currency/currency_gold.dds|t'
            sellPriceControl:SetText(sellPrice)
	        end
      else 
          if control.dataEntry.data.mmOriginalPrice then
            control.dataEntry.data.sellPrice = control.dataEntry.data.mmOriginalPrice
            control.dataEntry.data.stackSellPrice = control.dataEntry.data.mmOriginalStackPrice
          end
          local sellPriceControl = control:GetNamedChild("SellPrice")
          if (sellPriceControl) then
            sellPrice = string.format('%.0f', control.dataEntry.data.stackSellPrice)
            sellPrice = MasterMerchant.LocalizedNumber(sellPrice)
            sellPrice = sellPrice .. '|t16:16:EsoUI/Art/currency/currency_gold.dds|t'
            sellPriceControl:SetText(sellPrice)
	        end
      end
    end
  end
end

function MasterMerchant:TruncateHistory()
-- Rather than constantly managing the length of the history, we'll just
  -- truncate it once at init-time.  As a result it will fluctuate in size
  -- depending on how active guild stores are and how long someone plays for
  -- at a time, but that's OK as it shouldn't impact performance too severely
  -- unless someone plays for 24+ hours straight (and I've yet to see the game
  -- client last anywhere near that :P )

  local epochBack = GetTimeStamp() - (86400 * (self.systemSavedVariables.historyDepth + 1))
  for k, v in pairs(self.salesData) do
    for j, dataList in pairs(v) do
      if dataList['sales'] then
        local itemCount = #dataList['sales']
        while (itemCount > self.systemSavedVariables.minItemCount)
          and ((itemCount > self.systemSavedVariables.maxItemCount) or (dataList['sales'][1]['timestamp'] == nil) or (dataList['sales'][1]['timestamp'] and type(dataList['sales'][1]['timestamp']) ~= 'number') or dataList['sales'][1]['timestamp'] < epochBack) do
            table.remove(dataList['sales'], 1) 
            itemCount = itemCount - 1
        end
      end
    end
  end

  if GuildSalesAssistant and GuildSalesAssistant.MasterMerchantEdition then
    GuildSalesAssistant:TrimHistory(epochBack)
  end

end

function MasterMerchant:InitItemHistory()
  -- If no guild item history then load it up
  if self.guildItems == nil then
    self.guildItems = {}
    for k, v in pairs(self.salesData) do
      for j, dataList in pairs(v) do
        for i = 1, #dataList['sales'], 1 do
          local item = dataList['sales'][i]
          if (not (item == {})) and item.guild then
            self.guildItems[item.guild] = self.guildItems[item.guild] or MMGuild:new(item.guild)
            local guild = self.guildItems[item.guild]
            --guild:addSaleByDate(item.itemLink, item['timestamp'], item.price, item.quant, false, false)
            guild:addSaleByDate(dataList['sales'][1].itemLink, item['timestamp'], item.price, item.quant, false, false, MasterMerchant.concat(dataList['itemDesc'], dataList['itemAdderText']))
          end
        end
      end
    end
  end

  for _, guild in pairs(self.guildItems) do
    guild:sort()
  end

    -- If no guild item history then load it up
  if self.myItems == nil then
    local playerName = string.lower(GetDisplayName())
    self.myItems = {}
    for k, v in pairs(self.salesData) do
      for j, dataList in pairs(v) do
        for i = 1, #dataList['sales'], 1 do
          local item = dataList['sales'][i]
          if (not (item == {})) and item.guild then
            if (string.lower(item.seller) == playerName) then
              self.myItems[item.guild] = self.myItems[item.guild] or MMGuild:new(item.guild)
              local guild = self.myItems[item.guild]
              --guild:addSaleByDate(item.itemLink, item['timestamp'], item.price, false, false)
              guild:addSaleByDate(dataList['sales'][1].itemLink, item['timestamp'], item.price, item.quant, false, false, MasterMerchant.concat(dataList['itemDesc'], dataList['itemAdderText']))
            end
          end
        end
      end
    end
  end

  for _, guild in pairs(self.myItems) do
    guild:sort()
  end

end

function MasterMerchant:InitSalesHistory()
  --If no guild seller history then load it up
  self.totalRecords = 0
  if self.guildSales == nil then
    self.guildSales = {}
    for k, v in pairs(self.salesData) do
      for j, dataList in pairs(v) do
        for i = 1, #dataList['sales'], 1 do
          local item = dataList['sales'][i]
          if (not (item == {})) and item.guild then
            self.guildSales[item.guild] = self.guildSales[item.guild] or MMGuild:new(item.guild)
            local guild = self.guildSales[item.guild]          
            guild:addSaleByDate(item.seller, item['timestamp'], item.price, item.quant, false, false)
            self.totalRecords = self.totalRecords + 1
          end
        end
      end
    end
  end

  for guildName, guild in pairs(self.guildSales) do
    guild:sort()
  end
end

function MasterMerchant:InitPurchaseHistory()
  -- If no guild buyer history then load it up
  if self.guildPurchases == nil then
    self.guildPurchases = {}
    for k, v in pairs(self.salesData) do
      for j, dataList in pairs(v) do
        for i = 1, #dataList['sales'], 1 do
          local item = dataList['sales'][i]
          if (not (item == {})) and item.guild then
            self.guildPurchases[item.guild] = self.guildPurchases[item.guild] or MMGuild:new(item.guild)
            local guild = self.guildPurchases[item.guild]
            guild:addSaleByDate(item.buyer, item['timestamp'], item.price, item.quant, item.wasKiosk, false)
          end
        end
      end
    end
  end

  for _, guild in pairs(self.guildPurchases) do
    guild:sort()
  end
end


function MasterMerchant:InitIndexes(pause)
  -- Set up guild roster info
  if self:ActiveSettings().diplayGuildInfo then
    self:initRosterStats()
  end
  -- And index for search
  MasterMerchant:indexHistoryTables(pause)
end

function MasterMerchant:InitScrollLists()

    self:SetupScrollLists()
    
    d('|cFFFF00Master Merchant Initialized -- Holding information on ' .. self.totalRecords .. ' sales.|r')
    --DEBUG
    --d(GetTimeStamp() - self.startTime)

    self.isFirstScan = self:ActiveSettings().offlineSales
    if NonContiguousCount(self.salesData) > 0 then 
      self.veryFirstScan = false
      self:ScanStores(false)
    else
      self.veryFirstScan = true
      CHAT_SYSTEM:AddMessage(MasterMerchant.concat(GetString(MM_APP_MESSAGE_NAME), GetString(SK_FIRST_SCAN)))
      self:ScanStores(true)
    end                           
	
    -- RegisterForUpdate lets us scan at a given interval (in ms), so we'll use that to
    -- keep the sales history updated
    local scanInterval = self:ActiveSettings().scanFreq * 1000
    EVENT_MANAGER:RegisterForUpdate(self.name, scanInterval, function() self:ScanStores(false) end)
    
end

local deals = {}
MasterMerchant.GetDealValue = function(index)
	return deals[index]
end

local profits = {}
MasterMerchant.GetProfitValue = function(index)
	return profits[index]
end

MasterMerchant.AdjustGetTradingHouseSearchResultItemInfo = function(index)
		local icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice = OriginalGetTradingHouseSearchResultItemInfo(index)
	    if(name ~= '' and stackCount > 0) then
      
      local setPrice = nil
      local salesCount = 0
      local tipLine = nil
      local itemLink = GetTradingHouseSearchResultItemLink(index, LINK_STYLE_DEFAULT)
      if itemLink then
        local theIID = string.match(itemLink, '|H.-:item:(.-):')
        local itemIndex = MasterMerchant.makeIndexFromLink(itemLink)
        local tipStats = MasterMerchant:toolTipStats(tonumber(theIID), itemIndex, true)
        if tipStats.avgPrice then
          setPrice = tipStats['avgPrice']
          salesCount = tipStats['numSales']
        end
      end

      local deal, margin, profit = MasterMerchant.DealCalc(setPrice, salesCount, purchasePrice, stackCount)

      local dealString = ''
      if deal then 
        dealString = string.format('%.0f', deal) 
        deals[index] = deal 
      end
      if profit then 
        profits[index] = profit 
      end

      local marginString = ''
      if margin then marginString = string.format('%.2f', margin) end 

      if MasterMerchant:ActiveSettings().saucy and profit then
        marginString = string.format('%.0f', profit)
      end

      return icon, name, quality, stackCount, sellerName .. '|c000000;' .. dealString .. ';' .. marginString .. '|r', timeRemaining, purchasePrice
		end
		return nil, '', nil, 0
	end
  

  function MasterMerchant:SendNote(gold)
    MasterMerchantFeedback:SetHidden(true)
    SCENE_MANAGER:Show('mailSend')
    ZO_MailSendToField:SetText('@Philgo68')
    ZO_MailSendSubjectField:SetText('Master Merchant')
    QueueMoneyAttachment(gold)
    ZO_MailSendBodyField:TakeFocus()	
  end
  
	MasterMerchant.AdjustGetTradingHouseListingItemInfo = function(index)
		local icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice = OriginalGetTradingHouseListingItemInfo(index)
        if(name ~= '' and stackCount > 0) then
      
      local setPrice = nil
      local salesCount = 0
      local tipLine = nil
      local itemLink = GetTradingHouseListingItemLink(index, LINK_STYLE_DEFAULT)
      if itemLink then
        local theIID = string.match(itemLink, '|H.-:item:(.-):')
        local itemIndex = MasterMerchant.makeIndexFromLink(itemLink)
        local tipStats = MasterMerchant:toolTipStats(tonumber(theIID), itemIndex, true)
        if tipStats.avgPrice then
          setPrice = tipStats['avgPrice']
          salesCount = tipStats['numSales']
        end
      end
      
      local deal, margin, profit = MasterMerchant.DealCalc(setPrice, salesCount, purchasePrice, stackCount)

      local dealString = ''
      if deal then dealString = string.format('%.0f', deal) end 

      local marginString = ''
      if margin then marginString = string.format('%.2f', margin) end

      if MasterMerchant:ActiveSettings().saucy and profit then
        marginString = string.format('%.0f', profit)
      end

      return icon, name, quality, stackCount, sellerName .. ';' .. dealString .. ';' .. marginString, timeRemaining, purchasePrice
		end
		return nil, '', nil, 0
	end
  
  
  Original_ZO_InventorySlotActions_Show = ZO_InventorySlotActions.Show

  function ZO_InventorySlotActions:Show() 
    g_slotActions = self
    Original_ZO_InventorySlotActions_Show(self)
  end	

	
function MasterMerchant:InitializeFilterFunction()
  OriginalGetTradingHouseSearchResultItemInfo = GetTradingHouseSearchResultItemInfo
  GetTradingHouseSearchResultItemInfo = MasterMerchant.AdjustGetTradingHouseSearchResultItemInfo

  OriginalGetTradingHouseListingItemInfo = GetTradingHouseListingItemInfo
  GetTradingHouseListingItemInfo = MasterMerchant.AdjustGetTradingHouseListingItemInfo
end
-------------------------------------------------------------------------------
-- LMP - Removed Fonts v1.1
-------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Ales Machat (Garkin)
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the 'Software'), to deal in the Software without
-- restriction, including without limitation the rights to use,
-- copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following
-- conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.


local function OnAddOnLoaded(eventCode, addOnName)
   if addOnName:find('^ZO_') then return end
   if addOnName == MasterMerchant.name then
        MasterMerchant:Initialize()
        -- Set up /mm as a slash command toggle for the main window
        SLASH_COMMANDS['/mm'] = MasterMerchant.Slash
   elseif addOnName == "AwesomeGuildStore" then
     -- Set up AGS integration, if it's installed
     MasterMerchant:initAGSIntegration()
   end
   
   local LMP = LibStub('LibMediaProvider-1.0')

   --if the first loaded version of LibMediaProvider was r6 and older, fonts are
   --already registered, but with invalid paths.
   if LMP.MediaTable.font['Arial Narrow']     then LMP.MediaTable.font['Arial Narrow']     = 'MasterMerchant/Fonts/arialn.ttf'               end
   if LMP.MediaTable.font['ESO Cartographer'] then LMP.MediaTable.font['ESO Cartographer'] = 'MasterMerchant/Fonts/esocartographer-bold.otf' end
   if LMP.MediaTable.font['Fontin Bold']      then LMP.MediaTable.font['Fontin Bold']      = 'MasterMerchant/Fonts/fontin_sans_b.otf'        end
   if LMP.MediaTable.font['Fontin Italic']    then LMP.MediaTable.font['Fontin Italic']    = 'MasterMerchant/Fonts/fontin_sans_i.otf'        end
   if LMP.MediaTable.font['Fontin Regular']   then LMP.MediaTable.font['Fontin Regular']   = 'MasterMerchant/Fonts/fontin_sans_r.otf'        end
   if LMP.MediaTable.font['Fontin SmallCaps'] then LMP.MediaTable.font['Fontin SmallCaps'] = 'MasterMerchant/Fonts/fontin_sans_sc.otf'       end

   --LMP r7 and above doesn't have fonts registered yet
   LMP:Register('font', 'Arial Narrow',           'MasterMerchant/Fonts/arialn.ttf')
   LMP:Register('font', 'ESO Cartographer',       'MasterMerchant/Fonts/esocartographer-bold.otf')
   LMP:Register('font', 'Fontin Bold',            'MasterMerchant/Fonts/fontin_sans_b.otf')
   LMP:Register('font', 'Fontin Italic',          'MasterMerchant/Fonts/fontin_sans_i.otf')
   LMP:Register('font', 'Fontin Regular',         'MasterMerchant/Fonts/fontin_sans_r.otf')
   LMP:Register('font', 'Fontin SmallCaps',       'MasterMerchant/Fonts/fontin_sans_sc.otf')

   --this game font is missing in all versions of LMP
   LMP:Register('font', 'Futura Condensed Bold',  'EsoUI/Common/Fonts/FuturaStd-CondensedBold.otf')
end


-- Event handler for the OnAddOnLoaded event
--function MasterMerchant.OnAddOnLoaded(event, addonName)
--  if addonName == MasterMerchant.name then
--    MasterMerchant:Initialize()
----end
--end
function MasterMerchant.Slash(allArgs)
  local args = ""
  local guildNumber = 0
  local argNum = 0
  for w in string.gmatch(allArgs,"%w+") do
    argNum = argNum + 1
    if argNum == 1 then args = w end
    if argNum == 2 then guildNumber = tonumber(w) end
  end
  if args == 'help' then
    d("/mm  - show/hide the main Master Merchant window")
    d("/mm missing  - rescans the availiable guild history to try to pick up missed records")
    d("/mm dups  - scans your history to purge duplicate entries")
    d("/mm clearprices  - clears your historical listing prices")
    d("/mm invisible  - resets the MM window positions in case they are invisible (aka off the screen)")
    d("/mm export <Guild number>  - 'exports' last weeks sales/purchase totals for the guild")
    d("/mm sales <Guild number>  - 'exports' sales activity data for your guild")

    d("/mm deal  - toggles deal display between margin % and profit in the guild stores")
    d("/mm saucy  - toggles deal display between margin % and profit in the guild stores")
    d("/mm types  - list the item type filters that are available")
    d("/mm traits  - list the item trait filters that are available")
    d("/mm quality  - list the item quality filters that are available")
    d("/mm equip  - list the item equipment type filters that are available")
    return
  end
  if args == 'missing' or args == 'stillmissing' then
    if MasterMerchant.isScanning then 
        if args == 'missing' then CHAT_SYSTEM:AddMessage("Search for missing sales will begin when current scan completes.") end
        zo_callLater(function() MasterMerchant.Slash('stillmissing') end, 10000) 
        return
    end
    MasterMerchant.numEvents = {}
    MasterMerchant.checkingForMissingSales = true
    CHAT_SYSTEM:AddMessage("Searching for missing sales.")
    MasterMerchant:ScanStores(true)
    return
  end
  if args == 'dups' or args == 'stilldups' then
    if MasterMerchant.isScanning then 
        if args == 'dups' then CHAT_SYSTEM:AddMessage("Purging of duplicate sales records will begin when current scan completes.") end
        zo_callLater(function() MasterMerchant.Slash('stilldups') end, 10000) 
        return
    end
    CHAT_SYSTEM:AddMessage("Purging duplicates.")
    MasterMerchant:PurgeDups()
    return
  end

  if args == 'export' then
    MasterMerchant.guildNumber = guildNumber
    if MasterMerchant.guildNumber or 0 > 0 then
      CHAT_SYSTEM:AddMessage("'Exporting' last weeks sales/purchase/rank data.")
      MasterMerchant:ExportLastWeek()
      CHAT_SYSTEM:AddMessage("Export complete.  /reloadui to save the file.")
    else
      CHAT_SYSTEM:AddMessage("Please include the guild number you wish to export.")
    end
    return
  end

  if args == 'sales' then
    MasterMerchant.guildNumber = guildNumber
    if MasterMerchant.guildNumber or 0 > 0 then
      CHAT_SYSTEM:AddMessage("'Exporting' sales activity.")
      MasterMerchant:ExportSalesData()
      CHAT_SYSTEM:AddMessage("Export complete.  /reloadui to save the file.")
    else
      CHAT_SYSTEM:AddMessage("Please include the guild number you wish to export.")
    end
    return
  end


  if args == '42' then
    MasterMerchant:SpecialMessage(true)
    return
  end

  if args == 'clean' or args == 'stillclean' then
    if MasterMerchant.isScanning then 
        if args == 'clean' then CHAT_SYSTEM:AddMessage("Cleaning out bad sales records will begin when current scan completes.") end
        zo_callLater(function() MasterMerchant.Slash('stillclean') end, 10000) 
        return
    end
    CHAT_SYSTEM:AddMessage("Cleaning Out Bad Records.")
    MasterMerchant:CleanOutBad()
    return
  end
  if args == 'clearprices' then
    MasterMerchant:ActiveSettings().pricingData = {}
    CHAT_SYSTEM:AddMessage("Your prices have been cleared.")
    return
  end
  if args == 'invisible' then
    MasterMerchantWindow:ClearAnchors()
    MasterMerchantWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 30, 30)
    MasterMerchantGuildWindow:ClearAnchors()
    MasterMerchantGuildWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 30, 30)
    MasterMerchant:ActiveSettings().winLeft=30
    MasterMerchant:ActiveSettings().guildWinLeft=30
    MasterMerchant:ActiveSettings().winTop=30
    MasterMerchant:ActiveSettings().guildWinTop=30
    CHAT_SYSTEM:AddMessage("Your MM window positions have been reset.")
    return
  end
  if args == 'deal' or args == 'saucy' then
    MasterMerchant:ActiveSettings().saucy = not MasterMerchant:ActiveSettings().saucy
    CHAT_SYSTEM:AddMessage("Guild listing display switched.")
    return
  end
  if args == 'types' then
    local message = 'Item types: '
    for i = 0, 64 do
      message = message .. i .. ')' .. GetString("SI_ITEMTYPE", i) .. ', '
    end
    CHAT_SYSTEM:AddMessage(message)
    return
  end
  if args == 'traits' then
    local message = 'Item traits: '
    for i = 0, 32 do
      message = message .. i .. ')' .. GetString("SI_ITEMTRAITTYPE", i) .. ', '
    end
    CHAT_SYSTEM:AddMessage(message)
    return
  end
  if args == 'quality' then
    local message = 'Item quality: '
    for i = 0, 5 do
      message = message .. GetString("SI_ITEMQUALITY", i) .. ', '
    end
    CHAT_SYSTEM:AddMessage(message)
    return
  end
  if args == 'equip' then
    local message = 'Equipment types: '
    for i = 0, 14 do
      message = message .. GetString("SI_EQUIPTYPE", i) .. ', '
    end
    CHAT_SYSTEM:AddMessage(message)
    return
  end
  
  MasterMerchant:ToggleMasterMerchantWindow()
end

-- Register for the OnAddOnLoaded event
EVENT_MANAGER:RegisterForEvent(MasterMerchant.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

