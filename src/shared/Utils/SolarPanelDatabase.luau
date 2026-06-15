local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SolarPanels = require(ReplicatedStorage.Shared.Datas.SolarPanels)
local ResourcesDatabase = require(script.Parent.ResourcesDatabase)
local panelsDatabase = {}

export type PanelNames = "Basic" | "Intermediate" | "Advanced"

export type PanelData = {
	Name: PanelNames,
	DisplayName: string,
	Boost: boolean,
	Production: number,
	MaxCapacity: number,
	ConnectedTo: Instance?,
	Position: Vector3?,
	Craft: {
		[ResourcesDatabase.ResourcesName]: number,
	},
}

panelsDatabase.AllPanels = SolarPanels

panelsDatabase.GetByName = function(Name: PanelNames): PanelData
	for _, data in panelsDatabase.AllPanels do
		if Name == data.Name then
			return data
		end
	end
	return error(`[SolarPanelDatabase - GetByName] Panel not founded {Name}`)
end

return panelsDatabase
