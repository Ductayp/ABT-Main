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

--// InitializePower
function PowersController:InitializePower(params)

    if BlockInput.IsBlocked(Players.LocalPlayer.UserId) then
        if params.KeyState == "InputBegan" then
            return
        end
    end

    local powerData = PowersService:GetCurrentPower(Players.LocalPlayer)
    params.PowerID = powerData.Power
    params.PowerRarity = powerData.Rarity

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
                    params = {}
                    params.InitUserId = folder.Name
                    params.StandModel = equippedStand.Value
                    require(Knit.Abilities.ManageStand).QuickRender(params)
                end
            end
        end
    end
end 

--// KnitStart
function PowersController:KnitStart()

    -- redner existing stands on join
    spawn(function()
        self:RenderExistingStands()
        wait(10)
        self:RenderExistingStands()
        wait(60)
        self:RenderExistingStands()
    end)
    
    PowersService.ExecutePower:Connect(function(initPlayer,params)
        self:ExecutePower(initPlayer,params)
    end)

    PowersService.RenderHitEffect:Connect(function(effect,params)
        self:RenderHitEffect(effect, params)
    end)

    PowersService.RenderAbilityEffect:Connect(function(abilityModule, functionName, params)
        self:RenderAbilityEffect(abilityModule, functionName, params)
    end)

end

--// KnitInit
function PowersController:KnitInit()

end

return PowersController