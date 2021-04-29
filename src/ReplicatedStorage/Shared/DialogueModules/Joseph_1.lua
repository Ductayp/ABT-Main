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
            Value = 5000
        },
        Destination = "SkeletonHeelStone"
    },
}


module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Joseph",
    Title = "Joseph",
    Body = "Wait! Your next line is, 'Is this game PvP Only?'" ..
        "<br/><br/>Well, NO! You can toggle PvP on and off using the button on your right, but it only wroks here at spawn. Or you can head to the Arene for a real fight.",
    Choice_1 = {
        Display = true,
        Text = "A PvP arena?",
        Action = {
            Type = "ChangeStage",
            Stage = "Arena"
        }
    },
    Choice_2 = {
        Display = true,
        Text = "Safe Zone?",
        Action = {
            Type = "ChangeStage",
            Stage = "SafeZone"
        }
    },
    Choice_3 = {
        Display = true,
        Text = "DUNGEON",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(85, 85, 255), Size = UDim2.new(0.25, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "ArenaDungeon"
        }
    },
}

module.Stage.Arena = {
    IconName = "Icon_Joseph",
    Title = "Joseph",
    Body = "YES! We have a PvP Arena! Next you're gonna say 'How do I get there?'" ..
        "<br/><br/>Well, right now you just walk over there. It's another island next to this one, you cant miss it. Soon we will have a teleprt, but the devs here got busy.",
    Choice_1 = {
        Display = true,
        Text = "Safe Zone?",
        Action = {
            Type = "ChangeStage",
            Stage = "SafeZone"
        }
    },
    Choice_2 = {
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.ArenaDungeon = {
    IconName = "Icon_Joseph",
    Title = "Joseph",
    Body = "Back when I was younger, YADDA YADDA YADDA. I can get you there, bt stabilzing this Time Rift to fly us there will cost you." ..
        "<br/><br/>5,000 CASH to go the The Arena.",
    Choice_1 = {
        Display = true,
        Text = "Pay 5,000 to go to ARENA",
        CustomProperties = {Size = UDim2.new(0.6, 0, 0.9, 0)},
        Action = {
            Type = "DungeonTravel",
            ModuleName = "Joseph_1",
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

module.Stage.SafeZone = {
    IconName = "Icon_Joseph",
    Title = "Joseph",
    Body = "This is the Safe Zone. You will have a shield over your head when you can't be hurt by other players." ..
        "<br/><br/>You can toggle PvP (player vs. player) mode on or off, but only while you are in this Safe Zone. You get bonus XP to your stand if you leave it on though.",
    Choice_1 = {
        Display = true,
        Text = "A PvP arena?",
        Action = {
            Type = "ChangeStage",
            Stage = "Arena"
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