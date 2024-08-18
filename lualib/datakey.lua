--[[
Author: elenno elenno.chen@gmail.com
Date: 2024-08-06 23:27:05
LastEditors: elenno elenno.chen@gmail.com
LastEditTime: 2024-08-18 11:42:17
FilePath: \MySkynetServer\lualib\datakey.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local skynet = require "skynet"
local server = require "server"
local CMD = {}
local log = require "utility.log"

-- 返回单服全局数据的key字符串拼接
local function global_key(key, server_id)
	local gkey = "g_" .. server_id .. "_" .. key
	return gkey
end

-- 返回单服玩家数据的key字符串拼接
local function player_key(key, player_id) -- player_id 全服唯一，所以不用server区分
	local pkey = "p_" .. player_id .. "_" .. key
	return pkey
end

-- 返回单服用户数据的key字符串拼接 (用户名可能不同服会有相同，所以要加server段)
local function user_key(key, server_id, username)
    local ukey = "u_" .. server_id .. "_" .. username .. "_" .. key
    return ukey
end

--TODO server_id 如何搞成全局变量？
function CMD.get_login_key(username)
    --TODO 解决server_id问题
    --log.debug("CMD.get_login_key server={1}", server)
    --local ukey = user_key("username", server.server_id, username)
    local ukey = user_key("username", 1, username)
    return ukey
end

function CMD.get_player_basic_data_key(player_id)
    local pkey = player_key("player", player_id)
    return pkey
end

function CMD.get_server_basic_data_key()
    local gkey = global_key("server", server.server_id)
    return gkey
end

return CMD