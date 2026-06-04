local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FSM = require(ReplicatedStorage.Shared.Utils.FSM)
local Modux = require(ReplicatedStorage.Shared.Modux)
local Types = require(ReplicatedStorage.Shared.Modux.Types)

type GameStates = "Begin" | "Normal" | "DarkMoon"
local GameService = Modux.Service("GameService"):Import("DayNightService")

GameService.CurrentState = "Begin" :: GameStates

GameService.OnBegin = GameService.Signal.new() :: Types.Signal<>
GameService.OnNormal = GameService.Signal.new() :: Types.Signal<>
GameService.OnDarkMoon = GameService.Signal.new() :: Types.Signal<>

GameService.State = FSM.new<<GameStates>>("Begin", {
	Begin = { "Normal" },
	Normal = { "DarkMoon" },
	DarkMoon = { "Normal" },
})

GameService:OnInit(function(self) 
	self.State:Transition("Begin")
	
	task.delay(5, function()
		self.State:Transition("Normal")
		self.DayNightService:StartCycle()
	end)

	local connection = self.DayNightService.OnCycleChanged:Connect(function(current: "Day" | "Night", previous: "Day" | "Night")
		if previous == "Night" then
			
		end
	end)

	self:Cleanup(connection)
end)

return GameService
