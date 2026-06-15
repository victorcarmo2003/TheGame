local Modux = require(game.ReplicatedStorage.Shared.Modux)

local TankerComponent = Modux.Component("TankerComponent")
	:Extend("AlienBaseMixin")
	:Tag("Tanker")
	:ClassName("Model")

TankerComponent:OnStart(function(self)
	
end)

TankerComponent:OnDestroy(function(self)
	
end)

return TankerComponent
