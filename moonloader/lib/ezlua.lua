--[[
 Получение информации
 
 result = isPlayerInStream(id) -- Есть ли игрок в зоне стрима по его ID
 text, color, x, y, z, dist, isWalls, pId, vehId = find3dTextByText(text) -- Поиск 3D текста по его части
 dist = getDistById2d(id1, id2) -- узнаёт дистанцию между двумя игроками по id в 2д пространстве 
 dist = getDistById3d(id1, id2) -- узнаёт дистанцию между двумя игроками по id в 3д пространстве 
 dist = getDistByChar2d(char1, char2) -- узнаёт дистанцию между двумя игроками по хендлу в 2д пространстве 
 dist = getDistByChar3d(char1, char2) -- узнаёт дистанцию между двумя игроками по хендлу в 3д пространстве 
 
 set
 
 result = setAngleToCoord2d(x, y) -- Устанавливает угол поворота игрока к координатам X, Y
 result = setPlayerSkin(skinid) -- Устанавливает скин вашему игроку
 result = setSkinToChar(char, skinid) -- Устанавливает скин игроку по хендлу
 result = setSkinToPlayer(id, skinid) -- Устанавливает скин игроку по id
]]

local module = { } 

local function isPlayerInStream(id)
	local result = sampGetCharHandleBySampPlayerId(id)
	return result
end

local setAngleToCoord2d = function(x, y)
	if sampIsLocalPlayerSpawned() then
		local posX, posY, posZ = getCharCoordinates(playerPed)
		local pX = x - posX
		local pY = y - posY
		local zAngle = getHeadingFromVector2d(pX, pY)
		setCharHeading(playerPed, zAngle)
		return true
	else
		return false
	end
end

local function find3dTextByText(text)
	if text ~= nil then
		for i=0, 2048 do
			if sampIs3dTextDefined(i) then
				local txt, clr, x, y, z, dist, isWalls, pId, vehId = sampGet3dTextInfoById(i)
				if txt:find(text) then
					return txt, clr, x, y, z, dist, isWalls, pId, vehId
				end
			end
		end
	end
end

local function getDistById3d(id1, id2)
	local res1, char1 = sampGetCharHandleBySampPlayerId(id1)
	local res2, char2 = sampGetCharHandleBySampPlayerId(id2)
	if res1 and res2 then
		local x1, y1, z1 = getCharCoordinates(char1)
		local x2, y2, z2 = getCharCoordinates(char2)
		local dist = getDistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2)
		return dist
	else
		return false
	end
end

local function getDistByChar3d(char1, char2)
	local x1, y1, z1 = getCharCoordinates(char1)
	local x2, y2, z2 = getCharCoordinates(char2)
	local dist = getDistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2)
	return dist
end

local function getDistById2d(id1, id2)
	local res1, char1 = sampGetCharHandleBySampPlayerId(id1)
	local res2, char2 = sampGetCharHandleBySampPlayerId(id2)
	if res1 and res2 then
		local x1, y1, z1 = getCharCoordinates(char1)
		local x2, y2, z2 = getCharCoordinates(char2)
		local dist = getDistanceBetweenCoords2d(x1, y1, x2, y2)
		return dist
	else
		return false
	end
end

local function getDistByChar2d(char1, char2)
	local x1, y1, z1 = getCharCoordinates(char1)
	local x2, y2, z2 = getCharCoordinates(char2)
	local dist = getDistanceBetweenCoords2d(x1, y1, x2, y2)
	return dist
end

local function setPlayerSkin(skinid) 
if skinid ~= nil then
	local new1 = raknetNewBitStream()
	local _, id = sampGetPlayerIdByCharHandle(playerPed)
	raknetBitStreamWriteInt32(new1, id)
	raknetBitStreamWriteInt32(new1, skinid)
	raknetEmulRpcReceiveBitStream(153, new1)
	raknetDeleteBitStream(new1)
	return true
end
end

local function setSkinToPlayer(id, skinid) 
if id ~= nil and skinid ~= nil then
	local res, id = sampGetCharHandleBySampPlayerId(id)
	if res then
		local new1 = raknetNewBitStream()
		raknetBitStreamWriteInt32(new1, id)
		raknetBitStreamWriteInt32(new1, skinid)
		raknetEmulRpcReceiveBitStream(153, new1)
		raknetDeleteBitStream(new1)
		return true
	else
		return false
	end
end
end

local function setSkinToChar(chared, skinid) 
if chared ~= nil and skinid ~= nil then
	local res, id = sampGetPlayerIdByCharHandle(chared)
	if res then
		local new1 = raknetNewBitStream()
		raknetBitStreamWriteInt32(new1, id)
		raknetBitStreamWriteInt32(new1, skinid)
		raknetEmulRpcReceiveBitStream(153, new1)
		raknetDeleteBitStream(new1)
		return true
	else
		return false
	end
end
end

local reconnect = function()
	local ip, port = sampGetCurrentServerAddress()
	sampDisconnectWithReason(true)
	sampConnectToServer(ip, port)
end