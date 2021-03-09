-- ItemSpawnController

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local ItemSpawnController = Knit.CreateController { Name = "ItemSpawnController" }
local ItemSpawnService = Knit.GetService("ItemSpawnService")
local GamePassService = Knit.GetService("GamePassService")
local BoostService = Knit.GetService("BoostService")
local utils = require(Knit.Shared.Utils)

print("Knit", Knit)

-- local variables
local spawnedItemsFolder = Workspace:WaitForChild("SpawnedItems")

--// UpdateItemFinder
function ItemSpawnController:UpdateItemFinder()

    --[[
    -- check if player has access to finder
    local hasAccess = false

    if GamePassService:Has_GamePass("ItemFinder") or BoostService:Has_Boost("ItemFinder") then
        hasAccess = true
    end

    if not hasAccess then
        return
    end
    ]]--

    if not GamePassService:Has_GamePass("ItemFinder") or BoostService:Has_Boost("ItemFinder") then
       return
    end
        

    if Knit.Controllers.GuiController.ItemFinderWindow.ActiveKeys ~= nil then
        for itemKey, itemBool in pairs(Knit.Controllers.GuiController.ItemFinderWindow.ActiveKeys) do
            for _, item in pairs(spawnedItemsFolder:GetChildren()) do

                -- if this item.Name and key match, make a new beam and attachments
                if item.Name == itemKey then
                    
                    -- find or create item attachment
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

                    -- find
                    local itemBeam = item:FindFirstChild("ItemBeam")
                    if itemBeam then
                        itemBeam.Attachment0 = itemAttchment
                        itemBeam.Attachment1 = playerAttachment
                        itemBeam.Enabled = itemBool
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