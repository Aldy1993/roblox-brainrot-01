-- Brainrot Blast: every character, rarity and mutation in the game.
-- All names are original inventions for this game. No HttpService, no
-- external asset ids: each brainrot is built at runtime from plain Parts.

local BrainrotData = {}

BrainrotData.RARITY_ORDER = { "Common", "Rare", "Epic", "Legendary", "Mythic", "Brainrot God" }

BrainrotData.RARITY_COLORS = {
	Common = Color3.fromRGB(180, 180, 180),
	Rare = Color3.fromRGB(60, 160, 255),
	Epic = Color3.fromRGB(170, 80, 255),
	Legendary = Color3.fromRGB(255, 170, 0),
	Mythic = Color3.fromRGB(255, 60, 120),
	["Brainrot God"] = Color3.fromRGB(255, 215, 0),
}

-- Chance a spawned brainrot lands in each rarity band (out of 100).
BrainrotData.RARITY_WEIGHTS = {
	Common = 40,
	Rare = 28,
	Epic = 16,
	Legendary = 9,
	Mythic = 5,
	["Brainrot God"] = 2,
}

-- The cast. cost is the buy price, income is cash per second at x1.
-- bodyColor / headColor paint the Part model; accessory picks the extra
-- piece the model builder sticks on top.
BrainrotData.CAST = {
	{ name = "Noodle Cat", rarity = "Common", cost = 10, income = 1, bodyColor = Color3.fromRGB(255, 220, 130), headColor = Color3.fromRGB(255, 240, 180), accessory = "ears", accessoryColor = Color3.fromRGB(255, 220, 130) },
	{ name = "Toilet Duck", rarity = "Common", cost = 25, income = 2, bodyColor = Color3.fromRGB(255, 235, 80), headColor = Color3.fromRGB(255, 245, 150), accessory = "hat", accessoryColor = Color3.fromRGB(240, 240, 240) },
	{ name = "Banana Shark", rarity = "Rare", cost = 100, income = 5, bodyColor = Color3.fromRGB(255, 220, 60), headColor = Color3.fromRGB(120, 170, 255), accessory = "fin", accessoryColor = Color3.fromRGB(90, 140, 230) },
	{ name = "Pizza Rat King", rarity = "Rare", cost = 250, income = 12, bodyColor = Color3.fromRGB(150, 110, 80), headColor = Color3.fromRGB(180, 140, 100), accessory = "crown", accessoryColor = Color3.fromRGB(255, 215, 0) },
	{ name = "Skibidi Toaster", rarity = "Epic", cost = 1000, income = 30, bodyColor = Color3.fromRGB(200, 200, 210), headColor = Color3.fromRGB(120, 120, 130), accessory = "antenna", accessoryColor = Color3.fromRGB(255, 80, 80) },
	{ name = "Cursed Croissant", rarity = "Epic", cost = 2500, income = 75, bodyColor = Color3.fromRGB(220, 160, 70), headColor = Color3.fromRGB(240, 190, 100), accessory = "horn", accessoryColor = Color3.fromRGB(90, 40, 140) },
	{ name = "Giga Chad Hamster", rarity = "Legendary", cost = 10000, income = 200, bodyColor = Color3.fromRGB(255, 180, 90), headColor = Color3.fromRGB(255, 205, 130), accessory = "crown", accessoryColor = Color3.fromRGB(255, 215, 0) },
	{ name = "Quantum Pickle", rarity = "Legendary", cost = 25000, income = 500, bodyColor = Color3.fromRGB(90, 200, 90), headColor = Color3.fromRGB(140, 230, 120), accessory = "halo", accessoryColor = Color3.fromRGB(255, 240, 150) },
	{ name = "Elon Muskrat", rarity = "Mythic", cost = 100000, income = 1500, bodyColor = Color3.fromRGB(110, 110, 120), headColor = Color3.fromRGB(190, 190, 200), accessory = "wings", accessoryColor = Color3.fromRGB(200, 200, 220) },
	{ name = "Void Spaghetti Monster", rarity = "Mythic", cost = 250000, income = 4000, bodyColor = Color3.fromRGB(60, 20, 90), headColor = Color3.fromRGB(120, 50, 170), accessory = "horn", accessoryColor = Color3.fromRGB(170, 60, 220) },
	{ name = "Sigma Granny", rarity = "Brainrot God", cost = 1000000, income = 10000, bodyColor = Color3.fromRGB(200, 160, 220), headColor = Color3.fromRGB(230, 200, 240), accessory = "halo", accessoryColor = Color3.fromRGB(255, 215, 0) },
	{ name = "Ohio Final Boss", rarity = "Brainrot God", cost = 5000000, income = 50000, bodyColor = Color3.fromRGB(40, 40, 45), headColor = Color3.fromRGB(255, 60, 60), accessory = "crown", accessoryColor = Color3.fromRGB(255, 215, 0) },
}

-- Mutations multiply the $/second. Rolled once when a brainrot spawns.
BrainrotData.MUTATIONS = {
	{ name = "Normal", mult = 1, weight = 80, color = Color3.fromRGB(255, 255, 255) },
	{ name = "Golden", mult = 5, weight = 12, color = Color3.fromRGB(255, 215, 0) },
	{ name = "Diamond", mult = 10, weight = 6, color = Color3.fromRGB(120, 220, 255) },
	{ name = "Rainbow", mult = 25, weight = 2, color = Color3.fromRGB(255, 120, 220) },
}

local nextId = 0

function BrainrotData.formatMoney(amount)
	amount = math.floor(amount + 0.5)
	if amount >= 1000000 then
		return string.format("$%.2fM", amount / 1000000)
	elseif amount >= 10000 then
		return string.format("$%.1fK", amount / 1000)
	else
		return "$" .. tostring(amount)
	end
end

function BrainrotData.rollMutation()
	local roll = math.random(1, 100)
	local running = 0
	for _, mutation in ipairs(BrainrotData.MUTATIONS) do
		running += mutation.weight
		if roll <= running then
			return mutation
		end
	end
	return BrainrotData.MUTATIONS[1]
end

function BrainrotData.pickRandomBrainrot()
	local roll = math.random(1, 100)
	local running = 0
	local pickedRarity = "Common"
	for _, rarity in ipairs(BrainrotData.RARITY_ORDER) do
		running += BrainrotData.RARITY_WEIGHTS[rarity]
		if roll <= running then
			pickedRarity = rarity
			break
		end
	end
	local pool = {}
	for _, entry in ipairs(BrainrotData.CAST) do
		if entry.rarity == pickedRarity then
			table.insert(pool, entry)
		end
	end
	return pool[math.random(1, #pool)]
end

-- One fresh brainrot: a cast entry plus a rolled mutation and a unique id.
function BrainrotData.newBrainrotRecord()
	nextId += 1
	local entry = BrainrotData.pickRandomBrainrot()
	local mutation = BrainrotData.rollMutation()
	return {
		id = "br" .. tostring(nextId) .. "_" .. tostring(os.time()),
		name = entry.name,
		rarity = entry.rarity,
		cost = entry.cost,
		baseIncome = entry.income,
		income = entry.income * mutation.mult,
		mutation = mutation.name,
		mutationMult = mutation.mult,
		bodyColor = entry.bodyColor,
		headColor = entry.headColor,
		accessory = entry.accessory,
		accessoryColor = entry.accessoryColor,
	}
end

local function makePart(name, size, color, position, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.SmoothPlastic
	if shape then
		part.Shape = shape
	end
	return part
end

local function makeLabel(name, order, text, color, textSize)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = UDim2.new(1, 0, 0.34, 0)
	label.Position = UDim2.new(0, 0, order * 0.33, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextSize = textSize
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextStrokeTransparency = 0.4
	return label
end

-- Builds the visible 3D model for a brainrot record: body, head, feet,
-- one accessory piece, and a floating label with name, rarity and $/sec.
function BrainrotData.buildBrainrotModel(record)
	local model = Instance.new("Model")
	model.Name = record.name:gsub(" ", "") .. "_" .. record.id

	local body = makePart("Body", Vector3.new(3, 3, 2), record.bodyColor, Vector3.new(0, 0, 0))
	body.Parent = model
	model.PrimaryPart = body

	local head = makePart("Head", Vector3.new(2, 2, 2), record.headColor, Vector3.new(0, 2.5, 0))
	head.Parent = model

	local footLeft = makePart("FootLeft", Vector3.new(1, 1, 1.5), record.headColor, Vector3.new(-0.8, -1.8, 0))
	footLeft.Parent = model
	local footRight = makePart("FootRight", Vector3.new(1, 1, 1.5), record.headColor, Vector3.new(0.8, -1.8, 0))
	footRight.Parent = model

	local kind = record.accessory
	if kind == "ears" then
		local earLeft = makePart("EarLeft", Vector3.new(0.8, 1.2, 0.8), record.accessoryColor, Vector3.new(-0.8, 3.9, 0))
		earLeft.Parent = model
		local earRight = makePart("EarRight", Vector3.new(0.8, 1.2, 0.8), record.accessoryColor, Vector3.new(0.8, 3.9, 0))
		earRight.Parent = model
	elseif kind == "fin" then
		local fin = makePart("Fin", Vector3.new(0.6, 2, 2.4), record.accessoryColor, Vector3.new(0, 3.7, 0))
		fin.Parent = model
	elseif kind == "crown" then
		local crown = makePart("Crown", Vector3.new(2.4, 0.8, 2.4), record.accessoryColor, Vector3.new(0, 3.9, 0))
		crown.Parent = model
	elseif kind == "hat" then
		local hat = makePart("Hat", Vector3.new(3, 0.8, 3), record.accessoryColor, Vector3.new(0, 3.9, 0))
		hat.Parent = model
	elseif kind == "antenna" then
		local stick = makePart("Antenna", Vector3.new(0.4, 2, 0.4), record.accessoryColor, Vector3.new(0, 4.4, 0))
		stick.Parent = model
		local tip = makePart("AntennaTip", Vector3.new(1, 1, 1), record.accessoryColor, Vector3.new(0, 5.6, 0), Enum.PartType.Ball)
		tip.Parent = model
	elseif kind == "horn" then
		local horn = makePart("Horn", Vector3.new(0.8, 1.8, 0.8), record.accessoryColor, Vector3.new(0, 4, 0))
		horn.Parent = model
	elseif kind == "halo" then
		local halo = makePart("Halo", Vector3.new(3, 0.4, 3), record.accessoryColor, Vector3.new(0, 4.3, 0))
		halo.Parent = model
	elseif kind == "wings" then
		local wingLeft = makePart("WingLeft", Vector3.new(2.5, 0.4, 1.5), record.accessoryColor, Vector3.new(-2.4, 0.8, 0))
		wingLeft.Parent = model
		local wingRight = makePart("WingRight", Vector3.new(2.5, 0.4, 1.5), record.accessoryColor, Vector3.new(2.4, 0.8, 0))
		wingRight.Parent = model
	end

	local displayName = record.name
	if record.mutation ~= "Normal" then
		displayName = record.mutation .. " " .. record.name
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "BrainrotLabel"
	billboard.Adornee = body
	billboard.Size = UDim2.new(0, 220, 0, 90)
	billboard.StudsOffset = Vector3.new(0, 5.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = model

	local nameLabel = makeLabel("NameLabel", 0, displayName, Color3.fromRGB(255, 255, 255), 22)
	nameLabel.Parent = billboard
	local rarityLabel = makeLabel("RarityLabel", 1, record.rarity, BrainrotData.RARITY_COLORS[record.rarity], 20)
	rarityLabel.Parent = billboard
	local incomeLabel = makeLabel("IncomeLabel", 2, BrainrotData.formatMoney(record.income) .. "/s  |  " .. BrainrotData.formatMoney(record.cost), Color3.fromRGB(120, 255, 140), 20)
	incomeLabel.Parent = billboard

	return model
end

return BrainrotData
