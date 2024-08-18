--[[
Author: elenno elenno.chen@gmail.com
Date: 2024-08-06 23:27:05
LastEditors: elenno elenno.chen@gmail.com
LastEditTime: 2024-08-14 00:59:23
FilePath: \MySkynetServer\utility\util.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local inspect = require "lualib.inspect"
local Util = {}

function Util.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    
    return t
end

function Util.print(x)
    print(inspect(x))
end

function Util.inspect(x)
    return inspect(x, {
        newline = "",
        indent = "",
    })
end

return Util