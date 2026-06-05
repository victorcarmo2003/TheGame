-- modux ignore file
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modux = require(ReplicatedStorage.Shared.Modux)

local RunnerAlienComponent = Modux.Component("RunnerAlienComponent")
	:Tag("RunnerAlien")
	:ClassName("Model")
	:Extend("AlienBaseMixin")

RunnerAlienComponent:OnInit(function(self)
	self.Behavior = "Runner"
end)

return RunnerAlienComponent
