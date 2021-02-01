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


local TimeStop = {}

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
    


    --TimeStop.RenderEffects(params, abilityDefs)

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

    -- require toggles to be inactive, excluding "Q"
    if not AbilityToggle.RequireOff(params.InitUserId, abilityDefs.RequireToggle_Off) then
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

    -- set toggle
    AbilityToggle.QuickToggle(params.InitUserId, params.InputId, true)

    -- setup the hit
    TimeStop.CreateHitRadius(params, abilityDefs)

end

--// Execute
function TimeStop.Execute(params, abilityDefs)
	print(params)

	if Players.LocalPlayer.UserId == params.InitUserId then
		--print("Players.LocalPlayer == initPlayer: DO NOT RENDER")
		--return
    end
    
    TimeStop.RenderEffects(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

--// ACTIVATE ----------------------------------
function TimeStop.CreateHitRadius(params, abilityDefs)

    spawn(function()

        wait(1)

        -- get initPlayer
        local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    
        -- hit players: put all player within range inside a table, including the initPlayer
        local affectedPlayers = {}
        for _, targetPlayer in pairs(game.Players:GetPlayers()) do
            if targetPlayer:DistanceFromCharacter(initPlayer.Character.Head.Position) <= abilityDefs.Range then
                table.insert(affectedPlayers, targetPlayer)
            end
        end
        print("affectdPlayers", affectedPlayers)

        -- play ColorShift effect for all player within range, this happens before immunities
        for _,player in pairs(affectedPlayers) do
            print("this player is:", player)
            Knit.Services.PowersService:RegisterHit(initPlayer, player.Character, {ColorShift = abilityDefs.HitEffects.ColorShift})
        end

        -- remove any player that is immune to timestop
        for index,player in pairs(affectedPlayers) do
            local isImmune = require(Knit.StateModules.Immunity).Has_Immunity(player,"TimeStop")
            if isImmune then
                --table.remove(affectedPlayers, index)
            end
        end


        -- remove ColorShift
        local newHitEffects = {}
        for i,v in pairs(abilityDefs.HitEffects) do
            if i ~= "ColorShift" then
                newHitEffects[i] = v
            end
        end

        print(newHitEffects)


        -- play remainign effects on all players
        for _,player in pairs(affectedPlayers) do
            Knit.Services.PowersService:RegisterHit(initPlayer, player.Character, newHitEffects)
        end

        -- hit all Mobs in range
        for _,mob in pairs(Knit.Services.MobService.SpawnedMobs) do
            if initPlayer:DistanceFromCharacter(mob.Model.HumanoidRootPart.Position) <= abilityDefs.Range then
                Knit.Services.PowersService:RegisterHit(initPlayer, mob.Model, newHitEffects)
            end
        end
    
    end)
    
end


--// Main Effects
function TimeStop.RenderEffects(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    
    -- setup the stand, if its not there then quick render it
	local targetStand = workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		targetStand = ManageStand.QuickRender(params)
    end

    -- play animations
    ManageStand.PlayAnimation(params, "TimeStop")

    -- wait for animation
    wait(1)

    -- animate spehres
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

    local sphere1 = utils.EasyInstance("Part",sphereParams)
    local sphere2 = utils.EasyInstance("Part",sphereParams)
    local sphere3 = utils.EasyInstance("Part",sphereParams)

    sphere1.Color = Color3.new(255, 7, 160)
    sphere2.Color = Color3.new(2, 243, 255)
    sphere3.Color = Color3.new(255, 255, 2)
    
    Debris:AddItem(sphere1,abilityDefs.Duration)
    Debris:AddItem(sphere2,abilityDefs.Duration)
    Debris:AddItem(sphere3,abilityDefs.Duration)

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