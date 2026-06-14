local Modux = require(game.ReplicatedStorage.Shared.Modux)

local IntermediateComponent = Modux.Component("IntermediateComponent")
	:Extend("AlienBaseMixin")
	:Tag("Intermediate")
	:ClassName("Model")

IntermediateComponent:OnStart(function(self)
	
end)

IntermediateComponent:OnDestroy(function(self)
	
end)

return IntermediateComponent
