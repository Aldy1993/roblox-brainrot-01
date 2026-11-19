-- Brainrot Blast client HUD: cash and income up top in the middle (never the
-- top-left corner, where Roblox puts its own menu buttons), action buttons
-- down the right side, a shop price list on the left, and a tsunami banner.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local BrainrotData = require(ReplicatedStorage:WaitForChild("BrainrotData"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local LockBase = ReplicatedStorage:WaitForChild("LockBase")
local RequestRebirth = ReplicatedStorage:WaitForChild("RequestRebirth")
local UpgradeBase = ReplicatedStorage:WaitForChild("UpgradeBase")
local GameEvent = ReplicatedStorage:WaitForChild("GameEvent")

-- Golden Hour x2 (from the server), the brainrot names this player has
-- ever owned (for the Index grid), and the token that kills a stale
-- Golden Hour countdown when a new one starts. All arrive over GameEvent.
local goldenMultiplier = 1
local goldenToken = 0
local foundNames = {}

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotBlastGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

-- Hide Roblox's default "People" player list: measured from the user's
-- Studio Play screenshot, it covers the right end of the TopBar, and the
-- TopBar already shows the local player's cash/income/rebirths, so hiding
-- it loses nothing. pcall + a 2s retry because the call can fail if
-- CoreGui isn't ready yet when this LocalScript runs.
local function hidePlayerList()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	end)
end
hidePlayerList()
task.delay(2, hidePlayerList)

-- Clamp a scale-sized panel so it never gets too small on a tiny viewport
-- or too wide on a big one.
local function addSizeConstraint(instance, minSize, maxSize)
	local constraint = Instance.new("UISizeConstraint")
	constraint.MinSize = minSize
	constraint.MaxSize = maxSize
	constraint.Parent = instance
	return constraint
end

local function makeLabel(parent, name, position, size, text, textSize, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Position = position
	label.Size = size
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextSize = textSize
	label.TextColor3 = color
	label.Font = Enum.Font.GothamBold
	label.TextScaled = false
	label.Parent = parent
	return label
end

local function makeButton(parent, name, position, size, text, color)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 18
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.TextWrapped = true
	button.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	return button
end

-- One helper for every rounded panel: frame + optional corner, so the
-- seven HUD panels below are each a single call with identical geometry.
-- color nil = leave the default; cornerRadius nil = no rounded corner.
local function makePanel(parent, name, anchor, position, size, color, transparency, cornerRadius)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.AnchorPoint = anchor
	frame.Position = position
	frame.Size = size
	if color then
		frame.BackgroundColor3 = color
	end
	frame.BackgroundTransparency = transparency
	frame.BorderSizePixel = 0
	frame.Parent = parent
	if cornerRadius then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, cornerRadius)
		corner.Parent = frame
	end
	return frame
end

-- Top-middle wallet bar: cash, income per second, rebirths. Scale-wide with a
-- clamp so it stays clear of the top-left menu buttons at any viewport size.
-- The default player list (which used to cover its right end) is hidden above.
local topBar = makePanel(gui, "TopBar", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 8), UDim2.new(0.32, 0, 0, 56), Color3.fromRGB(20, 20, 30), 0.25, 10)
addSizeConstraint(topBar, Vector2.new(300, 56), Vector2.new(420, 56))

local cashLabel = makeLabel(topBar, "CashLabel", UDim2.new(0, 12, 0, 4), UDim2.new(0.55, 0, 0.5, 0), "Cash: $100", 22, Color3.fromRGB(120, 255, 140))
local incomeLabel = makeLabel(topBar, "IncomeLabel", UDim2.new(0.58, 0, 0, 4), UDim2.new(0.42, -8, 0.5, 0), "$0/s", 22, Color3.fromRGB(120, 220, 255))
local rebirthLabel = makeLabel(topBar, "RebirthLabel", UDim2.new(0, 12, 0, 30), UDim2.new(1, -12, 0.5, 0), "Rebirths: 0  |  Multiplier: x1", 16, Color3.fromRGB(255, 220, 120))
cashLabel.TextScaled = true
incomeLabel.TextScaled = true
rebirthLabel.TextScaled = true

-- Tsunami banner, hidden until a warning arrives.
local tsunamiBanner = makePanel(gui, "TsunamiBanner", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 72), UDim2.new(0.32, 0, 0, 44), Color3.fromRGB(30, 120, 255), 0, 10)
tsunamiBanner.Visible = false
addSizeConstraint(tsunamiBanner, Vector2.new(300, 44), Vector2.new(420, 44))
local tsunamiLabel = makeLabel(tsunamiBanner, "TsunamiLabel", UDim2.new(0, 8, 0, 0), UDim2.new(1, -16, 1, 0), "TSUNAMI INCOMING!", 22, Color3.fromRGB(255, 255, 255))
tsunamiLabel.TextScaled = true

-- Golden Hour banner, yellow, under the tsunami banner so the two never
-- overlap even when both events run at once.
local goldenBanner = makePanel(gui, "GoldenHourBanner", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 122), UDim2.new(0.32, 0, 0, 44), Color3.fromRGB(255, 200, 0), 0, 10)
goldenBanner.Visible = false
addSizeConstraint(goldenBanner, Vector2.new(300, 44), Vector2.new(420, 44))
local goldenLabel = makeLabel(goldenBanner, "GoldenHourLabel", UDim2.new(0, 8, 0, 0), UDim2.new(1, -16, 1, 0), "GOLDEN HOUR! BASES PAY x2", 22, Color3.fromRGB(20, 20, 30))
goldenLabel.TextScaled = true

-- Right-side action buttons, anchored to the bottom-right corner so they
-- never collide with the leaderboard (top-right) or the bottom-centre
-- message line. Buttons are laid out by a UIListLayout with scale heights
-- so they always fit the panel exactly.
local buttonPanel = makePanel(gui, "ButtonPanel", Vector2.new(1, 1), UDim2.new(1, -12, 1, -12), UDim2.new(0.16, 0, 0.5, 0), nil, 1, nil)
addSizeConstraint(buttonPanel, Vector2.new(180, 220), Vector2.new(230, 280))

local buttonList = Instance.new("UIListLayout")
buttonList.FillDirection = Enum.FillDirection.Vertical
buttonList.Padding = UDim.new(0, 5)
buttonList.SortOrder = Enum.SortOrder.LayoutOrder
buttonList.Parent = buttonPanel

local stealButton = makeButton(buttonPanel, "StealButton", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0.18, 0), "STEAL: click a brainrot in another base!", Color3.fromRGB(180, 60, 60))
stealButton.LayoutOrder = 1
local lockButton = makeButton(buttonPanel, "LockButton", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0.18, 0), "LOCK BASE ($250 - 60s)", Color3.fromRGB(60, 90, 200))
lockButton.LayoutOrder = 2
local rebirthButton = makeButton(buttonPanel, "RebirthButton", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0.18, 0), "REBIRTH (x2 income)", Color3.fromRGB(150, 60, 200))
rebirthButton.LayoutOrder = 3
local upgradeButton = makeButton(buttonPanel, "UpgradeButton", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0.18, 0), "UPGRADE BASE (+2 slots)", Color3.fromRGB(40, 150, 70))
upgradeButton.LayoutOrder = 4
local indexButton = makeButton(buttonPanel, "IndexButton", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0.18, 0), "INDEX (0/" .. tostring(#BrainrotData.CAST) .. " found)", Color3.fromRGB(60, 120, 220))
indexButton.LayoutOrder = 5

-- Left-side shop list, built from the same data the server uses. It sits
-- BELOW the Roblox chat window (top-left), so its top starts at 46% of
-- screen height, and the entries live in a ScrollingFrame with one label
-- per brainrot, so long names wrap to a second line instead of spilling
-- over the title or out of the frame.
local shopFrame = makePanel(gui, "ShopFrame", Vector2.new(0, 0), UDim2.new(0, 12, 0.46, 0), UDim2.new(0.20, 0, 0.50, 0), Color3.fromRGB(20, 20, 30), 0.25, 10)
addSizeConstraint(shopFrame, Vector2.new(200, 230), Vector2.new(300, 420))

local shopTitle = makeLabel(shopFrame, "ShopTitle", UDim2.new(0, 10, 0, 6), UDim2.new(1, -20, 0, 26), "SHOP - watch the belt!", 18, Color3.fromRGB(255, 220, 120))
shopTitle.TextScaled = true

local shopScroll = Instance.new("ScrollingFrame")
shopScroll.Name = "ShopList"
shopScroll.Position = UDim2.new(0, 10, 0, 38)
shopScroll.Size = UDim2.new(1, -20, 1, -48)
shopScroll.BackgroundTransparency = 1
shopScroll.BorderSizePixel = 0
shopScroll.ScrollBarThickness = 4
shopScroll.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140)
shopScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
shopScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
shopScroll.Parent = shopFrame

local shopListLayout = Instance.new("UIListLayout")
shopListLayout.Padding = UDim.new(0, 2)
shopListLayout.SortOrder = Enum.SortOrder.LayoutOrder
shopListLayout.Parent = shopScroll

for _, entry in ipairs(BrainrotData.CAST) do
	local line = makeLabel(shopScroll, "ShopEntry", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 18), entry.name .. " (" .. entry.rarity .. ") - " .. BrainrotData.formatMoney(entry.cost) .. " / " .. BrainrotData.formatMoney(entry.income) .. "/s", 13, Color3.fromRGB(230, 230, 230))
	line.AutomaticSize = Enum.AutomaticSize.Y
	line.TextXAlignment = Enum.TextXAlignment.Left
	line.TextYAlignment = Enum.TextYAlignment.Top
	line.Font = Enum.Font.Gotham
	line.TextWrapped = true
end

-- Bottom-centre lines, stacked and scale-wide: the hint sits above the
-- message line. Both are centred, so they stay clear of the shop frame
-- (left) and the button panel (bottom-right) at any viewport size.
local messageLabel = makeLabel(gui, "MessageLabel", UDim2.new(0.5, 0, 1, -44), UDim2.new(0.55, 0, 0, 30), "", 18, Color3.fromRGB(255, 255, 255))
messageLabel.AnchorPoint = Vector2.new(0.5, 0)
messageLabel.TextScaled = true
messageLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
messageLabel.BackgroundTransparency = 1
local messageCorner = Instance.new("UICorner")
messageCorner.CornerRadius = UDim.new(0, 8)
messageCorner.Parent = messageLabel

local hintLabel = makeLabel(gui, "HintLabel", UDim2.new(0.5, 0, 1, -80), UDim2.new(0.45, 0, 0, 30), "Walk to the belt, hold E on a brainrot to buy it. Guard your base!", 14, Color3.fromRGB(220, 220, 220))
hintLabel.AnchorPoint = Vector2.new(0.5, 0)
hintLabel.TextScaled = true
hintLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
hintLabel.BackgroundTransparency = 0.35
local hintCorner = Instance.new("UICorner")
hintCorner.CornerRadius = UDim.new(0, 8)
hintCorner.Parent = hintLabel

-- Mission bar, bottom-centre above the hint line: the current mission,
-- its progress and its cash reward. The server sends MissionUpdate
-- whenever progress moves or a mission is completed.
local missionBar = makePanel(gui, "MissionBar", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 1, -118), UDim2.new(0.55, 0, 0, 32), Color3.fromRGB(20, 20, 60), 0.25, 8)
local missionLabel = makeLabel(missionBar, "MissionLabel", UDim2.new(0, 10, 0, 0), UDim2.new(1, -20, 1, 0), "MISSION 1/7: Buy your first brainrot  0/1  +$100", 16, Color3.fromRGB(255, 255, 255))
missionLabel.TextScaled = true

-- Index grid: every brainrot in the game, one cell each. Found ones show
-- their name in their rarity colour; the rest stay grey with a "?".
-- Toggled by the INDEX button, hidden by default so it never covers the
-- game while playing.
local indexFrame = makePanel(gui, "IndexFrame", Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0), UDim2.new(0.5, 0, 0.6, 0), Color3.fromRGB(20, 20, 30), 0.1, 12)
indexFrame.Visible = false
addSizeConstraint(indexFrame, Vector2.new(420, 300), Vector2.new(640, 480))

local indexTitle = makeLabel(indexFrame, "IndexTitle", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 30), "BRAINROT INDEX - 0/" .. tostring(#BrainrotData.CAST) .. " found", 20, Color3.fromRGB(255, 220, 120))
indexTitle.TextScaled = true

local indexScroll = Instance.new("ScrollingFrame")
indexScroll.Name = "IndexGrid"
indexScroll.Position = UDim2.new(0, 12, 0, 46)
indexScroll.Size = UDim2.new(1, -24, 1, -58)
indexScroll.BackgroundTransparency = 1
indexScroll.BorderSizePixel = 0
indexScroll.ScrollBarThickness = 4
indexScroll.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140)
indexScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
indexScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
indexScroll.Parent = indexFrame

local indexGrid = Instance.new("UIGridLayout")
indexGrid.CellSize = UDim2.new(0, 92, 0, 52)
indexGrid.CellPadding = UDim2.new(0, 6, 0, 6)
indexGrid.SortOrder = Enum.SortOrder.LayoutOrder
indexGrid.Parent = indexScroll

local indexCells = {}
for order, entry in ipairs(BrainrotData.CAST) do
	local cell = Instance.new("Frame")
	cell.Name = "IndexCell"
	cell.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	cell.BorderSizePixel = 0
	cell.LayoutOrder = order
	cell.Parent = indexScroll
	local cellCorner = Instance.new("UICorner")
	cellCorner.CornerRadius = UDim.new(0, 6)
	cellCorner.Parent = cell
	local cellName = makeLabel(cell, "CellName", UDim2.new(0, 4, 0, 4), UDim2.new(1, -8, 0, 22), "?", 12, Color3.fromRGB(180, 180, 180))
	cellName.TextScaled = true
	cellName.TextWrapped = true
	local cellRarity = makeLabel(cell, "CellRarity", UDim2.new(0, 4, 0, 28), UDim2.new(1, -8, 0, 20), entry.rarity, 11, Color3.fromRGB(150, 150, 150))
	cellRarity.TextScaled = true
	indexCells[entry.name] = { frame = cell, nameLabel = cellName, rarityLabel = cellRarity, rarity = entry.rarity }
end

local function refreshIndex()
	local foundCount = 0
	for _ in pairs(foundNames) do
		foundCount += 1
	end
	indexTitle.Text = "BRAINROT INDEX - " .. tostring(foundCount) .. "/" .. tostring(#BrainrotData.CAST) .. " found"
	indexButton.Text = "INDEX (" .. tostring(foundCount) .. "/" .. tostring(#BrainrotData.CAST) .. " found)"
	for name, cell in pairs(indexCells) do
		if foundNames[name] then
			cell.frame.BackgroundColor3 = BrainrotData.RARITY_COLORS[cell.rarity]
			cell.nameLabel.Text = name
			cell.nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			cell.rarityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			cell.frame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			cell.nameLabel.Text = "?"
			cell.nameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
			cell.rarityLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		end
	end
end

local messageToken = 0
local function showMessage(text)
	messageToken += 1
	local token = messageToken
	messageLabel.Text = text
	messageLabel.BackgroundTransparency = 0.35
	task.delay(4, function()
		if token == messageToken then
			messageLabel.Text = ""
			messageLabel.BackgroundTransparency = 1
		end
	end)
end

local function refreshWallet()
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end
	local cash = leaderstats:FindFirstChild("Cash")
	local income = leaderstats:FindFirstChild("IncomePerSec")
	local rebirths = leaderstats:FindFirstChild("Rebirths")
	if cash then
		cashLabel.Text = "Cash: " .. BrainrotData.formatMoney(cash.Value)
	end
	if income and rebirths then
		incomeLabel.Text = BrainrotData.formatMoney(income.Value) .. "/s"
		-- Rebirth multiplier x Golden Hour multiplier (x2 while golden).
		local multiplier = (2 ^ rebirths.Value) * goldenMultiplier
		rebirthLabel.Text = "Rebirths: " .. tostring(rebirths.Value) .. "  |  Multiplier: x" .. tostring(multiplier)
	end
end

stealButton.MouseButton1Click:Connect(function()
	showMessage("Click a brainrot in ANOTHER player's base to steal it, then run home in 15s!")
end)

lockButton.MouseButton1Click:Connect(function()
	LockBase:FireServer()
end)

rebirthButton.MouseButton1Click:Connect(function()
	RequestRebirth:FireServer()
end)

upgradeButton.MouseButton1Click:Connect(function()
	UpgradeBase:FireServer()
end)

indexButton.MouseButton1Click:Connect(function()
	indexFrame.Visible = not indexFrame.Visible
	if indexFrame.Visible then
		refreshIndex()
	end
end)

GameEvent.OnClientEvent:Connect(function(kind, payload)
	if kind == "Notify" then
		showMessage(payload)
	elseif kind == "TsunamiWarning" then
		local seconds = payload or 10
		tsunamiBanner.Visible = true
		tsunamiLabel.Text = "TSUNAMI IN " .. tostring(seconds) .. "s - GET TO YOUR BASE!"
		task.spawn(function()
			for remaining = seconds - 1, 1, -1 do
				task.wait(1)
				if tsunamiBanner.Visible then
					tsunamiLabel.Text = "TSUNAMI IN " .. tostring(remaining) .. "s - GET TO YOUR BASE!"
				end
			end
		end)
	elseif kind == "TsunamiWave" then
		tsunamiLabel.Text = "TSUNAMI! HOLD ON!"
	elseif kind == "TsunamiOver" then
		tsunamiBanner.Visible = false
	elseif kind == "GoldenHourStart" then
		local seconds = payload or 60
		goldenMultiplier = 2
		refreshWallet()
		goldenToken += 1
		local token = goldenToken
		goldenBanner.Visible = true
		goldenLabel.Text = "GOLDEN HOUR! BASES PAY x2  " .. tostring(seconds) .. "s"
		task.spawn(function()
			for remaining = seconds - 1, 1, -1 do
				task.wait(1)
				if token ~= goldenToken or not goldenBanner.Visible then
					return
				end
				goldenLabel.Text = "GOLDEN HOUR! BASES PAY x2  " .. tostring(remaining) .. "s"
			end
		end)
	elseif kind == "GoldenHourEnd" then
		goldenMultiplier = 1
		goldenToken += 1
		refreshWallet()
		goldenBanner.Visible = false
	elseif kind == "MissionUpdate" then
		if payload then
			if payload.reward and payload.reward > 0 then
				missionLabel.Text = "MISSION " .. tostring(payload.index) .. "/" .. tostring(payload.total) .. ": " .. payload.name .. "  " .. tostring(payload.progress) .. "/" .. tostring(payload.goal) .. "  +$" .. tostring(payload.reward)
			else
				missionLabel.Text = payload.name
			end
		end
	elseif kind == "IndexUpdate" then
		foundNames = {}
		if payload then
			for _, name in ipairs(payload) do
				foundNames[name] = true
			end
		end
		refreshIndex()
	end
end)

local leaderstats = player:WaitForChild("leaderstats", 30)
if leaderstats then
	refreshWallet()
	for _, child in ipairs(leaderstats:GetChildren()) do
		child:GetPropertyChangedSignal("Value"):Connect(refreshWallet)
	end
end

showMessage("Welcome to Brainrot Blast! Buy brainrots off the belt and fill your base.")
