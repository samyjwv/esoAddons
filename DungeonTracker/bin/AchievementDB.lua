local DTAddon = _G['DTAddon']

DTAddon.DungeonIndex = {
-- vII = ID (in [] to left) of alt version if dungeon has two versions
-- nA = Full normal mode dungeon clear achievement ID
-- vA = Full veteran mode dungeon clear achievement ID
-- fP = Faction dungeon completion achievement ID
[1] =	{nodeIndex = 192,	vII = 0,	nA = 272,	vA = 1604,	fP = 1073,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Arx Corinium
[2] =	{nodeIndex = 194,	vII = 3,	nA = 325,	vA = 1549,	fP = 1075,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Banished Cells I
[3] =	{nodeIndex = 262,	vII = 2,	nA = 1555,	vA = 545,	fP = 1075,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Banished Cells II
[4] =	{nodeIndex = 186,	vII = 0,	nA = 410,	vA = 1647,	fP = 1074,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Blackheart Haven
[5] =	{nodeIndex = 187,	vII = 0,	nA = 393,	vA = 1641,	fP = 1073,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Blessed Crucible
[6] =	{nodeIndex = 197,	vII = 7,	nA = 551,	vA = 1597,	fP = 1075,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- City of Ash I
[7] =	{nodeIndex = 268,	vII = 6,	nA = 1603,	vA = 878,	fP = 1075,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- City of Ash II
[8] =	{nodeIndex = 261,	vII = 0,	nA = 1522,	vA = 1523,	fP = 0,		icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Cradle of Shadows
[9] =	{nodeIndex = 190,	vII = 10,	nA = 80,	vA = 1610,	fP = 1074,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Crypt of Hearts I
[10] =	{nodeIndex = 269,	vII = 9,	nA = 1616,	vA = 876,	fP = 1074,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Crypt of Hearts II
[11] =	{nodeIndex = 198,	vII = 12,	nA = 78,	vA = 1581,	fP = 1073,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Darkshade Caverns I
[12] =	{nodeIndex = 264,	vII = 11,	nA = 1587,	vA = 464,	fP = 1073,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Darkshade Caverns II
[13] =	{nodeIndex = 195,	vII = 0,	nA = 357,	vA = 1623,	fP = 1073,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Direfrost Keep
[14] =	{nodeIndex = 191,	vII = 15,	nA = 11,	vA = 1573,	fP = 1075,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Elden Hollow I
[15] =	{nodeIndex = 265,	vII = 14,	nA = 1579,	vA = 459,	fP = 1075,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Elden Hollow II
[16] =	{nodeIndex = 98,	vII = 17,	nA = 294,	vA = 1556,	fP = 1073,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Fungal Grotto I
[17] =	{nodeIndex = 266,	vII = 16,	nA = 1562,	vA = 343,	fP = 1073,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Fungal Grotto II
[18] =	{nodeIndex = 236,	vII = 0,	nA = 1345,	vA = 880,	fP = 0,		icon = "|t48:48:/esoui/art/campaign/gamepad/gp_overview_menuicon_emperor.dds|t"},	-- Imperial City Prison
[19] =	{nodeIndex = 260,	vII = 0,	nA = 1504,	vA = 1505,	fP = 0,		icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Ruins of Mazzatun
[20] =	{nodeIndex = 185,	vII = 0,	nA = 417,	vA = 1635,	fP = 1075,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Selene's Web
[21] =	{nodeIndex = 193,	vII = 22,	nA = 301,	vA = 1565,	fP = 1074,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Spindleclutch I
[22] =	{nodeIndex = 267,	vII = 21,	nA = 1571,	vA = 421,	fP = 1074,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Spindleclutch II
[23] =	{nodeIndex = 188,	vII = 0,	nA = 81,	vA = 1617,	fP = 1075,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Tempest Island
[24] =	{nodeIndex = 184,	vII = 0,	nA = 570,	vA = 1653,	fP = 0,		icon = "|t34:34:/esoui/art/journal/gamepad/gp_questtypeicon_mainstory.dds|t"},		-- Vaults of Madness
[25] =	{nodeIndex = 196,	vII = 0,	nA = 391,	vA = 1629,	fP = 1074,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Volenfell
[26] =	{nodeIndex = 189,	vII = 27,	nA = 79,	vA = 1589,	fP = 1074,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Wayrest Sewers I
[27] =	{nodeIndex = 263,	vII = 26,	nA = 1595,	vA = 678,	fP = 1074,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Wayrest Sewers II
[28] =	{nodeIndex = 247,	vII = 0,	nA = 1346,	vA = 1120,	fP = 0,		icon = "|t48:48:/esoui/art/campaign/gamepad/gp_overview_menuicon_emperor.dds|t"},	-- White-Gold Tower
[29] =	{nodeIndex = 258,	vII = 0,	nA = 1343,	vA = 1368,	fP = 0,		icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Maw of Lorkhaj
[30] =	{nodeIndex = 231,	vII = 0,	nA = 990,	vA = 1503,	fP = 0,		icon = "|t48:48:/esoui/art/tutorial/ava_rankicon64_overlord.dds|t"},				-- Aetherian Archive
[31] =	{nodeIndex = 230,	vII = 0,	nA = 991,	vA = 1474,	fP = 0,		icon = "|t48:48:/esoui/art/tutorial/ava_rankicon64_overlord.dds|t"},				-- Hel Ra Citadel
[32] =	{nodeIndex = 232,	vII = 0,	nA = 1123,	vA = 1462,	fP = 0,		icon = "|t48:48:/esoui/art/tutorial/ava_rankicon64_overlord.dds|t"},				-- Sanctum Ophidia

}

DTAddon.DelveIndex = {
-- bA = All delve bosses defeated achievement ID
-- gA = Group challenge skillpoint achievement ID
-- fP = Faction delve completion achievement ID
[1] =	{zoneIndex = 2,		poiIndex = 41,	bA = 1053,	gA = 380,	fP = 1070,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},		-- Bad Man's Hallows
[2] =	{zoneIndex = 4,		poiIndex = 21,	bA = 1054,	gA = 714,	fP = 1070,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},		-- Bonesnap Ruins
[3] =	{zoneIndex = 11,	poiIndex = 37,	bA = 1051,	gA = 460,	fP = 1069,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},			-- Crimson Cove
[4] =	{zoneIndex = 9,		poiIndex = 18,	bA = 368,	gA = 379,	fP = 1068,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},		-- Crow's Wood
[5] =	{zoneIndex = 10,	poiIndex = 20,	bA = 370,	gA = 388,	fP = 1068,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},		-- Forgotten Crypts
[6] =	{zoneIndex = 15,	poiIndex = 37,	bA = 376,	gA = 381,	fP = 1068,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},		-- Hall of the Dead
[7] =	{zoneIndex = 16,	poiIndex = 31,	bA = 374,	gA = 371,	fP = 1068,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},		-- Lion's Den
[8] =	{zoneIndex = 17,	poiIndex = 28,	bA = 396,	gA = 707,	fP = 1070,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},		-- Na-Totambu
[9] =	{zoneIndex = 5,		poiIndex = 16,	bA = 378,	gA = 713,	fP = 1070,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},		-- Obsidian Scar
[10] =	{zoneIndex = 367,	poiIndex = 2,	bA = 1239,	gA = 1238,	fP = 1257,	icon = "|t48:48:/esoui/art/mappins/ava_imperialdistrict_neutral.dds|t"},		-- Old Orsinium
[11] =	{zoneIndex = 14,	poiIndex = 16,	bA = 1055,	gA = 708,	fP = 1070,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},		-- Razak's Wheel
[12] =	{zoneIndex = 367,	poiIndex = 29,	bA = 1236,	gA = 1235,	fP = 1257,	icon = "|t48:48:/esoui/art/mappins/ava_imperialdistrict_neutral.dds|t"},		-- Rkindaleft
[13] =	{zoneIndex = 180,	poiIndex = 2,	bA = 1049,	gA = 470,	fP = 1069,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},			-- Root Sunder
[14] =	{zoneIndex = 18,	poiIndex = 1,	bA = 1050,	gA = 445,	fP = 1069,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},			-- Rulanyil's Fall
[15] =	{zoneIndex = 19,	poiIndex = 40,	bA = 300,	gA = 372,	fP = 1068,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},		-- Sanguine's Demesne
[16] =	{zoneIndex = 178,	poiIndex = 40,	bA = 390,	gA = 468,	fP = 1069,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},			-- Toothmaul Gully Group Event	
[17] =	{zoneIndex = 179,	poiIndex = 23,	bA = 1052,	gA = 469,	fP = 1069,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},			-- Vile Manse Group Event
[18] =	{zoneIndex = 154,	poiIndex = 40,	bA = 1056,	gA = 874,	fP = 0,		icon = "|t34:34:/esoui/art/journal/gamepad/gp_questtypeicon_mainstory.dds|t"},	-- Village of the Lost Group Event

}

DTAddon.FinderNormalIndex = {
[1]		=	{svI = 16},		-- Fungal Grotto I
[2]		=	{svI = 21},		-- Spindleclutch I
[3]		=	{svI = 2},		-- Banished Cells I
[4]		=	{svI = 11},		-- Darkshade Caverns I
[5]		=	{svI = 26},		-- Wayrest Sewers I
[6]		=	{svI = 14},		-- Elden Hollow I
[7]		=	{svI = 1},		-- Arx Corinium
[8]		=	{svI = 9},		-- Crypt of Hearts I
[9]		=	{svI = 6},		-- City of Ash I
[10]	=	{svI = 13},		-- Direfrost Keep
[11]	=	{svI = 25},		-- Volenfell
[12]	=	{svI = 23},		-- Tempest Island
[13]	=	{svI = 5},		-- Blessed Crucible
[14]	=	{svI = 4},		-- Blackheart Haven
[15]	=	{svI = 20},		-- Selene's Web
[16]	=	{svI = 24},		-- Vaults of Madness
[17]	=	{svI = 17},		-- Fungal Grotto II
[18]	=	{svI = 27},		-- Wayrest Sewers II
[19]	=	{svI = 28},		-- White-Gold Tower
[20]	=	{svI = 18},		-- Imperial City Prison
[21]	=	{svI = 19},		-- Ruins of Mazzatun
[22]	=	{svI = 8},		-- Cradle of Shadows
[23]	=	{svI = 3},		-- Banished Cells II
[24]	=	{svI = 15},		-- Elden Hollow II
[25]	=	{svI = 12},		-- Darkshade Caverns II
[26]	=	{svI = 22},		-- Spindleclutch II
[27]	=	{svI = 10},		-- Crypt of Hearts II
[28]	=	{svI = 7},		-- City of Ash II

}

DTAddon.FinderVeteranIndex = {

[1]		=	{svI = 22},		-- Veteran Spindleclutch II
[2]		=	{svI = 2},		-- Veteran Banished Cells I
[3]		=	{svI = 11},		-- Veteran Darkshade Caverns I
[4]		=	{svI = 14},		-- Veteran Elden Hollow I
[5]		=	{svI = 9},		-- Veteran Crypt of Hearts I
[6]		=	{svI = 7},		-- Veteran City of Ash II
[7]		=	{svI = 18},		-- Veteran Imperial City Prison
[8]		=	{svI = 28},		-- Veteran White-Gold Tower
[9]		=	{svI = 19},		-- Veteran Ruins of Mazzatun
[10]	=	{svI = 8},		-- Veteran Cradle of Shadows
[11]	=	{svI = 16},		-- Veteran Fungal Grotto I
[12]	=	{svI = 3},		-- Veteran Banished Cells II
[13]	=	{svI = 15},		-- Veteran Elden Hollow II
[14]	=	{svI = 25},		-- Veteran Volenfell
[15]	=	{svI = 1},		-- Veteran Arx Corinium
[16]	=	{svI = 26},		-- Veteran Wayrest Sewers I
[17]	=	{svI = 27},		-- Veteran Wayrest Sewers II
[18]	=	{svI = 12},		-- Veteran Darkshade Caverns II
[19]	=	{svI = 6},		-- Veteran City of Ash I
[20]	=	{svI = 23},		-- Veteran Tempest Island
[21]	=	{svI = 17},		-- Veteran Fungal Grotto II
[22]	=	{svI = 20},		-- Veteran Selene's Web
[23]	=	{svI = 24},		-- Veteran Vaults of Madness
[24]	=	{svI = 21},		-- Veteran Spindleclutch I
[25]	=	{svI = 10},		-- Veteran Crypt of Hearts II
[26]	=	{svI = 13},		-- Veteran Direfrost Keep
[27]	=	{svI = 5},		-- Veteran Blessed Crucible
[28]	=	{svI = 4},		-- Veteran Blackheart Haven

}




------------------------------------------------------------------------------------------------------------------------------------
--[[ Helpful info and functions:

--local achievementName, description, points, icon, completed, date, time = GetAchievementInfo(294)
function DTInfo(cat, scat, i)
	local aid = GetAchievementId(cat, scat, i)
	d(aid)
	d(GetAchievementInfo(aid))
end
--]]

--[[
/script DTInfo(6, 3, 7)

--local description, numCompleted, numRequired = GetAchievementCriterion(achievementId, 1)
local numCriteria = GetAchievementNumCriteria(achievementId)
for i= 1, numCriteria do d(GetAchievementCriterion(1070, i)) end

--if nodeIndex == nil then d("nil") else d(nodeIndex) end
--local poiName, _, poiStartDesc, poiFinishedDesc = GetPOIInfo(zoneIndex, poiIndex)
d(tostring(GetPOIInfo(zoneIndex, poiIndex)))
d("zoneIndex: " .. zoneIndex)
d("poiIndex: " .. poiIndex)

--]]
