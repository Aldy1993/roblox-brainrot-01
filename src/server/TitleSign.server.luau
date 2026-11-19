-- TitleSign: hangs the "BRAINROT BLAST - NEON ISLAND" sign over the
-- entrance arch. The sign part itself lives in default.project.json;
-- the text is a BillboardGui attached here at runtime (the same pattern
-- BaseService uses for the base name signs), because Rojo project files
-- cannot carry child instances.

local signPart = workspace:WaitForChild("NeonIslandTitleSign")

local gui = Instance.new("BillboardGui")
gui.Name = "NeonIslandTitle"
gui.Adornee = signPart
gui.Size = UDim2.new(0, 600, 0, 170)
gui.StudsOffset = Vector3.new(0, 0, 0)
-- NOT AlwaysOnTop: the sign must not paint over the HUD.
gui.AlwaysOnTop = false
gui.MaxDistance = 200
gui.Parent = signPart

local title = Instance.new("TextLabel")
title.Name = "TitleLabel"
title.Size = UDim2.new(1, 0, 0.55, 0)
title.BackgroundTransparency = 1
title.Text = "BRAINROT BLAST"
title.TextColor3 = Color3.fromRGB(255, 217, 25)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = gui

local subtitle = Instance.new("TextLabel")
subtitle.Name = "SubtitleLabel"
subtitle.Size = UDim2.new(1, 0, 0.45, 0)
subtitle.Position = UDim2.new(0, 0, 0.55, 0)
subtitle.BackgroundTransparency = 1
subtitle.Text = "NEON ISLAND"
subtitle.TextColor3 = Color3.fromRGB(77, 230, 255)
subtitle.TextScaled = true
subtitle.Font = Enum.Font.GothamBold
subtitle.Parent = gui

print("TitleSign ready: BRAINROT BLAST - NEON ISLAND")
