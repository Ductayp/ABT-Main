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
    Body = "Wait! Your next line is, 'You are here too?' and I would say, 'How else do you think I got you here?'" ..
        "<br/><br/>You can go home for free, but to come back you will have to pay me again. Oh Yes!",
    Choice_1 = {
        Display = true,
        Text = "GO HOME",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(85, 85, 255), Size = UDim2.new(0.25, 0, 0.9, 0)},
        Action = {
            Type = "LeaveDungeon",
        }
    },
    Choice_2 = {
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.GoHome = {
    IconName = "Icon_Joseph",
    Title = "Joseph",
    Body = "You can go home for free, the connection was already made. Next you're gonna say 'Can I come back?'" ..
        "<br/><br/>You can come back, but it's going to cost you again so be sure you are ready.",
    Choice_1 = {
        Display = true,
        Text = "BACK TO SPAWN",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(85, 85, 255)},
        Action = {
            Type = "LeaveDungeon",
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