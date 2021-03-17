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


----------------------------------------------------------------------------------------------------------------
--// GAME PASSES
----------------------------------------------------------------------------------------------------------------

-- GAME PASSES
local gamePasses = {

    MobileStandStorage = {
        Id = 13434519,
        CreateState = "StandStorageAccess",
        StateValue = true
    },

    DoubleCash = {
        Id = 13434733,
        CreateState = "Multiplier_Cash",
        StateValue = 2
    },

    ArrowLuck = {
        Id = 13434798,
        CreateState = nil
    },

    DoubleOrbs = {
        Id = 13740628,
        CreateState = "Multiplier_Orbs",
        StateValue = 2
    },

    ItemFinder = {
        Id = 13434805,
        CreateState = nil
    },

    DoubleExperience = {
        Id = 13855263,
        CreateState = "Multiplier_Experience",
        StateValue = 2
    }
}

--// Has_GamePass
function GamePassService:Has_GamePass(player, passName)

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
    local passId = gamePasses[passName].Id
    MarketplaceService:PromptGamePassPurchase(player, passId)
end

--// Client.Prompt_GamePassPurchase
function GamePassService.Client:Prompt_GamePassPurchase(player,passName)
    self.Server:Prompt_GamePassPurchase(player,passName)
end

--// Finished_GamePassPurchase
function GamePassService:Finished_GamePassPurchase(player, passId, wasPurchased)
    
    if wasPurchased then

        -- get the pass from the table
        for passName, passTable in pairs(gamePasses) do
            if passTable.Id == passId then
                
                -- set the bool value object in the GamePassService player folder
                local playerFolder = ReplicatedStorage.GamePassService:FindFirstChild(player.UserId)
                local thisObject = playerFolder:FindFirstChild(passName)
                if thisObject then
                    thisObject.Value = true
                end

                -- create state is StateService 
                if passTable.CreateState then
                    Knit.Services.StateService:AddEntryToState(player, passTable.CreateState, "GamePassService", passTable.StateValue)
                end

            end
        end

        -- if pass is ItemFinder then update ItemFinderWindow
        if passId == 13434805 then
            Knit.Services.GuiService:Update_Gui(player, "ItemFinderWindow")
        end
    end

end

----------------------------------------------------------------------------------------------------------------
--// DEVELOPER PRODUCTS
----------------------------------------------------------------------------------------------------------------

-- setup the callback
MarketplaceService.ProcessReceipt = function(receiptInfo)
    return GamePassService:ProcessReceipt(receiptInfo)
end

-- DEV PRODUCTS
local devProducts = require(script.DevProducts)

--// Prompt_ProductPurchase
function GamePassService:Prompt_ProductPurchase(player, productName)
    print(player, productName)
    local productId = devProducts[productName].ProductId
    MarketplaceService:PromptProductPurchase(player, productId)
end

--// Client.Prompt_ProductPurchase
function GamePassService.Client:Prompt_ProductPurchase(player, productName)
    self.Server:Prompt_ProductPurchase(player, productName)
end

--// ProcessReceipt
function GamePassService:ProcessReceipt(receiptInfo)

    print(receiptInfo)

    if receiptInfo then
        -- get the player by their PlayerId
        local player = utils.GetPlayerByUserId(receiptInfo.PlayerId)
        if player then

            -- get the players data
            local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

            -- check if this product has already been granted
            local purchaseExists = false
            for key,value in pairs(playerData.DeveloperProductPurchases) do
                if key == receiptInfo.PurchaseId then
                    purchaseExists = true
                end
            end

            -- process the results
            if purchaseExists then
                print("purchase already existed, NOPERS!")

                -- return to Roblox that we did not give the product
                return Enum.ProductPurchaseDecision.NotProcessedYet
            else
                print(player," bought a dev product with this PurchaseId: ", receiptInfo.PurchaseId)

                -- add this to the layers table so we dont buy it again
                playerData.DeveloperProductPurchases[receiptInfo.PurchaseId] = receiptInfo.CurrencySpent

                -- find the dev product by the productId sent
                for _, productTable in pairs(devProducts) do
                    if productTable.ProductId == receiptInfo.ProductId then

                        if productTable.Params.DataCategory == "Currency" then
                            Knit.Services.InventoryService:Give_Currency(player, productTable.Params.DataKey, productTable.Params.Value, "GamePassService")
                        end

                        if productTable.Params.DataCategory == "Boost" then
                            --AddBoost(player, boostName, duration)
                            Knit.Services.BoostService:AddBoost(player, productTable.Params.DataKey, productTable.Params.Duration, "GamePassService")
                        end

                        print("Match!")
                        print(productTable.ProductId, productTable.Params.DataKey, productTable.Params.Value, productTable.Params.DataCategory)
                    end
                end

                -- return to Roblox we successfully processed this
                return Enum.ProductPurchaseDecision.PurchaseGranted
            end
            
        end

    end

end

----------------------------------------------------------------------------------------------------------------
--// Service Utility
----------------------------------------------------------------------------------------------------------------

--// PlayerAdded
function GamePassService:PlayerAdded(player)

    -- create a folder for the player
    local playerFolder = utils.EasyInstance("Folder",{Name = player.UserId, Parent = ReplicatedStorage.GamePassService})

    -- get gamepasses for player and create states for them
    for passName,passTable in pairs(gamePasses) do

        local passId = passTable.Id
        if MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId) then

            -- create and set valueObject to true
            utils.NewValueObject(passName,true,playerFolder)

            -- create state in StateService 
            if passTable.CreateState then
                print("GAMEPASS SEVRIE SETUP: ", passName,passTable)
                Knit.Services.StateService:AddEntryToState(player, passTable.CreateState, "GamePassService", passTable.StateValue)
            end
        else

            -- create and set valueObject to false
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