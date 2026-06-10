local HttpService = game:GetService("HttpService")

local Modux = require(game.ReplicatedStorage.Shared.Modux)
local AliensList = require(game.ReplicatedStorage.Shared.Enums.Aliens)
local AreasConfig = require(game.ReplicatedStorage.Shared.Settings.AreasConfig)
local FSM = require(game.ReplicatedStorage.Shared.Utils.FSM)

local EnemyService = Modux.Service("EnemyService")
EnemyService._Aliens = {}

local DEBUG_MODE = true
local Loaded = false
local RandomGenerator = Random.new()

type BaseTypes = AreasConfig.SpawnType
type AreaConfig = AreasConfig.SpawnAreaConfig
type AlienType = AliensList.AlienType

export type AlienConfig = {
	AlienType: AlienType,
	Position: CFrame,
	State: FSM.FSM<AliensList.AlienStates>,
	Alived: boolean,
}

local function GetAliensFolder(): Folder
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Assets: Folder = ReplicatedStorage:WaitForChild("Assets")

	return Assets:WaitForChild("AliensModels") :: Folder
end

local function ChekingAliensModels(): boolean
	local TotalAliensRegistred: number = table.maxn(AliensList)

	local AliensModelFolders: Folder = GetAliensFolder()
	if not AliensModelFolders or #AliensModelFolders:GetChildren() < 0 then
		warn(`[{script.Name} - ChekingAliensModels] Aliens models folder is nil or not has children.`)
		return false
	end

	local cont: number = 0
	for _, Alien: Model | Instance in AliensModelFolders:GetChildren() do
		if not AliensList[Alien.Name] then
			warn(`[{script.Name} | ChekingAliensModels] Alien model there's not registred in Alien Enums. {Alien.Name}`)
			return false
		end

		cont = cont + 1
	end

	if cont < TotalAliensRegistred then
		warn(
			`[{script.Name} - ChekingAliensModels] Total cont is different totalAliens. TotalAliens: {TotalAliensRegistred}, Cont Result: {cont}`
		)
		return false
	end

	return true
end

local function GetAreaConfig(Area: BaseTypes): AreaConfig?
	return AreasConfig[Area]
end

local function IsDifficultyAllowed(Config: AreaConfig, Difficult: number): boolean
	return Difficult >= Config.MinDifficulty and Difficult <= Config.MaxDifficulty
end

local function GetRandomAlienType(AlienWeights: { [AlienType]: number }): AlienType?
	local TotalWeight = 0
	for _, Weight in AlienWeights do
		if Weight > 0 then
			TotalWeight += Weight
		end
	end

	if TotalWeight <= 0 then
		return
	end

	local Roll = RandomGenerator:NextNumber(0, TotalWeight)
	local AccumulatedWeight = 0

	for AlienName, Weight in AlienWeights do
		if Weight <= 0 then
			continue
		end

		AccumulatedWeight += Weight
		if Roll <= AccumulatedWeight then
			return AlienName
		end
	end

	return
end

local function CreateAlienConfig(AlienModelName: string, SpawnCFrame: CFrame): string
	local AlienKey = tostring(HttpService:GenerateGUID(false))
	EnemyService._Aliens[AlienKey] = {
		AlienType = AlienModelName,
		Position = SpawnCFrame,
		State = FSM.new<<AliensList.AlienStates>>, "Idle", {
			Idle = { "Walk", "Running", "Jumping", "attacking", "attacked" },
			Walk = { "Idle", "Running", "Jumping", "attacking", "attacked" },
			Running = { "Idle", "Walk", "Jumping", "attacking", "attacked" },
			Jumping = { "Idle", "Walk", "Running", "attacked" },
			attacking = { "Idle", "Walk", "Running", "attacked" },
			attacked = { "Idle", "Walk", "Running" },
		},
		Alived = true,
	}

	return AlienKey
end

local function GetRandomCFrameInArea(AreaInstance: BasePart): CFrame
	local HalfSize = AreaInstance.Size / 2
	local RandomX = RandomGenerator:NextNumber(-HalfSize.X, HalfSize.X)
	local RandomZ = RandomGenerator:NextNumber(-HalfSize.Z, HalfSize.Z)

	return AreaInstance.CFrame * CFrame.new(RandomX, HalfSize.Y, RandomZ)
end

function EnemyService:GetAlienByKey(Key: string)
	return self._Aliens[Key]
end

function EnemyService:GetRandomAlienPosition(AreaInstance: BasePart): CFrame
	return GetRandomCFrameInArea(AreaInstance)
end

function EnemyService:GetRandomAlienType(BaseType: BaseTypes, Difficult: number): AlienType?
	local AreaConfig: AreaConfig? = GetAreaConfig(BaseType)
	if not AreaConfig then
		warn(`[{script.Name} - GetRandomAlienType] BaseType not registred in AreaConfig or returned nil.`)
		return
	end

	if not AreaConfig.Enabled then
		warn(`[{script.Name} - GetRandomAlienType] AreaConfig is disabled. BaseType: {BaseType}`)
		return
	end

	if not IsDifficultyAllowed(AreaConfig, Difficult) then
		warn(
			`[{script.Name} - GetRandomAlienType] Difficult out of range. Difficult: {Difficult}, Min: {AreaConfig.MinDifficulty}, Max: {AreaConfig.MaxDifficulty}`
		)
		return
	end

	local SelectedAlienType: AlienType? = GetRandomAlienType(AreaConfig.AlienWeights)
	if not SelectedAlienType then
		warn(`[{script.Name} - GetRandomAlienType] Not has alien with weight greater than 0. BaseType: {BaseType}`)
		return
	end

	return SelectedAlienType
end

function EnemyService:CreateAlien(BaseType: BaseTypes, Difficult: number, SpawnCFrame: CFrame): string?
	local AreaConfig: AreaConfig? = GetAreaConfig(BaseType)
	if not AreaConfig then
		warn(`[{script.Name} - CreateAlien] BaseType not registred in AreaConfig or returned nil`)
		return
	end

	local SelectedAlienType: AlienType? = self:GetRandomAlienType(BaseType, Difficult)
	if not SelectedAlienType then
		return
	end

	return CreateAlienConfig(SelectedAlienType, SpawnCFrame)
end

EnemyService:OnInit(function(self) end)

EnemyService:OnStart(function(self) end)

EnemyService:OnTick(function(self)
	if Loaded then
		return
	end

	local CheckAliensResponse: boolean = ChekingAliensModels()
	if CheckAliensResponse then
		Loaded = true
	end
end, Modux.TickRate.Hz1)

return EnemyService
