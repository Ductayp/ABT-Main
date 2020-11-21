-- HitBox
-- PDab
-- 11/20/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

local HitBox = {}

--// NewHitBox
function HitBox.NewHitBox(params)

    if params.dimensions then
        -- make the part
    else
        return
    end

    return HitBox
end

return HitBox