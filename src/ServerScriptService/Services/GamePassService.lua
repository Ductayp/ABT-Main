-- Game Pass Service
-- PDab
-- 12/27/2020

-- services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")


-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GamePassService = Knit.CreateService { Name = "GamePassService", Client = {}}

-- modules
local utils = require(Knit.Shared.Utils)

-- GAME PASSES
local gamePasses = {
    MobileStandStorage = 13434519,
    DoubleCash = 13434733,
    DoubleArrowLuck = 13434798,
    ItemFinder = 13434805
}

--// Has_GamePass
function GamePassService:Has_GamePass(player,passName)

    local hasPass = false

    local playerFolder = ReplicatedStorage.GamePassService:FindFirstChild(player.UserId)
    if playerFolder then

        local gamePassObject = playerFolder:FindFirstChild(passName)
        if gamePassObject then
            if gamePassObject.Value == true then
                hasPass = true
            end
        end
    end

    return hasPass
end

--// Client.Has_Pass
function GamePassService.Client:Has_GamePass(player,passName)
    return self.Server:Has_GamePass(player,passName)
end

--// Prompt_GamePassPurchase
function GamePassService:Prompt_GamePassPurchase(player,passName)
    local passId = gamePasses[passName]
    MarketplaceService:PromptGamePassPurchase(player, passId)
end

--// Client.Prompt_GamePassPurchase
function GamePassService.Client:Prompt_GamePassPurchase(player,passName)
    self.Server:Prompt_GamePassPurchase(player,passName)
end

--// Finished_GamePassPurchase
function GamePassService:Finished_GamePassPurchase(player, passId, wasPurchased)
    
    local playerFolder = ReplicatedStorage.GamePassService:FindFirstChild(player.UserId)

    if wasPurchased then
        for key,value in pairs(gamePasses) do
            if value == passId then
                local thisObject = playerFolder:FindFirstChild(key)
                if thisObject then
                    thisObject.Value = true
                end
            end
        end
    end
end

--// PlayerAdded
function GamePassService:PlayerAdded(player)

    -- create a folder for the player
    local playerFolder = utils.EasyInstance("Folder",{Name = player.UserId, Parent = ReplicatedStorage.GamePassService})

    -- get gamepasses for player and create states for them
    for passName,passId in pairs(gamePasses) do
        if MarketplaceService:UserOwnsGamePassAsync(player.UserId,passId) then
            --utils.NewValueObject(player, "GamePass", passName, true)
            utils.NewValueObject(passName,true,playerFolder)
        else
            utils.NewValueObject(passName,false,playerFolder)
        end
    end
end

--// PlayerRemoved
function GamePassService:PlayerRemoved(player)
    ReplicatedStorage.GamePassService:FindFirstChild(player.UserId):Destroy()
end

--// KnitStart
function GamePassService:KnitStart()

end

--// KnitInit
function GamePassService:KnitInit()

     -- create a folder to hold all the valueObjects
     local mainFolder = utils.EasyInstance("Folder",{Name = "GamePassService", Parent = ReplicatedStorage})

     -- setup PromptGamePassPurchaseFinished
     MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
        self:Finished_GamePassPurchase(player, passId, wasPurchased)
     end)

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)
    end)

    -- Player Added event for studio tesing, catches when a player has joined before the server fully starts
    for _, player in ipairs(Players:GetPlayers()) do
        self:PlayerAdded(player)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        self:PlayerRemoved(player)
    end)

end

return GamePassService