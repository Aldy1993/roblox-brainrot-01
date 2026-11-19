-- EconomyService: leaderstats plus the heartbeat of the game - every
-- brainrot sitting in a base pays its owner cash every second.

local Players = game:GetService("Players")

local GameState = require(script.Parent:WaitForChild("GameState"))
local GoldenHour = require(script.Parent:WaitForChild("GoldenHour"))
local MissionService = require(script.Parent:WaitForChild("MissionService"))

local function setupLeaderstats(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	for _, spec in ipairs({ { "Cash", GameState.START_CASH }, { "IncomePerSec", 0 }, { "Rebirths", 0 } }) do
		local value = Instance.new("IntValue")
		value.Name = spec[1]
		value.Value = spec[2]
		value.Parent = leaderstats
	end

	GameState.ensurePlayerData(player)
	GameState.syncLeaderstats(player)
end

-- Adds one second of income for every player with brainrots in a base.
function EconomyService_collectIncomePerSecond()
	for _, player in ipairs(Players:GetPlayers()) do
		local data = GameState.playerData[player]
		if data and data.baseIndex > 0 then
			local basePay = GameState.baseIncome(data.baseIndex)
			-- Rebirth multiplier x Golden Hour multiplier (x2 while the
			-- island is golden).
			local payout = basePay * data.multiplier * GoldenHour.getMultiplier()
			data.income = payout
			if payout > 0 then
				data.cash += payout
				MissionService.addEarnings(player, payout)
			end
			GameState.syncLeaderstats(player)
		end
	end
end

Players.PlayerAdded:Connect(setupLeaderstats)

for _, player in ipairs(Players:GetPlayers()) do
	setupLeaderstats(player)
end

task.spawn(function()
	while true do
		task.wait(1)
		EconomyService_collectIncomePerSecond()
	end
end)

print("EconomyService ready: income ticks every 1s")
