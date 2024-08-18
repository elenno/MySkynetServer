--[[
Author: elenno elenno.chen@gmail.com
Date: 2024-08-14 00:39:52
LastEditors: elenno elenno.chen@gmail.com
LastEditTime: 2024-08-14 00:40:12
FilePath: \MySkynetServer\proto\sproto_loader.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local sprotoparser = require "sprotoparser"
local sprotoloader = require "sprotoloader"
local sproto = require "sproto"
local sprotocore = require "sproto.core"
local Util = require "utility.util"

local function LoadProto()
    local file = assert(io.open("proto/spb/proto.spb", "r"))
    local sproto_content = file:read("*a")
    file:close()

    sprotoloader.save(sproto_content, 1)
    local proto = sprotoloader.load(1)

    --输出所有协议
    sprotocore.dumpproto(proto.__cobj)
end

local ok, proto = pcall(sprotoloader.load, 1)
if not ok then
    LoadProto()
    proto = sprotoloader.load(1)
end

return proto