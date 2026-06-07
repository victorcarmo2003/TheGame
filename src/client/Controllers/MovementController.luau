local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FSM = require(ReplicatedStorage.Shared.Utils.FSM)
local Modux = require(ReplicatedStorage.Shared.Modux)

export type MovementStates = "Walking" | "Running" | "Crouch" | "Jumping" | "Dead"

local MovementController = Modux.Controller("MovementController"):Import("InputController")

local transitions: FSM.Transitions<MovementStates> = {
	Walking = { "Running", "Crouch", "Jumping", "Dead" }, -- can do everything
	Running = { "Walking", "Crouch", "Jumping", "Dead" }, -- can do everything
	Crouch = { "Walking", "Running", "Jumping", "Dead" }, -- can do everything
	Jumping = { "Walking", "Running", "Dead" },
}

MovementController.State = FSM.new<<MovementStates>>("Walking", transitions)

MovementController.StartWalk = function(self)
	local result = self.Network.Packages.CanMovement:request({ ActionName = "Walk" })
	if result.CanDo then
		self.LocalHumanoid.WalkSpeed = 16
	else
		self.State:Transition(result.CurrentState)
	end
end

MovementController.StartRun = function(self)
	local result = self.Network.Packages.CanMovement:request({ ActionName = "Run" })
	if result.CanDo then
		self.LocalHumanoid.WalkSpeed = 24
	else
		self.State:Transition(result.CurrentState)
	end
end

MovementController.StartCrouch = function(self)
	local result = self.Network.Packages.CanMovement:request({ ActionName = "Crouch" })
	if result.CanDo then
		self.LocalHumanoid.WalkSpeed = 10
	else
		self.State:Transition(result.CurrentState)
	end
end

MovementController.HandleTranstions = function(self)
	self.State:OnLeave("Crouch", function(state, otherState)
		-- animation stop
	end)

	self.State:OnEnter("Crouch", function(stateates, otherState)
		-- animation start
	end)
end

MovementController.BindKeys = function(self)
	local ShiftHandler = self.InputController:BindAction("Sprint", Enum.KeyCode.LeftShift, true, 10)
	ShiftHandler.OnPress(function()
		local canChange = MovementController.State:Transition("Running")
		if canChange then
			self:StartRun()
		end
	end)

	ShiftHandler.OnRelease(function()
		local canChange = MovementController.State:Transition("Walking")
		if canChange then
			self:StartWalk()
		end
	end)

	local CHandler = self.InputController:BindAction("Crouch", Enum.KeyCode.C, true, 10)

	CHandler.OnPress(function()
		if MovementController.State:Is("Crouch") then
			local canChange = MovementController.State:Transition("Walking")
			if canChange then
				self:StartWalk()
			end
			return
		end

		local canChange = MovementController.State:Transition("Crouch")
		if canChange then
			self:StartCrouch()
		end
	end)
end

MovementController:OnStart(function(self)
	self:BindKeys()
	self:HandleTranstions()
end)

return MovementController
