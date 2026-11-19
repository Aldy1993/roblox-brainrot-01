-- MissionService: one mission at a time, in order; each pays cash the
-- moment it is done. Services report the events missions watch: Economy
-- reports earnings, Hazard reports a survived tsunami, Rebirth reports a
-- rebirth, and brainrots landing in a base re-check owned-count missions.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotData = require(ReplicatedStorage:WaitForChild("BrainrotData"))
local GameState = require(script.Parent:WaitForChild("GameState"))

local GameEvent = ReplicatedStorage:WaitForChild("GameEvent")

local MissionService = {}

MissionService.MISSIONS = {
	{ name = "Buy your first brainrot", kind = "owned", goal = 1, reward = 100 },
	{ name = "Own 3 brainrots", kind = "owned", goal = 3, reward = 250 },
	{ name = "Earn $5,000 total", kind = "earned", goal = 5000, reward = 500 },
	{ name = "Survive a tsunami", kind = "tsunami", goal = 1, reward = 300 },
	{ name = "Rebirth once", kind = "rebirth", goal = 1, reward = 1000 },
	{ name = "Own 8 brainrots", kind = "owned", goal = 8, reward = 1500 },
	{ name = "Earn $50,000 total", kind = "earned", goal = 50000, reward = 5000 },
}

-- How many brainrots the player has sitting in their base right now.
function MissionService.countOwnedBrainrots(player)
	local data = GameState.playerData[player]
	if not data or data.baseIndex == 0 then
		return 0
	end
	local count = 0
	for _ in pairs(GameState.bases[data.baseIndex].slots) do
		count += 1
	end
	return count
end

-- The progress number for the player's current mission, from live data.
function MissionService.currentProgress(player)
	local data = GameState.playerData[player]
	if not data then
		return 0
	end
	local mission = MissionService.MISSIONS[data.missions.index]
	if not mission then
		return 0
	end
	if mission.kind == "owned" then
		return MissionService.countOwnedBrainrots(player)
	elseif mission.kind == "earned" then
		return math.floor(data.lifetimeEarned)
	elseif mission.kind == "tsunami" then
		return data.missions.tsunamiDone and 1 or 0
	elseif mission.kind == "rebirth" then
		return data.missions.rebirthDone and 1 or 0
	end
	return 0
end

-- Sends the player's current mission to their client for the mission bar.
function MissionService.sendMissionToClient(player)
	local data = GameState.playerData[player]
	if not data then
		return
	end
	local mission = MissionService.MISSIONS[data.missions.index]
	if mission then
		GameEvent:FireClient(player, "MissionUpdate", {
			index = data.missions.index,
			total = #MissionService.MISSIONS,
			name = mission.name,
			progress = MissionService.currentProgress(player),
			goal = mission.goal,
			reward = mission.reward,
		})
	else
		GameEvent:FireClient(player, "MissionUpdate", {
			index = #MissionService.MISSIONS + 1,
			total = #MissionService.MISSIONS,
			name = "All missions complete!",
			progress = 1,
			goal = 1,
			reward = 0,
		})
	end
end

-- Checks the current mission and pays out every one that is done (a big
-- earnings tick can finish more than one at once).
function MissionService.checkMissions(player)
	local data = GameState.playerData[player]
	if not data then
		return
	end
	while true do
		local mission = MissionService.MISSIONS[data.missions.index]
		if not mission then
			return
		end
		if MissionService.currentProgress(player) < mission.goal then
			MissionService.sendMissionToClient(player)
			return
		end
		data.cash += mission.reward
		GameState.syncLeaderstats(player)
		GameState.notifyPlayer(player, "MISSION COMPLETE: " .. mission.name .. " + " .. BrainrotData.formatMoney(mission.reward) .. "!")
		data.missions.index += 1
		MissionService.sendMissionToClient(player)
	end
end

-- Lifetime earnings tick, called by EconomyService once a second.
function MissionService.addEarnings(player, amount)
	local data = GameState.playerData[player]
	if not data then
		return
	end
	data.lifetimeEarned += amount
	MissionService.checkMissions(player)
end

-- Called by HazardService for every player standing safe in their own
-- base when the wave passes.
function MissionService.markTsunamiSurvived(player)
	local data = GameState.playerData[player]
	if not data then
		return
	end
	if not data.missions.tsunamiDone then
		data.missions.tsunamiDone = true
		MissionService.checkMissions(player)
	end
end

-- Called by RebirthService after a successful rebirth.
function MissionService.markRebirth(player)
	local data = GameState.playerData[player]
	if not data then
		return
	end
	if not data.missions.rebirthDone then
		data.missions.rebirthDone = true
		MissionService.checkMissions(player)
	end
end

-- A brainrot landing in a base moves the owned count, so missions that
-- count brainrots get re-checked for the base's owner.
GameState.BrainrotPlaced.Event:Connect(function(record, model, baseIndex, slotIndex)
	for _, player in ipairs(Players:GetPlayers()) do
		local data = GameState.playerData[player]
		if data and data.baseIndex == baseIndex then
			MissionService.checkMissions(player)
		end
	end
end)

-- A joining player gets their first mission shortly after spawning, once
-- their client HUD is up.
Players.PlayerAdded:Connect(function(player)
	task.delay(2, function()
		MissionService.sendMissionToClient(player)
	end)
end)

return MissionService
