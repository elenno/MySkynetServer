local skynet = require "skynet"
local socket = require "skynet.socket"
local util = require "util"
local game_def = require "game_def"

local CMD = {}
local REQUEST = {}
local _client_fd
local _client_addr

function CMD.on_accept(client_fd, client_addr)
    _client_fd = client_fd
    _client_addr = client_addr
    socket.start(client_fd)
	while true do
		local msg, err = socket.read(client_fd)
		if not msg then
			skynet.error("read error from client_addr:" .. client_addr .. " fd=" .. client_fd)
			break
		else
			skynet.error("read SUCC from client_addr:" .. client_addr .. " fd=" .. client_fd .. " msg=" .. msg)
            local proto = util.split(msg, " ")
            if #proto ~= 2 then
                socket.write(client_fd, "proto wrong, fotmat is [TYPE + ' ' + MSG]")
                skynet.error("proto wrong, fotmat is [TYPE + ' ' + MSG], from client_addr:" .. client_addr .. " fd=" .. client_fd)
                break
            else
                local type = proto[1]
                skynet.call(skynet.self(), "request", type, proto[2])
            end
		end
	end
	skynet.error("end of reading, disconnect client_addr:" .. client_addr .. " fd=" .. client_fd)
	socket.close(client_fd)

    -- 目前是一个玩家一个agent，所以关闭连接后就要关闭服务
    skynet.exit() -- 如果on_accept调用是用call的话吗，这里直接exit()会报错
end

function REQUEST.echo(msg)
    socket.write(_client_fd, "[echo] " .. msg)
end

skynet.register_protocol {
    name = "request",
    id = game_def.ID_REQUEST,
    pack = skynet.pack,
    unpack = skynet.unpack,
}

skynet.start (function ()
	skynet.dispatch ("lua", function (_, _, command, ...)
        skynet.error("agent dispatch command=" .. command)
		local f = assert (CMD[command])
		skynet.retpack (f (...))
    end)
    skynet.dispatch("request", function(_, _, command, ...)
        skynet.error("agent dispatch request=" .. command)
        local f = assert(REQUEST[command])
        skynet.retpack(f(...))
    end)
end)