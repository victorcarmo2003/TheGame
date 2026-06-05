local Aliens = require(game.ReplicatedStorage.Shared.Enums.Aliens)

export type SpawnType = "Base" | "Field"

export type SpawnAreaType = {
    [SpawnType]: {
        Enabled: boolean,
        MinDifficulty: number,
        MaxDifficulty: number,
        AlienWeights: { [string]: number },
    }
}

return {
    Base = {
        Enabled = false
        MinDifficulty = 1,
        MaxDifficulty = 999,
        AlienWeights = {
            Common = 0,
        }
    },

    Field = {
        Enabled = true,
        MinDifficulty = 1,
        MaxDifficulty = 3,
        AlienWeights = {
            Common = 70,
            Intermediate = 20,
            Runner = 10,
        },
    },
} :: SpawnAreaType