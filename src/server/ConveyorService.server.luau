-- ConveyorService: a fresh brainrot rolls onto the belt every few seconds,
-- strolls from the green start pad to the red end pad, and despawns if
-- nobody buys it on the way.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotData = require(ReplicatedStorage:WaitForChild("BrainrotData"))
local GameState = require(script.Parent:WaitForChild("GameState"))

local SPAWN_INTERVAL = 4
local WALK_SPEED = 5 -- studs per second
local STEP_WAIT = 0.1

local function countConveyorBrainrots()
	local count = 0
	for _ in pairs(GameState.conveyor) do
		count += 1
	end
	return count
end

-- Walks one brainrot along the belt, step by step, until it is bought or
-- reaches the end pad.
function ConveyorService_walkBrainrotAlongConveyor(brainrotId)
	local entry = GameState.conveyor[brainrotId]
	if not entry then
		return
	end
	local model = entry.model
	local x = GameState.CONVEYOR_START_X
	while x < GameState.CONVEYOR_END_X do
		if GameState.conveyor[brainrotId] == nil then
			return -- bought while walking
		end
		x += WALK_SPEED * STEP_WAIT
		local bob = math.sin(x * 0.5) * 0.15
		model:PivotTo(CFrame.new(x, GameState.CONVEYOR_Y + bob, 0))
		task.wait(STEP_WAIT)
	end
	if GameState.conveyor[brainrotId] ~= nil then
		GameState.conveyor[brainrotId] = nil
		model:Destroy()
	end
end

function ConveyorService_spawnBrainrotOnConveyor()
	if countConveyorBrainrots() >= GameState.MAX_CONVEYOR_BRAINROTS then
		return
	end
	local record = BrainrotData.newBrainrotRecord()
	local model = BrainrotData.buildBrainrotModel(record)

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "BuyPrompt"
	prompt.ActionText = "Buy"
	prompt.ObjectText = record.name .. " - " .. BrainrotData.formatMoney(record.cost) .. " (" .. BrainrotData.formatMoney(record.income) .. "/s)"
	prompt.HoldDuration = 0
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 12
	prompt.Parent = model.PrimaryPart

	prompt.Triggered:Connect(function(player)
		GameState.buyBrainrotForPlayer(player, record.id)
	end)

	model:PivotTo(CFrame.new(GameState.CONVEYOR_START_X, GameState.CONVEYOR_Y, 0))
	model.Parent = workspace

	GameState.conveyor[record.id] = { record = record, model = model }
	task.spawn(ConveyorService_walkBrainrotAlongConveyor, record.id)
end

task.spawn(function()
	while true do
		task.wait(SPAWN_INTERVAL)
		ConveyorService_spawnBrainrotOnConveyor()
	end
end)

-- One brainrot is already on the belt when the server starts.
ConveyorService_spawnBrainrotOnConveyor()

print("ConveyorService ready: a brainrot spawns every " .. tostring(SPAWN_INTERVAL) .. "s")
