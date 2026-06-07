local Modux = require(game.ReplicatedStorage.Shared.Modux)
local Aliens = require(game.ReplicatedStorage.Shared.Enums.Aliens)
local SpawnAreaSettings = require(game.ReplicatedStorage.Shared.Settings.SpawnArea)

type AlienType = Aliens.AlienType
type SpawnType = SpawnAreaSettings.SpawnType
type SpawnAreaConfig = {
	Enabled: boolean,
	MinDifficulty: number,
	MaxDifficulty: number,
	AlienWeights: { [AlienType]: number },
}

local DEFAULT_AREA_TYPE: SpawnType = "Field"

local SpawnAreaComponent = Modux.Component("SpawnAreaComponent"):Tag("SpawnArea"):ClassName("BasePart")

local function readNumberAttribute(instance: Instance, name: string, fallback: number): number
	local value = instance:GetAttribute(name)
	return if typeof(value) == "number" then value else fallback
end

local function readBooleanAttribute(instance: Instance, name: string, fallback: boolean): boolean
	local value = instance:GetAttribute(name)
	return if typeof(value) == "boolean" then value else fallback
end

function SpawnAreaComponent:GetAreaType(): SpawnType
	local areaType = self.Instance:GetAttribute("AreaType")
	if typeof(areaType) == "string" and SpawnAreaSettings[areaType :: SpawnType] then
		return areaType :: SpawnType
	end

	return DEFAULT_AREA_TYPE
end

function SpawnAreaComponent:GetConfig(): SpawnAreaConfig
	local areaConfig = SpawnAreaSettings[self:GetAreaType()] or SpawnAreaSettings[DEFAULT_AREA_TYPE]
	local weights = table.clone(areaConfig.AlienWeights)

	for _, alienType in Aliens do
		print(alienType)
		local overrideWeight = self.Instance:GetAttribute(`{alienType}Weight`)
		if typeof(overrideWeight) ~= "number" then
			overrideWeight = self.Instance:GetAttribute(`Weight_{alienType}`)
		end
		if typeof(overrideWeight) == "number" then
			weights[alienType] = overrideWeight
		end
	end

	return {
		Enabled = readBooleanAttribute(self.Instance, "Enabled", areaConfig.Enabled),
		MinDifficulty = readNumberAttribute(self.Instance, "MinDifficulty", areaConfig.MinDifficulty),
		MaxDifficulty = readNumberAttribute(self.Instance, "MaxDifficulty", areaConfig.MaxDifficulty),
		AlienWeights = weights,
	}
end

function SpawnAreaComponent:CanSpawn(difficulty: number): boolean
	local config = self:GetConfig()
	return config.Enabled and difficulty >= config.MinDifficulty and difficulty <= config.MaxDifficulty
end

function SpawnAreaComponent:GetAlienWeights(difficulty: number?): { [AlienType]: number }
	local config = self:GetConfig()
	if difficulty and not self:CanSpawn(difficulty) then
		return {}
	end

	return table.clone(config.AlienWeights)
end

function SpawnAreaComponent:GetSpawnCFrame(): CFrame
	local area = self.Instance :: BasePart
	local halfSize = area.Size * 0.5
	local padding = math.max(0, readNumberAttribute(area, "Padding", 0))
	local xLimit = math.max(0, halfSize.X - padding)
	local zLimit = math.max(0, halfSize.Z - padding)
	local x = (math.random() * 2 - 1) * xLimit
	local z = (math.random() * 2 - 1) * zLimit
	local heightOffset = readNumberAttribute(area, "SpawnHeightOffset", 0)

	return area.CFrame * CFrame.new(x, halfSize.Y + heightOffset, z)
end

SpawnAreaComponent:OnInit(function(self)
	self.AreaType = self:GetAreaType()
end)

return SpawnAreaComponent
