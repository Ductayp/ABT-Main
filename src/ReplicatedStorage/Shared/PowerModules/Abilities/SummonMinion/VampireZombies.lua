local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local utils = require(Knit.Shared.Utils)

local targetRange = 50
local zombieLifetime = 10
local detonateRange = 2
local blastRange = 10
local zombieBlastDamage = 20

local VampireZombies = {}

--// RunServer
function VampireZombies.RunServer(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    local targetTable = VampireZombies.AquireTargets(initPlayer)
    for count = 1, 3 do
        local target = targetTable[count][1]
        VampireZombies.SpawnZombie(initPlayer, target, abilityDefs)
    end
    
end

--// RunClient
function VampireZombies.RunClient(params, abilityDefs)


end

--// AcquireTargets
function VampireZombies.AquireTargets(initPlayer)

    local targetTable = {}

    -- put all mobs in targetTable
    for _,mob in pairs(Knit.Services.MobService.SpawnedMobs) do
        if mob.Model:FindFirstChild("Humanoid") then
            if mob.Model.Humanoid.Health > 0 then
                targetTable[#targetTable + 1] = {mob.Model, (mob.Model.HumanoidRootPart.Position -  initPlayer.Character.HumanoidRootPart.Position).Magnitude}
            end
        end
    end

    -- put all players in targetTable
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= initPlayer then
            if not require(Knit.StateModules.Invulnerable).IsInvulnerable(player) then
                if player.Character and player.Character.HumanoidRootPart then
                    targetTable[#targetTable + 1] = {player.Character, (player.Character.HumanoidRootPart.Position -  initPlayer.Character.HumanoidRootPart.Position).Magnitude}
                end
            end
        end
    end

    -- sort table by magnitude value, smallest magnitude gets into position 1
    table.sort(targetTable, function(a, b)
        return a[2] < b[2]
    end)

    return targetTable

end

--// SpawnZombie
function VampireZombies.SpawnZombie(initPlayer, target, abilityDefs)
    --print("ZOMBIE TARGET",target)

    local allZombies = ReplicatedStorage.EffectParts.Abilities.SummonMinion.VampireZombies.ZombieModels:GetChildren()
    local pickZombie = math.random(1, #allZombies)
    local newZombie = allZombies[pickZombie]:Clone()

    newZombie.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    newZombie.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

    newZombie.Parent = Workspace.RenderedEffects
    local studsOffset = 6
    local randX = math.random(-studsOffset * 100, studsOffset * 100)
    local randZ = math.random(-studsOffset * 100, studsOffset * 100) 
    newZombie.HumanoidRootPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(randX / 100, 2, randZ / 100)
    newZombie.HumanoidRootPart.Anchored = false

    newZombie.HumanoidRootPart.Blood:Emit(200)
    newZombie.HumanoidRootPart.Mist:Emit(200)
   
    local animator = Instance.new("Animator")
    animator.Parent = newZombie.Humanoid

    local walkAnimation = Instance.new("Animation")
    walkAnimation.AnimationId = "rbxassetid://616168032"
    local loadedAnimation = animator:LoadAnimation(walkAnimation)
    walkAnimation:Destroy()
    loadedAnimation:Play()

    WeldedSound.NewSound(newZombie.HumanoidRootPart, ReplicatedStorage.Audio.General.ZombieBreatheLabored, {Looped = true, Volume = 3})
    WeldedSound.NewSound(newZombie.HumanoidRootPart, ReplicatedStorage.Audio.General.MagicBoom)

    spawn(function()

        local endTime = os.clock() + zombieLifetime

        while os.clock() < endTime do

            if target then
                if target:FindFirstChild("HumanoidRootPart") then
                    newZombie.Humanoid:MoveTo(target.HumanoidRootPart.Position)
                else
                    VampireZombies.BlastZombie(initPlayer, target, newZombie, abilityDefs)
                    return
                end
            else
                VampireZombies.BlastZombie(initPlayer, target, newZombie, abilityDefs)
                return
            end

            local distance = (newZombie.HumanoidRootPart.Position - target.HumanoidRootPart.Position).magnitude
            if distance <= detonateRange then
                VampireZombies.BlastZombie(initPlayer, target, newZombie, abilityDefs)
                return
            end
            wait()
        end

        VampireZombies.BlastZombie(initPlayer, target, newZombie, abilityDefs)

    end)

    --// BlastZombie
    function VampireZombies.BlastZombie(initPlayer, target, zombie, abilityDefs)

        local hitCharacters = {}
        -- hit all players in range, subject to immunity
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character then
                local distance = (player.Character.HumanoidRootPart.Position - zombie.HumanoidRootPart.Position).magnitude
                if distance <= blastRange then
                    --if player ~= initPlayer then
                        if not require(Knit.StateModules.Invulnerable).IsInvulnerable(player) then
                            table.insert(hitCharacters, player.Character)
                        end
                   -- end
                end
            end
        end
    
        -- hit all Mobs in range
        for _,mob in pairs(Knit.Services.MobService.SpawnedMobs) do
            local distance = (mob.Model.HumanoidRootPart.Position - zombie.HumanoidRootPart.Position).magnitude
            if distance <= blastRange then
                table.insert(hitCharacters, mob.Model)
            end
        end
    
        -- hit all dummies
        for _, dummy in pairs(Workspace.Dummies:GetChildren()) do
            local distance = (dummy.HumanoidRootPart.Position - zombie.HumanoidRootPart.Position).magnitude
            if distance <= blastRange then
                table.insert(hitCharacters, dummy)
            end
        end

        for _, character in pairs(hitCharacters) do

            local newLookVector = (character.HumanoidRootPart.Position - zombie.HumanoidRootPart.Position).unit
            --abilityDefs.HitEffects = {Damage = {Damage = 35, HideEffects = true}, Blast = {}, KnockBack = {Force = 70, ForceY = 50, LookVector = newLookVector}}
            abilityDefs.HitEffects = {Damage = {Damage = zombieBlastDamage}}
            Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)
        end

        local effectParts = {
            ball = ReplicatedStorage.EffectParts.Abilities.SummonMinion.VampireZombies.BlastEffect.Ball:Clone(),
            fatBurst = ReplicatedStorage.EffectParts.Abilities.SummonMinion.VampireZombies.BlastEffect.FatBurst:Clone(),
            skinnyBurst = ReplicatedStorage.EffectParts.Abilities.SummonMinion.VampireZombies.BlastEffect.SkinnyBurst:Clone(),
        }

        for _, part in pairs(effectParts) do
            part.Parent = Workspace.RenderedEffects
            part.Position = zombie.Head.Position
            Debris:AddItem(part, 5)
        end

        -- EFFECT PARTS
        local tweens = {}
        tweens.Ball = {
            Part = effectParts.ball,
            Tweens = {
                Transparency = {
                    Defs = {thisInfo = TweenInfo.new(.5), thisParams = {Transparency = 1}},
                    Delay = 0
                },
                
                Size = {
                    Defs = {thisInfo = TweenInfo.new(.7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), thisParams = {Size = Vector3.new(6, 6, 6)}},
                    Delay = 0
                }
            }
        }

        tweens.FatBurst = {
            Part = effectParts.fatBurst,
            Tweens = {
                Transparency = {
                    Defs = {thisInfo = TweenInfo.new(1.2), thisParams = {Transparency = 1}},
                    Delay = 0
                },
                
                Size = {
                    Defs = {thisInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), thisParams = {Size = Vector3.new(9, 9, 9)}},
                    Delay = 0
                }
            }
        }

        tweens.SkinnyBurst = {
            Part = effectParts.skinnyBurst,
            Tweens = {
                Transparency = {
                    Defs = {thisInfo = TweenInfo.new(.5), thisParams = {Transparency = 1}},
                    Delay = 0
                },
                
                Size = {
                    Defs = {thisInfo = TweenInfo.new(.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), thisParams = {Size = Vector3.new(12, 12, 12)}},
                    Delay = 0
                }
            }
        }

        -- run the Tweens
        for _, table in pairs(tweens) do
            if table.Tweens then
                for _, tweenDef in pairs(table.Tweens) do
                    spawn(function()
                        wait(tweenDef.Delay)
                        local thisTween = TweenService:Create(table.Part,tweenDef.Defs.thisInfo, tweenDef.Defs.thisParams)
                        thisTween:Play()
                        thisTween = nil
                    end)
                    
                end
            end
        end

        WeldedSound.NewSound(zombie.Head, ReplicatedStorage.Audio.General.HeadBurstSound)

        zombie.HumanoidRootPart.Blood.LockedToPart = false
        zombie.HumanoidRootPart.Mist.LockedToPart = false

        zombie.HumanoidRootPart.Blood:Emit(200)
        zombie.HumanoidRootPart.Mist:Emit(200)
        zombie:BreakJoints()

        wait(5)
        zombie:Destroy()

        


    end







end

return VampireZombies