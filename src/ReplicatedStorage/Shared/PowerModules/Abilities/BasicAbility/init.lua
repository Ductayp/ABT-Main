-- BasicAttack

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local MobilityLock = require(Knit.PowerUtils.MobilityLock)
local BlockInput = require(Knit.PowerUtils.BlockInput)

local BasicAttack = {}

------------------------------------------------------------------------------------------------------------------------------
--// Initialize --------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
function BasicAttack.Initialize(params, abilityDefs)

	-- checks
	if params.KeyState == "InputBegan" then params.CanRun = true end
    if params.KeyState == "InputEnded" then params.CanRun = false return end
    if not Cooldown.Client_IsCooled(params) then params.CanRun = false return end
    if not Cooldown.Server_IsCooled(params) then params.CanRun = false return end
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then params.CanRun = false return end
    end

    local abilityMod = require(abilityDefs.AbilityMod)

    Cooldown.Client_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    MobilityLock.Client_AddLock(abilityMod.MobilityLockParams)

    --local playerPing = Knit.Controllers.PlayerUtilityController:GetPing()
    local playerPing = 0
    abilityMod.Client_Initialize(params, abilityDefs, playerPing)
    spawn(function()
        abilityMod.Client_Stage_1(params, abilityDefs, playerPing)
    end)
    
end

------------------------------------------------------------------------------------------------------------------------------
--// Activate ----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
function BasicAttack.Activate(params, abilityDefs)

	-- checks
	if params.KeyState == "InputBegan" then params.CanRun = true end
    if params.KeyState == "InputEnded" then params.CanRun = false return end
    if not Cooldown.Server_IsCooled(params) then params.CanRun = false return end
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then params.CanRun = false return end
    end

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then return end
    if not initPlayer.Character then return end

    local abilityMod = require(abilityDefs.AbilityMod)

    Cooldown.Server_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
    BlockInput.AddBlock(params.InitUserId, "BasicAbility", abilityMod.InputBlockTime)
    
    abilityMod.Server_Setup(params, abilityDefs, initPlayer)
    spawn(function()
        abilityMod.Server_Run(params, abilityDefs, initPlayer)
    end)

end

------------------------------------------------------------------------------------------------------------------------------
--// Execute -----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
function BasicAttack.Execute(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then return end

    local abilityMod = require(abilityDefs.AbilityMod)

    if initPlayer ~= Players.LocalPlayer then
        spawn(function()
            abilityMod.Client_Stage_1(params, abilityDefs)
        end)
    end
    
    abilityMod.Client_Stage_2(params, abilityDefs, initPlayer)

end

return BasicAttack