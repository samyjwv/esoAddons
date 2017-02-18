-- MasterMerchant UI Functions File
-- Last Updated September 15, 2014
-- Written August 2014 by Dan Stone (@khaibit) - dankitymao@gmail.com
-- Extended February 2015 by Chris Lasswell (@Philgo68) - Philgo68@gmail.com
-- Released under terms in license accompanying this file.
-- Distribution without license is prohibited!

-- Sort scrollList by price in 'ordering' order (asc = true as per ZOS)
-- Rather than using the built-in Lua quicksort, we use my own
-- implementation of Shellsort to save on memory.

local ITEMS = 'full'
local GUILDS = 'half'
local LISTINGS = 'listings'

function MasterMerchant:SortByPrice(ordering, scrollList)
  local listData = ZO_ScrollList_GetDataList(scrollList.list)
  
  if not ordering then
    -- If they're viewing prices per-unit, then we need to sort on price / quantity.
    if self:ActiveSettings().showUnitPrice then
      MasterMerchant.shellSort(listData, function(sortA, sortB)
        -- In case quantity ends up 0 or nil somehow, let's not divide by it
        if sortA.data[6] and sortA.data[6] > 0 and sortB.data[6] and sortB.data[6] > 0 then
          return ((sortA.data[5] or 0)/ sortA.data[6]) > ((sortB.data[5] or 0) / sortB.data[6])
        else return (sortA.data[5] or 0) > (sortB.data[5] or 0) end
      end)
    -- Otherwise just sort on pure price.
    else
      MasterMerchant.shellSort(listData, function(sortA, sortB)
        return (sortA.data[5] or 0) > (sortB.data[5] or 0)
      end)
    end
  else
    -- And the same thing with descending sort
    if self:ActiveSettings().showUnitPrice then
      MasterMerchant.shellSort(listData, function(sortA, sortB)
        -- In case quantity ends up 0 or nil somehow, let's not divide by it
        if sortA.data[6] and sortA.data[6] > 0 and sortB.data[6] and sortB.data[6] > 0 then
          return ((sortA.data[5] or 0) / sortA.data[6]) < ((sortB.data[5] or 0) / sortB.data[6])
        else return (sortA.data[5] or 0) < (sortB.data[5] or 0) end
      end)
    else
      MasterMerchant.shellSort(listData, function(sortA, sortB)
        return (sortA.data[5] or 0) < (sortB.data[5] or 0)
      end)
    end
  end
end

-- Sort the scrollList by time in 'ordering' order (asc = true as per ZOS).
function MasterMerchant:SortByTime(ordering, scrollList)
  local listData = ZO_ScrollList_GetDataList(scrollList.list)

  if not ordering then
      MasterMerchant.shellSort(listData, function(sortA, sortB)
        return (sortA.data[4] or 0) < (sortB.data[4] or 0)
      end)
  else
      MasterMerchant.shellSort(listData, function(sortA, sortB)
        return (sortA.data[4] or 0) > (sortB.data[4] or 0)
      end)
  end
end

function MasterMerchant:SortBySales(ordering, scrollList)
  local listData = ZO_ScrollList_GetDataList(scrollList.list)
  
  if not ordering then
    MasterMerchant.shellSort(listData, function(sortA, sortB)
      return (sortA.data[3] or 0) > (sortB.data[3] or 0)
    end)
  else
    MasterMerchant.shellSort(listData, function(sortA, sortB)
      return (sortA.data[3] or 0) < (sortB.data[3] or 0)
    end)
  end
end

function MasterMerchant:SortByRank(ordering, scrollList)
  local listData = ZO_ScrollList_GetDataList(scrollList.list)
  
  if not ordering then
    MasterMerchant.shellSort(listData, function(sortA, sortB)
      return (sortA.data[4] or 9999) > (sortB.data[4] or 9999)
    end)
  else
      MasterMerchant.shellSort(listData, function(sortA, sortB)
        return (sortA.data[4] or 9999) < (sortB.data[4] or 9999)
      end)
  end
end

function MasterMerchant:SortByCount(ordering, scrollList)
  local listData = ZO_ScrollList_GetDataList(scrollList.list)
  
  if not ordering then
    MasterMerchant.shellSort(listData, function(sortA, sortB)
      return (sortA.data[5] or 0) > (sortB.data[5] or 0)
    end)
  else
      MasterMerchant.shellSort(listData, function(sortA, sortB)
        return (sortA.data[5] or 0) < (sortB.data[5] or 0)
      end)
  end
end

function MasterMerchant:SortByTax(ordering, scrollList)
  local listData = ZO_ScrollList_GetDataList(scrollList.list)
  
  if not ordering then
    MasterMerchant.shellSort(listData, function(sortA, sortB)
      return (sortA.data[8] or 0) > (sortB.data[8] or 0)
    end)
  else
      MasterMerchant.shellSort(listData, function(sortA, sortB)
        return (sortA.data[8] or 0) < (sortB.data[8] or 0)
      end)
  end
end

function MasterMerchant:SortByName(ordering, scrollList)
  local listData = ZO_ScrollList_GetDataList(scrollList.list)
  if not ordering then
    MasterMerchant.shellSort(listData, function(sortA, sortB)
      return (sortA.data[2] or 0) > (sortB.data[2] or 0)
    end)
  else
    MasterMerchant.shellSort(listData, function(sortA, sortB)
      return (sortA.data[2] or 0) < (sortB.data[2] or 0)
    end)
  end
end

function MasterMerchant:SortByGuildName(ordering, scrollList)
  local listData = ZO_ScrollList_GetDataList(scrollList.list)
  if not ordering then
    MasterMerchant.shellSort(listData, function(sortA, sortB)
      return (sortA.data[1] or 0) > (sortB.data[1] or 0)
    end)
  else
    MasterMerchant.shellSort(listData, function(sortA, sortB)
      return (sortA.data[1] or 0) < (sortB.data[1] or 0)
    end)
  end
end

function MasterMerchant:SortByItemGuildName(ordering, scrollList)
  local listData = ZO_ScrollList_GetDataList(scrollList.list)
  if not ordering then
    MasterMerchant.shellSort(listData, function(sortA, sortB)
      return (MasterMerchant.salesData[sortA.data[1]][sortA.data[2]]['sales'][sortA.data[3]]['guild'] or 0) > (MasterMerchant.salesData[sortB.data[1]][sortB.data[2]]['sales'][sortB.data[3]]['guild'] or 0)
    end)
  else
    MasterMerchant.shellSort(listData, function(sortA, sortB)
      return (MasterMerchant.salesData[sortA.data[1]][sortA.data[2]]['sales'][sortA.data[3]]['guild'] or 0) < (MasterMerchant.salesData[sortB.data[1]][sortB.data[2]]['sales'][sortB.data[3]]['guild'] or 0)
    end)
  end
end

function MMScrollList:SetupSalesRow(control, data)

  control.rowId = GetControl(control, 'RowId')
  control.buyer = GetControl(control, 'Buyer')
  control.guild = GetControl(control, 'Guild')
  control.icon = GetControl(control, 'ItemIcon')
  control.quant = GetControl(control, 'Quantity')
  control.itemName = GetControl(control, 'ItemName')
  control.sellTime = GetControl(control, 'SellTime')
  control.price = GetControl(control, 'Price')
  
  if (MasterMerchant.salesData[data[1]] == nil) then 
    -- just starting up so just bail out
    return
  end
  
  local actualItem = MasterMerchant.salesData[data[1]][data[2]]['sales'][data[3]]
  local actualItemIcon = MasterMerchant.salesData[data[1]][data[2]]['itemIcon']
  local isFullSize = string.find(control:GetName(), '^MasterMerchantWindow')

  local LMP = LibStub('LibMediaProvider-1.0')
  if LMP then
    local fontString = LMP:Fetch('font', MasterMerchant:ActiveSettings().windowFont) .. '|%d'

    control.rowId:SetFont(string.format(fontString, 12))   
    control.buyer:SetFont(string.format(fontString, 15)) 
    control.guild:SetFont(string.format(fontString, ((isFullSize and 15) or 11)))
    control.itemName:SetFont(string.format(fontString, ((isFullSize and 15) or 11)))
    control.quant:SetFont(string.format(fontString, ((isFullSize and 15) or 10)) .. '|soft-shadow-thin')
    control.sellTime:SetFont(string.format(fontString, ((isFullSize and 15) or 11)))
    control.price:SetFont(string.format(fontString, ((isFullSize and 15) or 11)))
  end

  control.rowId:SetText(data.sortIndex)
  
  -- Some extra stuff for the Buyer cell to handle double-click and color changes
  -- Plus add a marker if buyer is not in-guild (kiosk sale)
  
  local buyerString
  if MasterMerchant:ActiveSettings().viewBuyerSeller == 'buyer' then
    buyerString = actualItem.buyer
  else
    buyerString = actualItem.seller
  end

  control.buyer:GetLabelControl():SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  control.buyer:SetText(buyerString)
  -- If the seller is the player, color the buyer green.  Otherwise, blue.
  local acctName = GetDisplayName()
  if string.lower(actualItem.seller) == string.lower(acctName) then
    control.buyer:SetNormalFontColor(0.18, 0.77, 0.05, 1)
    control.buyer:SetPressedFontColor(0.18, 0.77, 0.05, 1)
    control.buyer:SetMouseOverFontColor(0.32, 0.90, 0.18, 1)
  else
    control.buyer:SetNormalFontColor(0.21, 0.54, 0.94, 1)
    control.buyer:SetPressedFontColor(0.21, 0.54, 0.94, 1)
    control.buyer:SetMouseOverFontColor(0.34, 0.67, 1, 1)
  end
  
  control.buyer:SetHandler('OnMouseUp', function(self, upInside)
    MasterMerchant:my_NameHandler_OnLinkMouseUp(buyerString, upInside, self)
  end)
  
  -- Guild cell
  local guildString = actualItem.guild
  if actualItem.wasKiosk then guildString = '|t16:16:/EsoUI/Art/icons/item_generic_coinbag.dds|t ' .. guildString else guildString = '     ' .. guildString end  
  control.guild:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  control.guild:SetText(guildString)

  -- Item Icon
  control.icon:SetHidden(false)
  control.icon:SetTexture(actualItemIcon)


  -- Item name cell
  control.itemName:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  control.itemName:SetText(zo_strformat('<<t:1>>', actualItem.itemLink))
  -- Insert the item link into the chat box, with a quick substitution so brackets show up
  --control.itemName:SetHandler('OnMouseDoubleClick', function()
  --  ZO_ChatWindowTextEntryEditBox:SetText(ZO_ChatWindowTextEntryEditBox:GetText() .. string.gsub(actualItem.itemLink, '|H0', '|H1'))
  --end)
  control.itemName:SetHandler('OnMouseEnter', function() MasterMerchant.ShowToolTip(actualItem.itemLink, control.itemName) end)
  control.itemName:SetHandler('OnMouseExit', function() ClearTooltip(ItemTooltip) end)

  -- Quantity cell
  if actualItem.quant == 1 then control.quant:SetHidden(true)
  else
    control.quant:SetHidden(false)
    control.quant:SetText(actualItem.quant)
  end

  -- Sale time cell
  control.sellTime:SetText(MasterMerchant.TextTimeSince(actualItem.timestamp, false))

  -- Handle the setting of whether or not to show pre-cut sale prices
  -- math.floor(number + 0.5) is a quick shorthand way to round for
  -- positive values.
  local dispPrice = actualItem.price
  local quantity = actualItem.quant
  local settingsToUse = MasterMerchant:ActiveSettings()
  if settingsToUse.showFullPrice then
    if settingsToUse.showUnitPrice and quantity > 0 then dispPrice = math.floor((dispPrice / quantity) + 0.5) end
  else
    local cutPrice = dispPrice * (1 - (GetTradingHouseCutPercentage() / 100))
    if settingsToUse.showUnitPrice and quantity > 0 then cutPrice = cutPrice / quantity end
    dispPrice = math.floor(cutPrice + 0.5)
  end

  -- Insert thousands separators for the price
  local stringPrice = MasterMerchant.LocalizedNumber(dispPrice)

  -- Finally, set the price
  control.price:SetText(stringPrice .. ' |t16:16:EsoUI/Art/currency/currency_gold.dds|t')

  ZO_SortFilterList.SetupRow(self, control, data)
end


function MMScrollList:SetupGuildSalesRow(control, data)

  control.rowId = GetControl(control, 'RowId')
  control.seller = GetControl(control, 'Seller')
  control.itemName = GetControl(control, 'ItemName')
  control.guild = GetControl(control, 'Guild')
  control.rank = GetControl(control, 'Rank')
  control.sales = GetControl(control, 'Sales') 
  control.tax = GetControl(control, 'Tax')  
  control.count = GetControl(control, 'Count')  
  control.percent = GetControl(control, 'Percent')
  
  if (data[1] == nil) then 
    -- just starting up so just bail out
    return
  end
  
  local LMP = LibStub('LibMediaProvider-1.0')
  if LMP then
    local fontString = LMP:Fetch('font', MasterMerchant:ActiveSettings().windowFont) .. '|%d'

    control.rowId:SetFont(string.format(fontString, 12))     
    control.seller:SetFont(string.format(fontString, 15)) 
    control.itemName:SetFont(string.format(fontString, 15)) 
    control.guild:SetFont(string.format(fontString, 15))
    control.rank:SetFont(string.format(fontString, 15))
    control.sales:SetFont(string.format(fontString, 15))
    control.tax:SetFont(string.format(fontString, 15))
    control.count:SetFont(string.format(fontString, 15))
    control.percent:SetFont(string.format(fontString, 15))
    
  end

  control.rowId:SetText(data.sortIndex)

  -- Some extra stuff for the Seller cell to handle double-click and color changes

  local sellerString = data[2]

  if (string.sub(sellerString,1, 1) == '@' or sellerString == GetString(MM_ENTIRE_GUILD) ) then
    control.itemName:SetHidden(true);
    control.seller:SetHidden(false);
    control.seller:GetLabelControl():SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    control.seller:SetText(sellerString)
    -- If the seller is the player, color the buyer green.  Otherwise, blue.
    local acctName = GetDisplayName()
    if string.lower(sellerString) == string.lower(acctName) then
      control.seller:SetNormalFontColor(0.18, 0.77, 0.05, 1)
      control.seller:SetPressedFontColor(0.18, 0.77, 0.05, 1)
      control.seller:SetMouseOverFontColor(0.32, 0.90, 0.18, 1)
    else
      control.seller:SetNormalFontColor(0.21, 0.54, 0.94, 1)
      control.seller:SetPressedFontColor(0.21, 0.54, 0.94, 1)
      control.seller:SetMouseOverFontColor(0.34, 0.67, 1, 1)
    end
    control.seller:SetHandler('OnMouseUp', function(self, upInside)
      MasterMerchant:my_NameHandler_OnLinkMouseUp(sellerString, upInside, self)
    end)
  else
    -- Item name cell
    control.seller:SetHidden(true);
    control.itemName:SetHidden(false);
    control.itemName:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    control.itemName:SetText(zo_strformat('<<t:1>>', sellerString))
    control.itemName:SetHandler('OnMouseEnter', function() MasterMerchant.ShowToolTip(sellerString, control.itemName) end)
    control.itemName:SetHandler('OnMouseExit', function() ClearTooltip(ItemTooltip) end)
  end

  -- Guild cell
  if data[9] then guildString = '|t16:16:/EsoUI/Art/icons/item_generic_coinbag.dds|t ' .. data[1] else guildString = '     ' .. data[1] end  
  control.guild:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  control.guild:SetText(guildString)

  -- Rank Cell
  control.rank:SetText(data[4])
  
  -- Sales Cell
  local sales = data[3] or 0
  local stringSales = MasterMerchant.LocalizedNumber(sales)
  control.sales:SetText(stringSales .. ' |t16:16:EsoUI/Art/currency/currency_gold.dds|t')

  -- Tax Cell
  --local taxAmount = math.floor((sales * GetTradingHouseCutPercentage() / 200))
  local taxAmount = data[8]
  local stringTax = MasterMerchant.LocalizedNumber(taxAmount)
  control.tax:SetText(stringTax .. ' |t16:16:EsoUI/Art/currency/currency_gold.dds|t')

  -- Count Cell
  
  control.count:SetText((data[5] or '-') .. '/' .. (data[6] or '-'))

  -- Percent Cell
  if data[7] and data[7] ~= 0 then
    local percent = math.floor(( 1000 * sales / data[7]) + 0.5) / 10
    control.percent:SetText(percent .. GetString(MM_PERCENT_CHAR))
  else
    control.percent:SetText('--' .. GetString(MM_PERCENT_CHAR))
  end

    
  ZO_SortFilterList.SetupRow(self, control, data)
end

function MMScrollList:SetupListingsRow(control, data)

  control.rowId = GetControl(control, 'RowId')
  control.seller = GetControl(control, 'Seller')
  control.guild = GetControl(control, 'Guild')
  control.icon = GetControl(control, 'ItemIcon')
  control.quant = GetControl(control, 'Quantity')
  control.itemName = GetControl(control, 'ItemName')
  control.sellTime = GetControl(control, 'SellTime')
  control.price = GetControl(control, 'Price')
  
  if (MasterMerchant.salesData[data[1]] == nil) then 
    -- just starting up so just bail out
    return
  end
  
  local actualItem = MasterMerchant.salesData[data[1]][data[2]]['sales'][data[3]]
  local actualItemIcon = MasterMerchant.salesData[data[1]][data[2]]['itemIcon']
  local isFullSize = string.find(control:GetName(), '^MasterMerchantWindow')

  local LMP = LibStub('LibMediaProvider-1.0')
  if LMP then
    local fontString = LMP:Fetch('font', MasterMerchant:ActiveSettings().windowFont) .. '|%d'

    control.rowId:SetFont(string.format(fontString, 12))   
    control.buyer:SetFont(string.format(fontString, 15)) 
    control.guild:SetFont(string.format(fontString, ((isFullSize and 15) or 11)))
    control.itemName:SetFont(string.format(fontString, ((isFullSize and 15) or 11)))
    control.quant:SetFont(string.format(fontString, ((isFullSize and 15) or 10)) .. '|soft-shadow-thin')
    control.sellTime:SetFont(string.format(fontString, ((isFullSize and 15) or 11)))
    control.price:SetFont(string.format(fontString, ((isFullSize and 15) or 11)))
  end

  control.rowId:SetText(data.sortIndex)
  
  -- Some extra stuff for the Buyer cell to handle double-click and color changes
  -- Plus add a marker if buyer is not in-guild (kiosk sale)
  
  local buyerString
  if MasterMerchant:ActiveSettings().viewBuyerSeller == 'buyer' then
    buyerString = actualItem.buyer
  else
    buyerString = actualItem.seller
  end

  control.buyer:GetLabelControl():SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  control.buyer:SetText(buyerString)
  -- If the seller is the player, color the buyer green.  Otherwise, blue.
  local acctName = GetDisplayName()
  if string.lower(actualItem.seller) == string.lower(acctName) then
    control.buyer:SetNormalFontColor(0.18, 0.77, 0.05, 1)
    control.buyer:SetPressedFontColor(0.18, 0.77, 0.05, 1)
    control.buyer:SetMouseOverFontColor(0.32, 0.90, 0.18, 1)
  else
    control.buyer:SetNormalFontColor(0.21, 0.54, 0.94, 1)
    control.buyer:SetPressedFontColor(0.21, 0.54, 0.94, 1)
    control.buyer:SetMouseOverFontColor(0.34, 0.67, 1, 1)
  end
  
  control.buyer:SetHandler('OnMouseUp', function(self, upInside)
    MasterMerchant:my_NameHandler_OnLinkMouseUp(buyerString, upInside, self)
  end)
  
  -- Guild cell
  local guildString = actualItem.guild
  if actualItem.wasKiosk then guildString = '|t16:16:/EsoUI/Art/icons/item_generic_coinbag.dds|t ' .. guildString else guildString = '     ' .. guildString end  
  control.guild:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  control.guild:SetText(guildString)

  -- Item Icon
  control.icon:SetHidden(false)
  control.icon:SetTexture(actualItemIcon)


  -- Item name cell
  control.itemName:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  control.itemName:SetText(zo_strformat('<<t:1>>', actualItem.itemLink))
  -- Insert the item link into the chat box, with a quick substitution so brackets show up
  --control.itemName:SetHandler('OnMouseDoubleClick', function()
  --  ZO_ChatWindowTextEntryEditBox:SetText(ZO_ChatWindowTextEntryEditBox:GetText() .. string.gsub(actualItem.itemLink, '|H0', '|H1'))
  --end)
  control.itemName:SetHandler('OnMouseEnter', function() MasterMerchant.ShowToolTip(actualItem.itemLink, control.itemName) end)
  control.itemName:SetHandler('OnMouseExit', function() ClearTooltip(ItemTooltip) end)

  -- Quantity cell
  if actualItem.quant == 1 then control.quant:SetHidden(true)
  else
    control.quant:SetHidden(false)
    control.quant:SetText(actualItem.quant)
  end

  -- Sale time cell
  control.sellTime:SetText(MasterMerchant.TextTimeSince(actualItem.timestamp, false))

  -- Handle the setting of whether or not to show pre-cut sale prices
  -- math.floor(number + 0.5) is a quick shorthand way to round for
  -- positive values.
  local dispPrice = actualItem.price
  local quantity = actualItem.quant
  local settingsToUse = MasterMerchant:ActiveSettings()
  if settingsToUse.showFullPrice then
    if settingsToUse.showUnitPrice and quantity > 0 then dispPrice = math.floor((dispPrice / quantity) + 0.5) end
  else
    local cutPrice = dispPrice * (1 - (GetTradingHouseCutPercentage() / 100))
    if settingsToUse.showUnitPrice and quantity > 0 then cutPrice = cutPrice / quantity end
    dispPrice = math.floor(cutPrice + 0.5)
  end

  -- Insert thousands separators for the price
  local stringPrice = MasterMerchant.LocalizedNumber(dispPrice)

  -- Finally, set the price
  control.price:SetText(stringPrice .. ' |t16:16:EsoUI/Art/currency/currency_gold.dds|t')

  ZO_SortFilterList.SetupRow(self, control, data)
end

function MMScrollList:ColorRow(control, data, mouseIsOver)
  for i = 1, control:GetNumChildren() do
    local child = control:GetChild(i)
    if not child.nonRecolorable then
      if child:GetType() == CT_LABEL then
        if string.find(child:GetName(), 'Price$') then child:SetColor(0.84, 0.71, 0.15, 1)
        else child:SetColor(1, 1, 1, 1) end
      end
    end
  end
end

function MMScrollList:InitializeDataType(controlName)
  self.masterList = {}
  if controlName == 'MasterMerchantWindow' then
    ZO_ScrollList_AddDataType(self.list, 1, 'MasterMerchantDataRow', 36, function(control, data) self:SetupSalesRow(control, data) end)
  elseif controlName == 'MasterMerchantGuildWindow' then
    ZO_ScrollList_AddDataType(self.list, 1, 'MasterMerchantGuildDataRow', 36, function(control, data) self:SetupGuildSalesRow(control, data) end)
  else
    ZO_ScrollList_AddDataType(self.list, 1, 'MasterMerchantListingDataRow', 36, function(control, data) self:SetupListingsRow(control, data) end)
  end
  self:RefreshData()
end

function MMScrollList:New(control)
  local skList = ZO_SortFilterList.New(self, control)
  skList:InitializeDataType(control:GetName())
  if control:GetName() == 'MasterMerchantWindow' then
    skList.sortHeaderGroup:SelectHeaderByKey('time')
    ZO_SortHeader_OnMouseExit(MasterMerchantWindowHeadersSellTime)
  else 
    skList.sortHeaderGroup:SelectHeaderByKey('guildRank')
    ZO_SortHeader_OnMouseExit(MasterMerchantGuildWindowHeadersRank)
  end
  
  MasterMerchant.functionPostHook(skList, 'RefreshData', function()
    local texCon = skList.list.scrollbar:GetThumbTextureControl()
    if texCon:GetHeight() < 10 then skList.list.scrollbar:SetThumbTextureHeight(10) end
  end)

  return skList
end

function MasterMerchant.CleanupSearch(term)
  -- ( ) . % + - * ? [ ^ $ 
  term = string.gsub(term, '%(', '%%%(')
  term = string.gsub(term, '%)', '%%%)')
  term = string.gsub(term, '%.', '%%%.')
  term = string.gsub(term, '%+', '%%%+')
  term = string.gsub(term, '%-', '%%%-')
  term = string.gsub(term, '%*', '%%%*')  
  term = string.gsub(term, '%?', '%%%?')
  term = string.gsub(term, '%[', '%%%[')
  term = string.gsub(term, '%^', '%%%^')
  term = string.gsub(term, '%$', '%%%$')  
  return term
end


function MMScrollList:FilterScrollList()
  local settingsToUse = MasterMerchant:ActiveSettings()
  local listData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(listData)
  local searchText = nil
  if settingsToUse.viewSize == ITEMS then 
    searchText = MasterMerchantWindowSearchBox:GetText()
  elseif settingsToUse.viewSize == GUILDS then
   searchText = MasterMerchantGuildWindowSearchBox:GetText() 
  else
   searchText = MasterMerchantListingWindowSearchBox:GetText() 
  end
  if searchText then searchText = string.gsub(string.lower(searchText), '^%s*(.-)%s*$', '%1') end
  
  if settingsToUse.viewSize == ITEMS then
    -- return item sales
    if searchText == nil or searchText == '' then
      if MasterMerchant.viewMode == 'self' then
        local seenIndexes = {}
        for _, indexes in pairs(MasterMerchant.SSIndex) do
          for i = 1, #indexes do
            local itemID = indexes[i][1]
            local itemData = indexes[i][2]
            local itemIndex = indexes[i][3]
            if itemID and itemData and itemIndex then
              if seenIndexes[itemID] == nil then seenIndexes[itemID] = {} end
              if seenIndexes[itemID][itemData] == nil then seenIndexes[itemID][itemData] = {} end
              if seenIndexes[itemID][itemData][itemIndex] == nil then
                seenIndexes[itemID][itemData][itemIndex] = true
                local actualItem = MasterMerchant.salesData[itemID][itemData]['sales'][itemIndex]
                table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {itemID, itemData, itemIndex, actualItem.timestamp, actualItem.price, actualItem.quant}))
              end
            end
          end
        end
      else
        local timeCheck = MasterMerchant:TimeCheck()
        for k, v in pairs(MasterMerchant.salesData) do
          for j, dataList in pairs(v) do
            for i, item in ipairs(dataList['sales']) do
              if (item.timestamp > timeCheck) then
                table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {k, j, i, item.timestamp, item.price, item.quant}))
              end
            end
          end 
        end
      end
    else
      -- Break up search term into words
      local searchByWords = string.gmatch(searchText, '%S+')
      local indexToUse = ((MasterMerchant.viewMode == 'self') and MasterMerchant.SSIndex) or MasterMerchant.SRIndex
      local intersectionIndexes = {}

      -- Build up a list of indexes matching each word, then compute the intersection
      -- of those sets
      for searchWord in searchByWords do
        searchWord = MasterMerchant.CleanupSearch(searchWord)
        local addedIndexes = {}
        for key, indexes in pairs(indexToUse) do
          local findStatus, findResult = pcall(string.find, key, searchWord)
          if findStatus then
            if findResult then
              for i = 1, #indexes do
                if not addedIndexes[indexes[i][1]] then addedIndexes[indexes[i][1]] = {} end
                if not addedIndexes[indexes[i][1]][indexes[i][2]] then addedIndexes[indexes[i][1]][indexes[i][2]] = {} end
                addedIndexes[indexes[i][1]][indexes[i][2]][indexes[i][3]] = true
              end
            end
          end
        end

        -- If this is the first(or only) word, the intersection is itself
        if NonContiguousCount(intersectionIndexes) == 0 then
          intersectionIndexes = addedIndexes
        else
          -- Compute the intersection of the two
          local newIntersection = {}
          for k, val in pairs(intersectionIndexes) do
            if addedIndexes[k] then
              for j, subval in pairs(val) do
                if addedIndexes[k][j] then
                  for i in pairs(subval) do
                    if not newIntersection[k] then newIntersection[k] = {} end
                    if not newIntersection[k][j] then newIntersection[k][j] = {} end
                    newIntersection[k][j][i] = addedIndexes[k][j][i] 
                  end
                end
              end
            end
          end
          intersectionIndexes = newIntersection
        end
      end

      -- Now that we have the intersection, actually build the search table
      for k, val in pairs(intersectionIndexes) do
        for j, subval in pairs(val) do
          for i in pairs(subval) do
            local actualItem = MasterMerchant.salesData[k][j]['sales'][i]
            table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {k, j, i, actualItem.timestamp, actualItem.price, actualItem.quant}))
          end
        end
      end
    end
  elseif settingsToUse.viewSize == GUILDS then
    local dataSet = nil
    if settingsToUse.viewGuildBuyerSeller == 'buyer' then 
      dataSet = MasterMerchant.guildPurchases
    elseif settingsToUse.viewGuildBuyerSeller == 'seller' then
      dataSet = MasterMerchant.guildSales
    else
      if MasterMerchant.viewMode == 'self' then
        dataSet = MasterMerchant.myItems
      else
        dataSet = MasterMerchant.guildItems
      end
    end

    local guildList = ''
    local guildNum = 1
    while guildNum <= GetNumGuilds() do
      local guildID = GetGuildId(guildNum)
      guildList = guildList .. GetGuildName(guildID) .. ', '
      guildNum = guildNum + 1
    end

    local rankIndex = settingsToUse.rankIndex or 1
    if searchText == nil or searchText == '' then
      if MasterMerchant.viewMode == 'self' and settingsToUse.viewGuildBuyerSeller ~= 'item' then
        -- my guild sales  
        for gn, g in pairs(dataSet) do
          local sellerData = g.sellers[GetDisplayName()] or nil
          if (sellerData and sellerData.sales[rankIndex]) then 
            if (sellerData.sales[rankIndex] > 0) or (zo_plainstrfind(guildList, gn)) then
              table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, sellerData.sellerName, sellerData.sales[rankIndex], sellerData.rank[rankIndex], sellerData.count[rankIndex], sellerData.stack[rankIndex], g.sales[rankIndex], sellerData.tax[rankIndex], sellerData.outsideBuyer}))       
            end
          else
            if zo_plainstrfind(guildList, gn) then
              table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, GetDisplayName(), 0, 9999, 0, 0, g.sales[rankIndex], 0, false}))           
            end
          end
        end 
      else  
        -- all guild sales
        for gn, g in pairs(dataSet) do
          if (settingsToUse.viewGuildBuyerSeller ~= 'item') then
            if ((g.sales[rankIndex] or 0) > 0) or (zo_plainstrfind(guildList, gn)) then
              table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, GetString(MM_ENTIRE_GUILD), g.sales[rankIndex], 0, g.count[rankIndex], g.stack[rankIndex], g.sales[rankIndex], g.tax[rankIndex]}))
            end
          end
          for sn, sellerData in pairs(g.sellers) do
            if (sellerData and sellerData.sales[rankIndex]) then 
              if (sellerData.sales[rankIndex] > 0) or (zo_plainstrfind(guildList, gn)) then
                table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, sellerData.sellerName, sellerData.sales[rankIndex], sellerData.rank[rankIndex], sellerData.count[rankIndex], sellerData.stack[rankIndex], g.sales[rankIndex], sellerData.tax[rankIndex], sellerData.outsideBuyer}))       
              end
            else
              --table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, sellerData.sellerName, 0, 9999, 0, 0, g.sales[rankIndex], 0, false}))           
            end          
          end 
        end
      end
    else
      if MasterMerchant.viewMode == 'self' and settingsToUse.viewGuildBuyerSeller ~= 'item'  then
        -- my guild sales - filtered      
        for gn, g in pairs(dataSet) do
          -- Search the guild name for all words
          local matchesAll = true
          -- Break up search term into words
          local searchByWords = string.gmatch(searchText, '%S+')
          for searchWord in searchByWords do
            searchWord = MasterMerchant.CleanupSearch(searchWord)
            matchesAll = matchesAll and string.find(string.lower(gn), searchWord)
          end
          if matchesAll then 
            local sellerData = g.sellers[GetDisplayName()] or nil
            if (sellerData and sellerData.sales[rankIndex]) then 
              if (sellerData.sales[rankIndex] > 0) or (zo_plainstrfind(guildList, gn)) then
                table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, sellerData.sellerName, sellerData.sales[rankIndex], sellerData.rank[rankIndex], sellerData.count[rankIndex], sellerData.stack[rankIndex], g.sales[rankIndex], sellerData.tax[rankIndex], sellerData.outsideBuyer}))       
              end
            else
              --table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, GetDisplayName(), 0, 9999, 0, 0, g.sales[rankIndex], 0, false}))           
            end
          end
        end 
      else  
        -- all guild sales - filtered
        --DEBUG
        --local startTimer = GetTimeStamp()

        for gn, g in pairs(dataSet) do
          -- Search the guild name for all words
          local matchesAll = true
          -- Break up search term into words
          local searchByWords = string.gmatch(searchText, '%S+')
          for searchWord in searchByWords do
            searchWord = MasterMerchant.CleanupSearch(searchWord)
            matchesAll = matchesAll and string.find(string.lower(gn), searchWord)
          end
          if matchesAll and settingsToUse.viewGuildBuyerSeller ~= 'item' then   
            if ((g.sales[rankIndex] or 0) > 0) or (zo_plainstrfind(guildList, gn)) then
              table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, GetString(MM_ENTIRE_GUILD), g.sales[rankIndex], 0, g.count[rankIndex], g.stack[rankIndex], g.sales[rankIndex], g.tax[rankIndex], false}))
            end
          end
          for sn, sellerData in pairs(g.sellers) do
            -- Search the guild name and player name for all words
            local matchesAll = true
            -- Break up search term into words
            local searchByWords = string.gmatch(searchText, '%S+')
            for searchWord in searchByWords do
              searchWord = MasterMerchant.CleanupSearch(searchWord)
              local txt
              if settingsToUse.viewGuildBuyerSeller == 'item' then
                txt = string.lower(MasterMerchant.concat(gn, sellerData.searchText))
              else
                txt = string.lower(MasterMerchant.concat(gn, sellerData.sellerName))
              end
              matchesAll = matchesAll and string.find(txt, searchWord)
            end
            if matchesAll then   
              if (sellerData.sales[rankIndex] and (sellerData.sales[rankIndex] > 0)) then 
                table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, sellerData.sellerName, sellerData.sales[rankIndex], sellerData.rank[rankIndex], sellerData.count[rankIndex], sellerData.stack[rankIndex], g.sales[rankIndex], sellerData.tax[rankIndex], sellerData.outsideBuyer}))       
              else
                --table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, sellerData.sellerName, 0, 9999, 0, 0, g.sales[rankIndex], 0, false}))           
              end    
            end
          end
        end
        --DEBUG
        --d('Filter Time' .. ': ' .. GetTimeStamp() - startTimer)

      end      
    end
  elseif settingsToUse.viewSize == LISTINGS then
    local dataSet = nil
    if settingsToUse.viewGuildBuyerSeller == 'buyer' then 
      dataSet = MasterMerchant.guildPurchases
    elseif settingsToUse.viewGuildBuyerSeller == 'seller' then
      dataSet = MasterMerchant.guildSales
    else
      if MasterMerchant.viewMode == 'self' then
        dataSet = MasterMerchant.myItems
      else
        dataSet = MasterMerchant.guildItems
      end
    end

    local guildList = ''
    local guildNum = 1
    while guildNum <= GetNumGuilds() do
      local guildID = GetGuildId(guildNum)
      guildList = guildList .. GetGuildName(guildID) .. ', '
      guildNum = guildNum + 1
    end

    local rankIndex = settingsToUse.rankIndex or 1
    if searchText == nil or searchText == '' then
      if MasterMerchant.viewMode == 'self' and settingsToUse.viewGuildBuyerSeller ~= 'item' then
        -- my guild sales  
        for gn, g in pairs(dataSet) do
          local sellerData = g.sellers[GetDisplayName()] or nil
          if (sellerData and sellerData.sales[rankIndex]) then 
            if (sellerData.sales[rankIndex] > 0) or (zo_plainstrfind(guildList, gn)) then
              table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, sellerData.sellerName, sellerData.sales[rankIndex], sellerData.rank[rankIndex], sellerData.count[rankIndex], sellerData.stack[rankIndex], g.sales[rankIndex], sellerData.tax[rankIndex], sellerData.outsideBuyer}))       
            end
          else
            if zo_plainstrfind(guildList, gn) then
              table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, GetDisplayName(), 0, 9999, 0, 0, g.sales[rankIndex], 0, false}))           
            end
          end
        end 
      else  
        -- all guild sales
        for gn, g in pairs(dataSet) do
          if (settingsToUse.viewGuildBuyerSeller ~= 'item') then
            if ((g.sales[rankIndex] or 0) > 0) or (zo_plainstrfind(guildList, gn)) then
              table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, GetString(MM_ENTIRE_GUILD), g.sales[rankIndex], 0, g.count[rankIndex], g.stack[rankIndex], g.sales[rankIndex], g.tax[rankIndex]}))
            end
          end
          for sn, sellerData in pairs(g.sellers) do
            if (sellerData and sellerData.sales[rankIndex]) then 
              if (sellerData.sales[rankIndex] > 0) or (zo_plainstrfind(guildList, gn)) then
                table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, sellerData.sellerName, sellerData.sales[rankIndex], sellerData.rank[rankIndex], sellerData.count[rankIndex], sellerData.stack[rankIndex], g.sales[rankIndex], sellerData.tax[rankIndex], sellerData.outsideBuyer}))       
              end
            else
              --table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, sellerData.sellerName, 0, 9999, 0, 0, g.sales[rankIndex], 0, false}))           
            end          
          end 
        end
      end
    else
      if MasterMerchant.viewMode == 'self' and settingsToUse.viewGuildBuyerSeller ~= 'item'  then
        -- my guild sales - filtered      
        for gn, g in pairs(dataSet) do
          -- Search the guild name for all words
          local matchesAll = true
          -- Break up search term into words
          local searchByWords = string.gmatch(searchText, '%S+')
          for searchWord in searchByWords do
            searchWord = MasterMerchant.CleanupSearch(searchWord)
            matchesAll = matchesAll and string.find(string.lower(gn), searchWord)
          end
          if matchesAll then 
            local sellerData = g.sellers[GetDisplayName()] or nil
            if (sellerData and sellerData.sales[rankIndex]) then 
              if (sellerData.sales[rankIndex] > 0) or (zo_plainstrfind(guildList, gn)) then
                table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, sellerData.sellerName, sellerData.sales[rankIndex], sellerData.rank[rankIndex], sellerData.count[rankIndex], sellerData.stack[rankIndex], g.sales[rankIndex], sellerData.tax[rankIndex], sellerData.outsideBuyer}))       
              end
            else
              --table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, GetDisplayName(), 0, 9999, 0, 0, g.sales[rankIndex], 0, false}))           
            end
          end
        end 
      else  
        -- all guild sales - filtered
        --DEBUG
        --local startTimer = GetTimeStamp()

        for gn, g in pairs(dataSet) do
          -- Search the guild name for all words
          local matchesAll = true
          -- Break up search term into words
          local searchByWords = string.gmatch(searchText, '%S+')
          for searchWord in searchByWords do
            searchWord = MasterMerchant.CleanupSearch(searchWord)
            matchesAll = matchesAll and string.find(string.lower(gn), searchWord)
          end
          if matchesAll and settingsToUse.viewGuildBuyerSeller ~= 'item' then   
            if ((g.sales[rankIndex] or 0) > 0) or (zo_plainstrfind(guildList, gn)) then
              table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, GetString(MM_ENTIRE_GUILD), g.sales[rankIndex], 0, g.count[rankIndex], g.stack[rankIndex], g.sales[rankIndex], g.tax[rankIndex], false}))
            end
          end
          for sn, sellerData in pairs(g.sellers) do
            -- Search the guild name and player name for all words
            local matchesAll = true
            -- Break up search term into words
            local searchByWords = string.gmatch(searchText, '%S+')
            for searchWord in searchByWords do
              searchWord = MasterMerchant.CleanupSearch(searchWord)
              local txt
              if settingsToUse.viewGuildBuyerSeller == 'item' then
                txt = string.lower(MasterMerchant.concat(gn, sellerData.searchText))
              else
                txt = string.lower(MasterMerchant.concat(gn, sellerData.sellerName))
              end
              matchesAll = matchesAll and string.find(txt, searchWord)
            end
            if matchesAll then   
              if (sellerData.sales[rankIndex] and (sellerData.sales[rankIndex] > 0)) then 
                table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, sellerData.sellerName, sellerData.sales[rankIndex], sellerData.rank[rankIndex], sellerData.count[rankIndex], sellerData.stack[rankIndex], g.sales[rankIndex], sellerData.tax[rankIndex], sellerData.outsideBuyer}))       
              else
                --table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {gn, sellerData.sellerName, 0, 9999, 0, 0, g.sales[rankIndex], 0, false}))           
              end    
            end
          end
        end
        --DEBUG
        --d('Filter Time' .. ': ' .. GetTimeStamp() - startTimer)

      end      
    end
  end
end

function MMScrollList:SortScrollList()
  if self.currentSortKey == 'price' then 
    MasterMerchant:SortByPrice(self.currentSortOrder, self)
  elseif self.currentSortKey == 'time' then
    MasterMerchant:SortByTime(self.currentSortOrder, self)
  elseif self.currentSortKey == 'rank' then
    MasterMerchant:SortByRank(self.currentSortOrder, self)
  elseif self.currentSortKey == 'sales' then
    MasterMerchant:SortBySales(self.currentSortOrder, self)
  elseif self.currentSortKey == 'count' then
    MasterMerchant:SortByCount(self.currentSortOrder, self)    
  elseif self.currentSortKey == 'tax' then
    MasterMerchant:SortByTax(self.currentSortOrder, self)   
  elseif self.currentSortKey == 'name' then
    MasterMerchant:SortByName(self.currentSortOrder, self)   
  elseif self.currentSortKey == 'itemGuildName' then
    MasterMerchant:SortByItemGuildName(self.currentSortOrder, self)   
  elseif self.currentSortKey == 'guildName' then
    MasterMerchant:SortByGuildName(self.currentSortOrder, self)   
  end
end

-- Handle the OnMoveStop event for the windows
function MasterMerchant:OnWindowMoveStop(windowMoved)
  local settingsToUse = MasterMerchant:ActiveSettings()

  if windowMoved == MasterMerchantWindow then
    settingsToUse.winLeft = MasterMerchantWindow:GetLeft()
    settingsToUse.winTop = MasterMerchantWindow:GetTop()

    settingsToUse.guildWinLeft = MasterMerchantWindow:GetLeft()
    settingsToUse.guildWinTop = MasterMerchantWindow:GetTop()
    MasterMerchantGuildWindow:ClearAnchors()
    MasterMerchantGuildWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settingsToUse.guildWinLeft, settingsToUse.guildWinTop)
  elseif windowMoved == MasterMerchantGuildWindow then
    settingsToUse.guildWinLeft = MasterMerchantGuildWindow:GetLeft()
    settingsToUse.guildWinTop = MasterMerchantGuildWindow:GetTop()

    settingsToUse.winLeft = MasterMerchantGuildWindow:GetLeft()
    settingsToUse.winTop = MasterMerchantGuildWindow:GetTop()
    MasterMerchantWindow:ClearAnchors()
    MasterMerchantWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settingsToUse.winLeft, settingsToUse.winTop)
  elseif windowMoved == MasterMerchantStatsWindow then
    settingsToUse.statsWinLeft = MasterMerchantStatsWindow:GetLeft()
    settingsToUse.statsWinTop = MasterMerchantStatsWindow:GetTop()
  else 
    settingsToUse.feedbackWinLeft = MasterMerchantFeedback:GetLeft()
    settingsToUse.feedbackWinTop = MasterMerchantFeedback:GetTop()
  end
end

-- Restore the window positions from saved vars
function MasterMerchant:RestoreWindowPosition()
  local settingsToUse = MasterMerchant:ActiveSettings()

  MasterMerchantWindow:ClearAnchors()
  MasterMerchantStatsWindow:ClearAnchors()
  MasterMerchantGuildWindow:ClearAnchors()
  MasterMerchantFeedback:ClearAnchors()

  MasterMerchantWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settingsToUse.winLeft, settingsToUse.winTop)
  MasterMerchantStatsWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settingsToUse.statsWinLeft, settingsToUse.statsWinTop)
  MasterMerchantGuildWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settingsToUse.guildWinLeft, settingsToUse.guildWinTop)
  MasterMerchantFeedback:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settingsToUse.feedbackWinLeft, settingsToUse.feedbackWinTop)
end

-- Handle the changing of window font settings
function MasterMerchant:UpdateFonts()
  local LMP = LibStub('LibMediaProvider-1.0')
  if LMP then
    local font = LMP:Fetch('font', MasterMerchant:ActiveSettings().windowFont)
    local fontString = font .. '|%d'
    local mainButtonLabel = 14
    local mainTitle = 26
    local mainHeader = 17
    local guildButtonLabel = 14
    local guildTitle = 26
    local guildHeader = 17
    local guildQuant = 10

    -- Main Window
    MasterMerchantWindowHeadersBuyer:GetNamedChild('Name'):SetFont(string.format(fontString, mainHeader))
    MasterMerchantWindowHeadersGuild:GetNamedChild('Name'):SetFont(string.format(fontString, mainHeader))
    MasterMerchantWindowHeadersItemName:GetNamedChild('Name'):SetFont(string.format(fontString, mainHeader))
    MasterMerchantWindowHeadersSellTime:GetNamedChild('Name'):SetFont(string.format(fontString, mainHeader))
    MasterMerchantWindowHeadersPrice:GetNamedChild('Name'):SetFont(string.format(fontString, mainHeader))
    MasterMerchantWindowSearchBox:SetFont(string.format(fontString, mainButtonLabel))
    MasterMerchantWindowTitle:SetFont(string.format(fontString, mainTitle))
    MasterMerchantSwitchViewButton:SetFont(string.format(fontString, mainButtonLabel))
    MasterMerchantPriceSwitchButton:SetFont(string.format(fontString, mainButtonLabel))
    MasterMerchantResetButton:SetFont(string.format(fontString, mainButtonLabel))
    MasterMerchantRefreshButton:SetFont(string.format(fontString, mainButtonLabel))

    -- Guild Window
    MasterMerchantGuildWindowHeadersGuild:GetNamedChild('Name'):SetFont(string.format(fontString, guildHeader))
    MasterMerchantGuildWindowHeadersSeller:GetNamedChild('Name'):SetFont(string.format(fontString, guildHeader))
    MasterMerchantGuildWindowHeadersRank:GetNamedChild('Name'):SetFont(string.format(fontString, guildHeader))
    MasterMerchantGuildWindowHeadersSales:GetNamedChild('Name'):SetFont(string.format(fontString, guildHeader))
    MasterMerchantGuildWindowHeadersTax:GetNamedChild('Name'):SetFont(string.format(fontString, guildHeader))
    MasterMerchantGuildWindowHeadersCount:GetNamedChild('Name'):SetFont(string.format(fontString, guildHeader))    
    MasterMerchantGuildWindowHeadersPercent:GetNamedChild('Name'):SetFont(string.format(fontString, guildHeader))    
    MasterMerchantGuildWindowSearchBox:SetFont(string.format(fontString, guildButtonLabel))
    MasterMerchantGuildWindowTitle:SetFont(string.format(fontString, guildTitle))
    MasterMerchantGuildSwitchViewButton:SetFont(string.format(fontString, guildButtonLabel))
    MasterMerchantGuildResetButton:SetFont(string.format(fontString, guildButtonLabel))
    MasterMerchantGuildRefreshButton:SetFont(string.format(fontString, guildButtonLabel))

    -- Stats Window
    MasterMerchantStatsWindowTitle:SetFont(string.format(fontString, mainTitle))
    MasterMerchantStatsWindowGuildChooserLabel:SetFont(string.format(fontString, mainHeader))
    MasterMerchantStatsGuildChooser.m_comboBox:SetFont(string.format(fontString, mainHeader))
    MasterMerchantStatsWindowItemsSoldLabel:SetFont(string.format(fontString, mainHeader))
    MasterMerchantStatsWindowTotalGoldLabel:SetFont(string.format(fontString, mainHeader))
    MasterMerchantStatsWindowBiggestSaleLabel:SetFont(string.format(fontString, mainHeader))
    MasterMerchantStatsWindowSliderSettingLabel:SetFont(string.format(fontString, mainHeader))
    MasterMerchantStatsWindowSliderLabel:SetFont(string.format(fontString, mainButtonLabel))

    MasterMerchantFeedbackTitle:SetFont(string.format(fontString, mainTitle))
    MasterMerchantFeedbackNote:SetFont(string.format(fontString, mainHeader))
    MasterMerchantFeedbackNote:SetText("I hope you are enjoying Master Merchant.  Your feedback is always welcome, so please drop me a note with or without a donation.  Your donation will help me focus my non adventuring ESO time on more features, and keep me from becoming a Nirn farmer.  Or you can donate a little real money here: http://tinyurl.com/ESOMMDonate")
  end
end

function MasterMerchant:updateCalc()
  local stackSize = string.match(MasterMerchantPriceCalculatorStack:GetText(), 'x (%d+)')
  local totalPrice = math.floor(tonumber(MasterMerchantPriceCalculatorUnitCostAmount:GetText()) * tonumber(stackSize))
  MasterMerchantPriceCalculatorTotal:SetText(GetString(MM_TOTAL_TITLE) .. MasterMerchant.LocalizedNumber(totalPrice) .. ' |t16:16:EsoUI/Art/currency/currency_gold.dds|t')
  TRADING_HOUSE:SetPendingPostPrice(totalPrice)
end


function MasterMerchant:remStatsItemTooltip() 
  self.tippingControl = nil 
  if ItemTooltip.graphPool then
    ItemTooltip.graphPool:ReleaseAllObjects()
  end
  ItemTooltip.mmGraph = nil
  if ItemTooltip.textPool then
    ItemTooltip.textPool:ReleaseAllObjects()
  end
  ItemTooltip.mmText = nil
  ItemTooltip.mmTextDebug = nil
  ItemTooltip.mmQualityDown = nil
 end

function MasterMerchant:addStatsAndGraph(tooltip, itemLink, clickable)
  
  if not (self:ActiveSettings().showPricing or self:ActiveSettings().showGraph) then return end

  local tipLine, avePrice, graphInfo = self:itemPriceTip(itemLink, false, clickable)

  if not tooltip.textPool then
    tooltip.textPool = ZO_ControlPool:New('MMGraphLabel', tooltip, 'Text')
  end

  if self:ActiveSettings().displayItemAnalysisButtons and not tooltip.mmQualityDown then
    tooltip.mmQualityDown = tooltip.textPool:AcquireObject()
    tooltip:AddControl(tooltip.mmQualityDown, 1, true)
    tooltip.mmQualityDown:SetAnchor(LEFT)   
    tooltip.mmQualityDown:SetText('<<')    
    tooltip.mmQualityDown:SetMouseEnabled(true)
  	tooltip.mmQualityDown:SetHandler("OnMouseUp", MasterMerchant.NextItem)
    tooltip.mmQualityDown.mmData = {}
    tooltip.mmQualityDown:SetHidden(true)

    tooltip.mmQualityUp = tooltip.textPool:AcquireObject()
    tooltip:AddControl(tooltip.mmQualityUp, 1, true)
    tooltip.mmQualityUp:SetAnchor(RIGHT)   
    tooltip.mmQualityUp:SetText('>>')
    tooltip.mmQualityUp:SetMouseEnabled(true)
  	tooltip.mmQualityUp:SetHandler("OnMouseUp", MasterMerchant.NextItem)
    tooltip.mmQualityUp.mmData = {}
    tooltip.mmQualityUp:SetHidden(true)

    tooltip.mmLevelDown = tooltip.textPool:AcquireObject()
    tooltip:AddControl(tooltip.mmLevelDown, 1, true)
    tooltip.mmLevelDown:ClearAnchors()
    tooltip.mmLevelDown:SetAnchor(TOPLEFT, tooltip.mmQualityDown, BOTTOMLEFT, 0, 0)
    tooltip.mmLevelDown:SetText('< L')
    tooltip.mmLevelDown:SetColor(1,1,1,1)
    tooltip.mmLevelDown:SetMouseEnabled(true)
  	tooltip.mmLevelDown:SetHandler("OnMouseUp", MasterMerchant.NextItem)
    tooltip.mmLevelDown.mmData = {}
    tooltip.mmLevelDown:SetHidden(true)

    tooltip.mmLevelUp = tooltip.textPool:AcquireObject()
    tooltip:AddControl(tooltip.mmLevelUp, 1, true)
    tooltip.mmLevelUp:ClearAnchors()
    tooltip.mmLevelUp:SetAnchor(TOPRIGHT, tooltip.mmQualityUp, BOTTOMRIGHT, 0, 0)
    tooltip.mmLevelUp:SetText('L >')
    tooltip.mmLevelUp:SetColor(1,1,1,1)
    tooltip.mmLevelUp:SetMouseEnabled(true)
  	tooltip.mmLevelUp:SetHandler("OnMouseUp", MasterMerchant.NextItem)
    tooltip.mmLevelUp.mmData = {}
    tooltip.mmLevelUp:SetHidden(true)

    tooltip.mmSalesDataDown = tooltip.textPool:AcquireObject()
    tooltip:AddControl(tooltip.mmSalesDataDown, 1, true)
    tooltip.mmSalesDataDown:ClearAnchors()
    tooltip.mmSalesDataDown:SetAnchor(BOTTOMLEFT, tooltip.mmQualityDown, TOPLEFT, 0, 0)
    tooltip.mmSalesDataDown:SetText('<SI')
    tooltip.mmSalesDataDown:SetColor(1,1,1,1)
    tooltip.mmSalesDataDown:SetMouseEnabled(true)
  	tooltip.mmSalesDataDown:SetHandler("OnMouseUp", MasterMerchant.NextItem)
    tooltip.mmSalesDataDown.mmData = {}
    tooltip.mmSalesDataDown:SetHidden(true)

    tooltip.mmSalesDataUp = tooltip.textPool:AcquireObject()
    tooltip:AddControl(tooltip.mmSalesDataUp, 1, true)
    tooltip.mmSalesDataUp:ClearAnchors()
    tooltip.mmSalesDataUp:SetAnchor(BOTTOMRIGHT, tooltip.mmQualityUp, TOPRIGHT, 0, 0)
    tooltip.mmSalesDataUp:SetText('SI>')
    tooltip.mmSalesDataUp:SetColor(1,1,1,1)
    tooltip.mmSalesDataUp:SetMouseEnabled(true)
  	tooltip.mmSalesDataUp:SetHandler("OnMouseUp", MasterMerchant.NextItem)
    tooltip.mmSalesDataUp.mmData = {}
    tooltip.mmSalesDataUp:SetHidden(true)
  end

  local itemType = GetItemLinkItemType(itemLink)
  if (clickable) and self:ActiveSettings().displayItemAnalysisButtons and (itemType == 1 or itemType == 2 or itemType == 20 or itemType == 21 or itemType == 26) then
    
    local itemQuality = GetItemLinkQuality(itemLink)  
    tooltip.mmQualityDown.mmData.nextItem = MasterMerchant.QualityDown(itemLink)
    --d(tooltip.mmQualityDown.mmData.nextItem)
    if tooltip.mmQualityDown.mmData.nextItem then
      local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, itemQuality - 1)
      tooltip.mmQualityDown:SetColor(r,g,b,1)
      tooltip.mmQualityDown:SetHidden(false)    
    else
      tooltip.mmQualityDown:SetHidden(true)
    end

    tooltip.mmQualityUp.mmData.nextItem = MasterMerchant.QualityUp(itemLink)
    --d(tooltip.mmQualityUp.mmData.nextItem)
    if tooltip.mmQualityUp.mmData.nextItem then
      local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, itemQuality + 1)
      tooltip.mmQualityUp:SetColor(r,g,b,1)
      tooltip.mmQualityUp:SetHidden(false)
    else
      tooltip.mmQualityUp:SetHidden(true)
    end

    tooltip.mmLevelDown.mmData.nextItem = MasterMerchant.LevelDown(itemLink)
    --d(tooltip.mmLevelDown.mmData.nextItem)
    if tooltip.mmLevelDown.mmData.nextItem then
      tooltip.mmLevelDown:SetHidden(false)    
    else
      tooltip.mmLevelDown:SetHidden(true)
    end

    tooltip.mmLevelUp.mmData.nextItem = MasterMerchant.LevelUp(itemLink)
    --d(tooltip.mmLevelUp.mmData.nextItem)
    if tooltip.mmLevelUp.mmData.nextItem then
      tooltip.mmLevelUp:SetHidden(false)    
    else
      tooltip.mmLevelUp:SetHidden(true)
    end

    tooltip.mmSalesDataDown.mmData.nextItem = MasterMerchant.Down(itemLink)
    while tooltip.mmSalesDataDown.mmData.nextItem and not self:itemHasSales(tooltip.mmSalesDataDown.mmData.nextItem) do
        tooltip.mmSalesDataDown.mmData.nextItem = MasterMerchant.Down(tooltip.mmSalesDataDown.mmData.nextItem)
    end
    --d(tooltip.mmSalesDataDown.mmData.nextItem)
    if tooltip.mmSalesDataDown.mmData.nextItem then
      tooltip.mmSalesDataDown:SetHidden(false)    
    else
      tooltip.mmSalesDataDown:SetHidden(true)
    end

    tooltip.mmSalesDataUp.mmData.nextItem = MasterMerchant.Up(itemLink)
    while tooltip.mmSalesDataUp.mmData.nextItem and not self:itemHasSales(tooltip.mmSalesDataUp.mmData.nextItem) do
        tooltip.mmSalesDataUp.mmData.nextItem = MasterMerchant.Up(tooltip.mmSalesDataUp.mmData.nextItem)
    end
    --d(tooltip.mmSalesDataUp.mmData.nextItem)
    if tooltip.mmSalesDataUp.mmData.nextItem then
      tooltip.mmSalesDataUp:SetHidden(false)    
    else
      tooltip.mmSalesDataUp:SetHidden(true)
    end

  end
  
  if tipLine then

    if self:ActiveSettings().showPricing then

      if not tooltip.mmText then
        tooltip:AddVerticalPadding(5)
        ZO_Tooltip_AddDivider(tooltip)
        tooltip:AddVerticalPadding(5)   
        tooltip.mmText = tooltip.textPool:AcquireObject()
        tooltip:AddControl(tooltip.mmText)
        tooltip.mmText:SetAnchor(CENTER)   
      end

      if tooltip.mmText then
        tooltip.mmText:SetText(tipLine)
        tooltip.mmText:SetColor(1,1,1,1)
      end
    end

    if self:ActiveSettings().showGraph then

      if not tooltip.graphPool then
          tooltip.graphPool = ZO_ControlPool:New('MasterMerchantGraph', tooltip, 'Graph')
      end

      if not tooltip.mmGraph then
        tooltip.mmGraph = tooltip.graphPool:AcquireObject()
        if not tooltip.mmText then 
          tooltip:AddVerticalPadding(5)
          ZO_Tooltip_AddDivider(tooltip)
        end
        tooltip:AddVerticalPadding(5)
        tooltip:AddControl(tooltip.mmGraph)
        tooltip.mmGraph:SetAnchor(CENTER)
      end

      if tooltip.mmGraph then
        local graph = tooltip.mmGraph

        if not graph.points then
          graph.points = MM_Graph:New(graph)
        end
        local format = (self:ActiveSettings().trimDecimals and '%.0f') or '%.2f'
        if graphInfo.low == graphInfo.high then
            graphInfo.low = avePrice * 0.85
            graphInfo.high = avePrice * 1.15
        end

        local xLow = string.format(format, graphInfo.low) .. '|t16:16:EsoUI/Art/currency/currency_gold.dds|t'
        local xHigh = string.format(format, graphInfo.high) .. '|t16:16:EsoUI/Art/currency/currency_gold.dds|t'
        graph.points:Initialize(MasterMerchant.TextTimeSince(graphInfo.oldestTime), "Now", xLow, xHigh, graphInfo.oldestTime, GetTimeStamp(), graphInfo.low, graphInfo.high)
        if self:ActiveSettings().displaySalesDetails then
          for _, point in ipairs(graphInfo.points) do
              graph.points:AddPoint(point[1], point[2], point[3], point[4])
          end
        else
          for _, point in ipairs(graphInfo.points) do
              graph.points:AddPoint(point[1], point[2], point[3], nil)
          end
        end
        local xPrice = string.format(format, avePrice) .. '|t16:16:EsoUI/Art/currency/currency_gold.dds|t'
        graph.points:AddYLabel(xPrice, avePrice)

      end
    end
  else
  -- No data returned
  end

  --DEBUG ITEM INFO
  --[[
  if not tooltip.mmTextDebug then
    tooltip.mmTextDebug = tooltip.textPool:AcquireObject()
    tooltip:AddControl(tooltip.mmTextDebug)
    tooltip.mmTextDebug:SetAnchor(CENTER)   
  end

  local itemInfo = MasterMerchant.ItemCodeText(itemLink)
  --local itemInfo = string.match(itemLink, '|H.-:item:(.-):')
  itemInfo = itemInfo .. ' - ' .. MasterMerchant.makeIndexFromLink(itemLink)
  itemInfo = itemInfo .. ' - ' .. MasterMerchant.addedSearchToItem(itemLink)
  --local itemType = GetItemLinkItemType(itemLink)
  --itemInfo = '(' .. itemType .. ')' .. itemInfo 
  if itemInfo then
    tooltip.mmTextDebug:SetText(string.format('%s', itemInfo))
    tooltip.mmTextDebug:SetColor(1,1,1,1)
  else
    tooltip.mmTextDebug:SetText('What')
    tooltip.mmTextDebug:SetColor(1,1,1,1)
  end
  --]]

end

function MasterMerchant.NextItem(control, button)
    if control and button == MOUSE_BUTTON_INDEX_LEFT and ZO_PopupTooltip_SetLink then
      ZO_PopupTooltip_SetLink(control.mmData.nextItem)
    end
end

function MasterMerchant.ThisItem(control, button)
    if button == MOUSE_BUTTON_INDEX_RIGHT then
      ZO_LinkHandler_OnLinkMouseUp(PopupTooltip.lastLink, button, control)
    end
end


-- |H<style>:<type>[:<data>...]|h<text>|h 
function MasterMerchant:addStatsPopupTooltip()

  --Make sure Info Tooltip and Context Menu is on top of the popup
  --InformationTooltip:GetOwningWindow():BringWindowToTop()
  PopupTooltip:GetOwningWindow():SetDrawTier(ZO_Menus:GetDrawTier() - 1)
 	PopupTooltip:SetHandler("OnMouseUp", MasterMerchant.ThisItem)

  -- Make sure we don't double-add stats (or double-calculate them if they bring
  -- up the same link twice) since we have to call this on Update rather than Show
  if (not (self:ActiveSettings().showPricing or self:ActiveSettings().showGraph))
   or PopupTooltip.lastLink == nil 
   or (self.activeTip and self.activeTip == PopupTooltip.lastLink and self.isShiftPressed == IsShiftKeyDown() and self.isCtrlPressed == IsControlKeyDown()) then -- thanks Garkin  
    return 
  end 

  if self.activeTip ~= PopupTooltip.lastLink then  
    if PopupTooltip.graphPool then
      PopupTooltip.graphPool:ReleaseAllObjects()
    end
    PopupTooltip.mmGraph = nil
    if PopupTooltip.textPool then
      PopupTooltip.textPool:ReleaseAllObjects()
    end
    PopupTooltip.mmText = nil
    PopupTooltip.mmTextDebug = nil
    PopupTooltip.mmQualityDown = nil
  end
  self.activeTip = PopupTooltip.lastLink
  self.isShiftPressed = IsShiftKeyDown()
  self.isCtrlPressed = IsControlKeyDown()

  self:addStatsAndGraph(PopupTooltip, self.activeTip, true)
end

function MasterMerchant:remStatsPopupTooltip() 
  self.activeTip = nil
  if PopupTooltip.graphPool then
    PopupTooltip.graphPool:ReleaseAllObjects()
  end
  PopupTooltip.mmGraph = nil
  if PopupTooltip.textPool then
    PopupTooltip.textPool:ReleaseAllObjects()
  end
  PopupTooltip.mmText = nil
  PopupTooltip.mmTextDebug = nil
  PopupTooltip.mmQualityDown = nil
end

-- ItemTooltips get used all over the place, we have to figure out
-- who the control generating the tooltip is so we know
-- how to grab the item data
function MasterMerchant:addStatsItemTooltip()
  local skMoc = moc()
  -- Make sure we don't double-add stats or try to add them to nothing
  -- Since we call this on Update rather than Show it gets called a lot
  -- even after the tip appears
  if (not (self:ActiveSettings().showPricing or self:ActiveSettings().showGraph))
     or (not skMoc or not skMoc:GetParent()) 
     or (skMoc == self.tippingControl and self.isShiftPressed == IsShiftKeyDown() and self.isCtrlPressed == IsControlKeyDown()) then 
    return 
  end

  local itemLink = nil
  local mocParent = skMoc:GetParent():GetName()

  -- Store screen
  if mocParent == 'ZO_StoreWindowListContents' then itemLink = GetStoreItemLink(skMoc.index)
  -- Store buyback screen
  elseif mocParent == 'ZO_BuyBackListContents' then itemLink = GetBuybackItemLink(skMoc.index)
  -- Guild store posted items
  elseif mocParent == 'ZO_TradingHousePostedItemsListContents' then
    local mocData = skMoc.dataEntry.data
    itemLink = GetTradingHouseListingItemLink(mocData.slotIndex)
  -- Guild store search
  elseif mocParent == 'ZO_TradingHouseItemPaneSearchResultsContents' then
    local rData = skMoc.dataEntry and skMoc.dataEntry.data or nil
    -- The only thing with 0 time remaining should be guild tabards, no
    -- stats on those!
    if not rData or rData.timeRemaining == 0 then return end
    itemLink = GetTradingHouseSearchResultItemLink(rData.slotIndex)
  -- Guild store item posting
  elseif mocParent == 'ZO_TradingHouseLeftPanePostItemFormInfo' then
    if skMoc.slotIndex and skMoc.bagId then itemLink = GetItemLink(skMoc.bagId, skMoc.slotIndex) end
  -- Player bags (and bank) (and crafting tables)
  elseif mocParent == 'ZO_PlayerInventoryBackpackContents' or
         mocParent == 'ZO_PlayerInventoryListContents' or
         mocParent == 'ZO_CraftBagListContents' or
         mocParent == 'ZO_QuickSlotListContents' or
         mocParent == 'ZO_PlayerBankBackpackContents' or
         mocParent == 'ZO_SmithingTopLevelImprovementPanelInventoryBackpackContents' or
         mocParent == 'ZO_SmithingTopLevelDeconstructionPanelInventoryBackpackContents' or
         mocParent == 'ZO_SmithingTopLevelRefinementPanelInventoryBackpackContents' or
         mocParent == 'ZO_EnchantingTopLevelInventoryBackpackContents' or
         mocParent == 'ZO_GuildBankBackpackContents' then
         if skMoc and skMoc.dataEntry then
            local rData = skMoc.dataEntry.data
            itemLink = GetItemLink(rData.bagId, rData.slotIndex)
         end
  -- Worn equipment
  elseif mocParent == 'ZO_Character' then itemLink = GetItemLink(skMoc.bagId, skMoc.slotIndex)
  -- Loot window if autoloot is disabled
  elseif mocParent == 'ZO_LootAlphaContainerListContents' then itemLink = GetLootItemLink(skMoc.dataEntry.data.lootId)
  elseif mocParent == 'ZO_MailInboxMessageAttachments' then itemLink = GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), skMoc.id, LINK_STYLE_DEFAULT)
  elseif mocParent == 'ZO_MailSendAttachments' then itemLink = GetMailQueuedAttachmentLink(skMoc.id, LINK_STYLE_DEFAULT)
  --elseif mocParent == 'ZO_SmithingTopLevelImprovementPanelSlotContainer' then
  --d(skMoc)

  -- MasterMerchant windows
  else
    local mocGP = skMoc:GetParent():GetParent()
    if mocGP and (mocGP:GetName() == 'MasterMerchantWindowListContents' or mocGP:GetName() == 'MasterMerchantWindowList' or  mocGP:GetName() == 'MasterMerchantGuildWindowListContents') then
      local itemLabel = skMoc --:GetLabelControl()
      if itemLabel and itemLabel.GetText then 
        itemLink = itemLabel:GetText() 
      end
    else 
      --DEBUG
      --d(mocParent)
      --'ZO_ListDialog1ListContents'  
      --ZO_SmithingTopLevelImprovementPanelSlotContainer
    end
  end

  if itemLink then
    if self.tippingControl ~= skMoc then
      if ItemTooltip.graphPool then
        ItemTooltip.graphPool:ReleaseAllObjects()
      end
      ItemTooltip.mmGraph = nil
      if ItemTooltip.textPool then
        ItemTooltip.textPool:ReleaseAllObjects()
      end
      ItemTooltip.mmText = nil
      ItemTooltip.mmTextDebug = nil
      ItemTooltip.mmQualityDown = nil
    end

    self.tippingControl = skMoc
    self.isShiftPressed = IsShiftKeyDown()
    self.isCtrlPressed = IsControlKeyDown()
    self:addStatsAndGraph(ItemTooltip, itemLink)
  end

end


-- Display item tooltips
function MasterMerchant.ShowToolTip(itemName, itemButton)
  InitializeTooltip(ItemTooltip, itemButton)
  ItemTooltip:SetLink(itemName)
end

function MasterMerchant:HeaderToolTip(control, tipString)
  InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -5)
  SetTooltipText(InformationTooltip, tipString)
end

-- Update Guild Sales window to use the selected date range
function MasterMerchant:UpdateGuildWindow(rankIndex)
  if not rankIndex or rankIndex == 0 then rankIndex = 1 end
  local settingsToUse = MasterMerchant:ActiveSettings()
  settingsToUse.rankIndex = rankIndex
  self.guildScrollList:RefreshFilters()
end


-- Update Guild Roster window to use the selected date range
function MasterMerchant:UpdateRosterWindow(rankIndex)
  if not rankIndex or rankIndex == 0 then rankIndex = 1 end
  local settingsToUse = MasterMerchant:ActiveSettings()
  settingsToUse.rankIndexRoster = rankIndex
  GUILD_ROSTER_MANAGER:RefreshData()
end


-- Switch Sales window to display buyer or seller
function MasterMerchant:ToggleBuyerSeller()
  local settingsToUse = MasterMerchant:ActiveSettings()
  if settingsToUse.viewSize == 'full' then 
    if settingsToUse.viewBuyerSeller == 'buyer' then 
      settingsToUse.viewBuyerSeller = 'seller' 
      MasterMerchantWindowHeadersBuyer:GetNamedChild('Name'):SetText(GetString(SK_SELLER_COLUMN))
    else
      settingsToUse.viewBuyerSeller = 'buyer' 
      MasterMerchantWindowHeadersBuyer:GetNamedChild('Name'):SetText(GetString(SK_BUYER_COLUMN))
    end

    MasterMerchant.scrollList:RefreshFilters()
  else 
    if settingsToUse.viewGuildBuyerSeller == 'buyer' then 
      settingsToUse.viewGuildBuyerSeller = 'seller' 
      MasterMerchantGuildWindowHeadersSeller:GetNamedChild('Name'):SetText(GetString(SK_SELLER_COLUMN))
      MasterMerchantGuildWindowHeadersSales:GetNamedChild('Name'):SetText(GetString(SK_SALES_COLUMN))
    elseif settingsToUse.viewGuildBuyerSeller == 'seller' then
      settingsToUse.viewGuildBuyerSeller = 'item' 
      MasterMerchantGuildWindowHeadersSeller:GetNamedChild('Name'):SetText(GetString(SK_ITEM_COLUMN))
      MasterMerchantGuildWindowHeadersSales:GetNamedChild('Name'):SetText(GetString(SK_SALES_COLUMN))
    else
      settingsToUse.viewGuildBuyerSeller = 'buyer' 
      MasterMerchantGuildWindowHeadersSeller:GetNamedChild('Name'):SetText(GetString(SK_BUYER_COLUMN))
      MasterMerchantGuildWindowHeadersSales:GetNamedChild('Name'):SetText(GetString(SK_PURCHASES_COLUMN))
    end

    MasterMerchant.guildScrollList:RefreshFilters() 
  end
end

-- Update all the fields of the stats window based on the response from SalesStats()
function MasterMerchant:UpdateStatsWindow(guildName)
  if not guildName or guildName == '' then guildName = 'SK_STATS_TOTAL' end
  local sliderLevel = MasterMerchantStatsWindowSlider:GetValue()
  self.newStats = self:SalesStats(sliderLevel)

  self.newStats['totalDays'] = self.newStats['totalDays'] or 1
  self.newStats['numSold'][guildName] = self.newStats['numSold'][guildName] or 0
  self.newStats['kioskPercent'][guildName] = self.newStats['kioskPercent'][guildName] or 0
  self.newStats['totalGold'][guildName] = self.newStats['totalGold'][guildName] or 0
  self.newStats['avgGold'][guildName] = self.newStats['avgGold'][guildName] or 0
  self.newStats['biggestSale'][guildName] = self.newStats['biggestSale'][guildName] or {} 
  self.newStats['biggestSale'][guildName][1] = self.newStats['biggestSale'][guildName][1] or 0
  self.newStats['biggestSale'][guildName][2] = self.newStats['biggestSale'][guildName][2] or GetString(MM_NOTHING)

  -- Hide the slider if there's less than a day of data
  -- and set the slider's range for the new day range returned
  MasterMerchantStatsWindowSliderLabel:SetHidden(false)
  MasterMerchantStatsWindowSlider:SetHidden(false)
  MasterMerchantStatsWindowSlider:SetMinMax(1, (self.newStats['totalDays']))

  if self.newStats['totalDays'] == nil or self.newStats['totalDays'] < 2 then
    MasterMerchantStatsWindowSlider:SetHidden(true)
    MasterMerchantStatsWindowSliderLabel:SetHidden(true)
    sliderLevel = 1
  elseif sliderLevel > (self.newStats['totalDays']) then sliderLevel = self.newStats['totalDays'] end

  -- Set the time range label appropriately
  if sliderLevel == self.newStats['totalDays'] then MasterMerchantStatsWindowSliderSettingLabel:SetText(GetString(SK_STATS_TIME_ALL))
  else MasterMerchantStatsWindowSliderSettingLabel:SetText(zo_strformat(GetString(SK_STATS_TIME_SOME), sliderLevel)) end

  -- Grab which guild is selected
  local guildSelected = GetString(SK_STATS_ALL_GUILDS)
  if guildName ~= 'SK_STATS_TOTAL' then guildSelected = guildName end
  local guildDropdown = ZO_ComboBox_ObjectFromContainer(MasterMerchantStatsGuildChooser)
  guildDropdown:SetSelectedItem(guildSelected)

  -- And set the rest of the stats window up with data from the appropriate
  -- guild (or overall data)
  MasterMerchantStatsWindowItemsSoldLabel:SetText(string.format(GetString(SK_STATS_ITEMS_SOLD), self.LocalizedNumber(self.newStats['numSold'][guildName]), (self.newStats['kioskPercent'][guildName])))
  MasterMerchantStatsWindowTotalGoldLabel:SetText(string.format(GetString(SK_STATS_TOTAL_GOLD), self.LocalizedNumber(self.newStats['totalGold'][guildName]), self.LocalizedNumber(self.newStats['avgGold'][guildName])))
  MasterMerchantStatsWindowBiggestSaleLabel:SetText(string.format(GetString(SK_STATS_BIGGEST), zo_strformat('<<t:1>>', self.newStats['biggestSale'][guildName][2]), (self.newStats['biggestSale'][guildName][1])))

end

-- Switches the main window between full and half size.  Really this is hiding one
-- and showing the other, but close enough ;)  Also makes the scene adjustments
-- necessary to maintain the desired mail/trading house behaviors.  Copies the
-- contents of the search box and the current sorting settings so they're the
-- same on the other window when it appears.
function MasterMerchant:ToggleViewMode()
  local settingsToUse = MasterMerchant:ActiveSettings()
  -- Switching to guild view
  if settingsToUse.viewSize == 'full' then
    settingsToUse.viewSize = 'half'
    MasterMerchantWindow:SetHidden(true)
    if not self.listIsDirty['guild'] then self.guildScrollList:RefreshFilters() end
    MasterMerchantGuildWindow:SetHidden(false)

    if settingsToUse.openWithMail then
      MAIL_INBOX_SCENE:RemoveFragment(self.uiFragment)
      MAIL_SEND_SCENE:RemoveFragment(self.uiFragment)
      MAIL_INBOX_SCENE:AddFragment(self.guildUiFragment)
      MAIL_SEND_SCENE:AddFragment(self.guildUiFragment)
    end

    if settingsToUse.openWithStore then
      TRADING_HOUSE_SCENE:RemoveFragment(self.uiFragment)
      TRADING_HOUSE_SCENE:AddFragment(self.guildUiFragment)
    end
  -- Switching to full view
  else
    settingsToUse.viewSize = 'full'
    MasterMerchantGuildWindow:SetHidden(true)
    if not self.listIsDirty['full'] then self.scrollList:RefreshFilters() end
    MasterMerchantWindow:SetHidden(false)

    if settingsToUse.openWithMail then
      MAIL_INBOX_SCENE:RemoveFragment(self.guildUiFragment)
      MAIL_SEND_SCENE:RemoveFragment(self.guildUiFragment)
      MAIL_INBOX_SCENE:AddFragment(self.uiFragment)
      MAIL_SEND_SCENE:AddFragment(self.uiFragment)
    end

    if settingsToUse.openWithStore then
      TRADING_HOUSE_SCENE:RemoveFragment(self.guildUiFragment)
      TRADING_HOUSE_SCENE:AddFragment(self.uiFragment)
    end
  end
end

-- Set the visibility status of the main window to the opposite of its current status
function MasterMerchant.ToggleMasterMerchantWindow()
  if MasterMerchant:ActiveSettings().viewSize == 'full' then
    MasterMerchantGuildWindow:SetHidden(true)
    MasterMerchantWindow:SetHidden(not MasterMerchantWindow:IsHidden())
  else
    MasterMerchantWindow:SetHidden(true)
    MasterMerchantGuildWindow:SetHidden(not MasterMerchantGuildWindow:IsHidden())
  end
end

-- Set the visibility status of the feebback window to the opposite of its current status
function MasterMerchant.ToggleMasterMerchantFeedback()
  MasterMerchantFeedback:SetDrawLayer(DL_OVERLAY)
  MasterMerchantFeedback:SetHidden(not MasterMerchantFeedback:IsHidden())
end

-- Set the visibility status of the stats window to the opposite of its current status
function MasterMerchant.ToggleMasterMerchantStatsWindow()
  if MasterMerchantStatsWindow:IsHidden() then MasterMerchant:UpdateStatsWindow('SK_STATS_TOTAL') end
  MasterMerchantStatsWindow:SetHidden(not MasterMerchantStatsWindow:IsHidden())
end

-- Switch between all sales and your sales
function MasterMerchant:SwitchViewMode()
  if self.viewMode == 'self' then
    MasterMerchantSwitchViewButton:SetText(GetString(SK_VIEW_YOUR_SALES))
    MasterMerchantWindowTitle:SetText(GetString(MM_APP_NAME) .. ' - ' .. GetString(SK_ALL_SALES_TITLE))
    MasterMerchantGuildSwitchViewButton:SetText(GetString(SK_VIEW_YOUR_SALES))
    MasterMerchantGuildWindowTitle:SetText(GetString(MM_APP_NAME) .. ' - ' .. GetString(SK_GUILD_SALES_TITLE))
    self.viewMode = 'all'
  else
    MasterMerchantSwitchViewButton:SetText(GetString(SK_VIEW_ALL_SALES))
    MasterMerchantWindowTitle:SetText(GetString(MM_APP_NAME) .. ' - '.. GetString(SK_YOUR_SALES_TITLE))
    MasterMerchantGuildSwitchViewButton:SetText(GetString(SK_VIEW_ALL_SALES))
    MasterMerchantGuildWindowTitle:SetText(GetString(MM_APP_NAME) .. ' - ' .. GetString(SK_GUILD_SALES_TITLE))
    self.viewMode = 'self'
  end

  if MasterMerchant:ActiveSettings().viewSize == 'full' then
    self.scrollList:RefreshFilters()
    ZO_Scroll_ResetToTop(self.scrollList.list)
  else 
    self.guildScrollList:RefreshFilters()
    ZO_Scroll_ResetToTop(self.guildScrollList.list)
  end
end

-- Switch between total price mode and unit price mode
function MasterMerchant:SwitchPriceMode()
  local settingsToUse = MasterMerchant:ActiveSettings()
  if settingsToUse.showUnitPrice then
    settingsToUse.showUnitPrice = false
    MasterMerchantPriceSwitchButton:SetText(GetString(SK_SHOW_UNIT))
    MasterMerchantWindowHeadersPrice:GetNamedChild('Name'):SetText(GetString(SK_PRICE_COLUMN))
  else
    settingsToUse.showUnitPrice = true
    MasterMerchantPriceSwitchButton:SetText(GetString(SK_SHOW_TOTAL))
    MasterMerchantWindowHeadersPrice:GetNamedChild('Name'):SetText(GetString(SK_PRICE_EACH_COLUMN))
  end

  if settingsToUse.viewSize == 'full' 
    then MasterMerchant.scrollList:RefreshFilters()
    else MasterMerchant.guildScrollList:RefreshFilters() 
  end
end

-- Update the stats window if the slider in it moved
function MasterMerchant.OnStatsSliderMoved(self, sliderLevel, eventReason)
  local guildDropdown = ZO_ComboBox_ObjectFromContainer(MasterMerchantStatsGuildChooser)
  local selectedGuild = guildDropdown:GetSelectedItem()
  if selectedGuild == GetString(SK_STATS_ALL_GUILDS) then selectedGuild = 'SK_STATS_TOTAL' end
  MasterMerchant:UpdateStatsWindow(selectedGuild)
end

-- Set up the labels and tooltips from translation files and do a couple other UI
-- setup routines
function MasterMerchant:SetupMasterMerchantWindow()
  local settingsToUse = self:ActiveSettings()
  -- MasterMerchant button in guild store screen
  local reopenMasterMerchant = CreateControlFromVirtual('MasterMerchantReopenButton', ZO_TradingHouseLeftPane, 'ZO_DefaultButton')
  reopenMasterMerchant:SetAnchor(CENTER, ZO_TradingHouseLeftPane, BOTTOM, 0, 5)
  reopenMasterMerchant:SetWidth(200)
  reopenMasterMerchant:SetText(GetString(MM_APP_NAME))
  reopenMasterMerchant:SetHandler('OnClicked', self.ToggleMasterMerchantWindow)
  local skCalc = CreateControlFromVirtual('MasterMerchantPriceCalculator', ZO_TradingHouseLeftPanePostItem, 'MasterMerchantPriceCalc')
  skCalc:SetAnchor(BOTTOM, reopenMasterMerchant, TOP, 0, -4)

  -- MasterMerchant button in mail screen
  local MasterMerchantMail = CreateControlFromVirtual('MasterMerchantMailButton', ZO_MailInbox, 'ZO_DefaultButton')
  MasterMerchantMail:SetAnchor(TOPLEFT, ZO_MailInbox, TOPLEFT, 100, 4)
  MasterMerchantMail:SetWidth(200)
  MasterMerchantMail:SetText(GetString(MM_APP_NAME))
  MasterMerchantMail:SetHandler('OnClicked', self.ToggleMasterMerchantWindow)

  -- Stats dropdown choice box
  local MasterMerchantStatsGuild = CreateControlFromVirtual('MasterMerchantStatsGuildChooser', MasterMerchantStatsWindow, 'MasterMerchantStatsGuildDropdown')
  MasterMerchantStatsGuild:SetDimensions(270,25)
  MasterMerchantStatsGuild:SetAnchor(LEFT, MasterMerchantStatsWindowGuildChooserLabel, RIGHT, 5, 0)
  MasterMerchantStatsGuild.m_comboBox:SetSortsItems(false)
  
   -- Guild Time dropdown choice box
  local MasterMerchantGuildTime = CreateControlFromVirtual('MasterMerchantGuildTimeChooser', MasterMerchantGuildWindow, 'MasterMerchantStatsGuildDropdown')
  MasterMerchantGuildTime:SetDimensions(180,25)
  MasterMerchantGuildTime:SetAnchor(LEFT, MasterMerchantGuildSwitchViewButton, RIGHT, 5, 0)
  MasterMerchantGuildTime.m_comboBox:SetSortsItems(false)
  
  local timeDropdown = ZO_ComboBox_ObjectFromContainer(MasterMerchantGuildTimeChooser)
  timeDropdown:ClearItems()
  
  settingsToUse.rankIndex = settingsToUse.rankIndex or 1
  
  local timeEntry = timeDropdown:CreateItemEntry(GetString(MM_INDEX_TODAY), function() self:UpdateGuildWindow(1) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndex == 1 then timeDropdown:SetSelectedItem(GetString(MM_INDEX_TODAY)) end
  
  timeEntry = timeDropdown:CreateItemEntry(GetString(MM_INDEX_3DAY), function() self:UpdateGuildWindow(2) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndex == 2 then timeDropdown:SetSelectedItem(GetString(MM_INDEX_3DAY)) end
  
  timeEntry = timeDropdown:CreateItemEntry(GetString(MM_INDEX_THISWEEK), function() self:UpdateGuildWindow(3) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndex == 3 then timeDropdown:SetSelectedItem(GetString(MM_INDEX_THISWEEK)) end
  
  timeEntry = timeDropdown:CreateItemEntry(GetString(MM_INDEX_LASTWEEK), function() self:UpdateGuildWindow(4) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndex == 4 then timeDropdown:SetSelectedItem(GetString(MM_INDEX_LASTWEEK)) end
  
  timeEntry = timeDropdown:CreateItemEntry(GetString(MM_INDEX_PRIORWEEK), function() self:UpdateGuildWindow(5) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndex == 5 then timeDropdown:SetSelectedItem(GetString(MM_INDEX_PRIORWEEK)) end

  timeEntry = timeDropdown:CreateItemEntry(GetString(MM_INDEX_7DAY), function() self:UpdateGuildWindow(8) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndex == 8 then timeDropdown:SetSelectedItem(GetString(MM_INDEX_7DAY)) end
  
  timeEntry = timeDropdown:CreateItemEntry(GetString(MM_INDEX_10DAY), function() self:UpdateGuildWindow(6) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndex == 6 then timeDropdown:SetSelectedItem(GetString(MM_INDEX_10DAY)) end
      
  timeEntry = timeDropdown:CreateItemEntry(GetString(MM_INDEX_28DAY), function() self:UpdateGuildWindow(7) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndex == 7 then timeDropdown:SetSelectedItem(GetString(MM_INDEX_28DAY)) end
  
  timeEntry = timeDropdown:CreateItemEntry(settingsToUse.customTimeframeText, function() self:UpdateGuildWindow(9) end)
  timeDropdown:AddItem(timeEntry)
  if settingsToUse.rankIndex == 9 then timeDropdown:SetSelectedItem(settingsToUse.customTimeframeText) end

  -- Set sort column headers and search label from translation
  local LMP = LibStub('LibMediaProvider-1.0')
  local fontString = 'ZoFontGameLargeBold'
  local guildFontString = 'ZoFontGameLargeBold'
  if LMP then
    local font = LMP:Fetch('font', self:ActiveSettings().windowFont)
    fontString = font .. '|17'
    guildFontString = font .. '|17'
  end
  
  if settingsToUse.viewBuyerSeller == 'buyer' then 
    MasterMerchantWindowHeadersBuyer:GetNamedChild('Name'):SetText(GetString(SK_BUYER_COLUMN))    
  else
    MasterMerchantWindowHeadersBuyer:GetNamedChild('Name'):SetText(GetString(SK_SELLER_COLUMN))
  end

  if settingsToUse.viewGuildBuyerSeller == 'buyer' then 
    MasterMerchantGuildWindowHeadersSeller:GetNamedChild('Name'):SetText(GetString(SK_BUYER_COLUMN))
  elseif settingsToUse.viewGuildBuyerSeller == 'seller' then
    MasterMerchantGuildWindowHeadersSeller:GetNamedChild('Name'):SetText(GetString(SK_SELLER_COLUMN))
  else
    MasterMerchantGuildWindowHeadersSeller:GetNamedChild('Name'):SetText(GetString(SK_ITEM_COLUMN))
  end

  MasterMerchantWindowHeadersGuild:GetNamedChild('Name'):SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
  ZO_SortHeader_Initialize(MasterMerchantWindowHeadersGuild, GetString(SK_GUILD_COLUMN), 'itemGuildName', ZO_SORT_ORDER_DOWN, TEXT_ALIGN_LEFT, fontString)
  MasterMerchantWindowHeadersItemName:GetNamedChild('Name'):SetText(GetString(SK_ITEM_COLUMN))
  MasterMerchantWindowHeadersSellTime:GetNamedChild('Name'):SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
  ZO_SortHeader_Initialize(MasterMerchantWindowHeadersSellTime, GetString(SK_TIME_COLUMN), 'time', ZO_SORT_ORDER_DOWN, TEXT_ALIGN_LEFT, fontString)
  MasterMerchantWindowHeadersPrice:GetNamedChild('Name'):SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
  
  MasterMerchantWindowHeadersPrice:GetNamedChild('Name'):SetColor(0.84, 0.71, 0.15, 1)
  if settingsToUse.showUnitPrice then
    ZO_SortHeader_Initialize(MasterMerchantWindowHeadersPrice, GetString(SK_PRICE_EACH_COLUMN), 'price', ZO_SORT_ORDER_DOWN, TEXT_ALIGN_LEFT, fontString)
  else
    ZO_SortHeader_Initialize(MasterMerchantWindowHeadersPrice, GetString(SK_PRICE_COLUMN), 'price', ZO_SORT_ORDER_DOWN, TEXT_ALIGN_LEFT, fontString)
  end

  MasterMerchantGuildWindowHeadersGuild:GetNamedChild('Name'):SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
  ZO_SortHeader_Initialize(MasterMerchantGuildWindowHeadersGuild, GetString(SK_GUILD_COLUMN), 'guildName', ZO_SORT_ORDER_DOWN, TEXT_ALIGN_LEFT, fontString)

  MasterMerchantGuildWindowHeadersRank:GetNamedChild('Name'):SetText(GetString(SK_RANK_COLUMN))
  MasterMerchantGuildWindowHeadersRank:GetNamedChild('Name'):SetModifyTextType(MODIFY_TEXT_TYPE_NONE)  
  ZO_SortHeader_Initialize(MasterMerchantGuildWindowHeadersRank, GetString(SK_RANK_COLUMN), 'rank', ZO_SORT_ORDER_DOWN, TEXT_ALIGN_RIGHT, guildFontString)
  

  MasterMerchantGuildWindowHeadersSales:GetNamedChild('Name'):SetModifyTextType(MODIFY_TEXT_TYPE_NONE)  
  ZO_SortHeader_Initialize(MasterMerchantGuildWindowHeadersSales, GetString(SK_SALES_COLUMN), 'sales', ZO_SORT_ORDER_DOWN, TEXT_ALIGN_RIGHT, guildFontString)
  local ctrl = GetControl(MasterMerchantGuildWindowHeadersSales, "Name")

  if settingsToUse.viewGuildBuyerSeller == 'buyer' then 
    ctrl:SetText(GetString(SK_PURCHASES_COLUMN))  
  elseif settingsToUse.viewGuildBuyerSeller == 'seller' then
    ctrl:SetText(GetString(SK_SALES_COLUMN))
  else
    ctrl:SetText(GetString(SK_SALES_COLUMN))
  end

  MasterMerchantGuildWindowHeadersSales:GetNamedChild('Name'):SetColor(0.84, 0.71, 0.15, 1)

  local txt
  if settingsToUse.viewGuildBuyerSeller == 'buyer' then 
    txt = GetString(SK_BUYER_COLUMN)
  elseif settingsToUse.viewGuildBuyerSeller == 'seller' then
    txt = GetString(SK_SELLER_COLUMN)
  else
    txt = GetString(SK_ITEM_COLUMN)
  end
  MasterMerchantGuildWindowHeadersSeller:GetNamedChild('Name'):SetText(GetString(txt))
  MasterMerchantGuildWindowHeadersSeller:GetNamedChild('Name'):SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
  ZO_SortHeader_Initialize(MasterMerchantGuildWindowHeadersSeller, txt, 'name', ZO_SORT_ORDER_DOWN, TEXT_ALIGN_LEFT, guildFontString)
  
  MasterMerchantGuildWindowHeadersTax:GetNamedChild('Name'):SetText(GetString(SK_TAX_COLUMN))
  MasterMerchantGuildWindowHeadersTax:GetNamedChild('Name'):SetModifyTextType(MODIFY_TEXT_TYPE_NONE) 
  ZO_SortHeader_Initialize(MasterMerchantGuildWindowHeadersTax, GetString(SK_TAX_COLUMN), 'tax', ZO_SORT_ORDER_DOWN, TEXT_ALIGN_RIGHT, guildFontString)
  
  MasterMerchantGuildWindowHeadersCount:GetNamedChild('Name'):SetText(GetString(SK_COUNT_COLUMN))
  MasterMerchantGuildWindowHeadersCount:GetNamedChild('Name'):SetModifyTextType(MODIFY_TEXT_TYPE_NONE) 
  ZO_SortHeader_Initialize(MasterMerchantGuildWindowHeadersCount, GetString(SK_COUNT_COLUMN), 'count', ZO_SORT_ORDER_DOWN, TEXT_ALIGN_RIGHT, guildFontString)
  
  MasterMerchantGuildWindowHeadersPercent:GetNamedChild('Name'):SetText(GetString(SK_PERCENT_COLUMN))
  MasterMerchantGuildWindowHeadersPercent:GetNamedChild('Name'):SetColor(0.84, 0.71, 0.15, 1)

  -- Set second half of window title from translation
  MasterMerchantWindowTitle:SetText(GetString(MM_APP_NAME) .. ' - ' .. GetString(SK_YOUR_SALES_TITLE))
  MasterMerchantGuildWindowTitle:SetText(GetString(MM_APP_NAME) .. ' - ' .. GetString(SK_GUILD_SALES_TITLE))

  -- And set the stats window title and slider label from translation
  MasterMerchantStatsWindowTitle:SetText(GetString(MM_APP_NAME) .. ' - ' .. GetString(SK_STATS_TITLE))
  MasterMerchantStatsWindowGuildChooserLabel:SetText(GetString(SK_GUILD_COLUMN) .. ': ')
  MasterMerchantStatsWindowSliderLabel:SetText(GetString(SK_STATS_DAYS))

  -- Set up some helpful tooltips for the Time and Price column headers
  ZO_SortHeader_SetTooltip(MasterMerchantWindowHeadersSellTime, GetString(SK_SORT_TIME_TOOLTIP))
  ZO_SortHeader_SetTooltip(MasterMerchantWindowHeadersPrice, GetString(SK_SORT_PRICE_TOOLTIP))
  --ZO_SortHeader_SetTooltip(MasterMerchantGuildWindowHeadersSellTime, GetString(SK_SORT_TIME_TOOLTIP))
  --ZO_SortHeader_SetTooltip(MasterMerchantGuildWindowHeadersPrice, GetString(SK_SORT_PRICE_TOOLTIP))

  -- View switch button
  MasterMerchantSwitchViewButton:SetText(GetString(SK_VIEW_ALL_SALES))
  MasterMerchantGuildSwitchViewButton:SetText(GetString(SK_VIEW_ALL_SALES))

  -- Total / unit price switch button
  if settingsToUse.showUnitPrice then
    MasterMerchantPriceSwitchButton:SetText(GetString(SK_SHOW_TOTAL))
  else
    MasterMerchantPriceSwitchButton:SetText(GetString(SK_SHOW_UNIT))
  end

  -- Spinny animations that display while SK is scanning
	MasterMerchantWindowLoadingIcon.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual('LoadIconAnimation', MasterMerchantWindowLoadingIcon)
	MasterMerchantGuildWindowLoadingIcon.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual('LoadIconAnimation', MasterMerchantGuildWindowLoadingIcon)

  -- Refresh button
  MasterMerchantRefreshButton:SetText(GetString(SK_REFRESH_LABEL))
  MasterMerchantGuildRefreshButton:SetText(GetString(SK_REFRESH_LABEL))

  -- Reset button and confirmation dialog
  MasterMerchantResetButton:SetText(GetString(SK_RESET_LABEL))
  MasterMerchantGuildResetButton:SetText(GetString(SK_RESET_LABEL))
  local confirmDialog = {
    title = { text = GetString(SK_RESET_CONFIRM_TITLE) },
    mainText = { text = GetString(SK_RESET_CONFIRM_MAIN) },
    buttons = {
      {
        text = SI_DIALOG_ACCEPT,
        callback = function() self:DoReset() end
      },
      { text = SI_DIALOG_CANCEL }
    }
  }
  ZO_Dialogs_RegisterCustomDialog('MasterMerchantResetConfirmation', confirmDialog)

  -- Stats buttons
  MasterMerchantWindowStatsButton:SetHandler('OnMouseEnter', function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SK_STATS_TOOLTIP)) end)
  MasterMerchantGuildWindowStatsButton:SetHandler('OnMouseEnter', function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SK_STATS_TOOLTIP)) end)

  -- View size change buttons
  MasterMerchantWindowViewSizeButton:SetHandler('OnMouseEnter', function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SK_SELLER_TOOLTIP)) end)
  MasterMerchantGuildWindowViewSizeButton:SetHandler('OnMouseEnter', function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SK_ITEMS_TOOLTIP)) end)

  -- Slider setup
  MasterMerchantStatsWindowSlider:SetValue(100)

  -- We're all set, so make sure we're using the right font to finish up
  self:UpdateFonts()
end

function MasterMerchant:SetupScrollLists()
    -- Scroll list init
  self.scrollList = MMScrollList:New(MasterMerchantWindow)
  --self.scrollList:Initialize()
  self.functionPostHook(self.scrollList.sortHeaderGroup, 'OnHeaderClicked', function(self, header, suppressCallbacks)
    if header == MasterMerchantWindowHeadersPrice then 
      if header.mouseIsOver then MasterMerchantWindowHeadersPrice:GetNamedChild('Name'):SetColor(0.95, 0.92, 0.26, 1)
      else MasterMerchantWindowHeadersPrice:GetNamedChild('Name'):SetColor(0.84, 0.81, 0.15, 1) end
    else MasterMerchantWindowHeadersPrice:GetNamedChild('Name'):SetColor(0.84, 0.71, 0.15, 1) end
  end)
  self.handlerPostHook(MasterMerchantWindowHeadersPrice, 'OnMouseExit', function()
    if MasterMerchantWindowHeadersPrice.selected then MasterMerchantWindowHeadersPrice:GetNamedChild('Name'):SetColor(0.84, 0.81, 0.15, 1)
    else MasterMerchantWindowHeadersPrice:GetNamedChild('Name'):SetColor(0.84, 0.71, 0.15, 1) end
  end)
  self.handlerPostHook(MasterMerchantWindowHeadersPrice, 'OnMouseEnter', function(control)
    if control == MasterMerchantWindowHeadersPrice then MasterMerchantWindowHeadersPrice:GetNamedChild('Name'):SetColor(0.84, 0.81, 0.15, 1)
    else MasterMerchantWindowHeadersPrice:GetNamedChild('Name'):SetColor(0.84, 0.71, 0.15, 1) end
  end)

  self.guildScrollList = MMScrollList:New(MasterMerchantGuildWindow)
  --self.guildScrollList:Initialize()
  self.functionPostHook(self.guildScrollList.sortHeaderGroup, 'OnHeaderClicked', function()
    MasterMerchantGuildWindowHeadersSales:GetNamedChild('Name'):SetColor(0.84, 0.71, 0.15, 1)
  end)
  self.handlerPostHook(MasterMerchantGuildWindowHeadersSales, 'OnMouseExit', function()
    MasterMerchantGuildWindowHeadersSales:GetNamedChild('Name'):SetColor(0.84, 0.71, 0.15, 1)
  end)
  self.handlerPostHook(MasterMerchantGuildWindowHeadersSales, 'OnMouseEnter', function()
    MasterMerchantGuildWindowHeadersSales:GetNamedChild('Name'):SetColor(0.84, 0.71, 0.15, 1)
  end)
end