--[[
Author: elenno elenno.chen@gmail.com
Date: 2024-08-17 17:58:11
LastEditors: elenno elenno.chen@gmail.com
LastEditTime: 2024-08-17 21:31:01
FilePath: \MySkynetServer\utility\log.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local skynet = require "skynet"
local util = require "utility.util"

local log = {}
local _DEBUG = true --TODO 读取启动配置或配置文件

local function gsub(msg, ...)
    local args = { ... }
    local formatted_msg = msg:gsub("{(%d+)}", function(n)
        return util.inspect(args[tonumber(n)])
    end)
    return formatted_msg
end

function log.debug(msg, ...)
    if _DEBUG then
        local callerInfo = debug.getinfo(2, "Sl")
        local caller = callerInfo.short_src .. ":" .. callerInfo.currentline
        local fullmsg = caller .. " " .. gsub(msg, ...) 
        skynet.error("[DEBUG]", fullmsg)
    end
end

function log.info(msg, ...)
    local callerInfo = debug.getinfo(2, "Sl")
    local caller = callerInfo.short_src .. ":" .. callerInfo.currentline
    local fullmsg = caller .. " " .. gsub(msg, ...) 
    skynet.error("[INFO]", fullmsg)
end

function log.warn(msg, ...)
    local callerInfo = debug.getinfo(2, "Sl")
    local caller = callerInfo.short_src .. ":" .. callerInfo.currentline
    local traceback = debug.traceback("", 2)
    local fullmsg = caller .. " " .. gsub(msg, ...) .. traceback
    skynet.error("[WARN]", fullmsg)
end

function log.error(msg, ...)
    local callerInfo = debug.getinfo(2, "Sl")
    local caller = callerInfo.short_src .. ":" .. callerInfo.currentline
    local traceback = debug.traceback("", 2)
    local fullmsg = caller .. " " .. gsub(msg, ...) .. "\nTraceBack=\n" .. traceback
    skynet.error("[ERROR]", fullmsg)
end

return log
