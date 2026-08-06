local Modux = require(game.ReplicatedStorage.Shared.Modux)
local OxygenZoneComponent = Modux.Component("OxygenZoneComponent"):Tag("OxygenZone"):Extend("PlayerZoneComponent")

OxygenZoneComponent:OnInit(function(self)
	self:ObserverPlayersInPart({ MinHeight = self.Instance.Size.Y })

	self:OnEnter(function(Player: Player, Zone)
		local oxygenComponent = self:GetComponent(Player, "OxygenComponent")
		oxygenComponent[self.Instance.Name](oxygenComponent)
	end)

	self:OnExit(function(Player: Player, Zone)
		local oxygenComponent = self:GetComponent(Player, "OxygenComponent")
	end)
end)

return OxygenZoneComponent
