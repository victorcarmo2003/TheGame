--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FSM = require(ReplicatedStorage.Shared.Utils.FSM)
local Modux = require(game.ReplicatedStorage.Shared.Modux)

export type OxygenStates = "Avaliable" | "Unavaliable" | "Low"

local OxygenComponent = Modux.Component("OxygenComponent"):Tag("OxygenComponent"):ClassName("Player")

local transitions: FSM.Transitions<OxygenStates> = {
	Avaliable = { "Unavaliable", "Low" },
	Unavaliable = { "Avaliable", "Low" },
	Low = { "Avaliable", "Unavaliable" },
}

OxygenComponent.FSM = FSM.new<<OxygenStates>>("Unavaliable", transitions)

OxygenComponent.Avaliable = function(self)
	self.FSM:Transition("Avaliable")
end

OxygenComponent.Unavaliable = function(self)
	self.FSM:Transition("Unavaliable")
end

OxygenComponent.Low = function(self)
	self.FSM:Transition("Low")
end

OxygenComponent.SufocatePlayer = function(self)
	self.Vital:TakeDamage(self.SuffocateDamage)
end

OxygenComponent:OnInit(function(self)
	self.ConsumeRate = 1
	self.RegenRate = 1
	self.SuffocateDamage = 2

	self.Vital = self:GetRequiredComponent(self.Instance, "VitalComponent")
end)

OxygenComponent:OnTick(function(self, deltaTime)
	if self.Vital.Health <= 0 then
		return
	end

	if self.FSM:Is("Unavaliable") then
		self.Vital:ConsumeOxygen(self.ConsumeRate)
	end

	if self.FSM:Is("Avaliable") then
		self.Vital:IncreaseOxygen(self.RegenRate)
	end

	if self.Vital.Oxygen <= 0 then
		self:SufocatePlayer()
	end
end, Modux.TickRate.Hz1)

return OxygenComponent