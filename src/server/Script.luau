local Event = Instance.new("RemoteEvent")

local Responses = {
	Equip = function(Player, Item)
		print(`[Item {Item} equipped on Player: {Player}!]`)
	end,
	
	Buy = function(Player, Item)
		print(`[{Player} Trying to buy {Item}!]`)
	end,
}

Event.OnServerEvent:Connect(function(Player, EventName, ...)
	local payload = {...}
	
	if Responses[EventName] then
		Responses[EventName](Player, payload.Item)
	end
end)