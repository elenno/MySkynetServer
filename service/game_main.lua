local skynet = require "skynet"
local socket = require "skynet.socket"

local host = "0.0.0.0"  -- 监听所有网络接口
local port = 8888        -- 指定端口号
local watchdog

skynet.start(function()
	skynet.error("[start game main] MyGameServer started!!!")
	
	watchdog = skynet.newservice("watchdog")

	local conf = {}
	conf.port = port
	conf.address = host
	skynet.call(watchdog, "lua", "start", conf)
end)
