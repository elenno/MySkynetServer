-- 实际处理玩家请求的agent

local skynet = require("skynet")
local CMD = {}
local REQUEST = {}


function CMD.dispatch(client_fd, proto, data)
	if not REQUEST[proto] then
		skynet.error("login_mgr CMD.dispatch proto not found,  proto=" .. proto)
		return
	end
	REQUEST[proto](client_fd, data)
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		--skynet.trace()
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)