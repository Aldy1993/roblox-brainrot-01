-- HazardService: about every 3 minutes a tsunami warning sounds, then a
-- giant wave sweeps the map. Players caught outside their own base get
-- flung across the map and drop whatever brainrot they were carrying.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GameState = require(script.Parent:WaitForChild("GameState"))
local MissionService = require(script.Parent:WaitForChild("MissionService"))

local GameEvent = ReplicatedStorage:WaitForChild("GameEvent")

local CYCLE_SECONDS = 180
local WARNING_SECONDS = 10

-- Flings one player and makes them drop a carried brainrot.
function HazardService_flingPlayerOutOfWave(player)
	local character = player.Character
	if not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	if GameState.carrying[player] then
		GameState.notifyPlayer(player, "The wave knocked the brainrot out of your hands!")
		GameState.returnCarriedBrainrot(player)
	end
	root.AssemblyLinearVelocity = Vector3.new(math.random(-50, 50), 70, math.random(-50, 50))
	root.AssemblyAngularVelocity = Vector3.new(math.random(-8, 8), math.random(-8, 8), math.random(-8, 8))
end

function HazardService_triggerTsunamiWave()
	GameEvent:FireAllClients("TsunamiWarning", WARNING_SECONDS)
	task.wait(WARNING_SECONDS)

	local wave = Instance.new("Part")
	wave.Name = "TsunamiWave"
	wave.Size = Vector3.new(12, 24, 240)
	wave.Position = Vector3.new(-130, 12, 0)
	wave.Color = Color3.fromRGB(30, 120, 255)
	wave.Transparency = 0.35
	wave.Material = Enum.Material.Neon
	wave.Anchored = true
	wave.CanCollide = false
	wave.Parent = workspace

	GameEvent:FireAllClients("TsunamiWave")

	local sweep = TweenService:Create(wave, TweenInfo.new(6, Enum.EasingStyle.Linear), { Position = Vector3.new(130, 12, 0) })
	sweep:Play()

	-- Anyone still outside their own base when the wave passes gets flung.
	task.wait(3)
	for _, player in ipairs(Players:GetPlayers()) do
		local data = GameState.playerData[player]
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			local safe = false
			if data and data.baseIndex > 0 then
				safe = GameState.isPointInBase(root.Position, data.baseIndex)
			end
			if not safe then
				HazardService_flingPlayerOutOfWave(player)
			else
				-- Standing safe in your own base when the wave passes
				-- counts as surviving the tsunami (mission 4).
				MissionService.markTsunamiSurvived(player)
			end
		end
	end

	sweep.Completed:Wait()
	wave:Destroy()
	GameEvent:FireAllClients("TsunamiOver")
end

task.spawn(function()
	while true do
		task.wait(CYCLE_SECONDS)
		HazardService_triggerTsunamiWave()
	end
end)

print("HazardService ready: tsunami every " .. tostring(CYCLE_SECONDS) .. "s with a " .. tostring(WARNING_SECONDS) .. "s warning")
