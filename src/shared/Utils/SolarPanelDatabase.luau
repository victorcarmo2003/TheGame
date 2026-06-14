local ResourcesDatabase = require(script.Parent.ResourcesDatabase)
local panelsDatabase = {}

export type PanelNames = "Basic" | "Intermediate" | "Advanced"

export type PanelData = {
    Name: PanelNames,
    Production: number,
    Cost: {
        [ResourcesDatabase.ResourcesName]: number,
    }
}

panelsDatabase.AllPanels = {
	["Basic"] = {
        Name = "Basic",
		Production = 10,
		Cost = {
			["Iron"] = 10,
			["Glass"] = 5,
			["Circuit"] = 1,
		},
	},
	["Intermediate"] = {
        Name = "Intermediate",
		Production = 25,
		Cost = {
			["Iron"] = 100,
			["Glass"] = 25,
			["Circuit"] = 5,
		},
	},
	["Advanced"] = {
        Name = "Advanced",
		Production = 100,
		Cost = {
			["Iron"] = 500,
			["Glass"] = 100,
			["Circuit"] = 15,
		},
	},
}

panelsDatabase.GetByName = function(Name)
    for _, data in panelsDatabase.AllPanels do
        if Name == data.Name then
            return data
        end
    end
    return error(`[SolarPanelDatabase - GetByName] Panel not founded {Name}`)
end

return panelsDatabase
