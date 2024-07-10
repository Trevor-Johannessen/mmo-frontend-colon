-- TODO: Make ability for these paths to be reletive
local globals = require("/websites/mmo/api/init")
local packet = require("/websites/mmo/api/packets")
_G['ws'] = {}

--[[
    This handles the authentication and connection to the auth server, and main server's websocket. 
]]

function connect(id)
    local res = http.post(globals['auth_url'] .. "/unsafe/authenticate?account_id=" .. id, "")
    if not res or res.getResponseCode() ~= 200 then
        error("Error: Authentication failed.")
    end
    colon.log("Setting id to " .. id)
    _G['player_id'] = id
    token = string.sub(res.readAll(), 2, -2)
    _G['ws'] = http.websocket(globals['base_url'])

    return token
end

function login(token, setMapPage)
    local msg
    local p = packet.login(token, setMapPage)
    _G['ws'].send(p, true)
end

function sendPacket(p)
    _G['ws'].send(p, true)
end

return{
    connect=connect,
    login=login,
    sendPacket=sendPacket,
}