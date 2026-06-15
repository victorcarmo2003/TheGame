local Modux = require(game.ReplicatedStorage.Shared.Modux)

local CommonComponent = Modux.Component("CommonComponent")
    :Extend("AlienBaseMixin")
    :Tag("Common")
    :ClassName("Model")

CommonComponent:OnStart(function(self)
    
end)

CommonComponent:OnDestroy(function(self)
    
end)

return CommonComponent
