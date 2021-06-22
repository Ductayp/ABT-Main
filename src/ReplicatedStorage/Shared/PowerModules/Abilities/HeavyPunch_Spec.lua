-- Heavy Punch Ability
-- PDab
-- 12-1-2020

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local RayHitbox = require(Knit.PowerUtils.RayHitbox)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)


local ANIMATION_DELAY = .3

local HeavyPunch = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function HeavyPunch.Initialize(params, abilityDefs)

	-- checks
	if params.KeyState == "InputBegan" then params.CanRun = true end
    if params.KeyState == "InputEnded" then params.CanRun = false return end
    if not Cooldown.Client_IsCooled(params) then params.CanRun = false return end
    if not Cooldown.Server_IsCooled(params) then params.CanRun = false return end
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then params.CanRun = false return end
    end

    Cooldown.Client_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
end

--// Activate
function HeavyPunch.Activate(params, abilityDefs)

	-- checks
	if params.KeyState == "InputBegan" then params.CanRun = true end
    if params.KeyState == "InputEnded" then params.CanRun = false return end
    if not Cooldown.Server_IsCooled(params) then params.CanRun = false return end
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then params.CanRun = false return end
    end

    Cooldown.Server_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "HeavyPunch", 1)

    HeavyPunch.Run_Server(params, abilityDefs)
end

--// Execute
function HeavyPunch.Execute(params, abilityDefs)
	HeavyPunch.Run_Clients(params, abilityDefs)
end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function HeavyPunch.Run_Server(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then return end

    Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].HeavyPunch_Short:Play()
    
	-- clone out a new hitpart
	local hitPart = Instance.new("Part")
    hitPart.CanCollide = false
    hitPart.Massless = true
	hitPart.Size = Vector3.new(5,5,7)
	hitPart.Transparency = 1
	hitPart.Name = "HeavyPunch_Spec"
	hitPart.Parent = Workspace.ServerHitboxes[params.InitUserId]
    Debris:AddItem(hitPart, 2)
	
	local newWeld = Instance.new("Weld")
	newWeld.C1 =  CFrame.new(0, 0, 3)
	newWeld.Part0 = initPlayer.Character.HumanoidRootPart
	newWeld.Part1 = hitPart
	newWeld.Parent = hitPart

    hitPart.Touched:Connect(function() end)

    spawn(function()
        wait(ANIMATION_DELAY)

        local hitParts = hitPart:GetTouchingParts()
        local hitCharacters = {}
        for _, part in pairs(hitParts) do
            if part.Parent:FindFirstChild("Humanoid") then
                hitCharacters[part.Parent] = true
            end
        end

        for character, _ in pairs(hitCharacters) do
            local thisPlayer = utils.GetPlayerFromCharacter(character)
            if thisPlayer ~= initPlayer then
                Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)
            end
        end
    end)

end

function HeavyPunch.Run_Clients(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then return end

    wait(ANIMATION_DELAY)

	WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, abilityDefs.Sound)

end

return HeavyPunch


