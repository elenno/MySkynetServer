local skynet = require "skynet"
local socket = require "skynet.socket"

local host = "0.0.0.0"  -- 监听所有网络接口
local port = 8888        -- 指定端口号

local function on_accept(client_fd, client_addr)
	skynet.error("new connection from client_addr:" .. client_addr .. " fd=" .. client_fd)
	
	socket.start(client_fd)
	while true do
		local msg, err = socket.read(client_fd)
		if not msg then
			skynet.error("read error from client_addr:" .. client_addr .. " fd=" .. client_fd)
			break
		else
			skynet.error("read SUCC from client_addr:" .. client_addr .. " fd=" .. client_fd .. " msg=" .. msg)
			socket.write(client_fd, "echo back: " .. msg)
		end
	end
	skynet.error("end of reading, disconnect client_addr:" .. client_addr .. " fd=" .. client_fd)
	socket.close(client_fd)
end

skynet.start(function()
	skynet.error("[start game main] MyGameServer started!!!")
	
	local addr = host .. ":" .. port
	local listen_fd = socket.listen(host, port)
	skynet.error("listen for addr=" .. addr)

	socket.start(listen_fd, on_accept)
end)
