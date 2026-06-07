local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Modux = require(ReplicatedStorage.Shared.Modux)
local Aliens = require(ReplicatedStorage.Shared.Enums.Aliens)
local EnemyTypes = require(ReplicatedStorage.Shared.Settings.EnemyTypes)

type AlienType = Aliens.AlienType

local EnemyService = Modux.Service("EnemyService")

-- local DEBUG_MODE = true
-- local DEBUG_CONFIG_LIST = {
-- 	DEFAULT_DIFFICULTY = 1,
-- 	DEBUG_INITIAL_SPAWN_COUNT = 10,
-- }

-- local GENERIC_ALIEN_TAG = "Aliens"

-- local DEBUG_CLIENT_SPAWN = true
-- local DEBUG_AUTO_SPAWN = true
-- local DEBUG_SHOW_SPAWN_PROXIES = true

-- local SPAWN_PROXY_TAG = "EnemySpawnProxy"
-- local SPAWN_PROXY_SIZE = Vector3.new(2, 2, 2)

-- local rng = Random.new()
-- local enemiesFolder: Folder? = nil

-- local function getEnemiesFolder(): Folder
-- 	if enemiesFolder and enemiesFolder.Parent then
-- 		return enemiesFolder
-- 	end

-- 	local folder = Workspace:FindFirstChild("Enemies")
-- 	if not folder or not folder:IsA("Folder") then
-- 		folder = Instance.new("Folder")
-- 		folder.Name = "Enemies"
-- 		folder.Parent = Workspace
-- 	end

-- 	enemiesFolder = folder :: Folder
-- 	return enemiesFolder :: Folder
-- end

-- local function getAlienModelsFolder(): Folder?
-- 	local assets = ReplicatedStorage:FindFirstChild("Assets")
-- 	if not assets then
-- 		warn("[EnemyService] ReplicatedStorage.Assets not found.")
-- 		return nil
-- 	end

-- 	local aliensModels = assets:FindFirstChild("AliensModels")
-- 	if not aliensModels or not aliensModels:IsA("Folder") then
-- 		warn("[EnemyService] ReplicatedStorage.Assets.AliensModels not found.")
-- 		return nil
-- 	end

-- 	return aliensModels
-- end

-- local function filterWeights(weights: { [AlienType]: number }, difficulty: number): { [AlienType]: number }
-- 	local filtered = {}
-- 	for alienType, weight in weights do
-- 		local config = EnemyTypes[alienType]
-- 		if config and weight > 0 and difficulty >= config.MinDifficulty then
-- 			filtered[alienType] = weight
-- 		end
-- 	end

-- 	return filtered
-- end


-- function EnemyService:GetValidSpawnAreas(difficulty: number): { any }
-- 	local validAreas = {}
-- 	for _, area in self:GetAllComponents("SpawnAreaComponent") do
-- 		if area:CanSpawn(difficulty) then
-- 			table.insert(validAreas, area)
-- 		end
-- 	end

-- 	return validAreas
-- end

-- function EnemyService:ChooseSpawnArea(difficulty: number)
-- 	local validAreas = self:GetValidSpawnAreas(difficulty)
-- 	if #validAreas == 0 then
-- 		return nil
-- 	end

-- 	return validAreas[rng:NextInteger(1, #validAreas)]
-- end

-- function EnemyService:ChooseAlien(weights: { [AlienType]: number }, difficulty: number): AlienType?
-- 	local filteredWeights = filterWeights(weights, difficulty)
-- 	local totalWeight = 0
-- 	for _, weight in filteredWeights do
-- 		totalWeight += weight
-- 	end

-- 	if totalWeight <= 0 then
-- 		return nil
-- 	end

-- 	local roll = rng:NextNumber(0, totalWeight)
-- 	local accumulated = 0
-- 	for alienType, weight in filteredWeights do
-- 		accumulated += weight
-- 		if roll <= accumulated then
-- 			return alienType
-- 		end
-- 	end

-- 	return nil
-- end

-- function EnemyService:GetAlienModel(alienType: AlienType): Model?
-- 	local config = EnemyTypes[alienType]
-- 	if not config then
-- 		warn(`[EnemyService] EnemyTypes config missing for "{alienType}".`)
-- 		return nil
-- 	end

-- 	local aliensModels = getAlienModelsFolder()
-- 	if not aliensModels then
-- 		return nil
-- 	end

-- 	local model = aliensModels:FindFirstChild(config.ModelName)
-- 	if not model or not model:IsA("Model") then
-- 		warn(`[EnemyService] Alien model "{config.ModelName}" not found in ReplicatedStorage.Assets.AliensModels.`)
-- 		return nil
-- 	end

-- 	return model
-- end

-- function EnemyService:CreateSpawnProxy(alienType: AlienType, area): BasePart
-- 	local spawnCFrame = area:GetSpawnCFrame()
-- 	local proxy = Instance.new("Part")
-- 	proxy.Name = `{alienType}SpawnProxy`
-- 	proxy.Anchored = true
-- 	proxy.CanCollide = false
-- 	proxy.CanTouch = false
-- 	proxy.CanQuery = false
-- 	proxy.Size = SPAWN_PROXY_SIZE
-- 	proxy.CFrame = spawnCFrame
-- 	proxy.Transparency = if DEBUG_SHOW_SPAWN_PROXIES then 0.45 else 1
-- 	proxy.Color = Color3.fromRGB(255, 72, 72)
-- 	proxy.Material = Enum.Material.Neon
-- 	proxy:SetAttribute("AlienType", alienType)
-- 	proxy:SetAttribute("SpawnAreaType", area:GetAreaType())
-- 	proxy:SetAttribute("ComponentTag", self:GetComponentTag(alienType))
-- 	proxy:SetAttribute("SpawnMode", "Client")
-- 	proxy.Parent = getEnemiesFolder()

-- 	CollectionService:AddTag(proxy, SPAWN_PROXY_TAG)
-- 	return proxy
-- end

-- function EnemyService:GetComponentTag(alienType: AlienType): string
-- 	local config = EnemyTypes[alienType]
-- 	local configuredTag = config and config.ComponentTag
-- 	if typeof(configuredTag) == "string" and configuredTag ~= "" then
-- 		return configuredTag
-- 	end

-- 	return GENERIC_ALIEN_TAG
-- end

-- function EnemyService:ValidateEnemyConfigs(): boolean
-- 	local aliensModels = getAlienModelsFolder()
-- 	if not aliensModels then
-- 		return false
-- 	end

-- 	local isValid = true
-- 	for alienType, config in EnemyTypes do
-- 		if typeof(config.ModelName) ~= "string" or config.ModelName == "" then
-- 			warn(`[EnemyService] EnemyTypes config for "{alienType}" has invalid ModelName.`)
-- 			isValid = false
-- 			continue
-- 		end

-- 		local model = aliensModels:FindFirstChild(config.ModelName)
-- 		if not model or not model:IsA("Model") then
-- 			warn(`[EnemyService] Alien model "{config.ModelName}" for "{alienType}" was not found.`)
-- 			isValid = false
-- 		end

-- 		local componentTag = config.ComponentTag
-- 		if componentTag ~= nil and (typeof(componentTag) ~= "string" or componentTag == "") then
-- 			warn(`[EnemyService] EnemyTypes config for "{alienType}" has invalid ComponentTag.`)
-- 			isValid = false
-- 		end
-- 	end

-- 	return isValid
-- end

-- function EnemyService:SpawnServerModel(alienType: AlienType, area): Model?
-- 	local sourceModel = self:GetAlienModel(alienType)
-- 	if not sourceModel then
-- 		return nil
-- 	end

-- 	local alien = sourceModel:Clone()
-- 	alien.Name = alienType
-- 	alien:SetAttribute("AlienType", alienType)
-- 	alien:SetAttribute("SpawnAreaType", area:GetAreaType())
-- 	alien:PivotTo(area:GetSpawnCFrame())
-- 	alien.Parent = getEnemiesFolder()

-- 	CollectionService:AddTag(alien, self:GetComponentTag(alienType))
-- 	return alien
-- end

-- function EnemyService:SpawnAtArea(alienType: AlienType, area): Instance?
-- 	if DEBUG_CLIENT_SPAWN then
-- 		return self:CreateSpawnProxy(alienType, area)
-- 	end

-- 	return self:SpawnServerModel(alienType, area)
-- end

-- function EnemyService:SpawnSpecific(alienType: AlienType, difficulty: number?): Instance?
-- 	local currentDifficulty = difficulty or DEFAULT_DIFFICULTY
-- 	local config = EnemyTypes[alienType]
-- 	if not config then
-- 		warn(`[EnemyService] EnemyTypes config missing for "{alienType}".`)
-- 		return nil
-- 	end

-- 	if currentDifficulty < config.MinDifficulty then
-- 		warn(`[EnemyService] "{alienType}" requires difficulty {config.MinDifficulty}, got {currentDifficulty}.`)
-- 		return nil
-- 	end

-- 	local area = self:ChooseSpawnArea(currentDifficulty)
-- 	if not area then
-- 		warn(`[EnemyService] No valid SpawnArea found for difficulty {currentDifficulty}.`)
-- 		return nil
-- 	end

-- 	return self:SpawnAtArea(alienType, area)
-- end

-- function EnemyService:SpawnRandom(difficulty: number?): Instance?
-- 	local currentDifficulty = if DEBUG_MODE then difficulty else DEBUG_CONFIG_LIST.DEFAULT_DIFFICULTY
-- 	local area = self:ChooseSpawnArea(currentDifficulty)

-- 	if not area then
-- 		warn(`[EnemyService] No valid SpawnArea found for difficulty {currentDifficulty}.`)
-- 		return nil
-- 	end

-- 	local selectedAlien = self:ChooseAlien(area:GetAlienWeights(currentDifficulty), currentDifficulty)
-- 	if not selectedAlien then
-- 		warn(`[EnemyService] No valid alien weight found for difficulty {currentDifficulty}.`)
-- 		return nil
-- 	end

-- 	return self:SpawnAtArea(selectedAlien, area)
-- end

-- function EnemyService:SpawnEnemy(alienType: AlienType?, difficulty: number?): Instance?
-- 	if alienType then
-- 		return self:SpawnSpecific(alienType, difficulty)
-- 	end

-- 	return self:SpawnRandom(difficulty)
-- end

-- function EnemyService:SpawnDebug(difficulty: number?, count: number?): { Instance }
-- 	local spawned = {}
-- 	local currentDifficulty = if DEBUG_MODE then difficulty else DEBUG_CONFIG_LIST.DEFAULT_DIFFICULTY
-- 	local amount = if DEBUG_MODE then count else DEBUG_CONFIG_LIST.DEBUG_INITIAL_SPAWN_COUNT

-- 	for _ = 1, amount do
-- 		local enemy = self:SpawnRandom(currentDifficulty)
-- 		if enemy then
-- 			table.insert(spawned, enemy)
-- 		end
-- 	end

-- 	return spawned
-- end

EnemyService:OnInit(function(self) end)

EnemyService:OnStart(function(self)
	-- self:ValidateEnemyConfigs()
	-- self.DebugInitialSpawnDone = false
end)

EnemyService:OnTick(function(self)
	-- if DEBUG_MODE and not self.DebugInitialSpawnDone then
	-- 	local areaList = loadSpawnArea()
	-- 	if #areaList == 0 then
	-- 		warn(`[{script.Parent} - OnTick] Error in load spawns areas.`)
	-- 		return
	-- 	end

	-- 	self.DebugInitialSpawnDone = true

	-- 	self:SpawnDebug(DEBUG_CONFIG_LIST.DEFAULT_DIFFICULTY, DEBUG_CONFIG_LIST.DEBUG_INITIAL_SPAWN_COUNT)
	-- end
end, Modux.TickRate.Hz1)

return EnemyService
