
local adr = ActionDurationReminder
local tinsert = table.insert
adr.alert = {}
adr.alert.showList = {}

function adr.Alert(abilityName, abilityIcon)

	
	if adr.savedVars.alertPlaySound then PlaySound(SOUNDS[adr.soundChoices[adr.savedVars.alertSoundIndex]]) end
	
	if not adr.alertControlPool then
		adr.alertControlPool = ZO_ObjectPool:New(adr.alert.ControlFactory, adr.alert.ControlDispose)
	end
	local control,key = adr.alertControlPool:AcquireObject()
	control.label:SetFont(adr.UtilGetAlertFont())
	control.label:SetText(zo_strformat('<<C:1>>',abilityName))
	control.icon:SetTexture(abilityIcon)
	control:SetAnchor(BOTTOMLEFT, GuiRoot, CENTER, -150 + adr.savedVars.alertOffsetX, -150 + adr.savedVars.alertOffsetY)
	control:SetHidden(false)
	local showList = adr.alert.showList
	for k,v in pairs(showList) do
		local _, _, _, _, offsetX, offsetY = v:GetAnchor(0)
		v:ClearAnchors()
		v:SetAnchor(BOTTOMLEFT, GuiRoot, CENTER, offsetX, offsetY -adr.savedVars.alertIconSize-10)
	end
	showList.key = control
	zo_callLater(
		function()
			control:SetHidden(true)
			showList.key = nil
			adr.alertControlPool:ReleaseObject(key)
		end, 
		adr.savedVars.alertKeepSeconds*1000
	)
end


function adr.alert.ControlFactory(pool)

	local control = WINDOW_MANAGER:CreateTopLevelWindow()
	
	local icon = control:CreateControl(nil, CT_TEXTURE)
	icon:SetDrawLayer(DL_CONTROLS)
	icon:SetDimensions(adr.savedVars.alertIconSize,adr.savedVars.alertIconSize)
	icon:SetAnchor(LEFT)
	control.icon = icon
				
	local label = control:CreateControl(nil, CT_LABEL)
	label:SetFont("ZoFontGameMedium")
	label:SetColor(1,1,1)
	label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	label:SetAnchor(LEFT, icon, RIGHT, 10, 0)
	label:SetDrawLayer(DL_TEXT)
	control.label = label
	
	return control
end
 
function adr.alert.ControlDispose(control)
	control:SetHidden(true)
	control:ClearAnchors()
end
 
