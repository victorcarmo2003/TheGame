local Modux = require(game.ReplicatedStorage.Shared.Modux)

local KniferComponent = Modux.Component("KniferComponent")
	:Extend("AlienBaseMixin")
	:Tag("Knifer")
	:ClassName("Model")

KniferComponent:OnStart(function(self)
	
end)

KniferComponent:OnDestroy(function(self)
	
end)

return KniferComponent
