--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modux = require(ReplicatedStorage.Shared.Modux)

local VitalComponent = Modux.Component("VitalComponent"):Tag("VitalComponent"):ClassName("Player")

export type VitalAttributes = "Armor" | "Hunger" | "Health" | "Oxygen" | "MaxOxygen"

VitalComponent.OnDie = VitalComponent.Signal.new() :: Modux.Signal<Player>

VitalComponent.ReplicateAll = function(self)
	self.Package:sendKey("Armor", self.Armor, self.Instance)
	self.Package:sendKey("Hunger", self.Hunger, self.Instance)
	self.Package:sendKey("Health", self.Health, self.Instance)
	self.Package:sendKey("Oxygen", self.Oxygen, self.Instance)
	self.Package:sendKey("MaxOxygen", self.MaxOxygen, self.Instance)
end

VitalComponent.ReplicateKey = function(self, Key: VitalAttributes)
	self.Package:sendKey(Key, self[Key], self.Instance)
end

VitalComponent.TakeDamage = function(self, Amount: number)
	local targetHealth = self.Health - Amount
	if targetHealth <= 0 then
		self.Health = 0
		self.Package:sendKey("Health", self.Health, self.Instance)
		warn(`[{self.Instance} Died!]`)
		return false
	end
	targetHealth = math.clamp(targetHealth, 0, 100)
	self.Health = targetHealth
	self.Package:sendKey("Health", self.Health, self.Instance)
	return true
end

VitalComponent.ConsumeOxygen = function(self, Amount: number)
	local targetOxygen = self.Oxygen - Amount
	if targetOxygen <= 0 then
		self.Oxygen = 0
		self.Package:sendKey("Oxygen", self.Oxygen, self.Instance)
		return false
	end
	targetOxygen = math.clamp(targetOxygen, 0, self.MaxOxygen)
	self.Oxygen = targetOxygen
	self.Package:sendKey("Oxygen", self.Oxygen, self.Instance)
	return true
end

VitalComponent.ConsumeHunger = function(self, Amount: number)
	local targetHunger = self.Hunger - Amount
	if targetHunger <= 0 then
		self.Hunger = 0
		self.Package:sendKey("Hunger", self.Hunger, self.Instance)
		return false
	end
	targetHunger = math.clamp(targetHunger, 0, 100)
	self.Hunger = targetHunger
	self.Package:sendKey("Hunger", self.Hunger, self.Instance)
	return true
end

VitalComponent.SetArmor = function(self, Amount: number)
	self.Armor = Amount
	self.Package:sendKey("Armor", self.Armor, self.Instance)
	return true
end

VitalComponent.Heal = function(self, Amount: number)
	local targetHealth = self.Health + Amount
	targetHealth = math.clamp(targetHealth, 0, 100)
	self.Health = targetHealth
	self.Package:sendKey("Health", self.Health, self.Instance)
	return true
end

VitalComponent.IncreaseHunger = function(self, Amount: number)
	local targetAmount = self.Hunger + Amount
	Amount = math.clamp(targetAmount, 0, 100)
	self.Hunger = Amount
	self.Package:sendKey("Hunger", self.Hunger, self.Instance)
	return true
end

VitalComponent.IncreaseOxygen = function(self, Amount: number)
	local targetAmount = self.Oxygen + Amount
	Amount = math.clamp(targetAmount, 0, self.MaxOxygen)
	self.Oxygen = Amount
	self.Package:sendKey("Oxygen", self.Oxygen, self.Instance)
	return true
end

VitalComponent.SetMaxOxygen = function(self, Amount: number)
	self.MaxOxygen = Amount
	self.Package:sendKey("MaxOxygen", self.MaxOxygen, self.Instance)
	return true
end

VitalComponent:OnInit(function(self)
	self.Armor = 0
	self.Health = 100
	self.Hunger = 100
	self.Stamina = 100
	self.Oxygen = 30
	self.MaxOxygen = 30

	self.Package = self.Network.Packages.VitalKey
end)

VitalComponent:OnTick(function(self, deltaTime: number)
	self:Heal(0.5)
end, Modux.TickRate.Hz1)

return VitalComponent
