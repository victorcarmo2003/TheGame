local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modux = require(ReplicatedStorage.Shared.Modux)

local EnemyBaseComponent =
	Modux.Component("EnemyBaseComponent"):Tag("EnemyBase"):ClassName("BasePart"):Extend("AreaMixin")

-- AliensSpaneTypes

EnemyBaseComponent:OnStart(function(self)
	self.AreaName = "EnemyBase"
    self:CreateAliens()
end)

EnemyBaseComponent:OnDestroy(function(self) end)

return EnemyBaseComponent
