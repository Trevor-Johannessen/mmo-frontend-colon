local packet_id = 1
_G['unack_packets'] = {}

-- limiting this to 32 bit
function packet(opcode, length, body, callback, callback_args)
    local bitstr = string.char(opcode)
    for i=0,3,1 do
        bitstr = bitstr .. string.char(bit32.band(bit32.rshift(packet_id, i*8), 0xff))
    end
    for i=0,3,1 do
        bitstr = bitstr .. string.char(bit32.band(bit32.rshift(length, i*8), 0xff))
    end
    bitstr = bitstr .. body
    
    -- register and increment packet ID
    if callback then
        _G['unack_packets'][packet_id] = {callback, callback_args}
        packet_id = packet_id + 1    
    end
    
    return bitstr, packet_id
end

function parsePacket(bin)
    local packet = {}
    packet.opcode = string.byte(string.sub(bin, 1, 1))
    packet.id = 0
    packet.length = 0
    for i=5,2,-1 do
        packet.id = packet.id + bit32.rshift(string.byte(string.sub(bin, i,i)), 8*(i-2))
    end
    for i=9,6,-1 do
        packet.length = packet.length + bit32.rshift(string.byte(string.sub(bin, i,i)), 8*(i-6))
    end
    packet.data = string.sub(bin, 10)
    return packet
end

function login(token, setMapPage)
    return packet(1, #token, token, setMapPage, {})
end

function move(x, y)
    bitstr = ""
    for i=0,3,1 do
        bitstr = bitstr .. string.char(bit32.band(bit32.rshift(x, i*8), 0xff))
    end
    for i=0,3,1 do
        bitstr = bitstr .. string.char(bit32.band(bit32.rshift(y, i*8), 0xff))
    end
    return packet(5, #bitstr, bitstr)
end

function inspectPlayerPacket(id)
    return packet(8, #id, id)
end

function ntoh(str)
    local value = 0
    for i=0,3,1 do
        value = value + bit32.rshift(string.byte(string.sub(str, i+1, i+1)), i*8)
    end
    return value
end

function hton(str)
    return ntoh(str)
end

return{
    login=login,
    ntoh=ntoh,
    hton=hton,
    move=move
}
