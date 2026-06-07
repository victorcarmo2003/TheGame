local Modux = require(game.ReplicatedStorage.Shared.Modux)

local MovementService = Modux.Service("MovementService")

MovementService:OnInit(function(self)
	self.Network.Packages.CanMovement:handle(
		function(request: { ActionName: string }, player: Player?): { CanDo: boolean }?
			if request.ActionName == "Run" then
				return { CanDo = true }
			end

			if request.ActionName == "Walk" then
				return { CanDo = true }
			end

			if request.ActionName == "Crouch" then
				return { CanDo = true }
			end

			if request.ActionName == "Jump" then
				return { CanDo = true }
			end
			return { CanDo = false }
		end
	)
end)

MovementService:OnStart(function(self) end)

return MovementService
