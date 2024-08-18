--[[
Author: elenno elenno.chen@gmail.com
Date: 2024-08-06 23:27:05
LastEditors: elenno elenno.chen@gmail.com
LastEditTime: 2024-08-14 00:48:08
FilePath: \MySkynetServer\service\game_main.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local skynet = require "skynet"
local socket = require "skynet.socket"
local Conf = require "conf.game_conf"
local server = require "server"
local SprotoLoader = require "proto.sproto_loader"
local log = require "utility.log"

skynet.start(function()
	skynet.error("[start game main] MyGameServer started!!!")
	
	local watchdog = skynet.newservice("watchdog")

	server.server_id = Conf.server_id
	log.debug("game main server_id={1},server={2}", server.server_id, server)

	local conf = {}
	conf.port = Conf.port
	conf.address = Conf.host
	skynet.call(watchdog, "lua", "start", conf)

	local redisconf = {}
	redisconf.host = Conf.redis_host
	redisconf.port = Conf.redis_port
	local cache = skynet.uniqueservice("cacheservice")
	skynet.call(cache, "lua", "open", redisconf)
	--skynet.call(cache, "lua", "test")

	skynet.uniqueservice("login_mgr")
	skynet.uniqueservice("player_mgr")
end)
