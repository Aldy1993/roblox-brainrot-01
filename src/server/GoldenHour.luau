-- GoldenHour: a timed x2 income event for Neon Island. Every few minutes
-- the whole island goes golden: every base pays double for 60 seconds and
-- every client sees a yellow GOLDEN HOUR banner with a countdown.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameEvent = ReplicatedStorage:WaitForChild("GameEvent")

local GoldenHour = {}

GoldenHour.DURATION_SECONDS = 60
GoldenHour.MULTIPLIER = 2

local active = false
local endsAt = 0

function GoldenHour.isActive()
	return active and os.time() < endsAt
end

function GoldenHour.getMultiplier()
	if GoldenHour.isActive() then
		return GoldenHour.MULTIPLIER
	end
	return 1
end

function GoldenHour.secondsLeft()
	if not GoldenHour.isActive() then
		return 0
	end
	return endsAt - os.time()
end

-- Starts one Golden Hour now (or extends the running one). Fires the
-- banner event to every client and schedules the matching end event.
function GoldenHour.startGoldenHour(duration)
	duration = duration or GoldenHour.DURATION_SECONDS
	if duration <= 0 then
		return
	end
	active = true
	endsAt = os.time() + duration
	GameEvent:FireAllClients("GoldenHourStart", duration)
	task.delay(duration, function()
		if os.time() >= endsAt then
			active = false
			GameEvent:FireAllClients("GoldenHourEnd")
		end
	end)
end

return GoldenHour
