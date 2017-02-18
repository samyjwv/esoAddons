
CraftStoreFixedAndImprovedLongClassName = {}

local CS = CraftStoreFixedAndImprovedLongClassName

function CS.SplitLink(link,nr)
  local split = {SplitString(':', link)}
  if split[nr] then return tonumber(split[nr]) else return false end
end

function CS.SetLinkValue(link,nr,value)
  local split = {SplitString(':', link)}
  if split[nr+2] then 
    split[nr+2] = value
  end
  return table.concat(split, ":")
end

function CS.ToChat(message)
  local chat = CHAT_SYSTEM.textEntry:GetText()
  StartChatInput(chat..message)
end

function CS.TravelToNode(control,node)
  if control.data then if control.data.travel then FastTravelToNode(CS.Sets[control.data.set].nodes[node]) end end
end

function CS.Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

function CS.StripLink(link)
  if CanItemLinkBeVirtual(link) then return CS.NakedLink(link) end
  
  local split = {SplitString(':', link)}  
  --Highlight
  if split[1] then 
    split[1] = "|H0"
  end
  --Crafted
  if split[19] then 
    split[19] = 0
  end
  --Bound
  if split[20] then 
    split[20] = 0
  end
  --Stolen
  if split[21] then 
    split[21] = 0
  end
  --Durability
  if split[22] then 
    split[22] = "0"
  end
  return table.concat(split, ":")
end

function CS.NakedLink(link)
  local split = {SplitString(':', link)} 
  return  "|H0:item:"..split[3]..":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
end

function CS.UpdateMatsInfo(link)
  local itemType = GetItemLinkItemType(link)
  if CS.RawItemTypes[itemType] and not CS.Account.materials[link] then
    local refinedLink = CS.NakedLink(GetItemLinkRefinedMaterialItemLink(link,0))
    CS.Account.materials[link] = {raw=true,link=refinedLink}
    CS.Account.materials[refinedLink] = {raw=false,link=link}
  end
end

function CS.Switch(t)
  t.case = function (self,x)
    local f=self[x] or self.default
    if f then
      if type(f)=="function" then
        f(x,self)
      else
        error("case "..tostring(x).." not a function")
      end
    end
  end
  return t
end
