-- Powers Service
-- PDab
-- 11/2/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PowersService = Knit.CreateService { Name = "PowersService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- modules
local utils = require(Knit.Shared.Utils)

-- events
PowersService.Client.ExecutePower = RemoteEvent.new()

--// ActivatePower -- the server side version of this
function PowersService:ActivatePower(player,params)
    
    -- sanity check
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData.Character.CurrentPower == params.PowerId then
        print("PlayerData doesn't match the PowerID sent")
        return
    end

    -- activate ability
    local powerModule = require(Knit.Powers[params.PowerID])
    params.SystemStage = "Activate"
    params.CanRun = false
    params = powerModule.Manager(player,params)

    -- if it returns CanRun, then fire all clients and set cooldowns
    if params.CanRun then
        self.Client.ExecutePower:FireAll(player,params)
    end

end

--// Client:ActivatePower -- fired by client to activate apower
function PowersService.Client:ClientActivatePower(player,params)
    self.Server:ActivatePower(player,params)

    --[[
    -- sanity check
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData.Character.CurrentPower == params.PowerId then
        print("PlayerData doesn't match the PowerID sent")
        return
    end

    -- activate ability
    local powerModule = require(Knit.Powers[params.PowerID])
    params.SystemStage = "Activate"
    params.CanRun = false
    params = powerModule.Manager(player,params)

    -- if it returns CanRun, then fire all clients and set cooldowns
    if params.CanRun then
        self.ExecutePower:FireAll(player,params)
    end
]]--

end

--// SetPower -- sets the players curret power
function PowersService:SetPower(player,power)
    print("SetPower: ",power," - For player: ",player)
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    playerData.Character.CurrentPower = power
    Knit.Services.DataReplicationService:UpdateAll(player)

    -- clear stand folder
    local playerStandFolder = workspace.PlayerStands:FindFirstChild(player.UserId)
    if playerStandFolder then
        playerStandFolder:ClearAllChildren()
    end

    -- clear power status folder
    local playerStatusFolder = ReplicatedStorage.PowerStatus:FindFirstChild (player.userId)
    if playerStatusFolder then
        playerStatusFolder:ClearAllChildren()
    end

end

--// PlayerSetup - fires when the player joins and after each death
function PowersService:PlayerSetup(player)

    -- Setup the PlayerStand folder - destroys the stand folder along with contents, then recreates it
    local playerStandFolder = workspace.PlayerStands:FindFirstChild(player.UserId)
    if not playerStandFolder then
        playerStandFolder = Instance.new("Folder")
        playerStandFolder.Name = player.UserId
        playerStandFolder.Parent = workspace.PlayerStands
    end
    
    playerStandFolder:ClearAllChildren() -- clear the stand completely

    -- Setup the PowerStatus folders. clears itself and gets ready for new statuses
    local playerStatusFolder = ReplicatedStorage.PowerStatus:FindFirstChild (player.userId)
    if not playerStatusFolder then
        playerStatusFolder = Instance.new("Folder")
        playerStatusFolder.Name = player.UserId
        playerStatusFolder.Parent = ReplicatedStorage.PowerStatus
    end

    playerStatusFolder:ClearAllChildren()

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

    -- setup the Power Status folder in ReplciatedStorage
    local statusFolder = Instance.new("Folder")
    statusFolder.Name = "PowerStatus"
    statusFolder.Parent = ReplicatedStorage

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        self:PlayerSetup(player)
        player.CharacterAdded:Connect(function()
            self:PlayerSetup(player)
        end)
    end)

    for _, player in ipairs(Players:GetPlayers()) do -- Player Added event for studio testing
        self:PlayerSetup(player)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        workspace.PlayerStands:FindFirstChild(player.UserId):Destroy()
        ReplicatedStorage.PowerStatus:FindFirstChild(player.UserId):Destroy()
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