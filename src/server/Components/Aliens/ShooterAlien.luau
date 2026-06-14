local Modux = require(game.ReplicatedStorage.Shared.Modux)

local ShooterComponent = Modux.Component("ShooterComponent")
	:Extend("AlienBaseMixin")
	:Tag("Shooter")
	:ClassName("Model")

ShooterComponent:OnStart(function(self)
	
end)

ShooterComponent:OnDestroy(function(self)
	
end)

return ShooterComponent
