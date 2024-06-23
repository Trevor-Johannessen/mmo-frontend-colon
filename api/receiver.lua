local colon = require("/colon/colon")
local socket = require("/websites/mmo/api/socket")
local packet = require("/websites/mmo/api/packets")

local keys = {
    UP=265,
    LEFT=263,
    DOWN=264,
    RIGHT=262
}
local opcodes = {
    MOVE=6
}
local players = {}

function receive(args)
    if args['event'] == "key" or args['event'] == 'char' then
        handleKey(args['event_id'])
    elseif args['event'] == "websocket_message" then
        handlePacket(args)
    end
end


function handleKey(key)
    if not players[_G['player_id']] then return end
    local direction
    local x = players[_G['player_id']].x-1
    local y = players[_G['player_id']].y-2
    if key == keys.UP or key == 'w' then
        y=y-1
    elseif key == keys.DOWN or key == 's' then
        y=y+1
    elseif key == keys.LEFT or key == 'a' then
        x=x-1
    elseif key == keys.RIGHT or key == 'd' then
        x=x+1
    end
    colon.log("x="..x..", y="..y)
    p = packet.move(x, y)
    _G['ws'].send(p, true)
end

function handleMove(p)
    local x = packet.ntoh(string.sub(p.data, 1, 4))
    local y = packet.ntoh(string.sub(p.data, 5, 8))
    local id = string.sub(p.data, 9)
    local player_obj
    if players[id] then
        players[id].x = x+1
        players[id].y = y+2
    else
        local icon_text = "o"
        if id == _G['player_id'] then icon_text = "0" end
        players[id] = colon.getObjectTypes().button.create{name="button_" .. id,x=x,y=y+1,width=1,height=1,useTemplate="true",sprite="white",background="white", hoverBackground="white", hoverSprite="white",text=icon_text}
        colon.addObject{page="map.txt", object=players[id]}
    end
    colon.redraw()
end

function handlePacket(args)
    local packet = parsePacket(args['mouse_x']) -- I really need to change these arg names
    colon.log("Packet> Id: " .. packet.id .. " Op: " .. packet.opcode .. " L: " .. packet.length .. " Data: " .. packet.data)
    if _G['unack_packets'][packet.id] then
        local func = _G['unack_packets'][packet.id][1]
        local args = _G['unack_packets'][packet.id][2]
        func(args)
        table.remove(_G['unack_packets'], packet_id)
    end
    if packet.opcode == opcodes.MOVE then
        handleMove(packet)
    end
end

return {
    receive=receive
}