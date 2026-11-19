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
	{ name = "Soggy Cereal Goblin", rarity = "Common", cost = 15, income = 1, bodyColor = Color3.fromRGB(200, 170, 120), headColor = Color3.fromRGB(230, 200, 150), accessory = "ears", accessoryColor = Color3.fromRGB(200, 170, 120) },
	{ name = "Toilet Duck", rarity = "Common", cost = 25, income = 2, bodyColor = Color3.fromRGB(255, 235, 80), headColor = Color3.fromRGB(255, 245, 150), accessory = "hat", accessoryColor = Color3.fromRGB(240, 240, 240) },
	{ name = "Traffic Cone Crab", rarity = "Common", cost = 40, income = 3, bodyColor = Color3.fromRGB(255, 110, 40), headColor = Color3.fromRGB(255, 150, 80), accessory = "horn", accessoryColor = Color3.fromRGB(255, 200, 40) },
	{ name = "Bubblegum Pigeon", rarity = "Common", cost = 60, income = 4, bodyColor = Color3.fromRGB(255, 140, 200), headColor = Color3.fromRGB(255, 180, 220), accessory = "wings", accessoryColor = Color3.fromRGB(255, 120, 180) },
	{ name = "Couch Potato Knight", rarity = "Common", cost = 80, income = 4, bodyColor = Color3.fromRGB(140, 90, 60), headColor = Color3.fromRGB(180, 130, 90), accessory = "hat", accessoryColor = Color3.fromRGB(120, 120, 120) },
	{ name = "Banana Shark", rarity = "Rare", cost = 100, income = 5, bodyColor = Color3.fromRGB(255, 220, 60), headColor = Color3.fromRGB(120, 170, 255), accessory = "fin", accessoryColor = Color3.fromRGB(90, 140, 230) },
	{ name = "Disco Microwave", rarity = "Rare", cost = 175, income = 8, bodyColor = Color3.fromRGB(120, 120, 130), headColor = Color3.fromRGB(200, 200, 210), accessory = "antenna", accessoryColor = Color3.fromRGB(255, 80, 200) },
	{ name = "Pizza Rat King", rarity = "Rare", cost = 250, income = 12, bodyColor = Color3.fromRGB(150, 110, 80), headColor = Color3.fromRGB(180, 140, 100), accessory = "crown", accessoryColor = Color3.fromRGB(255, 215, 0) },
	{ name = "Sock Puppet Shark", rarity = "Rare", cost = 400, income = 18, bodyColor = Color3.fromRGB(120, 170, 255), headColor = Color3.fromRGB(200, 220, 255), accessory = "fin", accessoryColor = Color3.fromRGB(90, 140, 230) },
	{ name = "Angry Houseplant", rarity = "Rare", cost = 600, income = 25, bodyColor = Color3.fromRGB(60, 160, 60), headColor = Color3.fromRGB(120, 220, 120), accessory = "horn", accessoryColor = Color3.fromRGB(200, 60, 60) },
	{ name = "Skibidi Toaster", rarity = "Epic", cost = 1000, income = 30, bodyColor = Color3.fromRGB(200, 200, 210), headColor = Color3.fromRGB(120, 120, 130), accessory = "antenna", accessoryColor = Color3.fromRGB(255, 80, 80) },
	{ name = "Laser Llama", rarity = "Epic", cost = 1750, income = 55, bodyColor = Color3.fromRGB(240, 240, 240), headColor = Color3.fromRGB(255, 255, 255), accessory = "glasses", accessoryColor = Color3.fromRGB(40, 40, 40) },
	{ name = "Cursed Croissant", rarity = "Epic", cost = 2500, income = 75, bodyColor = Color3.fromRGB(220, 160, 70), headColor = Color3.fromRGB(240, 190, 100), accessory = "horn", accessoryColor = Color3.fromRGB(90, 40, 140) },
	{ name = "Invisible Mime", rarity = "Epic", cost = 3200, income = 95, bodyColor = Color3.fromRGB(220, 220, 230), headColor = Color3.fromRGB(240, 240, 245), accessory = "hat", accessoryColor = Color3.fromRGB(30, 30, 35) },
	{ name = "Haunted Vending Machine", rarity = "Epic", cost = 4000, income = 120, bodyColor = Color3.fromRGB(180, 60, 60), headColor = Color3.fromRGB(220, 100, 100), accessory = "antenna", accessoryColor = Color3.fromRGB(120, 220, 255) },
	{ name = "Giga Chad Hamster", rarity = "Legendary", cost = 10000, income = 200, bodyColor = Color3.fromRGB(255, 180, 90), headColor = Color3.fromRGB(255, 205, 130), accessory = "crown", accessoryColor = Color3.fromRGB(255, 215, 0) },
	{ name = "Turbo Grandpa", rarity = "Legendary", cost = 15000, income = 300, bodyColor = Color3.fromRGB(200, 200, 200), headColor = Color3.fromRGB(230, 210, 180), accessory = "glasses", accessoryColor = Color3.fromRGB(60, 60, 60) },
	{ name = "Quantum Pickle", rarity = "Legendary", cost = 25000, income = 500, bodyColor = Color3.fromRGB(90, 200, 90), headColor = Color3.fromRGB(140, 230, 120), accessory = "halo", accessoryColor = Color3.fromRGB(255, 240, 150) },
	{ name = "Disco Ball Dragon", rarity = "Legendary", cost = 40000, income = 800, bodyColor = Color3.fromRGB(200, 200, 210), headColor = Color3.fromRGB(230, 230, 240), accessory = "wings", accessoryColor = Color3.fromRGB(180, 180, 200) },
	{ name = "President Pigeon", rarity = "Legendary", cost = 60000, income = 1200, bodyColor = Color3.fromRGB(100, 100, 110), headColor = Color3.fromRGB(150, 150, 160), accessory = "crown", accessoryColor = Color3.fromRGB(255, 215, 0) },
	{ name = "Elon Muskrat", rarity = "Mythic", cost = 100000, income = 1500, bodyColor = Color3.fromRGB(110, 110, 120), headColor = Color3.fromRGB(190, 190, 200), accessory = "wings", accessoryColor = Color3.fromRGB(200, 200, 220) },
	{ name = "Captain Microwave", rarity = "Mythic", cost = 175000, income = 2500, bodyColor = Color3.fromRGB(150, 150, 160), headColor = Color3.fromRGB(210, 210, 220), accessory = "antenna", accessoryColor = Color3.fromRGB(255, 200, 0) },
	{ name = "Void Spaghetti Monster", rarity = "Mythic", cost = 250000, income = 4000, bodyColor = Color3.fromRGB(60, 20, 90), headColor = Color3.fromRGB(120, 50, 170), accessory = "horn", accessoryColor = Color3.fromRGB(170, 60, 220) },
	{ name = "The Last WiFi Router", rarity = "Mythic", cost = 400000, income = 6000, bodyColor = Color3.fromRGB(60, 60, 70), headColor = Color3.fromRGB(110, 110, 130), accessory = "halo", accessoryColor = Color3.fromRGB(120, 220, 255) },
	{ name = "Moon Cheese Wizard", rarity = "Mythic", cost = 750000, income = 8000, bodyColor = Color3.fromRGB(240, 230, 140), headColor = Color3.fromRGB(255, 245, 180), accessory = "hat", accessoryColor = Color3.fromRGB(90, 60, 180) },
	{ name = "Sigma Granny", rarity = "Brainrot God", cost = 1000000, income = 10000, bodyColor = Color3.fromRGB(200, 160, 220), headColor = Color3.fromRGB(230, 200, 240), accessory = "halo", accessoryColor = Color3.fromRGB(255, 215, 0) },
	{ name = "Galactic Toaster Overlord", rarity = "Brainrot God", cost = 2500000, income = 25000, bodyColor = Color3.fromRGB(180, 180, 200), headColor = Color3.fromRGB(220, 220, 240), accessory = "crown", accessoryColor = Color3.fromRGB(255, 215, 0) },
	{ name = "Ohio Final Boss", rarity = "Brainrot God", cost = 5000000, income = 50000, bodyColor = Color3.fromRGB(40, 40, 45), headColor = Color3.fromRGB(255, 60, 60), accessory = "crown", accessoryColor = Color3.fromRGB(255, 215, 0) },
	{ name = "The Eternal Loading Screen", rarity = "Brainrot God", cost = 10000000, income = 100000, bodyColor = Color3.fromRGB(40, 40, 50), headColor = Color3.fromRGB(90, 90, 110), accessory = "halo", accessoryColor = Color3.fromRGB(255, 215, 0) },
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
	label.Size = UDim2.new(1, 0, 1 / 3, 0)
	label.Position = UDim2.new(0, 0, order * (1 / 3), 0)
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
	elseif kind == "glasses" then
		local lensLeft = makePart("GlassesLeft", Vector3.new(1, 0.8, 0.4), record.accessoryColor, Vector3.new(-0.7, 2.8, 1))
		lensLeft.Parent = model
		local lensRight = makePart("GlassesRight", Vector3.new(1, 0.8, 0.4), record.accessoryColor, Vector3.new(0.7, 2.8, 1))
		lensRight.Parent = model
		local bridge = makePart("GlassesBridge", Vector3.new(0.8, 0.3, 0.3), record.accessoryColor, Vector3.new(0, 2.8, 1))
		bridge.Parent = model
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

	-- Floating label: NOT AlwaysOnTop, so it never paints over the HUD
	-- (shop panel, buttons) or over other labels; it hides past
	-- MaxDistance so distant brainrots on the belt stay quiet. Kept small
	-- (160x64, MaxDistance 90) so a title rarely drifts over the chat
	-- hint line or the shop's left edge.
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "BrainrotLabel"
	billboard.Adornee = body
	billboard.Size = UDim2.new(0, 160, 0, 64)
	billboard.StudsOffset = Vector3.new(0, 5, 0)
	billboard.AlwaysOnTop = false
	billboard.MaxDistance = 90
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
