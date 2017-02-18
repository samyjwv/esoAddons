if WritCreater.lang ~= "none" then

WritCreater.styleNames = {}

for styleItemIndex = 1, GetNumSmithingStyleItems() do
	local  itemName = GetSmithingStyleItemInfo(styleItemIndex)
	if itemName ~= "" then
		table.insert(WritCreater.styleNames,{styleItemIndex,itemName})
	end
end



local function mypairs(tableIn)
	local t = {}
	for k,v in pairs(tableIn) do
		t[#t + 1] = {k,v}
	end
	table.sort(t, function(a,b) return a[1]<b[1] end)

	return t
end

local optionStrings = WritCreater.optionStrings
local function styleCompiler()

	local submenuTable = {}
	local styleNames = WritCreater.styleNames
	for k,v in ipairs(styleNames) do
		local option = {
			type = "checkbox",
			name = zo_strformat("<<1>>", v[2]),
			tooltip = optionStrings["style tooltip"](v[2]),
			getFunc = function() return WritCreater.savedVars.styles[v[1]] end,
			setFunc = function(value)
				WritCreater.savedVars.styles[v[1]] = value
				end,
		}
		submenuTable[#submenuTable + 1] = option
	end
	return submenuTable
end


function WritCreater.Options() --Sentimental
	local options =  {
			{
				type = "checkbox",
				name = optionStrings["show craft window"],
				tooltip =WritCreater.optionStrings["show craft window tooltip"],
				getFunc = function() return WritCreater.savedVars.showWindow end,
				setFunc = function(value) 
					WritCreater.savedVars.showWindow = value
					if value == false then
						WritCreater.savedVars.autoCraft = true
					end
				end,
			},
			{
				type = "checkbox",
				name = WritCreater.optionStrings["autocraft"]  ,
				tooltip = WritCreater.optionStrings["autocraft tooltip"] ,
				getFunc = function() return WritCreater.savedVars.autoCraft end,
				disabled = function() return not WritCreater.savedVars.showWindow end,
				setFunc = function(value) 
					WritCreater.savedVars.autoCraft = value 
				end,
			},
			{
				type = "checkbox",
				name = WritCreater.optionStrings["blackmithing"]   ,
				tooltip = WritCreater.optionStrings["blacksmithing tooltip"] ,
				getFunc = function() return WritCreater.savedVars[CRAFTING_TYPE_BLACKSMITHING] end,
				setFunc = function(value) 
					WritCreater.savedVars[CRAFTING_TYPE_BLACKSMITHING] = value 
				end,
			},
			{
				type = "checkbox",
				name = WritCreater.optionStrings["clothing"]  ,
				tooltip = WritCreater.optionStrings["clothing tooltip"] ,
				getFunc = function() return WritCreater.savedVars[CRAFTING_TYPE_CLOTHIER] end,
				setFunc = function(value) 
					WritCreater.savedVars[CRAFTING_TYPE_CLOTHIER] = value 
				end,
			},
			{
			  type = "checkbox",
			  name = WritCreater.optionStrings["woodworking"]    ,
			  tooltip = WritCreater.optionStrings["woodworking tooltip"],
			  getFunc = function() return WritCreater.savedVars[CRAFTING_TYPE_WOODWORKING] end,
			  setFunc = function(value) 
				WritCreater.savedVars[CRAFTING_TYPE_WOODWORKING] = value 
			  end,
			},
			{
				type = "checkbox",
				name = WritCreater.optionStrings["enchanting"],
				tooltip = WritCreater.optionStrings["enchanting tooltip"]  ,
				getFunc = function() return WritCreater.savedVars[CRAFTING_TYPE_ENCHANTING] end,
				setFunc = function(value) 
					WritCreater.savedVars[CRAFTING_TYPE_ENCHANTING] = value 
				end,
			},
			{
				type = "checkbox",
				name = WritCreater.optionStrings["provisioning"],
				tooltip = WritCreater.optionStrings["provisioning tooltip"]  ,
				getFunc = function() return WritCreater.savedVars[CRAFTING_TYPE_PROVISIONING] end,
				setFunc = function(value) 
					WritCreater.savedVars[CRAFTING_TYPE_PROVISIONING] = value 
				end,
			},
			{
				type = "checkbox",
				name = WritCreater.optionStrings["alchemy"],
				tooltip = WritCreater.optionStrings["alchemy tooltip"]  ,
				getFunc = function() return WritCreater.savedVars[CRAFTING_TYPE_ALCHEMY] end,
				setFunc = function(value) 
					WritCreater.savedVars[CRAFTING_TYPE_ALCHEMY] = value 
				end,
			},
			{
			type = "checkbox",
			name = WritCreater.optionStrings["ignore autoloot"] ,
			tooltip =WritCreater.optionStrings["ignore autoloot tooltip"]   ,
			getFunc = function() return WritCreater.savedVars.ignoreAuto end,
			setFunc = function(value) WritCreater.savedVars.ignoreAuto = value end,
			},
			{
			type = "checkbox",
			name = WritCreater.optionStrings["autoloot containters"] ,
			tooltip = WritCreater.optionStrings["autoLoot containters tooltip"],
			getFunc = function() return WritCreater.savedVars.autoLoot end,
			setFunc = function(value) WritCreater.savedVars.autoLoot = value end,
			disabled = function() return not WritCreater.savedVars.ignoreAuto end,
			},
			{
				type = "checkbox",
				name = "Master Writs",
				tooltip = "Craft Master Writ Items",
				getFunc = function() return WritCreater.savedVarsAccountWide.masterWrits end,
				setFunc = function(value) 
				WritCreater.savedVarsAccountWide.masterWrits = value
					if value  then
						
						for i = 1, 25 do WritCreater.MasterWritsQuestAdded(1, i,GetJournalQuestName(i)) end
					else
						WritCreater.LLCInteraction:cancelItem()
					end
					
					
				end,
			},

	}


  if WritCreater.lang =="en" then
  table.insert(options, {
	type = "checkbox",
	name = WritCreater.optionStrings["writ grabbing"] ,
	tooltip = WritCreater.optionStrings["writ grabbing tooltip"] ,
	getFunc = function() return WritCreater.savedVars.shouldGrab end,
	setFunc = function(value) WritCreater.savedVars.shouldGrab = value end,
  })
  table.insert(options,{
	type = "slider",
	name = WritCreater.optionStrings["delay"],
	tooltip = WritCreater.optionStrings["delay tooltip"]    ,
	min = 10,
	max = 2000,
	getFunc = function() return WritCreater.savedVars.delay end,
	setFunc = function(value)
	WritCreater.savedVars.delay = value
	end,
	disabled = function() return not WritCreater.savedVars.shouldGrab end,
  })
  end

	if false --[[GetWorldName() == "NA Megaserver" and WritCreater.lang =="en" ]] then
	  table.insert(options,8, {
	  type = "checkbox",
	  name = WritCreater.optionStrings["send data"],
	  tooltip =WritCreater.optionStrings["send data tooltip"] ,
	  getFunc = function() return WritCreater.savedVarsAccountWide.sendData end,
	  setFunc = function(value) WritCreater.savedVarsAccountWide.sendData = value  end,
	}) 
	end

	table.insert(options,{
	  type = "submenu",
	  name =WritCreater.optionStrings["style stone menu"],
	  tooltip = WritCreater.optionStrings["style stone menu tooltip"]  ,
	  controls = styleCompiler(),
	  reference = "WritCreaterStyleSubmenu",
	})
	table.insert(options,3 ,{
		type = "checkbox",
		name = WritCreater.optionStrings["exit when done"],
		tooltip = WritCreater.optionStrings["exit when done tooltip"],
		getFunc = function() return WritCreater.savedVars.exitWhenDone end,
		setFunc = function(value) WritCreater.savedVars.exitWhenDone = value end,
		})
	table.insert(options, 4, {
		type = "checkbox",
		name = WritCreater.optionStrings["automatic complete"],
		tooltip = WritCreater.optionStrings["automatic complete tooltip"],
		getFunc = function() return WritCreater.savedVars.autoAccept end,
		setFunc = function(value) WritCreater.savedVars.autoAccept = value end,
		})



	return options
end




else
	d("Language not supported")
end
