-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Pucci",
    Title = "Pucci",
    Body = "Welcome to my shop, in here you can access your Stand Storage.<br/><br/>You don't need to talk to me, just stop in here anytime and your menu will work.",
    Choice_1 = {
        Display = true,
        Text = "Mobile Storage?",
        --CustomSize = UDim2.new(0.6, 6, 0.9, 0),
        Action = {
            Type = "ChangeStage",
            Stage = "MobileStorage"
        }
    },

    Choice_2 = {
        Display = true,
        Text = "Sacrifice Stands?",
        Action = {
            Type = "ChangeStage",
            Stage = "Sacrifice"
        }
    },

    Choice_3 = {
        Display = false,
    },
}

module.Stage.MobileStorage = {
    IconName = "Icon_Pucci",
    Title = "Pucci",
    Body = "If you want to be able to manage your stands outside the shop you will need to get the MOBILE STORAGE pass, then you can use any of my services wherver you go!",
    Choice_1 = {
        Display = true,
        Text = "Sacrifice Stands?",
        Action = {
            Type = "ChangeStage",
            Stage = "Sacrifice"
        }
    },

    Choice_2 = {
        Display = true,
        Text = "Aight thanks",
        Action = {
            Type = "Close",
        }
    },

    Choice_3 = {
        Display = false,
    },
}

module.Stage.Sacrifice = {
    IconName = "Icon_Pucci",
    Title = "Pucci",
    Body = "Sacrificing stands is a great way to get Soul Orbs. I will give you 1 Soul Orb for every 100 XP the stand has.<br/><br/>You can use Soul Orbs to buy more storage, and 'other' things too.",
    Choice_1 = {
        Display = true,
        Text = "Mobile Stand Storage?",
        --CustomSize = UDim2.new(0.6, 6, 0.9, 0),
        Action = {
            Type = "ChangeStage",
            Stage = "MobileStorage"
        }
    },

    Choice_2 = {
        Display = true,
        Text = "Aight thanks",
        Action = {
            Type = "Close",
        },
    },

    Choice_3 = {
        Display = false,
    },
}


return module