-- Jotaro Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- nothing here yet
end

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Jotaro",
    Title = "Funny Hat Guy",
    Body = "This island seems to be at the nexus of a TIME RIFT where many timelines cross. As the timelines overlap, it's common to see time-clones walking around." .. 
        "<br/><br/>Dio must be up to soemthing.",
    Choice_1 = {
        Display = true,
        Text = "Time Rift?",
        Action = {
            Type = "ChangeStage",
            Stage = "TimeRift"
        }
    },

    Choice_2 = {
        Display = true,
        Text = "Time Clones?",
        Action = {
            Type = "ChangeStage",
            Stage = "TimeClones"
        }
    },

    Choice_3 = {
        Display = false,
    },
}

module.Stage.TimeRift = {
    IconName = "Icon_Jotaro",
    Title = "Funny Hat Guy",
    Body = "Did you notice the water looks CRAZY PINK? If you go into it, you die. Thats not water at all I bet." ..
        "<br/><br/>You might want to talk to the Gang Star at the end of the dock to see what he knows about it.",
    Choice_1 = {
        Display = true,
        Text = "Time Clones?",
        Action = {
            Type = "ChangeStage",
            Stage = "TimeClones"
        }
    },
    Choice_2 = {
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.TimeClones = {
    IconName = "Icon_Jotaro",
    Title = "Funny Hat Guy",
    Body = "I dont know what to call them but they are multiple copies of someone, as if they arrived here from other timelines." ..
        "<br/><br/>If you see any that look like me, just kill them please. Those guys are a bunch of idiots and they keep stealing my hat.",
    Choice_1 = {
        Display = true,
        Text = "Time Rift?",
        Action = {
            Type = "ChangeStage",
            Stage = "TimeRift"
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