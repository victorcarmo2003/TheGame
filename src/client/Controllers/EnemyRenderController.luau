-- modux ignore file
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Modux = require(ReplicatedStorage.Shared.Modux)
local EnemyTypes = require(ReplicatedStorage.Shared.Settings.EnemyTypes)

local EnemyRenderController = Modux.Controller("EnemyRenderController")

local SPAWN_PROXY_TAG = "EnemySpawnProxy"
local RENDER_DISTANCE = 120
local DESPAWN_DISTANCE = 150
local RENDER_LERP_SPEED = 18
local CLIENT_ENEMIES_FOLDER = "ClientEnemies"

local localPlayer = Players.LocalPlayer

local function getRootPart(): BasePart?
	local character = localPlayer.Character
	if not character then
		return nil
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end

	return nil
end

function EnemyRenderController:GetRenderFolder(): Folder
	if self.RenderFolder and self.RenderFolder.Parent then
		return self.RenderFolder
	end

	local folder = Workspace:FindFirstChild(CLIENT_ENEMIES_FOLDER)
	if not folder or not folder:IsA("Folder") then
		folder = Instance.new("Folder")
		folder.Name = CLIENT_ENEMIES_FOLDER
		folder.Parent = Workspace
	end

	self.RenderFolder = folder
	return folder
end

function EnemyRenderController:GetAlienTemplate(alienType: string): Model?
	local config = EnemyTypes[alienType]
	if not config then
		warn(`[EnemyRenderController] EnemyTypes config missing for "{alienType}".`)
		return nil
	end

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local aliensModels = assets and assets:FindFirstChild("AliensModels")
	if not aliensModels then
		warn("[EnemyRenderController] ReplicatedStorage.Assets.AliensModels not found.")
		return nil
	end

	local model = aliensModels:FindFirstChild(config.ModelName)
	if not model or not model:IsA("Model") then
		warn(`[EnemyRenderController] Alien model "{config.ModelName}" not found.`)
		return nil
	end

	return model
end

function EnemyRenderController:RenderProxy(proxy: BasePart)
	if self.Rendered[proxy] then
		return
	end

	local alienType = proxy:GetAttribute("AlienType")
	if typeof(alienType) ~= "string" then
		return
	end

	local template = self:GetAlienTemplate(alienType)
	if not template then
		return
	end

	local model = template:Clone()
	model.Name = `{alienType}Client`
	model:SetAttribute("AlienType", alienType)
	model:SetAttribute("SpawnProxy", proxy.Name)
	model:PivotTo(proxy.CFrame)
	model.Parent = self:GetRenderFolder()

	self.Rendered[proxy] = model
end

function EnemyRenderController:DespawnProxy(proxy: Instance)
	local model = self.Rendered[proxy]
	if model then
		model:Destroy()
		self.Rendered[proxy] = nil
	end
end

function EnemyRenderController:DespawnAll()
	local proxies = {}
	for proxy in self.Rendered do
		table.insert(proxies, proxy)
	end

	for _, proxy in proxies do
		self:DespawnProxy(proxy)
	end
end

function EnemyRenderController:LerpRenderedProxy(proxy: BasePart, deltaTime: number)
	local model = self.Rendered[proxy]
	if not model then
		return
	end

	if not model.Parent then
		self.Rendered[proxy] = nil
		return
	end

	local alpha = math.clamp(1 - math.exp(-RENDER_LERP_SPEED * deltaTime), 0, 1)
	model:PivotTo(model:GetPivot():Lerp(proxy.CFrame, alpha))
end

function EnemyRenderController:UpdateProxy(proxy: Instance, root: BasePart, deltaTime: number)
	if not proxy:IsA("BasePart") then
		return
	end

	local distance = (root.Position - proxy.Position).Magnitude
	if distance <= RENDER_DISTANCE then
		self:RenderProxy(proxy)
	end

	if distance >= DESPAWN_DISTANCE then
		self:DespawnProxy(proxy)
	else
		self:LerpRenderedProxy(proxy, deltaTime)
	end
end

EnemyRenderController:OnStart(function(self)
	self.Rendered = {}
	self.RenderFolder = nil

	self:Cleanup(CollectionService:GetInstanceRemovedSignal(SPAWN_PROXY_TAG):Connect(function(proxy)
		self:DespawnProxy(proxy)
	end))
end)

EnemyRenderController:OnTick(function(self, deltaTime)
	local root = getRootPart()
	if not root then
		warn(`[{script.Parent} - OnTick] Root Part not find.`)
		self:DespawnAll()
		return
	end

	for _, proxy in CollectionService:GetTagged(SPAWN_PROXY_TAG) do
		self:UpdateProxy(proxy, root, deltaTime)
	end
end, 60)

EnemyRenderController:OnDestroy(function(self)
	self:DespawnAll()
end)

return EnemyRenderController
