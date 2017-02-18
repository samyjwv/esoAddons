-- This file is part of CyrHUD
--
-- (C) 2016 Scott Yeskie (Sasky)
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

ZO_CreateStringId("SI_CYRHUD_LANG", "en")
ZO_CreateStringId("SI_CYRHUD_FONT", "$(CHAT_FONT)|18|soft-shadow-thick")
ZO_CreateStringId("SI_CYRHUD_APRIL1", "April Fools Fix")
ZO_CreateStringId("SI_CYRHUD_APRIL1_TOOLTIP", "Turn on to restore normal coloring")
ZO_CreateStringId("SI_CYRHUD_HIDE_IC", "Hide Imperial District Battles")
ZO_CreateStringId("SI_CYRHUD_HIDE_IC_INFO", "Hides Imperial District battles from CyrHUD notifications")
ZO_CreateStringId("SI_CYRHUD_QT_DEFAULT", "Auto-hide Default Quest Tracker")
ZO_CreateStringId("SI_CYRHUD_QT_TOOLTIP", "Hides quest trackers when CyrHUD is shown")
ZO_CreateStringId("SI_CYRHUD_QT_WYKKYD", "Auto-hide Ravalox Quest Tracker")
ZO_CreateStringId("SI_CYRHUD_POPBAR", "Population bars for flags")
ZO_CreateStringId("SI_CYRHUD_POPBAR_INFO", "Shows current population instead of alliance flag in summary")
ZO_CreateStringId("SI_BINDING_NAME_CYRHUD_TOGGLE", "Enable/disable CyrHUD")

local CZ = "|cC5C29E" -- ZOS standard text color
local CR = "|cFFFFFF" -- Reset color
ZO_CreateStringId("SI_CYRHUD_KEYBIND_HEADER", "Keybind")
ZO_CreateStringId("SI_CYRHUD_KEYBIND_DESC",
    CZ .. "See the controls game menu for setting a keybind for the" .. CR .. " /cyrhud" .. CZ .. " command.\n"
        .."This toggles the addon on or off.")


--Templates for using in code (reference):
--ZO_CreateStringId("SI_CYRHUD_", )
--GetString(SI_CYRHUD_...)
--zo_strformat(GetString(SI_CYRHUD_...), param1, param2))
