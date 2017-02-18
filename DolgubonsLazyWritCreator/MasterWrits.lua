local function proper(str)
	if type(str)== "string" then
		return zo_strformat("<<C:1>>",str)
	else
		return str
	end
end


local weaponTraits ={}

------------------------------------
-- TRAIT DECLARATION

for i = 0, 8 do --create the weapon trait table
	--Takes the strings starting at SI_ITEMTRAITTYPE0 == no trait, # 897 to SI_ITEMTRAITTYPE8 === Divines, #905
	--Then saves the proper trait index used for crafting to it. The offset of 1 is due to ZOS; the offset of STURDY is so they start at 12
	weaponTraits[i + 1] = {[2]  = i + 1, [1] = GetString(SI_ITEMTRAITTYPE0 + i),}
end

local armourTraits = {}
for i = 0, 7 do --create the armour trait table
	--Takes the strings starting at SI_ITEMTRAITTYPE11 == Sturdy, # 908 to SI_ITEMTRAITTYPE18 === Divines, #915
	--Then saves the proper trait index used for crafting to it. The offset of 1 is due to ZOS; the offset of STURDY is so they start at 12
	armourTraits[i + 1] = {[2] = i + 1 + ITEM_TRAIT_TYPE_ARMOR_STURDY, [1] = GetString(SI_ITEMTRAITTYPE11 + i)}
end
--Add a few missing traits to the tables - i.e., nirnhoned, and no trait
armourTraits[#armourTraits + 1] = {[2] = ITEM_TRAIT_TYPE_NONE + 1, [1] = GetString(SI_ITEMTRAITTYPE0)} -- No Trait to armour traits
armourTraits[#armourTraits + 1] = {[2] = ITEM_TRAIT_TYPE_ARMOR_NIRNHONED + 1, [1] = GetString(SI_ITEMTRAITTYPE26)} -- Nirnhoned
weaponTraits[#weaponTraits + 1] = {[2] = ITEM_TRAIT_TYPE_WEAPON_NIRNHONED + 1, [1] = GetString(SI_ITEMTRAITTYPE25)}  -- Nirnhoned

styles = {}
for i = 1, GetNumSmithingStyleItems() do
	if GetString("SI_ITEMSTYLE", i)~="" then
		styles[#styles + 1] = {GetString("SI_ITEMSTYLE", i),i+1 }
		
	end
end

local function myLower(str)
	return zo_strformat("<<z:1>>",str)
end


local function enchantSearch(info,condition)
	for i = 1, #info do
		if string.find(myLower(condition), info[i][1]) then
			
			return info[i]
		end

	end

	return nil
end

local function foundAllEnchantingRequirements(essence, potency, aspect)
	if WritCreater.lang~="en" then return false end
	local foundAll = true
	if not essence then
		foundAll = false
		d("Essence/Effect not found")
	end
	if not potency then
		foundAll = false
		d("Level not found")
	end
	if not aspect or aspect[1]=="" then
		foundAll = false
		d("Quality not found")
	end
	return foundAll
end

local function EnchantingMasterWrit(journalIndex)
	-- "Superb Glyph of Health *Quality: Legendary *Progress:0/1"
	local condition, complete = GetJournalQuestConditionInfo(journalIndex, 1)
	if complete == 1 then return end
	if condition =="" then return end
	local craftInfo = WritCreater.craftInfo[CRAFTING_TYPE_ENCHANTING]

	local essence = enchantSearch(craftInfo["pieces"], condition)
	local potency = enchantSearch(craftInfo["match"], condition)
	local aspect = enchantSearch(craftInfo["quality"], condition)

	if foundAllEnchantingRequirements(essence, potency, aspect) then
		local lvl = potency[1]
		if potency[1]=="truly" then lvl = "truly superb" end
		d(zo_strformat("Crafting a <<t:1>> Glyph of <<t:2>> at <<t:3>> quality", lvl, essence[1], aspect[1]))

		WritCreater.LLCInteraction:CraftEnchantingItemId(potency[2][essence[3]], essence[2], aspect[2], true)
	else
	end
end

local function smithingSearch(condition, info, debug)

	local matches = {}
	for i = 1, #info do
		local str = string.gsub(info[i][1], "-"," ")
		if string.find(myLower(condition), myLower(str)) then
			matches[#matches+1] = {info[i] , i}
		end
	end

	if #matches== 0 then
		return {"",0} , -1
	elseif #matches==1 then

		return matches[1][1], matches[1][2]
	else
		local longest = 0
		local position = 0
		for i = 1, #matches do
			if string.len(matches[i][1][1])>longest then
				longest = string.len(matches[i][1][1])
				position = i
			end
		end
		return matches[position][1], matches[position][2]
	end

end

local function foundAllRequirements(pattern, style, setIndex, trait, quality)
	local foundAllRequirements = true
	if setIndex==-1 then 
		foundAllRequirements = false
		d("Set not found") 
	end
	if pattern[1] =="" then 
		foundAllRequirements = false
		d("Pattern not found")
	end
	if trait[1]=="" then
		foundAllRequirements = false
		d("Trait not found")
	end
	if style[1]=="" then
		foundAllRequirements = false
		d("Style not found")
	end
	if quality[1]=="" then
		foundAllRequirements = false
		d("Quality not found")
	end
	return foundAllRequirements
end

local function germanRemoveEN (str)

	return string.sub(str, 1 , string.len(str) - 2)

end

local function splitCondition(condition)

	local a = 1
	local t = {}
	while string.find(condition , "\n") and a<100 do
		a = a+1
		t[#t+1] = string.sub(condition, 1, string.find(condition, "\n") - 1)
		condition = string.sub(condition, string.find(condition,"\n") + 1, string.len(condition) ) 

	end

	return unpack(t)
end

local function SmithingMasterWrit(journalIndex, info, station, isArmour, material)

	if WritCreater.lang == "de" then for i = 1, #info do  info[i][1] = germanRemoveEN(info[i][1])   end end
	local condition, complete =GetJournalQuestConditionInfo(journalIndex, 1)

	condition = string.gsub(condition, "-" , " ")
	
	if complete == 1 then return end
	if condition =="" then return end
	local conditionStrings = {}
	conditionStrings["pattern"], conditionStrings["quality"], conditionStrings["trait"],
	  conditionStrings["set"], conditionStrings["style"] = splitCondition(condition)
	  

	local pattern =  smithingSearch(conditionStrings["pattern"], info) --search pattern
	
	if pattern[1] =="" and pattern[2]==0 then return end
	
	local trait
	if isArmour then
		
		trait = smithingSearch(conditionStrings["trait"], armourTraits )
	else
		trait = smithingSearch(conditionStrings["trait"], weaponTraits)
	end
	local style = smithingSearch(conditionStrings["style"], styles)
	local _,setIndex = smithingSearch(conditionStrings["set"], GetSetIndexes())
	local quality
	if WritCreater.lang =="en" then
		quality = smithingSearch(conditionStrings["quality"], {{"Epic",4},{"Legendary",5}}) --search quality
	elseif WritCreater.lang=="de" then
		quality = smithingSearch(conditionStrings["quality"], {{"episch",4},{"legendär",5}})
	elseif WritCreater.lang =="fr" then
		quality = smithingSearch(conditionStrings["quality"], {{"épique",4},{"légendaire",5}})
	end

	if foundAllRequirements(pattern, style, setIndex, trait, quality) then

		d(zo_strformat("Crafting a CP150 <<t:6>> <<t:1>> from <<t:2>> with trait <<t:3>> and style <<t:4>> at <<t:5>> quality"
			,pattern[1], 
			GetSetIndexes()[setIndex][1],
			trait[1],
			style[1], 
			quality[1],
			material ))
		
		WritCreater.LLCInteraction:CraftSmithingItemByLevel( pattern[2], true , 150, style[2], trait[2], false, station, setIndex, quality[2], true)
	end
end

local function keyValueTable(t)
	local temp = {}
	for k, v in pairs(t) do
		temp[#temp + 1] = {v,k}
	end
	return temp
end

local function partialTable(t, start, ending)

	local temp = {}
	for i = start or 1, ending or #t do 
		temp[i] = t[i]
	end
	return temp
end


function WritCreater.MasterWritsQuestAdded(event, journalIndex,name)
	if not WritCreater.langMasterWritNames or not WritCreater.savedVarsAccountWide.masterWrits then return end
	local writNames = WritCreater.langMasterWritNames()
	local isMasterWrit = false
	local writType = ""
	for k, v in pairs(writNames) do
		if string.find(myLower(name), v) then
			if k == "M" then
				isMasterWrit = true
			else
				writType = k
			end

		end
	end
	--if not isMasterWrit then return end
	if not isMasterWrit then return end
	local langInfo = WritCreater.languageInfo()
	--local info = {}
	if writType =="" then 
		return
	else
		if writType=="weapon" then

			local info = partialTable(langInfo[CRAFTING_TYPE_BLACKSMITHING]["pieces"] , 1, 7)
			info = keyValueTable(info)
			local patternBlacksmithing =  smithingSearch(condition, info) --search pattern

			SmithingMasterWrit(journalIndex, info, CRAFTING_TYPE_BLACKSMITHING, false, "Rubedite")

			info = partialTable(langInfo[CRAFTING_TYPE_WOODWORKING]["pieces"] , 1, 6)
			info[6] = "healing"
			info[4] = "frost"
			info = keyValueTable(info)
			SmithingMasterWrit(journalIndex, info, CRAFTING_TYPE_WOODWORKING, false, "Ruby Ash")

		elseif writType == CRAFTING_TYPE_ALCHEMY then
		elseif writType == CRAFTING_TYPE_ENCHANTING then
			EnchantingMasterWrit(journalIndex)
		elseif writType == CRAFTING_TYPE_PROVISIONING then
		elseif writType == "shield" then
			local info = {{"shield",2}}
			if WritCreater.lang=="de" then info[1][1] ="schilden" end
			if WritCreater.lang=="fr" then info[1][1] = "bouclier" end
			SmithingMasterWrit(journalIndex, info, CRAFTING_TYPE_WOODWORKING, true, "Ruby Ash")
		elseif writType == "plate" then
			local info = partialTable(langInfo[CRAFTING_TYPE_BLACKSMITHING]["pieces"] , 8, 14)
			info = keyValueTable(info)

			SmithingMasterWrit(journalIndex, info, CRAFTING_TYPE_BLACKSMITHING, true, "Rubedite")
		elseif writType == "leatherwear" then
			local info = partialTable(langInfo[CRAFTING_TYPE_CLOTHIER]["pieces"] , 9, 15)
			info = keyValueTable(info)
			SmithingMasterWrit(journalIndex, info, CRAFTING_TYPE_CLOTHIER, true, "Rubedo Leather")
		elseif writType == "tailoring" then

			local info = partialTable(langInfo[CRAFTING_TYPE_CLOTHIER]["pieces"] , 1, 8)
			info = keyValueTable(info)
			SmithingMasterWrit(journalIndex, info, CRAFTING_TYPE_CLOTHIER, true, "Ancestor Silk")
		end

	end

end

local function QuestCounterChanged(event, journalIndex, questName, _, _, currConditionVal, newConditionVal, conditionMax)

	if newConditionVal<conditionMax then
		WritCreater.MasterWritsQuestAdded(event, journalIndex, questName)
	end

end


--EVENT_QUEST_ADDED found in AlchGrab File
EVENT_MANAGER:RegisterForEvent(WritCreater.name,EVENT_QUEST_CONDITION_COUNTER_CHANGED , QuestCounterChanged)

local function scanAllQuests()
	for i = 1, 25 do WritCreater.MasterWritsQuestAdded(1, i,GetJournalQuestName(i)) end
end

SLASH_COMMANDS['/rerunmasterwrits'] = scanAllQuests



SLASH_COMMANDS['/craftitems'] = function() WritCreater.LLCInteraction:CraftAllItems() end












