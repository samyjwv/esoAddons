-- 0.
local adr = ActionDurationReminder
adr.rrb = {} -- rrb for RepositionResourceBar
local rrb = adr.rrb
rrb.hudInfo = {}

function rrb.Reposition()
	-- 1. check if we have done
	local shiftBarVisible = false
	if adr.savedVars.showShiftActions then
		for id,action in pairs(adr.actions) do
			if not action.inBar then
				shiftBarVisible = true
				break
			end
		end
	end
	if not shiftBarVisible and not rrb.shifted then return end
	if shiftBarVisible and rrb.shifted then return end
	-- 2. collect info
	local gap = adr.savedVars.positionGap
	local hudTable = {
		hb = ZO_PlayerAttributeHealth,
		mb = ZO_PlayerAttributeMagicka,
		sb = ZO_PlayerAttributeStamina,
	}
	-- 2.1 record their original info
	for name,hud in pairs(hudTable) do 
		if not rrb.hudInfo[name] then
			local _, point, relativeTo, relativePoint, offsetX, offsetY = hud:GetAnchor(0)
			local bottom = hud:GetBottom()
			rrb.hudInfo[name] = {
				point = point,
				relativeTo = relativeTo,
				relativePoint = relativePoint,
				offsetX = offsetX,
				offsetY = offsetY,
				bottom = bottom,
			}
		end
	end
	
	-- 2.2 compute newRect
	if not rrb.newRectReady then
		local rectList = {}
		local tinsert = table.insert
		local slot3 = ZO_ActionBar_GetButton(3).slot
		local slot7 = ZO_ActionBar_GetButton(7).slot
		local shiftY = -50 - gap
		local offsetX = adr.savedVars.shiftBarOffsetX
		local offsetY = adr.savedVars.shiftBarOffsetY
		tinsert(rectList,{
			top = slot3:GetTop() + shiftY + offsetY,
			bottom = slot3:GetBottom() + shiftY + offsetY,
			left = slot3:GetLeft() + offsetX,
			right = slot7:GetRight() + offsetX,
		})
		local nameList = {'hb','mb','sb'}
		table.sort(nameList, function(name1, name2)
			return hudTable[name1]:GetBottom()> hudTable[name2]:GetBottom()
		end)
		for index = 1,#nameList do
			local name = nameList[index]
			local hud = hudTable[name]
			local hudRect, newOffsetY, newBottom = rrb.ComputeNewOffsetY(rectList, name, hud, gap)
			tinsert(rectList, hudRect)
			rrb.hudInfo[name].newRect = hudRect
		end
		rrb.newRectReady = true
	end
	-- 3. check bottom to set anchor
	for name,hud in pairs(hudTable) do
		local info = rrb.hudInfo[name]
		local bottom = shiftBarVisible and info.newRect.bottom or info.bottom
		if bottom ~= hud:GetBottom() then
			hud:ClearAnchors()
			if shiftBarVisible then
				hud:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, info.newRect.left, info.newRect.top)
				hud:SetAnchor(BOTTOMRIGHT, GuiRoot, TOPLEFT, info.newRect.right, info.newRect.bottom)
			else
				hud:SetAnchor(info.point, info.relativeTo, info.relativePoint, info.offsetX, info.offsetY)
			end
		end
	end
	-- 4. reset data
	rrb.shifted = shiftBarVisible
	if not shiftBarVisible then
		rrb.hudInfo = {}
		rrb.newRectReady = false 
	end
end

function rrb.ComputeNewOffsetY(rectList, name, hud, gap)
	local hudRect = {
		left = hud:GetLeft(),
		right = hud:GetRight(),
		top = hud:GetTop(), -- bar have out margin
		bottom = hud:GetBottom(), -- bar have out margin
	}
	local delta = 0
	for _,rect in pairs(rectList) do
		delta = delta + rrb.MoveUp(hudRect, rect, gap)
	end
	return hudRect, rrb.hudInfo[name].offsetY + delta, rrb.hudInfo[name].bottom + delta
end

function rrb.MoveUp(movingRect, rect, gap)
	if movingRect.left > rect.right or movingRect.right < rect.left then return 0 end
	if movingRect.bottom + gap < rect.top or movingRect.top - gap > rect.bottom then return 0 end
	local delta = rect.top - gap - movingRect.bottom
	movingRect.top = movingRect.top + delta
	movingRect.bottom = movingRect.bottom + delta
	return delta
end