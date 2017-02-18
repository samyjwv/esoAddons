--Declarations
--GetSkillAbilityInfo(number SkillType skillType, number skillIndex, number abilityIndex)
--GetSkillLineInfo(number SkillType skillType, number skillIndex)

--[[local t = {}
for i =1, 500 do 
	local name, note, rankIndex, playerStatus, secs = GetGuildMemberInfo(2, i)
	if secs<604800 and rankIndex>3 then
		t[#t + 1] = name
	end
end
local winner = math.random(1,#t)
d("The winner is "..t[winner].."!")]]

--local d = function() for i = 1, #abc do end end
--test

WritCreater = {}


WritCreater.settings = {}
local LAM
local LAM2
WritCreater.languageStrings = {}
WritCreater.resetTime = true
WritCreater.version = 19
WritCreater.savedVars = {}
WritCreater.default = 
{
	["tutorial"]	= true,
	["ignoreAuto"] = false,
	["autoCraft"]	= false,
	["showWindow"]	= true,
	[1]	= true,
	[2]	= true,
	[3]	= true,
	[4]	= true,
	[5]	= true,
	[6]	= true,
	["delay"] = 100,
	["shouldGrab"] = true,
	["OffsetX"] = 1150,
	["OffsetY"] = 0,
	["styles"] = {true,true,true,true,true,true,true,true,true,true,},
	["debug"] = false,
	["autoLoot"] = true,
	["exitWhenDone"] = true,
	["autoAccept"] = true, 
	
}
WritCreater.defaultAccountWide = {
	["masterWrits"] = false,
	["identifier"] = math.random(1000),
	["timeSinceReset"] = GetTimeStamp(),
	["skipped"] = 0,
	["total"] = 0,
	["rewards"] = 
	{
		[CRAFTING_TYPE_BLACKSMITHING] = 
		{
			["recipe"] = {
				["white"] = 0,
				["green"] = 0,
				["blue"] = 0,
				["purple"] = 0,
				["gold"] = 0,
			},
			["survey"] = 0, 
			["ornate"] = 0,
			["intricate"] = 0,
			["num"] = 0, 
			["fragment"] = 0,
			["material"] = 0,
			["repair"] = 0,
			["master"] = 0,
		},
		[CRAFTING_TYPE_ALCHEMY] = 
		{
			["num"] = 0,
			["recipe"] = {
				["white"] = 0,
				["green"] = 0,
				["blue"] = 0,
				["purple"] = 0,
				["gold"] = 0,
			},
			["survey"] = 0,
			["master"] = 0,
		},
		[CRAFTING_TYPE_ENCHANTING] = 
		{
			["num"] = 0, 
			["recipe"] = {
				["white"] = 0,
				["green"] = 0,
				["blue"] = 0,
				["purple"] = 0,
				["gold"] = 0,
			},
			["survey"] = 0, 
			["glyph"] = 0,
			["soulGem"] = 0,
			["master"] = 0,
		},
		[CRAFTING_TYPE_WOODWORKING] = 
		{
			["num"] = 0,
			["survey"] = 0,
			["recipe"] = {
				["white"] = 0,
				["green"] = 0,
				["blue"] = 0,
				["purple"] = 0,
				["gold"] = 0,
			},
			["ornate"] = 0,
			["intricate"] = 0,
			["fragment"] = 0,
			["material"] = 0,
			["repair"] = 0,
			["master"] = 0,
		},
		[CRAFTING_TYPE_PROVISIONING] = 
		{
			["recipe"] = {
				["white"] = 0,
				["green"] = 0,
				["blue"] = 0,
				["purple"] = 0,
				["gold"] = 0,
			},
			["num"] = 0, 
			["fragment"] = 0, 
			["master"] = 0,
	 	},
		[CRAFTING_TYPE_CLOTHIER] = 
		{
			["ornate"] = 0,
			["recipe"] = {
				["white"] = 0,
				["green"] = 0,
				["blue"] = 0,
				["purple"] = 0,
				["gold"] = 0,
			},
			["survey"] = 0,
			["intricate"] = 0,
			["num"] = 0, 
			["fragment"] = 0,
			["material"] = 0,
			["repair"] = 0,
			["master"] = 0,
		},
	},
}
WritCreater.settings["panel"] =  
{
     type = "panel",
     name = "Dolgubon's Lazy Writ Crafter",
     registerForRefresh = true,
     displayName = "|c8080FF Dolgubon's Lazy Writ Crafter|r",
     author = "@Dolgubon"
}
WritCreater.settings["options"] =  {} 
local LibLazyCrafting  


local matSaver = 0
local craftingEnchantCurrently = false
local closeOnce = false

local inWritCreater = true

local writRewardNames

       --[[ RequestOpenMailbox()
        SendMail("@sylviermoone", "Testing 1", "with requestopen, then closemailbox after") d("sent test")
        CloseMailbox()]]

WritCreater.name = "DolgubonsLazyWritCreator"
local indexRanges = { --the first tier is index 1-7, second is material index 8-12, etc
	[1] = 7,
	[2] = 12,
	[3] = 17,
	[4] = 22,
	[5] = 25,
	[6] = 28,
	[7] = 29,
	[8] = 32,
	[9] = 39,
	[10] = 41,
	[11] = 7,
	[12] = 12,
	[13] = 17,
	[14] = 22,
	[15] = 25,
	[16] = 28,
	[17] = 29,
	[18] = 32,
	[19] = 39,
	[20] = 41,
}

local backdrop = DolgubonsWrits

local craftingWrits = false

local completionStrings


--Language declarations
local craftInfo

local potencyNames 

local essenceNames 

local craftCheck

local function getOut()
	return DolgubonsWritsBackdropOutput:GetText()
end

--outputs the string in the crafting window
local function out(string)
	--d(string)
	DolgubonsWritsBackdropOutput:SetText(string)
end


--[[
|H1:item:44812:129:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:131072|h|h
|H1:item:44812:134:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:131072|h|h
|H1:item:54339:134:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:65536|h|h
|H1:item:44810:134:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:917760|h|h
|H1:item:44715:134:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:1441792|h|h
|H1:item:30141:134:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:983040|h|h
]]



--Helper functions

--Capitalizes first letter, decapitalizes everything else
local function proper(str)
	if type(str)== "string" then
		return zo_strformat("<<C:1>>",str)
	else
		return str
	end
end

local function myLower(str)
	return zo_strformat("<<z:1>>",str)
end


local function myUpper(str)
	return zo_strformat("<<Z:1>>",str)
end

--string.match(input,"(%S*)%s+(%S*)")
--string.match(input,"([^"..seperater.."]*)"..seperater.."+(.*)")
--takes in a string and returns a table with each word seperate
local function parser(str)
	local seperater = "%s+"
	if WritCreater.lang ~= "jp" then 
		str = string.gsub(str,":"," ")
	else
		seperater = ":"
		str = string.gsub(str,"の",":")
		str = string.gsub(str,"を",":")
		str = string.gsub(str,"な",":")
	end
	local params = {}
	local i = 1
	local searchResult1, searchResult2  = string.find(str,seperater)
	if searchResult1 == 1 then
		str = string.sub(str, searchResult2+1)
		searchResult1, searchResult2  = string.find(str,seperater)
	end

	while searchResult1 do

		params[i] = string.sub(str, 1, searchResult1-1)
		str = string.sub(str, searchResult2+1)
	    searchResult1, searchResult2  = string.find(str,seperater)
	    i=i+1
	end 
	params[i] = str
	return params

end

WritCreater.parser = parser

function GetItemNameFromItemId(itemId)

	return GetItemLinkName(ZO_LinkHandler_CreateLink("Test Trash", nil, ITEM_LINK_TYPE,itemId, 1, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 10000, 0))
end


--debug functions
	--[[d("hey") [16:51] 12 17 8 20 1
	local function isItemInBackpack(item, amountNeeded)
		for i = 1, GetBagSize(BAG_BACKPACK) do
			if GetItemName(BAG_BACKPACK,i)==item then
				
				if amountNeeded and GetItemTotalCount(BAG_BACKPACK, i)< amountNeeded then
					
					return true,  GetItemTotalCount(BAG_BACKPACK, i)
				else

					return false , GetItemTotalCount(BAG_BACKPACK, i)
				end

			end
		end
		return true, 0
	end--]]

	--[[d
	local fauxConditions = {
	[1] = function() local item = "Grand Magicka" return "Craft "..item..": ", 0,1,false,false,false , item end,
	--[2] = function() local item = "Yew Ice Staff" return "Craft "..item..": ", 0,3,false,false,false , item end,
	--[3] = function() local item = "Yew Lightning Staff" return "Craft "..item..": ", 0,3,false,false,false , item end,
	--[2] = function() return "Craft 1 Rubedite Axe", 0,1,false,false,false end,
}

	GetJournalQuestConditionInfo = function(Qindex, stepIndex, conditionIndex)
	if Qindex ~= 1 then return "" end
	if not conditionIndex then return end

		if fauxConditions and conditionIndex<= #fauxConditions then

			if not isItemInBackpack then return fauxConditions[conditionIndex]() end
			local a, b, c,e,f,g, h = fauxConditions[conditionIndex]()
			local unfinished, current = isItemInBackpack(h,c)
			if unfinished then
				
				return a,current,c,e,f,g
			else

				return a, c,c,e,f,g
			end
		else
			return "hjhjh"
		end
	end
	GetJournalQuestConditionValues = function(Qindex, stepIndex, conditionIndex)
	local a, b, c = GetJournalQuestConditionInfo(Qindex, stepIndex, conditionIndex)
	return b,c 
end
	


	local function GetJournalQuestName(questIndex)
		if questIndex == 1 then
			return "Enchanter Writ"
		else 
			return ""
		end

	end

	 GetJournalQuestNumConditions = function(questIndex, stepIndex)

		return #fauxConditions
	end

	GetJournalQuestType = function(questIndex)
		if questIndex ==1 then
			return QUEST_TYPE_CRAFTING
		else
			return -1
		end
	end    --]]


--Crafting helper functions



local function maxStyle (piece) -- Searches to find the style that the user has the most style stones for. Only searches basic styles. User must know style
	local max = -1
	for i, v in pairs(WritCreater.savedVars.styles) do
		if GetCurrentSmithingStyleItemCount(i)>GetCurrentSmithingStyleItemCount(max) and IsSmithingStyleKnown(i, piece) then 
			if GetCurrentSmithingStyleItemCount(i)>0 and v then
				max = i
			end
		end
	end
	return max
end


--matches the condition text with what needs to be crafted
local function searchLevel(info,conditions,place)

	for i,value in pairs(conditions["text"]) do
		conditions[place][i] = false
		if conditions["text"][i] then
			for j = 1, #conditions["text"][i] do
				for k = 1, #info do
					if myUpper(conditions["text"][i][j]) == myUpper(info[k]) then
						conditions[place][i] = k
					end
				end
			end
		end
	end
end


local function addMats(type,num,matsRequired, pattern, index)

	local place = matsRequired[type]

	if place then

		place.amount = place.amount + num
	else
		place = {}
		matsRequired[type] = place
		place.amount =  num
	end
	if place.amount == 0 then place = nil return end
	place.pattern = pattern
	place.index = index

	place.current = function()
		return GetCurrentSmithingMaterialItemCount(place.pattern ,place.index)
	end		


end

local function sendNote(gold)
	DolgubonsWrits:SetHidden(true)
	DolgubonsWritsFeedback:SetHidden(true)
    SCENE_MANAGER:Show('mailSend')
    zo_callLater(function()
    ZO_MailSendToField:SetText('@Dolgubon')
    ZO_MailSendSubjectField:SetText("Dolgubon's Lazy Writ Crafter")
    if gold and GetWorldName() == "NA Megaserver" then
    	QueueMoneyAttachment(gold)
    end
    ZO_MailSendBodyField:TakeFocus() end, 200)
  end

WritCreater.SendNote = sendNote

local function doesCharHaveSkill(patternIndex,materialIndex,abilityIndex)

	local requirement =  select(10,GetSmithingPatternMaterialItemInfo( patternIndex,  materialIndex))
	
	local _,skillIndex = GetCraftingSkillLineIndices(GetCraftingInteractionType())
	local skillLevel = GetSkillAbilityUpgradeInfo(SKILL_TYPE_TRADESKILL ,skillIndex,abilityIndex )

	if skillLevel>=requirement then
		return true
	else
		return false
	end
end

local function setupConditionsTable(quest, info )
	local conditions =
	{
		["text"] = {},
		["cur"] = {},
		["max"] = {},
		["complete"] = {},
		["pattern"] = {},
		["mats"] = {},
	}
	for i = 1, GetJournalQuestNumConditions(quest,1) do
		conditions["text"][i], conditions["cur"][i], conditions["max"][i],_,conditions["complete"][i] = GetJournalQuestConditionInfo(quest, 1, i)
		conditions["text"][i] = WritCreater.exceptions(conditions["text"][i])
		--d(conditions["text"][i])
		if conditions["complete"][i] or conditions["text"][i] == "" or conditions["cur"][i]== conditions["max"][i] then
			conditions["text"][i] = nil
		else

			if string.find(myLower(conditions["text"][i]),"deliver") then
				conditions["text"][i] = nil
			else

				conditions["text"][i] = parser(conditions["text"][i])
			end
		end
	end
	searchLevel(info["pieces"],conditions,"pattern") --searches for pattern
	searchLevel(info["match"], conditions,"mats") --searches for the level of mats
	return conditions
end

local function writCompleteUIHandle()
	craftingWrits = false

	out(WritCreater.strings.complete)
	--if WritCreater.savedVars.exitWhenDone then SCENE_MANAGER:ShowBaseScene() end
	if WritCreater.savedVars.exitWhenDone and closeOnce then SCENE_MANAGER:ShowBaseScene() closeOnce = false end
	DolgubonsWritsBackdropCraft:SetHidden(true)
end

local queue = {}
local crafting = function() end

local function craftNextQueueItem(calledFromCrafting)
	
	if (not IsPerformingCraftProcess()) and (craftingWrits or WritCreater.savedVars.autoCraft ) then

		if queue[1] then

			if queue[1](true) then
				if WritCreater.savedVars.exitWhenDone then 
					closeOnce = true
				end
				out(getOut().."\n"..WritCreater.strings.crafting)
				table.remove(queue, 1)

			end
		else
			writCompleteUIHandle()			
		end
	elseif calledFromCrafting then
		return
	elseif IsPerformingCraftProcess() then
		return
	else
		--craftCheck(1, GetCraftingInteractionType())

		writs = WritCreater.writSearch()
		local station = GetCraftingInteractionType()
		if WritCreater.savedVars[station] and writs[station] then
			if station ~= CRAFTING_TYPE_PROVISIONING and station ~= CRAFTING_TYPE_ENCHANTING and station ~= CRAFTING_TYPE_ALCHEMY then
				DolgubonsWrits:SetHidden(not WritCreater.savedVars.showWindow)
				crafting(craftInfo[station],writs[station],craftingWrits)
			end
		end
	
		--craftCheck(1,GetCraftingInteractionType())
	end

end

local function createMatRequirementText(matsRequired)
	--d(matsRequired)
	local text = ""
	local unfinished = false
	local haveMats = true

	for type, value in pairs(matsRequired) do

		if value.amount ~= 0 then unfinished = true end

		if text ~= "" then
			if value.current()<value.amount then
				text = text..WritCreater.strings.smithingReqM2(value.amount,type, value.amount - value.current())
				haveMats = false
			else
				text = text..WritCreater.strings.smithingReq2(value.amount,type, value.current())
			end
		else
			if value.current()<value.amount then
				text = text..WritCreater.strings.smithingReqM(value.amount,type, value.amount - value.current())
				haveMats = false
			else

				text = text..WritCreater.strings.smithingReq(value.amount,type, value.current())
			end
		end
	end
	if not unfinished then out(WritCreater.strings.complete)  

		if WritCreater.savedVars.exitWhenDone and closeOnce then SCENE_MANAGER:ShowBaseScene() closeOnce = false end
		return 
	end

	if  haveMats then
		text = text..WritCreater.strings.smithingEnough
		DolgubonsWritsBackdropCraft:SetText(WritCreater.strings.craft)
	else
		text=text..WritCreater.strings.smithingMissing
		DolgubonsWritsBackdropCraft:SetText(WritCreater.strings.craftAnyway)
	end
	out(text)	
end

crafting = function(info,quest, craftItems)
	--if #queue>0 then return end

	out("If you see this, something is wrong.\nCopy the quest conditions, and send to Dolgubon\non esoui")
	queue = {}
	local style
	local matsRequired = {}
	
	local numMats
	
	local conditions  = setupConditionsTable(quest, info)

	for i,value in pairs(conditions["text"]) do

		local pattern, index = conditions["pattern"][i], indexRanges[conditions["mats"][i]]
		if pattern and index then

			 -- pattern is are we making gloves, chest, etc. Index is level.
			numMats = GetSmithingPatternNextMaterialQuantity(pattern, index,1,1)
			local curMats = GetCurrentSmithingMaterialItemCount(pattern, index)
			
			if not doesCharHaveSkill(pattern, index,1) then
				out(WritCreater.strings.notEnoughSkill)
				return
			else

			
				style = maxStyle()
				if style == -1 then out(WritCreater.strings.moreStyle) return false end
				
				local needed = conditions["max"][i] - conditions["cur"][i]
				for s = 1, needed do
					addMats(info["names"][conditions["mats"][i]],numMats ,matsRequired, conditions["pattern"][i], indexRanges[conditions["mats"][i]] )

					--d("queueing "..info["pieces"][conditions["pattern"][i]].." "..info["match"][conditions["mats"][i]])
					--d(conditions["pattern"][i] ,indexRanges[conditions["mats"][i]],numMats,style,1)
					--d("initial check"..(not IsPerformingCraftProcess()))
					
					queue[#queue + 1]= 
					function(changeRequired)
						local numMats = GetSmithingPatternNextMaterialQuantity(pattern, index,1,1)
						local curMats = GetCurrentSmithingMaterialItemCount(pattern, index)
						if numMats<=curMats then 
							local style = maxStyle()
							if style == -1 then out(WritCreater.strings.moreStyle) return false end
							CraftSmithingItem(pattern, index,numMats,style,1)

							DolgubonsWritsBackdropCraft:SetHidden(true) 
							if changeRequired then return true end
							addMats(info["names"][conditions["mats"][i]], -numMats ,matsRequired, conditions["pattern"][i], indexRanges[conditions["mats"][i]] )
							createMatRequirementText(matsRequired)
							return true
							
						else 
							return false
						end 
					end

				end
			end
		else
			--d("pattern not found",conditions["pattern"][i], conditions["mats"][i])
			return --pattern or level not found.
		end
	end

	createMatRequirementText(matsRequired)


	queue.updateCraftRequirements = function() 
		createMatRequirementText(matsRequired)
	end

	if queue[1] then
		if not craftingWrits then DolgubonsWritsBackdropCraft:SetHidden(false) end
		craftNextQueueItem(true)
	else

		writCompleteUIHandle()
	end
	
end


local function enchantSearch(info,conditions, position,parity)
	for i = 1, #conditions["text"] do
		if conditions["text"][i] then
			for j = 1, #conditions["text"][i] do
				for k = 1, #info do
					if myUpper(conditions["text"][i][j]) == myUpper(info[k][1]) then
						if type(info[k][2])=="table" then
							conditions[position][i] = info[k][2][parity]
						else
							conditions[position][i] = info[k][2]
							return info[k][3]
						end
					end
				end
			end
		end
	end
	return nil
end

local function formatName(text)
	if text then
		local pos = string.find(text,"^",1,true)
		if pos then
			return string.sub(text,1, pos-1)
		end
	end
	
	return text
end


function findItem(item)

	for i=0, GetBagSize(BAG_BANK) do
		if GetItemId(BAG_BANK,i)==item  then
			return BAG_BANK, i
		end
	end
	for i=0, GetBagSize(BAG_BACKPACK) do
		if GetItemId(BAG_BACKPACK,i)==item then
			return BAG_BACKPACK,i
		end
	end
	if GetItemId(BAG_VIRTUAL, item) ~=0 then
		
		return BAG_VIRTUAL, item

	end
	return nil, GetItemNameFromItemId(item)
end

local function enchantCrafting(info, quest,add)
	out("")

	ENCHANTING.potencySound = SOUNDS["NONE"]
	ENCHANTING.potencyLength = 0
	ENCHANTING.essenceSound = SOUNDS["NONE"]
	ENCHANTING.essenceLength = 0
	ENCHANTING.aspectSound = SOUNDS["NONE"]
	ENCHANTING.aspectLength = 0
	local  numConditions = GetJournalQuestNumConditions(quest,1)
	local conditions = 
	{
		["text"] = {},
		["cur"] = {},
		["max"] = {},
		["complete"] = {},
		["glyph"] = {},
		["type"] = {},
	}
	for i = 1, numConditions do
		conditions["text"][i], conditions["cur"][i], conditions["max"][i],a,conditions["complete"][i] = GetJournalQuestConditionInfo(quest, 1, i)
		conditions["text"][i] = WritCreater.enchantExceptions(conditions["text"][i])
		if conditions["cur"][i]>0 then conditions["text"][i] = "" end

		if string.find(myLower(conditions["text"][i]),"deliver") then
			out(WritCreater.strings.complete)
			if WritCreater.savedVars.exitWhenDone and closeOnce then SCENE_MANAGER:ShowBaseScene() closeOnce = false end

			DolgubonsWritsBackdropCraft:SetHidden(true)
			conditions["text"][i] = false
			return
		elseif string.find(myLower(conditions["text"][i]),"acquire") or string.find(myLower(conditions["text"][i]),"rune") then
			conditions["text"][i] = false
		elseif conditions["text"][i] =="" then
		else
			conditions["text"][i] = parser(conditions["text"][i])
			DolgubonsWritsBackdropCraft:SetHidden(false)
			local parity = enchantSearch(info["pieces"], conditions,"type") --searches for pattern
			enchantSearch(info["match"], conditions,"glyph", parity) --searches for the type of mats
			if conditions["text"][i] then
				local ta={}
				local essence={}
				local potency={}
				local taString

				taString = WritCreater.getTaString()

				ta["bag"],ta["slot"] = findItem(45850)
				
				essence["bag"], essence["slot"] = findItem(conditions["type"][i])
				potency["bag"], potency["slot"] = findItem(conditions["glyph"][i])

				if essence["slot"] == nil or potency["slot"] == nil  or ta["slot"]== nil then -- should never actually be run, but whatever
					out("An error was encountered.")
					return
				end
				if not add then
					if essence["bag"] and potency["bag"] and ta["bag"] then
						out(WritCreater.strings.runeReq(GetItemName(essence["bag"], essence["slot"]),GetItemName(potency["bag"], potency["slot"])))
						DolgubonsWritsBackdropCraft:SetHidden(false)
					else
						out(WritCreater.strings.runeMissing(proper(ta),proper(essence),proper(potency)))
						DolgubonsWritsBackdropCraft:SetHidden(true)
					end
				else
					if essence["bag"] and potency["bag"] and ta["bag"] then
						craftingEnchantCurrently = true
						--d(conditions["type"][i],conditions["glyph"][i])
						local runeNames = {
							proper(GetItemName(essence["bag"], essence["slot"])),
							proper(GetItemName(potency["bag"], potency["slot"])),
						}
						out(WritCreater.strings.runeReq(unpack(runeNames)).."\n"..WritCreater.strings.crafting)
						DolgubonsWritsBackdropCraft:SetHidden(true)
						--d(GetEnchantingResultingItemInfo(potency["bag"], potency["slot"], essence["bag"], essence["slot"], ta["bag"], ta["slot"]))
						if WritCreater.savedVars.exitWhenDone then 
							closeOnce = true
						end
						CraftEnchantingItem(potency["bag"], potency["slot"], essence["bag"], essence["slot"], ta["bag"], ta["slot"])					

						zo_callLater(function() craftingEnchantCurrently = false end,4000) 
						craftingWrits = false
					else
						out("Glyph could not be crafted\n"..WritCreater.strings.runeMissing(ta,essence,potency))
						DolgubonsWritsBackdropCraft:SetHidden(true)
						craftingWrits = false
					end
				end
			end
		end
	end

	
	function ZO_SharedEnchanting:Create()
	    if self.enchantingMode == ENCHANTING_MODE_CREATION then
	        local rune1BagId, rune1SlotIndex, rune2BagId, rune2SlotIndex, rune3BagId, rune3SlotIndex = self:GetAllCraftingBagAndSlots()
	        self.potencySound, self.potencyLength = GetRunestoneSoundInfo(rune1BagId, rune1SlotIndex)
	        self.essenceSound, self.essenceLength = GetRunestoneSoundInfo(rune2BagId, rune2SlotIndex)
	        self.aspectSound, self.aspectLength = GetRunestoneSoundInfo(rune3BagId, rune3SlotIndex)
	        CraftEnchantingItem(rune1BagId, rune1SlotIndex, rune2BagId, rune2SlotIndex, rune3BagId, rune3SlotIndex)
	    elseif self.enchantingMode == ENCHANTING_MODE_EXTRACTION then
	        ExtractEnchantingItem(self.extractionSlot:GetBagAndSlot())
	        self.extractionSlot:ClearDropCalloutTexture()
	    end
	end
end




local function writSearch()
	local W = {}
	for i=1 , 25 do
		local Qname=GetJournalQuestName(i)
		Qname=WritCreater.questExceptions(Qname)
		if GetJournalQuestType(i) == QUEST_TYPE_CRAFTING or string.find(Qname, WritCreater.writNames["G"])then
			for j = 1, 6 do 
				if string.find(myLower(Qname),myLower(WritCreater.writNames[j])) then
					W[j] = i
				end
			end
		end
	end
	return W
end
WritCreater.writSearch = writSearch

local tutorial1 = function () end

local function temporarycraftcheckerjustbecause(eventcode, station)
	
	local currentAPIVersionOfAddon = 100017
	if GetTimeStamp()>1486339200 then
		currentAPIVersionOfAddon = currentAPIVersionOfAddon + 1
	end
	if GetAPIVersion() > currentAPIVersionOfAddon and GetWorldName()~="PTS" then 
		for i= 1, 10 do 
			d("Update your addons!") 
		end 
	end

	if GetAPIVersion() > currentAPIVersionOfAddon+1 and GetDisplayName()=="@Dolgubon" and GetWorldName()=="PTS"  then 
		for i = 1 , 20 do 
			d("Set a reminder to change the API version of addon in function temporarycraftcheckerjustbecause when the game update comes out.") 
		end
	end
	local writs
	if WritCreater.savedVars.tutorial then
		DolgubonsWrits:SetHidden(false)
		tutorial1()
	else
		craftInfo = WritCreater.languageInfo()
		if craftInfo then
			if WritCreater.savedVars.autoCraft then
				craftingWrits = true
			end
			writs = writSearch()

			if WritCreater.savedVars[station] and writs[station] then
				if station == CRAFTING_TYPE_ENCHANTING then

					DolgubonsWrits:SetHidden(not WritCreater.savedVars.showWindow)
					enchantCrafting(craftInfo[station],writs[station],craftingWrits)
				elseif station == CRAFTING_TYPE_PROVISIONING then
				elseif station== CRAFTING_TYPE_ALCHEMY then
				else

					DolgubonsWrits:SetHidden(not WritCreater.savedVars.showWindow)
					crafting(craftInfo[station],writs[station],craftingWrits)
				end
			end
		else
			DolgubonsWrits:SetHidden(false)
			local text = "The current client language is not supported. \nPlease contact Dolgubon on esoui if you are interested in translating for this language.\n"
			out(text)
		end
		-- Prevent UI bug due to fast Esc
		CALLBACK_MANAGER:FireCallbacks("CraftingAnimationsStopped")
	end
end

craftCheck = temporarycraftcheckerjustbecause

WritCreater.craft = function()  local station =GetCraftingInteractionType() craftingWrits = true 
	if station == CRAFTING_TYPE_ENCHANTING then 

		local writs = writSearch()
		enchantCrafting(craftInfo[CRAFTING_TYPE_ENCHANTING],writs[CRAFTING_TYPE_ENCHANTING],craftingWrits)

	elseif station == CRAFTING_TYPE_ALCHEMY then
	elseif station == CRAFTING_TYPE_PROVISIONING then
	else
		craftNextQueueItem() 
	end 
end

local currentTutorialStep = 0

local function tutorial5()
	WritCreater.savedVars.tutorial = false

	currentTutorialStep = 5
	out(WritCreater.langTutorial(5))
	DolgubonsWritsBackdropSettingOn:SetText(WritCreater.langTutorialButton(5,true))

end

local function tutorial4()
	currentTutorialStep = 4
	out(WritCreater.langTutorial(4))
	DolgubonsWritsBackdropSettingOn:SetText(WritCreater.langTutorialButton(4,true))
	DolgubonsWritsBackdropSettingOff:SetHidden(true)
	DolgubonsWritsBackdropSettingOn:ClearAnchors()
	DolgubonsWritsBackdropSettingOn:SetAnchor(BOTTOM,DolgubonsWritsBackdrop,BOTTOM,0,-230)
end

local function tutorial3()
	currentTutorialStep = 3
	out(WritCreater.langTutorial(3))
	DolgubonsWritsBackdropSettingOff:SetText(WritCreater.langTutorialButton(3,false))
	DolgubonsWritsBackdropSettingOn:SetText(WritCreater.langTutorialButton(3,true))
end

local function tutorial2()
	currentTutorialStep = 2
	out(WritCreater.langTutorial(2))
	DolgubonsWritsBackdropSettingOff:SetText(WritCreater.langTutorialButton(2,false))
	DolgubonsWritsBackdropSettingOn:SetText(WritCreater.langTutorialButton(2,true))
end

tutorial1 = function()
	DolgubonsWritsBackdrop:SetDimensions (500,500)
	currentTutorialStep = 1
	DolgubonsWritsBackdropCraft:SetHidden(true)
	out(WritCreater.langTutorial(1))
	DolgubonsWritsBackdropSettingOn:SetHidden(false)
	DolgubonsWritsBackdropSettingOff:SetHidden(false)
	DolgubonsWritsBackdropSettingOn:SetText(WritCreater.langTutorialButton(1,true))
	DolgubonsWritsBackdropSettingOff:SetText(WritCreater.langTutorialButton(1,false))

	DolgubonsWritsBackdropSettingOn:ClearAnchors()
	DolgubonsWritsBackdropSettingOn:SetAnchor(BOTTOM,DolgubonsWritsBackdrop,BOTTOM,-80,-230)

	DolgubonsWritsBackdropSettingOff:ClearAnchors()
	DolgubonsWritsBackdropSettingOff:SetAnchor(BOTTOM,DolgubonsWritsBackdrop,BOTTOM,80,-230)

	DolgubonsWritsBackdropOutput:ClearAnchors()
 	DolgubonsWritsBackdropOutput:SetAnchor(TOPLEFT,PARENT, TOPLEFT, 35, 100)

	DolgubonsWritsBackdropHead:ClearAnchors()
 	DolgubonsWritsBackdropHead:SetAnchor(TOPLEFT, PARENT, TOPLEFT, 160,70)
	
end
local function resetWindowElements()
	DolgubonsWritsBackdrop:SetDimensions (500,400)
	DolgubonsWritsBackdropOutput:ClearAnchors()
 	DolgubonsWritsBackdropOutput:SetAnchor(TOP,PARENT, TOP, -10,80)

	DolgubonsWritsBackdropHead:ClearAnchors()
 	DolgubonsWritsBackdropHead:SetAnchor(TOP, PARENT, TOP, 0,55)
end
local function onButton()
	if currentTutorialStep ==5 then
		DolgubonsWrits:SetHidden(true)
		craftCheck(1,GetCraftingInteractionType())
		WritCreater.savedVars.tutorial = false
		DolgubonsWritsBackdropSettingOn:SetHidden(true)
		resetWindowElements()
	elseif currentTutorialStep ==4 then
		tutorial5()
	elseif currentTutorialStep ==3 then
		WritCreater.savedVars.showWindow=true
		tutorial4()
	elseif currentTutorialStep ==2 then
		WritCreater.savedVars.autoCraft=true
		tutorial3()
	elseif currentTutorialStep ==1 then
		WritCreater.savedVars.tutorial = false
		DolgubonsWrits:SetHidden(true)
		craftCheck(1,GetCraftingInteractionType())
		DolgubonsWritsBackdropSettingOn:SetHidden(true)
		DolgubonsWritsBackdropSettingOff:SetHidden(true)
		resetWindowElements()
		
	end
	
end

local function offButton()

	if currentTutorialStep ==3 then
		WritCreater.savedVars.showWindow=false
		tutorial4()
	end
	if currentTutorialStep ==2 then
		WritCreater.savedVars.autoCraft=false
		WritCreater.savedVars.showWindow=true
		tutorial4()
	end
	if currentTutorialStep ==1 then
		tutorial2()
	end
end

WritCreater.on=onButton

WritCreater.off=offButton

local function closeWindow(event, station)
	DolgubonsWritsFeedback:SetHidden(true)
	DolgubonsWrits:SetHidden(true)
	craftingWrits = false
	WritCreater.savedVars.OffsetX = DolgubonsWrits:GetRight()
	WritCreater.savedVars.OffsetY = DolgubonsWrits:GetTop()
	queue = {}
	DolgubonsWritsBackdropCraft:SetHidden(false)
	closeOnce = false
	
end


EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_CRAFTING_STATION_INTERACT, craftCheck)

--EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_CRAFT_COMPLETED, crafteventholder)
EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_CRAFT_COMPLETED, 
	function(event, station) 
		if station == CRAFTING_TYPE_ENCHANTING then
			craftCheck(event, station)
		elseif station ==CRAFTING_TYPE_PROVISIONING then
		elseif station == CRAFTING_TYPE_ALCHEMY then
		else
			craftCheck(event, station) craftNextQueueItem() 
		end
		end)
EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_END_CRAFTING_STATION_INTERACT, closeWindow)



local function HandleQuestCompleteDialog(eventCode, journalIndex)
	local writs = writSearch()
	local writComplete = false
	local currentWritDialogue = 0
	for i = 1, 6 do
		if type(writs[i]) == "number" then
			writComplete = writComplete or GetJournalQuestIsComplete(writs[i])
			currentWritDialogue= i
		end
	end
	EVENT_MANAGER:UnregisterForEvent(WritCreater.name, EVENT_QUEST_COMPLETE_DIALOG)

	if not writComplete then return end
	-- Increment the number of writs complete number
	WritCreater.savedVarsAccountWide["rewards"][currentWritDialogue]["num"] = WritCreater.savedVarsAccountWide["rewards"][currentWritDialogue]["num"] + 1
	WritCreater.savedVarsAccountWide["total"] = WritCreater.savedVarsAccountWide["total"] + 1
    -- Complete the writ quest
	CompleteQuest()

end
local function HandleEventQuestOffered(eventCode)
    -- Stop listening for quest offering
    EVENT_MANAGER:UnregisterForEvent(WritCreater.name, EVENT_QUEST_OFFERED)
    -- Accept the writ quest
    AcceptOfferedQuest()
end

local function isQuestTypeActive(optionString)
	optionString = string.gsub(optionString, "tailleur", "couture")

	for i = 1, 6 do

		if string.find(string.lower(optionString), string.lower(WritCreater.writNames[i])) and (WritCreater.savedVars[i] or WritCreater.savedVars[i]==nil) then 
			return true
		
		end
	end

	return false
end
local function HandleChatterBegin(eventCode, optionCount)
	if not WritCreater.savedVars.autoAccept then return end
    -- Ignore interactions with no options
    if optionCount == 0 then return end
    for i = 1, optionCount do
	    -- Get details of first option
	    local optionString, optionType = GetChatterOption(i)
	    -- If it is a writ quest option...
	    if optionType == CHATTER_START_NEW_QUEST_BESTOWAL 
	       and string.find(string.lower(optionString), string.lower(WritCreater.writNames["G"])) ~= nil 
	    then
	    	if isQuestTypeActive(optionString) then
				-- Listen for the quest offering
				EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_QUEST_OFFERED, HandleEventQuestOffered)
				-- Select the first writ
				SelectChatterOption(i)
			end
	        
	    -- If it is a writ quest completion option
	    elseif optionType == CHATTER_START_ADVANCE_COMPLETABLE_QUEST_CONDITIONS
	       and string.find(string.lower(optionString), string.lower(completionStrings.place)) ~= nil  
	    then
	        -- Listen for the quest complete dialog
	        EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_QUEST_COMPLETE_DIALOG, HandleQuestCompleteDialog)
	        -- Select the first option to complete the quest
	        SelectChatterOption(1)
	    
	    -- If the goods were already placed, then complete the quest
	    elseif optionType == CHATTER_START_COMPLETE_QUEST
	       and (string.find(string.lower(optionString), string.lower(completionStrings.place)) ~= nil 
	            or string.find(string.lower(optionString), string.lower(completionStrings.sign)) ~= nil)
	    then
	        -- Listen for the quest complete dialog
	        EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_QUEST_COMPLETE_DIALOG, HandleQuestCompleteDialog)
	        -- Select the first option to place goods and/or sign the manifest
	        SelectChatterOption(1)
	    end
	end
end

--Saves what the user got from the writ rewards

local function saveStats(loot, boxType, boxRank)
	local vars = WritCreater.savedVarsAccountWide -- shortcut
	local location = boxType
	if boxType == 1 then end

	vars = vars["rewards"][location]
	if vars["level"] > boxRank then
		WritCreater.savedVarsAccountWide["total"] = WritCreater.savedVarsAccountWide["total"] - vars["num"]
		vars = WritCreater.defaultAccountWide["rewards"][location]
		vars["level"] = boxRank
	elseif vars["level"] == boxRank then
		WritCreater.savedVarsAccountWide["total"] = WritCreater.savedVarsAccountWide["total"] + 1
	else
		WritCreater.savedVarsAccountWide["skipped"] = WritCreater.savedVarsAccountWide["skipped"] + 1
		return
	end
	vars["num"] = vars["num"] + 1


	for key, value in pairs(vars) do
		if key == "num" or key == "level" or key == "gold" then
		else
			for i = 1, #loot do
				if string.find(string.lower(loot[i]["name"]),string.lower(key)) then
					vars[key] = vars[key] + loot[i]["quantity"]
				end
			end
		end
	end
	WritCreater.savedVarsAccountWide["rewards"][location] = vars
end

-- Converts a roman nummeral from 1 to 10 into an integer
function romanNumeral(number)
	if number == "X" then
		return 10
	elseif number == "IX" then
		return 9
	elseif string.sub(number,1,1) == "V" then
		return 5 + romanNumeral(string.sub(number,2))
	elseif number == "IV" then
		return 4
	elseif number == "III" then
		return 3
	elseif number == "II" then
		return 2
	elseif number =="I" then
		return 1
	else 
		return 0
	end
end

function GetItemIDFromLink(itemLink) return tonumber(string.match(itemLink,"|H%d:item:(%d+)")) end

local function updateSavedVars(vars, location, quantity)
	if vars[location] then
		vars[location] = vars[location] + quantity
	else
		vars[location] = quantity
	end
end

--begin the save stat process. Also decides if a mail with current stats should be sent.
local function LootAllHook(boxType, boxRank) -- technically not a hook. 
	local vars = WritCreater.savedVarsAccountWide["rewards"][boxType]
	local loot = {}
	for i = 1, 10 do

		local lootId, name, _, quantity = GetLootItemInfo(i)
		local itemLink = GetLootItemLink(lootId, 0)
		--d(itemLink)
		local itemType, specializedType = GetItemLinkItemType(itemLink) 
		-- if it's gear
		if name=="" then
		elseif itemType==ITEMTYPE_ARMOR or itemType==ITEMTYPE_WEAPON then
			if GetItemLinkTraitInfo(itemLink)==19 then
				updateSavedVars(vars, "ornate", quantity)
			else
				updateSavedVars(vars, "intricate", quantity)
			end
		elseif CanItemLinkBeVirtual(itemLink) then 
			updateSavedVars(vars, GetItemIDFromLink(itemLink), quantity)
		elseif itemType==ITEMTYPE_RECIPE then 
			local quality = GetItemLinkQuality(itemLink)
			if quality==ITEM_QUALITY_MAGIC then
				updateSavedVars(vars["recipe"], "green", quantity)
			elseif quality == ITEM_QUALITY_ARCANE then
				updateSavedVars(vars["recipe"], "blue", quantity)
			elseif quality == ITEM_QUALITY_ARTIFACT then
				updateSavedVars(vars["recipe"], "purple", quantity)
			elseif quality == ITEMITEM_QUALITY_NORMAL then
				updateSavedVars(vars["recipe"], "white", quantity)
			elseif quality == ITEM_QUALITY_LEGENDARY then
				updateSavedVars(vars["recipe"], "gold", quantity)
			else
				updateSavedVars(vars["recipe"], "unkownQuality", quantity)
			end
		elseif specializedType==SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT then
			updateSavedVars(vars, "survey", quantity)
		elseif specializedType ==SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT then
			updateSavedVars(vars, "fragment", quantity)
		elseif itemType ==ITEMTYPE_CONTAINER then
			updateSavedVars(vars, "material", quantity)
		elseif itemType ==ITEMTYPE_TOOL then
			updateSavedVars(vars, "repair", quantity)
		elseif itemType ==ITEMTYPE_GLYPH_JEWELRY or itemType ==ITEMTYPE_GLYPH_ARMOR or itemType ==ITEMTYPE_GLYPH_WEAPON then
			updateSavedVars(vars, "glyph", quantity)
		elseif itemType == ITEMTYPE_SOUL_GEM then 
			updateSavedVars(vars, "soulGem", quantity)
		elseif itemType == ITEMTYPE_MASTER_WRIT then
			updateSavedVars(vars, "master", quantity)
		else
			if vars["other"]==nil then vars["other"] = {} end
			updateSavedVars(vars, "other", quantity)
		end
	end
	--saveStats(loot,boxType,boxRank)
end

--if the stats should be saved, saves them

local function shouldSaveStats(boxType, boxRank)
	if GetNumLootItems() < 2 then return false end

	return true
end



--If the box/loot item that is open is a writ container, loot it and open the inventory again

local function OnLootUpdated(event)
	local ignoreAuto = WritCreater.savedVars.ignoreAuto
	local autoLoot 
	if ignoreAuto then
		autoLoot = WritCreater.savedVars.autoLoot
	else
		autoLoot = GetSetting(SETTING_TYPE_LOOT,LOOT_SETTING_AUTO_LOOT) == "1"
	end
	if autoLoot then
		local lootInfo = {GetLootTargetInfo()}
		for i = 1, #writRewardNames do
			local a, b = string.find(lootInfo[1], writRewardNames[i])
			if a then				
				LOOT_SHARED:LootAllItems()
				--local boxRank = romanNumeral(string.sub(lootInfo[1], b + 2))
				if shouldSaveStats(i,boxRank) then LootAllHook(i,boxRank) end
				--SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_INVENTORY)
				zo_callLater(function() SYSTEMS:GetObject("mainMenu"):ShowCategory(MENU_CATEGORY_INVENTORY)end, 50)
				
			end
		end
	end
end



function WritCreater:Initialize()
	DolgubonsWrits:SetHidden(true)
	LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("DolgubonsWritCrafter", WritCreater.settings["panel"])
	WritCreater.settings["options"] = WritCreater.Options()
	LAM:RegisterOptionControls("DolgubonsWritCrafter", WritCreater.settings["options"])
	craftInfo = WritCreater.languageInfo
	WritCreater.craftInfo = WritCreater.languageInfo()

	SLASH_COMMANDS['/dailyreset'] = WritCreater.resetTime


	WritCreater.savedVars = ZO_SavedVars:NewCharacterIdSettings("DolgubonsWritCrafterSavedVars", WritCreater.version, nil, WritCreater.default)
	WritCreater.savedVarsAccountWide = ZO_SavedVars:NewAccountWide("DolgubonsWritCrafterSavedVars", WritCreater.version, nil, WritCreater.defaultAccountWide)

	SLASH_COMMANDS['/dlazybank'] = function() 
		WritCreater.savedVarsAccountWide["easyBank"] = not WritCreater.savedVarsAccountWide["easyBank"]
		if WritCreater.savedVarsAccountWide["easyBank"] then
			d("Reload the UI for this to take effect. Effect is on.")
		else
			d("Reload the UI for this to take effect. Effect is off.")
		end
	end

	WritCreater.setupAlchGrabEvents()
	--copy old saved vars onto new ones
	if WritCreater.savedVars[1] == nil then WritCreater.savedVars[1] = WritCreater.savedVars["Blacksmith"] end
	if WritCreater.savedVars[2] == nil then WritCreater.savedVars[2] = WritCreater.savedVars["Clothier"] end
	if WritCreater.savedVars[3] == nil then WritCreater.savedVars[3] = WritCreater.savedVars["Enchanter"] end
	if WritCreater.savedVars[6] == nil then WritCreater.savedVars[6] = WritCreater.savedVars["Woodworker"] end

	potencyNames = WritCreater.langPotencyNames()
	essenceNames = WritCreater.langEssenceNames()

	WritCreater.writNames = WritCreater.langWritNames()
	DolgubonsWrits:ClearAnchors()
	DolgubonsWrits:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, WritCreater.savedVars.OffsetX-470, WritCreater.savedVars.OffsetY)

	completionStrings = WritCreater.writCompleteStrings()

	local function ZO_AlertNoSuppression_Hook(category, soundId, message)
		if message == SI_ENCHANT_NO_YIELD and craftingEnchantCurrently then
			return true
		else
			return false
		end
	end
	ZO_PreHook("ZO_AlertNoSuppression", ZO_AlertNoSuppression_Hook)

	if GetWorldName() ~= "NA Megaserver" then
		DolgubonsWritsFeedbackSmall:SetHidden(true)
		DolgubonsWritsFeedbackMedium:SetHidden(true)
		DolgubonsWritsFeedbackLarge:SetHidden(true)
		DolgubonsWritsFeedbackNote:SetText("If you found a bug, have a request or a suggestion, send me a mail.")

	end
	LibLazyCrafting = LibStub:GetLibrary("LibLazyCrafting")
	WritCreater.LLCInteraction = LibLazyCrafting:AddRequestingAddon(WritCreater.name, true, function(...) end)
	writRewardNames = WritCreater.langWritRewardBoxes()

	EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_CHATTER_BEGIN, HandleChatterBegin)
	EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_LOOT_UPDATED ,OnLootUpdated )
	
	for i = 1, 25 do WritCreater.MasterWritsQuestAdded(1, i,GetJournalQuestName(i)) end
	
	
	
	
	
	--if GetDisplayName() == "@Dolgubon" then EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_MAIL_READABLE, function(event, code) local displayName,_,subject =  GetMailItemInfo(code) WritCreater.savedVarsAccountWide["mails"]  d(displayName) d(subject) d(ReadMail(code)) end) end

end

function getItemLinkFromItemId(itemId) local name = GetItemLinkName(ZO_LinkHandler_CreateLink("Test Trash", nil, ITEM_LINK_TYPE,itemId, 1, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 10000, 0)) 
	return ZO_LinkHandler_CreateLink(zo_strformat("<<t:1>>",name), nil, ITEM_LINK_TYPE,itemId, 1, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 10000, 0) end

SLASH_COMMANDS['/outputwritstats'] = function()
	for k, v in pairs(WritCreater.savedVarsAccountWide["rewards"]) do 
		if type(v) == "table" then 
			d("---------------")
			d(WritCreater.writNames[k].." Stats")
			for statType, stats in pairs(v) do 
				if stats==0 then
				elseif type(stats)=="table" then
					for quality, amount in pairs(stats) do
						if amount~=0 then
							d(quality.." recipes: "..amount)
						end
					end
				else
					if type(statType)=="number" then
						d(getItemLinkFromItemId(statType)..": "..tostring(stats))
					else
						d(statType..": "..tostring(stats))
					end
				end
			end
		elseif type(v)=="function" then
		else
			d(k..": "..tostring(v))
		end
	end
	local daysSinceReset = math.floor((GetTimeStamp() - WritCreater.savedVarsAccountWide.timeSinceReset)/86400*100)/100
	d("Total Writs Completed: "..WritCreater.savedVarsAccountWide.total.." in the past "..tostring(daysSinceReset).." days")
end




SLASH_COMMANDS['/resetwritstatistics'] = function() 
	WritCreater.savedVarsAccountWide = WritCreater.defaultAccountWide 
	WritCreater.savedVarsAccountWide.timeSinceReset = GetTimeStamp() 
	d("Writ statistics reset.")
end

SLASH_COMMANDS['/resetwcsettings'] = function() WritCreater.savedVars = WritCreater.default d("settings reset") end
SLASH_COMMANDS['/dlwcdebug'] = function() WritCreater.savedVars.debug = not WritCreater.savedVars.debug d(WritCreater.savedVars.debug) end
SLASH_COMMANDS['/abaondwrits'] = function() local a = writSearch() d("Abandon Ship!!!") for i = 1, 6 do AbandonQuest(a[i]) end end

--[[SLASH_COMMANDS['/wcbag'] = function (str)
	t = parser (str)
	d(GetItemLink(tostring(t[1]),tostring(t[2]),LINK_STYLE_DEFAULT))
end]]

SLASH_COMMANDS['/dlwcfindwrit'] = function (params)
	for i=1 , GetNumJournalQuests() do
		Qname=GetJournalQuestName(i)

		if string.find (Qname, "Writ") then
			if string.find(Qname, "Alchemist") then
				d("Alchemist Writ = "..i)
			end
			if string.find(Qname, "Blacksmith") then
				d("Blacksmith Writ = "..i)
			end
			if string.find(Qname, "Woodworker") then
				d("Woodworker Writ = "..i)
			end
			if string.find(Qname, "Provisioner") then
				d("Provisioner Writ = "..i)
			end
			if string.find(Qname, "Clothier") then
				d("Clothier Writ = "..i)
			end
			if string.find(Qname, "Enchanter" )then
				d("Enchanter Writ = "..i)
			end
		end
	end
end--]]

function WritCreater.OnAddOnLoaded(event, addonName)


	if addonName == WritCreater.name then
		WritCreater:Initialize()

	end
end



EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_ADD_ON_LOADED, WritCreater.OnAddOnLoaded)


-- to-do :	prompt - you need that weapon! and/or save it using function
--			don't take tripots
--			Account wide saved variables
--			FCO Item Saver and Item Saver compatability
--			Pausing for farming
--			Add in Levelling Mode
--			Add in statistics
--			Fishing competition or something
--			Auto refine if you run out
--			Autoloot the supply box rewards

--possible to-do:
--		'craft multiple option'
--		Queue craft system
--		Set crafting addon: Select what you want... and then one click, craft everything


--[[local index, recipes = 1, {}
      local lists = {1,2,3,8,9,10}
      for list_num=1,#lists do
        local _,num,_,_,_,_,sound = GetRecipeListInfo(lists[list_num])
        for id = num, 1, -1 do
          local _, name = GetRecipeInfo(lists[list_num],id)
          for _, step in pairs(QUEST[CRAFTING_TYPE_PROVISIONING].work) do 
            local res1, res2 = string.find(step, name)
            if res1 then
              recipes[index] = {list = lists[list_num], recipe = id, sound = sound}
              index = index + 1
            end
          end
        end


/script local a = 0 for i = 1, 200 do if string.find(GetItemName(BAG_BACKPACK, i), "urvey") then local _, b = GetItemInfo(BAG_BACKPACK,i) a = a+b end end d(a)









]]


        -- bug report: When no styles available, says writ complete, not missing styles.


--WTS |H1:item:114361:4:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h|H1:item:117737:4:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h|H1:item:117854:5:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h|H1:item:116391:4:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h|H1:item:115376:4:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h PST
