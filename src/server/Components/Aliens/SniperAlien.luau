local Modux = require(game.ReplicatedStorage.Shared.Modux)

local SniperComponent = Modux.Component("SniperComponent")
	:Extend("AlienBaseMixin")
	:Tag("Sniper")
	:ClassName("Model")

SniperComponent:OnStart(function(self)
	
end)

SniperComponent:OnDestroy(function(self)
	
end)

return SniperComponent
