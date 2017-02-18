local LMP = LibStub("LibMapPins-1.0")

if not Harvest then
	Harvest = {}
end
local Options = Harvest.options
local language = GetCVar("language.2")

function Harvest.GetLocalizedExactTooltip( itemId, pinTypeId )
	return Harvest.itemId2Tooltip[ itemId ] or Harvest.pinTypeId2Tooltip[ pinTypeId ]
end

local pinTypeId2Tooltip = {
	["en"] = {
		[Harvest.BLACKSMITH] = "Ore",
		[Harvest.CLOTHING] = "Fibre",
		[Harvest.ENCHANTING] = "Runestone",
		[Harvest.MUSHROOM] = "Mushroom",
		[Harvest.FLOWER] = "Herb",
		[Harvest.WATERPLANT] = "Water herb",
		[Harvest.WOODWORKING] = "Wood",
		[Harvest.CHESTS] = "Chest",
		[Harvest.WATER] = "Solvent",
		[Harvest.FISHING] = "Fishing spot",
		[Harvest.HEAVYSACK] = "Heavy Sack",
		[Harvest.TROVE] = "Thieves Trove",
		[Harvest.JUSTICE] = "Justice Container",
		[Harvest.STASH] = "Stash",
	},
	["de"] = {
		[Harvest.BLACKSMITH] = "Erz",
		[Harvest.CLOTHING] = "Faser",
		[Harvest.ENCHANTING] = "Runenstein",
		[Harvest.MUSHROOM] = "Pilze",
		[Harvest.FLOWER] = "Kräuter",
		[Harvest.WATERPLANT] = "Wasserkräuter",
		[Harvest.WOODWORKING] = "Holz",
		[Harvest.CHESTS] = "Schatztruhe",
		[Harvest.WATER] = "Wasser",
		[Harvest.FISHING] = "Fischgrund",
		[Harvest.HEAVYSACK] = "Schwerer Sack",
		[Harvest.TROVE] = "Diebesgut",
		[Harvest.JUSTICE] = "Justiz Behälter",
		[Harvest.STASH] = "Geheimversteck",
	},
	["fr"] = {
		[Harvest.BLACKSMITH] = "Minerai",
		[Harvest.CLOTHING] = "Fibre",
		[Harvest.ENCHANTING] = "Rune",
		[Harvest.MUSHROOM] = "Champignon",
		[Harvest.FLOWER] = "Herbe",
		[Harvest.WATERPLANT] = "Plante aquatique",
		[Harvest.WOODWORKING] = "Bois",
		[Harvest.CHESTS] = "Coffre",
		[Harvest.WATER] = "Solvant",
		[Harvest.FISHING] = "Trou de pêche",
		[Harvest.HEAVYSACK] = "Sac lourd",
		[Harvest.TROVE] = "Trésor de voleur",
		[Harvest.JUSTICE] = "Conteneur de justice",
		[Harvest.STASH] = "Planque",
	},
	["ru"] = {
		[Harvest.BLACKSMITH] = "Руда",
		[Harvest.CLOTHING] = "Ткань",
		[Harvest.ENCHANTING] = "Рунный камень",
		[Harvest.MUSHROOM] = "Трава", -- todo
		[Harvest.FLOWER] = "Трава", -- todo
		[Harvest.WATERPLANT] = "Трава", -- todo
		[Harvest.WOODWORKING] = "Древесина",
		[Harvest.CHESTS] = "Сундук",
		[Harvest.WATER] = "Растворитель",
		[Harvest.FISHING] = "Рыбное место",
		[Harvest.HEAVYSACK] = "Тяжелый мешок",
		[Harvest.TROVE] = "Воровской тайник",
		[Harvest.JUSTICE] = "Охраняемый сейф",
		[Harvest.STASH] = "Тайник",
	},
	["jp"] = {
		[Harvest.BLACKSMITH] = "鉱石",
		[Harvest.CLOTHING] = "繊維",
		[Harvest.ENCHANTING] = "ルーンストーン",
		[Harvest.MUSHROOM] = "キノコ",
		[Harvest.FLOWER] = "花",
		[Harvest.WATERPLANT] = "水生植物",
		[Harvest.WOODWORKING] = "木材",
		[Harvest.CHESTS] = "宝箱",
		[Harvest.WATER] = "溶媒",
		[Harvest.FISHING] = "釣り場",
		[Harvest.HEAVYSACK] = "重い袋",
		[Harvest.TROVE] = "盗賊の宝",
		[Harvest.JUSTICE] = "金庫",
		[Harvest.STASH] = "隠し場所",
	},
}
Harvest.pinTypeId2Tooltip = pinTypeId2Tooltip["en"]
if pinTypeId2Tooltip[language] then
	for pinTypeId, tooltip in pairs(pinTypeId2Tooltip[language]) do
		Harvest.pinTypeId2Tooltip[pinTypeId] = tooltip
	end
end

local itemId2Tooltip = {
	["en"] = {
		[808] = "Iron Ore",
		[5820] = "High Iron Ore",
		[23103] = "Orichalcum Ore",
		[23104] = "Dwarven Ore",
		[23105] = "Ebony Ore",
		[4482] = "Calcinium Ore",
		[23133] = "Galatite Ore",
		[23134] = "Quicksilver Ore",
		[23135] = "Voidstone Ore",
		[71198] = "Rubedite Ore",

		[812] = "Jute",
		[4464] = "Flax",
		[23129] = "Cotton",
		[23130] = "Spidersilk",
		[23131] = "Ebonthread",
		[33217] = "Kreshweed",
		[33218] = "Ironweed",
		[33219] = "Silverweed",
		[33220] = "Void Bloom",
		[71200] = "Ancestor Silk",

		[30148] = "Entoloma",
		[30149] = "Stinkhorn",
		[30151] = "Emetic Russula",
		[30152] = "Violet Coprinus",
		[30153] = "Namira's Rot",
		[30154] = "White Cap",
		[30155] = "Luminous Russula",
		[30156] = "Imp Stool",
		[30157] = "Blessed Thistle",
		[30158] = "Lady's Smock",
		[30159] = "Wormwood",
		[30160] = "Bugloss",
		[30161] = "Corn Flower",
		[30162] = "Dragonthorn",
		[30163] = "Mountain Flower",
		[30164] = "Columbine",
		[30165] = "Nirnroot",
		[30166] = "Water Hyacinth",
		[77590] = "Nightshade",
		
		[802] = "Maple",
		[521] = "Oak",
		[23117] = "Beech",
		[23118] = "Hickory",
		[23119] = "Yew",
		
		[818] = "Birch",
		[4439] = "Ashtree",
		[23137] = "Mahogany",
		[23138] = "Nightwood",
		[71199] = "Ruby Ash Wood",

		[883] = "Natural Water",
		[1187] =  "Clear Water",
		[4570] = "Pristine Water",
		[23265] = "Cleansed Water",
		[23266] = "Filtered Water",
		[23267] = "Purified Water",
		[23268] ="Cloud Mist",
		[64500] = "Star Dew",
		[64501] = "Lorkhan's Tears",
	},
	["de"] = {
		[808] = "Eisenerz",
		[4482] = "Kalciniumerz",
		[5820] = "Feineisenerz",
		[23103] = "Oreichalkoserz",
		[23104] = "Dwemererz",
		[23105] = "Ebenerz",
		[23133] = "Galatiterz",
		[23134] = "Flinksilbererz",--"Quecksilbererz", -- lol was translated to Flinksilber ingame...
		[23135] = "Leereneisenerz",
		[71198] = "Rubediterz",

		[812] = "Jute",
		[4464] = "Flachs",
		[23129] = "Baumwolle",
		[23130] = "Spinnenseide",
		[23131] = "Ebenseide",
		[33217] = "Kreshkraut",
		[33218] = "Eisenkraut",
		[33219] = "Silberkraut",
		[33220] = "Leerenblüte",
		[71200] = "Ahnenseide",

		[30148] = "Glöckling",
		[30149] = "Stinkmorchel",
		[30151] = "Brechtäubling",
		[30152] = "Violetter Tintling",
		[30153] = "Namiras Fäulnis",
		[30154] = "Weißkappe",
		[30155] = "Leuchttäubling",
		[30156] = "Koboldschemel",
		[30157] = "Benediktenkraut",
		[30158] = "Wiesenschaumkraut",
		[30159] = "Wermut",
		[30160] = "Wolfsauge",
		[30161] = "Kornblume",
		[30162] = "Drachendorn",
		[30163] = "Bergblume",
		[30164] = "Akelei",
		[30165] = "Nirnwurz",
		[30166] = "Wasser Hyacinth",
		[77590] = "Nachtschatten",

		[521] = "Eichenholz",
		[802] = "Ahornholz",
		[818] = "Birkenholz",
		[4439] = "Eschenholz",
		[23117] = "Buchenholz",
		[23118] = "Hickoryholz",
		[23119] = "Eibenholz",
		[23137] = "Mahagoniholz",
		[23138] = "Nachtholz",
		[71199] = "Rubinesche",

		[883] = "Natürliches Wasser",
		[1187] =  "Klares Wasser",--"Clear Water",
		[4570] = "Unberührtes Wasser",--"Pristine Water",
		[23265] = "Gesäubertes Wasser",--"Cleansed Water",
		[23266] = "Gefiltertes Wasser",--"Filtered Water",
		[23267] = "Gereinigtes Wasser",--"Purified Water",
		[23268] = "Wolkennebel",--"Cloud Mist"
		[64500] = "Sternentau",
		[64501] = "Lorkhans Tränen",
	},
	["fr"] = {
		[808] = "Minerai de Fer",
		[5820] = "Minerai de Fer Noble",
		[23103] = "Minerai d'Orichalque",
		[23104] = "Minerai Dwemer",
		[23105] = "Minerai d'Ebonite",
		[4482] = "Minerai de Calcinium",
		[23133] = "Minerai de Galatite",
		[23134] = "Minerai de Mercure",
		[23135] = "Minerai de Pierre de Vide",
		[71198] = "Minerai de Cuprite",

		[812] = "Jute",
		[4464] = "Lin",
		[23129] = "Coton",
		[23130] = "Toile D'araignée",
		[23131] = "Fil d'Ebonite",
		[33217] = "Fibre de Kresh",
		[33218] = "Herbe de Fer",
		[33219] = "Herbe d'Argent",
		[33220] = "Tissu du Vide",
		[71200] = "Soie Ancestrale",

		[30148] = "Entoloma",
		[30149] = "Mutinus Elégans",
		[30151] = "Russule Emetique",
		[30152] = "Violet Coprinus",
		[30153] = "Truffe de Namira",
		[30154] = "Chapeau Blanc",
		[30155] = "Russule Phosphorescente",
		[30156] = "Pied-de-Lutin",
		[30157] = "Chardon Béni",
		[30158] = "Cardamine des Prés",
		[30159] = "Absinthe",
		[30160] = "Noctuelle",
		[30161] = "Bleuet",
		[30162] = "Épine-de-Dragon",
		[30163] = "Lys des Cimes",
		[30164] = "Ancolie",
		[30165] = "Nirnrave",
		[30166] = "Jacinthe d'Eau",
		[77590] = "Belladone",
		
		[802] = "Érable",
		[521] = "Chêne",
		[23117] = "Hêtre",
		[23118] = "Noyer",
		[23119] = "If",
		
		[818] = "Bouleau",
		[4439] = "Frêne",
		[23137] = "Acajou",
		[23138] = "Bois de Nuit",
		[71199] = "Frêne Roux",

		[883] = "Eau Naturelle",
		[1187] =  "Eau Claire",
		[4570] = "Eau Limpide",
		[23265] = "Eau Assainie",
		[23266] = "Eau Filtrée",
		[23267] = "Eau Purifiée",
		[23268] ="Brume",
		[64500] = "Rosée Stellaire",
		[64501] = "Larmes de Lorkhan",
	},
	["ru"] = {
		[808] = "Железная руда",
		[5820] = "Высокожелезистая руда",
		[23103] = "Орихалковая руда",
		[23104] = "Двемерская руда",
		[23105] = "Эбонитовая руда",
		[4482] = "Кальциновая руда",
		[23133] = "Галатитовая руда",
		[23134] = "Ртутная руда",
		[23135] = "Пустотная руда",
		[71198] = "Рубедитовая руда",

		[812] = "Джут",
		[4464] = "Лен",
		[23129] = "Хлопок",
		[23130] = "Паучий шелк",
		[23131] = "Эбеновое волокно",
		[33217] = "Волокно креша",
		[33218] = "Железная трава",
		[33219] = "Серебряная трава",
		[33220] = "Пустоцвет",
		[71200] = "Шелк предков",

		[30148] = "Голубая энтолома",
		[30149] = "Цветохвостник веретеновидный",
		[30151] = "Жгучеедкая сыроежка",
		[30152] = "Лиловый копринус",
		[30153] = "Гниль Нaмиpы",
		[30154] = "Белянка",
		[30155] = "Светящаяся сыроежка",
		[30156] = "Бесовский гриб",
		[30157] = "Благословенный чертополох",
		[30158] = "Луговой сердечник",
		[30159] = "Полынь",
		[30160] = "Вoлoвик",
		[30161] = "Василек",
		[30162] = "Дpaкoний шип",
		[30163] = "Горноцвет",
		[30164] = "Вoдocбop",
		[30165] = "Корень Нирна",
		[30166] = "Водный гиацинт",
		
		[802] = "Клен",
		[521] = "Дуб",
		[23117] = "Бук",
		[23118] = "Гикори",
		[23119] = "Тис",
		
		[818] = "Береза",
		[4439] = "Ясень",
		[23137] = "Красное дерево",
		[23138] = "Ночное дерево",
		[71199] = "Рубиновый ясень",

		[883] = "Природная вода",
		[1187] =  "Чистая вода",
		[4570] = "Нетронутая вода",
		[23265] = "Очищенная вода",
		[23266] = "Фильтрованная вода",
		[23267] = "Дистиллированная вода",
		[23268] ="Облачный пар",
		[64500] = "Звездная роса",
		[64501] = "Слезы Лорхана",
	},
	["jp"] = {
		[808] = "鉄鉱石",
		[5820] = "上質な鉄鉱石",
		[23103] = "オリハルコンの鉱石",
		[23104] = "ドワーフの鉱石",
		[23105] = "黒檀の鉱石",
		[4482] = "カルシニウムの鉱石",
		[23133] = "ガラタイトの鉱石",
		[23134] = "水銀の鉱石",
		[23135] = "虚無の石の鉱石",
		[71198] = "ルベダイトの鉱石",

		[812] = "黄麻",
		[4464] = "亜麻",
		[23129] = "コットン",
		[23130] = "スパイダーシルク",
		[23131] = "エボンスレッド",
		[33217] = "クレッシュ草",
		[33218] = "アイアンウィード",
		[33219] = "シルバーウィード",
		[33220] = "虚無の花",
		[71200] = "先人のシルク",

		[30148] = "イッポンシメジ",
		[30149] = "スッポンタケ",
		[30151] = "ドクベニタケ",
		[30152] = "ムラサキヒトヨタケ",
		[30153] = "ナミラキノコ",
		[30154] = "白かさキノコ",
		[30155] = "光ベニタケ",
		[30156] = "木椅子キノコ",
		[30157] = "聖なるシッスル",
		[30158] = "タネツケバナ",
		[30159] = "ニガヨモギ",
		[30160] = "ムラサキ草",
		[30161] = "コーンフラワー",
		[30162] = "ドラゴンソーン",
		[30163] = "山の花",
		[30164] = "オダマキ",
		[30165] = "ニルンルート",
		[30166] = "ホテイアオイ",
		[77590] = "ベラドンナ",
		
		[802] = "カエデ",
		[521] = "カシ",
		[23117] = "ブナノキ",
		[23118] = "ヒッコリー",
		[23119] = "イチイ",
		
		[818] = "カバノキ",
		[4439] = "アッシュ",
		[23137] = "マホガニー",
		[23138] = "ナイトウッド",
		[71199] = "ルビーアッシュ",

		[883] = "自然水",
		[1187] =  "清水",
		[4570] = "清浄水",
		[23265] = "浄化水",
		[23266] = "ろ過水",
		[23267] = "浄化水",
		[23268] ="霧の雲",
		[64500] = "星のしずく",
		[64501] = "ロルカーンの涙",
	},
}
Harvest.itemId2Tooltip = itemId2Tooltip["en"]
if itemId2Tooltip[language] then
	for itemId, tooltip in pairs(itemId2Tooltip[language]) do
		Harvest.itemId2Tooltip[itemId] = tooltip
	end
end


local mushroomTable = {}
local flowerTable = {}
local waterplantTable = {}
do
	-- mushrooms
	local group = {30148,30149,30151,30152,30153,30154,30155,30156}
	for _, itemId in pairs(group) do
		mushroomTable[itemId] = group
	end
	-- flowers
	group = {30157,30158,30159,30160,30161,30162,30163,30164,77590}
	for _, itemId in pairs(group) do
		flowerTable[itemId] = group
	end
	-- water plants
	group = {30165,30166}
	for _, itemId in pairs(group) do
		waterplantTable[itemId] = group
	end
end

local craftingRankPinTypeGroups = {
	-- iron etc
	{
		[Harvest.BLACKSMITH] = {808},
		[Harvest.CLOTHING] = {812},
		[Harvest.WOODWORKING] = {802},
	},
	-- high iron
	{
		[Harvest.BLACKSMITH] = {5820},
		[Harvest.CLOTHING] = {4464},
		[Harvest.WOODWORKING] = {521},
	},
	-- oricalcum
	{
		[Harvest.BLACKSMITH] = {23103},
		[Harvest.CLOTHING] = {23129},
		[Harvest.WOODWORKING] = {23117},
	},
	--dwarven ore
	{
		[Harvest.BLACKSMITH] = {23104},
		[Harvest.CLOTHING] = {23130},
		[Harvest.WOODWORKING] = {23118},
	},
	-- ebonstuff
	{
		[Harvest.BLACKSMITH] = {23105},
		[Harvest.CLOTHING] = {23131},
		[Harvest.WOODWORKING] = {23119},
	},
	-- first VR stuff silver
	{
		[Harvest.BLACKSMITH] = {4482},
		[Harvest.CLOTHING] = {33217},
		[Harvest.WOODWORKING] = {818},
	},
	-- 2nd VR stuff silver
	{
		[Harvest.BLACKSMITH] = {23133},
		[Harvest.CLOTHING] = {33218},
		[Harvest.WOODWORKING] = {4439},
	},
	-- first VR stuff gold
	{
		[Harvest.BLACKSMITH] = {23134},
		[Harvest.CLOTHING] = {33219},
		[Harvest.WOODWORKING] = {23137},
	},
	-- 2nd VR stuff gold
	{
		[Harvest.BLACKSMITH] = {23135},
		[Harvest.CLOTHING] = {33220},
		[Harvest.WOODWORKING] = {23138},
	},
	-- ruby stuff
	{
		[Harvest.BLACKSMITH] = {71198},
		[Harvest.CLOTHING] = {71200},
		[Harvest.WOODWORKING] = {71199},
	},
}

function Harvest.GetLocalizedItemNames(itemIds, pinTypeId, craftingRank, playerRank)
	local tooltip = {}
	local group
	if pinTypeId == Harvest.MUSHROOM then
		for _, itemId in pairs(mushroomTable) do
			tooltip[itemId] = Harvest.itemId2Tooltip[itemId]
		end
	end
	if pinTypeId == Harvest.FLOWER then
		for _, itemId in pairs(flowerTable) do
			tooltip[itemId] = Harvest.itemId2Tooltip[itemId]
		end
	end
	if pinTypeId == Harvest.WATERPLANT then
		for _, itemId in pairs(waterplantTable) do
			tooltip[itemId] = Harvest.itemId2Tooltip[itemId]
		end
	end

	-- add scaled resources
	-- based on crafting level
	if craftingRank then
		group = craftingRankPinTypeGroups[craftingRank][pinTypeId]
		if group then
			for _, groupId in pairs(group) do
				tooltip[groupId] = Harvest.itemId2Tooltip[groupId]
			end
		end
	end
	-- based on character level
	group = craftingRankPinTypeGroups[Harvest.GetLevel2CraftingRank(playerRank)][pinTypeId]
	if group then
		for _, groupId in pairs(group) do
			tooltip[groupId] = Harvest.itemId2Tooltip[groupId]
		end
	end

	-- still nothing? try get a tooltip based on the pinType
	if next(tooltip) == nil then
		tooltip[pinTypeId] = Harvest.pinTypeId2Tooltip[pinTypeId]
	end
	if next(tooltip) == nil then
		tooltip[1] = "Unknown item"
	end
	return tooltip
end

local craftingRankMinLevel = {
	[1] = 0, --iron
	[2] = 16, --steel
	[3] = 26, --orichalcum
	[4] = 36, --dwarven
	[5] = 46, --ebony
	[6] = 51, --calcinium
	[7] = 54, --galatite
	[8] = 57, --quicksilver
	[9] = 59, --voidstone
	[10] = 65, --rubedite
}
function Harvest.GetLevel2CraftingRank(playerRank)
	for rank, level in ipairs(craftingRankMinLevel) do
		if playerRank < level then
			return rank - 1
		end
	end
	return 10
end

function Harvest.GetLocalizedTooltip( pin, mapCache )
	local result = {}
	
	local nodeId = pin.m_PinTag
	
	if nodeId == "TourPin" then
		table.insert(result, "Next resource of your farming tour" )
		return result
	end
	
	local pinTypeId = mapCache.pinTypeId[nodeId]
	if not pinTypeId then
		table.insert(result, "[Bug] Stuck Pin") -- stuck pin, return something to prevent crashing
		return result
	end
	
	if Harvest.IsDebugEnabled() then
		table.insert(result, "Click to delete:" )
	end

	local nodeId = pin.m_PinTag
	local itemIds = mapCache.items[nodeId]
	
	local lines = {}
	if Harvest.ShouldSaveItemId(pinTypeId) and Harvest.AreExactItemsShown() then
		local text
		for itemId, _ in pairs( itemIds ) do
			text = Harvest.GetLocalizedExactTooltip( itemId, pinTypeId )
			if text then
				-- different itemIDs may result in the same tooltip line, ie runes
				if not Harvest.contains(lines, text) then
					table.insert(lines, text)
				end
			end
		end
		-- nothing was added, try to get a tooltip based on the pinTypeId
		if next(lines) == nil then
			text = Harvest.pinTypeId2Tooltip[ pinTypeId ]
			if text then
				if not Harvest.contains(lines, text) then
					table.insert(lines, text)
				end
			end
		end
		-- still nothing? then we just add some error text
		if next(lines) == nil then
			table.insert(lines, "Unknown item" )
		end
	else
		-- get the rank of the crafting skill line which belongs to this pinTypeId
		local tradeSkill = Harvest.pinTypeId2TradeSkill[pinTypeId]
		local rank
		if tradeSkill then
			local skillType, skillIndex = GetCraftingSkillLineIndices(tradeSkill)
			rank = GetSkillAbilityUpgradeInfo(skillType, skillIndex, 1)
		end
		local tooltip = Harvest.GetLocalizedItemNames(itemIds, pinTypeId, rank, GetUnitEffectiveLevel("player") )
		local text = {}
		local counter = 0
		for _, line in pairs(tooltip) do
			if (#text) >= 3 then
				table.insert(lines, table.concat(text, ", ") )
				text = {}
			else
				table.insert(text, line)
			end
		end
		if (#text) > 0 then
			table.insert(lines, table.concat(text, ", ") )
		end
	end
	for _, line in ipairs(lines) do
		table.insert(result, line)
	end
	return result
end
