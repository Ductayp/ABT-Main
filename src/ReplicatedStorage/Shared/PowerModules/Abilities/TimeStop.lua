-- Time Stop
-- PDab
-- 11/25/2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService('Players')

-- Knits and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)

local TimeStop = {}

local effectDelay = 2

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function TimeStop.Initialize(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
	end

	-- check cooldown
	if not Cooldown.Client_IsCooled(params) then
		params.CanRun = false
		return
    end

    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end
    
    --[[
    -- run client
    spawn(function()
        TimeStop.Run_Client(params, abilityDefs)
    end)
    ]]--

end

--// Activate
function TimeStop.Activate(params, abilityDefs)

    -- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
	end

    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end

	-- check cooldown
	if not Cooldown.Server_IsCooled(params) then
		print("not cooled down")
		params.CanRun = false
		return
	end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "TimeStop", 3)

    -- run server
    spawn(function()
        TimeStop.Run_Server(params, abilityDefs)
    end)
    
end

--// Execute
function TimeStop.Execute(params, abilityDefs)

    --[[
	if Players.LocalPlayer.UserId == params.InitUserId then
		--print("Players.LocalPlayer == initPlayer: DO NOT RENDER")
		return
    end
    ]]--
    
    -- run client
    spawn(function()
        TimeStop.Run_Client(params, abilityDefs)
    end)

end

--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

--// ACTIVATE ----------------------------------
function TimeStop.Run_Server(params, abilityDefs)

    wait(effectDelay)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- apply color shift to the initPlayer
    require(Knit.Shared.PowerModules.HitEffects.ColorShift).Server_ApplyEffect(initPlayer, initPlayer.Character, {Duration = 8})

    -- hit all players in range, subject to immunity
    for _, player in pairs(game.Players:GetPlayers()) do
        if player:DistanceFromCharacter(initPlayer.Character.Head.Position) <= abilityDefs.Range then
            if player ~= initPlayer then
                Knit.Services.PowersService:RegisterHit(initPlayer, player.Character, abilityDefs)
            end
        end
    end

    -- hit all Mobs in range
    for _,mob in pairs(Knit.Services.MobService.SpawnedMobs) do
        if initPlayer:DistanceFromCharacter(mob.Model.HumanoidRootPart.Position) <= abilityDefs.Range then
            Knit.Services.PowersService:RegisterHit(initPlayer, mob.Model, abilityDefs)
        end
    end

end


--// Main Effects
function TimeStop.Run_Client(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- play animations
    ManageStand.PlayAnimation(params, "TimeStop")
    ManageStand.Aura_On(params, 6)

    -- play the sound
    WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, abilityDefs.Sounds.TimeStop)

    -- get Localplayer ping
    local ping = Knit.Controllers.PlayerUtilityController:GetPing()

    --wait for animation and audio
    if params.SystemStage == "Initialize" then
        wait(effectDelay + ping)
    else
        wait(effectDelay - ping)
    end

    --[[
    -- color shift effect for all players in range
    for _, player in pairs(game.Players:GetPlayers()) do
        if player:DistanceFromCharacter(initPlayer.Character.Head.Position) <= abilityDefs.Range then
            spawn(function()
                local colorCorrection = Lighting:FindFirstChild("ColorCorrection")
                local originalContrast = colorCorrection.Contrast
                local newColorCorrection = colorCorrection:Clone()
                newColorCorrection.Name = "newColorCorrection"
                newColorCorrection.Parent = Lighting
        
                local colorTween1 = TweenService:Create(newColorCorrection, TweenInfo.new(.5), {Contrast = -3})
                colorTween1:Play()
        
                colorCorrection.Enabled = false
        
                wait(abilityDefs.Duration)
        
                local colorTween2 = TweenService:Create(newColorCorrection, TweenInfo.new(.5), {Contrast = originalContrast})
                colorTween2:Play()

                wait(.5)

                newColorCorrection:Destroy()
                colorCorrection.Enabled = true
                
            end)
        end
    end
    ]]--

    -- if this is the initPlayer, then do colorshift for them
    if Players.LocalPlayer.UserId == params.InitUserId then

    end

    -- animate spheres
    local sphereParams = {}
    sphereParams.CFrame = initPlayer.Character.HumanoidRootPart.CFrame
    sphereParams.Size = Vector3.new(1,1,1)
    sphereParams.Shape = "Ball"
    sphereParams.Parent = workspace.RenderedEffects
    sphereParams.Anchored = true
    sphereParams.CanCollide = false
    sphereParams.Transparency = -.5
    sphereParams.Material = Enum.Material.ForceField
    sphereParams.CastShadow = false

    local sphere1 = utils.EasyInstance("Part", sphereParams)
    local sphere2 = utils.EasyInstance("Part", sphereParams)
    local sphere3 = utils.EasyInstance("Part", sphereParams)

    sphere1.Color = Color3.new(255, 7, 160)
    sphere2.Color = Color3.new(2, 243, 255)
    sphere3.Color = Color3.new(255, 255, 2)
    
    Debris:AddItem(sphere1, abilityDefs.Duration)
    Debris:AddItem(sphere2, abilityDefs.Duration)
    Debris:AddItem(sphere3, abilityDefs.Duration)

    spawn(function()
        local size = abilityDefs.Range * 2

        local tweenInfo = TweenInfo.new(
            1, -- Time
            Enum.EasingStyle.Linear, -- EasingStyle
            Enum.EasingDirection.In -- EasingDirection
        )

        local sphereTween1 = TweenService:Create(sphere1,tweenInfo,{Size = Vector3.new(size,size,size)})
        local sphereTween2 = TweenService:Create(sphere2,tweenInfo,{Size = Vector3.new(size,size,size)})
        local sphereTween3 = TweenService:Create(sphere3,tweenInfo,{Size = Vector3.new(size,size,size)})
        sphereTween1:Play()
        wait(.005)
        sphereTween2:Play()
        wait(.005)
        sphereTween3:Play()

        wait(2)

        local tweenInfo = TweenInfo.new(
            .25, -- Time
            Enum.EasingStyle.Linear, -- EasingStyle
            Enum.EasingDirection.Out -- EasingDirection
        )

        local sphereTween4 = TweenService:Create(sphere1,tweenInfo,{Size = Vector3.new(1,1,1)})
        local sphereTween5 = TweenService:Create(sphere2,tweenInfo,{Size = Vector3.new(1,1,1)})
        local sphereTween6 = TweenService:Create(sphere3,tweenInfo,{Size = Vector3.new(1,1,1)})

        sphereTween6.Completed:Connect(function(playbackState)
            if playbackState == Enum.PlaybackState.Completed then
                sphere1:Destroy()
                sphere2:Destroy()
                sphere3:Destroy()
            end
        end)


        sphereTween4:Play()
        wait(.005)
        sphereTween5:Play()
        wait(.005)
        sphereTween6:Play()
    end)



end


return TimeStop