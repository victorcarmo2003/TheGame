-- modux ignore file
export type AlienType =
	"Common"
	| "Intermediate"
	| "Runner"
	| "Rage"
	| "Telekinesis"
	| "Screamer"
	| "Shooter"
	| "Knifer"
	| "Sniper"
	| "Tanker"
	| "Brutus"

export type AlienStates = 
	"Idle"
	| "Walk"
	| "Running"
	| "Jumping"
	| "attacking"
	| "attacked"

export type AliensEnum = {
	Common: "Common",
	Intermediate: "Intermediate",
	Runner: "Runner",
	Rage: "Rage",
	Telekinesis: "Telekinesis",
	Screamer: "Screamer",
	Shooter: "Shooter",
	Knifer: "Knifer",
	Sniper: "Sniper",
	Tanker: "Tanker",
	Brutus: "Brutus",
}

return {
	Common = "Common",
	Intermediate = "Intermediate",
	Runner = "Runner",
	Rage = "Rage",
	Telekinesis = "Telekinesis",
	Screamer = "Screamer",
	Shooter = "Shooter",
	Knifer = "Knifer",
	Sniper = "Sniper",
	Tanker = "Tanker",
	Brutus = "Brutus",
} :: AliensEnum
