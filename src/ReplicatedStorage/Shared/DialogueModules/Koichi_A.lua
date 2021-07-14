-- Koichi_A

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- nothing here yet
end

module.DungeonTravel = {
    DuwangHarbor = {
        Input = {
            Key = "DungeonKey",
            Value = 1
        },
        SpawnName = "DuwangHarbor",
        MapZone = "DuwangHarbor",
    },
}

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Koichi",
    Title = "Smol Guy",
    Body = "Akira and Hot Tamale have been shooting arrows all over the island! Maybe you can collect some <b>BROKEN ARROWS</b> inside?" ..
        "<br/><br/>I can get you in for <b>1 DUNGEON KEY.</b>",
    Choice_1 = {
        Display = true,
        Text = "ENTER DUNGEON",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(85, 85, 255), Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "Dungeon"
        }
    },
    Choice_2 = {
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}


module.Stage.Dungeon = {
    IconName = "Icon_Koichi",
    Title = "Smol Guy",
    Body = "Do you realy want to spend 2 DUNEGON KEYS to enter this dungeon?",
    Choice_1 = {
        Display = true,
        Text = "YES",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(0, 255, 0), Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "DungeonTravel",
            ModuleName = "Koichi_A",
            TransactionKey = "DuwangHarbor",
        }
    },
    Choice_2 = {
        Display = true,
        Text = "NO",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(255, 0, 0), Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "Close",
        }
    },
    Choice_3 = {
        Display = false,
    },
}



return module