local Shared = game:GetService("ReplicatedStorage").Shared
local Modux = require(Shared.Modux)

--modux ignore line
local SolarPanelMixin = Modux.Mixin("SolarPanelMixin")
SolarPanelMixin:Import("DayNightService")

SolarPanelMixin.UpdateBillboard = function(self)
	local Billboard = self.Instance.Panel.BillboardGui
	local storageLabel = Billboard.Frame.Storage :: TextLabel
	storageLabel.Text = `{self.Energy}/{self.MaxCapacity}`
end

SolarPanelMixin.SetEnable = function(self)
	self.Enable = true
end

SolarPanelMixin.SetDisable = function(self)
	self.Enable = false
end

SolarPanelMixin.ProduceEnergy = function(self)
	if not self.Enable then
		return
	end

	if self.Energy >= self.MaxCapacity then
		return self.Energy
	end
	
	local produceAmount = self.Production

	if self.Nerfed then 
		produceAmount /= 2
	end

	if self.Boost then
		produceAmount *= 2
	end
	self.Energy += math.clamp(produceAmount, 0, self.MaxCapacity)

	return self.Energy
end

SolarPanelMixin.RecieveEnergy = function(self, amount)
	self.Energy = math.clamp(amount, 0, self.MaxCapacity)
end

SolarPanelMixin.TransferEnergy = function(self)
	if not self.ConnectedTo then
		return self.Energy
	end
	if self.Energy <= 0 then
		return self.Energy
	end
	local connectedComponent = self:GetComponent(self.ConnectedTo, "BasicSolarComponent")

	if self.Energy > self.Production then
		self.Energy -= self.Production
		connectedComponent:RecieveEnergy(self.Production)
		return self.Energy
	end
	connectedComponent:RecieveEnergy(self.Energy)
	self.Energy = 0

	return self.Energy
end

SolarPanelMixin.PlugTo = function(self) end

SolarPanelMixin.TakePlug = function(self) end

SolarPanelMixin.TakeDamage = function(self, amount)
	self.Health = math.clamp(self.Health - amount, 0, self.MaxHealth)
end

SolarPanelMixin.RegenHealth = function(self, amount)
	self.Health = math.clamp(self.Health + amount, 0, self.MaxHealth)
end

SolarPanelMixin:OnInit(function(self)
	self.Health = 100
	self.MaxHealth = 100
	self:Cleanup(self.DayNightService:ObserverCycle(function(currentCycle)
		if currentCycle == "Day" then
			self:SetEnable()
		else
			self:SetDisable()
		end
	end))
end)

return SolarPanelMixin
