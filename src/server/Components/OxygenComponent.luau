--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FSM = require(ReplicatedStorage.Shared.Utils.FSM)
local Modux = require(game.ReplicatedStorage.Shared.Modux)

export type OxygenStates = "Avaliable" | "Unavaliable"

local OxygenComponent = Modux.Component("OxygenComponent"):Tag("OxygenComponent"):ClassName("Player")

local transitions: FSM.Transitions<OxygenStates> = {
	Avaliable = { "Unavaliable" },
	Unavaliable = { "Avaliable" },
}

OxygenComponent.FSM = FSM.new<<OxygenStates>>("Avaliable", transitions)

OxygenComponent.Avaliable = function(self)
	self.FSM:Transition("Avaliable")
end

OxygenComponent.Unavaliable = function(self)
	self.FSM:Transition("Unavaliable")
end

OxygenComponent:OnInit(function(self)
	self.ConsumeRate = 1
	self.RegenRate = 1
	self.SuffocateDamage = 2
end)

OxygenComponent:OnTick(function(self, deltaTime) 
	
end, Modux.TickRate.Hz1)

return OxygenComponent
