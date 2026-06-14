local Modux = require(game.ReplicatedStorage.Shared.Modux)

local BrutusComponent = Modux.Component("BrutusComponent")
		:Tag("Brutus")
		:ClassName("Model")
		:Extend("AlienBaseMixin")

BrutusComponent:OnStart(function(self)
	
end)

BrutusComponent:OnDestroy(function(self)
	
end)

return BrutusComponent
