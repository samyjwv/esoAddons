local CS = CraftStoreFixedAndImprovedLongClassName

CS.Debug = (GetWorldName() == "PTS" or GetDisplayName()=="@VladislavAksjonov")
CS.Name = 'CraftStoreFixedAndImproved'
CS.Title = 'CraftStore Fixed'
CS.Version = '1.0'
CS.Account = nil
CS.Character = nil
CS.Init = false
CS.MaxTraits = select(3,GetSmithingResearchLineInfo(1,1))
CS.Loc = CS.Lang[GetCVar('language.2')] or CS.Lang.en
CS.Quest = {}
CS.Extern = false
CS.Inspiration = ''
CS.Quality = {
  [0] = {0.65,0.65,0.65,1}, --Trash
        {1,   1,   1,   1}, --Normal
        {0.17,0.77,0.05,1}, --Fine
        {0.22,0.57,1,   1}, --Superior
        {0.62,0.18,0.96,1}, --Epic
        {0.80,0.66,0.10,1}, --Legendary
}
CS.QualityHex = {
  [0] = 'B3B3B3', --Trash
        'FFFFFF', --Normal
        '2DC50E', --Fine
        '3A92FF', --Superior
        'A02EF7', --Epic
        'EECA2A', --Legendary
}
CS.HealthName  = GetString(SI_ATTRIBUTES1)
CS.MagickaName = GetString(SI_ATTRIBUTES2)
CS.StaminaName = GetString(SI_ATTRIBUTES3)
CS.CurrentPlayer  = zo_strformat('<<C:1>>',GetUnitName('player'))
CS.SelectedPlayer = CS.CurrentPlayer
CS.UIClosed = false
CS.ChampionPointsTexture = "|t16:16:esoui/art/champion/champion_icon_32.dds|t"
--TODO: Generate recipe and ingridients list on the init
CS.Cook = {
  category = {
    CS.HealthName, 
    CS.MagickaName, 
    CS.StaminaName, 
    CS.HealthName ..' + '..CS.MagickaName, 
    CS.HealthName ..' + '..CS.StaminaName, 
    CS.MagickaName..' + '..CS.StaminaName, 
    CS.HealthName ..' + '..CS.MagickaName..' + '..CS.StaminaName,
    CS.HealthName, 
    CS.MagickaName, 
    CS.StaminaName, 
    CS.HealthName ..' + '..CS.MagickaName, 
    CS.HealthName ..' + '..CS.StaminaName, 
    CS.MagickaName..' + '..CS.StaminaName, 
    CS.HealthName ..' + '..CS.MagickaName..' + '..CS.StaminaName,
    GetString(SI_ITEMFILTERTYPE5), 
    GetString(SI_ITEMFILTERTYPE5), 
    '', 
    ''
  },
  craftLevel = 0,
  qualityLevel = 0,
  job = {amount = 0, list = nil, id = nil},
  recipe = {},
  ingredient = {},
  recipelist = {
    45535,45539,45540,45541,45542,45543,45544,45545,45546,45547,45548,45549,
    45551,45552,45553,45554,45555,45556,45557,45559,45560,45561,45562,45563,
    45564,45565,45567,45568,45569,45570,45571,45572,45573,45574,45575,45576,
    45577,45579,45580,45581,45582,45583,45584,45587,45588,45589,45590,45591,
    45592,45594,45595,45596,45597,45598,45599,45600,45601,45602,45603,45604,
    45607,45608,45609,45610,45611,45612,45614,45615,45616,45617,45618,45619,
    45620,45621,45622,45623,45624,45625,45626,45627,45628,45629,45630,45631,
    45632,45633,45634,45636,45637,45638,45639,45640,45641,45642,45643,45644,
    45645,45646,45647,45648,45649,45650,45651,45652,45653,45654,45655,45656,
    45657,45658,45659,45660,45661,45662,45663,45664,45665,45666,45667,45668,
    45670,45671,45672,45673,45674,45675,45676,45677,45678,45679,45680,45681,
    45682,45683,45684,45685,45686,45687,45688,45689,45690,45691,45692,45693,
    45694,45695,45696,45697,45698,45699,45700,45701,45702,45703,45704,45705,
    45706,45707,45708,45709,45710,45711,45712,45713,45714,45715,45716,45717,
    45718,45719,45791,45887,45888,45889,45890,45891,45892,45893,45894,45895,
    45896,45897,45898,45899,45900,45901,45902,45903,45904,45905,45906,45907,
    45908,45909,45910,45911,45912,45913,45914,45915,45916,45917,45918,45919,
    45920,45921,45922,45923,45924,45925,45926,45927,45928,45929,45930,45931,
    45932,45933,45934,45935,45936,45937,45938,45939,45940,45941,45942,45943,
    45944,45945,45946,45947,45948,45949,45950,45951,45952,45953,45954,45955,
    45956,45957,45958,45959,45960,45961,45962,45963,45964,45965,45966,45967,
    45968,45969,45970,45971,45972,45973,45974,45975,45976,45977,45978,45979,
    45980,45981,45982,45983,45984,45985,45986,45987,45988,45989,45990,45991,
    45992,45993,45994,45995,45996,45997,45998,45999,46000,46001,46002,46003,
    46004,46005,46006,46007,46008,46009,46010,46011,46012,46013,46014,46015,
    46016,46017,46018,46019,46020,46021,46022,46023,46024,46025,46026,46027,
    46028,46029,46030,46031,46032,46033,46034,46035,46036,46037,46038,46039,
    46040,46041,46042,46043,46044,46045,46046,46047,46048,46049,46050,46051,
    46052,46053,46054,46055,46056,46079,46081,46082,54241,54242,54243,54369,
    54370,54371,56943,56944,56945,56946,56947,56948,56949,56950,56951,56952,
    56953,56954,56955,56956,56957,56958,56959,56961,56962,56963,56964,56965,
    56966,56967,56968,56969,56970,56971,56972,56973,56974,56975,56976,56977,
    56978,56979,56980,56981,56982,56983,56984,56985,56986,56987,56988,56989,
    56990,56991,56992,56993,56994,56995,56996,56997,56998,56999,57000,57001,
    57002,57003,57004,57005,57006,57007,57008,57009,57010,57011,57012,57013,
    57014,57015,57016,57017,57018,57019,57020,57021,57022,57023,57024,57025,
    57026,57027,57028,57029,57030,57031,57032,57033,57034,57035,57036,57037,
    57038,57039,57040,57041,57042,57043,57044,57045,57046,57047,57048,57049,
    57050,57051,57052,57053,57054,57055,57056,57057,57058,57059,57060,57061,
    57062,57063,57064,57065,57066,57067,57068,57069,57070,57071,57072,57073,
    57074,57075,57076,57077,57078,57079,64223,68189,68190,68191,68192,68193,
    68194,68195,68196,68197,68198,68199,68200,68201,68202,68203,68204,68205,
    68206,68207,68208,68209,68210,68211,68212,68213,68214,68215,68216,68217,
    68218,68219,68220,68221,68222,68223,68224,68225,68226,68227,68228,68229,
    68230,68231,68232,71060,71061,71062,71063,87682,87683,87684,87688,87689,
    87692,87693,87694,87698,96960,96961,96962,96963,96964,96965,96966,96967,
    96968,115029,120076 
  },
  ingredientlist = {
    34349,34348,34347,34346,34345,34335,34334,34333,34330,34329,34324,34323,
    34321,34311,34309,34308,34307,34305,33774,33773,33772,33771,33768,33758,
    33756,33755,33754,33753,33752,29030,28666,28639,28636,28610,28609,28604,
    28603,27100,27064,27063,27059,27058,27057,27052,27049,27048,27043,27035,
    26954,26802
  }
}

CS.Furnisher = {
  recipe = {},
  category = {
    'Diagram',
    'Pattern',
    'Praxis',
    'Formula',
    'Design',
    'Blueprint'
  },  
  recipelist = {
    115772,115773,115930,115932,115945,115958,115960,115961,115962,115965,115966,115968,115993,115995,116004,116005,116007,116008,116009,116010,116011,116019,116020,116025,116044,
    116048,116052,116053,116054,116055,116056,116068,116069,116073,116074,116075,116077,116078,116079,116080,116093,116114,116115,116116,116121,116128,116140,116144,116145,116146,
    116152,116161,116163,116164,116187,116189,116192,116209,116210,116211,116212,116213,116215,118925,118930,118938,118939,118940,118941,118946,118948,118949,118950,118952,118953,
    118972,118977,118978,118980,118981,118983,118998,118999,119000,119001,119004,119024,119029,119049,119060,119061,119063,119064,119067,119068,119069,119070,119072,119073,119074,
    119101,119109,119110,119114,119115,119116,119117,119118,119119,119123,119149,119158,119161,119177,119185,119186,119201,119202,119203,119204,119205,119206,119207,119208,119209,
    119210,119211,119212,119213,119218,119219,119230,119251,119268,119269,119277,119278,119279,119280,119281,119288,119328,119330,119331,119379,119380,119382,119383,119384,119387,
    119389,119390,119395,119396,119397,119399,119400,119401,119404,119405,119413,119416,119418,119424,119428,119432,119440,119442,119445,119446,119450,119451,119476,119518,119520,
    121059,121163,121165,121177,121178,121213,121304,121305,121309,121310,121373,121374,115723,115724,115728,115729,115738,115739,115743,115746,115747,115748,115751,115752,115754,
    115774,115778,115779,115780,115782,115783,115784,115785,115787,115788,115789,115800,115801,115802,115807,115808,115815,115816,115817,115818,115819,115821,115822,115833,115834,
    115835,115836,115842,115843,115852,115853,115854,115856,115857,115858,115859,115861,115862,115863,115864,115867,115869,115870,115872,115873,115874,115884,115885,115896,115897,
    115898,115899,115900,115908,115909,115925,115926,115934,115935,115952,115953,115954,115969,115970,115976,115978,115990,115991,115992,115994,115996,116000,116001,116016,116021,
    116022,116023,116024,116037,116038,116047,116049,116050,116051,116062,116063,116070,116071,116072,116082,116084,116086,116089,116091,116092,116095,116096,116097,116099,116100,
    116108,116109,116110,116113,116120,116126,116131,116134,116135,116136,116141,116142,116143,116188,116206,116207,116208,116214,118918,118931,118942,118943,118973,118974,118975,
    118976,119002,119003,119010,119027,119030,119031,119034,119035,119037,119038,119039,119042,119071,119102,119106,119107,119108,119122,119154,119155,119170,119172,119180,119181,
    119183,119184,119196,119197,119198,119199,119200,119220,119221,119222,119223,119224,119225,119226,119232,119233,119234,119235,119236,119238,119239,119240,119246,119247,119255,
    119256,119264,119265,119266,119267,119282,119283,119290,119291,119292,119293,119298,119299,119300,119305,119306,119307,119312,119350,119359,119360,119361,119362,119374,119375,
    119408,121108,121109,121110,121111,121171,121209,121215,121308,121365,121366,115737,115741,115742,115775,115776,115777,115781,115791,115803,115804,115805,115809,115810,115811,
    115812,115813,115814,115824,115825,115828,115832,115850,115851,115855,115860,115927,115967,116003,116006,116081,118922,118928,118929,118932,118934,118935,118936,118937,118951,
    118954,118964,118965,118966,118967,118968,118969,118982,118987,119009,119028,119046,119050,119054,119055,119056,119057,119058,119059,119076,119077,119083,119085,119088,119089,
    119096,119097,119160,119216,119217,119260,119271,119272,119274,119284,119394,119514,119592,121167,121203,121204,121206,121207,121208,121210,121211,121212,121306,121312,121315,
    121371,115806,115982,116026,116045,116046,118944,118945,118947,118979,119121,119173,119174,119249,119270,119273,119275,119276,119302,119303,119304,119308,119309,119310,119311,
    119484,119485,119486,119488,121104,121156,121164,121193,121194,121197,121198,121217,121307,115725,115736,115753,115755,115792,115793,115794,115795,115820,115823,115826,115829,
    115831,115844,115845,115846,115847,115848,115849,115865,115866,115868,115875,115876,115877,115878,115879,115880,115881,115882,115883,115886,115888,115889,115890,115891,115892,
    115893,115894,115895,115901,115902,115903,115904,115924,115928,115955,115956,115957,115959,116002,116087,116088,116090,116106,116107,116111,116112,116123,116137,116138,116139,
    116153,116154,116162,116168,116169,116170,116171,116186,116193,119023,119025,119026,119032,119033,119062,119065,119066,119078,119103,119104,119105,119113,119130,119131,119150,
    119151,119152,119153,119162,119165,119166,119167,119195,119227,119231,119261,119262,119263,119325,119351,119352,119353,119354,119355,119356,119373,119376,119377,119378,119381,
    119385,119386,119388,119391,119392,119393,119402,119425,119426,119427,119429,119437,119438,119439,119441,119443,119444,119447,119462,119463,119464,119465,119467,119468,119469,
    119470,119471,119472,119477,119478,119479,119480,119481,119482,119487,119489,119491,119525,119526,119527,119529,119532,119533,119539,119541,119542,119543,121097,121100,121101,
    121102,121103,121107,121157,121161,121174,121175,121176,121179,121180,121181,121182,121183,121184,121185,121186,121187,121188,121189,121190,121191,121192,121199,121201,121205,
    121214,121218,121372,115721,115722,115726,115727,115730,115731,115732,115733,115734,115735,115740,115744,115745,115749,115750,115756,115757,115758,115759,115760,115761,115762,
    115763,115764,115765,115766,115767,115768,115769,115770,115771,115790,115796,115799,115827,115830,115837,115838,115839,115840,115841,115871,115887,115906,115907,115910,115911,
    115912,115913,115914,115915,115916,115917,115918,115919,115920,115921,115922,115923,115929,115931,115933,115936,115937,115938,115939,115940,115941,115942,115943,115944,115946,
    115947,115948,115949,115950,115951,115963,115964,115971,115972,115973,115974,115975,115977,115979,115980,115981,115983,115984,115985,115986,115987,115988,115989,115997,115998,
    115999,116012,116013,116014,116015,116017,116018,116027,116028,116029,116030,116031,116032,116033,116034,116035,116036,116039,116040,116041,116042,116043,116057,116058,116059,
    116060,116061,116064,116065,116066,116067,116083,116085,116094,116098,116101,116102,116103,116104,116105,116117,116118,116119,116122,116124,116125,116127,116129,116130,116132,
    116133,116147,116148,116149,116150,116151,116155,116156,116157,116158,116159,116160,116165,116166,116167,116172,116173,116174,116175,116176,116177,116178,116179,116180,116181,
    116182,116183,116184,116185,116190,116191,116194,116195,116196,116197,116198,116199,116200,116201,116202,116203,116204,116205,116216,118916,118917,118919,118920,118921,118923,
    118924,118926,118927,118933,118955,118956,118957,118958,118959,118960,118961,118962,118963,118970,118971,118984,118985,118986,118988,118989,118990,118991,118992,118993,118994,
    118995,118996,118997,119005,119006,119007,119008,119011,119012,119013,119014,119015,119016,119017,119018,119019,119020,119021,119022,119036,119040,119041,119043,119044,119045,
    119047,119048,119051,119052,119053,119075,119079,119080,119081,119082,119084,119086,119087,119090,119091,119092,119093,119094,119095,119098,119099,119100,119111,119112,119120,
    119124,119125,119126,119127,119128,119129,119132,119133,119134,119135,119136,119137,119138,119139,119140,119141,119142,119143,119144,119145,119146,119147,119148,119156,119157,
    119159,119163,119164,119168,119169,119171,119175,119176,119178,119179,119182,119187,119188,119189,119190,119191,119192,119193,119194,119214,119215,119228,119229,119241,119242,
    119243,119244,119245,119248,119250,119252,119253,119254,119257,119258,119259,119285,119286,119287,119295,119296,119297,119301,119314,119317,119338,119342,119344,119348,119357,
    119358,119363,119364,119365,119366,119367,119368,119369,119370,119371,119372,119403,119406,119407,119420,119421,119422,119423,119448,119449,119454,119455,119456,119466,119483,
    119490,119524,119540,121061,121091,121098,121099,121105,121106,121120,121160,121166,121168,121172,121173,121200,121216,121311,121313,121369
  }
}

CS.Rune = {
  level = {
    '1 - 10',
    '5 - 15',
    '10 - 20',
    '15 - 25',
    '20 - 30',
    '25 - 35',
    '30 - 40',
    '35 - 45',
    '40 - 50',
    CS.ChampionPointsTexture..'10',
    CS.ChampionPointsTexture..'30',
    CS.ChampionPointsTexture..'50',
    CS.ChampionPointsTexture..'70',
    CS.ChampionPointsTexture..'100',
    CS.ChampionPointsTexture..'150',
    CS.ChampionPointsTexture..'160'
  },
  skillLevel = {1,1,2,2,3,3,4,4,5,5,6,7,8,9,10,10},
  aspectSkill = 1,
  potencySkill = 1,
  rune = {
    [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = {
        45831,45832,45833,45834,45835,45836,
        45837,45838,45839,45840,45841,45842,
        45843,45846,45847,45848,45849,68342
      },
    [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = { 
      {
        45855,45856,45857,45806,45807,45808,
        45809,45810,45811,45812,45813,45814,
        45815,45816,64509,68341
      }, 
      {
        45817,45818,45819,45820,45821,45822,
        45823,45824,45825,45826,45827,45828,
        45829,45830,64508,68340
      } 
    },
    [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = {
        45850,45851,45852,45853,45854
      },
  },
  glyph = {
    [ITEMTYPE_GLYPH_ARMOR] = {
      {26580,45831,1,1}, -- health, oko
      {26582,45832,1,2}, -- magicka, makko
      {26588,45833,1,3}, -- stamina, deni
      {68343,68342,1,4}, -- prismatic defense, hakeijo 
    },
    [ITEMTYPE_GLYPH_WEAPON] = {
      {68344,68342,2, 1}, -- prismatic onslaught, hakeijo 
      {54484,45843,1, 2}, -- weapon damage, okori
      {26845,45842,2, 3}, -- crushing, deteri
      {43573,45831,2, 4}, -- absorb health, oko
      {45868,45832,2, 5}, -- absorb magicka, makko
      {45867,45833,2, 6}, -- absorb stamina, deni
      {45869,45834,2, 7}, -- decrease health, okoma
      { 5365,45839,1, 8}, -- frost weapon, dekeipa
      {26848,45838,1, 9}, -- flame weapon, rakeipa
      {26844,45840,1,10}, -- shock weapon, meip
      {26587,45837,1,11}, -- poison weapon, kuoko
      {26841,45841,1,12}, -- foul weapon, haoko
      { 5366,45842,1,13}, -- hardening, deteri
      {26591,45843,2,14}, -- weakening, okori
    },
    [ITEMTYPE_GLYPH_JEWELRY] = {
      {26581,45834,1, 1},  -- health recovery, okoma
      {26583,45835,1, 2},  -- magicka recovery, makkoma
      {26589,45836,1, 3},  -- stamina recovery, denima
      {45870,45835,2, 4},  -- reduce spell cost, makkoma
      {45871,45836,2, 5},  -- reduce feat cost, denima
      {45883,45847,1, 6},  -- increase physical harm, taderi
      {45884,45848,1, 7},  -- increase magical harm, makderi
      {45885,45847,2, 8},  -- decrease physical harm, taderi
      {45886,45848,2, 9},  -- decrease spell harm, makderi
      { 5364,45839,2,10},  -- frost resist, dekeipa
      {26849,45838,2,11},  -- flame resist, rakeipa
      {43570,45840,2,12},  -- shock resist, meip
      {26586,45837,2,13},  -- poison resist, kuoko
      {26847,45841,2,14},  -- disease resist, haoko
      {45872,45849,1,15},  -- bashing, kaderi
      {45873,45849,2,16},  -- shielding, kaderi
      {45874,45846,1,17},  -- potion boost, oru
      {45875,45846,2,18},  -- potion speed, oru
    },
  },
  job = { amount = 0, slot = {0,0,0}},
  refine = { glyphs = {nil}, crafted = false }
}
CS.Flask = {
  reagent = {},
  noBad = false,
  solvent = {883,1187,4570,23265,23266,23267,23268,64500,64501},
  reagentTrait = {
    {30165, 2,14,12,23},
    {30158, 9, 3,18,13},
    {30155, 6, 8, 1,22},
    {30152,18, 2, 9, 4},
    {30162, 7, 5,16,11},
    {30148, 4,10, 1,23},
    {30149,16, 2, 7, 6},
    {30161, 3, 9, 2,24},
    {30160,17, 1,10, 3},
    {30154,10, 4,17,12},
    {30157, 5, 7, 2,21},
    {30151, 2, 4, 6,20},
    {30164, 1, 3, 5,19},
    {30159,11,22,24,19},
    {30163,15, 1, 8, 5},
    {30153,13,21,23,19},
    {30156, 8, 6,15,12},
    {30166, 1,13,11,20}
  },
  solventSelection = 1,
  traitSelection = {1},
  traitIcon = {
    'restorehealth','ravagehealth', 
    'restoremagicka','ravagemagicka',
    'restorestamina','ravagestamina',
    'increaseweaponpower','lowerweaponpower',
    'increasespellpower','lowerspellpower',
    'weaponcrit','lowerweaponcrit',
    'spellcrit','lowerspellcrit',
    'increasearmor','lowerarmor',
    'increasespellresist','lowerspellresist',
    'unstoppable','stun',
    'speed','reducespeed',
    'invisible','detection',
  }
}
CS.CraftIcon = {  
  'esoui/art/icons/ability_smith_007.dds',       -- BlackSmithing
  'esoui/art/icons/ability_tradecraft_008.dds',  -- Closier
  'esoui/art/icons/ability_enchanter_001b.dds',  -- Enchanting
  'esoui/art/icons/ability_alchemy_006.dds',     -- Alchemy
  'esoui/art/icons/ability_provisioner_002.dds', -- Provisioning
  'esoui/art/icons/ability_tradecraft_009.dds',  -- WoodWorking
}
CS.Flags = {
  'esoui/art/guild/guildbanner_icon_aldmeri.dds',    -- AD
  'esoui/art/guild/guildbanner_icon_ebonheart.dds',  -- EP
  'esoui/art/guild/guildbanner_icon_daggerfall.dds', -- DC
}
CS.Classes = {
  'esoui/art/icons/class/class_dragonknight.dds', -- Dragon Knight
  'esoui/art/icons/class/class_sorcerer.dds',     -- Sorcerer
  'esoui/art/icons/class/class_nightblade.dds',   -- NightBlade
  'esoui/art/icons/class/class_warden.dds',       -- Warden
  'esoui/art/icons/class/class_battlemage.dds',   -- Battle Mage
  'esoui/art/icons/class/class_templar.dds'       -- Templar
}
CS.Sets = {
  {traits=2,nodes={  7,175, 77},item=49575,zone={ 2,15,11}},  -- Aschengriff
  {traits=2,nodes={  1,177, 71},item=43805,zone={ 2,15,11}},  -- Todeswind
  {traits=2,nodes={216,121, 65},item=47279,zone={ 2,15,11}},  -- Stille der Nacht
  
  {traits=3,nodes={ 15,169,205},item=43808,zone={ 4, 7,10}},  -- Zwielicht
  {traits=3,nodes={ 23,164, 32},item=48042,zone={ 4, 7,10}},  -- Verführung
  {traits=3,nodes={ 19,165, 24},item=43979,zone={ 4, 7,10}},  -- Torugs Pakt
  {traits=3,nodes={237,237,237},item=69942,zone={27,27,27}},  -- Prüfungen
  
  {traits=4,nodes={  9,154, 51},item=51105,zone={ 3,16, 9}},  -- Histrinde
  {traits=4,nodes={ 82,151, 78},item=47663,zone={ 3,16, 9}},  -- Weißplanke
  {traits=4,nodes={ 13,148, 48},item=43849,zone={ 3,16, 9}},  -- Magnus
  
  {traits=5,nodes={ 58,101, 93},item=48425,zone={ 5, 8,13}},  -- Kuss des Vampirs
  {traits=5,nodes={137,103, 89},item=52243,zone={ 5, 8,13}},  -- Lied der Lamien
  {traits=5,nodes={155,105, 95},item=52624,zone={ 5, 8,13}},  -- Alessias Bollwerk
  {traits=5,nodes={199,201,203},item=60280,zone={26,26,26}},  -- Adelssieg
  {traits=5,nodes={257,257,257},item=71806,zone={28,28,28}},  -- Tavas Gunst
  {traits=5,nodes={254,254,254},item=75406,zone={29,29,29}},  -- DB:Kwatch Gladiator
  
  {traits=6,nodes={ 35,144,111},item=51486,zone={ 6,17,12}},  -- Weidenpfad
  {traits=6,nodes={ 39,161,113},item=51864,zone={ 6,17,12}},  -- Hundings Zorn
  {traits=6,nodes={ 34,156,118},item=49195,zone={ 6,17,12}},  -- Mutter der Nacht
  {traits=6,nodes={241,241,241},item=69592,zone={27,27,27}},  -- Julianos
  
  {traits=7,nodes={199,201,203},item=60630,zone={26,26,26}},  -- Umverteilung
  {traits=7,nodes={257,257,257},item=72156,zone={28,28,28}},  -- Schlauer Alchemist
  {traits=7,nodes={251,251,251},item=75756,zone={29,29,29}},  -- DB:Varen's Legacy
  
  {traits=8,nodes={135,135,135},item=43968,zone={23,23,23}},  -- Erinnerung
  {traits=8,nodes={133,133,133},item=43972,zone={23,23,23}},  -- Schemenauge
  {traits=8,nodes={ -1, -1, -1},item=44053,zone={ 6,17,12}},  -- Augen von Mara
  {traits=8,nodes={ -1, -1, -1},item=54149,zone={ 6,17,12}},  -- Shalidor's Fluch
  {traits=8,nodes={ -2, -2, -2},item=53772,zone={ 6,17,12}},  -- Karegnas Hoffnung
  {traits=8,nodes={ -2, -2, -2},item=53006,zone={ 6,17,12}},  -- Ogrumms Schuppen
  {traits=8,nodes={217,217,217},item=54963,zone={25,25,25}},  -- Arena
  
  {traits=9,nodes={234,234,234},item=58174,zone={25,25,25}},  -- Doppelstern
  {traits=9,nodes={199,201,203},item=60980,zone={26,26,26}},  -- Rüstungsmeister
  {traits=9,nodes={237,237,237},item=70642,zone={27,27,27}},  -- Morkuldin
  {traits=9,nodes={255,255,255},item=72506,zone={28,28,28}},  -- Ewige Jagd
  {traits=9,nodes={254,254,254},item=76106,zone={29,29,29}},  -- DB:Pelinal's Aptitude
}

CS.AccountInit = {
  option = {true,false,true,true,true,true,true,true,true,true,true,true,true,false,true,true},
  mainchar = false,
  timer = { [12] = 0, [24] = 0},
  position = {350,100},
  questbox = {GuiRoot:GetWidth()-500,-20},
  button = {75,75},
  player = {},
  storage = {},
  materials = {},
  announce = {},
  crafting = { research = {}, studies = {}, stored = {}, skill = {} },
  style = { tracking = {}, knowledge = {} },
  cook =  { tracking = {}, knowledge = {}, ingredients = {} },
  furnisher =  { tracking = {}, knowledge = {}, ingredients = {} }
}

CS.CharInit = {
  income = { GetDate(), GetCurrentMoney() },
  favorites = { {}, {}, {}, {}, {}, {} },
  recipe = 1,
  furniture = 1,
  potency = 1,
  essence = 1,
  aspect = 1,
  potencytype = 1,
  enchant = ITEMTYPE_GLYPH_ARMOR,
  runemode = 'craft',
  hidestyles = false,
  hideperfectedstyles = false,   
  previewtype = 1
}

CS.ItemLinkCache = {
  [BAG_BACKPACK]={},
  [BAG_BANK]={},
  [BAG_VIRTUAL]={},
}

CS.RawItemTypes = CS.Set{    
  ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
  ITEMTYPE_CLOTHIER_RAW_MATERIAL,
  ITEMTYPE_WOODWORKING_RAW_MATERIAL,
  ITEMTYPE_RAW_MATERIAL
}

CS.previewType = {
  [CS.Loc.previewType[1]] = 1,
  [CS.Loc.previewType[2]] = 2,
  [CS.Loc.previewType[3]] = 3,
  [CS.Loc.previewType[4]] = 4,
}
