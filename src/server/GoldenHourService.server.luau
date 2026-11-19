-- GoldenHourService: the schedule behind the Golden Hour event. The first
-- one starts 90 seconds after the server boots (so a Studio play session
-- sees it quickly), then one runs every 5 minutes for 60 seconds.

local GoldenHour = require(script.Parent:WaitForChild("GoldenHour"))

local FIRST_DELAY_SECONDS = 90
local CYCLE_SECONDS = 300

task.spawn(function()
	task.wait(FIRST_DELAY_SECONDS)
	while true do
		GoldenHour.startGoldenHour()
		task.wait(CYCLE_SECONDS)
	end
end)

print("GoldenHourService ready: first Golden Hour in " .. tostring(FIRST_DELAY_SECONDS) .. "s, then every " .. tostring(CYCLE_SECONDS) .. "s")
