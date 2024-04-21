local skynet = require "skynet"
local socket = require "skynet.socket"
local netpack = require "skynet.netpack"
local util = require "util"
local json = require "dkjson"

local CMD = {}
local REQUEST = {}
local WATCHDOG
local gate
local client_fd

local function request(proto, data)
	local f = assert(REQUEST[proto])
	f(data)
end

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

local function unpack_and_dispatch(msg, sz)
	-- 包的格式是 {"proto":"xxx", "data":{some json}}

	local json_str = skynet.tostring(msg, sz) -- 不要用netpack.tostring, 内部会把内存释放，而导致skynet coredump
	local succ, package = pcall(json.decode, json_str)
	if succ and package.proto and package.data then
		return true, package.proto, package.data
	else
		return false, nil, nil
	end
end

function REQUEST.echo(data)
    send_package("[echo] " .. data.msg)
end

function REQUEST.handshake(data)
	send_package("[handshake] hello")
end

function REQUEST.set(data)
	local str = string.format("what:%s value:%s", data.what, data.value)
	send_package("[set] " .. str)

	local cacheservice = skynet.uniqueservice("cacheservice")
	local ok, err = skynet.call(cacheservice, "lua", "set", data.what, data.value)
	if not ok then
		skynet.error("REQUEST.set " .. str .. " FAILED FAILED FAILED, error=" .. err)
	end
	send_package("[set] succ")	
end

function REQUEST.get(data)
	local str = string.format("what :%s", data.what)
	send_package("[get] " .. str)

	local cacheservice = skynet.uniqueservice("cacheservice")
	local value = skynet.call(cacheservice, "lua", "get", data.what)
	str = string.format("%s=%s", data.what, value)
	send_package("[get] succ, " .. str)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
        --暂时不使用sproto, 直接使用json
		--return host:dispatch(msg, sz)

        return unpack_and_dispatch(msg, sz)
	end,
	dispatch = function (fd, _, succ, proto, data)
		assert(fd == client_fd)	-- You can use fd to reply message
		skynet.ignoreret()	-- session is fd, don't call skynet.ret
		--skynet.trace() -- 服务调用跟踪，可以暂时不需要
		if succ then
			local ok = pcall(request, proto, data)
			if not ok then
				skynet.error("proto pcall failed, proto:" .. proto .. " data:" .. json.encode(data))
			end
		else
			skynet.error("proto unpack failed! disconnect!")
			skynet.call(WATCHDOG, "lua", "close", client_fd)
		end		
	end
}

function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	-- slot 1,2 set at main.lua

    -- 先不考虑用sproto
	--host = sprotoloader.load(1):host "package"
	--send_request = host:attach(sprotoloader.load(2))
	--skynet.fork(function()
	--	while true do
	--		send_package(send_request "heartbeat")
	--		skynet.sleep(500)
	--	end
	--end)

	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.error("CMD.disconnect fd=" .. client_fd)
	skynet.exit()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		--skynet.trace()
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)