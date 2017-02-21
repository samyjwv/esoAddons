local CS = CraftStoreFixedAndImprovedLongClassName
function CS.STYLE()
  local self = {}
  --                   Axe    Belt    Boot    Bow     Chest   Dager   Glove   Head    Legs    Mace    Shield  Shoul   Staves  Swords
  --                   1      2       3       4       5       6       7       8       9       10      11      12      13      14  
  local itemHeavy =   {43532, 43542,  43538,  43549,  43537,  43535,  43539,  43562,  43540,  43533,  43556,  43541,  43557,  43534} --Heavy Armor cp160
  local itemMedium =  {43532, 43555,  43551,  43549,  43550,  43535,  43552,  43563,  43553,  43533,  43556,  43554,  43557,  43534} --Medium Armor cp160
  local itemRobe =    {43532, 43548,  43544,  43549,  43543,  43535,  43545,  43564,  43546,  43533,  43556,  43547,  43557,  43534} --Light Armor Robe cp160
  local itemJack =    {43532, 43548,  43544,  43549,  44241,  43535,  43545,  43564,  43546,  43533,  43556,  43547,  43557,  43534} --Light Armor Jack cp160
  local previewItems = {itemHeavy, itemMedium, itemRobe, itemJack}
  local item = itemHeavy
  
  local styles = {
    [ITEMSTYLE_RACIAL_BRETON        +1] = {1,1025,16425},
    [ITEMSTYLE_RACIAL_REDGUARD      +1] = {1,1025,16427},
    [ITEMSTYLE_RACIAL_ORC           +1] = {1,1025,16426},
    [ITEMSTYLE_RACIAL_DARK_ELF      +1] = {1,1025,27245},
    [ITEMSTYLE_RACIAL_NORD          +1] = {1,1025,27244},
    [ITEMSTYLE_RACIAL_ARGONIAN      +1] = {1,1025,27246},
    [ITEMSTYLE_RACIAL_HIGH_ELF      +1] = {1,1025,16424},
    [ITEMSTYLE_RACIAL_WOOD_ELF      +1] = {1,1025,16428},
    [ITEMSTYLE_RACIAL_KHAJIIT       +1] = {1,1025,44698},
    [ITEMSTYLE_RACIAL_IMPERIAL      +1] = {1,1025,54868},
    
    [ITEMSTYLE_DEITY_MALACATH       +1] = {2,1412,71567},
    [ITEMSTYLE_DEITY_TRINIMAC       +1] = {2,1411,71551},
    [ITEMSTYLE_DEITY_AKATOSH        +1] = {2,1660,82088}, --Order of the Hour 
    
    [ITEMSTYLE_AREA_DWEMER          +1] = {2,1144,57573},
    [ITEMSTYLE_AREA_ANCIENT_ELF     +1] = {1,1025,51638},
    [ITEMSTYLE_AREA_REACH           +1] = {1,1025,51565}, -- Barbaric
    [ITEMSTYLE_AREA_ANCIENT_ORC     +1] = {2,1341,69528},
    [ITEMSTYLE_AREA_XIVKYN          +1] = {2,1181,57835},
    [ITEMSTYLE_AREA_SOUL_SHRIVEN    +1] = {1,1418,71765},
    [ITEMSTYLE_AREA_AKAVIRI         +1] = {2,1318,57591},
    [ITEMSTYLE_AREA_YOKUDAN         +1] = {2,1713,57606}, -- YOKUDAN
    
    [ITEMSTYLE_ENEMY_PRIMITIVE      +1] = {1,1025,51345}, -- Primal
    [ITEMSTYLE_ENEMY_DAEDRIC        +1] = {1,1025,51688},
    [ITEMSTYLE_ENEMY_DROMOTHRA      +1] = {2,1659,74653}, --Dro-m'Athra
    [ITEMSTYLE_ENEMY_MINOTAUR       +1] = {2,1662,82072}, --Minotaur
    [ITEMSTYLE_ENEMY_DRAUGR         +1] = {2,1715,76895}, -- DRAUGR
    [ITEMSTYLE_ENEMY_SKINCHANGER    +1] = {2,1676,73855}, -- SkinChanger 
    
    [ITEMSTYLE_ALLIANCE_DAGGERFALL  +1] = {2,1416,71705},
    [ITEMSTYLE_ALLIANCE_EBONHEART   +1] = {2,1414,71721},
    [ITEMSTYLE_ALLIANCE_ALDMERI     +1] = {2,1415,71689},
    
    [ITEMSTYLE_UNDAUNTED            +1] = {2,1348,64716}, -- Mercenary
    [ITEMSTYLE_GLASS                +1] = {2,1319,64670},
    
    [ITEMSTYLE_ORG_THIEVES_GUILD    +1] = {2,1423,74556},
    [ITEMSTYLE_ORG_OUTLAW           +1] = {2,1417,71523},
    [ITEMSTYLE_ORG_ASSASSINS        +1] = {2,1424,76879},
    [ITEMSTYLE_ORG_ABAHS_WATCH      +1] = {2,1422,74540},
    [ITEMSTYLE_ORG_DARK_BROTHERHOOD +1] = {2,1661,82055}, -- Dark Brotherhood
    
    [ITEMSTYLE_RAIDS_CRAGLORN       +1] = {2,1714,82007}, -- CELESTIAL
    
    [ITEMSTYLE_EBONY                +1] = {2,1798,75229}, -- Ebony
    [ITEMSTYLE_AREA_RA_GADA         +1] = {2,1797,71673}, -- Ra Gada
    
    [ITEMSTYLE_UNUSED16             +1] = {3,0,96954}, -- Stalhrim Frostcaster//??? 54
    [ITEMSTYLE_UNUSED19             +1] = {2,1796,114968}, -- Silken Ring
    [ITEMSTYLE_UNUSED20             +1] = {2,1795,114952}, -- Mazzatun
    [ITEMSTYLE_UNUSED21             +1] = {3,0,82039}, -- GRIM HARLEQUIN//??? 59
    [ITEMSTYLE_UNUSED22             +1] = {2,1545,82023}, -- HOLLOWJACK
  }
  --|H1:item:96954:5:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
  
  
  function self.IsSimpleStyle(style)
    if not styles[style] then return false end
    if styles[style][1] == 1 then return true end
    return false
  end
  
  function self.IsCrownStyle(style)
    if not styles[style] then return false end
    if styles[style][1] == 3 then return true end
    return false
  end
  
  function self.IsPerfectedStyle(style)
    if not styles[style] then return false end
    if self.IsSimpleStyle(style) then
      return IsSmithingStyleKnown(style)
    else 
      if self.IsCrownStyle(style) then
        return IsItemLinkBookKnown(('|H1:item:%u:6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h'):format(styles[style][3]))
      else      
        for chapter = 1,14 do
          local _, known = GetAchievementCriterion(styles[style][2],chapter)
          if known == 0 then return false end
        end
        return true
      end
    end
    return false
  end

  function self.IsKnownStyle(style,chapter)
    if not styles[style] then return false end
    if self.IsSimpleStyle(style) then
      return IsSmithingStyleKnown(style)
    else 
      if self.IsCrownStyle(style) then
        return IsItemLinkBookKnown(('|H1:item:%u:6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h'):format(styles[style][3]))
      else  
        local _, known = GetAchievementCriterion(styles[style][2],chapter)
        if known == 1 then return true end
      end
    end
    return false
  end
  
  function self.UpdatePreview(preview)
    if type(preview) == "string" then preview=1 end
    item = previewItems[preview]
  end
    
  function self.GetChapterId(style,chapter)
    if not styles[style] then styles[style] = {1,1028,63026} end
    if self.IsSimpleStyle(style) then return styles[style][3]
    else return styles[style][3] + (chapter - 1) end
  end
  
  function self.GetIconAndLink(style,chapter)
    if not styles[style] then styles[style] = {1,1028,63026} end
    local link, icon = GetSmithingStyleItemInfo(style)
    local _, _, _, _, rawStyle = GetSmithingStyleItemInfo(style)
    link = ('|H1:item:%u:370:50:0:0:0:0:0:0:0:0:0:0:0:0:%u:0:0:0:10000:0|h|h'):format(item[chapter],rawStyle)
    icon = GetItemLinkInfo(link)
    if self.IsSimpleStyle(style) or self.IsCrownStyle(style) then link = ('|H1:item:%u:5:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h'):format(styles[style][3])
    else link = ('|H1:item:%u:6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h'):format(styles[style][3] + (chapter - 1)) end
    return icon, link
  end
  
  function self.CheckStyle(style)
    --if style == ITEMSTYLE_UNIVERSAL+1 then return false end
    --if style == ITEMSTYLE_NONE then return false end
    if not CS.Debug then
      if not styles[style] then return false end
      if styles[style][1] == 0 then return false end        
    elseif not styles[style] then 
      local _, icon, _, _, rawStyle = GetSmithingStyleItemInfo(style)
      name = zo_strformat('<<C:1>>',GetString('SI_ITEMSTYLE', rawStyle))
      if name ~= "None" and name ~= "" then
        return true 
      else
        return false
      end
    end
    return true
  end
  
  function self.GetHeadline(style)
    if not styles[style] then styles[style] = {1,1028,63026} end
    local link, name, aName, aLink, popup
    local _, icon, _, _, rawStyle = GetSmithingStyleItemInfo(style)
    link = GetSmithingStyleItemLink(style)
    name = zo_strformat('<<C:1>>',GetString('SI_ITEMSTYLE', rawStyle))
    if CS.Debug then name = name..zo_strformat('<<C:1>>',style) end
    if styles[style][1]~=3 then
      aLink = GetAchievementLink(styles[style][2],LINK_STYLE_BRACKETS)
      aName = zo_strformat('<<C:1>>',GetAchievementInfo(styles[style][2])) 
    else
      aName = 'crown'
    end
    local _,_,_,_,progress,ts = ZO_LinkHandler_ParseLink(aLink)
    popup = {styles[style][2],progress,ts}
    return icon, link, name, aName, aLink, popup
  end
  return self
end