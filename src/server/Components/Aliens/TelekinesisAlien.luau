local Modux = require(game.ReplicatedStorage.Shared.Modux)

local TelekinesisComponent = Modux.Component("TelekinesisComponent")
	:Extend("AlienBaseMixin")
	:Tag("Telekinesis")
	:ClassName("Model")

TelekinesisComponent:OnStart(function(self)
	
end)

TelekinesisComponent:OnDestroy(function(self)
	
end)

return TelekinesisComponent
