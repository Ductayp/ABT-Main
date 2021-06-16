-- BlackHole

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local ManageStand = require(Knit.Abilities.ManageStand)


local module = {}

module.HitDelay = 0
module.Range = 15
module.TickCount = 7
module.TickTime = 1
module.InputBlockTime = 1

--// Server_Start
function module.Server_Start(params, abilityDefs, initPlayer)

    abilityDefs.HitEffects = {Damage = {Damage = 15, HideEffects = true, KnockBack = 30}}

    for _, character in pairs(params.HitCharacters) do
        Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)
    end

    return params, abilityDefs
end

--// Server_Tick
function module.Server_Tick(params, abilityDefs, initPlayer)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(initPlayer)
    if not playerData then return end

    local multiplier
    local rank = playerData.CurrentStand.Rank
    if rank == 3 then
        multiplier = 1
    elseif rank == 2 then
        multiplier = 1.5
    else
        multiplier = 2
    end

    local baseHeal = 3
    local thisHeal = baseHeal * multiplier

    abilityDefs.HitEffects = {Damage = {Damage = 2}}

    for _, character in pairs(params.HitCharacters) do

        Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)
        
        local currentHealth = initPlayer.Character.Humanoid.Health
        local maxHealth = initPlayer.Character.Humanoid.MaxHealth
    
        if currentHealth < maxHealth then
            local difference = maxHealth - currentHealth
            if difference < thisHeal then
                initPlayer.Character.Humanoid.Health = maxHealth
            else
                initPlayer.Character.Humanoid.Health = initPlayer.Character.Humanoid.Health + thisHeal
            end
        end
    end

    return params, abilityDefs
end

--// Server_End
function module.Server_End(params, abilityDefs, initPlayer)

    abilityDefs.HitEffects = {RemoveStand = {}}
    
    for _, character in pairs(params.HitCharacters) do
        Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)
    end

    return params, abilityDefs
end

--// Client_Start
function module.Client_Start(params, abilityDefs, initPlayer)

end






return module