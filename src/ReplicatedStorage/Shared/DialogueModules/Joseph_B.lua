-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- nothign here yet
end


module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Joseph",
    Title = "Joseph",
    Body = "Wait! Your next line is, 'How do I get out of here?'" ..
        "<br/><br/>I can send you back for free, but to get back in you will have to pay me again. Oh Yes!",
    Choice_1 = {
        Display = true,
        Text = "LEAVE DUNGEON",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(85, 85, 255), Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "DungeonLeave"
        }
    },
    Choice_2 = {
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.DungeonLeave = {
    IconName = "Icon_Joseph",
    Title = "Joseph",
    Body = "Next you're gonna say 'Why do I have to pay every time?' And then I would say, 'Time Rift nonsense I guess!'" ..
        "<br/><br/>Are you sure you are ready to leave? It will cost more <b>Dungeon Keys</b> to get back.",
        Choice_1 = {
            Display = true,
            Text = "YES",
            CustomProperties = {BackgroundColor3 = Color3.fromRGB(0, 255, 0), Size = UDim2.new(0.4, 0, 0.9, 0)},
            Action = {
                Type = "LeaveDungeon",
            }
        },
        Choice_2 = {
            Display = true,
            Text = "NO",
            CustomProperties = {BackgroundColor3 = Color3.fromRGB(255, 0, 0), Size = UDim2.new(0.4, 0, 0.9, 0)},
            Action = {
                Type = "Close",
            }
        },
        Choice_3 = {
            Display = false,
        },
}


return module