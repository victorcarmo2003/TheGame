local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Extend = require(ReplicatedStorage.Shared.Modux.src.Core.Extend)
local Modux = require(game.ReplicatedStorage.Shared.Modux)

local EnemyBaseComponent = Modux.Component("EnemyBaseComponent")
    :Tag("EnemyBase")
    :ClassName("BasePart")
    :Extend("AreaMixin");

EnemyBaseComponent:OnStart(function(self)
    
end)

EnemyBaseComponent:OnDestroy(function(self)
    
end)

return EnemyBaseComponent