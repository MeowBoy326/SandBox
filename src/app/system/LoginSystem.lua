require "app.message.PACHIN_G2U_LOGIN_ACK"
require "app.message.PACHIN_G2U_ROOM_INFO_ACK"
require "app.message.PACHIN_G2U_JOIN_ROOM_ACK"
require "app.message.PACHIN_U2G_LOGIN_REQ"
require "app.message.PACHIN_U2G_ROOM_INFO_REQ"

local LoginSystem = class("LoginSystem", cc.SubSystemBase:GetInstance())
local RecvCommand = cc.Protocol.PachinG2UProtocol

function LoginSystem:ctor()
    print("LoginSystem:ctor")
    self:Registers(RecvCommand.PACHIN_G2U_LOGIN_ACK, handler(self, self.OnRecvLogin))
    self:Registers(RecvCommand.PACHIN_G2U_ROOM_INFO_ACK, handler(self, self.OnRecvRoomInfo))
    self:Registers(RecvCommand.PACHIN_G2U_JOIN_ROOM_ACK, handler(self, self.OnRecvJoinRoom)) 
end

function LoginSystem:Connect(ip, port, accountID)
    self.IP = self:GetDefaultorTextValue(DEFAULT_LOGIN_INFO.IP, ip)

    self.port = self:GetDefaultorTextValue(DEFAULT_LOGIN_INFO.port, port)
    print("IP and Port:", self.IP .. " ".. self.port)

    self.accoundId = self:GetDefaultorTextValue(DEFAULT_LOGIN_INFO.accoundId, accountID)
    print("AccountId:",  self.accoundId)

    self:GetInstance():Connect(self.IP, self.port, handler(self, self.OnConnected))
end

function LoginSystem:GetDefaultorTextValue(defaultValue, textValue)
    if textValue ~= "" then
        return textValue
    end
    return defaultValue
end

function LoginSystem:OnConnected()
    self:RequestLogin(self.accoundId)
end

function LoginSystem:RequestLogin(accountid)
    local request = cc.PACHIN_U2G_LOGIN_REQ:create(accountid)
    self:GetInstance():Send(cc.Protocol.PachinU2GProtocol.PACHIN_U2G_LOGIN_REQ, request:Serialize())
end

-- function LoginSystem:RequestRoomInfo(accountid)
--     local request = cc.PACHIN_U2G_ROOM_INFO_REQ:create(accountid)
--     self:GetInstance():Send(cc.Protocol.PachinU2GProtocol.PACHIN_U2G_ROOM_INFO_REQ, request:Serialize())
-- end

function LoginSystem:OnRecvLogin(command)
    print("Recv Command 1")
    local response = cc.PACHIN_G2U_LOGIN_ACK:create(command.content)
    if response.LoginAck.success then
        cc.exports.dispatchEvent( cc.exports.define.EVENTS.LOGIN_SUCCESS )
    else
        cc.exports.dispatchEvent( cc.exports.define.EVENTS.SHOW_MSG,
        {
            title = "SystemInfo",
            content = "login fail: ",
            confirmCB = function ()
            print("click confirmCB")
        end,
            btnPosType = 1,
        } )
    end
end

return LoginSystem