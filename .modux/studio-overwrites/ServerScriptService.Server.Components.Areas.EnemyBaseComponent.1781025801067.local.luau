local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modux = require(ReplicatedStorage.Shared.Modux)

local EnemyBaseComponent = Modux.Component("EnemyBaseComponent")
    :Tag("EnemyBase")
    :ClassName("BasePart")
    :Extend("AreaMixin");

EnemyBaseComponent:OnStart(function(self) end)

EnemyBaseComponent:OnDestroy(function(self) end)

return EnemyBaseComponent