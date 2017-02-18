ZO_CreateStringId("SI_BINDING_NAME_THIEFSKNAPSACK_TOGGLE", "Toggle Window")
ZO_CreateStringId("SI_BINDING_NAME_THIEFSKNAPSACK_LOCK_TOGGLE", "Toggle Lock")
ZO_CreateStringId("SI_BINDING_NAME_THIEFSKNAPSACK_METER_TOGGLE", "Toggle Meter")

local TK = ThiefsKnapsackExtended
local LAM = LibStub("LibAddonMenu-2.0")

local util = LibStub("util.rpav-1")
local prnd = util.prnd
local str = util.str

local function tex(name, color)
   if(color) then
      return str("|c", color, "|t16:16:", name, ":inheritColor|t|r")
   else
      return str("|t16:16:", name, "|t")
   end
end

local panel = {
   type = "panel",
   name = GetString(SI_TK_NAME),
   displayName = "|cFFD700"..GetString(SI_TK_NAME).."|r",
   author = "|cec33ffElmseeker|r",
   version = "|cFFD7002.6.2.5|r",
   website = "http://www.esoui.com/portal.php?&uid=28137",
   slashCommand = "/tko",
   registerForRefresh = true,
}

local anchors = {
   "Center",
   "Left",
   "Right",
}

local anchor_to_text = {
   [TOPLEFT] = "Left",
   [TOPRIGHT] = "Right",
   [TOP] = "Center",
}

local text_to_anchor = {
   ["Left"] = TOPLEFT,
   ["Right"] = TOPRIGHT,
   ["Center"] = TOP,
}

local options = {
   { type = "button",
     name = GetString(SI_TK_DON_AND_FB),
	 tooltip = GetString(SI_TK_DON_AND_FB),
	 func = function() TKDonateWindow:SetDrawTier(DT_HIGH)
	 TKDonateWindow:SetDrawLayer(DL_OVERLAY)
	 TKDonateWindow:SetHidden(false)
	 end,
   },
{ type = "submenu",
     name = "|cFFD700"..GetString(SI_TK_FIELDS).."|r",
	 tooltip = GetString(SI_TK_FIELDS_TT),
     controls = {

   { type = "checkbox",
     name = str(tex("/esoui/art/currency/currency_gold.dds"), GetString(SI_TK_GOLD_VALUE_NAME)),
     tooltip = GetString(SI_TK_GOLD_VALUE),
     getFunc = function() return TK.saved.show.Value end,
     setFunc = function(x)
        TK.saved.show.Value = x
        TK:UpdateControls()
     end,
   },
   { type = "checkbox",
     name = str(tex("/esoui/art/inventory/inventory_stolenitem_icon.dds"), GetString(SI_TK_SCOUNT_NAME)),
     tooltip = GetString(SI_TK_SCOUNT),
     getFunc = function() return TK.saved.show.Count end,
     setFunc = function(x)
        TK.saved.show.Count = x
        TK:UpdateControls()
     end,
   },
   { type = "checkbox",
     name = str(tex("/esoui/art/icons/quest_book_001.dds"),
                GetString(SI_TK_RMCOUNT_NAME)),
     tooltip = GetString(SI_TK_RMCOUNT),
     getFunc = function() return TK.saved.show.Recipes end,
     setFunc = function(x)
        TK.saved.show.Recipes = x
        TK:UpdateControls()
     end,
   },
   { type = "checkbox",
     name = str(tex("/esoui/art/icons/mapkey/mapkey_fence.dds", "00FF00"),
                GetString(SI_TK_LDXP_NAME)),
     tooltip = GetString(SI_TK_LDXP),
     getFunc = function() return TK.saved.show.Legerdemain end,
     setFunc = function(x)
        TK.saved.show.Legerdemain = x
        TK:UpdateControls()
     end,
   },
   { type = "checkbox",
     name = str(tex("/esoui/art/vendor/vendor_tabicon_sell_up.dds"),
                GetString(SI_TK_SELLS_NAME)),
     tooltip = GetString(SI_TK_SELLS),
     getFunc = function() return TK.saved.show.SellsLeft end,
     setFunc = function(x)
        TK.saved.show.SellsLeft = x
        TK:UpdateControls()
     end,
   },
   { type = "checkbox",
     name = GetString(SI_TK_LAUNDERS_NAME),
     tooltip = GetString(SI_TK_LAUNDERS),
     disabled = function() return not TK.saved.show.SellsLeft end,
     getFunc = function() return TK.saved.show.LaundersLeft end,
     setFunc = function(x)
        TK.saved.show.LaundersLeft = x
        TK:UpdateDisplay()
     end,
   },
   
   { type = "checkbox",
     name = str(tex("/esoui/art/miscellaneous/gamepad/gp_icon_timer32.dds"), GetString(SI_TK_FRESET_NAME)),
     tooltip = GetString(SI_TK_FRESET),
     getFunc = function() return TK.saved.show.FenceTimer end,
     setFunc = function(x)
        TK.saved.show.FenceTimer = x
        TK:UpdateControls()
     end,
   },
   { type = "checkbox",
     name = str(tex("/esoui/art/miscellaneous/gamepad/gp_icon_timer32.dds", "FF0000"),
                GetString(SI_TK_BCLOCK_NAME)),
     tooltip = GetString(SI_TK_BCLOCK),
     getFunc = function() return TK.saved.show.BountyTimer end,
     setFunc = function(x)
        TK.saved.show.BountyTimer = x
        TK:UpdateControls()
     end,
   },

   { type = "checkbox",
     name = str(tex("/esoui/art/currency/currency_gold.dds", "FF0000"),
                GetString(SI_TK_SBOUNTY_NAME)),
     tooltip = GetString(SI_TK_SBOUNTY),
     getFunc = function() return TK.saved.show.Bounty end,
     setFunc = function(x)
        TK.saved.show.Bounty = x
        TK:UpdateControls()
     end,
   },
   { type = "checkbox",
     name = str(tex("/esoui/art/vendor/vendor_tabicon_fence_up.dds"),
                GetString(SI_TK_SAVALUE_NAME)),
     tooltip = GetString(SI_TK_SAVALUE),
     getFunc = function() return TK.saved.show.Average end,
     setFunc = function(x)
        TK.saved.show.Average = x
        TK:UpdateControls()
     end,
   },
   { type = "checkbox",
     name = str(tex("/esoui/art/vendor/vendor_tabicon_fence_up.dds", "EECA00"),
                GetString(SI_TK_EDP_NAME)),
     tooltip = GetString(SI_TK_EDP),
     getFunc = function() return TK.saved.show.Estimate end,
     setFunc = function(x)
        TK.saved.show.Estimate = x
        TK:UpdateControls()
     end,
   },
   { type = "checkbox",
     name = str(tex("/esoui/art/crafting/smithing_tabicon_improve_up.dds"),
                GetString(SI_TK_SAQ_NAME)),
     tooltip = GetString(SI_TK_SAQ),
     getFunc = function() return TK.saved.show.Quality end,
     setFunc = function(x)
        TK.saved.show.Quality = x
        TK:UpdateControls()
     end,
   },
   { type = "checkbox",
     name = GetString(SI_TK_DQG_NAME),
     tooltip = GetString(SI_TK_DQG),
     getFunc = function() return TK.saved.showBars end,
     setFunc = function(x)
        TK.saved.showBars = x
        TK:UpdateControls()
     end,
   },
   { type = "checkbox",
     name = GetString(SI_TK_TEXT_LABEL_NAME),
     tooltip = GetString(SI_TK_TEXT_LABEL),
     getFunc = function() return TK.saved.options.textLabel end,
     setFunc = function(x)
        TK.saved.options.textLabel = x
		TK.saved.compactMode = x
        TK:UpdateDisplay()
     end,
	 warning = "|cff0000"..GetString(SI_TK_TL_WARNING.."|r"),
   },
 },
},

{ type = "submenu",
     name = "|cFFD700"..GetString(SI_TK_OPTIONS_NAME).."|r",
	 tooltip = GetString(SI_TK_OPTIONS_TT),
     controls = {

   { type = "checkbox",
     name = GetString(SI_TK_DBT_NAME),
     tooltip = GetString(SI_TK_DBT),
     getFunc = function() return TK.saved.dshow.Bounty end,
     setFunc = function(x)
        TK.saved.dshow.Bounty = x
        TK.saved.dshow.BountyTimer = x
        if(x) then
           TK:DynamicBountyCheck()
        else
           TK:UpdateControls()
        end
     end,
   },
   { type = "checkbox",
     name = GetString(SI_TK_WELCOME_NAME),
     tooltip = GetString(SI_TK_WELCOME_MSG),
     getFunc = function() return TK.saved.show.chatMessage end,
     setFunc = function(x)
        TK.saved.show.chatMessage = x
        TK:UpdateDisplay()
     end,
   },
        { type = "checkbox",
          name = GetString(SI_TK_LOCK_NAME),
          tooltip = GetString(SI_TK_LOCK),
          getFunc = function() return TK.saved.locked end,
          setFunc = function(x)
             TK.saved.locked = x
             TK:lockWindow()
          end,
        },
        { type = "checkbox",
          name = GetString(SI_TK_AUTO_LOCK_NAME),
          tooltip = GetString(SI_TK_AUTO_LOCK),
          getFunc = function() return TK.saved.autoLock end,
          setFunc = function(x)
             TK.saved.autoLock = x
             TK:SavePosition()
          end,
        },
	},
},
{ type = "submenu",
     name = "|cFFD700"..GetString(SI_TK_FILTERS_NAME).."|r",
	 tooltip = GetString(SI_TK_FILTERS_TT),
     controls = {
   { type = "checkbox",
     name = GetString(SI_TK_SEPRAM_NAME),
     tooltip = GetString(SI_TK_SEPRAM),
     getFunc = function() return TK.saved.options.sep_recipe end,
     setFunc = function(x)
        TK.saved.options.sep_recipe = x
        TK:CalcBagGoods()
        TK:UpdateDisplay()
     end,
   },
   { type = "checkbox",
     name = GetString(SI_TK_SEPGEAR_NAME),
     tooltip = GetString(SI_TK_SEPGEAR),
     getFunc = function() return TK.saved.options.sep_gear end,
     setFunc = function(x)
        TK.saved.options.sep_gear = x
        TK:CalcBagGoods()
        TK:UpdateDisplay()
     end,
	},
   { type = "checkbox",
     name = GetString(SI_TK_DCJ_NAME),
     tooltip = GetString(SI_TK_DCJ),
     getFunc = function() return TK.saved.options.nojunk end,
     setFunc = function(x)
        TK.saved.options.nojunk = x
        TK:CalcBagGoods()
        TK:UpdateDisplay()
     end,
   },
  },
},

   { type = "submenu",
     name = "|cFFD700"..GetString(SI_TK_DISPLAY_NAME).."|r",
	 tooltip = GetString(SI_TK_DISPLAY_TT),
     controls = {
        { type = "slider",
          name = GetString(SI_TK_SCALE_NAME),
		  tooltip = GetString(SI_TK_SCALE_NAME),
          min = 75,
          max = 200,
          step = 1,
          getFunc = function() return TK.saved.scale*100 end,
          setFunc = function(x)
             TK.saved.scale = x/100
             TK.window:SetScale(1)
             TK:UpdateControls()
             TK.window:SetScale(x/100)
          end,
		  requiresReload = true,
        },
        { type = "checkbox",
          name = GetString(SI_TK_COMPACT_NAME),
          tooltip = GetString(SI_TK_COMPACT),
          getFunc = function() return TK.saved.compactMode end,
          setFunc = function(x)
             TK.saved.compactMode = x
             TK:UpdateControls()
          end,
		  requiresReload = true,
        },
        { type = "checkbox",
          name = GetString(SI_TK_SBG_NAME),
          tooltip = GetString(SI_TK_SBG),
          getFunc = function() return TK.saved.show.Background end,
          setFunc = function(x)
             TK.saved.show.Background = x
             TK:UpdateControls()
          end,
        },
        {  type = "checkbox",
           name = GetString(SI_TK_HIDE_IN_MENUS_NAME),
           tooltip = GetString(SI_TK_HIDE_IN_MENUS),
           getFunc = function() return TK.saved.options.hide_on_menu end,
           setFunc = function(x)
              TK.saved.options.hide_on_menu = x
			  TK.window:SetHidden(x)
           end
        },
        { type = "dropdown",
          name = GetString(SI_TK_ALIGN_NAME),
          tooltip = GetString(SI_TK_ALIGN),
          choices = anchors,
          getFunc = function() return TK.saved.anchor end,
          setFunc = function(x)
             TK.saved.anchor = text_to_anchor[x]
             TK:ReAnchor()
             TK:SavePosition()
          end,
        },
        { type = "checkbox",
          name = GetString(SI_TK_SNAP_CENTER_NAME),
          tooltip = GetString(SI_TK_SNAP_CENTER),
          getFunc = function() return TK.saved.snapCenter end,
          setFunc = function(x)
             TK.saved.snapCenter = x
             TK:SavePosition()
          end,
        },
        { type = "checkbox",
          name = GetString(SI_TK_HIDE_METER_NAME),
          tooltip = GetString(SI_TK_HIDE_METER),
          getFunc = function() return TK.saved.hideMeter end,
          setFunc = function(x)
             TK.saved.hideMeter = x
             TK:SavePosition()
          end,
        },
     },
   },
}

function TK:RegisterSettings()
   LAM:RegisterAddonPanel("ThiefsKnapsackOptions", panel)
   LAM:RegisterOptionControls("ThiefsKnapsackOptions", options)
end
