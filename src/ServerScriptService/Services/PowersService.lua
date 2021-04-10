-- Powers Service
-- PDab
-- 11/2/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PowersService = Knit.CreateService { Name = "PowersService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- modules
local utils = require(Knit.Shared.Utils)
local BlockInput = require(Knit.PowerUtils.BlockInput)

-- events
PowersService.Client.ExecutePower = RemoteEvent.new()
PowersService.Client.RenderHitEffect = RemoteEvent.new()
PowersService.Client.RenderAbilityEffect = RemoteEvent.new()

--// ActivatePower -- the server side version of this
function PowersService:ActivatePower(player,params)

    print("PowersService:ActivatePower(player,params)", player, params)

    -- if the player is dialogue locked they cant use powers
    if Knit.Services.GuiService.DialogueLocked[player.UserId] then
        return
    end

    -- check if the players input is block
    if not params.ForceRemoveStand then
        if BlockInput.IsBlocked(player.UserId) then
            if params.KeyState == "InputBegan" then
                return
            end
        end
    end

    -- sanity check
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData.CurrentStand.Power == params.PowerId then
        print("PlayerData doesn't match the PowerID sent")
        return
    end

    -- activate ability
    local powerModule = require(Knit.Powers[params.PowerID])
    params.SystemStage = "Activate"
    params.CanRun = false
    params.InitUserId = player.UserId -- reset this to the player who sent the remote
    params = powerModule.Manager(params) -- pass the params in and in parmas.CanRun comes back true then we can move on

    -- if it returns CanRun, then fire all clients and set cooldowns
    if params.CanRun == true then
        self.Client.ExecutePower:FireAll(params)
    end
end

--// ForceRemoveStand 
function PowersService:ForceRemoveStand(player)

    --print("PowersService:ForceRemoveStand(player)", player)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    local params = {
        CanRun = true,
        InitUserId = player.UserId,
        InputId = "Q",
        KeyState = "InputBegan",
        PowerID = playerData.CurrentStand.Power,
        PowerRarity = playerData.CurrentStand.Rarity,
        SystemStage = "Initialize",
        ForceRemoveStand = true,
    }

    self:ActivatePower(player,params)

end

--// Client:ActivatePower -- fired by client to activate apower
function PowersService.Client:ClientActivatePower(player,params)
    self.Server:ActivatePower(player,params)
end

--// GetCurrentPower
function PowersService:GetCurrentPower(player)
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    local currentPower = playerData.CurrentStand
    return currentPower
end

--// Client:GetCurrentPower
function PowersService.Client:GetCurrentPower(player)
    --local currentPower = self.Server:GetCurrentPower(player)
    return self.Server:GetCurrentPower(player)
end

--// NPC_RegisterHit
function PowersService:NPC_RegisterHit(targetPlayer, hitEffects)

    -- be sure we have a character to act on
    if not targetPlayer then return end
    if not targetPlayer.Character then return end

    -- default hitParams
    local hitParams = {}
    hitParams.DamageMultiplier = 1

    -- run the effects on the player that was hit
    for effect,effectParams in pairs(hitEffects) do
        require(Knit.HitEffects[effect]).Server_ApplyEffect(nil, targetPlayer.Character, effectParams, hitParams)
    end
end


--// RegisterHit
function PowersService:RegisterHit(initPlayer, characterHit, abilityDefs)

    -- print("REGISTER HIT: ", initPlayer, characterHit, abilityDefs)

    -- setup some variables
    local canHit = false
    local hitParams = {} -- additional params we need to pass into the effects

    -- get damage multiplier
    local damageMultiplier = require(Knit.StateModules.Multiplier_Damage).GetTotalMultiplier(initPlayer)
    hitParams.DamageMultiplier = damageMultiplier
    print("HIT: DMG MULT: ", damageMultiplier)
    --[[
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(initPlayer)
    local findPowerModule = Knit.Powers:FindFirstChild(playerData.CurrentStand.Power)
    if findPowerModule then
        hitParams.DamageMultiplier = require(findPowerModule).Defs.DamageMultiplier[playerData.CurrentStand.Rarity]
    end
    ]]--

    -- test if a player or a mob, then set variables
    local isPlayer = utils.GetPlayerFromCharacter(characterHit)
    if isPlayer then

        -- check if initPlayer has PvP off, if so then return
        if Knit.Services.GuiService.PvPToggles[initPlayer.UserId] then
            --print("YES PVP !!!!!!!!!!!!!!!!!!")
        else
            --print("NO PVP !!!!!!!!!!!!!!!!!!")
            return
        end

        -- check if players character is invulnerable
        local isInvulnerable = require(Knit.StateModules.Invulnerable).IsInvulnerable(isPlayer)
        if not isInvulnerable then
            canHit = true
            hitParams.IsMob = false
        end

        -- check if the player is Immune to this ability
        if require(Knit.StateModules.Immunity).Has_Immunity(isPlayer, abilityDefs.Id) then
            print(isPlayer, " is immune to: ", abilityDefs.Id)
            return
        end

    else
        local mobIdObject = characterHit:FindFirstChild("MobId")
        if mobIdObject then
            canHit = true
            hitParams.IsMob = true
            hitParams.MobId = mobIdObject.Value
        end
    end
   
    -- do hitEffects if canHit is true
    if canHit == true then
        for effect,effectParams in pairs(abilityDefs.HitEffects) do
            require(Knit.HitEffects[effect]).Server_ApplyEffect(initPlayer, characterHit, effectParams, hitParams)
        end
    end

end

--// RenderEffectAllPlayers 
function PowersService:RenderHitEffect_AllPlayers(effect,params)
    self.Client.RenderHitEffect:FireAll(effect,params)
end

--// RenderEffectSinglePlayer 
function PowersService:RenderHitEffect_SinglePlayer(player,effect,params)
    self.Client.RenderHitEffect:Fire(player,effect,params)
end

--// RenderAbilityEffect_AllPlayers
function PowersService:RenderAbilityEffect_AllPlayers(abilityModule, functionName, params)
    self.Client.RenderAbilityEffect:FireAll(abilityModule, functionName, params)
end

--// RenderAbilityEffect_SinglePlayers
function PowersService:RenderAbilityEffect_SinglePlayers(abilityModule, functionName, params)
    self.Client.RenderAbilityEffect:Fire(player, abilityModule, functionName, params)
end

--// SetPower -- sets the players current power
function PowersService:SetCurrentPower(player, params)

    --print("PowersService:SetCurrentPower(player,params)", player,params)

    -- get the players current power and run the remove function if it exists
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    local currentPowerModule = Knit.Powers:FindFirstChild(playerData.CurrentStand.Power)
    if currentPowerModule then
        local removePowerModule = require(currentPowerModule)
        local removePowerParams = {} --right now this is nil, but we can add things later if we need to
        if removePowerModule.RemovePower then
            removePowerModule.RemovePower(player,removePowerParams)
        end
    else
        print("no power exists with that name, cant run the REMOVE POWER function")
        --return
    end

    -- run the new powers setup function
    if Knit.Powers:FindFirstChild(params.Power) then
        local setupPowerModule = require(Knit.Powers[params.Power])
        local setupPowerParams = {} 
        setupPowerParams.Rarity = params.Rarity
        if setupPowerModule.SetupPower then
            setupPowerModule.SetupPower(player, setupPowerParams)
        end
    end

    -- give the stand t the playerData
    playerData.CurrentStand = params

    -- update the gui
    Knit.Services.GuiService:Update_Gui(player, "BottomGUI")
    Knit.Services.GuiService:Update_Gui(player, "StoragePanel")

    -- run the player setup so we can start fresh
    self:PlayerRefresh(player)

end

--// PlayerRefresh - fires when the player joins and after each death
function PowersService:PlayerRefresh(player)

    -- wait for the character
    repeat wait() until player.Character

    -- cleanup before setup
    self:PlayerCleanup(player)

    -- setup player folders
    local playerStandFolder = utils.EasyInstance("Folder",{Name = player.UserId,Parent = workspace.PlayerStands})
    local playerStatusFolder = utils.EasyInstance("Folder",{Name = player.UserId,Parent = ReplicatedStorage.PowerStatus})
    local playerHitboxServerFolder = utils.EasyInstance("Folder",{Name = player.UserId,Parent = workspace.ServerHitboxes})
    local playerHitboxClientFolder = utils.EasyInstance("Folder",{Name = player.UserId,Parent = workspace.ClientHitboxes})

end

--// PlayerCleanup -- cleans up after the player, used on PlayerRemoving and also in other functions, such as PlayerRefresh
function PowersService:PlayerCleanup(player)

    -- cleanup folders
    local cleanupLocations = {workspace.PlayerStands,workspace.ServerHitboxes,workspace.ClientHitboxes,ReplicatedStorage.PowerStatus}
    for _,location in pairs(cleanupLocations) do
        for _,object in pairs(location:GetChildren()) do
            if object.Name == tostring(player.UserId) then
                object:Destroy()
            end
        end
    end
end

--// PlayerAdded - run once when the player joins the game
function PowersService:PlayerAdded(player)

    -- make sure the players data is loaded
    local playerDataStatuses = ReplicatedStorage:WaitForChild("PlayerDataLoaded")
    local playerDataBoolean = playerDataStatuses:WaitForChild(player.UserId)
    repeat wait(1) until playerDataBoolean.Value == true -- wait until the value is true, this is set by PlayerDataService when the data is fully loaded for this player

    -- refresh the player, this sets up all their folders (it happens a second time when we set powers, i guess we just VERY sure it happens!)
    self:PlayerRefresh(player)

    -- setup the current powers
    local character = player.Character or player.CharacterAdded:Wait()
    if character then
        local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
        self:SetCurrentPower(player, playerData.CurrentStand)
    end

end

--// CharacterAdded - run once when the player joins the game
function PowersService:CharacterAdded(player)

    -- setup the current powers
    local character = player.Character or player.CharacterAdded:Wait()
    if character then
        local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
        self:SetCurrentPower(player, playerData.CurrentStand)
    end
end


--// KnitStart
function PowersService:KnitStart()

        -- Player Added event
        Players.PlayerAdded:Connect(function(player)
            self:PlayerAdded(player)
    
            player.CharacterAdded:Connect(function(character)
                self:CharacterAdded(player)
        
                character:WaitForChild("Humanoid").Died:Connect(function()
                    -- empty for now
                end)
            end)
        end)

        -- Player Added event for studio tesing, catches when a player has joined before the server fully starts
        for _, player in ipairs(Players:GetPlayers()) do
            self:PlayerAdded(player)
            
            player.CharacterAdded:Connect(function(character)
                self:CharacterAdded(player)
        
                character:WaitForChild("Humanoid").Died:Connect(function()
                    -- empty for now
                end)
            end)
        end
    
end

--// KnitInit - runs at server startup
function PowersService:KnitInit()

    -- make some folders
    local effectFolder = utils.EasyInstance("Folder",{Name = "RenderedEffects",Parent = workspace})
    local effectFolder_2 = utils.EasyInstance("Folder",{Name = "RenderedEffects_BlockAbility",Parent = workspace})
    local standsFolder = utils.EasyInstance("Folder",{Name = "PlayerStands",Parent = workspace})
    local serverHitboxes = utils.EasyInstance("Folder",{Name = "ServerHitboxes",Parent = workspace})
    local clientHitboxes = utils.EasyInstance("Folder",{Name = "ClientHitboxes",Parent = workspace})
    local statusFolder = utils.EasyInstance("Folder", {Name = "PowerStatus",Parent = ReplicatedStorage})

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        self:PlayerCleanup(player)
    end)
    

    local standButtons2 = Workspace:FindFirstChild("StandButtons2", true)
    for i,v in pairs (standButtons2:GetChildren()) do
        if v:IsA("BasePart") then
            local dbValue = utils.EasyInstance("BoolValue",{Name = "Debounce",Parent = v,Value = false})
            v.Touched:Connect(function(hit)

                if dbValue.Value == false then
                    dbValue.Value = true
                    local humanoid = hit.Parent:FindFirstChild("Humanoid")
                    if humanoid then
                        local player = game.Players:GetPlayerFromCharacter(humanoid.Parent)
                        if player then

                            local params = {}
                            params.Power = v.Power.Value
                            params.Rarity = v.Rarity.Value
                            params.Xp = 7800

                            local HttpService = game:GetService("HttpService")
                            params.GUID = HttpService:GenerateGUID(false)

                            print("button goes beep")
                            self:SetCurrentPower(player,params)    
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