local ITEM_LINK_FORMAT = ("|H%%d:%s:%%s|h|h"):format(ITEM_LINK_TYPE)

local ItemLinkWrapper = ZO_Object:Subclass()
sidTools.ItemLinkWrapper = ItemLinkWrapper

function ItemLinkWrapper:New(link)
	local object = ZO_Object.New(self)
	object:SetLink(link)
	return object
end

function ItemLinkWrapper:GetItemID()
	return self.itemID
end

function ItemLinkWrapper:SetItemID(itemID)
	self.itemID = tonumber(itemID) or 3
end

function ItemLinkWrapper:GetQuality()
	return self.quality
end

function ItemLinkWrapper:SetQuality(quality)
	self.quality = tonumber(quality) or 0
end

function ItemLinkWrapper:GetLevel()
	return self.level
end

function ItemLinkWrapper:SetLevel(level)
	self.level = tonumber(level) or 0
end

function ItemLinkWrapper:GetEnchantmentType()
	return self.enchantmentType
end

function ItemLinkWrapper:SetEnchantmentType(enchantmentType)
	self.enchantmentType = tonumber(enchantmentType) or 0
end

function ItemLinkWrapper:GetEnchantmentStrength1()
	return self.enchantmentStrength1
end

function ItemLinkWrapper:SetEnchantmentStrength1(enchantmentStrength1)
	self.enchantmentStrength1 = tonumber(enchantmentStrength1) or 0
end

function ItemLinkWrapper:GetEnchantmentStrength2()
	return self.enchantmentStrength2
end

function ItemLinkWrapper:SetEnchantmentStrength2(enchantmentStrength2)
	self.enchantmentStrength2 = tonumber(enchantmentStrength2) or 0
end

function ItemLinkWrapper:GetField7()
	return self.field7
end

function ItemLinkWrapper:SetField7(value)
	self.field7 = tonumber(value) or 0
end

function ItemLinkWrapper:GetField8()
	return self.field8
end

function ItemLinkWrapper:SetField8(value)
	self.field8 = tonumber(value) or 0
end

function ItemLinkWrapper:GetField9()
	return self.field9
end

function ItemLinkWrapper:SetField9(value)
	self.field9 = tonumber(value) or 0
end

function ItemLinkWrapper:GetField10()
	return self.field10
end

function ItemLinkWrapper:SetField10(value)
	self.field10 = tonumber(value) or 0
end

function ItemLinkWrapper:GetField11()
	return self.field11
end

function ItemLinkWrapper:SetField11(value)
	self.field11 = tonumber(value) or 0
end

function ItemLinkWrapper:GetField12()
	return self.field12
end

function ItemLinkWrapper:SetField12(value)
	self.field12 = tonumber(value) or 0
end

function ItemLinkWrapper:GetField13()
	return self.field13
end

function ItemLinkWrapper:SetField13(value)
	self.field13 = tonumber(value) or 0
end

function ItemLinkWrapper:GetField14()
	return self.field14
end

function ItemLinkWrapper:SetField14(value)
	self.field14 = tonumber(value) or 0
end

function ItemLinkWrapper:GetField15()
	return self.field15
end

function ItemLinkWrapper:SetField15(value)
	self.field15 = tonumber(value) or 0
end

function ItemLinkWrapper:GetStyle()
	return self.style
end

function ItemLinkWrapper:SetStyle(style)
	self.style = tonumber(style) or 0
end

function ItemLinkWrapper:GetCrafted()
	return self.crafted
end

function ItemLinkWrapper:SetCrafted(crafted)
	self.crafted = tonumber(crafted) or 0
end

function ItemLinkWrapper:GetBound()
	return self.bound
end

function ItemLinkWrapper:SetBound(bound)
	self.bound = tonumber(bound) or 0
end

function ItemLinkWrapper:GetStolen()
	return self.stolen
end

function ItemLinkWrapper:SetStolen(stolen)
	self.stolen = tonumber(stolen) or 0
end

function ItemLinkWrapper:GetCondition()
	return self.condition
end

function ItemLinkWrapper:SetCondition(condition)
	self.condition = tonumber(condition) or 0
end

function ItemLinkWrapper:GetInstanceData()
	return self.instanceData
end

function ItemLinkWrapper:SetInstanceData(instanceData)
	self.instanceData = tonumber(instanceData) or 0
end

function ItemLinkWrapper:GetLink()
	local data = table.concat({
		self.itemID,
		self.quality,
		self.level,
		self.enchantmentType,
		self.enchantmentStrength1,
		self.enchantmentStrength2,
		self.field7,
		self.field8,
		self.field9,
		self.field10,
		self.field11,
		self.field12,
		self.field13,
		self.field14,
		self.field15,
		self.style,
		self.crafted,
		self.bound,
		self.stolen,
		self.condition,
		self.instanceData,
	}, ":")
	return ITEM_LINK_FORMAT:format(LINK_STYLE_BRACKETS, data)
end

function ItemLinkWrapper:SetLink(link)
	local data = {}
	if(type(link) == "string" and #link > 0) then
		local linkStyle, linkType, text
		linkStyle, linkType, data, text = link:match("|H(.-):(.-):(.-)|h(.-)|h")
		data = (linkType == ITEM_LINK_TYPE) and {zo_strsplit(':', data)} or {}
	end

	self:SetItemID(data[1])
	self:SetQuality(data[2])
	self:SetLevel(data[3])
	self:SetEnchantmentType(data[4])
	self:SetEnchantmentStrength1(data[5])
	self:SetEnchantmentStrength2(data[6])
	for i = 7, 15 do
		self["SetField" .. i](self, data[i])
	end
	self:SetStyle(data[16])
	self:SetCrafted(data[17])
	self:SetBound(data[18])
	self:SetStolen(data[19])
	self:SetCondition(data[20])
	self:SetInstanceData(data[21])
end

function ItemLinkWrapper:ExportQualityList()
	local data = table.concat({self.itemID, "%d", self.level, "0:0:0:0:0:0:0:0:0:0:0:0:20:0:0:0:0:0"}, ":")
	local link = ITEM_LINK_FORMAT:format(LINK_STYLE_BRACKETS, data)
	local resultLink
	local qualityList = {}
	for i=0, 420 do
		resultLink = link:format(i)
		qualityList[#qualityList + 1] = table.concat({
			i,
			GetItemLinkName(resultLink),
			GetItemLinkQuality(resultLink),
			GetItemLinkItemType(resultLink),
			GetItemLinkArmorType(resultLink),
			GetItemLinkEquipType(resultLink),
			GetItemLinkWeaponType(resultLink),
			GetItemLinkWeaponPower(resultLink),
			GetItemLinkArmorRating(resultLink, false),
			GetItemLinkRequiredLevel(resultLink),
			GetItemLinkRequiredVeteranRank(resultLink),
			GetItemLinkValue(resultLink),
			GetItemLinkItemStyle(resultLink),
			tostring(IsItemLinkVendorTrash(resultLink)),
			tostring(IsItemLinkUnique(resultLink)),
			tostring(IsItemLinkConsumable(resultLink)),
			tostring(IsItemLinkStackable(resultLink)),
		}, ";")
	end
	return qualityList
end

function ItemLinkWrapper:ExportEnchantmentList(callback)
	local data = table.concat({self.itemID, "0", self.level, "%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0"}, ":")
	local link = ITEM_LINK_FORMAT:format(LINK_STYLE_BRACKETS, data)
	local resultLink
	local enchantmentList = {}

	local start, count, throttle = 0, 70000, 1000
	local function DoGenerate()
		for i = start, start + throttle - 1 do
			resultLink = link:format(i)
			local hasCharges, enchantHeader = GetItemLinkEnchantInfo(resultLink)
			if(hasCharges) then
				enchantmentList[#enchantmentList + 1] = table.concat({
					i,
					enchantHeader
				}, ";")
			end
		end
		if(start >= count) then
			callback(enchantmentList)
		else
			start = start + throttle
			zo_callLater(DoGenerate, 10)
		end
	end
	DoGenerate()
end
