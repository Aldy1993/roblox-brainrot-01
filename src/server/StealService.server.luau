-- StealService: click a brainrot in somebody else's base to grab it, then
-- carry it home within 15 seconds. A locked base refuses every thief.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotData = require(ReplicatedStorage:WaitForChild("BrainrotData"))
local GameState = require(script.Parent:WaitForChild("GameState"))

local LockBase = ReplicatedStorage:WaitForChild("LockBase")

-- Buys a 60-second lock: thieves clicking this base get turned away.
function StealService_lockBaseAgainstTheft(player)
	local data = GameState.ensurePlayerData(player)
	if data.baseIndex == 0 then
		GameState.notifyPlayer(player, "You have no base to lock!")
		return
	end
	local base = GameState.bases[data.baseIndex]
	if base.lockedUntil > os.time() then
		GameState.notifyPlayer(player, "Your base is already locked for " .. tostring(base.lockedUntil - os.time()) .. "s more.")
		return
	end
	if data.cash < GameState.LOCK_COST then
		GameState.notifyPlayer(player, "Locking costs " .. BrainrotData.formatMoney(GameState.LOCK_COST) .. "!")
		return
	end
	data.cash -= GameState.LOCK_COST
	base.lockedUntil = os.time() + GameState.LOCK_SECONDS
	GameState.syncLeaderstats(player)
	local gateLeft = workspace:FindFirstChild("Base" .. tostring(data.baseIndex) .. "_GateLeft")
	local gateRight = workspace:FindFirstChild("Base" .. tostring(data.baseIndex) .. "_GateRight")
	if gateLeft then
		gateLeft.Color = Color3.fromRGB(255, 0, 0)
	end
	if gateRight then
		gateRight.Color = Color3.fromRGB(255, 0, 0)
	end
	task.delay(GameState.LOCK_SECONDS, function()
		local gateColor = GameState.BASES[data.baseIndex].color
		if gateLeft then
			gateLeft.Color = gateColor
		end
		if gateRight then
			gateRight.Color = gateColor
		end
	end)
	GameState.notifyPlayer(player, "Base locked for " .. tostring(GameState.LOCK_SECONDS) .. "s! Nobody can steal from you.")
end

-- Carries the stolen brainrot above the thief's head until they reach
-- their own base or the timer runs out.
function StealService_carryStolenBrainrotHome(player)
	local carry = GameState.carrying[player]
	if not carry then
		return
	end
	local data = GameState.ensurePlayerData(player)
	local deadline = os.time() + GameState.STEAL_SECONDS
	while GameState.carrying[player] ~= nil do
		if os.time() >= deadline then
			GameState.notifyPlayer(player, "Too slow! " .. carry.record.name .. " ran back to its base.")
			GameState.returnCarriedBrainrot(player)
			return
		end
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root then
			GameState.returnCarriedBrainrot(player)
			return
		end
		carry.model:PivotTo(root.CFrame * CFrame.new(0, 4.5, 0))
		if data.baseIndex > 0 and GameState.isPointInBase(root.Position, data.baseIndex) then
			GameState.carrying[player] = nil
			local slotIndex = GameState.placeBrainrotInBase(data.baseIndex, carry.record, carry.model)
			if slotIndex then
				GameState.notifyPlayer(player, "Stolen! " .. carry.record.name .. " is yours now.")
			else
				GameState.notifyPlayer(player, "Your base is full - the brainrot slipped away!")
				carry.model:Destroy()
			end
			return
		end
		task.wait(0.1)
	end
end

function StealService_stealBrainrotFromBase(player, brainrotId)
	local baseIndex, slotIndex, entry = GameState.findBrainrotInBases(brainrotId)
	if not entry then
		return
	end
	local data = GameState.ensurePlayerData(player)
	local victimBase = GameState.bases[baseIndex]
	if victimBase.owner == player then
		GameState.notifyPlayer(player, "That brainrot is already yours!")
		return
	end
	if victimBase.lockedUntil > os.time() then
		GameState.notifyPlayer(player, "That base is LOCKED! Come back later.")
		return
	end
	if GameState.carrying[player] then
		GameState.notifyPlayer(player, "You are already carrying a brainrot - bring it home first!")
		return
	end
	if data.baseIndex == 0 then
		GameState.notifyPlayer(player, "You have no base to bring it home to!")
		return
	end
	local removed = GameState.removeBrainrotFromBase(baseIndex, slotIndex)
	if not removed then
		return
	end
	GameState.carrying[player] = {
		record = removed.record,
		model = removed.model,
		fromBase = baseIndex,
		fromSlot = slotIndex,
	}
	GameState.notifyPlayer(player, "You grabbed " .. removed.record.name .. "! Run home in " .. tostring(GameState.STEAL_SECONDS) .. "s!")
	if victimBase.owner then
		GameState.notifyPlayer(victimBase.owner, player.DisplayName .. " is stealing your " .. removed.record.name .. "!")
	end
	task.spawn(StealService_carryStolenBrainrotHome, player)
end

-- Every brainrot that lands in a base gets a ClickDetector so rivals can
-- try to steal it.
GameState.BrainrotPlaced.Event:Connect(function(record, model, baseIndex, slotIndex)
	local body = model.PrimaryPart
	if not body then
		return
	end
	if body:FindFirstChildOfClass("ClickDetector") then
		return
	end
	local clicker = Instance.new("ClickDetector")
	clicker.Name = "StealClick"
	clicker.MaxActivationDistance = 16
	clicker.Parent = body
	clicker.MouseClick:Connect(function(player)
		StealService_stealBrainrotFromBase(player, record.id)
	end)
end)

LockBase.OnServerEvent:Connect(function(player)
	StealService_lockBaseAgainstTheft(player)
end)

Players.PlayerRemoving:Connect(function(player)
	if GameState.carrying[player] then
		GameState.returnCarriedBrainrot(player)
	end
end)

print("StealService ready: 15s to bring a steal home, lock lasts " .. tostring(GameState.LOCK_SECONDS) .. "s")
