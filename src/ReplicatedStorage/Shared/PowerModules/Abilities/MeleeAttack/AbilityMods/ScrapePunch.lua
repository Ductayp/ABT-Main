-- ScrapePunch

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local ManageStand = require(Knit.Abilities.ManageStand)

local ScrapePunch = {}

-- timing
ScrapePunch.HitDelay = 0.4
ScrapePunch.InputBlockTime = 1
ScrapePunch.TickCount = 0 -- if 0 then there wont be any ticks, just a  regular attack

-- hitbox
ScrapePunch.HitboxSize = Vector3.new(5, 5, 12)
ScrapePunch.HitboxOffset = CFrame.new(0, 0, 6)
ScrapePunch.HitboxDestroyTime = .6

local punchSound = ReplicatedStorage.Audio.Abilities.HeavyPunch

--// HitCharacter
function ScrapePunch.HitCharacter(params, abilityDefs, initPlayer, hitCharacter)

    local blackHolePosition = hitCharacter.HumanoidRootPart.Position
    abilityDefs.HitEffects = {Damage = {Damage = 15}, PinCharacter = {Duration = 5.5}, BlackHole = {Duration = 5}, Invulnerable = {Duration = 5}}
    Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)

    return params
end

--// Client_Start
function ScrapePunch.Client_Start(params, abilityDefs, initPlayer)

    local initCharacter = initPlayer.Character
    if not initCharacter then return end

    local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    --move the stand and do animations
    spawn(function()
        local moveTime = ManageStand.MoveStand(params, "Front")
        ManageStand.PlayAnimation(params, "HeavyPunch")
        ManageStand.Aura_On(params)
        wait(1.5)
        ManageStand.MoveStand(params, "Idle")
        wait(.5)
        ManageStand.Aura_Off(params)
    end)

    wait(ScrapePunch.HitDelay)

    WeldedSound.NewSound(targetStand.HumanoidRootPart, punchSound)

    local scrapeAssembly = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.ScrapePunch.Scrape:Clone()
    local shockRing = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.BasicHeavyPunch.Shock:Clone()
    Debris:AddItem(scrapeAssembly, 3)
    Debris:AddItem(shockRing, 3)

    scrapeAssembly.CFrame = initCharacter.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-8))
    scrapeAssembly.Parent = Workspace.RenderedEffects

    shockRing.CFrame = initCharacter.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-8))
    shockRing.Parent = Workspace.RenderedEffects

    local scrapePosition = TweenService:Create(scrapeAssembly, TweenInfo.new(.5), {CFrame = scrapeAssembly.CFrame:ToWorldSpace(CFrame.new( 0, 0, -5))})
    local scrapeTrans_1 = TweenService:Create(scrapeAssembly.Main, TweenInfo.new(.5), {Transparency = 1})
    local scrapeTrans_2 = TweenService:Create(scrapeAssembly.Left, TweenInfo.new(.5), {Transparency = 1})
    local scrapeTrans_3 = TweenService:Create(scrapeAssembly.Right, TweenInfo.new(.5), {Transparency = 1})

    local shockTransparency = TweenService:Create(shockRing.Shock, TweenInfo.new(1), {Transparency = 1})
    local shockPosition = TweenService:Create(shockRing.Shock, TweenInfo.new(1), {Size = Vector3.new(5, 1.5, 5)})

    scrapeTrans_1:Play()
    scrapeTrans_2:Play()
    scrapeTrans_3:Play()
    scrapePosition:Play()
    shockTransparency:Play()
    shockPosition:Play()

end






return ScrapePunch