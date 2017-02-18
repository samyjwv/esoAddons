local Srendarr		= _G['Srendarr'] -- grab addon table from global
local LMP			= LibStub('LibMediaProvider-1.0')

-- UPVALUES --
local PlaySound			= PlaySound

local procAbilityNames	= Srendarr.procAbilityNames
local crystalFragments	= Srendarr.crystalFragments -- special case for tracking fragments proc

local slotData			= Srendarr.slotData
local procAnims			= {}
local animsEnabled, procSound


-- ------------------------
-- PROC HANDLING
-- ------------------------
function Srendarr:ProcAnimationStart(slot)
	if (animsEnabled and not procAnims[slot].isPlaying) then -- no need to start if already playing
		procAnims[slot].loopTexture:SetHidden(false)
		procAnims[slot].loop:PlayFromStart()
		procAnims[slot].isPlaying = true

		PlaySound(procSound)
	end
end

function Srendarr:ProcAnimationStop(slot)
	if (animsEnabled and procAnims[slot].isPlaying) then
		procAnims[slot].isPlaying = false
		procAnims[slot].loopTexture:SetHidden(true)
		procAnims[slot].loop:Stop()
	end
end

function Srendarr:OnCrystalFragmentsProc(onGain)
	if (onGain) then
		procAbilityNames[crystalFragments] = true

		for slot = 3, 7 do
			if (slotData[slot].abilityName == crystalFragments) then
				self:ProcAnimationStart(slot)
				break
			end
		end
	else
		procAbilityNames[crystalFragments] = false

		for slot = 3, 7  do
			if (slotData[slot].abilityName == crystalFragments) then
				self:ProcAnimationStop(slot)
				break
			end
		end
	end
end


-- ------------------------
-- PROC INIT & CONFIG
-- ------------------------
function Srendarr:ConfigureProcs()
	animsEnabled	= self.db.procEnableAnims
	procSound		= LMP:Fetch('sound', self.db.procPlaySound)

	if (not animsEnabled) then -- ensure animations are hidden if not using
		for slot = 3, 7 do
			procAnims[slot].loopTexture:SetHidden(true)
			procAnims[slot].loop:Stop()
		end
	end
end

function Srendarr:InitializeProcs()
	local button, ctrl

	for slot = 3, 7 do
		button			= ZO_ActionBar_GetButton(slot)
		procAnims[slot]	= {}

		ctrl = WINDOW_MANAGER:CreateControl(nil, button.slot, CT_TEXTURE)
		ctrl:SetAnchor(TOPLEFT, button.slot:GetNamedChild('FlipCard'))
		ctrl:SetAnchor(BOTTOMRIGHT, button.slot:GetNamedChild('FlipCard'))
		ctrl:SetTexture([[esoui/art/actionbar/abilityhighlight_mage_med.dds]])
		ctrl:SetBlendMode(TEX_BLEND_MODE_ADD)
		ctrl:SetDrawLevel(2)
		ctrl:SetHidden(true)

		procAnims[slot].loopTexture = ctrl

		procAnims[slot].loop = ANIMATION_MANAGER:CreateTimelineFromVirtual('UltimateReadyLoop', ctrl)
		procAnims[slot].loop:SetHandler('OnStop', function()
			procAnims[slot].loopTexture:SetHidden(true)
		end)
	end

	self:ConfigureProcs()
end
