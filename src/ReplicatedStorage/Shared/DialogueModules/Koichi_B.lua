-- Koichi_B

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.DungeonTravel = {
    DuwangHarbor = {
        Input = {
            Key = "DungeonKey",
            Value = 2
        },
        SpawnName = "DuwangHarbor",
        MapZone = "DuwangHarbor",
    },
}

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Koichi",
    Title = "Smol Guy",
    Body = "Let's get to work! Akira is causing too much trouble with all these arrows. Kill his stand Hot Tamale to get a bunch of <b>BROKEN ARROWS.</b>" ..
        "<br/><br/>Just let me know when your ready to leave here.",
    Choice_1 = {
        Display = true,
        Text = "LEAVE DUNGEON",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(85, 85, 255), Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "DungeonLeave"
        }
    },
    Choice_2 = {
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}


module.Stage.DungeonLeave = {
    IconName = "Icon_Koichi",
    Title = "Smol Guy",
    Body = "Are you sure you are ready to leave? There might be more <b>BROKEN ARROWS</b> laying around ..."  ..
        "<br/><br/>If you want to come back, you will have to use more keys.",
    Choice_1 = {
        Display = true,
        Text = "YES",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(0, 255, 0), Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "LeaveDungeon",
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