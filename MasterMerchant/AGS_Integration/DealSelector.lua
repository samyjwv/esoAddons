function MasterMerchant.InitDealSelectorClass()
	local L = AwesomeGuildStore.Localization
	local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider
	local SimpleIconButton = AwesomeGuildStore.SimpleIconButton
	local FilterBase = AwesomeGuildStore.FilterBase

	local DealSelector = FilterBase:Subclass()

	local BUTTON_SIZE = 36
	local BUTTON_PADDING = 0
	local BUTTON_OFFSET_Y = 12
	local BUTTON_FOLDER = "AwesomeGuildStore/images/qualitybuttons/"
	local MIN_DEAL = 0
	local MAX_DEAL = 5
	local MOUSE_LEFT = 1
	local MOUSE_RIGHT = 2
	local MOUSE_MIDDLE = 3
	local DEAL_LABEL = {"Overpriced", "Ok", "Reasonable", "Good", "Great", "Buy it!"}
	local LINE_SPACING = 4
	local DEAL_FITLER_TYPE_ID = 100

	function DealSelector:New(name, tradingHouseWrapper, ...)
		return FilterBase.New(self, DEAL_FITLER_TYPE_ID, name, tradingHouseWrapper, ...)
	end

	function DealSelector:Initialize(name, tradingHouseWrapper)
		local tradingHouse = tradingHouseWrapper.tradingHouse
		local saveData = tradingHouseWrapper.saveData
		local container = self.container

		local label = container:CreateControl(name .. "Label", CT_LABEL)
		label:SetFont("ZoFontWinH4")
		label:SetText("Deal Range:")
		self:SetLabelControl(label)

		local slider = MinMaxRangeSlider:New(container, name .. "Slider")
		slider:SetMinMax(MIN_DEAL, MAX_DEAL)
		slider:SetRangeValue(MIN_DEAL, MAX_DEAL)
		slider.control:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, LINE_SPACING)
		slider.control:SetAnchor(RIGHT, container, RIGHT, 0, 0)
		slider.OnValueChanged = function(slider, min, max)
			self:HandleChange()
		end
		self.slider = slider

		local function SafeSetRangeValue(button, value)
			local min, max = slider:GetRangeValue()
			if(button == MOUSE_LEFT) then
				if(value > max) then slider:SetMaxValue(value) end
				slider:SetMinValue(value)
			elseif(button == MOUSE_RIGHT) then
				if(value < min) then slider:SetMinValue(value) end
				slider:SetMaxValue(value)
			elseif(button == MOUSE_MIDDLE) then
				slider:SetRangeValue(value, value)
			end
		end

		local function CreateButtonControl(name, textureName, tooltipText, value)
			local button = SimpleIconButton:New(name, BUTTON_FOLDER .. textureName, BUTTON_SIZE, tooltipText)
			button:SetMouseOverTexture(BUTTON_FOLDER .. "over.dds") -- we reuse the texture as it is the same for all quality buttons
			button.control:SetHandler("OnMouseDoubleClick", function(control, button)
				SafeSetRangeValue(MOUSE_MIDDLE, value)
			end)
			button.OnClick = function(self, mouseButton, ctrl, alt, shift)
				local oldBehavior = saveData.oldQualitySelectorBehavior
				local setBoth = (oldBehavior and shift) or (not oldBehavior and not shift)
				if(setBoth) then
					SafeSetRangeValue(MOUSE_MIDDLE, value)
				else
					SafeSetRangeValue(mouseButton, value)
				end
				return true
			end
			return button
		end

		self.buttons = {}
		local overpricedButton = CreateButtonControl(name .. "OverpricedDealButton", "", DEAL_LABEL[1], 0)
		overpricedButton:SetNormalTexture("MasterMerchant/AGS_Integration/overpriced_up.dds")
		overpricedButton:SetPressedTexture("MasterMerchant/AGS_Integration/overpriced_down.dds")
		self.buttons[1] = overpricedButton
		self.buttons[2] = CreateButtonControl(name .. "NormalDealButton", "normal_%s.dds", DEAL_LABEL[2], 1)
		self.buttons[3] = CreateButtonControl(name .. "MagicDealButton", "magic_%s.dds", DEAL_LABEL[3], 2)
		self.buttons[4] = CreateButtonControl(name .. "ArcaneDealButton", "arcane_%s.dds", DEAL_LABEL[4], 3)
		self.buttons[5] = CreateButtonControl(name .. "ArtifactDealButton", "artifact_%s.dds", DEAL_LABEL[5], 4)
		self.buttons[6] = CreateButtonControl(name .. "LegendaryDealButton", "legendary_%s.dds", DEAL_LABEL[6], 5)

		container:SetHeight(label:GetHeight() + LINE_SPACING + slider.control:GetHeight() + LINE_SPACING + BUTTON_OFFSET_Y + BUTTON_SIZE)

		local tooltipText = L["RESET_FILTER_LABEL_TEMPLATE"]:format(label:GetText():gsub(":", ""))
		self.resetButton:SetTooltipText(tooltipText)
	end

	function DealSelector:BeforeRebuildSearchResultsPage(tradingHouseWrapper)
		if(not self:IsDefault()) then
			return true
		end
		return false
	end
  
	function DealSelector:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
		local minDeal, maxDeal = self:GetRangeValue()
		local deal = MasterMerchant.GetDealValue(index)
		if not deal or deal < minDeal or deal > maxDeal then
			return false
		end
		return true
	end

	function DealSelector:SetWidth(width)
		self.container:SetWidth(width)
		self.slider:UpdateVisuals()

		local buttons = self.buttons
		local sliderControl = self.slider.control
		local spacing = (width + BUTTON_PADDING) / (MAX_DEAL + 1)
		for i = 1, #buttons do
			buttons[i]:SetAnchor(TOPLEFT, sliderControl, TOPLEFT, spacing * (i - 1), LINE_SPACING + BUTTON_OFFSET_Y)
		end
	end

	function DealSelector:Reset()
		self.slider:SetRangeValue(MIN_DEAL, MAX_DEAL)
	end

	function DealSelector:IsDefault()
		local min, max = self:GetRangeValue()
		return (min == MIN_DEAL and max == MAX_DEAL)
	end

	function DealSelector:GetRangeValue()
		return self.slider:GetRangeValue()
	end

	function DealSelector:Serialize()
		local min, max = self:GetRangeValue()
		return tostring(min) .. ";" .. tostring(max)
	end

	function DealSelector:Deserialize(state)
		local min, max = zo_strsplit(";", state)
		assert(min and max)
		self.slider:SetRangeValue(tonumber(min), tonumber(max))
	end

	function DealSelector:GetTooltipText(state)
		local minDeal, maxDeal = zo_strsplit(";", state)
		minDeal = tonumber(minDeal)
		maxDeal = tonumber(maxDeal)
		if(minDeal and maxDeal and not (minDeal == MIN_DEAL and maxDeal == MAX_DEAL)) then
			local text = ""
			for i = minDeal, maxDeal do
				text = text .. DEAL_LABEL[i + 1] .. ", "
			end
			return {{label = "Deal Range", text = text:sub(0, -3)}}
		end
		return {}
	end

	return DealSelector
end

function MasterMerchant.InitProfitFilterClass()
	local L = AwesomeGuildStore.Localization
	local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider
	local SimpleIconButton = AwesomeGuildStore.SimpleIconButton
	local FilterBase = AwesomeGuildStore.FilterBase

	local ProfitFilter = FilterBase:Subclass()

	local BUTTON_OFFSET_Y = 12
  local LOWER_LIMIT = 1
  local UPPER_LIMIT = 2100000000
  local values = { LOWER_LIMIT, 10, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 50000, 100000, UPPER_LIMIT }
  local MIN_PROFIT = 1
  local MAX_PROFIT = #values

	local MOUSE_LEFT = 1
	local MOUSE_RIGHT = 2
	local MOUSE_MIDDLE = 3
	local LINE_SPACING = 4
	local DEAL_FITLER_TYPE_ID = 101
  local changeTime = nil

	function ProfitFilter:New(name, tradingHouseWrapper, ...)
		return FilterBase.New(self, DEAL_FITLER_TYPE_ID, name, tradingHouseWrapper, ...)
	end

  function ProfitFilter:TestForHandleChange()
    if GetTimeStamp() > changeTime then
      self:HandleChange()
    else
      zo_callLater(function()
        self:TestForHandleChange()	  
      end, 100)
    end
  end

  function ProfitFilter:DelayedHandleChange()
    self:HandleChange()
    
    --changeTime = GetTimeStamp()
    --zo_callLater(function()
    --  self:TestForHandleChange()	  
    --end, 100)
  end

	function ProfitFilter:Initialize(name, tradingHouseWrapper)
		local tradingHouse = tradingHouseWrapper.tradingHouse
  	local common = tradingHouse.m_browseItems:GetNamedChild("Common")
		local saveData = tradingHouseWrapper.saveData
		local container = self.container

		local label = container:CreateControl(name .. "Label", CT_LABEL)
		label:SetFont("ZoFontWinH4")
		label:SetText("Profit Range:")
		self:SetLabelControl(label)

		local slider = MinMaxRangeSlider:New(container, name .. "Slider")
		slider:SetMinMax(MIN_PROFIT, MAX_PROFIT)
		slider:SetRangeValue(MIN_PROFIT, MAX_PROFIT)
		slider.control:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, LINE_SPACING)
		slider.control:SetAnchor(RIGHT, container, RIGHT, 0, 0)
		slider.OnValueChanged = function(slider, min, max)
			self:DelayedHandleChange()
		end
		self.slider = slider

  	local input = CreateControlFromVirtual(name .. "MinProfit", container, "MasterMerchantPrice")
	  input:ClearAnchors()
	  input:SetAnchor(TOPLEFT, slider.control, BOTTOMLEFT, 0, LINE_SPACING)
	  local minProfit = input:GetNamedChild("Box")
	  minProfit:SetMaxInputChars(8)
	  self.minProfit = minProfit

    local profitRangeDivider = container:CreateControl(name .. "Divider", CT_TEXTURE)
    local divider = common:GetNamedChild("PriceRangeDivider")
    profitRangeDivider:SetColor(divider:GetColor())
    profitRangeDivider:SetWidth(divider:GetWidth())
    profitRangeDivider:SetHeight(divider:GetHeight())
	  profitRangeDivider:ClearAnchors()
	  profitRangeDivider:SetAnchor(LEFT, input, RIGHT, LINE_SPACING, 0)
    common:GetNamedChild("PriceRangeDivider")
    profitRangeDivider:SetHidden(false)

    local input2 = CreateControlFromVirtual(name .. "MaxProfit", container, "MasterMerchantPrice")
	  input2:ClearAnchors()
	  input2:SetAnchor(LEFT, profitRangeDivider, RIGHT, LINE_SPACING, 0)
	  local maxProfit = input2:GetNamedChild("Box")
	  maxProfit:SetMaxInputChars(8)
	  self.maxProfit = maxProfit

		container:SetHeight(label:GetHeight() + LINE_SPACING + slider.control:GetHeight() + LINE_SPACING + input:GetHeight() + LINE_SPACING + BUTTON_OFFSET_Y)

		local tooltipText = L["RESET_FILTER_LABEL_TEMPLATE"]:format(label:GetText():gsub(":", ""))
		self.resetButton:SetTooltipText(tooltipText)

  	self:InitializeHandlers(tradingHouseWrapper.tradingHouse)
	end
  
  local function ToNearestLinear(value)
	  for i, range in ipairs(values) do
		  if(i < MAX_PROFIT and value < ((values[i + 1] + range) / 2)) then return i end
	  end
	  return MAX_PROFIT
  end

  local function ValueFromText(value, limit, old)
	  if(value == "") then
		  value = limit
	  else
		  value = ToNearestLinear(tonumber(value)) or old
	  end
	  return value
  end

  function ProfitFilter:InitializeHandlers(tradingHouse)
	  local minProfit = self.minProfit
	  local maxProfit = self.maxProfit
	  local slider = self.slider
	  local setFromTextBox = false

	  local function UpdateSliderFromTextBox()
		  setFromTextBox = true
		  local oldMin, oldMax = slider:GetRangeValue()
		  local min = ValueFromText(minProfit:GetText(), MIN_PROFIT, oldMin)
		  local max = ValueFromText(maxProfit:GetText(), MAX_PROFIT, oldMax)

		  slider:SetRangeValue(min, max)
		  setFromTextBox = false
	  end

	  minProfit:SetHandler("OnTextChanged", UpdateSliderFromTextBox)
	  maxProfit:SetHandler("OnTextChanged", UpdateSliderFromTextBox)

	  local function UpdateTextBoxFromSlider()
		  local min, max = slider:GetRangeValue()
		  if(min == MIN_PROFIT) then min = "" else min = values[min] end
		  if(max == MAX_PROFIT) then max = "" else max = values[max] end

		  minProfit:SetText(min)
		  maxProfit:SetText(max)
	  end

	  slider.OnValueChanged = function(slider, min, max)
		  self:DelayedHandleChange()
		  if(setFromTextBox) then return end
		  UpdateTextBoxFromSlider()
	  end

	  ZO_PreHook(tradingHouse.m_search, "InternalExecuteSearch", function(self)
		  local min = minProfit:GetText()
		  local max = maxProfit:GetText()
		  if(min == "" and max == "") then return end
		  if(min == "") then min = LOWER_LIMIT end
		  if(max == "") then max = UPPER_LIMIT end
		  min = tonumber(min)
		  max = tonumber(max)
		  if(min == max) then max = nil end
      ProfitFilter.searchMin = min
      ProfitFilter.searchMax = max
	  end)

	  UpdateTextBoxFromSlider()
  end

	function ProfitFilter:BeforeRebuildSearchResultsPage(tradingHouseWrapper)
		if(not self:IsDefault()) then
			return true
		end
		return false
	end
  
	function ProfitFilter:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
		local profit = MasterMerchant.GetProfitValue(index)
		if not profit or (profit < (self.searchMin or 0)) or (profit > (self.searchMax or UPPER_LIMIT)) then
			return false
		end
		return true
	end

	function ProfitFilter:SetWidth(width)
		self.container:SetWidth(width)
		self.slider:UpdateVisuals()
	end

	function ProfitFilter:Reset()
	  --self.slider:SetMinMax(MIN_PROFIT, MAX_PROFIT)
	  self.slider:SetRangeValue(MIN_PROFIT, MAX_PROFIT)
	end

	function ProfitFilter:IsDefault()
		local min, max = self:GetRangeValue()
		return (min == MIN_PROFIT and max == MAX_PROFIT)
	end

	function ProfitFilter:GetRangeValue()
		return self.slider:GetRangeValue()
	end

	function ProfitFilter:Serialize()
	  local min = tonumber(self.minProfit:GetText()) or "-"
	  local max = tonumber(self.maxProfit:GetText()) or "-"
	  return min .. ";" .. max
	end

	function ProfitFilter:Deserialize(state)
	  local min, max = zo_strsplit(";", state)
	  min = tonumber(min) or LOWER_LIMIT
	  max = tonumber(max) or UPPER_LIMIT
	  self.minProfit:SetText(min <= LOWER_LIMIT and "" or min)
	  self.maxProfit:SetText(max >= UPPER_LIMIT and "" or max)
	end
  
  local function GetFormattedPrice(price)
	  return zo_strformat(SI_FORMAT_ICON_TEXT, ZO_CurrencyControl_FormatCurrency(price), zo_iconFormat("EsoUI/Art/currency/currency_gold.dds", 16, 16))
  end

	function ProfitFilter:GetTooltipText(state)
		local minProfit, maxProfit = zo_strsplit(";", state)
		minProfit = tonumber(minProfit)
		maxProfit = tonumber(maxProfit)
	  local profitText = ""
	  if(minProfit and maxProfit) then
		  profitText = GetFormattedPrice(minProfit) .. " - " .. GetFormattedPrice(maxProfit)
	  elseif(minProfit) then
		  profitText = L["TOOLTIP_GREATER_THAN"] .. GetFormattedPrice(minProfit)
	  elseif(maxProfit) then
		  profitText = L["TOOLTIP_LESS_THAN"] .. GetFormattedPrice(maxProfit)
	  end

	  if(profitText ~= "") then
		  return {{label = "Profit Range", text = profitText}}
	  end
	  return {}
	end

	return ProfitFilter
end

