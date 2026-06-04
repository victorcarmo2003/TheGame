local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:getService("ReplicatedStorage")

-- Folders
local Enums = ReplicatedStorage.Shared.Enums

-- Module
local Modux = require(game.ReplicatedStorage.Shared.Modux)
local AliensEnum = require(Enums.Aliens)

-- Instance
local CharactersValidLists = {}

local AliensComponent = Modux.Component("AliensComponent")
	:Tag("Aliens") --modux ignore line
	:ClassName("Model")
	:Import("PlayerService")

local function getAlienType(Instance: Model)
	local InstanceName = Instance.Name

	return AliensEnum[InstanceName]
end

local function isValidCharacter(Char)
	return CollectionService:HasTag(Char, "Died")
end

local function createConnections()
	AliensComponent.PlayerService:OnCharacterAdded(function(Character, _)
		table.insert(CharactersValidLists, Character)
	end)

	AliensComponent.PlayerService:OnCharacterRemoved(function(Character, _)
		table.remove(CharactersValidLists, table.find(CharactersValidLists, Character))
	end)
end

function AliensComponent:TakeDamage(amount: number)
	self.Health = self.Health - amount
	if self.Health <= 0 then
		self:Destroy()
	end
end

function AliensComponent:MoveTo() end

function AliensComponent:ChooseTarget() end

function AliensComponent:StartSonar() end

--[[
self.Range = 16

function AliensComponent:StartSonar()
    usa o quickzone para checkar os players dentro do range de 16 studs
    fazendo um cubo 16x16x16
    
    se tiver um player dentro
        dispara um raycast para ver se tem visão direta com o player
        se tiver visão, 
        anda em direção à ele
    
end
]]

AliensComponent:OnInit(function(self)
	self.Type = getAlienType(self.Instance) or AliensEnum.Common
	self.Damage = 10
	self.Health = 100
end)

AliensComponent:OnStart(function(self)
	createConnections()
end)

AliensComponent:OnDestroy(function(self) end)

return AliensComponent
