-- OmniStats
-- Provides character attributes in a compact frame
-- Author: RunningDuck
-- Original author of version 1.x: stjobe
-- LibAddonMenu courtesy of Seerah: http://www.esoui.com/downloads/info7-LibAddonMenu.html
-- Credits: Autohide code by @uladz
------------------
-- DECLARATIONS --
------------------
local DebugMe = false -- Set to false to inhibit trace printout in chat
local FirstMainLoop = true

local OmniStats = {}
OmniStats.name = "OmniStats"
OmniStats.displayVersion = "2.8.0"
OmniStats.saveVersion = "280"

OmniStats.Initialized = false
OmniStats.ToggledOff = false

local DefaultSettings = {
	posX = 30,
	posY = 100,
	ShowMax = true,
	Layout = "3 rows, 2 by 2",
	BDAlpha = 0.3,
	TextAlpha = 1,
	Scale = 1,
	ShowIC = false,
	ShowOOC = true,
	ShowManual = false,
	TextType = 4, -- 1,2,3,4, see CtrlWidth
	ShowTarget = false,
	AutoHide = true,
	
	-- Pos must be unique, Show = true or false
	Omni = {
	[STAT_MAGICKA_MAX] = {
		DebugId = STAT_MAGICKA_MAX,
		Text = {
			[1] = "STAT_MAGICKA_MAX: ", -- DebugN
			[2] = "Magicka max: ", -- LongN
			[3] = "Magicka: ", -- MediumN
			[4] = "Mag: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 1, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_MAGICKA_REGEN_COMBAT] = {
		DebugId = STAT_MAGICKA_REGEN_COMBAT,
		Text = {
			[1] = "STAT_MAGICKA_REGEN_COMBAT: ", -- DebugN
			[2] = "Magicka Recovery: ", -- LongN
			[3] = "Mag Rec: ", -- MediumN
			[4] = "MaR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 2, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_HEALTH_MAX] = {
		DebugId = STAT_HEALTH_MAX,
		Text = {
			[1] = "STAT_HEALTH_MAX: ", -- DebugN
			[2] = "Health Max: ", -- LongN
			[3] = "Health: ", -- MediumN
			[4] = "Hth: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 3, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_HEALTH_REGEN_COMBAT] = {
		DebugId = STAT_HEALTH_REGEN_COMBAT,
		Text = {
			[1] = "STAT_HEALTH_REGEN_COMBAT: ", -- DebugN
			[2] = "Health Recovery: ", -- LongN
			[3] = "Hth Rec: ", -- MediumN
			[4] = "HtR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 4, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_STAMINA_MAX] = {
		DebugId = STAT_STAMINA_MAX,
		Text = {
			[1] = "STAT_STAMINA_MAX: ", -- DebugN
			[2] = "Stamina Max: ", -- LongN
			[3] = "Stamina: ", -- MediumN
			[4] = "Sta: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 5, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_STAMINA_REGEN_COMBAT] = {
		DebugId = STAT_STAMINA_REGEN_COMBAT,
		Text = {
			[1] = "STAT_STAMINA_REGEN_COMBAT: ", -- DebugN
			[2] = "Stamina Recovery: ", -- LongN
			[3] = "Sta Rec: ", -- MediumN
			[4] = "StR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 6, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_SPELL_POWER] = {
		DebugId = STAT_SPELL_POWER,
		Text = {
			[1] = "STAT_SPELL_POWER: ", -- DebugN
			[2] = "Spell Damage: ", -- LongN
			[3] = "Spe Dmg: ", -- MediumN
			[4] = "SpD: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 7, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_POWER] = { -- use STAT_POWER instead of STAT_WEAPON_POWER
		DebugId = STAT_POWER,
		Text = {
			[1] = "STAT_POWER: ", -- DebugN
			[2] = "Weapon Damage: ", -- LongN
			[3] = "Wpn Dmg: ", -- MediumN
			[4] = "WpD: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 8, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_SPELL_CRITICAL] = {
		DebugId = STAT_SPELL_CRITICAL,
		Text = {
			[1] = "STAT_SPELL_CRITICAL: ", -- DebugN
			[2] = "Spell Critical: ", -- LongN
			[3] = "Spe Crit: ", -- MediumN
			[4] = "SpC: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 9, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_CRITICAL_STRIKE] = {
		DebugId = STAT_CRITICAL_STRIKE,
		Text = {
			[1] = "STAT_CRITICAL_STRIKE: ", -- DebugN
			[2] = "Weapon Critical: ", -- LongN
			[3] = "Wpn Crit: ", -- MediumN
			[4] = "WpC: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 10, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_SPELL_RESIST] = {
		DebugId = STAT_SPELL_RESIST,
		Text = {
			[1] = "STAT_SPELL_RESIST: ", -- DebugN
			[2] = "Spell Resistance: ", -- LongN
			[3] = "Spe Res: ", -- MediumN
			[4] = "SpR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 11, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_PHYSICAL_RESIST] = {
		DebugId = STAT_PHYSICAL_RESIST,
		Text = {
			[1] = "STAT_PHYSICAL_RESIST: ", -- DebugN
			[2] = "Physical Resistance: ", -- LongN
			[3] = "Phys Res: ", -- MediumN
			[4] = "PhR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 12, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	
	-- Additional stats
	[STAT_ATTACK_POWER] = {
		DebugId = STAT_ATTACK_POWER,
		Text = {
			[1] = "STAT_ATTACK_POWER: ", -- DebugN
			[2] = "Attack Power: ", -- LongN
			[3] = "Attack: ", -- MediumN
			[4] = "Att: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 13, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_HEALTH_REGEN_IDLE] = {
		DebugId = STAT_HEALTH_REGEN_IDLE,
		Text = {
			[1] = "STAT_HEALTH_REGEN_IDLE: ", -- DebugN
			[2] = "Health Rec. Idle: ", -- LongN
			[3] = "Hth Rec I: ", -- MediumN
			[4] = "HRI: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 14, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_SPELL_PENETRATION] = {
		DebugId = STAT_SPELL_PENETRATION,
		Text = {
			[1] = "STAT_SPELL_PENETRATION: ", -- DebugN
			[2] = "Spell Penetration: ", -- LongN
			[3] = "Spell Pen: ", -- MediumN
			[4] = "SpP: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 15, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_MAGICKA_REGEN_IDLE ] = {
		DebugId = STAT_MAGICKA_REGEN_IDLE ,
		Text = {
			[1] = "STAT_MAGICKA_REGEN_IDLE : ", -- DebugN
			[2] = "Magicka Rec. Idle: ", -- LongN
			[3] = "Mag Rec I: ", -- MediumN
			[4] = "MRI: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 16, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_PHYSICAL_PENETRATION] = {
		DebugId = STAT_PHYSICAL_PENETRATION,
		Text = {
			[1] = "STAT_PHYSICAL_PENETRATION: ", -- DebugN
			[2] = "Armor Penetration: ", -- LongN
			[3] = "Armor Pen: ", -- MediumN
			[4] = "ArP: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 17, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_STAMINA_REGEN_IDLE ] = {
		DebugId = STAT_STAMINA_REGEN_IDLE ,
		Text = {
			[1] = "STAT_STAMINA_REGEN_IDLE : ", -- DebugN
			[2] = "Stamina Rec. Idle: ", -- LongN
			[3] = "Sta Rec I: ", -- MediumN
			[4] = "SRI: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 18, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_SPELL_MITIGATION ] = {
		DebugId = STAT_SPELL_MITIGATION ,
		Text = {
			[1] = "STAT_SPELL_MITIGATION : ", -- DebugN
			[2] = "Spell Mitigation: ", -- LongN
			[3] = "Spell Mit: ", -- MediumN
			[4] = "SpM: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 19, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_MITIGATION ] = {
		DebugId = STAT_MITIGATION ,
		Text = {
			[1] = "STAT_MITIGATION : ", -- DebugN
			[2] = "Mitigation: ", -- LongN
			[3] = "Mitig: ", -- MediumN
			[4] = "Mit: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 20, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_HEALING_TAKEN ] = {
		DebugId = STAT_HEALING_TAKEN ,
		Text = {
			[1] = "STAT_HEALING_TAKEN : ", -- DebugN
			[2] = "Healing Taken: ", -- LongN
			[3] = "Healed: ", -- MediumN
			[4] = "Hea: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 21, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_CRITICAL_RESISTANCE ] = {
		DebugId = STAT_CRITICAL_RESISTANCE ,
		Text = {
			[1] = "STAT_CRITICAL_RESISTANCE : ", -- DebugN
			[2] = "Critical Resistance: ", -- LongN
			[3] = "Crit Res: ", -- MediumN
			[4] = "CrR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 22, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_DAMAGE_RESIST_COLD ] = {
		DebugId = STAT_DAMAGE_RESIST_COLD ,
		Text = {
			[1] = "STAT_DAMAGE_RESIST_COLD : ", -- DebugN
			[2] = "Cold Resistance: ", -- LongN
			[3] = "Cold Res: ", -- MediumN
			[4] = "CoR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 23, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_DAMAGE_RESIST_DISEASE ] = {
		DebugId = STAT_DAMAGE_RESIST_DISEASE ,
		Text = {
			[1] = "STAT_DAMAGE_RESIST_DISEASE : ", -- DebugN
			[2] = "Disease Resistance: ", -- LongN
			[3] = "Dis Res: ", -- MediumN
			[4] = "DiR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 24, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_DAMAGE_RESIST_DROWN ] = {
		DebugId = STAT_DAMAGE_RESIST_DROWN ,
		Text = {
			[1] = "STAT_DAMAGE_RESIST_DROWN : ", -- DebugN
			[2] = "Drown Resistance: ", -- LongN
			[3] = "Drow Res: ", -- MediumN
			[4] = "DrR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 25, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_DAMAGE_RESIST_EARTH ] = {
		DebugId = STAT_DAMAGE_RESIST_EARTH ,
		Text = {
			[1] = "STAT_DAMAGE_RESIST_EARTH : ", -- DebugN
			[2] = "Earth Resistance: ", -- LongN
			[3] = "Eath Res: ", -- MediumN
			[4] = "EaR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 26, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_DAMAGE_RESIST_FIRE ] = {
		DebugId = STAT_DAMAGE_RESIST_FIRE ,
		Text = {
			[1] = "STAT_DAMAGE_RESIST_FIRE : ", -- DebugN
			[2] = "Fire Resistance: ", -- LongN
			[3] = "Fire Res: ", -- MediumN
			[4] = "FiR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 27, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_DAMAGE_RESIST_GENERIC ] = {
		DebugId = STAT_DAMAGE_RESIST_GENERIC ,
		Text = {
			[1] = "STAT_DAMAGE_RESIST_GENERIC : ", -- DebugN
			[2] = "Generic Resistance: ", -- LongN
			[3] = "Gen Res: ", -- MediumN
			[4] = "GeR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 28, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_DAMAGE_RESIST_MAGIC ] = {
		DebugId = STAT_DAMAGE_RESIST_MAGIC ,
		Text = {
			[1] = "STAT_DAMAGE_RESIST_MAGIC : ", -- DebugN
			[2] = "Magic Resistance: ", -- LongN
			[3] = "Mag Res: ", -- MediumN
			[4] = "MaR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 29, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_DAMAGE_RESIST_OBLIVION ] = {
		DebugId = STAT_DAMAGE_RESIST_OBLIVION ,
		Text = {
			[1] = "STAT_DAMAGE_RESIST_OBLIVION : ", -- DebugN
			[2] = "Oblivion Resistance: ", -- LongN
			[3] = "Obl Res: ", -- MediumN
			[4] = "ObR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 30, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_DAMAGE_RESIST_PHYSICAL ] = {
		DebugId = STAT_DAMAGE_RESIST_PHYSICAL ,
		Text = {
			[1] = "STAT_DAMAGE_RESIST_PHYSICAL : ", -- DebugN
			[2] = "Damage Resistance: ", -- LongN
			[3] = "Dmg Res: ", -- MediumN
			[4] = "Dmg: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 31, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_DAMAGE_RESIST_POISON ] = {
		DebugId = STAT_DAMAGE_RESIST_POISON ,
		Text = {
			[1] = "STAT_DAMAGE_RESIST_POISON : ", -- DebugN
			[2] = "Poison Resistance: ", -- LongN
			[3] = "Pois Res: ", -- MediumN
			[4] = "PoR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 32, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_DAMAGE_RESIST_SHOCK ] = {
		DebugId = STAT_DAMAGE_RESIST_SHOCK ,
		Text = {
			[1] = "STAT_DAMAGE_RESIST_SHOCK : ", -- DebugN
			[2] = "Shock Resistance: ", -- LongN
			[3] = "Sho Res: ", -- MediumN
			[4] = "ShR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 33, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_NONE ] = {
		DebugId = STAT_NONE ,
		Text = {
			[1] = "STAT_NONE : ", -- DebugN
			[2] = "None: ", -- LongN
			[3] = "None: ", -- MediumN
			[4] = "Non: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 34, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_DODGE ] = {
		DebugId = STAT_DODGE ,
		Text = {
			[1] = "STAT_DODGE : ", -- DebugN
			[2] = "Dodge: ", -- LongN
			[3] = "Dodge: ", -- MediumN
			[4] = "Dge: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 35, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_BLOCK] = {
		DebugId = STAT_BLOCK ,
		Text = {
			[1] = "STAT_BLOCK : ", -- DebugN
			[2] = "Block: ", -- LongN
			[3] = "Block: ", -- MediumN
			[4] = "Blk: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 36, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_HEALING_DONE] = {
		DebugId = STAT_HEALING_DONE ,
		Text = {
			[1] = "STAT_HEALING_DONE : ", -- DebugN
			[2] = "Healing Done: ", -- LongN
			[3] = "HealDone: ", -- MediumN
			[4] = "HeD: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 37, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_MISS ] = {
		DebugId = STAT_MISS ,
		Text = {
			[1] = "STAT_MISS : ", -- DebugN
			[2] = "Miss: ", -- LongN
			[3] = "Miss: ", -- MediumN
			[4] = "Mis: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 38, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_ARMOR_RATING] = {
		DebugId = STAT_ARMOR_RATING,
		Text = {
			[1] = "STAT_ARMOR_RATING: ", -- DebugN
			[2] = "Armor Rating: ", -- LongN
			[3] = "Armor: ", -- MediumN
			[4] = "Arm: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 39, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_MOUNT_STAMINA_MAX ] = {
		DebugId = STAT_MOUNT_STAMINA_MAX ,
		Text = {
			[1] = "STAT_MOUNT_STAMINA_MAX : ", -- DebugN
			[2] = "Mount Stamina: ", -- LongN
			[3] = "Mnt Sta: ", -- MediumN
			[4] = "MSt: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 40, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	[STAT_MOUNT_STAMINA_REGEN_MOVING ] = {
		DebugId = STAT_MOUNT_STAMINA_REGEN_MOVING ,
		Text = {
			[1] = "STAT_MOUNT_STAMINA_REGEN_MOVING : ", -- DebugN
			[2] = "Mount Stamina Rec: ", -- LongN
			[3] = "Mnt Sta R: ", -- MediumN
			[4] = "MSR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 41, Show = false, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil,
	},
	},
	-- Pos must be unique, Show = true or false
	Target = {
	[POWERTYPE_MAGICKA] = {
		Text = {[1] = "POWERTYPE_MAGICKA: ", [2] = "Magicka max: ", [3] = "Magicka: ", [4] = "Mag: "},
		Current = 0, Ref = 0, Pos = 1, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[POWERTYPE_HEALTH] = {
		Text = {[1] = "POWERTYPE_HEALTH: ", [2] = "Health Max: ", [3] = "Health: ", [4] = "Hth: "},
		Current = 0, Ref = 0, Pos = 2, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[POWERTYPE_STAMINA] = {
		Text = {[1] = "POWERTYPE_STAMINA: ", [2] = "Stamina Max: ", [3] = "Stamina: ", [4] = "Sta: "},
		Current = 0, Ref = 0, Pos = 3, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[POWERTYPE_ULTIMATE] = {
		Text = {[1] = "POWERTYPE_ULTIMATE: ", [2] = "Ultimate: ", [3] = "Ultimate: ", [4] = "Ult: "},
		Current = 0, Ref = 0, Pos = 5, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[POWERTYPE_WEREWOLF] = {
		Text = {[1] = "POWERTYPE_WEREWOLF: ", [2] = "Werewolf: ", [3] = "Werewolf: ", [4] = "Wwf: "},
		Current = 0, Ref = 0, Pos = 6, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[POWERTYPE_MOUNT_STAMINA] = {
		Text = {[1] = "POWERTYPE_MOUNT_STAMINA: ", [2] = "Mount Stamina Max: ", [3] = "Mnt Sta: ", [4] = "MSt: "},
		Current = 0, Ref = 0, Pos = 7, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[POWERTYPE_INVALID] = {
		Text = {[1] = "POWERTYPE_INVALID: ", [2] = "Invalid power type: ", [3] = "Invalid: ", [4] = "Inv: "},
		Current = 0, Ref = 0, Pos = 8, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[POWERTYPE_HEALTH_BONUS] = {
		Text = {[1] = "POWERTYPE_HEALTH_BONUS: ", [2] = "Health Bonus: ", [3] = "Hth Bonu: ", [4] = "Hbo: "},
		Current = 0, Ref = 0, Pos = 12, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[101] = {
		Text = {[1] = "Homebrewed: TARGET_NAME: ", [2] = "Target Name: ", [3] = "Name: ", [4] = "T N: "},
		Current = 0, Ref = 0, Pos = 14, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[102] = {
		Text = {[1] = "Homebrewed: TARGET_CLASS: ", [2] = "Target Class: ", [3] = "Tar Class: ", [4] = "T C: "},
		Current = 0, Ref = 0, Pos = 15, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[103] = {
		Text = {[1] = "Homebrewed: TARGET_Level: ", [2] = "Target Level: ", [3] = "Tar Lvl: ", [4] = "T L: "},
		Current = 0, Ref = 0, Pos = 16, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[104] = {
		Text = {[1] = "Homebrewed: TARGET_VET_LVL: ", [2] = "Target Vet Lvl: ", [3] = "Tar Vet: ", [4] = "T V: "},
		Current = 0, Ref = 0, Pos = 17, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	},

	thousandDelimiter = 3, -- Space
	saveMode = false, -- false = use account wide, i.e. same settings for all chars
	refreshTime = 1000 -- refresh interval in milliseconds
}

-- There should be this number of stats in SV.Target
local TargetStats = 12

-- There should be this number of stats in SV.Omni
local NumberOfStats = 41

local RefStats = {} -- Saved Variables that defaults to DefaultSettings.Omni[].Ref
local SV = {} -- Saved Variables that defaults to DefaultSettings
local alwaysAccountWide = {} -- Default, except "saveMode", account wide Saved Variables that defaults to DefaultSettings
SV = DefaultSettings
alwaysAccountWide = DefaultSettings

-- Width for display controls
local CtrlWidth = {
	[1] = {Length = 198, Name = "Debug (35)"}, -- DebugN: 37 chars in text (35 define + 1 : + 1 space)
	[2] = {Length = 126, Name = "Long (19)"}, -- LongN: 21 chars in text (19 define + 1 : + 1 space)
	[3] = {Length = 60, Name = "Medium (8)"}, -- MediumN: 10 chars in text (8 define + 1 : + 1 space)
	[4] = {Length = 30, Name = "Short (3)"}, -- ShortN: 5 chars in text (3 define + 1 : + 1 space)
	[5] = {Length = 36, Name = "Number value"}, -- Number value, after Update 6 need a 5th digit, plus  room for a thousand delimiter
	[6] = {Length = 16, Name = "Icon"}, -- Icon field
	[7] = {Length = 16, Name = "Delimiter"}, -- Width for grouping delimiter
}

---------------
-- FUNCTIONS --
---------------
local panelData = {
	type = "panel",
    name = OmniStats.name,
	author = "RunningDuck",
    version = OmniStats.displayVersion,
}

function OmniStats.GetBaseValues()
    for stat, _ in pairs(SV.Omni) do
		SV.Omni[stat].Ref = GetPlayerStat(stat, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
		RefStats[stat] = SV.Omni[stat].Ref
	end
end

function OmniStats.GetValues()
    for stat, _ in pairs(SV.Omni) do
		if (SV.ShowMax == false) then
			if (stat == STAT_HEALTH_MAX) then
				SV.Omni[stat].Current, _, _ = GetUnitPower("player", POWERTYPE_HEALTH)
			elseif (stat == STAT_STAMINA_MAX) then
				SV.Omni[stat].Current, _, _ = GetUnitPower("player", POWERTYPE_STAMINA)
			elseif (stat == STAT_MAGICA_MAX) then
				SV.Omni[stat].Current, _, _ = GetUnitPower("player", POWERTYPE_MAGICA)
			else
				SV.Omni[stat].Current = GetPlayerStat(stat, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
			end
		else -- always show max
			if (stat == STAT_HEALTH_MAX) then
				_, _, SV.Omni[stat].Current = GetUnitPower("player", POWERTYPE_HEALTH)
			elseif (stat == STAT_STAMINA_MAX) then
				_, _, SV.Omni[stat].Current = GetUnitPower("player", POWERTYPE_STAMINA)
			elseif (stat == STAT_MAGICA_MAX) then
				_, _, SV.Omni[stat].Current = GetUnitPower("player", POWERTYPE_MAGICA)
			else
				SV.Omni[stat].Current = GetPlayerStat(stat, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
			end
		end
    end
end

function OmniStats.UpdateUI()
    for stat, _ in pairs(SV.Omni) do
		SV.Omni[stat].ValueCtrl:SetColor(1,1,1,1)
		-- SoftCap deprecated set it to nil to trigger workaround
		-- local softcap = GetStatSoftCap(stat)
		softcap = nil
		if softcap == nil then 
			softcap = 100000 -- workaround for WpD, WpC, SpC 
		end
		if (SV.Omni[stat].Current > softcap) then -- softcapped
			SV.Omni[stat].ValueCtrl:SetColor(0.9,0.5,0.3,1)
			SV.Omni[stat].IconCtrl:SetHidden(false)
		else
			SV.Omni[stat].IconCtrl:SetHidden(true)
		end
		if SV.Omni[stat].Current > SV.Omni[stat].Ref then -- buffed
            SV.Omni[stat].ValueCtrl:SetColor(0,1,0,1)
        elseif SV.Omni[stat].Current < SV.Omni[stat].Ref then -- debuffed
            SV.Omni[stat].ValueCtrl:SetColor(1,0,0,1)
        end
		
		if (stat == STAT_CRITICAL_STRIKE or stat == STAT_SPELL_CRITICAL) then
			percentvalue = GetCriticalStrikeChance(SV.Omni[stat].Current, true)
			SV.Omni[stat].ValueCtrl:SetText(string.format("%.0f", percentvalue).."%")
			-- debug
			if (DebugMe == true and FirstMainLoop == false) then
				d(SV.Omni[stat])
			end
			-- end debug
		else
				if SV.thousandDelimiter > 0 and SV.Omni[stat].Current > 1000 then
					thousands = math.floor(SV.Omni[stat].Current / 1000)
					rest = SV.Omni[stat].Current - (thousands * 1000)
					if SV.thousandDelimiter == 1 then delimiter = "."
					elseif SV.thousandDelimiter == 2 then delimiter = ","
					else delimiter = " " end
					SV.Omni[stat].ValueCtrl:SetText(string.format("%d%s%.3d", thousands, delimiter, rest))
				else -- None
					SV.Omni[stat].ValueCtrl:SetText(string.format("%d", SV.Omni[stat].Current))
				end

		end
    end
end

function OmniStats.CreateLayout()
	local xOffset = 0
	local xGOffset = 0
	local yOffset = 0
	local yGOffset = 0
	local DisplayStats = 0
	local DisplayTStats = 0
	local i = 0
	
	-- index of StatPos = display order, array of stats that should be shown, used as index to Omni
	local StatPos = {}
	local TargetPos = {}

	-- StatPos should contain the stat that should be displayed (shown) and in the right display order
	for i=1, NumberOfStats do
		for stat, _ in pairs(SV.Omni) do
			if SV.Omni[stat].Pos == i and SV.Omni[stat].Show == true then
				DisplayStats = DisplayStats + 1
				StatPos[DisplayStats] = stat
				break -- the inner for-loop as we found the item 
			end
		end
	end
	for i=1, TargetStats do
		for stat, _ in pairs(SV.Target) do
			if SV.Target[stat].Pos == i and SV.Target[stat].Show == true then
				DisplayTStats = DisplayTStats + 1
				TargetPos[DisplayTStats] = stat
				break -- the inner for-loop as we found the item 
			end
		end
	end
	
	-- Reposition controls for new namelength and print new name, hide if it shouldn't be displayed
	for stat, _ in pairs(SV.Omni) do
        SV.Omni[stat].NameCtrl:SetDimensions(CtrlWidth[SV.TextType].Length, 16)
		SV.Omni[stat].NameCtrl:SetText(string.format("%s", SV.Omni[stat].Text[SV.TextType]))
		SV.Omni[stat].NameCtrl:SetHidden(not SV.Omni[stat].Show)
		SV.Omni[stat].ValueCtrl:SetHidden(not SV.Omni[stat].Show)
		SV.Omni[stat].IconCtrl:SetHidden(not SV.Omni[stat].Show)
	end
	for stat, _ in pairs(SV.Target) do
        SV.Target[stat].NameCtrl:SetDimensions(CtrlWidth[SV.TextType].Length, 16)
		SV.Target[stat].NameCtrl:SetText(string.format("%s", SV.Target[stat].Text[SV.TextType]))
		SV.Target[stat].NameCtrl:SetHidden(not SV.Target[stat].Show)
		SV.Target[stat].ValueCtrl:SetHidden(not SV.Target[stat].Show)
	end
	
	-- Width is dependent on type of text + space for digits + an icon
	local width = CtrlWidth[SV.TextType].Length + CtrlWidth[5].Length + CtrlWidth[6].Length
	
	if (SV.Layout == "Vertical") then
		-- Vertical = one column by DisplayStats rows
		for pos=1, DisplayStats do
			SV.Omni[StatPos[pos]].NameCtrl:SetAnchor(TOPLEFT, OmniStats.MainWindow, TOPLEFT, 0, (yOffset * 16 + yGOffset * 10) * SV.Scale)
			yOffset = yOffset + 1
			if (yOffset % 2 == 0) then yGOffset = yGOffset + 1 end
		end
		OmniStats.MainWindow:SetDimensions(width, yOffset * 16 + yGOffset * 10)
		
	elseif (SV.Layout == "Horizontal") then
		-- Horizontal = DisplayStats columns by one row
		for pos=1, DisplayStats do
			SV.Omni[StatPos[pos]].NameCtrl:SetAnchor(TOPLEFT, OmniStats.MainWindow, TOPLEFT, (xOffset * width + xGOffset * CtrlWidth[7].Length) * SV.Scale, 0)
			xOffset = xOffset + 1
			if (xOffset % 2 == 0) then xGOffset = xGOffset + 1 end
		end
		OmniStats.MainWindow:SetDimensions(xOffset * width + xGOffset * CtrlWidth[7].Length, 16)
		
	elseif (SV.Layout == "2 columns") then
		-- 2 columns = 2 columns by DisplayStats/2 rows
		local maxcolumns = 1 -- i.e 2, as 0 is first column
		for pos=1, DisplayStats do
			SV.Omni[StatPos[pos]].NameCtrl:SetAnchor(TOPLEFT, OmniStats.MainWindow, TOPLEFT, (xOffset * width) * SV.Scale, (yOffset * 16 + yGOffset * 10) * SV.Scale)
			-- Iterate over all columns. After last column increase row and start on first column
			if (xOffset == maxcolumns) then 
				xOffset = 0
				yOffset = yOffset + 1
				if (yOffset % 3 == 0) then 	yGOffset = yGOffset + 1 end
			else 
				xOffset = xOffset + 1 
			end
		end
		OmniStats.MainWindow:SetDimensions((maxcolumns+1) * width, yOffset * 16 + yGOffset * 10)
		
		-- Target stat currently only available in the "2 columns" mode
		xOffset = 0
		yOffset = 0
		for pos=1, DisplayTStats do
			SV.Target[TargetPos[pos]].NameCtrl:SetAnchor(TOPLEFT, OmniStats.TargetWindow, TOPLEFT, (xOffset * width) * SV.Scale, (yOffset * 16) * SV.Scale)
			-- Iterate over all columns. After last column increase row and start on first column
			if (xOffset == maxcolumns) then 
				xOffset = 0
				yOffset = yOffset + 1
			else 
				xOffset = xOffset + 1 
			end
		end
		OmniStats.TargetWindow:SetDimensions((maxcolumns+1) * width, (yOffset+1) * 16)
		
	elseif (SV.Layout == "3 rows, 2 by 2") then
		-- 3 rows = DisplayStats/3 columns by 3 rows
		local maxcolumns = math.ceil(DisplayStats/3) - 1  -- 0 is first column
		if (maxcolumns % 2 == 0) then maxcolumns = maxcolumns + 1 end -- ensure an even number of columns (again; 0 is first column)
		local tempcolumns = 1 -- order stats in first two columns, then next 2 columns
		for pos=1, DisplayStats do
			SV.Omni[StatPos[pos]].NameCtrl:SetAnchor(TOPLEFT, OmniStats.MainWindow, TOPLEFT, (xOffset * width + xGOffset * CtrlWidth[7].Length) * SV.Scale, (yOffset * 16) * SV.Scale)
			-- Iterate over all columns. After last column increase row and start on first column
			if (xOffset == tempcolumns) then 
				xOffset = xOffset - 1
				yOffset = yOffset + 1
			else 
				xOffset = xOffset + 1 
			end
			-- When two cols are filled, i.e. want to start on 4th row, start with next 2 cols
			if (yOffset >= 3) then 
				xOffset = tempcolumns + 1
				tempcolumns = tempcolumns + 2
				yOffset = 0
				xGOffset = xGOffset + 1
			end	
		end
		OmniStats.MainWindow:SetDimensions((maxcolumns+1) * width + xGOffset * CtrlWidth[7].Length, 3 * 16)
		
	else
		d("OmniStats: Unknown layout parameter")
	end
end


function OmniStats.CreateUI()
	OmniStats.MainWindow = WINDOW_MANAGER:CreateTopLevelWindow(OmniStats.name.."MainWindow")
    OmniStats.MainWindow:SetDimensions(280, 200)
    OmniStats.MainWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.posX, SV.posY)
    OmniStats.MainWindow:SetHidden(false)
    OmniStats.MainWindow:SetMovable(true)
    OmniStats.MainWindow:SetMouseEnabled(true)
	OmniStats.MainWindow:SetHandler("OnMouseUp", function(_, button)
			if button == 2 then
				OmniStats.GetBaseValues()
			elseif button == 1 then
				SV.posX = math.floor(OmniStatsMainWindow:GetLeft())
				SV.posY = math.floor(OmniStatsMainWindow:GetTop())
			end
		end)
	OmniStats.MainWindow:SetAlpha(SV.TextAlpha)

	-- Controls
	for stat, _ in pairs(SV.Omni) do
		SV.Omni[stat].NameCtrl = WINDOW_MANAGER:CreateControl(OmniStats.name.."Name"..stat, OmniStats.MainWindow, CT_LABEL)
        SV.Omni[stat].NameCtrl:SetHidden(false)
        SV.Omni[stat].NameCtrl:SetDimensions(CtrlWidth[SV.TextType].Length, 16)
        SV.Omni[stat].NameCtrl:SetAlpha(1)
		SV.Omni[stat].NameCtrl:SetFont("ZoFontGameSmall")
        SV.Omni[stat].NameCtrl:SetColor(1, 0.98, 0.8, 1)
		SV.Omni[stat].NameCtrl:SetText(string.format("%s", SV.Omni[stat].Text[SV.TextType]))
		
		SV.Omni[stat].ValueCtrl = WINDOW_MANAGER:CreateControl(OmniStats.name.."Value"..stat, OmniStats.MainWindow, CT_LABEL)
		SV.Omni[stat].ValueCtrl:SetHidden(false)
        SV.Omni[stat].ValueCtrl:SetFont("ZoFontGameSmall")
        SV.Omni[stat].ValueCtrl:SetDimensions(CtrlWidth[5].Length, 16)
        SV.Omni[stat].ValueCtrl:SetColor(1, 1, 1, 1)
        SV.Omni[stat].ValueCtrl:SetAlpha(1)
        SV.Omni[stat].ValueCtrl:SetAnchor(TOPLEFT, SV.Omni[stat].NameCtrl, TOPRIGHT, 0, 0)
		SV.Omni[stat].ValueCtrl:SetHorizontalAlignment(2) -- align right
        SV.Omni[stat].ValueCtrl:SetText("0")
		
		SV.Omni[stat].IconCtrl = WINDOW_MANAGER:CreateControl(OmniStats.name.."Icon"..stat, OmniStats.MainWindow, CT_TEXTURE)
		SV.Omni[stat].IconCtrl:SetHidden(true)
		SV.Omni[stat].IconCtrl:SetDimensions(CtrlWidth[6].Length, 16)
		SV.Omni[stat].IconCtrl:SetAlpha(1)
		SV.Omni[stat].IconCtrl:SetAnchor(TOPLEFT, SV.Omni[stat].ValueCtrl, TOPRIGHT, 0, 0)
		SV.Omni[stat].IconCtrl:SetTexture("ESOUI/art/stats/diminishingreturns_icon.dds")
		SV.Omni[stat].IconCtrl:SetDrawLevel(1)
    end

	-- Target window
	OmniStats.TargetWindow = WINDOW_MANAGER:CreateTopLevelWindow(OmniStats.name.."TargetWindow")
    OmniStats.TargetWindow:SetDimensions(280, 200)
    OmniStats.TargetWindow:SetAnchor(TOPLEFT, OmniStats.MainWindow, TOPRIGHT, 16, 0)
    OmniStats.TargetWindow:SetHidden(false)
	OmniStats.TargetWindow:SetAlpha(SV.TextAlpha)

	-- Target controls
	for stat, _ in pairs(SV.Target) do
		SV.Target[stat].NameCtrl = WINDOW_MANAGER:CreateControl(OmniStats.name.."TarName"..stat, OmniStats.TargetWindow, CT_LABEL)
        SV.Target[stat].NameCtrl:SetHidden(false)
        SV.Target[stat].NameCtrl:SetDimensions(CtrlWidth[SV.TextType].Length, 16)
        SV.Target[stat].NameCtrl:SetAlpha(1)
		SV.Target[stat].NameCtrl:SetFont("ZoFontGameSmall")
        SV.Target[stat].NameCtrl:SetColor(1, 0.98, 0.8, 1)
		SV.Target[stat].NameCtrl:SetText(string.format("%s", SV.Target[stat].Text[SV.TextType]))
		
		SV.Target[stat].ValueCtrl = WINDOW_MANAGER:CreateControl(OmniStats.name.."TarValue"..stat, OmniStats.TargetWindow, CT_LABEL)
		SV.Target[stat].ValueCtrl:SetHidden(false)
        SV.Target[stat].ValueCtrl:SetFont("ZoFontGameSmall")
        SV.Target[stat].ValueCtrl:SetDimensions(CtrlWidth[5].Length, 16)
        SV.Target[stat].ValueCtrl:SetColor(1, 1, 1, 1)
        SV.Target[stat].ValueCtrl:SetAlpha(1)
        SV.Target[stat].ValueCtrl:SetAnchor(TOPLEFT, SV.Target[stat].NameCtrl, TOPRIGHT, 0, 0)
		SV.Target[stat].ValueCtrl:SetHorizontalAlignment(2) -- align right
        SV.Target[stat].ValueCtrl:SetText("0")
    end
	
	
	-- Layout
	OmniStats.CreateLayout()
	
	-- Backdrop
	OmniStats.MainBD = WINDOW_MANAGER:CreateControlFromVirtual(OmniStats.name.."MainBD", OmniStats.MainWindow, "ZO_DefaultBackdrop")
	OmniStats.MainBD:SetAlpha(SV.BDAlpha)
	OmniStats.TargetBD = WINDOW_MANAGER:CreateControlFromVirtual(OmniStats.name.."TargetBD", OmniStats.TargetWindow, "ZO_DefaultBackdrop")
	OmniStats.TargetBD:SetAlpha(SV.BDAlpha)

	-- Set scale
	OmniStats.MainWindow:SetScale(SV.Scale)
	OmniStats.TargetWindow:SetScale(SV.Scale)
	
	-- Initially hide target window
	OmniStats.TargetWindow:SetHidden(true)
end


function OmniStats.CreateSettings()
	
	local LAM2 = LibStub("LibAddonMenu-2.0")
	local optionsData = {
		[1] = {
			type = "checkbox",
			name = "Always show max values",
			tooltip = "Checking this option prevents regular depletion of Magicka, Health, and Stamina to show as debuffed",
			getFunc = function() return SV.ShowMax end,
			setFunc = function(value) 
				SV.ShowMax = value
			end,
		},
		[2] = {
			type = "dropdown",
			name = "Layout",
			tooltip = "Sets the layout the stats are displayed with",
			choices = {"3 rows, 2 by 2", "2 columns", "Vertical", "Horizontal"},
			getFunc = function() return SV.Layout end,
			setFunc = function(value) 
				if value ~= SV.Layout then
					SV.Layout = value
					OmniStats.CreateLayout()
				end
			end,
		},
		[3] = {
			type = "dropdown",
			name = "Text type",
			tooltip = "How much text should be displayed. ('Debug' is the name of the DerivedStats global LUA value)",
			choices = {CtrlWidth[4].Name, CtrlWidth[3].Name, CtrlWidth[2].Name, CtrlWidth[1].Name},
			getFunc = function() return CtrlWidth[SV.TextType].Name end,
			setFunc = function(value) 
				local index = 0
				for ix, _ in pairs(CtrlWidth) do
					if (value == CtrlWidth[ix].Name) then index = ix; end
				end
				if index ~= SV.TextType then
					SV.TextType = index
					OmniStats.CreateLayout()
				end
			end,
		},
		[4] = {
			type = "slider",
			name = "Text alpha (percent)",
			tooltip = "Sets the text alpha",
			min = 0,
			max = 100,
			step = 1,
			getFunc = function() return SV.TextAlpha * 100 end,
			setFunc = function(value) 
				if value ~= SV.TextAlpha then
					SV.TextAlpha = value / 100
					OmniStatsMainWindow:SetAlpha(SV.TextAlpha)
				end
			end,
		},
		[5] = {
			type = "slider",
			name = "Background alpha (percent)",
			tooltip = "Sets the background alpha",
			min = 0,
			max = 100,
			step = 1,
			getFunc = function() return SV.BDAlpha * 100 end,
			setFunc = function(value) 
				if value ~= SV.BDAlpha then
					SV.BDAlpha = value / 100
					OmniStatsMainBD:SetAlpha(SV.BDAlpha)
				end
			end,
		},
		[6] = {
			type = "slider",
			name = "Window scaling (percent)",
			tooltip = "Sets the scaling",
			min = 50,
			max = 300,
			step = 1,
			getFunc = function() return SV.Scale * 100 end,
			setFunc = function(value) 
				if value ~= SV.Scale then
					SV.Scale = value / 100
					OmniStatsMainWindow:SetScale(SV.Scale)
					OmniStatsTargetWindow:SetScale(SV.Scale)
					OmniStats.CreateLayout()
				end
			end,
		},
		[7] = {
			type = "dropdown",
			name = "Show all stats",
			tooltip = "When to show and hide the entire stat window, for manual define a key: Control/Keybindings: User Interface/OmniStats toggle on/off",
			choices = {"Manual (keybind)", "Out-Of-Combat", "In-Combat", "Always"},
			getFunc = function()  
				if (SV.ShowManual == true) then 
					return "Manual (keybind)"
				elseif (SV.ShowOOC == true and SV.ShowIC == false) then 
					return "Out-Of-Combat"
				elseif (SV.ShowIC == true and SV.ShowOOC == false) then 
					return "In-Combat"
				else 
					return "Always" 
				end
			end,
			setFunc = function(value) 
				if (value == "Manual (keybind)") then 
					SV.ShowManual = true
					SV.ShowIC = false
					SV.ShowOOC = false
				elseif (value == "In-Combat") then 
					SV.ShowManual = false 
					SV.ShowIC = true
					SV.ShowOOC = false
				elseif (value == "Out-Of-Combat") then 
					SV.ShowManual = false 
					SV.ShowIC = false
					SV.ShowOOC = true
				else -- "Always"
					SV.ShowManual = false 
					SV.ShowIC = true
					SV.ShowOOC = true
				end
				OmniStats.CreateLayout()
			end,
		},
		[8] = {
			type = "dropdown",
			name = "Thousand delimiter",
			tooltip = "Increase readability with a delimiter that separate the last three digits",
			choices = {"Space ' '", "Dot '.'", "Comma ','", "None"},
			getFunc = function()  
				if (SV.thousandDelimiter == 0) then return "None"
				elseif (SV.thousandDelimiter == 1) then return "Dot '.'"
				elseif (SV.thousandDelimiter == 2) then return "Comma ','"
				else return "Space ' '" end
			end,
			setFunc = function(value) 
				if (value == "None") then SV.thousandDelimiter = 0
				elseif (value == "Dot '.'") then SV.thousandDelimiter = 1
				elseif (value == "Comma ','") then SV.thousandDelimiter = 2
				else SV.thousandDelimiter = 3 end -- "Space ' '" 
				OmniStats.CreateLayout()
			end,
		},
        [9] = {
			type = "checkbox",
			name = "Autohide when menu or dialog open",
			tooltip = "Hides the stats window whenever you open up a menu or a dialog.",
			getFunc = function() return SV.AutoHide end,
			setFunc = function(value) 
				SV.AutoHide = value
            end,
        },		
		[10] = {
			type = "checkbox",
			name = "Show target values (experimental)",
			tooltip = "Shows stats for target, alas most are blocked and return zero. Currently only available for the '2 columns' mode.",
			getFunc = function() return SV.ShowTarget end,
			setFunc = function(value) 
				SV.ShowTarget = value
			end,
		},
		[11] = {
			type = "checkbox",
			name = "Save settings per character [account wide]",
			tooltip = "Don't use account wide settings, but rather for each character. Note, this setting (only) is ALWAYS account wide.",
			getFunc = function() return alwaysAccountWide.saveMode end,
			setFunc = function(value) 
				alwaysAccountWide.saveMode = value 
			end,
		},
		[12] = {
			type = "slider",
			name = "Refresh interval (milliseconds)",
			tooltip = "Sets the time between check of changes in the stats. Note that shorter time steals some performance!",
			min = 100,
			max = 1000,
			step = 100,
			getFunc = function() return SV.refreshTime end,
			setFunc = function(value) 
				SV.refreshTime = value
			end,
		},
		[13] = {
			type = "header",
			name = "Show/hide individual stats",
		},
	}
	
	-- dynamically add all stats
	local DisplayOrder = {}
	local i = 0
	local found = false
	for i=1, NumberOfStats do
		found = false
		for stat, _ in pairs(DefaultSettings.Omni) do
			if DefaultSettings.Omni[stat].Pos == i then
				DisplayOrder[i] = stat
				found = true
				break -- the inner for-loop as we found the item 
			end
		end
		if found == false then DisplayOrder[i] = STAT_NONE end
	end
	for i=1, NumberOfStats do
		local checkbox = {
			type = "checkbox",
			name = DefaultSettings.Omni[DisplayOrder[i]].Text[2],
			tooltip = "Check to show stat, uncheck to hide",
			width = "half",
			getFunc = function() return SV.Omni[DisplayOrder[i]].Show end,
			setFunc = function(value) 
				if SV.Omni[DisplayOrder[i]].Show ~= value then
					SV.Omni[DisplayOrder[i]].Show = value
					OmniStats.CreateLayout()
				end
			end
		}
		table.insert(optionsData, checkbox)
	end
		
	LAM2:RegisterAddonPanel(OmniStats.name.."Options", panelData)
	LAM2:RegisterOptionControls(OmniStats.name.."Options", optionsData)
end

function OmniStatsToggleWindow()
	OmniStats.ToggledOff = not OmniStats.ToggledOff
	OmniStats.MainWindow:SetHidden(OmniStats.ToggledOff)
end

-- AuotHide code by uladz
local function AutoHide()
	if SV.AutoHide == true then
		local menu1 = not ZO_GameMenu_InGame:IsHidden()
		local menu2 = not ZO_KeybindStripControl:IsHidden()
		local menu3 = not ZO_InteractWindow:IsHidden()
        local menu4 = not ZO_Character:IsHidden()
        local menu5 = WINDOW_MANAGER:IsSecureRenderModeEnabled()
        if menu1 or menu2 or menu3 or menu4 or menu5 then
			return true;
		end
	end
    return false;
 end

function OmniStats.MainLoop()

    if AutoHide() then
        OmniStats.MainWindow:SetHidden(true)
    elseif SV.ShowManual == false then
		if IsUnitInCombat("player") then
			if SV.ShowIC == false then
				OmniStats.MainWindow:SetHidden(true)
			else
				OmniStats.MainWindow:SetHidden(false)
			end
		else 
			if SV.ShowOOC == false then
				OmniStats.MainWindow:SetHidden(true)
			else
				OmniStats.MainWindow:SetHidden(false)
			end
		end
    else
		OmniStats.MainWindow:SetHidden(OmniStats.ToggledOff)
	end

	OmniStats.GetValues()
    OmniStats.UpdateUI()
	
	-- debug
	if (DebugMe == true and FirstMainLoop == true) then
		FirstMainLoop = false
		for stat, _ in pairs(SV.Omni) do
			if (SV.Omni[stat].Show) then 
				d(SV.Omni[stat])
			end
		end
	end
	-- end debug
	
    zo_callLater(function() OmniStats.MainLoop() end, SV.refreshTime)
end

function OmniStats.DelayedInit()
	if (RefStats[STAT_MAGICKA_MAX] == 0) then
		OmniStats.GetBaseValues()
	else
		for stat, _ in pairs(SV.Omni) do
			SV.Omni[stat].Ref = RefStats[stat]
		end
	end
	OmniStats.MainLoop()
	OmniStats.Initialized = true
end

function OmniStats.WaitForPlayerLoad()
	if (OmniStats.PlayerActivated == true) then
		zo_callLater(function() OmniStats.DelayedInit() end, 1000)
	else
		zo_callLater(function() OmniStats.WaitForPlayerLoad() end, 1000)
	end
end


local function OnAddOnLoaded(eventCode, addOnName)
	if (addOnName == OmniStats.name) then

		--Load the user's settings from SavedVariables file -> Account wide of basic version 999 at first
		alwaysAccountWide = ZO_SavedVars:NewAccountWide(OmniStats.name.."_SavedVariables", 999, "SettingsForAll", DefaultSettings)
		--Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
		--Use the current addon version to read the settings now
		if (alwaysAccountWide.saveMode == true) then
			--Use each character settings
			SV = ZO_SavedVars:New(OmniStats.name.."_SavedVariables", OmniStats.saveVersion , "Settings", DefaultSettings)
		else
			--Use standard: account wide settings
			SV = ZO_SavedVars:NewAccountWide(OmniStats.name.."_SavedVariables", OmniStats.saveVersion, "Settings", DefaultSettings)
		end
  		-- old SV = ZO_SavedVars:NewAccountWide(OmniStats.name.."_SavedVariables", 8, nil, DefaultSettings)

		-- Init first item in RefStat, although only usable first time per character to trigger load of values
		RefStats[STAT_MAGICKA_MAX] = 0
		RefStat = ZO_SavedVars:New(OmniStats.name.."_SavedVariables", 8, nil, RefStat)
		
		OmniStats.CreateSettings()
		OmniStats.CreateUI()
		OmniStats.WaitForPlayerLoad()
	end
end

local function OnPlayerActivated()
	OmniStats.PlayerActivated = true
end

local function OnTargetChanged()
	if (SV.Layout == "2 columns" and OmniStats.Initialized) then
		if (SV.ShowTarget and DoesUnitExist("reticleover") == true) then
			-- get creature info
			for stat, _ in pairs(SV.Target) do
				if (stat < 101) then
					_, SV.Target[stat].Current, _ = GetUnitPower("reticleover", stat)
					SV.Target[stat].ValueCtrl:SetText(string.format("%d", SV.Target[stat].Current))
				elseif (stat == 101) then
					SV.Target[stat].Current = GetUnitName('reticleover')
					SV.Target[stat].ValueCtrl:SetText(string.format("%s", SV.Target[stat].Current))
				elseif (stat == 102) then
					SV.Target[stat].Current	= GetUnitClass('reticleover')
					SV.Target[stat].ValueCtrl:SetText(string.format("%s", SV.Target[stat].Current))
				elseif (stat == 103) then
					SV.Target[stat].Current = GetUnitLevel('reticleover')
					SV.Target[stat].ValueCtrl:SetText(string.format("%d", SV.Target[stat].Current))
				elseif (stat == 104) then
					SV.Target[stat].Current	= GetUnitVeteranRank('reticleover')	
					SV.Target[stat].ValueCtrl:SetText(string.format("%d", SV.Target[stat].Current))
				end
			end
			OmniStats.TargetWindow:SetHidden(false)
		else
			--hide target window
			OmniStats.TargetWindow:SetHidden(true)
		end
	end
end

function OmniStatsInitialize()
	EVENT_MANAGER:RegisterForEvent(OmniStats.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(OmniStats.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
	EVENT_MANAGER:RegisterForEvent(OmniStats.name, EVENT_RETICLE_TARGET_CHANGED, OnTargetChanged )
end