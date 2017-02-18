-- Taos AP Session english localization file

-- Options
local strings = {
    TAS_OPTIONS_HEADER =                "Options",
    TAS_OPTIONS_DRAG_LABEL =            "Drag window",
    TAS_OPTIONS_DRAG_TOOLTIP =          "If activated, you can drag the window.",
    TAS_OPTIONS_LONG_STYLE_LABEL =      "Long style",
    TAS_OPTIONS_LONG_STYLE_TOOLTIP =    "If activated, the window is shown in long style."
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end