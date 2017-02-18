BuffTimers 				= {}
BuffTimers.name 		= "BuffTimers"
BuffTimers.version 		= "1.31"
BuffTimers.author		= "coolmodi"

BuffTimers.sounds = {
	"none",
	"Emperor_Coronated_Aldmeri",
	"Emperor_Abdicated",
	"General_Alert_Error",
	"New_Notification",
	"Console_Game_Enter",	
	"Console_Character_Click",	
	"Achievement_Awarded",
	"Money_Transact",
	"Lockpicking_lockpick_broke",
	"Lockpicking_force",
	"Voice_Chat_Menu_Channel_Joined",
	"Voice_Chat_Menu_Channel_Left",
	"Voice_Chat_Menu_Channel_Made_Active",
	"Justice_NowKOS",
	"Justice_StateChanged",
    "Justice_NoLongerKOS",
    "Justice_PickpocketBonus",
    "Justice_PickpocketFailed",
}
BuffTimers.settingIcons 		= {}
BuffTimers.settingIconsTt 		= {}

BuffTimers.defaultBarData 		= {	--TODO: Need to change FillMissingBarDefaults() to work with profiles if this default ever changes
	offset 					= {["x"]=250, ["y"]=200},
	buffName 				= "",
	width					= 250,
	height					= 35,
	locked					= false,
	colorEdge				= {0,0,0,1},
	colorBg					= {0.2,0.2,0.2,0.4},
	colorBar				= {1,0,0,1,0,1,0,1},
	textSize				= 30,
	criticalTime			= 5,				
	soundToPlay				= "none",
	announcement			= false,
	showIcon				= true,
	iconSize				= 35,
	alwaysShow				= false,
	iconTexture				= "BuffTimers/res/doge.dds",
	notiText				= "",
	customIcon				= false,
	customIconTex			= "",
}



--test for ability collection
--BuffTimers.testarr = {
	--[999999] = {"name",99}
--}
--BuffTimers.testarr2 = {
	--[1] = "name D:99 ID:999999"
--}
--BuffTimers.testarr3 = {
	--["name D:99 ID:999999"] = id
--}

-- function BuffTimers:CreateEffectList()
	-- self.testarr2 = nil
	-- self.testarr2 = {}
	-- self.testarr3 = nil
	-- self.testarr3 = {}
	-- for id, info in pairs(self.testarr) do
		-- local nameUse = info[1].." D:"..info[2].." ID:"..id
		-- self.testarr3[nameUse] = id
		-- table.insert(self.testarr2, nameUse)	
	-- end
	-- --sort here
-- end

--NEW1.31 custom filters WIP
BuffTimers.filterList = {}
function BuffTimers:CreateFilterLists()
	self.filterList = nil
	self.filterList = {}
	for name, isALso in pairs(self.savedvars.customFilterXalsoY) do
		table.insert(self.filterList, name.." = "..isALso)
	end
end


local defaults 					= {
	needsCheckForNewFormat		= true, --check once for old save data and convert to new system on first startup with new version
	updateSpeed					= 100,
	activeProfile				= 1,
	profiles					= {
		["names"] 				= {
			[1] 				= "default",
		},
		["profileData"] 		= {
			[1] = {			
				numberBars 		= 1,	
				barData 		= {},
				buffNames 		= {},
				announcePos		= {["x"]=0, ["y"]=0},
				announceDur		= 1.5,
				announceColor 	= {0.9,0.1,0.1,1},			
			},
		},
	},
	
	customFilterXalsoY = {
		--["name"] = "name" 	--if ["name"] then start timer for "name"
	},
	
}


BuffTimers.unlockAnn 		= false
BuffTimers.debugOutput 		= false
BuffTimers.regForUpdate 	= {}
BuffTimers.soundPlayed 		= {}
BuffTimers.announceLock		= {}

function BuffTimers.OnAddOnLoaded(event, addonName)
	if addonName ~= BuffTimers.name then return end	
	EVENT_MANAGER:UnregisterForEvent(BuffTimers.name, EVENT_ADD_ON_LOADED)
	BuffTimers:Initialize()	
end
function BuffTimers:Initialize()
	self:RestoreData() 
	self:SetupAddonMenu()
	self:InitializeControls()
	
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_EFFECT_CHANGED, self.OnEffectEvent)
	EVENT_MANAGER:RegisterForUpdate(self.name, self.savedvars.updateSpeed, function(gameTimeMs) BuffTimers.updateHandler() end)
end
function BuffTimers:RestoreData()
	self.savedvars = ZO_SavedVars:New("BuffTimersSavedVariables", 1, nil, defaults)	
	self.svars = self.savedvars.profiles.profileData[self.savedvars.activeProfile]
	
	if self.savedvars.needsCheckForNewFormat then
		if self.savedvars.numberBars ~= nil then
			self:ConvertToNewProfileFormat()			
		end
		self.savedvars.needsCheckForNewFormat = false
	end	
	
	--NEW1.31 temporary(haha) shitty stuff
	self:CreateFilterLists()
	
	BuffTimers:FillMissingBarDefaults()
end
function BuffTimers:FillMissingBarDefaults()
	for i=1, self.svars.numberBars do
		if self.svars.barData[i] == nil then self.svars.barData[i] = {} end
		for k,v in pairs(self.defaultBarData) do
			if self.svars.barData[i][k] == nil then self.svars.barData[i][k] = v end
		end
	end
end

local function slashHandler(inputString)
	local GD = GroupDamage
	local input = {string.match(inputString,"^(%S*)%s*(.-)$")}
	local inputs = {}
	for k,v in pairs(input) do
		if v ~= nil and v ~= "" then
			table.insert(inputs, string.lower(v)) 
		end
	end
	
	if inputs[1] == "db" or inputs[1] == "d" then 
		BuffTimers.debugOutput = not BuffTimers.debugOutput
		d("Debug output = "..tostring(BuffTimers.debugOutput))
	
	elseif inputs[1] == "p" then
		if inputs[2] ~= nil and BuffTimers.savedvars.profiles.names[tonumber(inputs[2])] ~= nil then
			BuffTimers:LoadProfile(BuffTimers.savedvars.profiles.names[tonumber(inputs[2])])
			return
		end
		for i=1, #BuffTimers.savedvars.profiles.names do
			if BuffTimers.savedvars.activeProfile == i then
				d(i..": "..BuffTimers.savedvars.profiles.names[i].." (ACTIVE)")
			else
				d(i..": "..BuffTimers.savedvars.profiles.names[i])
			end
			
		end
		
	elseif inputs[1] == "s" then		
		BuffTimers.LAM:OpenToPanel(BuffTimersPanel)
			
	else
		for k,pName in pairs(BuffTimers.savedvars.profiles.names) do
			if inputs[1] == pName then BuffTimers:LoadProfile(inputs[1]) return end
		end
		
		local function COONE(text) return ZO_ColorDef:New("00FFFF"):Colorize(text) end
		local function COTWO(text) return ZO_ColorDef:New("00FF00"):Colorize(text) end
		local function COTRE(text) return ZO_ColorDef:New("FF8800"):Colorize(text) end		
		d(COONE("BuffTimers chat commands."))
		d(COTWO("/buti s").. " Open settings panel.")
		d(COTWO("/buti p")..COTRE(" number").." Load profile by number, use without a number to list profiles.")
		d(COTWO("/buti ")..COTRE("profilename").." Load profile by name.")
		d(COTWO("/buti d").." Toggle debug mode.")
	end
end
SLASH_COMMANDS["/buti"] = slashHandler

EVENT_MANAGER:RegisterForEvent(BuffTimers.name, EVENT_ADD_ON_LOADED, BuffTimers.OnAddOnLoaded)