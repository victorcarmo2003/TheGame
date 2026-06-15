-- modux ignore file
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modux = require(ReplicatedStorage.Shared.Modux)

local GenericAlienComponent = Modux.Component("GenericAlienComponent")
	:Tag("Aliens")
	:ClassName("Model")
	:Extend("AlienBaseMixin")

GenericAlienComponent:OnInit(function(self)
	self.Behavior = "Generic"
end)

return GenericAlienComponent
