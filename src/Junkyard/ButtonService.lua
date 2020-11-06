-- Button Service - temporary maybe delete after testing lol
-- PDab
-- 11/2/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local ButtonsService = Knit.CreateService { Name = "ButtonsService", Client = {}}

function ButtonsService:SendPower(player,power)
    local PowersService = Knit.GetService("PowersService")
    PowersService:SetPower(player,v.Name)
end

function ButtonsService:KnitInit()
    for i,v in pairs (workspace.StandButtons:GetChildren()) do
        v.Touched:Connect(function(player)
            local PowersService = Knit.GetService("PowersService")
            PowersService:SetPower(player,v.Name)
        end)
    end
end

return ButtonsService