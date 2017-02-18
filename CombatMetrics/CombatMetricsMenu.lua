if CMX == nil then CMX = {} end
local CMX = CMX
local _
--
-- Register with LibMenu and ESO

function CMX.MakeMenu()
    -- load the settings->addons menu library
	local menu = LibStub("LibAddonMenu-2.0")
	local db = CMX.db
	local def = CMX.defaults 

    -- the panel for the addons menu
	local panel = {
		type = "panel",
		name = "Combat Metrics",
		displayName = "Combat Metrics",
		author = "Solinur",
        version = "" .. CMX.version,
		registerForRefresh = true,
	}

    --this adds entries in the addon menu
	local options = {
		{
			type = "header",
			name = GetString(SI_COMBAT_METRICS_MENU_PROFILES)
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_AC_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_AC_TOOLTIP),
			default = def.accountwide,
			getFunc = function() return CombatMetrics_Save.Default[GetDisplayName()]['$AccountWide']["accountwide"] end,
			setFunc = function(value) CombatMetrics_Save.Default[GetDisplayName()]['$AccountWide']["accountwide"] = value end,
			requiresReload = true,
		},		
		{
			type = "custom",
		},
		{
			type = "header",
			name = GetString(SI_COMBAT_METRICS_MENU_GS_NAME)
		},
		{
			type = "slider",
			name = GetString(SI_COMBAT_METRICS_MENU_CT_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_CT_TOOLTIP),
			min = 0,
			max = 20,
			step = 1,
			default = def.timeout,
			getFunc = function() return db.timeout/1000 end,
			setFunc = function(value) db.timeout = value*1000	end,
		},
		{
			type = "slider",
			name = GetString(SI_COMBAT_METRICS_MENU_FH_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_FH_TOOLTIP),
			min = 1,
			max = 25,
			step = 1,
			default = def.fighthistory,
			getFunc = function() return db.fighthistory end,
			setFunc = function(value) db.fighthistory = value end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_UH_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_UH_TOOLTIP),
			default = def.timeheals,
			getFunc = function() return db.timeheals end,
			setFunc = function(value) db.timeheals = value	end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_MG_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_MG_TOOLTIP),
			default = def.recordgrp,
			getFunc = function() return db.recordgrp end,
			setFunc = function(value) db.recordgrp = value CMX.UI:ControlLR() end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_GL_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_GL_TOOLTIP),
			default = def.recordgrpinlarge,
			getFunc = function() return db.recordgrpinlarge end,
			setFunc = function(value) db.recordgrpinlarge = value end,
			disabled = not db.recordgrp,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_LM_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_LM_TOOLTIP),
			default = def.lightmode,
			getFunc = function() return db.lightmode end,
			setFunc = function(value) db.lightmode = value	end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_NOPVP_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_NOPVP_TOOLTIP),
			default = def.offincyrodil,
			getFunc = function() return db.offincyrodil end,
			setFunc = function(value) 
				db.offincyrodil = value 
				CMX.onZoneChange()  -- check if in Cyrodil and apply change if neccessary
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_LMPVP_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_LMPVP_TOOLTIP),
			default = def.lightmodeincyrodil,
			getFunc = function() return db.lightmodeincyrodil end,
			setFunc = function(value) db.lightmodeincyrodil = value end,
			disabled = function() return (db.offincyrodil or db.lightmode) end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_ASCC_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_ASCC_TOOLTIP),
			default = def.autoselectchatchannel,
			getFunc = function() return db.autoselectchatchannel end,
			setFunc = function(value) db.autoselectchatchannel = value end,
		},	
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_AS_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_AS_TOOLTIP),
			default = def.autoscreenshot,
			getFunc = function() return db.autoscreenshot end,
			setFunc = function(value) db.autoscreenshot = value end,
		},		
		{
			type = "slider",
			name = GetString(SI_COMBAT_METRICS_MENU_ML_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_ML_TOOLTIP),
			min = 1,
			max = 120,
			step = 1,
			disabled = function() return (not db.autoscreenshot) end,
			default = def.autoscreenshotmintime,
			getFunc = function() return db.autoscreenshotmintime end,
			setFunc = function(value) db.autoscreenshotmintime = value end,
		},
		{
			type = "slider",
			name = GetString(SI_COMBAT_METRICS_MENU_SF_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_SF_TOOLTIP),
			min = 30,
			max = (math.ceil(GuiRoot:GetHeight()/75)*10) or 200,
			step = 10,
			default = def.UI.ReportScale,
			getFunc = function() return db.UI.ReportScale*100  end,
			setFunc = function(value) 
					db.UI.ReportScale = value/100 
					CMX.UI:ControlRW() 	
				end,
		},
		{
			type = "custom",
		},
		{
			type = "header",
			name = GetString(SI_COMBAT_METRICS_MENU_LR_NAME),
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_ENABLE_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_ENABLE_TOOLTIP),
			default = def.EnableLiveMonitor,
			getFunc = function() return db.EnableLiveMonitor end,
			setFunc = function(value) CMX.UI:ToggleLR(value) db.EnableLiveMonitor = value end,
		},
		{
			type = "dropdown",
			name = GetString(SI_COMBAT_METRICS_MENU_LAYOUT_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_LAYOUT_TOOLTIP),
			default = def.UI.CMX_LiveReportSettings.layout,
			choices = {"Compact", "Horizontal", "Vertical"},
			getFunc = function() return db.UI.CMX_LiveReportSettings.layout end,
			setFunc = function(value) db.UI.CMX_LiveReportSettings.layout = value CMX.UI:RefreshLRWindow() end,
			disabled = function() return not db.EnableLiveMonitor end,
		},
		{
			type = "slider",
			name = GetString(SI_COMBAT_METRICS_MENU_SCALE_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_SCALE_TOOLTIP),
			min = 30,
			max = 300,
			step = 10,
			default = def.UI.CMX_LiveReportSettings.scale,
			getFunc = function() return db.UI.CMX_LiveReportSettings.scale*100  end,
			setFunc = function(value) 
					db.UI.CMX_LiveReportSettings.scale = value/100 
					CMX.UI:ControlLR() 
				end,
			disabled = function() return not db.EnableLiveMonitor end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_SHOW_BG_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_SHOW_BG_TOOLTIP),
			default = def.UI.CMX_LiveReportSettings.bg,
			getFunc = function() return db.UI.CMX_LiveReportSettings.bg end,
			setFunc = function(value) db.UI.CMX_LiveReportSettings.bg = value CMX_LiveReport_BG:SetHidden(not value) end,
			disabled = function() return not db.EnableLiveMonitor end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_SHOW_DPS_NAME),
			width = "half",
			tooltip = GetString(SI_COMBAT_METRICS_MENU_SHOW_DPS_TOOLTIP),
			default = def.UI.CMX_LiveReportSettings.dps,
			getFunc = function() return db.UI.CMX_LiveReportSettings.dps end,
			setFunc = function(value) db.UI.CMX_LiveReportSettings.dps = value CMX.UI:RefreshLRWindow() end,
			disabled = function() return not db.EnableLiveMonitor end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_SHOW_HPS_NAME),
			width = "half",
			tooltip = GetString(SI_COMBAT_METRICS_MENU_SHOW_HPS_TOOLTIP),
			default = def.UI.CMX_LiveReportSettings.hps,
			getFunc = function() return db.UI.CMX_LiveReportSettings.hps end,
			setFunc = function(value) db.UI.CMX_LiveReportSettings.hps = value CMX.UI:RefreshLRWindow() end,
			disabled = function() return not db.EnableLiveMonitor end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_SHOW_INC_DPS_NAME),
			width = "half",
			tooltip = GetString(SI_COMBAT_METRICS_MENU_SHOW_INC_DPS_TOOLTIP),
			default = def.UI.CMX_LiveReportSettings.idps,
			getFunc = function() return db.UI.CMX_LiveReportSettings.idps end,
			setFunc = function(value) db.UI.CMX_LiveReportSettings.idps = value CMX.UI:RefreshLRWindow() end,
			disabled = function() return not db.EnableLiveMonitor end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_SHOW_INC_HPS_NAME),
			width = "half",
			tooltip = GetString(SI_COMBAT_METRICS_MENU_SHOW_INC_HPS_TOOLTIP),
			default = def.UI.CMX_LiveReportSettings.ihps,
			getFunc = function() return db.UI.CMX_LiveReportSettings.ihps end,
			setFunc = function(value) db.UI.CMX_LiveReportSettings.ihps = value CMX.UI:RefreshLRWindow() end,
			disabled = function() return not db.EnableLiveMonitor end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_SHOW_TIME_NAME),
			width = "half",
			tooltip = GetString(SI_COMBAT_METRICS_MENU_SHOW_TIME_TOOLTIP),
			default = def.UI.CMX_LiveReportSettings.time,
			getFunc = function() return db.UI.CMX_LiveReportSettings.time end,
			setFunc = function(value) db.UI.CMX_LiveReportSettings.time = value CMX.UI:RefreshLRWindow() end,
			disabled = function() return not db.EnableLiveMonitor end,
		},
		{
			type = "custom",
			width = "half",
			
		},
		{
			type = "custom",
		},
		{
			type = "header",
			name = GetString(SI_COMBAT_METRICS_MENU_CHAT_TITLE),
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_ENABLE_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_CHAT_DH_TOOLTIP),
			default = def.EnableChatLog,
			getFunc = function() return db.EnableChatLog end,
			setFunc = function(value) if value then CMX.getCombatLog() end db.EnableChatLog = value end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_CHAT_SD_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_CHAT_SD_TOOLTIP),
			default = def.EnableChatLogDmgOut,
			getFunc = function() return db.EnableChatLogDmgOut end,
			setFunc = function(value) db.EnableChatLogDmgOut = value end,
			disabled = function() return not db.EnableChatLog end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_CHAT_SH_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_CHAT_SH_TOOLTIP),
			default = def.EnableChatLogHealOut,
			getFunc = function() return db.EnableChatLogHealOut end,
			setFunc = function(value) db.EnableChatLogHealOut = value end,
			disabled = function() return not db.EnableChatLog end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_CHAT_SID_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_CHAT_SID_TOOLTIP),
			default = def.EnableChatLogDmgIn,
			getFunc = function() return db.EnableChatLogDmgIn end,
			setFunc = function(value) db.EnableChatLogDmgIn = value end,
			disabled = function() return not db.EnableChatLog end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_CHAT_SIH_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_CHAT_SIH_TOOLTIP),
			default = def.EnableChatLogHealIn,
			getFunc = function() return db.EnableChatLogHealIn end,
			setFunc = function(value) db.EnableChatLogHealIn = value end,
			disabled = function() return not db.EnableChatLog end,
		},
		{
			type = "custom",
		},
		{
			type = "header",
			name = GetString(SI_COMBAT_METRICS_MENU_DEBUG_TITLE),
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_DEBUG_SF_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_DEBUG_SF_TOOLTIP),
			default = def.debuginfo.fightsummary,
			getFunc = function() return db.debuginfo.fightsummary end,
			setFunc = function(value) db.debuginfo.fightsummary = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_DEBUG_SA_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_DEBUG_SA_TOOLTIP),
			default = def.debuginfo.ids,
			getFunc = function() return db.debuginfo.ids end,
			setFunc = function(value) db.debuginfo.ids = value	end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_DEBUG_SFC_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_DEBUG_SFC_TOOLTIP),
			default = def.debuginfo.calculationtime,
			getFunc = function() return db.debuginfo.calculationtime end,
			setFunc = function(value) db.debuginfo.calculationtime = value	end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_DEBUG_BI_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_DEBUG_BI_TOOLTIP),
			default = def.debuginfo.buffs,
			getFunc = function() return db.debuginfo.buffs end,
			setFunc = function(value) db.debuginfo.buffs = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_DEBUG_US_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_DEBUG_US_TOOLTIP),
			default = def.debuginfo.skills,
			getFunc = function() return db.debuginfo.skills end,
			setFunc = function(value) db.debuginfo.skills = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_DEBUG_SG_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_DEBUG_SG_TOOLTIP),
			default = def.debuginfo.group,
			getFunc = function() return db.debuginfo.group end,
			setFunc = function(value) db.debuginfo.group = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_DEBUG_MD_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_DEBUG_MD_TOOLTIP),
			default = def.debuginfo.misc,
			getFunc = function() return db.debuginfo.misc end,
			setFunc = function(value) db.debuginfo.misc = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_DEBUG_SPECIAL_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_DEBUG_SPECIAL_TOOLTIP),
			default = def.debuginfo.special,
			getFunc = function() return db.debuginfo.special end,
			setFunc = function(value) db.debuginfo.special = value end,
			width = "half",
		},
	}

	menu:RegisterAddonPanel("CMX_Options", panel)
	menu:RegisterOptionControls("CMX_Options", options)
end