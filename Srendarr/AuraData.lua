local Srendarr		= _G['Srendarr'] -- grab addon table from global
local L				= Srendarr:GetLocale()

-- UPVALUES --
local GetAbilityName		= GetAbilityName

-- Major & Minor Effect Identifiers
local EFFECT_BERSERK		= 1
local EFFECT_BREACH			= 2
local EFFECT_BRUTALITY		= 3
local EFFECT_DEFILE			= 4
local EFFECT_ENDURANCE		= 5
local EFFECT_EROSION		= 6
local EFFECT_EVASION		= 7
local EFFECT_EXPEDITION		= 8
local EFFECT_FORCE			= 9
local EFFECT_FORTITUDE		= 10
local EFFECT_FRACTURE		= 11
local EFFECT_HEROISM		= 12
local EFFECT_INTELLECT		= 13
local EFFECT_MAIM			= 14
local EFFECT_MANGLE			= 15
local EFFECT_MENDING		= 16
local EFFECT_PROPHECY		= 17
local EFFECT_PROTECTION		= 18
local EFFECT_RESOLVE		= 19
local EFFECT_SAVAGERY		= 20
local EFFECT_SORCERY		= 21
local EFFECT_SPELL_SHATTER	= 22
local EFFECT_VITALITY		= 23
local EFFECT_WARD			= 24
local EFFECT_WOUND			= 25

local minorEffects, majorEffects -- populated at the end of file due to how large they are (legibility reasons)

local alteredAuraIcons = { -- used to alter the default icon for selected auras
	[45902] = [[/esoui/art/icons/ability_mage_065.dds]],	-- Off-Balance
	[35771]	= [[Srendarr/Icons/Vamp_Stage1.dds]],			-- Stage 1 Vampirism
	[35776]	= [[Srendarr/Icons/Vamp_Stage2.dds]],			-- Stage 2 Vampirism
	[35783]	= [[Srendarr/Icons/Vamp_Stage3.dds]],			-- Stage 3 Vampirism
	[35786]	= [[Srendarr/Icons/Vamp_Stage4.dds]],			-- Stage 4 Vampirism
	[35792]	= [[Srendarr/Icons/Vamp_Stage4.dds]],			-- Stage 4 Vampirism
	[23392] = [[/esoui/art/icons/ability_mage_042.dds]],	-- Altmer Glamour
}

local fakeAuras = { -- used to spawn fake auras to handle mismatch of information provided by the API to what user's want|need
	[GetAbilityName(23634)] = {unitTag = 'groundaoe', duration = 18, abilityID = 200000},	-- Summon Storm Atronach
	[GetAbilityName(23492)] = {unitTag = 'groundaoe', duration = 28, abilityID = 200001},	-- Greater Storm Atronach
	[GetAbilityName(23495)] = {unitTag = 'groundaoe', duration = 18, abilityID = 200002},	-- Summon Charged Atronach
	[GetAbilityName(33376)] = {unitTag = 'groundaoe', duration = 30, abilityID = 200003},	-- Caltrops
	[GetAbilityName(40242)] = {unitTag = 'groundaoe', duration = 30, abilityID = 200004},	-- Razor Caltrops
	[GetAbilityName(40255)] = {unitTag = 'groundaoe', duration = 35, abilityID = 200005},	-- Anti-Cavalry Caltrops
	[GetAbilityName(81519)] = {unitTag = 'reticleover', duration = 10, abilityID = 200006},	-- Infallible Aether
	[GetAbilityName(22259)] = {unitTag = 'groundaoe', duration = 12, abilityID = 200011},	-- Ritual of Retribution Lvl 1
	[GetAbilityName(27261)] = {unitTag = 'groundaoe', duration = 12, abilityID = 200012},	-- Ritual of Retribution Lvl 2
	[GetAbilityName(27269)] = {unitTag = 'groundaoe', duration = 12, abilityID = 200013},	-- Ritual of Retribution Lvl 3
	[GetAbilityName(27275)] = {unitTag = 'groundaoe', duration = 12, abilityID = 200014},	-- Ritual of Retribution Lvl 4
}

local fakeProcs = { -- used to spawn fake auras to handle invisible procs like certain weapon enchants
-- Weapon enchant procs
	[21230] = {unitTag = 'player', duration = 5, icon = '/esoui/art/icons/ability_rogue_006.dds'},			-- Weapon/spell power enchant (Berserker)
	[17906] = {unitTag = 'player', duration = 5, icon = '/esoui/art/icons/ability_armor_001.dds'},			-- Reduce spell/physical resist (Crusher)
	[21578] = {unitTag = 'player', duration = 5, icon = '/esoui/art/icons/ability_healer_029.dds'},			-- Damage shield enchant (Hardening)
-- Armor set procs
	[71067] = {unitTag = 'player', duration = 4, icon = '/esoui/art/icons/death_recap_shock_melee.dds'},	-- Trial By Fire: Shock
	[71058] = {unitTag = 'player', duration = 4, icon = '/esoui/art/icons/death_recap_fire_melee.dds'},		-- Trial By Fire: Fire
	[71019] = {unitTag = 'player', duration = 4, icon = '/esoui/art/icons/death_recap_cold_melee.dds'},		-- Trial By Fire: Frost
	[71069] = {unitTag = 'player', duration = 4, icon = '/esoui/art/icons/death_recap_disease_melee.dds'},	-- Trial By Fire: Disease
	[71072] = {unitTag = 'player', duration = 4, icon = '/esoui/art/icons/death_recap_poison_melee.dds'},	-- Trial By Fire: Poison
	[49236] = {unitTag = 'player', duration = 8, icon = '/esoui/art/icons/ability_healer_035.dds'},			-- Whitestrake's Retribution
	[57170] = {unitTag = 'player', duration = 6, icon = '/esoui/art/icons/ability_vampire_002.dds'},		-- Blod Frenzy
	[75726] = {unitTag = 'player', duration = 3, icon = '/esoui/art/icons/ability_healer_005.dds'},			-- Tava's Favor
	[75746] = {unitTag = 'player', duration = 15, icon = '/esoui/art/icons/ability_rogue_033.dds'},			-- Clever Alchemist
	[61870] = {unitTag = 'player', duration = 15, icon = '/esoui/art/icons/ability_warrior_033.dds'},		-- Armor Master Resistance
	[70352] = {unitTag = 'player', duration = 15, icon = '/esoui/art/icons/ability_mage_065.dds'},			-- Armor Master Spell Resistance
	[71107] = {unitTag = 'player', duration = 10, icon = '/esoui/art/icons/gear_artifacthound_head_a.dds'}, -- Briarheart
-- Special case for Defensive Rune tracking
	[24574] = {unitTag = 'player', duration = 0, icon = '/esoui/art/icons/ability_sorcerer_weakening_fog.dds'},		-- Defensive Rune I
	[30182] = {unitTag = 'player', duration = 0, icon = '/esoui/art/icons/ability_sorcerer_weakening_fog.dds'},		-- Defensive Rune II
	[30188] = {unitTag = 'player', duration = 0, icon = '/esoui/art/icons/ability_sorcerer_weakening_fog.dds'},		-- Defensive Rune III
	[30194] = {unitTag = 'player', duration = 0, icon = '/esoui/art/icons/ability_sorcerer_weakening_fog.dds'},		-- Defensive Rune IV
}

local fakeTargetDebuffs = { -- used to spawn fake auras to handle invisible debuffs on current target
-- Special case for Fighters Guild Beast Trap (and morph) tracking
	[35754] = {duration = 6, icon = '/esoui/art/icons/ability_fightersguild_004.dds'}, 		-- Trap Beast I
	[42712] = {duration = 6, icon = '/esoui/art/icons/ability_fightersguild_004.dds'}, 		-- Trap Beast II
	[42719] = {duration = 6, icon = '/esoui/art/icons/ability_fightersguild_004.dds'}, 		-- Trap Beast III
	[42726] = {duration = 6, icon = '/esoui/art/icons/ability_fightersguild_004.dds'}, 		-- Trap Beast IV
	[40389] = {duration = 6, icon = '/esoui/art/icons/ability_fightersguild_004_a.dds'}, 	-- Rearming Trap I
	[42731] = {duration = 6, icon = '/esoui/art/icons/ability_fightersguild_004_a.dds'}, 	-- Rearming Trap II
	[42741] = {duration = 6, icon = '/esoui/art/icons/ability_fightersguild_004_a.dds'}, 	-- Rearming Trap III
	[42751] = {duration = 6, icon = '/esoui/art/icons/ability_fightersguild_004_a.dds'}, 	-- Rearming Trap IV
	[40376] = {duration = 6, icon = '/esoui/art/icons/ability_fightersguild_004_b.dds'}, 	-- Lightweight Beast Trap I
	[42761] = {duration = 6, icon = '/esoui/art/icons/ability_fightersguild_004_b.dds'}, 	-- Lightweight Beast Trap II
	[42768] = {duration = 6, icon = '/esoui/art/icons/ability_fightersguild_004_b.dds'}, 	-- Lightweight Beast Trap III
	[42775] = {duration = 6, icon = '/esoui/art/icons/ability_fightersguild_004_b.dds'}, 	-- Lightweight Beast Trap IV
--	[45217] = {duration = 6, icon = '/esoui/art/icons/ability_templar_031.dds'},			-- Templar Prism passive cooldown
-- Monster AOE/snare effects
	[69950] = {duration = 3, icon = '/esoui/art/icons/death_recap_magic_aoe.dds'}, 			-- Desecrated Ground (Zombie Snare)
	[60402] = {duration = 3, icon = '/esoui/art/icons/ability_warrior_015.dds'},			-- Ensnare
	[39060] = {duration = 5, icon = '/esoui/art/icons/ability_debuff_root.dds'},			-- Bear Trap
	[81519] = {duration = 10, icon = '/esoui/art/icons/ability_mage_008.dds'},				-- Infallible Aether
--	[8239] = {duration = 5, icon = '/esoui/art/icons/ability_warrior_015.dds'}, 			-- Hamstring
}

local releaseTriggers = {
-- Special case for Defensive Rune
	[24576] = {release = 24574}, -- Defensive Rune I Release
	[62294] = {release = 30182}, -- Defensive Rune II Release
	[62298] = {release = 30188}, -- Defensive Rune III Release
	[62299] = {release = 30194}, -- Defensive Rune IV Release
}

local alternateAura = {
	[26213] = {altName = GetAbilityName(26207), unitTag = 'player'}, -- Display "Restoring Aura" instead of all three auras
	[76420] = {altName = GetAbilityName(34080), unitTag = 'player'}, -- Display "Flames of Oblivion" instead of both auras
}

local procAbilityNames = { -- using names rather than IDs to ease matching multiple IDs to multiple different IDs
	[GetAbilityName(46327)] = false,	-- Crystal Fragments -- special case, controlled by the actual aura
	[GetAbilityName(61907)] = true,		-- Assassin's Will
	[GetAbilityName(62128)] = true,		-- Assassin's Scourge
	[GetAbilityName(23903)] = true,		-- Power Lash
	[GetAbilityName(62549)] = true,		-- Deadly Throw
}

local toggledAuras = { -- there is a seperate abilityID for every rank of a skill
	[23316] = true,			-- Volatile Familiar
	[30664] = true,			-- Volatile Familiar
	[30669] = true,			-- Volatile Familiar
	[30674] = true,			-- Volatile Familiar
	[23304] = true,			-- Unstable Familiar
	[30631] = true,			-- Unstable Familiar
	[30636] = true,			-- Unstable Familiar
	[30641] = true,			-- Unstable Familiar
	[23319] = true,			-- Unstable Clannfear
	[30647] = true,			-- Unstable Clannfear
	[30652] = true,			-- Unstable Clannfear
	[30657] = true,			-- Unstable Clannfear
	[24613] = true,			-- Summon Winged Twilight
	[30581] = true,			-- Summon Winged Twilight
	[30584] = true,			-- Summon Winged Twilight
	[30587] = true,			-- Summon Winged Twilight
	[24639] = true,			-- Summon Twilight Matriarch
	[30618] = true,			-- Summon Twilight Matriarch
	[30622] = true,			-- Summon Twilight Matriarch
	[30626] = true,			-- Summon Twilight Matriarch
	[24636] = true,			-- Summon Twilight Tormentor
	[30592] = true,			-- Summon Twilight Tormentor
	[30595] = true,			-- Summon Twilight Tormentor
	[30598] = true,			-- Summon Twilight Tormentor
	[61529] = true,			-- Stalwart Guard
	[63341] = true,			-- Stalwart Guard
	[63346] = true,			-- Stalwart Guard
	[63351] = true,			-- Stalwart Guard
	[61536] = true,			-- Mystic Guard
	[63323] = true,			-- Mystic Guard
	[63329] = true,			-- Mystic Guard
	[63335] = true,			-- Mystic Guard
	[36908] = true,			-- Leeching Strikes
	[37989] = true,			-- Leeching Strikes
	[38002] = true,			-- Leeching Strikes
	[38015] = true,			-- Leeching Strikes
	[61511] = true,			-- Guard
	[63308] = true,			-- Guard
	[63313] = true,			-- Guard
	[63318] = true,			-- Guard
	[24158] = true,			-- Bound Armor
	[30410] = true,			-- Bound Armor
	[30414] = true,			-- Bound Armor
	[30418] = true,			-- Bound Armor
	[24165] = true,			-- Bound Armaments
	[30422] = true,			-- Bound Armaments
	[30427] = true,			-- Bound Armaments
	[30432] = true,			-- Bound Armaments
	[24163] = true,			-- Bound Aegis
	[30437] = true,			-- Bound Aegis
	[30441] = true,			-- Bound Aegis
	[30445] = true,			-- Bound Aegis
	[116007] = true,		-- Sample Aura (FAKE)
	[116008] = true,		-- Sample Aura (FAKE)
	[24574] = true,			-- Defensive Rune I
	[30182] = true,			-- Defensive Rune II
	[30188] = true,			-- Defensive Rune III
	[30194] = true,			-- Defensive Rune IV
}


-- ------------------------
-- MAIN FILTER TABLES
-- ------------------------
local filterAlwaysIgnored = {
-- Default ignore list
	[29667] = true,		-- Concentration (Light Armour)
	[40359] = true,		-- Fed On Ally (Vampire)
	[45569] = true,		-- Medicinal Use (Alchemy)
	[62760] = true,		-- Spell Shield (Champion Point Ability)
	[63601] = true,		-- ESO Plus Member
	[64160] = true,		-- Crystal Fragments Passive (Not Timed)
	[36603] = true,		-- Soul Siphoner Passive I
	[45155] = true,		-- Soul Siphoner Passive II
	[57472] = true,		-- Rapid Maneuver (Extra Aura)
	[57475] = true,		-- Rapid Maneuver (Extra Aura)
	[57474] = true,		-- Rapid Maneuver (Extra Aura)
	[57476] = true,		-- Rapid Maneuver (Extra Aura)
	[57480]	= true,		-- Rapid Maneuver (Extra Aura)
	[57481]	= true,		-- Rapid Maneuver (Extra Aura)
	[57482]	= true,		-- Rapid Maneuver (Extra Aura)
	[64945] = true,		-- Guard Regen (Guarded Extra)
	[64946] = true,		-- Guard Regen (Guarded Extra)
	[46672] = true,		-- Propelling Shield (Extra Aura)
	[42197] = true,		-- Spinal Surge (Extra Aura)
	[42198] = true,		-- Spinal Surge (Extra Aura)
	[62587] = true,		-- Focused Aim (2s Refreshing Aura)
	[42589] = true,		-- Flawless Dawnbreaker (2s aura on Weaponswap)
	[40782] = true,		-- Acid Spray (Extra Aura)
-- Consolidated multi-auras
	[26215] = true,	-- Redundant Restoring Aura aura
	[26216] = true,	-- Redundant Restoring Aura aura
	[57484] = true,	-- Duplicate Rapid Maneuver on Charging morph
	[80275] = true,	-- Redundant Circle of Protection
	[80280] = true,	-- Redundant Turn Undead
	[80287] = true,	-- Redundant Ring of Preservation
	[80295] = true,	-- Redundant Ring of Preservation
	[76426] = true, -- Redundant Flames of Oblivion
-- Special case for Fighters Guild Beast Trap (and morph) tracking
	[35753] = true, -- Redundant Trap Beast I
	[42710] = true, -- Redundant Trap Beast II
	[42717] = true, -- Redundant Trap Beast III
	[42724] = true, -- Redundant Trap Beast IV
	[40384] = true, -- Redundant Rearming Trap I
	[42732] = true, -- Redundant Rearming Trap II
	[42742] = true, -- Redundant Rearming Trap III
	[42752] = true, -- Redundant Rearming Trap IV
	[40374] = true, -- Redundant Lightweight Beast Trap I
	[42759] = true, -- Redundant Lightweight Beast Trap II
	[42766] = true, -- Redundant Lightweight Beast Trap III
	[42773] = true, -- Redundant Lightweight Beast Trap IV
-- Light Armor active ability redundant buffs
	[41503] = true, -- Annulment Dummy
	[39188] = true, -- Dampen Magic
	[41110] = true, -- Dampen Magic
	[41112] = true, -- Dampen Magic
	[41114] = true, -- Dampen Magic
	[44323] = true, -- Dampen Magic
	[39185] = true, -- Harness Magicka
	[41117] = true, -- Harness Magicka
	[41120] = true, -- Harness Magicka
	[41123] = true, -- Harness Magicka
	[42876] = true, -- Harness Magicka
	[42877] = true, -- Harness Magicka
	[42878] = true, -- Harness Magicka
-- Random blacklisted (thanks Scootworks)
	[29705] = true, -- Whirlpool
	[30455] = true, -- Arachnophobia
	[37136] = true, -- Amulet
	[37342] = true, -- dummy
	[37475] = true, -- ?
	[43588] = true, -- Killing Blow
	[43594] = true, -- Wait for teleport
	[44912] = true, -- Q4730 Shackle Breakign Shakes
	[45050] = true, -- Executioner
	[47718] = true, -- Death Stun
	[49807] = true, -- Killing Blow Stun
	[55406] = true, -- Resurrect Trigger
	[55915] = true, -- Sucked Under Fall Bonus
	[56739] = true, -- Damage Shield
	[57275] = true, -- Shadow Tracker
	[57360] = true, -- Portal
	[57425] = true, -- Brace For Impact
	[57756] = true, -- Blend into Shadows
	[57771] = true, -- Clone Die Counter
	[58107] = true, -- Teleport
	[58210] = true, -- PORTAL CHARGED
	[58241] = true, -- Shadow Orb - Lord Warden
	[58242] = true, -- Fearpicker
	[58955] = true, -- Death Achieve Check
	[59040] = true, -- Teleport Tracker
	[59911] = true, -- Boss Speed
	[60414] = true, -- Tower Destroyed
	[60947] = true, -- Soul Absorbed
	[60967] = true, -- Summon Adds
	[64132] = true, -- Grapple Immunity
	[66808] = true, -- Molag Kena
	[66813] = true, -- White-Gold Tower Item Set
	[69809] = true, -- Hard Mode
	[70113] = true, -- Shade Despawn
}

local filterAuraGroups = {
	['block'] = {
		[14890]	= true,		-- Brace (Generic)
	},
	['cyrodiil'] = {
		[11341] = true,		-- Enemy Keep Bonus I
		[11343] = true,		-- Enemy Keep Bonus II
		[11345] = true,		-- Enemy Keep Bonus III
		[11347] = true,		-- Enemy Keep Bonus IV
		[11348] = true,		-- Enemy Keep Bonus V
		[11350] = true,		-- Enemy Keep Bonus VI
		[11352] = true,		-- Enemy Keep Bonus VII
		[11353] = true,		-- Enemy Keep Bonus VIII
		[12033] = true,		-- Battle Spirit
		[15058]	= true,		-- Offensive Scroll Bonus I
		[15060]	= true,		-- Defensive Scroll Bonus I
		[16348]	= true,		-- Offensive Scroll Bonus II
		[16350]	= true,		-- Defensive Scroll Bonus II
		[39671]	= true,		-- Emperorship Alliance Bonus
	},
	['disguise'] = {
		-- intentionally empty table just so setup can iterate through filters more simply
	},
	['mundusBoon'] = {
		[13940]	= true,		-- Boon: The Warrior
		[13943]	= true,		-- Boon: The Mage
		[13974]	= true,		-- Boon: The Serpent
		[13975]	= true,		-- Boon: The Thief
		[13976]	= true,		-- Boon: The Lady
		[13977]	= true,		-- Boon: The Steed
		[13978]	= true,		-- Boon: The Lord
		[13979]	= true,		-- Boon: The Apprentice
		[13980]	= true,		-- Boon: The Ritual
		[13981]	= true,		-- Boon: The Lover
		[13982]	= true,		-- Boon: The Atronach
		[13984]	= true,		-- Boon: The Shadow
		[13985]	= true,		-- Boon: The Tower
	},
	['soulSummons'] = {
		[39269] = true,		-- Soul Summons (Rank 1)
		[43752] = true,		-- Soul Summons (Rank 2)
		[45590] = true,		-- Soul Summons (Rank 2)
	},
	['vampLycan'] = {
		[35658] = true,		-- Lycanthropy
		[35771]	= true,		-- Stage 1 Vampirism (trivia: has a duration even though others don't)
		[35773]	= true,		-- Stage 2 Vampirism
		[35780]	= true,		-- Stage 3 Vampirism
		[35786]	= true,		-- Stage 4 Vampirism
		[35792]	= true,		-- Stage 4 Vampirism
	},
	['vampLycanBite'] = {
		[40525] = true,		-- Bit an ally
		[40539] = true,		-- Fed on ally
		[39472] = true,		-- Vampirism
		[40521] = true,		-- Sanies Lupinus
	},
}

local filteredAuras = { -- used to hold the abilityIDs of filtered auras
	['player']		= {},
	['reticleover']	= {},
	['groundaoe']	= {}
}


for id in pairs(filterAlwaysIgnored) do -- populate initial ignored auras to filters
	filteredAuras['player'][id]			= true
	filteredAuras['reticleover'][id]	= true
	filteredAuras['groundaoe'][id]		= true
end	-- run once on init of addon

Srendarr.crystalFragments			= GetAbilityName(46324) -- special case for merging frags procs
Srendarr.crystalFragmentsPassive	= GetAbilityName(46327) -- with the general proc system

-- set external references
Srendarr.alteredAuraIcons	= alteredAuraIcons
Srendarr.fakeAuras			= fakeAuras
Srendarr.fakeProcs			= fakeProcs
Srendarr.releaseTriggers	= releaseTriggers
Srendarr.fakeTargetDebuffs	= fakeTargetDebuffs
Srendarr.alternateAura 		= alternateAura
Srendarr.filteredAuras		= filteredAuras
Srendarr.procAbilityNames	= procAbilityNames


-- ------------------------
-- AURA DATA FUNCTIONS
-- ------------------------
function Srendarr.IsToggledAura(abilityID)
	return toggledAuras[abilityID] and true or false
end

function Srendarr.IsMajorEffect(abilityID)
	return majorEffects[abilityID] and true or false
end

function Srendarr.IsMinorEffect(abilityID)
	return minorEffects[abilityID] and true or false
end

function Srendarr.IsEnchantEffect(abilityID)
	if fakeProcs[abilityID] ~= nil then return true else return false end
end

function Srendarr.IsAlternateAura(abilityID)
	if alternateAura[abilityID] ~= nil then return true else return false end
end

function Srendarr:PopulateFilteredAuras()
	for _, filterUnitTag in pairs(filteredAuras) do
		for id in pairs(filterUnitTag) do
			if (not filterAlwaysIgnored[id]) then
				filterUnitTag[id] = nil -- clean out existing filters unless always ignored
			end
		end
	end

	-- populate player aura filters
	for filterGroup, doFilter in pairs(self.db.filtersPlayer) do
		if (filterAuraGroups[filterGroup] and doFilter) then -- filtering this group for player
			for id in pairs(filterAuraGroups[filterGroup]) do
				filteredAuras.player[id] = true
			end
		end
	end

	-- populate target aura filters
	for filterGroup, doFilter in pairs(self.db.filtersTarget) do
		if (doFilter) then
			if (filterGroup == 'majorEffects') then			-- special case for majorEffects
				for id in pairs(majorEffects) do
					filteredAuras.reticleover[id] = true
				end
			elseif (filterGroup == 'minorEffects') then		-- special case for minorEffects
				for id in pairs(minorEffects) do
					filteredAuras.reticleover[id] = true
				end
			elseif (filterAuraGroups[filterGroup]) then
				for id in pairs(filterAuraGroups[filterGroup]) do
					filteredAuras.reticleover[id] = true
				end
			end
		end
	end

	-- populate ground aoe filters
	--

	-- add blacklisted auras to all filter tables
	for _, filterForUnitTag in pairs(filteredAuras) do
		for _, abilityIDs in pairs(self.db.blacklist) do
			for id in pairs(abilityIDs) do
				filterForUnitTag[id] = true
			end
		end
	end
end


-- ------------------------
-- MINOR & MAJOR EFFECT DATA
-- ------------------------
minorEffects = {
	[3929]	= EFFECT_PROTECTION,
	[9611]	= EFFECT_WOUND,
	[28347] = EFFECT_PROTECTION,
	[29308] = EFFECT_MAIM,
	[31818] = EFFECT_RESOLVE,
	[31899] = EFFECT_MAIM,
	[32733] = EFFECT_VITALITY,
	[32761] = EFFECT_WARD,
	[33228] = EFFECT_MAIM,
	[37027] = EFFECT_VITALITY,
	[37031] = EFFECT_VITALITY,
	[37032] = EFFECT_VITALITY,
	[37033] = EFFECT_VITALITY,
	[37247] = EFFECT_RESOLVE,
	[37472] = EFFECT_MAIM,
	[38068] = EFFECT_MAIM,
	[38072] = EFFECT_MAIM,
	[38076] = EFFECT_MAIM,
	[38688] = EFFECT_FRACTURE,
	[38746] = EFFECT_HEROISM,
	[38817] = EFFECT_MAIM,
	[39168] = EFFECT_MANGLE,
	[39180] = EFFECT_MANGLE,
	[39181] = EFFECT_MANGLE,
	[40185] = EFFECT_PROTECTION,
	[42197] = EFFECT_VITALITY,
	[42984] = EFFECT_MANGLE,
	[42986] = EFFECT_MANGLE,
	[42991] = EFFECT_MANGLE,
	[42993] = EFFECT_MANGLE,
	[42998] = EFFECT_MANGLE,
	[43000] = EFFECT_MANGLE,
	[61768] = EFFECT_RESOLVE,
	[61769] = EFFECT_RESOLVE,
	[61770] = EFFECT_RESOLVE,
	[61798] = EFFECT_BRUTALITY,
	[61799] = EFFECT_BRUTALITY,
	[61817] = EFFECT_RESOLVE,
	[61818] = EFFECT_RESOLVE,
	[61819] = EFFECT_RESOLVE,
	[61822] = EFFECT_RESOLVE,
	[61854] = EFFECT_MAIM,
	[61855] = EFFECT_MAIM,
	[61856] = EFFECT_MAIM,
	[61862] = EFFECT_WARD,
	[61863] = EFFECT_WARD,
	[61864] = EFFECT_WARD,
	[61882] = EFFECT_SAVAGERY,
	[61892] = EFFECT_VITALITY,
	[61894] = EFFECT_VITALITY,
	[61896] = EFFECT_VITALITY,
	[61898] = EFFECT_SAVAGERY,
	[62056] = EFFECT_ENDURANCE,
	[62102] = EFFECT_ENDURANCE,
	[62106] = EFFECT_ENDURANCE,
	[62110] = EFFECT_ENDURANCE,
	[62245] = EFFECT_PROTECTION,
	[62246] = EFFECT_PROTECTION,
	[62247] = EFFECT_PROTECTION,
	[62319] = EFFECT_PROPHECY,
	[62320] = EFFECT_PROPHECY,
	[62336] = EFFECT_HEROISM,
	[62337] = EFFECT_HEROISM,
	[62338] = EFFECT_HEROISM,
	[62339] = EFFECT_MAIM,
	[62340] = EFFECT_MAIM,
	[62341] = EFFECT_MAIM,
	[62475] = EFFECT_RESOLVE,
	[62477] = EFFECT_RESOLVE,
	[62481] = EFFECT_RESOLVE,
	[62483] = EFFECT_RESOLVE,
	[62492] = EFFECT_MAIM,
	[62493] = EFFECT_MAIM,
	[62494] = EFFECT_MAIM,
	[62495] = EFFECT_MAIM,
	[62500] = EFFECT_MAIM,
	[62501] = EFFECT_MAIM,
	[62503] = EFFECT_MAIM,
	[62504] = EFFECT_MAIM,
	[62505] = EFFECT_HEROISM,
	[62507] = EFFECT_MAIM,
	[62508] = EFFECT_HEROISM,
	[62509] = EFFECT_MAIM,
	[62510] = EFFECT_HEROISM,
	[62511] = EFFECT_MAIM,
	[62512] = EFFECT_HEROISM,
	[62582] = EFFECT_FRACTURE,
	[62585] = EFFECT_FRACTURE,
	[62588] = EFFECT_FRACTURE,
	[62619] = EFFECT_WARD,
	[62620] = EFFECT_RESOLVE,
	[62621] = EFFECT_WARD,
	[62622] = EFFECT_RESOLVE,
	[62623] = EFFECT_WARD,
	[62624] = EFFECT_RESOLVE,
	[62625] = EFFECT_WARD,
	[62626] = EFFECT_RESOLVE,
	[62627] = EFFECT_WARD,
	[62628] = EFFECT_RESOLVE,
	[62629] = EFFECT_WARD,
	[62630] = EFFECT_RESOLVE,
	[62631] = EFFECT_WARD,
	[62632] = EFFECT_RESOLVE,
	[62633] = EFFECT_WARD,
	[62634] = EFFECT_RESOLVE,
	[62635] = EFFECT_WARD,
	[62636] = EFFECT_BERSERK,
	[62637] = EFFECT_RESOLVE,
	[62638] = EFFECT_WARD,
	[62639] = EFFECT_BERSERK,
	[62640] = EFFECT_RESOLVE,
	[62641] = EFFECT_WARD,
	[62642] = EFFECT_BERSERK,
	[62643] = EFFECT_RESOLVE,
	[62644] = EFFECT_WARD,
	[62645] = EFFECT_BERSERK,
	[62799] = EFFECT_SORCERY,
	[62800] = EFFECT_SORCERY,
	[63340] = EFFECT_VITALITY,
	[63532] = EFFECT_RESOLVE,
	[63558] = EFFECT_EXPEDITION,
	[63561] = EFFECT_EXPEDITION,
	[63562] = EFFECT_EXPEDITION,
	[63563] = EFFECT_EXPEDITION,
	[63571] = EFFECT_WARD,
	[63599] = EFFECT_RESOLVE,
	[63600] = EFFECT_WARD,
	[63602] = EFFECT_RESOLVE,
	[63603] = EFFECT_WARD,
	[63606] = EFFECT_RESOLVE,
	[63607] = EFFECT_WARD,
	[64047] = EFFECT_BERSERK,
	[64048] = EFFECT_BERSERK,
	[64050] = EFFECT_BERSERK,
	[64051] = EFFECT_BERSERK,
	[64052] = EFFECT_BERSERK,
	[64053] = EFFECT_BERSERK,
	[64054] = EFFECT_BERSERK,
	[64055] = EFFECT_BERSERK,
	[64056] = EFFECT_BERSERK,
	[64057] = EFFECT_BERSERK,
	[64058] = EFFECT_BERSERK,
	[64080] = EFFECT_VITALITY,
	[64081] = EFFECT_VITALITY,
	[64082] = EFFECT_VITALITY,
	[64144] = EFFECT_FRACTURE,
	[64145] = EFFECT_FRACTURE,
	[64146] = EFFECT_FRACTURE,
	[64147] = EFFECT_FRACTURE,
	[64178] = EFFECT_BERSERK,
	[64255] = EFFECT_FRACTURE,
	[64256] = EFFECT_BREACH,
	[64258] = EFFECT_SORCERY,
	[64259] = EFFECT_BRUTALITY,
	[64260] = EFFECT_SAVAGERY,
	[64261] = EFFECT_PROPHECY,
	[64954] = EFFECT_EROSION,
	[64955] = EFFECT_EROSION,
	[64956] = EFFECT_EROSION,
	[64957] = EFFECT_EROSION,
	[68359] = EFFECT_MAIM,
	[68512] = EFFECT_WARD,
	[68513] = EFFECT_WARD,
	[68514] = EFFECT_WARD,
	[68515] = EFFECT_WARD,
	[68588] = EFFECT_BREACH,
	[68589] = EFFECT_BREACH,
	[68591] = EFFECT_BREACH,
	[68592] = EFFECT_BREACH,
	[68595] = EFFECT_FORCE,
	[68596] = EFFECT_FORCE,
	[68597] = EFFECT_FORCE,
	[68598] = EFFECT_FORCE,
	[68628] = EFFECT_FORCE,
	[68629] = EFFECT_FORCE,
	[68630] = EFFECT_FORCE,
	[68631] = EFFECT_FORCE,
	[68632] = EFFECT_FORCE,
	[68636] = EFFECT_FORCE,
	[68638] = EFFECT_FORCE,
	[68640] = EFFECT_FORCE,
	[76037] = EFFECT_BERSERK,
	[76564] = EFFECT_FORCE,
	[76724] = EFFECT_PROTECTION,
	[76725] = EFFECT_PROTECTION,
	[76726] = EFFECT_PROTECTION,
	[76727] = EFFECT_PROTECTION,
	[77056] = EFFECT_PROTECTION,
	[77057] = EFFECT_PROTECTION,
	[77058] = EFFECT_PROTECTION,
	[77059] = EFFECT_PROTECTION,
	[77418] = EFFECT_INTELLECT,
	[77419] = EFFECT_INTELLECT,
	[77420] = EFFECT_INTELLECT,
	[77421] = EFFECT_INTELLECT,
}

majorEffects = {
	[18868] = EFFECT_WARD,
	[21927] = EFFECT_DEFILE,
	[22236] = EFFECT_RESOLVE,
	[23216] = EFFECT_EXPEDITION,
	[23673] = EFFECT_BRUTALITY,
	[24153] = EFFECT_DEFILE,
	[24686] = EFFECT_DEFILE,
	[24702] = EFFECT_DEFILE,
	[24703] = EFFECT_DEFILE,
	[26220] = EFFECT_ENDURANCE,
	[26795] = EFFECT_SAVAGERY,
	[26809] = EFFECT_ENDURANCE,
	[26999] = EFFECT_ENDURANCE,
	[27005] = EFFECT_ENDURANCE,
	[27011] = EFFECT_ENDURANCE,
	[27020] = EFFECT_ENDURANCE,
	[27026] = EFFECT_ENDURANCE,
	[27032] = EFFECT_ENDURANCE,
	[27190] = EFFECT_SAVAGERY,
	[27194] = EFFECT_SAVAGERY,
	[27198] = EFFECT_SAVAGERY,
	[28307] = EFFECT_FRACTURE,
	[29011] = EFFECT_FORTITUDE,
	[29230] = EFFECT_DEFLIE,
	[31759] = EFFECT_MENDING,
	[32748] = EFFECT_ENDURANCE,
	[33210] = EFFECT_EXPEDITION,
	[33317] = EFFECT_BRUTALITY,
	[33328] = EFFECT_EXPEDITION,
	[33363] = EFFECT_BREACH,
	[33399] = EFFECT_DEFILE,
	[34734] = EFFECT_FRACTURE,
	[36050] = EFFECT_EXPEDITION,
	[36228] = EFFECT_FRACTURE,
	[36232] = EFFECT_FRACTURE,
	[36236] = EFFECT_FRACTURE,
	[36509] = EFFECT_DEFILE,
	[36515] = EFFECT_DEFILE,
	[36894] = EFFECT_BRUTALITY,
	[36903] = EFFECT_BRUTALITY,
	[36946] = EFFECT_EXPEDITION,
	[36959] = EFFECT_EXPEDITION,
	[36972] = EFFECT_BREACH,
	[36973] = EFFECT_BERSERK,
	[36980] = EFFECT_BREACH,
	[37511] = EFFECT_DEFILE,
	[37515] = EFFECT_DEFILE,
	[37519] = EFFECT_DEFILE,
	[37523] = EFFECT_DEFILE,
	[37528] = EFFECT_DEFILE,
	[37533] = EFFECT_DEFILE,
	[37538] = EFFECT_DEFILE,
	[37542] = EFFECT_DEFILE,
	[37546] = EFFECT_DEFILE,
	[37591] = EFFECT_BREACH,
	[37599] = EFFECT_BREACH,
	[37607] = EFFECT_BREACH,
	[37618] = EFFECT_BREACH,
	[37627] = EFFECT_BREACH,
	[37636] = EFFECT_BREACH,
	[37645] = EFFECT_BERSERK,
	[37654] = EFFECT_BERSERK,
	[37663] = EFFECT_BERSERK,
	[37789] = EFFECT_EXPEDITION,
	[37793] = EFFECT_EXPEDITION,
	[37797] = EFFECT_EXPEDITION,
	[37852] = EFFECT_EXPEDITION,
	[37859] = EFFECT_EXPEDITION,
	[37866] = EFFECT_EXPEDITION,
	[37873] = EFFECT_EXPEDITION,
	[37881] = EFFECT_EXPEDITION,
	[37889] = EFFECT_EXPEDITION,
	[37897] = EFFECT_EXPEDITION,
	[37906] = EFFECT_EXPEDITION,
	[37915] = EFFECT_EXPEDITION,
	[37924] = EFFECT_BRUTALITY,
	[37927] = EFFECT_BRUTALITY,
	[37930] = EFFECT_BRUTALITY,
	[37933] = EFFECT_BRUTALITY,
	[37936] = EFFECT_BRUTALITY,
	[37939] = EFFECT_BRUTALITY,
	[37942] = EFFECT_BRUTALITY,
	[37947] = EFFECT_BRUTALITY,
	[37952] = EFFECT_BRUTALITY,
	[38686] = EFFECT_DEFILE,
	[38838] = EFFECT_DEFILE,
	[40175] = EFFECT_FORTITUDE,
	[40225] = EFFECT_FORCE,
	[40443] = EFFECT_FORTITUDE,
	[42285] = EFFECT_FORTITUDE,
	[42288] = EFFECT_FORTITUDE,
	[42291] = EFFECT_FORTITUDE,
	[44820] = EFFECT_WARD,
	[44821] = EFFECT_WARD,
	[44822] = EFFECT_RESOLVE,
	[44823] = EFFECT_WARD,
	[44824] = EFFECT_RESOLVE,
	[44825] = EFFECT_WARD,
	[44826] = EFFECT_RESOLVE,
	[44827] = EFFECT_WARD,
	[44828] = EFFECT_RESOLVE,
	[44829] = EFFECT_WARD,
	[44830] = EFFECT_RESOLVE,
	[44831] = EFFECT_WARD,
	[44832] = EFFECT_RESOLVE,
	[44833] = EFFECT_WARD,
	[44834] = EFFECT_RESOLVE,
	[44835] = EFFECT_WARD,
	[44836] = EFFECT_RESOLVE,
	[44838] = EFFECT_WARD,
	[44839] = EFFECT_RESOLVE,
	[44840] = EFFECT_WARD,
	[44841] = EFFECT_RESOLVE,
	[44842] = EFFECT_WARD,
	[44843] = EFFECT_RESOLVE,
	[44854] = EFFECT_PROTECTION,
	[44857] = EFFECT_PROTECTION,
	[44859] = EFFECT_PROTECTION,
	[44860] = EFFECT_PROTECTION,
	[44862] = EFFECT_PROTECTION,
	[44863] = EFFECT_PROTECTION,
	[44864] = EFFECT_PROTECTION,
	[44865] = EFFECT_PROTECTION,
	[44866] = EFFECT_PROTECTION,
	[44867] = EFFECT_PROTECTION,
	[44868] = EFFECT_PROTECTION,
	[44869] = EFFECT_PROTECTION,
	[44871] = EFFECT_PROTECTION,
	[44872] = EFFECT_PROTECTION,
	[44874] = EFFECT_PROTECTION,
	[44876] = EFFECT_PROTECTION,
	[45076] = EFFECT_WARD,
	[48078] = EFFECT_BERSERK,
	[48946] = EFFECT_FRACTURE,
	[53881] = EFFECT_SPELL_SHATTER,
	[55033] = EFFECT_MENDING,
	[58869] = EFFECT_DEFILE,
	[61670] = EFFECT_BRUTALITY,
	[61758] = EFFECT_MENDING,
	[61759] = EFFECT_MENDING,
	[61760] = EFFECT_MENDING,
	[61815] = EFFECT_RESOLVE,
	[61816] = EFFECT_WARD,
	[61820] = EFFECT_RESOLVE,
	[61821] = EFFECT_WARD,
	[61823] = EFFECT_RESOLVE,
	[61824] = EFFECT_WARD,
	[61825] = EFFECT_RESOLVE,
	[61826] = EFFECT_WARD,
	[61827] = EFFECT_RESOLVE,
	[61828] = EFFECT_WARD,
	[61829] = EFFECT_RESOLVE,
	[61830] = EFFECT_WARD,
	[61831] = EFFECT_RESOLVE,
	[61832] = EFFECT_WARD,
	[61833] = EFFECT_EXPEDITION,
	[61834] = EFFECT_WARD,
	[61835] = EFFECT_RESOLVE,
	[61836] = EFFECT_RESOLVE,
	[61837] = EFFECT_WARD,
	[61838] = EFFECT_EXPEDITION,
	[61839] = EFFECT_EXPEDITION,
	[61840] = EFFECT_EXPEDITION,
	[61841] = EFFECT_RESOLVE,
	[61842] = EFFECT_WARD,
	[61843] = EFFECT_WARD,
	[61844] = EFFECT_RESOLVE,
	[61845] = EFFECT_WARD,
	[61846] = EFFECT_RESOLVE,
	[61871] = EFFECT_FORTITUDE,
	[61872] = EFFECT_FORTITUDE,
	[61873] = EFFECT_FORTITUDE,
	[61884] = EFFECT_FORTITUDE,
	[61885] = EFFECT_FORTITUDE,
	[61886] = EFFECT_ENDURANCE,
	[61887] = EFFECT_FORTITUDE,
	[61888] = EFFECT_ENDURANCE,
	[61889] = EFFECT_ENDURANCE,
	[61890] = EFFECT_FORTITUDE,
	[61891] = EFFECT_FORTITUDE,
	[61893] = EFFECT_FORTITUDE,
	[61895] = EFFECT_FORTITUDE,
	[61897] = EFFECT_FORTITUDE,
	[61909] = EFFECT_FRACTURE,
	[61910] = EFFECT_FRACTURE,
	[61911] = EFFECT_FRACTURE,
	[62057] = EFFECT_BRUTALITY,
	[62058] = EFFECT_BRUTALITY,
	[62059] = EFFECT_BRUTALITY,
	[62060] = EFFECT_BRUTALITY,
	[62062] = EFFECT_SORCERY,
	[62063] = EFFECT_BRUTALITY,
	[62064] = EFFECT_SORCERY,
	[62065] = EFFECT_BRUTALITY,
	[62066] = EFFECT_SORCERY,
	[62067] = EFFECT_BRUTALITY,
	[62068] = EFFECT_SORCERY,
	[62147] = EFFECT_BRUTALITY,
	[62150] = EFFECT_BRUTALITY,
	[62153] = EFFECT_BRUTALITY,
	[62156] = EFFECT_BRUTALITY,
	[62159] = EFFECT_RESOLVE,
	[62160] = EFFECT_WARD,
	[62161] = EFFECT_RESOLVE,
	[62162] = EFFECT_WARD,
	[62163] = EFFECT_RESOLVE,
	[62164] = EFFECT_WARD,
	[62165] = EFFECT_RESOLVE,
	[62166] = EFFECT_WARD,
	[62167] = EFFECT_WARD,
	[62168] = EFFECT_RESOLVE,
	[62169] = EFFECT_RESOLVE,
	[62170] = EFFECT_WARD,
	[62171] = EFFECT_RESOLVE,
	[62172] = EFFECT_WARD,
	[62173] = EFFECT_RESOLVE,
	[62174] = EFFECT_WARD,
	[62175] = EFFECT_RESOLVE,
	[62176] = EFFECT_WARD,
	[62179] = EFFECT_RESOLVE,
	[62180] = EFFECT_WARD,
	[62181] = EFFECT_EXPEDITION,
	[62184] = EFFECT_RESOLVE,
	[62185] = EFFECT_WARD,
	[62186] = EFFECT_EXPEDITION,
	[62189] = EFFECT_RESOLVE,
	[62190] = EFFECT_WARD,
	[62191] = EFFECT_EXPEDITION,
	[62195] = EFFECT_BERSERK,
	[62240] = EFFECT_SORCERY,
	[62241] = EFFECT_SORCERY,
	[62242] = EFFECT_SORCERY,
	[62243] = EFFECT_SORCERY,
	[62249] = EFFECT_EXPEDITION,
	[62250] = EFFECT_FORTITUDE,
	[62251] = EFFECT_ENDURANCE,
	[62252] = EFFECT_INTELLECT,
	[62256] = EFFECT_EXPEDITION,
	[62257] = EFFECT_FORTITUDE,
	[62258] = EFFECT_ENDURANCE,
	[62259] = EFFECT_INTELLECT,
	[62263] = EFFECT_EXPEDITION,
	[62264] = EFFECT_FORTITUDE,
	[62265] = EFFECT_ENDURANCE,
	[62266] = EFFECT_INTELLECT,
	[62270] = EFFECT_EXPEDITION,
	[62271] = EFFECT_FORTITUDE,
	[62272] = EFFECT_ENDURANCE,
	[62273] = EFFECT_INTELLECT,
	[62344] = EFFECT_BRUTALITY,
	[62347] = EFFECT_BRUTALITY,
	[62350] = EFFECT_BRUTALITY,
	[62387] = EFFECT_BRUTALITY,
	[62392] = EFFECT_BRUTALITY,
	[62396] = EFFECT_BRUTALITY,
	[62400] = EFFECT_BRUTALITY,
	[62415] = EFFECT_BRUTALITY,
	[62425] = EFFECT_BRUTALITY,
	[62441] = EFFECT_BRUTALITY,
	[62448] = EFFECT_BRUTALITY,
	[62470] = EFFECT_FRACTURE,
	[62471] = EFFECT_FRACTURE,
	[62473] = EFFECT_FRACTURE,
	[62474] = EFFECT_FRACTURE,
	[62476] = EFFECT_FRACTURE,
	[62480] = EFFECT_FRACTURE,
	[62482] = EFFECT_FRACTURE,
	[62484] = EFFECT_FRACTURE,
	[62485] = EFFECT_BREACH,
	[62486] = EFFECT_BREACH,
	[62487] = EFFECT_FRACTURE,
	[62488] = EFFECT_FRACTURE,
	[62489] = EFFECT_BREACH,
	[62490] = EFFECT_FRACTURE,
	[62491] = EFFECT_BREACH,
	[62513] = EFFECT_DEFILE,
	[62514] = EFFECT_DEFILE,
	[62515] = EFFECT_DEFILE,
	[62531] = EFFECT_EXPEDITION,
	[62537] = EFFECT_EXPEDITION,
	[62540] = EFFECT_EXPEDITION,
	[62543] = EFFECT_EXPEDITION,
	[62578] = EFFECT_DEFILE,
	[62579] = EFFECT_DEFILE,
	[62580] = EFFECT_DEFILE,
	[62747] = EFFECT_PROPHECY,
	[62748] = EFFECT_PROPHECY,
	[62749] = EFFECT_PROPHECY,
	[62750] = EFFECT_PROPHECY,
	[62751] = EFFECT_PROPHECY,
	[62752] = EFFECT_PROPHECY,
	[62753] = EFFECT_PROPHECY,
	[62754] = EFFECT_PROPHECY,
	[62755] = EFFECT_PROPHECY,
	[62756] = EFFECT_PROPHECY,
	[62757] = EFFECT_PROPHECY,
	[62758] = EFFECT_PROPHECY,
	[62772] = EFFECT_SPELL_SHATTER,
	[62773] = EFFECT_SPELL_SHATTER,
	[62774] = EFFECT_SPELL_SHATTER,
	[62775] = EFFECT_SPELL_SHATTER,
	[62780] = EFFECT_SPELL_SHATTER,
	[62783] = EFFECT_SPELL_SHATTER,
	[62786] = EFFECT_SPELL_SHATTER,
	[62787] = EFFECT_SPELL_SHATTER,
	[62789] = EFFECT_SPELL_SHATTER,
	[62792] = EFFECT_SPELL_SHATTER,
	[62795] = EFFECT_SPELL_SHATTER,
	[63015] = EFFECT_EVASION,
	[63016] = EFFECT_EVASION,
	[63017] = EFFECT_EVASION,
	[63018] = EFFECT_EVASION,
	[63019] = EFFECT_EVASION,
	[63023] = EFFECT_EVASION,
	[63026] = EFFECT_EVASION,
	[63028] = EFFECT_EVASION,
	[63030] = EFFECT_EVASION,
	[63036] = EFFECT_EVASION,
	[63040] = EFFECT_EVASION,
	[63042] = EFFECT_EVASION,
	[63084] = EFFECT_RESOLVE,
	[63085] = EFFECT_WARD,
	[63088] = EFFECT_RESOLVE,
	[63089] = EFFECT_WARD,
	[63091] = EFFECT_RESOLVE,
	[63092] = EFFECT_WARD,
	[63116] = EFFECT_RESOLVE,
	[63117] = EFFECT_WARD,
	[63119] = EFFECT_RESOLVE,
	[63120] = EFFECT_WARD,
	[63123] = EFFECT_RESOLVE,
	[63124] = EFFECT_WARD,
	[63127] = EFFECT_RESOLVE,
	[63128] = EFFECT_WARD,
	[63131] = EFFECT_RESOLVE,
	[63132] = EFFECT_WARD,
	[63134] = EFFECT_RESOLVE,
	[63135] = EFFECT_WARD,
	[63137] = EFFECT_RESOLVE,
	[63138] = EFFECT_WARD,
	[63140] = EFFECT_RESOLVE,
	[63141] = EFFECT_WARD,
	[63143] = EFFECT_RESOLVE,
	[63144] = EFFECT_WARD,
	[63148] = EFFECT_DEFILE,
	[63223] = EFFECT_SORCERY,
	[63224] = EFFECT_SORCERY,
	[63225] = EFFECT_SORCERY,
	[63226] = EFFECT_SORCERY,
	[63227] = EFFECT_SORCERY,
	[63228] = EFFECT_SORCERY,
	[63229] = EFFECT_SORCERY,
	[63230] = EFFECT_SORCERY,
	[63231] = EFFECT_SORCERY,
	[63232] = EFFECT_SORCERY,
	[63233] = EFFECT_SORCERY,
	[63234] = EFFECT_SORCERY,
	[63533] = EFFECT_VITALITY,
	[63534] = EFFECT_VITALITY,
	[63535] = EFFECT_VITALITY,
	[63536] = EFFECT_VITALITY,
	[63909] = EFFECT_FRACTURE,
	[63912] = EFFECT_FRACTURE,
	[63913] = EFFECT_FRACTURE,
	[63914] = EFFECT_FRACTURE,
	[63915] = EFFECT_FRACTURE,
	[63916] = EFFECT_FRACTURE,
	[63917] = EFFECT_FRACTURE,
	[63918] = EFFECT_FRACTURE,
	[63919] = EFFECT_FRACTURE,
	[63920] = EFFECT_FRACTURE,
	[63921] = EFFECT_BREACH,
	[63922] = EFFECT_FRACTURE,
	[63923] = EFFECT_BREACH,
	[63924] = EFFECT_FRACTURE,
	[63925] = EFFECT_BREACH,
	[63987] = EFFECT_EXPEDITION,
	[63993] = EFFECT_EXPEDITION,
	[63999] = EFFECT_EXPEDITION,
	[64005] = EFFECT_EXPEDITION,
	[64012] = EFFECT_EXPEDITION,
	[64019] = EFFECT_EXPEDITION,
	[64026] = EFFECT_EXPEDITION,
	[64166] = EFFECT_PROTECTION,
	[64251] = EFFECT_BREACH,
	[64254] = EFFECT_FRACTURE,
	[64509] = EFFECT_SAVAGERY,
	[64562] = EFFECT_WARD,
	[64952] = EFFECT_SAVAGERY,
	[65133] = EFFECT_HEROISM,
	[66075] = EFFECT_RESOLVE,
	[66083] = EFFECT_RESOLVE,
	[67708] = EFFECT_EXPEDITION,
	[67714] = EFFECT_EXPEDITION,
	[67715] = EFFECT_EXPEDITION,
	[67716] = EFFECT_EXPEDITION,
	[68163] = EFFECT_DEFILE,
	[68164] = EFFECT_DEFILE,
	[68165] = EFFECT_DEFILE,
	[68793] = EFFECT_EXPEDITION,
	[68795] = EFFECT_EXPEDITION,
	[68797] = EFFECT_ENDURANCE,
	[68799] = EFFECT_ENDURANCE,
	[68800] = EFFECT_ENDURANCE,
	[68801] = EFFECT_ENDURANCE,
	[68804] = EFFECT_BRUTALITY,
	[68805] = EFFECT_BRUTALITY,
	[68806] = EFFECT_BRUTALITY,
	[68807] = EFFECT_BRUTALITY,
	[68814] = EFFECT_BRUTALITY,
	[68815] = EFFECT_BRUTALITY,
	[68816] = EFFECT_BRUTALITY,
	[68817] = EFFECT_BRUTALITY,
	[68843] = EFFECT_BRUTALITY,
	[68845] = EFFECT_BRUTALITY,
	[68852] = EFFECT_BRUTALITY,
	[68859] = EFFECT_BRUTALITY,
	[69685] = EFFECT_EVASION,
	[72655] = EFFECT_EXPEDITION,
	[72656] = EFFECT_EXPEDITION,
	[72657] = EFFECT_EXPEDITION,
	[72658] = EFFECT_EXPEDITION,
	[76044] = EFFECT_EXPEDITION,
	[76420] = EFFECT_PROPHECY,
	[76426] = EFFECT_SAVAGERY,
	[76433] = EFFECT_PROPHECY,
	[76057] = EFFECT_PROPHECY,
	[76498] = EFFECT_EXPEDITION,
	[76499] = EFFECT_EXPEDITION,
	[76500] = EFFECT_EXPEDITION,
	[76501] = EFFECT_EXPEDITION,
	[76502] = EFFECT_EXPEDITION,
	[76503] = EFFECT_EXPEDITION,
	[76504] = EFFECT_EXPEDITION,
	[76505] = EFFECT_EXPEDITION,
	[76506] = EFFECT_EXPEDITION,
	[76507] = EFFECT_EXPEDITION,
	[76509] = EFFECT_EXPEDITION,
	[76510] = EFFECT_EXPEDITION,
	[76518] = EFFECT_BRUTALITY,
	[76519] = EFFECT_BRUTALITY,
	[76520] = EFFECT_BRUTALITY,
	[76521] = EFFECT_BRUTALITY,
	[77031] = EFFECT_INTELLECT,
	[77033] = EFFECT_INTELLECT,
	[77034] = EFFECT_INTELLECT,
	[77035] = EFFECT_INTELLECT,
	[77082] = EFFECT_MENDING,
	[77918] = EFFECT_MENDING,
	[77922] = EFFECT_MENDING,
	[77945] = EFFECT_PROPHECY,
	[77958] = EFFECT_PROPHECY,
	[77928] = EFFECT_PROPHECY,
	[77955] = EFFECT_PROPHECY,
	[75088] = EFFECT_PROPHECY,
}


-- ------------------------
-- AURA DATA DEBUG & PATCH FUNCTIONS
-- Used after patches to assist in getting hold of changed abilityIDs (messy, only uncomment when needed to use)
-- ------------------------

--[[
function GetToggled()
	-- returns all abilityIDs that match the names used as toggledAuras
	-- used to grab ALL the nessecary abilityIDs for the table after a patch changes things
	local data, names, saved = {}, {}, {}

	for k, v in pairs(toggledAuras) do
		names[GetAbilityName(k)] = true
	end

	for x = 1, 100000 do
		if (DoesAbilityExist(x) and names[GetAbilityName(x)] and GetAbilityDuration(x) == 0 and GetAbilityDescription(x) ~= '') then
			table.insert(data, {(GetAbilityName(x)), x, GetAbilityDescription(x)})
		end
	end

	table.sort(data, function(a, b)	return a[1] > b[1] end)

	for k, v in ipairs(data) do
		d(v[2] .. ' ' .. v[1] .. '      ' .. string.sub(v[3], 1, 30))
		table.insert(saved, v[2] .. '|' .. v[1]..'||' ..string.sub(v[3],1,30))
	end

	--SrendarrDB.toggled = saved
end
]]

--[[
function GetMajorEffects()
	local name
	SrendarrDB.majorBuffs = {}

	for id = 3000, 100000 do -- haven't seen any outside of these ids so compact search space a bit
		if (DoesAbilityExist(id) and GetAbilityDuration(id) > 0) then
			name = string.sub(GetAbilityName(id), 1, 6)

			if (name == 'Major ') then
--				table.insert(SrendarrDB.majorBuffs, string.format('[%d] = %s, ', id, GetAbilityName(id)))
				table.insert(SrendarrDB.majorBuffs, string.format('%d|%s|%d|%s', id, GetAbilityName(id), GetAbilityDuration(id), GetAbilityIcon(id)))
			end
		end
	end
end
]]
--[[
function GetMinorEffects()
	local name
	SrendarrDB.minorBuffs = {}

	for id = 3000, 100000 do -- haven't seen any outside of these ids so compact search space a bit
		if (DoesAbilityExist(id) and GetAbilityDuration(id) > 0) then
			name = string.sub(GetAbilityName(id), 1, 6)

			if (name == 'Minor ') then
--				table.insert(SrendarrDB.minorBuffs, string.format('[%d] = %s, ', id, GetAbilityName(id)))
				table.insert(SrendarrDB.minorBuffs, string.format('%d|%s|%d|%s', id, GetAbilityName(id), GetAbilityDuration(id), GetAbilityIcon(id)))
			end
		end
	end
end
]]
--[[
function GetAurasByName(name)
	for x = 1, 100000 do
		if (DoesAbilityExist(x) and GetAbilityName(x) == name and GetAbilityDuration(x) > 0) then
			d('['..x ..'] '..GetAbilityName(x) .. '-' .. GetAbilityDuration(x) .. '-' .. GetAbilityDescription(x))
		end
	end
end
]]
--[[
function GetAuraInfo(idA, idB)
	d(string.format('[%d] %s (%ds) - %s', idA, GetAbilityName(idA), GetAbilityDuration(idA), GetAbilityDescription(idA)))
	d(string.format('[%d] %s (%ds) - %s', idB, GetAbilityName(idB), GetAbilityDuration(idB), GetAbilityDescription(idB)))
end
]]
