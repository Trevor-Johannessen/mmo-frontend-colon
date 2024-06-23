local colon = require("/colon/colon")
-- TODO: Make ability for these paths to be reletive
local socket = require("/websites/mmo/api/socket")

function login()
    local id = colon.getObject{name="id"}.text.text
    _G['player_id'] = id
    token = socket.connect(id)
    socket.login(token, setMapPage)
end

function setMapPage()
    local ascii = colon.getObject{page="map.txt", name="field"}
    ascii:set(string.rep("-", 32*8))
    colon.setCurrentPage("map.txt")
end

function inputHandler()

end

return {
    login=login,
    setMapPage=setMapPage,
    inputHandler=inputHandler
}