-- modux ignore file
type EnemyConfig = {
	BaseHealth: number,
	BaseDamage: number,
	WalkSpeed: number,
}

local CollectionService = game:GetService("CollectionService")
local Modux = require(game.ReplicatedStorage.Shared.Modux)
local Aliens = require(game.ReplicatedStorage.Shared.Enums.Aliens)
local EnemyTypes = require(game.ReplicatedStorage.Shared.Settings.EnemyTypes)

type AlienType = Aliens.AlienType

local AlienBaseMixin = Modux.Mixin("AlienBaseMixin")
local ARRIVE_DISTANCE = 0.25
local DEFAULT_WALK_SPEED = 10

local function getAlienType(instance: Model): AlienType
	local attributeType = instance:GetAttribute("AlienType")
	if typeof(attributeType) == "string" and EnemyTypes[attributeType :: AlienType] then
		return attributeType :: AlienType
	end

	if EnemyTypes[instance.Name :: AlienType] then
		return instance.Name :: AlienType
	end

	return Aliens.Common
end

local function setHumanoidStats(instance: Model, health: number, walkSpeed: number)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	humanoid.MaxHealth = health
	humanoid.Health = health
	humanoid.WalkSpeed = walkSpeed
end

local function getTargetCFrame(currentPosition: Vector3, targetPosition: Vector3): CFrame
	local offset = targetPosition - currentPosition
	local flatOffset = Vector3.new(offset.X, 0, offset.Z)
	if flatOffset.Magnitude <= 0.001 then
		return CFrame.new(targetPosition)
	end

	return CFrame.lookAt(targetPosition, targetPosition + flatOffset.Unit)
end

function AlienBaseMixin:Configure(config: EnemyConfig)
	self.Config = config :: EnemyConfig
	self.Health = config.BaseHealth :: number
	self.MaxHealth = config.BaseHealth :: number
	self.Damage = config.BaseDamage :: number
	self.WalkSpeed = config.WalkSpeed :: number

	self.Instance:SetAttribute("Health", self.Health)
	self.Instance:SetAttribute("MaxHealth", self.MaxHealth)
	self.Instance:SetAttribute("Damage", self.Damage)
	self.Instance:SetAttribute("WalkSpeed", self.WalkSpeed)

	setHumanoidStats(self.Instance, self.Health, self.WalkSpeed)
end

function AlienBaseMixin:TakeDamage(amount: number)
	if self.IsDead then
		return
	end

	self.Health = math.max(0, self.Health - amount) :: number
	self.Instance:SetAttribute("Health", self.Health)
	if self.Health <= 0 then
		self:Die()
	end
end

function AlienBaseMixin:Die()
	if self.IsDead then
		return
	end

	self.IsDead = true :: boolean
	CollectionService:AddTag(self.Instance, "Died")
	self.Instance:SetAttribute("IsDead", true)
	self.Instance:Destroy()
end

function AlienBaseMixin:MoveTo(position: Vector3)
	self.MoveTarget = position :: Vector3
	self.IsMoving = true :: boolean
end

function AlienBaseMixin:StopMoving()
	self.MoveTarget = nil
	self.IsMoving = false :: boolean
end

function AlienBaseMixin:UpdateMovement(deltaTime: number)
	if self.IsDead or not self.IsMoving or typeof(self.MoveTarget) ~= "Vector3" then
		return
	end

	local currentCFrame = self.Instance:GetPivot()
	local currentPosition = currentCFrame.Position
	local targetPosition = self.MoveTarget
	local distance = (targetPosition - currentPosition).Magnitude
	if distance <= ARRIVE_DISTANCE then
		self.Instance:PivotTo(CFrame.new(targetPosition) * currentCFrame.Rotation)
		self:StopMoving()
		return
	end

	local walkSpeed = if typeof(self.WalkSpeed) == "number" then self.WalkSpeed else DEFAULT_WALK_SPEED
	local alpha = math.clamp((walkSpeed * deltaTime) / distance, 0, 1)
	self.Instance:PivotTo(currentCFrame:Lerp(getTargetCFrame(currentPosition, targetPosition), alpha))
end

function AlienBaseMixin:ChooseTarget()
	return nil
end

function AlienBaseMixin:StartSonar() end

AlienBaseMixin:OnInit(function(self)
	self.Type = getAlienType(self.Instance) :: AlienType
	local config = EnemyTypes[self.Type] or EnemyTypes[Aliens.Common]
	self:Configure(config)
end)

AlienBaseMixin:OnTick(function(self, deltaTime)
	self:UpdateMovement(deltaTime)
end, Modux.TickRate.Hz30)

AlienBaseMixin:OnDestroy(function(self)
	self.IsDead = true :: boolean
end)

return AlienBaseMixin
