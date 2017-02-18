-- Taos AP Session french localization file

-- Options
local strings = {
    TAS_OPTIONS_HEADER =                "Options",
    TAS_OPTIONS_DRAG_LABEL =            "Déplacement fenêtre",
    TAS_OPTIONS_DRAG_TOOLTIP =          "Activée vous pouvez déplacer la fenêtre.",
    TAS_OPTIONS_LONG_STYLE_LABEL =      "Style en longueur",
    TAS_OPTIONS_LONG_STYLE_TOOLTIP =    "Activée, la fenêtre est affichée en longueur."
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end