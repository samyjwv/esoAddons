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

CyrHUD = CyrHUD or {}
CyrHUD.ScoringBar = {}
CyrHUD.ScoringBar.type = "ScoringBar"
CyrHUD.ScoringBar.__index = CyrHUD.ScoringBar
setmetatable(CyrHUD.ScoringBar, {
    __call = function(cls, ...) return cls.new(...) end
})
local bar = CyrHUD.ScoringBar

local AD = ALLIANCE_ALDMERI_DOMINION
local DC = ALLIANCE_DAGGERFALL_COVENANT
local EP = ALLIANCE_EBONHEART_PACT

function CyrHUD.ScoringBar.new(campaign)
    local self = setmetatable({}, CyrHUD.ScoringBar)
    self.campaign = campaign or GetCurrentCampaignId()
    self:determineCampaignIndex()
    self:update()
    return self
end

function bar:determineCampaignIndex()
    --d("Calling findCampaignIndex for " .. self.campaign)
    self.campaignIndex = 0
    for i = 1, GetNumSelectionCampaigns() do
        local id = GetSelectionCampaignId(i)
        if self.campaign == id then
            --d("Result: " .. i)
            self.campaignIndex = i
        end
    end

    if self.campaignIndex == 0 then
        --d("No campaign index. Running QueryCampaignSelectionData()")
        QueryCampaignSelectionData()
        zo_callLater(function() self:determineCampaignIndex() end, 2000)
    end
end

local slowUpdate = 0
function bar:update()
    self.ad_points = GetCampaignAlliancePotentialScore(self.campaign, AD)
    self.dc_points = GetCampaignAlliancePotentialScore(self.campaign, DC)
    self.ep_points = GetCampaignAlliancePotentialScore(self.campaign, EP)

    if CyrHUD.cfg.showPopBars then
        self.ad_pop = GetSelectionCampaignPopulationData(self.campaignIndex, AD)
        self.dc_pop = GetSelectionCampaignPopulationData(self.campaignIndex, DC)
        self.ep_pop = GetSelectionCampaignPopulationData(self.campaignIndex, EP)

        -- Main update is every 5s
        -- Only refresh population bar data once every 3min
        slowUpdate = slowUpdate + 1
        if slowUpdate == 36 then
            QueryCampaignSelectionData()
            slowUpdate = 0
        end
    end
end

local TEXT_TIME = "txt4"
local ICON_DC, ICON_EP, ICON_AD = "img1", "img2", "img3"
local TEXT_DC, TEXT_EP, TEXT_AD = "txt1", "txt2", "txt3"
function bar:configureLabel(label)
    label:exposeControls(3,4)
    label.main:SetCenterColor(CyrHUD.info.invisColor:UnpackRGBA())
    label:getControl(ICON_DC):SetTexture(CyrHUD.info[DC].flag)
    label:getControl(ICON_EP):SetTexture(CyrHUD.info[EP].flag)
    label:getControl(ICON_AD):SetTexture(CyrHUD.info[AD].flag)
    label:positionControl(TEXT_TIME, 90, 40, 10, 10)
    label:positionControl(TEXT_DC, 50, 40, 100, 10)
    label:positionControl(TEXT_EP, 50, 40, 170, 10)
    label:positionControl(TEXT_AD, 50, 40, 240, 10)
    label:getControl(TEXT_DC):SetColor(CyrHUD.info[DC].color:UnpackRGBA())
    label:getControl(TEXT_EP):SetColor(CyrHUD.info[EP].color:UnpackRGBA())
    label:getControl(TEXT_AD):SetColor(CyrHUD.info[AD].color:UnpackRGBA())
    if CyrHUD.cfg.showPopBars then
        label:getControl(ICON_DC):SetColor(CyrHUD.info[DC].color:UnpackRGBA())
        label:getControl(ICON_EP):SetColor(CyrHUD.info[EP].color:UnpackRGBA())
        label:getControl(ICON_AD):SetColor(CyrHUD.info[AD].color:UnpackRGBA())
        label:positionControl(ICON_DC, 28, 28,  72, 7)
        label:positionControl(ICON_EP, 28, 28, 142, 7)
        label:positionControl(ICON_AD, 28, 28, 212, 7)
    else
        label:getControl(ICON_DC):SetColor(CyrHUD.info[ALLIANCE_NONE].color:UnpackRGBA())
        label:getControl(ICON_EP):SetColor(CyrHUD.info[ALLIANCE_NONE].color:UnpackRGBA())
        label:getControl(ICON_AD):SetColor(CyrHUD.info[ALLIANCE_NONE].color:UnpackRGBA())
        label:positionControl(ICON_DC, 20, 40,  80, 10)
        label:positionControl(ICON_EP, 20, 40, 150, 10)
        label:positionControl(ICON_AD, 20, 40, 220, 10)
    end
end

function bar:updateLabel(label)
    local pre = "+"
    local time = GetSecondsUntilCampaignScoreReevaluation(self.campaign)
    label:getControl(TEXT_TIME):SetText(CyrHUD.formatTime(time, true))
    label:getControl(TEXT_DC):SetText(pre .. self.dc_points)
    label:getControl(TEXT_EP):SetText(pre .. self.ep_points)
    label:getControl(TEXT_AD):SetText(pre .. self.ad_points)
    if CyrHUD.cfg.showPopBars then
        label:getControl(ICON_DC):SetTexture(ZO_CampaignBrowser_GetPopulationIcon(self.dc_pop))
        label:getControl(ICON_AD):SetTexture(ZO_CampaignBrowser_GetPopulationIcon(self.ad_pop))
        label:getControl(ICON_EP):SetTexture(ZO_CampaignBrowser_GetPopulationIcon(self.ep_pop))
    end
end
