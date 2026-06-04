local ResourcesDatabase = {}

export type ResourcesName = "Sand" | "Wood" | "Iron" | "Glass" | "Circuit"

ResourcesDatabase.AllResources = {
	["Sand"] = {
		Name = "Sand",
		Description = "I'm not really sure if this is sand, but I can make glass with it.",
	},
	["Wood"] = {
		Name = "Wood",
		Description = "Although it works pretty fine, It's probably some alien wood...",
	},
	["Iron"] = {
		Name = "Iron",
		Description = "Yes, iron! I can make a lot of stuffs with this, I should probably pick some more.",
	},
	["Glass"] = {
		Name = "Glass",
		Description = "Glass is really useful, no matter which planet are you in.",
	},
	["Circuit"] = {
		Name = "Circuit",
		Description = "Most important resource in this planet, I need to make some more.",
	},
}

ResourcesDatabase.GetByName = function() end

return ResourcesDatabase
