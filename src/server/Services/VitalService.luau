local CollectionService = game:GetService("CollectionService")
local Modux = require(game.ReplicatedStorage.Shared.Modux)

local VitalService = Modux.Service("VitalService"):Import("PlayerService")

VitalService:OnInit(function(self)
	self.Network.Packages.GetVitals:handle(function(_, Player: Player?)
		if not Player then
			return nil
		end

		local playerVital = self:GetComponent(Player, "VitalComponent")
		if not playerVital then
			return nil
		end

		return {
			Armor = playerVital.Armor,
			Health = playerVital.Health,
			Hunger = playerVital.Hunger,
			Stamina = playerVital.Stamina,
			Oxygen = playerVital.Oxygen,
			MaxOxygen = playerVital.MaxOxygen,
		}
	end)

	self.PlayerService:OnPlayerAdded(function(Player: Player)
		CollectionService:AddTag(Player, "VitalComponent")
		CollectionService:AddTag(Player, "OxygenComponent")
		CollectionService:AddTag(Player, "HungerComponent")
	end)

end)

return VitalService
