-- HiddenDio Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- nothign here yet
end

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Dio",
    Title = "Dio",
    Body = "Wondering how all these arrows got here? Or why there are so many stand users from all timelines here at once?<br/><br/>" ..
    "<b>It Was Me, Dio!</b>",
    Choice_1 = {
        Display = true,
        Text = "Why did you do it?",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "Why"
        }
    },

    Choice_2 = {
        Display = false,
    },

    Choice_3 = {
        Display = false,
    },
}

module.Stage.Why = {
    IconName = "Icon_Dio",
    Title = "Dio",
    Body = "The more carefully you scheme, the more unexpected events come along!<br/><br/>" ..
    "By creating more stand users to build my army, I will burn Jonathan's family tree to the ground!",
    Choice_1 = {
        Display = true,
        Text = "How did you do it?",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "How"
        }
    },

    Choice_2 = {
        Display = false,
    },

    Choice_3 = {
        Display = false,
    },
}

module.Stage.How = {
    IconName = "Icon_Dio",
    Title = "Dio",
    Body = "The leader of the Pillar Men was banished into space ...<br/><br/>" ..
    "The arrow heads are made from a rare metal only found in a special metorite. Even a small brained loser like you can figure out the rest.",
    Choice_1 = {
        Display = true,
        Text = "Right ...",
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