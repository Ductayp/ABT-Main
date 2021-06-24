-- StandSteal

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local ManageStand = require(Knit.Abilities.ManageStand)

local ssParticle = ReplicatedStorage.EffectParts.Abilities.RadiusAttack.StandSteal.StandSteal_Particle
local ssDisk = ReplicatedStorage.EffectParts.Abilities.RadiusAttack.StandSteal.Disk
local ssShockWave = ReplicatedStorage.EffectParts.Abilities.RadiusAttack.StandSteal.Shockwave
local ssFatBurst = ReplicatedStorage.EffectParts.Abilities.RadiusAttack.StandSteal.FatBurst
local ssSkinnyBurst = ReplicatedStorage.EffectParts.Abilities.RadiusAttack.StandSteal.SkinnyBurst
local beams = {
    ssBeam_A1 = ReplicatedStorage.EffectParts.Abilities.RadiusAttack.StandSteal.StandSteal_Beam_A1,
    ssBeam_A2 = ReplicatedStorage.EffectParts.Abilities.RadiusAttack.StandSteal.StandSteal_Beam_A2,
    ssBeam_B1 = ReplicatedStorage.EffectParts.Abilities.RadiusAttack.StandSteal.StandSteal_Beam_B1,
    ssBeam_B2 = ReplicatedStorage.EffectParts.Abilities.RadiusAttack.StandSteal.StandSteal_Beam_B2,
}


local StandSteal = {}

StandSteal.HitDelay = 0
StandSteal.Range = 15
StandSteal.TickCount = 7
StandSteal.TickTime = 1
StandSteal.InputBlockTime = 1

--// Server_Start
function StandSteal.Server_Start(params, abilityDefs, initPlayer)

    abilityDefs.HitEffects = {Damage = {Damage = 15, HideEffects = true, KnockBack = 30}}

    for _, character in pairs(params.HitCharacters) do
        Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)
    end

    return params, abilityDefs
end

--// Server_Tick
function StandSteal.Server_Tick(params, abilityDefs, initPlayer)

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
function StandSteal.Server_End(params, abilityDefs, initPlayer)

    abilityDefs.HitEffects = {RemoveStand = {}}
    
    for _, character in pairs(params.HitCharacters) do
        Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)
    end

    return params, abilityDefs
end

--// Client_Start
function StandSteal.Client_Start(params, abilityDefs, initPlayer)

    local targetStand = Workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		targetStand = ManageStand.QuickRender(params)
    end

    -- audio
    spawn(function()
        ManageStand.Aura_On(params)
        ManageStand.PlayAnimation(params, "QuickCast_ArmsUp")
        WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.Rumble_1, {Volume = .5})
        wait(.2)
        WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.StandSpecific.WhiteSnake.StandSteal)
        wait(4)
        ManageStand.Aura_Off(params)
    end)


    local destroyStuff = {}

    local attach0 = utils.EasyInstance("Attachment", {Name = "Attach0", Parent = abilityDefs.TargetStand.HumanoidRootPart})
    table.insert(destroyStuff, attach0)

    local shockWave = ssShockWave:Clone()
    table.insert(destroyStuff, shockWave)
    local newWeld = Instance.new("Weld")
    newWeld.C1 =  CFrame.new(0,0,0)
    newWeld.Part0 = shockWave
    newWeld.Part1 = initPlayer.Character.HumanoidRootPart
    newWeld.Parent = shockWave
    shockWave.Parent = Workspace.RenderedEffects
    shockWave.Size = Vector3.new(StandSteal.Range * 2, .25, StandSteal.Range * 2)

    local shockTweenInfo = TweenInfo.new(1)
    local shockTween = TweenService:Create(shockWave, shockTweenInfo, {Size = Vector3.new(1,.25,1), Transparency = 1})
    shockTween.Completed:Connect(function()
        shockWave:Destroy()
    end)
    shockTween:Play()

    for _, character in pairs(params.HitCharacters) do


        local skinnyBurst = ssSkinnyBurst:Clone()
        skinnyBurst.CFrame = character.HumanoidRootPart.CFrame
        skinnyBurst.Parent = Workspace.RenderedEffects

        local fatBurst = ssFatBurst:Clone()
        fatBurst.CFrame = character.HumanoidRootPart.CFrame
        fatBurst.Parent = Workspace.RenderedEffects

        local fade1 = TweenService:Create(skinnyBurst, TweenInfo.new(1), {Transparency = 1})
        local fade2 = TweenService:Create(fatBurst, TweenInfo.new(1), {Transparency = 1})
        local size1 = TweenService:Create(skinnyBurst, TweenInfo.new(.5), {Size = Vector3.new(2,2,2)})
        local size2 = TweenService:Create(fatBurst, TweenInfo.new(.5), {Size = Vector3.new(1,1,1)})
        fade1.Completed:Connect(function()
            fatBurst:Destroy()
            skinnyBurst:Destroy()
        end)
        spawn(function()
            fade1:Play()
            fade2:Play()
            wait(.3)
            size1:Play()
            size2:Play()
        end)


        local attach1 = utils.EasyInstance("Attachment", {Name = "Attach1", Parent = character.HumanoidRootPart})
        table.insert(destroyStuff, attach1)

        for _, beam in pairs(beams) do
            local newBeam = beam:Clone()
            newBeam.Attachment0 = attach0
            newBeam.Attachment1 = attach1
            newBeam.Parent = character.HumanoidRootPart
            table.insert(destroyStuff, newBeam)
        end

        local newDisk = ssDisk:Clone()
        table.insert(destroyStuff, newDisk)
        
        local newWeld = Instance.new("Weld")
        newWeld.C1 =  CFrame.new(0,2,0)
        newWeld.Part0 = newDisk
        newWeld.Part1 = character.Head
        newWeld.Parent = newDisk

        newDisk.Parent = character.Head

        local spinTweenInfo = TweenInfo.new(
            1, -- Time
            Enum.EasingStyle.Linear, -- EasingStyle
            Enum.EasingDirection.Out, -- EasingDirection
            -1, -- RepeatCount (when less than zero the tween will loop indefinitely)
            false, -- Reverses (tween will reverse once reaching it's goal)
            0 -- DelayTime
        )
        local spinTween = TweenService:Create(newWeld, spinTweenInfo, {C1 = CFrame.new(0,2,0) * CFrame.Angles(0,math.rad(180),0)})
        spinTween:Play()

        spawn(function()
            wait(StandSteal.TickCount * StandSteal.TickTime)
            for i,v in pairs(destroyStuff) do
                v:Destroy()
            end
        end)
    end
end

--// Client_Tick
function StandSteal.Client_Tick(params, abilityDefs, initPlayer)
    for _, character in pairs(params.HitCharacters) do

    end

end

--// Client_End
function StandSteal.Client_End(params, abilityDefs, initPlayer)
    for _, character in pairs(params.HitCharacters) do

    end

end




return StandSteal