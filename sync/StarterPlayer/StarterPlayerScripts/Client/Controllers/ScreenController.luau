--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modux = require(ReplicatedStorage.Shared.Modux)

local ScreenController = Modux.Controller("ScreenController")

ScreenController:OnInit(function(self) end)

ScreenController:OnStart(function(self) end)

return ScreenController
