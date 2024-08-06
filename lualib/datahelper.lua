-- 用于获取数据  从cache服务和db服务获取数据
-- 只是一个接口

local skynet = require "skynet"

local CMD = {}

function CMD.query_data(key)
	-- 1. 获取cache数据
	-- 2. 如果cache有就返回，没有就获取db数据
	local cache = skynet.uniqueservice("cacheservice")
	local data = skynet.call(cache, "lua", "get", key)
	return data

	-- 第3,4步以后实现
	-- 3. 如果db都没有，返回nil
	-- 4. 如果db有，就写入缓存
end

function CMD.save_data(key, data)
	-- 1. 写入cache数据
	local cache = skynet.uniqueservice("cacheservice")
	skynet.send(cache, "lua", "set", key, data)

	-- 2. 写入db （用send，不用等待结果）

	-- data传入一个table
	-- 转成json字符串保存
end

return CMD