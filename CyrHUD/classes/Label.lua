-- This file is part of CyrHUD
--
-- (C) 2015 Scott Yeskie (Sasky)
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

-- Setup class
CyrHUD = CyrHUD or {}

CyrHUD.Label = {}
CyrHUD.Label.__index = CyrHUD.Label
setmetatable(CyrHUD.Label, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

local Label = CyrHUD.Label

function Label.new()
    local self = setmetatable({}, CyrHUD.Label)
    self.labelType = "uninit"
    self.num = (Label.entryCount or 0) + 1
    self.entryName = "CyrHUDEntry" .. self.num
    Label.entryCount = self.num
    self.entry = {}
    local entry = self.entry

    --Main control/backdrop
    local yoff = self.num*35-5
    self.main = WINDOW_MANAGER:CreateControl(self.entryName .. "main", CyrHUD_UI, CT_BACKDROP)
    self.main:SetDimensions(280, 35)
    self.main:SetAnchor(TOPLEFT, CyrHUD_UI, TOPLEFT, 0, yoff)
    self.main:SetCenterColor(CyrHUD.info.defaultBGColor:UnpackRGBA())
    self.main:SetEdgeColor(CyrHUD.info.invisColor:UnpackRGBA())

    -- Images
    entry.img1 = WINDOW_MANAGER:CreateControl(self.entryName .. "img1", self.main, CT_TEXTURE)
    entry.img2 = WINDOW_MANAGER:CreateControl(self.entryName .. "img2", self.main, CT_TEXTURE)
    entry.img3 = WINDOW_MANAGER:CreateControl(self.entryName .. "img3", self.main, CT_TEXTURE)

    --Labels
    entry.txt1 = WINDOW_MANAGER:CreateControl(self.entryName .. "txt1", self.main, CT_LABEL)
    entry.txt2 = WINDOW_MANAGER:CreateControl(self.entryName .. "txt2", self.main, CT_LABEL)
    entry.txt3 = WINDOW_MANAGER:CreateControl(self.entryName .. "txt3", self.main, CT_LABEL)
    entry.txt4 = WINDOW_MANAGER:CreateControl(self.entryName .. "txt4", self.main, CT_LABEL)

    entry.txt1:SetFont(CyrHUD.info.fontMain)
    entry.txt2:SetFont(CyrHUD.info.fontMain)
    entry.txt3:SetFont(CyrHUD.info.fontMain)
    entry.txt4:SetFont(CyrHUD.info.fontMain)
    return self
end

function Label:hide()
    self.main:SetHidden(true)
end

function Label:show()
    self.main:SetHidden(false)
end

function Label:getControl(name)
    return self.entry[name]
end

function Label:moveControl(name, x, y)
    if self.entry[name] then
        self.entry[name]:ClearAnchors()
        self.entry[name]:SetAnchor(TOPLEFT, self.entry.main, TOPLEFT, x, y)
    end
end

function Label:resizeControl(name, width, height)
    if self.entry[name] then
        self.entry[name]:SetDimensions(width, height)
    end
end

function Label:positionControl(name, width, height, x, y)
    if self.entry[name] then
        self.entry[name]:ClearAnchors()
        self.entry[name]:SetAnchor(TOPLEFT, self.entry.main, TOPLEFT, x, y)
        self.entry[name]:SetDimensions(width, height)
    end
end

function Label:exposeControls(nImg, nText)
    for i=1,3 do
        self.entry["img"..i]:SetHidden(i > nImg)
    end
    for i=1,3 do
        self.entry["txt"..i]:SetHidden(i > nText)
    end
end

function Label:update(model)
    if self.type ~= model.type then
        --TODO: Handle some form of reset
        model:configureLabel(self)
        self.type = model.type
        self:show()
    end
    model:updateLabel(self)
end
