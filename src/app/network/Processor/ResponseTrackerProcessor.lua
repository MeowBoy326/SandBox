require "app.network.Processor.ResponseTracker"
local ResponseTrackerProcessor = class("ResponseTrackerProcessor")

--[[
    處理command綁定，command逾時處理
]]
local commandSorrespond = {
    {cc.Protocol.PachinU2GProtocol.PACHIN_U2G_GAME_INFO_REQ, cc.Protocol.PachinG2UProtocol.SLOT_G2U_GAME_INFO_ACK},
    {cc.Protocol.PachinU2GProtocol.PACHIN_U2G_SPIN_REQ, cc.Protocol.PachinG2UProtocol.SLOT_G2U_SPIN_ACK},
    {cc.Protocol.PachinU2GProtocol.PACHIN_U2G_SPIN_END_REQ, nil},
    {cc.Protocol.PachinU2GProtocol.PACHIN_U2G_FREE_SPIN_REQ, cc.Protocol.PachinG2UProtocol.SLOT_G2U_FREE_SPIN_ACK},
    {cc.Protocol.PachinU2GProtocol.PACHIN_U2G_FREE_SPIN_END_REQ, nil},
    {cc.Protocol.PachinU2GProtocol.PACHIN_U2G_GET_BONUS_RECORD_REQ, cc.Protocol.PachinG2UProtocol.SLOT_G2U_GET_BONUS_RECORD_ACK},
}

local scheduler = cc.Director:getInstance():getScheduler()
local TRACK_SECOND = 15
local TRACK_DURATION = 1

function ResponseTrackerProcessor:ctor()
    self._trackList = {}
    scheduler:scheduleScriptFunc(handler(self, self.Update), TRACK_DURATION, false)
end

function ResponseTrackerProcessor:Update()
    local deleteIndex = nil
    for index, value in ipairs(self._trackList) do
        if value:Update(TRACK_DURATION) then
            deleteIndex = index
        end
    end

    if deleteIndex then
        table.remove(self._trackList, deleteIndex)
    end
end

function ResponseTrackerProcessor:PreProcessSend(command)
    if command == nil then
        return
    end
    
    for index, value in ipairs(commandSorrespond) do
        local requestId, responseId = value[1], value[2]
        if requestId == command:CommandType() and responseId ~= nil then
             table.insert(self._trackList, cc.ResponseTracker:create(responseId, TRACK_SECOND))
             break
        end
    end
end

function ResponseTrackerProcessor:PreProcessRecv(command)
    if command == nil then
        return
    end

    local removeIndex = nil
    for index, value in ipairs(self._trackList) do
        if value == command.commandType then
            removeIndex = index
            break
        end
    end

    if removeIndex then
        table.remove(self._trackList, removeIndex)
        print("PreProcessRecv", command.commandType)
    end
end


cc.ResponseTrackerProcessor = ResponseTrackerProcessor
return ResponseTrackerProcessor