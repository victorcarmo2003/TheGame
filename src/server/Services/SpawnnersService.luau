local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Modux = require(ReplicatedStorage.Shared.Modux)

local SpawnnersService = Modux.Service("SpawnnersService")
SpawnnersService.AreasRegistred = {} :: AreaRegistredType

local SpawnArea = require(ReplicatedStorage.Shared.Settings.SpawnArea)
local FSM = require(ReplicatedStorage.Shared.Utils.FSM)

type AreaState = "Active" | "Unactive"
type SpawnType = SpawnArea.SpawnType
type AreaRegistredType = {
	ID: number,
	Instance: BasePart,
	AreaType: SpawnType,
	CurrentDifficult: number,
	DifficultMode: "EASY" | "MEDIUM" | "HARD",
	State: FSM.FSM<AreaState>,
}

local DEBUG_MODE = true
local DEBUG_PARTS_LOADED = false
local DEBUG_DIFFICULT = 1
local DEBUG_DIFFICULT_MODE = "EASY"
local DEBUG_AREATYPE = "Field"

local function DEBUG_loadSpawnArea()
	local Map = Workspace:FindFirstChild("Map")
	local SpawnAreas = Map:FindFirstChild("SpawnAreas")

	local spawnAreas = {}
	for _, area in SpawnAreas:GetDescendants() do
		if area:IsA("BasePart") then
			SpawnnersService:RegisterArea(area, DEBUG_DIFFICULT, DEBUG_AREATYPE)
		end
	end

	return spawnAreas
end

local function AreaRegistred(Area: BasePart): AreaRegistredType | nil
	local GetAreaRegistred = SpawnnersService:GetRegistredsArea()
	if not GetAreaRegistred or #GetAreaRegistred >= 0 then
		return
	end

	for Index: number, Registers: AreaRegistredType in GetAreaRegistred do
		if Registers.Instance == Area then
			return Registers
		end
	end

	return
end

function SpawnnersService:GetRegistredsArea(): { AreaRegistredType }
	return self.AreasRegistred
end

function SpawnnersService:HasArea(instance: BasePart)
	return AreaRegistred(instance)
end

function SpawnnersService:ResumeArea(Instance: BasePart) : boolean
	local AreaConfig: AreaRegistredType? = AreaRegistred(Instance)
	if not AreaConfig then 
		warn(`[{script.Name} - ResumeArea] instance recept not is Registred Area.`)
		return false
	end

	if AreaConfig.State:Is("Active") then
		return false
	end

	return AreaConfig.State:Transition("Active")
end

function SpawnnersService:PausaArea(Area: BasePart | string): boolean
	local RegistredAreaList = self:GetRegistredsArea()
	if not RegistredAreaList then
		warn(`[{script.Name} - PausaArea] Not has area registred or Registred area returned with size = 0.`)
		return false
	end

	local _CurrentFindMethod: string? = if typeof(Area) == "Instance" and Area:IsA("BasePart")
		then "Instance"
		elseif type(Area) == "string" then "ID"
		else nil

	local Response: boolean
	for _, AreaConfig: AreaRegistredType in self.AreasRegistred do
		local hasAreaConfig = AreaConfig[_CurrentFindMethod] == Area and true or false
		if not hasAreaConfig then
			continue
		end

		if not AreaConfig.State:Is("Unactive") then
			return false
		end

		Response = AreaConfig.State:Transition("Unactive") 

		break
	end

	return Response
end

function SpawnnersService:RegisterArea(Instance: BasePart, difficulty: number, AreaType: SpawnType): boolean
	if AreaRegistred(Instance) then
		warn(`[{script.Name} - RegisterArea] - Area already registered. [{Instance.Name}]`) -- Alterar para o Panic
		return false
	end

	local ChekingExistsArea = SpawnArea[AreaType]
	if not ChekingExistsArea then
		warn(`[{script.Name} - RegisterArea] AreaType not exist`)
		return false
	end

	Instance:AddTag(AreaType)

	local AreaConfig = {
		ID = HttpService:GenerateGUID(false),
		Instance = Instance,
		AreaType = AreaType,
		CurrentDifficult = difficulty,
		DifficultMode = DEBUG_DIFFICULT_MODE, -- Pegar a dificultade vinda do servidor
		State = FSM.new<<AreaState>>("Unactive", {
			Active = {"Unactive"},
			Unactive = {"Active"}
		}),
	}

	table.insert(self.AreasRegistred, AreaConfig)

	AreaConfig.State:OnTransition(function(previousState: "Active" | "Unactive", nextState: "Active" | "Unactive")
		print(`Status alterado para: {nextState}. Status antigo: {previousState}`)
	end)

	return true
end

function SpawnnersService:UnregisterArea(Area: Instance | BasePart?, All: boolean?): boolean
	if Area and not All then
		if not Area:IsA("BasePart") then
			return false
		end

		local AreaConfig = AreaRegistred(Area)
		if not AreaConfig then
			return false
		end

		self:PausaArea(Area)

		local OldArea = table.remove(self.AreasRegistred, table.find(self.AreasRegistred, AreaConfig))
		OldArea:Destroy()

		return true
	end

	if All then
		for I: number, A: AreaRegistredType in self.AreasRegistred do
			if A.State:Is("Active") then
				self:PausaArea(A)
			end

			local OldArea = table.remove(self.AreasRegistred, I)
			OldArea.Status:Destroy()
		end

		self.AreasRegistred = {}

		return true
	end

	return false
end

SpawnnersService:OnInit(function(self) end)

SpawnnersService:OnStart(function(self) end)

SpawnnersService:OnTick(function(self)
	if DEBUG_MODE and not DEBUG_PARTS_LOADED then
		DEBUG_loadSpawnArea()
		DEBUG_PARTS_LOADED = true
	end
end, Modux.TickRate.Hz1)

return SpawnnersService
