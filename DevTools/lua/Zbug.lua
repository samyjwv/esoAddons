local tinsert,tremove,min,max,type = table.insert,table.remove,math.min,math.max,type

Zbug = {}
Zbug.errors = {}

--EVENT_MANAGER:RegisterForEvent("Zbug", EVENT_LUA_ERROR, Zbug.Grab)
local seenbugs={}

function Zbug:ColorizeError(err)
	err="\n"..err.."\n"
	err = err
	:gsub("\n%s*","\n")
	:gsub("\n!NO ERROR!","No errors captured. Yay!")
	:gsub("\nuser:/AddOns/","\n")
	:gsub("\nstack traceback:\n","\n|cffee00Stack:|r\n")

	:gsub("\n(EsoUI)([^\n]*/)([^/\n]-):(%d+): ","\n|c0077ff%1|c0000ff%2|c00aaff%3|r:|cffaa00%4|r: ")
	:gsub("\n([^/|\n]+)([^\n]*/)([^/\n]-):(%d+): ","\n|c00ff00%1|c00bb00%2|caaff00%3|r:|cffaa00%4|r: ")
	:gsub("\n%[C%]: ","\n|caa0000[internal]|r: ")
	:gsub("\n%[string \"(.-)\"]:(%d+): " , "\n|c00aa77string \"|c00ffaa%1|c00aa77\"|r:|cffaa00%2|r: ")
	:gsub("\n(%d+):(%d+): " , "\n|cff0000In XML #|cff5500%1|r:|cffaa00%2|r: ")

	:gsub(": in function '(%(main chunk%))'\n" , ": |cffee77%1|r\n")
	:gsub(": in function '([^\n]*)'\n" , ": function |cffee77%1|r\n")
	:gsub("\n%(tail call%): " , "\n|c66aa66(tail call):|r ")

	if err:match("^\n[^\n]+:|cffaa00%d+|r: ") then -- regular error
		err=err:gsub("^\n([^\n]*): (.-)\n","|cffee00Reason:|r %2\n|cffee00At:|r %1\n")
	elseif err:match("^\nLoad%[") then -- file load error
		err=err:gsub("^\nLoad%[([^\n]*)%((%d+), (%d+)%)%]: (.-)\n",function(file,row,col,err) return "|cffee00Failed to load:|r |caaff00"..file.."|r\n|cffee00Line:|r "..(tonumber(row)+1).."   |cffee00Char:|r "..(tonumber(col)+1).."   |cffee00Error:|r "..err.."\n" end)
	else -- assertion?
		err=err:gsub("^\n([^\n]*)\n","|cffee00Assertion failed:|r %1\n")
	end

	return err
end

function ZbugOnUIError(eventCode, errorString)
	local self=Zbug
	if seenbugs[errorString] then
		seenbugs[errorString]=seenbugs[errorString]+1
		for i=1,#self.errors do
			if self.errors[i].error==errorString then
				self.errors[i].date=GetTimeString()
				self.errors[i].ftime=GetFrameTimeSeconds()
				if not ZbugFrame:IsHidden() and self.errornum==i then  -- is currently shown!
					Zbug:ShowErrors()
				end
				return
			end
		end
	else
		seenbugs[errorString]=1
		tinsert(self.errors,{date=GetTimeString(),ftime=GetFrameTimeSeconds(),error=errorString})
		self:ShowErrors(#self.errors)
	end
end

function Zbug:ShowErrors(n)

	self.errornum = n or self.errornum or 1
	ZbugFrame:SetHidden(false)
	local err = self.errors[self.errornum] or {date="?",ftime=0,error="!NO ERROR!"}
	
	ZbugFrameTitle:SetText("ZBUG")
	ZbugFrameLabel:SetText("Lua Error")
	ZbugFrameTextEdit:SetText(err.error)
	ZbugFrameTextEdit:SetEditEnabled(false)
	ZbugFrameTextEdit:SelectAll()
	
	ZbugFrameLabel:SetText( ("|cffee00Error:|r %d / %d   |cffee00Time:|r %s   |cffee00Gametime:|r %.3f   |cffee00Count:|r %d\n%s"):format(
		self.errornum , #self.errors , err.date , err.ftime , seenbugs[err.error] or 0 , Zbug:ColorizeError(err.error)
	))
	
	ZbugFrame:SetHidden(false)
	SetGameCameraUIMode(true)

end

function Zbug:SkipError(delta)
	self.errornum = zo_max(1, zo_min(#self.errors, (self.errornum or 1) + delta))
	self:ShowErrors()
end

function Zbug.SlashCmd()
	Zbug:ShowErrors(#Zbug.errors)
end

EVENT_MANAGER:RegisterForEvent("Zbug_OnEvent", EVENT_LUA_ERROR, ZbugOnUIError)

-- squelch the default buggrabber
ZO_UIErrors_ToggleSupressDialog()

SLASH_COMMANDS["/zbug"] = Zbug.SlashCmd

-- Adorn the default buggrabber

local function createButton(name,parent)
	local but = CHAIN(wm:CreateControl(name,parent,CT_BUTTON))
		:SetDimensions(50,25)
		:SetFont("ZoFontGame")
	.__END

	but.bd = CHAIN(wm:CreateControl(name.."_BD",but,CT_BACKDROP))
		:SetCenterColor(255,0,0,1)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(but)
	.__END

	return but
end