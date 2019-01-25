require "Common/define"
require "FairyGUI"
require "3rd/pbc/protobuf"
require "Controller/FirstPersonController"
local sproto = require "3rd/sproto/sproto"
local core = require "sproto.core"
local print_r = require "3rd/sproto/print_r"

GameCtrl = {}
local this = GameCtrl
local panel
local prompt
local transform
local gameObject
local myrole
local camera
local animator
local x, y, z = 0, 0, 0
local spr
local speed = 2.5
local isMobile = false
local joystick = false -- 判断摇杆是否在移动
local view
local textshowtime = 0
local textview = 0
local detiltime = 0
local localPlayes = {}
local people = {}
local moves
local status
local playes
local nameUI
local cameraCom
local mainrole
local peoplesNames = {}
local Rotation = 0
local firstCamera
local text =
    "很高兴为你服务，你现在使用的是kagnzw提供的游戏样例，整合了市场上较为方便的前后端框架（前端 unity luaframework-ugui  fairygui 数据传输 protobuf 后端 leaf(golang)），如果在使用的过程中有任何疑问欢迎加群431560923。"

--构建函数--
function GameCtrl.New()
    logWarn("GameCtrl.New--->>")
    return this
end

function GameCtrl.Awake(obj)
    isMobile = obj
    logWarn("GameCtrl.Awake--->>")
    panelMgr:CreatePanel("role", this.OnCreate)
end

--启动事件--
function GameCtrl.OnCreate(obj)
    camera = GameObject.FindWithTag("GuiCamera")
    cameraCom = camera:GetComponent("Camera") 
    gameObject = obj
    transform = obj.transform
    transform.localScale = Vector3.New(1, 1, 1)
    transform.localRotation = Vector4.zero
    transform.localPosition = Vector3.New(-40, 80, 1)
    logWarn("GameCtrl.OnCreate--->>")
    resMgr:LoadPrefab("role", {"role"}, this.InitPanel)
end

function GameCtrl.Update()
    if view ~= nil and textshowtime >= 0 then
        textshowtime = textshowtime + 1
        if (textshowtime < string.len(text)) then
            textview.text = string.sub(text, 0, textshowtime)
        else
            textview.text = text
            textshowtime = -1
        end
    end
end
function GameCtrl.SendStatus()
    local path = Util.DataPath .. "lua/3rd/pbc/StatusDTO.pb"
    local addr = io.open(path, "rb")
    local buffer = addr:read "*a"
    addr:close()
    protobuf.register(buffer) 
    local staus = {
      id = LogingCtrl.id,
      status = {
        wa = LogingCtrl.windex ~= nil and LogingCtrl.windex+1 or 1,
        wr = LogingCtrl.runable == true and 1 or 2,
        wi = LogingCtrl.isrun == true and 1 or 2,
        wj = LogingCtrl.m_Jumping == true and 1 or 2 
      }
    }
    local code = protobuf.encode("msg.StatusDTO", staus)
    local buffer = ByteBuffer.New()
    buffer:WriteShort(Protocal.Send_Status)
    buffer:WriteTString(code)
    networkMgr:SendMessage(buffer)
end
function GameCtrl.SendMove()
    local path = Util.DataPath .. "lua/3rd/pbc/MoveDTO.pb"
    local addr = io.open(path, "rb")
    local buffer = addr:read "*a"
    addr:close()
    protobuf.register(buffer)
    local movedo = {
        id = LogingCtrl.id,
        point = {
            x = tostring(myrole.transform.localPosition.x),
            y = tostring(myrole.transform.localPosition.y),
            z = tostring(myrole.transform.localPosition.z)
        },
        roation = {
            x = tostring(myrole.transform.eulerAngles.x),
            y = tostring(myrole.transform.eulerAngles.y),
            z = tostring(myrole.transform.eulerAngles.z)
        },
    }  
    local code = protobuf.encode("msg.MoveDTO", movedo)
    local buffer = ByteBuffer.New()
    buffer:WriteShort(Protocal.Send_Move)
    buffer:WriteTString(code)
    networkMgr:SendMessage(buffer)
end
function GameCtrl.GetStatus()
    local path = Util.DataPath .. "lua/3rd/pbc/StatusDTO.pb"
    local addr = io.open(path, "rb")
    local buffer = addr:read "*a"
    addr:close()
    protobuf.register(buffer)
    local sta = {}
    local code = protobuf.encode("msg.StatusResult", sta)
    local buffer = ByteBuffer.New()
    buffer:WriteShort(Protocal.Get_Status)
    buffer:WriteTString(code)
    networkMgr:SendMessage(buffer)
end
function GameCtrl.GetMoves()
    local path = Util.DataPath .. "lua/3rd/pbc/MoveDTO.pb"
    local addr = io.open(path, "rb")
    local buffer = addr:read "*a"
    addr:close()
    protobuf.register(buffer)
    local movestemp = {}
    local code = protobuf.encode("msg.MoveResult", movestemp)
    local buffer = ByteBuffer.New()
    buffer:WriteShort(Protocal.Get_Moves)
    buffer:WriteTString(code)
    networkMgr:SendMessage(buffer)
end
function GameCtrl.GetPlayes()
    local path = Util.DataPath .. "lua/3rd/pbc/MoveDTO.pb"
    local addr = io.open(path, "rb")
    local buffer = addr:read "*a"
    addr:close()
    protobuf.register(buffer)
    local playestemp = {}
    local code = protobuf.encode("msg.PlaysResult", playestemp)
    local buffer = ByteBuffer.New()
    buffer:WriteShort(Protocal.Get_Playes)
    buffer:WriteTString(code)
    networkMgr:SendMessage(buffer)
end
function GameCtrl.updateUsers()
    if this.playes ~= nil then
        for key, value in pairs(this.playes) do
            if localPlayes[value.id] == nil then
                localPlayes[value.id] = {}
                localPlayes[value.id].UserName = value.UserName
                if (value.id ~= LogingCtrl.id) then
                    resMgr:LoadPrefab(
                        "role",
                        {"people"},
                        function(objs)
                            this.addpeople(objs, value.id)
                        end
                    )
                end
            end
            localPlayes[value.id].UserName = value.UserName
        end
        for key, value in pairs(localPlayes) do
            local flag = true
            for _, v in pairs(this.playes) do
                if (v.id == key) then
                    flag = false
                    break
                end
            end
            -- 如果未找到该用户信息则删除该用户角色
            if (flag) then
                if (people[key] ~= nil) then
                    destroy(people[key])
                    peoplesNames[key]:Dispose()
                    people[key] = nil
                end
                if (localPlayes[key] ~= nil) then
                    localPlayes[key] = nil
                end
            end
        end
    end
    if this.moves ~= nil then
        for _, v in pairs(this.moves) do
            if localPlayes[v.id] ~= nil and people[v.id] ~= nil then
                if (v.id ~= LogingCtrl.id) then
                    people[v.id].transform.eulerAngles =
                        Vector3.New(tonumber(v.roation.x), tonumber(v.roation.y), tonumber(v.roation.z))
                    people[v.id].transform.localPosition =
                        Vector3.New(tonumber(v.point.x), tonumber(v.point.y), tonumber(v.point.z))
                    local nameobj = people[v.id].transform:Find("name").gameObject
                    nameobj.transform.eulerAngles = firstCamera.transform.eulerAngles;
                end
            end
        end
    end
    if this.status ~= nil then
        for _, v in pairs(this.status) do
            if localPlayes[v.id] ~= nil and people[v.id] ~= nil then
                if (v.id ~= LogingCtrl.id) then
                   local ani = people[v.id]:GetComponent("Animator")
                   ani:SetFloat("windex", v.status.wa-1)
                   ani:SetBool("runable", v.status.wr==1)
                   ani:SetBool("isrun", v.status.wi==1)
                   ani:SetBool("jump", v.status.wj==1)
                end
            end
        end
    end
end 
function GameCtrl.addpeople(objs, id)
    people[id] = newObject(objs[0])
    peoplesNames[id] = UIPackage.CreateObject("talk", "name")
    local panel = people[id]:AddComponent(typeof(UIPanel))
    panel.packageName = "talk"
    panel.componentName = "name"
    panel.container.renderMode = RenderMode.WorldSpace
    panel.container.renderCamera = cameraCom
    panel.container.fairyBatching = true
    panel:SetSortingOrder(1, true)
    panel:SetHitTestMode(HitTestMode.Default)
    panel:CreateUI()
    local nametext = panel.ui:GetChild("n0")
    nametext.text = localPlayes[id].UserName 
    local nameobj = people[id].transform:Find("name").gameObject
    nameobj.transform.localPosition = Vector3.New(-0.6, 2, 0)
    nameobj.transform.eulerAngles = Vector3.zero
    nameobj.transform.localScale = Vector3.New(0.005, 0.005, 0.005)
end

--启动事件--
function GameCtrl.FixedUpdate(obj)
    speed = 2.5
    if (myrole ~= nil and detiltime >= 0.01) then
        detiltime = 0
        this.SendMove()
        this.SendStatus();
        this.GetStatus();
        this.GetMoves()
        this.GetPlayes()
        this.updateUsers()
    else
        detiltime = detiltime + Time.deltaTime
    end
end

function GameCtrl.OnCollisionEnter2D(collider)
    if collider ~= nil then
    end
end

function GameCtrl.onClickSkip()
    if (textshowtime == -1) then
        view:Dispose()
        view = nil
    end
    textshowtime = 1000
end

--初始化面板--
function GameCtrl.InitPanel(objs)
    local count = 1
    for i = 1, count do
        myrole = newObject(objs[0])
        myrole.transform.localScale = Vector3.one
        myrole.transform.localRotation = Vector4.New(0, 0, 0, 1)
        myrole.transform.localPosition = Vector3.New(350, 0, 160)
        mainrole = myrole.Find("modal")
        mainrole.transform.localRotation = Vector4.New(0, 0, 0, 1)
        animator = myrole:GetComponent("Animator")
        nameUI = UIPackage.CreateObject("talk", "name")
        -- local nametext = nameUI:GetChild("n0");
        -- nametext.text = LogingCtrl.username;
        firstCamera = myrole.transform:Find("FirstPersonCharacter").gameObject


        local panel = myrole:AddComponent(typeof(UIPanel))
        panel.packageName = "talk"
        panel.componentName = "name"
        panel.container.renderMode = RenderMode.WorldSpace
        panel.container.renderCamera = cameraCom
        panel.container.fairyBatching = true
        panel:SetSortingOrder(1, true)
        panel:SetHitTestMode(HitTestMode.Default)
        panel:CreateUI()
        local nametext = panel.ui:GetChild("n0")
        nametext.text = LogingCtrl.username
        local nameobj = myrole.transform:Find("name").gameObject 

        nameobj.transform.localPosition = Vector3.New(-0.6, 2, 0)
        nameobj.transform.eulerAngles = Vector3.zero
        nameobj.transform.localScale = Vector3.New(0.005, 0.005, 0.005)
        
        logWarn("animator--->>")
    end
end

--关闭事件--
function GameCtrl.Close()
    panelMgr:ClosePanel(CtrlNames.Prompt)
end
