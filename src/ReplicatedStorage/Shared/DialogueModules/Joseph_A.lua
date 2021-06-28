-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- nothign here yet
end

module.DungeonTravel = {
    SkeletonHeelStone = {
        Input = {
            Key = "DungeonKey",
            Value = 3
        },
        SpawnName = "SkeletonHeelStone",
        MapZone = "SkeletonHeelStone",
    },
}


module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Joseph",
    Title = "Joseph",
    Body = "Wait! Your next line is, 'Whats in that HUGE arena over there?'" ..
        "<br/><br/>Well, last time I was there, I fought Wham and won! Looks like Wham is back though, in fact, LOTS of him!",
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
    IconName = "Icon_Joseph",
    Title = "Joseph",
    Body = "Stabilizing the Time Rift to get you there won't be easy. I need Dunegon Keys and they dont grow on trees!" ..
        "<br/><br/>Do you want to pend <b>6 Dunegon Keys</b> to get there?",
        Choice_1 = {
            Display = true,
            Text = "YES",
            CustomProperties = {BackgroundColor3 = Color3.fromRGB(0, 255, 0), Size = UDim2.new(0.4, 0, 0.9, 0)},
            Action = {
                Type = "DungeonTravel",
                ModuleName = "Joseph_A",
                TransactionKey = "SkeletonHeelStone",
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