local TK = ThiefsKnapsackExtended

local function onPlayerActivated()
   EVENT_MANAGER:UnregisterForEvent(TK.name, EVENT_PLAYER_ACTIVATED)
   TK:BuildUI()
end

local function onLoaded(ev, addon)
   if(addon ~= TK.name) then return end

   EVENT_MANAGER:UnregisterForEvent(TK.name, EVENT_ADD_ON_LOADED)
   TK.saved = ZO_SavedVars:New("ThiefsKnapsackVars", 1, nil, TK.defaults)
   if TK.saved.show.chatMessage == true then
		d(GetString(SI_TK_NAME).." "..GetString(SI_TK_INITIALIZE))
   end

   TK:RegisterSettings()
end

EVENT_MANAGER:RegisterForEvent(TK.name, EVENT_ADD_ON_LOADED, onLoaded)
EVENT_MANAGER:RegisterForEvent(TK.name, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
SLASH_COMMANDS["/tk"] = tkToggle
SLASH_COMMANDS["/tklock"] = lockWindow
SLASH_COMMANDS["/tkm"] = hideMeter
