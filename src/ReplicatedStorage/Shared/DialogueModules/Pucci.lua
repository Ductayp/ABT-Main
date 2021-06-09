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
    Body = "Welcome to my shop, in here you can access your Stand Storage.<br/><br/>You don't need to talk to me, just use your MENU while inside this shop and it will work.",
    Choice_1 = {
        Display = true,
        Text = "Remove Stand?",
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

module.Stage.MobileStorage = {
    IconName = "Icon_Pucci",
    Title = "Enrico",
    Body = "If you want to be able to manage your stands outside the shop you will need to get the MOBILE STORAGE pass.<br/><br/>Then your menu will work wherever you go!",
    Choice_1 = {
        Display = true,
        Text = "Remove Stand?",
        --CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "RemoveStand"
        }
    },

    Choice_2 = {
        Display = false,
    },

    Choice_3 = {
        Display = false,
    },
}

module.Stage.RemoveStand = {
    IconName = "Icon_Pucci",
    Title = "Enrico",
    Body = "You can remove your stand any time, no matter whee you are!<br/><br/>Just open your stand storage from the main menu, click the stand you want to remove, and click TRASH.",
    Choice_1 = {
        Display = true,
        Text = "Mobile Storage?",
        Action = {
            Type = "ChangeStage",
            Stage = "MobileStorage"
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