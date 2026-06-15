local Modux = require(game.ReplicatedStorage.Shared.Modux)
local VitalController = Modux.Controller("VitalController"):Import("ScreenController"):Import("UIAnimationsController")

VitalController.AutoConsume = function(self) end

VitalController.UpdateHunger = function(self, number: number)
	local hungerConteiner = self.PlayerStatus.Hunger
	local hungerBar = hungerConteiner.Inner
	local text = hungerConteiner.TextLabel
	local percent = number / (self.MaxHunger or 100)
	local handle = self.UIAnimationsController:Bar(hungerBar, percent)
	handle:Play(percent)
	text.Text = `{number}%`
end

VitalController.UpdateOxygen = function(self, number: number)
	local oxygenConteiner = self.PlayerStatus.Oxygen
	local oxygenBar = oxygenConteiner.Inner
	local text = oxygenConteiner.TextLabel
	local percent = number / (self.MaxOxygen or 100)
	local handle = self.UIAnimationsController:Bar(oxygenBar, percent)
	handle:Play(percent)
	text.Text = `{number}%`
end

VitalController.UpdateHealth = function(self, number: number)
	local healthConteiner = self.PlayerStatus.Health
	local healthBar = healthConteiner.Inner
	local text = healthConteiner.TextLabel
	local percent = number / (self.MaxHealth or 100)
	local handle = self.UIAnimationsController:Bar(healthBar, percent)
	handle:Play(percent)
	text.Text = `{number}%`
end

VitalController:OnInit(function(self)
	self.Health = 100
	self.MaxHealth = 100
	self.Hunger = 100
	self.Oxygen = 30
	self.MaxOxygen = 30
	self.Network.Packages.VitalKey:onKey(function(key, value)
		if key == "Health" then
			self.Health = value
			self:UpdateHealth(value)
		end
		if key == "Oxygen" then
			self.Oxygen = value
			self:UpdateOxygen(value)
		end
		if key == "Hunger" then
			self.Hunger = value
			self:UpdateHunger(value)
		end
	end)
end)

VitalController:OnStart(function(self)
	local screenGui = self.ScreenController:GetGui()
	self.PlayerStatus = screenGui.Conteiner.Player
	task.spawn(function()
		local Vitals = self.Network.Packages.GetVitals:request(nil)

		if Vitals then
			self.Armor = Vitals.Armor
			self.Health = Vitals.Health
			self.Hunger = Vitals.Hunger
			self.Oxygen = Vitals.Oxygen
			self.Stamina = Vitals.Stamina
			self.MaxOxygen = Vitals.MaxOxygen
			self.MaxHealth = (Vitals.MaxHealth :: number) or 100
			self.MaxHunger = (Vitals.MaxHunger :: number) or 100
			self.MaxStamina = (Vitals.MaxStamina :: number) or 100

			self:UpdateHealth(self.Health)
			self:UpdateHunger(self.Hunger)
			self:UpdateOxygen(self.Oxygen)
		end
	end)
end)

return VitalController
