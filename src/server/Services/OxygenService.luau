local CollectionService = game:GetService("CollectionService")
local Modux = require(game.ReplicatedStorage.Shared.Modux)

local OxygenService = Modux.Service("OxygenService"):Import("PlayerService")

OxygenService:OnInit(function(self)
	self.PlayerService:OnPlayerAdded(function(Player: Player)
		CollectionService:AddTag(Player, "OxygenComponent")
	end)
end)

return OxygenService
