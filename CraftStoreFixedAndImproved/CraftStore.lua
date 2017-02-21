local CS = CraftStoreFixedAndImprovedLongClassName

local EM, WM, SM, ZOSF, CSLOOT = EVENT_MANAGER, WINDOW_MANAGER, SCENE_MANAGER, zo_strformat, nil
local ITEMMARK, TIMER, SELF, MODE, MAXCRAFT = {}, {}, false, 0, 50

local blueprints_count = 500

function CS.LoadCharacter(control,button)
  local char = control.data.charactername
  if button == 2 then
    if CS.Account.mainchar == char then CS.Account.mainchar = false else CS.Account.mainchar = char end
    CS.DrawCharacters()
  elseif button == 3 and char ~= CS.CurrentPlayer then
    CS.SelectedPlayer = CS.CurrentPlayer
    if CS.Account.mainchar == char then CS.Account.mainchar = false end
    CS.Account.player[char] = nil
    CS.Account.crafting.research[char] = nil
    CS.Account.crafting.studies[char] = nil
    CS.Account.crafting.skill[char] = nil
    CS.Account.style.tracking[char] = nil
    CS.Account.style.knowledge[char] = nil
    CS.Account.cook.tracking[char] = nil
    CS.Account.cook.knowledge[char] = nil
    CS.Account.furnisher.tracking[char] = nil
    CS.Account.furnisher.knowledge[char] = nil
    CS.Character[char] = nil
    for nr,_ in pairs(CS.GetCharacters()) do WM:GetControlByName('CraftStoreFixed_CharacterFrame'..nr):SetHidden(true) end
    CS.DrawCharacters()
    CraftStoreFixed_CharacterPanelBoxScrollChild:SetHeight(#CS.GetCharacters() * 204 - 5)
  else
    CS.SelectedPlayer = char
    CS.UpdateScreen()
    CraftStoreFixed_PanelButtonCharacters:SetText(char)
    CraftStoreFixed_CharacterPanel:SetHidden(true)
    for id,value in pairs(CS.Account.cook.knowledge[char]) do
      for x,recipe in pairs(CS.Cook.recipe) do
        if recipe.id == id then CS.Cook.recipe[x].known = value; break end
      end
    end
  end
end

function CS.DrawCharacters()
  local control, mainchar
  local swatch = {[false] = '|t16:16:esoui/art/buttons/checkbox_unchecked.dds|t', [true] = '|t16:16:esoui/art/buttons/checkbox_checked.dds|t'}
  local tex = {[true] = '|t18:18:esoui/art/characterwindow/equipmentbonusicon_full.dds|t ', [false] = ''}
  local function GetResearch(char,nr)
    local row, now, control = 1, GetTimeStamp()
    for craft,craftData in pairs(CS.Account.crafting.research[char]) do
      for line,lineData in pairs(craftData) do
        for trait,traitData in pairs(lineData) do
          if traitData ~= true and traitData ~= false then
            if traitData > 0 then
              local name, icon = GetSmithingResearchLineInfo(craft,line)
              local tid = GetSmithingResearchLineTraitInfo(craft,line,trait)
              local _,_,ticon = GetSmithingTraitItemInfo(tid + 1)
              control = WM:GetControlByName('CraftStoreFixed_Character'..nr..'Research'..craft..'Slot'..row)
              control:SetText('|t22:22:'..icon..'|t  |t22:22:'..ticon..'|t')
              control.data = {info = ZOSF('<<C:1>> - <<C:2>>',name,GetString('SI_ITEMTRAITTYPE',tid))}
              WM:GetControlByName('CraftStoreFixed_Character'..nr..'Research'..craft..'Slot'..row..'Time'):SetText(CS.GetTime(traitData - now))
              row = row + 1
            end
          end
        end
      end
      local maxsim = CS.Account.crafting.skill[char][craft].maxsim or 1
      local level = string.format('%02d',CS.Account.crafting.skill[char][craft].level) or 1
      local rank = string.format('%02d',CS.Account.crafting.skill[char][craft].rank) or 1
      local simcolor, current = '|cFFFFFF', row - 1
      if maxsim > 1 then if current == maxsim then simcolor = '|c00FF00' else simcolor = '|cFF0000' end end
      WM:GetControlByName('CraftStoreFixed_Character'..nr..'Skill'..craft):SetText('|t24:24:'..CS.CraftIcon[craft]..'|t  '..level..' ('..rank..')|r    |c808080'..GetString(SI_BULLET)..'|r   '..simcolor..current..' / '..maxsim..'|r')
      row = 1
    end
  end
  for x = 1,12 do control = WM:GetControlByName('CraftStoreFixed_CharacterFrame'..x); if control then control:SetHidden(true) end end
  for nr, char in pairs(CS.GetCharacters()) do
    local player = CS.Account.player[char]
    if CS.Account.mainchar == char then mainchar = true else mainchar = false end
    WM:GetControlByName('CraftStoreFixed_CharacterFrame'..nr):SetHidden(false)
    control = WM:GetControlByName('CraftStoreFixed_Character'..nr..'Name')
    control:SetText(tex[mainchar]..char..' ('..player.level..') |t25:25:'..CS.Flags[player.faction]..'|t|t30:30:'..CS.Classes[player.class]..'|t')
    control.data = { charactername = char, info = CS.Loc.TT[10] }
    control = WM:GetControlByName('CraftStoreFixed_Character'..nr..'Info')
    control:SetText(player.mount.space..'  '..player.mount.stamina..' '..player.mount.speed..'  '..'|t22:22:esoui/art/miscellaneous/timer_32.dds|t '..CS.GetTime(player.mount.time - GetTimeStamp()))
    control.data = { info = CS.Loc.TT[20] }
    for x, icon in pairs(CS.CraftIcon) do
      local name = GetSkillLineInfo(GetCraftingSkillLineIndices(x))
      local level = string.format('%02d',CS.Account.crafting.skill[char][x].level) or 1
      local rank = string.format('%02d',CS.Account.crafting.skill[char][x].rank) or 1
      control = WM:GetControlByName('CraftStoreFixed_Character'..nr..'Skill'..x)
      control:SetText('|t24:24:'..icon..'|t  '..level..' ('..rank..')')
      control.data = { info = ZOSF('<<C:1>>',name)..' - '..CS.Loc.rank..' ('..CS.Loc.level..')' }
    end
    GetResearch(char,nr)
    WM:GetControlByName('CraftStoreFixed_Character'..nr..'Recipe'):SetText(swatch[CS.Account.cook.tracking[char]]..' |t22:22:esoui/art/icons/quest_scroll_001.dds|t')
    WM:GetControlByName('CraftStoreFixed_Character'..nr..'Style'):SetText(swatch[CS.Account.style.tracking[char]]..' |t22:22:esoui/art/icons/quest_book_001.dds|t')
  end
end

function CS.DrawTraitColumn(craft,line)
  local name, icon = GetSmithingResearchLineInfo(craft,line)
  local craftname = GetSkillLineInfo(GetCraftingSkillLineIndices(craft))
  local p = WM:GetControlByName('CraftStoreFixed_PanelCraft'..craft..'Line'..line)
  local c = WM:CreateControl('CraftStoreFixed_PanelCraft'..craft..'Line'..line..'Header',p,CT_BUTTON)
  c:SetAnchor(3,p,3,-1,0)
  c:SetDimensions(27,27)
  c:SetClickSound('Click')
  c:EnableMouseButton(2,true)
  c:SetHandler('OnMouseEnter',function(self) CS.Tooltip(self,true,true,self,'bc') end)
  c:SetHandler('OnMouseExit',function(self) CS.Tooltip(self,false,true) end)
  c:SetHandler('OnMouseDown',function(self,button)
    local value = not CS.Account.crafting.studies[CS.SelectedPlayer][craft][line]
    if button == 2 then
      for col = 1, WM:GetControlByName('CraftStoreFixed_PanelCraft'..craft):GetNumChildren() do
        CS.Account.crafting.studies[CS.SelectedPlayer][craft][col] = value
        CS.UpdateStudyLine(WM:GetControlByName('CraftStoreFixed_PanelCraft'..craft):GetChild(col),value)
      end
    else
      CS.Account.crafting.studies[CS.SelectedPlayer][craft][line] = value
      CS.UpdateStudyLine(p,value)
    end
  end)
  c.data = {info = ZOSF(CS.Loc.TT[1],name,CS.CraftIcon[craft],craftname)}
  local t = WM:CreateControl('CraftStoreFixed_PanelCraft'..craft..'Line'..line..'HeaderTexture',c,CT_TEXTURE)
  t:SetAnchor(128,c,128,0,0)
  t:SetDimensions(26,26)
  t:SetTexture(icon)
  for trait = 1, CS.MaxTraits do
    local b = WM:CreateControl('CraftStoreFixed_PanelCraft'..craft..'Line'..line..'Trait'..trait..'Bg',p,CT_BACKDROP)
    b:SetAnchor(3,p,3,-1,2 + trait * 26)
    b:SetDimensions(27,25)
    b:SetCenterColor(0.06,0.06,0.06,1)
    b:SetEdgeTexture('',1,1,1,1)
    b:SetEdgeColor(1,1,1,0.12)
    c = WM:CreateControl('CraftStoreFixed_PanelCraft'..craft..'Line'..line..'Trait'..trait,b,CT_BUTTON)
    c:SetAnchor(128,b,128,0,0)
    c:SetDimensions(25,25)
    c:SetClickSound('Click')
    c:EnableMouseButton(2,true)
    c:SetHandler('OnMouseEnter',function(self) CS.Tooltip(self,true) end)
    c:SetHandler('OnMouseExit',function(self) CS.Tooltip(self,false) end)
    c:SetHandler('OnMouseDown',function(self,button)
      if button == 1 and self.data.research and CS.SelectedPlayer == CS.CurrentPlayer and (self.data.research[4] == CS.CurrentPlayer or self.data.research[4] == CS.Loc.bank) then
        local uid = CS.Account.crafting.stored[self.data.research[1]][self.data.research[2]][self.data.research[3]].id or false
        if uid then
          local bag,slot = CS.ScanUidBag(uid)
          d(bag,slot)
          if CanItemBeSmithingTraitResearched(bag,slot,self.data.research[1],self.data.research[2],self.data.research[3]) then ResearchSmithingTrait(bag,slot) else d(CS.Loc.noSlot) end
        end
      elseif button == 2 then
        local tnr = GetSmithingResearchLineTraitInfo(craft,line,trait)
        CS.ToChat(ZOSF(CS.Loc.itemsearch,name,GetString('SI_ITEMTRAITTYPE',tnr)))
      end
    end)
    local t = WM:CreateControl('CraftStoreFixed_PanelCraft'..craft..'Line'..line..'Trait'..trait..'Texture',c,CT_TEXTURE)
    t:SetAnchor(128,c,128,0,0)
    t:SetDimensions(25,25)
  end
  local b = WM:CreateControl('CraftStoreFixed_PanelCraft'..craft..'Line'..line..'CountBg',p,CT_BACKDROP)
  b:SetAnchor(3,p,3,-1,262)
  b:SetDimensions(27,25)
  b:SetCenterColor(0.06,0.06,0.06,1)
  b:SetEdgeTexture('',1,1,1,1)
  b:SetEdgeColor(1,1,1,0.12)
  local c = WM:CreateControl('CraftStoreFixed_PanelCraft'..craft..'Line'..line..'Count',b,CT_BUTTON)
  c:SetAnchor(128,b,128,0,0)
  c:SetDimensions(25,25)
  c:SetHorizontalAlignment(1)
  c:SetVerticalAlignment(1)
  c:SetFont('CraftStoreFixedFont')
  c:SetNormalFontColor(0.9,0.87,0.68,1)
end

function CS.ScanBag(scanid)
  local bag = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_BACKPACK,BAG_BANK,BAG_VIRTUAL)
  for _, data in pairs(bag) do
    local id = CS.SplitLink(GetItemLink(data.bagId,data.slotIndex),3)
    if id == scanid then return data.bagId, data.slotIndex end
  end
end

function CS.ScanUidBag(id)
  if not id then return false end
  local bag = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_BACKPACK,BAG_BANK,BAG_VIRTUAL)
  for _, data in pairs(bag) do if id == Id64ToString(data.uniqueId) then return data.bagId, data.slotIndex end end
  return false
end

function CS.UpdateBag()
  CS.ItemLinkCache = { [1]={}, [2]={}, [5]={}}
  local bag = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_BACKPACK,BAG_BANK,BAG_VIRTUAL)  
  for _, data in pairs(bag) do
    local link, stack = CS.StripLink(GetItemLink(data.bagId,data.slotIndex)), 0
    if not CS.Account.storage[link] then CS.Account.storage[link] = {} end
    stack = data.stackCount
    local bagName = CS.CurrentPlayer
    if data.bagId == BAG_BANK then bagName = CS.Loc.bank end
    if data.bagId == BAG_VIRTUAL then bagName = CS.Loc.craftbag end
    CS.Account.storage[link][bagName] = stack
    local itemType = GetItemLinkItemType(link)
    if CS.RawItemTypes[itemType] and not CS.Account.materials[link] then
      local refinedLink = CS.StripLink(GetItemLinkRefinedMaterialItemLink(link,0))
      CS.Account.materials[link] = {raw=true,link=refinedLink}
      CS.Account.materials[refinedLink] = {raw=false,link=link}
    end
  end
  
end

function CS.ClearStorage()
  for x, slot in pairs(CS.Account.storage) do
    local count = 0
    for y, item in pairs(slot) do
      if item < 1 then CS.Account.storage[x][y] = nil
      else count = count + 1 end
    end
    if count == 0 then CS.Account.storage[x] = nil end
  end
end
function CS.ScrollText()
  local function DrawControl(control)
    local container = CraftStoreFixed_QuestFrame:CreateControl('CraftStoreFixed_Inspiration'..control:GetNextControlId(),CT_CONTROL)
    local c = container:CreateControl('$(parent)Loot',CT_LABEL)
    c:SetFont('CraftStoreFixedInsp')
    c:SetColor(1,1,1,1)
    c:SetAnchor(1,container,1,0,0)
    container.c = c
    return container
  end
  local function ClearControl(c)
    c:SetHidden(true)
    c:ClearAnchors()
  end
  CSLOOT = ZO_ObjectPool:New(DrawControl,ClearControl)
end
function CS.Slide(c,x1,y1,x2,y2,duration)
    local a=ANIMATION_MANAGER:CreateTimeline()
    local s=a:InsertAnimation(ANIMATION_TRANSLATE,c)
    local fi=a:InsertAnimation(ANIMATION_ALPHA,c)
    local fo=a:InsertAnimation(ANIMATION_ALPHA,c,duration-500)
    fi:SetAlphaValues(0,1)
    fi:SetDuration(10)
    s:SetStartOffsetX(x1)
    s:SetStartOffsetY(y1)
    s:SetEndOffsetX(x2)
    s:SetEndOffsetY(y2)
    s:SetDuration(duration)
    fo:SetAlphaValues(1,0)
    fo:SetDuration(500)
  a:PlayFromStart()
end
function CS.Queue()
  if CS.Init then
    if CS.Account.option[12] then
      for x,project in pairs(TIMER) do
        if(GetDiffBetweenTimeStamps(project.time,GetTimeStamp())) <= 0 then
          PlaySound('Smithing_Finish_Research')
          CraftStoreFixed_Alarm:AddMessage(project.info,1,0.66,0.2,1)
          CraftStoreFixed_Alarm:AddMessage('|t10:10:x.dds|t',0,0,0,1)
          table.remove(TIMER,x)
          CS.Account.announce[project.id] = GetTimeStamp()
        end
      end
    end
    if ZO_Provisioner_IsSceneShowing() and CS.Account.option[7] then ZO_ProvisionerTopLevelTooltip:SetHidden(true) end
    if CS.Inspiration ~= '' then
      local c,x = CSLOOT:AcquireObject()
      c:SetHidden(false)
      c:SetAnchor(128,CraftStoreFixed_QuestFrame,128,0,0)
      c:GetChild(1):SetText(CS.Inspiration)
      CS.Slide(c,0,20,0,(GuiRoot:GetHeight()/2)-180,3500)
      zo_callLater(function() CSLOOT:ReleaseObject(x) end,3510)
      CS.Inspiration = ''
    end
  end
end

function CS.UpdateScreen()
  local function SetPoint(x)
    local left,num,right=string.match(x,'^([^%d]*%d)(%d*)(,-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
  end
  for craft, _ in pairs(CS.Account.crafting.research[CS.SelectedPlayer]) do
    for line = 1, GetNumSmithingResearchLines(craft) do
      for trait = 1, CS.MaxTraits do
        CS.UpdatePanelIcon(craft,line,trait)
      end
    end
  end
  CS.UpdateAllStudies()
  CS.UpdateResearchWindows()
  CS.UpdateStyleKnowledge()
  local fmax,fused = GetFenceSellTransactionInfo()
  CraftStoreFixed_PanelFenceGoldText:SetText("|cC5C29E"..fused.."/"..fmax.." |r  "..SetPoint(GetCurrentMoney() - CS.Character.income[2]).." |t14:14:esoui/art/currency/currency_gold.dds|t")
end
function CS.UpdatePanelIcon(craft,line,trait)
  if not craft or not line or not trait then return end
  local traitname = GetString('SI_ITEMTRAITTYPE',GetSmithingResearchLineTraitInfo(craft,line,trait))
  local control = WM:GetControlByName('CraftStoreFixed_PanelCraft'..craft..'Line'..line..'Trait'..trait..'Texture')
  local known = CS.Account.crafting.research[CS.SelectedPlayer][craft][line][trait] or false
  local store = CS.Account.crafting.stored[craft][line][trait] or { link = false, owner = false }
  local now, tip = GetTimeStamp(), ''
  local function CountTraits()
    local count = 0
    for _, trait in pairs(CS.Account.crafting.research[CS.SelectedPlayer][craft][line]) do
      if trait == true then count = count + 1 end
    end
    return count
  end
  for _, char in pairs(CS.GetCharacters()) do
    local val = CS.Account.crafting.research[char][craft][line][trait] or false
    if val == true then
      tip = tip..'\n|t20:20:esoui/art/buttons/accept_up.dds|t |c00FF00'..char..'|r'
    elseif val == false then
      tip = tip..'\n|t20:20:esoui/art/buttons/decline_up.dds|t |cFF1010'..char..'|r'
    elseif val and val > 0 then
      if char == CS.CurrentPlayer then
        local _,remain = GetSmithingResearchLineTraitTimes(craft,line,trait)
        tip = tip..'\n|t23:23:esoui/art/miscellaneous/timer_32.dds|t |c66FFCC'..char..' ('..CS.GetTime(remain)..')|r'
      else
        tip = tip..'\n|t23:23:esoui/art/miscellaneous/timer_32.dds|t |c66FFCC'..char..' ('..CS.GetTime(GetDiffBetweenTimeStamps(val,now))..')|r'
      end
    end
  end
  control:GetParent().data = { info = '|cFFFFFF'..traitname..'|r'..tip..'\n'..CS.Loc.TT[6] }
  if known == false then
    control:SetColor(1,0,0,1)
    control:SetTexture('esoui/art/buttons/decline_up.dds')
    if store.link and store.owner then
      local isSet = GetItemLinkSetInfo(store.link)
      local mark = true
      if not CS.Account.option[14] and isSet then mark = false end
      if mark then 
        tip = '\n|t20:20:esoui/art/buttons/pointsplus_up.dds|t |cE8DFAF'..store.owner..'|r'..tip
        control:SetColor(1,1,1,1)
        control:SetTexture('esoui/art/buttons/pointsplus_up.dds')
        control:GetParent().data = { link = store.link, addline = {tip}, research = {craft,line,trait,store.owner} }
      end
    end
  elseif known == true then
    control:SetColor(0,1,0,1)
    control:SetTexture('esoui/art/buttons/accept_up.dds')
  else
    control:SetColor(0.4,1,0.8,1)
    control:SetTexture('esoui/art/miscellaneous/timer_32.dds')
  end
  WM:GetControlByName('CraftStoreFixed_PanelCraft'..craft..'Line'..line..'Count'):SetText(CountTraits())
end
function CS.UpdateStudyLine(control,condition)
  if condition then
    control:GetNamedChild('HeaderTexture'):SetColor(1,1,1,1)
    for x = 1, control:GetNumChildren() - 1 do
      local subcontrol = control:GetChild(x)
      subcontrol:SetCenterColor(0.06,0.06,0.06,1)
      subcontrol:SetEdgeColor(1,1,1,0.12)
    end
  else 
    control:GetNamedChild('HeaderTexture'):SetColor(1,0,0,1)
    for x = 1, control:GetNumChildren() - 1 do
      local subcontrol = control:GetChild(x)
      subcontrol:SetCenterColor(0.15,0,0,1)
      subcontrol:SetEdgeColor(1,0,0,0.5)
    end
  end
end
function CS.UpdateAllStudies()
  for craft, craftData in pairs(CS.Account.crafting.studies[CS.SelectedPlayer]) do
    for line, lineData in pairs(craftData) do
      CS.UpdateStudyLine(WM:GetControlByName('CraftStoreFixed_PanelCraft'..craft..'Line'..line),lineData)
    end
  end
end
function CS.UpdatePlayer(deactivation)
  deactivation = deactivation or false
  local function GetBonus(bonus,craft)
    local skillType, skillId = GetCraftingSkillLineIndices(craft)
    local _, rank = GetSkillLineInfo(skillType,skillId)
    return {level = GetNonCombatBonus(bonus) or 1, rank = rank, maxsim = GetMaxSimultaneousSmithingResearch(craft) or 1}
  end
  if not deactivation then
    CS.Account.crafting.skill[CS.CurrentPlayer] = {
      GetBonus(NON_COMBAT_BONUS_BLACKSMITHING_LEVEL,1),
      GetBonus(NON_COMBAT_BONUS_CLOTHIER_LEVEL,2),
      GetBonus(NON_COMBAT_BONUS_ENCHANTING_LEVEL,3),
      GetBonus(NON_COMBAT_BONUS_ALCHEMY_LEVEL,4),
      GetBonus(NON_COMBAT_BONUS_PROVISIONING_LEVEL,5),
      GetBonus(NON_COMBAT_BONUS_WOODWORKING_LEVEL,6)
    }
  end
  local ride = {GetRidingStats()}
  local ridetime = GetTimeUntilCanBeTrained()/1000 or 0
  if ridetime > 1 then ridetime = ridetime + GetTimeStamp() end
  local level = GetUnitLevel('player')
  local levelcp = GetUnitChampionPoints('player')
  if levelcp>0 then
    level = "|c"..CS.QualityHex[5]..CS.ChampionPointsTexture..levelcp..'|r'
  end
  CS.Account.player[CS.CurrentPlayer] = {
    race = ZOSF('<<C:1>>',GetUnitRace('player')),
    class = GetUnitClassId('player'),
    level = level,
    faction = GetUnitAlliance('player'),
    mount = {
      space = '|t20:20:esoui/art/mounts/ridingskill_capacity.dds|t '..ride[1]..'/'..ride[2],
      stamina = '|t20:20:esoui/art/mounts/ridingskill_stamina.dds|t '..ride[3]..'/'..ride[4],
      speed = '|t20:20:esoui/art/mounts/ridingskill_speed.dds|t '..ride[5]..'/'..ride[6],
      time = ridetime
    }
  }
end
function CS.UpdateStyleKnowledge()
  local known, control
  for id = 1,GetNumSmithingStyleItems() do
    local _, _, _, _, style = GetSmithingStyleItemInfo(id)
    if CS.Style.CheckStyle(id) then
      for chapter = 1,14 do
        CS.Account.style.knowledge[CS.CurrentPlayer][CS.Style.GetChapterId(id,chapter)] = CS.Style.IsKnownStyle(id,chapter)
        known = CS.Account.style.knowledge[CS.SelectedPlayer][CS.Style.GetChapterId(id,chapter)]
        control = WM:GetControlByName('CraftStoreFixed_StylePanelScrollChild'..id..'Button'..chapter..'Texture')
        if known then control:SetColor(1,1,1,1) else control:SetColor(1,0,0,1) end
      end
    end
    CS.FilterStyles()
  end
  
end
function CS.UpdateRecipeKnowledge()
  CS.Cook.recipe = {}
  CS.Furnisher.recipe = {}
  for _,id in pairs(CS.Cook.recipelist) do
    local link,stat = ('|H1:item:%u:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h'):format(id), 0
    local name = GetItemLinkName(link)
    local known = IsItemLinkRecipeKnown(link)
    CS.Account.cook.knowledge[CS.SelectedPlayer][id] = known
    local reslink = GetItemLinkRecipeResultItemLink(link,LINK_STYLE_DEFAULT)
    local quality,itype = GetItemLinkQuality(reslink), GetItemLinkItemType(reslink)
    local _,_,text = GetItemLinkOnUseAbilityInfo(reslink)
    local level = GetItemLinkRequiredLevel(reslink)
    local levelcp = GetItemLinkRequiredChampionPoints(reslink)
    local numlevel = level+levelcp
    if levelcp>0 then
      level = CS.ChampionPointsTexture..levelcp
    end
    local function statcheck(stat) if string.find(text,stat) then return true else return false end end
    local function namecheck(stat) if string.find(name,stat) then return true else return false end end
    local fm,fs,fh = statcheck(CS.MagickaName), statcheck(CS.StaminaName), statcheck(CS.HealthName)
    if fm and fh and fs then stat = 7
    elseif fs and fh then stat = 5
    elseif fm and fh then stat = 4
    elseif fm and fs then stat = 6
    elseif fm then stat = 2
    elseif fh then stat = 1
    elseif fs then stat = 3
    else stat = 8 end
    if itype == ITEMTYPE_DRINK then stat = stat + 7 end
    if id > 70000 then stat = 15 end
    table.insert(CS.Cook.recipe,{name = ZOSF('<<C:1>>',GetItemLinkName(reslink)), stat = stat, quality = quality, level = level, numlevel = numlevel, link = link, result = reslink, known = known, id = id})
  end
  for _,id in pairs(CS.Furnisher.recipelist) do
    local link,stat = ('|H1:item:%u:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h'):format(id), 0
    local _, spectype = GetItemLinkItemType(link)
    local name = GetItemLinkName(link)
    local known = IsItemLinkRecipeKnown(link)
    CS.Account.furnisher.knowledge[CS.SelectedPlayer][id] = known
    local reslink = GetItemLinkRecipeResultItemLink(link,LINK_STYLE_DEFAULT)
    local quality,itype = GetItemLinkQuality(reslink), GetItemLinkItemType(reslink)
    local _,_,text = GetItemLinkOnUseAbilityInfo(reslink)
    local level = GetItemLinkRequiredLevel(reslink)
    local levelcp = GetItemLinkRequiredChampionPoints(reslink)
    local numlevel = level+levelcp
    if levelcp>0 then
      level = CS.ChampionPointsTexture..levelcp
    end
    stat = spectype - 171
    if level > 0 then
      table.insert(CS.Furnisher.recipe,{name = ZOSF('<<C:1>>',GetItemLinkName(reslink)), stat = stat, quality = quality, level = level, numlevel = numlevel, link = link, result = reslink, known = known, id = id})
    end
  end
  local function tsort(a,b) return a.numlevel > b.numlevel end
  table.sort(CS.Cook.recipe,tsort)
  table.sort(CS.Furnisher.recipe,tsort)
  CS.UpdateIngredientTracking()
end
function CS.UpdateIngredientTracking()
  for recid,_ in pairs(CS.Account.cook.ingredients)do
    local reslink,_ = ('|H1:item:%u:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h'):format(recid), false
    for num = 1, GetItemLinkRecipeNumIngredients(reslink) do
      local name = GetItemLinkRecipeIngredientInfo(reslink,num)
      for _,ingid in pairs(CS.Cook.ingredientlist) do
        if GetItemLinkName('|H1:item:'..ingid..':0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h') == name then CS.Cook.ingredient[ingid] = true; break end
      end
    end
  end
end
function CS.UpdateResearchWindows()
  local known, unknown, row, now, control = 0, 0, 1, GetTimeStamp()
  local pip = '|r|c808080  '..GetString(SI_BULLET)..'|r  '
  for craft,craftData in pairs(CS.Account.crafting.research[CS.SelectedPlayer]) do
    for x = 1,3 do
      control = WM:GetControlByName('CraftStoreFixed_PanelResearch'..craft..'WindowLine'..x)
      control:SetText(nil)
      control.data = nil
      control:GetNamedChild('Time'):SetText(nil)
    end
    for line,lineData in pairs(craftData) do
      for trait,traitData in pairs(lineData) do
        if traitData then known = known + 1 else unknown = unknown + 1 end
        if traitData ~= true and traitData ~= false then
          if traitData > 0 then
            control = WM:GetControlByName('CraftStoreFixed_PanelResearch'..craft..'WindowLine'..row)
            local name, icon = GetSmithingResearchLineInfo(craft,line)
            local tid = GetSmithingResearchLineTraitInfo(craft,line,trait)
            control:SetText(' |t28:28:'..icon..'|t  '..GetString('SI_ITEMTRAITTYPE',tid))
            control.data = {info = ZOSF('<<C:1>>',name)}
            if CS.SelectedPlayer == CS.CurrentPlayer then
              local _,remain = GetSmithingResearchLineTraitTimes(craft,line,trait)
              control:GetNamedChild('Time'):SetText(CS.GetTime(remain))
            else
              control:GetNamedChild('Time'):SetText(CS.GetTime(GetDiffBetweenTimeStamps(traitData,now)))
            end
            row = row + 1
          end
        end
      end
    end
    local maxsim = (CS.Account.crafting.skill[CS.SelectedPlayer][craft].maxsim or 1)
    local level = (CS.Account.crafting.skill[CS.SelectedPlayer][craft].level or 1)
    local rank = (CS.Account.crafting.skill[CS.SelectedPlayer][craft].rank or 1)
    local simcolor, current = '|cFFFFFF', row - 1
    if maxsim > 1 then if current == maxsim then simcolor = '|c00FF00' else simcolor = '|cFF0000' end end
    control = WM:GetControlByName('CraftStoreFixed_PanelResearch'..craft..'Header')
    control:GetNamedChild('Data'):SetText('|c00FF00'..known..pip..'|cFF0000'..unknown..pip..'|c808080'..CS.Loc.level..': '..level..' ('..rank..')|r')
    control:GetNamedChild('Slot'):SetText(simcolor..current..' / '..maxsim..'|r')
    row = 1; known = 0; unknown = 0
  end
end
function CS.UpdateAccountVars()
  local crafts = {CRAFTING_TYPE_BLACKSMITHING,CRAFTING_TYPE_CLOTHIER,CRAFTING_TYPE_WOODWORKING}
  for _,craft in pairs(crafts) do
    for line = 1, GetNumSmithingResearchLines(craft) do
      for trait = 1, CS.MaxTraits do
        local _,_,known = GetSmithingResearchLineTraitInfo(craft,line,trait)
        if known == false then
          local _,remaining = GetSmithingResearchLineTraitTimes(craft,line,trait)
          if remaining and remaining > 0 then CS.Account.crafting.research[CS.CurrentPlayer][craft][line][trait] = remaining + GetTimeStamp()
          else CS.Account.crafting.research[CS.CurrentPlayer][craft][line][trait] = false end
        else CS.Account.crafting.research[CS.CurrentPlayer][craft][line][trait] = true end
        CS.UpdatePanelIcon(craft,line,trait)
      end
    end
  end
  CS.Account.style.knowledge[CS.CurrentPlayer] = {}
  CS.Account.cook.knowledge[CS.CurrentPlayer] = {}
  CS.Account.furnisher.knowledge[CS.CurrentPlayer] = {}
  if not CS.Account.style.tracking[CS.CurrentPlayer] then CS.Account.style.tracking[CS.CurrentPlayer] = false end
  if not CS.Account.cook.tracking[CS.CurrentPlayer] then CS.Account.cook.tracking[CS.CurrentPlayer] = false end
  if not CS.Account.furnisher.tracking[CS.CurrentPlayer] then CS.Account.furnisher.tracking[CS.CurrentPlayer] = false end
end
function CS.UpdateQuest(qId)
  for _, quest in pairs(CS.Quest) do
    if quest.id == qId then
      local out = ''
      local title = quest.name..'\n'
      quest.work = {}
      for cId = 1, GetJournalQuestNumConditions(qId,1) do
        local text,current,maximum = GetJournalQuestConditionInfo(qId,1,cId)
        if text and text ~= '' then
          if current == maximum then text = '|c00FF00'..text..'|r' end
          quest.work[cId] = text
          out = out..text..'\n'
        end
      end
      if DolgubonsWrits and CraftStoreFixed_DolgubonsWritsEndpoint then
        if WritCreater.savedVars.tutorial then zo_callLater(function () CS.UpdateQuest(qId) end, 1000) return end
        CraftStoreFixed_DolgubonsWritsEndpoint:SetText(out)
        CraftStoreFixed_QuestText:SetText(title..out)
      else        
        CraftStoreFixed_QuestText:SetText(title..out)
      end
      return
    end
  end
end
function CS.UpdateInventory()
  local inv = {
    ZO_PlayerInventoryBackpack,ZO_PlayerBankBackpack,ZO_GuildBankBackpack,
    ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack,
    ZO_SmithingTopLevelImprovementPanelInventoryBackpack
  }
  for x = 1,#inv do
    local puffer = inv[x].dataTypes[1].setupCallback
    inv[x].dataTypes[1].setupCallback = function(control,slot)
      puffer(control,slot)
      CS.SetItemMark(control,1)
    end
  end
    local puffer1 = ZO_LootAlphaContainerList.dataTypes[1].setupCallback
    ZO_LootAlphaContainerList.dataTypes[1].setupCallback = function(control,slot)
    puffer1(control,slot)
    CS.SetItemMark(control,2)
  end
end
function CS.UpdateGuildStore()
    local puffer = TRADING_HOUSE.m_searchResultsList.dataTypes[1].setupCallback
    TRADING_HOUSE.m_searchResultsList.dataTypes[1].setupCallback = function(control,slot)
    puffer(control,slot)
    CS.SetItemMark(control,3)
  end
end
function CS.UpdateStored(action,data)
  local link, owner = data.lnk, CS.CurrentPlayer
  local craft,line,trait = CS.GetTrait(link)
  local function CompareItem(craft,line,trait,q1,l1,v1)
    if not CS.Account.crafting.stored[craft][line][trait].link then return true else
      local q2 = GetItemLinkQuality(CS.Account.crafting.stored[craft][line][trait].link)
      local l2 = GetItemLinkRequiredLevel(CS.Account.crafting.stored[craft][line][trait].link)
      local v2 = GetItemLinkRequiredChampionPoints(CS.Account.crafting.stored[craft][line][trait].link)
      if q1 < q2 then return true end if l1 < l2 then return true end if v1 < v2 then return true end return false
    end
  end
  if craft and line and trait then
    if action == 'added' then
      if data.bagId == BAG_BANK then owner = CS.Loc.bank end
      if data.bagId == BAG_GUILDBANK then owner = CS.Loc.guildbank end
      if data.bagId == BAG_VIRTUAL then owner = CS.Loc.craftbag end
      if CompareItem(craft,line,trait,GetItemLinkQuality(link),GetItemLinkRequiredLevel(link),GetItemLinkRequiredChampionPoints(link)) then
        CS.Account.crafting.stored[craft][line][trait] = { link = link, owner = owner, id = data.uid }
      end
    end
    if action == 'removed' and CS.Account.crafting.stored[craft][line][trait].id == data.uid then
      CS.Account.crafting.stored[craft][line][trait] = {}
    end
    CS.UpdatePanelIcon(craft,line,trait)
  end
end

function CS.RecipeMark(control,button)
  local mark
  if button == 2 then CS.ToChat(control.data.link)
  else
    local tracked = CS.Account.cook.ingredients[control.data.id] or false
    if tracked then
      mark = ''
      CS.Account.cook.ingredients[control.data.id] = nil
    else
      mark = '|t22:22:esoui/art/inventory/newitem_icon.dds|t '
      CS.Account.cook.ingredients[control.data.id] = true
    end
    control:SetText(mark..'('..CS.Cook.recipe[control.data.rec].level..') '..CS.Cook.recipe[control.data.rec].name)
    zo_callLater(CS.UpdateIngredientTracking,500)
  end
end
function CS.RecipeShow(id,inc,known)
  local color, mark, control
  if CS.Account.cook.ingredients[CS.Cook.recipe[id].id] then mark = '|t22:22:esoui/art/inventory/newitem_icon.dds|t ' else mark = '' end
  if CS.Cook.recipe[id].known then color = CS.Quality[CS.Cook.recipe[id].quality]; known = known + 1; else color = {1,0,0,1} end
  control = WM:GetControlByName('CraftStoreFixed_RecipePanelScrollChildButton'..inc)
  control:SetNormalFontColor(color[1],color[2],color[3],color[4])
  control:SetText(mark..'('..CS.Cook.recipe[id].level..') '..CS.Cook.recipe[id].name)
  control:SetHidden(false)
  control.data = {link = CS.Cook.recipe[id].link, rec = id, id = CS.Cook.recipe[id].id, buttons = {CS.Loc.TT[7],CS.Loc.TT[6]}}
  return inc + 1, known
end
function CS.RecipeShowCategory(list)
  if list > 15 then list = 1 end
  local inc, known = 1, 0
  for x = 1,50 do WM:GetControlByName('CraftStoreFixed_RecipePanelScrollChildButton'..x):SetHidden(true) end
  for id, recipe in pairs(CS.Cook.recipe) do
    if recipe.stat == list then inc,known = CS.RecipeShow(id,inc,known) end
  end
  CraftStoreFixed_RecipePanelScrollChild:SetHeight(inc * 22 - 13)
  CraftStoreFixed_RecipeHeadline:SetText(ZOSF('<<C:1>>',GetRecipeListInfo(list)))
  -- CraftStoreFixed_RecipeInfo:SetText(CS.Cook.category[list]..' ('..known..'/'..(inc - 1)..')')
  CraftStoreFixed_RecipeInfo:SetText('('..known..' / '..(inc - 1)..')')
  CS.Character.recipe = list
end
function CS.RecipeSearch()
  local search, inc, known = CraftStoreFixed_RecipeSearch:GetText(), 1, 0
  if search ~= '' then
    for x = 1,50 do
      local control = WM:GetControlByName('CraftStoreFixed_RecipePanelScrollChildButton'..x)
      control:SetHidden(true)
      control.data = nil
    end
    for id, food in pairs(CS.Cook.recipe) do
      if string.find(string.lower(food.name),string.lower(search)) then inc,known = CS.RecipeShow(id,inc,known) end
    end
    CraftStoreFixed_RecipePanelScrollChild:SetHeight(inc * 22 - 13)
    CraftStoreFixed_RecipeHeadline:SetText(CS.Loc.searchfor)
    CraftStoreFixed_RecipeInfo:SetText(search..' ('..(inc - 1)..')')
  end
end
function CS.RecipeLearned(list,id)
  local link = GetRecipeResultItemLink(list,id,LINK_STYLE_DEFAULT)
  if link then for id, recipe in pairs(CS.Cook.recipe) do
    if recipe.result == link then
      CS.Cook.recipe[id].known = true
      CS.Account.cook.knowledge[CS.CurrentPlayer][CS.Cook.recipe[id].id] = true
      break
    end
  end end
end

function CS.CookStart(control,button)
  if not control then return end
  if button == 3 then
    local idx = control.data.list..'_'..control.data.id
    if CS.Character.favorites[5][idx] then CS.Character.favorites[5][idx] = nil
    else CS.Character.favorites[5][idx] = {control.data.list, control.data.id} end
    CS.CookShowRecipe(control,control.data.list,control.data.id,0)
    return
  end
  if control.data.craftable then
    if GetNumBagFreeSlots(BAG_BACKPACK) > 0 then
      local amount = (tonumber(CraftStoreFixed_CookAmount:GetText()) or 1)
      if button == 2 then amount = control.data.crafting[2] end
      if amount > MAXCRAFT then amount = MAXCRAFT end
      CraftStoreFixed_CookAmount:SetText(amount)
      if amount > 1 then CS.Cook.job = {amount = amount - 1, list = control.data.list, id = control.data.id, sound = control.data.sound} end
      CraftProvisionerItem(control.data.list, control.data.id)
      PlaySound(control.data.sound)
    else d(CS.Loc.nobagspace) end
  end
end
function CS.CookShowRecipe(control,list,id,inc,sound)
  local known, name, numIngredients, pLev, qLev = GetRecipeInfo(list,id)
  local mark = ''
  if known then
    local fault, maxval, ing = false, 999999, {}
    local link = GetRecipeResultItemLink(list,id,LINK_STYLE_DEFAULT)
    local level = GetItemLinkRequiredLevel(link)
    local levelcp = GetItemLinkRequiredChampionPoints(link)
    if levelcp>0 then
      level = CS.ChampionPointsTexture..levelcp
    end
    for num = 1, numIngredients do
      local count, color = GetCurrentRecipeIngredientCount(list,id,num)
      if count == 0 then color = 'FF0000'; fault = true else color = '00FF00' end
      if count < maxval then maxval = count end
      table.insert(ing,ZOSF('<<C:1>> |c<<2>>(<<3>>)|r',GetRecipeIngredientItemLink(list,id,num,LINK_STYLE_DEFAULT),color,count))
    end
    if CS.Character.favorites[5][list..'_'..id] then mark = '|t16:16:esoui/art/characterwindow/equipmentbonusicon_full.dds|t ' else mark = '' end
    control:SetText(ZOSF(mark..'(<<1>>) <<C:2>> |c666666(<<3>>)|r',level,name,maxval))
    if fault or pLev > CS.Cook.craftLevel or qLev > CS.Cook.qualityLevel then
      control:SetNormalFontColor(1,0,0,1)
      fault = true
    else
      local color = GetItemLinkQuality(link)
      control:SetNormalFontColor(CS.Quality[color][1],CS.Quality[color][2],CS.Quality[color][3],1)
    end
    control.data = {id = id, list = list, link = link, sound = sound, crafting = {CraftStoreFixed_CookAmount,maxval}, addline = {table.concat(ing,'\n')}, craftable = not fault}
    control:SetHidden(false)
    return inc + 1
  end
  return inc
end
function CS.CookShowCategory(list)
  if not list then return end
  local inc, control, name, num = 1
  for x = 1,50 do CraftStoreFixed_CookFoodSectionScrollChild:GetNamedChild('Button'..x):SetHidden(true) end
  if list == 17 then
    name = CS.Loc.TT[11]
    for _,val in pairs(CS.Character.favorites[5]) do
      control = CraftStoreFixed_CookFoodSectionScrollChild:GetNamedChild('Button'..inc)
      inc = CS.CookShowRecipe(control,val[1],val[2],inc)
    end
  elseif list == 18 then
    name = CS.Loc.TT[23]
    if CS.Quest[CRAFTING_TYPE_PROVISIONING] then
      local lists = {1,2,3,8,9,10}
      for list_num=1,#lists do
        local _,num,_,_,_,_,sound = GetRecipeListInfo(lists[list_num])
        for id = num, 1, -1 do
          local _, name = GetRecipeInfo(lists[list_num],id)
          for _, step in pairs(CS.Quest[CRAFTING_TYPE_PROVISIONING].work) do 
            local res1, res2 = string.find(step:gsub("-",""), name)
            if res1 then
              control = CraftStoreFixed_CookFoodSectionScrollChild:GetNamedChild('Button'..inc)
              inc = CS.CookShowRecipe(control,lists[list_num],id,inc,sound)
            end
          end
        end  
      end
    end
  elseif list == 19 then
    for cat = 17,GetNumRecipeLists() do
      local _,num,_,_,_,_,sound = GetRecipeListInfo(cat)
      for id = num, 1, -1 do
        local _, _, _, _, _, _, crafttype = GetRecipeInfo(cat, id);
        if crafttype == RECIPE_CRAFTING_SYSTEM_PROVISIONING_DESIGNS then
          control = CraftStoreFixed_CookFoodSectionScrollChild:GetNamedChild('Button'..inc)
          inc = CS.CookShowRecipe(control,cat,id,inc,sound)
        end
      end
    end
  else
    local _,num,_,_,_,_,sound = GetRecipeListInfo(list)
    for id = num, 1, -1 do
      control = CraftStoreFixed_CookFoodSectionScrollChild:GetNamedChild('Button'..inc)
      inc = CS.CookShowRecipe(control,list,id,inc,sound)
    end
  end
  CraftStoreFixed_CookFoodSectionScrollChild:SetHeight(inc * 24 - 15)
  CraftStoreFixed_CookHeadline:SetText(ZOSF('<<C:1>>',name))
  CraftStoreFixed_CookInfo:SetText(CS.Cook.category[list])
  CS.Character.recipe = list
end
function CS.CookSearchRecipe()
  local search, inc, control = CraftStoreFixed_CookSearch:GetText(), 1
  if search ~= '' then
    for x = 1,50 do CraftStoreFixed_CookFoodSectionScrollChild:GetNamedChild('Button'..x):SetHidden(true) end
    for list = 1, GetNumRecipeLists() do
      local _,num = GetRecipeListInfo(list)
      for id = num, 1, -1 do
        local known, name = GetRecipeInfo(list,id)
        if string.find(string.lower(name),string.lower(search)) and known then
          control = CraftStoreFixed_CookFoodSectionScrollChild:GetNamedChild('Button'..inc)
          inc = CS.CookShowRecipe(control,list,id,inc)
        end
      end
    end
    CraftStoreFixed_CookFoodSectionScrollChild:SetHeight(inc * 23 - 10)
    CraftStoreFixed_CookHeadline:SetText(CS.Loc.searchfor)
    CraftStoreFixed_CookInfo:SetText(search)
  end
end

function CS.RuneCreate(control,button)
  if not control then return end
  if control.data.list ~= nil then
    return CS.CookStart(control,button) 
  end
  if CS.Extern and button == 2 then CS.ToChat(control.data.link); return end
  if button == 3 then
    local id, idx = control.data.glyph, control.data.glyph..'_'..control.data.quality..'_'..control.data.level
    if CS.Character.favorites[3][idx] then CS.Character.favorites[3][idx] = nil
    else CS.Character.favorites[3][idx] = { id, control.data.level, control.data.quality, control.data.essence, control.data.potencyType } end
    CS.RuneShow(control.data.nr ,id, control.data.quality, control.data.level, control.data.essence, control.data.potencyType)
    return
  end
  if control.data.craftable and not CS.Extern then
    if GetNumBagFreeSlots(BAG_BACKPACK) > 0 then
      local amount = (tonumber(CraftStoreFixed_RuneAmount:GetText()) or 1)
      if button == 2 then amount = control.data.crafting[2] end
      if amount > MAXCRAFT then amount = MAXCRAFT end
      CraftStoreFixed_RuneAmount:SetText(amount)
      if amount > 1 then CS.Rune.job = {amount = amount - 1, id = {control.data.potency,control.data.essence,control.data.aspect}} end
      local bagP, slotP = CS.ScanBag(control.data.potency)
      local bagE, slotE = CS.ScanBag(control.data.essence)
      local bagA, slotA = CS.ScanBag(control.data.aspect)
      CraftEnchantingItem(bagP,slotP,bagE,slotE,bagA,slotA)
      if CS.Account.option[13] then
        local soundP, lengthP = GetRunestoneSoundInfo(bagP,slotP)
        local soundE, lengthE = GetRunestoneSoundInfo(bagE,slotE)
        local soundA, _ = GetRunestoneSoundInfo(bagA,slotA)
        PlaySound(soundP)
        zo_callLater(function() PlaySound(soundE) end, lengthP)
        zo_callLater(function() PlaySound(soundA) end, lengthE + lengthP)
      else
        PlaySound('Enchanting_Create_Tooltip_Glow')
      end
    else d(CS.Loc.nobagspace) end
  end
end
function CS.RuneGetGylphs()
  local bag = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_BANK,BAG_BACKPACK,BAG_VIRTUAL)
  local glyphs = {}
  for _, data in pairs(bag) do
    local item = data.itemType
    local link = GetItemLink(data.bagId, data.slotIndex)
    local icon = GetItemLinkInfo(link)
    if item == ITEMTYPE_GLYPH_ARMOR or item == ITEMTYPE_GLYPH_WEAPON or item == ITEMTYPE_GLYPH_JEWELRY then
      table.insert(glyphs,{ name = ZOSF('<<C:1>>',data.name), icon = icon, link = link, quality = data.quality, bag = data.bagId, slot = data.slotIndex, crafted = IsItemLinkCrafted(link) })
    end
  end
  return glyphs
end
function CS.RuneGetLink(id,quality,rank)
  local color = {19,19,19,19,19,19,19,19,19,115,117,119,121,271,307,365,[0] = 0}
  local adder = {1,1,1,1,1,1,1,1,1,10,10,10,10,1,1,1,[0] = 0}
  local level = {5,10,15,20,25,30,35,40,45,50,50,50,50,50,50,50,[0] = 0}
  return ('|H1:item:%u:%u:%u:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h'):format(id,(color[rank] + quality * adder[rank]),level[rank])
end
function CS.RuneSetValue(key,value,ptype)
  if key == 1 then CS.Character.enchant = value
  elseif key == 2 then CS.Character.aspect = value; CraftStoreFixed_RuneLevelButton:SetNormalFontColor(CS.Quality[value][1],CS.Quality[value][2],CS.Quality[value][3],1)
  elseif key == 3 then CS.Character.potency = value; if ptype then CS.Character.potencytype = ptype end
  elseif key == 4 then CS.Character.essence = value
  elseif key == 5 then CS.Character.runemode = 'search'
  elseif key == 6 then CS.Character.runemode = 'craft'
  elseif key == 7 then CS.Character.runemode = 'refine'
  elseif key == 9 then CS.Character.runemode = 'selection'
  elseif key == 10 then CS.Character.runemode = 'favorites'
  elseif key == 11 then CS.Character.runemode = 'writ'
  elseif key == 12 then CS.Character.runemode = 'furniture'
  end
end
function CS.RuneShow(nr,id,quality,level,essence,potencytype)
  local bank, bag, virt, mark, control, color, maxval, fault, addline, countcol, col
  control = WM:GetControlByName('CraftStoreFixed_RuneGlyphSectionScrollChildButton'..nr)
  local link = CS.RuneGetLink(id,quality,level)
  local icon = GetItemLinkInfo(link)
  local basename = ZOSF('<<C:1>>',GetItemLinkName(('|H0:item:%u:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h'):format(id)))
  local potencyId, essenceId, aspectId = CS.Rune.rune[51][potencytype][level], essence, CS.Rune.rune[52][quality]
  local potencyLink, essenceLink,aspectLink = CS.RuneGetLink(potencyId,1,1), CS.RuneGetLink(essenceId,1,1), CS.RuneGetLink(aspectId,quality,1)
  local potencySkill, aspectSkill = CS.Rune.skillLevel[level], quality - 1
  bag, bank, virt = GetItemLinkStacks(potencyLink)
  local potencyCount = bag + bank + virt
  bag, bank, virt = GetItemLinkStacks(essenceLink)
  local essenceCount = bag + bank + virt
  bag, bank, virt = GetItemLinkStacks(aspectLink)
  local aspectCount = bag + bank+ virt
  maxval = math.min(potencyCount, essenceCount, aspectCount)
  if maxval == 0 or (aspectSkill > CS.Rune.aspectSkill or potencySkill > CS.Rune.potencySkill) then color = {1,0,0}; fault = true else color = CS.Quality[quality]; fault = false end
  if CS.Character.favorites[3][id..'_'..quality..'_'..level] then mark = '|t16:16:esoui/art/characterwindow/equipmentbonusicon_full.dds|t ' else mark = '' end
  control:SetText(mark..'|t24:24:'..icon..'|t '..basename..' |c666666('..maxval..')|r')
  control:SetNormalFontColor(color[1],color[2],color[3],1)
  if potencyCount == 0 or potencySkill > CS.Rune.potencySkill then col = 'FF0000' else col = 'FFFFFF' end
  if potencyCount == 0 then countcol = 'FF0000' else countcol = '00FF00' end
  addline = '|t22:22:'..GetItemLinkInfo(potencyLink)..'|t |c'..col..ZOSF('<<C:1>>',GetItemLinkName(potencyLink))..' |c'..countcol..'('..potencyCount..')|r'
  if essenceCount == 0 then col = 'FF0000' else col = 'FFFFFF' end
  if essenceCount == 0 then countcol = 'FF0000' else countcol = '00FF00' end
  addline = addline..'|r  |t22:22:'..GetItemLinkInfo(essenceLink)..'|t |c'..col..ZOSF('<<C:1>>',GetItemLinkName(essenceLink))..' |c'..countcol..'('..essenceCount..')|r'
  if aspectCount == 0 or aspectSkill > CS.Rune.aspectSkill then col = 'FF0000' else col = CS.QualityHex[quality] end
  if aspectCount == 0 then countcol = 'FF0000' else countcol = '00FF00' end
  addline = addline..'|r  |t22:22:'..GetItemLinkInfo(aspectLink)..'|t |c'..col..ZOSF('<<C:1>>',GetItemLinkName(aspectLink))..' |c'..countcol..'('..aspectCount..')|r'
  control:SetHidden(false)
  control.data = {
    nr = nr, link = link, addline = {addline}, crafting = {CraftStoreFixed_RuneAmount,maxval}, craftable = not fault, 
    quality = quality, level = level, glyph = id, potency = potencyId, essence = essenceId, aspect = aspectId, potencyType = potencytype
  }
end
function CS.RuneShowCategory()
  local count = 1
  CraftStoreFixed_RuneInfo:SetText(GetString(SI_CRAFTING_PERFORM_FREE_CRAFT))
  local function tsort(a,b) return a[4] < b[4] end
  table.sort(CS.Rune.glyph[CS.Character.enchant],tsort)
  for _,glyph in pairs(CS.Rune.glyph[CS.Character.enchant]) do
    CS.RuneShow(count,glyph[1],CS.Character.aspect,CS.Character.potency,glyph[2],glyph[3])
    count = count + 1
  end
  CraftStoreFixed_RuneGlyphSectionScrollChild:SetHeight(#CS.Rune.glyph[CS.Character.enchant] * 30 + 20)
end
function CS.RuneRefine(control)
  if GetNumBagFreeSlots(BAG_BACKPACK) >= 3 then
    ExtractEnchantingItem(control.data.bag, control.data.slot)
    PlaySound('Enchanting_Extract_Start_Anim')
  else d(CS.Loc.nobagspace) end
end
function CS.RefineAll(_,button)
  CS.Rune.refine = {glyphs = CS.RuneGetGylphs(), crafted = (button == 2)}
  if #CS.Rune.refine.glyphs > 0 then
    local remove = true
    while remove do
      if CS.Rune.refine.glyphs[1] and CS.Rune.refine.glyphs[1].crafted and not CS.Rune.refine.crafted then 
        table.remove(CS.Rune.refine.glyphs,1) 
      else
        remove = false 
      end
    end
    
    
    if CS.Rune.refine.glyphs[1] then
      if GetNumBagFreeSlots(BAG_BACKPACK) >= 3 then
        ExtractEnchantingItem(CS.Rune.refine.glyphs[1].bag, CS.Rune.refine.glyphs[1].slot)
        PlaySound('Enchanting_Extract_Start_Anim')
        table.remove(CS.Rune.refine.glyphs,1)
      else d(CS.Loc.nobagspace) end
    end
  end
end
function CS.RuneShowMode()
  CraftStoreFixed_RuneGlyphDivider:SetHidden(true)
  CraftStoreFixed_RuneGlyphSectionScrollChildRefine:SetHidden(true)
  CraftStoreFixed_RuneGlyphSectionScrollChildSelection:SetHidden(true)
  CraftStoreFixed_RuneRefineAllButton:SetHidden(true)
  for x = 1,25 do WM:GetControlByName('CraftStoreFixed_RuneGlyphSectionScrollChildButton'..x):SetHidden(true) end
    if CS.Character.runemode == 'craft' then CS.RuneShowCategory()
    elseif CS.Character.runemode == 'search' then CS.RuneSearch()
    elseif CS.Character.runemode == 'refine' then CS.RuneShowRefine()
    elseif CS.Character.runemode == 'selection' then CS.RuneShowSelection()
    elseif CS.Character.runemode == 'favorites' then CS.RuneShowFavorites()
    elseif CS.Character.runemode == 'writ' then CS.RuneShowWrit()
    elseif CS.Character.runemode == 'furniture' then CS.RuneShowFurniture()
  end
end
function CS.RuneShowRefine()
  CraftStoreFixed_RuneInfo:SetText(GetString(SI_CRAFTING_PERFORM_EXTRACTION))
  CraftStoreFixed_RuneGlyphSectionScrollChildRefine:SetHidden(false)
  CraftStoreFixed_RuneRefineAllButton:SetHidden(false)
  for x = 1, CraftStoreFixed_RuneGlyphSectionScrollChildRefine:GetNumChildren() do
    CraftStoreFixed_RuneGlyphSectionScrollChildRefine:GetChild(x):SetHidden(true)
    CraftStoreFixed_RuneGlyphSectionScrollChildRefine:GetChild(x):ClearAnchors()
  end
  local count, crafted = 0
  for x, glyph in pairs(CS.RuneGetGylphs()) do
    local c = WM:GetControlByName('CraftStoreFixed_GlyphControl'..x)
    if not c then
      c = WM:CreateControl('CraftStoreFixed_GlyphControl'..x,CraftStoreFixed_RuneGlyphSectionScrollChildRefine,CT_BUTTON)
      c:SetAnchor(TOPLEFT,CraftStoreFixed_RuneGlyphSectionScrollChild,TOPLEFT,8,5 + (x - 1) * 30)
      c:SetDimensions(508,30)
      c:SetFont('ZoFontGame')
      c:SetClickSound('Click')
      c:SetMouseOverFontColor(1,0.66,0.2,1)
      c:SetHorizontalAlignment(0)
      c:SetVerticalAlignment(1)
      c:SetHandler('OnMouseEnter',function(self) CS.Tooltip(self,true,false,CraftStoreFixed_Rune,'tl') end)
      c:SetHandler('OnMouseExit',function(self) CS.Tooltip(self,false) end)
      c:SetHandler('OnClicked',function(self) CS.RuneRefine(self) end)
    end
    if glyph.crafted then crafted = '|t22:22:esoui/art/treeicons/achievements_indexicon_crafting_up.dds|t ' else crafted = '' end
    c:SetHidden(false)
    c:SetText(crafted..'|t24:24:'..glyph.icon..'|t '..glyph.name)
    c:SetNormalFontColor(CS.Quality[glyph.quality][1],CS.Quality[glyph.quality][2],CS.Quality[glyph.quality][3],1)
    c.data = { link = glyph.link, bag = glyph.bag, slot = glyph.slot, buttons = {CS.Loc.TT[8]} }
    count = count + 1
  end
  CraftStoreFixed_RuneGlyphSectionScrollChild:SetHeight(count * 30 + 20)
end
function CS.RuneShowSelection()
  local color, count = 'FFFFFF', 0
  local function RuneSelected()
    local essence = CS.SplitLink(CS.RuneGetLink(CS.Rune.rune[ITEMTYPE_ENCHANTING_RUNE_ESSENCE][CS.Character.essence],1,1),3)
    for _, enchant in pairs(CS.Rune.glyph) do
      for _, glyph in pairs(enchant) do
        if glyph[2] == essence and glyph[3] == CS.Character.potencytype then
          CS.RuneShow(1,glyph[1],CS.Character.aspect,CS.Character.potency,essence,glyph[3])
          return
        end
      end
    end
  end
  for x,rune in pairs(CS.Rune.rune[ITEMTYPE_ENCHANTING_RUNE_POTENCY][1]) do
    local link = CS.RuneGetLink(rune,1,1)
    local known = GetItemLinkEnchantingRuneName(link)
    local bag, bank, virt = GetItemLinkStacks(link)
    count = bag + bank + virt
    color = CS.Quality[GetItemLinkQuality(link)]
    if count == 0 then color = {0.4,0.4,0.4} end
    if not known then color = {1,0,0} end
    local btn = WM:GetControlByName('CraftStoreFixed_RuneGlyphSectionScrollChild1Selector'..x)
    if not btn then
      btn = WM:CreateControl('CraftStoreFixed_RuneGlyphSectionScrollChild1Selector'..x,CraftStoreFixed_RuneGlyphSectionScrollChildSelection,CT_BUTTON)
      btn:SetAnchor(3,nil,3,8,50 + (x-1) * 30)
      btn:SetDimensions(160,30)
      btn:SetFont('ZoFontGame')
      btn:EnableMouseButton(2,true)
      btn:SetClickSound('Click')
      btn:SetNormalFontColor(color[1],color[2],color[3],1)
      btn:SetMouseOverFontColor(1,0.66,0.2,1)
      btn:SetHorizontalAlignment(0)
      btn:SetVerticalAlignment(1)
      btn:SetHandler('OnMouseEnter',function(self) CS.Tooltip(self,true,false,CraftStoreFixed_Rune,'tl') end)
      btn:SetHandler('OnMouseExit',function(self) CS.Tooltip(self,false) end)
      btn:SetHandler('OnMouseDown',function(self,button)
        if button == 1 then
          CS.RuneSetValue(3,x,1)
          CraftStoreFixed_RuneLevelButton:SetText(CS.Loc.level..': '..CS.Rune.level[x])
          CraftStoreFixed_RuneHighlight1:SetAnchor(2,WM:GetControlByName('CraftStoreFixed_RuneGlyphSectionScrollChild1Selector'..x),2,-14,0)
          RuneSelected()
        elseif button == 2 then CS.ToChat(link) end
      end)
    end
    btn:SetText('|t24:24:'..GetItemLinkInfo(link)..'|t '..ZOSF('<<C:1>>',GetItemLinkName(link))..' |c666666('..count..')')
    btn.data = { link = link, addline = {'|cFFAA33CraftStoreRune:|r '..CS.Loc.level..' '..CS.Rune.level[x]} }
  end
  for x,rune in pairs(CS.Rune.rune[ITEMTYPE_ENCHANTING_RUNE_POTENCY][2]) do
    local link = CS.RuneGetLink(rune,1,1)
    local known = GetItemLinkEnchantingRuneName(link)
    local bag, bank, virt = GetItemLinkStacks(link)
    count = bag + bank + virt
    color = CS.Quality[GetItemLinkQuality(link)]
    if count == 0 then color = {0.4,0.4,0.4} end
    if not known then color = {1,0,0} end
    local btn = WM:GetControlByName('CraftStoreFixed_RuneGlyphSectionScrollChild2Selector'..x)
    if not btn then
      btn = WM:CreateControl('CraftStoreFixed_RuneGlyphSectionScrollChild2Selector'..x,CraftStoreFixed_RuneGlyphSectionScrollChildSelection,CT_BUTTON)
      btn:SetAnchor(3,nil,3,170,50 + (x-1) * 30)
      btn:SetDimensions(160,30)
      btn:SetFont('ZoFontGame')
      btn:EnableMouseButton(2,true)
      btn:SetClickSound('Click')
      btn:SetNormalFontColor(color[1],color[2],color[3],1)
      btn:SetMouseOverFontColor(1,0.66,0.2,1)
      btn:SetHorizontalAlignment(0)
      btn:SetVerticalAlignment(1)
      btn:SetHandler('OnMouseEnter',function(self) CS.Tooltip(self,true,false,CraftStoreFixed_Rune,'tl') end)
      btn:SetHandler('OnMouseExit',function(self) CS.Tooltip(self,false) end)
      btn:SetHandler('OnMouseDown',function(self,button)
        if button == 1 then
          CS.RuneSetValue(3,x,2)
          CraftStoreFixed_RuneLevelButton:SetText(CS.Loc.level..': '..CS.Rune.level[x])
          CraftStoreFixed_RuneHighlight1:SetAnchor(2,WM:GetControlByName('CraftStoreFixed_RuneGlyphSectionScrollChild2Selector'..x),2,-14,0)
          RuneSelected()
        elseif button == 2 then CS.ToChat(link) end
      end)
    end
    btn:SetText('|t24:24:'..GetItemLinkInfo(link)..'|t '..ZOSF('<<C:1>>',GetItemLinkName(link))..' |c666666('..count..')')
    btn.data = { link = link, addline = {'|cFFAA33CraftStoreRune:|r '..CS.Loc.level..' '..CS.Rune.level[x]} }
  end
  for x,rune in pairs(CS.Rune.rune[ITEMTYPE_ENCHANTING_RUNE_ESSENCE]) do
    local link = CS.RuneGetLink(rune,1,1)
    local known = GetItemLinkEnchantingRuneName(link)
    local bag, bank, virt = GetItemLinkStacks(link)
    count = bag + bank + virt
    color = CS.Quality[GetItemLinkQuality(link)]
    if count == 0 then color = {0.4,0.4,0.4} end
    if not known then color = {1,0,0} end
    local btn = WM:GetControlByName('CraftStoreFixed_RuneGlyphSectionScrollChild3Selector'..x)
    if not btn then
      btn = WM:CreateControl('CraftStoreFixed_RuneGlyphSectionScrollChild3Selector'..x,CraftStoreFixed_RuneGlyphSectionScrollChildSelection,CT_BUTTON)
      btn:SetAnchor(3,nil,3,332,50 + (x-1) * 30)
      btn:SetDimensions(160,30)
      btn:SetFont('ZoFontGame')
      btn:EnableMouseButton(2,true)
      btn:SetClickSound('Click')
      btn:SetNormalFontColor(color[1],color[2],color[3],1)
      btn:SetMouseOverFontColor(1,0.66,0.2,1)
      btn:SetHorizontalAlignment(0)
      btn:SetVerticalAlignment(1)
      btn:SetHandler('OnMouseEnter',function(self) CS.Tooltip(self,true,false,CraftStoreFixed_Rune,'tl') end)
      btn:SetHandler('OnMouseExit',function(self) CS.Tooltip(self,false) end)
      btn:SetHandler('OnMouseDown',function(self,button)
        if button == 1 then
          CraftStoreFixed_RuneHighlight2:SetAnchor(2,WM:GetControlByName('CraftStoreFixed_RuneGlyphSectionScrollChild3Selector'..x),2,-14,0)
          CS.RuneSetValue(4,x)
          RuneSelected()
        elseif button == 2 then CS.ToChat(link) end
      end)
    end
    btn:SetText('|t24:24:'..GetItemLinkInfo(link)..'|t '..ZOSF('<<C:1>>',GetItemLinkName(link))..' |c666666('..count..')')
    btn.data = { link = link }
  end
  local dot = WM:GetControlByName('CraftStoreFixed_RuneHighlight1')
  if not dot then
    dot = WM:CreateControl('CraftStoreFixed_RuneHighlight1',CraftStoreFixed_RuneGlyphSectionScrollChildSelection,CT_TEXTURE)
    dot:SetAnchor(2,WM:GetControlByName('CraftStoreFixed_RuneGlyphSectionScrollChild'..CS.Character.potencytype..'Selector'..CS.Character.potency),2,-14,0)
    dot:SetDimensions(48,48)
    dot:SetColor(1,1,1,1)
    dot:SetTexture('esoui/art/quickslots/quickslot_highlight_blob.dds')
  end
  dot = WM:GetControlByName('CraftStoreFixed_RuneHighlight2')
  if not dot then
    dot = WM:CreateControl('CraftStoreFixed_RuneHighlight2',CraftStoreFixed_RuneGlyphSectionScrollChildSelection,CT_TEXTURE)
    dot:SetAnchor(2,WM:GetControlByName('CraftStoreFixed_RuneGlyphSectionScrollChild3Selector'..CS.Character.essence),2,-14,0)
    dot:SetDimensions(48,48)
    dot:SetColor(1,1,1,1)
    dot:SetTexture('esoui/art/quickslots/quickslot_highlight_blob.dds')
  end
  CraftStoreFixed_RuneGlyphDivider:SetHidden(false)
  CraftStoreFixed_RuneGlyphSectionScrollChildSelection:SetHidden(false)
  CraftStoreFixed_RuneInfo:SetText(GetString(SI_CRAFTING_PERFORM_FREE_CRAFT))
  RuneSelected()
end
function CS.RuneSearch()
  local search, count = CraftStoreFixed_RuneSearch:GetText(), 1
  if search ~= '' then
    for _,enchant in pairs(CS.Rune.glyph) do
      for _,glyph in pairs(enchant) do
        local basename = ZOSF('<<C:1>>',GetItemLinkName(('|H1:item:%u:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h'):format(glyph[1])))
        if string.find(string.lower(basename),string.lower(search)) then
          CS.RuneShow(count,glyph[1],CS.Character.aspect,CS.Character.potency,glyph[2],glyph[3])
          count = count + 1
        end
      end
    end
    CraftStoreFixed_RuneGlyphSectionScrollChild:SetHeight(count * 24 + 20)
    CraftStoreFixed_RuneInfo:SetText(CS.Loc.searchfor..' '..search)
  end
end
function CS.RuneShowFurniture()
  local inc = 1
  for cat = 17,GetNumRecipeLists() do
    local _,num,_,_,_,_,sound = GetRecipeListInfo(cat)
    for id = num, 1, -1 do
      local _, _, _, _, _, _, crafttype = GetRecipeInfo(cat, id);
      if crafttype == RECIPE_CRAFTING_SYSTEM_ENCHANTING_SCHEMATICS then
        control =  WM:GetControlByName('CraftStoreFixed_RuneGlyphSectionScrollChildButton'..inc)
        inc = CS.CookShowRecipe(control,cat,id,inc,sound)
      end
    end
  end
end


function CS.RuneShowWrit()
  CS.GetQuest()
  
  local function GetLevelName(level)
    local basename = ZOSF('<<t:1>>', GetItemLinkName(CS.RuneGetLink(26580,0,0)))
    local basedata = { zo_strsplit(' ', basename) }
    local name = ZOSF('<<t:1>>', GetItemLinkName(CS.RuneGetLink(26580,3,level)))
    local namedata = { zo_strsplit(' ', name) }
    for j = #namedata, 1, -1 do
      for i = #basedata, 1, -1 do
        if namedata[j] == basedata[i] then
          table.remove(namedata, j)
          table.remove(basedata, i)
        end 
      end
    end
    return ZOSF('<<C:1>>', table.concat(namedata,' '))
  end
  
  local function GetEssenceName(essence)
    local basename = ZOSF('<<t:1>>', GetItemLinkName(CS.RuneGetLink(68343,0,0)))
    local basedata = { zo_strsplit(' ', basename) }
    local name = ZOSF('<<t:1>>', GetItemLinkName(CS.RuneGetLink(essence,0,0)))
    local namedata = { zo_strsplit(' ', name) }
    for j = #namedata, 1, -1 do
      for i = #basedata, 1, -1 do
        if namedata[j] == basedata[i] then
          table.remove(namedata, j)
          table.remove(basedata, i)
        end 
      end
    end
    return ZOSF('<<C:1>>', table.concat(namedata,' '))
  end
  
  local levels = {}
  for level=1,16 do
    levels[level] = GetLevelName(level)
  end
  
  local runes = {{id=26580,name="",essence="oko"},{id=26582,name="",essence="makko"},{id=26588,name="",essence="deni"}}
  for rune=1,#runes do
    runes[rune].name = GetEssenceName(runes[rune].id)
  end
  
  if CS.Quest[CRAFTING_TYPE_ENCHANTING] then
    for _, step in pairs(CS.Quest[CRAFTING_TYPE_ENCHANTING].work) do 
      local writ_level = nil
      local writ_rune = nil
      for level = 1,16 do
        local res1, res2 = string.find(step, levels[level])
        if res1 then writ_level = level end
      end
      for rune = 1,#runes do
        local res1, res2 = string.find(step, runes[rune].name)
        if res1 then writ_rune = rune end
      end
      if writ_level and writ_rune then
        CS.RuneShow(1,runes[writ_rune].id,1,writ_level,45830+writ_rune,1)
      end
    end
  end
end

function CS.RuneShowFavorites()
  local count = 1
  for _,glyph in pairs(CS.Character.favorites[3]) do CS.RuneShow(count,glyph[1],glyph[3],glyph[2],glyph[4],glyph[5]); count = count + 1 end
  CraftStoreFixed_RuneGlyphSectionScrollChild:SetHeight(#CS.Character.favorites[3] * 24 + 20)
  CraftStoreFixed_RuneInfo:SetText(CS.Loc.TT[11])
end
function CS.RuneView(mode)
  local function Close()
    CraftStoreFixed_Rune:SetHidden(true)
    CraftStoreFixed_RuneCreateButton:SetHidden(false)
    CraftStoreFixed_RuneRefineButton:SetHidden(false)
    CraftStoreFixed_RuneHeader:SetWidth(440)
    CraftStoreFixed_RuneSearch:SetWidth(150)
    CraftStoreFixed_RuneSearchBG:SetWidth(160)
    CraftStoreFixed_RuneInfo:SetHidden(false)
    CraftStoreFixed_RuneAmount:SetHidden(false)
    CraftStoreFixed_RuneAmountLabel:SetHidden(false)
    CS.Extern = false
  end
  if ZO_EnchantingTopLevel:IsHidden() then
    if mode == 1 and CraftStoreFixed_Rune:IsHidden() then
      CraftStoreFixed_RuneCreateButton:SetHidden(true)
      CraftStoreFixed_RuneRefineButton:SetHidden(true)
      CraftStoreFixed_RuneHeader:SetWidth(522)
      CraftStoreFixed_RuneSearch:SetWidth(290)
      CraftStoreFixed_RuneSearchBG:SetWidth(300)
      CraftStoreFixed_RuneInfo:SetHidden(true)
      CraftStoreFixed_RuneAmount:SetHidden(true)
      CraftStoreFixed_RuneAmountLabel:SetHidden(true)
      CS.Extern = true
      CS.Character.runemode = 'craft'
      CS.RuneInitalize()
    else Close() end
  end
end
function CS.RuneInitalize()
  CS.Rune.aspectSkill = GetNonCombatBonus(NON_COMBAT_BONUS_ENCHANTING_RARITY_LEVEL)
  CS.Rune.potencySkill = GetNonCombatBonus(NON_COMBAT_BONUS_ENCHANTING_LEVEL)
  CraftStoreFixed_RuneLevelButton:SetNormalFontColor(CS.Quality[CS.Character.aspect][1],CS.Quality[CS.Character.aspect][2],CS.Quality[CS.Character.aspect][3],1)
  CS.RuneShowMode()
  CraftStoreFixed_RuneAmount:SetText('')
  CraftStoreFixed_RuneSearch:SetText(GetString(SI_GAMEPAD_HELP_SEARCH)..'...')
  CraftStoreFixed_Rune:SetHidden(false)
end

function CS.SetTimer(control,hour)
  local seconds = hour * 3600
  if CS.Account.timer[hour] > 0 then
    control:SetText(hour..':00h')
    CS.Account.timer[hour] = 0
  else 
    control:SetText(CS.GetTime(seconds - 1))
    CS.Account.timer[hour] = seconds + GetTimeStamp()
  end
  CS.GetTimer()
end
function CS.SetItemMark(control,linksource)
  if not control then return end
  local function GetMark(control)
    local name = control:GetName()
    if not ITEMMARK[name] then ITEMMARK[name] = WM:CreateControl(name..'CSMark',control,CT_TEXTURE) end
    ITEMMARK[name]:SetDrawLayer(3)
    ITEMMARK[name]:SetDimensions(30,30)
    ITEMMARK[name]:SetHidden(true)
    ITEMMARK[name]:ClearAnchors()
    return ITEMMARK[name]
  end
  local function Show(mark,icon,color)
    if color == false then color = {1,0,1}
    elseif color == true then color = {1,0,0} end    
    mark:SetColor(color[1],color[2],color[3],0.8)
    mark:SetHidden(false)
    if (control:GetWidth() - control:GetHeight()) > 5 then mark:SetAnchor(LEFT,control:GetNamedChild('Bg'),LEFT,0,0)
    else mark:SetAnchor(TOPLEFT,control:GetNamedChild('Bg'),TOPLEFT,-4,-4) end
    mark:SetTexture(icon)
  end
    local slot, link = control.dataEntry.data or nil, nil
  local uid = Id64ToString(GetItemUniqueId(slot.bagId,slot.slotIndex)) or nil
  if linksource == 3 then link = GetTradingHouseSearchResultItemLink(slot.slotIndex); uid = nil
  elseif linksource == 2 then link = GetLootItemLink(slot.lootId); uid = nil
  elseif linksource == 1 then link = GetItemLink(slot.bagId,slot.slotIndex) end
  if not slot or not link then return end
  local mark = GetMark(control)
  if CS.Account.option[11] then
    local trait = GetItemTrait(slot.bagId,slot.slotIndex)
    if trait == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or trait == ITEM_TRAIT_TYPE_WEAPON_INTRICATE then
      Show(mark,'esoui/art/icons/servicemappins/servicepin_smithy.dds',{0,1,1}); return
    elseif trait == ITEM_TRAIT_TYPE_ARMOR_ORNATE or trait == ITEM_TRAIT_TYPE_WEAPON_ORNATE or trait == ITEM_TRAIT_TYPE_JEWELRY_ORNATE then
      Show(mark,'esoui/art/guild/guild_tradinghouseaccess.dds',{1,1,0}); return
    end 
  end
  if CS.Account.option[10] then
    --local item = (slot.itemType or GetItemLinkItemType(link))
    local item, specializedItemType = GetItemLinkItemType(link)
    if item == ITEMTYPE_INGREDIENT then
      local ingid = CS.SplitLink(link,3)
      if ingid then if CS.Cook.ingredient[ingid] then Show(mark,'esoui/art/inventory/newitem_icon.dds',{0,1,0}); return end end
    end
    if item == ITEMTYPE_RACIAL_STYLE_MOTIF then
      if CS.IsStyleNeeded(link) ~= '' then Show(mark,'esoui/art/inventory/newitem_icon.dds',SELF); return end
    end
    if item == ITEMTYPE_RECIPE then
      
      if specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING or
      specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING or
      specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING or
      specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING or
      specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING or
      specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING then
        if CS.IsRecipeFurnisherNeeded(link) ~= '' then Show(mark,'esoui/art/inventory/newitem_icon.dds',SELF); return end
      else
        if CS.IsRecipeNeeded(link) ~= '' then Show(mark,'esoui/art/inventory/newitem_icon.dds',SELF); return end
      end
    end
    local craft,line,trait = CS.GetTrait(link)
    if craft and line and trait then
      if CS.IsItemNeeded(craft,line,trait,uid,link) ~= '' then
        Show(mark,'esoui/art/inventory/newitem_icon.dds',SELF)
        return
      end
    end
  end
end
function CS.SetAllStyles()
  if MODE == 1 then CraftStoreFixed_Style_Window:SetHidden(true); MODE = 0; return end
  CraftStoreFixed_StylePanelScrollChildStyles:SetHidden(false)
  CraftStoreFixed_StylePanelScrollChildSets:SetHidden(true)
  CraftStoreFixed_StyleHeader:SetText('CraftStoreStyles')
  CS.ControlShow(CraftStoreFixed_Style_Window)
  MODE = 1
end
function CS.CloseStyle()
  CraftStoreFixed_Style_Window:SetHidden(true)
  ACHIEVEMENTS.popup:Hide()
  MODE = 0
end
function CS.HideStyles(init)
  local val, tex = {[true]='checked',[false]='unchecked'}, '|t16:16:esoui/art/buttons/checkbox_<<1>>.dds|t |t2:2:x.dds|t '
  if not init then CS.Character.hidestyles = not CS.Character.hidestyles end
  CraftStoreFixed_StyleHideButton:SetText(ZOSF(tex,val[CS.Character.hidestyles])..CS.Loc.hideStyles)
  CS.FilterStyles()  
end

function CS.HidePerfectedStyles(init)
  local val, tex = {[true]='checked',[false]='unchecked'}, '|t16:16:esoui/art/buttons/checkbox_<<1>>.dds|t |t2:2:x.dds|t '
  if not init then CS.Character.hideperfectedstyles = not CS.Character.hideperfectedstyles end
  CraftStoreFixed_StyleHidePerfectedButton:SetText(ZOSF(tex,val[CS.Character.hideperfectedstyles])..CS.Loc.hidePerfectedStyles)
  CS.FilterStyles()  
end

function CS.FilterStyles()
  local h = {[true]=0,[false]=90}
  local filterPerfected = CS.Character.hideperfectedstyles
  local filterSimple = CS.Character.hidestyles
  for id = 1,GetNumSmithingStyleItems() do
    local _, _, _, _, style = GetSmithingStyleItemInfo(id)
    if CS.Style.CheckStyle(id) then
      local c = WM:GetControlByName('CraftStoreFixed_StyleRow'..id)
      if (filterPerfected and CS.Style.IsPerfectedStyle(id)) 
      or (filterSimple and CS.Style.IsSimpleStyle(id)) then
        c:SetHidden(true)
        c:SetHeight(h[true])
      else
        c:SetHidden(false)
        c:SetHeight(h[false])
      end
    end
  end
end

function CS.UpdateIcons()
  local pre, icons = 0, {8,5,9,12,7,3,2,1,14,10,6,13,4,11}
  for id = 1,GetNumSmithingStyleItems() do
    local _, _, _, _, style = GetSmithingStyleItemInfo(id)
    if CS.Style.CheckStyle(id) then
      local icon, link, name, aName, aLink, popup = CS.Style.GetHeadline(id)
      for z,y in pairs(icons) do
        icon, link = CS.Style.GetIconAndLink(id,y)
        local tex = WM:GetControlByName('CraftStoreFixed_StylePanelScrollChild'..id..'Button'..y..'Texture')
        tex:SetTexture(icon)
      end
    end
  end
end

function CS.InitPreviews()
  local previews = {CS.Loc.previewType[1], CS.Loc.previewType[2], CS.Loc.previewType[3], CS.Loc.previewType[4]}
  local combo = CraftStoreFixed_StylePreviewType
  local selected = combo.name
  local dropdown = combo.dropdown
  
  if not CS.Character.previewType then 
    CS.Character.previewType = 1
  end
  
  dropdown:SetSelectedItem(CS.Loc.previewType[CS.Character.previewType])
  
  local function OnItemSelect(_, choiceText, choice)
    
    CS.Character.previewType = CS.previewType[choiceText]
    CS.Style.UpdatePreview(CS.previewType[choiceText])
    CS.UpdateIcons()
  end
  
  for i=1,#previews do
    local entry = dropdown:CreateItemEntry(previews[i], OnItemSelect)
    dropdown:AddItem(entry)
  end
end


function CS.GetQuest()
  local function GetQuestCraft(qName)
    local craftString={
      [CRAFTING_TYPE_BLACKSMITHING]={'blacksmith','schmied','forge','forgeron'},
      [CRAFTING_TYPE_CLOTHIER]={'cloth','schneider','tailleur'},
      [CRAFTING_TYPE_ENCHANTING]={'enchant','verzauber','enchantement','enchanteur'},
      [CRAFTING_TYPE_ALCHEMY]={'alchemist','alchemie','alchimie','alchimiste'},
      [CRAFTING_TYPE_PROVISIONING]={'provision','versorg','cuisine','cuisinier'},
      [CRAFTING_TYPE_WOODWORKING]={'woodwork','schreiner','travail du bois'}
    }
    for x, craft in pairs(craftString) do
      for _,s in pairs(craft) do if string.find(string.lower(qName),s)then return x end end
    end
    return false
  end
  CS.Quest = {}
  for qId = 1, MAX_JOURNAL_QUESTS do
    if IsValidQuestIndex(qId) then
      if GetJournalQuestType(qId) == QUEST_TYPE_CRAFTING then
        local qName,_,activeText,_,_,completed = GetJournalQuestInfo(qId)
        local craft = GetQuestCraft(qName)
        if craft and not completed then
          CS.Quest[craft] = {id = qId, name = ZOSF('|cFFFFFF<<C:1>>|r',qName), work = {}}
          for cId = 1, GetJournalQuestNumConditions(qId,1) do
            local text,current,maximum,_,complete = GetJournalQuestConditionInfo(qId,1,cId)
            if text and text ~= ''and not complete then
              if current == maximum then text = '|c00FF00'..text..'|r' end
              CS.Quest[craft].work[cId] = text
            end
          end
        elseif craft then CS.Quest[craft] = {id = qId, name = '|cFFFFFF'..qName..'|r', work = {[1] = activeText}} end
      end
    end
  end
end
function CS.GetTime(seconds)
  if seconds and seconds > 0 then
    seconds = tostring(ZO_FormatTime(seconds,TIME_FORMAT_STYLE_COLONS,TIME_FORMAT_PRECISION_SECONDS))
    local ts,endtime,y={},'',0
    for x in string.gmatch(seconds,'%d+') do ts[y] = x; y = y + 1; end
    if y == 4 then
      if tonumber(ts[1]) < 10 then ts[1] = '0'..ts[1] end
      endtime = ts[0]..'d '..ts[1]..':'..ts[2]..'h'
    end
    if y == 3 then
      if tonumber(ts[0]) < 10 then ts[0] = '0'..ts[0] end
      endtime = ts[0]..':'..ts[1]..'h'
    end
    if y == 2 then endtime = ts[0]..'min' end
    return endtime
  else return '|cFF4020'..CS.Loc.finished..'|r' end
end
function CS.GetTimer()
  CS.UpdatePlayer()
  TIMER = {}
  for _,x in pairs(CS.Account.announce) do if x + 3600 > GetTimeStamp() then x = nil end end
  if CS.Account.timer[12] > 0 then table.insert(TIMER,{id = "AccountTimer12", info = CS.Loc.finish12, time = CS.Account.timer[12]}) end
  if CS.Account.timer[24] > 0 then table.insert(TIMER,{id = "AccountTimer24",info = CS.Loc.finish24, time = CS.Account.timer[24]}) end
  local crafts = {CRAFTING_TYPE_BLACKSMITHING,CRAFTING_TYPE_CLOTHIER,CRAFTING_TYPE_WOODWORKING}
  for _, char in pairs(CS.GetCharacters()) do
    if CS.Account.player[char].mount.time > 1 then table.insert(TIMER,{info = ZOSF(CS.Loc.finishMount, char), id = char..'mount', time = CS.Account.player[char].mount.time}) end
    for _,craft in pairs(crafts) do
      for line = 1, GetNumSmithingResearchLines(craft) do
        for trait = 1, CS.MaxTraits do
          local ts = CS.Account.crafting.research[char][craft][line][trait] or false
          if ts ~= true and ts ~= false then
          if ts and ts > 1 then
            table.insert(TIMER,{id = char..craft..line..trait, info = ZOSF(CS.Loc.finishResearch,char,GetString('SI_ITEMTRAITTYPE',GetSmithingResearchLineTraitInfo(craft,line,trait)),GetSmithingResearchLineInfo(craft,line)), time = CS.Account.crafting.research[char][craft][line][trait]})
          end end
        end
      end
    end
  end
end
function CS.GetCharacters()
  local function TableSort(t)
    local orderedIndex = {}
    for key in pairs(t) do table.insert(orderedIndex,key) end
    table.sort(orderedIndex)
    return orderedIndex
  end
  return TableSort(CS.Account.player)
end
function CS.GetTrait(link)
  if not link then return false end
  local trait,eq,craft=GetItemLinkTraitInfo(link),GetItemLinkEquipType(link)
  if not CS.IsValidEquip(eq)or not CS.IsValidTrait(trait)then return false end
  local at,wt,line=GetItemLinkArmorType(link),GetItemLinkWeaponType(link),nil
  if trait==25 then trait=19 end -- Nirnhoned Weapon replacement
  if trait==26 then trait=9 end -- Nirnhoned Armor replacement
  if wt==WEAPONTYPE_AXE then craft=1;line=1;
  elseif wt==WEAPONTYPE_HAMMER then craft=1;line=2;
  elseif wt==WEAPONTYPE_SWORD then craft=1;line=3
  elseif wt==WEAPONTYPE_TWO_HANDED_AXE then craft=1;line=4;
  elseif wt==WEAPONTYPE_TWO_HANDED_HAMMER then craft=1;line=5;
  elseif wt==WEAPONTYPE_TWO_HANDED_SWORD then craft=1;line=6;
  elseif wt==WEAPONTYPE_DAGGER then craft=1;line=7;
  elseif wt==WEAPONTYPE_BOW then craft=6;line=1;
  elseif wt==WEAPONTYPE_FIRE_STAFF then craft=6;line=2;
  elseif wt==WEAPONTYPE_FROST_STAFF then craft=6;line=3;
  elseif wt==WEAPONTYPE_LIGHTNING_STAFF then craft=6;line=4;
  elseif wt==WEAPONTYPE_HEALING_STAFF then craft=6;line=5;
  elseif wt==WEAPONTYPE_SHIELD then craft=6;line=6;trait=trait-10;
  elseif eq==EQUIP_TYPE_CHEST then line=1
  elseif eq==EQUIP_TYPE_FEET then line=2
  elseif eq==EQUIP_TYPE_HAND then line=3
  elseif eq==EQUIP_TYPE_HEAD then line=4
  elseif eq==EQUIP_TYPE_LEGS then line=5
  elseif eq==EQUIP_TYPE_SHOULDERS then line=6
  elseif eq==EQUIP_TYPE_WAIST then line=7
  end
  if at==ARMORTYPE_HEAVY then craft=1;line=line+7;trait=trait-10;end
  if at==ARMORTYPE_MEDIUM then craft=2;line=line+7;trait=trait-10; end
  if at==ARMORTYPE_LIGHT then craft=2;trait=trait-10; end
  if craft and line and trait then return craft,line,trait
  else return false end
end
function CS.IsValidEquip(equip)
  if equip==EQUIP_TYPE_CHEST
  or equip==EQUIP_TYPE_FEET
  or equip==EQUIP_TYPE_HAND
  or equip==EQUIP_TYPE_HEAD
  or equip==EQUIP_TYPE_LEGS
  or equip==EQUIP_TYPE_MAIN_HAND
  or equip==EQUIP_TYPE_OFF_HAND
  or equip==EQUIP_TYPE_ONE_HAND
  or equip==EQUIP_TYPE_TWO_HAND
  or equip==EQUIP_TYPE_SHOULDERS
  or equip==EQUIP_TYPE_WAIST
  then return true else return false end
end
function CS.IsValidTrait(trait)
  if trait~=ITEM_TRAIT_TYPE_NONE
  and trait~=ITEM_TRAIT_TYPE_ARMOR_INTRICATE
  and trait~=ITEM_TRAIT_TYPE_ARMOR_ORNATE
  and trait~=ITEM_TRAIT_TYPE_WEAPON_INTRICATE
  and trait~=ITEM_TRAIT_TYPE_WEAPON_ORNATE
  then return true else return false end
end
function CS.IsItemNeeded(craft,line,trait,id,link)
  if not craft or not line or not trait then return end
  local isSet = GetItemLinkSetInfo(link)
  local mark, need, storedId = true, '', CS.Account.crafting.stored[craft][line][trait].id or 0
  if not CS.Account.option[14] and isSet then mark = false end
  SELF = false
  if mark and (storedId == id or (not id and storedId == 0)) then
    for _, char in pairs(CS.GetCharacters()) do
      if CS.Account.crafting.studies[char][craft][line] and not CS.Account.crafting.research[char][craft][line][trait] then
        if char == CS.CurrentPlayer then SELF = true end
        need = need..'\n|t20:20:esoui/art/buttons/decline_up.dds|t |cFF1010'..char..'|r'
      end
    end
  end
  return need
end
function CS.IsStyleNeeded(link)
  SELF = false
  local need, id = '', CS.SplitLink(link,3)
  if id then
    for _, char in pairs(CS.GetCharacters()) do
      if CS.Account.style.tracking[char] and not CS.Account.style.knowledge[char][id] then
        if char == CS.CurrentPlayer then SELF = true end
        need = need..'\n|t20:20:esoui/art/buttons/decline_up.dds|t |cFF1010'..char..'|r'
      end
    end
  end
  return need
end
function CS.IsRecipeNeeded(link)
  SELF = false
  local id, need = CS.SplitLink(link,3), ''
  if id then
    for char,data in pairs(CS.Account.cook.knowledge) do
      if not data[id] and CS.Account.cook.tracking[char] then
        if char == CS.CurrentPlayer then SELF = true end
        need = need..'\n|t20:20:esoui/art/buttons/decline_up.dds|t |cFF1010'..char..'|r'
      end
    end
  end
  return need
end
function CS.IsRecipeFurnisherNeeded(link)
  SELF = false
  local id, need = CS.SplitLink(link,3), ''
  if id then
    for char,data in pairs(CS.Account.furnisher.knowledge) do
      --if not data[id] and CS.Account.furnisher.tracking[char] then
      if not data[id] and CS.Account.cook.tracking[char] then -- FIXME: Create option to track only furnisher items
        if char == CS.CurrentPlayer then SELF = true end
        need = need..'\n|t20:20:esoui/art/buttons/decline_up.dds|t |cFF1010'..char..'|r'
      end
    end
  end
  return need
end
function CS.IsBait(link)
  if not link then return '' end
  local id = CS.SplitLink(link,3)
  local bait = { [42877] = 1,[42871] = 2,[42873] = 2,[42872] = 3,[42874] = 3,[42870] = 4,[42876] = 4,[42875] = 5,[42869] = 5 }
  if id then return '\n'..CS.Loc.TT[21][bait[id]] end
  return ''
end
function CS.IsPotency(link)
  if not link then return '' end
  if CS.Account.option[8] then
    local id = CS.SplitLink(link,3)
    for _,add in pairs(CS.Rune.rune[ITEMTYPE_ENCHANTING_RUNE_POTENCY]) do
      for level,rune in pairs(add) do
        if rune == id then return CS.Loc.level..' '..CS.Rune.level[level] end
      end
    end
    return ''
  end
end
function CS.IsItemStoredForCraftStore(id)
  for x,craft in pairs(CS.Account.crafting.stored)do
    for y,line in pairs(craft)do
      for z,trait in pairs(line)do
        if trait.id == id then
          for char,data in pairs(CS.Account.crafting.research)do
            if CS.Account.crafting.studies[char][x][y] and not data[x][y][z] then return true end
          end
        end
      end
    end
  end
  return false
end

function CS.OptionSetSelect(control,button)
  if button == 2 then
    CS.ToChat(control.data.link)
  else
    for x = 1,3 do
      local zone = {GetMapInfo(control.data.zone[x])}
      local node = {GetFastTravelNodeInfo(control.data.node[x])}
      local nr, travel, zonename, nodename = control.data.nr, true, ZOSF('<<C:1>>',zone[1]), CS.Loc.unknown
      if CS.Sets[nr].nodes[x] == -1 then nodename = CS.Loc.TT[17]
      elseif CS.Sets[nr].nodes[x] == -2 then nodename = CS.Loc.TT[18] end
      local cost = ' (|cFFFF00'..GetRecallCost()..'|r|t1:0:x.dds|t |t14:14:esoui/art/currency/currency_gold.dds|t)'
      if node[1] then nodename = ZOSF('<<C:1>>',node[2]) else travel = false; cost = '' end 
      WM:GetControlByName('CraftStoreFixed_PanelButtonWayshrine'..x).data = { set = nr, travel = travel, info = nodename..'\n'..zonename..cost }
    end
    CraftStoreFixed_PanelButtonCraftedSets.data = { link = control.data.link }
    CraftStoreFixed_PanelButtonCraftedSets:SetText(control.data.name)
    CraftStoreFixed_SetPanel:SetHidden(true)
  end
end
function CS.OptionSelect(control,condition,text)
  if not control then return end
  if condition then condition = false else condition = true end
  local tex = 'esoui/art/buttons/checkbox_unchecked.dds'
  if condition then tex = 'esoui/art/buttons/checkbox_checked.dds' end
  control:SetText('|t16:16:'..tex..'|t '..text)
  return condition
end
function CS.OptionSet()
  CraftStoreFixed_ButtonFrame:SetHidden(not CS.Account.option[1])
  CraftStoreFixed_ButtonFrameButtonBG:SetMovable(not CS.Account.option[2])
  CraftStoreFixed_ButtonFrameButtonBG:SetMouseEnabled(not CS.Account.option[2])
  CraftStoreFixed_Quest:SetMovable(not CS.Account.option[2])
  CraftStoreFixed_Quest:SetMouseEnabled(not CS.Account.option[2])
end
function CS.PanelInitialize()
  local crafts = {CRAFTING_TYPE_BLACKSMITHING,CRAFTING_TYPE_CLOTHIER,CRAFTING_TYPE_WOODWORKING}
  CS.Account.crafting.research[CS.CurrentPlayer] = {}
  if not CS.Account.crafting.studies[CS.CurrentPlayer] then CS.Account.crafting.studies[CS.CurrentPlayer] = {} end
  for _,craft in pairs(crafts) do
    CS.Account.crafting.research[CS.CurrentPlayer][craft] = {}
    if not CS.Account.crafting.studies[CS.CurrentPlayer][craft] then CS.Account.crafting.studies[CS.CurrentPlayer][craft] = {} end
    if not CS.Account.crafting.stored[craft] then CS.Account.crafting.stored[craft] = {} end
    for line = 1, GetNumSmithingResearchLines(craft) do
      CS.DrawTraitColumn(craft,line)
      CS.Account.crafting.research[CS.CurrentPlayer][craft][line] = {}
      if not CS.Account.crafting.studies[CS.CurrentPlayer][craft][line] then CS.Account.crafting.studies[CS.CurrentPlayer][craft][line] = false end
      if not CS.Account.crafting.stored[craft][line] then CS.Account.crafting.stored[craft][line] = {} end
      for trait = 1, CS.MaxTraits do
        if not CS.Account.crafting.stored[craft][line][trait] then CS.Account.crafting.stored[craft][line][trait] = {} end
      end
    end
  end
  for nr, text in pairs(CS.Loc.option) do
    local btn = CreateControl('CraftStoreFixed_OptionPanelOption'..nr,CraftStoreFixed_OptionPanel,CT_BUTTON)
    local tex = '|t16:16:esoui/art/buttons/checkbox_unchecked.dds|t'
    if CS.Account.option[nr] then tex = '|t16:16:esoui/art/buttons/checkbox_checked.dds|t' end
    btn:SetAnchor(TOPLEFT,CraftStoreFixed_OptionPanel,TOPLEFT,12,10 + (nr - 1) * 26)
    btn:SetDimensions(375,26)
    btn:SetFont('CraftStoreFixedFont')
    btn:SetNormalFontColor(0.9,0.87,0.68,1)
    btn:SetMouseOverFontColor(1,0.66,0.2,1)
    btn:SetHorizontalAlignment(0)
    btn:SetVerticalAlignment(1)
    btn:SetClickSound('Click')
    btn:SetText(tex..' '..text)
    btn:SetHandler('OnClicked',function(self)
      CS.Account.option[nr] = CS.OptionSelect(self,CS.Account.option[nr],CS.Loc.option[nr])
      CS.OptionSet()
      if nr == 14 then
        for craft, storeCraft in pairs(CS.Account.crafting.stored) do
          for line, storeLine in pairs(storeCraft) do
            for trait,_ in pairs(storeLine) do CS.UpdatePanelIcon(craft,line,trait) end
          end
        end
      end
    end)
  end
  for x,set in pairs(CS.Sets) do
    local btn = WM:CreateControl('CraftStoreFixed_SetPanelScrollChildButton'..x,CraftStoreFixed_SetPanelScrollChild,CT_BUTTON)
    btn:SetAnchor(3,nil,3,8,5 + (x-1) * 22)
    btn:SetDimensions(280,22)
    btn:SetFont('CraftStoreFixedFont')
    btn:SetClickSound('Click')
    btn:EnableMouseButton(2,true)
    btn:SetNormalFontColor(0.9,0.87,0.68,1)
    btn:SetMouseOverFontColor(1,0.66,0.2,1)
    btn:SetHorizontalAlignment(0)
    btn:SetVerticalAlignment(1)
    btn:SetHandler('OnMouseEnter',function(self) CS.Tooltip(self,true,false,CraftStoreFixed_SetPanel,'tl') end)
    btn:SetHandler('OnMouseExit',function(self) CS.Tooltip(self,false) end)
    btn:SetHandler('OnMouseDown',function(self,button) CS.OptionSetSelect(self,button) end)
    local link = '|H1:item:'..set.item..':370:50:0:370:50:0:0:0:0:0:0:0:0:0:28:0:0:0:10000:0|h|h'
    local _,setName = GetItemLinkSetInfo(link,false)
    setName = ZOSF('[<<1>>] <<C:2>>',set.traits,setName)
    btn:SetText(setName)
    btn.data = { link = link, nr = x, zone = set.zone, node = set.nodes, name = setName, buttons = {CS.Loc.TT[5],CS.Loc.TT[6]} }
  end

  local pre, icons = 0, {8,5,9,12,7,3,2,1,14,10,6,13,4,11}
  for id = 1,GetNumSmithingStyleItems() do
    local _, _, _, _, style = GetSmithingStyleItemInfo(id)
    if CS.Style.CheckStyle(id) then
      local c = WM:GetControlByName('CraftStoreFixed_StyleRow'..pre)
      local p = WM:CreateControl('CraftStoreFixed_StyleRow'..id,CraftStoreFixed_StylePanelScrollChildStyles,CT_CONTROL)
      if c then p:SetAnchor(3,c,6,0,0) else p:SetAnchor(3,nil,3,0,3) end
      p:SetDimensions(750,90)
      local bg = WM:CreateControl('CraftStoreFixed_StylePanelScrollChildBgLine'..id,p,CT_BACKDROP)
      bg:SetAnchor(3,p,3,0,0)
      bg:SetDimensions(750,37)
      bg:SetCenterColor(0,0,0,0.2)
      bg:SetEdgeColor(1,1,1,0)

      local icon, link, name, aName, aLink, popup = CS.Style.GetHeadline(id)
      local btn = WM:CreateControl('CraftStoreFixed_StylePanelScrollChildMaterial'..id,p,CT_BUTTON)
      btn:SetAnchor(2,bg,2,10,0)
      btn:SetDimensions(30,30)
      btn:SetNormalTexture(icon)
      btn:EnableMouseButton(2,true)
      btn:SetHandler('OnMouseEnter',function(self) CS.Tooltip(self,true,false,CraftStoreFixed_Style,'tl') end)
      btn:SetHandler('OnMouseExit',function(self) CS.Tooltip(self,false) end)
      btn:SetHandler('OnMouseDown',function(self,button) if button == 2 then CS.ToChat(self.data.link) end end)
      btn.data = { link = link, buttons = {CS.Loc.TT[6]} }
      
      local lbl = WM:CreateControl('CraftStoreFixed_StylePanelScrollChildName'..id,p,CT_LABEL)
      lbl:SetAnchor(2,bg,2,50,0)
      lbl:SetDimensions(nil,32)
      lbl:SetFont('CraftStoreFixedFont')
      lbl:SetText(name)
      lbl:SetColor(1,0.66,0.2,1)
      lbl:SetHorizontalAlignment(0)
      lbl:SetVerticalAlignment(1)

      local av = WM:CreateControl('CraftStoreFixed_StylePanelScrollChildAchievment'..id,p,CT_BUTTON)
      av:SetAnchor(2,lbl,8,15,0)
      av:SetDimensions(300,32)
      av:SetFont('CraftStoreFixedFont')
      av:SetNormalFontColor(1,0.66,0.2,0.5)
      av:SetMouseOverFontColor(1,0.66,0.2,1)
      av:SetHorizontalAlignment(0)
      av:SetVerticalAlignment(1)
      if aName ~= 'crown' then
        av:EnableMouseButton(2,true)
        av:SetText('['..aName..']')
        av:SetHandler('OnMouseDown',function(self,button)
          if button == 2 then  CS.ToChat(aLink) else
            ACHIEVEMENTS:ShowAchievementPopup(unpack(popup))
            ZO_PopupTooltip_Hide()
          end
        end)
      else
        av:SetText('|t32:32:esoui/art/currency/currency_crowns_32.dds|t')
      end
      for z,y in pairs(icons) do
        icon, link = CS.Style.GetIconAndLink(id,y)
        local btn = WM:CreateControl('CraftStoreFixed_StylePanelScrollChild'..id..'Button'..y,p,CT_BUTTON)
        btn:SetAnchor(3,bg,6,4+(z-1)*52,2)
        btn:SetDimensions(52,50)
        btn:EnableMouseButton(2,true)
        btn:SetClickSound('Click')
        btn:SetHandler('OnMouseEnter',function(self) CS.Tooltip(self,true,true,CraftStoreFixed_Style,'tl') end)
        btn:SetHandler('OnMouseExit',function(self) CS.Tooltip(self,false,true) end)
        btn:SetHandler('OnMouseDown',function(self,button) if button == 2 then CS.ToChat(self.data.link) end end)
        btn.data = { link = link, buttons = {CS.Loc.TT[6]} }
        local tex = WM:CreateControl('$(parent)Texture',btn,CT_TEXTURE)
        tex:SetAnchor(128,btn,128,0,0)
        tex:SetDimensions(45,45)
        tex:SetColor(1,0,0,0.5)
        tex:SetTexture(icon)
      end
      pre = id
    end
  end
  for x = 1,50 do
    local btn = WM:CreateControl('CraftStoreFixed_RecipePanelScrollChildButton'..x,CraftStoreFixed_RecipePanelScrollChild,CT_BUTTON)
    btn:SetAnchor(3,nil,3,8,5 + (x-1) * 22)
    btn:SetDimensions(508,22)
    btn:SetFont('CraftStoreFixedFont')
    btn:SetHidden(true)
    btn:EnableMouseButton(2,true)
    btn:SetClickSound('Click')
    btn:SetMouseOverFontColor(1,0.66,0.2,1)
    btn:SetHorizontalAlignment(0)
    btn:SetVerticalAlignment(1)
    btn:SetHandler('OnMouseEnter',function(self) CS.Tooltip(self,true,false,CraftStoreFixed_Recipe,'tl') end)
    btn:SetHandler('OnMouseExit',function(self) CS.Tooltip(self,false) end)
    btn:SetHandler('OnMouseDown',function(self,button) CS.RecipeMark(self,button) end)
    btn = WM:CreateControl('CraftStoreFixed_CookFoodSectionScrollChildButton'..x,CraftStoreFixed_CookFoodSectionScrollChild,CT_BUTTON)
    btn:SetAnchor(3,nil,3,8,5 + (x-1) * 24)
    btn:SetDimensions(508,24)
    btn:SetFont('ZoFontGame')
    btn:EnableMouseButton(2,true)
    btn:EnableMouseButton(3,true)
    btn:SetClickSound('Click')
    btn:SetMouseOverFontColor(1,0.66,0.2,1)
    btn:SetHorizontalAlignment(0)
    btn:SetVerticalAlignment(1)
    btn:SetHandler('OnMouseEnter',function(self) CS.Tooltip(self,true,false,CraftStoreFixed_Cook,'tl') end)
    btn:SetHandler('OnMouseExit',function(self) CS.Tooltip(self,false) end)
    btn:SetHandler('OnMouseDown',function(self,button) CS.CookStart(self,button) end)
  end
  for x = 1,blueprints_count do
    local btn = WM:CreateControl('CraftStoreFixed_BlueprintPanelScrollChildButton'..x,CraftStoreFixed_BlueprintPanelScrollChild,CT_BUTTON)
    btn:SetAnchor(3,nil,3,8,5 + (x-1) * 22)
    btn:SetDimensions(508,22)
    btn:SetFont('CraftStoreFixedFont')
    btn:SetHidden(true)
    btn:EnableMouseButton(2,true)
    btn:SetClickSound('Click')
    btn:SetMouseOverFontColor(1,0.66,0.2,1)
    btn:SetHorizontalAlignment(0)
    btn:SetVerticalAlignment(1)
    btn:SetHandler('OnMouseEnter',function(self) CS.Tooltip(self,true,false,CraftStoreFixed_Blueprint,'tl') end)
    btn:SetHandler('OnMouseExit',function(self) CS.Tooltip(self,false) end)
    btn:SetHandler('OnMouseDown',function(self,button) CS.BlueprintMark(self,button) end)
  end
  for x = 1,25 do
    local btn = WM:CreateControl('CraftStoreFixed_RuneGlyphSectionScrollChildButton'..x,CraftStoreFixed_RuneGlyphSectionScrollChild,CT_BUTTON)
    btn:SetAnchor(3,nil,3,8,5 + (x-1) * 30)
    btn:SetDimensions(508,30)
    btn:SetFont('ZoFontGame')
    btn:EnableMouseButton(2,true)
    btn:EnableMouseButton(3,true)
    btn:SetClickSound('Click')
    btn:SetMouseOverFontColor(1,0.66,0.2,1)
    btn:SetHorizontalAlignment(0)
    btn:SetVerticalAlignment(1)
    btn:SetHandler('OnMouseEnter',function(self) CS.Tooltip(self,true,false,CraftStoreFixed_Rune,'tl') end)
    btn:SetHandler('OnMouseExit',function(self) CS.Tooltip(self,false) end)
    btn:SetHandler('OnMouseDown',function(self,button) CS.RuneCreate(self,button) end)
  end
  local function Split(level)
    local basename = ZOSF('<<t:1>>', GetItemLinkName(CS.RuneGetLink(26580,0,0)))
    local basedata = { zo_strsplit(' ', basename) }
    local name = ZOSF('<<t:1>>', GetItemLinkName(CS.RuneGetLink(26580,3,level)))
    local namedata = { zo_strsplit(' ', name) }
    for j = #namedata, 1, -1 do
      for i = #basedata, 1, -1 do
      if namedata[j] == basedata[i] then
        table.remove(namedata, j)
        table.remove(basedata, i)
      end end
    end
    return ZOSF('<<C:1>>', table.concat(namedata,' '))
  end
  for x,level in pairs(CS.Rune.level) do
    local name = Split(x)
    local btn = WM:CreateControl('CraftStoreFixed_RuneMenuButton'..x,CraftStoreFixed_RuneMenu,CT_BUTTON)
    btn:SetAnchor(3,nil,3,8,5 + (x-1) * 24)
    btn:SetDimensions(240,24)
    btn:SetFont('ZoFontGame')
    btn:SetClickSound('Click')
    btn:SetNormalFontColor(0.9,0.87,0.68,1)
    btn:SetMouseOverFontColor(1,0.66,0.2,1)
    btn:SetHorizontalAlignment(0)
    btn:SetVerticalAlignment(1)
    btn:SetText(name..' |c888888('..level..')|r')
    btn.data = {level = x}
    btn:SetHandler('OnClicked',function(self)
      CS.RuneSetValue(3,self.data.level);
      CraftStoreFixed_RuneLevelButton:SetText(CS.Loc.level..': '..CS.Rune.level[self.data.level])
      CraftStoreFixed_RuneMenu:SetHidden(true)
      CS.RuneShowMode()
    end)
  end
  CraftStoreFixed_OptionPanel:SetDimensions(CS.Loc.optionwidth,#CS.Loc.option * 26 + 20)
  CraftStoreFixed_SetPanelScrollChild:SetHeight(#CS.Sets * 22 + 10)
  CraftStoreFixed_CharacterPanelBoxScrollChild:SetHeight(#CS.GetCharacters() * 204 - 10)
  CraftStoreFixed_Panel:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,CS.Account.position[1],CS.Account.position[2])
  CraftStoreFixed_Quest:SetAnchor(TOPLEFT,CraftStoreFixed_QuestFrame,TOPLEFT,CS.Account.questbox[1],CS.Account.questbox[2])
  CraftStoreFixed_ButtonFrameButtonBG:SetAnchor(TOPLEFT,CraftStoreFixed_ButtonFrame,TOPLEFT,CS.Account.button[1],CS.Account.button[2])
  CraftStoreFixed_PanelButtonCraftedSets:SetText(CS.Loc.set)
  CraftStoreFixed_CharacterPanelHeader:SetText(CS.Loc.chars)
  if CS.Account.mainchar then CraftStoreFixed_PanelButtonCharacters:SetText(CS.Account.mainchar) else CraftStoreFixed_PanelButtonCharacters:SetText(CS.CurrentPlayer) end
  CraftStoreFixed_RuneInfo:SetText(GetString(SI_CRAFTING_PERFORM_FREE_CRAFT))
  CraftStoreFixed_RuneLevelButton:SetText(CS.Loc.level..': '..CS.Rune.level[CS.Character.potency])
  CS.OptionSet()
  -- Tooltips
  local control
  for x = 1,16 do
    control = WM:GetControlByName('CraftStoreFixed_CookCategoryButton'..x)
    control.data = {info = ZOSF('|cFFFFFF<<C:1>>|r\n<<2>>',GetRecipeListInfo(x),CS.Cook.category[x])}
    if x < 16 then control = WM:GetControlByName('CraftStoreFixed_RecipeCategoryButton'..x)
    control.data = {info = ZOSF('|cFFFFFF<<C:1>>|r\n<<2>>',GetRecipeListInfo(x),CS.Cook.category[x])} end
  end
  CraftStoreFixed_PanelQuestButton.data = nil
  for line = 1, 2 do
    for trait = 1, CS.MaxTraits do
      local tid = GetSmithingResearchLineTraitInfo(1,math.abs(line - 9),trait)
      local _,desc = GetSmithingResearchLineTraitInfo(1,math.abs(line - 9),trait)
      local _,name,icon = GetSmithingTraitItemInfo(tid + 1)
      control = WM:GetControlByName('CraftStoreFixed_PanelTraitrow'..(trait + (line - 1) * 9))
      control:SetText(GetString('SI_ITEMTRAITTYPE',tid)..' |t25:25:'..icon..'|t|t5:25:x.dds|t')
      control.data = {info = ZOSF('|cFFFFFF<<C:1>>',name)..'|r\n'..desc}
    end
  end
  CraftStoreFixed_PanelFenceGoldText.data = { info = CS.Loc.TT[16] }
  CraftStoreFixed_ButtonFrameButton.data = { info = 'CraftStore' }
  CraftStoreFixed_RuneArmorButton.data =  { info = GetString('SI_ITEMTYPE',ITEMTYPE_GLYPH_ARMOR) }
  CraftStoreFixed_RuneWeaponButton.data =  { info = GetString('SI_ITEMTYPE',ITEMTYPE_GLYPH_WEAPON) }
  CraftStoreFixed_RuneJewelryButton.data =  { info = GetString('SI_ITEMTYPE',ITEMTYPE_GLYPH_JEWELRY) }
  CraftStoreFixed_RuneCreateButton.data =  { info = GetString(SI_CRAFTING_PERFORM_FREE_CRAFT) }
  CraftStoreFixed_RuneRefineButton.data =  { info = GetString(SI_CRAFTING_PERFORM_EXTRACTION) }
  CraftStoreFixed_RuneFavoriteButton.data =  { info = CS.Loc.TT[11] }
  CraftStoreFixed_RuneWritButton.data =  { info = CS.Loc.TT[23] }
  CraftStoreFixed_RuneRefineAllButton.data =  { info = CS.Loc.TT[22], addline = {CS.Loc.TT[9]} }
  CraftStoreFixed_RuneHandmadeButton.data =  { info = CS.Loc.TT[12] }
  CraftStoreFixed_CookCategoryButton17.data = { info = CS.Loc.TT[11] }
  CraftStoreFixed_CookCategoryButtonWrit.data = { info = CS.Loc.TT[23] }
  for x = 1,5 do WM:GetControlByName('CraftStoreFixed_RuneAspect'..x..'Button').data = { link = CS.RuneGetLink(CS.Rune.rune[ITEMTYPE_ENCHANTING_RUNE_ASPECT][x],x,1) } end
end
function CS.CharacterInitialize()
  local tex = {[false] = '|t16:16:esoui/art/buttons/checkbox_unchecked.dds|t', [true] = '|t16:16:esoui/art/buttons/checkbox_checked.dds|t'}
  for x,char in pairs(CS.GetCharacters()) do
    local frame = WM:CreateControl('CraftStoreFixed_CharacterFrame'..x,CraftStoreFixed_CharacterPanelBoxScrollChild,CT_CONTROL)
    frame:SetAnchor(TOPLEFT,CraftStoreFixed_CharacterPanelBoxScrollChild,TOPLEFT,0,(x - 1) * 204)
    
    local bg = WM:CreateControl('CraftStoreFixed_Character'..x..'NameBG',frame,CT_BACKDROP)
    bg:SetAnchor(TOPLEFT,frame,TOPLEFT,0,0)
    bg:SetDimensions(506,65)
    bg:SetCenterColor(0.06,0.06,0.06,1)
    bg:SetEdgeColor(0.12,0.12,0.12,1)
    bg:SetEdgeTexture('',1,1,1)

    local btn = WM:CreateControl('CraftStoreFixed_Character'..x..'Name',frame,CT_BUTTON)
    btn:SetAnchor(TOPLEFT,frame,TOPLEFT,10,1)
    btn:SetDimensions(450,30)
    btn:SetHorizontalAlignment(0)
    btn:SetVerticalAlignment(1)
    btn:SetClickSound('Click')
    btn:EnableMouseButton(2,true)
    btn:EnableMouseButton(3,true)
    btn:SetFont('ZoFontWinH3')
    btn:SetNormalFontColor(1,1,1,1)
    btn:SetMouseOverFontColor(1,0.66,0.3,1)
    btn:SetHandler('OnMouseEnter', function(self) CS.Tooltip(self,true,false,self,'bl') end)
    btn:SetHandler('OnMouseExit', function(self) CS.Tooltip(self,false) end)
    btn:SetHandler('OnMouseDown', function(self,button) CS.LoadCharacter(self,button) end)
    
    btn = WM:CreateControl('CraftStoreFixed_Character'..x..'Info',frame,CT_BUTTON)
    btn:SetAnchor(TOPLEFT,frame,TOPLEFT,8,30)
    btn:SetDimensions(400,35)
    btn:SetHorizontalAlignment(0)
    btn:SetVerticalAlignment(1)
    btn:SetFont('ZoFontGame')
    btn:SetNormalFontColor(0.9,0.87,0.68,1)
    btn:SetHandler('OnMouseEnter', function(self) CS.Tooltip(self,true,false,self,'bl') end)
    btn:SetHandler('OnMouseExit', function(self) CS.Tooltip(self,false) end)
    
    btn = WM:CreateControl('CraftStoreFixed_Character'..x..'Style',frame,CT_BUTTON)
    btn:SetAnchor(TOPLEFT,frame,TOPLEFT,415,7)
    btn:SetDimensions(80,25)
    btn:SetHorizontalAlignment(2)
    btn:SetVerticalAlignment(1)
    btn:SetFont('ZoFontGame')
    btn:SetClickSound('Click')
    btn:SetText(tex[CS.Account.style.tracking[char]]..' |t22:22:esoui/art/icons/quest_book_001.dds|t')
    btn:SetNormalFontColor(0.9,0.87,0.68,1)
    btn:SetHandler('OnMouseEnter', function(self) CS.Tooltip(self,true,false,self,'bc') end)
    btn:SetHandler('OnMouseExit', function(self) CS.Tooltip(self,false) end)
    btn:SetHandler('OnClicked', function(self) CS.Account.style.tracking[char] = CS.OptionSelect(self,CS.Account.style.tracking[char],'|t22:22:esoui/art/icons/quest_book_001.dds|t') end)
    btn.data = { info = CS.Loc.TT[13] }

    btn = WM:CreateControl('CraftStoreFixed_Character'..x..'Recipe',frame,CT_BUTTON)
    btn:SetAnchor(TOPLEFT,frame,TOPLEFT,415,36)
    btn:SetDimensions(80,25)
    btn:SetHorizontalAlignment(2)
    btn:SetVerticalAlignment(1)
    btn:SetFont('ZoFontGame')
    btn:SetClickSound('Click')
    btn:SetText(tex[CS.Account.cook.tracking[char]]..' |t22:22:esoui/art/icons/quest_scroll_001.dds|t')
    btn:SetNormalFontColor(0.9,0.87,0.68,1)
    btn:SetHandler('OnMouseEnter', function(self) CS.Tooltip(self,true,false,self,'bc') end)
    btn:SetHandler('OnMouseExit', function(self) CS.Tooltip(self,false) end)
    btn:SetHandler('OnClicked', function(self) CS.Account.cook.tracking[char] = CS.OptionSelect(self,CS.Account.cook.tracking[char],'|t22:22:esoui/art/icons/quest_scroll_001.dds|t') end)
    btn.data = { info = CS.Loc.TT[14] }
    
    local skills, xpos, ypos, res = {5,4,3,2,1,6}, 0, 66, {2,1,6}
    for y,z in pairs(skills) do 
      bg = WM:CreateControl('CraftStoreFixed_Character'..x..'Skill'..z..'BG',frame,CT_BACKDROP)
      bg:SetAnchor(TOPLEFT,frame,TOPLEFT,xpos,ypos)
      bg:SetDimensions(168,28)
      bg:SetCenterColor(0.06,0.06,0.06,1)
      bg:SetEdgeColor(0.12,0.12,0.12,1)
      bg:SetEdgeTexture('',1,1,1)

      btn = WM:CreateControl('CraftStoreFixed_Character'..x..'Skill'..z,frame,CT_BUTTON)
      btn:SetAnchor(TOPLEFT,frame,TOPLEFT,xpos + 5,ypos)
      btn:SetDimensions(165,28)
      btn:SetFont('CraftStoreFixedFont')
      btn:SetNormalFontColor(0.9,0.87,0.68,1)
      btn:SetHorizontalAlignment(0)
      btn:SetVerticalAlignment(1)
      btn:SetHandler('OnMouseEnter', function(self) CS.Tooltip(self,true,false,self,'bl') end)
      btn:SetHandler('OnMouseExit', function(self) CS.Tooltip(self,false) end)
      xpos = xpos + 169
      if y == 3 then xpos = 0; ypos = 95; end
    end xpos = 0
    for _,z in pairs(res) do
      bg = WM:CreateControl('CraftStoreFixed_Character'..x..'Research'..z..'BG',frame,CT_BACKDROP)
      bg:SetAnchor(TOPLEFT,frame,TOPLEFT,xpos,124)
      bg:SetDimensions(168,70)
      bg:SetCenterColor(0.06,0.06,0.06,1)
      bg:SetEdgeColor(0.12,0.12,0.12,1)
      bg:SetEdgeTexture('',1,1,1)
      xpos = xpos + 169
      for i = 1,3 do
        btn = WM:CreateControl('CraftStoreFixed_Character'..x..'Research'..z..'Slot'..i,bg,CT_BUTTON)
        btn:SetAnchor(TOPLEFT,bg,TOPLEFT,5,1 + (i - 1) * 22)
        btn:SetDimensions(165,22)
        btn:SetFont('CraftStoreFixedFont')
        btn:SetNormalFontColor(0.9,0.87,0.68,1)
        btn:SetHorizontalAlignment(0)
        btn:SetVerticalAlignment(1)
        btn:SetHandler('OnMouseEnter', function(self) CS.Tooltip(self,true,false,self,'bl') end)
        btn:SetHandler('OnMouseExit', function(self) CS.Tooltip(self,false) end)
        local lbl = WM:CreateControl('CraftStoreFixed_Character'..x..'Research'..z..'Slot'..i..'Time',bg,CT_LABEL)
        lbl:SetAnchor(TOPRIGHT,bg,TOPRIGHT,-5,1 + (i - 1) * 22)
        lbl:SetDimensions(90,22)
        lbl:SetFont('CraftStoreFixedFont')
        lbl:SetColor(0.9,0.87,0.68,1)
        lbl:SetHorizontalAlignment(2)
        lbl:SetVerticalAlignment(1)
      end
    end
  end
end
function CS.Tooltip(c,visible,scale,parent,pos)
  if not c then return end
  local function IconScale(c,from,to)
    local a,t = CreateSimpleAnimation(ANIMATION_SCALE,c)
    a:SetDuration(150)
    a:SetStartScale(from)
    a:SetEndScale(to)
    t:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
    t:PlayFromStart()
  end
  local function TooltipCraft(c,field,maxval)
    if CS.Extern then return {CS.Loc.TT[6],CS.Loc.TT[4]} end
    if c.data.craftable and maxval > 0 then
      if maxval > MAXCRAFT then maxval = MAXCRAFT end
      local amount = tonumber(field:GetText()) or 1
      return {ZOSF(CS.Loc.TT[2],amount),ZOSF(CS.Loc.TT[3],maxval),CS.Loc.TT[4]}
    end
    return {CS.Loc.TT[4]}
  end  
  if scale then
    if visible then IconScale(c:GetNamedChild('Texture'),1,1.4)
    else IconScale(c:GetNamedChild('Texture'),1.4,1) end
  end
  if c.data == nil then return
  elseif visible then
    if not parent then parent = c end
    if not pos then pos = 0 end
    local anchor, first = {tl={9,2,1,3},tc={4,0,-2,1},tr={3,2,3,9},cl={8,-2,0,2},[0]={2,1,0,8},cr={2,2,0,8},bl={3,2,2,6},bc={1,0,2,4},br={6,2,-3,12}}, '\n'
    if c.data.link then
      c.text = ItemTooltip
      InitializeTooltip(c.text,parent,anchor[pos][1],anchor[pos][2],anchor[pos][3],anchor[pos][4])
      c.text:SetLink(c.data.link)
      ZO_ItemTooltip_ClearCondition(c.text)
      ZO_ItemTooltip_ClearCharges(c.text)
    elseif c.data.info then
      c.text = InformationTooltip
      InitializeTooltip(c.text,parent,anchor[pos][1],anchor[pos][2],anchor[pos][3],anchor[pos][4])
      SetTooltipText(c.text,c.data.info)
    end
    if c.data.addline then for _,text in pairs(c.data.addline) do c.text:AddLine(first..text,'CraftStoreFixedFont'); first = '' end end
    if c.data.buttons then c.text:AddLine(first..table.concat(c.data.buttons,'\n'),'CraftStoreFixedFont'); first = '' end
    if c.data.crafting then c.text:AddLine(first..table.concat(TooltipCraft(c,c.data.crafting[1],c.data.crafting[2]),'\n'),'CraftStoreFixedFont'); first = '' end
    c.text:SetHidden(false)
  else
    if c.text == nil then return end
    ClearTooltip(c.text)
    c.text:SetHidden(true)
    c.text = nil
  end
end
function CS.TooltipShow(control,link,id)
  local stripedLink = CS.StripLink(link)
  local it, specializedItemType = GetItemLinkItemType(link)
  local store, need = {}
  if it == ITEMTYPE_RACIAL_STYLE_MOTIF then need = CS.IsStyleNeeded(link)
  elseif it == ITEMTYPE_RECIPE then

    if specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING or
    specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING or
    specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING or
    specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING or
    specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING or
    specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING then
      need = CS.IsRecipeFurnisherNeeded(link)
    else
      need = CS.IsRecipeNeeded(link)
    end
    
  elseif it == ITEMTYPE_LURE then need = CS.IsBait(link)
  elseif it == ITEMTYPE_ENCHANTING_RUNE_POTENCY then need = CS.IsPotency(link)
  elseif CS.IsValidEquip(GetItemLinkEquipType(link)) then
    local craft,line,trait = CS.GetTrait(link)
    if CS.Account.option[9] then control:AddLine('\n|cC5C29E'..ZOSF('<<ZC:1>>',GetString('SI_ITEMSTYLE',GetItemLinkItemStyle(link)))..'|r','ZoFontGameSmall')end
    if craft and line and trait then need = CS.IsItemNeeded(craft,line,trait,id,link) end
  end
  if need ~= '' then control:AddLine(need,'CraftStoreFixedFont') end
  if CS.Account.option[15] and CS.Account.storage[stripedLink] then
    if CS.Account.materials[stripedLink] and CS.Account.storage[CS.Account.materials[stripedLink].link] then
      local pairedInfo = CS.Account.materials[stripedLink]
      local prefix1, prefix2 = '', ''
      
      if pairedInfo.raw then
        prefix1 = 'Raw: '
        prefix2 = 'Refined: '
      else
        prefix1 = 'Refined: '
        prefix2 = 'Raw: '
      end
      for x, stock in pairs(CS.Account.storage[stripedLink]) do if stock and stock > 0 then table.insert(store,'|c8085FF'..x..':|r |cC0C5FF'..stock..'|r') end end
      if #store > 0 then control:AddLine(prefix1..table.concat(store,', '),'CraftStoreFixedFont') end
      store={}
      for x, stock in pairs(CS.Account.storage[pairedInfo.link]) do if stock and stock > 0 then table.insert(store,'|c8085FF'..x..':|r |cC0C5FF'..stock..'|r') end end
      if #store > 0 then control:AddLine(prefix2..table.concat(store,', '),'CraftStoreFixedFont') end
    else
      for x, stock in pairs(CS.Account.storage[stripedLink]) do if stock and stock > 0 then table.insert(store,'|c8085FF'..x..':|r |cC0C5FF'..stock..'|r') end end
      if #store > 0 then control:AddLine(table.concat(store,', '),'CraftStoreFixedFont') end
    end
  end
  store = nil
end
function CS.TooltipHandler()
  local tt=ItemTooltip.SetBagItem
  ItemTooltip.SetBagItem=function(control,bagId,slotIndex,...)
    tt(control,bagId,slotIndex,...)
    local itemLink = GetItemLink(bagId,slotIndex)
    local uID = GetItemUniqueId(bagId,slotIndex)
    CS.TooltipShow(control,itemLink,Id64ToString(uID))
  end
  local tt=ItemTooltip.SetLootItem
  ItemTooltip.SetLootItem=function(control,lootId,...)
    tt(control,lootId,...)
    CS.TooltipShow(control,GetLootItemLink(lootId))
  end
  local ResultTooltip=ZO_SmithingTopLevelCreationPanelResultTooltip
  local tt=ResultTooltip.SetPendingSmithingItem
  ResultTooltip.SetPendingSmithingItem=function(control,pid,mid,mq,sid,tid)
    tt(control,pid,mid,mq,sid,tid)
    CS.TooltipShow(control,GetSmithingPatternResultLink(pid,mid,mq,sid,tid))
  end  
  local tt=PopupTooltip.SetLink
  PopupTooltip.SetLink=function(control,link,...)
    tt(control,link,...)
    CS.TooltipShow(control,link)
  end
  local tt=ItemTooltip.SetLink
  ItemTooltip.SetLink=function(control,link,...)
    tt(control,link,...)
    CS.TooltipShow(control,link)
  end
  local tt=ItemTooltip.SetAttachedMailItem
  ItemTooltip.SetAttachedMailItem=function(control,openMailId,attachmentIndex,...)
    tt(control,openMailId,attachmentIndex,...)
    CS.TooltipShow(control,GetAttachedItemLink(openMailId,attachmentIndex))
  end
  local tt=ItemTooltip.SetBuybackItem
  ItemTooltip.SetBuybackItem=function(control,index,...)
    tt(control,index,...)
    CS.TooltipShow(control,GetBuybackItemLink(index))
  end
  local tt=ItemTooltip.SetTradingHouseItem
  ItemTooltip.SetTradingHouseItem=function(control,tradingHouseIndex,...)
    tt(control,tradingHouseIndex,...)
    CS.TooltipShow(control,GetTradingHouseSearchResultItemLink(tradingHouseIndex))
  end
  local tt=ItemTooltip.SetTradingHouseListing
  ItemTooltip.SetTradingHouseListing=function(control,tradingHouseListingIndex,...)
    tt(control,tradingHouseListingIndex,...)
    CS.TooltipShow(control,GetTradingHouseListingItemLink(tradingHouseListingIndex))
  end
  local tt=ItemTooltip.SetTradeItem
  ItemTooltip.SetTradeItem=function(control,tradeWho,slotIndex,...)
    tt(control,tradeWho,slotIndex,...)
    CS.TooltipShow(control,GetTradeItemLink(slotIndex))
  end
  local tt=ItemTooltip.SetQuestReward
  ItemTooltip.SetQuestReward=function(control,rewardIndex,...)
    tt(control,rewardIndex,...)
    CS.TooltipShow(control,GetQuestRewardItemLink(rewardIndex))
  end
end
function CS.ControlCloseAll()
  CraftStoreFixed_CharacterPanel:SetHidden(true)
  CraftStoreFixed_OptionPanel:SetHidden(true)
  CraftStoreFixed_Recipe_Window:SetHidden(true)
  CraftStoreFixed_Style_Window:SetHidden(true)
  CraftStoreFixed_Blueprint_Window:SetHidden(true)
  CraftStoreFixed_SetPanel:SetHidden(true)
  SM:HideTopLevel(CraftStoreFixed_Panel)
  CS.RuneView(2)
  MODE = 0
end
function CS.ControlShow(scene)
  local closed = scene:IsHidden()
  CraftStoreFixed_CharacterPanel:SetHidden(true)
  CraftStoreFixed_OptionPanel:SetHidden(true)
  CraftStoreFixed_Recipe_Window:SetHidden(true)
  CraftStoreFixed_Style_Window:SetHidden(true)
  CraftStoreFixed_SetPanel:SetHidden(true)
  if closed then scene:SetHidden(false) end
end

function CS.ShowMain()


  SM:ToggleTopLevel(CraftStoreFixed_Panel)
    if not CraftStoreFixed_Panel:IsHidden() then
    CS.GetQuest()
    local questText = ''
    for _, quest in pairs(CS.Quest) do
      if questText ~= '' then questText = questText..'\n\n' end
      questText = questText..quest.name
      for _, step in pairs(quest.work) do questText = questText..'\n'..step end
    end
    if questText ~= '' then CraftStoreFixed_PanelQuestButton.data = { info = questText } else CraftStoreFixed_PanelQuestButton.data = nil end
    if CS.Account.mainchar then CS.SelectedPlayer = CS.Account.mainchar end
    CS.UpdatePlayer()
    CS.UpdateScreen()
    if CS.Account.timer[12] > 0 then CraftStoreFixed_Panel12Hours:SetText(CS.GetTime(CS.Account.timer[12] - GetTimeStamp())) else CraftStoreFixed_Panel12Hours:SetText('12:00h') end
    if CS.Account.timer[24] > 0 then CraftStoreFixed_Panel24Hours:SetText(CS.GetTime(CS.Account.timer[24] - GetTimeStamp())) else CraftStoreFixed_Panel24Hours:SetText('24:00h') end
  end
end

function CS.BlueprintMark(control,button)
  local mark
  if button == 2 then CS.ToChat(control.data.link)
  else
    local tracked = CS.Account.furnisher.ingredients[control.data.id] or false
    if tracked then
      mark = ''
      CS.Account.furnisher.ingredients[control.data.id] = nil
    else
      mark = '|t22:22:esoui/art/inventory/newitem_icon.dds|t '
      CS.Account.furnisher.ingredients[control.data.id] = true
    end
    control:SetText(mark..'('..CS.Furnisher.recipe[control.data.rec].level..') '..CS.Furnisher.recipe[control.data.rec].name)
    zo_callLater(CS.UpdateIngredientTracking,500)
  end
end
function CS.BlueprintShow(id,inc,known)
  local color, mark, control
  if CS.Account.furnisher.ingredients[CS.Furnisher.recipe[id].id] then mark = '|t22:22:esoui/art/inventory/newitem_icon.dds|t ' else mark = '' end
  if CS.Furnisher.recipe[id].known then color = CS.Quality[CS.Furnisher.recipe[id].quality]; known = known + 1; else color = {1,0,0,1} end
  control = WM:GetControlByName('CraftStoreFixed_BlueprintPanelScrollChildButton'..inc)
  control:SetNormalFontColor(color[1],color[2],color[3],color[4])
  control:SetText(mark..'('..CS.Furnisher.recipe[id].level..') '..CS.Furnisher.recipe[id].name)
  control:SetHidden(false)
  control.data = {link = CS.Furnisher.recipe[id].link, rec = id, id = CS.Furnisher.recipe[id].id, buttons = {CS.Loc.TT[7],CS.Loc.TT[6]}}
  return inc + 1, known
end
function CS.BlueprintShowCategory(list)
  if list > 6 then list = 1 end
  local inc, known = 1, 0
  for x = 1,blueprints_count do WM:GetControlByName('CraftStoreFixed_BlueprintPanelScrollChildButton'..x):SetHidden(true) end
  for id, recipe in pairs(CS.Furnisher.recipe) do
    if recipe.stat == list then inc,known = CS.BlueprintShow(id,inc,known) end
  end
  CraftStoreFixed_BlueprintPanelScrollChild:SetHeight(inc * 22 - 13)
  CraftStoreFixed_BlueprintHeadline:SetText(ZOSF('<<C:1>>',CS.Furnisher.category[list]))
  -- CraftStoreFixed_BlueprintInfo:SetText(CS.Furnisher.category[list]..' ('..known..'/'..(inc - 1)..')')
  CraftStoreFixed_BlueprintInfo:SetText('('..known..' / '..(inc - 1)..')')
  CS.Character.recipe = list
end
function CS.BlueprintSearch()
  local search, inc, known = CraftStoreFixed_BlueprintSearch:GetText(), 1, 0
  if search ~= '' then
    for x = 1,blueprints_count do
      local control = WM:GetControlByName('CraftStoreFixed_BlueprintPanelScrollChildButton'..x)
      control:SetHidden(true)
      control.data = nil
    end
    for id, food in pairs(CS.Furnisher.recipe) do
      if string.find(string.lower(food.name),string.lower(search)) then inc,known = CS.BlueprintShow(id,inc,known) end
    end
    CraftStoreFixed_BlueprintPanelScrollChild:SetHeight(inc * 22 - 13)
    CraftStoreFixed_BlueprintHeadline:SetText(CS.Loc.searchfor)
    CraftStoreFixed_BlueprintInfo:SetText(search..' ('..(inc - 1)..')')
  end
end
function CS.BlueprintLearned(list,id)
  local link = GetRecipeResultItemLink(list,id,LINK_STYLE_DEFAULT)
  if link then for id, recipe in pairs(CS.Furnisher.recipe) do
    if recipe.result == link then
      CS.Furnisher.recipe[id].known = true
      CS.Account.furnisher.knowledge[CS.CurrentPlayer][CS.Furnisher.recipe[id].id] = true
      break
    end
  end end
end


if CS.Debug then
  
  --[[
  function CS.ListItems(begin, count)
    begin = tonumber(begin)
    for i=begin,begin+100 do
      d('|H1:item:'..i..':5:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h')
    end
  end
  
  
  function CS.PerfomanceTest(args)
    local start = 0
    local endt = 0
    local count, count2 = zo_strsplit(' ',args)
    count = tonumber(count)
    count2 = tonumber(count2)
    
    local test_1 = {}
    test_2 = {}
    test_2.test_3 = {}
    test_5 = {}
    local test_4 = test_2.test_3
    start = GetTimeStamp()
    for j = 1, count2 do
      for i = 1,count do
        test_1[i] = i
      end
      test_1 = {}
    end
    endt = GetTimeStamp()
    d("Local: "..(endt-start))
    start = GetTimeStamp()
    for j = 1, count2 do
      for i = 1,count do
        test_4[i] = i
      end
      test_4 = {}
    end
    endt = GetTimeStamp()
    d("Referenced: "..(endt-start))
    start = GetTimeStamp()
    for j = 1, count2 do
      for i = 1,count do
        test_5[i] = i
      end
      test_5 = {}
    end
    endt = GetTimeStamp()
    d("Global: "..(endt-start))
  end
  SLASH_COMMANDS["/list"] = CS.ListItems
  SLASH_COMMANDS["/perf"] = CS.PerfomanceTest]]
  _CS = CS
  SLASH_COMMANDS["/_"] = function() d(_G["_"]) end
  SLASH_COMMANDS["//"] = SLASH_COMMANDS["/reloadui"]
  SLASH_COMMANDS["/langfr"] = function() SetCVar("language.2", "fr") end
  SLASH_COMMANDS["/langen"] = function() SetCVar("language.2", "en") end
  SLASH_COMMANDS["/langde"] = function() SetCVar("language.2", "de") end
end