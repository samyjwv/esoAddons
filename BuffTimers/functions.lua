function BuffTimers.updateHandler()
	for k,v in pairs(BuffTimers.regForUpdate) do		
		BuffTimers:UpdateBar(k, v)
	end
	BuffTimers:announceMgr()
end

local dontFuckUpBuffer = {} 	--prevent from falsely removing things that just got refreshed but the fade event comes after the gained event for some reason
local dontFuckUpTimeFrame = 100	--time window after gained to ignore faded for same spell

local filteredIds = { --effect IDs that need to be ignored
	[26298] = true, --cleasing ritual (which is called healing ritual in the API...) heal effect that is actually a buff without duration, yeah, wtf
	[64160] = true, --crystal fragments proc buff#2 whatever it even is for
	
	[66959] = true, --player vibration fx
	
}
local filteredIdsFade = {--effect IDs that need to be ignored if they fire a fade event
	[27090] = true, --Spear Shards cast/fly part, would cancel real ground aoe part
	[27167] = true, --Blazing Spear ^
	
}
local hookedTracking = { --for agressive horn's major force(<- doesn't appear in api)
	["AGGRESSIVE HORN"] = { --spell to listen for
		["dur"] = 30, --for weapon swap reapplying buff the buff...
		["hooked"] = "MAJOR FORCE", --timer to start
		["ranks"] = { --durations
			[40223] = 8,	--R1
			[46531]	= 8.5,--R2
			[46534]	= 9, 	--R3
			[46537]	= 9.5,--R4		
		},
	},
	["AGGRESSIVES SIGNAL"] = { --spell to listen for
		["dur"] = 30, --for weapon swap reapplying buff the buff...
		["hooked"] = "GRÖSSERE KRAFT", --to track spell
		["ranks"] = { --durations
			[40223] = 8,	--R1
			[46531]	= 8.5,--R2
			[46534]	= 9, 	--R3
			[46537]	= 9.5,--R4		
		},
	},
	["COR AGRESSIF"] = { --spell to listen for
		["dur"] = 30, --for weapon swap reapplying buff the buff...
		["hooked"] = "FORCE MAJEURE", --timer to start
		["ranks"] = { --durations
			[40223] = 8,	--R1
			[46531]	= 8.5,--R2
			[46534]	= 9, 	--R3
			[46537]	= 9.5,--R4		
		},
	},
	
}

--NEW1.31
BuffTimers.notifications = {
	--[1] = {"notification", endSeconds}
}
function BuffTimers:announceMgr()
	if #self.notifications == 0 or self.unlockAnn then return end
	--d("announceMgr notifications ~= 0")
	
	if self.notifications[1][2] < GetFrameTimeSeconds() then 
		table.remove(self.notifications, 1)
		--d("removed notification: announce time ran out")
	end
	
	if #self.notifications == 0 and not self.unlockAnn then 
		--d("0 notifactions, not unlocked, hide label and return")
		self.announce:SetHidden(true) 
		return 
	else 
		--d("not 0 notifactions, show label")
		self.announce:SetHidden(false) 
	end
	
	local notiText = self.notifications[1][1]
	--d("notiText="..notiText)
	for i=2, #self.notifications do
		--d("more than 1 notification, extend text")
		notiText = notiText .. "\n"..self.notifications[i][1]
	end
	--d("final text="..notiText)
	self.announce.label:SetText(notiText)
end

function BuffTimers.OnEffectEvent(_, changeType, _, effectName, unitTag, beginTime, endTime, _, iconName, _, _, _, _, unitName, _, abilityId)	
	if unitTag ~= "player" and unitName ~= "Offline" then return end
	if filteredIds[abilityId] or (filteredIdsFade[abilityId] and changeType==2) then return end
	
	--if BuffTimers.testarr[abilityId] == nil then BuffTimers.testarr[abilityId] = {effectName, endTime-beginTime} end
	
	effectName = zo_strformat("<<Z:1>>", effectName)
	
	if BuffTimers.debugOutput then 
		local function COONE(text) return ZO_ColorDef:New("00FF88"):Colorize(text) end
		local function COTWO(text) return ZO_ColorDef:New("00FF00"):Colorize(text) end
		if changeType == 1 then
			d(COONE("Gained: ")..effectName .. COTWO(" DUR:")..endTime-beginTime .. COTWO(" ID:")..abilityId .. COTWO(" T:")..unitName..COTWO(" : ")..unitTag) 
		elseif changeType == 2 then
			d(COONE("Faded: ")..effectName .. COTWO(" ID:")..abilityId .. COTWO(" T:")..unitName..COTWO(" : ")..unitTag) 
		else
			d(COONE("Refreshed("..changeType.."): ")..effectName .. COTWO(" DUR:")..endTime-beginTime .. COTWO(" ID:")..abilityId .. COTWO(" T:")..unitName..COTWO(" : ")..unitTag)
		end		
	end
	
	--custom XalsoY filter shitty implementation (most here is shitty...) :)
	if BuffTimers.savedvars.customFilterXalsoY[effectName] ~= nil then
		--pls just work
		BuffTimers.OnEffectEvent(_, changeType, _, BuffTimers.savedvars.customFilterXalsoY[effectName], unitTag, beginTime, endTime, _, iconName, _, _, _, _, unitName, _, abilityId)
	end
	
	--special handler for agressive horn's major force buff
	if hookedTracking[effectName] ~= nil and (changeType == 1 or changeType == 3) and BuffTimers.svars.buffNames[hookedTracking[effectName]["hooked"]] ~= nil and BuffTimers.svars.buffNames[hookedTracking[effectName]["hooked"]] <= BuffTimers.svars.numberBars and endTime-GetFrameTimeSeconds() >= hookedTracking[effectName]["dur"]-0.1 then
		local barNumber = BuffTimers.svars.buffNames[hookedTracking[effectName]["hooked"]]
		BuffTimers.bar[barNumber]:SetHidden(false)
		BuffTimers.bar[barNumber].bar:SetMinMax(0, hookedTracking[effectName]["ranks"][abilityId])
		if BuffTimers.svars.barData[barNumber].customIcon then 
			BuffTimers.bar[barNumber].icon:SetTexture(BuffTimers.svars.barData[barNumber].customIconTex)
		else
			BuffTimers.bar[barNumber].icon:SetTexture(iconName) 
		end
		BuffTimers.svars.barData[barNumber].iconTexture = iconName
		BuffTimers.soundPlayed[barNumber] = false
		BuffTimers.regForUpdate[barNumber] = GetFrameTimeSeconds()+hookedTracking[effectName]["ranks"][abilityId]
		BuffTimers:UpdateBar(barNumber, GetFrameTimeSeconds()+hookedTracking[effectName]["ranks"][abilityId])	
	end
	
	--check if spell is tracked and on an active bar
	if BuffTimers.svars.buffNames[effectName] == nil or BuffTimers.svars.buffNames[effectName] > BuffTimers.svars.numberBars then return end
		
	local barNumber = BuffTimers.svars.buffNames[effectName]
	
	--unregister on buff faded
	if changeType == 2 and BuffTimers.regForUpdate[BuffTimers.svars.buffNames[effectName]] ~= nil and dontFuckUpBuffer[effectName] < GetFrameTimeMilliseconds()-dontFuckUpTimeFrame then 
		BuffTimers.regForUpdate[barNumber] = endTime
		return 
	end
	
	--register buff gained/refreshed/updated if it has duration
	if endTime-beginTime <= 0 then return end
	BuffTimers.announceLock[barNumber] = nil
	dontFuckUpBuffer[effectName] = GetFrameTimeMilliseconds()
	BuffTimers.bar[barNumber]:SetHidden(false)
	BuffTimers.bar[barNumber].bar:SetMinMax(0, endTime-beginTime)
	if BuffTimers.svars.barData[barNumber].customIcon then 
		BuffTimers.bar[barNumber].icon:SetTexture(BuffTimers.svars.barData[barNumber].customIconTex)
	else
		BuffTimers.bar[barNumber].icon:SetTexture(iconName) 
	end
	BuffTimers.svars.barData[barNumber].iconTexture = iconName
	BuffTimers.soundPlayed[barNumber] = false
	BuffTimers.regForUpdate[barNumber] = endTime
	BuffTimers:UpdateBar(barNumber, endTime)
end

function BuffTimers:UpdateBar(bar, endTime)
	if (endTime-GetFrameTimeSeconds()) < self.svars.barData[bar].criticalTime then 
		self.bar[bar].label:SetColor(1,0,0,1) 
		if not self.soundPlayed[bar] then PlaySound(self.svars.barData[bar].soundToPlay) self.soundPlayed[bar]=true end	
		if self.svars.barData[bar].announcement and not self.announceLock[bar] then 
			--d("insert notifictaion into tabnle for "..self.svars.barData[bar].buffName)
			if self.svars.barData[bar].notiText ~= "" then
				table.insert(self.notifications, {self.svars.barData[bar].notiText, GetFrameTimeSeconds()+self.svars.announceDur})
			else
				table.insert(self.notifications, {self.svars.barData[bar].buffName, GetFrameTimeSeconds()+self.svars.announceDur})				
			end
			--d(notifications)
			self.announceLock[bar] = true
		end	
	else 
		self.bar[bar].label:SetColor(1,1,1,1) 
	end
	if endTime < GetFrameTimeSeconds() then 
		self.bar[bar]:SetHidden(not self.svars.barData[bar].alwaysShow and self.svars.barData[bar].locked)
		self.bar[bar].label:SetText("")
		if self.svars.barData[bar].locked then self.bar[bar].bar:SetValue(0) else self.bar[bar].bar:SetValue(9999) end
		self.regForUpdate[bar] = nil
		return 
	end	
	self.bar[bar].bar:SetValue(endTime-GetFrameTimeSeconds())
	self.bar[bar].label:SetText(("%03.01f"):format(endTime-GetFrameTimeSeconds()))
end

------------------------
--PROFILE FUNCTIONS
------------------------
function BuffTimers:ConvertToNewProfileFormat()
	self.svars.numberBars 		= self.savedvars.numberBars					
	self.svars.announceDur 		= self.savedvars.announceDur
	self.svars.announcePos 		= nil
	self.svars.announcePos 		= {}
	self.svars.announcePos["x"] = self.savedvars.announcePos["x"]
	self.svars.announcePos["y"] = self.savedvars.announcePos["y"]
	self.svars.announceColor 	= nil
	self.svars.announceColor 	= {}
	for k,v in pairs(self.savedvars.announceColor) do
		self.svars.announceColor[k] = v
	end
	
	self.savedvars.numberBars	= nil					
	self.savedvars.announceDur  = nil
	self.savedvars.announcePos 	= nil
	self.savedvars.announceColor= nil
	
	for name, barId in pairs(self.savedvars.buffNames) do
		self.svars.buffNames[name] = barId
	end
	self.savedvars.buffNames = nil
	
	for barId, data in pairs(self.savedvars.barData) do
		self.svars.barData[barId] = {}
		for key, value in pairs(data) do
			if value == type("table") then
				self.svars.barData[barId][key] = {}
				for k,v in pairs(value) do
					self.svars.barData[barId][key][k] = v
				end
			else
				self.svars.barData[barId][key] = value
			end			
		end
	end
	self.savedvars.barData = nil
end

function BuffTimers:LoadProfile(profileName)	
	local profId = -1
	for key, profName in pairs(self.savedvars.profiles.names) do
		if profName == profileName then profId = key end
	end	
	if profId == -1 then return end
	if profId == self.savedvars.activeProfile then d("Profile already active!") return end
	local oldNumberBars = self.svars.numberBars
	self.savedvars.activeProfile = profId
	self.svars = self.savedvars.profiles.profileData[self.savedvars.activeProfile]
	d("Loaded profile: "..profileName.." (ID:"..profId..")")
	if self.svars.numberBars > oldNumberBars then ReloadUI() end
	if self.svars.numberBars < oldNumberBars then 
		for i=self.svars.numberBars+1, oldNumberBars do
			if self.svars.barData[i] == nil then self.svars.barData[i] = {} end
			for k,v in pairs(self.defaultBarData) do
				if self.svars.barData[i][k] == nil then self.svars.barData[i][k] = v end
			end
			self.svars.barData[i].locked = true
		end
		self.svars.numberBars = oldNumberBars
		d("Profile has less bars then the previous, set to same number and filled additional active bars with default settings and locked them!")
	end
	self:SetControlSettings(oldNumberBars)
end

function BuffTimers:DeleteProfile(chosenProfile)
	local profId = -1
	for key, profName in pairs(self.savedvars.profiles.names) do
		if profName == chosenProfile then profId = key end
	end	

	if profId == self.savedvars.activeProfile then return end
 	
	table.remove(self.savedvars.profiles.names, profId)
	table.remove(self.savedvars.profiles.profileData, profId)
	
	if self.savedvars.activeProfile > profId then 
		self.savedvars.activeProfile = self.savedvars.activeProfile-1
		self.svars = self.savedvars.profiles.profileData[self.savedvars.activeProfile]
	end
end

function BuffTimers:RenameProfile(profileName, newName)
	for k, name in pairs(self.savedvars.profiles.names) do
		if name == profileName then self.savedvars.profiles.names[k] = newName end
	end
end

function BuffTimers:CreateProfile(name, templateProfile)
	if name == "" then return end
	table.insert(self.savedvars.profiles.names, name)
	if templateProfile == "Current profile" then templateProfile = self.savedvars.profiles.names[self.savedvars.activeProfile] end
	local newProfId = -1
	local templateId = -1
	for key, profName in pairs(self.savedvars.profiles.names) do
		if profName == name then newProfId = key end
		if profName == templateProfile then templateId = key end
	end	
	self.savedvars.profiles.profileData[newProfId] = {}	
	self:CopySettings(self.savedvars.profiles.profileData[newProfId], self.savedvars.profiles.profileData[templateId])
end
function BuffTimers:CopySettings(dest, source)
	for key, value in pairs(source) do
		if type(value) == "table" then
			dest[key] = {}
			self:CopySettings(dest[key], source[key])
		else
			dest[key] = value
		end
	end
end