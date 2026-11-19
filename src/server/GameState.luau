-- Brainrot Blast shared server state: player wallets, the 8 bases, the
-- conveyor line and anything being carried. Every server service requires
-- this one module, so they all see the same live tables.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotData = require(ReplicatedStorage:WaitForChild("BrainrotData"))

local GameState = {}

GameState.START_CASH = 100
GameState.START_SLOTS = 6
GameState.MAX_SLOTS = 10
GameState.LOCK_COST = 250
GameState.LOCK_SECONDS = 60
GameState.STEAL_SECONDS = 15
GameState.CONVEYOR_START_X = -65
GameState.CONVEYOR_END_X = 65
GameState.CONVEYOR_Y = 2.6
GameState.MAX_CONVEYOR_BRAINROTS = 12

-- Base layout: must match the platforms built in default.project.json.
GameState.BASES = {
	{ name = "Noodle Nest", center = Vector3.new(-85, 0, -85), color = Color3.fromRGB(217, 31, 31) },
	{ name = "Banana Bay", center = Vector3.new(85, 0, -85), color = Color3.fromRGB(31, 89, 230) },
	{ name = "Pizza Plaza", center = Vector3.new(-85, 0, 85), color = Color3.fromRGB(242, 191, 26) },
	{ name = "Toaster Town", center = Vector3.new(85, 0, 85), color = Color3.fromRGB(31, 191, 64) },
	{ name = "Pickle Park", center = Vector3.new(-85, 0, 0), color = Color3.fromRGB(140, 51, 217) },
	{ name = "Spaghetti Station", center = Vector3.new(85, 0, 0), color = Color3.fromRGB(242, 115, 20) },
	{ name = "Granny Grove", center = Vector3.new(0, 0, -85), color = Color3.fromRGB(242, 89, 166) },
	{ name = "Ohio Outpost", center = Vector3.new(0, 0, 85), color = Color3.fromRGB(20, 191, 217) },
}

GameState.playerData = {}
GameState.bases = {}
GameState.conveyor = {}
GameState.carrying = {}

for index, base in ipairs(GameState.BASES) do
	GameState.bases[index] = {
		owner = nil,
		lockedUntil = 0,
		slotCount = GameState.START_SLOTS,
		slots = {},
		folder = nil,
		signGui = nil,
	}
end

-- Fired when a brainrot lands in a base slot (record, model, baseIndex, slotIndex).
GameState.BrainrotPlaced = Instance.new("BindableEvent")
GameState.BrainrotPlaced.Name = "BrainrotPlaced"
GameState.BrainrotPlaced.Parent = script

local GameEvent = ReplicatedStorage:WaitForChild("GameEvent")

function GameState.notifyPlayer(player, text)
	GameEvent:FireClient(player, "Notify", text)
end

function GameState.ensurePlayerData(player)
	local data = GameState.playerData[player]
	if not data then
		-- lifetimeEarned feeds the "earn $X total" missions; found is the
		-- set of brainrot names this player has ever owned (Index grid);
		-- missions holds the mission-bar progress (see MissionService).
		data = { cash = GameState.START_CASH, rebirths = 0, multiplier = 1, baseIndex = 0, income = 0, lifetimeEarned = 0, found = {}, missions = { index = 1, tsunamiDone = false, rebirthDone = false } }
		GameState.playerData[player] = data
	end
	return data
end

-- Records that a player has owned this brainrot name (for the Index grid)
-- and tells their client the updated found list.
function GameState.markBrainrotFound(player, recordName)
	local data = GameState.ensurePlayerData(player)
	if data.found[recordName] then
		return
	end
	data.found[recordName] = true
	local foundList = {}
	for name in pairs(data.found) do
		table.insert(foundList, name)
	end
	GameEvent:FireClient(player, "IndexUpdate", foundList)
end

function GameState.syncLeaderstats(player)
	local data = GameState.playerData[player]
	if not data then
		return
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end
	local cash = leaderstats:FindFirstChild("Cash")
	if cash then
		cash.Value = math.floor(data.cash)
	end
	local income = leaderstats:FindFirstChild("IncomePerSec")
	if income then
		income.Value = math.floor(data.income)
	end
	local rebirths = leaderstats:FindFirstChild("Rebirths")
	if rebirths then
		rebirths.Value = data.rebirths
	end
end

-- Slot grid inside a base: 3 columns, rows of 3, first 10 used.
function GameState.slotPosition(baseIndex, slotIndex)
	local base = GameState.BASES[baseIndex]
	local columns = { -6, 0, 6 }
	local rows = { -6, -2, 2, 6 }
	local column = ((slotIndex - 1) % 3) + 1
	local row = math.ceil(slotIndex / 3)
	return Vector3.new(base.center.X + columns[column], 3.2, base.center.Z + rows[row])
end

function GameState.findFreeSlot(baseIndex)
	local base = GameState.bases[baseIndex]
	for slotIndex = 1, base.slotCount do
		if base.slots[slotIndex] == nil then
			return slotIndex
		end
	end
	return nil
end

function GameState.findBrainrotInBases(brainrotId)
	for baseIndex, base in ipairs(GameState.bases) do
		for slotIndex, entry in pairs(base.slots) do
			if entry.record.id == brainrotId then
				return baseIndex, slotIndex, entry
			end
		end
	end
	return nil, nil, nil
end

function GameState.baseIncome(baseIndex)
	local total = 0
	for _, entry in pairs(GameState.bases[baseIndex].slots) do
		total += entry.record.income
	end
	return total
end

-- Drops a brainrot model into the first free slot of a base and records it.
-- Pass an existing model (conveyor buy, finished steal) or nil to build one.
function GameState.placeBrainrotInBase(baseIndex, record, model)
	local slotIndex = GameState.findFreeSlot(baseIndex)
	if not slotIndex then
		return nil
	end
	if not model then
		model = BrainrotData.buildBrainrotModel(record)
	end
	local base = GameState.bases[baseIndex]
	base.slots[slotIndex] = { record = record, model = model }
	model:PivotTo(CFrame.new(GameState.slotPosition(baseIndex, slotIndex)))
	if base.folder then
		model.Parent = base.folder
	else
		model.Parent = workspace
	end
	GameState.BrainrotPlaced:Fire(record, model, baseIndex, slotIndex)
	return slotIndex
end

function GameState.removeBrainrotFromBase(baseIndex, slotIndex)
	local base = GameState.bases[baseIndex]
	local entry = base.slots[slotIndex]
	base.slots[slotIndex] = nil
	return entry
end

function GameState.isPointInBase(point, baseIndex)
	local center = GameState.BASES[baseIndex].center
	return math.abs(point.X - center.X) < 13 and math.abs(point.Z - center.Z) < 13
end

-- The buy path, used by the conveyor ProximityPrompt and the BuyBrainrot
-- remote: validate cash and a free slot, then move the brainrot home.
function GameState.buyBrainrotForPlayer(player, brainrotId)
	local entry = GameState.conveyor[brainrotId]
	if not entry then
		return false
	end
	local data = GameState.ensurePlayerData(player)
	if data.baseIndex == 0 then
		GameState.notifyPlayer(player, "You have no base yet!")
		return false
	end
	if data.cash < entry.record.cost then
		GameState.notifyPlayer(player, "Not enough cash for " .. entry.record.name .. "!")
		return false
	end
	local slotIndex = GameState.findFreeSlot(data.baseIndex)
	if not slotIndex then
		GameState.notifyPlayer(player, "Your base is full! Upgrade for more slots.")
		return false
	end
	GameState.conveyor[brainrotId] = nil
	local prompt = entry.model:FindFirstChild("Body") and entry.model.Body:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		prompt:Destroy()
	end
	data.cash -= entry.record.cost
	GameState.placeBrainrotInBase(data.baseIndex, entry.record, entry.model)
	GameState.markBrainrotFound(player, entry.record.name)
	GameState.syncLeaderstats(player)
	GameState.notifyPlayer(player, "Bought " .. entry.record.name .. " for " .. BrainrotData.formatMoney(entry.record.cost) .. "!")
	return true
end

-- A carried brainrot goes back to the base it came from.
function GameState.returnCarriedBrainrot(player)
	local carry = GameState.carrying[player]
	if not carry then
		return
	end
	GameState.carrying[player] = nil
	local base = GameState.bases[carry.fromBase]
	local slotIndex = carry.fromSlot
	if base.slots[slotIndex] ~= nil then
		slotIndex = GameState.findFreeSlot(carry.fromBase)
	end
	if slotIndex then
		base.slots[slotIndex] = { record = carry.record, model = carry.model }
		carry.model:PivotTo(CFrame.new(GameState.slotPosition(carry.fromBase, slotIndex)))
		if base.folder then
			carry.model.Parent = base.folder
		end
		GameState.BrainrotPlaced:Fire(carry.record, carry.model, carry.fromBase, slotIndex)
	else
		carry.model:Destroy()
	end
end

-- Clears every brainrot out of a base (rebirth, player leaving).
function GameState.clearBase(baseIndex)
	local base = GameState.bases[baseIndex]
	for slotIndex, entry in pairs(base.slots) do
		base.slots[slotIndex] = nil
		if entry.model then
			entry.model:Destroy()
		end
	end
end

Players.PlayerRemoving:Connect(function(player)
	local carry = GameState.carrying[player]
	if carry then
		GameState.returnCarriedBrainrot(player)
	end
	local data = GameState.playerData[player]
	if data and data.baseIndex > 0 then
		GameState.clearBase(data.baseIndex)
		GameState.bases[data.baseIndex].owner = nil
		GameState.bases[data.baseIndex].lockedUntil = 0
		GameState.bases[data.baseIndex].slotCount = GameState.START_SLOTS
	end
	GameState.playerData[player] = nil
end)

return GameState
