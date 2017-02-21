local function BuildEventDictonary()
    local lookupTable = {}
    local eventPrefix = "EVENT_"
    for varname, value in zo_insecurePairs(_G) do
        if(type(value) == "number" and string.sub(varname, 1, #eventPrefix) == eventPrefix) then
            lookupTable[value] = varname
        end
    end
    return lookupTable
end

local function CreateMessageWindow(name, title, parent, x, y, width, height)
    local LIBMW = LibStub:GetLibrary("LibMsgWin-1.0")
    local window = LIBMW:CreateMsgWindow(name, title)
    window:ClearAnchors()
    if(parent) then
        window:SetAnchor(TOPLEFT, parent, TOPRIGHT, x, y)
    else
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    end
    window:SetDimensions(width, height)

    window.buffer = _G[name .. "Buffer"]
    window.slider = _G[name .. "Slider"]
    window.label = _G[name .. "Label"]

    window.SetLabel = function(self, text)
        self.label:SetText(text)
    end

    window.ScrollToTop = function(self)
        local buffer, slider = self.buffer, self.slider
        local visible = buffer:GetNumVisibleLines()
        buffer:SetScrollPosition(buffer:GetNumHistoryLines() - visible)
        slider:SetValue(0)
    end

    return window
end

local function Initialize(saveData)
    local EVENT_LINK_TYPE = "sidToolsEvent"
    local OUTPUT_FORMAT = ("|H0:%s:%%d|h%%s - %%d|h"):format(EVENT_LINK_TYPE)

    local eventNameById = BuildEventDictonary() -- TODO: check out "EVENT_NAME_LOOKUP[eventName] or eventName"
    local eventDataList = {}
    local selectedEventId = EVENT_ADD_ON_LOADED
    local hasChanged = true

    local eventWindow = CreateMessageWindow("sidToolsEventView", "Event Viewer", nil, 200, 150, 600, 550)
    local detailWindow = CreateMessageWindow("sidToolsEventDetails", "Event Details", eventWindow, 4, 0, 600, 550)

    local function GetEventData(eventId)
        if(not eventDataList[eventId]) then
            eventDataList[eventId] = {
                count = 0,
                argCount = {}
            }
        end
        return eventDataList[eventId]
    end

    local tmp_args = {}
    local tconcat, strformat = table.concat, string.format
    local function arglist(...)
        local n = select("#", ...)
        for i = 1, n do
            local a = select(i, ...)
            if type(a) == "string" then
                tmp_args[i] = strformat("%q", a)
            else
                tmp_args[i] = tostring(a)
            end
        end
        return tconcat(tmp_args, ", ", 1, n)
    end

    local function HandleEvents(eventId, ...)
        local eventData = GetEventData(eventId)
        local key = arglist(...)
        eventData.count = eventData.count + 1
        eventData.argCount[key] = (eventData.argCount[key] or 0) + 1
        hasChanged = true
    end

    local function UpdateEventDetails(eventId)
        local eventData = GetEventData(eventId)
        detailWindow:ClearText()

        detailWindow:SetLabel(("Event Details - %s (%d)"):format(eventNameById[eventId], eventData.count))

        local eventDataOutput = {}
        for key, count in pairs(eventData.argCount) do
            eventDataOutput[#eventDataOutput + 1] = {
                key = key,
                count = count,
                text = string.format("%d: %s", count, key)
            }
        end

        table.sort(eventDataOutput, function(a, b)
            if (a.count == b.count) then
                return a.key < b.key
            else
                return a.count > b.count
            end
        end)

        for i = 1, math.min(200, #eventDataOutput) do
            detailWindow:AddText(eventDataOutput[i].text, 1, 1, 1)
        end

        detailWindow:ScrollToTop()
    end

    local function OnUpdate()
        if(not hasChanged) then return end
        eventWindow:ClearText()

        local eventDataOutput = {}
        for eventId, eventData in pairs(eventDataList) do
            eventDataOutput[#eventDataOutput + 1] = {
                eventId = eventId,
                count = eventData.count,
                text = OUTPUT_FORMAT:format(eventId, eventNameById[eventId], eventData.count)
            }
        end

        table.sort(eventDataOutput, function(a, b)
            if (a.count == b.count) then
                return a.eventId < b.eventId
            else
                return a.count > b.count
            end
        end)

        for i = 1, math.min(200, #eventDataOutput) do
            eventWindow:AddText(eventDataOutput[i].text, 1, 1, 1)
        end

        eventWindow:ScrollToTop()

        UpdateEventDetails(selectedEventId)
    end

    local function HandleLinkClicked(link, button)
        if type(link) == "string" and #link > 0 then
            local text, color, linkType, eventId = ZO_LinkHandler_ParseLink(link)
            if linkType == EVENT_LINK_TYPE then
                selectedEventId = tonumber(eventId)
                UpdateEventDetails(selectedEventId)
                return true
            end
        end
    end

    ZO_PreHook("ZO_LinkHandler_OnLinkClicked", HandleLinkClicked)
    ZO_PreHook("ZO_LinkHandler_OnLinkMouseUp", HandleLinkClicked)

    local running = true
    EVENT_MANAGER:RegisterForAllEvents("sidToolsEventViewer", function(...) if(running) then HandleEvents(...) end end)
    EVENT_MANAGER:RegisterForUpdate("sidToolsEventViewerUpdate", 1000, OnUpdate)

    local eventsCmd = sidTools.eventsCmd

    local clearCmd = eventsCmd:RegisterSubCommand()
    clearCmd:AddAlias("clear")
    clearCmd:SetCallback(function()
        eventDataList = {}
        OnUpdate()
    end)
    clearCmd:SetDescription("Clears the displayed events")

    local showCmd = eventsCmd:RegisterSubCommand()
    showCmd:AddAlias("show")
    showCmd:SetCallback(function()
        eventWindow:SetHidden(false)
        detailWindow:SetHidden(false)
    end)
    showCmd:SetDescription("Show the event viewer window")

    local hideCmd = eventsCmd:RegisterSubCommand()
    hideCmd:AddAlias("hide")
    hideCmd:SetCallback(function()
        eventWindow:SetHidden(true)
        detailWindow:SetHidden(true)
    end)
    hideCmd:SetDescription("Hide the event viewer window")

    local stopCmd = eventsCmd:RegisterSubCommand()
    stopCmd:AddAlias("stop")
    stopCmd:SetCallback(function()
        if(running) then
            EVENT_MANAGER:UnregisterForUpdate("sidToolsEventViewerUpdate")
            running = false
        end
    end)
    stopCmd:SetDescription("Stop listening to events")

    local startCmd = eventsCmd:RegisterSubCommand()
    startCmd:AddAlias("start")
    startCmd:SetCallback(function()
        if(not running) then
            EVENT_MANAGER:RegisterForUpdate("sidToolsEventViewerUpdate", 1000, OnUpdate)
            running = true
        end
    end)
    startCmd:SetDescription("Start listening to events")

    local function ToggleEventViewer()
        if(eventWindow:IsHidden()) then
            startCmd()
            showCmd()
        else
            hideCmd()
            stopCmd()
        end
    end
    sidTools.ToggleEventViewer = ToggleEventViewer

    eventsCmd:SetCallback(ToggleEventViewer)
end

sidTools.InitializeEventViewer = Initialize
