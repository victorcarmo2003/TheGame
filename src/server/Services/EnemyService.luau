local HttpService = game:GetService("HttpService")

local Modux = require(game.ReplicatedStorage.Shared.Modux)
local AliensList = require(game.ReplicatedStorage.Shared.Enums.Aliens)
local AreasConfig = require(game.ReplicatedStorage.Shared.Settings.AreasConfig)
local FSM = require(game.ReplicatedStorage.Shared.Utils.FSM)

local EnemyService = Modux.Service("EnemyService")

local DEBUG_MODE = true
local DEBUG_ALIEN_MARKERS_FOLDER = "DEBUG_AlienPositions"
local Loaded = false
local RandomGenerator = Random.new()

type SpawnType = AreasConfig.SpawnType
type SpawnAreaConfig = AreasConfig.SpawnAreaConfig
type AlienType = AliensList.AlienType
type AlienStates = AliensList.AlienStates
type FSM<State> = FSM.FSM<State>

export type AlienConfig = {
	AlienType: AlienType,
	Position: CFrame,
	State: FSM<AlienStates>,
	Alived: boolean,
	Visible: FSM<boolean>
}

EnemyService.Aliens = {} :: { [string]: AlienConfig }

export type removeTypes = "Visible" | "Destroy"

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

local function GetAreaConfig(Area: SpawnType): SpawnAreaConfig?
	return AreasConfig[Area]
end

local function IsDifficultyAllowed(Config: SpawnAreaConfig, Difficult: number): boolean
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

local function CreateAlienConnection(ReferenceKey: string)
	local AlienConfig: AlienConfig = EnemyService.Aliens[ReferenceKey]

	AlienConfig.State:OnTransition(function(previousState: AlienStates, nextState: AlienStates)
		
	end)

	AlienConfig.Visible:OnTransition(function(previousState: boolean, nextState: boolean)
		
	end)
end

local function CreateAlienConfig(AlienModelName: AlienType, SpawnCFrame: CFrame): string
	local AlienKey = tostring(HttpService:GenerateGUID(false))
	local AlienStateTransitions: FSM.Transitions<AlienStates> = {
		Idle = { "Walk", "Running", "Jumping", "attacking", "attacked" },
		Walk = { "Idle", "Running", "Jumping", "attacking", "attacked" },
		Running = { "Idle", "Walk", "Jumping", "attacking", "attacked" },
		Jumping = { "Idle", "Walk", "Running", "attacked" },
		attacking = { "Idle", "Walk", "Running", "attacked" },
		attacked = { "Idle", "Walk", "Running" },
	}
	local VisibleTransitions: FSM.Transitions<boolean> = {
		[true] = { false },
		[false] = { true },
	}

	EnemyService.Aliens[AlienKey] = {
		AlienType = AlienModelName,
		Position = SpawnCFrame,
		State = FSM.new<<AlienStates>>("Idle" :: AlienStates, AlienStateTransitions),
		Alived = true,
		Visible = FSM.new<<boolean>>(false, VisibleTransitions)
	}

	CreateAlienConnection(AlienKey)
	return AlienKey
end

local function DEBUG_CreateAlienPositionMarker(AlienKey: string, AlienModelName: string, SpawnCFrame: CFrame)
	if not DEBUG_MODE then
		return
	end

	local Workspace = game:GetService("Workspace")
	local DebugFolder = Workspace:FindFirstChild(DEBUG_ALIEN_MARKERS_FOLDER)
	if not DebugFolder then
		DebugFolder = Instance.new("Folder")
		DebugFolder.Name = DEBUG_ALIEN_MARKERS_FOLDER
		DebugFolder.Parent = Workspace
	end

	local Marker = Instance.new("Part")
	Marker.Name = `AlienPosition_{AlienModelName}_{AlienKey}`
	Marker.Anchored = true
	Marker.CanCollide = false
	Marker.CanQuery = false
	Marker.CanTouch = false
	Marker.Size = Vector3.new(1.5, 1.5, 1.5)
	Marker.CFrame = SpawnCFrame
	Marker.Color = Color3.fromRGB(255, 0, 0)
	Marker.Material = Enum.Material.Neon
	Marker.Transparency = 0.15
	Marker.Parent = DebugFolder
end

local function GetRandomCFrameInArea(AreaInstance: BasePart): CFrame?
	local HalfSize =  AreaInstance.Size / 2

	local Overlap = OverlapParams.new()
	Overlap.FilterType = Enum.RaycastFilterType.Exclude
	Overlap.FilterDescendantsInstances = { AreaInstance }

	local MaxAttempts = 30
	local Attempt = 0

	while Attempt < MaxAttempts do
		Attempt += 1

		local RandomX = RandomGenerator:NextNumber(-HalfSize.X, HalfSize.X)
		local RandomZ = RandomGenerator:NextNumber(-HalfSize.Z, HalfSize.Z)
		local SpawnCFrame = AreaInstance.CFrame * CFrame.new(RandomX, HalfSize.Y, RandomZ)

		local BoxSize = Vector3.new(4, 6, 4)

		local Obstructions = workspace:GetPartBoundsInBox(
			SpawnCFrame * CFrame.new(0, BoxSize.Y / 2, 0),
			BoxSize,
			Overlap
		)

		if #Obstructions == 0 then
			return SpawnCFrame
		end
	end 

	return nil
end

function EnemyService:RemoveAlienByKey(Key: string, RemoveType: removeTypes): boolean
	local removeEnum = {
		Visible = "VISIBLE",
		Destroy = "DESTROY"
	}
	
	local ReferenteAlien = self.Aliens[Key] :: AlienConfig
	if not ReferenteAlien then
		warn(`[{script.Name} - RemoveAlienByKey] Alien not find.`)
		return false
	end

	if string.upper("RemoveType") == removeEnum.Visible then
		return ReferenteAlien.Visible:Transition(false)
	elseif string.upper("RemoveType") == removeEnum.Destroy then
		local OldList = table.remove(self.Aliens, table.find(self.Aliens, ReferenteAlien))
		OldList.State:Destroy()
		OldList.Visible:Destroy()
		return true
	else
		return false
	end
end

function EnemyService:GetAlienByKey(Key: string): AlienConfig?
	return self.Aliens[Key]
end

function EnemyService:GetRandomAlienPosition(AreaInstance: BasePart): CFrame?
	return GetRandomCFrameInArea(AreaInstance)
end

function EnemyService:GetRandomAlienType(BaseType: SpawnType, Difficult: number): AlienType?
	local AreaConfig: SpawnAreaConfig? = GetAreaConfig(BaseType)
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

function EnemyService:CreateAlien(BaseType: SpawnType, Difficult: number, SpawnCFrame: CFrame): string?
	local AreaConfig: SpawnAreaConfig? = GetAreaConfig(BaseType)
	if not AreaConfig then
		warn(`[{script.Name} - CreateAlien] BaseType not registred in AreaConfig or returned nil`)
		return
	end

	local SelectedAlienType: AlienType? = self:GetRandomAlienType(BaseType, Difficult)
	if not SelectedAlienType then
		return
	end

	local AlienKey = CreateAlienConfig(SelectedAlienType, SpawnCFrame)
	DEBUG_CreateAlienPositionMarker(AlienKey, SelectedAlienType, SpawnCFrame)

	return AlienKey
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
