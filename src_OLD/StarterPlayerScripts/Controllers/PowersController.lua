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
local BlockInput = require(Knit.Effects.BlockInput)
local utils = require(Knit.Shared.Utils)

--// InitializePower
function PowersController:InitializePower(params)

    if BlockInput.IsBlocked(Players.LocalPlayer) then
        return
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
        print("power doesnt exist")
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
function PowersController:RenderEffect(effect,params)

    local effectModule = require(Knit.Effects[effect])
    effectModule.Client_RenderEffect(params)
end

--// QuickRenderStands
function PowersController:QuickRenderStand(params)

    print(params)

    --check for initplayers stand tracker
    local standTracker = Workspace.PlayerStands.StandTracker:FindFirstChild(params.InitUserId)

    -- if the standTracker exists, there should be a stand, lets try to find it
    local doRender = true -- start with true and prove it. Set to false if we find the stand
    if standTracker then
        playerStandFolder =  Workspace.PlayerStands:FindFirstChild(params.InitUserId)
        if playerStandFolder then
            local playerStand = playerStandFolder:FindFirstChildWhichIsA("Model")
            if playerStand then
                doRender = false
            end
        end
    end

    -- if doRedner is still true, QuickRender the stand
    if doRender then
        require(Knit.Abilities.ManageStand).QuickRender(params)
    end

end

--// RenderExistingStands
function PowersController:RenderExistingStands()
    
    for _, folder in pairs(Workspace.PlayerStands:GetChildren()) do

        -- only run this on other players
        if folder.Name ~= Players.LocalPlayer.UserId then

            local equippedStand = folder:FindFirstChild("EquippedStand")
            if equippedStand then
                local thisStand = folder:FindFirstChildWhichIsA("Model")
                if not thisStand then
                    print("WE NEED TO RENDER A STAND!!!!")
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

    PowersService.RenderEffect:Connect(function(effect,params)
        self:RenderEffect(effect,params)
    end)

end

--// KnitInit
function PowersController:KnitInit()

end

return PowersController