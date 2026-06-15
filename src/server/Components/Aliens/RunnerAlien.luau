local Modux = require(game.ReplicatedStorage.Shared.Modux)

local RunnerComponent = Modux.Component("RunnerComponent")
	:Extend("AlienBaseMixin")
	:Tag("Runner")
	:ClassName("Model")

RunnerComponent:OnStart(function(self)
	
end)

RunnerComponent:OnDestroy(function(self)
	
end)

return RunnerComponent
