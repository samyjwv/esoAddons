local HarvensImprovedSkillsWindow = {}

function HarvensImprovedSkillsWindow.UpgradeAbilityOnMouseEnter(control)
	InitializeTooltip(SkillTooltip, control, TOPLEFT, 5, -5, TOPRIGHT)
	local ability = control:GetParent()
    SkillTooltip:SetSkillUpgradeAbility(ability.slot.skillType, ability.slot.lineIndex, ability.slot.index)
end

function HarvensImprovedSkillsWindow.AbilityOnMouseEnter(control)
	local ability = control:GetParent()
	if ability.progressionIndex then
		_, morph, rank = GetAbilityProgressionInfo(ability.progressionIndex)
		if morph > 0 and rank >= 4 then return end
		InitializeTooltip(HarvensSkillTooltipMorph1, control, TOPLEFT, 5, 5, BOTTOMRIGHT)
    	HarvensSkillTooltipMorph1:SetProgressionAbility(ability.progressionIndex, morph, rank+1)
		InitializeTooltip(SkillTooltip, HarvensSkillTooltipMorph1, TOPRIGHT, -5, 0, TOPLEFT)
		SkillTooltip:SetSkillAbility(ability.slot.skillType, ability.slot.lineIndex, ability.slot.index)
	else
		InitializeTooltip(SkillTooltip, control, TOPLEFT, 5, 5, BOTTOMRIGHT)
		SkillTooltip:SetSkillAbility(ability.slot.skillType, ability.slot.lineIndex, ability.slot.index)
	end
end

function HarvensImprovedSkillsWindow.AbilityOnMouseExit(control)
	ClearTooltip(SkillTooltip)
	ClearTooltip(HarvensSkillTooltipMorph1)
end

function HarvensImprovedSkillsWindow.Initialize(eventCode, addonName)
	if addonName ~= "HarvensImprovedSkillsWindow" then return end
	
	local defaults = { showDetails = true }
	HarvensImprovedSkillsWindow.sv = ZO_SavedVars:New("HarvensImprovedSkillsWindow_SavedVariables", 1, nil, defaults)
	
	local checkbox = WINDOW_MANAGER:CreateControlFromVirtual(SKILLS_WINDOW.container:GetName().."HarvensShowDetails", SKILLS_WINDOW.container, "HarvensImprovedSkillsWindowShowDetails")
	checkbox:SetAnchor(BOTTOMRIGHT, SKILLS_WINDOW.container, TOPRIGHT, -8, -8)
	ZO_CheckButton_SetLabelText(checkbox, "Show detailed skills progression")
	checkbox:GetNamedChild("Label"):ClearAnchors()
	checkbox:GetNamedChild("Label"):SetAnchor(RIGHT, checkbox, LEFT, -4)
	ZO_CheckButton_SetCheckState(checkbox, HarvensImprovedSkillsWindow.sv.showDetails)
	ZO_CheckButton_SetToggleFunction(checkbox, function()
		HarvensImprovedSkillsWindow.sv.showDetails = ZO_CheckButton_IsChecked(checkbox)
		SKILLS_WINDOW:Refresh()
	end)
	
	local AbilitySlotOnMouseEnterOrg = ZO_Skills_AbilitySlot_OnMouseEnter
	ZO_Skills_AbilitySlot_OnMouseEnter = function(control)
    	InitializeTooltip(SkillTooltip, control, TOPLEFT, 5, -5, TOPRIGHT)
    	SkillTooltip:SetSkillAbility(control.skillType, control.lineIndex, control.index)
    	local ability = control:GetParent()
    	local curLvl, maxLvl = GetSkillAbilityUpgradeInfo(control.skillType, control.lineIndex, control.index)
    	if ability.progressionIndex then
    		_, morph, rank = GetAbilityProgressionInfo(ability.progressionIndex)
    		if morph == 0 then rank = 0 end
			if morph > 0 and rank >= 4 then
				InitializeTooltip(HarvensSkillTooltipMorph1, control, TOPRIGHT, -5, -5, TOPLEFT)
				morph = (morph == 2 and 1 or 2)
				HarvensSkillTooltipMorph1:SetProgressionAbility(ability.progressionIndex, morph, rank)
				return
			end
    		InitializeTooltip(HarvensSkillTooltipMorph2, control, TOPRIGHT, -5, -5, TOPLEFT)
    		HarvensSkillTooltipMorph2:SetProgressionAbility(ability.progressionIndex, 2, rank+1)
			InitializeTooltip(HarvensSkillTooltipMorph1, HarvensSkillTooltipMorph2, TOPRIGHT, -5, 0, TOPLEFT)
    		HarvensSkillTooltipMorph1:SetProgressionAbility(ability.progressionIndex, 1, rank+1)
    		return
    	elseif curLvl and maxLvl and curLvl < maxLvl and ability.purchased then
    		InitializeTooltip(HarvensSkillTooltipMorph1, control, TOPRIGHT, -5, -5, TOPLEFT)
    		HarvensSkillTooltipMorph1:SetSkillUpgradeAbility(control.skillType, control.lineIndex, control.index)
    	end
	end
	
	local AbilitySlotOnMouseExitOrg = ZO_Skills_AbilitySlot_OnMouseExit
	ZO_Skills_AbilitySlot_OnMouseExit = function()
		ClearTooltip(SkillTooltip)
		ClearTooltip(HarvensSkillTooltipMorph1)
		ClearTooltip(HarvensSkillTooltipMorph2)
	end
	
	local SetupAbilityEntryOrg = SKILLS_WINDOW.SetupAbilityEntry
	SKILLS_WINDOW.SetupAbilityEntry = function(manager, control, data)
		SetupAbilityEntryOrg(manager, control, data)
		local ctrl = control.xpBar:GetControl()
		if not ctrl.label then
			ctrl:SetHeight(ctrl:GetHeight()+5)
			ctrl.label = WINDOW_MANAGER:CreateControlFromVirtual(ctrl:GetName().."HarvensLabel", ctrl, "HarvensImprovedSkillsWindowLabel")
			ctrl.label:SetAnchor(CENTER, ctrl, CENTER)
		end
		if not control.morphLabel then
			control.morphLabel = WINDOW_MANAGER:CreateControlFromVirtual(ctrl:GetName().."HarvensMorphLabel", ctrl, "HarvensImprovedSkillsWindowMorphLabel")
			control.morphLabel:SetAnchor(LEFT, control.nameLabel, RIGHT)
		end
		if data.progressionIndex then
			local lastXP, nextXP, currentXP, atMorph = GetAbilityProgressionXPInfo(data.progressionIndex)
			local name, morph = GetAbilityProgressionInfo(data.progressionIndex)
			if morph > 0 then
				local orgText = control.nameLabel:GetText()
				control.morphLabel:SetHidden(false)
				control.morphLabel:SetText(" ("..zo_strformat("<<1>>", name)..")")
			else
				control.morphLabel:SetHidden(true)
			end
			
			if nextXP > 0 then
				local percent = string.format("%.2f", (currentXP-lastXP)/(nextXP-lastXP)*100 )
				local text = ""
				if HarvensImprovedSkillsWindow.sv.showDetails then
					text = currentXP-lastXP.."/"..nextXP-lastXP.." ("
				end
				text = text..percent.."%"
				if HarvensImprovedSkillsWindow.sv.showDetails then
					text = text..")"
				end
				ctrl.label:SetText(text)
				ctrl.label:SetHidden(false)
				ctrl:SetHandler("OnMouseEnter", HarvensImprovedSkillsWindow.AbilityOnMouseEnter)
				ctrl:SetHandler("OnMouseExit", HarvensImprovedSkillsWindow.AbilityOnMouseExit)
			else
				ctrl.label:SetHidden(true)
				ctrl:SetHandler("OnMouseEnter", nil)
				ctrl:SetHandler("OnMouseExit", nil)
			end
		else
			ctrl.label:SetHidden(true)
			ctrl:SetHandler("OnMouseEnter", nil)
			ctrl:SetHandler("OnMouseExit", nil)
		end
		
		local a = control.alert
		if control.upgradeAvailable then
			a:SetHandler("OnMouseEnter", HarvensImprovedSkillsWindow.UpgradeAbilityOnMouseEnter)
			a:SetHandler("OnMouseExit", HarvensImprovedSkillsWindow.AbilityOnMouseExit)
		elseif not control.atMorph then
			a:SetHandler("OnMouseEnter", HarvensImprovedSkillsWindow.AbilityOnMouseEnter)
			a:SetHandler("OnMouseExit", HarvensImprovedSkillsWindow.AbilityOnMouseExit)
		else
			a:SetHandler("OnMouseEnter", nil)
			a:SetHandler("OnMouseExit", nil)
		end
	end
	
	local RefreshSkillInfoOrg = SKILLS_WINDOW.RefreshSkillInfo
	SKILLS_WINDOW.RefreshSkillInfo = function(self)
		local ctrl = self.skillInfo.xpBar:GetControl()
		if not ctrl.label then
			ctrl:SetHeight(ctrl:GetHeight()+3)
			ctrl.label = WINDOW_MANAGER:CreateControlFromVirtual(ctrl:GetName().."HarvensLabel", ctrl, "HarvensImprovedSkillsWindowLabel")
			ctrl.label:SetAnchor(CENTER, ctrl, CENTER)
		end
		
	    local skillType = self:GetSelectedSkillType()
	    local skillIndex = self:GetSelectedSkillLineIndex()
	    local lastXP, nextXP, currentXP = GetSkillLineXPInfo(skillType, skillIndex)
		if nextXP > 0 then
			local percent = string.format("%.2f", (currentXP-lastXP)/(nextXP-lastXP)*100 )
			local text = ""
			if HarvensImprovedSkillsWindow.sv.showDetails then
				text = currentXP-lastXP.."/"..nextXP-lastXP.." ("
			end
			text = text..percent.."%"
			if HarvensImprovedSkillsWindow.sv.showDetails then
				text = text..")"
			end
			ctrl.label:SetText(text)
			ctrl.label:SetHidden(false)
		else
			ctrl.label:SetHidden(true)
		end
		RefreshSkillInfoOrg(self)
	end	
end

EVENT_MANAGER:RegisterForEvent("HarvensImprovedSkillsWindowInitialize", EVENT_ADD_ON_LOADED, HarvensImprovedSkillsWindow.Initialize)