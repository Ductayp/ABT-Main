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
    print("boop")
    self.Server:ActivatePower(player,params)
end

--// Client:GetCuurentPower
function PowersService.Client:GetCurrentPower(player)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    local currentPower = playerData.Character.CurrentPower

    return currentPower
end

--// SetPower -- sets the players curret power
function PowersService:SetPower(player,power)
    print("SetPower: ",power," - For player: ",player)
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    playerData.Character.CurrentPower = power
    Knit.Services.DataReplicationService:UpdateAll(player)

    -- run the player setup so we can start fresh
    self:PlayerSetup(player)
end

--// RegisterHit
function PowersService:RegisterHit(initPlayer,characterHit,params)

    -- get the damage
    local powerModule = require(Knit.Powers[params.PowerId])
    local damage = powerModule.Defs.Abilities[params.AbilityId].Damage

    characterHit.Humanoid:TakeDamage(damage)

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
    
    -- cleanup before setup
    self:PlayerCleanup(player)
    
    -- setup player folders
    local playerStandFolder = utils.EasyInstance("Folder",{Name = player.UserId,Parent = workspace.PlayerStands})
    local playerStatusFolder = utils.EasyInstance("Folder",{Name = player.UserId,Parent = ReplicatedStorage.PowerStatus})
    local playerHitboxServerFolder = utils.EasyInstance("Folder",{Name = player.UserId,Parent = workspace.ServerHitboxes})
    local playerHitboxClientFolder = utils.EasyInstance("Folder",{Name = player.UserId,Parent = workspace.ClientHitboxes})

    Knit.Services.DataReplicationService:UpdateAll(player)
end

function PowersService:PlayerCleanup(player)
    local cleanupLocations = {workspace.PlayerStands,workspace.ServerHitboxes,workspace.ClientHitboxes,ReplicatedStorage.PowerStatus}

    for _,location in pairs(cleanupLocations) do
        for _,object in pairs(location:GetChildren()) do
            if object.Name == tostring(player.UserId) then
                object:Destroy()
            end
        end
    end
end

--// KnitStart
function PowersService:KnitStart()
    
end

--// KnitInit - runs at server startup
function PowersService:KnitInit()

    -- make some folders
    local effectFolder = utils.EasyInstance("Folder",{Name = "RenderedEffects",Parent = workspace})
    local standsFolder = utils.EasyInstance("Folder",{Name = "PlayerStands",Parent = workspace})
    local serverHitboxes = utils.EasyInstance("Folder",{Name = "ServerHitboxes",Parent = workspace})
    local clientHitboxes = utils.EasyInstance("Folder",{Name = "ClientHitboxes",Parent = workspace})
    local statusFolder = utils.EasyInstance("Folder", {Name = "PowerStatus",Parent = ReplicatedStorage})

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        --self:PlayerSetup(player)
        
        player.CharacterAdded:Connect(function(character)
            self:PlayerSetup(player)
            self:RenderExistingStands(player)

            character:WaitForChild("Humanoid").Died:Connect(function()
                self:PlayerSetup(player)
            end)
        end)
    end)

    -- Player Added event for studio testing
    for _, player in ipairs(Players:GetPlayers()) do
        --self:PlayerCleanup(player)
        --self:PlayerSetup(player)
        --self:RenderExistingStands(player)

        player.CharacterAdded:Connect(function(character)
            self:PlayerSetup(player)
            self:RenderExistingStands(player)

            character:WaitForChild("Humanoid").Died:Connect(function()
                self:PlayerSetup(player)
            end)
        end)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        PowersService:PlayerCleanup(player)
    end)

    
    -- Buttons setup - this is for testing, delete it later
    for i,v in pairs (workspace.StandButtons:GetChildren()) do
        if v:IsA("BasePart") then
            local dbValue = utils.EasyInstance("BoolValue",{Name = "Debounce",Parent = v,Value = false})
            v.Touched:Connect(function(hit)

                if dbValue.Value == false then
                    dbValue.Value = true
                    local humanoid = hit.Parent:FindFirstChild("Humanoid")
                    if humanoid then
                        local player = game.Players:GetPlayerFromCharacter(humanoid.Parent)
                        if player then
                            self:SetPower(player,v.Name)
                        end
                    end
                    wait(5)
                    dbValue.Value = false
                end
            end)
        end
    end
end

return PowersService