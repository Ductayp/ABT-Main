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
PowersService.Client.RenderExistingStands = RemoteEvent.new()

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

-- RegisterHit
function PowersService:RegisterHit(hitParams)
    for i,v in pairs(hitParams) do
        print(i,v)
    end
end

-- RenderExistingStands  -- fired when the player first joins, will render any existing stands in the game
function PowersService:RenderExistingStands(player)

    spawn(function()
		for _,targetPlayer in pairs(Players:GetPlayers()) do
			if player ~= targetPlayer then

				print("player loading in: ",player)
				print("player to check for render:",targetPlayer)
  
                local targetPlayerData = Knit.Services.PlayerDataService:GetPlayerData(targetPlayer)
                local params = {}
                params.PowerID = targetPlayerData.Character.CurrentPower
                params.KeyState = "InputBegan"
                params.Key = "Q" -- "Q" is always EqupiStand toggle

				local abilityToggleFolder = ReplicatedStorage.PowerStatus[targetPlayer.UserId].Toggles
				local standToggle = abilityToggleFolder:FindFirstChild("Q")

				if standToggle then
                    if standToggle.Value == true then
                        print("server-side fire")
						self.Client.RenderExistingStands:Fire(player,targetPlayer,params)
					end
                end
			end
		end
    end)
end

--// PlayerSetup - fires when the player joins and after each death
function PowersService:PlayerSetup(player)

    -- Setup the PlayerStand folder - destroys the stand folder along with contents, then recreates it
    local playerStandFolder = workspace.PlayerStands:FindFirstChild(player.UserId)
    if not playerStandFolder then
        playerStandFolder = utils.EasyInstance("Folder",{Name = player.UserId,Parent = workspace.PlayerStands})
    end
    playerStandFolder:ClearAllChildren() -- clear the stand completely

    -- Setup the PowerStatus folders. clears itself and gets ready for new statuses
    local playerStatusFolder = ReplicatedStorage.PowerStatus:FindFirstChild (player.userId)
    if not playerStatusFolder then
        playerStatusFolder = utils.EasyInstance("Folder",{Name = player.UserId,Parent = ReplicatedStorage.PowerStatus})
    end
    playerStatusFolder:ClearAllChildren()

    -- Setup player Hitbox folder.
    local playerHitboxFolder = workspace.PlayerHitboxes:FindFirstChild(player.UserId)
    if not playerHitboxFolder then
        playerHitboxFolder = utils.EasyInstance("Folder",{Name = player.UserId,Parent = workspace.PlayerHitboxes})
    end
    playerHitboxFolder:ClearAllChildren()

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

    local hitboxFolder = Instance.new("Folder")
    hitboxFolder.Name = "PlayerHitboxes"
    hitboxFolder.Parent = workspace

    -- setup the Power Status folder in ReplciatedStorage
    local statusFolder = Instance.new("Folder")
    statusFolder.Name = "PowerStatus"
    statusFolder.Parent = ReplicatedStorage

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        --self:PlayerSetup(player)
        
        player.CharacterAdded:Connect(function()
            self:PlayerSetup(player)
            self:RenderExistingStands(player)
        end)
    end)

    for _, player in ipairs(Players:GetPlayers()) do -- Player Added event for studio testing
        self:PlayerSetup(player)
        self:RenderExistingStands(player)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        workspace.PlayerStands:FindFirstChild(player.UserId):Destroy()
        ReplicatedStorage.PowerStatus:FindFirstChild(player.UserId):Destroy()
    end)

    
    -- Buttons setup - this is for testing, delete it later
    for i,v in pairs (workspace.StandButtons:GetChildren()) do
        if v:IsA("BasePart") then
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
end

return PowersService