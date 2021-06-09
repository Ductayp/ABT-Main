-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end


module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Giorno",
    Title = "Gang Star",
    Body = "Im trying to get back to Naples, but I'm trapped in this Time Rift with everyone else. Theres no way across the water in fact its not water at all." ..
        "<br/><br/>If we could gather up enough <b>DUNEGON KEYS</b> then maybe we could stabilize the Rift long enough to travel to other places.",
    Choice_1 = {
        Display = true,
        Text = "It's not water?",
        Action = {
            Type = "ChangeStage",
            Stage = "NotWater"
        }
    },
    Choice_2 = {
        Display = true,
        Text = "Dunegon Keys?",
        Action = {
            Type = "ChangeStage",
            Stage = "DunegonKeys"
        }
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.NotWater = {
    IconName = "Icon_Giorno",
    Title = "Gang Star",
    Body = "This all around me is NOT water. It's PINK after all. It seems to be some substance that connects different times in the Rift." ..
        "<br/><br/>Don't try to swim, it's highly unstable and your body will be ripped to pieces. We need the <b>Dunegon Keys.</b> to travel off this island.",
    Choice_1 = {
        Display = true,
        Text = "Dunegon Keys?",
        Action = {
            Type = "ChangeStage",
            Stage = "DunegonKeys"
        }
    },
    Choice_2 = {
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.DunegonKeys = {
    IconName = "Icon_Giorno",
    Title = "Gang Star",
    Body = "A <b>Dunegon Key</b> is concentrated collection of power, in the shape of a key. We use them to stablize the time rift and travel into areas that are highly unstable." ..
        "<br/><br/>You can find them around or you can buy them at the shop, dont ask where they come from.",
    Choice_1 = {
        Display = true,
        Text = "It's not water?",
        Action = {
            Type = "ChangeStage",
            Stage = "NotWater"
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