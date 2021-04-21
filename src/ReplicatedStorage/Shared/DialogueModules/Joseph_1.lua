-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end


module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Joseph",
    Title = "Joseph",
    Body = "Wait! Your next line is, 'Is this game PvP Only?'" ..
        "<br/><br/>Well, NO! You can toggle PvP on and off using the button on your right, but it only wroks here at spawn. Or you can head to the Arene for a real fight.",
    Choice_1 = {
        Display = true,
        Text = "A PvP arena?",
        Action = {
            Type = "ChangeStage",
            Stage = "Arena"
        }
    },
    Choice_2 = {
        Display = true,
        Text = "Safe Zone?",
        Action = {
            Type = "ChangeStage",
            Stage = "SafeZone"
        }
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.Arena = {
    IconName = "Icon_Joseph",
    Title = "Joseph",
    Body = "YES! We have a PvP Arena! Next you're gonna say 'How do I get there?'" ..
        "<br/><br/>Well, right now you just walk over there. It's another island next to this one, you cant miss it. Soon we will have a teleprt, but the devs here got busy.",
    Choice_1 = {
        Display = true,
        Text = "Safe Zone?",
        Action = {
            Type = "ChangeStage",
            Stage = "SafeZone"
        }
    },
    Choice_2 = {
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.SafeZone = {
    IconName = "Icon_Joseph",
    Title = "Joseph",
    Body = "This is the Safe Zone. You will have a shield over your head when you can't be hurt by other players." ..
        "<br/><br/>You can toggle PvP (player vs. player) mode on or off, but only while you are in this Safe Zone. You get bonus XP to your stand if you leave it on though.",
    Choice_1 = {
        Display = true,
        Text = "A PvP arena?",
        Action = {
            Type = "ChangeStage",
            Stage = "Arena"
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