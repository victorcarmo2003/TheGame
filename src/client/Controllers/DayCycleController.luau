--!strict
local Modux = require(game.ReplicatedStorage.Shared.Modux)

local DayCycleController = Modux.Controller("DayCycleController")

local localPlayer = game.Players.LocalPlayer
local ScreenGui = localPlayer.PlayerGui:WaitForChild("ScreenGui")
local statusUI = ScreenGui.Conteiner.Status

DayCycleController.UpdateClock = function(self, seconds: number)
	local ClockLabel = statusUI.ClockLabel
	local timeString = string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
	ClockLabel.Text = timeString
end

DayCycleController.UpdateDay = function(self, currentDay: number)
	local Daylabel = statusUI.DayLabel
	Daylabel.Text = `Day {tostring(currentDay)}`
end

DayCycleController:OnInit(function(self)
	self.Network.Packages.SecondsCycle:on(function(payload)
		self:UpdateClock(payload.Seconds)
	end)

	self.Network.Packages.DayCycle:on(function(payload)
		self:UpdateDay(payload.CurrentDay)
	end)

	self.Network.Packages.TransitionCycle:on(function(data: { DayTime: string })
		print(`[CLIENT-SIDE] Daytime:`, data.DayTime)
	end)
end)

return DayCycleController
