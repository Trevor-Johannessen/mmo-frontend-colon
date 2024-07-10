local colon = require("/colon/colon")
-- TODO: Make ability for these paths to be reletive
local socket = require("/websites/mmo/api/socket")
local packet = require("/websites/mmo/api/packets")

function login()
    local id = colon.getObject{name="id"}.text.text
    colon.log("Setting id to " .. id)
    _G['player_id'] = id
    token = socket.connect(id)
    socket.login(token, setMapPage)
end

function setMapPage(args)
    if args['packet'].opcode == 4 then
        local status = colon.getObject{name="failedLogin"}
        status.hidden = false
        colon.redraw()
        return
    end
    -- local ascii = colon.getObject{page="map.txt", name="field"}
    -- ascii:set(string.rep("-", 32*8))
    colon.setCurrentPage("map.txt")
end

function inspectPlayer(args)
    local packet = inspectPlayerPacket(args.id)
    socket.sendPacket(packet)
end

function inputHandler()

end

return {
    login=login,
    setMapPage=setMapPage,
    inputHandler=inputHandler,
    inspectPlayer=inspectPlayer,
}