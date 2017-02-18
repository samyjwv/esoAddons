function MasterMerchant:initAGSIntegration()
  if AwesomeGuildStore.GetAPIVersion == nil then return end
  if AwesomeGuildStore.GetAPIVersion() ~= 2 then return end

  local DealSelector = MasterMerchant.InitDealSelectorClass()
  local ProfitFilter = MasterMerchant.InitProfitFilterClass()

  CALLBACK_MANAGER:RegisterCallback(AwesomeGuildStore.OnInitializeFiltersCallbackName or AwesomeGuildStore.AfterInitialSetupCallbackName, function(tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local browseItemsControl = tradingHouse.m_browseItems
    local common = browseItemsControl:GetNamedChild("Common")

    dealSelector = DealSelector:New('MasterMerchantDealButtons', tradingHouseWrapper)
    MasterMerchant.dealSelector = dealSelector

    if ProfitFilter then
      profitFilter = ProfitFilter:New('MasterMerchantProfitFilter', tradingHouseWrapper)
      MasterMerchant.profitFilter = profitFilter
    end

    tradingHouseWrapper:RegisterFilter(dealSelector)
    tradingHouseWrapper:AttachFilter(dealSelector)
    if MasterMerchant:ActiveSettings().minProfitFilter then
      tradingHouseWrapper:RegisterFilter(profitFilter)
      tradingHouseWrapper:AttachFilter(profitFilter)
    end

    tradingHouseWrapper.searchTab.categoryFilter:UpdateSubfilterVisibility() -- small hack to ensure that the order is correct
  end)
  
  CALLBACK_MANAGER:RegisterCallback(AwesomeGuildStore.OnOpenSearchTabCallbackName, function(tradingHouseWrapper)
    tradingHouseWrapper:AttachButton(MasterMerchantReopenButton)
  end)

  CALLBACK_MANAGER:RegisterCallback(AwesomeGuildStore.OnCloseSearchTabCallbackName, function(tradingHouseWrapper)
    local button = MasterMerchantReopenButton
    tradingHouseWrapper:DetachButton(button)
    button:ClearAnchors()
    button:SetParent(ZO_TradingHouseLeftPane)
    button:SetAnchor(CENTER, ZO_TradingHouseLeftPane, BOTTOM, 0, 5)
    button:SetHidden(false)
  end)

end
