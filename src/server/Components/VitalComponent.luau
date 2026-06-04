local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modux = require(ReplicatedStorage.Shared.Modux)

local VitalComponent = Modux.Component("VitalComponent"):Tag("Vital"):ClassName("Player")

VitalComponent.OnDie = VitalComponent.Signal.new() :: Modux.Signal<Player>

VitalComponent.ReplicateAll = function(self)
	self.Package:sendKey("Armor", self.Armor, self.Instance)
	self.Package:sendKey("Hunger", self.Hunger, self.Instance)
	self.Package:sendKey("Health", self.Health, self.Instance)
	self.Package:sendKey("Oxygen", self.Oxygen, self.Instance)
	self.Package:sendKey("MaxOxygen", self.MaxOxygen, self.Instance)
end

VitalComponent.TakeDamage = function(self, Amount: number)
	local targetHealth = self.Health - Amount
	if targetHealth <= 0 then
		self.Health = 0
		self.Package:sendKey("Health", self.Health, self.Instance)
		warn(`[{self.Instance} Died!]`)
		return
	end
	targetHealth = math.clamp(targetHealth, 0, 100)
	self.Health = targetHealth
	self.Package:sendKey("Health", self.Health, self.Instance)
end

VitalComponent.ConsumeOxygen = function(self, Amount: number)
	local targetOxygen = self.Oxygen - Amount
	if targetOxygen <= 0 then
		self.Oxygen = 0
		self.Package:sendKey("Oxygen", self.Oxygen, self.Instance)
		warn(`[{self.Instance} Lack of oxygen!]`)
		return
	end
	targetOxygen = math.clamp(targetOxygen, 0, self.MaxOxygen)
	self.Oxygen = targetOxygen
	self.Package:sendKey("Oxygen", self.Oxygen, self.Instance)
end

VitalComponent.ConsumeHunger = function(self, Amount: number)
	local targetHunger = self.Hunger - Amount
	if targetHunger <= 0 then
		self.Hunger = 0
		self.Package:sendKey("Oxygen", self.Hunger, self.Instance)
		warn(`[{self.Instance} is Hunger!]`)
		return
	end
	targetHunger = math.clamp(targetHunger, 0, 100)
	self.Hunger = targetHunger
	self.Package:sendKey("Hunger", self.Hunger, self.Instance)
end

VitalComponent.SetArmor = function(self, Amount: number)
	self.Armor = Amount
	self.Package:sendKey("Armor", self.Armor, self.Instance)
end

VitalComponent.Heal = function(self, Amount: number)
	local targetHealth = self.Health + Amount
	targetHealth = math.clamp(targetHealth, 0, 100)
	self.Health = targetHealth
	self.Package:sendKey("Health", self.Health, self.Instance)
end

VitalComponent.IncreaseHunger = function(self, Amount: number)
	local targetAmount = self.Hunger + Amount
	Amount = math.clamp(targetAmount, 0, 100)
	self.Hunger = Amount
	self.Package:sendKey("Hunger", self.Hunger, self.Instance)
end

VitalComponent.IncreaseOxygen = function(self, Amount: number)
	local targetAmount = self.Oxygen + Amount
	Amount = math.clamp(targetAmount, 0, self.MaxOxygen)
	self.Oxygen = Amount
	self.Package:sendKey("Oxygen", self.Oxygen, self.Instance)
end

VitalComponent.SetMaxOxygen = function(self, Amount: number)
	self.MaxOxygen = Amount
	self.Package:sendKey("MaxOxygen", self.MaxOxygen, self.Instance)
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

VitalComponent:OnStart(function(self)
	warn(`[UI Showcase]`)
	task.spawn(function()
		while task.wait(1) do
			self:TakeDamage(10)
			self:ConsumeOxygen(5)
			self:ConsumeHunger(5)
			task.wait(1)
			self:TakeDamage(5)
			self:ConsumeHunger(15)
			self:ConsumeOxygen(15)
			task.wait(1)
			self:TakeDamage(50)
			self:ConsumeHunger(30)
			self:ConsumeOxygen(5)
			warn(`[repetindo]`)
			task.wait(1)
			self:Heal(100)
			self:IncreaseHunger(100)
			self:IncreaseOxygen(100)
		end
	end)
end)

return VitalComponent
