local Modux = require(game.ReplicatedStorage.Shared.Modux)

local HungerComponent = Modux.Component("HungerComponent"):Tag("HungerComponent"):ClassName("Player")

HungerComponent.DamagePlayer = function(self)
	return self.Vital:TakeDamage(self.HungerDamage)
end

HungerComponent:OnInit(function(self)
	self.ConsumeRate = 1
	self.HungerDamage = 1

	self.Vital = self:GetRequiredComponent(self.Instance, "VitalComponent")
end)

HungerComponent:OnTick(function(self)
	if self.Vital.Health <= 0 then
		return
	end

	if self.Vital.Hunger <= 0 then
		self.Vital:TakeDamage(self.HungerDamage)
		self.Vital:ReplicateKey("Hunger")
		return
	end

	self.Vital:ConsumeHunger(self.ConsumeRate)
end, Modux.TickRate.Hz1)

return HungerComponent
