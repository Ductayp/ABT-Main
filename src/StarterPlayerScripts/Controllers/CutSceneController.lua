-- CutSceneController
-- PDab
-- 1/22/2020

-- services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local CutSceneController = Knit.CreateController { Name = "CutSceneController" }
local CutSceneService = Knit.GetService("CutSceneService")

-- modules
local utils = require(Knit.Shared.Utils)

function CutSceneController:LoadScene(params)

    local findModule = Knit.CutScenes:FindFirstChild(params.SceneName)
    if not findModule then return end

    local functionName = "Client_" .. params.Stage
    require(findModule)[functionName](params)

end


function CutSceneController:KnitStart()
   
end

function CutSceneController:KnitInit()

    CutSceneService.Event_LoadScene:Connect(function(params)
        self:LoadScene(params)
    end)
end

return CutSceneController