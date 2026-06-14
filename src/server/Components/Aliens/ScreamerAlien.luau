local Modux = require(game.ReplicatedStorage.Shared.Modux)

local ScreamerComponent = Modux.Component("ScreamerComponent")
	:Extend("AlienBaseMixin")
	:Tag("Screamer")
	:ClassName("Model")

ScreamerComponent:OnStart(function(self)
	
end)

ScreamerComponent:OnDestroy(function(self)
	
end)

return ScreamerComponent
