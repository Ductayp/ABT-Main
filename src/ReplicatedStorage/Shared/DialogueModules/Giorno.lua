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
        "<br/><br/>If we could gather up enough Soul Shards then maybe we could stabilize the Rift long enough to travel to other places.",
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
        Text = "What are Shards?",
        Action = {
            Type = "ChangeStage",
            Stage = "Shards"
        }
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.NotWater = {
    IconName = "Icon_Giorno",
    Title = "Gang Star",
    Body = "Does it look like water? It's PINK after all. It seems to be some substance that connects different times in the continuum." ..
        "<br/><br/>But DONT try to swim, it's highly unstable and your body will be ripped to pieces and scattered across time. We need the Shards.",
    Choice_1 = {
        Display = true,
        Text = "What are Shards?",
        Action = {
            Type = "ChangeStage",
            Stage = "Shards"
        }
    },
    Choice_2 = {
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.Shards = {
    IconName = "Icon_Giorno",
    Title = "Gang Star",
    Body = "A Soul Shard is cencentrated collection of souls. We can use them to stablize the time rift and travel off this island." ..
        "<br/><br/>You get then by SACRIFICING a stand. You should go to the STAND STORAGE shop in town, Enrico will explain it more.",
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