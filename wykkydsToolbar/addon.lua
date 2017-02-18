--[[
  * Ravalox' Wykkyd [ Toolbar ]
  * Sponsored & Supported by: The Prydonian Elders
  * Author: Ravalox Darkshire (support@ecgroup.us) & Calia1120
  * Embedded: LibStub & libAddonMenu by Seerah.
  * Special Thanks To: Zenimax Online Studios & Bethesda for The Elder Scrolls Online
]]--

local _addon = {}
_addon._v = {}
_addon._v.major		= 2
_addon._v.monthly 	= 7
_addon._v.daily 	= 0
_addon._v.minor 	= 0
_addon.Version 	= _addon._v.major
	..".".._addon._v.monthly
	..".".._addon._v.daily
	..".".._addon._v.minor
_addon.Name			= "wykkydsToolbar"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Wykkyd Toolbar"
_addon.SavedVariableVersion = 3
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = {
	["player_name_enabled"] = false,
	["clock_suffix"] = false,
	["bag_setting"] = "Used / Total",
	["weaponcharge_icon"] = true,
	["player_class_enabled"] = false,
	["zone_enabled"] = true,
	["weaponcharge_enabled"] = true,
	["rt_smithing"] = false,
	["clock_title"] = false,
	["ap_setting"] = false,
	["enable_background"] = false,
	["rt_clothing"] = false,
	["xpvp_enabled"] = "Earned %",
	["creature_xp_bar_enabled"] = false,
	["ShiftX"] = 0,
	["soulgem_setting"] = "Empty / Full",
	["level_enabled"] = true,
	["lock_in_place"] = false,
	["horse_setting"] = "Countdown",
	["horse_trainFull"] = true,
	["timerGroup"] = true,
	["lock_horizontal"] = true,
	["gold_setting"] = true,
	["xp_bar_enabled"] = true,
	["player_race_enabled"] = false,
	["bump_compass"] = true,
	["horse_icon"] = true,
	["rt_wood"] = false,
	["fps_enabled"] = true,
	["latency_enabled"] = true,
	["durability_enabled"] = true,
	["clock_type"] = "12 hour",
}

_addon.Feature = {}
_addon.Feature.Toolbar = {}

_addon.LoadSavedVariables = function( self )
	local setDefault = function( parm, default ) if _addon.Settings[ parm ] == nil then _addon.Settings[ parm ] = default end end

	setDefault( "bag_setting", "Used / Total" )
	setDefault( "fps_enabled", true )
	setDefault( "latency_enabled", true )
	setDefault( "clock_type", "12 hour" )
	setDefault( "gold_setting", true )
	setDefault( "xpvp_enabled", "Needed %" )
	setDefault( "zone_enabled", true )
	setDefault( "ap_setting", true )
	setDefault( "xp_bar_enabled", false )
	setDefault( "player_name_enabled", false )
	setDefault( "player_race_enabled", false )
	setDefault( "player_class_enabled", false )
	setDefault( "level_enabled", false )
	setDefault( "soulgem_setting", "Empty / Full" )
	setDefault( "horse_setting", "Countdown" )
	setDefault( "horse_trainFull", true )
	setDefault( "creature_xp_bar_enabled", false )
	setDefault( "durability_enabled", false )
	setDefault( "weaponcharge_enabled", false )
	setDefault( "rt_wood", false )
	setDefault( "rt_smithing", false )
	setDefault( "rt_clothing", false )
	setDefault( "timerGroup", false )
end

_addon.LoadSettingsMenu = function( self )
	local panelData = {
		type = "panel",
		name = _addon.DisplayName,
		displayName = "|cFF2222".._addon.DisplayName.."|r",
		author = "Exodus Code Group",
		version = self.Version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local optionsTable = {
		[1] = {
			type = "description",
			text = "Welcome to the Wykkyd Toolbar, orginally adapted from Bazgrim's pre-launch toolbar. This addon will be receiving many enhancements, if there's a feature you don't see that you want, please message us on ESOUI.com!",
		},
		[2] = self:MakeStandardOption( self.Settings, "Tool Alignment", "align_tools", "CENTER", "dropdown", { choices={"LEFT","CENTER","RIGHT"},default="CENTER", } ),
		[3] = self:MakeStandardOption( self.Settings, "Lock Toolbar In Place", "lock_in_place", false, "checkbox", { default=false, } ),
		[4] = self:MakeStandardOption( self.Settings, "Lock Horizontal Center", "lock_horizontal", true, "checkbox", { default=true, } ),
		[5] = self:MakeStandardOption( self.Settings, "Bump Compass Down", "bump_compass", true, "checkbox", { tooltip="Only bumps the compass if locked to center AND if top of frame is at the top of screen", default=true, } ),
		[6] = self:MakeStandardOption( self.Settings, "Enable Background", "enable_background", false, "checkbox", { default=false, } ),
		[7] = self:MakeStandardOption( self.Settings, "Toolbar Scale", "scale", 100, "slider", { min=50, max=150, step=1, default=100, } ),
		[8] = { type = "submenu", name = "|cCAB222".."Clock".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Time Setting", "clock_type", "12 hour", "dropdown", { choices={"Off","24 hour","12 hour"},default="12 hour", } ),
				[2] = self:MakeStandardOption( self.Settings, "Show Title", "clock_title", false, "checkbox", { width="half",default=false, } ),
				[3] = self:MakeStandardOption( self.Settings, "Show AM/PM", "clock_suffix", true, "checkbox", { width="half",default=true, } ),
			},
		},
		[9] = { type = "submenu", name = "|cCAB222".."Frames Per Second (FPS)".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show FPS", "fps_enabled", true, "checkbox", { default=true, } ),
				[2] = self:MakeStandardOption( self.Settings, "Low Threshold", "fps_low", 15, "slider", { width="half",min=5, max=30, step=1, default=15, } ),
				[3] = self:MakeStandardOption( self.Settings, "Moderate Threshold", "fps_mid", 22, "slider", { width="half",min=20, max=60, step=1, default=22, } ),
			},
		},
		[10] = { type = "submenu", name = "|cCAB222".."Ping Rate (Latency) (PR)".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show PR", "latency_enabled", true, "checkbox", { default=true, } ),
				[2] = self:MakeStandardOption( self.Settings, "Bad Latency", "latency_high", 300, "slider", { width="half",min=100, max=1000, step=1, default=300, } ),
				[3] = self:MakeStandardOption( self.Settings, "Poor Latency", "latency_mid", 150, "slider", { width="half",min=50, max=400, step=1, default=150, } ),
			},
		},
		[11] = { type = "submenu", name = "|cCAB222".."Zone".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Zone", "zone_enabled", true, "checkbox", { default=true, } ),
				[2] = self:MakeStandardOption( self.Settings, "Show Title", "zone_title", false, "checkbox", { default=false, } ),
			},
		},
		[12] = { type = "submenu", name = "|cCAB222".."Character Name".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Name", "player_name_enabled", false, "checkbox", { default=false, } ),
			},
		},
		[13] = { type = "submenu", name = "|cCAB222".."Character Race".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Race", "player_race_enabled", false, "checkbox", { default=false, } ),
			},
		},
		[14] = { type = "submenu", name = "|cCAB222".."Character Class".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Class", "player_class_enabled", false, "checkbox", { default=false, } ),
			},
		},
		[15] = { type = "submenu", name = "|cCAB222".."Level".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Level", "level_enabled", true, "checkbox", { default=true, } ),
				[2] = self:MakeStandardOption( self.Settings, "Show Title", "level_title", false, "checkbox", { default=false, } ),
			},
		},
		[16] = { type = "submenu", name = "|cCAB222".."Experience Bar".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show XP Bar", "xp_bar_enabled", false, "checkbox", { default=false, } ),
			},
		},
		[17] = { type = "submenu", name = "|cCAB222".."XP/Champion Point Numbers".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show XP / CP", "xpvp_enabled", "Needed %", "dropdown", { choices={"Off","Earned / Total","Earned","Earned % / Total","Earned %","Needed","Needed %"},default="Needed %", } ),
				[2] = self:MakeStandardOption( self.Settings, "Show Title", "xpvp_title", false, "checkbox", { width="half",default=false, } ),
				[3] = self:MakeStandardOption( self.Settings, "Use Commas", "xpvp_commas", true, "checkbox", { width="half",default=true, } ),
			},
		},
		[18] = { type = "submenu", name = "|cCAB222".."Vampire / Werewolf XP Bar".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show 'Creature' XP Bar", "creature_xp_bar_enabled", false, "checkbox", { default=false, } ),
			},
		},
		[19] = { type = "submenu", name = "|cCAB222".."Horse Training Timer".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Training Timer", "horse_setting", "Countdown", "dropdown", { choices={"Off","Fancy","Descriptive","Countdown"},default="Countdown", } ),
				[2] = self:MakeStandardOption( self.Settings, "Hide Training Timer when all maxed", "horse_trainFull", false, "checkbox", {tooltip="This option will remove Horse Training from the bar once maxed out at 60/60/60.  If this option is not on then the timer will always show 60/60/60 when maxed.", default=false, } ),
				[3] = self:MakeStandardOption( self.Settings, "Show Horse Icon", "horse_icon", true, "checkbox", { default=true, } ),

			},
		},
		[20] = { type = "submenu", name = "|cCAB222".."Bag Space".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Bag Space Counter", "bag_setting", "Used %", "dropdown", { choices={"Off","Used / Total","Used Space","Used %","Free Space","Free %"},default="Used %", } ),
				[2] = self:MakeStandardOption( self.Settings, "Show Icon", "bag_icon", true, "checkbox", { width="half",default=true, } ),
				[3] = self:MakeStandardOption( self.Settings, "Show Title", "bag_title", false, "checkbox", { width="half",default=false, } ),
				[4] = self:MakeStandardOption( self.Settings, "Low Space Threshold", "bag_low", 10, "slider", { width="half",min=5, max=15, step=1, default=10, } ),
				[5] = self:MakeStandardOption( self.Settings, "Moderate Space Threshold", "bag_mid", 25, "slider", { width="half",min=10, max=35, step=1, default=25, } ),
			},
		},
		[21] = { type = "submenu", name = "|cCAB222".."Soul Gems".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Soul Gem Counter", "soulgem_setting", "Empty / Full", "dropdown", { choices={"Off","Empty / Full","Empty","Full"},default="Empty / Full", } ),
				[2] = self:MakeStandardOption( self.Settings, "Show Icon", "soulgem_icon", true, "checkbox", { default=true, } ),
			},
		},
		[22] = { type = "submenu", name = "|cCAB222".."Gold".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Gold Counter", "gold_setting", true, "checkbox", { default=true, } ),
				[2] = self:MakeStandardOption( self.Settings, "Show Icon", "gold_icon", true, "checkbox", { default=true, } ),
				[3] = self:MakeStandardOption( self.Settings, "Show Title", "gold_title", false, "checkbox", { default=false, } ),
				[4] = self:MakeStandardOption( self.Settings, "Use Commas", "gold_commas", true, "checkbox", { default=true, } ),
			},
		},
		[23] = { type = "submenu", name = "|cCAB222".."Alliance Points".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Alliance Point Counter", "ap_setting", true, "checkbox", { default=true, } ),
				[2] = self:MakeStandardOption( self.Settings, "Show Icon", "ap_icon", true, "checkbox", { default=true, } ),
				[3] = self:MakeStandardOption( self.Settings, "Show Title", "ap_title", false, "checkbox", { default=false, } ),
				[4] = self:MakeStandardOption( self.Settings, "Use Commas", "ap_commas", true, "checkbox", { default=true, } ),
			},
		},
		[24] = { type = "submenu", name = "|cCAB222".."Repair Cost".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Repair Cost", "durability_enabled", false, "checkbox", { default=false, } ),
				[2] = self:MakeStandardOption( self.Settings, "Show Icon", "durability_icon", true, "checkbox", { default=true, } ),
				[3] = self:MakeStandardOption( self.Settings, "Use Commas", "durability_commas", true, "checkbox", { default=true, } ),
			},
		},
		[25] = { type = "submenu", name = "|cCAB222".."Weapon Charge Bar(s)".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Weapon Charge Bar(s)", "weaponcharge_enabled", false, "checkbox", { default=false, } ),
				[2] = self:MakeStandardOption( self.Settings, "Show Icon", "weaponcharge_icon", true, "checkbox", { default=true, } ),
			},
		},
		[26] = { type = "submenu", name = "|cCAB222".."Research Timers".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, _addon.G.BAR_STR_SHOW_SMITH, "rt_smithing", false, "checkbox", { default=false, } ),
				[2] = self:MakeStandardOption( self.Settings, _addon.G.BAR_STR_SHOW_CLOTH, "rt_clothing", false, "checkbox", { default=false, } ),
				[3] = self:MakeStandardOption( self.Settings, _addon.G.BAR_STR_SHOW_WOOD, "rt_wood", false, "checkbox", { default=false, } ),
				[4] = self:MakeStandardOption( self.Settings, _addon.G.BAR_STR_CRAFT_ICON, "rt_icon", true, "checkbox", { default=true, } ),
				[5] = self:MakeStandardOption( self.Settings, _addon.G.BAR_STR_SHOW_CRAFT, "rt_timers", _addon.G.BAR_STR_COUNTDOWN, "dropdown", { choices={_addon.G.BAR_STR_OFF,_addon.G.BAR_STR_FANCY_STUDY,_addon.G.BAR_STR_DESCRIPTIVE,_addon.G.BAR_STR_PERCENTAGE_LEFT,_addon.G.BAR_STR_PERCENTAGE_DONE,_addon.G.BAR_STR_ADAPTIVE,_addon.G.BAR_STR_COUNTDOWN},default=_addon.G.BAR_STR_COUNTDOWN, } ),
				[6] = self:MakeStandardOption( self.Settings, _addon.G.BAR_STR_TIMER_TARGET, "rt_timer_type", _addon.G.BAR_STR_TIME_TO_NEXT_FREE, "dropdown", { choices={_addon.G.BAR_STR_TIME_TO_NEXT_FREE,_addon.G.BAR_STR_TIME_TO_ALL_FREE},default=_addon.G.BAR_STR_TIME_TO_NEXT_FREE, } ),
				[7] = self:MakeStandardOption( self.Settings, _addon.G.BAR_STR_SLOTS, "rt_slots", _addon.G.BAR_STR_OFF, "dropdown", { choices={_addon.G.BAR_STR_OFF,_addon.G.BAR_STR_SLOTS_TOTAL,_addon.G.BAR_STR_SLOTS_USED,_addon.G.BAR_STR_SLOTS_FREE,_addon.G.BAR_STR_SLOTS_USED_TOTAL,_addon.G.BAR_STR_SLOTS_FREE_TOTAL},default=_addon.G.BAR_STR_OFF, } ),
				[8] = self:MakeStandardOption( self.Settings, "Group all toolbar timers", "timerGroup", true, "checkbox", { tooltip="When set this option will move the Horse Training timer to group with the Research Timers.", warning="Reloads UI when changed", default=true, } ),
			},
		},
	}
	optionsTable[26].controls[8].setFunc = function( val )
		self.Settings[ "timerGroup" ] = val
		_addon:ReloadUI()
	end
	optionsTable[2].setFunc = function( val ) self.Settings["align_tools"] = val
		wykkydsToolbar:SetFrameCoords()
	end
	optionsTable[3].setFunc = function( val ) self.Settings["lock_in_place"] = val
		wykkydsToolbar:SetMouseEnabled(not val)
		wykkydsToolbar:SetMovable(not val)
	end
	optionsTable[4].setFunc = function( val ) self.Settings["lock_horizontal"] = val
		wykkydsToolbar:SetFrameCoords()
	end
	optionsTable[6].setFunc = function( val ) self.Settings["enable_background"] = val
		if val then if wykkydsToolbar.bg:IsHidden() then wykkydsToolbar.bg:SetHidden(false); end
		else if not wykkydsToolbar.bg:IsHidden() then wykkydsToolbar.bg:SetHidden(true); end
		end
	end

	local xx = _addon:GetCountOf( optionsTable )
	local fixFunc = function( targ )
		if targ.type == "description" then return end
		local ff = targ.setFunc
		targ.setFunc = function( val )
			ff( val )
			_addon.Feature.Toolbar.Redraw()
		end
	end
	for yy = 7, xx, 1 do
		if optionsTable[yy].type == "submenu" then
			local zz = _addon:GetCountOf( optionsTable[yy].controls )
			for aa = 1, zz, 1 do fixFunc( optionsTable[yy].controls[aa] ) end
		else
			fixFunc( optionsTable[yy] )
		end
	end

	optionsTable = self:InjectAdvancedSettings( optionsTable, 1 )
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end

_addon.Initialize = function( self )
	_addon.Feature.Toolbar.Create()
	_addon:OnUpdateCallback( "wykkydsToolbar_UpdateTic", wykkydsToolbar.UpdateAll, .5 )
end

if wykkydsToolbarGlobal == nil then wykkydsToolbarGlobal = {} end
LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) _addon:LoadSavedVariables( self ) end,
	function( self ) _addon:LoadSettingsMenu( self ) end,
	function( self ) _addon:Initialize( self ) end,
	"wykkydsToolbarGlobal", true
)

WYK_Toolbar = _addon
