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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PowersController = Knit.CreateController { Name = "PowersController" }
local PowersService = Knit.GetService("PowersService")
local BlockInput = require(Knit.Effects.BlockInput)

--// InitializePower
function PowersController:InitializePower(params)

    if BlockInput.IsBlocked(Players.LocalPlayer) then
        return
    end

    params.SystemStage = "Intialize"
    local powerData = PowersService:GetCurrentPower(Players.LocalPlayer)
    params.PowerID = powerData.Power
    params.PowerRarity = powerData.Rarity

    -- if we find the powerModule, then run its INITIALIZE stage
    local powerModule
    local findModule = Knit.Powers:FindFirstChild(params.PowerID)
    if findModule then
        powerModule = require(Knit.Powers[params.PowerID])
    else
        print("power doesnt exist")
        return
    end
    local params = powerModule.Manager(Players.localPlayer,params)

    -- if INITIALIZE stage return CanRun == true then we fire it off the the server
    if params.CanRun then
        PowersService:ClientActivatePower(params)
    else
        return
    end
end

--// ExecutePower
function PowersController:ExecutePower(initPlayer,params)
    
    params.SystemStage = "Execute"
    local powerModule = require((Knit.Powers[params.PowerID]))
    powerModule.Manager(initPlayer,params)
end

--// RenderEffect -- render general effects
function PowersController:RenderEffect(effect,params)
    local effectModule = require(Knit.Effects[effect])
    effectModule.Client_RenderEffect(params)
end

--// RenderExistingStands
function PowersController:RenderExistingAbility(targetPlayer,params)
    self:ExecutePower(targetPlayer,params)
end 

--// KnitStart
function PowersController:KnitStart()

    PowersService.ExecutePower:Connect(function(initPlayer,params)
        self:ExecutePower(initPlayer,params)
    end)

    PowersService.RenderEffect:Connect(function(effect,params)
        self:RenderEffect(effect,params)
    end)

    PowersService.RenderExistingStands:Connect(function(targetPlayer,params)
        local standFolder = workspace:waitForChild("PlayerStands") -- this wait is here just to be sure the workspace folder has fullyloaded for the new player
        self:RenderExistingAbility(targetPlayer,params)
    end)

end

--// KnitInit
function PowersController:KnitInit()

end

return PowersController
