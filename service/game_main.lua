local skynet = require "skynet"
local socket = require "skynet.socket"

local host = "0.0.0.0"  -- 监听所有网络接口
local port = 8888        -- 指定端口号

local function on_accept(client_fd, client_addr)
	skynet.error("new connection from client_addr:" .. client_addr .. " fd=" .. client_fd)
	
	local agent = skynet.newservice("agent")
	skynet.send(agent, "lua", "on_accept", client_fd, client_addr) -- 这里用send而不是call，否则agent调用skynet.exit()时会报错
end

skynet.start(function()
	skynet.error("[start game main] MyGameServer started!!!")
	
	local addr = host .. ":" .. port
	local listen_fd = socket.listen(host, port)
	skynet.error("listen for addr=" .. addr)

	socket.start(listen_fd, on_accept)
end)
