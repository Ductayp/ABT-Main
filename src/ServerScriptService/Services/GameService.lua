-- AdminService
-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GameService = Knit.CreateService { Name = "GameService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)
local utils = require(Knit.Shared.Utils)

local testerRoles = {"Owner", "Admin", "Mod", "Tester"}

function GameService:SetupGame()

    local gameId = game.GameId
    local placeId = game.PlaceId
 

    local testBoolValue = Instance.new("BoolValue")
    testBoolValue.Name = "TestServer"
   
    local isSuccessful, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, placeId)
    if isSuccessful then
        if info.Name:find("TEST SERVER") then
            print("THIS IS A TEST SERVER")
            testBoolValue.Value = true
        else
            testBoolValue.Value = false
        end
    else
        testBoolValue.Value = false
    end

    testBoolValue.Parent = ReplicatedStorage

end

--// PlayerAdded
function GameService:PlayerAdded(player)

    local playerDataStatuses = ReplicatedStorage:WaitForChild("PlayerDataLoaded")
    local playerDataBoolean = playerDataStatuses:WaitForChild(player.UserId)
    repeat wait(1) until playerDataBoolean.Value == true -- wait until the value is true

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)


    local playerRole = player:GetRoleInGroup(3486129)
    local isTester
    if table.find(testerRoles, playerRole) then
        isTester = true
    else
        isTester = false
    end

    if player.UserId == -1 or player.UserId == -2 then
        isTester = true
    end

    local newTesterBool = Instance.new("BoolValue")
    newTesterBool.Name = player.UserId
    newTesterBool.Value = isTester
    newTesterBool.Parent = ReplicatedStorage.TestServer

    if ReplicatedStorage.TestServer.Value == true and isTester == false then
        wait(60)
        player:Kick()
    end

    repeat wait() until player.Character

    self:CharacterAdded(player)
    player.CharacterAdded:Connect(function(character)
        self:CharacterAdded(player)
    end)

end

--// PlayerRemoved
function GameService:PlayerRemoved(player)
    local playerTesterEntry = ReplicatedStorage.TestServer:FindFirstChild(player.UserId)
    if playerTesterEntry then
        playerTesterEntry:Destroy()
    end
end

--// CharacterAdded
function GameService:CharacterAdded(player)

end


--// KnitStart
function GameService:KnitStart()

    self:SetupGame()

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

--// KnitInit
function GameService:KnitInit()



end


return GameService