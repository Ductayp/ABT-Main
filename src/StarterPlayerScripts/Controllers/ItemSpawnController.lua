-- ItemSpawnController

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local ItemSpawnController = Knit.CreateController { Name = "ItemSpawnController" }
local ItemSpawnService = Knit.GetService("ItemSpawnService")
local utils = require(Knit.Shared.Utils)

-- local variables
local spawnedItemsFolder = Workspace:WaitForChild("SpawnedItems")

--// UpdateItemFinder
function ItemSpawnController:UpdateItemFinder()

    -- check if player has ItemFinder State
    if not require(Knit.StateModules.ItemFinderAccess).HasAccess(Players.LocalPlayer) then
        return
    end

    print("this player can find items: ", Players.LocalPlayer)


    if Knit.Controllers.GuiController.ItemFinderWindow.ActiveKeys ~= nil then
        for key,_ in pairs(Knit.Controllers.GuiController.ItemFinderWindow.ActiveKeys) do
            for _, item in pairs(spawnedItemsFolder:GetChildren()) do

                -- destroy old beams
                local itemBeam = item:FindFirstChild("ItemBeam")
                if itemBeam then
                    itemBeam:Destroy()
                end

                if item:GetAttribute("Destroyed") then
                    itemBeam:Destroy()
                end

                -- if this item.Name and key match, make a new beam and attachments
                if item.Name == key then
                    
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

                    -- find or create beam
                    local itemBeam = item:FindFirstChild("ItemBeam")
                    if not itemBeam then
                        itemBeam = ReplicatedStorage.EffectParts.ItemFinder.ItemBeam:Clone()
                        itemBeam.Parent = item
                        itemBeam.Attachment0 = playerAttachment
                        itemBeam.Attachment1 = itemAttchment
                        itemBeam.Enabled = true
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