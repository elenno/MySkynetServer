local skynet = require "skynet"
local socket = require "skynet.socket"

local host = "0.0.0.0"  -- 监听所有网络接口
local port = 8888        -- 指定端口号
local redis_host = "127.0.0.1"
local redis_port = 6379
local watchdog

skynet.start(function()
	skynet.error("[start game main] MyGameServer started!!!")
	
	watchdog = skynet.newservice("watchdog")

	local conf = {}
	conf.port = port
	conf.address = host
	skynet.call(watchdog, "lua", "start", conf)

	local redisconf = {}
	redisconf.host = redis_host
	redisconf.port = redis_port
	local cache = skynet.uniqueservice("cacheservice")
	skynet.call(cache, "lua", "open", redisconf)
	--skynet.call(cache, "lua", "test")
end)
