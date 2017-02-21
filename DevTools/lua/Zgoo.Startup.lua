if Zgoo then return end

Zgoo = {}
setmetatable(Zgoo, {__call = function(me,tab) Zgoo.CommandHandler(tab) end})
Zgoo.version = 1.0
Zgoo.author = "@Errc"

local defaults = {
	events = {},
	conditionTypes = {},
}

local wm = WINDOW_MANAGER

function Zgoo.ChainCall(obj)
	local T={}
	setmetatable(T,{__index = function(self,fun)
		if fun=="__END" then
			return obj
		end
		return function(self,...)
			assert(obj[fun],fun.." missing in object")
			obj[fun](obj,...)
			return self
		end
	end})
	return T
end

local firsttime=true
function Zgoo.CommandHandler(text)
	
	local self = Zgoo
	
	Zgoo.SV = ZO_SavedVars:New("ZgooSV", Zgoo.version, nil, defaults)	-- This isn't actually used.... But without it global examining doesn't work with a for loop... wat?
	
	SetGameCameraUIMode(true)	--Free da mouse!

	if (not text or text=="") and firsttime then text="global" firsttime=false end
	
	if not text or text=="" then
		if not self.Frame then self:CreateFrame() end
		self.Frame:SetHidden(not self.Frame:IsHidden())
	elseif text=="global" or text=="_G" or text=="GLOBAL" then
		Zgoo:Main(nil,1,_G,nil,"global") -- indicate global mode explicitly
	elseif text=="g2" then  -- unused, not needed
		Zgoo:CloneGlobals()
		Zgoo:Main(nil,1,Zgoo._G2,nil,"global")
	elseif text.find and text:find("^find") then  -- unused, not needed
		self.find = text:match("^find (.*)")
		d("Finding "..(self.find and self.find or "(nothing)")..", keep scrolling around...")
		Zgoo:Update()
	elseif text=="free" or text=="FREE" then
		-- Just freed the mouse. We done....
	elseif text=="events" or text=="EVENTS" then
		if not self.Events.EventTracker then self.Events:CreateEventTracker() end
		-- Reset defaults
		self.Events.curBotEvent = 0
		self.Events.eventsTable = {}
		Zgoo.ChainCall(self.Events.EventTracker.slider)
			:SetMinMax(0,0)
			:SetValue(0)
		self.Events.EventTracker:SetHidden(not self.Events.EventTracker:IsHidden())
	elseif text=="mouse" then
		local control = wm:GetMouseOverControl()
		-- TODO maybe find a way to do all controls under the mouse.
		Zgoo:Main(nil,1,control)
	elseif type(text)=="table" or type(text)=="userdata" then
		Zgoo:Main(nil,1,text)
	elseif type(text)=="string" then
		local s = ("Zgoo:Main(nil,1,%s)"):format(text)
		local f,err = zo_loadstring( s )
		if f then f() else d("|cffff0000Error:|r "..err) end
	else
		error("Invalid Zgoo Param: "..tostring(text))
	end
end

SLASH_COMMANDS["/zgoo"] = Zgoo.CommandHandler
SLASH_COMMANDS["/spoo"] = Zgoo.CommandHandler
SLASH_COMMANDS["/run"] = SLASH_COMMANDS["/script"]
SLASH_COMMANDS["/re"] = SLASH_COMMANDS["/reloadui"]
SLASH_COMMANDS["/dump"] = function(text)
	local f,err = zo_loadstring( ("d(%s)"):format(text) )
	if f then f() else d("|cffff0000Error:|r "..err) end
end

SLASH_COMMANDS["/findlorebook"] = function(text)
	text=text:lower()
	local lore = Zgoo.Utils:GetLoreBookInfo()
	for cati,cat in ipairs(lore) do
		for coli,col in ipairs(cat) do
			for booki,book in ipairs(col) do
				if book:lower():match(text) then d(book) end
			end
		end
	end
end

Zgoo.UiTypes = {
	[-1] = "CT_INVALID_TYPE",
	[0] = "CT_CONTROL",
	"CT_LABEL",
	"CT_DEBUGTEXT",
	"CT_TEXTURE",
	"CT_TOPLEVELCONTROL",
	"CT_ROOT_WINDOW",
	"CT_TEXTBUFFER",
	"CT_BUTTON",
	"CT_STATUSBAR",
	"CT_EDITBOX",
	"CT_COOLDOWN",
	"CT_TOOLTIP",
	"CT_SCROLL",
	"CT_SLIDER",
	"CT_BACKDROP",
	"CT_MAPDISPLAY",
	"CT_COLORSELECT",
	"CT_LINE",
	"CT_BROWSER",
	"CT_COMPASS",
}
setmetatable(Zgoo.UiTypes,{__index = "NO_TYPE"})

function Zgoo:Init()

	-- and now for something completely different, copy error out of the default window
	local CHAIN = Zgoo.ChainCall
	local wm = WINDOW_MANAGER
	ZO_UIErrors.copy = CHAIN(wm:CreateControl("ZO_UIErrorsContainer_Copy",ZO_UIErrors,CT_BUTTON))
		:SetDimensions(50,20)
		:SetAnchor(BOTTOMRIGHT,ZO_UIErrors,BOTTOMRIGHT,0,0)
		:SetFont("ZoFontGame")
		:SetText("COPY")
		:SetHandler("OnClicked",function(self,but)
			ZO_UIErrors.edit:SetText(ZO_UIErrorsText:GetText():gsub("|c......",""):gsub("|r",""))
			ZO_UIErrors.edit:CopyAllTextToClipboard()
			d("|c88ffffError copied to clipboard.")
		end)
	.__END

	-- hidden edit box
	ZO_UIErrors.edit = CHAIN(wm:CreateControl("ZO_UIErrorsContainer_Edit",ZO_UIErrors,CT_EDITBOX))
		:SetMultiLine(true)
		:SetMaxInputChars(999999)
		:SetEditEnabled(false)
		:SetPasteEnabled(false)
		:SetCursorPosition(0)
		:SetHidden(true)
	.__END

end

EVENT_MANAGER:RegisterForEvent("Zgoo", EVENT_ADD_ON_LOADED, function(event,name)
	if name=="Zgoo" then
		Zgoo:Init()
	end
end)
