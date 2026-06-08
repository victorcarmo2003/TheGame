local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FSM = require(ReplicatedStorage.Shared.Utils.FSM)
local Modux = require(ReplicatedStorage.Shared.Modux)

local AreaMixin = Modux.Mixin("AreaMixin"):Extend("PlayerZoneComponent")

type AlienVisibleStatus = "Show" | "Hiden"

function AlienVisibleController(State: AlienVisibleStatus, EnemyList: {any}): boolean
    if #EnemyList <= 0 then
        return false
    end

    for _, Enemy in EnemyList do
        -- Ocultar ou aparecer aliens
    end

    return true
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

AreaMixin:OnInit(function(self)
    self.Enemys = {}
    self.OnEnemyStatus = FSM.new<<AlienVisibleStatus>>("Hiden", {
        Hiden = "Show",
        Show = "Hiden"
    })

    self.MinEnemys = 0
    self.MaxEnemys = 0

    self.OnEnemyStatus:OnTransition(function(previousState: "Hiden" | "Show", nextState: "Hiden" | "Show")
        if previousState == nextState then return end;

        return AlienVisibleController(nextState, self.Enemys)
    end)
end)

return AreaMixin