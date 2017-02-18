-- Taos AP Session german localization file

-- Options
local strings = {
    TAS_OPTIONS_HEADER =                "Optionen",
    TAS_OPTIONS_DRAG_LABEL =            "Fenster verschieben",
    TAS_OPTIONS_DRAG_TOOLTIP =          "Wenn aktiv, kann das AP Session Fenster verschoben werden.",
    TAS_OPTIONS_LONG_STYLE_LABEL =      "Langer Stil",
    TAS_OPTIONS_LONG_STYLE_TOOLTIP =    "Wenn aktiv, wird das AP Session Fenster im langen Stil angezeigt."
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end