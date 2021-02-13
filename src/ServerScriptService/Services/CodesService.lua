-- CodesService
-- PDab
-- 2/12/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local CodesService = Knit.CreateService { Name = "CodesService", Client = {}}

-- modules
local utils = require(Knit.Shared.Utils)

--// RedeemCode
function CodesService:RedeemCode(player, code)

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    -- defaut message
    local returnMessage = "CODE ERROR"

    -- run the code tests
    local codeDef = {}
    local codeExists = false
    local codeExpired
    local codeRedeemed = false
    for _,module in pairs(Knit.ServerModules.Codes:GetDescendants()) do
        if module:IsA("ModuleScript") then
            local thisModule = require(module)
            for defTable, defEntry in pairs(thisModule) do
                if defEntry.CodeString == code then
    
                    codeExists = true
                    if defEntry.Expiration > os.time() then
    
                        codeExpired = false
    
                        -- check if it was redeemed
                        for _,redeemedCode in pairs(playerData.RedeemedCodes) do
                            if code == redeemedCode then
                                codeRedeemed = true
                                break
                            end
                        end
    
                        -- if it wasnt redeemed, then set codeDef = defTable
                        if codeRedeemed == false then
                            codeDef = defEntry
                            table.insert(playerData.RedeemedCodes, code)
                        end
    
                    else
                        codeExpired = true
                        break
                    end
                end
            end
        end
    end

    if codeExists == false then
        returnMessage = "CODE DOES NOT EXIST: " .. code
        return returnMessage
    end

    if codeExpired then
        returnMessage = "CODE EXPIRED: " .. code
        return returnMessage
    end

    if codeRedeemed then
        returnMessage = "CODE ALREADY REDEEMED: " .. code
        return returnMessage
    end

    if codeExists then

        if codeDef.ActionType == "GiveCurrency" then
            Knit.Services.InventoryService:Give_Currency(player, codeDef.Key, codeDef.Value, "Code")
        end

        returnMessage = codeDef.Message
        return returnMessage
    end

    return returnMessage
end

--// Client:RedeemCode
function CodesService.Client:RedeemCode(player, code)
    local returnMessage = self.Server:RedeemCode(player, code)
    print("SERVER RETURN: ", returnMessage)
    return returnMessage
end


--// PlayerAdded
function CodesService:PlayerAdded(player)

end

--// PlayerRemoved
function CodesService:PlayerRemoved(player)

end
   
--// KnitStart
function CodesService:KnitStart()
    --print("CodesService", self)
end

--// KnitInit
function CodesService:KnitInit()

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


return CodesService