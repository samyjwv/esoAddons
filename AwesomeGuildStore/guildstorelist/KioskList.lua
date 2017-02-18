local KioskData = AwesomeGuildStore.KioskData

local KioskList = ZO_Object:Subclass()
AwesomeGuildStore.KioskList = KioskList

function KioskList:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function KioskList:Initialize(saveData)
    self.saveData = saveData
    self.kiosk = {}
    for kioskName, serializedData in pairs(saveData) do
        local kiosk = KioskData:New()
        kiosk.name = kioskName
        kiosk:Deserialize(serializedData)
        self.kiosk[kioskName] = kiosk
    end
end

function KioskList:HasKiosk(kioskName)
    return self.kiosk[kioskName] ~= nil
end

function KioskList:GetKiosk(kioskName)
    return self.kiosk[kioskName]
end

function KioskList:GetAllKiosks()
    return self.kiosk
end

function KioskList:SetKiosk(kiosk)
    self.kiosk[kiosk.name] = kiosk
    self.saveData[kiosk.name] = kiosk:Serialize()
end