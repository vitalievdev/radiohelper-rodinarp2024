local sampev = require 'lib.samp.events'

local azq = false
local typeRun = 0

function main()
sampRegisterChatCommand("az_q2", function() azq = not azq end)
while true do
wait(0)
if azq then
	if typeRun == 1 then
		
	end
end
end
end

function sampev.onApplyPlayerAnimation(playerId, animLib, animName, loop, lockX, lockY, freeze, time)
print("animLib "..animLib.." animName "..animName)
end

function sampev.onShowTextDraw(id, data)
if data.modelId ~= 0 then
print(data.modelId)
end
end