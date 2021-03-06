-- ItemSpawnController

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local ItemSpawnController = Knit.CreateController { Name = "ItemSpawnController" }
--local ItemSpawnService = Knit.GetService("ItemSpawnService")
local PlayerUtilityService = Knit.GetService("PlayerUtilityService")
local GamePassService = Knit.GetService("GamePassService")
--local BoostService = Knit.GetService("BoostService")
local utils = require(Knit.Shared.Utils)

-- local variables
local spawnedItemsFolder = Workspace:WaitForChild("SpawnedItems")

--// UpdateItemFinder
function ItemSpawnController:UpdateItemFinder()

    local hasFinder
    if GamePassService:Has_GamePass("ItemFinder") then
        hasFinder = true
    else
        hasFinder = false
    end

    local activeFinderKeys = Knit.Controllers.GuiController.Modules.ItemFinder.ActiveKeys
    local playerMapZone = PlayerUtilityService:GetPlayerMapZone(Players.LocalPlayer)
        
    if activeFinderKeys ~= nil then
        for itemKey, itemBool in pairs(activeFinderKeys) do
            for _, item in pairs(spawnedItemsFolder:GetChildren()) do

                -- if this item.Name and key match, make a new beam and attachments
                if item.Name == itemKey then
                    
                    local itemAttchment = item:FindFirstChild("ItemAttachment")
                    if not itemAttchment then
                        itemAttchment = Instance.new("Attachment")
                        itemAttchment.Name = "ItemAttachment"
                        itemAttchment.Parent = item
                    end

                    -- find or create player attachment
                    local playerAttachment = Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("PlayerAttachment")
                    if not playerAttachment then
                        playerAttachment = Instance.new("Attachment")
                        playerAttachment.Name = "PlayerAttachment"
                        playerAttachment.Parent = Players.LocalPlayer.Character.HumanoidRootPart
                    end

                    -- check if the players zone matches the items zone
                    local inZone = false
                    local itemMapZone = item:GetAttribute("MapZone")
                    if itemMapZone == playerMapZone then
                        inZone = true
                    end

                    -- find the beam
                    local itemBeam = item:FindFirstChild("ItemBeam")
                    if itemBeam then
                        itemBeam.Attachment0 = itemAttchment
                        itemBeam.Attachment1 = playerAttachment

                         -- do the beam if inZone
                        if inZone and hasFinder then
                            itemBeam.Enabled = itemBool
                        else
                            itemBeam.Enabled = false
                        end
                    end

                end
            end
        end
    end
end


--// PlayerAdded
function ItemSpawnController:PlayerAdded(player)

end

--// PlayerRemoved
function ItemSpawnController:PlayerRemoved(player)

end

--// KnitStart
function ItemSpawnController:KnitStart()

    --local spawnedItemsFolder = Workspace:WaitForChild("SpawnedItems")
    spawnedItemsFolder.ChildAdded:Connect(function(child)
        self:UpdateItemFinder()
    end)

    spawnedItemsFolder.ChildRemoved:Connect(function(child)
        self:UpdateItemFinder()
    end)
end

--// KnitInit
function ItemSpawnController:KnitInit()

end

return ItemSpawnController