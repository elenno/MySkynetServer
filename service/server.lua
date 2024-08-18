--[[
Author: elenno elenno.chen@gmail.com
Date: 2024-08-18 11:36:50
LastEditors: elenno elenno.chen@gmail.com
LastEditTime: 2024-08-18 11:37:13
FilePath: \MySkynetServer\service\server.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local skynet = require "skynet"
local server = {}
local log = require "utility.log"

function server.send_request(agent_handle, client_fd, proto, data)
    log.debug("server.send_request client_fd={1},proto={2},data={3}", client_fd, proto, data)
    skynet.send(agent_handle, "lua", "send_request", client_fd, proto, data)
end

return server

