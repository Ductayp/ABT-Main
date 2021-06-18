-- PowersController
-- PDab
-- 11/12/2020

--[[
    When a player presses a key that is bound to a power, it is first handled by PoweresController which then communicates to PowersServce
    before receiveing an event back which will then render the power for all players on the client side. 
    
    STEPS:
    1 - INTIALIZE: PowersController - handles initialization of the power, gather any data required such as mouse position
    2 - ACTIVATE: PowersService - receives infor from client, does sanity checks, triggers htiboxes, fires all clients to render effects
    3 - EXECUTE: PowersController - each clients is fired from the service to render all effects locally for each player
]]--

-- services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PowersController = Knit.CreateController { Name = "PowersController" }
local PowersService = Knit.GetService("PowersService")
local BlockInput = require(Knit.PowerUtils.BlockInput)
local utils = require(Knit.Shared.Utils)

-- this is the default render distance for effects. Only works if the sent effect has position data in its params
local defaultRenderDistance = 350

--// InitializePower
function PowersController:InitializePower(params)

    if BlockInput.IsBlocked(Players.LocalPlayer.UserId) then
        if params.KeyState == "InputBegan" then
            return
        end
    end

    local playerFolder = ReplicatedStorage.CurrentPowerData:FindFirstChild(Players.LocalPlayer.UserId)
    params.PowerID = playerFolder.Power.Value
    params.PowerRank = playerFolder.Rank.Value

    -- find the powerModule
    local powerModule
    local findModule = Knit.Powers:FindFirstChild(params.PowerID)
    if findModule then
        powerModule = require(Knit.Powers[params.PowerID])
    else
        warn("power doesnt exist")
        return
    end

    -- run its INITIALIZE stage
    params.SystemStage = "Initialize"
    params.CanRun = false
    params.InitUserId = Players.localPlayer.UserId
    local params = powerModule.Manager(params)

    -- if INITIALIZE stage returns CanRun == true then we fire it off the the server
    if params.CanRun then
        PowersService:ClientActivatePower(params)
    else
        return
    end
end

--// ExecutePower
function PowersController:ExecutePower(params)

    --print("execut power", params)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then return end

    local initCharacter = initPlayer.Character
    if not initCharacter then return end

    local thisCharacter = Players.LocalPlayer.Character
    if not thisCharacter then return end

    local distance = (initCharacter.HumanoidRootPart.Position - thisCharacter.HumanoidRootPart.Position).magnitude

    local effectRange
    if params.RenderRange then
        effectRange = params.RenderRange
    else
        effectRange = defaultRenderDistance
    end

    if distance > effectRange then return end

    local powerModule = require((Knit.Powers[params.PowerID]))
    params.SystemStage = "Execute"
    powerModule.Manager(params)
end

--// RenderEffect -- render general effects
function PowersController:RenderHitEffect(effect, params)
    local effectModule = require(Knit.HitEffects[effect])
    effectModule.Client_RenderEffect(params)
end

--// RenderAbilityEffect
function PowersController:RenderAbilityEffect(abilityModule, functionName, params)

    --print("PowersController:RenderAbilityEffect", abilityModule, functionName, params)

    if not Players.LocalPlayer.Character then return end

    -- render distance check
    if params.Position then
        local effectRange
        if params.RenderRange then
            effectRange = params.RenderRange
        else
            effectRange = defaultRenderDistance
        end


        local distance = (Players.LocalPlayer.Character.HumanoidRootPart.Position - params.Position).magnitude
        if distance > effectRange then 
            return
        end
    end

    local thisModule = require(abilityModule)
    thisModule[functionName](params)
end

--// RenderExistingStands
function PowersController:RenderExistingStands()
    
    for _, folder in pairs(ReplicatedStorage.PowerStatus:GetChildren()) do

        -- only run this on other players
        if folder.Name ~= Players.LocalPlayer.UserId then

            local equippedStand = folder:FindFirstChild("EquippedStand")
            if equippedStand then
                local thisStand = Workspace.PlayerStands[folder.Name]:FindFirstChildWhichIsA("Model")
                if not thisStand then
                    local params = {}
                    params.InitUserId = folder.Name
                    params.StandModel = equippedStand.Value
                    require(Knit.Abilities.ManageStand).QuickRender(params)
                end
            end
        end
    end
end 

--// PowerChanged
function PowersController:PowerChanged(targetPlayer, params)

    local character = targetPlayer.Character
    if character then
        for _, v in pairs(character:GetDescendants()) do
            local attribute = v:GetAttribute("StatusEffect")
            if attribute then
                v:Destroy()
            end
        end
    end

end

function PowersController:PlayerAdded(player)
    repeat wait() until player.character
    self:RenderExistingStands()

end

function PowersController:CharacterAdded(player)


end

--// KnitStart
function PowersController:KnitStart()


    PowersService.ExecutePower:Connect(function(initPlayer,params)
        self:ExecutePower(initPlayer,params)
    end)

    PowersService.RenderHitEffect:Connect(function(effect,params)
        self:RenderHitEffect(effect, params)
    end)

    PowersService.RenderAbilityEffect:Connect(function(abilityModule, functionName, params)
        self:RenderAbilityEffect(abilityModule, functionName, params)
    end)

    PowersService.PowerChanged:Connect(function(targetPlayer, params)
        self:PowerChanged(targetPlayer, params)
    end)

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

--// KnitInit
function PowersController:KnitInit()

end

return PowersController