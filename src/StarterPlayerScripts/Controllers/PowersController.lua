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

-- instance references

--// InitializePower
function PowersController:InitializePower(params)

    params.SystemStage = "Intialize"
    params.PowerID = ReplicatedStorage.ReplicatedPlayerData[Players.localPlayer.UserId].CurrentPower.Value 
    local powerModule = require(Knit.Powers[params.PowerID])

    -- if we find the powerModule, then run its INITIALIZE stage
    if powerModule then
        local params = powerModule.Manager(Players.localPlayer,params)
    else 
        return
    end

    -- if INITIALIZE stage return CanRun == true then we fire it off the the server
    if params.CanRun then
        PowersService:ActivatePower(params)
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

--// KnitStart
function PowersController:KnitStart()

    PowersService.ExecutePower:Connect(function(initPlayer,params)
        self:ExecutePower(initPlayer,params)
    end)

end

--// KnitInit
function PowersController:KnitInit()

end

return PowersController
