local L = AwesomeGuildStore.Localization
local RegisterForEvent = AwesomeGuildStore.RegisterForEvent

local TRADING_HOUSE_SORT_LISTING_NAME = 1
local TRADING_HOUSE_SORT_LISTING_PRICE = 2
local TRADING_HOUSE_SORT_LISTING_TIME = 3
AwesomeGuildStore.TRADING_HOUSE_SORT_LISTING_NAME = TRADING_HOUSE_SORT_LISTING_NAME
AwesomeGuildStore.TRADING_HOUSE_SORT_LISTING_PRICE = TRADING_HOUSE_SORT_LISTING_PRICE
AwesomeGuildStore.TRADING_HOUSE_SORT_LISTING_TIME = TRADING_HOUSE_SORT_LISTING_TIME

local iconMarkup = string.format("|t%u:%u:%s|t", 16, 16, "EsoUI/Art/currency/currency_gold.dds")

local ascSortFunctions = {
    [TRADING_HOUSE_SORT_LISTING_NAME] = function(a, b) return a.data.name < b.data.name end,
    [TRADING_HOUSE_SORT_LISTING_PRICE] = function(a, b) return a.data.purchasePrice < b.data.purchasePrice end,
    [TRADING_HOUSE_SORT_LISTING_TIME] = function(a, b) return a.data.timeRemaining < b.data.timeRemaining end,
}

local descSortFunctions = {
    [TRADING_HOUSE_SORT_LISTING_NAME] = function(a, b) return a.data.name > b.data.name end,
    [TRADING_HOUSE_SORT_LISTING_PRICE] = function(a, b) return a.data.purchasePrice > b.data.purchasePrice end,
    [TRADING_HOUSE_SORT_LISTING_TIME] = function(a, b) return a.data.timeRemaining > b.data.timeRemaining end,
}

local ListingTabWrapper = ZO_Object:Subclass()
AwesomeGuildStore.ListingTabWrapper = ListingTabWrapper

function ListingTabWrapper:New(saveData)
    local wrapper = ZO_Object.New(self)
    wrapper.saveData = saveData
    return wrapper
end

function ListingTabWrapper:RunInitialSetup(tradingHouseWrapper)
    self.tradingHouseWrapper = tradingHouseWrapper
    self:InitializeListingSortHeaders(tradingHouseWrapper)
    self:InitializeListingCount(tradingHouseWrapper)
    self:InitializeLoadingOverlay(tradingHouseWrapper)
    self:InitializeUnitPriceDisplay(tradingHouseWrapper)
    self:InitializeCancelSaleOperation(tradingHouseWrapper)
    self:InitializeRequestListingsOperation(tradingHouseWrapper)
    self:InitializeCancelNotification(tradingHouseWrapper)
    self:InitializeOverallPrice(tradingHouseWrapper)
end

local function PrepareSortHeader(container, name, key)
    local header = container:GetNamedChild(name)
    header.key = key
    header:SetMouseEnabled(true)
end

function ListingTabWrapper:InitializeListingSortHeaders(tradingHouseWrapper)
    local control = ZO_TradingHouse
    local sortHeadersControl = control:GetNamedChild("PostedItemsHeader")
    PrepareSortHeader(sortHeadersControl, "Name", TRADING_HOUSE_SORT_LISTING_NAME)
    PrepareSortHeader(sortHeadersControl, "Price", TRADING_HOUSE_SORT_LISTING_PRICE)
    PrepareSortHeader(sortHeadersControl, "TimeRemaining", TRADING_HOUSE_SORT_LISTING_TIME)

    local sortHeaders = ZO_SortHeaderGroup:New(sortHeadersControl, true)

    self.sortHeadersControl = sortHeadersControl
    self.sortHeaders = sortHeaders

    local function OnSortHeaderClicked(key, order)
        self:ChangeSort(key, order)
    end

    sortHeaders:RegisterCallback(ZO_SortHeaderGroup.HEADER_CLICKED, OnSortHeaderClicked)
    sortHeaders:AddHeadersFromContainer()
    self.currentSortKey = self.saveData.listingSortField
    self.currentSortOrder = self.saveData.listingSortOrder
    sortHeaders:SelectHeaderByKey(self.currentSortKey, ZO_SortHeaderGroup.SUPPRESS_CALLBACKS)
    if(not self.currentSortOrder) then -- call it a second time to invert the sort order
        sortHeaders:SelectHeaderByKey(self.currentSortKey, ZO_SortHeaderGroup.SUPPRESS_CALLBACKS)
    end

    local originalScrollListCommit = ZO_ScrollList_Commit
    local noop = function() end
    tradingHouseWrapper:Wrap("OnListingsRequestSuccess", function(originalOnListingsRequestSuccess, tradingHouse)
        ZO_ScrollList_Commit = noop
        originalOnListingsRequestSuccess(tradingHouse)
        ZO_ScrollList_Commit = originalScrollListCommit
        self:UpdateResultList()
    end)
end

function ListingTabWrapper:InitializeListingCount(tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    self.listingControl = tradingHouse.m_currentListings
    self.infoControl = self.listingControl:GetParent()
    self.itemControl = self.infoControl:GetNamedChild("Item")
    self.postedItemsControl = tradingHouse.m_postedItemsHeader:GetParent()
end

function ListingTabWrapper:InitializeLoadingOverlay(tradingHouseWrapper)
    tradingHouseWrapper:PreHook("OnAwaitingResponse", function(self, responseType)
        if(responseType == TRADING_HOUSE_RESULT_LISTINGS_PENDING or responseType == TRADING_HOUSE_RESULT_CANCEL_SALE_PENDING) then
            if(self:IsInListingsMode()) then
                tradingHouseWrapper:ShowLoadingOverlay()
            end
        end
    end)

    tradingHouseWrapper:PreHook("OnResponseReceived", function(self, responseType, result)
        if(responseType == TRADING_HOUSE_RESULT_LISTINGS_PENDING or responseType == TRADING_HOUSE_RESULT_CANCEL_SALE_PENDING) then
            if(result == TRADING_HOUSE_RESULT_SUCCESS) then
                self:UpdateListingCounts()
            end
            tradingHouseWrapper:HideLoadingOverlay()
        end
    end)
end

function ListingTabWrapper:InitializeUnitPriceDisplay(tradingHouseWrapper)
    local PER_UNIT_PRICE_CURRENCY_OPTIONS = {
        showTooltips = false,
        iconSide = RIGHT,
    }
    local UNIT_PRICE_FONT = "/esoui/common/fonts/univers67.otf|14|soft-shadow-thin"
    local ITEM_LISTINGS_DATA_TYPE = 2

    local saveData = self.saveData
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local dataType = tradingHouse.m_postedItemsList.dataTypes[ITEM_LISTINGS_DATA_TYPE]
    local originalSetupCallback = dataType.setupCallback

    dataType.setupCallback = function(rowControl, postedItem)
        originalSetupCallback(rowControl, postedItem)

        local sellPriceControl = rowControl:GetNamedChild("SellPrice")
        local perItemPrice = rowControl:GetNamedChild("SellPricePerItem")
        if(saveData.displayPerUnitPrice) then
            if(not perItemPrice) then
                local controlName = rowControl:GetName() .. "SellPricePerItem"
                perItemPrice = rowControl:CreateControl(controlName, CT_LABEL)
                perItemPrice:SetAnchor(TOPRIGHT, sellPriceControl, BOTTOMRIGHT, 0, 0)
                perItemPrice:SetFont(UNIT_PRICE_FONT)
            end

            if(postedItem.stackCount > 1) then
                local unitPrice = tonumber(string.format("%.2f", postedItem.purchasePrice / postedItem.stackCount))
                ZO_CurrencyControl_SetSimpleCurrency(perItemPrice, postedItem.currencyType, unitPrice, PER_UNIT_PRICE_CURRENCY_OPTIONS, nil, tradingHouse.m_playerMoney[postedItem.currencyType] < postedItem.purchasePrice)
                perItemPrice:SetText("@" .. perItemPrice:GetText():gsub("|t.-:.-:", "|t12:12:"))
                perItemPrice:SetHidden(false)
                sellPriceControl:ClearAnchors()
                sellPriceControl:SetAnchor(RIGHT, rowControl, RIGHT, -140, -8)
                perItemPrice = nil
            end
        end

        if(perItemPrice) then
            perItemPrice:SetHidden(true)
            sellPriceControl:ClearAnchors()
            sellPriceControl:SetAnchor(RIGHT, rowControl, RIGHT, -140, 0)
        end
    end
end

function ListingTabWrapper:InitializeCancelSaleOperation(tradingHouseWrapper)
    local activityManager = tradingHouseWrapper.activityManager

    tradingHouseWrapper:Wrap("ShowCancelListingConfirmation", function(originalShowCancelListingConfirmation, self, listingIndex)
        if(IsShiftKeyDown()) then
            activityManager:CancelSale(listingIndex)
        else
            originalShowCancelListingConfirmation(self, listingIndex)
        end
    end)

    ZO_PreHook("ZO_Dialogs_RegisterCustomDialog", function(name, info)
        if(name == "CONFIRM_TRADING_HOUSE_CANCEL_LISTING") then
            info.buttons[1].callback = function(dialog)
                activityManager:CancelSale(dialog.listingIndex)
                dialog.listingIndex = nil
            end
        end
    end)

    local ActivityBase = AwesomeGuildStore.ActivityBase
    local originalZO_TradingHouse_CreateItemData = ZO_TradingHouse_CreateItemData
    ZO_TradingHouse_CreateItemData = function(index, fn)
        local result = originalZO_TradingHouse_CreateItemData(index, fn)
        if(result) then
            if(fn == GetTradingHouseListingItemInfo) then
                local guildId = GetSelectedTradingHouseGuildId()
                local key = string.format("%d_%d", ActivityBase.ACTIVITY_TYPE_CANCEL_SALE, guildId) -- TODO: make it work with multiple cancel operations
                local operation = activityManager:GetActivity(key)
                if(operation and operation.listingIndex == result.slotIndex) then
                    result.cancelPending = true
                end
            end
            return result
        end
    end

    local AquireLoadingIcon = AwesomeGuildStore.LoadingIcon.Aquire
    local function SetCancelPending(rowControl, pending)
        local cancelButton = GetControl(rowControl, "CancelSale")
        cancelButton:SetHidden(false)
        if(pending) then
            if(not rowControl.loadingIcon) then
                local loadingIcon = AquireLoadingIcon()
                loadingIcon:SetParent(rowControl)
                loadingIcon:ClearAnchors()
                loadingIcon:SetAnchor(CENTER, cancelButton, CENTER, 0, 0)
                rowControl.loadingIcon = loadingIcon
            end
            cancelButton:SetHidden(true)
            rowControl.loadingIcon:Show()
        elseif(rowControl.loadingIcon) then
            rowControl.loadingIcon:Release()
            rowControl.loadingIcon = nil
        end
    end

    local ITEM_LISTINGS_DATA_TYPE = 2
    local rowType = tradingHouseWrapper.tradingHouse.m_postedItemsList.dataTypes[ITEM_LISTINGS_DATA_TYPE]
    local originalSetupCallback = rowType.setupCallback
    rowType.setupCallback = function(rowControl, postedItem)
        originalSetupCallback(rowControl, postedItem)
        SetCancelPending(rowControl, postedItem.cancelPending)
    end
end

function ListingTabWrapper:SetListedItemPending(index)
    local list = self.tradingHouseWrapper.tradingHouse.m_postedItemsList
    local scrollData = ZO_ScrollList_GetDataList(list)
    for i = 1, #scrollData do
        local data = ZO_ScrollList_GetDataEntryData(scrollData[i])
        if(data.slotIndex == index) then
            data.cancelPending = true
            ZO_ScrollList_RefreshVisible(list)
            return
        end
    end
end

function ListingTabWrapper:InitializeRequestListingsOperation(tradingHouseWrapper)
    local activityManager = tradingHouseWrapper.activityManager
    tradingHouseWrapper.tradingHouse.RequestListings = function()
        activityManager:RequestListings()
    end
end

function ListingTabWrapper:InitializeCancelNotification(tradingHouseWrapper)
    local saveData = self.saveData
    local cancelMessage = ""
    tradingHouseWrapper:Wrap("ShowCancelListingConfirmation", function(originalShowCancelListingConfirmation, self, listingIndex)
        local _, _, _, count, _, _, price = GetTradingHouseListingItemInfo(listingIndex)
        price = zo_strformat("<<1>> <<2>>", ZO_CurrencyControl_FormatCurrency(price), iconMarkup)
        local itemLink = GetTradingHouseListingItemLink(listingIndex)
        local _, guildName = GetCurrentTradingHouseGuildDetails()
        cancelMessage = zo_strformat(L["CANCEL_NOTIFICATION"], count, itemLink, price, guildName)

        originalShowCancelListingConfirmation(self, listingIndex)
    end)

    RegisterForEvent(EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, function(_, responseType, result)
        if(responseType == TRADING_HOUSE_RESULT_CANCEL_SALE_PENDING and result == TRADING_HOUSE_RESULT_SUCCESS) then
            if(saveData.cancelNotification and cancelMessage ~= "") then
                df("[AwesomeGuildStore] %s", cancelMessage)
                cancelMessage = ""
            end
        end
    end)
end

function ListingTabWrapper:InitializeOverallPrice(tradingHouseWrapper)
    local listingPriceSumControl = self.postedItemsControl:CreateControl("AwesomeGuildStoreListingPriceSum", CT_LABEL)
    listingPriceSumControl:SetFont("ZoFontWinH4")
    listingPriceSumControl:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    listingPriceSumControl:SetAnchor(TOPRIGHT, self.postedItemsControl, TOPRIGHT, -165, -47)
    listingPriceSumControl:SetText(zo_strformat(L["LISTING_TAB_OVERALL_PRICE"], "-", ""))
    listingPriceSumControl:SetHidden(true)
    self.listingPriceSumControl = listingPriceSumControl

    tradingHouseWrapper:Wrap("OnListingsRequestSuccess", function(originalOnListingsRequestSuccess, ...)
        originalOnListingsRequestSuccess(...)
        self:RefreshListingPriceSumDisplay()
    end)
end

function ListingTabWrapper:RefreshListingPriceSumDisplay()
    local sum = 0
    for i = 1, GetNumTradingHouseListings() do
        local _, _, _, _, _, _, price = GetTradingHouseListingItemInfo(i)
        sum = sum + price
    end
    local price = zo_strformat(L["LISTING_TAB_OVERALL_PRICE"], ZO_CurrencyControl_FormatCurrency(sum), iconMarkup)
    self.listingPriceSumControl:SetText(price)
end

function ListingTabWrapper:ChangeSort(key, order)
    self.currentSortKey = key
    self.currentSortOrder = order
    self.saveData.listingSortField = key
    self.saveData.listingSortOrder = order
    self:UpdateResultList()
end

function ListingTabWrapper:UpdateResultList()
    local list = TRADING_HOUSE.m_postedItemsList
    local scrollData = ZO_ScrollList_GetDataList(list)
    local sortFunctions = self.currentSortOrder and ascSortFunctions or descSortFunctions
    table.sort(scrollData, sortFunctions[self.currentSortKey])
    ZO_ScrollList_Commit(list)
end

function ListingTabWrapper:OnOpen(tradingHouseWrapper)
    self.listingControl:SetParent(self.postedItemsControl)
    self.listingControl:ClearAnchors()
    self.listingControl:SetAnchor(TOPLEFT, self.postedItemsControl, TOPLEFT, 55, -47)
    self.listingPriceSumControl:SetHidden(false)
    tradingHouseWrapper:SetLoadingOverlayParent(ZO_TradingHousePostedItemsList)
end

function ListingTabWrapper:OnClose(tradingHouseWrapper)
    self.listingControl:SetParent(self.infoControl)
    self.listingControl:ClearAnchors()
    self.listingControl:SetAnchor(TOP, self.itemControl, BOTTOM, 0, 15)
    self.listingPriceSumControl:SetHidden(true)
end
