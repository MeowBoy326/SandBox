require "app.serialization.JsonSerialize"

local PACHIN_U2G_JOIN_ROOM_REQ = class("PACHIN_U2G_JOIN_ROOM_REQ", cc.JsonSerialize:create())

function PACHIN_U2G_JOIN_ROOM_REQ:ctor(accountId,roomIndex)
    self.JoinRoomReq = {}
    self.JoinRoomReq.accountId = accountId
    self.JoinRoomReq.roomIndex = roomIndex
end

cc.PACHIN_U2G_JOIN_ROOM_REQ = PACHIN_U2G_JOIN_ROOM_REQ