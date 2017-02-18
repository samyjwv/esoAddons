AG.name = 'AlphaGear'
AG.version = '5.00'
AG.init = false
AG.account = {}
AG.setdata = {}
local L, ZOSF = AG[GetCVar('language.2')] or AG.en, zo_strformat
local MAXSLOT, MENU, SELECT, SELECTBAR, DRAGINFO, TTANI, SWAP = 16, { nr = nil, type = nil, copy = nil }, false, false, {}, false, false
local EM, WM, SM, ICON, MARK, PREBAG = EVENT_MANAGER, WINDOW_MANAGER, SCENE_MANAGER, {}, {}, nil
local IDLE, OPT, GEARQUEUE, SLOTS, DUPSLOTS = 0, {}, {}, {
{EQUIP_SLOT_MAIN_HAND,'mainhand','MainHand'},
{EQUIP_SLOT_OFF_HAND,'offhand','OffHand'},
{EQUIP_SLOT_BACKUP_MAIN,'mainhand','BackupMain'},
{EQUIP_SLOT_BACKUP_OFF,'offhand','BackupOff'},
{EQUIP_SLOT_HEAD,'head','Head'},
{EQUIP_SLOT_CHEST,'chest','Chest'},
{EQUIP_SLOT_LEGS,'legs','Leg'},
{EQUIP_SLOT_SHOULDERS,'shoulders','Shoulder'},
{EQUIP_SLOT_FEET,'feet','Foot'},
{EQUIP_SLOT_WAIST,'belt','Belt'},
{EQUIP_SLOT_HAND,'hands','Glove'},
{EQUIP_SLOT_NECK,'neck','Neck'},
{EQUIP_SLOT_RING1,'ring','Ring1'},
{EQUIP_SLOT_RING2,'ring','Ring2'}},
{1,2,3,4,13,14}

-- GetColor does something
local function GetColor(val,a)
	local r,g = 0,0
	if val >= 50 then r = 100-((val-50)*2); g = 100 else r = 100; g = val*2 end
	return r/100, g/100, 0, a
end

-- Quality does something
local function Quality(link,a)
	local QUALITY = {[0]={0.65,0.65,0.65,a},[1]={1,1,1,a},[2]={0.17,0.77,0.05,a},[3]={0.22,0.57,1,a},[4]={0.62,0.18,0.96,a},[5]={0.80,0.66,0.10,a}}
	return unpack(QUALITY[GetItemLinkQuality(link)])
end

-- Zero does something
local function Zero(val) if val == 0 then return nil else return val end end

-- Hide does something
local function Hide(c) c:SetHidden(true); c:SetWidth(0) end

-- Show does the opposite of Hide
local function Show(c) c:SetHidden(false); c:SetWidth(50) end

-- AG.DrawMenu reveals or hides the menu when invoked
function AG.DrawMenu(c,line)
	AG_PanelMenu:ToggleHidden()
	AG_PanelMenu:SetAnchor(3,c,6,0,0)
	local h, c = 0
	for z,x in pairs(line) do
		c = AG_PanelMenu:GetChild(z)
		if x then
			h = h + 30
			c:SetHeight(30)
			c:SetHidden(false)
		else
			c:SetHeight(0)
			c:SetHidden(true)
		end
	end
	AG_PanelMenu:SetHeight(h + 20)
end

-- AG.DrawInventory probably draws the 
function AG.DrawInventory()
	for _,c in pairs(SLOTS) do
		local p = WM:GetControlByName('ZO_CharacterEquipmentSlots'..c[3])
		local s = WM:CreateControl('AG_InvBg'..c[1], p, CT_TEXTURE)
		s:SetHidden(true)
		s:SetDrawLevel(1)
		s:SetTexture('AlphaGear/hole.dds')
		s:SetAnchorFill()
		s = WM:CreateControl('AG_InvBg'..c[1]..'Condition', p, CT_LABEL)
		s:SetFont('ZoFontGameSmall')
		s:SetAnchor(TOPRIGHT,p,TOPRIGHT,7,-8)
		s:SetDimensions(50,10)
		s:SetHidden(true)
		s:SetHorizontalAlignment(2)
	end
end

-- I guess AG.DrawButton draws buttons in the UI
function AG.DrawButton(p,name,btn,nr,x,xpos,ypos,show)
	local c = WM:CreateControl('AG_'..name..'_'..btn..'_'..nr..'_'..x, p, CT_BUTTON)
	if show then c:SetAnchor(3,p,3,xpos,ypos) else c:SetAnchor(2,p,2,xpos,ypos) end
	c:SetDrawTier(1)
	c:SetDimensions(40,40)
	c:SetMouseOverTexture('AlphaGear/light.dds')
	c:SetHandler('OnMouseEnter',function(self) AG.Tooltip(self,true,show) end)
	c:SetHandler('OnMouseExit',function(self) AG.Tooltip(self,false,show) end)
	local b = WM:CreateControl('AG_'..name..'_'..btn..'_'..nr..'_'..x..'Bg', c, CT_BACKDROP)
	b:SetAnchor(128,c,128,0,0)
	b:SetDimensions(44,44)
	b:SetCenterColor(0,0,0,0.2)
	b:SetEdgeColor(0,0,0,0)
	b:SetEdgeTexture('',1,1,2)
	b:SetInsets(2,2,-2,-2)
	if not show then
		c:SetClickSound('Click')
		c:EnableMouseButton(2,true)
		c:SetHandler('OnReceiveDrag',function(self) AG.OnDragReceive(self) end)
		if btn == 'Gear' then c:SetHandler('OnMouseDown',function(self,button,ctrl,alt,shift)
			if button == 2 then AG.setdata[nr].Gear[x] = { id = 0, link = 0 }; AG.ShowButton(self)
			elseif shift then if button == 1 then
				if GetItemInstanceId(BAG_WORN,SLOTS[x][1]) then
					AG.setdata[nr].Gear[x] = { id = Id64ToString(GetItemUniqueId(BAG_WORN,SLOTS[x][1])), link = GetItemLink(BAG_WORN,SLOTS[x][1]) }
				else AG.setdata[nr].Gear[x] = { id = 0, link = 0 } end
				AG.ShowButton(self)
			end
			elseif button == 1 then AG.LoadItem(nr,x) end
		end) end
		if btn == 'Skill' then c:SetHandler('OnMouseDown',function(self,button,ctrl,alt,shift)
			if button == 2 then AG.setdata[nr].Skill[x] = 0; AG.ShowButton(self)
			elseif shift then if button == 1 then AG.setdata[nr].Skill[x] = GetSlotBoundId(x+2); AG.ShowButton(self) end
			elseif button == 1 then AG.LoadSkill(nr,x) end end) end
		AG.ShowButton(c)
	end
end

-- AG.DrawButtonLine I suppose draws lines?
function AG.DrawButtonLine(mode,nr)
	local dim,count,btn,c,p = {635,299},{14,6},{'Gear','Skill'}
	if mode == 1 then p = WM:CreateControl('AG_Selector_Gear_'..nr, AG_PanelGearPanelScrollChild, CT_BUTTON)
	else p = WM:CreateControl('AG_Selector_Skill_'..nr, AG_PanelSkillPanelScrollChild, CT_BUTTON) end
	p:SetAnchor(3,nil,3,0,45*(nr-1))
	p:SetDimensions(dim[mode],44)
	p:SetClickSound('Click')
	p:EnableMouseButton(2,true)
	p:SetNormalTexture('AlphaGear/grey.dds')
	p:SetMouseOverTexture('AlphaGear/light.dds')
	p.data = { header = '|cFFAA33'..L.Head[btn[mode]]..nr..'|r', info = L.Selector[btn[mode]] }
	p:SetHandler('OnMouseEnter',function(self) AG.Tooltip(self,true) end)
	p:SetHandler('OnMouseExit',function(self) AG.Tooltip(self,false) end)
	if mode == 1 then p:SetHandler('OnMouseDown',function(self,button,ctrl,alt,shift)
		if button == 2 then AG.DrawMenu(self,{true,(MENU.copy and MENU.type == 1),true,true}); MENU.nr = nr; MENU.type = mode
		elseif shift then if button == 1 then MENU.type = mode; MENU.nr = nr; AG.MenuAction(3); AG.UpdateEditPanel(SELECT) end
		elseif button == 1 then if SELECTBAR then AG.setdata[SELECT].Set.gear = nr; SELECTBAR = false; AG.SetConnect(3,2); AG.UpdateEditPanel(SELECT) else AG.LoadGear(nr) end end
	end) end
	if mode == 2 then p:SetHandler('OnMouseDown',function(self,button,ctrl,alt,shift)
		if button == 2 then AG.DrawMenu(self,{true,(MENU.copy and MENU.type == 2),true,true}); MENU.nr = nr; MENU.type = mode
		elseif shift then if button == 1 then AG.GetSkillFromBar(nr); AG.UpdateEditPanel(nr) end
		elseif button == 1 then if SELECTBAR then AG.setdata[SELECT].Set.skill[SELECTBAR] = nr; SELECTBAR = false; AG.SetConnect(1,2); AG.UpdateEditPanel(SELECT) else AG.LoadBar(nr) end end 
	end) end
	c = WM:CreateControl('AG_Selector_'..btn[mode]..'_'..nr..'_Label', p, CT_LABEL)
	c:SetAnchor(3,p,3,0,0)
	c:SetDrawTier(1)
	c:SetDimensions(44,44)
	c:SetHorizontalAlignment(1)
	c:SetVerticalAlignment(1)
	c:SetFont('AGFontBold')
	c:SetColor(1,1,1,0.8)
	c:SetText(nr)
	for x = 1,count[mode] do AG.DrawButton(p,'Button',btn[mode],nr,x,46+42*(x-1),0) end
end

-- AG.DrawOptions probably draws the option box you can click inside the main UI
function AG.DrawOptions(set)
	local val, tex = {[true]='checked',[false]='unchecked'}, '|t16:16:esoui/art/buttons/checkbox_<<1>>.dds|t |t2:2:x.dds|t '
	local rows,row,opt = {6,8,11,13},1,1
	if not set then
		local w,c = L.OptionWidth
		for count = 1,#L.Options + #rows do
			if rows[row] == opt then
				c = WM:CreateControl('AG_OptionRow_'..row, AG_PanelOptionPanel, CT_BUTTON)
				c:SetAnchor(3,AG_PanelOptionPanel,3,10,10+(count-1)*25)
				c:SetDimensions(w-20,25)
				c:SetNormalTexture('AlphaGear/row.dds')
				row = row + 1
			else
				c = WM:CreateControl('AG_Option_'..opt, AG_PanelOptionPanel, CT_BUTTON)
				c:SetAnchor(3,AG_PanelOptionPanel,3,10,10+(count-1)*25)
				c:SetDimensions(w-20,25)
				c:SetNormalFontColor(1,1,1,1)
				c:SetMouseOverFontColor(1,0.66,0.2,1)
				c:SetFont('ZoFontGame')
				c:SetHorizontalAlignment(0)
				c:SetVerticalAlignment(1)
				c:SetClickSound('Click')
				c.data = { option = opt }
				c:SetHandler('OnClicked',function(self) AG.DrawOptions(self.data.option) end)
				c:SetText(ZOSF(tex,val[OPT[opt]])..L.Options[opt])
				opt = opt + 1
			end
		end
		AG_PanelOptionPanel:SetDimensions(w,(opt+row-2)*25+20)
	else
		AG.account.option[set] = not AG.account.option[set]
		OPT = AG.account.option
		WM:GetControlByName('AG_Option_'..set):SetText(ZOSF(tex,val[OPT[set]])..L.Options[set])
		AG.SetOptions()
	end
end

-- AG.DrawSet ???
function AG.DrawSet(nr)
	local p,l,s = WM:GetControlByName('AG_SetSelector_'..(nr-1)) or false
	local function Slide(sc,fc,sa)
		local ani = ANIMATION_MANAGER:CreateTimeline()
		local slide = ani:InsertAnimation(ANIMATION_SIZE,sc)
		local fade = ani:InsertAnimation(ANIMATION_ALPHA,fc,145)
		fc:SetHidden(not fc:IsHidden())
		fc:SetAlpha(0)
		fade:SetAlphaValues(0,1)
		fade:SetDuration(100)
		slide:SetStartAndEndHeight(76,408)
		slide:SetStartAndEndWidth(311,311)
		slide:SetDuration(150)
		if sa then ani:PlayFromStart() else ani:PlayFromEnd() end
	end
	s = WM:CreateControl('AG_SetSelector_'..nr, AG_PanelSetPanelScrollChild, CT_BUTTON)
	if p then s:SetAnchor(1,p,4,0,5) else s:SetAnchor(3,nil,3,0,0) end
	s:SetDimensions(311,76)
	s:SetClickSound('Click')
	s:EnableMouseButton(2,true)
	s:SetNormalTexture('AlphaGear/grey.dds')
	s:SetMouseOverTexture('AlphaGear/light.dds')
	s.setnr = nr
	s:SetHandler('OnMouseEnter',function(self) AG.Tooltip(self,true) end)
	s:SetHandler('OnMouseExit',function(self) AG.Tooltip(self,false) end)
	s:SetHandler('OnMouseDown',function(self,button)
		if button == 2 then
			local k,anchor = AG_PanelSetPanelScrollChildEditPanel
			anchor = {k:GetAnchor()}
			if anchor[3] and anchor[3] ~= self then
				anchor[3]:SetHeight(76)
				k:SetHidden(true)
				anchor[3]:GetNamedChild('Box'):SetHidden(false)
				anchor[3]:GetNamedChild('Edit'):SetHidden(true)
			end
			k:ClearAnchors()
			k:SetAnchor(6,self,6,2,-2)
			Slide(self,k,k:IsHidden())
			WM:GetControlByName('AG_SetSelector_'..nr..'Box'):ToggleHidden()
			WM:GetControlByName('AG_SetSelector_'..nr..'Edit'):ToggleHidden()
			AG.UpdateEditPanel(self.setnr)
			AG_PanelIcons:SetHidden(true)
			SELECT = nr
		elseif button == 1 then AG.LoadSet(nr) end
	end)
	l = WM:CreateControl('AG_SetSelector_'..nr..'Label', s, CT_LABEL)
	l:SetAnchor(3,s,3,0,0)
	l:SetDrawTier(1)
	l:SetDimensions(44,44)
	l:SetHorizontalAlignment(1)
	l:SetVerticalAlignment(1)
	l:SetFont('AGFontBold')
	l:SetColor(1,1,1,0.8)
	l:SetText(nr)
	l = WM:CreateControl('AG_SetSelector_'..nr..'KeyBind', s, CT_LABEL)
	l:SetAnchor(9,s,9,-15,0)
	l:SetDrawTier(1)
	l:SetDimensions(235,44)
	l:SetHorizontalAlignment(2)
	l:SetVerticalAlignment(1)
	l:SetFont('AGFont')
	l:SetColor(1,1,1,0.5)
	l = WM:CreateControl('AG_SetSelector_'..nr..'Box', s, CT_LABEL)
	l:SetAnchor(3,s,3,2,44)
	l:SetDrawTier(1)
	l:SetDimensions(307,30)
	l:SetHorizontalAlignment(0)
	l:SetVerticalAlignment(1)
	l:SetFont('AGFont')
	l:SetColor(1,1,1,1)
	p = WM:CreateControlFromVirtual('AG_SetSelector_'..nr..'Edit', s, 'ZO_DefaultEditForBackdrop')
	p:ClearAnchors()
	p:SetAnchor(128,l,128,0,4)
	p:SetDimensions(293,30)
	p:SetFont('AGFont')
	p:SetColor(1,1,1,1)
	p:SetMaxInputChars(100)
	p:SetHidden(true)
	p:SetHandler('OnFocusLost',function(self)
		AG.setdata[nr].Set.text[1] = self:GetText()
		self:LoseFocus()
		AG.UpdateUI(nr,nr)
	end)
	p:SetHandler('OnEscape',function(self) self:LoseFocus() end)
	p:SetHandler('OnEnter',function(self) self:LoseFocus() end)
	p = WM:CreateControl('AG_SetSelector_'..nr..'BoxBg', s, CT_BACKDROP)
	p:SetDrawTier(1)
	p:SetAnchor(128,l,128,0,0)
	p:SetDimensions(307,30)
	p:SetCenterColor(0,0,0,0.2)
	p:SetEdgeColor(0,0,0,0)
	p:SetEdgeTexture('',1,1,2)
end

-- AG.DrawSetButtonsUI probably draws the buttons
function AG.DrawSetButtonsUI()
	local xpos,ypos,c = 0,0
	for x = 1,MAXSLOT do
		c = WM:GetControlByName('AG_UI_SetButton_'..x)
		if not c then 
			c = WM:CreateControl('AG_UI_SetButton_'..x, AG_SetButtonFrame, CT_BUTTON)
			c:SetDimensions(24,24)
			c:SetHorizontalAlignment(1)
			c:SetVerticalAlignment(1)
			c:SetClickSound('Click')
			c:SetFont('AGFontSmall')
			c:SetNormalFontColor(1,1,1,1)
			c:SetMouseOverFontColor(1,0.66,0.2,1)
			c:SetText(x)
			c:SetNormalTexture('AlphaGear/grey.dds')
			c:SetMouseOverTexture('AlphaGear/light.dds')
			c:SetHandler('OnMouseEnter',function(self) AG.TooltipSet(x,true) end)
			c:SetHandler('OnMouseExit',function(self) AG.TooltipSet(x,false) end)
			c:SetHandler('OnClicked',function(self) AG.LoadSet(x) end)
		end
		c:ClearAnchors()
		c:SetAnchor(3,AG_SetButtonFrame,3,xpos,ypos)
		if x > AG.setdata.setamount then c:SetHidden(true) else c:SetHidden(false) end
		if x == math.ceil(AG.setdata.setamount/2) then ypos = ypos + 29; xpos = 0
		else xpos = xpos + 29 end
	end
end

-- AG.GetKey seems to be doing something with shift, alt, and ctrl
function AG.GetKey(keyStr)
	local modifier = ''
	local l,c,a = GetActionIndicesFromName(keyStr)
	local key,m1,m2,m3,m4 = GetActionBindingInfo(l,c,a,1)
	if key ~= KEY_INVALID then
		local shift = ZO_Keybindings_DoesKeyMatchAnyModifiers(KEY_SHIFT,m1,m2,m3,m4)
		local ctrl = ZO_Keybindings_DoesKeyMatchAnyModifiers(KEY_CTRL,m1,m2,m3,m4)
		local alt = ZO_Keybindings_DoesKeyMatchAnyModifiers(KEY_ALT,m1,m2,m3,m4)
		if alt then modifier = modifier..string.format('%s-',string.upper(string.sub(GetString(SI_KEYCODEALT),1,8)))
		elseif ctrl then modifier = modifier..string.format('%s-',string.upper(string.sub(GetString(SI_KEYCODECTRL),1,8)))
		elseif shift then modifier = modifier..string.format('%s-',string.upper(string.sub(GetString(SI_KEYCODESHIFT),1,8))) end
		return modifier..GetKeyName(key)
	else return '' end
end

-- AG.GetButton is doin a thing
function AG.GetButton(c)
	local res, name = {}, {string.match(c:GetName(),'AG_(%a+)_(%a+)_(%d+)_(%d+)')}
	table.insert(res, name[2])
	table.insert(res, tonumber(name[3]))
	table.insert(res, tonumber(name[4]))
	return unpack(res)
end

-- AG.GetSoulgem also doing a thing
function AG.GetSoulgem()
	local result, tier = false, 0
	local bag = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_BACKPACK)
	for _,data in pairs(bag) do
		if IsItemSoulGem(SOUL_GEM_TYPE_FILLED,BAG_BACKPACK,data.slotIndex) then
			local geminfo = GetSoulGemItemInfo(BAG_BACKPACK,data.slotIndex)
			if geminfo > tier then tier = geminfo; result = data.slotIndex end
		end
	end
	return result
end
function AG.GetItemFromBag(id)
	if not id then return false end
	local bag = PREBAG
	if not PREBAG then bag = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_WORN,BAG_BACKPACK) end
	for _,data in pairs(bag) do if id == Id64ToString(data.uniqueId) then return data.bagId, data.slotIndex end end
	return false
end
function AG.GetSetIcon(nr,bar)
	local endicon,gear,icon = nil, AG.setdata[nr].Gear, {
		[WEAPONTYPE_NONE] = 'nothing',
		[WEAPONTYPE_DAGGER] = 'onehand',
		[WEAPONTYPE_HAMMER] = 'onehand',
		[WEAPONTYPE_AXE] = 'onehand',
		[WEAPONTYPE_SWORD] = 'onehand',
		[WEAPONTYPE_TWO_HANDED_HAMMER] = 'twohand',
		[WEAPONTYPE_TWO_HANDED_AXE] = 'twohand',
		[WEAPONTYPE_TWO_HANDED_SWORD] = 'twohand',
		[WEAPONTYPE_FIRE_STAFF] = 'fire',
		[WEAPONTYPE_FROST_STAFF] = 'frost',
		[WEAPONTYPE_LIGHTNING_STAFF] = 'shock',
		[WEAPONTYPE_HEALING_STAFF] = 'heal',
		[WEAPONTYPE_BOW] = 'bow',
		[WEAPONTYPE_SHIELD] = 'shield'
	}
	if bar == 1 then
		if gear[2].link ~= 0 then endicon = icon[GetItemLinkWeaponType(gear[2].link)]
		else endicon = icon[GetItemLinkWeaponType(gear[1].link)] end
	else
		if gear[4].link ~= 0 then endicon = icon[GetItemLinkWeaponType(gear[4].link)]
		else endicon = icon[GetItemLinkWeaponType(gear[3].link)] end
	end
	if endicon then return 'AlphaGear/'..endicon..'.dds' else return nil end
end
function AG.GetSkillFromBar(nr)
	for x = 1,6 do
		AG.setdata[nr].Skill[x] = GetSlotBoundId(x+2) or 0
		AG.ShowButton(WM:GetControlByName('AG_Button_Skill_'..nr..'_'..x))
	end
end
function AG.GetAbility(id)
	local _,pi = GetAbilityProgressionXPInfoFromAbilityId(id)
	local _,mc,rank = GetAbilityProgressionInfo(pi)
	local _,_,ai = GetAbilityProgressionAbilityInfo(pi,mc,rank)
	if ai then return ai else return 0 end
end
function AG.GetSlotted(id)
	for x = 3,8 do if GetSlotBoundId(x) == id then return x end end
	return false
end
function AG.GetSkill(id)
	for a = 1,GetNumSkillTypes() do
		for b = 1,GetNumSkillLines(a) do
			for c = 1,GetNumSkillAbilities(a,b) do
				if GetSkillAbilityId(a,b,c,false) == id then return a,b,c end
			end
		end
	end
	return false
end

function AG.OnDragReceive(c)
	local function Contains(tab,item) for _, value in pairs(tab) do if value == item then return true end end return false end
	local function CheckItems(nr,target)
		local clear, et1, et2 = false, GetItemLinkEquipType(AG.setdata[nr].Gear[1].link), GetItemLinkEquipType(AG.setdata[nr].Gear[3].link)
		if DRAGINFO.type == EQUIP_TYPE_TWO_HAND then
			if target == 1 then clear = 2 elseif target == 3 then clear = 4 end
		elseif DRAGINFO.type == EQUIP_TYPE_ONE_HAND or DRAGINFO.type == EQUIP_TYPE_OFF_HAND then
			if target == 2 and et1 == EQUIP_TYPE_TWO_HAND then clear = 1 elseif target == 4 and et2 == EQUIP_TYPE_TWO_HAND then clear = 3 end
		end
		if clear then
			AG.setdata[nr].Gear[clear] = { id = 0, link = 0 }
			AG.ShowButton(WM:GetControlByName('AG_Button_Gear_'..nr..'_'..clear))
		end
		for _,slot in pairs(DUPSLOTS) do
			if AG.setdata[nr].Gear[slot].id == DRAGINFO.uid then
				AG.setdata[nr].Gear[slot] = { id = 0, link = 0 }
				AG.ShowButton(WM:GetControlByName('AG_Button_Gear_'..nr..'_'..slot))
				return
			end
		end
	end
	local function CheckSkills(nr)
		for x = 1,5 do
			if AG.setdata[nr].Skill[x] == DRAGINFO.id then
				AG.setdata[nr].Skill[x] = 0
				AG.ShowButton(WM:GetControlByName('AG_Button_Skill_'..nr..'_'..x))
				return
			end
		end
	end
	local function DragItem(btn)
		local _, nr, slot = AG.GetButton(btn)
		if DRAGINFO.uid and Contains(DRAGINFO.slot,slot)then
			if Contains(DUPSLOTS,slot) then CheckItems(nr,slot) end
			AG.setdata[nr].Gear[slot] = { id = DRAGINFO.uid, link = DRAGINFO.link }
			AG.ShowButton(btn)
			ClearCursor()
			PlaySound('Tablet_PageTurn')
		end
	end
	local function DragSkill(btn)
		local _, nr, slot = AG.GetButton(btn)
		if DRAGINFO.id then
			if (not DRAGINFO.ultimate and slot < 6) or (DRAGINFO.ultimate and slot == 6) then
				if slot < 6 then CheckSkills(nr) end
				AG.setdata[nr].Skill[slot] = DRAGINFO.id
				AG.ShowButton(btn)
				ClearCursor()
				PlaySound('Tablet_PageTurn')
			end
		end
	end
	local cursor = GetCursorContentType()
	if cursor == MOUSE_CONTENT_INVENTORY_ITEM or cursor == MOUSE_CONTENT_EQUIPPED_ITEM then DragItem(c)
	elseif cursor == MOUSE_CONTENT_ACTION then DragSkill(c) end
end
function AG.OnSkillDragStart(c)
    if GetCursorContentType() == MOUSE_CONTENT_EMPTY and not AG_Panel:IsHidden() then
		local _,_,_,_,ultimate,active = GetSkillAbilityInfo(c.skillType, c.lineIndex, c.index)
		if active then
			DRAGINFO.id			= GetSkillAbilityId(c.skillType,c.lineIndex,c.index,false)
			DRAGINFO.ultimate	= ultimate
			DRAGINFO.source 	= c
			DRAGINFO.slot 		= {1,2,3,4,5}
			if ultimate then DRAGINFO.slot = {6} end
			AG.SetCallout('Skill',1)
			c:RegisterForEvent(EVENT_CURSOR_DROPPED, function() AG.SetCallout('Skill',0) end)
		end
    end
end
function AG.OnItemDragStart(invSlot)
    if GetCursorContentType() == MOUSE_CONTENT_EMPTY and not AG_Panel:IsHidden() then
		local bag, slot
		if invSlot.dataEntry then bag, slot = invSlot.dataEntry.data.bagId, invSlot.dataEntry.data.slotIndex
		else bag, slot = invSlot.bagId, invSlot.slotIndex end
		local _,_,_,_,_,et = GetItemInfo(bag, slot)
		if et ~= EQUIP_TYPE_INVALID then
			local gear = {
				[EQUIP_TYPE_HEAD] = { 5 },
				[EQUIP_TYPE_CHEST] = { 6 },
				[EQUIP_TYPE_LEGS] = { 7 },
				[EQUIP_TYPE_SHOULDERS] = { 8 },
				[EQUIP_TYPE_FEET] = { 9 },
				[EQUIP_TYPE_WAIST] = { 10 },
				[EQUIP_TYPE_HAND] = { 11 },
				[EQUIP_TYPE_NECK] = { 12 },
				[EQUIP_TYPE_RING] = { 13, 14 },
				[EQUIP_TYPE_MAIN_HAND] = { 1, 3 },
				[EQUIP_TYPE_ONE_HAND] = { 1, 2, 3, 4 },
				[EQUIP_TYPE_TWO_HAND] = { 1, 3 },
				[EQUIP_TYPE_OFF_HAND] = { 2, 4 },
			}
			DRAGINFO.link = GetItemLink(bag, slot)
			DRAGINFO.uid = Id64ToString(GetItemUniqueId(bag, slot))
			DRAGINFO.type = et
			DRAGINFO.slot = gear[et]
			DRAGINFO.source = invSlot
			AG.SetCallout('Gear',1)
			invSlot:RegisterForEvent(EVENT_CURSOR_DROPPED, function() AG.SetCallout('Gear',0) end)
		end
    end
end

function AG.LoadItem(nr,slot,set)
	if not nr or not slot then return end
	if AG.setdata[nr].Gear[slot].id ~= 0 then
		if Id64ToString(GetItemUniqueId(BAG_WORN,SLOTS[slot][1])) ~= AG.setdata[nr].Gear[slot].id then
			local bag, bagSlot = AG.GetItemFromBag(AG.setdata[nr].Gear[slot].id)
			if bagSlot then EquipItem(bag ,bagSlot, SLOTS[slot][1])
			else d(ZOSF(L.NotFound,AG.setdata[nr].Gear[slot].link)) end
		end
	elseif set and AG.setdata[set].Set.lock == 1 then table.insert(GEARQUEUE,SLOTS[slot][1]) end
end
function AG.LoadSkill(nr,slot)
    if not nr or not slot or AG.setdata[nr].Skill[slot] == 0 then return end
	local id = AG.GetAbility(AG.setdata[nr].Skill[slot])
	local slotted = AG.GetSlotted(AG.setdata[nr].Skill[slot])
	if not slotted or slotted ~= slot + 2 then CallSecureProtected('SelectSlotAbility',id,slot+2) end
end
function AG.LoadBar(nr)
	if not nr then return end
	for slot = 1,6 do AG.LoadSkill(nr,slot) end
end
function AG.LoadGear(nr,set)
	if not nr then return end
	PREBAG = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_WORN,BAG_BACKPACK)
	for x = 1,14 do AG.LoadItem(nr,x,set) end
end
function AG.LoadSet(nr)
	if not nr then return end
	AG.setdata.lastset = nr
	local pair = GetActiveWeaponPairInfo()
	if AG.setdata[nr].Set.gear ~= 0 then AG.LoadGear(AG.setdata[nr].Set.gear,nr) end
	if AG.setdata[nr].Set.skill[pair] ~= 0 then AG.LoadBar(AG.setdata[nr].Set.skill[pair]) end
	SWAP = true
	AG_SwapMessage:SetHidden(true)
	AG.SwapMessage()
end

function AG.Undress(mode)
	if mode == 1 then for x = 5,11 do table.insert(GEARQUEUE,SLOTS[x][1]) end
	else for _,x in pairs(SLOTS) do table.insert(GEARQUEUE,x[1]) end end
end
function AG.Queue()
     if AG.init then
		local GT = GetGameTimeMilliseconds()
		if GEARQUEUE[1] and (GT >= IDLE or IDLE == 0) then
			if GetItemInstanceId(BAG_WORN,GEARQUEUE[1]) then
				if GetNumBagFreeSlots(BAG_BACKPACK) > 0 then
					UnequipItem(GEARQUEUE[1])
				else
					d(L.NotEnoughSpace)
					GEARQUEUE = {}
				end
			else table.remove(GEARQUEUE,1) end
			IDLE = GT + 200
		end
     end
end
function AG.Animate(fadeIn,slideIn,fadeOut)
	local a = ANIMATION_MANAGER:CreateTimeline()
	local c = AG_SwapMessage
	if fadeIn then
		local fi = a:InsertAnimation(ANIMATION_ALPHA,c)
		c:SetAlpha(0)
		c:SetHidden(false)
		c:SetAnchor(2,AG_Charge2,8,0,0)
		fi:SetAlphaValues(0,1)
		fi:SetDuration(400)
	end
	if fadeOut then
		local fo = a:InsertAnimation(ANIMATION_ALPHA,c,fadeOut)
		fo:SetAlphaValues(1,0)
		fo:SetDuration(150)
	end
	if slideIn then
		local si = a:InsertAnimation(ANIMATION_TRANSLATE,c)
		si:SetStartOffsetX(800)
		si:SetEndOffsetX(15)
		si:SetStartOffsetY(-22)
		si:SetEndOffsetY(-22)
		si:SetDuration(500)
		si:SetEasingFunction(ZO_GenerateCubicBezierEase(.25,.5,.4,1.2))
	end
	a:PlayFromStart()
end

function AG.UpdateRepair(_,bag)
	if bag ~= BAG_WORN then return end
	local condition, count, allcost, con, minval = 0, 0, 0, 0, 100
	for _,c in pairs(SLOTS) do
		if DoesItemHaveDurability(BAG_WORN,c[1]) then
			con = GetItemCondition(BAG_WORN,c[1])
			if con <= minval then minval = con end
			condition = condition + con
			allcost = allcost + GetItemRepairCost(BAG_WORN,c[1])
			count = count + 1
		end
	end
	if minval < 100 then minval = ' ('..minval..'%)' else minval = '' end
	condition = math.floor(condition/count) or 0
	AG_RepairTex:SetColor(GetColor(condition,1))
	AG_RepairValue:SetText(condition..'%'..minval)
	AG_RepairValue:SetColor(GetColor(condition,1))
	AG_RepairCost:SetText(allcost..' |t12:12:esoui/art/currency/currency_gold.dds|t')
end
function AG.UpdateCondition(_,bag,slot)
	if bag ~= BAG_WORN or slot == EQUIP_SLOT_COSTUME or slot == EQUIP_SLOT_POISON or slot == EQUIP_SLOT_BACKUP_POISON then return end
	local t, l = WM:GetControlByName('AG_InvBg'..slot), WM:GetControlByName('AG_InvBg'..slot..'Condition')
	local p, s = t:GetParent()
	p:SetMouseOverTexture(not ZO_Character_IsReadOnly() and 'AlphaGear/mo.dds' or nil)
	p:SetPressedMouseOverTexture(not ZO_Character_IsReadOnly() and 'AlphaGear/mo.dds' or nil)
	s = p:GetNamedChild('DropCallout')
	s:ClearAnchors()
	s:SetAnchor(1,p,1,0,2)
	s:SetDimensions(52,52)
	s:SetTexture('AlphaGear/spot.dds')
	s:SetDrawLayer(0)
	s = p:GetNamedChild('Highlight')
	if s then
		s:ClearAnchors()
		s:SetAnchor(1,p,1,0,2)
		s:SetDimensions(52,52)
		s:SetTexture('AlphaGear/spot.dds')
	end
	if GetItemInstanceId(BAG_WORN,slot) then
		if OPT[10] then
			t:SetHidden(false)
			t:SetColor(Quality(GetItemLink(BAG_WORN,slot),1))
		else t:SetHidden(true) end
		if OPT[9] and DoesItemHaveDurability(BAG_WORN,slot) then
			local con = GetItemCondition(BAG_WORN,slot)
			l:SetText(con..'%')
			l:SetColor(GetColor(con,0.9))
			l:SetHidden(false)
		else l:SetHidden(true) end
	else
		t:SetHidden(true)
		l:SetHidden(true)
	end
end
function AG.UpdateCharge(_,bag)
	if bag ~= BAG_WORN then return end
	local pair = GetActiveWeaponPairInfo()
	local w1,w2,c1,c2,g1,g2,charge,gem
	if pair == 1 then
		g1 = EQUIP_SLOT_MAIN_HAND
		if IsItemChargeable(BAG_WORN,g1)then
			c1 = {GetChargeInfoForItem(BAG_WORN,g1)}
			w1 = GetItemInfo(BAG_WORN,g1)
		end
		g2 = EQUIP_SLOT_OFF_HAND
		if IsItemChargeable(BAG_WORN,g2)then
			c2 = {GetChargeInfoForItem(BAG_WORN,g2)}
			w2 = GetItemInfo(BAG_WORN,g2)
		end
	else
		g1 = EQUIP_SLOT_BACKUP_MAIN
		if IsItemChargeable(BAG_WORN,g1)then
			c1 = {GetChargeInfoForItem(BAG_WORN,g1)}
			w1 = GetItemInfo(BAG_WORN,g1)
		end
		g2 = EQUIP_SLOT_BACKUP_OFF
		if IsItemChargeable(BAG_WORN,g2)then
			c2 = {GetChargeInfoForItem(BAG_WORN,g2)}
			w2 = GetItemInfo(BAG_WORN,g2)
		end
	end
	if w1 then
		Show(AG_Charge1)
		charge = math.floor(c1[1]/c1[2]*100)
		AG_Charge1Tex:SetTexture(w1)
		AG_Charge1Value:SetText(charge.."%")
		AG_Charge1Value:SetColor(GetColor(charge,1))
		AG_Charge1:SetHidden(false)
		if c1[1] < 1 and OPT[13] then
			gem = AG.GetSoulgem()
			if gem then
				ChargeItemWithSoulGem(BAG_WORN,g1,BAG_BACKPACK,gem)
				d(ZOSF(L.SoulgemUsed,GetItemLink(BAG_WORN,g1)))
			end
		end
	else Hide(AG_Charge1) end
	if w2 then
		Show(AG_Charge2)
		charge = math.floor(c2[1]/c2[2]*100)
		AG_Charge2Tex:SetTexture(w2)
		AG_Charge2Value:SetText(charge.."%")
		AG_Charge2Value:SetColor(GetColor(charge,1))
		AG_Charge2:SetHidden(false)
		if c2[1] < 1 and OPT[13] then
			gem = AG.GetSoulgem()
			if gem then
				ChargeItemWithSoulGem(BAG_WORN,g2,BAG_BACKPACK,gem)
				d(ZOSF(L.SoulgemUsed,GetItemLink(BAG_WORN,g2)))
			end
		end
	else Hide(AG_Charge2) end
end
function AG.UpdateUI(from,to)
	if not from then from = 1 end
	if not to then to = MAXSLOT end
	local text = 'text'
	for x = from, to do
		if AG.setdata[x].Set.text[1] == 0 then text = 'Set '..x else text = AG.setdata[x].Set.text[1] end
		local header, c = '|cFFAA33'..text..'|r', ''
		WM:GetControlByName('AG_SetSelector_'..x).data = { header = header, info = L.Set }
		WM:GetControlByName('AG_SetSelector_'..x..'KeyBind'):SetText(AG.GetKey('AG_SET_'..x))
		c = WM:GetControlByName('AG_SetSelector_'..x..'Box')
		c:SetText('  '..text)
	end
end
function AG.UpdateEditPanel(nr)
	if not nr then return end
	local val,set,c,_ = nil, AG.setdata[nr].Set
	for x = 1,2 do
		for slot = 1,6 do
			if set.skill[x] ~= 0 and AG.setdata[set.skill[x]].Skill[slot] ~= 0 then
				_,val = GetAbilityInfoByIndex(AG.GetAbility(AG.setdata[set.skill[x]].Skill[slot]))
			else val = nil end
			WM:GetControlByName('AG_Edit_Skill_'..x..'_'..slot):SetNormalTexture(val)
		end
	end
	for slot = 1,14 do
		c = WM:GetControlByName('AG_Edit_Gear_1_'..slot)
		if set.gear > 0 and AG.setdata[set.gear].Gear[slot].id ~= 0 then 
			c:SetNormalTexture(GetItemLinkInfo(AG.setdata[set.gear].Gear[slot].link))
			c:GetNamedChild('Bg'):SetCenterColor(Quality(AG.setdata[set.gear].Gear[slot].link,0.5))
		else
			c:SetNormalTexture('esoui/art/characterwindow/gearslot_'..SLOTS[slot][2]..'.dds')
			c:GetNamedChild('Bg'):SetCenterColor(0,0,0,0.2)
		end
	end
	if set.gear ~= 0 and AG.setdata[set.gear].Gear[1].id ~= 0 then val = Zero(set.icon[1]) or AG.GetSetIcon(set.gear,1)
	else val = Zero(set.icon[1]) or 'x.dds' end
	AG_PanelSetPanelScrollChildEditPanelBar1IconTex:SetTexture(val)
	if set.gear ~= 0 and AG.setdata[set.gear].Gear[3].id ~= 0 then val = Zero(set.icon[2]) or AG.GetSetIcon(set.gear,2)
	else val = Zero(set.icon[2]) or 'x.dds' end
	AG_PanelSetPanelScrollChildEditPanelBar2IconTex:SetTexture(val)

	if AG.setdata[nr].Set.text[1] == 0 then val = '|cFFAA33Set '..nr..'|r' else val = '|cFFAA33'..AG.setdata[nr].Set.text[1]..'|r' end
	c = AG_PanelSetPanelScrollChildEditPanelGearConnector
	c:SetText(Zero(set.gear) or '')
	c.data = { header = val, info = L.SetConnector[1] }
	c = AG_PanelSetPanelScrollChildEditPanelBar1Connector
	c:SetText(Zero(set.skill[1]) or '')
	c.data = { header = val, info = L.SetConnector[2] }
	c = AG_PanelSetPanelScrollChildEditPanelBar2Connector
	c:SetText(Zero(set.skill[2]) or '')
	c.data = { header = val, info = L.SetConnector[3] }
	c = AG_PanelSetPanelScrollChildEditPanelGearLockTex
	if set.lock == 0 then c:SetTexture('AlphaGear/unlocked.dds') else c:SetTexture('AlphaGear/locked.dds') end
	AG_PanelSetPanelScrollChildEditPanelBar1NameEdit:SetText(Zero(set.text[2]) or 'Action-Bar 1')
	AG_PanelSetPanelScrollChildEditPanelBar2NameEdit:SetText(Zero(set.text[3]) or 'Action-Bar 2')
	WM:GetControlByName('AG_SetSelector_'..nr..'Edit'):SetText(Zero(set.text[1]) or 'Set '..nr)
end
function AG.UpdateInventory()
	local function SetItemMark(c)
		if not c then return end
		local function GetMark(c)
			local name = c:GetName()
			if not MARK[name] then MARK[name] = WM:CreateControl(name..'AG_ItemMark',c,CT_TEXTURE) end
			MARK[name]:SetDrawLayer(3)
			MARK[name]:SetDimensions(12,12)
			MARK[name]:SetHidden(true)
			MARK[name]:ClearAnchors()
			MARK[name]:SetAnchor(6,c:GetNamedChild('Bg'),6,2,0)
			MARK[name]:SetTexture('AlphaGear/mark.dds')
			return MARK[name]
		end
		local slot, mark, uid = c.dataEntry.data or nil, GetMark(c)
		uid = Id64ToString(GetItemUniqueId(slot.bagId,slot.slotIndex))
		if not slot or not uid then return end
		for nr = 1,MAXSLOT do
			if AG.setdata[nr].Set.gear > 0 then
				for slot = 1,14 do
					if AG.setdata[AG.setdata[nr].Set.gear].Gear[slot].id == uid then
						mark:SetHidden(false)
						return
					end
				end
			end
		end
	end
	local inv = {
		ZO_PlayerInventoryBackpack,ZO_PlayerBankBackpack,
		ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack,
		ZO_SmithingTopLevelImprovementPanelInventoryBackpack,
	}
	for x = 1,#inv do
		local puffer = inv[x].dataTypes[1].setupCallback
		inv[x].dataTypes[1].setupCallback = function(c,slot)
			puffer(c,slot)
			if OPT[8] then SetItemMark(c) end
		end
	end
end

function AG.SetCallout(panel,mode)
	for a = 1, MAXSLOT do
		for _,b in pairs(DRAGINFO.slot) do
			WM:GetControlByName('AG_Button_'..panel..'_'..a..'_'..b..'Bg'):SetEdgeColor(0,1,0,mode)
		end
	end
	if mode == 0 then
		DRAGINFO.source:UnregisterForEvent(EVENT_CURSOR_DROPPED)
		DRAGINFO = {}
	end
end
function AG.SetConnect(parent,mode)
	local col, p = {'green','grey'}, {'Skill','Skill','Gear'}
	for nr = 1, MAXSLOT do
		WM:GetControlByName('AG_Selector_'..p[parent]..'_'..nr):SetNormalTexture('AlphaGear/'..col[mode]..'.dds')
	end
end
function AG.SetConnection(c,button)
	local name, mode = {string.match(c:GetName(),'(%a+)(%d)Connector')}
	mode = tonumber(name[2]) or 3
	SELECTBAR = mode
	if button == 1 then
		AG.SetConnect(mode,1)
	elseif button == 2 then
		if mode < 3 then AG.setdata[SELECT].Set.skill[SELECTBAR] = 0
		else AG.setdata[SELECT].Set.gear = 0 end
	end
	AG.UpdateEditPanel(SELECT)
end
function AG.SetSetLock()
	if SELECT then
		local set,c = AG.setdata[SELECT].Set
		c = AG_PanelSetPanelScrollChildEditPanelGearLockTex
		if set.lock == 0 then
			set.lock = 1
			c:SetTexture('AlphaGear/locked.dds')
		else
			set.lock = 0
			c:SetTexture('AlphaGear/unlocked.dds')
		end
	end
end
function AG.SetSetName(mode,text)
	if not mode or not text then return end
	if SELECT then AG.setdata[SELECT].Set.text[mode] = text end
end
function AG.SetOptions()
	if OPT[3] then Show(AG_Repair) else Hide(AG_Repair) end
	AG_RepairValue:SetHidden(not OPT[3])
	AG_RepairCost:SetHidden(not OPT[4])
	if OPT[3] then
		EM:RegisterForEvent('AG_Event_Repair',EVENT_INVENTORY_SINGLE_SLOT_UPDATE, AG.UpdateRepair)
		AG.UpdateRepair(nil,BAG_WORN)
	else
		EM:UnregisterForEvent('AG_Event_Repair',EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		Hide(AG_Repair)
	end
	
	AG_Charge1:SetHidden(not OPT[5])
	AG_Charge2:SetHidden(not OPT[5])
	if OPT[5] then
		EM:RegisterForEvent('AG_Event_Charge',EVENT_INVENTORY_SINGLE_SLOT_UPDATE, AG.UpdateCharge)
		AG.UpdateCharge(nil,BAG_WORN)
	else
		if not OPT[13] then EM:UnregisterForEvent('AG_Event_Charge',EVENT_INVENTORY_SINGLE_SLOT_UPDATE) end
		Hide(AG_Charge1)
		Hide(AG_Charge2)
	end

	if OPT[9] then
		EM:RegisterForEvent('AG_Event_Condition',EVENT_INVENTORY_SINGLE_SLOT_UPDATE, AG.UpdateCondition)
		for _,c in pairs(SLOTS) do AG.UpdateCondition(_,BAG_WORN,c[1]) end
	else
		EM:UnregisterForEvent('AG_Event_Condition',EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		for _,c in pairs(SLOTS) do AG.UpdateCondition(_,BAG_WORN,c[1]) end
	end
	
	if OPT[11] then EM:RegisterForEvent('AG_Event_Movement',EVENT_NEW_MOVEMENT_IN_UI_MODE, function() SM:HideTopLevel(AG_Panel) end)
	else EM:UnregisterForEvent('AG_Event_Movement',EVENT_NEW_MOVEMENT_IN_UI_MODE) end

	if not OPT[6] or not OPT[7] then AG_SwapMessage:SetHidden(true)
	else AG_SwapMessage:SetHidden(false) end
	AG_UI_Button:SetHidden(not OPT[1])
	AG_UI_ButtonBg:SetHidden(not OPT[1])
	AG_UI_ButtonBg:SetMouseEnabled(not OPT[12])
	AG_UI_ButtonBg:SetMovable(not OPT[12])
	AG_SetButtonFrame:SetHidden(not OPT[2])
	AG_SetButtonBg:SetHidden(not OPT[2])
	AG_SetButtonBg:SetMouseEnabled(not OPT[12])
	AG_SetButtonBg:SetMovable(not OPT[12])
	AG_Panel:ClearAnchors()
	AG_Panel:SetAnchor(3,GuiRoot,3,AG.account.pos[1],AG.account.pos[2])
	AG_UI_ButtonBg:ClearAnchors()
	AG_UI_ButtonBg:SetAnchor(3,GuiRoot,3,AG.account.button[1],AG.account.button[2])
	AG_SetButtonBg:ClearAnchors()
	AG_SetButtonBg:SetAnchor(3,AG_Charge1,3,AG.account.setbuttons[1],AG.account.setbuttons[2])
	AG.SetAmount(0)
end
function AG.SetPosition(parent,pos)
	AG_Panel:ClearAnchors()
	AG_Panel:SetAnchor(8,parent,2,pos,0)
	AG_SwapMessage:SetHidden(true)
end
function AG.SetAmount(val)
	if AG.setdata.setamount + val >= 1 and AG.setdata.setamount + val <= 16 then AG.setdata.setamount = AG.setdata.setamount + val end
	AG_PanelOptionPanelAmount:SetText(AG.setdata.setamount)
	AG.DrawSetButtonsUI()
end

function AG.ResetPosition()
	AG_Panel:ClearAnchors()
	AG_Panel:SetAnchor(3,GuiRoot,3,AG.account.pos[1],AG.account.pos[2])
	AG_SwapMessage:SetHidden(not OPT[7])
end
function AG.ShowIconMenu(c,bar)
	SELECTBAR = bar
	AG_PanelIcons:SetAnchor(6,c,12,0,0)
	AG_PanelIcons:ToggleHidden()
	if not AG_PanelIcons:IsHidden() then
		for x = 1,AG_PanelIconsScrollChild:GetNumChildren() do AG_PanelIconsScrollChild:GetChild(x):SetHidden(true) end
		local xpos,ypos,name,c = 10, 10
		for x,icon in pairs(ICON) do
			name = 'AG_SetIcon_'..x
			c = WM:GetControlByName(name)
			if not c then
				c = WM:CreateControl(name,AG_PanelIconsScrollChild,CT_BUTTON)
				c:SetAnchor(3,AG_PanelIconsScrollChild,3,xpos,ypos)
				c:SetDimensions(64,64)
				c:SetClickSound('Click')
				c:SetMouseOverTexture('AlphaGear/light.dds')
				c:SetHandler('OnClicked',function(self)
					AG.setdata[SELECT].Set.icon[SELECTBAR] = icon
					AG_PanelIcons:SetHidden(true)
					AG.UpdateEditPanel(SELECT)
				end)
				if x%3 == 0 then xpos = 10; ypos = ypos + 69
				else xpos = xpos + 69 end
			end
			c:SetNormalTexture(icon)
			c:SetHidden(false)
		end
		AG_PanelIconsScrollChild:SetHeight(math.ceil(#ICON/3)*69+10)
	end
end
function AG.ShowButton(c)
	if not c then return false end
	local type, nr, slot = AG.GetButton(c)
	local skill, gear = AG.setdata[nr].Skill, AG.setdata[nr].Gear
	if type == 'Skill' then
		if skill[slot] ~= 0 then
			local id = AG.GetAbility(skill[slot])
			if id ~= 0 then
				local _,icon = GetAbilityInfoByIndex(id)
				c:SetNormalTexture(icon)
				c.data = { hint = L.Button[type] }
			end
		else
			c:SetNormalTexture()
			c.data = nil
		end
	else
		if gear[slot].link ~= 0 then
			c:SetNormalTexture(GetItemLinkInfo(gear[slot].link))
			c:GetNamedChild('Bg'):SetCenterColor(Quality(gear[slot].link,0.5))
			c.data = { hint = L.Button[type] }
		else
			c:SetNormalTexture('esoui/art/characterwindow/gearslot_'..SLOTS[slot][2]..'.dds')
			c:GetNamedChild('Bg'):SetCenterColor(0,0,0,0.2)
			c.data = nil
		end
	end
	if SELECT and not AG_PanelSetPanelScrollChildEditPanel:IsHidden() then
		if (nr == AG.setdata[SELECT].Set.gear or nr == AG.setdata[SELECT].Set.skill[1] or nr == AG.setdata[SELECT].Set.skill[2])
		then AG.UpdateEditPanel(SELECT) end
	end
end
function AG.ShowMain()
	SM:ToggleTopLevel(AG_Panel)
	if not AG_Panel:IsHidden() then AG.UpdateUI() end
end
function AG.SwapMessage()
	if OPT[6] and AG.setdata.lastset then
		local pair,tex,set = GetActiveWeaponPairInfo()
		local pslot = {1,3}
		set = AG.setdata[AG.setdata.lastset].Set
		if set.gear ~= 0 and AG.setdata[set.gear].Gear[pslot[pair]].id ~= 0 then tex = Zero(set.icon[pair]) or AG.GetSetIcon(set.gear,pair)
		else tex = Zero(set.icon[pair]) or 'AlphaGear/nothing.dds' end
		AG_SwapMessageIcon:SetTexture(tex)
		AG_SwapMessageNumber:SetText(AG.setdata.lastset)
		AG_SwapMessageName:SetText((Zero(set.text[1]) or 'Set '..AG.setdata.lastset)..'\n|cFFFFFF'..(Zero(set.text[pair + 1]) or 'Action-Bar '..pair))
		PlaySound('Market_PurchaseSelected')
		if not OPT[7] then AG.Animate(true,true,2500) else AG.Animate(true,true,false) end
	end
end
function AG.Swap(_,isSwap)
    if isSwap and not IsBlockActive() then
		if AG.setdata.lastset and SWAP then
			local pair = GetActiveWeaponPairInfo()
			if AG.setdata[AG.setdata.lastset].Set.skill[pair] ~= 0 then AG.LoadBar(AG.setdata[AG.setdata.lastset].Set.skill[pair]) end
			SWAP = false
		end
		if OPT[5] then AG.UpdateCharge(nil,BAG_WORN) end
		AG.SwapMessage()
    end
end
function AG.MenuAction(nr)
	if nr == 1 then
		MENU.copy = MENU.nr
	elseif nr == 2 and MENU.copy then
		if MENU.type == 1 then for z = 1,14 do
			AG.setdata[MENU.nr].Gear[z] = AG.setdata[MENU.copy].Gear[z]
			AG.ShowButton(WM:GetControlByName('AG_Button_Gear_'..MENU.nr..'_'..z))
		end	else for z = 1,6 do
			AG.setdata[MENU.nr].Skill[z] = AG.setdata[MENU.copy].Skill[z]
			AG.ShowButton(WM:GetControlByName('AG_Button_Skill_'..MENU.nr..'_'..z))
		end end
	elseif nr == 3 then
		if MENU.type == 1 then for x = 1,14 do
			if GetItemInstanceId(BAG_WORN,SLOTS[x][1]) then
				AG.setdata[MENU.nr].Gear[x] = { id = Id64ToString(GetItemUniqueId(BAG_WORN,SLOTS[x][1])), link = GetItemLink(BAG_WORN,SLOTS[x][1]) }
			else AG.setdata[MENU.nr].Gear[x] = { id = 0, link = 0 } end
			AG.ShowButton(WM:GetControlByName('AG_Button_Gear_'..MENU.nr..'_'..x))
		end elseif MENU.type == 2 then AG.GetSkillFromBar(MENU.nr) end
	elseif nr == 4 then
		if MENU.type == 1 then for z = 1,14 do
			AG.setdata[MENU.nr].Gear[z] = { id = 0, link = 0 }
			AG.ShowButton(WM:GetControlByName('AG_Button_Gear_'..MENU.nr..'_'..z))
		end	elseif MENU.type == 2 then for z = 1,6 do
			AG.setdata[MENU.nr].Skill[z] = 0
			AG.ShowButton(WM:GetControlByName('AG_Button_Skill_'..MENU.nr..'_'..z))
		end else
			AG.setdata[MENU.nr].Set = { text = {0,0,0}, gear = 0, skill = {0,0}, icon = {0,0}, lock = 0 }
			AG.UpdateUI(MENU.nr,MENU.nr)
		end
	end
end
function AG.Tooltip(c,visible,edit)
	local function FadeIn(control)
		TTANI = ANIMATION_MANAGER:CreateTimeline()
		local fadeIn = TTANI:InsertAnimation(ANIMATION_ALPHA,control,400)
		fadeIn:SetAlphaValues(0,1)
		fadeIn:SetDuration(150)
		TTANI:PlayFromStart()
	end
	if not c then return end
	if visible then
		local type, nr, slot = AG.GetButton(c)
		if type == 'Gear' then
			if edit then nr = AG.setdata[SELECT].Set.gear end
			if nr > 0 then
				if AG.setdata[nr].Gear[slot].link == 0 then return end
				c.text = ItemTooltip
				InitializeTooltip(c.text,AG_Panel,3,0,0,9)
				c.text:SetLink(AG.setdata[nr].Gear[slot].link)
				ZO_ItemTooltip_ClearCondition(c.text)
				ZO_ItemTooltip_ClearCharges(c.text)
			else return end
		elseif type == 'Skill' then
			if edit then nr = AG.setdata[SELECT].Set.skill[nr] end
			if nr > 0 then
				if AG.setdata[nr].Skill[slot] == 0 then return end
				local s1,s2,s3 = AG.GetSkill(AG.setdata[nr].Skill[slot])
				if s1 and s2 and s3 then
					c.text = SkillTooltip
					InitializeTooltip(c.text,AG_Panel,3,0,0,9)
					c.text:SetSkillAbility(s1,s2,s3)
				else
					c.text = InformationTooltip
					InitializeTooltip(c.text,AG_Panel,3,0,0,9)
					c.text:AddLine('Please resave this skill with Shift + Click or Drag it from the SkillWindow to get the correct tooltip. The API was changed...')
				end
			else return end
		elseif c.data and c.data.tip then
			c.text = InformationTooltip
			InitializeTooltip(c.text,c,2,5,0,8)
			SetTooltipText(c.text,c.data.tip)
			c.text:SetHidden(false)
			return
		else
			if c.data == nil then return end
			c.text = InformationTooltip
			InitializeTooltip(c.text,AG_Panel,3,0,0,9)
			if c.data.header then c.text:AddLine(c.data.header,'ZoFontWinH4') end
			SetTooltipText(c.text,c.data.info)
		end
		if c.data and c.data.hint then c.text:AddLine(c.data.hint,'ZoFontGame') end
		c.text:SetAlpha(0)
		c.text:SetHidden(false)
		FadeIn(c.text)
	else
		if c.text == nil then return end
		ClearTooltip(c.text)
		if TTANI then TTANI:Stop() end
		c.text:SetHidden(true)
		c.text = nil
	end
end
function AG.TooltipSet(nr,visible)
	if not nr then return end
	if visible then
		local set,val,_ = AG.setdata[nr].Set
		for z = 1,2 do
			local ico = ''
			for x = 1,6 do
				if set.skill[z] > 0 and AG.setdata[set.skill[z]].Skill[x] ~= 0 then
					_,val = GetAbilityInfoByIndex(AG.GetAbility(AG.setdata[set.skill[z]].Skill[x]))
				else val = 'AlphaGear/grey1.dds' end
				ico = ico..'|t36:36:'..val..'|t '
			end
			WM:GetControlByName('AG_SetTipBar'..z..'Skills'):SetText(ico)
			if set.gear ~= 0 then
				val = Zero(set.icon[z]) or AG.GetSetIcon(set.gear,z)
			else val = 'AlphaGear/nothing.dds' end
			WM:GetControlByName('AG_SetTipSkill'..z..'Icon'):SetTexture(val)
		end
		AG_SetTipName:SetText(Zero(set.text[1]) or 'Set '..nr)
		AG_SetTipBar1Name:SetText(Zero(set.text[2]) or 'Action-Bar 1')
		AG_SetTipBar2Name:SetText(Zero(set.text[3]) or 'Action-Bar 2')
		AG_SetTip:ClearAnchors()
		AG_SetTip:SetAnchor(6,AG_UI_SetButton_1,3,0,-2)
		AG_SetTip:SetHidden(false)
	else AG_SetTip:SetHidden(true) end
end

function KEYBINDING_MANAGER:IsChordingAlwaysEnabled() return true end
function AlphaGear_RegisterIcon(icon) table.insert(ICON,icon or 'AlphaGear/nothing.dds') end






-- Function definitions end here, finally






EM:RegisterForEvent('AG4',EVENT_ADD_ON_LOADED,function(_,name)
	if name ~= AG.name then return end
	SM:RegisterTopLevel(AG_Panel,false)
    EM:UnregisterForEvent('AG4',EVENT_ADD_ON_LOADED)
	EM:RegisterForEvent('AG4',EVENT_ACTION_SLOTS_FULL_UPDATE, AG.Swap)
	EM:RegisterForEvent('AG4',EVENT_INVENTORY_FULL_UPDATE, function() PREBAG = nil end)

	local init_account = {
		option = {true,true,true,true,true,true,true,true,true,true,true,false,true},
		pos = {GuiRoot:GetWidth()/2 - 335, GuiRoot:GetHeight()/2 - 410},
		size = false,
		button = {50,100},
		setbuttons = {-10,-75},
	}
	local init_data = {
		setamount = 16,
		lastset = false,
	}
	for x = 1, MAXSLOT do
		init_data[x] = {
			Gear = {}, Skill = {},
			Set = { text = {0,0,0}, gear = 0, skill = {0,0}, icon = {0,0}, lock = 0 }
		}
		for z = 1,14 do init_data[x].Gear[z] = { id = 0, link = 0 } end
		for z = 1,6 do init_data[x].Skill[z] = 0 end
	end
	AG.setdata = ZO_SavedVars:New('AGX2_Character',1,nil,init_data)
	AG.account = ZO_SavedVars:NewAccountWide('AGX2_Account',1,nil,init_account)

	-- for x = 1, MAXSLOT do
		-- for z = 1,6 do
			-- if type(AG.setdata[x].Skill[z]) == 'table' then 
				-- local a,b,c = unpack(AG.setdata[x].Skill[z])
				-- AG.setdata[x].Skill[z] = GetSkillAbilityId(a,b,c,false) or 0
			-- end
		-- end
	-- end

	ZO_CreateStringId('SI_BINDING_NAME_SHOW_AG_WINDOW', 'AlphaGear')
	ZO_CreateStringId('SI_BINDING_NAME_AG_UNDRESS', 'Unequip all Armor')
	OPT = AG.account.option
	for x = 1, MAXSLOT do
		ZO_CreateStringId('SI_BINDING_NAME_AG_SET_'..x, 'Load Set '..x)
		AG.DrawSet(x)
		AG.DrawButtonLine(1,x)
		AG.DrawButtonLine(2,x)
	end
	for x = 1,3 do
		AG.DrawButton(AG_PanelSetPanelScrollChildEditPanelSkill11Box,'Edit','Skill',1,x,42*(x-1),0,true)
		AG.DrawButton(AG_PanelSetPanelScrollChildEditPanelSkill12Box,'Edit','Skill',1,x+3,42*(x-1),0,true)
		AG.DrawButton(AG_PanelSetPanelScrollChildEditPanelSkill21Box,'Edit','Skill',2,x,42*(x-1),0,true)
		AG.DrawButton(AG_PanelSetPanelScrollChildEditPanelSkill22Box,'Edit','Skill',2,x+3,42*(x-1),0,true)
	end
	for x = 1,2 do
		AG.DrawButton(AG_PanelSetPanelScrollChildEditPanelWeap1Box,'Edit','Gear',1,x,0,42*(x-1),true)
		AG.DrawButton(AG_PanelSetPanelScrollChildEditPanelWeap2Box,'Edit','Gear',1,x+2,0,42*(x-1),true)
	end
	for x = 5,9 do AG.DrawButton(AG_PanelSetPanelScrollChildEditPanelGear1Box,'Edit','Gear',1,x,42*(x-5),0,true) end
	for x = 10,14 do AG.DrawButton(AG_PanelSetPanelScrollChildEditPanelGear2Box,'Edit','Gear',1,x,42*(x-10),0,true) end

	ZO_PreHook('ZO_Skills_AbilitySlot_OnDragStart', AG.OnSkillDragStart)
	ZO_PreHook('ZO_InventorySlot_OnDragStart', AG.OnItemDragStart)
	ZO_PreHookHandler(AG_PanelMenu,'OnShow', function()
		zo_callLater(function() EM:RegisterForEvent('AG4',EVENT_GLOBAL_MOUSE_UP,function()
			AG_PanelMenu:SetHidden(true)
			EM:UnregisterForEvent('AG4',EVENT_GLOBAL_MOUSE_UP)
		end) end, 250)
	end)
	ZO_PreHookHandler(ZO_Skills,'OnShow', function() AG.SetPosition(ZO_Skills,-25) end)
	ZO_PreHookHandler(ZO_Skills,'OnHide', AG.ResetPosition)
	ZO_PreHookHandler(ZO_PlayerInventory,'OnShow', function() AG.SetPosition(ZO_PlayerInventory,0) end)
	ZO_PreHookHandler(ZO_PlayerInventory,'OnHide', AG.ResetPosition)
	ZO_PreHookHandler(ZO_ChampionPerks,'OnShow', function() SM:HideTopLevel(AG_Panel) end)
	ZO_PreHookHandler(AG_Panel,'OnHide', function() AG_PanelIcons:SetHidden(true); AG_PanelOptionPanel:SetHidden(true) end)
	
	AG_PanelIcons.useFadeGradient = false
	AG_PanelSetPanel.useFadeGradient = false
	AG_PanelGearPanel.useFadeGradient = false
	AG_PanelSkillPanel.useFadeGradient = false

	AG_UI_Button.data = { tip = AG.name }
	AG_PanelUndressArmor.data = { info = L.Unequip }
	AG_PanelUndressAll.data = { info = L.UnequipAll }
	AG_PanelSetPanelScrollChildEditPanelGearLock.data = { info = L.Lock }
	
	AG.DrawSetButtonsUI()
	AG.DrawInventory()
	AG.DrawOptions()
	AG.UpdateInventory()
	AG.SetOptions()
	zo_callLater(AG.SwapMessage,900)
	AG_PanelOptionPanelPlus:SetAnchor(8,AG_Option_2,8,0,0)
	
	AlphaGear_RegisterIcon('AlphaGear/onehand.dds')
	AlphaGear_RegisterIcon('AlphaGear/onehand_aoe.dds')
	AlphaGear_RegisterIcon('AlphaGear/twohand.dds')
	AlphaGear_RegisterIcon('AlphaGear/twohand_aoe.dds')
	AlphaGear_RegisterIcon('AlphaGear/fire.dds')
	AlphaGear_RegisterIcon('AlphaGear/fire_aoe.dds')
	AlphaGear_RegisterIcon('AlphaGear/frost.dds')
	AlphaGear_RegisterIcon('AlphaGear/frost_aoe.dds')
	AlphaGear_RegisterIcon('AlphaGear/shock.dds')
	AlphaGear_RegisterIcon('AlphaGear/shock_aoe.dds')
	AlphaGear_RegisterIcon('AlphaGear/heal.dds')
	AlphaGear_RegisterIcon('AlphaGear/heal_aoe.dds')
	AlphaGear_RegisterIcon('AlphaGear/bow.dds')
	AlphaGear_RegisterIcon('AlphaGear/bow_aoe.dds')
	AlphaGear_RegisterIcon('AlphaGear/shield.dds')
	AlphaGear_RegisterIcon('AlphaGear/power.dds')
	AlphaGear_RegisterIcon('AlphaGear/bonehead.dds')
	AlphaGear_RegisterIcon('AlphaGear/training.dds')
	AlphaGear_RegisterIcon('AlphaGear/wolf.dds')
	AlphaGear_RegisterIcon('AlphaGear/vampire.dds')
	AlphaGear_RegisterIcon('AlphaGear/horse.dds')
	
	SELECT = AG.setdata.lastset
	AG.init = true
end)