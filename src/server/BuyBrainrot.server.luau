-- BuyBrainrot: the remote the client fires when a player wants to buy a
-- brainrot. All validation lives in GameState.buyBrainrotForPlayer.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameState = require(script.Parent:WaitForChild("GameState"))

local BuyBrainrot = ReplicatedStorage:WaitForChild("BuyBrainrot")

BuyBrainrot.OnServerEvent:Connect(function(player, brainrotId)
	if typeof(brainrotId) ~= "string" then
		return
	end
	GameState.buyBrainrotForPlayer(player, brainrotId)
end)

print("BuyBrainrot remote ready")
