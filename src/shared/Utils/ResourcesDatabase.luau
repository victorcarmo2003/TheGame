local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage.Shared.Datas.Resources)
local ResourcesDatabase = {}

export type ResourcesName =
	"Scrap Metal"
	| "Rusted Iron"
	| "Iron Ore"
	| "Iron Ingot"
	| "Steel"
	| "Copper Ore"
	| "Copper Ingot"
	| "Eletronic Parts"
	| "Circuit Board"
	| "Solar Cell"
	| "Battery Cell"
	| "Fuel Canister"
	| "Crystal Shard"
	| "Meteorite"

export type ResourceType = {
	Name: ResourcesName,
	Category: string,
	Rarity: string,
	StackSize: number,
}

ResourcesDatabase.AllResources = Resources

ResourcesDatabase.GetByName = function() end

return ResourcesDatabase
