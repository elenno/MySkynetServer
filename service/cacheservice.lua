--[[
Author: elenno elenno.chen@gmail.com
Date: 2024-08-06 23:27:05
LastEditors: elenno elenno.chen@gmail.com
LastEditTime: 2024-08-18 12:36:07
FilePath: \MySkynetServer\service\cacheservice.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
-- 缓存服务

-- 角色登录时从缓存获取数据
-- 如果缓存没有，就从数据库中获取
-- 角色自己记录一份角色数据在内存中

local skynet = require "skynet"
local redis = require 'skynet.db.redis'
local log = require "utility.log"
local host
local port
local conn

local CMD = {}

function CMD.connect()
    conn = assert(redis.connect({host=host, port=port}))
end

function CMD.get(key)
    local response = conn:get(key)
    if not response then
        skynet.error("CMD.get key:" .. key .. " is nil")
    end
    return response
end

function CMD.set(key, value)
    local ok, err = conn:set(key, value)
    if not ok then
        skynet.error("CMD.set ERROR key:" .. key .. " value:" .. value .. "  error:" .. err)
    end
    return ok, err
end

function CMD.open(conf)
    host = conf.host
    port = conf.port
    conn = assert(redis.connect(conf))
    log.debug("CMD.open conf={1}", conf)
    return true
end

function CMD.test()
    conn:set("testdsadas", "world111")
    local resp = conn:get("testdsadas")
    skynet.error("CMD.test:" .. resp)
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, command, ...)
        skynet.error("cacheservice command:" .. command)
		--skynet.trace()
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)


