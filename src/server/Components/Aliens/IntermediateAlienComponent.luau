-- modux ignore file
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modux = require(ReplicatedStorage.Shared.Modux)

local IntermediateAlienComponent = Modux.Component("IntermediateAlienComponent")
	:Tag("IntermediateAlien")
	:ClassName("Model")
	:Extend("AlienBaseMixin")

IntermediateAlienComponent:OnInit(function(self)
	self.Behavior = "Intermediate"
end)

return IntermediateAlienComponent
