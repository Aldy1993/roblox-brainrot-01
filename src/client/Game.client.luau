-- Brainrot Blast client HUD: cash and income up top in the middle (never the
-- top-left corner, where Roblox puts its own menu buttons), action buttons
-- down the right side, a shop price list on the left, and a tsunami banner.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotData = require(ReplicatedStorage:WaitForChild("BrainrotData"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local LockBase = ReplicatedStorage:WaitForChild("LockBase")
local RequestRebirth = ReplicatedStorage:WaitForChild("RequestRebirth")
local UpgradeBase = ReplicatedStorage:WaitForChild("UpgradeBase")
local GameEvent = ReplicatedStorage:WaitForChild("GameEvent")

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotBlastGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

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
	button.Font = Enum.Font.GothamBold
	button.TextWrapped = true
	button.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	return button
end

-- Top-middle wallet bar: cash, income per second, rebirths.
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.AnchorPoint = Vector2.new(0.5, 0)
topBar.Position = UDim2.new(0.5, 0, 0, 12)
topBar.Size = UDim2.new(0, 460, 0, 56)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
topBar.BackgroundTransparency = 0.25
topBar.BorderSizePixel = 0
topBar.Parent = gui
local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topBar

local cashLabel = makeLabel(topBar, "CashLabel", UDim2.new(0, 12, 0, 4), UDim2.new(0.55, 0, 0.5, 0), "Cash: $100", 22, Color3.fromRGB(120, 255, 140))
local incomeLabel = makeLabel(topBar, "IncomeLabel", UDim2.new(0.58, 0, 0, 4), UDim2.new(0.42, -8, 0.5, 0), "$0/s", 22, Color3.fromRGB(120, 220, 255))
local rebirthLabel = makeLabel(topBar, "RebirthLabel", UDim2.new(0, 12, 0, 30), UDim2.new(1, -12, 0.5, 0), "Rebirths: 0  |  Multiplier: x1", 16, Color3.fromRGB(255, 220, 120))

-- Tsunami banner, hidden until a warning arrives.
local tsunamiBanner = Instance.new("Frame")
tsunamiBanner.Name = "TsunamiBanner"
tsunamiBanner.AnchorPoint = Vector2.new(0.5, 0)
tsunamiBanner.Position = UDim2.new(0.5, 0, 0, 78)
tsunamiBanner.Size = UDim2.new(0, 460, 0, 44)
tsunamiBanner.BackgroundColor3 = Color3.fromRGB(30, 120, 255)
tsunamiBanner.BorderSizePixel = 0
tsunamiBanner.Visible = false
tsunamiBanner.Parent = gui
local bannerCorner = Instance.new("UICorner")
bannerCorner.CornerRadius = UDim.new(0, 10)
bannerCorner.Parent = tsunamiBanner
local tsunamiLabel = makeLabel(tsunamiBanner, "TsunamiLabel", UDim2.new(0, 8, 0, 0), UDim2.new(1, -16, 1, 0), "TSUNAMI INCOMING!", 22, Color3.fromRGB(255, 255, 255))
tsunamiLabel.TextScaled = true

-- Right-side action buttons.
local buttonPanel = Instance.new("Frame")
buttonPanel.Name = "ButtonPanel"
buttonPanel.AnchorPoint = Vector2.new(1, 0)
buttonPanel.Position = UDim2.new(1, -16, 0, 140)
buttonPanel.Size = UDim2.new(0, 210, 0, 250)
buttonPanel.BackgroundTransparency = 1
buttonPanel.Parent = gui

local stealButton = makeButton(buttonPanel, "StealButton", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 52), "STEAL: click a brainrot in another base!", Color3.fromRGB(180, 60, 60))
local lockButton = makeButton(buttonPanel, "LockButton", UDim2.new(0, 0, 0, 62), UDim2.new(1, 0, 0, 52), "LOCK BASE ($250 - 60s)", Color3.fromRGB(60, 90, 200))
local rebirthButton = makeButton(buttonPanel, "RebirthButton", UDim2.new(0, 0, 0, 124), UDim2.new(1, 0, 0, 52), "REBIRTH (x2 income)", Color3.fromRGB(150, 60, 200))
local upgradeButton = makeButton(buttonPanel, "UpgradeButton", UDim2.new(0, 0, 0, 186), UDim2.new(1, 0, 0, 52), "UPGRADE BASE (+2 slots)", Color3.fromRGB(40, 150, 70))

-- Left-side shop list, built from the same data the server uses.
local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopFrame"
shopFrame.AnchorPoint = Vector2.new(0, 0.5)
shopFrame.Position = UDim2.new(0, 16, 0.5, 0)
shopFrame.Size = UDim2.new(0, 250, 0, 300)
shopFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
shopFrame.BackgroundTransparency = 0.25
shopFrame.BorderSizePixel = 0
shopFrame.Parent = gui
local shopCorner = Instance.new("UICorner")
shopCorner.CornerRadius = UDim.new(0, 10)
shopCorner.Parent = shopFrame

local shopTitle = makeLabel(shopFrame, "ShopTitle", UDim2.new(0, 10, 0, 6), UDim2.new(1, -20, 0, 26), "SHOP - watch the belt!", 18, Color3.fromRGB(255, 220, 120))
local shopList = Instance.new("TextLabel")
shopList.Name = "ShopList"
shopList.Position = UDim2.new(0, 10, 0, 36)
shopList.Size = UDim2.new(1, -20, 1, -46)
shopList.BackgroundTransparency = 1
shopList.TextXAlignment = Enum.TextXAlignment.Left
shopList.TextYAlignment = Enum.TextYAlignment.Top
shopList.TextSize = 14
shopList.TextColor3 = Color3.fromRGB(230, 230, 230)
shopList.Font = Enum.Font.Gotham
shopList.TextWrapped = true
shopList.Parent = shopFrame

local shopLines = {}
for _, entry in ipairs(BrainrotData.CAST) do
	table.insert(shopLines, entry.name .. " (" .. entry.rarity .. ") - " .. BrainrotData.formatMoney(entry.cost) .. " / " .. BrainrotData.formatMoney(entry.income) .. "/s")
end
shopList.Text = table.concat(shopLines, "\n")

-- Bottom-middle message line for server feedback.
local messageLabel = makeLabel(gui, "MessageLabel", UDim2.new(0.5, -300, 1, -40), UDim2.new(600, 0, 0, 30), "", 18, Color3.fromRGB(255, 255, 255))
messageLabel.AnchorPoint = Vector2.new(0.5, 0)
messageLabel.TextScaled = true

local hintLabel = makeLabel(gui, "HintLabel", UDim2.new(0, 16, 1, -76), UDim2.new(420, 0, 0, 30), "Walk to the belt, hold E on a brainrot to buy it. Guard your base!", 14, Color3.fromRGB(220, 220, 220))
hintLabel.TextXAlignment = Enum.TextXAlignment.Left

local messageToken = 0
local function showMessage(text)
	messageToken += 1
	local token = messageToken
	messageLabel.Text = text
	task.delay(4, function()
		if token == messageToken then
			messageLabel.Text = ""
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
		local multiplier = 2 ^ rebirths.Value
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
