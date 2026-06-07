--!strict
local Modux = require(game.ReplicatedStorage.Shared.Modux)

local DayCycleController = Modux.Controller("DayCycleController")

local localPlayer = game.Players.LocalPlayer
local ScreenGui = localPlayer.PlayerGui:WaitForChild("ScreenGui", 5)
local statusUI = ScreenGui.Conteiner.Status

type NumberMessage = { Message: number }

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
	self.Network.Packages.SecondsCycle:on(function(payload: NumberMessage)
		self:UpdateClock(payload.Message)
	end)

	self.Network.Packages.DayCycle:on(function(payload: NumberMessage)
		self:UpdateDay(payload.Message)
	end)
end)

return DayCycleController
