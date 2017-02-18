

--helper functions

local function hexConversion(IN)

	local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
	while IN>0 do
		I=I+1
		IN,D=math.floor(IN/B), IN%B+1
		OUT=string.sub(K,D,D)..OUT
	end
	return OUT
end

local timesToRun = 0

local queue = {}
local dqueue = {}

local queuePosition = 1



DolgubonTest = false

local function isItemWrit(condition, check2, bonusCondition, bag, location)

	return bonusCondition(location, bag) and ((not check2 and string.lower(string.gsub(GetItemName(bag, location),"-"," "))==condition) or (check2 and string.lower(string.gsub(GetItemName(bag, location),"-"," "))==condition))
end

emptySlots = {}

local function findEmptySlots(location)
	for i = FindFirstEmptySlotInBag(location) or 250, GetBagSize(location) do
		if GetItemName(location, i) == "" then
			emptySlots[#emptySlots + 1] = i
		end
	end
	return nil
end


local function potionGrab(condition,amount,check2,bonusCondition,max)

			--[[
		if DolgubonTest then
			local s = 1
			d("moved "..GetItemName(BAG_BANK, s))
			local emptySlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
			if IsProtectedFunction("RequestMoveItem") then
				CallSecureProtected("RequestMoveItem", BAG_BANK, s, BAG_BACKPACK,emptySlot,1)
			else
				RequestMoveItem(BAG_BANK, s, BAG_BACKPACK,emptySlot,1)
			end
			
			DolgubonTest = false
		end--]]
	for i=0, GetBagSize(BAG_BANK) do

		if isItemWrit(condition,  check2, bonusCondition, BAG_BANK, i)  then			
			
			local emptySlot = emptySlots[1]
			
			if emptySlot then
				table.remove(emptySlots,1)
				if IsProtectedFunction("RequestMoveItem") then
					CallSecureProtected("RequestMoveItem", BAG_BANK, i, BAG_BACKPACK,emptySlot,amount)
				else
					RequestMoveItem(BAG_BANK, i, BAG_BACKPACK,emptySlot,amount)
				end
				d("Dolgubon's Lazy Writ Crafter retrieved "..tostring(amount).." "..GetItemLink(BAG_BANK, i,0))
				return
			else
				d("You have no open bag spaces. Please empty your bag.")
			end

		end
	end
end

local function exceptions(condition)
	return condition
end


local alchGrab = function() end

local function queueRun()
	if queue[1] then
		queue[1]()
		table.remove(queue, 1)
		queuePosition = queuePosition+1
		queueRun()
		
	else
		queuePosition = 1
		queue = {}
		emptySlots = {}
	end

end

alchGrab = function (event) 
	findEmptySlots(BAG_BACKPACK)
	
	if WritCreater.savedVars.shouldGrab and WritCreater.lang =="en" then
		local nilFunc = function(i, b)return true end
		local writs = WritCreater.writSearch()
		local questIndex = writs[CRAFTING_TYPE_ALCHEMY]
		if questIndex then
			for j=1,4 do 
				local a=GetJournalQuestConditionInfo(questIndex, 1, j)
				local cur, max =GetJournalQuestConditionValues(questIndex,1,j)
				a=a:lower()
				if a:find("craft") and cur<max then
					a = exceptions(a)
					dqueue[#dqueue+1] = a
					a=WritCreater.parser(a)
					if a[4] =="ravage" then
						a = a[2].." of "..a[4].." "..a[5]
					else
						a =a[2].." of "..a[4]
					end
					queue[#queue+1] = function() potionGrab(a,1,false, function(i,BAG_BANK) local temp = {ZO_LinkHandler_ParseLink(GetItemLink(BAG_BANK,i))} if tonumber(temp[24]) then return tonumber(temp[24])>0 else return false end end) 
					--d(tonumber(select(24,ZO_LinkHandler_ParseLink(GetItemLink(BAG_BANK,i))))>0)
					
				end
				elseif a:find("acquire") and cur<max then
					a = exceptions(a)
					local place = string.find(a,":")
					a = string.sub(a,9,place-1)
					dqueue[#dqueue+1] = a
					queue[#queue+1] = function() potionGrab(a,max-cur,false,nilFunc,max) end
				end
			end
		end
		questIndex = writs[CRAFTING_TYPE_ENCHANTING]
		if questIndex then
			for j=1,4 do 
				local a=GetJournalQuestConditionInfo(questIndex, 1, j)
				local cur, max = GetJournalQuestConditionValues(questIndex,1,j)
				a=a:lower()
				if a:find("acquire") and cur<max then
					a = exceptions(a)
					a = WritCreater.parser(a)
					dqueue[#dqueue+1] = a[2]
					queue[#queue+1] = function() potionGrab(a[2],max-cur,true,nilFunc,max) end
				end
			end
		end
		questIndex = writs[CRAFTING_TYPE_PROVISIONING]
		if questIndex then

			for j=1,4 do 
				local a=GetJournalQuestConditionInfo(questIndex, 1, j)
				local cur, max =GetJournalQuestConditionValues(questIndex,1,j)
				a=a:lower()
				if a:find("craft") and cur<max then

					a = exceptions(a)

					a=string.gsub(a,"-"," ")

					a = string.gsub(a,"craft ", "")
					local place = string.find(a,":")

					a = string.sub(a,0,place-1)

					dqueue[#dqueue+1] = a

					queue[#queue+1] = function() potionGrab(a,max-cur,false,function(i, BAG_BANK) local temp = {ZO_LinkHandler_ParseLink(GetItemLink(BAG_BANK,i))} if tonumber(temp[5]) then  return tonumber(temp[5])>0 else return false end end ,max)
					end
				end
			end
		end
		if #queue>0 then

			--queueRun()
			zo_callLater(queueRun,WritCreater.savedVars.delay)
		end
	end

end



WritCreater.alchGrab = alchGrab

--SLASH_COMMANDS['/testpotion'] = returnPotionLevel

local function alchCall()
	timesToRun = 1
	queue = {}
	alchGrab()

	
end

function WritCreater.setupAlchGrabEvents()

	EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_QUEST_ADDED, function(event, journalIndex, name) 

	WritCreater.MasterWritsQuestAdded(event, journalIndex,name) end) 

	EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_OPEN_BANK, alchGrab)

	EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_CRAFTING_STATION_INTERACT, alchCall)

end