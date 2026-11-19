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

-- The cast, one compact row per brainrot: name, rarity, cost, income,
-- body hex, head hex, accessory, accessory hex. Rows are decoded
-- into full records below, so the shop, the Index grid and the
-- spawner all read BrainrotData.CAST exactly as before.
local ROWS = {
	{"Noodle Cat","Common",10,1,"#FFDC82","#FFF0B4","ears","#FFDC82"},
	{"Soggy Cereal Goblin","Common",15,1,"#C8AA78","#E6C896","ears","#C8AA78"},
	{"Pretzel Panda","Common",20,1,"#FFC864","#FFDC96","ears","#FFC864"},
	{"Toilet Duck","Common",25,2,"#FFEB50","#FFF596","hat","#F0F0F0"},
	{"Jellyfish Jam","Common",30,2,"#FF96C8","#FFBEDC","wings","#FF78B4"},
	{"Cupcake Crab","Common",35,2,"#FFAAC8","#FFC8DC","fin","#FF64A0"},
	{"Traffic Cone Crab","Common",40,3,"#FF6E28","#FF9650","horn","#FFC828"},
	{"Macaroni Moose","Common",50,3,"#FFD250","#FFE68C","horn","#C87828"},
	{"Bubblegum Pigeon","Common",60,4,"#FF8CC8","#FFB4DC","wings","#FF78B4"},
	{"Popcorn Puffin","Common",65,4,"#FFF5DC","#FFFFF0","wings","#FFC83C"},
	{"Honey Hamster","Common",70,4,"#FFC83C","#FFDC78","ears","#FFC83C"},
	{"Couch Potato Knight","Common",80,4,"#8C5A3C","#B4825A","hat","#787878"},
	{"Donut Dolphin","Common",85,4,"#FFB4C8","#FFD2E1","wings","#FF78B4"},
	{"Waffle Walrus","Common",90,5,"#E6AA5A","#FAC882","fin","#E6AA5A"},
	{"Banana Shark","Rare",100,5,"#FFDC3C","#78AAFF","fin","#5A8CE6"},
	{"Wasabi Wombat","Rare",125,6,"#78DC50","#A0F078","horn","#FF3C3C"},
	{"Salsa Sloth","Rare",150,7,"#FF7850","#FFA078","hat","#FFDC3C"},
	{"Disco Microwave","Rare",175,8,"#787882","#C8C8D2","antenna","#FF50C8"},
	{"Bagel Badger","Rare",200,10,"#C8965A","#E6B478","ears","#C8965A"},
	{"Pizza Rat King","Rare",250,12,"#966E50","#B48C64","crown","#FFD700"},
	{"Ramen Raccoon","Rare",300,15,"#787882","#B4B4BE","glasses","#3C3C3C"},
	{"Avocado Alligator","Rare",350,16,"#78C850","#A0E678","fin","#78C850"},
	{"Sock Puppet Shark","Rare",400,18,"#78AAFF","#C8DCFF","fin","#5A8CE6"},
	{"Coconut Cobra","Rare",450,18,"#F0E6C8","#FFF5DC","horn","#C8A064"},
	{"Curry Capybara","Rare",500,20,"#DC8C3C","#F0AA64","hat","#FFC828"},
	{"Angry Houseplant","Rare",600,25,"#3CA03C","#78DC78","horn","#C83C3C"},
	{"Skibidi Toaster","Epic",1000,30,"#C8C8D2","#787882","antenna","#FF5050"},
	{"Nacho Ninja","Epic",1250,40,"#FFB428","#FFD25A","glasses","#282828"},
	{"Burrito Bear","Epic",1500,45,"#DCB478","#F0CD96","hat","#C87828"},
	{"Laser Llama","Epic",1750,55,"#F0F0F0","#FFFFFF","glasses","#282828"},
	{"Kimchi Kraken","Epic",2000,60,"#FF5050","#FF8282","fin","#FF3C3C"},
	{"Cursed Croissant","Epic",2500,75,"#DCA046","#F0BE64","horn","#5A288C"},
	{"Mochi Moose","Epic",3000,90,"#F0E6FA","#FFF5FF","horn","#FFB4DC"},
	{"Invisible Mime","Epic",3200,95,"#DCDCE6","#F0F0F5","hat","#1E1E23"},
	{"Espresso Eagle","Epic",3500,100,"#5A3C28","#8C6446","wings","#5A3C28"},
	{"Haunted Vending Machine","Epic",4000,120,"#B43C3C","#DC6464","antenna","#78DCFF"},
	{"Sriracha Shark","Epic",4500,130,"#FF4632","#FF7864","fin","#FF3C28"},
	{"Matcha Manta","Epic",5000,150,"#8CC878","#B4E6A0","wings","#8CC878"},
	{"Giga Chad Hamster","Legendary",10000,200,"#FFB45A","#FFCD82","crown","#FFD700"},
	{"Molten Marshmallow","Legendary",12500,250,"#FF783C","#FFAA6E","halo","#FFF096"},
	{"Turbo Grandpa","Legendary",15000,300,"#C8C8C8","#E6D2B4","glasses","#3C3C3C"},
	{"Frostbite Fox","Legendary",20000,400,"#B4DCFF","#D2EBFF","ears","#B4DCFF"},
	{"Quantum Pickle","Legendary",25000,500,"#5AC85A","#8CE678","halo","#FFF096"},
	{"Stormy Salmon","Legendary",30000,600,"#FF6E5A","#FFA08C","fin","#FF503C"},
	{"Disco Ball Dragon","Legendary",40000,800,"#C8C8D2","#E6E6F0","wings","#B4B4C8"},
	{"Obsidian Owl","Legendary",50000,1000,"#282832","#5A5A6E","wings","#282832"},
	{"President Pigeon","Legendary",60000,1200,"#64646E","#9696A0","crown","#FFD700"},
	{"Solar Sundae","Legendary",75000,1500,"#FFDC64","#FFF0A0","halo","#FFD700"},
	{"Midnight Muffin","Legendary",80000,1600,"#3C325A","#6E5A8C","hat","#C8A0DC"},
	{"Aurora Alpaca","Legendary",90000,1800,"#B4C8FF","#D2E1FF","halo","#FFF096"},
	{"Elon Muskrat","Mythic",100000,1500,"#6E6E78","#BEBEC8","wings","#C8C8DC"},
	{"Void Vulture","Mythic",125000,1800,"#3C145A","#7832AA","wings","#AA3CDC"},
	{"Nebula Newt","Mythic",150000,2200,"#8C50DC","#B478F0","antenna","#78DCFF"},
	{"Captain Microwave","Mythic",175000,2500,"#9696A0","#D2D2DC","antenna","#FFC800"},
	{"Eclipse Elephant","Mythic",200000,3000,"#32323C","#646478","horn","#FFD700"},
	{"Void Spaghetti Monster","Mythic",250000,4000,"#3C145A","#7832AA","horn","#AA3CDC"},
	{"Quantum Quokka","Mythic",300000,4500,"#96C8FF","#BEDCFF","glasses","#3C3C3C"},
	{"The Last WiFi Router","Mythic",400000,6000,"#3C3C46","#6E6E82","halo","#78DCFF"},
	{"Celestial Crocodile","Mythic",500000,7000,"#C8E6FF","#E6F5FF","crown","#FFD700"},
	{"Phoenix Pancake","Mythic",600000,7500,"#FF963C","#FFBE6E","wings","#FFD700"},
	{"Moon Cheese Wizard","Mythic",750000,8000,"#F0E68C","#FFF5B4","hat","#5A3CB4"},
	{"Sigma Granny","Brainrot God",1000000,10000,"#C8A0DC","#E6C8F0","halo","#FFD700"},
	{"Infinity Ice Cream","Brainrot God",1500000,15000,"#FFC8E6","#FFE6F5","halo","#FFD700"},
	{"Omnipotent Onion","Brainrot God",2000000,20000,"#C88CDC","#E6B4F0","crown","#FFD700"},
	{"Galactic Toaster Overlord","Brainrot God",2500000,25000,"#B4B4C8","#DCDCF0","crown","#FFD700"},
	{"Cosmic Curry","Brainrot God",3000000,30000,"#FFAA3C","#FFC878","halo","#FFD700"},
	{"Ohio Final Boss","Brainrot God",5000000,50000,"#28282D","#FF3C3C","crown","#FFD700"},
	{"Galactic Garlic","Brainrot God",7500000,75000,"#F0F0FA","#FFFFFF","crown","#FFD700"},
	{"The Eternal Loading Screen","Brainrot God",10000000,100000,"#282832","#5A5A6E","halo","#FFD700"},
	{"Ultimate Udon","Brainrot God",20000000,200000,"#FFF0C8","#FFFAE6","halo","#FFD700"},
}
local function dec(r)
	return {name=r[1],rarity=r[2],cost=r[3],income=r[4],bodyColor=Color3.fromHex(r[5]),headColor=Color3.fromHex(r[6]),accessory=r[7],accessoryColor=Color3.fromHex(r[8])}
end
BrainrotData.CAST = {}
for _, r in ipairs(ROWS) do table.insert(BrainrotData.CAST, dec(r)) end

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

-- Accessory pieces per kind: name, size, position, optional PartType.
-- The builder below sticks each listed piece onto the model.
local ACCESSORY_PARTS = {
	ears = {
		{ "EarLeft", { 0.8, 1.2, 0.8 }, { -0.8, 3.9, 0 } },
		{ "EarRight", { 0.8, 1.2, 0.8 }, { 0.8, 3.9, 0 } },
	},
	fin = { { "Fin", { 0.6, 2, 2.4 }, { 0, 3.7, 0 } } },
	crown = { { "Crown", { 2.4, 0.8, 2.4 }, { 0, 3.9, 0 } } },
	hat = { { "Hat", { 3, 0.8, 3 }, { 0, 3.9, 0 } } },
	antenna = {
		{ "Antenna", { 0.4, 2, 0.4 }, { 0, 4.4, 0 } },
		{ "AntennaTip", { 1, 1, 1 }, { 0, 5.6, 0 }, Enum.PartType.Ball },
	},
	glasses = {
		{ "GlassesLeft", { 1, 0.8, 0.4 }, { -0.7, 2.8, 1 } },
		{ "GlassesRight", { 1, 0.8, 0.4 }, { 0.7, 2.8, 1 } },
		{ "GlassesBridge", { 0.8, 0.3, 0.3 }, { 0, 2.8, 1 } },
	},
	horn = { { "Horn", { 0.8, 1.8, 0.8 }, { 0, 4, 0 } } },
	halo = { { "Halo", { 3, 0.4, 3 }, { 0, 4.3, 0 } } },
	wings = {
		{ "WingLeft", { 2.5, 0.4, 1.5 }, { -2.4, 0.8, 0 } },
		{ "WingRight", { 2.5, 0.4, 1.5 }, { 2.4, 0.8, 0 } },
	},
}

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

	for _, spec in ipairs(ACCESSORY_PARTS[record.accessory] or {}) do
		local part = makePart(spec[1], Vector3.new(spec[2][1], spec[2][2], spec[2][3]), record.accessoryColor, Vector3.new(spec[3][1], spec[3][2], spec[3][3]), spec[4])
		part.Parent = model
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
