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
PowersService.Client.RenderEffect = RemoteEvent.new()
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
    params = powerModule.Manager(player,params) -- pass the params in and in parmas.CanRun comes back true then we can move on

    -- if it returns CanRun, then fire all clients and set cooldowns
    if params.CanRun then
        self.Client.ExecutePower:FireAll(player,params)
    end

end

--// Client:ActivatePower -- fired by client to activate apower
function PowersService.Client:ClientActivatePower(player,params)
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

    -- get the players current power and run the remove function if it exists
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    local currentPowerModule = Knit.Powers:FindFirstChild(playerData.Character.CurrentPower)
    if currentPowerModule then
        local removePowerModule = require(currentPowerModule)
        local removePowerParams = {} --right now this is nil, but we can add things later if we need to
        if removePowerModule.RemovePower then
            removePowerModule.RemovePower(player,removePowerParams)
        end
    end
    
    

    playerData.Character.CurrentPower = power
    Knit.Services.DataReplicationService:UpdateAll(player)

    -- run the new powers setup function
    local setupPowerModule = require(Knit.Powers[power])
    local setupPowerParams = {} --right now this is nil, but we can add things later if we need to
    if setupPowerModule.SetupPower then
        setupPowerModule.SetupPower(player,setupPowerParams)
    end

    -- run the player setup so we can start fresh
    self:PlayerRefresh(player)
end

--// RegisterHit -- this is currently not in use, instead we send hits directly to their Effect modules
function PowersService:RegisterHit(initPlayer,characterHit,params)
    if params.Damage then
        characterHit.Humanoid:TakeDamage(params.Damage)
    end
end

--// RenderEffectAllPlayers -- this function can be called from anywhere and will render Effects from Knit.Effects on all clients
function PowersService:RenderEffect_AllPlayers(effect,params)
    self.Client.RenderEffect:FireAll(effect,params)
end

--// RenderEffectSinglePlayers -- this function can be called from anywhere and will render Effects from Knit.Effects on all clients
function PowersService:RenderEffect_SinglePlayer(player,effect,params)
    self.Client.RenderEffect:Fire(player,effect,params)
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
                params.InputId = "Q" -- "Q" is always EqupiStand toggle
                params.CanRun = true

                local abilityToggleFolder = ReplicatedStorage.PowerStatus[targetPlayer.UserId]:FindFirstChild("Toggles")
                if not abilityToggleFolder then
                    return
                end
				local standToggle = abilityToggleFolder:FindFirstChild("Q")

				if standToggle then
                    if standToggle.Value == true then
						self.Client.RenderExistingStands:Fire(player,targetPlayer,params)
					end
                end
			end
		end
    end)
end

--// PlayerRefresh - fires when the player joins and after each death
function PowersService:PlayerRefresh(player)
    
    -- cleanup before setup
    self:PlayerCleanup(player)
    
    -- setup player folders
    local playerStandFolder = utils.EasyInstance("Folder",{Name = player.UserId,Parent = workspace.PlayerStands})
    local playerStatusFolder = utils.EasyInstance("Folder",{Name = player.UserId,Parent = ReplicatedStorage.PowerStatus})
    local playerHitboxServerFolder = utils.EasyInstance("Folder",{Name = player.UserId,Parent = workspace.ServerHitboxes})
    local playerHitboxClientFolder = utils.EasyInstance("Folder",{Name = player.UserId,Parent = workspace.ClientHitboxes})

    Knit.Services.DataReplicationService:UpdateAll(player)
end

--// PlayerCleanup -- cleans up after the player, used on PlayerRemoving and also in other functions, such as PlayerRefresh
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

--// PlayerJoined - run once when the player joins the game
function PowersService:PlayerJoined(player)

    -- refresh the player, this sets up all their folders (it happens a second time when we set powers, i guess we just VERY sure it happens!)
    self:PlayerRefresh(player)

    -- make sure the players data is loaded
    local playerDataStatuses = ReplicatedStorage:WaitForChild("PlayerDataLoaded")
    local playerDataBoolean = playerDataStatuses:WaitForChild(player.UserId)
    repeat wait(1) until playerDataBoolean.Value == true -- wait until the value is true, this is set by PlayerDataService when the data is fully loaded for this player

    -- render existing stands
    self:RenderExistingStands(player)

    -- get the players current power
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    local currentPower = playerData.Character.CurrentPower

    -- set the power, this is done when the player joins so they get any modifiers in the power setup
    self:SetPower(player,currentPower)
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
        --self:PlayerRefresh(player)
        
        player.CharacterAdded:Connect(function(character)
            self:PlayerJoined(player)
            

            character:WaitForChild("Humanoid").Died:Connect(function()
                self:PlayerJoined(player)
            end)
        end)
    end)

    -- Player Added event for studio testing
    for _, player in ipairs(Players:GetPlayers()) do
        --self:PlayerCleanup(player)
        --self:PlayerRefresh(player)
        --self:RenderExistingStands(player)

        player.CharacterAdded:Connect(function(character)
            self:PlayerJoined(player)
            

            character:WaitForChild("Humanoid").Died:Connect(function()
                self:PlayerJoined(player)
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