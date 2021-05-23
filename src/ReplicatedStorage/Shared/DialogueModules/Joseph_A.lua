-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.DungeonTravel = {
    SkeletonHeelStone = {
        Input = {
            Key = "Cash",
            Value = 3000
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
        Text = "DUNGEON",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(85, 85, 255), Size = UDim2.new(0.25, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "ArenaDungeon"
        }
    },
    Choice_2 = {
        Display = true,
        Text = "Who is Wham?",
        Action = {
            Type = "ChangeStage",
            Stage = "Wham"
        }
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.Wham = {
    IconName = "Icon_Joseph",
    Title = "Joseph",
    Body = "Wham is a Pillar Man, like these others on the beach but more powerful. Next you're gonna say 'Why is there more than one of them?'" ..
        "<br/><br/>I guess it's because the Time Rift? Seems like multiple copies of everyone show up here, I don't even know how I got here!",
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

module.Stage.ArenaDungeon = {
    IconName = "Icon_Joseph",
    Title = "Joseph",
    Body = "Stabilizing the Time Rift to get you there won't be easy. I need Time Crystals and they dont grow on trees!" ..
        "<br/><br/>Those crystals will cost me, AND YOU, a grand total of <b>3,000 Cash.</b>",
    Choice_1 = {
        Display = true,
        Text = "Spend 3,000 Cash",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(85, 85, 255), Size = UDim2.new(0.6, 0, 0.9, 0)},
        Action = {
            Type = "DungeonTravel",
            ModuleName = "Joseph_A",
            TransactionKey = "SkeletonHeelStone",
        }
    },
    Choice_2 = {
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.PillarMen = {
    IconName = "Icon_Joseph",
    Title = "Joseph",
    Body = "The leader of the Pillar Men is Kars. Why he brought them to Earth, I dont know but they are NOT from here!" ..
        "<br/><br/>Last I saw Kars, I sent him on a little trip ... TO OUTER SPACE! Frozen solid and floating through space for eternity.",
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
        Text = "Is Kars Dead?",
        --CustomProperties = {Size = UDim2.new(0.6, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "Kars"
        }
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.Kars = {
    IconName = "Icon_Joseph",
    Title = "Joseph",
    Body = "Wait! Your next line is, 'Is Kars dead?'" ..
        "<br/><br/>Well, I guess as the Ultimate Life Form, he wont actually die. Can't help but wonder what he's thinking about ...",
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
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}

return module