------------------
-- Local namespace
LUIE.Effects = {}

-- Performance Enhancement
local E = LUIE.Effects
local L = LUIE.GetLocale()
local GetAbilityIcon = GetAbilityIcon


--[[----------------------------------------------------------
 * Transition functions:
 * * t - current time
 * * b - start value
 * * c - change in value
 * * d - duration
 * (t and d can be frames or seconds/milliseconds)
--]]----------------------------------------------------------

--[[
 * simple linear tweening - no easing, no acceleration
 ]]--
function E.linearTween(t, b, c, d)
	return c*t/d + b
end

--[[
 * quadratic easing in - accelerating from zero velocity
 ]]--
function E.easeInQuad(t, b, c, d)
	t = t / d
	return c*t*t + b
end

--[[
 * quadratic easing out - decelerating to zero velocity
 ]]--
function E.easeOutQuad(t, b, c, d)
	t = t / d
	return -c * t*(t-2) + b
end

--[[
 * quadratic easing in/out - acceleration until halfway, then deceleration
 ]]--
function E.easeInOutQuad(t, b, c, d)
	t = t / (d/2);
	if (t < 1) then return c/2*t*t + b end
	t = t - 1
	return -c/2 * (t*(t-2) - 1) + b
end

--[[----------------------------------------------------------
 * Helper function to return custom ability icon
--]]----------------------------------------------------------
function E.GetAbilityIcon(abilityName, abilityId)
	return E.AbilityIcon[abilityName or ''] or GetAbilityIcon(abilityId)
end

--[[----------------------------------------------------------
 * Effects groupping
--]]----------------------------------------------------------

--[[
 * List of abilities considered for Ultimate generation - same as in SCB
 ]]--
E.IsWeaponAttack = {
	[L.Skill_Light_Attack]				= true,
	[L.Skill_Heavy_Attack]				= true,
	[L.Skill_Heavy_Attack_Dual_Wield]	= true,
	[L.Skill_Heavy_Attack_Bow]			= true,
	[L.Skill_Heavy_Attack_Werewolf]		= true,
}

--[[
 * Completely ignored effects
 ]]--
E.IsEffectIgnored = {
	--night blade
	[L.Passive_SoulSiphoner]	= true,
	--ESO Plus
	[L.Passive_BattleSpirit]    = true,
	[L.Passive_ESO_Plus_Member]	= true,
}

--[[
 * List of toggle abilities
 ]]--
E.IsToggle = {
	[L.Toggled_Unstable_Familiar]			= true,
	[L.Toggled_Unstable_Clannfear]			= true,
	[L.Toggled_Volatile_Familiar]			= true,
	[L.Toggled_Summon_Winged_Twilight]		= true,
	[L.Toggled_Summon_Restoring_Twilight]	= true,
	[L.Toggled_Summon_Twilight_Matriarch]	= true,
	[L.Toggled_Bound_Armor]					= true,
	[L.Toggled_Bound_Armaments]				= true,
	[L.Toggled_Bound_Aegis]					= true,
	[L.Toggled_Overload]					= true,
	[L.Toggled_Energy_Overload]				= true,
	[L.Toggled_Power_Overload]				= true,
	[L.Toggled_Siphoning_Strikes]			= true,
	[L.Toggled_Leeching_Strikes]			= true,
	[L.Toggled_Siphoning_Attacks]			= true,
	[L.Toggled_Magelight]					= true,
	[L.Toggled_Inner_Light]					= true,
	[L.Toggled_Radiant_Magelight]			= true,
	[L.Toggled_Brace_Generic]				= true,
}

--[[
 * Vampire / Lycantropy
 ]]--
E.IsVampLycan = {
	[L.VampLycan_Fed_on_ally]			= true,
	[L.VampLycan_Bit_an_ally]			= true,
	[L.VampLycan_Dark_Stalker]			= true,
	[L.VampLycan_Supernatural_Recovery]	= true,
	[L.VampLycan_Stage_1_Vampirism]		= true,
	[L.VampLycan_Stage_2_Vampirism]		= true,
	[L.VampLycan_Stage_3_Vampirism]		= true,
	[L.VampLycan_Stage_4_Vampirism]		= true,
	[L.VampLycan_Vampirism]				= true,
	[L.VampLycan_Lycanthropy]			= true,
	[L.VampLycan_Call_of_the_Pack]		= true,
	[L.VampLycan_Sanies_Lupinus]		= true,
}

--[[
 * Vampirism stages. Always true for VampStage4, but return false if effect is for player
 ]]--
local IsVampStage123 = {
	[L.VampLycan_Stage_1_Vampirism]	= 1,
	[L.VampLycan_Stage_2_Vampirism]	= 2,
	[L.VampLycan_Stage_3_Vampirism]	= 3,
}
function E.IsVampStage(effect)
	if effect.name == L.VampLycan_Stage_4_Vampirism then
		return 4
	elseif effect.target ~= "player" then
		return IsVampStage123[effect.name] or false
	end
	return false
end

--[[E.isMiniEffectIgnored = {
	L.Poisoned = true,
}
]]
--[[
 * Mundus passives
 ]]--
E.IsBoon = {
	[L.Boon_Warrior]	= true,
	[L.Boon_Mage]		= true,
	[L.Boon_Serpent]	= true,
	[L.Boon_Thief]		= true,
	[L.Boon_Lady]		= true,
	[L.Boon_Steed]		= true,
	[L.Boon_Lord]		= true,
	[L.Boon_Apprentice]	= true,
	[L.Boon_Ritual]		= true,
	[L.Boon_Lover]		= true,
	[L.Boon_Atronach]	= true,
	[L.Boon_Shadow]		= true,
	[L.Boon_Tower]		= true,
}

--[[
 * Equipment sets
 ]]--
E.IsEquipmentSet = {
	[L.Equip_Torugs_Pact]	= true,
	[L.Equip_Hist_Bark]		= true,
	[L.Equip_Master]        = true,
	[L.Equip_Phoenix]		= true,
	[L.Equip_Para_Bellum]	= true,
}

--[[
 * PvP related buffs
 ]]--
E.IsCyrodiil = {
	[L.Passive_Offensive_Scroll_Bonus_1]	= true,
	[L.Passive_Defensive_Scroll_Bonus_1]	= true,
	[L.Passive_Offensive_Scroll_Bonus_2]	= true,
	[L.Passive_Defensive_Scroll_Bonus_2]	= true,
	[L.Passive_Emperorship]					= true,
	[L.Passive_Blessing_of_War]				= true,
	[L.Passive_BattleSpirit]				= true,
}

--[[
 * List of abilities that have to be purged when first damage is recorded
 ]]--
E.IsGroundMine = {
	[L.Skill_Daedric_Mines]		= true,
	[L.Skill_Daedric_Minefield]	= true,
	[L.Skill_Daedric_Tomb]		= true,
	[L.Skill_Fire_Rune]			= true,
	[L.Skill_Scalding_Rune]		= true,
	[L.Skill_Volcanic_Rune]		= true,
	[L.Skill_Trap_Beast]		= true,
}

--[[
 * Taunts
 ]]--
E.IsTaunt = {
	[L.Skill_Puncture]		= true,
	[L.Skill_Pierce_Armor]	= true,
	[L.Skill_Ransack]		= true,
	[L.Skill_Inner_Fire]	= true,
	[L.Skill_Inner_Rage]	= true,
	[L.Skill_Inner_Beast]	= true,
}

--[[
 * Abilities icons that has to be override the API value returned by GetAbilityIcon(abilityId)
 * List only contains English names. Other languages will use game provided icons
 ]]--
E.AbilityIcon = {
	-- Currencies icons
	['Money']							= '/EsoUI/Art/Icons/Item_Generic_CoinBag.dds',
	['Alliance Points']					= '/EsoUI/Art/Icons/Icon_AlliancePoints.dds',
	['TelVar Stones']					= '/EsoUI/Art/Icons/Icon_TelVarStone.dds',
	
	

	['Magicka Restore']					= '/esoui/art/icons/consumable_potion_002_type_004.dds', -- EN, ?
	['Restore Magicka']					= '/esoui/art/icons/consumable_potion_002_type_004.dds', -- EN, ?
	['Stamina Restore']					= '/esoui/art/icons/consumable_potion_003_type_004.dds', -- EN, ?
	['Restore Stamina']					= '/esoui/art/icons/consumable_potion_003_type_004.dds', -- EN, ?
	
	[L.Effect_Fall_Snare]				= '/esoui/art/icons/death_recap_fall_damage.dds',

	['Feed']							= '/esoui/art/icons/ability_vampire_002.dds', -- EN,FR
	
	[L.Effect_Magicka_Bomb]            = '/esoui/art/icons/death_recap_magic_ranged.dds', -- EN

	[L.Effect_Surge_Heal]				= '/esoui/art/icons/ability_sorcerer_critical_surge.dds',
	[L.Effect_Dark_Exchange_Heal]		= '/esoui/art/icons/ability_sorcerer_dark_exchange.dds',
	[L.Skill_Dark_Exchange]				= '/esoui/art/icons/ability_sorcerer_dark_exchange.dds',
	['Blood Magic']						= '/esoui/art/icons/ability_mage_026.dds', -- EN, ?
	
	[L.Skill_Grand_Healing]				= '/esoui/art/icons/ability_restorationstaff_003.dds',
	[L.Skill_Healing_Ward]				= '/esoui/art/icons/ability_restorationstaff_001_a.dds',
	
	[L.Skill_Quick_Siphon]				= '/esoui/art/icons/ability_restorationstaff_005_b.dds',

	[L.Skill_Bash]						= '/esoui/art/icons/ability_warrior_008.dds',
	[L.Passive_Invigorating_Bash]		= '/esoui/art/icons/ability_warrior_026.dds',
	['Rending Slashes Bleed']			= '/esoui/art/icons/ability_dualwield_001_a.dds', -- EN

	--[[ FIXME: This all seams redundant as of Update 1.7.0
		-- Dwemer Automation set
		['Dwemer Automation Restore HP']	= '/esoui/art/icons/quest_dungeons_razaks_opus.dds',
		-- Lich Crystal (from Undaunted set)
		['Lich Crystal']					= '/esoui/art/icons/death_recap_magic_aoe.dds',
		-- Effect
		[L.Effect_Burning]					= '/esoui/art/icons/ability_dragonknight_004_b.dds',
		[L.Effect_Explosion]				= '/esoui/art/icons/death_recap_fire_aoe.dds',
		[L.Effect_Poisoned]					= '/esoui/art/icons/death_recap_poison_aoe.dds',
		[L.Effect_Diseased]					= '/esoui/art/icons/death_recap_disease_aoe.dds',
		[L.Effect_Bleeding]					= '/esoui/art/icons/crafting_leather_blood.dds',
		-- Health potion
		["Restore_Health"]					= '/esoui/art/icons/consumable_potion_001_type_005.dds', -- EN
		["Health Potion Lingering Effect"]	= '/esoui/art/icons/consumable_potion_001_type_005.dds', -- EN,?
		-- Vampire feeding
		-- Enchantments
		['Fiery Weapon']					= '/esoui/art/icons/death_recap_fire_melee.dds', -- EN
		['Charged Weapon']					= '/esoui/art/icons/death_recap_shock_melee.dds', -- EN
		['Frozen Weapon']					= '/esoui/art/icons/death_recap_cold_melee.dds', -- EN
		['Frozen Weapon and Hardening']		= '/esoui/art/icons/death_recap_cold_ranged.dds', -- EN ( pvp Ice Staff )
		['Poisoned Weapon']					= '/esoui/art/icons/death_recap_poison_melee.dds', -- EN
		['Befouled Weapon']					= '/esoui/art/icons/death_recap_disease_melee.dds', -- EN
		['Absorb Magicka']					= '/esoui/art/icons/death_recap_magic_melee.dds', -- EN
		['Absorb Stamina']					= '/esoui/art/icons/death_recap_magic_melee.dds', -- EN
		['Damage Health']					= '/esoui/art/icons/ability_mage_002.dds', -- EN
		['Life Drain']						= '/esoui/art/icons/ability_healer_031.dds', -- EN
		-- 'Life Drain' alternative icon 'rogue_069' or 'mage_052'
		-- Imperial self-heal (Red Diamond passive)
		['Star of the West']				= '/esoui/art/icons/ability_dragonknight_028.dds', -- EN,DE,FR
		-- Synergy icons
		['Conduit']							= '/esoui/art/icons/ability_mage_029.dds',
		['Slip Away']						= '/esoui/art/icons/ability_rogue_052.dds',
		['Blessed Shards']					= '/esoui/art/icons/gear_nord_staff_d.dds',
		['Luminous Shards']					= '/esoui/art/icons/gear_nord_staff_d.dds',
		['Impale']							= '/esoui/art/icons/ability_mage_001.dds', -- EN
		['Radiate']			 				= '/esoui/art/icons/ability_warrior_010.dds', -- EN
		['Shackle']							= '/esoui/art/icons/ability_mage_023.dds', -- EN
		['Supernova']						= '/esoui/art/icons/ability_healer_013.dds', -- EN
		['Gravity Crush']					= '/esoui/art/icons/ability_healer_013.dds', -- EN
		['Purify']							= '/esoui/art/icons/ability_healer_028.dds', -- EN
		['Combustion']						= '/esoui/art/icons/ability_mage_057.dds', -- EN
		-- Lightning staff specials
		['Shock Pulse']						= '/esoui/art/icons/death_recap_shock_ranged.dds', -- EN
		['Shock']							= '/esoui/art/icons/death_recap_shock_aoe.dds', -- EN
		[L.Skill_Overload_Light_Attack]		= '/esoui/art/icons/ability_sorcerer_016.dds',
		[L.Skill_Overload_Heavy_Attack]		= '/esoui/art/icons/death_recap_shock_ranged.dds',
		-- destruction staff skills, that depend on staff type
		['Frost Touch']						= '/esoui/art/icons/ability_destructionstaff_005.dds', -- EN
		['Shock Touch']						= '/esoui/art/icons/ability_destructionstaff_006.dds', -- EN
		['Fire Touch']						= '/esoui/art/icons/ability_destructionstaff_007.dds', -- EN
		['Frost Ring']						= '/esoui/art/icons/ability_destructionstaff_008.dds', -- EN
		['Shock Ring']						= '/esoui/art/icons/ability_destructionstaff_009.dds', -- EN
		['Fire Ring']						= '/esoui/art/icons/ability_destructionstaff_010.dds', -- EN,FR
		-- Dual Wield
		['Twin Slashes Bleed']				= '/esoui/art/icons/ability_dualwield_001.dds', -- EN,DE,FR
		['Rending Slashes Bleed']			= '/esoui/art/icons/ability_dualwield_001.dds', -- EN
		-- SORCERER
		-- Mages' Fury
		-- /esoui/art/icons/ability_sorcerer_mage_fury.dds
		-- /esoui/art/icons/ability_sorcerer_mage_wraith.dds
		-- /esoui/art/icons/ability_sorcerer_endless_fury.dds
		-- I want to put different icon for explosion ability to notice difference in floating text
		["Mages' Fury Explosion"]			= '/esoui/art/icons/ability_sorcerer_endless_fury.dds', -- EN,DE,FR
		["Mages' Wrath Explosion"]			= '/esoui/art/icons/ability_sorcerer_endless_fury.dds', -- EN,DE,FR
		["Endless Fury Explosion"]			= '/esoui/art/icons/ability_sorcerer_mage_wraith.dds', -- EN,DE,FR
		-- Atronach
		[L.Effect_Atronach]					= '/esoui/art/icons/ability_sorcerer_storm_atronach.dds',
		[L.Effect_Atronach_Zap]				= '/esoui/art/icons/ability_sorcerer_storm_atronach.dds',
		-- DRAGONKNIGHT
		-- Flame Lash
		[L.Effect_Flame_Lash_Heal]			= '/esoui/art/icons/ability_dragonknight_001_a.dds',
		-- Light and Heavy Attack icons
		[L.Skill_Light_Attack]				= '/esoui/art/icons/death_recap_melee_basic.dds',
		[L.Skill_Heavy_Attack]				= '/esoui/art/icons/death_recap_melee_heavy.dds',
		[L.Skill_Heavy_Attack_Dual_Wield]	= '/esoui/art/icons/ability_rogue_006.dds',
		[L.Skill_Heavy_Attack_Bow]			= '/esoui/art/icons/death_recap_ranged_heavy.dds',
		[L.Passive_Riposte]					= '/esoui/art/icons/ability_warrior_026.dds',
		[L.Skill_Familiar_Melee]			= '/esoui/art/icons/death_recap_melee_basic.dds',
		[L.Skill_Zap]						= '/esoui/art/icons/death_recap_shock_ranged.dds',
		[L.Skill_Kick]						= '/esoui/art/icons/ability_warrior_006.dds',
		-- AVA damages
		['Fire']							= '/esoui/art/icons/ability_dragonknight_002_a.dds', -- EN
		['Flaming Oil']						= '/esoui/art/icons/ability_dragonknight_002_a.dds', -- EN +
		['Ice Damage']						= '/esoui/art/icons/ava_siege_ammo_002.dds', -- EN
		['Meatbag Catapult']				= '/esoui/art/icons/ava_siege_ammo_003.dds', -- EN +
		['Stone Trebuchet']					= '/esoui/art/icons/ava_siege_ammo_004.dds', -- EN +
		['Ballista Bolt']					= '/esoui/art/icons/ava_siege_ammo_006.dds', -- EN +
		['Oil Pot']							= '/esoui/art/icons/ability_templar_031.dds', -- EN
		['Door Repair Kit']					= '/esoui/art/icons/crafting_forester_weapon_component_005.dds', -- EN
		['Wall Repair Kit']					= '/esoui/art/icons/crafting_heavy_armor_sp_names_001.dds', -- EN
		-- some reflected skills
		['Quick Shot']						= '/esoui/art/icons/death_recap_ranged_basic.dds', -- EN
		['Coiled Lash']						= '/esoui/art/icons/death_recap_ranged_basic.dds', -- EN
		['Throw Dagger']					= '/esoui/art/icons/ability_rogue_026.dds', -- EN
		['Flare']							= '/esoui/art/icons/death_recap_fire_ranged.dds', -- EN
		['Ice Arrow']						= '/esoui/art/icons/death_recap_cold_ranged.dds', -- EN
		['Entropic Flare']					= '/esoui/art/icons/death_recap_magic_ranged.dds', -- EN
		['Necrotic Spear']					= '/esoui/art/icons/death_recap_magic_ranged.dds', -- EN
		['Chasten']							= '/esoui/art/icons/death_recap_magic_ranged.dds', -- EN
		['Minor Wound']						= '/esoui/art/icons/death_recap_magic_ranged.dds', -- EN
	]]--
}

