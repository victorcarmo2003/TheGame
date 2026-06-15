local Modux = require(game.ReplicatedStorage.Shared.Modux)

local RageComponent = Modux.Component("RageComponent")
	:Extend("AlienBaseMixin")
	:Tag("Rage")
	:ClassName("Model")

RageComponent:OnStart(function(self)
	
end)

RageComponent:OnDestroy(function(self)
	
end)

return RageComponent
