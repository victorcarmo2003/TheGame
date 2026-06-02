local Shared = game:GetService("ReplicatedStorage").Shared
local Settings = require(Shared.Settings.DayCycle)

local Modux = require(Shared.Modux)
local Types = require(Shared.Modux.Types)
export type DayCycle = "Day" | "Night" | "Idle"

local DayNightService = Modux.Service("DayNightService")

DayNightService.CurrentClock = 0 :: number
DayNightService.CurrentDay = 0 :: number
DayNightService.CurrentCycle = "Day" :: DayCycle
DayNightService.OnCycleChanged = DayNightService.Signal.new() :: Types.Signal<DayCycle, DayCycle>

DayNightService.ReplicateClock = function(self)
	self.Network.Packages.SecondsCycle:send({ Message = self.CurrentClock }, self.Network.all)
end

DayNightService.ObserverCycle = function(self, callback: (currentState: DayCycle) -> ())
	callback(self.CurrentCycle)

	return self.OnCycleChanged:Connect(function(_, currentCycle)
		callback(currentCycle)
	end)
end

DayNightService.IncreaseDay = function(self)
	self.CurrentDay += 1
	self.Network.Packages.DayCycle:send({ Message = self.CurrentDay }, self.Network.all)
end

DayNightService.SetCycle = function(self, cycle: DayCycle)
	local lightning = game.Lighting
	local previousCycle = self.CurrentCycle

	self.CurrentCycle = cycle

	if cycle == "Night" then
		self.CurrentClock = Settings.NightDuration
		lightning.ClockTime = Settings.NightClock
		lightning.Brightness = Settings.NightBrightness
	else
		self.CurrentClock = Settings.DayDuration
		lightning.ClockTime = Settings.DayClock
		lightning.Brightness = Settings.DayBrightness
	end

	if previousCycle ~= cycle then
		self.OnCycleChanged:Fire(previousCycle, cycle)
	end

	if previousCycle == "Night" then
		self:IncreaseDay()
	end
end

DayNightService.ToggleCycle = function(self)
	if self.CurrentCycle == "Day" then
		self:SetCycle("Night")
	else
		self:SetCycle("Day")
	end
end

DayNightService.StartCycle = function(self)
	self:SetCycle("Day")
end

DayNightService:OnStart(function(self)
	self:SetCycle("Idle")
end)

DayNightService:OnTick(function(self)
	if self.CurrentCycle == "Idle" then
		return
	end
	if self.CurrentClock <= 0 then
		self:ToggleCycle()
	end

	self.CurrentClock -= 1
	self:ReplicateClock()
end, Modux.TickRate.Hz1)

return DayNightService
