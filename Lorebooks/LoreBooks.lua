--[[
-------------------------------------------------------------------------------
-- LoreBooks, by Ayantir
-------------------------------------------------------------------------------
This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at : 
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
]]

--Libraries--------------------------------------------------------------------
local LAM = LibStub("LibAddonMenu-2.0")
local LMP = LibStub("LibMapPins-1.0")
local GPS = LibStub("LibGPS2")
local Postmail = {}

--Local constants -------------------------------------------------------------
local ADDON_NAME = "LoreBooks"
local ADDON_AUTHOR = "Ayantir & Garkin"
local ADDON_VERSION = "6.2"
local ADDON_WEBSITE = "http://www.esoui.com/downloads/info288-LoreBooks.html"
local PINS_UNKNOWN = "LBooksMapPin_unknown"
local PINS_COLLECTED = "LBooksMapPin_collected"
local PINS_EIDETIC = "LBooksMapPin_eidetic"
local PINS_EIDETIC_COLLECTED = "LBooksMapPin_eideticCollected"
local PINS_COMPASS = "LBooksCompassPin_unknown"
local PINS_COMPASS_EIDETIC = "LBooksCompassPin_eidetic"

local MISSING_TEXTURE = "/esoui/art/icons/icon_missing.dds"
local PLACEHOLDER_TEXTURE = "/esoui/art/icons/lore_book4_detail1_color2.dds"
local SUPPORTED_API = 100018
local MAX_BOOKS_IN_LIBRARY = 3174

--Local variables -------------------------------------------------------------
local lang = GetCVar("Language.2")
local updatePins = {}
local loreBoooksLibrary = {}
local totalCurrentlyCollected = 0
local updating = false
local mapIsShowing
local db							--user settings
local defaults = {			--default settings for saved variables
	compassMaxDistance = 0.04,
	pinTexture = {
		type = 1,
		size = 26,
		level = 40,
	},
	filters = {
		[PINS_COMPASS_EIDETIC] = false,
		[PINS_COMPASS] = true,
		[PINS_UNKNOWN] = true,
		[PINS_COLLECTED] = false,
		[PINS_EIDETIC] = false,
		[PINS_EIDETIC_COLLECTED] = false,
	},
	shareData = true,
	postmailData = "",
	postmailFirstInsert = GetTimeStamp(),
	booksFound = {},
	nbBooksFound = 0,
	booksCollected = {},
	unlockEidetic = false,
	steps = {},
}

local INFORMATION_TOOLTIP
local loreLibraryReportKeybind
local eideticModeAsked
local reportShown
local copyReport
local ESOVersion

local booksList = ZO_SortFilterList:Subclass()
local booksManager = {}
local helpLibrary
local LOREBOOKS_CUSTOMREPORT

local LOREBOOKS_HELP = ZO_HelpScreenTemplate_Keyboard:Subclass()
local THREESHOLD_EIDETIC = 2000
local THREESHOLD_EIDETIC_REPORT = 2500

--prints message to chat
local function MyPrint(...)
	CHAT_SYSTEM:AddMessage(...)
end

--checks if normalized point is valid
local function InvalidPoint(x, y)
	return (x < 0 or x > 1 or y < 0 or y > 1)
end

-- Pins -----------------------------------------------------------------------
local pinTexturesList = {
	[1] = "Shalidor's Library icons",
	[2] = "Book icon set 1",
	[3] = "Book icon set 2",
	[4] = "Esohead's icons (Rushmik)",
}

local pinTextures = {
	--[index] = { known_book_texture, unknown_book_texture },
	[1] = { "EsoUI/Art/Icons/lore_book4_detail4_color5.dds", "EsoUI/Art/Icons/lore_book4_detail4_color5.dds" },
	[2] = { "LoreBooks/Icons/book1.dds", "LoreBooks/Icons/book1-invert.dds" },
	[3] = { "LoreBooks/Icons/book2.dds", "LoreBooks/Icons/book2-invert.dds" },
	[4] = { "LoreBooks/Icons/book3.dds", "LoreBooks/Icons/book3-invert.dds" },
}

local function GetPinTexture(self)
	local _, texture, known = GetLoreBookInfo(1, self.m_PinTag[3], self.m_PinTag[4])
	local textureType = db.pinTexture.type
	if texture == MISSING_TEXTURE then texture = PLACEHOLDER_TEXTURE end
	return (pinTexturesList[textureType] == "Shalidor's Library icons") and texture or pinTextures[textureType][known and 1 or 2]
end

local function GetPinTextureEidetic(self)
	local _, texture, known = GetLoreBookInfo(3, self.m_PinTag.c, self.m_PinTag.b)
	local textureType = db.pinTexture.type
	if texture == MISSING_TEXTURE then texture = PLACEHOLDER_TEXTURE end
	return (pinTexturesList[textureType] == "Shalidor's Library icons") and texture or pinTextures[textureType][known and 1 or 2]
end

local function IsPinGrayscale()
	return pinTexturesList[db.pinTexture.type] == "Shalidor's Library icons"
end

--tooltip creator
local pinTooltipCreator = {}
pinTooltipCreator.tooltip = 1 --TOOLTIP_MODE.INFORMATION
pinTooltipCreator.creator = function(pin)
	
	local pinTag = pin.m_PinTag
	local title, icon, known = GetLoreBookInfo(1, pinTag[3], pinTag[4])
	local collection = GetLoreCollectionInfo(1, pinTag[3])
	local moreinfo = {}
	if icon == MISSING_TEXTURE then icon = PLACEHOLDER_TEXTURE end
	
	if pinTag[5] then
		if pinTag[5] < 5 then
			table.insert(moreinfo, "[" .. GetString("LBOOKS_MOREINFO", pinTag[5]) .. "]")
		else
			table.insert(moreinfo, "[" .. zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetZoneNameByIndex(GetZoneIndex(pinTag[5]))) .. "]")
		end
	end
	if known then
		table.insert(moreinfo, "[" .. GetString(LBOOKS_KNOWN) .. "]")
	end
	
	if IsInGamepadPreferredMode() then
		INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, zo_strformat(collection), INFORMATION_TOOLTIP.tooltip:GetStyle("mapTitle"))
		INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, icon, title, {fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3})
		if #moreinfo > 0 then
			INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, table.concat(moreinfo, " / "), INFORMATION_TOOLTIP.tooltip:GetStyle("worldMapTooltip"))
		end
	else
		INFORMATION_TOOLTIP:AddLine(zo_strformat(collection), "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
		ZO_Tooltip_AddDivider(INFORMATION_TOOLTIP)
		INFORMATION_TOOLTIP:AddLine(zo_iconTextFormat(icon, 32, 32, title), "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
		if #moreinfo > 0 then
			INFORMATION_TOOLTIP:AddLine(table.concat(moreinfo, " / "), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
		end
	end
	
end

--tooltip creator
local pinTooltipCreatorEidetic = {}
pinTooltipCreatorEidetic.tooltip = 1 --TOOLTIP_MODE.INFORMATION
pinTooltipCreatorEidetic.creator = function(pin)
	
	local pinTag = pin.m_PinTag
	local title, icon, known = GetLoreBookInfo(3, pinTag.c, pinTag.b)
	local collection = GetLoreCollectionInfo(3, pinTag.c)
	if icon == MISSING_TEXTURE then icon = PLACEHOLDER_TEXTURE end
	
	if IsInGamepadPreferredMode() then
		
		local bookColor = ZO_HIGHLIGHT_TEXT
		if known then
			bookColor = ZO_SUCCEEDED_TEXT
		end
		
		INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, zo_strformat(collection), INFORMATION_TOOLTIP.tooltip:GetStyle("mapTitle"))
		INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, bookColor:Colorize(title), {fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3})
		
		if pinTag.q then
			if type(pinTag.q) == "table" then
				INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, GetString(LBOOKS_QUEST_BOOK), {fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2})
				INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, pinTag.q[lang] or pinTag.q["en"], {fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2})
				
				local questDetails
				if pinTag.qt then
					questDetails = zo_strformat(GetString("LBOOKS_SPECIAL_QUEST"), pinTag.qt)
				else
					questDetails = zo_strformat(GetString(LBOOKS_QUEST_IN_ZONE), zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(pinTag.qm)))
				end
				
				INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, questDetails, {fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2})
			end
		end
		
		if pinTag.d then
		
			if GetZoneNameByIndex(GetZoneIndex(pinTag.z)) == GetMapNameByIndex(pinTag.m) then
				INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, zo_strformat("[<<1>>]", GetString(SI_QUESTTYPE5)), {fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2})
			else
				INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, string.format("[%s]", zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetZoneNameByIndex(GetZoneIndex(pinTag.z)))), {fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2})
			end
			
		end
		
		if pinTag.i and pinTag.i == INTERACTION_NONE then
			INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, GetString(LBOOKS_MAYBE_NOT_HERE), {fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2})
		elseif pinTag.r then
			INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, GetString(LBOOKS_RANDOM_POSITION), {fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2})
		end
		
	else
		
		INFORMATION_TOOLTIP:AddLine(zo_strformat(collection), "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
		ZO_Tooltip_AddDivider(INFORMATION_TOOLTIP)
		
		local bookColor = ZO_HIGHLIGHT_TEXT
		if known then
			bookColor = ZO_SUCCEEDED_TEXT
		end
		
		INFORMATION_TOOLTIP:AddLine(zo_iconTextFormat(icon, 32, 32, title), "", bookColor:UnpackRGB())
		
		if pinTag.q then
			if type(pinTag.q) == "table" then
				INFORMATION_TOOLTIP:AddLine(GetString(LBOOKS_QUEST_BOOK), "", ZO_SELECTED_TEXT:UnpackRGB())
				INFORMATION_TOOLTIP:AddLine(zo_strformat("[<<1>>]", pinTag.q[lang] or pinTag.q["en"]), "", ZO_SELECTED_TEXT:UnpackRGB())
				
				local questDetails
				if pinTag.qt then
					questDetails = zo_strformat(GetString("LBOOKS_SPECIAL_QUEST"), pinTag.qt)
				else
					questDetails = zo_strformat(GetString(LBOOKS_QUEST_IN_ZONE), zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(pinTag.qm)))
				end
				
				INFORMATION_TOOLTIP:AddLine(questDetails, "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
			end
		end
		
		if pinTag.d then
		
			if GetZoneNameByIndex(GetZoneIndex(pinTag.z)) == GetMapNameByIndex(pinTag.m) then
				INFORMATION_TOOLTIP:AddLine(zo_strformat("[<<1>>]", GetString(SI_QUESTTYPE5)), "", ZO_SELECTED_TEXT:UnpackRGB())
			else
				INFORMATION_TOOLTIP:AddLine(string.format("[%s]",  zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetZoneNameByIndex(GetZoneIndex(pinTag.z)))), "", ZO_SELECTED_TEXT:UnpackRGB())
			end
		end
		
		if pinTag.i and pinTag.i == INTERACTION_NONE then
			INFORMATION_TOOLTIP:AddLine(GetString(LBOOKS_MAYBE_NOT_HERE))
		elseif pinTag.r then
			INFORMATION_TOOLTIP:AddLine(GetString(LBOOKS_RANDOM_POSITION))
		end
		
	end
	
end

local function CreatePins()
	
	if (updatePins[PINS_COLLECTED] and LMP:IsEnabled(PINS_COLLECTED)) or (updatePins[PINS_UNKNOWN] and LMP:IsEnabled(PINS_UNKNOWN)) or (updatePins[PINS_COMPASS] and db.filters[PINS_COMPASS]) then
		local zoneIndex = GetCurrentMapZoneIndex()
		if zoneIndex < 514 or zoneIndex == 4294967296 then -- tempfix 514+ are v2 of instanced dungeons. There is no Books inside them. 4294967296 is the value returned when there is no zoneIndex
			local zone, subzone = LMP:GetZoneAndSubzone()
			local lorebooks = LoreBooks_GetLocalData(zone, subzone)
			if lorebooks then
				for _, pinData in ipairs(lorebooks) do	
					local _, _, known, bookId = GetLoreBookInfo(1, pinData[3], pinData[4])
					pinData.k = bookId -- for help
					if known and updatePins[PINS_COLLECTED] and LMP:IsEnabled(PINS_COLLECTED) then
						LMP:CreatePin(PINS_COLLECTED, pinData, pinData[1], pinData[2])
					elseif not known then
						if updatePins[PINS_UNKNOWN] and LMP:IsEnabled(PINS_UNKNOWN) then
							LMP:CreatePin(PINS_UNKNOWN, pinData, pinData[1], pinData[2])
						end
						if updatePins[PINS_COMPASS] and db.filters[PINS_COMPASS] then
							COMPASS_PINS.pinManager:CreatePin(PINS_COMPASS, pinData, pinData[1], pinData[2])
						end
					end
				end
			end
		end
	end
	
	if (updatePins[PINS_EIDETIC] and LMP:IsEnabled(PINS_EIDETIC)) or (updatePins[PINS_EIDETIC_COLLECTED] and LMP:IsEnabled(PINS_EIDETIC_COLLECTED)) or (updatePins[PINS_COMPASS_EIDETIC] and db.filters[PINS_COMPASS_EIDETIC]) then
		
		local mapIndex = GetCurrentMapIndex()
		local mapContentType = GetMapContentType()
		local usePrecalculatedCoords = true
		local zoneId = GetZoneId(GetCurrentMapZoneIndex())
		local eideticBooks
		
		if not mapIndex then
		
			usePrecalculatedCoords = false
			if zoneId == 643 then --IC Sewers
				mapIndex = 26
			elseif mapContentType ~= MAP_CONTENT_DUNGEON then
				local measurements = GPS:GetCurrentMapMeasurements()
				mapIndex = measurements.mapIndex
			end
			
		end
		
		if mapIndex then
			eideticBooks = LoreBooks_GetNewEideticDataForMap(mapIndex)
		elseif zoneId then
			eideticBooks = LoreBooks_GetNewEideticDataForZone(GetZoneId(GetCurrentMapZoneIndex()))
		end
		
		if eideticBooks then
			for _, pinData in ipairs(eideticBooks) do
				local _, _, known = GetLoreBookInfo(3, pinData.c, pinData.b)
				if (not known and LMP:IsEnabled(PINS_EIDETIC)) or (known and LMP:IsEnabled(PINS_EIDETIC_COLLECTED)) then
					
					if zoneId == 584 and (pinData.z == 643 or pinData.z == 678 or pinData.z == 688) then --IC Sewers/ICP/WGT
						-- Don't render
					elseif not pinData.qm or pinData.qm == pinData.m then
					
						if usePrecalculatedCoords and pinData.zx and pinData.zy then
							pinData.xLoc = pinData.zx
							pinData.yLoc = pinData.zy
						else
							pinData.xLoc, pinData.yLoc = GPS:GlobalToLocal(pinData.x, pinData.y)
						end
						
						local CoordsOK = pinData.xLoc and pinData.yLoc
						if CoordsOK then
							if pinData.xLoc > 0 and pinData.yLoc > 0 and pinData.xLoc < 1 and pinData.yLoc < 1 then
								if (mapContentType == MAP_CONTENT_DUNGEON and pinData.d) or mapContentType ~= MAP_CONTENT_DUNGEON then
									if not known and updatePins[PINS_EIDETIC] and LMP:IsEnabled(PINS_EIDETIC) then
										LMP:CreatePin(PINS_EIDETIC, pinData, pinData.xLoc, pinData.yLoc)
									elseif known and updatePins[PINS_EIDETIC_COLLECTED] and LMP:IsEnabled(PINS_EIDETIC_COLLECTED) then
										LMP:CreatePin(PINS_EIDETIC_COLLECTED, pinData, pinData.xLoc, pinData.yLoc)
									end
								end
							end
							if not known then
								if updatePins[PINS_COMPASS_EIDETIC] and db.filters[PINS_COMPASS_EIDETIC] and ((mapContentType == MAP_CONTENT_DUNGEON and pinData.d) or (mapContentType ~= MAP_CONTENT_DUNGEON and pinData.d == false)) then
									COMPASS_PINS.pinManager:CreatePin(PINS_COMPASS_EIDETIC, pinData, pinData.xLoc, pinData.yLoc)
								end
							end
						end
					end
				end
			end
			
		end
		
	end
	
	updatePins = {}
	updating = false
	
end

local function QueueCreatePins(pinType)
	updatePins[pinType] = true

	if not updating then
		updating = true
		if IsPlayerActivated() then
			if LMP.AUI.IsMinimapEnabled() then
				zo_callLater(CreatePins, 150) -- See SkyShards
			else
				CreatePins()
			end
		else
			EVENT_MANAGER:RegisterForEvent("LoreBooks_PinUpdate", EVENT_PLAYER_ACTIVATED,
				function(event)
					EVENT_MANAGER:UnregisterForEvent("LoreBooks_PinUpdate", event)
					CreatePins()
				end)
		end
	end
end

local function MapCallback_unknown()
	if not LMP:IsEnabled(PINS_UNKNOWN) or GetMapType() > MAPTYPE_ZONE then return end
	QueueCreatePins(PINS_UNKNOWN)
end

local function MapCallback_collected()
	if not LMP:IsEnabled(PINS_COLLECTED) or GetMapType() > MAPTYPE_ZONE then return end
	QueueCreatePins(PINS_COLLECTED)
end

local function MapCallback_eidetic()
	if not LMP:IsEnabled(PINS_EIDETIC) or GetMapType() > MAPTYPE_ZONE then return end
	QueueCreatePins(PINS_EIDETIC)
end

local function MapCallback_eideticCollected()
	if not LMP:IsEnabled(PINS_EIDETIC_COLLECTED) or GetMapType() > MAPTYPE_ZONE then return end
	QueueCreatePins(PINS_EIDETIC_COLLECTED)
end

local function CompassCallback()
	if not db.filters[PINS_COMPASS] or GetMapType() > MAPTYPE_ZONE then return end
	QueueCreatePins(PINS_COMPASS)
end

local function CompassCallbackEidetic()
	if not db.filters[PINS_COMPASS_EIDETIC] or GetMapType() > MAPTYPE_ZONE then return end
	QueueCreatePins(PINS_COMPASS_EIDETIC)
end

-- Slash commands -------------------------------------------------------------
local function ShowMyPosition()
	if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
	end

	local x, y = GetMapPlayerPosition("player")

	local locX = ("%05.02f"):format(zo_round(x*10000)/100)
	local locY = ("%05.02f"):format(zo_round(y*10000)/100)

	MyPrint(zo_strformat("<<1>>: <<2>>\195\151<<3>> (<<4>>)", GetMapName(), locX, locY, LMP:GetZoneAndSubzone(true)))
end

SLASH_COMMANDS["/mypos"] = ShowMyPosition
SLASH_COMMANDS["/myloc"] = ShowMyPosition

local function Base62(value)
	local r = false
	local state = type( value )
	if state == "number" then
		local k = math.floor( value )
		if k == value and value > 0 then
			local m
			r = ""
			while k > 0 do
				m = k % 62
				k = ( k - m ) / 62
				if m >= 36 then
					m = m + 61
				elseif m >= 10 then
					m = m + 55
				else
					m = m + 48
				end
				r = string.char( m ) .. r
			end
		elseif value == 0 then
			r = "0"
		end
	elseif state == "string" then
		if value:match( "^%w+$" ) then
			local n = #value
			local k = 1
			local c
			r = 0
			for i = n, 1, -1 do
				c = value:byte( i, i )
				if c >= 48 and c <= 57 then
					c = c - 48
				elseif c >= 65 and c <= 90 then
					c = c - 55
				elseif c >= 97 and c <= 122 then
					c = c - 61
				else  -- How comes?
					r = nil
					break  -- for i
				end
				r = r + c * k
				k = k * 62
			end -- for i
		end
	end
	return r
end

-- Dirty trick
local function UnsignedBase62(value)
	if not value or value == "" or value == 0 then
		return "" --compression optimization
	end
	local isNegative = value < 0
	local value62 = Base62(math.abs(value))
	if isNegative then return "-" .. value62 end
	return value62
end

local function ConfigureMail(data)

	if data then
		
		Postmail = data
		if (not (Postmail.subject and type(Postmail.subject) == "string" and string.len(Postmail.subject) > 0)) then
			return false
		end
		if (not (Postmail.recipient and type(Postmail.recipient) == "string" and string.len(Postmail.recipient) > 0)) then
			return false
		end
		if (not (Postmail.maxDelay and type(Postmail.maxDelay) == "number" and Postmail.maxDelay >= 0)) then
			return false
		end
		if (not (Postmail.mailMaxSize and type(Postmail.mailMaxSize) == "number" and Postmail.mailMaxSize >= 0 and Postmail.mailMaxSize <= 700)) then
			return false
		end
		
		Postmail.isConfigured = true
		return true
		
	end
	
	return false

end

local function EnableMail()
	if Postmail.isConfigured then
		Postmail.isActive = true
	end
end

local function DisableMail()
	if Postmail.isConfigured and Postmail.isActive then
		Postmail.isActive = false
	end
end

local function SendData(data)

	local function SendMailData(data)
		if Postmail.recipient ~= GetDisplayName() then -- Cannot send to myself
			RequestOpenMailbox()
			SendMail(Postmail.recipient, Postmail.subject, data)
			CloseMailbox()
		else -- Directly add to COLLAB
			--COLLAB[GetDisplayName() .. GetTimeStamp()] = {body = data, sender = Postmail.recipient, received = GetDate()}
		end
	end
	
	local pendingData = db.postmailData
	if Postmail.recipient == GetDisplayName() then
		SendMailData(data)
	elseif Postmail.isActive then
		local dataLen = string.len(data)
		local now = GetTimeStamp()
		if pendingData ~= "" then
			if not string.find(pendingData, data) then
				local dataMergedLen = string.len(pendingData) + dataLen + 1 -- 1 is \n
				if now - db.postmailFirstInsert > Postmail.maxDelay then -- A send must be done
					if dataMergedLen > Postmail.mailMaxSize then
						SendMailData(pendingData) -- too big, send pendingData and save the modulo
						db.postmailData = data
						db.postmailFirstInsert = now
					else
						SendMailData(pendingData .. "\n" .. data) -- Send all data
						db.postmailData = ""
						db.postmailFirstInsert = now
					end
				else
					-- Send only if data is too big
					if dataMergedLen > Postmail.mailMaxSize then
						SendMailData(pendingData) -- too big, send pendingData and save the modulo
						db.postmailData = data
						db.postmailFirstInsert = now
					else
						db.postmailData = db.postmailData .. "\n" .. data
					end
				end
			end
		elseif dataLen < Postmail.mailMaxSize then
			db.postmailData = data
			db.postmailFirstInsert = now
		end
	end

end

--Now only build the Help Lirary and totalCurrentlyCollected. todo: delete. totalCurrentlyCollected should be kept.
local function BuildLorebooksLoreLibrary()

	helpLibrary = {}
	
	for categoryIndex = 1, GetNumLoreCategories() do
		
		helpLibrary[categoryIndex] = {}
		local categoryName, numCollections = GetLoreCategoryInfo(categoryIndex)
		
		for collectionIndex = 1, numCollections do
			
			local _, _, _, totalBooks, hidden = GetLoreCollectionInfo(categoryIndex, collectionIndex)
			
			if not hidden then
				
				helpLibrary[categoryIndex][collectionIndex] = {}
				
				for bookIndex = 1, totalBooks do
					
					local bookName, _, known, bookId = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
					
					helpLibrary[categoryIndex][collectionIndex][bookIndex] = bookName
					
					if known then
						totalCurrentlyCollected = totalCurrentlyCollected + 1
					end
					
				end
			end
		end
	end
	
end

-- Returns false if Book should not be datamined.
local function EideticValidEntry(categoryIndex, bookName)
	
	-- Collections where Eidetic Memory mining is disabled
	if not categoryIndex then
		return false -- books not in eidetic
	elseif categoryIndex == 2 then
		return false -- Crafting books
	elseif bookName then
		-- Eidetic not unlocked
		if string.find(bookName, "Motifs artisanaux ")
		or string.find(bookName, "Handwerksstile ")
		or string.find(bookName, "Crafting Motif ")
		or string.find(bookName, "Crafting Motifs ")
		then
			return false -- Crafting books with Eidetic not unlocked.
		end
	end
	
	return true
	
end

local function CoordsNearby(locX, locY, x, y)

	local nearbyIs = 0.0005 --It should be 0.00028, but we add a large diff just in case of. 0.0004 is not enough.
	if math.abs(locX - x) < nearbyIs and math.abs(locY - y) < nearbyIs then
		return true
	end
	return false
	
end

local function ShowThankYou(categoryIndex, collectionIndex, bookIndex)

	local icons = {
		[1] = "/esoui/art/icons/scroll_001.dds",
		[10] = "/esoui/art/icons/lore_book2_detail1_color1.dds",
		[20] = "/esoui/art/icons/quest_book_001.dds",
		[30] = "/esoui/art/icons/scroll_005.dds",
	}

	if not db.booksFound[categoryIndex] then db.booksFound[categoryIndex] = {} end
	if not db.booksFound[categoryIndex][collectionIndex] then db.booksFound[categoryIndex][collectionIndex] = {} end
	if not db.booksFound[categoryIndex][collectionIndex][bookIndex] then
		db.booksFound[categoryIndex][collectionIndex][bookIndex] = true
		db.nbBooksFound = db.nbBooksFound + 1
		if db.nbBooksFound == 1 or db.nbBooksFound == 10 or db.nbBooksFound == 20 or db.nbBooksFound == 30 then
			CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_EVENT_COMBINED_TEXT, SOUNDS.LEVEL_UP, GetString("LBOOKS_THANK_YOU", db.nbBooksFound), GetString("LBOOKS_THANK_YOU_LONG", db.nbBooksFound), icons[db.nbBooksFound], "EsoUI/Art/Achievements/achievements_iconBG.dds")
		end
	end

end

function BuildDataToShare(bookId)
	
	if bookId then
		
		local dataToShare
		
		if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
		end
		
		if GetCurrentZoneHouseId() ~= 0 then
			return -- You can now read books in houses
		end
		
		-- Will only returns the zone and not the subzone
		local zoneIndex = GetCurrentMapZoneIndex()
		local zoneId = GetZoneId(zoneIndex)
		
		-- mapType of the subzone. Needed when we are elsewhere than zone or subzone.
		local mapContentType = GetMapContentType()
		
		local xGPS, yGPS, zoneGPS = GPS:LocalToGlobal(GetMapPlayerPosition("player"))
		
		if not zoneGPS then
			zoneGPS = 0
		end
		
		local locX = zo_round(xGPS*100000) -- 5 decimals because of Cyrodiil map
		local locY = zo_round(yGPS*100000)
		
		-- v1		= 2.4.0	LOC_DATA_UPDATE	= locX, locY, zoneIndex, mapType, lastInteractionActionWas
		-- v2		= 2.4.2	LOC_DATA_UPDATE	= locX, locY, zoneIndex, mapContentType, mapIndex, lastInteractionActionWas
		-- v3		= 2.4.4	LOC_DATA_UPDATE	= locX, locY, zoneIndex, mapContentType, mapIndex, lastInteractionActionWas, langCode
		-- v4		= 2.4.5	LOC_DATA_UPDATE	= locX, locY, zoneIndex, mapContentType, mapIndex, lastInteractionActionWas, langCode, apiVersion
		-- v5		= 2.5		LOC_DATA_UPDATE	= locX, locY, zoneIndex, mapContentType, mapIndex, lastInteractionActionWas, langCode, apiVersion, currentZoneDungeonDifficulty
		-- v6		= 2.5.1	LOC_DATA_UPDATE	= locX, locY, zoneIndex, mapContentType, mapIndex, lastInteractionActionWas, langCode, apiVersion, currentZoneDungeonDifficulty, reticleAway, associatedQuest
		-- v7		= 4		BOOK_DATA_UPDATE	= categoryIndex, collectionIndex, bookIndex, mediumIndex
		-- v8		= 5		LOC_DATA_UPDATE	= locX, locY, zoneId, mapContentType, mapIndex, lastInteractionActionWas, langCode, ESOVersion, interactionType, associatedQuest
		-- v9		= 5.1		LOC_DATA_UPDATE	= locX, locY, zoneId, mapContentType, mapIndex, lastInteractionActionWas, langCode, LorebooksVersion, ESOVersion, interactionType, associatedQuest
		-- v10	= 5.3		DAT_UPDATE			= Added collection 52.
		-- v11	= 5.4		BOOK_DATA_UPDATE	= categoryIndex, collectionIndex, bookIndex, mediumIndex, bookId
		-- v12	= 5.4		BOOK_DATA_UPDATE	= locX, locY, zoneId, mapContentType, mapIndex, isObject, langCode, LorebooksVersion, ESOVersion, interactionType, associatedQuest
		-- v13	= 6		BOOK_DATA_UPDATE	= bookId
		dataToShare = UnsignedBase62(locX) .. ";" .. UnsignedBase62(locY) .. ";" .. UnsignedBase62(zoneId) .. ";" .. UnsignedBase62(mapContentType) .. ";" .. UnsignedBase62(zoneGPS)
		
		local isObject = IsPlayerInteractingWithObject()
		if isObject then
			dataToShare = dataToShare ..";" -- means 0
		else
			dataToShare = dataToShare ..";1"
		end
		
		local clang
		if lang == "en" then clang = 1 end
		if lang == "fr" then clang = 2 end
		if lang == "de" then clang = 3 end
		
		local MINER_VERSION = 13
		dataToShare = dataToShare ..";" .. clang .. ";" .. UnsignedBase62(MINER_VERSION) ..";" .. UnsignedBase62(tonumber(ESOVersion))
		
		local categoryIndex, collectionIndex, bookIndex = GetLoreBookIndicesFromBookId(bookId)
		
		local bookName = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
		
		local associatedQuest = ""
		local interactionType = GetInteractionType() -- If user runs an addon which break interaction, the result will return INTERACTION_NONE even if he was reading a book.
		if interactionType == INTERACTION_NONE then --book read from inventory or case above.
			for questIndex, questData in pairs(SHARED_INVENTORY.questCache) do
				for itemIndex, itemData in pairs(questData) do
					if string.lower(itemData.name) == string.lower(bookName) then
						associatedQuest = GetJournalQuestInfo(questIndex)
						break
					end
				end
			end
		end
		
		dataToShare = dataToShare .. ";" .. UnsignedBase62(interactionType) .. ";" .. associatedQuest
		
		if EideticValidEntry(categoryIndex, bookName) then
			
			local bookData = LoreBooks_GetNewEideticData(categoryIndex, collectionIndex, bookIndex)
			
			if bookData and bookData.c and bookData.e then
				if not isObject and (not bookData.r or (bookData.r and bookData.m[zoneGPS])) then
					return -- Found a random book and this book is already tagged as random for the same map or got a static position
				else
					for _, data in ipairs(bookData.e) do
						if data.r == false then
							if interactionType == INTERACTION_NONE then
								return -- User read book from inventory but we already found pin from a static position
							elseif data.z == zoneId and CoordsNearby(xGPS, yGPS, data.x, data.y) then
								return -- Pin already found
							end
						end
					end
				end
			end
			
			dataToShare = dataToShare .. "@" .. bookId
			
			--[[
			if not bookData and categoryIndex == 3 then
				ShowThankYou(categoryIndex, collectionIndex, bookIndex)
			end
			]]
			
		else
			return -- We don't collect anymore books from users which didn't yet unlocked Eidetic Memory
		end
		
		return dataToShare
		
	end
		
end
		
local function OnShowBook(_, _, _, _, _, bookId)
	local dataToShare = BuildDataToShare(bookId)
	if dataToShare then
		SendData(dataToShare)
	end
end

local function ToggleShareData()
	
	local PostmailData = {
		subject = "CM_DATA", -- Subject of the mail
		recipient = "@calia.1120", -- Recipient of the mail. The recipient *IS GREATLY ENCOURAGED* to run the CollabMiner
		maxDelay = 345600, -- ~4d
		mailMaxSize = MAIL_MAX_BODY_CHARACTERS - 25, -- Mail limitation is 700 Avoid > 675. (some books with additional data can have 14 additional chars, so we'll still have 16 in case of).
	}
	
	if GetAPIVersion() == SUPPORTED_API and GetWorldName() == "EU Megaserver" and (lang == "fr" or lang == "en" or lang == "de") then
		if db.shareData then
			ESOVersion = GetESOVersionString():gsub("eso%.live%.(%d)%.(%d)%.(%d+)%.%d+", "%1%2%3")
			if ESOVersion == "277" then
				EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_SHOW_BOOK, OnShowBook)
				local postmailIsConfigured = ConfigureMail(PostmailData)
				if postmailIsConfigured then
					EnableMail()
				end
			end
		else
			EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_SHOW_BOOK)
			DisableMail()
		end
	end
	
end

local function ShowCongrats(newBook)
	
	local congrats = {
		[2000] = "/esoui/art/icons/quest_book_003.dds",
		[2500] = "/esoui/art/icons/scroll_001.dds",
		[2600] = "/esoui/art/icons/scroll_005.dds",
		[2700] = "/esoui/art/icons/quest_book_001.dds",
		[2800] = "/esoui/art/icons/lore_book2_detail1_color1.dds",
		[2900] = "/esoui/art/icons/achievement_thievesguild_024.dds",
		[3000] = "/esoui/art/icons/achievement_wrothgar_027.dds",
		[3100] = "/esoui/art/icons/achievement_newlifefestival_011.dds",
		[MAX_BOOKS_IN_LIBRARY] = "/esoui/art/icons/ability_mage_064.dds", -- Max Homestead
	}
	
	local function CongratsStuff(collected)
		if not db.booksCollected[collected] then
			db.booksCollected[collected] = true
			CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_EVENT_COMBINED_TEXT, SOUNDS.LEVEL_UP, GetString("LBOOKS_THANK_YOU", collected), GetString("LBOOKS_THANK_YOU_LONG", collected), congrats[collected], "EsoUI/Art/Achievements/achievements_iconBG.dds")
		end
	end
	
	if newBook then
		
		if congrats[totalCurrentlyCollected] then
			if (totalCurrentlyCollected == MAX_BOOKS_IN_LIBRARY and GetAPIVersion() == SUPPORTED_API) then
				CongratsStuff(totalCurrentlyCollected)
			elseif totalCurrentlyCollected ~= MAX_BOOKS_IN_LIBRARY then
				CongratsStuff(totalCurrentlyCollected)
			end
		end
		
	else
	
		-- If first activation
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
		
		-- It won't show all achiev in a row, I prefer like this.
		if totalCurrentlyCollected == MAX_BOOKS_IN_LIBRARY and GetAPIVersion() == SUPPORTED_API then
			CongratsStuff(MAX_BOOKS_IN_LIBRARY)
		elseif totalCurrentlyCollected >= 3100 then
			CongratsStuff(3100)
		elseif totalCurrentlyCollected >= 3000 then
			CongratsStuff(3000)
		elseif totalCurrentlyCollected >= 2900 then
			CongratsStuff(2900)
		elseif totalCurrentlyCollected >= 2800 then
			CongratsStuff(2800)
		elseif totalCurrentlyCollected >= 2700 then
			CongratsStuff(2700)
		elseif totalCurrentlyCollected >= 2600 then
			CongratsStuff(2600)
		elseif totalCurrentlyCollected >= 2500 then
			CongratsStuff(2500)
		elseif totalCurrentlyCollected >= 2000 then
			CongratsStuff(2000)
		end
		
	end
	
end

local function OnGamepadPreferredModeChanged()
	if IsInGamepadPreferredMode() then
		INFORMATION_TOOLTIP = ZO_MapLocationTooltip_Gamepad
	else
		INFORMATION_TOOLTIP = InformationTooltip
	end
end

local function OnSearchTextChanged(self)
	
	ZO_EditDefaultText_OnTextChanged(self)
	local search = self:GetText()
	LORE_LIBRARY.search = search
	
	if string.len(search) > 2 or string.len(search) == 0 then
		LORE_LIBRARY.navigationTree:ClearSelectedNode()
		LORE_LIBRARY:BuildCategoryList()
	end
	
end

local function NameSorter(left, right)
	return left.name < right.name
end

local function IsFoundInLoreLibrary(search, data)

	if string.find(string.lower(data.name), search) then
		return true
	else
		
		for bookIndex = 1, data.totalBooks do
			local title = GetLoreBookInfo(data.categoryIndex, data.collectionIndex, bookIndex)
			if string.find(string.lower(title), search) then
				return true
			end
		end
		
	end
	
	return false

end

function booksList:New(control)
	
	ZO_SortFilterList.InitializeSortFilterList(self, control)
	
	local SorterKeys =
	{
		bookName = {},
		categoryIndex = {tiebreaker = "bookName", isNumeric = true},
		collectionIndex = {tiebreaker = "bookName", isNumeric = true},
		bookIndex = {tiebreaker = "bookName", isNumeric = true},
	}
	
 	self.masterList = {}
	
 	ZO_ScrollList_AddDataType(self.list, 1, "Lorebook_HelpBook_Template", 32, function(control, data) self:SetupEntry(control, data) end)
 	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	
	self.currentSortKey = "bookName"
	self.currentSortOrder = ZO_SORT_ORDER_UP
 	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, SorterKeys, self.currentSortOrder) end
	
	return self
	
end

function booksList:SetupEntry(control, data)
	
	control.data = data
	
	control.bookName = GetControl(control, "Name")
	control.icon = GetControl(control, "Icon")
	control.collection = GetControl(control, "Collection")
	control.coords = GetControl(control, "Coords")
	
	local collectionName = GetLoreCollectionInfo(data.categoryIndex, data.collectionIndex)
	local bookName, icon, known = GetLoreBookInfo(data.categoryIndex, data.collectionIndex, data.bookIndex)
	
	control.bookName:SetText(bookName)
	
	control.icon:SetTexture(icon)
	control.collection:SetText(collectionName)
	control.coords:SetText(zo_strformat("<<1>>/<<2>>/<<3>>", data.categoryIndex, data.collectionIndex, data.bookIndex))

	ZO_SortFilterList.SetupRow(self, control, data)
	
end

function booksList:BuildMasterList()
	
	local function Sanitize(value)
		return value:gsub("[-*+?^$().[%]%%]", "%%%0") -- escape meta characters
	end
	
	self.masterList = {}
	
	local search = string.lower(LOREBOOKS_HELP.search)
	
	if search ~= "" then
		for categoryIndex, categoryData in ipairs(helpLibrary) do
			for collectionIndex, collectionData in pairs(categoryData) do
				for bookIndex, bookName in ipairs(collectionData) do
					if string.find(string.lower(bookName), Sanitize(search)) then
						table.insert(self.masterList, {categoryIndex = categoryIndex, collectionIndex = collectionIndex, bookIndex = bookIndex})
					end
				end
			end
		end
	end
	
end

function booksList:SortScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	table.sort(scrollData, self.sortFunction)
end

function booksList:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

	for i = 1, #self.masterList do
		local data = self.masterList[i]
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
	end
end

function LoreBooks_RefreshShaliOptions(self, checked)
	
	local isChecked = ZO_CheckButton_IsChecked(self)
	local button = GetControl(LOREBOOKS_HELP.shaliOptions, "SendData")
	
	if isChecked then
		button:SetState(BSTATE_NORMAL)
	else
		button:SetState(BSTATE_DISABLED)
	end

end

function Lorebook_HoverRowOfHelpBook(control)
	booksList:Row_OnMouseEnter(control)
end

function Lorebook_ExitRowOfHelpBook(control)
	booksList:Row_OnMouseExit(control)
end

function Lorebook_ClickHelpBook(control, button)
	if button == MOUSE_BUTTON_INDEX_LEFT then
		--if control.data.categoryIndex == 3 then
			
		--end
	end
end

function LOREBOOKS_HELP:New(...)
	return ZO_HelpScreenTemplate_Keyboard.New(self, ...)
end

local function OnHelpSearchTextChanged(self)
	
	ZO_EditDefaultText_OnTextChanged(self)
	local search = self:GetText()
	LOREBOOKS_HELP.search = search
	
	if string.len(search) >= 5 or string.len(search) == 0 then
		if string.len(search) == 0 then
			LOREBOOKS_HELP.reference:SetHidden(true)
			LOREBOOKS_HELP.shaliOptions:SetHidden(true)
		end
		booksManager:RefreshData()
	end
	
end

function LOREBOOKS_HELP:Initialize(control)
	
	LOREBOOKS_HELP.control = control
	LOREBOOKS_CUSTOMREPORT = ZO_FadeSceneFragment:New(control)
	
	local iconData =
	{
		name = ADDON_NAME,
		categoryFragment = LOREBOOKS_CUSTOMREPORT,
		up = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_up.dds",
		down = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_down.dds",
		over = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_over.dds",
	}
	
	LOREBOOKS_HELP.control:GetNamedChild("Report"):SetText(zo_strformat(GetString(LBOOKS_EIDETIC_REPORT), ADDON_VERSION))
	
	LOREBOOKS_HELP.search = ""
	LOREBOOKS_HELP.reference = control:GetNamedChild("Reference")
	
	LOREBOOKS_HELP.book = control:GetNamedChild("BookBox")
	LOREBOOKS_HELP.book:SetHandler("OnTextChanged", OnHelpSearchTextChanged)
	
	LOREBOOKS_HELP.shaliOptions = control:GetNamedChild("ShaliOptions")
	
	booksManager = booksList:New(control)
	booksManager:RefreshData()
	
	ZO_HelpScreenTemplate_Keyboard.Initialize(self, control, iconData)
	
end

local function InitializeLoreBooksHelp()
	LOREBOOKS_HELP:New(LoreBooksHelp)
end

function LoreBooks_SendReport(mode)

	local FixData = {
		subject = "CM_FIX", -- Subject of the mail
		recipient = "@Ayantir", -- Recipient of the mail. The recipient *IS GREATLY ENCOURAGED* to run the CollabMiner
	}

	local function SendFixData(data)
		if FixData.recipient ~= GetDisplayName() then -- Cannot send to myself
			RequestOpenMailbox()
			SendMail(FixData.recipient, FixData.subject, data)
			CloseMailbox()
		else -- Directly add to COLLAB
			--COLLAB_FIX[GetDisplayName() .. GetTimeStamp()] = {body = data, sender = Postmail.recipient, received = GetDate()}
		end
	end
	
	local data
	if mode == 1 then
		data = string.format("%s;%s;%s;nh=%s", ADDON_VERSION, mode, LOREBOOKS_HELP.reference:GetText(), LOREBOOKS_HELP.shaliOptions:GetNamedChild("NotHereAnymore"):GetState())
	end
	
	if GetAPIVersion() == SUPPORTED_API then
		SendFixData(data)
	end
	
	SCENE_MANAGER:ShowBaseScene()
	CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_EVENT_COMBINED_TEXT, SOUNDS.QUEST_OBJECTIVE_COMPLETE, GetString(LBOOKS_REPORT_THANK_YOU), GetString(LBOOKS_REPORT_THANK_YOU_SEC))
	
end

local function ShowReportForShalidor(collectionIndex, bookIndex, x, y, zone, subzone, mapIndex)
	
	local function IsShaliBookRecentlyFound(collectionIndex, bookIndex, x, y, mapIndex)
		
		if mapIndex then
			local bookData = LoreBooks_GetNewEideticData(1, collectionIndex, bookIndex)
			local gX, gY = GPS:ZoneToGlobal(mapIndex, x, y)
			if bookData and bookData.e then
				for entryIndex, entryData in ipairs(bookData.e) do
					if CoordsNearby(gX, gY, entryData.x, entryData.y) then
						return true
					end
				end
			end
		end
		
		return false
		
	end
	
	local reference = string.format("{ %.4f, %.4f, %d, %d } --%s, %s", x, y, collectionIndex, bookIndex, zone, subzone)
	
	LOREBOOKS_HELP.reference:SetText(reference)
	
	if GetAPIVersion() == SUPPORTED_API then
		
		LOREBOOKS_HELP.reference:SetHidden(false)
		LOREBOOKS_HELP.shaliOptions:SetHidden(false)
		
		local bookRecentlyFound = IsShaliBookRecentlyFound(collectionIndex, bookIndex, x, y, mapIndex)
		
		local checkbox = GetControl(LOREBOOKS_HELP.shaliOptions, "NotHereAnymore")
		local explain = GetControl(LOREBOOKS_HELP.shaliOptions, "NotHereAnymoreLongExplain")
		local button = GetControl(LOREBOOKS_HELP.shaliOptions, "SendData")
		
		if bookRecentlyFound then
			checkbox:SetState(BSTATE_DISABLED)
			explain:SetText(GetString(LBOOKS_RS_NOT_HERE_ANYMORE_ERR))
			button:SetState(BSTATE_DISABLED)
		else
			checkbox:SetState(BSTATE_NORMAL)
			explain:SetText(GetString(LBOOKS_RS_NOT_HERE_ANYMORE_DESC))
		end
		
		button:SetState(BSTATE_DISABLED)
		
	end
	
end

local function ReportBook(bookId, x, y, zone, subzone, mapIndex)

	HELP_CUSTOMER_SUPPORT_KEYBOARD:OpenScreen(LOREBOOKS_CUSTOMREPORT)
	local categoryIndex, collectionIndex, bookIndex = GetLoreBookIndicesFromBookId(bookId)
	
	if categoryIndex then
	
		local bookName = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
		
		LOREBOOKS_HELP.book:SetText(bookName) -- Trigger OnHelpSearchTextChanged
		
		if categoryIndex == 1 then
			ShowReportForShalidor(collectionIndex, bookIndex, x, y, zone, subzone, mapIndex)
		end
		
	end

end

local function ShowLoreLibraryReport(forceHide)
	
	LoreBooksCopyReport:SetHidden(true)
	if forceHide then
		reportShown = false
		LoreBooksReport:SetHidden(forceHide)
	else
		if ZO_LoreLibrary:IsHidden() then
			LoreBooksReport:SetHidden(true)
			ZO_LoreLibrary:SetHidden(false)
			reportShown = false
		else
			LoreBooksReport:SetHidden(false)
			ZO_LoreLibrary:SetHidden(true)
			reportShown = true
		end
	end
	
	KEYBIND_STRIP:UpdateKeybindButtonGroup(loreLibraryReportKeybind)
	
end

local function ShowLoreLibraryCopyReport()
	
	LoreBooksReport:SetHidden(true)
	
	LoreBooksCopyReport:GetNamedChild("Content"):GetNamedChild("Edit"):SelectAll()
	LoreBooksCopyReport:GetNamedChild("Content"):GetNamedChild("Edit"):TakeFocus()
	LoreBooksCopyReport:GetNamedChild("Content"):GetNamedChild("Edit"):SetTopLineIndex(1)
	
	LoreBooksCopyReport:SetHidden(false)
	
end

local function IsReportShown()
	return reportShown
end

local function BuildShalidorReport()

	local function DisplayCollectionsReport(collectionsData)
		
		local yCollectionIndex = 48
		
		table.sort(collectionsData, function(a,b)
			return a.totalBooks - a.numKnownBooks < b.totalBooks - b.numKnownBooks
		end)
		
		local lastObject = 0
		for collectionIndex, data in pairs(collectionsData) do
			
			local shalidorCollectionName = GetControl(LoreBooksReportContainerScrollChild, "CollectionName" .. collectionIndex)
			local shalidorCollectionValue = GetControl(LoreBooksReportContainerScrollChild, "CollectionValue" .. collectionIndex)
			
			if data.numKnownBooks ~= data.totalBooks then
				
				local shalidorCollectionName = GetControl(LoreBooksReportContainerScrollChild, "CollectionName" .. collectionIndex)
				local shalidorCollectionValue = GetControl(LoreBooksReportContainerScrollChild, "CollectionValue" .. collectionIndex)
				
				if not shalidorCollectionName then
					shalidorCollectionName = CreateControlFromVirtual("$(parent)CollectionName", LoreBooksReportContainerScrollChild, "Lorebook_ShaliCollectionName_Template", collectionIndex)
					shalidorCollectionValue = CreateControlFromVirtual("$(parent)CollectionValue", LoreBooksReportContainerScrollChild, "Lorebook_ShaliCollectionValue_Template", collectionIndex)
				end
				
				shalidorCollectionValue:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 20, yCollectionIndex)
				shalidorCollectionName:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 70, yCollectionIndex)
				
				yCollectionIndex = yCollectionIndex + 32
				
				shalidorCollectionName:SetText(data.name)
				shalidorCollectionValue:SetText(zo_strformat("<<1>>/<<2>>", data.numKnownBooks, data.totalBooks))
				
				copyReport = copyReport .. "\n\n" .. data.name  .. " :\n" ..  zo_strformat("<<1>>/<<2>>", data.numKnownBooks, data.totalBooks)
				lastObject = yCollectionIndex
			elseif shalidorCollectionName then -- Dirty trick
				shalidorCollectionName:SetHidden(true)
				shalidorCollectionValue:SetHidden(true)
			end
			
		end
		
		return lastObject + 10
		
	end

	local POINTS_FOR_RANK_MAX = 1380
	
	local totalKnown = 0
	local points = 0
	local booksInShalidor = 0
	
	collectionsData = {}
	local _, numCollections = GetLoreCategoryInfo(1)
	for collectionIndex = 1, numCollections do
		local name, _, numKnownBooks, totalBooks, hidden = GetLoreCollectionInfo(1, collectionIndex)
		if not hidden then
			totalKnown = totalKnown + numKnownBooks
			booksInShalidor = booksInShalidor + totalBooks
			points = points + numKnownBooks * 5
			collectionsData[collectionIndex] = {name = name, numKnownBooks = numKnownBooks, totalBooks = totalBooks}
			if numKnownBooks == totalBooks then
				points = points + 20
			end
		end
	end
	
	local shalidorHeaderText = GetControl(LoreBooksReport, "ShalidorHeaderText")
	local lastObject = 52
	
	if points < POINTS_FOR_RANK_MAX then
		copyReport = GetString(LBOOKS_RS_FEW_BOOKS_MISSING)
		shalidorHeaderText:SetText(copyReport)
		lastObject = DisplayCollectionsReport(collectionsData)
	elseif totalKnown < booksInShalidor then
		copyReport = GetString(LBOOKS_RS_MDONE_BOOKS_MISSING)
		shalidorHeaderText:SetText(copyReport)
		lastObject = DisplayCollectionsReport(collectionsData)
	else
		copyReport = GetString(LBOOKS_RS_GOT_ALL_BOOKS)
		shalidorHeaderText:SetText(copyReport)
	end
	
	return lastObject

end

local function BuildEideticReportPerMap(lastObject)

	local eideticHeaderText = GetControl(LoreBooksReport, "EideticHeaderText")
	eideticHeaderText:ClearAnchors()
	
	eideticHeaderText:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 4, lastObject)
	
	if totalCurrentlyCollected >= THREESHOLD_EIDETIC then
		
		eideticHeaderText:SetText(GetString(LBOOKS_RE_FEW_BOOKS_MISSING))
		copyReport = copyReport .. "\n\n" .. GetString(LBOOKS_RE_FEW_BOOKS_MISSING)
		
		local eideticData = {}
		local eideticSeen = {}
		local yCollectionIndex = lastObject + 48
		
		for mapIndex = 1, GetNumMaps() do
			
			eideticData[mapIndex] = {}
			eideticBooks = LoreBooks_GetNewEideticDataForMap(mapIndex)
			
			if eideticBooks then
			
				for _, bookData in ipairs(eideticBooks) do
					local _, _, known = GetLoreBookInfo(3, bookData.c, bookData.b)
					
					if not known and not eideticSeen[bookData.c .. "-" .. bookData.b] then
						table.insert(eideticData[mapIndex], bookData)
						eideticSeen[bookData.c .. "-" .. bookData.b] = true
					end
					
				end
				
				-- Create controls
				
				local eideticBooksInMap = GetControl(LoreBooksReportContainerScrollChild, "EideticBooksInMap" .. mapIndex)
				local eideticMapName = GetControl(LoreBooksReportContainerScrollChild, "EideticMapName" .. mapIndex)
				local eideticReportForMap = GetControl(LoreBooksReportContainerScrollChild, "EideticReportForMap" .. mapIndex)
				
				if not eideticMapName then
					eideticBooksInMap = CreateControlFromVirtual("$(parent)EideticBooksInMap", LoreBooksReportContainerScrollChild, "Lorebook_EideticBooksInMap_Template", mapIndex)
					eideticMapName = CreateControlFromVirtual("$(parent)EideticMapName", LoreBooksReportContainerScrollChild, "Lorebook_EideticMapName_Template", mapIndex)
					eideticReportForMap = CreateControlFromVirtual("$(parent)EideticReportForMap", LoreBooksReportContainerScrollChild, "Lorebook_EideticReportForMap_Template", mapIndex)
				else
					eideticBooksInMap:SetHidden(false)
					eideticMapName:SetHidden(false)
					eideticReportForMap:SetHidden(false)
				end
				
				local missingInMap = #eideticData[mapIndex]
				if missingInMap > 0 then
					
					eideticBooksInMap:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 0, yCollectionIndex)
					eideticMapName:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 25, yCollectionIndex)
					eideticReportForMap:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 50, yCollectionIndex + 24)
					
					eideticBooksInMap:SetText(missingInMap)
					eideticMapName:SetText(zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(mapIndex)))
					
					local eideticReport = ""
					for index, data in ipairs(eideticData[mapIndex]) do
						local bookName = GetLoreBookInfo(3, data.c, data.b)
						eideticReport = zo_strjoin(" ; ", bookName, eideticReport)
					end
					
					if string.len(eideticReport) > 0 then
						eideticReport = string.sub(eideticReport, 0, -3)
					end
					
					eideticReportForMap:SetText(eideticReport)
					copyReport = copyReport .. "\n\n" .. zo_strformat("<<1>> (<<2>>):\n<<3>>", zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(mapIndex)), missingInMap, eideticReport)
					
					eideticReportForMap:GetHeight() -- Needed to let the UI recalculate the correct value. Anchors could be optimized.
					
					yCollectionIndex = yCollectionIndex + eideticReportForMap:GetHeight() + 32
					
				end
				
			end
		end
		
	else
		eideticHeaderText:SetText(GetString(LBOOKS_RE_THREESHOLD_ERROR))
		copyReport = copyReport .. "\n\n" .. GetString(LBOOKS_RE_THREESHOLD_ERROR)
	end
	
end

local function BuildEideticReportPerCollection(lastObject)

	local THRESHOLD_EIDETIC = 2000
	
	local eideticHeaderText = GetControl(LoreBooksReport, "EideticHeaderText")
	eideticHeaderText:ClearAnchors()
	
	eideticHeaderText:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 4, lastObject)
	
	if totalCurrentlyCollected >= THRESHOLD_EIDETIC then
		
		eideticHeaderText:SetText(GetString(LBOOKS_RE_FEW_BOOKS_MISSING))
		copyReport = copyReport .. "\n\n" .. GetString(LBOOKS_RE_FEW_BOOKS_MISSING)
		
		local totalBooks = 0
		local eideticData = {}
		local yCollectionIndex = lastObject + 48
		
		local categoryName, numCollections = GetLoreCategoryInfo(3) -- Only Eidetic
		
		for collectionIndex = 1, numCollections do
			
			eideticData[collectionIndex] = {}
			
			local collectionName, _, _, totalBooksInCollection, hidden = GetLoreCollectionInfo(3, collectionIndex)
			
			if not hidden then
				
				for bookIndex = 1, totalBooksInCollection do
					local bookName, _, known = GetLoreBookInfo(3, collectionIndex, bookIndex)
					
					if not known then
						eideticData[collectionIndex][bookIndex] = bookName
					end
				end
				
				-- Create controls
				
				local missingInCollection = NonContiguousCount(eideticData[collectionIndex])
				if missingInCollection > 0 then
					
					local eideticReport = ""
					
					local eideticBooksInCollection = GetControl(LoreBooksReportContainerScrollChild, "EideticBooksInCollection" .. collectionIndex)
					local eideticCollectionName = GetControl(LoreBooksReportContainerScrollChild, "EideticCollectionName" .. collectionIndex)
					local eideticReportForCollection = GetControl(LoreBooksReportContainerScrollChild, "EideticReportForCollection" .. collectionIndex)
					
					if not eideticCollectionName then
						eideticBooksInCollection = CreateControlFromVirtual("$(parent)EideticBooksInCollection", LoreBooksReportContainerScrollChild, "Lorebook_EideticBooksInCollection_Template", collectionIndex)
						eideticCollectionName = CreateControlFromVirtual("$(parent)EideticCollectionName", LoreBooksReportContainerScrollChild, "Lorebook_EideticCollectionName_Template", collectionIndex)
						eideticReportForCollection = CreateControlFromVirtual("$(parent)EideticReportForCollection", LoreBooksReportContainerScrollChild, "Lorebook_EideticReportForCollection_Template", collectionIndex)
					else
						eideticBooksInCollection:SetHidden(false)
						eideticCollectionName:SetHidden(false)
						eideticReportForCollection:SetHidden(false)
					end
					
					eideticBooksInCollection:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 0, yCollectionIndex)
					eideticCollectionName:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 25, yCollectionIndex)
					eideticReportForCollection:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 50, yCollectionIndex + 24)
					
					eideticBooksInCollection:SetText(missingInCollection)
					eideticCollectionName:SetText(collectionName)
					
					for bookIndex, bookName in pairs(eideticData[collectionIndex]) do
					
						local bookLocation = ""
						local bookData = LoreBooks_GetNewEideticData(3, collectionIndex, bookIndex)
						if bookData then
							if bookData.r then
								bookLocation = "[B] "
							elseif bookData.e then	
								bookLocation = string.format("[%s] ", zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(bookData.e[1].m)))
							end
						end
						
						eideticReport = zo_strjoin("; ", bookLocation .. bookName, eideticReport)
						
					end
					
					if string.len(eideticReport) > 0 then
						eideticReport = string.sub(eideticReport, 0, -3)
					end
					eideticReportForCollection:SetText(eideticReport)
					
					copyReport = copyReport .. "\n\n" .. zo_strformat("<<1>> (<<2>>):\n<<3>>", collectionName, missingInCollection, eideticReport)
					
					eideticReportForCollection:GetHeight() -- Needed to let the UI recalculate the correct value. Anchors could be optimized.
					
					yCollectionIndex = yCollectionIndex + eideticReportForCollection:GetHeight() + 32
					
					totalBooks = totalBooks + missingInCollection
				end
			end
		end
		
	else
		eideticHeaderText:SetText(GetString(LBOOKS_RE_THREESHOLD_ERROR))
		copyReport = copyReport .. "\n\n" .. GetString(LBOOKS_RE_THREESHOLD_ERROR)
	end
	
end

local function BuildEideticReport(lastObject)

	if eideticModeAsked == 2 then
		BuildEideticReportPerCollection(lastObject)
	else
		BuildEideticReportPerMap(lastObject)
	end
	
end

local function HidePreviousReport()
	for childIndex = 1, LoreBooksReportContainerScrollChild:GetNumChildren() do
		local childObject = LoreBooksReportContainerScrollChild:GetChild(childIndex)
		local childName = childObject:GetName()
		if childName ~= "LoreBooksReportEideticHeaderText" and string.find(childName, "Eidetic") then
			childObject:SetHidden(true)
		end
	end
end

-- Todo : use ZO_ScrollList.
local function BuildLoreBookSummary()

	HidePreviousReport()
	
	local lastObject = BuildShalidorReport()
	
	BuildEideticReport(lastObject)
	
	LoreBooksCopyReport:GetNamedChild("Content"):GetNamedChild("Edit"):SetText(copyReport)
	
end

local function SwitchLoreLibraryReportMode()

	if not eideticModeAsked or eideticModeAsked == 1 then
		eideticModeAsked = 2
	else
		eideticModeAsked = 1
	end
	
	BuildLoreBookSummary()
	
end

local function BuildCategoryList(self)
	if self.control:IsControlHidden() then
		self.dirty = true
		return
	end
	
	self.totalCurrentlyCollected = 0
	self.totalPossibleCollected = 0
	
	self.navigationTree:Reset()
	
	lbcategories = {}
	
	for categoryIndex = 1, GetNumLoreCategories() do
		local categoryName, numCollections = GetLoreCategoryInfo(categoryIndex)
		for collectionIndex = 1, numCollections do
			local collectionName, _, _, _, hidden = GetLoreCollectionInfo(categoryIndex, collectionIndex)
			if (db.unlockEidetic and collectionName ~= "") or not hidden then
				lbcategories[#lbcategories + 1] = { categoryIndex = categoryIndex, name = categoryName, numCollections = numCollections }
				break --Don't really understand why ZOS added this.
			end
		end
	end

	table.sort(lbcategories, NameSorter)

	for i, categoryData in ipairs(lbcategories) do
		local parent = self.navigationTree:AddNode("ZO_LabelHeader", categoryData, nil, SOUNDS.LORE_BLADE_SELECTED)
		
		local categoryIndex = categoryData.categoryIndex
		local numCollections = categoryData.numCollections
		
		lbcategories[i].lbcollections = {}
		
		for collectionIndex = 1, numCollections do
			local collectionName, description, numKnownBooks, totalBooks, hidden = GetLoreCollectionInfo(categoryIndex, collectionIndex)
			if (db.unlockEidetic and collectionName ~= "") or not hidden then
				lbcategories[i].lbcollections[#lbcategories[i].lbcollections + 1] = { categoryIndex = categoryIndex, collectionIndex = collectionIndex, name = collectionName, description = description, numKnownBooks = numKnownBooks, totalBooks = totalBooks }
				self.totalCurrentlyCollected = self.totalCurrentlyCollected + numKnownBooks
				self.totalPossibleCollected = self.totalPossibleCollected + totalBooks
			end
		end
		
		table.sort(lbcategories[i].lbcollections, NameSorter)
		
		local search = LORE_LIBRARY.search
		for _, collectionData in ipairs(lbcategories[i].lbcollections) do
			if search and string.len(search) > 2 then
				if IsFoundInLoreLibrary(string.lower(search), collectionData) then
					self.navigationTree:AddNode("ZO_LoreLibraryNavigationEntry", collectionData, parent, SOUNDS.LORE_ITEM_SELECTED)
				end
			else
				self.navigationTree:AddNode("ZO_LoreLibraryNavigationEntry", collectionData, parent, SOUNDS.LORE_ITEM_SELECTED)
			end
		end
		
	end

	self.navigationTree:Commit()
	self:RefreshCollectedInfo()
	
	--Dirty hack to unselect all nodes and select the 1st one.
	
	if self.navigationTree.rootNode.children then
		if self.navigationTree.rootNode.children[1] and self.navigationTree.rootNode.children[1].children then
			self.navigationTree:SelectNode(self.navigationTree.rootNode.children[1].children[1])
		elseif self.navigationTree.rootNode.children[2] and self.navigationTree.rootNode.children[2].children then
			self.navigationTree:SelectNode(self.navigationTree.rootNode.children[2].children[1])
		end
	end
	
	KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
	
	self.dirty = false
	
	return true
	
end

-- "Right clic"
local function OnRowMouseUp(control, button)
	if button == MOUSE_BUTTON_INDEX_RIGHT then
		ClearMenu()
		
		-- Cannot access to self. (and self ~= control here)
		--SetMenuHiddenCallback(function() self:UnlockSelection() end)
		--self:LockSelection()
		
		if control.known then
			AddMenuItem(GetString(SI_LORE_LIBRARY_READ), function() ZO_LoreLibrary_ReadBook(control.categoryIndex, control.collectionIndex, control.bookIndex) end)
		end
		
		if IsChatSystemAvailableForCurrentPlatform() then
			AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function()
				local link = ZO_LinkHandler_CreateChatLink(GetLoreBookLink, control.categoryIndex, control.collectionIndex, control.bookIndex)
				ZO_LinkHandler_InsertLink(link) 
			end)
		end
		
		if control.categoryIndex == 1 then
			local lorebookInfoOnBook = LoreBooks_GetDataOfBook(control.categoryIndex, control.collectionIndex, control.bookIndex)
			for resultEntry, resultData in ipairs(lorebookInfoOnBook) do
				
				local mapIndex = LoreBooks_GetMapIndexFromMapTile(resultData.zoneName, resultData.subZoneName)
				
				if mapIndex then
					AddMenuItem(zo_strformat("<<1>> : <<2>>x<<3>>", zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(mapIndex)), (resultData.locX * 100), (resultData.locY * 100)),
					function()
						
						ZO_WorldMap_SetMapByIndex(mapIndex)
						PingMap(MAP_PIN_TYPE_RALLY_POINT, MAP_TYPE_LOCATION_CENTERED, resultData.locX, resultData.locY)
						PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, resultData.locX, resultData.locY)
						
						if(not ZO_WorldMap_IsWorldMapShowing()) then
							if IsInGamepadPreferredMode() then
								SCENE_MANAGER:Push("gamepad_worldMap")
							else
								MAIN_MENU_KEYBOARD:ShowCategory(MENU_CATEGORY_MAP)
								mapAvailable = false
							end
							mapAvailable = false
							zo_callLater(function() GPS:PanToMapPosition(resultData.locX, resultData.locY) end, 1000)
						end
						
					end)
				end
				
			end
		elseif control.categoryIndex == 3 then
			
			local bookData = LoreBooks_GetNewEideticData(control.categoryIndex, control.collectionIndex, control.bookIndex)
			
			if bookData and bookData.c and bookData.e then
				
				for index, data in ipairs(bookData.e) do
				
					if not data.r and data.zx and data.zy then
					
						local xTooltip = ("%0.02f"):format(zo_round(data.zx*10000)/100)
						local yTooltip = ("%0.02f"):format(zo_round(data.zy*10000)/100)
						AddMenuItem(zo_strformat("<<1>> (<<2>>x<<3>>)", zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(data.m)), xTooltip, yTooltip),
						function()
							
							ZO_WorldMap_SetMapByIndex(data.m)
							
							PingMap(MAP_PIN_TYPE_RALLY_POINT, MAP_TYPE_LOCATION_CENTERED, data.zx, data.zy)
							PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, data.zx, data.zy)
							
							if(not ZO_WorldMap_IsWorldMapShowing()) then
								if IsInGamepadPreferredMode() then
									SCENE_MANAGER:Push("gamepad_worldMap")
								else
									MAIN_MENU_KEYBOARD:ShowCategory(MENU_CATEGORY_MAP)
								end
								mapIsShowing = true
								zo_callLater(function() mapIsShowing = false end, 500) -- Bit dirty but ZO_WorldMap_IsWorldMapShowing() isn't fast enought
								zo_callLater(function() GPS:PanToMapPosition(data.zx, data.zy) end, 1000)
							end
							
						end)
						
					end
				end
			end
			
		end
		
		ShowMenu(control)
		
	end
end

-- Mouse "hover"
local function OnMouseEnter(self, categoryIndex, collectionIndex, bookIndex)

	local STD_ZONE = 0

	-- No 1 for now.
	if categoryIndex == 3 and not mapIsShowing then
	
		local bookData = LoreBooks_GetNewEideticData(categoryIndex, collectionIndex, bookIndex)

		if bookData and bookData.c then
			
			local bookName = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex) -- Could be retrieved automatically
			InitializeTooltip(InformationTooltip, self, BOTTOMLEFT, 0, 0, TOPRIGHT)
			InformationTooltip:AddLine(bookName, "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
			ZO_Tooltip_AddDivider(InformationTooltip)
			
			local addDivider
			local entryWeight = {}
			
			if bookData.q then
				InformationTooltip:AddLine(GetString(LBOOKS_QUEST_BOOK), "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
				InformationTooltip:AddLine(string.format("[%s]", bookData.q[lang] or bookData.q["en"]), "", ZO_SELECTED_TEXT:UnpackRGB())
				
				local questDetails
				if bookData.qt then
					questDetails = zo_strformat(GetString("LBOOKS_SPECIAL_QUEST"), bookData.qt)
				else
					questDetails = zo_strformat(GetString(LBOOKS_QUEST_IN_ZONE), zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(bookData.qm)))
				end
				
				InformationTooltip:AddLine(questDetails)
				
			elseif bookData.r and NonContiguousCount(bookData.m) > 1 then
				
				InformationTooltip:AddLine(GetString(LBOOKS_RANDOM_POSITION), "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
				ZO_Tooltip_AddDivider(InformationTooltip)
				
				for mapIndex, count in pairs(bookData.m) do
					InformationTooltip:AddLine(zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(mapIndex)), "", ZO_SELECTED_TEXT:UnpackRGB())
				end
				
			else
				for index, data in ipairs(bookData.e) do
					
					local insert = true
					local x = data.x
					local y = data.y
					local mapIndex = data.m
					local zoneId = data.z
					local isRandom = data.r
					local inDungeon = data.d
					local isFromBag = data.i == INTERACTION_NONE
					
					local weight = 0
					if isRandom then
						weight = weight + 1
					end
					if inDungeon then
						weight = weight + 2
					end
					
					local zoneName = zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetZoneNameByIndex(GetZoneIndex(zoneId)))
					local mapName = zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(mapIndex))
					
					local bookPosition
					if zoneName ~= mapName then
						bookPosition = zo_strformat("<<1>> - <<2>>", mapName, zoneName)
						if entryWeight[bookPosition] and entryWeight[bookPosition][weight] then
							insert = false
						end
					else
						bookPosition = mapName
						if entryWeight[bookPosition] and entryWeight[bookPosition][weight] then
							insert = false
						end
					end
					
					if not entryWeight[bookPosition] then entryWeight[bookPosition] = {} end
					entryWeight[bookPosition][weight] = true
					
					if insert then
						if addDivider then
							ZO_Tooltip_AddDivider(InformationTooltip)
						end
						addDivider = true
						
						InformationTooltip:AddLine(bookPosition, "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
						
						if inDungeon then
							InformationTooltip:AddLine(zo_strformat("[<<1>>]", GetString(SI_QUESTTYPE5)), "", ZO_SELECTED_TEXT:UnpackRGB())
						end
						
						if isFromBag then
							InformationTooltip:AddLine(zo_strformat("[<<1>>]", GetString(LBOOKS_MAYBE_NOT_HERE)), "", ZO_SELECTED_TEXT:UnpackRGB())
						elseif isRandom then
							InformationTooltip:AddLine(GetString(LBOOKS_RANDOM_POSITION))
						end
							
					end
					
				end
				
			end
		end
		
	end
	
	self.owner:EnterRow(self)

end

local function OnMouseExit(self)
	ClearTooltip(InformationTooltip)
	self.owner:ExitRow(self)
end

local function BuildBookListPostHook()
	for _, controlObject in ipairs(LORE_LIBRARY.list.list.activeControls) do
		controlObject:SetHandler("OnMouseUp", OnRowMouseUp)
		controlObject:SetHandler("OnMouseEnter", function(self) OnMouseEnter(self, controlObject.categoryIndex, controlObject.collectionIndex, controlObject.bookIndex) end)
		controlObject:SetHandler("OnMouseExit", function(self) OnMouseExit(self) end)
	end
end

local function RewriteLibrairy()

	if (lang == "fr" or lang == "en" or lang == "de") and GetAPIVersion() == SUPPORTED_API then

		local original_GetNumLoreCategories = GetNumLoreCategories
		GetNumLoreCategories = function()
			if db.unlockEidetic then
				return 3
			else
				return original_GetNumLoreCategories()
			end
		end
		
		local original_GetLoreCategoryInfo = GetLoreCategoryInfo
		GetLoreCategoryInfo = function(categoryIndex)
			if db.unlockEidetic then
				return LoreBooks_GetNewEideticLoreCategoryInfo(categoryIndex)
			else
				return original_GetLoreCategoryInfo(categoryIndex)
			end
		end
		
		local original_GetLoreCollectionInfo = GetLoreCollectionInfo
		GetLoreCollectionInfo = function(categoryIndex, collectionIndex)
			if db.unlockEidetic then
				return LoreBooks_GetNewLoreCollectionInfo(categoryIndex, collectionIndex)
			else
				return original_GetLoreCollectionInfo(categoryIndex, collectionIndex)
			end
		end
	
	end
	
end

local function RebuildLoreLibrairy()
	
	loreLibraryReportKeybind =
	{
		{
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			name = "Report",
			keybind = "UI_SHORTCUT_SECONDARY",
			callback = ShowLoreLibraryReport,
		},
		{
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			name = "Switch Mode",
			keybind = "UI_SHORTCUT_QUATERNARY",
			callback = SwitchLoreLibraryReportMode,
			visible = IsReportShown,
		},
		{
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			name = "Copy",
			keybind = "UI_SHORTCUT_TERTIARY",
			callback = ShowLoreLibraryCopyReport,
			visible = IsReportShown,
		},
	}
	
	local function OnStateChanged(oldState, newState)
		if newState == SCENE_SHOWING then
			KEYBIND_STRIP:AddKeybindButtonGroup(loreLibraryReportKeybind)
		elseif newState == SCENE_HIDDEN then
			KEYBIND_STRIP:RemoveKeybindButtonGroup(loreLibraryReportKeybind)
			ShowLoreLibraryReport(true)
		end
	end
	
	LORE_LIBRARY_SCENE:RegisterCallback("StateChange", OnStateChanged)
	
	local lorebookResearch = WINDOW_MANAGER:CreateControlFromVirtual("Lorebook_Research", ZO_LoreLibrary, "Lorebook_Research_Template")
	lorebookResearch.searchBox = GetControl(lorebookResearch, "Box")
	lorebookResearch.searchBox:SetHandler("OnTextChanged", OnSearchTextChanged)
	
	ZO_PreHook(LORE_LIBRARY, "BuildCategoryList", BuildCategoryList)
	
	RewriteLibrairy()
	BuildLorebooksLoreLibrary()
	BuildLoreBookSummary()
	
	local origLoreLibraryBuildBookList = LORE_LIBRARY.BuildBookList
	LORE_LIBRARY.BuildBookList = function(self, ...)
		origLoreLibraryBuildBookList(self, ...)
		BuildBookListPostHook()
	end
	
end

local function IsPlayerOnCurrentMap()

	local x, y = GetMapPlayerPosition("player")
	if x and y and x > 0 and y > 0 and x < 1 and y < 1 then
		return true
	end
	return false
	
end

local function CreatePins()

	local pinTextureLevel = db.pinTexture.level
	local pinTextureSize = db.pinTexture.size
	local compassMaxDistance = db.compassMaxDistance
	
	local mapPinLayout_eidetic = { level = pinTextureLevel, texture = GetPinTextureEidetic, size = pinTextureSize }
	local mapPinLayout_eideticCollected = { level = pinTextureLevel, texture = GetPinTextureEidetic, size = pinTextureSize }
	local mapPinLayout_unknown = { level = pinTextureLevel, texture = GetPinTexture, size = pinTextureSize }
	local mapPinLayout_collected = { level = pinTextureLevel, texture = GetPinTexture, size = pinTextureSize, grayscale = IsPinGrayscale }
	local compassPinLayout = { maxDistance = compassMaxDistance, texture = pinTextures[db.pinTexture.type][2],
		sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
			if zo_abs(normalizedAngle) > 0.25 then
				pin:SetDimensions(54 - 24 * zo_abs(normalizedAngle), 54 - 24 * zo_abs(normalizedAngle))
			else
				pin:SetDimensions(48, 48)
			end
		end,
		additionalLayout = {
			function(pin, angle, normalizedAngle, normalizedDistance)
				if (pinTexturesList[db.pinTexture.type] == "Shalidor's Library icons") then --replace icon with icon from LoreLibrary
					local _, texture = GetLoreBookInfo(1, pin.pinTag[3], pin.pinTag[4])
					if icon == MISSING_TEXTURE then icon = PLACEHOLDER_TEXTURE end
					local icon = pin:GetNamedChild("Background")
					icon:SetTexture(texture)
				end
			end,
			function(pin)
				--I do not need to reset anything (texture is changed automatically), so the function is empty
			end
		}
	}
	local compassPinLayoutEidetic = { maxDistance = compassMaxDistance, texture = pinTextures[db.pinTexture.type][2],
		sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
			if zo_abs(normalizedAngle) > 0.25 then
				pin:SetDimensions(54 - 24 * zo_abs(normalizedAngle), 54 - 24 * zo_abs(normalizedAngle))
			else
				pin:SetDimensions(48, 48)
			end
		end,
		additionalLayout = {
			function(pin, angle, normalizedAngle, normalizedDistance)
				if (pinTexturesList[db.pinTexture.type] == "Shalidor's Library icons") then --replace icon with icon from LoreLibrary
					local _, texture = GetLoreBookInfo(3, pin.pinTag.c, pin.pinTag.b)
					if icon == MISSING_TEXTURE then icon = PLACEHOLDER_TEXTURE end
					local icon = pin:GetNamedChild("Background")
					icon:SetTexture(texture)
				end
			end,
			function(pin)
				--I do not need to reset anything (texture is changed automatically), so the function is empty
			end
		}
	}
	
	--initialize map pins
	LMP:AddPinType(PINS_UNKNOWN, MapCallback_unknown, nil, mapPinLayout_unknown, pinTooltipCreator)
	LMP:AddPinType(PINS_COLLECTED, MapCallback_collected, nil, mapPinLayout_collected, pinTooltipCreator)
	LMP:AddPinType(PINS_EIDETIC, MapCallback_eidetic, nil, mapPinLayout_eidetic, pinTooltipCreatorEidetic)
	
	--add map filters
	LMP:AddPinFilter(PINS_UNKNOWN, GetString(LBOOKS_FILTER_UNKNOWN), nil, db.filters)
	LMP:AddPinFilter(PINS_COLLECTED, GetString(LBOOKS_FILTER_COLLECTED), nil, db.filters)
	LMP:AddPinFilter(PINS_EIDETIC, GetLoreCategoryInfo(3), nil, db.filters)
	
	if totalCurrentlyCollected >= THREESHOLD_EIDETIC then
		LMP:AddPinType(PINS_EIDETIC_COLLECTED, MapCallback_eideticCollected, nil, mapPinLayout_eideticCollected, pinTooltipCreatorEidetic)
		LMP:AddPinFilter(PINS_EIDETIC_COLLECTED, zo_strformat(LBOOKS_FILTER_EICOLLECTED, GetLoreCategoryInfo(3)), nil, db.filters)
	end
	
	--add handler for the left click
	LMP:SetClickHandlers(PINS_UNKNOWN, {
		[1] = {
			name = function(pin) return zo_strformat(LBOOKS_SET_WAYPOINT, GetLoreBookInfo(1, pin.m_PinTag[3], pin.m_PinTag[4])) end,
			show = function(pin) return not select(3, GetLoreBookInfo(1, pin.m_PinTag[3], pin.m_PinTag[4])) end,
			duplicates = function(pin1, pin2) return (pin1.m_PinTag[3] == pin2.m_PinTag[3] and pin1.m_PinTag[4] == pin2.m_PinTag[4]) end,
			callback = function(pin) PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, pin.normalizedX, pin.normalizedY) end,
		}
	},
	{
		[1] = {
			name = function(pin) return zo_strformat(LBOOKS_SET_WAYPOINT, GetLoreBookInfo(1, pin.m_PinTag[3], pin.m_PinTag[4])) end,
			show = function(pin) return not select(3, GetLoreBookInfo(1, pin.m_PinTag[3], pin.m_PinTag[4])) end,
			duplicates = function(pin1, pin2) return (pin1.m_PinTag[3] == pin2.m_PinTag[3] and pin1.m_PinTag[4] == pin2.m_PinTag[4]) end,
			callback = function(pin)
				if IsPlayerOnCurrentMap() then
					local zone, subzone = LMP:GetZoneAndSubzone()
					local mapIndex = GetCurrentMapIndex()
					ReportBook(pin.m_PinTag.k, pin.m_PinTag[1], pin.m_PinTag[2], zone, subzone, mapIndex)
				end
			end,
		}
	})
	LMP:SetClickHandlers(PINS_COLLECTED, nil,
	{
		[1] = {
			name = function(pin) return zo_strformat(LBOOKS_REPORT_BOOK, GetLoreBookInfo(1, pin.m_PinTag[3], pin.m_PinTag[4])) end,
			show = function(pin) return select(3, GetLoreBookInfo(1, pin.m_PinTag[3], pin.m_PinTag[4])) == true end,
			duplicates = function(pin1, pin2) return (pin1.m_PinTag[3] == pin2.m_PinTag[3] and pin1.m_PinTag[4] == pin2.m_PinTag[4]) end,
			callback = function(pin)
				if IsPlayerOnCurrentMap() then
					local zone, subzone = LMP:GetZoneAndSubzone()
					local mapIndex = GetCurrentMapIndex()
					ReportBook(pin.m_PinTag.k, pin.m_PinTag[1], pin.m_PinTag[2], zone, subzone, mapIndex)
				end
			end,
		}
	})
	LMP:SetClickHandlers(PINS_EIDETIC, {
		[1] = {
			name = function(pin) return zo_strformat(LBOOKS_SET_WAYPOINT, GetLoreBookInfo(3, pin.m_PinTag.c, pin.m_PinTag.b)) end,
			show = function(pin) return not select(3, GetLoreBookInfo(3, pin.m_PinTag.c, pin.m_PinTag.b)) end,
			duplicates = function(pin1, pin2) return (pin1.m_PinTag.b == pin2.m_PinTag.c and pin1.m_PinTag.b == pin2.m_PinTag.b) end,
			callback = function(pin) PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, pin.normalizedX, pin.normalizedY) end,
		}
	})
	LMP:SetClickHandlers(PINS_EIDETIC_COLLECTED, {
		[1] = {
			name = function(pin) return zo_strformat(LBOOKS_SET_WAYPOINT, GetLoreBookInfo(3, pin.m_PinTag.c, pin.m_PinTag.b)) end,
			show = function(pin) return select(3, GetLoreBookInfo(3, pin.m_PinTag.c, pin.m_PinTag.b)) == true end,
			duplicates = function(pin1, pin2) return (pin1.m_PinTag.b == pin2.m_PinTag.c and pin1.m_PinTag.b == pin2.m_PinTag.b) end,
			callback = function(pin) PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, pin.normalizedX, pin.normalizedY) end,
		}
	})
	
	--initialize compass pins
	COMPASS_PINS:AddCustomPin(PINS_COMPASS, CompassCallback, compassPinLayout)
	COMPASS_PINS:RefreshPins(PINS_COMPASS)
	
	COMPASS_PINS:AddCustomPin(PINS_COMPASS_EIDETIC, CompassCallbackEidetic, compassPinLayoutEidetic)
	COMPASS_PINS:RefreshPins(PINS_COMPASS_EIDETIC)
	
end

local function OnBookLearned(eventCode, categoryIndex, collectionIndex, bookIndex)
	
	totalCurrentlyCollected = totalCurrentlyCollected + 1
	
	--Refresh map if needed and get player position
	if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
	end
	
	local x, y = GetMapPlayerPosition("player")

	if not InvalidPoint(x, y) then -- can be false in some very rare place (mainly fighters/mages/main questline dungeons).
		
		if categoryIndex == 1 then
			LMP:RefreshPins(PINS_UNKNOWN)
			LMP:RefreshPins(PINS_COLLECTED)
			COMPASS_PINS:RefreshPins(PINS_COMPASS)
		elseif categoryIndex == 3 then
			LMP:RefreshPins(PINS_EIDETIC)
			LMP:RefreshPins(PINS_EIDETIC_COLLECTED)
			COMPASS_PINS:RefreshPins(PINS_COMPASS_EIDETIC)
		end

	end
	
	BuildLoreBookSummary()
	
	-- LORE_LIBRARY need to be refreshed first
	zo_callLater(function() ShowCongrats(true) end, 50)
	
end

-- Settings menu --------------------------------------------------------------
local function CreateSettingsMenu()
	local panelData = {
		type = "panel",
		name = GetString(LBOOKS_TITLE),
		displayName = ZO_HIGHLIGHT_TEXT:Colorize(GetString(LBOOKS_TITLE)),
		author = ADDON_AUTHOR,
		version = ADDON_VERSION,
		slashCommand = "/lorebooks",
		registerForRefresh = true,
		registerForDefaults = true,
		website = ADDON_WEBSITE,
	}
	LAM:RegisterAddonPanel(ADDON_NAME, panelData)

	local CreateIcons, unknownIcon, collectedIcon
	CreateIcons = function(panel)
		if panel == LoreBooks then
			unknownIcon = WINDOW_MANAGER:CreateControl(nil, panel.controlsToRefresh[1], CT_TEXTURE)
			unknownIcon:SetAnchor(RIGHT, panel.controlsToRefresh[1].combobox, LEFT, -10, 0)
			unknownIcon:SetTexture(pinTextures[db.pinTexture.type][2])
			unknownIcon:SetDimensions(db.pinTexture.size, db.pinTexture.size)
			collectedIcon = WINDOW_MANAGER:CreateControl(nil, panel.controlsToRefresh[1], CT_TEXTURE)
			collectedIcon:SetAnchor(RIGHT, unknownIcon, LEFT, -5, 0)
			collectedIcon:SetTexture(pinTextures[db.pinTexture.type][1])
			collectedIcon:SetDimensions(db.pinTexture.size, db.pinTexture.size)
			collectedIcon:SetDesaturation((pinTexturesList[db.pinTexture.type] == "Shalidor's Library icons") and 1 or 0)
			CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", CreateIcons)
		end
	end
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", CreateIcons)

	local optionsTable = {
		{
			type = "dropdown",
			name = GetString(LBOOKS_PIN_TEXTURE),
			tooltip = GetString(LBOOKS_PIN_TEXTURE_DESC),
			choices = pinTexturesList,
			getFunc = function() return pinTexturesList[db.pinTexture.type] end,
			setFunc = function(selected)
					for index, name in ipairs(pinTexturesList) do
						if name == selected then
							db.pinTexture.type = index
							unknownIcon:SetTexture(pinTextures[index][2])
							collectedIcon:SetDesaturation((pinTexturesList[index] == "Shalidor's Library icons") and 1 or 0)
							collectedIcon:SetTexture(pinTextures[index][1])
							LMP:RefreshPins(PINS_UNKNOWN)
							LMP:RefreshPins(PINS_COLLECTED)
							LMP:RefreshPins(PINS_EIDETIC)
							LMP:RefreshPins(PINS_EIDETIC_COLLECTED)
							COMPASS_PINS.pinLayouts[PINS_COMPASS].texture = pinTextures[index][2]
							COMPASS_PINS:RefreshPins(PINS_COMPASS)
							COMPASS_PINS.pinLayouts[PINS_COMPASS_EIDETIC].texture = pinTextures[index][2]
							COMPASS_PINS:RefreshPins(PINS_COMPASS_EIDETIC)
							break
						end
					end
				end,
			disabled = function() return not (db.filters[PINS_UNKNOWN] or db.filters[PINS_COLLECTED] or db.filters[PINS_EIDETIC] or db.filters[PINS_EIDETIC_COLLECTED]) end,
			default = pinTexturesList[defaults.pinTexture.type],
		},
		{
			type = "slider",
			name = GetString(LBOOKS_PIN_SIZE),
			tooltip = GetString(LBOOKS_PIN_SIZE_DESC),
			min = 20,
			max = 70,
			step = 1,
			getFunc = function() return db.pinTexture.size end,
			setFunc = function(size)
					db.pinTexture.size = size
					unknownIcon:SetDimensions(size, size)
					collectedIcon:SetDimensions(size, size)
					LMP:SetLayoutKey(PINS_UNKNOWN, "size", size)
					LMP:SetLayoutKey(PINS_COLLECTED, "size", size)
					LMP:SetLayoutKey(PINS_EIDETIC, "size", size)
					LMP:SetLayoutKey(PINS_EIDETIC_COLLECTED, "size", size)
					LMP:RefreshPins(PINS_UNKNOWN)
					LMP:RefreshPins(PINS_COLLECTED)
					LMP:RefreshPins(PINS_EIDETIC)
					LMP:RefreshPins(PINS_EIDETIC_COLLECTED)
				end,
			disabled = function() return not (db.filters[PINS_UNKNOWN] or db.filters[PINS_COLLECTED] or db.filters[PINS_EIDETIC] or db.filters[PINS_EIDETIC_COLLECTED]) end,
			default = defaults.pinTexture.size
		},
		{
			type = "slider",
			name = GetString(LBOOKS_PIN_LAYER),
			tooltip = GetString(LBOOKS_PIN_LAYER_DESC),
			min = 10,
			max = 200,
			step = 5,
			getFunc = function() return db.pinTexture.level end,
			setFunc = function(level)
					db.pinTexture.level = level
					LMP:SetLayoutKey(PINS_UNKNOWN, "level", level)
					LMP:SetLayoutKey(PINS_COLLECTED, "level", level)
					LMP:SetLayoutKey(PINS_EIDETIC, "level", level)
					LMP:SetLayoutKey(PINS_EIDETIC_COLLECTED, "level", level)
					LMP:RefreshPins(PINS_UNKNOWN)
					LMP:RefreshPins(PINS_COLLECTED)
					LMP:RefreshPins(PINS_EIDETIC)
					LMP:RefreshPins(PINS_EIDETIC_COLLECTED)
				end,
			disabled = function() return not (db.filters[PINS_UNKNOWN] or db.filters[PINS_COLLECTED] or db.filters[PINS_EIDETIC] or db.filters[PINS_EIDETIC_COLLECTED]) end,
			default = defaults.pinTexture.level,
		},
		{
			type = "checkbox",
			name = GetString(LBOOKS_UNKNOWN),
			tooltip = GetString(LBOOKS_UNKNOWN_DESC),
			getFunc = function() return db.filters[PINS_UNKNOWN] end,
			setFunc = function(state)
					db.filters[PINS_UNKNOWN] = state
					LMP:SetEnabled(PINS_UNKNOWN, state)
				end,
			default = defaults.filters[PINS_UNKNOWN],
		},
		{
			type = "checkbox",
			name = GetString(LBOOKS_COLLECTED),
			tooltip = GetString(LBOOKS_COLLECTED_DESC),
			getFunc = function() return db.filters[PINS_COLLECTED] end,
			setFunc = function(state)
					db.filters[PINS_COLLECTED] = state
					LMP:SetEnabled(PINS_COLLECTED, state)
				end,
			default = defaults.filters[PINS_COLLECTED]
		},
		{
			type = "checkbox",
			name = GetString(LBOOKS_EIDETIC),
			tooltip = GetString(LBOOKS_EIDETIC_DESC),
			getFunc = function() return db.filters[PINS_EIDETIC] end,
			setFunc = function(state)
					db.filters[PINS_EIDETIC] = state
					LMP:SetEnabled(PINS_EIDETIC, state)
				end,
			default = defaults.filters[PINS_EIDETIC]
		},
		{
			type = "checkbox",
			name = GetString(LBOOKS_EIDETIC_COLLECTED),
			tooltip = GetString(LBOOKS_EIDETIC_COLLECTED_DESC),
			getFunc = function() return db.filters[PINS_EIDETIC_COLLECTED] end,
			setFunc = function(state)
					db.filters[PINS_EIDETIC_COLLECTED] = state
					LMP:SetEnabled(PINS_EIDETIC_COLLECTED, state)
				end,
			default = defaults.filters[PINS_EIDETIC_COLLECTED]
		},
		{
			type = "checkbox",
			name = GetString(LBOOKS_COMPASS_UNKNOWN),
			tooltip = GetString(LBOOKS_COMPASS_UNKNOWN_DESC),
			getFunc = function() return db.filters[PINS_COMPASS] end,
			setFunc = function(state)
					db.filters[PINS_COMPASS] = state
					COMPASS_PINS:RefreshPins(PINS_COMPASS)
				end,
			default = defaults.filters[PINS_COMPASS],
		},
		{
			type = "checkbox",
			name = GetString(LBOOKS_COMPASS_EIDETIC),
			tooltip = GetString(LBOOKS_COMPASS_EIDETIC_DESC),
			getFunc = function() return db.filters[PINS_COMPASS_EIDETIC] end,
			setFunc = function(state)
					db.filters[PINS_COMPASS_EIDETIC] = state
					COMPASS_PINS:RefreshPins(PINS_COMPASS_EIDETIC)
				end,
			default = defaults.filters[PINS_COMPASS_EIDETIC],
		},
		{
			type = "slider",
			name = GetString(LBOOKS_COMPASS_DIST),
			tooltip = GetString(LBOOKS_COMPASS_DIST_DESC),
			min = 1,
			max = 100,
			step = 1,
			getFunc = function() return db.compassMaxDistance * 1000 end,
			setFunc = function(maxDistance)
					db.compassMaxDistance = maxDistance / 1000
					COMPASS_PINS.pinLayouts[PINS_COMPASS].maxDistance = maxDistance / 1000
					COMPASS_PINS:RefreshPins(PINS_COMPASS)
					COMPASS_PINS.pinLayouts[PINS_COMPASS_EIDETIC].maxDistance = maxDistance / 1000
					COMPASS_PINS:RefreshPins(PINS_COMPASS_EIDETIC)
				end,
			disabled = function() return not (db.filters[PINS_COMPASS] or db.filters[PINS_COMPASS_EIDETIC]) end,
			default = defaults.compassMaxDistance * 1000,
		},
		{
			type = "checkbox",
			name = GetString(LBOOKS_UNLOCK_EIDETIC),
			tooltip = GetString(LBOOKS_UNLOCK_EIDETIC_DESC),
			getFunc = function() return db.unlockEidetic end,
			setFunc = function(state)
				db.unlockEidetic = state
				LORE_LIBRARY:BuildCategoryList()
			end,
			default = defaults.unlockEidetic,
			disabled = function() return GetAPIVersion() ~= SUPPORTED_API end,
		},
		{
			type = "checkbox",
			name = GetString(LBOOKS_SHARE_DATA),
			tooltip = GetString(LBOOKS_SHARE_DATA_DESC),
			getFunc = function() return db.shareData end,
			setFunc = function(state)
				db.shareData = state
				ToggleShareData()
				end,
			default = defaults.shareData,
			disabled = GetWorldName() ~= "EU Megaserver" or not (lang == "fr" or lang == "en" or lang == "de")
		},
	}
	LAM:RegisterOptionControls(ADDON_NAME, optionsTable)
end

local function OnLoad(eventCode, name)

	if name == ADDON_NAME then
		
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
		
		--saved variables for settings
		db = ZO_SavedVars:NewCharacterNameSettings("LBooks_SavedVariables", 2, nil, defaults)
		
		-- Settings
		CreateSettingsMenu()
		
		-- Lorelibrary
		RebuildLoreLibrairy()
		
		-- Tooltip Mode
		OnGamepadPreferredModeChanged()
		
		-- LibMapPins
		CreatePins()

		-- Data sniffer
		ToggleShareData()
		
		-- Help panel is built by XML
		InitializeLoreBooksHelp()
		
		--events
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_LORE_BOOK_LEARNED, OnBookLearned)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, ShowCongrats)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, OnGamepadPreferredModeChanged)
		
	end
	
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoad)