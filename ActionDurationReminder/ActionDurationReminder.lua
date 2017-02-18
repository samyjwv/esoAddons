-- 0. Declare
local adr = {
	name = "ActionDurationReminder",
	version = "1.29",
	savedVarsName = "ADRSV",
	savedVarsVersion = "1.0",
}
ActionDurationReminder = adr
local localizedGround = GetString(SI_ABILITY_TOOLTIP_TARGET_TYPE_GROUND)
local sformat = string.format
local tinsert = table.insert
local tsort = table.sort
local GetGameTimeMilliseconds = GetGameTimeMilliseconds
local pairs = pairs
local unpack = unpack

-- X. utils
function adr.UtilDebugActions ()
	d('{')
	for key,action in pairs(adr.actions) do
		d('  '..key..': '..action.abilityName)
	end
	d('}')
end

function adr.UtilRefineActions ()
	local now = GetGameTimeMilliseconds()
	local endLimit = now - adr.savedVars.secondsBeforeFade * 1000
	-- 1. remove obsolete actions
	local function refineActions(actions)
		for key,action in pairs(actions) do
			if action.endTime < endLimit then
				actions[key] = nil
			else
				if adr.savedVars.alertEnabled and action.endTime - adr.savedVars.alertAheadSeconds *1000 < now and not action.alerted then
					action.alerted = true
					adr.Alert(action.abilityName, action.abilityIcon)
				end
			end
		end
	end
	refineActions(adr.actions)
	refineActions(adr.timedEffectActions)
	-- 2. add confirmed ground action
	if adr.lastGroundAction then
		local slotNum = adr.lastGroundAction.slotNum
		local confirmTime = adr.lastGroundAction.confirmTime
		adr.lastGroundAction = nil
		adr.OnSlotAbilityUsed(0, slotNum, confirmTime)
	end
end

function adr.UtilGetLabelFont()
	return "$("..adr.savedVars.labelFontName..")|"..adr.savedVars.labelFontSize.."|thick-outline"
end

function adr.UtilGetAlertFont()
	return "$("..adr.savedVars.alertFontName..")|"..adr.savedVars.alertFontSize.."|thick-outline"
end

function adr.UtilOpenAlertFrame()
	if not adr.alertFrame then
		adr.alertFrame = WINDOW_MANAGER:CreateTopLevelWindow()
		adr.alertFrame:SetDimensions(350, 70)
		adr.alertFrame:SetMouseEnabled(true)
		adr.alertFrame:SetMovable(true)
		adr.alertFrame:SetDrawLayer(DL_COUNT)
		adr.alertFrame:SetHandler('OnMoveStop', adr.OnAlertFrameMoved)
		local backdrop = WINDOW_MANAGER:CreateControl(nil, adr.alertFrame, CT_BACKDROP)
		backdrop:SetAnchor(TOPLEFT)
		backdrop:SetAnchor(BOTTOMRIGHT)
		backdrop:SetCenterColor(0,0,1,0.5)
		backdrop:SetEdgeTexture('',1,1,1,1)
		local label = WINDOW_MANAGER:CreateControl(nil, backdrop, CT_LABEL)
		label:SetFont('$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thin')
		label:SetColor(1,1,1)
		label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		label:SetAnchor(CENTER)
		label:SetDrawLayer(DL_COUNT)
		label:SetDrawLevel(1)
		label:SetText('ADR Alert Frame')
		local labelClose = WINDOW_MANAGER:CreateControl(nil, backdrop, CT_LABEL)
		labelClose:SetFont('$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thin')
		labelClose:SetColor(1,1,1)
		labelClose:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		labelClose:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
		labelClose:SetAnchor(BOTTOMRIGHT, nil, BOTTOMRIGHT, -5, -2)
		labelClose:SetDrawLayer(DL_COUNT)
		labelClose:SetDrawLevel(1)
		labelClose:SetText('[X]')
		labelClose:SetMouseEnabled(true)
		local function onClick()
			adr.alertFrame:SetHidden(true)
		end
		labelClose:SetHandler('OnMouseUp', onClick)
	end
	adr.alertFrame:SetHidden(false)
	adr.alertFrame:ClearAnchors()
	adr.alertFrame:SetAnchor(BOTTOMLEFT, GuiRoot, CENTER, - 150+adr.savedVars.alertOffsetX, -150+adr.savedVars.alertOffsetY)
end

function adr.UtilOpenShiftBarFrame()
	local slot3 = ZO_ActionBar_GetButton(3).slot
	local slot7 = ZO_ActionBar_GetButton(7).slot
	if not adr.shiftBarFrame then
		adr.shiftBarFrame = WINDOW_MANAGER:CreateControl(nil, slot3, CT_BACKDROP)
		local width = slot7:GetRight() - slot3:GetLeft()
		local _,height = slot7:GetDimensions()
		adr.shiftBarFrame:SetDimensions(width, height)
		adr.shiftBarFrame:SetMouseEnabled(true)
		adr.shiftBarFrame:SetMovable(true)
		adr.shiftBarFrame:SetDrawLayer(DL_COUNT)
		adr.shiftBarFrame:SetCenterColor(0,0,1,0.5)
		adr.shiftBarFrame:SetEdgeTexture('',1,1,1,0)
		adr.shiftBarFrame:SetHandler('OnMoveStop', adr.OnShiftBarFrameMoved)
		local label = WINDOW_MANAGER:CreateControl(nil, adr.shiftBarFrame, CT_LABEL)
		label:SetFont('$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thin')
		label:SetColor(1,1,1)
		label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		label:SetAnchor(CENTER)
		label:SetDrawLayer(DL_COUNT)
		label:SetDrawLevel(1)
		label:SetText('ADR Shift Bar Frame')
		local labelClose = WINDOW_MANAGER:CreateControl(nil, adr.shiftBarFrame, CT_LABEL)
		labelClose:SetFont('$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thin')
		labelClose:SetColor(1,1,1)
		labelClose:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		labelClose:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
		labelClose:SetAnchor(BOTTOMRIGHT, nil, BOTTOMRIGHT, -5, -2)
		labelClose:SetDrawLayer(DL_COUNT)
		labelClose:SetDrawLevel(1)
		labelClose:SetText('[X]')
		labelClose:SetMouseEnabled(true)
		local function onClick()
			adr.shiftBarFrame:SetHidden(true)
		end
		labelClose:SetHandler('OnMouseUp', onClick)
	end
	adr.shiftBarFrame:SetHidden(false)
	adr.shiftBarFrame:ClearAnchors()
	adr.shiftBarFrame:SetAnchor(BOTTOMLEFT, slot3, TOPLEFT, adr.savedVars.shiftBarOffsetX, adr.savedVars.shiftBarOffsetY - adr.savedVars.positionGap)
end

function adr.UtilUpdateAllCooldownColor()
	local color = adr.savedVars.cooldownColor
	for key,widget in pairs(adr.actionBarWidgets) do
		widget.cd:SetFillColor(unpack(color))
	end
	for key,widget in pairs(adr.actionShiftBarWidgets) do
		widget.cd:SetFillColor(unpack(color))
	end
end

function adr.UtilUpdateAllCooldownOpacity()
	local opacity = adr.savedVars.cooldownOpacity / 100
	for key,widget in pairs(adr.actionBarWidgets) do
		widget.cd:SetAlpha(opacity)
	end
	for key,widget in pairs(adr.actionShiftBarWidgets) do
		widget.cd:SetAlpha(opacity)
	end
end

function adr.UtilUpdateAllCooldownVisible()
	local cooldownThickness = adr.savedVars.cooldownVisible and adr.savedVars.cooldownThickness or 0
	for key,widget in pairs(adr.actionShiftBarWidgets) do
		widget.bd:SetDimensions(50-math.max(0,cooldownThickness-2),50-math.max(0,cooldownThickness-2))
		widget.cd:ClearAnchors()
		widget.cd:SetAnchor(TOPLEFT, widget.bg, TOPLEFT, -cooldownThickness, -cooldownThickness)
		widget.cd:SetAnchor(BOTTOMRIGHT, widget.bg, BOTTOMRIGHT, cooldownThickness, cooldownThickness)
	end
end

function adr.UtilUpdateShiftPosition()
	local gap = adr.savedVars.positionGap
	local offsetX = adr.savedVars.shiftBarOffsetX
	local offsetY = adr.savedVars.shiftBarOffsetY
	for key,widget in pairs(adr.actionShiftBarWidgets) do
		local parent = widget.bd:GetParent()
		widget.bd:ClearAnchors()
		widget.bd:SetAnchor(BOTTOM, parent, TOP, offsetX, offsetY - gap)
	end
	adr.rrb.newRectReady = false
	adr.rrb.shifted = false
end

function adr.UtilUpdateAllLabelsFont()
	local font = adr.UtilGetLabelFont()
	for key,widget in pairs(adr.actionBarWidgets) do
		widget.label:SetFont(font)
		widget.countLabel:SetFont(font)
	end
	for key,widget in pairs(adr.actionShiftBarWidgets) do
		widget.label:SetFont(font)
		widget.countLabel:SetFont(font)
	end
end

function adr.UtilUpdateAllLabelsYOffset()
	local offset = adr.savedVars.labelYOffset + 5
	for key,widget in pairs(adr.actionBarWidgets) do
		widget.label:ClearAnchors()
		widget.label:SetAnchor(BOTTOM, nil, BOTTOM, 0, offset)
		widget.countLabel:ClearAnchors()
		widget.countLabel:SetAnchor(TOPRIGHT, nil, TOPRIGHT, 0, - offset)
	end
	for key,widget in pairs(adr.actionShiftBarWidgets) do
		widget.label:ClearAnchors()
		widget.label:SetAnchor(BOTTOM, nil, BOTTOM, 0, offset)
		widget.countLabel:ClearAnchors()
		widget.countLabel:SetAnchor(TOPRIGHT, nil, TOPRIGHT, 0, - offset)
	end
end


-- X. Create
function adr.Create()
	-- 1. data
	adr.actions = {}
	adr.timedEffectActions = {}
	-- 2. ui
	adr.actionBarWidgets = {}
	adr.actionShiftBarWidgets = {}
	adr.actionShiftAppendBarWidgets = {}
	-- 3. misc
	adr.lastGroundSlotNum = 0
	adr.lastGroundAction = nil
	adr.recheckAbility = nil
	adr.pairIndex, _ = GetActiveWeaponPairInfo() -- considier ultimate if locked
	adr.pairUltimate = false
end

-- X. Hook
function adr.OnAlertFrameMoved()
	local left = adr.alertFrame:GetLeft()
	local bottom = adr.alertFrame:GetBottom()
	local centerX,centerY = GuiRoot:GetCenter()
	adr.savedVars.alertOffsetX = left - centerX + 150
	adr.savedVars.alertOffsetY = bottom - centerY + 150
end

function adr.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, startTimeSec, endTimeSec, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
	--d('effectName:'..effectName..',stackCount:'..stackCount..',changeType:'..changeType..',abilityId:'..abilityId..',unitTag:'..unitTag..',unitId:'..unitId..',startTime:'..startTimeSec..',endTime:'..endTimeSec..',effectType:'..effectType..',buffType:'..buffType..',icon:'..iconName)
	-- 0. prepare
	local startTime = math.floor(startTimeSec * 1000)
	local endTime = math.floor(endTimeSec * 1000)
	local duration = endTime - startTime
	-- 1. process unitTag
	if unitTag == 'player' then
		if  stackCount > 0 then -- e.g. relentless focus
			for key,action in pairs(adr.actions) do
				if action.abilityName == effectName then
					if changeType == EFFECT_RESULT_FADED then
						if stackCount == action.stackCount then -- check to avoid removing a new action
							adr.actions[key] = nil
						end
					else
						action.stackCount = stackCount
					end
				end
			end
		end
		if changeType == EFFECT_RESULT_GAINED then -- e.g. hidden blade
			if duration < adr.savedVars.minimumDurationSeconds * 1000 + 100 then return end
			if abilityId == 46327 then -- Crystal Fragment Proc is triggered by all skills
				local slotAbilityId = 47569
				for slotNum = 3,7 do
					if slotAbilityId == GetSlotBoundId(slotNum) then
						local action = {
							abilityId = slotAbilityId,
							abilityName = GetAbilityName(slotAbilityId),
							abilityIcon	= GetAbilityIcon(slotAbilityId),
							effectAbilityId = abilityId,
							effectName = effectName,
							effectUnitId = unitId,
							startTime = startTime,
							endTime = endTime,
							duration = duration,
							slotNum = slotNum,
							pairIndex = adr.pairIndex,
							pairUltimate = adr.pairUltimate,
							playerBuff = true, -- avoid being changed by target debuff
						}
						tinsert(adr.actions, action.abilityId, action)
						return
					end
				end
				return
			end
			if adr.recheckAbility == nil or adr.recheckAbility.startTime + 2000 < startTime then
				adr.recheckAbility = nil
				return 
			end
			local nameMatch = string.find(effectName, adr.recheckAbility.abilityName) or string.find(adr.recheckAbility.abilityName, effectName) or
				string.find(effectName, adr.recheckAbility.abilityProgressionName) or string.find(adr.recheckAbility.abilityProgressionName, effectName)
			if abilityId==51392 and (adr.recheckAbility.abilityId==30215 or adr.recheckAbility.abilityId==30215) then
				nameMatch = true -- patch for bolt escape
			end
			if adr.recheckAbility.abilityId == abilityId or nameMatch or adr.recheckAbility.abilityIcon == iconName then
				local action = {
					abilityId = adr.recheckAbility.abilityId,
					abilityName = adr.recheckAbility.abilityName,
					abilityIcon	= adr.recheckAbility.abilityIcon,
					effectAbilityId = abilityId,
					effectName = effectName,
					effectUnitId = unitId,
					startTime = startTime,
					endTime = endTime,
					duration = duration,
					slotNum = adr.recheckAbility.slotNum,
					pairIndex = adr.pairIndex,
					pairUltimate = adr.pairUltimate,
					playerBuff = true, -- avoid being changed by target debuff
				}
				tinsert(adr.actions, action.abilityId, action)
				adr.recheckAbility = nil
				return
			end
		elseif changeType == EFFECT_RESULT_UPDATED then
			for key,action in pairs(adr.actions) do
				if action.effectName == effectName and action.effectUnitId == unitId then
					action.startTime = startTime
					action.endTime = endTime
					action.duration = duration
					action.effectAbilityId = abilityId
				end
			end
		elseif changeType == EFFECT_RESULT_FADED then
			for key,action in pairs(adr.actions) do
				if action.effectName == effectName and (not action.effectAbilityId or action.effectAbilityId==abilityId)then
					action.endTime = GetGameTimeMilliseconds()
					action.alerted = true -- ignore alert
					if action.abilityId == 47569 then
						adr.actions[key] = nil -- don't blink for used Crystal Fragment Proc
					end
				end
			end
		end
		return
	end
	-- 2. check changeType
	if changeType == EFFECT_RESULT_UPDATED then
		for key,action in pairs(adr.actions) do
			if action.effectName == effectName and action.effectUnitId == unitId then
				action.startTime = startTime
				action.endTime = endTime
				action.duration = duration
				action.effectAbilityId = abilityId
				tinsert(adr.timedEffectActions, startTime, action)
			end
		end
		return
	elseif changeType == EFFECT_RESULT_FADED then
		for key,action in pairs(adr.actions) do
			if action.effectName == effectName and (not action.effectAbilityId or action.effectAbilityId==abilityId)then
				action.endTime = GetGameTimeMilliseconds()
				action.alerted = true -- alert ignore
			end
		end
		return
	end
	-- 3. check gained
	if changeType ~= EFFECT_RESULT_GAINED then return end
	if duration < adr.savedVars.minimumDurationSeconds * 1000 + 100 then return end
	-- 4. check override current action, i.e. Beast Trap
	if effectType == BUFF_EFFECT_TYPE_DEBUFF and unitTag ~= 'player' then
		-- update time info for actions
		local function checkActions(actions)
			for key,action in pairs(actions) do
				if not action.playerBuff and action.abilityIcon == iconName then
					local newAction = {
						abilityId = action.abilityId,
						abilityName = action.abilityName,
						abilityIcon	= action.abilityIcon,
						effectAbilityId = abilityId,
						effectName = effectName,
						effectUnitId = unitId,
						startTime = startTime,
						endTime = endTime,
						duration = duration,
						slotNum = action.slotNum,
						pairIndex = action.pairIndex,
						pairUltimate = action.pairUltimate,
						oldEndTime = action.oldEndTime or action.endTime
					}
					tinsert(adr.timedEffectActions, startTime, newAction)
					tinsert(adr.actions, newAction.abilityId, newAction)
					return true
				end
			end
			return false
		end
		if checkActions(adr.actions) then return end
		if checkActions(adr.timedEffectActions) then return end
	end
		
	-- 5. check recheckAbility
	if unitTag ~= 'reticleover' then return end
	if adr.recheckAbility == nil or adr.recheckAbility.startTime + 2000 < startTime then
		adr.recheckAbility = nil
		return 
	end
	local nameMatch = string.find(effectName, adr.recheckAbility.abilityName) or string.find(adr.recheckAbility.abilityName, effectName)
	if adr.recheckAbility.abilityId ~= abilityId and not nameMatch and adr.recheckAbility.abilityIcon ~= iconName then return end
	-- 6. add to show
	local action = {
		abilityId = adr.recheckAbility.abilityId,
		abilityName = adr.recheckAbility.abilityName,
		abilityIcon	= adr.recheckAbility.abilityIcon,
		effectAbilityId = abilityId,
		effectName = effectName,
		effectUnitId = unitId,
		startTime = startTime,
		endTime = endTime,
		duration = duration,
		slotNum = adr.recheckAbility.slotNum,
		pairIndex = adr.pairIndex,
		pairUltimate = adr.pairUltimate,
	}
	tinsert(adr.timedEffectActions, startTime, action)
	tinsert(adr.actions, action.abilityId, action)
	-- 7. clear temp data
	adr.recheckAbility = nil
end

function adr.OnShiftBarFrameMoved()
	local slot3 = ZO_ActionBar_GetButton(3).slot
	local left = adr.shiftBarFrame:GetLeft()
	local bottom = adr.shiftBarFrame:GetBottom()
	adr.savedVars.shiftBarOffsetX = left - slot3:GetLeft()
	adr.savedVars.shiftBarOffsetY = bottom + adr.savedVars.positionGap - slot3:GetTop()
	adr.UtilUpdateShiftPosition()
end

function adr.OnSlotAbilityUsed(eventCode, slotNum, fixTime)
	local now =  fixTime or GetGameTimeMilliseconds()
	-- 1. filter other actions
	if slotNum < 3 or slotNum > 7 then return end
	-- 2. filter ground abilities
	local abilityId = GetSlotBoundId(slotNum)
	if eventCode > 0 and localizedGround == GetAbilityTargetDescription(abilityId) then
		adr.lastGroundSlotNum = slotNum
		return -- wait confirmation
	end
	adr.lastGroundSlotNum = 0
	if adr.lastGroundAction and now - adr.lastGroundAction.confirmTime < 10 then
		adr.lastGroundAction = nil  -- cancel confirmation by another skill
	end
	-- 3. slot action info
	local abilityName = GetSlotName(slotNum)
	local abilityIcon = GetSlotTexture(slotNum)
	local startTime = now
	local duration = GetAbilityDuration(abilityId)
	if duration==0 then
		local _,progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
		local abilityProgressionName = GetAbilityProgressionInfo(progressionIndex)
		adr.recheckAbility = {
			startTime = startTime,
			slotNum = slotNum,
			abilityId = abilityId,
			abilityName = abilityName,
			abilityProgressionName = abilityProgressionName,
			abilityIcon = abilityIcon,
			pairIndex = adr.pairIndex,
			pairUltimate = adr.pairUltimate,
		}
		return
	end
	if duration < adr.savedVars.minimumDurationSeconds * 1000 + 100 then return end
	-- 4. add action to show
	local endTime = startTime + duration
	tinsert(adr.actions,abilityId,{
		abilityId = abilityId,
		abilityName = abilityName,
		abilityIcon	= abilityIcon,
		startTime = startTime,
		endTime = endTime,
		duration = duration,
		slotNum = slotNum,
		pairIndex = adr.pairIndex,
		pairUltimate = adr.pairUltimate,
	})
end

function adr.OnSlotsFullUpdate(eventCode, isHotbarSwap)
	if not isHotbarSwap then return end
	adr.lastGroundSlotNum=0
	adr.lastGroundAction=nil
	adr.recheckAbility = nil
	
	local newPairIndex,_ = GetActiveWeaponPairInfo()
	if newPairIndex ~= adr.pairIndex then
		adr.pairIndex = newPairIndex
		adr.pairUltimate = false
	else
		adr.pairUltimate = not adr.pairUltimate
	end
end

function adr.OnTargetChanged()
	if not adr.savedVars.multipleTargetTracking then return end
	if not DoesUnitExist('reticleover') then return end
	-- 1. remove all effect actions from adr.actions
	for key,action in pairs(adr.actions) do
		if action.effectName and not action.playerBuff then
			adr.actions[key] = nil
		end
	end
	-- 2. scan all matched buffs
	local numBuffs = GetNumBuffs('reticleover')
	for i = 1, numBuffs do
		local effectName, startSec, endSec, _, stackCount, icon, _, effectType, abilityType, _, abilityId = GetUnitBuffInfo('reticleover', i)
		local startTime = math.floor(startSec * 1000)
		local endTime = math.floor(endSec * 1000)
		local action = adr.timedEffectActions[startTime]
		if action then
			tinsert(adr.actions, action.abilityId, action)
		end
	end
end

function adr.OnUpdate()
	-- 0. clear obsolete actions
	local now = GetGameTimeMilliseconds()
	adr.UtilRefineActions()
	-- 1. show in action bar widgets
	for key,action in pairs(adr.actions) do
		action.inBar = false
	end
	local cooldownThickness = adr.savedVars.cooldownVisible and adr.savedVars.cooldownThickness or 0
	for slotNum = 3,7 do
		local widget = adr.actionBarWidgets[slotNum]
		local abilityId = GetSlotBoundId(slotNum)
		if adr.actions[abilityId] then
			local action = adr.actions[abilityId]
			action.inBar = true
			if not widget then
				local slot = ZO_ActionBar_GetButton(slotNum).slot
				local slotIcon = slot:GetNamedChild("Icon")
				local flipCard = slot:GetNamedChild("FlipCard")
				widget = {}
				adr.actionBarWidgets[slotNum] = widget
				widget.slotIcon = slotIcon
				widget.flipCard = flipCard
				widget.label = WINDOW_MANAGER:CreateControl(nil, slotIcon, CT_LABEL)
				widget.label:SetFont(adr.UtilGetLabelFont())
				widget.label:SetColor(1,1,1)
				widget.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
				widget.label:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
				widget.label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
				widget.label:SetAnchor(BOTTOM, slotIcon, BOTTOM, 0, adr.savedVars.labelYOffset + 5)
				widget.label:SetDrawLayer(DL_TEXT)
				widget.countLabel = WINDOW_MANAGER:CreateControl(nil, slotIcon, CT_LABEL)
				widget.countLabel:SetFont(adr.UtilGetLabelFont())
				widget.countLabel:SetColor(1,1,1)
				widget.countLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
				widget.countLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
				widget.countLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
				widget.countLabel:SetAnchor(TOPRIGHT, slotIcon, TOPRIGHT, 0, - adr.savedVars.labelYOffset - 5)
				widget.countLabel:SetDrawLayer(DL_TEXT)
				widget.cd = WINDOW_MANAGER:CreateControl(nil, slot, CT_COOLDOWN)
				widget.cd:SetDrawLayer(DL_BACKGROUND)
				widget.cd:SetAnchor( CENTER, flipCard, CENTER)
				local slotWidth,slotHeight = slot:GetDimensions()
				widget.cd:SetDimensions( slotWidth, slotHeight)
				widget.cd:SetFillColor(unpack(adr.savedVars.cooldownColor))
				if adr.savedVars.cooldownOpacity < 100 then widget.cd:SetAlpha(adr.savedVars.cooldownOpacity/100) end
				widget.cdMark = 0
			end
			adr.UpdateWidget(widget, action, now)
			local flipParent = widget.flipCard:GetParent()
			if not widget.flipCardOldSize then widget.flipCardOldSize,_ =  widget.flipCard:GetDimensions() end
			local currentSize,_ = widget.flipCard:GetDimensions()
			local flipChanged = currentSize ~= widget.flipCardOldSize
			if now > action.endTime then
				if flipChanged then
					widget.flipCard:SetDimensions(widget.flipCardOldSize, widget.flipCardOldSize)
				end
			else
				if cooldownThickness > 0 and not flipChanged then
					local newSize = widget.flipCardOldSize-2*cooldownThickness
					widget.flipCard:SetDimensions(newSize, newSize)
				end
			end
		elseif widget then
			widget.label:SetHidden(true)
			widget.countLabel:SetHidden(true)
			widget.cd:SetHidden(true)
			widget.visible = false
			local _,_,_,_,flipOffset =  widget.flipCard:GetAnchor(0)
			if flipOffset>0 then
				local flipParent = widget.flipCard:GetParent()
				widget.flipCard:ClearAnchors()
				widget.flipCard:SetAnchor(TOPLEFT, flipParent, TOPLEFT, 0, 0)
				widget.flipCard:SetAnchor(BOTTOMRIGHT, flipParent, BOTTOMRIGHT, 0, 0)
			end
		end
	end
	-- 2. others show in shift bar
	-- 2.0 hide shift bar
	local function hideShiftBarWidget(widget)
		widget.bd:SetHidden(true)
		widget.bg:SetHidden(true)
		widget.label:SetHidden(true)
		widget.countLabel:SetHidden(true)
		widget.cd:SetHidden(true)
		widget.visible = false
	end
	for slotNum,widget in pairs(adr.actionShiftBarWidgets) do hideShiftBarWidget(widget) end
	for slotNum,widget in pairs(adr.actionShiftAppendBarWidgets) do hideShiftBarWidget(widget) end
	-- 2.1 collect abilities not shown in action bar
	if adr.savedVars.showShiftActions then
		local extraIdList = {}
		for id,action in pairs(adr.actions) do
			if not action.inBar then
				tinsert(extraIdList,id)
			end
		end
		-- 2.2 sort by start time, later abilities will be processed first
		tsort(extraIdList, function(id1,id2)return adr.actions[id1].startTime > adr.actions[id2].startTime end)
		-- 2.3 show valid
		local offsetX = adr.savedVars.shiftBarOffsetX
		local offsetY = adr.savedVars.shiftBarOffsetY
		local numAppend = 0
		for i=1,#extraIdList do
			local abilityId = extraIdList[i]
			local action = adr.actions[abilityId]
			local slotNum = action.slotNum
			local slot = ZO_ActionBar_GetButton(slotNum).slot
			local widget = adr.actionShiftBarWidgets[slotNum]
			local inAppend = adr.pairUltimate and ( action.pairIndex ~= adr.pairIndex ) or action.pairUltimate
			if not inAppend and not widget then
				widget = {}
				adr.actionShiftBarWidgets[slotNum] = widget
				widget.bd = WINDOW_MANAGER:CreateControl(nil, slot, CT_TEXTURE)
				widget.bd:SetDrawLayer(DL_BACKGROUND)
				widget.bd:SetAnchor(BOTTOM, slot, TOP, offsetX, offsetY - adr.savedVars.positionGap)
				widget.bd:SetDimensions(50-math.max(0,cooldownThickness-2),50-math.max(0,cooldownThickness-2))
				widget.bd:SetTexture("EsoUI\\Art\\ChatWindow\\chatOptions_bgColSwatch_frame.dds")
				widget.bd:SetTextureCoords(0, .625, 0, .8125)
				widget.bg = WINDOW_MANAGER:CreateControl(nil, widget.bd, CT_TEXTURE)
				widget.bg:SetDrawLayer(DL_CONTROLS)
				widget.bg:SetAnchor(TOPLEFT, widget.bd, TOPLEFT, 2, 2)
				widget.bg:SetAnchor(BOTTOMRIGHT, widget.bd, BOTTOMRIGHT, -2, -2 )
				widget.label = WINDOW_MANAGER:CreateControl(nil, widget.bg, CT_LABEL)
				widget.label:SetFont(adr.UtilGetLabelFont())
				widget.label:SetColor(1,1,1)
				widget.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
				widget.label:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
				widget.label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
				widget.label:SetAnchor(BOTTOM, widget.bg, BOTTOM, 0, adr.savedVars.labelYOffset + 5)
				widget.countLabel = WINDOW_MANAGER:CreateControl(nil, widget.bg, CT_LABEL)
				widget.countLabel:SetFont(adr.UtilGetLabelFont())
				widget.countLabel:SetColor(1,1,1)
				widget.countLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
				widget.countLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
				widget.countLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
				widget.countLabel:SetAnchor(TOPRIGHT, widget.bg, TOPRIGHT, 0, - adr.savedVars.labelYOffset - 5)
				widget.cd = WINDOW_MANAGER:CreateControl(nil, widget.bg, CT_COOLDOWN)
				widget.cd:SetAnchor( TOPLEFT, widget.bg, TOPLEFT, -cooldownThickness,-cooldownThickness )
				widget.cd:SetAnchor( BOTTOMRIGHT, widget.bg, BOTTOMRIGHT,cooldownThickness, cooldownThickness )
				widget.cd:SetDrawLayer(DL_BACKGROUND)
				widget.cd:SetFillColor(unpack(adr.savedVars.cooldownColor))
				if adr.savedVars.cooldownOpacity < 100 then widget.cd:SetAlpha(adr.savedVars.cooldownOpacity/100) end
				widget.cdMark = 0
			elseif inAppend or widget.visible then
				numAppend = numAppend + 1
				widget = adr.actionShiftAppendBarWidgets[numAppend]
				if not widget then
					widget = {}
					adr.actionShiftAppendBarWidgets[numAppend] = widget
					slot = ZO_ActionBar_GetButton(8).slot
					widget.bd = WINDOW_MANAGER:CreateControl(nil, slot, CT_TEXTURE)
					widget.bd:SetDrawLayer(DL_BACKGROUND)
					widget.bd:SetAnchor(BOTTOM, slot, TOP, offsetX + (numAppend-1) * (50+adr.savedVars.positionGap), offsetY - adr.savedVars.positionGap)
					widget.bd:SetDimensions(50-math.max(0,cooldownThickness-2),50-math.max(0,cooldownThickness-2))
					widget.bd:SetTexture("EsoUI\\Art\\ChatWindow\\chatOptions_bgColSwatch_frame.dds")
					widget.bd:SetTextureCoords(0, .625, 0, .8125)
					widget.bg = WINDOW_MANAGER:CreateControl(nil, widget.bd, CT_TEXTURE)
					widget.bg:SetDrawLayer(DL_CONTROLS)
					widget.bg:SetAnchor(TOPLEFT, widget.bd, TOPLEFT, 2, 2)
					widget.bg:SetAnchor(BOTTOMRIGHT, widget.bd, BOTTOMRIGHT, -2, -2 )
					widget.label = WINDOW_MANAGER:CreateControl(nil, widget.bg, CT_LABEL)
					widget.label:SetFont(adr.UtilGetLabelFont())
					widget.label:SetColor(1,1,1)
					widget.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
					widget.label:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
					widget.label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
					widget.label:SetAnchor(BOTTOM, widget.bg, BOTTOM, 0, adr.savedVars.labelYOffset + 5)
					widget.countLabel = WINDOW_MANAGER:CreateControl(nil, widget.bg, CT_LABEL)
					widget.countLabel:SetFont(adr.UtilGetLabelFont())
					widget.countLabel:SetColor(1,1,1)
					widget.countLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
					widget.countLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
					widget.countLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
					widget.countLabel:SetAnchor(TOPRIGHT, widget.bg, TOPRIGHT, 0, - adr.savedVars.labelYOffset - 5)
					widget.cd = WINDOW_MANAGER:CreateControl(nil, widget.bg, CT_COOLDOWN)
					widget.cd:SetAnchor( TOPLEFT, widget.bg, TOPLEFT, -cooldownThickness,-cooldownThickness )
					widget.cd:SetAnchor( BOTTOMRIGHT, widget.bg, BOTTOMRIGHT,cooldownThickness, cooldownThickness )
					widget.cd:SetDrawLayer(DL_BACKGROUND)
					widget.cd:SetFillColor(unpack(adr.savedVars.cooldownColor))
					if adr.savedVars.cooldownOpacity < 100 then widget.cd:SetAlpha(adr.savedVars.cooldownOpacity/100) end
					widget.cdMark = 0
				end
			end
			adr.UpdateWidget(widget, action, now)
			if now > action.endTime then
				widget.bd:SetDimensions(50,50)
			else
				widget.bd:SetDimensions(50-math.max(0,cooldownThickness-2),50-math.max(0,cooldownThickness-2))
			end
		end
	end
	
	-- 3. Reposition Health Bar
	adr.rrb.Reposition()
end

function adr.OnUpdateCooldowns(eventCode)
	if adr.lastGroundSlotNum > 0 then
		local now = GetGameTimeMilliseconds()
		adr.lastGroundAction = {
			confirmTime = now,
			slotNum = adr.lastGroundSlotNum,
		}
		adr.lastGroundSlotNum = 0
	end
end

function adr.UpdateWidget(widget, action, now)
	widget.visible = true
	if widget.bd then widget.bd:SetHidden(false) end
	if widget.bg then
		widget.bg:SetTexture(action.abilityIcon)
		widget.bg:SetHidden(false)
	end
	local remain = math.max(action.endTime-now,0)
	local hint = sformat('%.1f', remain/1000)
	widget.label:SetText(hint)
	widget.label:SetHidden(false)
	if action.stackCount ~= nil and action.stackCount > 0 then
		widget.countLabel:SetText(action.stackCount)
		widget.countLabel:SetHidden(false)
	else
		widget.countLabel:SetHidden(true)
	end
	local cdMark = action.endTime
	if remain > 7000 and action.duration > 8000 then
		cdMark = action.endTime - 7000
		if widget.cdMark ~= cdMark then
			widget.cdMark = cdMark
			local scale = action.duration/1000 - 7
			local scaledTotal = action.duration * scale
			local scaledRemain = remain * scale
			widget.cd:StartCooldown(scaledRemain, scaledTotal, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false )
		end
	elseif remain > 0 then
		if widget.cdMark ~= cdMark then
			widget.cdMark = cdMark
			widget.cd:StartCooldown(remain, 8000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false )
		end
	else
		widget.cdMark = 0
		local numSemiSeconds = math.floor((now-action.endTime)/200)
		if numSemiSeconds % 2 == 0 then 
			--if action.inBar then widget.label:SetColor(0,1,0) else widget.label:SetColor(1,0,0) end
			widget.label:SetHidden(true)
		end
	end
	local cdHidden = cdMark==0 or not adr.savedVars.cooldownVisible
	widget.cd:SetHidden(cdHidden)
end

function adr.Hook()
	EVENT_MANAGER:RegisterForUpdate(adr.name, 100, adr.OnUpdate)
	EVENT_MANAGER:RegisterForEvent(adr.name, EVENT_ACTION_SLOTS_FULL_UPDATE, adr.OnSlotsFullUpdate )
	EVENT_MANAGER:RegisterForEvent(adr.name, EVENT_ACTION_SLOT_ABILITY_USED, adr.OnSlotAbilityUsed)
	EVENT_MANAGER:RegisterForEvent(adr.name, EVENT_ACTION_UPDATE_COOLDOWNS,	adr.OnUpdateCooldowns )
	EVENT_MANAGER:RegisterForEvent(adr.name, EVENT_EFFECT_CHANGED, adr.OnEffectChanged )
	EVENT_MANAGER:RegisterForEvent(adr.name, EVENT_RETICLE_TARGET_CHANGED,	adr.OnTargetChanged)
end

-- $. Addon
local function OnAddOnLoaded(eventCode, addonName)
	-- check and clear
	if adr.name ~= addonName then return end
	EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
	--
	adr.SettingsLoad()
	adr.SettingsMenu()
	adr.Create()
	adr.Hook()
end

EVENT_MANAGER:RegisterForEvent(adr.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)