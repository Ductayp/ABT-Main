-- Powers Service
-- PDab
-- 11/2/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PowersService = Knit.CreateService { Name = "PowersService", Client = {}}

-- modules

-- properties
local powerStatus = {}

--// Client:ActivatePower -- fired by client to activate apower
function PowersService.Client:ActivatePower(player,params)
    print("PowerService hears you!",player,params)
    params.CanRun = false -- set this back to false, it must pass all the checks to be true at the end before it will run

    -- sanity check
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if playerData.Character.CurrentPower == params.PowerId then
        params.CanRun = true
    else
        print("PlayerData doesn't match the PowerID sent")
        return
    end

    -- cooldown check
    if not powerStatus[player.UserId].Cooldowns[params.AbilityID] then
        powerStatus[player.UserId].Cooldowns[params.AbilityID] = os.time() - 1
    end
    if powerStatus[player.UserId].Cooldowns[params.AbilityID] < os.time() then
        
    end


end

--// SetPower -- sets the players curret power
function PowersService:SetPower(player,power)
    print("SetPower: ",power," - For player: ",player)
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    playerData.Character.CurrentPower = power
    Knit.Services.DataReplicationService:UpdateAll(player)
end

--// PlayerSetup - fires when the player joins and after each death
function PowersService:PlayerSetup(player)
    
    -- Setup the PlayerStand folder - destroys the stand folder along with contents, then recreates it
    local playerStandFolder = workspace.PlayerStands:FindFirstChild(player.UserId)
    if not playerStandFolder then
        playerStandFolder = Instance.new("Folder")
        playerStandFolder.Name = player.UserId
        playerStandFolder.Parent = workspace:FindFirstChild('PlayerStands')
    end

    -- clear the stand completely
    playerStandFolder:ClearAllChildren()

    -- Setup the powerStatus table. clears itself and gets ready for new statuses
    powerStatus[player.UserId] = {}
    powerStatus[player.UserId].Toggles = {}
    powerStatus[player.UserId].Cooldowns = {}

    Knit.Services.DataReplicationService:UpdateAll(player)
end

--// KnitStart
function PowersService:KnitStart()

end

--// KnitInit - runs at server startup
function PowersService:KnitInit()

    -- setup some folder in Workspace
    local effectFolder = Instance.new("Folder")
    effectFolder.Name = "LocalPowersEffects"
    effectFolder.Parent = workspace

    local standFolder = Instance.new("Folder")
    standFolder.Name = "PlayerStands"
    standFolder.Parent = workspace

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        self:PlayerSetup(player)
        player.CharacterAdded:Connect(function()
            self:PlayerSetup(player)
        end)
    end)

    -- Player Added event for studio testing, catches when a player has joined before the server fully starts
    for _, player in ipairs(Players:GetPlayers()) do
        self:PlayerSetup(player)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        powerStatus[player.UserId] = nil
        workspace.PlayerStands:FindFirstChild(player.UserId):Destroy()
    end)

    -- Buttons setup - this is for testing, delete it later
    for i,v in pairs (workspace.StandButtons:GetChildren()) do
        v.Touched:Connect(function(hit)
            local db = false
            if db == false then db = true
                local humanoid = hit.Parent:FindFirstChild("Humanoid")
                if humanoid then
                    local player = game.Players:GetPlayerFromCharacter(humanoid.Parent)
                    if player then
                        self:SetPower(player,v.Name)
                    end
                end
                wait(0.5)
                db = false
            end
        end)
    end

end

return PowersService