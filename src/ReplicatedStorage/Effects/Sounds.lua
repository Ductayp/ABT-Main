-- Sound Effect Script

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- knite and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

local Sounds = {}

function Sounds.WeldSound(target,sound,params,soundProperties)

    -- get the target
    -- find a speaker part, if not exists create it, name it the same as sound
    -- weld speaker part to target
    -- clone sound
    -- parent sound to speaker part
    -- set properties for sound
    -- set debris for speaker
    -- set if it loops or plays once
    -- destroy 
    -- play sound

end

return Sounds