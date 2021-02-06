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

-- constants
PowersService.XP_PER_LEVEL = {
    Common = 3600,
    Rare = 10800,
    Legendary = 32400
}

-- events
PowersService.Client.ExecutePower = RemoteEvent.new()
PowersService.Client.RenderEffect = RemoteEvent.new()

--// ActivatePower -- the server side version of this
function PowersService:ActivatePower(player,params)

    -- check if the players input is block
    if BlockInput.IsBlocked(player.UserId) then
        if params.KeyState == "InputBegan" then
            return
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

--// Client:ActivatePower -- fired by client to activate apower
function PowersService.Client:ClientActivatePower(player,params)
    self.Server:ActivatePower(player,params)
end

--// Client:GetCurrentPower
function PowersService.Client:GetCurrentPower(player)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    local currentPower = playerData.CurrentStand

    return currentPower
end

--// GetLevelFromXp
function PowersService:GetLevelFromXp(standXp, standRarity)

	if standXp == nil then
		standXp = 1
	end

    local xpPerLevel = PowersService.XP_PER_LEVEL[standRarity]

    local rawLevel = math.floor(standXp / xpPerLevel)
    local adjustedLevel = rawLevel + 1

    local completedXp = adjustedLevel * xpPerLevel
    local adjustedXp = standXp + xpPerLevel

    local remainingXpToLevel = xpPerLevel - (adjustedXp - completedXp)
    local percentageComplete = 1 - (remainingXpToLevel / xpPerLevel)
    percentageComplete *= 100
    percentageComplete = math.floor(percentageComplete)
    percentageComplete = percentageComplete / 100

    if percentageComplete <= 0 then
        percentageComplete = 0.01
    elseif percentageComplete >= 1 then
        percentageComplete = 1
    end
 
    return adjustedLevel, percentageComplete, remainingXpToLevel
end

--// GetXpData
function PowersService:GetXpData(standXp, standRarity)

    -- be sure we start with at least 1 xp
    if standXp == nil then
		standXp = 1
    end

    -- if stand rarity is nil, its was probably a request that had standless
    if standRarity == nil then
        return
    end
    
    local xpPerLevel = PowersService.XP_PER_LEVEL[standRarity]

    local rawLevel = math.floor(standXp / xpPerLevel)
    local adjustedLevel = rawLevel + 1

    local completedXp = adjustedLevel * xpPerLevel
    local adjustedXp = standXp + xpPerLevel

    local remainingXpToLevel = xpPerLevel - (adjustedXp - completedXp)
    local percentageComplete = 1 - (remainingXpToLevel / xpPerLevel)
    percentageComplete *= 100
    percentageComplete = math.floor(percentageComplete)
    percentageComplete = percentageComplete / 100

    if percentageComplete <= 0 then
        percentageComplete = 0.01
    elseif percentageComplete >= 1 then
        percentageComplete = 1
    end

    -- build the data dictionary
    local data = {
        XpPerLevel = xpPerLevel, -- the static number of XP required for each level, depends on stand rarity
        Level = adjustedLevel, -- the level of the stand
        PercentageComplete = percentageComplete, -- a percetage of the xp completed for THIS LEVEL, used in Gui stuff
        XpThisLevel = xpPerLevel - remainingXpToLevel -- a number the represents how much xp has been gain THIS LEVEL
    }

    return data

end

--// Client:GetXPData
function PowersService.Client:GetXpData(standXp, standRarity)
    local data = self:GetXpData(standXp, standRarity)
    return data
end

--// Client:GetLevelFromXp
function PowersService.Client:GetLevelFromXp(player, standXp, standRarity) -- player arg is not used but gets passed in by Knit. we just ignore it
    local actualLevel, percentageRemaining, remainingXpToLevel = self.Server:GetLevelFromXp(standXp, standRarity)
    return actualLevel, percentageRemaining, remainingXpToLevel
end


--// AwardXpForKill
function PowersService:AwardXp(player, xpValue)

    -- check if player has any bonuses
    local multiplier = require(Knit.StateModules.Multiplier_Experience).GetTotalMultiplier(player)
    print("XP Multiplier is: ", multiplier)

    -- multiply the value
    xpValue = xpValue * multiplier

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    -- check if player is standless, if they are return out of here
    if playerData.CurrentStand.Power == "Standless" then

        local notificationParams = {}
        notificationParams.Icon = "XP"
        notificationParams.Text = "You are STANDLESS:  ZERO XP gained"
        Knit.Services.GuiService:Update_Notifications(player, notificationParams)
        return
    end

    playerData.CurrentStand.Xp += xpValue

    Knit.Services.GuiService:Update_Gui(player, "BottomGUI")
    Knit.Services.GuiService:Update_Gui(player, "StoragePanel")

    local notificationParams = {}
    notificationParams.Icon = "XP"
    notificationParams.Text = "You got: " .. tostring(xpValue) .. " XP Points"
    Knit.Services.GuiService:Update_Notifications(player, notificationParams)
    return

end

--// NPC_RegisterHit
function PowersService:NPC_RegisterHit(targetPlayer, hitEffects)
    print("YOU GOT HIT HOMES!")
    local hitParams = {}
    hitParams.DamageMultiplier = 1
    for effect,effectParams in pairs(hitEffects) do
        require(Knit.HitEffects[effect]).Server_ApplyEffect(nil, targetPlayer.Character, effectParams, hitParams)
    end
end


--// RegisterHit
function PowersService:RegisterHit(initPlayer, characterHit, abilityDefs)

    -- setup some variables
    local canHit = false
    local hitParams = {} -- additional params we need to pass into the effects

    -- get damage multiplier
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(initPlayer)
    local findPowerModule = Knit.Powers:FindFirstChild(playerData.CurrentStand.Power)
    if findPowerModule then
        hitParams.DamageMultiplier = require(findPowerModule).Defs.DamageMultiplier[playerData.CurrentStand.Rarity]
    end

    -- test if a player or a mob, then set variables
    local isPlayer = utils.GetPlayerFromCharacter(characterHit)
    if isPlayer then

        -- check if players character is invulnerable
        local isInvulnerable = require(Knit.StateModules.Invulnerable).IsInvulnerable(isPlayer)
        if not isInvulnerable then
            canHit = true
            hitParams.IsMob = false
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

--// RenderEffectAllPlayers -- this function can be called from anywhere and will render Effects from Knit.Effects on all clients
function PowersService:RenderEffect_AllPlayers(effect,params)
    self.Client.RenderEffect:FireAll(effect,params)
end

--// RenderEffectSinglePlayer -- this function can be called from anywhere and will render Effects from Knit.Effects on all clients
function PowersService:RenderEffect_SinglePlayer(player,effect,params)
    self.Client.RenderEffect:Fire(player,effect,params)
end

--// SetPower -- sets the players current power
function PowersService:SetCurrentPower(player,params)

    print("PowersService:SetCurrentPower(player,params)", player,params)

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