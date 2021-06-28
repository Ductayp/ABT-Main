-- HiddenCaesar Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- nothign here yet
end

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Caesar",
    Title = "Caesar",
    Body = "In another life, my enemy became my friend and I gave my all for that friendship. " ..
    "<br/><br/>If I had another life, I would spend it destroying the Stone Mask and the Pillar Men once and for all.",
    Choice_1 = {
        Display = true,
        Text = "Good luck with that!",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
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