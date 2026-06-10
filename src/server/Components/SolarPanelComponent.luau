local Shared = game:GetService("ReplicatedStorage").Shared
local Modux = require(Shared.Modux)

--modux ignore line
local SolarPanelComponent = Modux.Component("SolarPanelComponent"):Tag("SolarPanel")

SolarPanelComponent.Setup = function(self)
	local SolarPanelDatabase = require(Shared.Utils.SolarPanelDatabase)
	local panelDatabase = SolarPanelDatabase.GetByName(self.Instance.Name)
	
end

SolarPanelComponent:OnStart(function(self) end)

SolarPanelComponent:OnDestroy(function(self) end)

return SolarPanelComponent
