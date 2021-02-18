-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Josuke",
    Title = "Guy With Nice Hair (don't make fun of it!)",
    Body = "You new here too!? Lately so many weird people been showing up, seems like everyone is a stand user these days. If you already have a Stand and need to store or get rid of it, be sure to visit Pucci's down the street, you can't miss it.",
    Choice_1 = {
        Display = true,
        Text = "Why are stand users showing up?",
        CustomSize = UDim2.new(0.6, 6, 0.9, 0),
        Action = {
            Type = "ChangeStage",
            Stage = "Stage2"
        }
    },
    Choice_2 = {
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.Stage2 = {
    IconName = "Icon_Josuke",
    Title = "Guy With Nice Hair (don't make fun of it!)",
    Body = "No idea whats going on, but things are getting very strange. It seems the whole island might be stuck in a time rift. Maybe my nephew knows more. He's by the hotel.",
    Choice_1 = {
        Display = true,
        Text = "Cool, thanks!",
        Action = {
            Type = "Close",
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