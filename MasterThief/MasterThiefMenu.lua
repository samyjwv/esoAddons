--[[
Created by: Adalan@Aruntas
Support, Fixes, Improvements by:


--]]

-- Create MasterThief Addon-SettingsMenu
function MasterThief:CreateSettingsMenu()
	local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
	--Register the Options panel with LAM
	local panelData = 
	{
    	type = "panel",
     	name = "MasterThief",
		author = "Adalan",
		version = MasterThief.version,
	}
	LAM:RegisterAddonPanel("MasterThiefOptions", panelData)

	--Set the actual panel data
	local optionsData = {
		[1] = {
			type = "description",
			title = nil,
			text = "|cF1C013"..GetString(MT_MISC_MASTERTHIEF_COMMANDS).."|r\n/|cF1C013masterthief|r: "..GetString(MT_MISC_MASTERTHIEF_LISTCOMMANDS),
			width = "full",
		},	
    	[2] = {
          type = "checkbox",
          name = "MasterThief",
          tooltip = GetString(MASTER_THIEF_TEXT),
          getFunc = function() return MasterThief.SavedVarsOptions.MasterThiefActive end,
          setFunc = function(value) MasterThief.SavedVarsOptions.MasterThiefActive = value MasterThief:SetEvents() end,
          width = "full",
    	},
    	[3] = {
          type = "checkbox",
          name = GetString(MT_SNEAK_MODE_NAME),
          tooltip = GetString(MT_SNEAK_MODE_TEXT),
          getFunc = function() return MasterThief.SavedVarsOptions.SneakModeActive end,
          setFunc = function(value) MasterThief.SavedVarsOptions.SneakModeActive = value bInSneak=value MasterThief:SetEvents() end,
          width = "full",
    	},	
    	[4] = {
          type = "checkbox",
          name = GetString(MT_SHOW_MESSAGEBOX_NAME),
          tooltip = GetString(MT_SHOW_MESSAGEBOX_TEXT),
          getFunc = function() return MasterThief.SavedVarsOptions.MoveMsgbox end,
          setFunc = function(value) MasterThief.SavedVarsOptions.MoveMsgbox = value ctlMasterThiefLabel:SetText("MasterThief") MasterThief:ShowMsgBox(value) end,
          width = "full",
    	},
    	[5] = {
          type = "slider",
		  min = 1000,
		  max = 10000,		  
          name = GetString(MT_MESSAGE_DELAY_NAME),
          tooltip = GetString(MT_MESSAGE_DELAY_TEXT),
          getFunc = function() return MasterThief.SavedVarsOptions.MessageBoxDelay end,
          setFunc = function(value) MasterThief.SavedVarsOptions.MessageBoxDelay = value end,
          width = "full",
    	},		
    	[6] = {
          type = "slider",
		  min = 0,
		  max = 20,				  
          name = GetString(MT_FREE_SLOTS_LEFT_LIMIT_NAME),
          tooltip = GetString(MT_FREE_SLOTS_LEFT_LIMIT_TEXT),
          getFunc = function() return MasterThief.SavedVarsOptions.MinFreeSlots  end,
          setFunc = function(value) MasterThief.SavedVarsOptions.MinFreeSlots = value end,
          width = "full",
    	},
    	[7] = {
          type = "slider",
		  min = 0,
		  max = 1000,	
          name = GetString(MT_MIN_SELL_PRICE_AUTOLOOT_NAME),
          tooltip = GetString(MT_MIN_SELL_PRICE_AUTOLOOT_TEXT),
          getFunc = function() return MasterThief.SavedVarsOptions.MinSellPrice  end,
          setFunc = function(value) MasterThief.SavedVarsOptions.MinSellPrice = value end,
          width = "full",
    	},
		[8] = {
			type = "dropdown",
			name = GetString(MT_RECIPE_QUALITY_NAME),
			tooltip = GetString(MT_RECIPE_QUALITY_TEXT),
			choices = MasterThief.RecipeQualities,
	        getFunc = function() return MasterThief:GetMinRecipeQuality(MasterThief.SavedVarsOptions.MinRecipeQuality) end,
			setFunc = function(value) MasterThief:SetMinRecipeQuality(value) end,
			width = "full",
		},
    	[9] = {
          type = "checkbox",
          name = GetString(MT_LOOT_UNKNOWN_RECIPES_NAME),
          tooltip = GetString(MT_LOOT_UNKNOWN_RECIPES_TEXT),
          getFunc = function() return MasterThief.SavedVarsOptions.LootUnknownRecipesBelowLevel end,
          setFunc = function(value) MasterThief.SavedVarsOptions.LootUnknownRecipesBelowLevel = value end,
          width = "full",
    	},		
    	[10] = {
          type = "checkbox",
          name = GetString(MT_EXCLUDE_COMPARE_NAME),
          tooltip = GetString(MT_EXCLUDE_COMPARE_TEXT),
          getFunc = function() return MasterThief.SavedVarsOptions.compareMyRecipes end,
          setFunc = function(value) MasterThief.SavedVarsOptions.compareMyRecipes = value if (value) then MasterThief:SaveKnownRecipes(nil, false) else MasterThief:SaveKnownRecipes(nil, false) end end,
          width = "full",
    	},
    	[11] = {
          type = "checkbox",
          name = GetString(MT_AUTOLOOT_FROM_LOOTLIST_NAME),
          tooltip = GetString(MT_AUTOLOOT_FROM_LOOTLIST_TEXT),
          getFunc = function() return MasterThief.SavedVarsOptions.lootlist end,
          setFunc = function(value) MasterThief.SavedVarsOptions.lootlist = value end,
          width = "full",
    	},		
    	[12] = {
			type = "submenu",
			name = GetString(MT_SUB_ANNOUNCE_NAME),
			tooltip = GetString(MT_SUB_ANNOUNCE_TEXT),	
			controls = {		
				[1] = {
				  type = "checkbox",
				  name = GetString(MT_SUB_ANNOUNCE_ONSCREENMSG_NAME),
				  tooltip = GetString(MT_SUB_ANNOUNCE_ONSCREENMSG_TEXT),
				  getFunc = function() return MasterThief.SavedVarsOptions.SpecialOnScreenMsg end,
				  setFunc = function(value) MasterThief.SavedVarsOptions.SpecialOnScreenMsg = value end,
				  width = "full",
				},
				[2] = {
				  type = "checkbox",
				  name = GetString(MT_SUB_ANNOUNCE_SPECIALS_NAME),
				  tooltip = GetString(MT_SUB_ANNOUNCE_SPECIALS_TEXT),
				  getFunc = function() return MasterThief.SavedVarsOptions.SpecialChatMsg  end,
				  setFunc = function(value) MasterThief.SavedVarsOptions.SpecialChatMsg = value end,
				  width = "full",
				},		
				[3] = {
				  type = "checkbox",
				  name = GetString(MT_SUB_ANNOUNCE_REGULAR_NAME),
				  tooltip = GetString(MT_SUB_ANNOUNCE_REGULAR_TEXT),
				  getFunc = function() return MasterThief.SavedVarsOptions.RegularChatMsg  end,
				  setFunc = function(value) MasterThief.SavedVarsOptions.RegularChatMsg = value end,
				  width = "full",
				},		
				[4] = {
				  type = "checkbox",
				  name = GetString(MT_SUB_ANNOUNCE_USELESS_NAME),
				  tooltip = GetString(MT_SUB_ANNOUNCE_USELESS_TEXT),
				  getFunc = function() return MasterThief.SavedVarsOptions.AnnounceUselessItem  end,
				  setFunc = function(value) MasterThief.SavedVarsOptions.AnnounceUselessItem = value end,
				  width = "full",
				},
				[5] = {
				  type = "checkbox",
				  name = GetString(MT_SUB_ANNOUNCE_BECAREFUL_NAME),
				  tooltip = GetString(MT_SUB_ANNOUNCE_BECAREFUL_TEXT),
				  getFunc = function() return MasterThief.SavedVarsOptions.AnnounceBeCareful  end,
				  setFunc = function(value) MasterThief.SavedVarsOptions.AnnounceBeCareful = value end,
				  width = "full",
				},
				[6] = {
				  type = "checkbox",
				  name = GetString(MT_SUB_ANNOUNCE_KNOWN_RECIPES_NAME),
				  tooltip = GetString(MT_SUB_ANNOUNCE_KNOWN_RECIPES_TEXT),
				  getFunc = function() return MasterThief.SavedVarsOptions.AnnounceKnownRecipes  end,
				  setFunc = function(value) MasterThief.SavedVarsOptions.AnnounceKnownRecipes = value end,
				  width = "full",
				},
				[7] = {
				  type = "checkbox",
				  name = GetString(MT_SUB_ANNOUNCE_SELLS_TRANSFERS_NAME),
				  tooltip = GetString(MT_SUB_ANNOUNCE_SELLS_TRANSFERS_TEXT),
				  getFunc = function() return MasterThief.SavedVarsOptions.AnnounceSellsTransfers  end,
				  setFunc = function(value) MasterThief.SavedVarsOptions.AnnounceSellsTransfers = value end,
				  width = "full",
				},
				[8] = {
				  type = "checkbox",
				  name = GetString(MT_SUB_ANNOUNCE_MAX_FENCER_LIMITS_NAME),
				  tooltip = GetString(MT_SUB_ANNOUNCE_MAX_FENCER_LIMITS_TEXT),
				  getFunc = function() return MasterThief.SavedVarsOptions.AnnounceMaxFencerLimits  end,
				  setFunc = function(value) MasterThief.SavedVarsOptions.AnnounceMaxFencerLimits = value end,
				  width = "full",
				},				
			},
		},
	}
	LAM:RegisterOptionControls("MasterThiefOptions", optionsData)
end