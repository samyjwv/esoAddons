local nameForProfileSave = ""
local sourceForProfileSave = "Current profile"
local nameTaken = true
local chosenProfile = ""
local chosenIsCurrent = true	

local filterSelected = ""
local filter11 = ""
local filter12 = ""

--function BuffTimers.optionsShow()
	--BuffTimers:CreateEffectList()
	--BTTestDropDown:UpdateChoices(BuffTimers.testarr2)
	--CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BuffTimersPanel)
--end


function BuffTimers:SetupAddonMenu()
	
	for skillType = 1, GetNumSkillTypes() do
		for skillIndex = 1, GetNumSkillLines(skillType) do
			for abilityIndex = 1, GetNumSkillAbilities(skillType, skillIndex) do
				name, texture, _, _, _, _, _ = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
				table.insert(self.settingIcons, texture)									
			end
		end
	end
	for skillType = 1, GetNumSkillTypes() do
		for skillIndex = 1, GetNumSkillLines(skillType) do
			for abilityIndex = 1, GetNumSkillAbilities(skillType, skillIndex) do
				name, texture, _, _, _, _, _ = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
				table.insert(self.settingIconsTt, name)								
			end
		end
	end
	
	self.LAM = LibStub("LibAddonMenu-2.0")
	
	local panelData = {
        type = "panel",
        name = self.name,
        displayName = ZO_ColorDef:New("E6B85C"):Colorize(self.name),
        author = self.author,
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
	
	self.LAM:RegisterAddonPanel("BuffTimersPanel", panelData)
	--BuffTimersPanel:SetHandler( "OnEffectivelyShown", BuffTimers.optionsShow )
    --BuffTimersPanel:SetHandler( "OnEffectivelyHidden", BuffTimers.optionsHide )
	
	
	local optionsTable = {
		{
			type = "header",
			name = ZO_ColorDef:New("E6B85C"):Colorize("Configuration"),
		},
		{
			type = "slider",
			name = "Number of bars",
			min = 1,
			max = 15,
			step = 1,
			getFunc = function() return self.svars.numberBars end,
			setFunc = function(number) 
				self.svars.numberBars = number 
				ReloadUI()			
			end,
			warning = "Reloads UI!",
		},
		{
			type = "slider",
			name = "Notification duration",
			min = 0.5,
			max = 10,
			step = 0.5,
			getFunc = function() return self.svars.announceDur end,
			setFunc = function(number) self.svars.announceDur = number end,	
		},
		{
			type = "colorpicker",
			name = "Notification color",
			getFunc = function() return unpack(self.svars.announceColor) end,
			setFunc = function(r,g,b,a) self.svars.announceColor = {r,g,b,a} self.announce.label:SetColor(r,g,b,a) end,
		},
	}
	
	for i=1, self.svars.numberBars do
		local barData = {
			{
				type = "submenu",
				name = "Bar "..i.." settings",
				controls = {
					{
						type = "checkbox",
						name = "Lock",
						getFunc = function() return self.svars.barData[i].locked end,
						setFunc = function() 
							self.svars.barData[i].locked = not 
							self.svars.barData[i].locked self:LockBar(i, self.svars.barData[i].locked) 
							if not self.svars.barData[i].locked then self:SetSettingsExample(i) end			
						end
					},
					{
						type = "checkbox",
						name = "Always show",
						tooltip = "If on the bar will also be visible while the spell is not active.",
						getFunc = function() return self.svars.barData[i].alwaysShow end,
						setFunc = function() 
							self.svars.barData[i].alwaysShow = not self.svars.barData[i].alwaysShow
							self.bar[i]:SetHidden(not self.svars.barData[i].alwaysShow)
						end
					},
					{
						type = "editbox",
						name = "Buff name",
						getFunc = function() return self.svars.barData[i].buffName end,
						setFunc = function(str)
							for k,v in pairs(self.svars.buffNames) do
								if v == i then self.svars.buffNames[k] = nil end
							end
							str = zo_strformat("<<Z:1>>", str)
							self.svars.buffNames[str] = i
							self.svars.barData[i].buffName = str	
							CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BuffTimersPanel)
						end,
					},
					
					{
						type = "header",
						name = "Notification settings",
					},	
					{
						type = "slider",
						name = "Notification threshold",
						min = 0,
						max = 10,
						step = 0.5,
						getFunc = function() return self.svars.barData[i].criticalTime end,
						setFunc = function(number) self.svars.barData[i].criticalTime = number end,	
					},
					{
						type = "dropdown",
						name = "Sound to play",
						tooltip = "Sound that gets played when falling below the warning threshold.",
						choices = self.sounds,
						getFunc = function() return self.svars.barData[i].soundToPlay end,
						setFunc = function(var) 
							self.svars.barData[i].soundToPlay = var 
							PlaySound(var)						
						end,
					},
					{
						type = "checkbox",
						name = "Show text notification",
						getFunc = function() return self.svars.barData[i].announcement end,
						setFunc = function() 
							self.svars.barData[i].announcement = not self.svars.barData[i].announcement		
						end
					},
					{
						type = "editbox",
						name = "Text to show (leave empty to use name)",
						getFunc = function() return self.svars.barData[i].notiText end,
						setFunc = function(str) self.svars.barData[i].notiText = str end,
					},
					
					{
						type = "header",
						name = "Display settings",
					},
					{
						type = "slider",
						name = "Width",
						min = 0,
						max = 1000,
						step = 1,
						getFunc = function() return self.svars.barData[i].width end,
						setFunc = function(number) self.svars.barData[i].width=number self.bar[i]:SetWidth(number) end,						
					},
					{
						type = "slider",
						name = "Height",
						min = 0,
						max = 200,
						step = 1,
						getFunc = function() return self.svars.barData[i].height end,
						setFunc = function(number) 
							self.svars.barData[i].height=number self.bar[i]:SetHeight(number) 
							self.bar[i].icon:SetWidth(self.bar[i].icon:GetHeight())
						end,					
					},
					{
						type = "slider",
						name = "Font size",
						min = 10,
						max = 50,
						step = 1,
						getFunc = function() return self.svars.barData[i].textSize end,
						setFunc = function(number) self.svars.barData[i].textSize=number self.bar[i].label:SetFont("$(BOLD_FONT)|"..tostring(number).."|soft-shadow-thin") end,											
					},	
					{
						type = "checkbox",
						name = "Show buff icon",
						getFunc = function() return self.svars.barData[i].showIcon end,
						setFunc = function()
							self.svars.barData[i].showIcon = not self.svars.barData[i].showIcon
							self.bar[i].icon:SetHidden(not self.svars.barData[i].showIcon)
						end,
					},
					{
						type = "checkbox",
						name = "Use custom icon",
						tooltip = "Enter the name of an ability as it appears in your skillbook to use that icon, use this to replace it for effects that use a different one. If it works you'll see the icon show up below the edit box!",
						getFunc = function() return self.svars.barData[i].customIcon end,
						setFunc = function() 
							self.svars.barData[i].customIcon = not self.svars.barData[i].customIcon 
							if self.svars.barData[i].customIcon then 
								self.bar[i].icon:SetTexture(self.svars.barData[i].customIconTex)
							else
								self.bar[i].icon:SetTexture(self.svars.barData[i].iconTexture) 
							end
						end,
					},
					{						
						type = "iconpicker",
						name = "Choose icon",
						choices = self.settingIcons,
						choicesTooltips = self.settingIconsTt,
						getFunc = function() return self.svars.barData[i].customIconTex end,
						setFunc = function(str) 
							self.svars.barData[i].customIconTex = str
							if self.svars.barData[i].customIcon then 
								self.bar[i].icon:SetTexture(self.svars.barData[i].customIconTex)
							end
						end, 
						maxColumns = 7,
						visibleRows = 10,
						iconSize = 40,
					},	
					
					{
						type = "slider",
						name = "Icon size",
						min = 1,
						max = 250,
						step = 1,
						getFunc = function() return self.svars.barData[i].iconSize end,
						setFunc = function(number) 
							self.svars.barData[i].iconSize=number 
							self.bar[i].icon:SetWidth(number) 
							self.bar[i].icon:SetHeight(number) 
						end,						
					},							
					{
						type = "colorpicker",
						name = "Bar color left",
						getFunc = function() return self.svars.barData[i].colorBar[1], self.svars.barData[i].colorBar[2], self.svars.barData[i].colorBar[3], self.svars.barData[i].colorBar[4] end,
						setFunc = function(r,g,b,a)
							self.svars.barData[i].colorBar[1] = r
							self.svars.barData[i].colorBar[2] = g
							self.svars.barData[i].colorBar[3] = b
							self.svars.barData[i].colorBar[4] = a
							self.bar[i].bar:SetGradientColors(unpack(self.svars.barData[i].colorBar))
						end,
					},
					{
						type = "colorpicker",
						name = "Bar color right",
						getFunc = function() return self.svars.barData[i].colorBar[5], self.svars.barData[i].colorBar[6], self.svars.barData[i].colorBar[7], self.svars.barData[i].colorBar[8] end,
						setFunc = function(r,g,b,a)
							self.svars.barData[i].colorBar[5] = r
							self.svars.barData[i].colorBar[6] = g
							self.svars.barData[i].colorBar[7] = b
							self.svars.barData[i].colorBar[8] = a
							self.bar[i].bar:SetGradientColors(unpack(self.svars.barData[i].colorBar))
						end,
					},
					{
						type = "colorpicker",
						name = "Bar edge color",
						getFunc = function() return unpack(self.svars.barData[i].colorEdge) end,
						setFunc = function(r,g,b,a)
							self.svars.barData[i].colorEdge = {r,g,b,a}
							self.bar[i].bg:SetEdgeColor(unpack(self.svars.barData[i].colorEdge))	
						end,
					},
					{
						type = "colorpicker",
						name = "Bar bg color",
						getFunc = function() return unpack(self.svars.barData[i].colorBg) end,
						setFunc = function(r,g,b,a)
							self.svars.barData[i].colorBg = {r,g,b,a}
							self.bar[i].bg:SetCenterColor(unpack(self.svars.barData[i].colorBg))	
						end,
					},				
				},
			},
			
		}
		table.insert(optionsTable, barData[1])
	end
	
	local afterBars = {
		--PROFILES START
		{
			type = "header",
			name = ZO_ColorDef:New("E6B85C"):Colorize("Profiles"),
		},
		{
			type = "dropdown",
			name = "Choose profile",
			choices = self.savedvars.profiles["names"],
			getFunc = function() 
				if chosenProfile == "" then chosenProfile = self.savedvars.profiles.names[self.savedvars.activeProfile] end
				return chosenProfile 
			end,
			setFunc = function(var) 
				chosenProfile = var 
				local profId = -1
				for key, profName in pairs(self.savedvars.profiles.names) do
					if profName == chosenProfile then profId = key end
				end	
				if profId == self.savedvars.activeProfile then chosenIsCurrent = true else chosenIsCurrent = false end
				CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BuffTimersPanel)
			end,
			reference = "BTProfileChooseDropdown",
		},
		{
			type = "button",
			name = "Load profile",
			func = function() 
				self:LoadProfile(chosenProfile)
				chosenIsCurrent = true
				CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BuffTimersPanel)
			end,
			warning = "May reload UI!",
		},		
		{
			type = "editbox",
			name = "Rename chosen profile",
			getFunc = function() return chosenProfile end,
			setFunc = function(str) 
				self:RenameProfile(chosenProfile, str)
				chosenProfile = ""
				BTProfileChooseDropdown:UpdateChoices(self.savedvars.profiles.names)
				BTNewProfileChooseDropdown:UpdateChoices(self.savedvars.profiles.names)
				CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BuffTimersPanel)
			end,
		},			
		{
			type = "button",
			name = "!DELETE! chosen profile",
			func = function() 
				self:DeleteProfile(chosenProfile)
				chosenProfile = ""
				chosenIsCurrent = true
				BTProfileChooseDropdown:UpdateChoices(self.savedvars.profiles.names)
				BTNewProfileChooseDropdown:UpdateChoices(self.savedvars.profiles.names)
				CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BuffTimersPanel)
			end,
			disabled = function() return chosenIsCurrent end,			
		},
		{
			type = "submenu",
			name = "New profile",				
			controls = {
				{
					type = "dropdown",
					name = "Copy settings from",
					choices = self.savedvars.profiles["names"],
					getFunc = function() return sourceForProfileSave end,
					setFunc = function(var) sourceForProfileSave = var end,
					reference = "BTNewProfileChooseDropdown",
				},
				{
					type = "editbox",
					name = "Name",
					getFunc = function() return nameForProfileSave end,
					setFunc = function(str) 
						nameForProfileSave = str 
						local takenCheck = false
						if nameForProfileSave == "ALREADY TAKEN!" then takenCheck = true nameTaken = true end
						for k, pName in pairs(self.savedvars.profiles.names) do
							if pName == nameForProfileSave then nameTaken = true takenCheck = true nameForProfileSave = "ALREADY TAKEN!" end
						end
						if not takenCheck then nameTaken = false end
						CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BuffTimersPanel)
					end,
				},
				{
					type = "button",
					name = "Save new profile",
					func = function()					
						self:CreateProfile(nameForProfileSave, sourceForProfileSave)
						nameForProfileSave = ""
						BTProfileChooseDropdown:UpdateChoices(self.savedvars.profiles.names)
						BTNewProfileChooseDropdown:UpdateChoices(self.savedvars.profiles.names)
						CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BuffTimersPanel)
					end,
					disabled = function() return nameTaken end,
				},		
			},
		},	
		--PROFILES END
		
		{
			type = "header",
			name = ZO_ColorDef:New("E6B85C"):Colorize("Misc"),
		},
		{
			type = "slider",
			name = "Bar refresh interval (in ms)",
			min = 5,
			max = 500,
			step = 1,
			getFunc = function() return self.savedvars.updateSpeed end,
			setFunc = function(number) 
				self.savedvars.updateSpeed = number
				EVENT_MANAGER:UnregisterForUpdate(self.name)
				EVENT_MANAGER:RegisterForUpdate(self.name, self.savedvars.updateSpeed, function() BuffTimers.updateHandler() end)
			end,
		},
		{
			type = "button",
			name = "(De)activate debug",
			func = function() 
				self.debugOutput = not self.debugOutput	
				table.insert(self.notifications, {"----- Debug output = "..tostring(self.debugOutput).." -----", GetFrameTimeSeconds()+3})
			end,
			width = "half",
		},
		{
			type = "button",
			name = "(Un)lock notification",
			func = function()
				self.unlockAnn = not self.unlockAnn
				self.announce:SetMovable(self.unlockAnn)
				self.announce:SetMouseEnabled(self.unlockAnn)
				self.announce:SetHidden(not self.unlockAnn)
				if self.unlockAnn then
					self.announce.label:SetText("--------- Notification here! ---------")
				else
					self.announce.label:SetText("")
				end	
			end,
			width = "half",
		},
		{
			type = "header",
			name = ZO_ColorDef:New("E6B85C"):Colorize("(WIP) custom filters"),
		},
		{
			type = "dropdown",
			name = "Current filters",
			choices = self.filterList,
			getFunc = function() return filterSelected end,
			setFunc = function(var) 
				filterSelected = var
				local equalsPos1,_ = filterSelected:find("%s=")
				local selectedName = filterSelected:sub(1,equalsPos1-1)
				local selectedName2 = filterSelected:sub(equalsPos1+3)
				filter11 = selectedName
				filter12 = selectedName2
				CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BuffTimersPanel)
			end,
			reference = "BTXasYFiltersDropDown",
		},
		{
			type = "editbox",
			name = "On...",
			getFunc = function() return filter11 end,
			setFunc = function(str) 
				filter11 = zo_strformat("<<Z:1>>", str)
				CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BuffTimersPanel)
			end,
			width = "half",
		},
		{
			type = "editbox",
			name = "...also start...",
			getFunc = function() return filter12 end,
			setFunc = function(str) 
				filter12 = zo_strformat("<<Z:1>>", str)
				CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BuffTimersPanel)
			end,
			width = "half",
		},
		{
			type = "button",
			name = "Create filter",
			func = function() 
				self.savedvars.customFilterXalsoY[filter11] = filter12	
				self:CreateFilterLists()
				BTXasYFiltersDropDown:UpdateChoices(self.filterList)
			end,
			width = "half",
		},
		{
			type = "button",
			name = "Delete selected filter",
			func = function() 
				self.savedvars.customFilterXalsoY[filter11] = nil
				self:CreateFilterLists()
				BTXasYFiltersDropDown:UpdateChoices(self.filterList)	
			end,
			width = "half",
		},
		--{
		--	type = "dropdown",
		--	name = "Ability list test dropdown",
		--	tooltip = "just shows effects gained/used, has no function",
		--	choices = self.testarr2,
		--	getFunc = function() return "" end,
		--	setFunc = function(var) end,
		--	reference = "BTTestDropDown",
		--},
		
	}
	for i=1,#afterBars do
		table.insert(optionsTable, afterBars[i])
	end
	
	self.LAM:RegisterOptionControls("BuffTimersPanel", optionsTable)
end
