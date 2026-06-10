local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local EnemyService = require(ServerScriptService.Server.Services.EnemyService)
local FSM = require(ReplicatedStorage.Shared.Utils.FSM)
local Modux = require(ReplicatedStorage.Shared.Modux)

local AreaMixin = Modux.Mixin("AreaMixin"):Extend("PlayerZoneComponent")

type AlienVisibleStatus = "Show" | "Hiden"

local DEBUG_MODE = true

local function AlienVisibleController(State: AlienVisibleStatus, EnemyList: {any}): boolean
    if #EnemyList <= 0 then
        return false
    end

    for _, Enemy in EnemyList do
        -- Ocultar ou aparecer aliens
    end

    return true
end

function AreaMixin:CreateAliens()
    local Difficult: number = DEBUG_MODE and 5 or 1 --No lugar do primeiro valor, será a dificultade vinda do servidor
    local SortTotalAlien: number = math.random(self.MinEnemys, self.MaxEnemys)

    for i = 0, SortTotalAlien, 1 do
        local SpawnCFrame: CFrame = EnemyService:GetRandomAlienPosition(self.Instance)
        local AlienKey: string = EnemyService:CreateAlien(self.AreaName, Difficult, SpawnCFrame)
        if not AlienKey then
            warn(`[{script.Name} = CreateAliens] CreateAlien not returned Key for alien.`)
            continue
        end

        table.insert(self.Enemys, AlienKey)
    end
end

function AreaMixin:TotalAlienSpawn(): number | {}
    return #self.Enemys
end

function AreaMixin:SetMinEnemys(Value: number)
    self.MinEnemys = Value
end

function AreaMixin:SetMaxEnemys(Value: number)
    self.MinEnemys = Value
end

function AreaMixin:ChangedEnemyAreaStatus(NewStatus: AlienVisibleStatus): boolean
    return self.OnEnemyStatus:Transition(NewStatus)
end

-- Dificultade do jogo será recebido pelo receptedService

AreaMixin:OnInit(function(self)
    self.Enemys = {}
    self.AreaName = ""
    self.OnEnemyStatus = FSM.new<<AlienVisibleStatus>>("Hiden", {
        Hiden = "Show",
        Show = "Hiden"
    })

    self.MinEnemys = 1
    self.MaxEnemys = 5

    self.OnEnemyStatus:OnTransition(function(previousState: "Hiden" | "Show", nextState: "Hiden" | "Show")
        if previousState == nextState then return end;

        return AlienVisibleController(nextState, self.Enemys)
    end)
end)

return AreaMixin
