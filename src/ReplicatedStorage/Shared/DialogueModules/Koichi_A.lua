-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.DungeonTravel = {
    DuwangHarbor = {
        Input = {
            Key = "Cash",
            Value = 3000
        },
        SpawnName = "DuwangHarbor",
        MapZone = "DuwangHarbor",
    },
}

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Koichi",
    Title = "Small Guy",
    Body = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec scelerisque nibh finibus interdum ullamcorper." ..
        "<br/><br/>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec scelerisque nibh finibus interdum ullamcorper.",
    Choice_1 = {
        Display = true,
        Text = "DUNGEON",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(85, 85, 255), Size = UDim2.new(0.25, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "Dungeon"
        }
    },
    Choice_2 = {
        Display = true,
        Text = "Who is Wham?",
        Action = {
            Type = "ChangeStage",
            Stage = "NextLine"
        }
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.NextLine = {
    IconName = "Icon_Koichi",
    Title = "Small Guy",
    Body = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec scelerisque nibh finibus interdum ullamcorper." ..
        "<br/><br/>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec scelerisque nibh finibus interdum ullamcorper.",
    Choice_1 = {
        Display = true,
        Text = "DUNGEON",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(85, 85, 255), Size = UDim2.new(0.25, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "ArenaDungeon"
        }
    },
    Choice_2 = {
        Display = true,
        Text = "Why Are Pillar Men here?",
        CustomProperties = {Size = UDim2.new(0.5, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "PillarMen"
        }
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.Dungeon = {
    IconName = "Icon_Koichi",
    Title = "Small Guy",
    Body = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec scelerisque nibh finibus interdum ullamcorper." ..
        "<br/><br/>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec scelerisque nibh finibus interdum ullamcorper.</b>",
    Choice_1 = {
        Display = true,
        Text = "Spend 3,000 Cash",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(85, 85, 255), Size = UDim2.new(0.6, 0, 0.9, 0)},
        Action = {
            Type = "DungeonTravel",
            ModuleName = "Koichi_A",
            TransactionKey = "DuwangHarbor",
        }
    },
    Choice_2 = {
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}



return module