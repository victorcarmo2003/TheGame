local Modux = require(game.ReplicatedStorage.Shared.Modux)

local DebugVitalComponent = Modux.Component("DebugVitalComponent"):Tag("DebugVital")

DebugVitalComponent:OnInit(function(self)
	self:Cleanup(self.Instance.ProximityPrompt.Triggered:Connect(function(a0: Player)
		local lifeComponent = self:GetComponent(a0, "VitalComponent")

		print(self.Instance.Name)

		if self.Instance.Name == "Hunger" then
			lifeComponent:IncreaseHunger(5)
		end

		if self.Instance.Name == "Health" then
			lifeComponent:Heal(5)
		end

		if self.Instance.Name == "Damage" then
			lifeComponent:TakeDamage(10)
		end
	end))
end)

DebugVitalComponent:OnStart(function(self) end)

DebugVitalComponent:OnDestroy(function(self) end)

return DebugVitalComponent
