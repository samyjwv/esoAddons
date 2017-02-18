local L = AwesomeGuildStore.Localization
local ToggleButton = AwesomeGuildStore.ToggleButton
local ExecuteSearchOperation = AwesomeGuildStore.ExecuteSearchOperation
local ClearCallLater = AwesomeGuildStore.ClearCallLater
local GetItemLinkWritCount = AwesomeGuildStore.GetItemLinkWritCount

local SearchTabWrapper = ZO_Object:Subclass()
AwesomeGuildStore.SearchTabWrapper = SearchTabWrapper

local ACTION_LAYER_NAME = "AwesomeGuildStore"
local FILTER_PANEL_WIDTH = 220

function SearchTabWrapper:New(saveData)
    local wrapper = ZO_Object.New(self)
    wrapper.saveData = saveData
    return wrapper
end

local iconMarkup = string.format("|t%u:%u:%s|t", 16, 16, "EsoUI/Art/currency/currency_gold.dds")
function SearchTabWrapper:RunInitialSetup(tradingHouseWrapper)
    self:InitializeContainers(tradingHouseWrapper)
    self:InitializePageFiltering(tradingHouseWrapper)
    self:InitializeFilters(tradingHouseWrapper)
    self:InitializeButtons(tradingHouseWrapper)
    self:InitializeSearchSortHeaders(tradingHouseWrapper)
    self:InitializeNavigation(tradingHouseWrapper)
    self:InitializeUnitPriceDisplay(tradingHouseWrapper)
    self:InitializePurchaseNotification(tradingHouseWrapper)
    self:InitializeKeybinds(tradingHouseWrapper)
    zo_callLater(function()
        self:RefreshFilterDimensions() -- call this after the layout has been updated
        self.categoryFilter:UpdateSubfilterVisibility() -- fix inpage filters not working on first visit
    end, 1)
    self.tradingHouseWrapper = tradingHouseWrapper

    local saveData = self.saveData
    CALLBACK_MANAGER:RegisterCallback("AwesomeGuildStore_SearchLibraryEntry_Selected", function(entry)
        if(saveData.autoSearch) then
            self.fromSearchLibrary = true
            tradingHouseWrapper.tradingHouse:ClearSearchResults()
            self:Search()
        end
    end)
end

local function SortByFilterPriority(a, b)
    if(a.priority == b.priority) then
        return a.type < b.type
    end
    return b.priority < a.priority
end

function SearchTabWrapper:RequestUpdateFilterAnchors()
    if(self.updateFilterAnchorRequest) then
        ClearCallLater(self.updateFilterAnchorRequest)
    end
    self.updateFilterAnchorRequest = zo_callLater(function()
        self.updateFilterAnchorRequest = nil
        self:UpdateFilterAnchors()
    end, 10)
end

function SearchTabWrapper:UpdateFilterAnchors()
    table.sort(self.sortedFilters, SortByFilterPriority)

    local previousChild = self.filterAreaScrollChild
    for i = 1, #self.sortedFilters do
        local isFirst = (i == 1)
        local filterContainer = self.sortedFilters[i]:GetControl()
        filterContainer:ClearAnchors()
        filterContainer:SetAnchor(TOPLEFT, previousChild, isFirst and TOPLEFT or BOTTOMLEFT, 0, isFirst and 0 or 10)
        previousChild = filterContainer
    end
end

local function HandleFilterChanged(self)
    if(not self.fromSearchLibrary) then
        self:CancelSearch()
    end
end

local function RequestHandleFilterChanged(self)
    if(self.fireChangeCallback) then
        ClearCallLater(self.fireChangeCallback)
    end
    self.fireChangeCallback = zo_callLater(function()
        self.handleChangeCallback = nil
        HandleFilterChanged(self)
    end, 10)
end

local function RebuildSearchResultsPage()
    TRADING_HOUSE:RebuildSearchResultsPage()
end

function SearchTabWrapper:AttachFilter(filter)
    if(self.attachedFilters[filter.type]) then return end

    self.attachedFilters[filter.type] = filter
    self.sortedFilters[#self.sortedFilters + 1] = filter
    filter:SetParent(self.filterAreaScrollChild)
    filter:SetWidth(FILTER_PANEL_WIDTH)
    filter:SetHidden(false)
    CALLBACK_MANAGER:RegisterCallback(filter.callbackName, HandleFilterChanged, self)
    if(filter.isLocal) then
        CALLBACK_MANAGER:RegisterCallback(filter.callbackName, RebuildSearchResultsPage)
    end
    self:RequestUpdateFilterAnchors()
end

function SearchTabWrapper:DetachFilter(filter)
    if(not self.attachedFilters[filter.type]) then return end

    filter:SetHidden(true)
    filter:SetParent(GuiRoot)
    self.attachedFilters[filter.type] = nil
    for i = 1, #self.sortedFilters do
        if(self.sortedFilters[i] == filter) then
            table.remove(self.sortedFilters, i)
            break
        end
    end
    CALLBACK_MANAGER:UnregisterCallback(filter.callbackName, HandleFilterChanged)
    if(filter.isLocal) then
        CALLBACK_MANAGER:UnregisterCallback(filter.callbackName, RebuildSearchResultsPage)
    end
    self:RequestUpdateFilterAnchors()
end

function SearchTabWrapper:RefreshFilterDimensions()
    for _, filter in pairs(self.attachedFilters) do
        filter:SetWidth(FILTER_PANEL_WIDTH)
    end
end

function SearchTabWrapper:InitializeContainers(tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local leftPane = tradingHouse.m_leftPane
    local browseItemsControl = tradingHouse.m_browseItems
    local common = browseItemsControl:GetNamedChild("Common")
    local header = browseItemsControl:GetNamedChild("Header")
    header:ClearAnchors()
    header:SetAnchor(TOPLEFT, common:GetParent(), TOPLEFT, 0, -43)

    common:ClearAnchors()
    common:SetAnchor(TOPLEFT, leftPane, TOPLEFT, 0, -10)
    common:SetAnchor(BOTTOMRIGHT, leftPane, BOTTOMRIGHT, 0, 0)
    leftPane:SetWidth(247)

    local buttonArea = WINDOW_MANAGER:CreateControl("AwesomeGuildStoreButtonArea", common, CT_CONTROL)
    buttonArea:SetAnchor(BOTTOMLEFT, common, BOTTOMLEFT, 0, 0)
    buttonArea:SetAnchor(BOTTOMRIGHT, common, BOTTOMIGHT, 0, 0)
    self.buttonArea = buttonArea
    self.nextButtonIndex = 1
    self.attachedButtons = {}

    local filterArea = CreateControlFromVirtual("AwesomeGuildStoreFilterArea", common, "ZO_ScrollContainer")
    filterArea:ClearAnchors()
    filterArea:SetAnchor(TOPLEFT, common, TOPLEFT, 0, 0)
    filterArea:SetAnchor(BOTTOMRIGHT, buttonArea, TOPRIGHT, 0, -10)
    self.filterArea = filterArea

    local filterAreaScrollChild = filterArea:GetNamedChild("ScrollChild")
    self.filterAreaScrollChild = filterAreaScrollChild
    self.attachedFilters = {}
    self.sortedFilters = {}
end

function SearchTabWrapper:InitializePageFiltering(tradingHouseWrapper)
    local filters = self.attachedFilters
    local itemCount, filteredItemCount = 0, 0

    local activeFilters, numActiveFilters = {}, 0
    local function BeforeRebuildSearchResultsPage(tradingHouseWrapper)
        numActiveFilters = 0
        for _, filter in pairs(filters) do
            if(filter:BeforeRebuildSearchResultsPage(tradingHouseWrapper)) then
                numActiveFilters = numActiveFilters + 1
                activeFilters[numActiveFilters] = filter
            end
        end
        return (numActiveFilters > 0)
    end

    local function FilterPageResult(...)
        for i = 1, numActiveFilters do
            if(not activeFilters[i]:FilterPageResult(...)) then
                return false
            end
        end
        return true
    end

    local function AfterRebuildSearchResultsPage(tradingHouseWrapper)
        for _, filter in pairs(filters) do
            filter:AfterRebuildSearchResultsPage(tradingHouseWrapper)
        end
    end

    local OriginalGetTradingHouseSearchResultItemInfo = GetTradingHouseSearchResultItemInfo
    local FakeGetTradingHouseSearchResultItemInfo = function(index)
        local icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice = OriginalGetTradingHouseSearchResultItemInfo(index)

        if(name ~= "" and stackCount > 0) then
            itemCount = itemCount + 1
            if(FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)) then
                filteredItemCount = filteredItemCount + 1
                return icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice
            end
        end
        return nil, "", nil, 0
    end

    local saveData = self.saveData
    local searchTabWrapper = self
    tradingHouseWrapper:Wrap("RebuildSearchResultsPage", function(originalRebuildSearchResultsPage, self, ...)
        if(self.isReceivingResults) then
            self.fromSearchLibrary = false
        end

        local isFiltering = BeforeRebuildSearchResultsPage(tradingHouseWrapper)
        if(isFiltering and not searchTabWrapper.suppressLocalFilters) then
            itemCount, filteredItemCount = 0, 0
            GetTradingHouseSearchResultItemInfo = FakeGetTradingHouseSearchResultItemInfo
        end

        originalRebuildSearchResultsPage(self, ...)

        AfterRebuildSearchResultsPage(tradingHouseWrapper)
        if(isFiltering and not searchTabWrapper.suppressLocalFilters) then
            GetTradingHouseSearchResultItemInfo = OriginalGetTradingHouseSearchResultItemInfo
            self.m_resultCount:SetText(zo_strformat(L["TEXT_FILTER_ITEMCOUNT_TEMPLATE"], itemCount, filteredItemCount))

            local shouldHide = (filteredItemCount ~= 0 or self.m_search:HasPreviousPage() or self.m_search:HasNextPage())
            self.m_noItemsLabel:SetHidden(shouldHide)
            self.m_searchAllowed = true -- don't disable search when we have inpage filters active

            if(self.isReceivingResults and searchTabWrapper.isOpen and filteredItemCount == 0 and saveData.skipEmptyPages and self.m_search:HasNextPage()) then
                searchTabWrapper:SearchNextPage()
            end
        end
    end)
end

function SearchTabWrapper:InitializeFilters(tradingHouseWrapper)
    local saveData = self.saveData
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local browseItemsControl = tradingHouse.m_browseItems
    local common = browseItemsControl:GetNamedChild("Common")

    local searchLibrary = AwesomeGuildStore.SearchLibrary:New(saveData.searchLibrary)
    self.searchLibrary = searchLibrary

    SLASH_COMMANDS["/ags"] = function(command) -- TODO: make proper command handler once we have more
        if(command == "reset") then
            searchLibrary:ResetPosition()
            d("[AwesomeGuildStore] Default search library position restored")
    end
    end

    local categoryFilter = AwesomeGuildStore.CategorySelector:New(browseItemsControl, "AwesomeGuildStoreItemCategory", self, tradingHouseWrapper)
    searchLibrary:RegisterFilter(categoryFilter)
    self.categoryFilter = categoryFilter

    local priceFilter = AwesomeGuildStore.PriceFilter:New("AwesomeGuildStorePriceFilter", tradingHouseWrapper)
    self:AttachFilter(priceFilter)
    searchLibrary:RegisterFilter(priceFilter)
    self.priceFilter = priceFilter

    local levelFilter = AwesomeGuildStore.LevelFilter:New("AwesomeGuildStoreLevelFilter", tradingHouseWrapper)
    searchLibrary:RegisterFilter(levelFilter)
    self.levelFilter = levelFilter

    local qualityFilter = AwesomeGuildStore.QualityFilter:New("AwesomeGuildStoreQualityFilter", tradingHouseWrapper)
    self:AttachFilter(qualityFilter)
    searchLibrary:RegisterFilter(qualityFilter)
    self.qualityFilter = qualityFilter

    local unitPriceFilter = AwesomeGuildStore.UnitPriceFilter:New("AwesomeGuildStoreUnitPriceFilter", tradingHouseWrapper)
    self:AttachFilter(unitPriceFilter)
    searchLibrary:RegisterFilter(unitPriceFilter)
    self.unitPriceFilter = unitPriceFilter

    local textFilter = AwesomeGuildStore.TextFilter:New("AwesomeGuildStoreTextFilter", tradingHouseWrapper)
    self:AttachFilter(textFilter)
    searchLibrary:RegisterFilter(textFilter)
    self.textFilter = textFilter

    AwesomeGuildStore:FireOnInitializeFiltersCallbacks(tradingHouseWrapper)

    if(saveData.keepFiltersOnClose) then
        searchLibrary:Deserialize(saveData.searchLibrary.lastState)
    end
    searchLibrary:Serialize()
end

function SearchTabWrapper:UpdateButtonAnchors()
    local buttonArea = self.buttonArea
    local count = buttonArea:GetNumChildren()

    local previousChild = buttonArea
    local buttons = {}
    local height = 0
    for i = 1, count do
        local button = buttonArea:GetChild(i)
        buttons[#buttons + 1] = button
    end
    table.sort(buttons, function(a, b) return a.__agsIndex < b.__agsIndex end)
    for i = 1, #buttons do
        local button = buttons[i]
        local isFirst = (i == 1)
        button:ClearAnchors()
        button:SetAnchor(TOPLEFT, previousChild, isFirst and TOPLEFT or BOTTOMLEFT, 0, isFirst and 0 or 2)
        button:SetAnchor(TOPRIGHT, previousChild, isFirst and TOPRIGHT or BOTTOMRIGHT, 0, isFirst and 0 or 2)
        height = height + button:GetHeight() + 2
        previousChild = button
    end
    buttonArea:SetHeight(height)
end

function SearchTabWrapper:AttachButton(button)
    if(self.attachedButtons[button:GetName()]) then return end

    self.attachedButtons[button:GetName()] = button
    local hidden = button:IsControlHidden()
    button:SetParent(self.buttonArea)

    -- collapse buttons when they are hidden
    button.__agsSetHidden = button.SetHidden
    button.__agsHeight = button:GetHeight()
    button.SetHidden = function(button, hidden)
        if(not button:IsHidden() and hidden) then
            button.__agsHeight = button:GetHeight()
            button:SetHeight(0)
        elseif(button:IsHidden() and not hidden) then
            button:SetHeight(button.__agsHeight)
        end
        button:__agsSetHidden(hidden)
        self:UpdateButtonAnchors()
    end
    if(hidden) then button:SetHeight(0) end

    if(not button.__agsIndex) then
        button.__agsIndex = self.nextButtonIndex
        self.nextButtonIndex = self.nextButtonIndex + 1
    end

    self:UpdateButtonAnchors()
end

function SearchTabWrapper:DetachButton(button)
    if(not self.attachedButtons[button:GetName()]) then return end

    button.SetHidden = button.__agsSetHidden
    if(button:IsHidden()) then button:SetHeight(button.__agsHeight) end
    button:SetParent(GuiRoot)
    self:UpdateButtonAnchors()
    self.attachedButtons[button:GetName()] = nil
end

function SearchTabWrapper:InitializeButtons(tradingHouseWrapper)
    local saveData = self.saveData
    local tradingHouse = tradingHouseWrapper.tradingHouse

    local browseItemsControl = tradingHouse.m_browseItems
    local common = browseItemsControl:GetNamedChild("Common")

    local searchButton = CreateControlFromVirtual("AwesomeGuildStoreStartSearchButton", GuiRoot, "ZO_DefaultButton")
    searchButton:SetText(L["START_SEARCH_LABEL"])
    searchButton:SetHandler("OnMouseUp",function(control, button, isInside)
        if(control:GetState() == BSTATE_NORMAL and button == 1 and isInside) then
            self:Search()
        end
    end)
    self:AttachButton(searchButton)
    self.searchButton = searchButton

    local RESET_BUTTON_SIZE = 24
    local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"

    local resetButton = AwesomeGuildStore.SimpleIconButton:New("AwesomeGuildStoreFilterResetButton", RESET_BUTTON_TEXTURE, RESET_BUTTON_SIZE, L["RESET_ALL_FILTERS_LABEL"])
    resetButton:SetAnchor(TOPRIGHT, browseItemsControl:GetNamedChild("Header"), TOPLEFT, 196, 0)
    resetButton.OnClick = function()
        local originalClearSearchResults = tradingHouse.ClearSearchResults
        tradingHouse.ClearSearchResults = function() end
        tradingHouse:ResetAllSearchData()
        tradingHouse.ClearSearchResults = originalClearSearchResults
        RequestHandleFilterChanged(self)
    end

    tradingHouseWrapper:PreHook("ResetAllSearchData", function()
        self.searchLibrary:ResetFilters()
    end)

    local autoSearchButton = ToggleButton:New(browseItemsControl:GetNamedChild("Header"), "AwesomeGuildStoreAutoSearchButton", "EsoUI/Art/lfg/lfg_tabIcon_groupTools_%s.dds", 0, 0, 28, 28, L["AUTO_SEARCH_TOGGLE_LABEL"])
    autoSearchButton.control:ClearAnchors()
    autoSearchButton.control:SetAnchor(TOPRIGHT, browseItemsControl:GetNamedChild("Header"), TOPLEFT, 278, -2)
    if(saveData.autoSearch) then
        autoSearchButton:Press()
    end
    autoSearchButton.HandlePress = function()
        saveData.autoSearch = true
        return true
    end
    autoSearchButton.HandleRelease = function()
        saveData.autoSearch = false
        return true
    end
end

function SearchTabWrapper:InitializeSearchSortHeaders(tradingHouseWrapper)
    local saveData = self.saveData
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local search = tradingHouse.m_search

    search.InitializeOrderingData = function(self)
        if(saveData.keepSortOrderOnClose) then
            self.ResetOrderingData = function() end
            self.m_sortField = saveData.sortField
            self.m_sortOrder = saveData.sortOrder

            local sortHeader = tradingHouse.m_searchSortHeaders
            local oldEnabled = sortHeader.enabled
            sortHeader.enabled = true -- force it enabled for a bit, otherwise it won't update
            sortHeader:SelectHeaderByKey(self.m_sortField, ZO_SortHeaderGroup.SUPPRESS_CALLBACKS, true)
            if(not self.m_sortOrder) then -- call it a second time to invert the sort order
                sortHeader:SelectHeaderByKey(self.m_sortField, ZO_SortHeaderGroup.SUPPRESS_CALLBACKS)
            end
            sortHeader.enabled = oldEnabled
        else
            self.m_sortField = TRADING_HOUSE_SORT_SALE_PRICE
            self.m_sortOrder = ZO_SORT_ORDER_UP
        end
    end
    search:InitializeOrderingData()

    tradingHouseWrapper:PreHook("UpdateSortHeaders", function(self)
        if(self.m_numItemsOnPage == 0 or saveData.sortWithoutSearch) then
            self.m_searchSortHeaders:SetEnabled(true)
            return true
        end
    end)

    ZO_PreHook(search, "ChangeSort", function(self, sortKey, sortOrder)
        saveData.sortField = sortKey
        saveData.sortOrder = sortOrder
        if(tradingHouse.m_numItemsOnPage == 0 or saveData.sortWithoutSearch) then
            self:UpdateSortOption(sortKey, sortOrder)
            return true
        end
    end)
end

function SearchTabWrapper:InitializeNavigation(tradingHouseWrapper)
    local SHOW_MORE_DATA_TYPE = 4 -- watch out for changes in tradinghouse.lua
    local HAS_HIDDEN_DATA_TYPE = 5
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local search = tradingHouse.m_search

    local showPreviousPageEntry =  {
        label = L["SEARCH_PREVIOUS_PAGE_LABEL"],
        callback = function() self:SearchPreviousPage() end,
        updateState = function(rowControl)
            rowControl:SetEnabled(true)
        end,
        color = ZO_ColorDef:New("F97431")
    }

    local showNextPageEntry =  {
        label = L["SEARCH_SHOW_MORE_LABEL"],
        callback = function() self:SearchNextPage() end,
        updateState = function(rowControl)
            rowControl:SetEnabled(true)
        end,
        color = ZO_ColorDef:New("50D35D")
    }

    ZO_ScrollList_AddDataType(tradingHouse.m_searchResultsList, SHOW_MORE_DATA_TYPE, "AwesomeGuildStoreShowMoreRowTemplate", 32, function(rowControl, entry)
        local label = rowControl:GetNamedChild("Text")
        label:SetText(entry.label)
        rowControl.label = label

        local highlight = rowControl:GetNamedChild("Highlight")
        if(entry.color) then
            highlight:SetColor(entry.color:UnpackRGB())
            highlight:SetAlpha(0.5)
        end

        if not highlight.animation then
            highlight.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", highlight)
            local alphaAnimation = highlight.animation:GetFirstAnimation()
            alphaAnimation:SetAlphaValues(0.5, 1)
        end

        rowControl:SetHandler("OnMouseEnter", function()
            highlight.animation:PlayForward()
        end)

        rowControl:SetHandler("OnMouseExit", function()
            highlight.animation:PlayBackward()
        end)

        rowControl:SetHandler("OnMouseUp", function(control, button, isInside)
            if(rowControl.enabled and button == 1 and isInside) then
                PlaySound("Click")
                entry.callback()
            end
        end)

        rowControl.SetEnabled = function(self, enabled)
            rowControl.enabled = enabled
            highlight.animation:GetFirstAnimation():SetAlphaValues(0.5, enabled and 1 or 0.5)
            label:SetColor((enabled and ZO_NORMAL_TEXT or ZO_DEFAULT_DISABLED_COLOR):UnpackRGBA())
        end

        entry.updateState(rowControl)
        rowControl.entry = entry
        entry.rowControl = rowControl
    end, nil, nil, function(rowControl)
        rowControl.enabled = nil
        rowControl.label = nil
        rowControl.SetEnabled = nil
        rowControl.entry.rowControl = nil
        rowControl.entry = nil
        ZO_ObjectPool_DefaultResetControl(rowControl)
    end)

    ZO_ScrollList_AddDataType(tradingHouse.m_searchResultsList, HAS_HIDDEN_DATA_TYPE, "AwesomeGuildStoreHasHiddenRowTemplate", 24, function(rowControl, entry)
        local label = rowControl:GetNamedChild("Text")
        label:SetText(L["SEARCH_HAS_HIDDEN_RESULTS"])
    end, nil, nil, function(rowControl)
        ZO_ObjectPool_DefaultResetControl(rowControl)
    end)

    tradingHouseWrapper:Wrap("RebuildSearchResultsPage", function(originalRebuildSearchResultsPage, self)
        originalRebuildSearchResultsPage(self)

        local hasPrev = search:HasPreviousPage()
        local hasNext = search:HasNextPage()
        if(hasPrev or hasNext) then
            local list = self.m_searchResultsList
            local scrollData = ZO_ScrollList_GetDataList(list)
            local isEmpty = (#scrollData == 0)
            if(hasPrev) then
                table.insert(scrollData, 1, ZO_ScrollList_CreateDataEntry(SHOW_MORE_DATA_TYPE, showPreviousPageEntry))
            end
            if(isEmpty) then
                scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(HAS_HIDDEN_DATA_TYPE, {})
            end
            if(hasNext) then
                scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(SHOW_MORE_DATA_TYPE, showNextPageEntry)
            end
            ZO_ScrollList_Commit(list)
        end
    end)

    self.paging = AwesomeGuildStore.Paging:New(tradingHouseWrapper)

    tradingHouseWrapper:Wrap("UpdatePagingButtons", function(originalUpdatePagingButtons, self)
        if(showPreviousPageEntry.rowControl ~= nil) then showPreviousPageEntry.updateState(showPreviousPageEntry.rowControl) end
        if(showNextPageEntry.rowControl ~= nil) then showNextPageEntry.updateState(showNextPageEntry.rowControl) end
        originalUpdatePagingButtons(self)
    end)
end

local PER_UNIT_PRICE_CURRENCY_OPTIONS = {
    showTooltips = false,
    iconSide = RIGHT,
}
local UNIT_PRICE_FONT = "/esoui/common/fonts/univers67.otf|14|soft-shadow-thin"
local SEARCH_RESULTS_DATA_TYPE = 1

local function SetUnitPrice(tradingHouse, rowControl, sellPriceControl, perItemPrice, result, unitPrice)
    ZO_CurrencyControl_SetSimpleCurrency(perItemPrice, result.currencyType, unitPrice, PER_UNIT_PRICE_CURRENCY_OPTIONS, nil, tradingHouse.m_playerMoney[result.currencyType] < result.purchasePrice)
    perItemPrice:SetText("@" .. perItemPrice:GetText():gsub("|t.-:.-:", "|t12:12:"))
    perItemPrice:SetHidden(false)
    sellPriceControl:ClearAnchors()
    sellPriceControl:SetAnchor(RIGHT, rowControl, RIGHT, -5, -8)
end

function SearchTabWrapper:InitializeUnitPriceDisplay(tradingHouseWrapper)
    local saveData = self.saveData
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local dataType = tradingHouse.m_searchResultsList.dataTypes[SEARCH_RESULTS_DATA_TYPE]
    local originalSetupCallback = dataType.setupCallback

    dataType.setupCallback = function(rowControl, result)
        originalSetupCallback(rowControl, result)

        local sellPriceControl = rowControl:GetNamedChild("SellPrice")
        local perItemPrice = rowControl:GetNamedChild("SellPricePerItem")
        local shouldShow = false
        if(saveData.displayPerUnitPrice) then
            if(not perItemPrice) then
                local controlName = rowControl:GetName() .. "SellPricePerItem"
                perItemPrice = rowControl:CreateControl(controlName, CT_LABEL)
                perItemPrice:SetAnchor(TOPRIGHT, sellPriceControl, BOTTOMRIGHT, 0, 0)
                perItemPrice:SetFont(UNIT_PRICE_FONT)
            end

            if(result.stackCount > 1) then
                local unitPrice = tonumber(string.format("%.2f", result.purchasePrice / result.stackCount))
                SetUnitPrice(tradingHouse, rowControl, sellPriceControl, perItemPrice, result, unitPrice)
                shouldShow = true
            else
                local itemLink = GetTradingHouseSearchResultItemLink(result.slotIndex)
                local itemType = GetItemLinkItemType(itemLink)
                if(itemType == ITEMTYPE_MASTER_WRIT) then
                    local writCount = GetItemLinkWritCount(itemLink)
                    local unitPrice = tonumber(string.format("%.2f", result.purchasePrice / writCount))
                    SetUnitPrice(tradingHouse, rowControl, sellPriceControl, perItemPrice, result, unitPrice)
                    shouldShow = true
                end
            end
        end

        if(perItemPrice and not shouldShow) then
            perItemPrice:SetHidden(true)
            sellPriceControl:ClearAnchors()
            sellPriceControl:SetAnchor(RIGHT, rowControl, RIGHT, -5, 0)
        end
    end
end

function SearchTabWrapper:InitializePurchaseNotification(tradingHouseWrapper)
    local saveData = self.saveData
    local purchaseMessage = ""
    tradingHouseWrapper:Wrap("ConfirmPendingPurchase", function(originalConfirmPendingPurchase, self, pendingPurchaseIndex)
        local _, _, _, count, seller, _, price = GetTradingHouseSearchResultItemInfo(pendingPurchaseIndex)
        seller = ZO_LinkHandler_CreateDisplayNameLink(seller:gsub("|c.-$", "")) -- have to strip the stuff that MM is adding to the end
        price = zo_strformat("<<1>> <<2>>", ZO_CurrencyControl_FormatCurrency(price), iconMarkup)
        local itemLink = GetTradingHouseSearchResultItemLink(pendingPurchaseIndex)
        local _, guildName = GetCurrentTradingHouseGuildDetails()
        purchaseMessage = zo_strformat(L["PURCHASE_NOTIFICATION"], count, itemLink, seller, price, guildName)
        originalConfirmPendingPurchase(self, pendingPurchaseIndex)
    end)
    tradingHouseWrapper:Wrap("OnPurchaseSuccess", function(originalOnPurchaseSuccess, self)
        if(saveData.purchaseNotification and purchaseMessage ~= "") then
            df("[AwesomeGuildStore] %s", purchaseMessage)
            purchaseMessage = ""
        end
        originalOnPurchaseSuccess(self)
    end)
end

function SearchTabWrapper:InitializeKeybinds(tradingHouseWrapper)
    function AwesomeGuildStore.SuppressLocalFilters(pressed)
        self.suppressLocalFilters = pressed
        TRADING_HOUSE:RebuildSearchResultsPage()
    end
end

function SearchTabWrapper:Search(page)
    if(page) then
        self.tradingHouseWrapper.activityManager:ExecuteSearchPage(page)
    else
        self.tradingHouseWrapper.activityManager:ExecuteSearch()
    end
end

function SearchTabWrapper:SearchPreviousPage()
    self.tradingHouseWrapper.activityManager:ExecuteSearchPreviousPage()
end

function SearchTabWrapper:SearchNextPage()
    self.tradingHouseWrapper.activityManager:ExecuteSearchNextPage()
end

function SearchTabWrapper:CancelSearch()
    self.tradingHouseWrapper.activityManager:CancelSearch()
end

function SearchTabWrapper:RelocateButtons(tradingHouse)
    local buttonArea = self.buttonArea

    local leftPane = tradingHouse.m_leftPane
    local buttonsToAdd = {}
    for i = 1, leftPane:GetNumChildren() do
        local child = leftPane:GetChild(i)
        if(child and child:GetType() == CT_BUTTON) then
            buttonsToAdd[#buttonsToAdd + 1] = child
        end
    end

    local common = tradingHouse.m_browseItems:GetNamedChild("Common")
    for i = 1, common:GetNumChildren() do
        local child = common:GetChild(i)
        if(child and child:GetType() == CT_BUTTON) then
            buttonsToAdd[#buttonsToAdd + 1] = child
        end
    end

    for i = 1, #buttonsToAdd do
        self:AttachButton(buttonsToAdd[i])
    end
end

function SearchTabWrapper:OnOpen(tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    tradingHouseWrapper:SetLoadingOverlayParent(ZO_TradingHouseItemPaneSearchResults)
    tradingHouse.m_searchAllowed = true
    tradingHouse:OnSearchCooldownUpdate(GetTradingHouseCooldownRemaining())
    AwesomeGuildStore:FireOnOpenSearchTabCallbacks(tradingHouseWrapper)
    self:RelocateButtons(tradingHouse)
    PushActionLayerByName(ACTION_LAYER_NAME)
    self.isOpen = true
end

function SearchTabWrapper:OnClose(tradingHouseWrapper)
    self.isOpen = false
    local activity = ExecuteSearchOperation:New(self.tradingHouseWrapper) -- TODO not the best way to go about it, but it will do for now
    self.tradingHouseWrapper.activityManager:RemoveActivity(activity)
    RemoveActionLayerByName(ACTION_LAYER_NAME)
    AwesomeGuildStore:FireOnCloseSearchTabCallbacks(tradingHouseWrapper)
end
