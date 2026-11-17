-- BaseService: hands each joining player a base, builds its slot pads and
-- name sign, and sells extra capacity through the UpgradeBase remote.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameState = require(script.Parent:WaitForChild("GameState"))

local UpgradeBase = ReplicatedStorage:WaitForChild("UpgradeBase")

local UPGRADE_STEPS = { 1000, 2000 }

local function makeSignGui(baseIndex, signPart)
	local gui = Instance.new("BillboardGui")
	gui.Name = "BaseSign"
	gui.Adornee = signPart
	gui.Size = UDim2.new(0, 260, 0, 90)
	gui.StudsOffset = Vector3.new(0, 0, 0)
	gui.AlwaysOnTop = true
	gui.Parent = signPart

	local title = Instance.new("TextLabel")
	title.Name = "TitleLabel"
	title.Size = UDim2.new(1, 0, 0.5, 0)
	title.BackgroundTransparency = 1
	title.Text = "Base " .. tostring(baseIndex) .. " - " .. GameState.BASES[baseIndex].name
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 24
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = gui

	local owner = Instance.new("TextLabel")
	owner.Name = "OwnerLabel"
	owner.Size = UDim2.new(1, 0, 0.5, 0)
	owner.Position = UDim2.new(0, 0, 0.5, 0)
	owner.BackgroundTransparency = 1
	owner.Text = "Empty - walk in to claim it"
	owner.TextColor3 = Color3.fromRGB(200, 255, 200)
	owner.TextSize = 20
	owner.TextScaled = true
	owner.Font = Enum.Font.Gotham
	owner.Parent = gui

	return gui
end

local function refreshBaseSign(baseIndex)
	local base = GameState.bases[baseIndex]
	local gui = base.signGui
	if not gui then
		return
	end
	local ownerLabel = gui:FindFirstChild("OwnerLabel")
	if not ownerLabel then
		return
	end
	if base.owner then
		local lockedText = ""
		if base.lockedUntil > os.time() then
			lockedText = "  [LOCKED " .. tostring(base.lockedUntil - os.time()) .. "s]"
		end
		ownerLabel.Text = base.owner.DisplayName .. "'s base" .. lockedText
	else
		ownerLabel.Text = "Empty - walk in to claim it"
	end
end

local function buildBaseExtras(baseIndex)
	local folder = Instance.new("Folder")
	folder.Name = "Base" .. tostring(baseIndex) .. "Brainrots"
	folder.Parent = workspace
	GameState.bases[baseIndex].folder = folder

	local signPart = workspace:FindFirstChild("Base" .. tostring(baseIndex) .. "_NameSign")
	if signPart then
		GameState.bases[baseIndex].signGui = makeSignGui(baseIndex, signPart)
	end

	-- Pale pads mark every slot a brainrot can sit on.
	for slotIndex = 1, GameState.MAX_SLOTS do
		local position = GameState.slotPosition(baseIndex, slotIndex)
		local pad = Instance.new("Part")
		pad.Name = "SlotPad" .. tostring(slotIndex)
		pad.Size = Vector3.new(4.5, 0.2, 4.5)
		pad.Position = Vector3.new(position.X, 1.6, position.Z)
		pad.Color = GameState.BASES[baseIndex].color
		pad.Transparency = 0.6
		pad.Anchored = true
		pad.CanCollide = false
		pad.Material = Enum.Material.Neon
		pad.Parent = folder
	end
end

-- First free base goes to the joining player; a full server spectates.
function BaseService_assignBaseToPlayer(player)
	for baseIndex, base in ipairs(GameState.bases) do
		if base.owner == nil then
			base.owner = player
			local data = GameState.ensurePlayerData(player)
			data.baseIndex = baseIndex
			refreshBaseSign(baseIndex)
			GameState.notifyPlayer(player, "Welcome to Brainrot Blast! Your base is " .. GameState.BASES[baseIndex].name .. ".")
			return baseIndex
		end
	end
	GameState.notifyPlayer(player, "All bases are taken right now - spectating!")
	return 0
end

function BaseService_upgradeBaseCapacity(player)
	local data = GameState.ensurePlayerData(player)
	if data.baseIndex == 0 then
		GameState.notifyPlayer(player, "You have no base to upgrade!")
		return
	end
	local base = GameState.bases[data.baseIndex]
	if base.slotCount >= GameState.MAX_SLOTS then
		GameState.notifyPlayer(player, "Your base is already at max capacity!")
		return
	end
	local step = (base.slotCount - GameState.START_SLOTS) / 2 + 1
	local cost = UPGRADE_STEPS[step]
	if not cost then
		GameState.notifyPlayer(player, "Your base is already at max capacity!")
		return
	end
	if data.cash < cost then
		GameState.notifyPlayer(player, "Upgrade costs $" .. tostring(cost) .. " - keep earning!")
		return
	end
	data.cash -= cost
	base.slotCount += 2
	GameState.syncLeaderstats(player)
	GameState.notifyPlayer(player, "Base upgraded! You now have " .. tostring(base.slotCount) .. " slots.")
end

for baseIndex = 1, #GameState.BASES do
	buildBaseExtras(baseIndex)
end

Players.PlayerAdded:Connect(function(player)
	BaseService_assignBaseToPlayer(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	BaseService_assignBaseToPlayer(player)
end

UpgradeBase.OnServerEvent:Connect(function(player)
	BaseService_upgradeBaseCapacity(player)
end)

-- Keep lock timers visible on the signs.
task.spawn(function()
	while true do
		task.wait(1)
		for baseIndex, base in ipairs(GameState.bases) do
			if base.owner and base.lockedUntil > 0 and base.lockedUntil - os.time() <= 0 then
				base.lockedUntil = 0
				refreshBaseSign(baseIndex)
			elseif base.owner and base.lockedUntil > os.time() then
				refreshBaseSign(baseIndex)
			end
		end
	end
end)

print("BaseService ready: 8 bases, slots start at " .. tostring(GameState.START_SLOTS))
