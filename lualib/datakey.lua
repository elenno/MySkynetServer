local skynet = require("skynet")
local CMD = {}


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
    local ukey = user_key("username", server_id, username)
    return ukey
end

function CMD.get_player_basic_data_key(player_id)
    local pkey = player_key("player", player_id)
    return pkey
end

function CMD.get_server_basic_data_key()
    local gkey = global_key("server", server_id)
    return gkey
end

return CMD