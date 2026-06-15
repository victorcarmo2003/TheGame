local ServerScriptService = game:GetService("ServerScriptService")
local Modux = require(game.ReplicatedStorage.Shared.Modux)

local FieldAreaComponent = Modux.Component("FieldAreaComponent"):Tag("FieldArea"):ClassName("Part"):Extend("AreaMixin")

FieldAreaComponent:OnStart(function(self)
	self.AreaName = "Field"
	self:CreateAliens()
end)

FieldAreaComponent:OnDestroy(function(self) end)

return FieldAreaComponent
