local Shared = game:GetService("ReplicatedStorage").Shared
local Modux = require(Shared.Modux)

local BasicSolarComponent = Modux.Component("BasicSolarComponent"):Tag("BasicSolar"):Extend("SolarPanelMixin")
BasicSolarComponent:Import("DayNightService")

BasicSolarComponent:OnInit(function(self)
	local SolarPanelDatabase = require(Shared.Utils.SolarPanelDatabase)
	local solarPanelData = SolarPanelDatabase.GetByName(self.Instance.Name)
	assert(solarPanelData, `[BasicSolarComponent] Target database not founded {solarPanelData}`)

	self.DisplayName = solarPanelData.DisplayName
	self.Production = solarPanelData.Production
	self.MaxCapacity = 100 -- solarPanelData.MaxCapacity
	self.ConnectedTo = solarPanelData.ConnectedTo
	self.Position = solarPanelData.Position
	self.Boost = solarPanelData.Boost
	self.Nerfed = false
	self.Energy = 0

	if self.DayNightService:GetCycle() ~= "Night" then
		self:SetEnable()
	end

	self.DayNightService:ObserverCycle(function(currentState)
		warn(currentState)
		if currentState == "Night" then
			self:SetDisable()
		elseif currentState == "Transition" then
			self:SetEnable()
			self.Nerfed = true
		else
			self:SetEnable()
			self.Nerfed = false
		end
	end)
end)

BasicSolarComponent:OnTick(function(self, deltaTime: number)
	if self.Enable then
		self:ProduceEnergy()
		self:UpdateBillboard()
	end

	if self.ConnectedTo then
		self:TransferEnergy()
		self:UpdateBillboard()
	end
end, Modux.TickRate.Hz1)

return BasicSolarComponent
