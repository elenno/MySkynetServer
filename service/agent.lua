local skynet = require "skynet"
local socket = require "skynet.socket"
local netpack = require "skynet.netpack"
local util = require "util"
local json = require "dkjson"
local sproto_loader = require "proto.sproto_loader"
local sproto_host
local sproto_packer
local log = require "utility.log"

local CMD = {}
local REQUEST = {}
local WATCHDOG
local gate
local client_fd
local player_id = 0  -- 未登录就是0，大于0代表登录了
local agent_handle

local function request(fd, proto, data, response)
	if REQUEST[proto] then
		REQUEST[proto](data)

	elseif player_id > 0 then
		-- 调用player_mgr
		local player_mgr = skynet.uniqueservice("player_mgr")
		if response then
			return skynet.call(player_mgr, "lua", "dispatch", agent_handle, fd, proto, data)
		else
			skynet.send(player_mgr, "lua", "dispatch", agent_handle, fd, proto, data)
		end
	else
		-- 调用login_mgr
		local login_mgr = skynet.uniqueservice("login_mgr")
		if response then
			return skynet.call(login_mgr, "lua", "dispatch", agent_handle, fd, proto, data)
		else
			skynet.send(login_mgr, "lua", "dispatch", agent_handle, fd, proto, data)
		end
	end
end

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.write(fd, package)
end

local function unpack_and_dispatch(msg, sz)
	-- 改用sproto
	local type, protoname, content, response, ud = sproto_host:dispatch(msg, sz)
	print("unpack_and_dispatch type={1},protoname={2},content={3}", type, protoname, content)
	--local json_str = skynet.tostring(msg, sz) -- 不要用netpack.tostring, 内部会把内存释放，而导致skynet coredump
	--local succ, package = pcall(json.decode, json_str)
	--if succ and package.proto and package.data then
	--	return true, package.proto, package.data
	--else
	--	return false, nil, nil
	--end

	return true, protoname, content, response, ud
end

function REQUEST.echo(data)
    send_package(client_fd, "[echo] " .. data.msg)
end

function REQUEST.handshake(data)
	send_package(client_fd, "[handshake] hello")
end

function REQUEST.set(data)
	local str = string.format("what:%s value:%s", data.what, data.value)
	send_package(client_fd, "[set] " .. str)

	local cacheservice = skynet.uniqueservice("cacheservice")
	local ok, err = skynet.call(cacheservice, "lua", "set", data.what, data.value)
	if not ok then
		skynet.error("REQUEST.set " .. str .. " FAILED FAILED FAILED, error=" .. err)
	end
	send_package(client_fd, "[set] succ")	
end

function REQUEST.get(data)
	local str = string.format("what :%s", data.what)
	send_package(client_fd, "[get] " .. str)

	local cacheservice = skynet.uniqueservice("cacheservice")
	local value = skynet.call(cacheservice, "lua", "get", data.what)
	str = string.format("%s=%s", data.what, value)
	send_package(client_fd, "[get] succ, " .. str)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		-- 在这里解包并返回给dispatch
        return unpack_and_dispatch(msg, sz)
	end,
	dispatch = function (fd, _, succ, proto, data, response, ud)
		assert(fd == client_fd)	-- You can use fd to reply message
		skynet.ignoreret()	-- session is fd, don't call skynet.ret
		--skynet.trace() -- 服务调用跟踪，可以暂时不需要
		log.debug("dispatch proto={1},data={2},response={3},ud={4}", proto, data, response, ud)
		if succ then
			local ok, resp = pcall(request, fd, proto, data, response)
			log.debug("dispatch proto={1},resp={2},response={3}", proto, resp, response)
			if not ok then
				--skynet.error("proto pcall failed, proto:" .. proto .. " data:" .. json.encode(data))
				log.error("dispatch call failed, fd={1},proto={2},data={3}", fd, proto, data)
			elseif resp and response then
				send_package(fd, response(resp, ud))
			else
				log.warn("no response for proto, fd={1},proto={2},data={3},resp={4}", fd, proto, data, resp)
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
	
	client_fd = fd
	agent_handle = skynet.self()
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.error("CMD.disconnect fd=" .. client_fd)
	skynet.exit()
end

function CMD.response_json(proto, data)
	-- {"proto":"xxx", "data":{some json data}}
	if not data then 
		data = {}
	end
    local json_table = {proto=proto, data=data}
	local str = json.encode(json_table)
	send_package(client_fd, str)
end

--TODO 后续一个agent管理n个client_fd,所以这里要传入fd
function CMD.send_request(fd, proto, data)
	local pack = sproto_packer(proto, data)
	log.debug("CMD.send_request proto={1},data={2},pack={3}", proto, data, pack)
	send_package(fd, pack)
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		--skynet.trace()
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
	sproto_host = sproto_loader:host("package")
	sproto_packer = sproto_host:attach(sproto_loader)
end)