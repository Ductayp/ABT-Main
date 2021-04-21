-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Pucci",
    Title = "Enrico",
    Body = "Welcome to my shop, in here you can access your Stand Storage.<br/><br/>You don't need to talk to me, just stop in here anytime and your menu will work.",
    Choice_1 = {
        Display = true,
        Text = "Mobile Storage?",
        --CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "MobileStorage"
        }
    },

    Choice_2 = {
        Display = true,
        Text = "REMOVE Stand?",
        --CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "RemoveStand"
        }
    },

    Choice_3 = {
        Display = true,
        Text = "EVOLVE Stand?",
        Action = {
            Type = "ChangeStage",
            Stage = "EvolveStand"
        }
    },
}

module.Stage.MobileStorage = {
    IconName = "Icon_Pucci",
    Title = "Enrico",
    Body = "If you want to be able to manage your stands outside the shop you will need to get the MOBILE STORAGE pass<br/><br/>Then your menu will work wherever you go!",
    Choice_1 = {
        Display = true,
        Text = "REMOVE Stand?",
        --CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "RemoveStand"
        }
    },

    Choice_2 = {
        Display = true,
        Text = "EVOLVE a Stand?",
        Action = {
            Type = "ChangeStage",
            Stage = "EvolveStand"
        }
    },

    Choice_3 = {
        Display = false,
    },
}

module.Stage.RemoveStand = {
    IconName = "Icon_Pucci",
    Title = "Enrico",
    Body = "You can remove yur stand in 2 ways: <b>STORE</b> and <b>SACRIFICE</b>.<br/><br/><b>SACRIFICE</b> destroys it gives you a SHARD based on its Rarity.<br/><br/><b>STORE</b> will put it in a storage slot for later.",
    Choice_1 = {
        Display = true,
        Text = "Mobile Storage?",
        --CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "MobileStorage"
        }
    },

    Choice_2 = {
        Display = true,
        Text = "EVOLVE Stand?",
        Action = {
            Type = "ChangeStage",
            Stage = "EvolveStand"
        }
    },

    Choice_3 = {
        Display = false,
    },
}

module.Stage.EvolveStand = {
    IconName = "Icon_Pucci",
    Title = "Enrico",
    Body = "Stands can EVOLVE in 2 ways: You can increase their RARITY as well as TRANSFORM them into entirely NEW STANDS!<br/><br/>" ..
        "To EVOLVE A stand just click it in your storage and then click EVOLVE.",
    Choice_1 = {
        Display = true,
        Text = "REMOVE Stand?",
        --CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "RemoveStand"
        }
    },

    Choice_2 = {
        Display = true,
        Text = "Mobile Storage?",
        --CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "MobileStorage"
        }
    },

    Choice_3 = {
        Display = false,
    },
}


return module