
require "Common/define"
require "Common/protocal"
require "Common/functions"
Event = require 'events'
require "3rd/pblua/Cuser_pb"
require "3rd/pbc/protobuf"

local sproto = require "3rd/sproto/sproto"
local core = require "sproto.core"
local print_r = require "3rd/sproto/print_r"

Network = {};
local this = Network;

local transform;
local gameObject;
local islogging = false; 

function Network.Start() 
    logWarn("Network.Start!!");
    Event.AddListener(Protocal.Login, this.OnMessage); 
    Event.AddListener(Protocal.Send_Move, this.SetPostionOnMessage); 
    Event.AddListener(Protocal.Get_Playes, this.Get_PlayesOnMessage); 
    Event.AddListener(Protocal.Get_Moves, this.Get_MovesOnMessage); 
    Event.AddListener(Protocal.Send_Status, this.Send_StatusOnMessage); 
    Event.AddListener(Protocal.Get_Status, this.Get_StatusOnMessage); 
    Event.AddListener(Protocal.Connect, this.OnConnect); 
    Event.AddListener(Protocal.Exception, this.OnException); 
    Event.AddListener(Protocal.Disconnect, this.OnDisconnect); 
end

--Socket消息--
function Network.OnSocket(key, data)
    Event.Brocast(tostring(key), data);
end

--当连接建立时--
function Network.OnConnect() 
    logWarn("Game Server connected!!");
end

--异常断线--
function Network.OnException() 
    islogging = false; 
    NetManager:SendConnect();
   	logError("OnException------->>>>");
end

--连接中断，或者被踢掉--
function Network.OnDisconnect() 
    islogging = false; 
    logError("OnDisconnect------->>>>");
end

--登录返回--
function Network.OnMessage(buffer) 
    this.TestLoginPblua(buffer);
    logWarn('OnMessage-------->>>');
end
--PBLUA登录--
function Network.TestLoginPblua(buffer)
	local data = buffer:ReadTString();
    local msg = Cuser_pb.CUser();
    msg:ParseFromString(data);
    LogingCtrl.id = msg.id;
    LogingCtrl.username = msg.username;
    log('TestLoginPblua: protocal:>' ..' msg:>'..msg.id..msg.username..msg.password);
end
--获取用户信息--
function Network.Get_PlayesOnMessage(buffer)
	local data = buffer:ReadTString();
    local path = Util.DataPath.."lua/3rd/pbc/MoveDTO.pb";
    local addr = io.open(path, "rb")
    local buffer = addr:read "*a"
    addr:close()
    protobuf.register(buffer)
    local decode = protobuf.decode("msg.PlaysResult" , data)
    if decode ~=false then
        GameCtrl.playes = decode.playes;
    end
end
--获取用户位置--
function Network.Get_MovesOnMessage(buffer)
    local data = buffer:ReadTString();
    local path = Util.DataPath.."lua/3rd/pbc/MoveDTO.pb";
    local addr = io.open(path, "rb")
    local buffer = addr:read "*a"
    addr:close()
    protobuf.register(buffer)
    local decode = protobuf.decode("msg.MoveResult" , data)
    if decode ~=false then
        GameCtrl.moves = decode.moves;
    end
end

--获取用户状态--
function Network.Get_StatusOnMessage(buffer)
    local data = buffer:ReadTString();
    local path = Util.DataPath.."lua/3rd/pbc/StatusDTO.pb";
    local addr = io.open(path, "rb")
    local buffer = addr:read "*a"
    addr:close()
    protobuf.register(buffer)
    local decode = protobuf.decode("msg.StatusResult" , data)
    if decode ~=false then
        GameCtrl.status = decode.status;
    end
end
--发送用户状态--
function Network.Send_StatusOnMessage(buffer)
    local data = buffer:ReadTString(); 
end

 

--帧同步--
function Network.SetPostionOnMessage(buffer) 
    local data = buffer:ReadTString();
end


--卸载网络监听--
function Network.Unload()
    Event.RemoveListener(Protocal.Login);--Protocal.Message
    Event.RemoveListener(Protocal.Send_Move);--Protocal.Message
    Event.RemoveListener(Protocal.Get_Playes);--Protocal.Message
    Event.RemoveListener(Protocal.Get_Moves);--Protocal.Message
    Event.RemoveListener(Protocal.Send_Status);--Protocal.Message
    Event.RemoveListener(Protocal.Get_Status);--Protocal.Message
    Event.RemoveListener(Protocal.Connect);
    Event.RemoveListener(Protocal.Exception);
    Event.RemoveListener(Protocal.Disconnect);
    logWarn('Unload Network...');
end