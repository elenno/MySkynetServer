local skynet = require "skynet"
local socket = require "skynet.socket"

local host = "0.0.0.0"  -- 监听所有网络接口
local port = 8888        -- 指定端口号
local redis_host = "127.0.0.1"
local redis_port = 6379
local watchdog

server_id = 1

skynet.start(function()
	skynet.error("[start game main] MyGameServer started!!!")
	
	watchdog = skynet.newservice("watchdog")

	--TODO 通过配置文件读入port host server_id等

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

	skynet.uniqueservice("login_mgr")
	skynet.uniqueservice("player_mgr")
end)
