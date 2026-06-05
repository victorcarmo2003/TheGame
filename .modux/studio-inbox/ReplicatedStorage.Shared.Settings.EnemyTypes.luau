export type EnemyType = {
	ModelName: string,
	BaseHealth: number,
	BaseDamage: number,
	WalkSpeed: number,
	SpawnCost: number,
	MinDifficult: number,
}

return {
	Common = {
		ModelName = "Common",
		BaseHealth = 100,
		BaseDamage = 10,
		WalkSpeed = 10,
		SpawnCost = 10,
		MinDifficult = 1,
	},
	
	Intermediate = {
		ModelName = "Intermediate",
		BaseHealth = 200,
		BaseDamage = 20,
		WalkSpeed = 15,
		SpawnCost = 20,
		MinDifficult = 2,
	},
	
	Runner = {
		ModelName = "Runner",
		BaseHealth = 150,
		BaseDamage = 15,
		WalkSpeed = 20,
		SpawnCost = 15,
		MinDifficult = 3,
	},
	
	Rage = {
		ModelName = "Rage",
		BaseHealth = 300,
		BaseDamage = 30,
		WalkSpeed = 10,
		SpawnCost = 30,
		MinDifficult = 4,
	},
	
	Telekinesis = {
		ModelName = "Telekinesis",
		BaseHealth = 400,
		BaseDamage = 40,
		WalkSpeed = 10,
		SpawnCost = 40,
		MinDifficult = 5,
	},
	
	Screamer = {
		ModelName = "Screamer",
		BaseHealth = 500,
		BaseDamage = 50,
		WalkSpeed = 10,
		SpawnCost = 50,
		MinDifficult = 6,
	},
	
	Shooter = {
		ModelName = "Screamer",
		BaseHealth = 500,
		BaseDamage = 50,
		WalkSpeed = 10,
		SpawnCost = 50,
		MinDifficult = 6,
	}
}