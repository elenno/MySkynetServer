--[[
Author: elenno elenno.chen@gmail.com
Date: 2024-08-06 23:27:05
LastEditors: elenno elenno.chen@gmail.com
LastEditTime: 2024-08-18 13:13:24
FilePath: \MySkynetServer\service\player_mgr.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
-- player的管理器

local skynet = require "skynet"

local CMD = {}
local player_agent = {} -- 分发请求给多个agent去处理
local PLAYER_AGENT_NUM = 4
local pagent_idx = 1 

local function inc_pagent_idx()
    pagent_idx = pagent_idx + 1
    if pagent_idx >= PLAYER_AGENT_NUM then
        pagent_idx = 1
    end
end

function CMD.generate_player_id()
    --TODO
end

function CMD.generate_player_name()
    --TODO
end

function CMD.on_player_login(agent_handle, client_fd, player_id)
    --TODO

end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, command, ...)
		--skynet.trace()
        if command == "dispatch" then
            skynet.redirect(player_agent[pagent_idx], source, "lua", command, ...)
            inc_pagent_idx()
        else
            local f = CMD[command]
		    skynet.ret(skynet.pack(f(...)))
        end	
	end)

    for i = 1, PLAYER_AGENT_NUM do  --TODO 按线程数分配
        player_agent[i] = skynet.newservice("player_agent")
    end
end)