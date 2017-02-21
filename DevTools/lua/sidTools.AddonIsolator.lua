local AddOnManager = GetAddOnManager()
local AddonIsolator = ZO_Object:Subclass()
sidTools.AddonIsolator = AddonIsolator

function AddonIsolator:New(...)
	local obj = ZO_Object.New(self)
	obj:Initialize(...)
	return obj
end

local function FindAddonIndexByName(addonName)
	for index = 1, AddOnManager:GetNumAddOns() do
		local name = AddOnManager:GetAddOnInfo(index)
		if(addonName == name) then return index end
	end
end

local function GetEnabledAddons()
	local enabledAddons = {}
	for index = 1, AddOnManager:GetNumAddOns() do
		local name, _, _, _, enabled = AddOnManager:GetAddOnInfo(index)
		if(enabled) then
			enabledAddons[name] = enabled
		end
	end
	return enabledAddons
end

local function DisableAllAddons()
	local enabledAddons = {}
	for index = 1, AddOnManager:GetNumAddOns() do
		AddOnManager:SetAddOnEnabled(index, false)
	end
end

local function ActivateAddonAndDependencies(addonIndex)
	AddOnManager:SetAddOnEnabled(addonIndex, true)
	for index = 1, AddOnManager:GetAddOnNumDependencies(addonIndex) do
		local name = AddOnManager:GetAddOnDependencyInfo(addonIndex, index)
		AddOnManager:SetAddOnEnabled(FindAddonIndexByName(name), true)
	end
end

function AddonIsolator:Initialize(saveData, addonName)
	self.saveData = saveData
	self.ownIndex = FindAddonIndexByName(addonName)
end

function AddonIsolator:IsolateAddon(addonName)
	local addonIndex = FindAddonIndexByName(addonName)
	if(addonIndex == nil) then
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR, "addon '" .. addonName .. "' not found")
		return
	end

	local saveData = self.saveData
	if(not saveData.isolationActive) then
		-- save our active addons
		saveData.enabledAddons = GetEnabledAddons()
	end

	DisableAllAddons()
	ActivateAddonAndDependencies(self.ownIndex)
	ActivateAddonAndDependencies(addonIndex)
	saveData.isolationActive = true

	ReloadUI()
end

function AddonIsolator:RestoreAddons()
	local saveData = self.saveData
	if(not saveData.isolationActive) then
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR, "addon isolation not active")
		return
	end

	local enabledAddons = saveData.enabledAddons
	for index = 1, AddOnManager:GetNumAddOns() do
		local name = AddOnManager:GetAddOnInfo(index)
		AddOnManager:SetAddOnEnabled(index, enabledAddons[name] or false)
	end

	saveData.isolationActive = false

	ReloadUI()
end

function AddonIsolator:GetInstalledAddonNames()
    local addons = {}
    for index = 1, AddOnManager:GetNumAddOns() do
        local name = AddOnManager:GetAddOnInfo(index)
        addons[#addons + 1] = name
    end
    return addons
end
