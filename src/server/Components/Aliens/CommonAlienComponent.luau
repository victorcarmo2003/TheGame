-- modux ignore file
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modux = require(ReplicatedStorage.Shared.Modux)

local CommonAlienComponent = Modux.Component("CommonAlienComponent")
	:Tag("CommonAlien")
	:ClassName("Model")
	:Extend("AlienBaseMixin")

CommonAlienComponent:OnInit(function(self)
	self.Behavior = "Common"
end)

return CommonAlienComponent
