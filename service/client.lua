local skynet = require "skynet"
local socket = require "skynet.socket"
local sproto_loader = require "proto.sproto_loader"
local util = require "utility.util"
local log = require "utility.log"
local sproto_host
local sproto_packer

local host = "127.0.0.1"  -- 监听所有网络接口
local port = 8888        -- 指定端口号
local fd

local json = require("dkjson")
local request_hash = {}

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.write(fd, package)
end

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last)
	local result
	result, last = unpack_package(last)
	if result then
		return result, last
	end
	local r = socket.read(fd)
	if not r then
		return nil, last
	end
	if r == "" then
		log.error("Server closed")
	end
	return unpack_package(last .. r)
end

local function send_json_request(proto, data)
    -- {"proto":"xxx", "data":{some json data}}
	if not data then 
		data = {}
	end
    local json_table = {proto=proto, data=data}
	local str = json.encode(json_table)
	send_package(fd, str)
	print("Request:" .. str)
end

local session_generator
local function gen_session_id()
	session_generator = (session_generator or 0) + 1
	return session_generator
end

local function send_request(proto, data, session, ud)
	local session = gen_session_id()
	local ud = math.random(1, 100)
	request_hash[session] = {
		proto = proto,
		data = data,
		session = session,
		ud = ud,
	}
	local pack = sproto_packer(proto, data, session, ud)
	log.debug("send_request proto={1},data={2},session={3}", 
		proto, data, session)
	send_package(fd, pack)
end

local last = ""

local function print_request(name, args)
	print("REQUEST", name)
	if args then
		for k,v in pairs(args) do
			print(k,v)
		end
	end
end

local function print_response(session, args)
	print("RESPONSE", session)
	if args then
		for k,v in pairs(args) do
			print(k,v)
		end
	end
end

local function print_package(t, ...)
	if t == "REQUEST" then
		print_request(...)
	else
		assert(t == "RESPONSE")
		print_response(...)
	end
end

local function dispatch_package()
	while true do
		local v
		v, last = recv_package(last)
		if not v then
			break
		end

		print_package(sproto_host:dispatch(v))
	end
end

local function request_login()
	local data = {
		username = "robot"
	}
	send_request("cs_login", data)
end

local function handle_client()
    --send_json_request("handshake")
    --send_json_request("set", {what="hello", value="world"})
    --send_json_request("get", { what = "hello"})
	request_login()
    while true do
        dispatch_package()
        local cmd = socket.readstdin()
        if cmd then
			log.debug("handle_client cmd={1}", cmd)
            if cmd == "quit" then
                --send_json_request("quit")
            else
                --send_json_request("get", { what = cmd })
            end
        else
            socket.usleep(100)
        end
    end
end

skynet.start(function()
	log.debug("[start client] client started!!!")
	sproto_host = sproto_loader:host("package")
	sproto_packer = sproto_host:attach(sproto_loader)
	fd = socket.open(host, port)
    if fd then
        skynet.error("Connect to server:" .. host .. ":" .. port .. " SUCC SUCC SUCC")
        skynet.fork(handle_client)
    else
        skynet.error("Connect to server:" .. host .. ":" .. port .. " FAILED! abort")
        skynet.exit()
    end
end)