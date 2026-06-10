local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage.Shared.Datas.Resources)
local ResourcesDatabase = {}

export type ResourcesName = "Sand" | "Wood" | "Iron" | "Glass" | "Circuit"

ResourcesDatabase.AllResources = require(Resources)

ResourcesDatabase.GetByName = function() end

return ResourcesDatabase
