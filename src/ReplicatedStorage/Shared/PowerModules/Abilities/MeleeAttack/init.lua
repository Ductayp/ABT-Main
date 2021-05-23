-- MeleeAttack

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local BlockInput = require(Knit.PowerUtils.BlockInput)
--local MobilityLock = require(Knit.PowerUtils.MobilityLock)

local MeleeAttack = {}

--// Initialize --------------------------------------------------------------------------------------------------------
function MeleeAttack.Initialize(params, abilityDefs)

    params.CanRun = false

    -- checks
	if params.KeyState == "InputEnded" then return end
	if not Cooldown.Client_IsCooled(params) then return end
    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then return end

    params.CanRun = true

    -- run abilityMod setup
    local abilityMod = require(abilityDefs.AbilityMod)
    if abilityMod.InitialSetup then
        local params = abilityMod.InitialSetup(params, abilityDefs, Players.LocalPlayer)
    end
    
end

--// Activate --------------------------------------------------------------------------------------------------------
function MeleeAttack.Activate(params, abilityDefs)

    params.CanRun = false

    -- checks
    if params.KeyState == "InputEnded" then return end
    if not Cooldown.Server_IsCooled(params) then return end
    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then return end

    params.CanRun = true

    -- get player and character
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then return end
    local initCharacter = initPlayer.Character
    if not initCharacter then return end


    local abilityMod = require(abilityDefs.AbilityMod)

    -- set cooldown and input block
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
    BlockInput.AddBlock(params.InitUserId, "MeleeAttack", abilityMod.InputBlockTime)

    -- server start
    if abilityMod.Server_Start then
        params = abilityMod.Server_Start(params, abilityDefs, initPlayer)
    end

    -- hitbox
	local hitBox = Instance.new("Part")
    hitBox.CanCollide = false
    hitBox.Massless = true
	hitBox.Size = abilityMod.HitboxSize
	hitBox.Transparency = 1
    hitBox.CFrame = initCharacter.HumanoidRootPart.CFrame:ToWorldSpace(abilityMod.HitboxOffset)
	hitBox.Parent = Workspace.ServerHitboxes[params.InitUserId]

    local newWeld = Instance.new("Weld")
	newWeld.C1 =  abilityMod.HitboxOffset
	newWeld.Part0 = initPlayer.Character.HumanoidRootPart
	newWeld.Part1 = hitBox
	newWeld.Parent = hitBox

    hitBox.Touched:Connect(function() end)

    spawn(function()

        if abilityMod.HitDelay > 0 then wait(abilityMod.HitDelay) end

        if abilityMod.Hitbox_Start then
            abilityMod.Hitbox_Start(params, abilityDefs, initPlayer, hitBox)
        end

        local hit = hitBox:GetTouchingParts()
        local hitCharacters = {}
        for _, part in pairs(hit) do
            if part.Parent:FindFirstChild("Humanoid") then
                hitCharacters[part.Parent] = true
            end
        end

        for character, _ in pairs(hitCharacters) do
            local thisPlayer = utils.GetPlayerFromCharacter(character)
            if thisPlayer ~= initPlayer then
                abilityMod.HitCharacter(params, abilityDefs, initPlayer, character, hitBox)
            end
        end

        hitBox.Touched:Connect(function(part)
            if part.Parent:FindFirstChild("Humanoid") then
                if not hitCharacters[part.Parent] then
                    hitCharacters[part.Parent] = true
                    abilityMod.HitCharacter(params, abilityDefs, initPlayer, part.Parent, hitBox)
                end
            end
        end)

        wait(abilityMod.HitboxDestroyTime)
        hitBox:Destroy()

    end)

end

--// Execute --------------------------------------------------------------------------------------------------------
function MeleeAttack.Execute(params, abilityDefs)

    --print("YESSS!", params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then return end

    local abilityMod = require(abilityDefs.AbilityMod)

    abilityMod.Client_Start(params, abilityDefs, initPlayer)

end

return MeleeAttack