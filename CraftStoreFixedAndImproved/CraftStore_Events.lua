local CS = CraftStoreFixedAndImprovedLongClassName

local EM, WM, SM, ZOSF = EVENT_MANAGER, WINDOW_MANAGER, SCENE_MANAGER, zo_strformat
function CS.OnQuestConditionCounterChanged(eventCode,journalIndex)
  CS.UpdateQuest(journalIndex)
end

function CS.OnRecipeLearned(eventCode,list,id)
  -- FIXME: SpecializedItemType
  CS.RecipeLearned(list,id)
  CS.BlueprintLearned(list,id)
end

function CS.OnStyleLearned(eventCode, styleIndex, chapterIndex, isDefaultRacialStyle)
  CS.UpdateStyleKnowledge(true) 
end

function CS.OnSmithingTraitResearchStarted(eventCode, craft, line, trait)
  local _,remaining = GetSmithingResearchLineTraitTimes(craft,line,trait)
  if remaining then CS.Account.crafting.research[CS.CurrentPlayer][craft][line][trait] = remaining + GetTimeStamp() end
  CS.Account.crafting.stored[craft][line][trait] = {}
  CS.UpdateResearchWindows()
  CS.UpdatePanelIcon(craft,line,trait)
  if CS.Account.option[12] then CS.GetTimer() end
end

function CS.OnSmithingTraitResearchCompleted(eventCode, craft, line, trait)
  CS.Account.crafting.research[CS.CurrentPlayer][craft][line][trait] = true
  CS.UpdateResearchWindows()
  CS.UpdatePanelIcon(craft,line,trait)
end

function CS.OnStableInteractEnd(eventCode)
  if CS.Account.option[12] then CS.GetTimer() end
end

function CS.OnCraftingStationInteract(eventCode,craftSkill)
  if CS.Account.option[7] then
    if craftSkill == CRAFTING_TYPE_PROVISIONING then
      CS.Cook.craftLevel = GetNonCombatBonus(NON_COMBAT_BONUS_PROVISIONING_LEVEL)
      CS.Cook.qualityLevel = GetNonCombatBonus(NON_COMBAT_BONUS_PROVISIONING_RARITY_LEVEL)
      CS.CookShowCategory(CS.Character.recipe)
      CraftStoreFixed_CookAmount:SetText('')
      CraftStoreFixed_CookSearch:SetText(GetString(SI_GAMEPAD_HELP_SEARCH)..'...')
      CraftStoreFixed_Cook:SetHidden(false)
      for x = 2, ZO_ProvisionerTopLevel:GetNumChildren() do ZO_ProvisionerTopLevel:GetChild(x):SetAlpha(0) end
      ZO_KeybindStripControl:SetHidden(true)
    end
  end
  if CS.Account.option[8] then
    if craftSkill == CRAFTING_TYPE_ENCHANTING then
      CS.Extern = false
      CS.RuneInitalize()
      for x = 2, ZO_EnchantingTopLevel:GetNumChildren() do ZO_EnchantingTopLevel:GetChild(x):SetHidden(true) end
      ZO_KeybindStripControl:SetHidden(true)
      local soundPlayer = CRAFTING_RESULTS.enchantSoundPlayer
      soundPlayer.PlaySound = function() return end
    end
  end
  -- if CS.Account.option[8] then
    -- if craftSkill == CRAFTING_TYPE_ALCHEMY then
      -- CS_Flask:SetHidden(false)
    -- end
  -- end
  if CS.Account.option[6] then
    CS.GetQuest()
    if CS.Quest[craftSkill] then
      local title = CS.Quest[craftSkill].name..'\n'
      local out = ''
      for _, step in pairs(CS.Quest[craftSkill].work) do out = out..step..'\n' end
      if CS.Quest[craftSkill] then
        if DolgubonsWrits and craftSkill~=CRAFTING_TYPE_ALCHEMY and craftSkill~=CRAFTING_TYPE_PROVISIONING then
          if not CraftStoreFixed_DolgubonsWritsEndpoint then
            WM:CreateControl('CraftStoreFixed_DolgubonsWritsEndpoint',DolgubonsWritsBackdrop,CT_LABEL)
            CraftStoreFixed_DolgubonsWritsEndpoint:SetFont('ZoFontGame')
            CraftStoreFixed_DolgubonsWritsEndpoint:SetColor(1,1,1,1)
            CraftStoreFixed_DolgubonsWritsEndpoint:SetHorizontalAlignment(1)
            CraftStoreFixed_DolgubonsWritsEndpoint:SetVerticalAlignment(TOP)
            CraftStoreFixed_DolgubonsWritsEndpoint:SetWidth(400)
            CraftStoreFixed_DolgubonsWritsEndpoint:SetAnchor(TOP,DolgubonsWritsBackdropOutput,BOTTOM,0,5)
            DolgubonsWritsBackdrop.CraftStoreFixed_DolgubonsWritsEndpoint = CraftStoreFixed_DolgubonsWritsEndpoint
            DolgubonsWritsBackdropCraft:ClearAnchors()
            DolgubonsWritsBackdropCraft:SetAnchor(TOP,CraftStoreFixed_DolgubonsWritsEndpoint,BOTTOM,0,5)
          end
          if WritCreater.savedVars.tutorial then 
            zo_callLater(function () CS.UpdateQuest(CS.Quest[craftSkill].id) end, 1000)
          else
            CraftStoreFixed_DolgubonsWritsEndpoint:SetText(out)
          end
        else        
          CraftStoreFixed_QuestText:SetText(title..out)
          CraftStoreFixed_Quest:SetHidden(false)
        end
      end
    end
  end
end

function CS.OnCraftCompleted(eventCode,craftSkill)
  local val = GetLastCraftingResultTotalInspiration()
    if val > 0 then CS.Inspiration = '|t30:30:/esoui/art/currency/currency_inspiration.dds|t |c9095FF'..val..'|r' end
    if CS.Account.option[7] and craftSkill == CRAFTING_TYPE_PROVISIONING then
      if CS.Cook.job.amount > 0 then
        CraftProvisionerItem(CS.Cook.job.list,CS.Cook.job.id)
        PlaySound(CS.Cook.job.sound)
        CraftStoreFixed_CookAmount:SetText(CS.Cook.job.amount)
        CS.Cook.job.amount = CS.Cook.job.amount - 1
      end
      zo_callLater(function() CS.CookShowCategory(CS.Character.recipe) end,500)
    end
    if CS.Account.option[8] and craftSkill == CRAFTING_TYPE_ENCHANTING then
      if CS.Rune.job.amount > 0 then
        local bagP, slotP = CS.ScanBag(CS.Rune.job.id[1])
        local soundP, lengthP = GetRunestoneSoundInfo(bagP,slotP)
        local bagE, slotE = CS.ScanBag(CS.Rune.job.id[2])
        local soundE, lengthE = GetRunestoneSoundInfo(bagE,slotE)
        local bagA, slotA = CS.ScanBag(CS.Rune.job.id[3])
        local soundA,_ = GetRunestoneSoundInfo(bagA,slotA)
        CraftEnchantingItem(bagP,slotP,bagE,slotE,bagA,slotA)
        if CS.Account.option[13] then
          zo_callLater(function() PlaySound(soundP) end, 250)
          zo_callLater(function() PlaySound(soundE) end, lengthP + 250)
          zo_callLater(function() PlaySound(soundA) end, lengthE + lengthP + 250)
        else
          zo_callLater(function() PlaySound('Enchanting_Create_Tooltip_Glow') end, 250)
        end
        CraftStoreFixed_RuneAmount:SetText(CS.Rune.job.amount)
        CS.Rune.job.amount = CS.Rune.job.amount - 1
      elseif CS.Rune.refine.glyphs[1] then
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
      zo_callLater(CS.RuneShowMode,500)
    end
    CS.UpdateBag()
end

function CS.OnEndCraftingStationInteract(eventCode, craftSkill)
  CraftStoreFixed_Cook:SetHidden(true)
  CraftStoreFixed_Quest:SetHidden(true)
  CraftStoreFixed_Rune:SetHidden(true)
  CraftStoreFixed_Flask:SetHidden(true)
  CS.UIClosed = true
  for x = 2, ZO_ProvisionerTopLevel:GetNumChildren() do ZO_ProvisionerTopLevel:GetChild(x):SetAlpha(1) end
  for x = 2, ZO_EnchantingTopLevel:GetNumChildren() do ZO_EnchantingTopLevel:GetChild(x):SetHidden(false) end
end

function CS.OnGameCameraUIModeChanged(eventCode)
  if CS.UIClosed then CS.UIClosed=false end
end

function CS.OnActionLayerPushed(eventCode, layerIndex, activeLayerIndex)
  if CS.UIClosed then ZO_KeybindStripControl:SetHidden(false) CS.UIClosed=false end 
end

function CS.NewMovementInUIMode(eventCode)
  if CS.Account.option[3] and not CraftStoreFixed_Panel:IsHidden() then CS.ControlCloseAll() end
end

function CS.OnReticleHiddenUpdate(eventCode,hidden)
  if not hidden and not CraftStoreFixed_Rune:IsHidden() then CS.RuneView(2) end
end

function CS.OnPlayerActivated(eventCode,initial)
  CS.UpdateAccountVars()
  CS.UpdatePlayer()
  CS.UpdateStyleKnowledge(true)
  CS.UpdateRecipeKnowledge()
  CS.UpdateAllStudies()
  CS.UpdateInventory()
  CS.CharacterInitialize()
  CS.GetTimer()
  CS.InitPreviews()
  CS.HideStyles(true)
  CS.HidePerfectedStyles(true)
  CS.Init = true
  EM:UnregisterForEvent('CSEE',EVENT_PLAYER_ACTIVATED)
end

function CS.OnPlayerDeactivated(eventCode)
  CS.UpdatePlayer(true)
  EM:UnregisterForEvent('CSEE',EVENT_PLAYER_DEACTIVATED)
end

function CS.OnChampionPerksSceneStateChange(oldState,newState)
  if newState == SCENE_SHOWING then
      SM:HideTopLevel(CraftStoreFixed_Panel)
      CraftStoreFixed_ButtonFrame:SetHidden(true)
    elseif newState == SCENE_HIDDEN then
      if CS.Account.option[1] then CraftStoreFixed_ButtonFrame:SetHidden(false) end
    end
end

function CS.OnInventorySlotAdded(bag,slot,data)  
  if bag ~= 1 and bag~=2 and bag~=5 then return end
  local link = CS.StripLink(GetItemLink(bag,slot))
  local a1, a2, a3 = GetItemLinkStacks(link)
  if not CS.Account.storage[link] then CS.Account.storage[link] = {} end
  CS.Account.storage[link][CS.Loc.craftbag] = a3
  CS.Account.storage[link][CS.Loc.bank] = a2
  CS.Account.storage[link][CS.CurrentPlayer] = a1
  CS.UpdateMatsInfo(link)
  data.uid = Id64ToString(GetItemUniqueId(bag,slot))
  data.lnk = link
  if CS.IsValidEquip(GetItemLinkEquipType(link)) then CS.UpdateStored('added',data) end
end
  
function CS.OnInventorySlotRemoved(bag,slot,data)
  if bag ~= 1 and bag~=2 and bag~=5 then return end
  local link = CS.StripLink(data.lnk)
  local a1, a2, a3 = GetItemLinkStacks(link)
  CS.Account.storage[link][CS.Loc.craftbag] = a3
  CS.Account.storage[link][CS.Loc.bank] = a2
  CS.Account.storage[link][CS.CurrentPlayer] = a1
  CS.UpdateMatsInfo(link)
  if CS.IsValidEquip(GetItemLinkEquipType(data.lnk)) then CS.UpdateStored('removed',data) end
end

function CS.OnStackSplitShow()
  if CS.Account.option[16] then
    ZO_StackSplitSpinnerDisplay:TakeFocus()
    ZO_StackSplitSpinnerDisplay:SelectAll()
  end
end

function CS.OnInventorySingleSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
  CS.OnInventorySlotAdded(bagId, slotId, {bagId=bagId})
end


function CS.OnAddOnLoaded(eventCode,addOnName)
  if addOnName ~= CS.Name then return end
  CS.Style = CS.STYLE()
  --cs_flask = CS.CS.Flask()  
  CS.Account = ZO_SavedVars:NewAccountWide('CraftStore_Account',1,nil,CS.AccountInit)
  CS.Character = ZO_SavedVars:New('CraftStore_Character',1,nil,CS.CharInit)
  
  ZO_CreateStringId('SI_BINDING_NAME_SHOW_CRAFTSTOREFIXED_WINDOW',CS.Loc.TT[15])
  SM:RegisterTopLevel(CraftStoreFixed_Panel,false)
  EM:RegisterForEvent('CSEE',EVENT_QUEST_CONDITION_COUNTER_CHANGED,CS.OnQuestConditionCounterChanged)
  EM:RegisterForEvent("CSEE",EVENT_RECIPE_LEARNED,CS.OnRecipeLearned)
  EM:RegisterForEvent('CSEE',EVENT_STYLE_LEARNED,CS.OnStyleLearned)
  EM:RegisterForEvent('CSEE',EVENT_TRADING_HOUSE_RESPONSE_RECEIVED,CS.UpdateGuildStore)
  EM:RegisterForEvent('CSEE',EVENT_SMITHING_TRAIT_RESEARCH_STARTED,CS.OnSmithingTraitResearchStarted)
  EM:RegisterForEvent('CSEE',EVENT_STABLE_INTERACT_END,CS.OnStableInteractEnd)
  EM:RegisterForEvent('CSEE',EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED,CS.OnSmithingTraitResearchCompleted)
  EM:RegisterForEvent('CSEE',EVENT_CRAFTING_STATION_INTERACT,CS.OnCraftingStationInteract)
  EM:RegisterForEvent('CSEE',EVENT_INVENTORY_FULL_UPDATE,CS.UpdateBag)
  EM:RegisterForEvent('CSEE',EVENT_CRAFT_COMPLETED,CS.OnCraftCompleted)
  EM:RegisterForEvent('CSEE',EVENT_END_CRAFTING_STATION_INTERACT,CS.OnEndCraftingStationInteract)
  EM:RegisterForEvent('CSEE',EVENT_GAME_CAMERA_UI_MODE_CHANGED,CS.OnGameCameraUIModeChanged)
  EM:RegisterForEvent('CSEE',EVENT_ACTION_LAYER_PUSHED,CS.OnActionLayerPushed)
  EM:RegisterForEvent('CSEE',EVENT_NEW_MOVEMENT_IN_UI_MODE,CS.NewMovementInUIMode)
  EM:RegisterForEvent('CSEE',EVENT_RETICLE_HIDDEN_UPDATE,CS.OnReticleHiddenUpdate)
  EM:RegisterForEvent('CSEE',EVENT_PLAYER_ACTIVATED,CS.OnPlayerActivated)
  EM:RegisterForEvent('CSEE',EVENT_PLAYER_DEACTIVATED,CS.OnPlayerDeactivated)
  EM:RegisterForEvent('CSEE',EVENT_INVENTORY_SINGLE_SLOT_UPDATE, CS.OnInventorySingleSlotUpdate)
  CHAMPION_PERKS_SCENE:RegisterCallback('StateChange',CS.OnChampionPerksSceneStateChange)
  
  SHARED_INVENTORY:RegisterCallback('SlotAdded',CS.OnInventorySlotAdded)
  SHARED_INVENTORY:RegisterCallback('SlotRemoved',CS.OnInventorySlotRemoved)
  ZO_PreHookHandler(ZO_StackSplit,'OnShow', CS.OnStackSplitShow)
  
  
  CS.ScrollText()
  CS.TooltipHandler()
  if type(CS.Character.previewtype) == "string" then CS.Character.previewtype=1 end
  CS.Style.UpdatePreview(CS.Character.previewtype)
  CS.PanelInitialize()
  
  if CS.Character.income[1] ~= GetDate()then
    CS.Character.income[1] = GetDate()
    CS.Character.income[2] = GetCurrentMoney()
  end
  
  EM:UnregisterForEvent('CSEE',EVENT_ADD_ON_LOADED)
end

EM:RegisterForEvent('CSEE',EVENT_ADD_ON_LOADED,CS.OnAddOnLoaded)