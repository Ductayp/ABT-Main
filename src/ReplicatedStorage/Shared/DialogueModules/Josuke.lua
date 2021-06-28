-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- nothign here yet
end

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Josuke",
    Title = "Guy With Nice Hair (don't make fun of it!)",
    Body = "You new here too!? Lately so many weird people been showing up, seems like everyone is a stand user these days." .. 
        "<br/><br/><b>If you need to store your stand, visit STAND STORAGE down the street.</b>",
    Choice_1 = {
        Display = true,
        Text = "Why are stand users showing up?",
        CustomProperties = {Size = UDim2.new(0.6, 0, 0.9, 0)},
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
    Body = "No idea whats going on, but things are getting very strange. It seems the whole island might be stuck in a <b>TIME RIFT.</b>" .. 
        "<br/><br/>Maybe my nephew knows more. He's by the hotel.",
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