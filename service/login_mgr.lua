-- 登录服务
local skynet = require "skynet"
local json = require "dkjson"
local datahelper = require "datahelper"
local datakey = require "datakey"
local PROTO = require "proto"
local log = require "utility.log" 
local ErrCode = require "lualib.errorcode"
local server = require "server"
--TODO 把log做成不需要require都可以使用的 
--（考虑一个统一的require,例如require server)

local REQUEST = {}
local CMD = {}

local function send_json_response(client_fd, proto, data)
	skynet.send(client_fd, "lua", "response_json", proto, data)
end

function REQUEST.login(client_fd, data)
    local ukey = datakey.get_login_key(data.username)
    local userdata = datahelper.query_data(ukey)
	if not userdata then
		--返回登录失败错误码,需要注册
		send_json_response(client_fd, PROTO.ERROR, {errmsg="not register"})
		return
	end

	--返回玩家信息
	local pkey = datakey.get_player_basic_data_key(userdata.player_id)
	local player_data = datahelper.query_data(pkey)
	if not player_data then
		--没有主角数据，必定错误
		send_json_response(client_fd, PROTO.ERROR, {errmsg="no player data"})
		return
	end

	--返回登录成功
	send_json_response(client_fd, PROTO.LOGIN_RESP, {})

	--返回主角数据
	local resp = {
		player_id = player_data.player_id,
		player_name = player_data.player_name,
		level = player_data.level
	}
	send_json_response(client_fd, "player_data", resp)
end

function REQUEST.register(client_fd, data)
	local ukey = datakey.get_login_key(data.username)
    local userdata = datahelper.query_data(ukey)
	if userdata then
		--已经有数据，就不用注册了
		send_json_response(client_fd, PROTO.ERROR, {errmsg="already register"})
		return
	end

	userdata = {}
	userdata.username = data.username
	userdata.register_timestamp = os.time()
	datahelper.save_data(ukey, userdata)

	local gkey = datakey.get_server_basic_data_key()
	local server_data = datahelper.query_data(gkey)

	--顺便创角 可以优化为统一在player_mgr做
	local player_data = {}
	local player_mgr = skynet.uniqueservice("player_mgr")
	player_data.player_id = skynet.call(player_mgr, "lua", "generate_player_id")
	player_data.nickname = skynet.call(player_mgr, "lua", "generate_player_name")
	player_data.level = 1
	local pkey = datakey.get_player_basic_data_key(player_data.player_id)
	datahelper.save_data(pkey, player_data)

	send_json_response(client_fd, PROTO.PLAYER_DATA_RESP, player_data)
end

function REQUEST.cs_login(agent_handle, client_fd, data)
	log.debug("REQUEST.cs_login client_fd={1},data={2}", 
		client_fd, data)

	server.send_request(agent_handle, client_fd, "sc_tip_msg", {
		msg = "test123"
	})

	local ukey = datakey.get_login_key(data.username)
	local userdata = datahelper.query_data(ukey)
	if not userdata then
		--返回登录失败错误码,需要注册
		return {errCode = ErrCode.NOT_REGISTER_YET}
	end

	--返回玩家信息
	local pkey = datakey.get_player_basic_data_key(userdata.player_id)
	local player_data = datahelper.query_data(pkey)
	if not player_data then
		--没有主角数据，必定错误
		return {errCode = ErrCode.NOT_CREATE_PLAYER_YET}
	end

	--TODO 推送主角数据
	local resp = {
		player_id = player_data.player_id,
		player_name = player_data.nickname,
		level = player_data.level
	}
	
	--返回登录成功
	return {errCode = ErrCode.SUCCESS}
end

function CMD.dispatch(agent_handle, client_fd, proto, data)
	if not REQUEST[proto] then
		log.error("login_mgr CMD.dispatch proto not found,  proto=" .. proto)
		return
	end
	return REQUEST[proto](agent_handle, client_fd, data)
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		--skynet.trace()
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)