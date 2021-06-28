-- Rohan Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- nothing here yet
end

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Rohan",
    Title = "Famous Mangaka",
    Body = "Please don't interrupt my work, I have another chapter to get out and I need more pages to fill.<br/><br/>Have you seen any pages floating around?",
    Choice_1 = {
        Display = true,
        Text = "No I Haven't",
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

module.Stage.WhatsGoinOn_1 = {
    IconName = "Icon_Rohan",
    Title = "Famous Mangaka",
    Body = "Whatever is going on, it's going to make a great story if I can get my pages back.<br/><br/>Just yesterday some overly-muscular version of myself stole my blank pages, said something about not wanting Dio to find them.",
    Choice_1 = {
        Display = true,
        Text = "A buff version of YOU?",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "WhatsGoinOn_2"
        }
    },

    Choice_2 = {
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.WhatsGoinOn_2 = {
    IconName = "Icon_Rohan",
    Title = "Famous Mangaka",
    Body = "Thats right! It must have been me from another time, and theres more than one too! Must be some sort of time loop or rift hapenening.<br/><br/>Just not sure how I got so buff in the future ...",
    Choice_1 = {
        Display = true,
        Text = "Whatever ...",
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