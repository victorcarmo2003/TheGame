local Workspace = game:GetService("Workspace")
local Modux = require(game.ReplicatedStorage.Shared.Modux)

local EnemyService = Modux.Service("EnemyService")

local DEBUG_CONFIG_LIST = {
    Diffiult = 1,
}

local ValidAreas = {}

local function loadValidSpawnAreas()
	local Map: Folder =  Workspace:FindFirstChild("Map")
	if not Map then
		warn(`[{script.Parent} - loadValidSpawnAreas] - Map folder not find.`)
		return
	end
	
	local SpawnAreas: Folder = Map:FindFirstChild("SpawnAreas")
	if not SpawnAreas then
		warn(`[{script.Parent} - loadValidSpawnAreas] - SpawnAreas folder not find.`)
		return
	end
	
	local validSpawnAreas = {}
	for _, spawnArea in ipairs(SpawnAreas:GetChildren()) do
		if spawnArea:IsA("BasePart") then
			table.insert(validSpawnAreas, spawnArea)
		end
	end
	
	return validSpawnAreas
end

function EnemyService:SpawnEnemy(enemyName: string, difficulty: number)
	if #ValidAreas <= 0 then
		ValidAreas = loadValidSpawnAreas()
	end
	
	
end

EnemyService:OnInit(function(self)
    -- Criar as conexões
end)

EnemyService:OnStart(function(self)

end)

return EnemyService