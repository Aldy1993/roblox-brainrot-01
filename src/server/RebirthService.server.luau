-- RebirthService: trade everything for a permanent x2 income multiplier.
-- Each rebirth costs twice the last one and wipes cash and brainrots.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotData = require(ReplicatedStorage:WaitForChild("BrainrotData"))
local GameState = require(script.Parent:WaitForChild("GameState"))
local MissionService = require(script.Parent:WaitForChild("MissionService"))

local RequestRebirth = ReplicatedStorage:WaitForChild("RequestRebirth")

local FIRST_REBIRTH_COST = 25000

function RebirthService_rebirthCost(rebirths)
	return FIRST_REBIRTH_COST * (2 ^ rebirths)
end

function RebirthService_rebirthPlayer(player)
	local data = GameState.ensurePlayerData(player)
	local cost = RebirthService_rebirthCost(data.rebirths)
	if data.cash < cost then
		GameState.notifyPlayer(player, "Rebirth costs " .. BrainrotData.formatMoney(cost) .. " - you have " .. BrainrotData.formatMoney(data.cash) .. ".")
		return
	end
	if data.baseIndex > 0 then
		GameState.clearBase(data.baseIndex)
	end
	data.cash = 0
	data.rebirths += 1
	data.multiplier = 2 ^ data.rebirths
	data.income = 0
	GameState.syncLeaderstats(player)
	MissionService.markRebirth(player)
	GameState.notifyPlayer(player, "REBIRTH! Your income is now x" .. tostring(data.multiplier) .. " forever. Time to rebuild!")
end

RequestRebirth.OnServerEvent:Connect(function(player)
	RebirthService_rebirthPlayer(player)
end)

print("RebirthService ready: first rebirth costs " .. BrainrotData.formatMoney(FIRST_REBIRTH_COST))
