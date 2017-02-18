--LibExecutionQueue-1.0 allows you to queue up functions for execution and breakup long running operations fairly easily
-- See MasterMerchant for examples
-- Last Updated May, 2015 by @Philgo68 - Philgo68@gmail.com
-- License - Do whatever you want with this code.

local MAJOR, MINOR = "LibExecutionQueue-1.0", 1 -- remember to increase manually on changes
local LEQ = LibStub:NewLibrary(MAJOR, MINOR)
if not LEQ then return end

LEQ.Queue = LEQ.Queue or {}
LEQ.Paused = LEQ.Paused or true

function LEQ:Add(func, name)
  table.insert(self.Queue, 1, {func, name})  
end

function LEQ:ContinueWith(func, name)
  table.insert(self.Queue, {func, name})  
  self:Start()
end

function LEQ:Start()
  if self.Paused then
    self.Paused = false
    self:Next()
  end
end

function LEQ:Next() 
  if not self.Paused then
    local nextFunc = table.remove(self.Queue)
    if nextFunc then
      
      --DEBUG
      --local start = GetTimeStamp()
      
      nextFunc[1]()

      --DEBUG
      --if nextFunc[2] then
      --  d(nextFunc[2] .. ': ' .. GetTimeStamp() - start)
      --end
      
      zo_callLater(function() self:Next() end, 20) 
    else
      -- Queue empty so pausing
      self.Paused = true;
    end
  end
end

function LEQ:Pause()
  self.Paused = true
end


