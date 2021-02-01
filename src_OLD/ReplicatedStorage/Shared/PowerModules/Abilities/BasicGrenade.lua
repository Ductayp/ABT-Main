-- Basic Grenade Ability
-- PDab
-- 11-27-2020

-- this module requires a refernce to an AbilityMod script, it does not work alone

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

-- Ability modules
local ManageStand = require(Knit.Abilities.ManageStand)

-- Effect modules
local Damage = require(Knit.Effects.Damage)

local BasicGrenade = {}


function BasicGrenade.Server_Activate(initPlayer,params)
    print("boopies",params)

    local abilityMod = require(params.BasicGrenade.AbilityMod)

    --- make a new grenade
    local newGrenade = abilityMod.new(initPlayer)

    -- launch it
    abilityMod.Server_Launch(initPlayer, newGrenade)

    -- play the animation
    abilityMod.PlayAnimation(initPlayer)

    -- detonate it
    spawn(function()
        wait(newGrenade.DetonationDelay)

        print("SERVER - boom!")

        -- add all players in range
        for _,player in pairs(Players:GetPlayers()) do
            if player:DistanceFromCharacter(newGrenade.MainPart.Position) <= newGrenade.HitRadius then
                table.insert(newGrenade.HitCharacters, player.Character)
            end
        end

        -- add all Mobs in range
        for _,mob in pairs(Knit.Services.MobService.SpawnedMobs) do
            local distance = (mob.Model.HumanoidRootPart.Position - newGrenade.MainPart.Position).magnitude
            if distance <= newGrenade.HitRadius then
                table.insert(newGrenade.HitCharacters, mob.Model)
            end
        end

        -- run the Server_Explode function
        abilityMod.Server_Explode(initPlayer, newGrenade)
        
        -- hit all the characters
        for _,hitCharacter in pairs(newGrenade.HitCharacters) do

            -- get the most up-to-date hiteffects
            local hitEffects = abilityMod.GetHitEffects(initPlayer, hitCharacter, newGrenade)
 
            -- apply the hit effects
            Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, hitEffects)
        end

        -- cleanup
        newGrenade.MainPart:Destroy()
        newGrenade = nil

    end)

    -- add it to params for the later phases    
    params.Grenade = newGrenade 
        
end

function BasicGrenade.Client_Execute(initPlayer,params)

    print("EXECUTE", params)

    -- launch it
    local abilityMod = require(params.BasicGrenade.AbilityMod)
    abilityMod.Client_Launch(initPlayer, params.Grenade)

    -- get the local palyers ping
    local ping = Knit.Controllers.PlayerUtilityController:GetPing()

    -- wait for detonation
    spawn(function()
        wait(params.Grenade.DetonationDelay - ping)
        print("CLIENT - boom!")
        abilityMod.Client_Explode(initPlayer, params.Grenade)
    
    end)

end

return BasicGrenade


